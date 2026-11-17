import test from 'node:test';
import assert from 'node:assert/strict';
import {createStage1687RestrictedGateway,STAGE1687_GATEWAY_ALLOWLIST} from './stage16-87-restricted-gateway.mjs';
const base='https://isolated.example.test';

function fixture({authorized=true,trusted=true,networkId='isolated:test-network',limited=false,accessError=false,ingressError=false,rateError=false}={}) {
  const calls={access:0,ingress:0,rate:0};
  const gateway=createStage1687RestrictedGateway({
    verifySandboxAccess:async()=>{calls.access++;if(accessError)throw Error('secret failure');return authorized;},
    verifyTrustedIngress:async()=>{calls.ingress++;if(ingressError)throw Error('edge failure');return {verified:trusted,networkId};},
    checkRateLimit:async args=>{calls.rate++;assert.deepEqual(args,{action:'start',networkId});if(rateError)throw Error('D1 unavailable');return !limited;},
  });
  const request=(path='/__stage1687/rate-probe',options={})=>new Request(base+path,{method:options.method||'POST',headers:options.headers||{}});
  const hit=(path,opts,env={STAGE1687_LOCAL_TEST_ONLY:'local-workerd-fixture'})=>gateway.fetch(request(path,opts),env);
  return {gateway,calls,hit,request};
}
test('constructor requires three independent trusted callbacks',()=>{
  for(const args of [
    {},{verifyTrustedIngress:()=>({verified:true,networkId:'xyz'})},
    {verifyTrustedIngress:()=>true,verifySandboxAccess:()=>true},
  ]) assert.throws(()=>createStage1687RestrictedGateway(args),/Independent trusted/);
});
test('environment lock is fail-closed even if injected verifiers approve',async()=>{
  const f=fixture();
  for(const env of [{},{STAGE1687_LOCAL_TEST_ONLY:'production'},{STAGE1687_LOCAL_TEST_ONLY:true}]) {
    const response=await f.hit(undefined,undefined,env);
    assert.equal(response.status,404);
  }
  assert.deepEqual(f.calls,{access:0,ingress:0,rate:0});
});
test('only nonprivileged probe route exists; all sensitive paths stay dark',async()=>{
  const f=fixture();
  for(const path of [
    '/api/v1/violation/history','/api/v1/feedback/appeal','/admin',
    '/pair/start','/pair/browser/approve','/auth/start',
    '/__stage1687/rate-probe?userId=1234','/__stage1687/rate-probe?next=admin',
  ]) {
    const r=await f.hit(path);
    assert.equal(r.status,404,path);
  }
  assert.equal((await f.hit(undefined,{method:'GET'})).status,404);
  assert.deepEqual(f.calls,{access:0,ingress:0,rate:0});
});
test('synthetic Worker-to-Worker hops blocked before external trust verifiers',async()=>{
  const f=fixture();
  for(const headers of [{'CF-Worker':'example.com'},{'X-Real-IP':'192.0.2.20'}]){
    const r=await f.hit(undefined,{headers});
    assert.equal(r.status,403);
  }
  assert.equal(f.calls.rate,0);
});
test('browser-controlled Origin, XFF and Roblox UserId do not create authorization',async()=>{
  const f=fixture({authorized:false});
  const r=await f.hit(undefined,{headers:{
    'X-Forwarded-For':'203.0.113.3','CF-Connecting-IP':'203.0.113.3',
    Origin:base,'X-Roblox-UserId':'1234',Authorization:'Bearer forged',
  }});
  assert.equal(r.status,403);
  assert.equal(f.calls.rate,0);
});
test('untrusted ingress is refused even if sandbox access says yes',async()=>{
  const f=fixture({trusted:false});
  assert.equal((await f.hit()).status,403);
  assert.equal(f.calls.rate,0);
});
test('missing or malformed network identity fails closed',async()=>{
  for(const networkId of ['', 'bad net', 'a'.repeat(129),undefined]){
    const f=fixture({networkId});
    assert.equal((await f.hit()).status,403);
    assert.equal(f.calls.rate,0);
  }
});
test('independent verification failures return generic 503 without secrets',async()=>{
  for(const flags of [{accessError:true},{ingressError:true}]){
    const f=fixture(flags),r=await f.hit(),body=await r.json();
    assert.equal(r.status,503);
    assert.equal(body.error,'Verification unavailable');
    assert.equal(f.calls.rate,0);
    assert.ok(!JSON.stringify(body).includes('secret'));
  }
});
test('D1 failure is fail-closed, denies access',async()=>{
  const f=fixture({rateError:true}),r=await f.hit();
  assert.equal(r.status,503);
  assert.deepEqual(await r.json(),{ok:false,error:'Rate limit unavailable'});
});
test('trusted but throttled probe gets 429 without identity disclosure',async()=>{
  const f=fixture({limited:true}),r=await f.hit();
  assert.equal(r.status,429);
  assert.deepEqual(await r.json(),{ok:false,limited:true});
});
test('all verified prerequisites give minimal probe response',async()=>{
  const f=fixture(),r=await f.hit();
  assert.equal(r.status,200);
  assert.deepEqual(await r.json(),{ok:true,probe:true});
  assert.equal(r.headers.get('cache-control'),'no-store, private');
  assert.equal(r.headers.get('access-control-allow-origin'),null);
  assert.deepEqual(f.calls,{access:1,ingress:1,rate:1});
});
test('the allowlist cannot grow without changing security review',()=>{
  assert.deepEqual(Object.keys(STAGE1687_GATEWAY_ALLOWLIST).sort(),
    ['disabledWithoutBinding','method','path']);
  assert.equal(STAGE1687_GATEWAY_ALLOWLIST.path,'/__stage1687/rate-probe');
  assert.equal(STAGE1687_GATEWAY_ALLOWLIST.method,'POST');
});
