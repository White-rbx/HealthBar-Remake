// STAGING-only external smoke. Never transmit credentials or create accounts.
// Accept either fail-closed provisioning or explicitly enabled isolated QA.
// This remains a non-authenticating check even after opening the QA website.
import test from 'node:test';
import assert from 'node:assert/strict';

const base='https://arcscriptcenter-account-qa.kogpasan14.workers.dev';
const timeout=15000;
const request=(path,options={})=>fetch(base+path,{redirect:'manual',signal:AbortSignal.timeout(timeout),...options});

test('live STAGING Account QA status agrees with its page and non-authenticated API',async()=>{
 const health=await request('/health');
 assert.ok([200,503].includes(health.status),'unexpected QA health status');
 const state=await health.json();
 assert.equal(state.service,'ArcScriptCenter Account QA');

 const home=await request('/');
 assert.equal(home.status,200);
 assert.match(home.headers.get('content-type')||'',/text\/html/);
 assert.match(home.headers.get('cache-control')||'',/no-store/);
 const html=await home.text();

 if(health.status===503){
  assert.equal(state.status,'provisioning');
  assert.equal(state.loginEnabled,false);
  assert.equal(state.registrationEnabled,false);
  assert.match(html,/Registration and login are not available yet/i);
  assert.doesNotMatch(html,/<form\b|<input\b|type=["']password["']/i);
  const pair=await request('/api/v1/accounts/pair/start',{
   method:'POST',headers:{'Content-Type':'application/json'},body:'{}',
  });
  assert.equal(pair.status,503);
  assert.deepEqual(await pair.json(),{ok:false,code:'account_qa_provisioning'});
  return;
 }

 assert.equal(state.environment,'qa');
 assert.equal(state.status,'isolated-test-enabled');
 assert.equal(state.loginEnabled,true);
 assert.equal(state.registrationEnabled,true);
 assert.match(home.headers.get('x-robots-tag')||'',/noindex/);
 assert.match(html,/ArcScriptCenter Account/);
 assert.match(html,/Staging/);
 assert.match(html,/id="login-form"/);
 assert.match(html,/id="register-form"/);
 assert.match(html,/data-action="asc_register"/);
 // Invalid input must fail without creating an account or issuing a session.
 const invalid=await request('/api/v1/accounts/login',{
  method:'POST',headers:{'Content-Type':'application/json',Origin:base},body:'{}',
 });
 assert.equal(invalid.status,400);
 assert.deepEqual(await invalid.json(),{ok:false,code:'invalid_input'});
 // Exercise the real password KDF with a synthetic account name (no account
 // exists, no account is created, no real password or Turnstile code is used).
 const missing=await request('/api/v1/accounts/login',{
  method:'POST',headers:{'Content-Type':'application/json',Origin:base},
  body:JSON.stringify({username:'qa_missing_probe_2026',password:'SYNTHETIC-UNUSED-PASSWORD-ONLY'}),
 });
 assert.equal(missing.status,401,'Cloudflare native password KDF should not exceed Worker runtime limits');
 assert.deepEqual(await missing.json(),{ok:false,code:'login_failed'});
});
