import assert from 'node:assert/strict';
import test from 'node:test';

const base='https://arcscriptcenter-ban-policy-qa.kogpasan14.workers.dev';
const statusRoute='/api/v1/client/bans/v2/status';
async function lookup(userId,path=statusRoute){
 const r=await fetch(base+path,{
  method:'POST',signal:AbortSignal.timeout(12000),redirect:'error',
  headers:{'Content-Type':'application/json'},body:JSON.stringify({userId}),
 });
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),null);
 assert.match(r.headers.get('Cache-Control'),/no-store/);
 return {status:r.status,data:await r.json()};
}

test('live public lookup returns only the UI policy for an isolated synthetic account',async()=>{
 const subject='9007199254740901';
 const {status,data}=await lookup(subject);
 assert.equal(status,200);
 assert.deepEqual(Object.keys(data).sort(),['checkedAt','identityVerified','nextCheckAt','ok','state','subject']);
 assert.equal(data.subject,subject);
 assert.equal(data.identityVerified,false);
 assert.equal(data.ok,true);
 assert.ok(['clear','ban_ingame','restricted_mode'].includes(data.state));
 assert.equal(data.nextCheckAt-data.checkedAt,30);
});

test('live public lookup rejects out-of-scope accounts and exposes no case or admin route',async()=>{
 const outside=await lookup('9007199254740910');
 assert.deepEqual(outside,{status:403,data:{ok:false,code:'target_not_allowed'}});
 for(const path of ['/api/v1/admin/bans/v2/manage','/api/v1/roblox/bans/v2/violation','/api/v1/roblox/bans/v2/appeal']){
  const denied=await lookup('9007199254740901',path);
  assert.deepEqual(denied,{status:404,data:{ok:false,code:'route'}});
 }
});
