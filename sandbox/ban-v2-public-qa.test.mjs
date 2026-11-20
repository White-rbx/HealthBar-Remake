import assert from 'node:assert/strict';
import test from 'node:test';
import {readFileSync} from 'node:fs';
import {PUBLIC_BAN_STATUS,createPublicBanStatus,gitBlobSha} from './ban-v2-integration.mjs';
import worker from './ban-v2-public-qa-worker.mjs';

const id='9777206932';
const synthetic='9007199254740901';
const approved=new Set([id,synthetic]);
const now=Date.UTC(2026,10,20,12)/1000;
const base=readFileSync(new URL('banned-check-center-source-STAGING.lua',import.meta.url),'utf8');
const fixture=(userId=id,selection='restricted_mode',duration='permanent',expiresAt='')=>({
 userId,username:'PrivateFixture',reason:'Private moderator reason',description:'Private details',
 selection,duration,startAt:'2026-11-20 18:00',expiresAt,
});
async function snapshot(entries) {
 const source=base.replace('{"schema":1,"entries":[]}',JSON.stringify({schema:2,entries}));
 return {source,sha:await gitBlobSha(source)};
}
function request(body={userId:id},{method='POST',path=PUBLIC_BAN_STATUS,headers={}}={}) {
 return new Request('https://qa.invalid'+path,{
  method,headers:{'Content-Type':'application/json',...headers},
  body:method==='POST'?JSON.stringify(body):undefined,
 });
}
async function body(r,code) {
 assert.equal(r.status,code);
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),null);
 assert.match(r.headers.get('Cache-Control'),/no-store/);
 return r.json();
}

test('public policy looks up the approved account on each fresh request, with no case fields',async()=>{
 let record=await snapshot([fixture()]);
 let clock=now;
 const handler=createPublicBanStatus({
  store:{read:async()=>record},allowTarget:v=>approved.has(v),rateLimit:async()=>true,clock:()=>clock,
 });
 const expected=(subject,state)=>({ok:true,identityVerified:false,subject,state,checkedAt:clock,nextCheckAt:clock+30});
 assert.deepEqual(await body(await handler(request()),200),expected(id,'restricted_mode'));
 assert.deepEqual(await body(await handler(request({userId:synthetic})),200),expected(synthetic,'clear'));
 record=await snapshot([fixture(id,'ban_ingame','temporary','2026-11-20 19:04')]);
 assert.deepEqual(await body(await handler(request()),200),expected(id,'ban_ingame'));
 clock+=240;
 assert.deepEqual(await body(await handler(request()),200),expected(id,'clear'));
 record=await snapshot([fixture()]);
 assert.deepEqual(await body(await handler(request()),200),expected(id,'restricted_mode'));
 record=await snapshot([]);
 assert.deepEqual(await body(await handler(request()),200),expected(id,'clear'));
});

test('standalone Worker limits requests, scopes QA, and has no privileged path',async()=>{
 const valid=await snapshot([fixture()]);
 let rate=true, row=valid, reads=0;
 const env={
  BAN_PUBLIC_QA_TEST_IDS:id,
  BAN_QA_DB:{prepare(sql){
   assert.match(sql,/^SELECT sha, source FROM asc_ban_v2_qa_source WHERE id=1$/);
   return {async first(){reads++;return row;}};
  }},
  BAN_PUBLIC_QA_RATE:{async limit({key}){assert.equal(key,'unknown');return {success:rate};}},
 };
 await body(await worker.fetch(request(),env),200);
 for(const path of ['/api/v1/roblox/bans/v2/authorize','/api/v1/roblox/bans/v2/violation',
  '/api/v1/roblox/bans/v2/appeal','/api/v1/admin/bans/v2/manage',PUBLIC_BAN_STATUS+'?userId=1']){
  assert.equal((await body(await worker.fetch(request({userId:id},{path}),env),404)).code,'route');
 }
 for(const headers of [{Origin:'https://example.invalid'},{Authorization:'Bearer sample'},{Cookie:'test=1'},{'X-Admin-Key':'sample'}]){
  assert.equal((await body(await worker.fetch(request({userId:id},{headers}),env),403)).code,'client_lookup_only');
 }
 assert.equal((await body(await worker.fetch(request({userId:'1'}),env),403)).code,'target_not_allowed');
 assert.equal((await body(await worker.fetch(request({userId:id,universeId:'1'}),env),400)).code,'invalid_request');
 assert.equal((await body(await worker.fetch(request({userId:'9'.repeat(150)}),env),413)).code,'body_size');
 assert.equal((await body(await worker.fetch(request({userId:id},{method:'GET'}),env),405)).code,'method');
 rate=false;
 assert.equal((await body(await worker.fetch(request(),env),429)).code,'rate');
 assert.equal(reads,1);
 rate=true;
 row={...valid,sha:'a'.repeat(40)};
 assert.deepEqual(await body(await worker.fetch(request(),env),503),{ok:false,code:'unavailable'});
});
