import test from 'node:test';
import assert from 'node:assert/strict';
import worker,{EDGE_QA_WORKER,EDGE_QA_ORIGIN} from './eslogin-independent-edge-qa.mjs';

test('isolated HTTPS worker has an explicit, different account QA origin',()=>{
 assert.equal(EDGE_QA_WORKER,'arcscriptcenter-eslogin-edge-qa');
 assert.equal(EDGE_QA_ORIGIN,'https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev');
 assert.notEqual(EDGE_QA_ORIGIN,'https://arcscriptcenter-account-qa.kogpasan14.workers.dev');
});

test('isolated HTTPS worker stays locked even if dangerous account flags or D1 are supplied',async()=>{
 const env={ASC_ACCOUNT_AUTH_MODE:'passkey',
  ASC_ACCOUNT_LAUNCH_STATE:'isolated-test-enabled',
  ACCOUNT_DB:{prepare(){throw Error('LOCKED EDGE QA MUST NEVER ACCESS D1')}},
  ACCOUNT_RATE:{limit(){throw Error('LOCKED EDGE QA MUST NEVER USE RATE LIMITER')}},
 };
 const send=(path,options={})=>worker.fetch(new Request(EDGE_QA_ORIGIN+path,options),env);
 const landing=await send('/');
 assert.equal(landing.status,200);
 assert.match(await landing.text(),/Registration and login are not available yet/i);
 const health=await send('/health');
 assert.equal(health.status,503);
 const h=await health.json();
 assert.equal(h.loginEnabled,false);
 assert.equal(h.registrationEnabled,false);
 assert.equal(health.headers.get('Set-Cookie'),null);
 for(const route of ['/api/v1/accounts/pair/start','/api/v1/accounts/pair/poll',
  '/api/v1/accounts/passkey/login/options','/api/v1/accounts/passkey/register/options',
  '/api/v1/accounts/session','/api/v1/accounts/logout']){
  const response=await send(route,{method:'POST',headers:{
   Origin:EDGE_QA_ORIGIN,'Content-Type':'application/json'},body:'{}'});
  assert.equal(response.status,503,route);
  assert.equal((await response.json()).code,'account_qa_provisioning',route);
  assert.equal(response.headers.get('Set-Cookie'),null,route);
 }
 const forged=await worker.fetch(new Request('https://arcscriptcenter-account-qa.kogpasan14.workers.dev/',{
  headers:{Origin:EDGE_QA_ORIGIN}}),env);
 assert.equal(forged.status,404);
 assert.equal((await forged.json()).code,'not_found');
});

test('no Account QA API can be unlocked with query, path or external origin',async()=>{
 const response=await worker.fetch(new Request(EDGE_QA_ORIGIN+'/api/v1/accounts/passkey/login/options?allow=1',{
  method:'POST',body:'{}'}),{});
 assert.equal(response.status,404);
 const body=await response.json();
 assert.equal(body.code,'not_found');
});
