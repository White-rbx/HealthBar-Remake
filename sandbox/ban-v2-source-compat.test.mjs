import test from 'node:test';
import assert from 'node:assert/strict';
import {createBanV2QaGateway} from './ban-v2-qa-gateway.mjs';

const ORIGIN='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev';
const BASE='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev';
const URL=BASE+'/api/v1/admin/bans/v2/compatibility';
const KEY='Q'.repeat(40),SHA='c'.repeat(40);
const oldEntry={userId:'123456789',username:'LegacyUser',reason:'Test only',description:'',
 startAt:'',expiresAt:'2026-12-01 12:00'};
const mkReq=(method='GET',key=KEY)=>new Request(URL,{
 method,headers:{'Origin':ORIGIN,'X-Admin-Key':key}
});
function makeEnv(source,opts={}){
 const calls=[];
 const DB={prepare:()=>{throw Error('Compatibility preview must never access QA database')}};
 const AUTH_API={fetch:async request=>{
  calls.push({url:request.url,key:request.headers.get('X-Admin-Key'),
   origin:request.headers.get('Origin'),method:request.method});
  if(request.url.endsWith('/api/v1/admin/feedback/summary'))
   return Response.json({ok:true,adminOnly:true,summary:{total:0}});
  if(request.url.endsWith('/api/v1/admin/bans'))
   return Response.json({ok:true,sha:SHA,entries:source.entries,...(source.schema?{schema:source.schema}:{})});
  throw Error('Unexpected endpoint');
 }};
 return {env:{DB,AUTH_API},calls};
}

test('migrates existing schema 1 Ban entries read-only, preserves duration and effective legacy mode',async()=>{
 const {env,calls}=makeEnv({schema:1,entries:[oldEntry]});
 const gate=createBanV2QaGateway();
 const response=await gate.fetch(mkReq(),env);
 assert.equal(response.status,200);
 const body=await response.json();
 assert.equal(body.ok,true);assert.equal(body.adminOnly,true);assert.equal(body.qaOnly,true);assert.equal(body.readOnly,true);
 assert.equal(body.sourceSchema,1);assert.equal(body.sourceSha,SHA);
 assert.equal(body.entriesRead,1);assert.equal(body.legacyUnassigned,1);
 assert.equal(body.document.schema,2);
 assert.deepEqual(body.document.entries[0],{...oldEntry,selection:'unassigned',duration:'temporary'});
 assert.equal(calls.length,2);
 assert.deepEqual(calls.map(x=>x.method),['GET','GET']);
 assert.ok(calls.every(x=>x.key===KEY&&x.origin===ORIGIN));
});

test('reads explicit schema 2 without redefining Restricted Mode or Permanent duration',async()=>{
 const entry={...oldEntry,selection:'restricted_mode',duration:'permanent',expiresAt:''};
 const {env}=makeEnv({schema:2,entries:[entry]});
 const resp=await createBanV2QaGateway().fetch(mkReq(),env);
 assert.equal(resp.status,200);
 const body=await resp.json();
 assert.equal(body.sourceSchema,2);
 assert.equal(body.legacyUnassigned,0);
 assert.deepEqual(body.document.entries,[entry]);
});

test('empty legacy list stays empty; does not attempt actual GitHub or QA D1 write',async()=>{
 const {env,calls}=makeEnv({entries:[]});
 const resp=await createBanV2QaGateway().fetch(mkReq(),env);
 assert.equal(resp.status,200);
 const data=await resp.json();
 assert.deepEqual(data.document,{schema:2,entries:[]});
 assert.equal(data.entriesRead,0);
 assert.equal(calls.length,2);
});

test('malformed upstream legacy Ban entries fail closed instead of dropping fields',async()=>{
 const bad=[{...oldEntry,selection:'restricted_mode'}, {...oldEntry,expiresAt:'invalid'}];
 for(const entry of bad){
  const {env}=makeEnv({schema:1,entries:[entry]});
  const response=await createBanV2QaGateway().fetch(mkReq(),env);
  assert.equal(response.status,503);
  assert.equal((await response.json()).ok,false);
 }
});

test('read-only compatibility route cannot change Ban entries even with Admin auth',async()=>{
 const {env,calls}=makeEnv({entries:[]});
 const response=await createBanV2QaGateway().fetch(mkReq('POST'),env);
 assert.equal(response.status,405);
 const body=await response.json();
 assert.equal(body.ok,false);
 assert.equal(calls.filter(x=>x.url.endsWith('/api/v1/admin/bans')).length,0);
});

test('invalid Admin Key denied before original GitHub Ban list is read',async()=>{
 const {env,calls}=makeEnv({entries:[]});
 const gate=createBanV2QaGateway({adminAuthenticated:async()=>false});
 const resp=await gate.fetch(mkReq('GET','wrong-invalid'),env);
 assert.equal(resp.status,401);
 assert.equal(calls.length,0);
});

test('upstream schema cannot lie or contain silently mixed formats',async()=>{
 const entry={...oldEntry,selection:'restricted_mode',duration:'temporary'};
 for(const source of [{schema:2,entries:[oldEntry]}, {schema:1,entries:[entry]}]){
  const {env}=makeEnv(source);
  const r=await createBanV2QaGateway().fetch(mkReq(),env);
  assert.equal(r.status,503);
 }
});
