// STAGING-only external smoke: keep this test while Account QA is locked.
// No accounts, credentials, Turnstile tokens or production resources are used.
import test from 'node:test';
import assert from 'node:assert/strict';

const base='https://arcscriptcenter-account-qa.kogpasan14.workers.dev';
const timeout=15000;

test('live STAGING Account QA serves provisioning page, not a password form',async()=>{
 const response=await fetch(base+'/',{redirect:'manual',signal:AbortSignal.timeout(timeout)});
 assert.equal(response.status,200);
 assert.match(response.headers.get('content-type')||'',/text\/html/);
 assert.match(response.headers.get('cache-control')||'',/no-store/);
 const html=await response.text();
 assert.match(html,/Registration and login are not available yet/i);
 assert.doesNotMatch(html,/<form\b|<input\b|type=["']password["']/i);
});

test('live STAGING Account QA API denies unauthenticated pairing while locked',async()=>{
 const response=await fetch(base+'/api/v1/accounts/pair/start',{
  method:'POST',headers:{'Content-Type':'application/json'},
  body:'{}',redirect:'manual',signal:AbortSignal.timeout(timeout),
 });
 assert.equal(response.status,503);
 assert.deepEqual(await response.json(),{ok:false,code:'account_qa_provisioning'});
});

test('live STAGING Account QA health is correctly marked not ready',async()=>{
 const response=await fetch(base+'/health',{redirect:'manual',signal:AbortSignal.timeout(timeout)});
 assert.equal(response.status,503);
 const health=await response.json();
 assert.equal(health.status,'provisioning');
 assert.equal(health.loginEnabled,false);
 assert.equal(health.registrationEnabled,false);
});
