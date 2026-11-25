import test from 'node:test';
import assert from 'node:assert/strict';
import {LOCKED_EDGE,REQUIRED_ACCOUNT_TABLES,verifyLockedEdgeResources}
 from './eslogin-locked-resources-gate.mjs';

const fixture=()=>({
 worker:{id:LOCKED_EDGE.workerId,name:LOCKED_EDGE.worker},
 bindings:[{name:'ACCOUNT_DB',type:'d1',id:LOCKED_EDGE.db},
  {name:'ACCOUNT_RATE',type:'ratelimit',namespace_id:LOCKED_EDGE.rateNamespace,
   simple:{limit:40,period:60}}],
 access:{id:LOCKED_EDGE.accessApp,type:'self_hosted',options_preflight_bypass:false,
  destinations:[{type:'worker',worker_id:LOCKED_EDGE.workerId}]},
 policies:[{decision:'deny',include:[{everyone:{}}],exclude:[],require:[]}],
 subdomain:{enabled:true,previews_enabled:false},
 qaDeployment:[{version_id:LOCKED_EDGE.deployedQa,percentage:100}],
 qaSubdomain:{enabled:true,previews_enabled:false},
 database:{name:LOCKED_EDGE.dbName,id:LOCKED_EDGE.db},
 databaseRows:Object.fromEntries(REQUIRED_ACCOUNT_TABLES.map(n=>[n,0])),
 foreignKeyViolations:0,
});

test('isolated resource snapshot remains locked and contains no account data',()=>{
 assert.deepEqual(verifyLockedEdgeResources(fixture()),{
  d1Isolated:true,rateLimiterIsolated:true,accessDenyAll:true,
  version10Unchanged:true,accountTableCount:11,accountRowCount:0,
  loginEnabled:false,readyForPasskey:false,
 });
});
test('blocks old/shared DB, accidental secret/auth flags or extra bindings',()=>{
 for(const update of [
  s=>s.bindings[0].id=LOCKED_EDGE.oldQaDb,
  s=>s.bindings[0].id='11111111-2222-3333-4444-555555555555',
  s=>s.bindings.push({name:'ASC_ACCOUNT_AUTH_MODE',type:'plain_text',text:'passkey'}),
  s=>s.bindings.push({name:'ACCOUNT_TURNSTILE_SECRET',type:'secret_text'}),
 ]){
  const s=fixture();update(s);
  assert.throws(()=>verifyLockedEdgeResources(s),/ESLOGIN_LOCKED_EDGE_BLOCKED/);
 }
});
test('blocks reused rate namespace and changed or disabled limits',()=>{
 for(const change of [
  s=>s.bindings[1].namespace_id='8728',
  s=>s.bindings[1].simple.limit=0,
  s=>s.bindings[1].simple.period=10,
 ]){
  const s=fixture();change(s);
  assert.throws(()=>verifyLockedEdgeResources(s),/rate limiting/);
 }
});
test('blocks Access bypass, wrong Worker, allow policies or auth exceptions',()=>{
 for(const mutate of [
  s=>s.access.options_preflight_bypass=true,
  s=>s.access.destinations[0].type='preview_worker',
  s=>s.access.destinations[0].worker_id='wrong',
  s=>s.access.destinations[0].overrides=[{behavior:'public',path_pattern:'/'}],
  s=>s.policies[0].decision='allow',
  s=>s.policies[0].exclude=[{email:{email:'tester@example.test'}}],
  s=>s.policies[0].require=[{email:{email:'tester@example.test'}}],
 ]){
  const s=fixture();mutate(s);
  assert.throws(()=>verifyLockedEdgeResources(s),/ESLOGIN_LOCKED_EDGE_BLOCKED/);
 }
});
test('blocks nonempty account DB, changed Version 10 traffic or enabled Version URLs',()=>{
 for(const mutate of [
  s=>s.databaseRows.asc_accounts=1,
  s=>delete s.databaseRows.asc_accounts,
  s=>s.databaseRows.unexpected=0,
  s=>s.foreignKeyViolations=1,
  s=>s.qaDeployment[0].percentage=0,
  s=>s.qaDeployment[0].version_id='version11',
  s=>s.subdomain.previews_enabled=true,
  s=>s.qaSubdomain.previews_enabled=true,
 ]){
  const s=fixture();mutate(s);
  assert.throws(()=>verifyLockedEdgeResources(s),/ESLOGIN_LOCKED_EDGE_BLOCKED/);
 }
});

test('provisioned locked phase permits only all three QA secret bindings, without activation',()=>{
 const state=fixture();
 for(const name of ['ACCOUNT_TOTP_KEY','ACCOUNT_TURNSTILE_SECRET','ACCOUNT_TURNSTILE_SITE_KEY']){
  state.bindings.push({name,type:'secret_text'});
 }
 const options={withQaSecrets:true};
 assert.equal(verifyLockedEdgeResources(state,options).loginEnabled,false);
 assert.throws(()=>verifyLockedEdgeResources(state));
 state.bindings.at(-1).type='plain_text';
 assert.throws(()=>verifyLockedEdgeResources(state,options));
});
