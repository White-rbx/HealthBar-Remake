import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {CASE_DELIVERY_POLL,CASE_DELIVERY_LINK,createCaseDeliveryHandler} from './feedback-case-delivery-staging.mjs';
const site='https://synthetic.invalid';
const uuid='11111111-2222-4333-8444-555555555555';
const id2='22222222-2222-4333-8444-555555555555';
const receipt='a'.repeat(64);
const hash=s=>createHash('sha256').update(s).digest('hex');
function mock({subject='1199',active=true,verified=true,method='roblox_oidc_device_verified',expiresAt=1795100500,
              allow=true,dbFail=false,sessionThrows=false}={}){
 let now=1795100000;const owners=new Map(),calls={auth:0,limit:0,sql:[],reads:0,writes:0};
 const cases=new Map([
  [uuid,{id:uuid,kind:'feedback',status:'denied',topic:'QA test',updated_unix:1795099000,
    revision:0,public_note:'Reviewed',admin_note:'HIDDEN',removed:0,receipt_hash:hash(receipt),claimed_user_id:'1199'}],
  [id2,{id:id2,kind:'feedback',status:'approved',topic:'Other account',updated_unix:1795099001,
    revision:0,public_note:'Ok',admin_note:'PRIVATE',removed:0,receipt_hash:hash('b'.repeat(64)),claimed_user_id:'1199'}]
 ]);
 const DB={
  prepare(sql){
   calls.sql.push(sql);
   return {bind(...args){
    return {
     async all(){
      calls.reads++;
      if(dbFail)throw Error('DB failed');
      if(!sql.includes('FROM asc_feedback_case_owners'))throw Error('Unexpected SELECT: '+sql);
      const rows=[...cases.values()].filter(c=>owners.get(c.id)===args[0]&&c.removed===0&&c.kind==='feedback')
        .sort((a,b)=>b.updated_unix-a.updated_unix||a.id.localeCompare(b.id));
      return {results:rows};
     },
     async first(){
      calls.reads++;
      if(dbFail)throw Error('DB failed');
      if(!sql.includes('SELECT owner_sub'))throw Error('Unexpected lookup');
      return owners.has(args[0])?{owner_sub:owners.get(args[0])}:null;
     },
     async run(){
      calls.writes++;
      if(dbFail)throw Error('DB failed');
      if(!sql.startsWith('INSERT OR IGNORE INTO asc_feedback_case_owners'))throw Error('Unexpected write');
      const [owner,,id,digest]=args;const c=cases.get(id);
      if(c && c.receipt_hash===digest && c.kind==='feedback' && c.removed===0 && !owners.has(id))
       owners.set(id,owner);
      return {meta:{changes:owners.get(id)===owner?1:0}};
     }
    };
   }};
  }
 };
 const handler=createCaseDeliveryHandler({
  resolveActivePrincipal:async()=>{calls.auth++;if(sessionThrows)throw Error('not verified');return {subject,active,verified,method,expiresAt,scope:'cases:read'};},
  checkRateLimit:async()=>{calls.limit++;return allow;},
  clock:()=>now
 });
 const request=(path,body={},h={})=>new Request(site+path,{method:'POST',headers:{'content-type':'application/json',...h},body:JSON.stringify(body)});
 const send=async (path,body={},headers={})=>{const res=await handler(request(path,body,headers),{DB});return {code:res.status,headers:res.headers,json:await res.json()};};
 return {send,handler,cases,owners,calls,DB,request};
}
test('closed unless independently verified ACTIVE OAuth-device session; no analytics shortcuts',async()=>{
 for(const opts of [{verified:false},{active:false},{method:'claimed_user_id'},{expiresAt:1795099999},{subject:'invalid user id'},{sessionThrows:true}]){
  const f=mock(opts),r=await f.send(CASE_DELIVERY_POLL);
  assert.ok([401,503].includes(r.code));
  assert.equal(f.calls.reads,0);
 }
});
test('spoofing UserId, claimed id, cookie, Origin or auth header never authenticates',async()=>{
 const f=mock({verified:false});
 for(const headers of [{'X-Roblox-UserId':'1199'},{'authorization':'Bearer forged'},{'origin':site},{cookie:'fake=1'}]){
  const r=await f.send(CASE_DELIVERY_POLL,{},headers);
  assert.equal(r.code,401);
 }
 assert.equal(f.calls.reads,0);
});
test('unlinked claimed_user_id does NOT disclose cases even when verified',async()=>{
 const f=mock(),r=await f.send(CASE_DELIVERY_POLL);
 assert.equal(r.code,200);assert.deepEqual(r.json.cases,[]);
 assert.equal(r.json.serverVerified,true);
 assert.equal(r.headers.get('cache-control'),'private, no-store');
 assert.equal(r.headers.get('access-control-allow-origin'),null);
});
test('owner link requires BOTH authenticated session and matching private case Receipt',async()=>{
 const f=mock();
 assert.equal((await f.send(CASE_DELIVERY_LINK,{id:uuid,receipt:'b'.repeat(64)})).code,404);
 assert.equal(f.owners.size,0);
 const linked=await f.send(CASE_DELIVERY_LINK,{id:uuid,receipt});
 assert.equal(linked.code,200);assert.deepEqual(linked.json,{ok:true,linked:true});
 const r=await f.send(CASE_DELIVERY_POLL);
 assert.equal(r.json.cases.length,1);
 assert.equal(r.json.cases[0].status,'denied');
 const dump=JSON.stringify(r.json);
 for(const forbidden of ['receipt','admin_note','HIDDEN','claimed_user_id','1199','description','owner_sub'])
  assert.ok(!dump.includes(forbidden),forbidden);
});
test('rejoin: same trusted server subject can poll again without re-sending receipt',async()=>{
 const f=mock();
 await f.send(CASE_DELIVERY_LINK,{id:uuid,receipt});
 const first=(await f.send(CASE_DELIVERY_POLL)).json.cases;
 const second=(await f.send(CASE_DELIVERY_POLL)).json.cases;
 assert.equal(first[0].id,second[0].id);
 assert.equal(f.calls.writes,1);
});
test('other signed-in principal cannot see another account or steal linked case',async()=>{
 const f=mock();
 await f.send(CASE_DELIVERY_LINK,{id:uuid,receipt});
 const other=mock({subject:'8888'});
 other.owners.set(uuid,'1199');
 assert.deepEqual((await other.send(CASE_DELIVERY_POLL)).json.cases,[]);
 assert.equal((await other.send(CASE_DELIVERY_LINK,{id:uuid,receipt})).code,404);
});
test('removed and spam Mail stay private; no Admin routing or active users analytics',async()=>{
 const f=mock();
 await f.send(CASE_DELIVERY_LINK,{id:uuid,receipt});
 f.cases.get(uuid).status='spam_mail';f.cases.get(uuid).public_note='SECRET';
 assert.deepEqual((await f.send(CASE_DELIVERY_POLL)).json.cases.map(v=>[v.status,v.publicNote]),[['reviewing','']]);
 f.cases.get(uuid).removed=1;
 assert.deepEqual((await f.send(CASE_DELIVERY_POLL)).json.cases,[]);
 const src=readFileSync('sandbox/feedback-case-delivery-staging.mjs','utf8');
 assert.doesNotMatch(src,/asc_presence_sessions|asc_usage_live_sessions|/api/v1/admin/feedback/);
});
test('denied methods, unexpected fields, oversized body and missing D1 fail closed',async()=>{
 const f=mock();
 const bad=await f.handler(new Request(site+CASE_DELIVERY_POLL,{method:'GET'}),{DB:f.DB});
 assert.equal(bad.status,405);
 assert.equal((await f.send(CASE_DELIVERY_POLL,{userId:'1199'})).code,400);
 assert.equal((await f.send(CASE_DELIVERY_LINK,{id:uuid,receipt,claimedUserId:'1199'})).code,400);
 const missing=await f.handler(f.request(CASE_DELIVERY_POLL),{});
 assert.equal(missing.status,503);
 assert.equal((await f.send('/api/v1/admin/feedback/list')).code,404);
});
test('rate limiting, SQL failure and malformed session are never treated as empty authenticated results',async()=>{
 assert.equal((await mock({allow:false}).send(CASE_DELIVERY_POLL)).code,429);
 assert.equal((await mock({dbFail:true}).send(CASE_DELIVERY_POLL)).code,503);
});
test('review migration never auto-links claimed_user_id or changes Production schema',()=>{
 const sql=readFileSync('migrations/feedback_case_owner_links_STAGING_REVIEW_ONLY_20261119.sql','utf8');
 assert.match(sql,/CREATE TABLE IF NOT EXISTS asc_feedback_case_owners/);
 assert.match(sql,/owner_sub TEXT NOT NULL/);
 assert.match(sql,/ON DELETE CASCADE/);
 assert.doesNotMatch(sql,/INSERT INTO .*SELECT claimed_user_id|UPDATE asc_feedback_cases/i);
});
