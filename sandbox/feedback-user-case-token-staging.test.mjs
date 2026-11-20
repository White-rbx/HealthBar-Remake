import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {CASE_TOKEN_ROUTES,createUserCaseTokenHandler} from './feedback-user-case-token-staging.mjs';

const origin='https://qa.invalid';
const id='11111111-2222-4333-8444-555555555555';
const otherId='22222222-2222-4333-8444-555555555555';
const receipt='a'.repeat(64),otherReceipt='b'.repeat(64);
const digest=x=>createHash('sha256').update(x).digest('hex');

function fixture({allow=true,rateThrows=false,dbFails=false}={}){
 let now=1795100000;
 const tokens=new Map(),links=new Map(),queries=[];
 const cases=new Map([
  [id,{id,kind:'feedback',status:'reviewing',topic:'Test feedback',public_note:'',
   updated_unix:1795100000,revision:0,receipt_hash:digest(receipt),removed:0,
   description:'PRIVATE',admin_note:'NEVER RETURN',claimed_user_id:'999999'}],
  [otherId,{id:otherId,kind:'feedback',status:'approved',topic:'Older feedback',public_note:'Reviewed',
   updated_unix:1795099999,revision:2,receipt_hash:digest(otherReceipt),removed:0,
   description:'SECRET',admin_note:'PRIVATE',claimed_user_id:'999999'}],
 ]);
 const DB={
  prepare(sql){
   queries.push(sql);
   return {bind(...args){
    return {
     async first(){
      if(dbFails)throw Error('database unavailable');
      if(sql.startsWith('SELECT id FROM asc_feedback_cases')){
       const row=cases.get(args[0]);
       return row && row.receipt_hash===args[1] && row.kind==='feedback' && row.removed===0?{id:row.id}:null;
      }
      if(sql.startsWith('SELECT token_hash FROM asc_user_case_tokens')){
       const row=tokens.get(args[0]);
       return row&&row.revoked_unix===null?{token_hash:args[0]}:null;
      }
      if(sql.startsWith('SELECT token_hash FROM asc_user_case_links')){
       const link=links.get(args[0]);return link?{token_hash:link}:null;
      }
      throw Error('Unexpected query: '+sql);
     },
     async all(){
      if(dbFails)throw Error('database unavailable');
      if(!sql.startsWith('SELECT c.id'))throw Error('Unexpected SELECT: '+sql);
      return {results:[...cases.values()].filter(c=>links.get(c.id)===args[0]
        && c.removed===0&&c.kind==='feedback').sort((a,b)=>b.updated_unix-a.updated_unix)};
     },
     async run(){
      if(dbFails)throw Error('database unavailable');
      if(sql.startsWith('INSERT INTO asc_user_case_tokens')){
       if(tokens.has(args[0]))throw Error('collision');
       tokens.set(args[0],{created_unix:args[1],revoked_unix:null});return {meta:{changes:1}};
      }
      if(sql.startsWith('INSERT OR IGNORE INTO asc_user_case_links')){
       if(links.has(args[0]))return {meta:{changes:0}};
       links.set(args[0],args[1]);return {meta:{changes:1}};
      }
      if(sql.startsWith('UPDATE asc_user_case_links SET')){
       if(links.get(args[2])!==args[3])return {meta:{changes:0}};
       links.set(args[2],args[0]);return {meta:{changes:1}};
      }
      if(sql.startsWith('UPDATE asc_user_case_tokens SET')){
       const item=tokens.get(args[1]);
       if(!item||item.revoked_unix!==null)return {meta:{changes:0}};
       item.revoked_unix=args[0];return {meta:{changes:1}};
      }
      throw Error('Unexpected mutation: '+sql);
     }
    };
   }};
  }
 };
 const handler=createUserCaseTokenHandler({
  clock:()=>now,
  checkRateLimit:async()=>{if(rateThrows)throw Error('rate unavailable');return allow;}
 });
 async function send(action,body={},headers={}){
  const request=new Request(origin+CASE_TOKEN_ROUTES[action],{
   method:'POST',headers:{'content-type':'application/json',...headers},
   body:JSON.stringify(body),
  });
  const response=await handler(request,{DB});
  return {code:response.status,body:await response.json(),headers:response.headers};
 }
 return {send,handler,tokens,links,cases,queries,DB,setNow:n=>{now=n;}};
}
const start=(f,caseId=id,key=receipt)=>f.send('create',{id:caseId,receipt:key,consent:true});

test('first Feedback requires explicit opt-in and private receipt, never claimed UserId',async()=>{
 const f=fixture();
 assert.equal((await f.send('create',{id,receipt,consent:false})).code,400);
 assert.equal((await f.send('create',{id,receipt:'c'.repeat(64),consent:true})).code,404);
 assert.equal((await f.send('create',{id,receipt,consent:true,userId:'999999'})).code,400);
 assert.equal(f.tokens.size,0);
 const r=await start(f);
 assert.equal(r.code,201);
 assert.equal(r.body.expiresAt,null);
 assert.equal(r.body.revocable,true);
 assert.equal(r.body.showOnlyOnce,true);
 assert.equal(r.body.identityVerified,false);
 assert.match(r.body.token,/^USERCASETOKEN_01_[A-Za-z0-9_-]{43}-[a-f0-9]{8}$/);
 assert.equal(f.tokens.size,1);
 assert.equal(f.tokens.has(digest(r.body.token)),true);
 assert.equal(f.tokens.has(r.body.token),false);
 assert.equal(f.links.get(id),digest(r.body.token));
 assert.equal(r.headers.get('cache-control'),'private, no-store');
 assert.equal(r.headers.get('access-control-allow-origin'),null);
});
test('token is a case-scoped capability: rejoin can list linked cases without UserId or HWID',async()=>{
 const f=fixture(),issued=(await start(f)).body.token;
 const a=await f.send('list',{token:issued});
 const b=await f.send('list',{token:issued});
 assert.equal(a.code,200);
 assert.deepEqual(a.body,b.body);
 assert.equal(a.body.delivery,'user-case-token');
 assert.equal(a.body.identityVerified,false);
 assert.deepEqual(a.body.cases.map(c=>c.id),[id]);
 const dump=JSON.stringify(a.body);
 for(const leak of ['receipt','999999','description','NEVER RETURN','owner_sub','token_hash','PRIVATE'])
  assert.ok(!dump.includes(leak),leak);
 assert.equal((await f.send('list',{userId:'999999',username:'any'})).code,400);
 assert.equal((await f.send('list',{token:issued.toLowerCase()})).code,404);
});
test('one token can attach a new Feedback only with its own private Receipt',async()=>{
 const f=fixture(),token=(await start(f)).body.token;
 assert.equal((await f.send('attach',{token,id:otherId,receipt:'a'.repeat(64)})).code,404);
 assert.equal((await f.send('attach',{token,id:otherId,receipt:otherReceipt})).code,200);
 assert.deepEqual((await f.send('list',{token})).body.cases.map(c=>c.id),[id,otherId]);
 assert.equal((await f.send('attach',{token,id:otherId,receipt:otherReceipt})).code,200);
 assert.equal((await f.send('create',{id,receipt,consent:true})).code,409);
});
test('revoke is explicit, permanent, and disables lookup and attaching',async()=>{
 const f=fixture(),token=(await start(f)).body.token;
 assert.equal((await f.send('revoke',{token,confirm:false})).code,400);
 assert.equal((await f.send('list',{token})).code,200);
 assert.deepEqual((await f.send('revoke',{token,confirm:true})).body,{ok:true,revoked:true,irreversible:true});
 assert.equal((await f.send('list',{token})).code,404);
 assert.equal((await f.send('attach',{token,id:otherId,receipt:otherReceipt})).code,404);
 assert.equal((await f.send('revoke',{token,confirm:true})).code,404);
 // A person retaining the original private Case ID + Receipt can issue a replacement.
 const replaced=await start(f);
 assert.equal(replaced.code,201);
 assert.notEqual(replaced.body.token,token);
 assert.equal((await f.send('list',{token:replaced.body.token})).code,200);
});
test('separate bearer token cannot access other token cases',async()=>{
 const f=fixture(),token1=(await start(f)).body.token;
 const token2=(await start(f,otherId,otherReceipt)).body.token;
 assert.deepEqual((await f.send('list',{token:token1})).body.cases.map(x=>x.id),[id]);
 assert.deepEqual((await f.send('list',{token:token2})).body.cases.map(x=>x.id),[otherId]);
 assert.equal((await f.send('attach',{token:token1,id:otherId,receipt:otherReceipt})).code,409);
});
test('Spam Mail never reveals private status or notes and removed cases disappear',async()=>{
 const f=fixture(),token=(await start(f)).body.token;
 f.cases.get(id).status='spam_mail';
 f.cases.get(id).public_note='SECRET MODERATOR TEXT';
 assert.deepEqual((await f.send('list',{token})).body.cases.map(c=>[c.status,c.publicNote]),[['reviewing','']]);
 f.cases.get(id).removed=1;
 assert.deepEqual((await f.send('list',{token})).body.cases,[]);
});
test('fail-closed on network rate-limit, database errors, cookie/origin/query and invalid token',async()=>{
 const f=fixture();
 assert.equal((await fixture({allow:false}).send('create',{id,receipt,consent:true})).code,429);
 assert.equal((await fixture({rateThrows:true}).send('create',{id,receipt,consent:true})).code,503);
 assert.equal((await fixture({dbFails:true}).send('create',{id,receipt,consent:true})).code,503);
 assert.equal((await f.send('list',{token:'USERCASETOKEN_01_'+('a'.repeat(43))+'-00000000'})).code,404);
 assert.equal((await f.send('create',{id,receipt,consent:true},{origin:'https://evil.invalid'})).code,403);
 assert.equal((await f.send('create',{id,receipt,consent:true},{cookie:'sid=malicious'})).code,403);
 const req=new Request(origin+CASE_TOKEN_ROUTES.list+'?token=leak',{method:'POST'});
 assert.equal((await f.handler(req,{DB:f.DB})).status,404);
 assert.equal((await f.handler(new Request(origin+CASE_TOKEN_ROUTES.list,{method:'GET'}),{DB:f.DB})).status,405);
});
test('no HWID, LocalPlayer, admin keys or automatic UserId ownership mapping in handler',()=>{
 const src=readFileSync('sandbox/feedback-user-case-token-staging.mjs','utf8');
 assert.doesNotMatch(src,/getgenv\(|\.UserId|\.Name\b|asc_presence_sessions|asc_usage_live_sessions/);
 assert.doesNotMatch(src,/INSERT[^\n]*claimed_user_id/);
 assert.match(src,/crypto\.getRandomValues\(new Uint8Array\(32\)\)/);
});
