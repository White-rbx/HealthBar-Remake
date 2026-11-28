import test from 'node:test';
import assert from 'node:assert/strict';
import {createLockedPrivatePreview,validatePrivatePreviewOrigin}
 from './private-preview-locked-entry.mjs';

const origin='https://eslogin-arcscriptcenter-account-qa.kogpasan14.workers.dev';
const live='https://arcscriptcenter-account-qa.kogpasan14.workers.dev';

test('only an explicit, exact HTTPS QA Preview origin can be pinned',()=>{
 assert.equal(validatePrivatePreviewOrigin(origin),origin);
 for(const candidate of [undefined,'',live,'http://eslogin-arcscriptcenter-account-qa.kogpasan14.workers.dev',
  origin+'/',origin+'/signin',origin+'?enable=1',
  'https://arcscriptcenter-account-qa.kogpasan14.workers.dev.evil.test',
  'https://eslogin-other-worker.kogpasan14.workers.dev',
  'https://user:pass@eslogin-arcscriptcenter-account-qa.kogpasan14.workers.dev',
  'https://eslogin-arcscriptcenter-account-qa.kogpasan14.workers.dev:8443']){
  assert.throws(()=>validatePrivatePreviewOrigin(candidate),/PRIVATE PREVIEW LOCKED/,String(candidate));
 }
});

test('locked Preview always fails closed, even when dangerous auth flags are supplied',async()=>{
 const worker=createLockedPrivatePreview({origin});
 const env={
  ASC_ACCOUNT_MODE:'isolated-qa',ASC_ACCOUNT_AUTH_MODE:'passkey',
  ASC_ACCOUNT_LAUNCH_STATE:'isolated-test-enabled',
  ACCOUNT_DB:{prepare(){throw Error('MUST NOT TOUCH D1')}},
  ACCOUNT_RATE:{limit(){throw Error('MUST NOT TOUCH rate limiter')}},
 };
 const invoke=async(path,init={})=>worker.fetch(new Request(origin+path,init),env);
 for(const route of ['/api/v1/accounts/pair/start','/api/v1/accounts/passkey/register/options',
  '/api/v1/accounts/passkey/login/options','/api/v1/accounts/session']){
  const response=await invoke(route,{method:'POST',headers:{
   Origin:origin,'Content-Type':'application/json'},body:'{}'});
  assert.equal(response.status,503,route);
  assert.equal((await response.json()).code,'account_qa_provisioning',route);
 }
 const health=await invoke('/health');
 assert.equal(health.status,503);
 const state=await health.json();
 assert.equal(state.loginEnabled,false);
 assert.equal(state.registrationEnabled,false);
 const landing=await invoke('/');
 assert.equal(landing.status,200);
 assert.match(await landing.text(),/not available yet/i);
 const attack=await worker.fetch(new Request(live+'/api/v1/accounts/pair/start',{
  method:'POST',headers:{Origin:origin},body:'{}'}),env);
 assert.equal(attack.status,404);
 assert.equal((await attack.json()).code,'not_found');
});
