import test from 'node:test';
import assert from 'node:assert/strict';
import worker from './provisioning-worker.mjs';

const origin='https://arcscriptcenter-account-qa.kogpasan14.workers.dev';
const call=(method,path)=>worker.fetch(new Request(origin+path,{method}));

test('provisioning page clearly states sign-in is disabled without collecting credentials',async()=>{
  const r=await call('GET','/');
  const html=await r.text();
  assert.equal(r.status,200);
  assert.match(html,/Registration and login are not available yet/i);
  assert.match(html,/This is not the production account service/);
  assert.doesNotMatch(html,/<form|<input|<script|name="password"/i);
  assert.match(r.headers.get('content-security-policy'),/default-src 'none'/);
  assert.match(r.headers.get('cache-control'),/no-store/);
});

test('provisioning API rejects every authentication operation without accepting credentials',async()=>{
  for(const operation of ['register','login','factor','session','pair/start','pair/poll','pair/approve','heartbeat','logout','history','appeal']){
    const r=await call('POST','/api/v1/accounts/'+operation);
    assert.equal(r.status,503,operation);
    assert.deepEqual(await r.json(),{ok:false,code:'account_qa_provisioning'});
  }
});

test('health endpoint reports non-operational QA, unrelated paths do not serve account UI',async()=>{
  const r=await call('GET','/health');
  assert.equal(r.status,503);
  const state=await r.json();
  assert.equal(state.status,'provisioning');
  assert.equal(state.loginEnabled,false);
  assert.equal(state.registrationEnabled,false);
  assert.equal((await call('GET','/unknown')).status,404);
  assert.equal((await call('GET','/?access_token=secret')).status,404);
});
