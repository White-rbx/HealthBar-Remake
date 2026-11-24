import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {PIN,verifyBundle,verifyRemote,makeVersion,uploadUndeployed} from './qa-undeployed-version-upload.mjs';
const bytes=readFileSync(new URL('./dist/account-passkey-worker.mjs',import.meta.url));
// Version 11 is immutable. New page builds MUST be rejected by the old uploader
// instead of silently re-pinning its digest or uploading a changed candidate.
const matchesPinned=bytes.length===900711&&createHash('sha256').update(bytes).digest('hex')===PIN.digest;
const bindings=[
 {name:'ACCOUNT_DB',type:'d1',id:PIN.d1},
 {name:'ACCOUNT_RATE',type:'ratelimit',namespace_id:PIN.rateNamespace},
 {name:'ACCOUNT_TOTP_KEY',type:'secret_text'},
 {name:'ACCOUNT_TURNSTILE_SECRET',type:'secret_text'},
 {name:'ACCOUNT_TURNSTILE_SITE_KEY',type:'plain_text'},
 {name:'ASC_ACCOUNT_MODE',type:'plain_text',text:'isolated-qa'},
];
const worker={success:true,result:{id:PIN.workerId,name:PIN.name}};
const settings={success:true,result:{bindings}};
const deployments={success:true,result:{deployments:[{id:'qa-deployment',versions:[{version_id:PIN.activeVersion,percentage:100}]}]}};
const validResponse=(data,status=200)=>({ok:status<300,status,json:async()=>data});

test('only the immutable Version 11 build is uploadable; changed UI bundles fail closed',()=>{
 if(!matchesPinned){
  assert.throws(()=>verifyBundle(bytes),/unexpected module size|digest differs/);
  assert.throws(()=>makeVersion(bytes),/unexpected module size|digest differs/);
  return;
 }
 assert.equal(verifyBundle(bytes),PIN.digest);
 const p=makeVersion(bytes);
 assert.equal(p.modules.length,1);
 assert.equal(Buffer.from(p.modules[0].content_base64,'base64').equals(bytes),true);
 assert.equal(p.bindings.length,6);
 assert.ok(p.bindings.every(b=>b.type==='inherit'&&b.version_id===PIN.activeVersion));
 assert.equal(p.compatibility_flags[0],'nodejs_compat');
 assert.ok(!JSON.stringify(p).includes('isolated-test-enabled'));
});

test('remote guard requires exact QA resources and locked state',()=>{
 assert.equal(verifyRemote(worker,settings,deployments),'qa-deployment');
 assert.throws(()=>verifyRemote(worker,{success:true,result:{bindings:[...bindings,{name:'ASC_ACCOUNT_LAUNCH_STATE',type:'plain_text',text:'isolated-test-enabled'}]}},deployments),/binding count/);
 assert.throws(()=>verifyRemote(worker,{success:true,result:{bindings:bindings.map(b=>b.name==='ACCOUNT_DB'?{...b,id:'production-db'}:b)}},deployments),/not pinned/);
 assert.throws(()=>verifyRemote(worker,settings,{success:true,result:{deployments:[{id:'changed',versions:[{version_id:'changed',percentage:100}]}]}}),/deployed QA version changed/);
});

test('upload only calls beta Worker versions endpoint; changed build makes zero API calls',async()=>{
 const calls=[];
 const mock=async(url,opt)=>{
  const u=new URL(url),body=opt.body?JSON.parse(opt.body):undefined;
  calls.push({url:u.pathname,method:opt.method,body});
  if(u.pathname.endsWith('/settings'))return validResponse(settings);
  if(u.pathname.endsWith('/deployments'))return validResponse(deployments);
  if(u.pathname.endsWith('/versions'))return validResponse({success:true,result:{id:'11111111-1111-4111-8111-111111111111'}});
  return validResponse(worker);
 };
 if(!matchesPinned){
  await assert.rejects(uploadUndeployed(bytes,{enabled:true,fetcher:mock,token:'synthetic_testing_token_very_long'}),/unexpected module size|digest differs/);
  assert.equal(calls.length,0,'changed bundle must never reach Cloudflare API');
  return;
 }
 await assert.rejects(uploadUndeployed(bytes,{fetcher:mock,token:'synthetic_testing_token_very_long'}),/explicit --upload/);
 assert.equal(calls.length,0,'disabled by default');
 const result=await uploadUndeployed(bytes,{enabled:true,fetcher:mock,token:'synthetic_testing_token_very_long'});
 assert.equal(result.trafficPercent,0);
 assert.equal(calls.filter(x=>x.method==='POST').length,1);
 assert.match(calls.find(x=>x.method==='POST').url,/\/workers\/workers\/arcscriptcenter-account-qa\/versions$/);
 assert.ok(calls.every(x=>!(/\/deployments$/.test(x.url)&&x.method!=='GET')));
 assert.equal(calls.filter(x=>x.url.endsWith('/deployments')).length,2);
});

test('fails closed if Cloudflare post-upload deployment changes when pinned',async t=>{
 if(!matchesPinned){t.skip('Version 11 uploader is immutable; new build already rejected');return;}
 let count=0;
 const mock=async(url,opt)=>{
  const u=new URL(url);
  if(u.pathname.endsWith('/settings'))return validResponse(settings);
  if(u.pathname.endsWith('/deployments')){
   count++;
   return validResponse(count===1?deployments:{success:true,result:{deployments:[{id:'changed',versions:[{version_id:'11111111-1111-4111-8111-111111111111',percentage:100}]}]}});
  }
  if(opt.method==='POST')return validResponse({success:true,result:{id:'11111111-1111-4111-8111-111111111111'}});
  return validResponse(worker);
 };
 await assert.rejects(uploadUndeployed(bytes,{enabled:true,fetcher:mock,token:'synthetic_testing_token_very_long'}),/deployed QA version changed/);
});
