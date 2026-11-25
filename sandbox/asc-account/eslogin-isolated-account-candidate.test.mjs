import test from 'node:test';
import assert from 'node:assert/strict';
import {ISOLATED_ESLOGIN_ORIGIN,createIsolatedESLoginCandidate}
 from './eslogin-isolated-account-candidate.mjs';

test('future ESLogin candidate uses the explicitly pinned HTTPS WebAuthn origin',()=>{
 const u=new URL(ISOLATED_ESLOGIN_ORIGIN);
 assert.equal(u.protocol,'https:');
 assert.equal(u.hostname,'arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev');
 assert.equal(u.origin,ISOLATED_ESLOGIN_ORIGIN);
 assert.notEqual(u.hostname,'arcscriptcenter-account-qa.kogpasan14.workers.dev');
});

test('isolated candidate remains provisioning-only without reviewed auth settings',async()=>{
 let calls=0;
 const env={ASC_ACCOUNT_MODE:'isolated-qa',
  ACCOUNT_DB:{prepare(){calls++;throw Error('D1 MUST NOT BE ACCESSED')},
   batch(){calls++;throw Error('D1 MUST NOT BE ACCESSED')}},
  ACCOUNT_RATE:{limit(){calls++;throw Error('RATE MUST NOT BE ACCESSED')}},
 };
 const worker=createIsolatedESLoginCandidate();
 const get=async(path,options={})=>worker.fetch(new Request(
  ISOLATED_ESLOGIN_ORIGIN+path,options),env);
 const health=await get('/health');
 assert.equal(health.status,503);
 const body=await health.json();
 assert.equal(body.loginEnabled,false);
 assert.equal(body.registrationEnabled,false);
 assert.equal(health.headers.get('Set-Cookie'),null);
 const attempt=await get('/api/v1/accounts/passkey/register/options',{
  method:'POST',headers:{Origin:ISOLATED_ESLOGIN_ORIGIN,
   'Content-Type':'application/json'},body:'{}'});
 assert.equal(attempt.status,503);
 assert.equal((await attempt.json()).code,'account_qa_provisioning');
 assert.equal(calls,0,'locked code must not touch D1 or limiter');
});

test('even synthetic launch flags cannot activate missing Turnstile/secrets',async()=>{
 const env={ASC_ACCOUNT_MODE:'isolated-qa',
  ASC_ACCOUNT_AUTH_MODE:'passkey',
  ASC_ACCOUNT_LAUNCH_STATE:'isolated-test-enabled',
  ACCOUNT_DB:{prepare(){throw Error('UNSAFE D1 ACCESSED')},
   batch(){throw Error('UNSAFE D1 ACCESSED')}},
  ACCOUNT_RATE:{limit(){throw Error('UNSAFE LIMITER ACCESSED')}},
 };
 const worker=createIsolatedESLoginCandidate();
 const response=await worker.fetch(new Request(ISOLATED_ESLOGIN_ORIGIN+'/health'),env);
 assert.equal(response.status,503);
 assert.equal((await response.json()).loginEnabled,false);
});

test('rejects spoofed Host and an unrelated origin before any auth routing',async()=>{
 const worker=createIsolatedESLoginCandidate();
 for(const target of [
  'https://arcscriptcenter-account-qa.kogpasan14.workers.dev/health',
  'https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev.evil.test/health',
  'http://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev/health',
 ]){
  const response=await worker.fetch(new Request(target,{
   headers:{Origin:ISOLATED_ESLOGIN_ORIGIN}}),{
   ASC_ACCOUNT_MODE:'isolated-qa'});
  assert.equal(response.status,404,target);
  assert.equal((await response.json()).code,'not_found');
 }
});
