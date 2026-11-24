import test from 'node:test';
import assert from 'node:assert/strict';
import {PIN,verifyNoTrafficBaseline,verifyPrivatePreviewPlan} from './private-preview-gate.mjs';
const baseline=()=>({
 worker:{id:PIN.workerId,name:PIN.worker},
 bindings:[{name:'ACCOUNT_DB',type:'d1',id:PIN.qaDb},
  {name:'ACCOUNT_RATE',type:'ratelimit'},
  {name:'ACCOUNT_TOTP_KEY',type:'secret_text'},
  {name:'ACCOUNT_TURNSTILE_SECRET',type:'secret_text'},
  {name:'ACCOUNT_TURNSTILE_SITE_KEY',type:'plain_text'},
  {name:'ASC_ACCOUNT_MODE',type:'plain_text',text:'isolated-qa'}],
 deployments:[{versions:[{version_id:PIN.deployed,percentage:100}]}],
 versions:[{id:PIN.candidate,number:11,annotations:{'workers/commit_sha':PIN.source}}],
});
const plan=()=>({accountScope:'isolated-account-qa',transport:'Cloudflare Worker Preview',
 sharedVersionUrl:false,
 origin:'https://private-arcscriptcenter-account-qa.kogpasan14.workers.dev',
 originWiring:'fixed-explicit-createAccountWorker-origin',
 access:{protected:true,destination:'preview_worker',workerId:PIN.workerId,reviewed:true},
 previewD1:{type:'d1',id:'11111111-2222-3333-4444-555555555555',schemaVerified:true,syntheticOnly:true},
 defaultLaunchState:'locked',initialAuthMode:null,
 usesRealUsers:false,usesProductionBindings:false,createsPublicRegistration:false,
 editsDeployedTraffic:false});
const bad=(fn,re)=>assert.throws(fn,re);
test('pinned read-only baseline permits only locked version11 at 0% traffic',()=>{
 assert.equal(verifyNoTrafficBaseline(baseline()).trafficPercent,0);
});
test('blocks wrong QA worker, shared database or changed deployed traffic',()=>{
 let x=baseline();x.worker.name='arcscriptcenter-api';bad(()=>verifyNoTrafficBaseline(x),/Worker identity/);
 x=baseline();x.bindings[0].id='production';bad(()=>verifyNoTrafficBaseline(x),/QA D1 changed/);
 x=baseline();x.deployments[0].versions[0].percentage=99;bad(()=>verifyNoTrafficBaseline(x),/live deployment changed/);
});
test('blocks accidental account activation and mismatched immutable version',()=>{
 let x=baseline();x.bindings.push({name:'ASC_ACCOUNT_LAUNCH_STATE',type:'plain_text',text:'isolated-test-enabled'});
 bad(()=>verifyNoTrafficBaseline(x),/binding count|locked/);
 x=baseline();x.versions[0].annotations['workers/commit_sha']='wrong';bad(()=>verifyNoTrafficBaseline(x),/source mismatch/);
});
test('accepts only a reviewed, locked, synthetic-only Preview plan, not user enrollment',()=>{
 assert.deepEqual(verifyPrivatePreviewPlan(plan(),baseline()),{
  readyForLockedPreviewSetup:true,readyForLiveEnrollment:false,
 });
});
test('blocks Version URL due to shared bindings',()=>{
 let p=plan();p.transport='Cloudflare Version URL';bad(()=>verifyPrivatePreviewPlan(p,baseline()),/Preview/);
 p=plan();p.sharedVersionUrl=true;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/Version URL/);
});
test('blocks unprotected preview access or wrong resource target',()=>{
 let p=plan();p.access.protected=false;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/Access policy/);
 p=plan();p.access.destination='worker';bad(()=>verifyPrivatePreviewPlan(p,baseline()),/Access policy/);
 p=plan();p.access.reviewed=false;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/Access policy/);
});
test('blocks same database and unverified synthetic schema',()=>{
 let p=plan();p.previewD1.id=PIN.qaDb;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/separate synthetic-only D1/);
 p=plan();p.previewD1.schemaVerified=false;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/schema/);
 p=plan();p.previewD1.syntheticOnly=false;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/synthetic-only/);
});
test('blocks dynamic host trust, wrong origin and HTTP preview',()=>{
 let p=plan();p.originWiring='trust-request-host';bad(()=>verifyPrivatePreviewPlan(p,baseline()),/origin\/RP ID/);
 p=plan();p.origin=PIN.canonicalOrigin;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/separate QA preview/);
 p=plan();p.origin=p.origin.replace('https:','http:');bad(()=>verifyPrivatePreviewPlan(p,baseline()),/HTTPS/);
});
test('blocks any premature enrollment, login activation, Production or traffic modification',()=>{
 for(const [key,value] of [['defaultLaunchState','isolated-test-enabled'],['initialAuthMode','passkey'],
  ['usesRealUsers',true],['usesProductionBindings',true],['createsPublicRegistration',true],
  ['editsDeployedTraffic',true]]){
  const p=plan();p[key]=value;bad(()=>verifyPrivatePreviewPlan(p,baseline()),/disabled|Production|registration|traffic/);
 }
});
