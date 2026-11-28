import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {DatabaseSync} from 'node:sqlite';
import {CASE_TOKEN_ROUTES,createUserCaseTokenHandler} from './feedback-user-case-token-staging.mjs';

const origin='https://qa.invalid';
const id='11111111-2222-4333-8444-555555555555';
const otherId='22222222-2222-4333-8444-555555555555';
const receipt='a'.repeat(64),otherReceipt='b'.repeat(64);
const digest=x=>createHash('sha256').update(x).digest('hex');

const feedbackSchema=readFileSync(
 'migrations/feedback_release_additive_REVIEW_ONLY_20261117.sql','utf8'
).split('-- table: asc_feedback_followup_details_history')[0];
const tokenSchema=readFileSync(
 'migrations/feedback_user_case_token_STAGING_REVIEW_ONLY_20261120.sql','utf8'
);

function fixture({allow=true,rateThrows=false,dbFails=false}={}){
 const now=1795100000;
 const db=new DatabaseSync(':memory:');
 db.exec(feedbackSchema+tokenSchema);
 const insert=db.prepare(`INSERT INTO asc_feedback_cases
  (id,receipt_hash,kind,claimed_user_id,topic,description,status,public_note,admin_note,created_unix,updated_unix)
  VALUES (?,?,'feedback','999999',?,'PRIVATE description that meets the minimum length requirement',?,?,
    'NEVER RETURN',?,?)`);
 const addCase=(id,receipt,topic='Older feedback',status='approved',note='Reviewed')=>
  insert.run(id,digest(receipt),topic,status,note,now,now);
 addCase(id,receipt,'Test feedback','reviewing','');
 addCase(otherId,otherReceipt);
 const DB={
  prepare(sql){
   return {bind(...args){
    const stmt=db.prepare(sql);
    return {
     async first(){if(dbFails)throw Error('database unavailable');return stmt.get(...args)??null;},
     async all(){return {results:stmt.all(...args)};},
     batchRun(){return {meta:{changes:stmt.run(...args).changes}};},
     async run(){return this.batchRun();},
    };
   }};
  },
  async batch(statements){
   db.exec('BEGIN');
   try{
    const results=statements.map(statement=>statement.batchRun());
    db.exec('COMMIT');
    return results;
   }catch(error){
    db.exec('ROLLBACK');
    throw error;
   }
  },
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
 return {send,handler,db,addCase,DB};
}
const start=(f,caseId=id,key=receipt)=>f.send('create',{id:caseId,receipt:key,consent:true});

test('first Feedback requires explicit opt-in and private receipt, never claimed UserId',async()=>{
 const f=fixture();
 assert.equal((await f.send('create',{id,receipt,consent:false})).code,400);
 assert.equal((await f.send('create',{id,receipt:'c'.repeat(64),consent:true})).code,404);
 assert.equal((await f.send('create',{id,receipt,consent:true,userId:'999999'})).code,400);
 assert.equal(f.db.prepare('SELECT COUNT(*) AS n FROM asc_user_case_tokens').get().n,0);
 const r=await start(f);
 assert.equal(r.code,201);
 assert.equal(r.body.expiresAt,null);
 assert.equal(r.body.revocable,true);
 assert.equal(r.body.showOnlyOnce,true);
 assert.equal(r.body.identityVerified,false);
 assert.match(r.body.token,/^USERCASETOKEN_01_[A-Za-z0-9_-]{43}-[a-f0-9]{8}$/);
 const hashes=f.db.prepare('SELECT token_hash FROM asc_user_case_tokens').all();
 assert.deepEqual(hashes.map(row=>row.token_hash),[digest(r.body.token)]);
 assert.equal(f.db.prepare('SELECT token_hash FROM asc_user_case_links WHERE case_id=?').get(id).token_hash,digest(r.body.token));
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
 assert.equal((await f.send('list',{token})).body.code,'token_not_found');
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
 f.db.prepare("UPDATE asc_feedback_cases SET status='spam_mail',public_note='SECRET MODERATOR TEXT' WHERE id=?").run(id);
 assert.deepEqual((await f.send('list',{token})).body.cases.map(c=>[c.status,c.publicNote]),[['reviewing','']]);
 f.db.prepare('UPDATE asc_feedback_cases SET removed=1 WHERE id=?').run(id);
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

test('concurrent token creation yields one linked token and no orphan',async()=>{
 const f=fixture();
 const replies=await Promise.all([start(f),start(f)]);
 assert.deepEqual(replies.map(reply=>reply.code).sort(),[201,409]);
 assert.equal(f.db.prepare('SELECT COUNT(*) AS n FROM asc_user_case_tokens').get().n,1);
 assert.equal(f.db.prepare('SELECT COUNT(*) AS n FROM asc_user_case_links').get().n,1);
});

test('rejoin walks older cases past 30 and can relink cases held by revoked tokens',async()=>{
 const f=fixture(),old=(await start(f)).body.token;
 await f.send('revoke',{token:old,confirm:true});
 const token=(await start(f,otherId,otherReceipt)).body.token;
 assert.equal((await f.send('attach',{token,id,receipt})).code,200);
 for(let index=0;index<30;index++){
  const caseId='33333333-2222-4333-8444-'+String(index).padStart(12,'0');
  const key=digest(caseId);
  f.addCase(caseId,key);
  assert.equal((await f.send('attach',{token,id:caseId,receipt:key})).code,200);
 }
 const first=(await f.send('list',{token})).body;
 assert.equal(first.cases.length,30);
 assert.equal(first.nextCursor,first.cases.at(-1).id);
 const second=(await f.send('list',{token,after:first.nextCursor})).body;
 assert.equal(second.cases.length,2);
 assert.equal(second.nextCursor,null);
 assert.equal(new Set([...first.cases,...second.cases].map(row=>row.id)).size,32);
 assert.equal((await f.send('list',{token,after:'no'})).code,400);
});

test('the token router preserves legacy routes and fails closed without the edge rate binding',async()=>{
 const {mountUserCaseToken}=await import('./feedback-user-case-token-router.mjs');
 const legacy={fetch:()=>new Response('legacy'),scheduled:()=>{}};
 const router=mountUserCaseToken(legacy);
 assert.equal(router.scheduled,legacy.scheduled);
 assert.equal(await (await router.fetch(new Request(origin+'/api/v1/health'),{})).text(),'legacy');

 const request=new Request(origin+CASE_TOKEN_ROUTES.list,{
  method:'POST',headers:{'content-type':'application/json','CF-Connecting-IP':'192.0.2.10'},
  body:'{}',
 });
 Object.defineProperty(request,'cf',{value:{colo:'TEST'}});
 assert.equal((await router.fetch(request,{})).status,404);
 assert.equal((await router.fetch(request,{CASE_TOKEN_HOST:'qa.invalid'})).status,503);
 let limitKey;
 const env={CASE_TOKEN_HOST:'qa.invalid',CASE_TOKEN_RATE:{limit:async({key})=>{
  limitKey=key;
  return {success:false};
 }}};
 assert.equal((await router.fetch(request,env)).status,429);
 assert.match(limitKey,/^list:[a-f0-9]{64}$/);
 assert.doesNotMatch(limitKey,/192\.0\.2\.10/);
});
