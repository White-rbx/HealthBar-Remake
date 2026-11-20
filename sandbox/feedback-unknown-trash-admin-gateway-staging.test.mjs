import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {createTrashAdminGateway} from './feedback-unknown-trash-admin-gateway-staging.mjs';
import {TRASH_ROUTE,TRASH_SECONDS} from './feedback-unknown-case-trash.mjs';

const ORIGIN='https://arcscriptcenter-dashboard-staging.pages.dev';
const HOST='https://arcscriptcenter-trash-admin-qa.kogpasan14.workers.dev';
const ID='00000000-0000-4000-8000-000000000001',TIME=1795000000;
const KEY='A'.repeat(48);
function fixture(){
 const sql=new DatabaseSync(':memory:');
 sql.exec('PRAGMA foreign_keys=ON');
 sql.exec([
  'CREATE TABLE asc_feedback_cases(id TEXT PRIMARY KEY,receipt_hash TEXT UNIQUE,kind TEXT,claimed_user_id TEXT,topic TEXT,removed INTEGER DEFAULT 0,updated_unix INTEGER NOT NULL);',
  'CREATE TABLE asc_feedback_unknown_trash(case_id TEXT PRIMARY KEY REFERENCES asc_feedback_cases(id) ON DELETE CASCADE,trashed_unix INTEGER NOT NULL,purge_unix INTEGER NOT NULL CHECK(purge_unix-trashed_unix=2592000));'
 ].join('\n'));
 sql.prepare('INSERT INTO asc_feedback_cases(id,receipt_hash,kind,claimed_user_id,topic,removed,updated_unix) VALUES(?,?,?,?,?,0,?)')
  .run(ID,'synthetic-receipt','feedback',null,'Synthetic example',TIME-100);
 let dbQueries=0,serviceCalls=0,lastServiceURL='',lastServiceOrigin='';
 const DB={prepare(q){dbQueries++;return{bind(...a){
  const statement=sql.prepare(q);
  return{first:async()=>statement.get(...a)||null,
   all:async()=>({results:statement.all(...a)}),
   run:async()=>({meta:{changes:statement.run(...a).changes}})}
 }}},async batch(stmts){sql.exec('BEGIN');try{
  const result=[];for(const q of stmts)result.push(await q.run());
  sql.exec('COMMIT');return result;
 }catch(e){sql.exec('ROLLBACK');throw e;}}};
 const AUTH_API={async fetch(request){
  serviceCalls++;lastServiceURL=request.url;lastServiceOrigin=request.headers.get('Origin');
  const valid=request.headers.get('X-Admin-Key')===KEY;
  return Response.json(valid?{ok:true,adminOnly:true,summary:{total:1}}:{ok:false,error:'Unauthorized'},{status:valid?200:401});
 }};
 const env={DB,AUTH_API};
 const gateway=createTrashAdminGateway({clock:()=>TIME});
 function req(method='GET',{origin=ORIGIN,key=KEY,body=null,path=TRASH_ROUTE}={}){
  return new Request(HOST+path,{method,headers:{
   ...(origin!==null?{'Origin':origin}:{}),
   ...(key!==null?{'X-Admin-Key':key}:{}),
   ...(body!==null?{'Content-Type':'application/json'}:{})
  },...(body===null?{}:{body:JSON.stringify(body)})});
 }
 const act=async(action,id=ID,conf=true)=>gateway.fetch(req('POST',{body:{action,id,confirm:conf?
  (action==='move'?'MOVE UNKNOWN CASE TO TRASH':'RESTORE UNKNOWN CASE'):'INVALID'}}),env);
 return{sql,env,gateway,req,act,get serviceCalls(){return serviceCalls},
  get dbQueries(){return dbQueries},get lastServiceURL(){return lastServiceURL},
  get lastServiceOrigin(){return lastServiceOrigin},close:()=>sql.close()};
}
test('preflight allowed origin responds 204 without any Auth or D1',async()=>{
 const f=fixture();try{
  const r=await f.gateway.fetch(f.req('OPTIONS',{key:null}),f.env);
  assert.equal(r.status,204);
  assert.equal(r.headers.get('Access-Control-Allow-Origin'),ORIGIN);
  assert.match(r.headers.get('Access-Control-Allow-Headers'),/X-Admin-Key/);
  assert.equal(f.serviceCalls,0);
  assert.equal(f.dbQueries,0);
 }finally{f.close()}
});
test('unknown origin is denied before calling the Auth Worker or D1',async()=>{
 const f=fixture();try{
  const r=await f.gateway.fetch(f.req('GET',{origin:'https://hostile.example'}),f.env);
  assert.equal(r.status,403);
  assert.equal(f.serviceCalls,0);assert.equal(f.dbQueries,0);
  assert.equal(r.headers.get('Access-Control-Allow-Origin'),null);
 }finally{f.close()}
});
test('no X-Admin-Key denied without sending service call or DB mutation',async()=>{
 const f=fixture();try{
  const r=await f.gateway.fetch(f.req('GET',{key:null}),f.env);
  assert.equal(r.status,401);assert.equal(f.serviceCalls,0);assert.equal(f.dbQueries,0);
 }finally{f.close()}
});
test('invalid Admin Key delegates only to existing /summary API and fails closed',async()=>{
 const f=fixture();try{
  const r=await f.gateway.fetch(f.req('GET',{key:'B'.repeat(48)}),f.env);
  assert.equal(r.status,401);
  assert.equal(f.serviceCalls,1);
  assert.match(f.lastServiceURL,/\/api\/v1\/admin\/feedback\/summary$/);
  assert.equal(f.lastServiceOrigin,ORIGIN);
  assert.equal(f.dbQueries,0);
 }finally{f.close()}
});
test('valid existing Admin Key can view Trash without leaking receipt',async()=>{
 const f=fixture();try{
  const r=await f.gateway.fetch(f.req(),f.env);
  assert.equal(r.status,200);
  assert.equal(r.headers.get('Access-Control-Allow-Origin'),ORIGIN);
  assert.equal(r.headers.get('Cache-Control'),'no-store');
  const body=await r.text();assert.equal(JSON.parse(body).adminOnly,true);
  assert.doesNotMatch(body,/synthetic-receipt/);
 }finally{f.close()}
});
test('verified Admin move and restore work on synthetic D1 and exact deadline',async()=>{
 const f=fixture();try{
  const moved=await f.act('move');assert.equal(moved.status,200,await moved.clone().text());
  const result=await moved.json();assert.equal(result.purgeAt,TIME+TRASH_SECONDS);
  assert.equal(f.sql.prepare('SELECT removed FROM asc_feedback_cases').get().removed,1);
  const list=await f.gateway.fetch(f.req(),f.env);
  assert.equal((await list.json()).items.length,1);
  const restored=await f.act('restore');assert.equal(restored.status,200,await restored.clone().text());
  assert.equal(f.sql.prepare('SELECT removed FROM asc_feedback_cases').get().removed,0);
  assert.equal(f.sql.prepare('SELECT COUNT(*) n FROM asc_feedback_unknown_trash').get().n,0);
 }finally{f.close()}
});
test('invalid confirmation does not modify D1',async()=>{
 const f=fixture();try{
  const r=await f.act('move',ID,false);assert.equal(r.status,400);
  assert.equal(f.sql.prepare('SELECT removed FROM asc_feedback_cases').get().removed,0);
 }finally{f.close()}
});
test('no public purge action, and arbitrary paths cannot access data',async()=>{
 const f=fixture();try{
  assert.equal((await f.gateway.fetch(f.req('GET',{path:'/purge'}),f.env)).status,404);
  assert.equal((await f.gateway.fetch(f.req('POST',{body:{action:'purge',id:ID,confirm:'PURGE'}}),f.env)).status,400);
  assert.equal(f.sql.prepare('SELECT COUNT(*) n FROM asc_feedback_cases').get().n,1);
 }finally{f.close()}
});
test('service binding offline never grants Admin authorization',async()=>{
 const f=fixture();try{
  f.env.AUTH_API.fetch=async()=>{throw new Error('Upstream unavailable')};
  const res=await f.gateway.fetch(f.req(),f.env);
  assert.equal(res.status,401);
 }finally{f.close()}
});
