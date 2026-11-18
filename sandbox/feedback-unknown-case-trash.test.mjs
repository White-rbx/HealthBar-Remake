import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {createUnknownCaseTrashHandler,TRASH_SECONDS,TRASH_ROUTE,purgeExpiredUnknownTrash} from './feedback-unknown-case-trash.mjs';
const NOW=1795000000,ID='00000000-0000-4000-8000-000000000001';
const SCHEMA= [
'CREATE TABLE asc_feedback_cases(id TEXT PRIMARY KEY,receipt_hash TEXT NOT NULL UNIQUE,kind TEXT NOT NULL,claimed_user_id TEXT,topic TEXT,removed INTEGER DEFAULT 0,updated_unix INTEGER);',
'CREATE TABLE asc_feedback_history(case_id TEXT,event_type TEXT);',
'CREATE TABLE asc_feedback_followup_history(case_id TEXT,event_type TEXT);',
'CREATE TABLE asc_feedback_followup_details_history(case_id TEXT,event_type TEXT);',
'CREATE TABLE asc_feedback_unknown_trash(case_id TEXT PRIMARY KEY REFERENCES asc_feedback_cases(id) ON DELETE CASCADE, trashed_unix INTEGER NOT NULL CHECK(trashed_unix>0), purge_unix INTEGER NOT NULL CHECK(purge_unix-trashed_unix=2592000));'
].join('\n');
function setup(kind='feedback',idClaim=null,removed=0,simulateD1Meta=false){
 const sql=new DatabaseSync(':memory:');sql.exec('PRAGMA foreign_keys=ON');sql.exec(SCHEMA);
 sql.prepare('INSERT INTO asc_feedback_cases(id,receipt_hash,kind,claimed_user_id,topic,removed,updated_unix) VALUES(?,?,?,?,?,?,?)')
 .run(ID,'synthetic_hash',kind,idClaim,'Synthetic test',removed,NOW-100);
 const db={
  prepare(text){return{bind(...params){const q=sql.prepare(text);return{
    first:async()=>q.get(...params)||null,all:async()=>({results:q.all(...params)}),
    run:async()=>({meta:{changes:q.run(...params).changes}})}}}},
  async batch(stmts){sql.exec('BEGIN IMMEDIATE');try{
   const out=[];for(const stmt of stmts){\n    const v=await stmt.run();\n    // Cloudflare D1 meta.changes includes writes from triggers/FK cascades.\n    if(simulateD1Meta&&v.meta.changes>0)v.meta.changes+=1;\n    out.push(v);\n   }
   sql.exec('COMMIT');return out;
  }catch(e){sql.exec('ROLLBACK');throw e;}}
 };
 const create=(auth=true,origin=true,at=NOW)=>createUnknownCaseTrashHandler({
  adminAuthenticated:async()=>auth,originAllowed:()=>origin,clock:()=>at
 });
 const call=async(h,action,confirm=action==='move'?'MOVE UNKNOWN CASE TO TRASH':'RESTORE UNKNOWN CASE')=>{
  const r=await h(new Request('https://example.test'+TRASH_ROUTE,{method:'POST',headers:{Origin:'https://admin.example','Content-Type':'application/json'},
   body:JSON.stringify({action,id:ID,confirm})}),{DB:db});
  return{status:r.status,body:await r.json()};
 };
 const count=(table)=>sql.prepare('SELECT COUNT(*) AS n FROM '+table).get().n;
 return {sql,db,create,call,count,close:()=>sql.close()};
}
test('move requires verified Admin, origin and explicit confirmation',async()=>{
 const f=setup();try{
  assert.equal((await f.call(f.create(false),'move')).status,401);
  assert.equal((await f.call(f.create(true,false),'move')).status,403);
  assert.equal((await f.call(f.create(),'move','NO')).status,400);
  assert.equal(f.count('asc_feedback_unknown_trash'),0);
 }finally{f.close()}
});
test('only active unlinked Feedback may move to Trash',async()=>{
 for(const [kind,id,removed] of [['feedback','12345',0],['appeal',null,0],['feedback',null,1]]){
  const f=setup(kind,id,removed);try{assert.equal((await f.call(f.create(),'move')).status,409);assert.equal(f.count('asc_feedback_unknown_trash'),0)}
  finally{f.close()}
 }
});
test('30-day deadline starts when Admin moves; receipt-scoped source is hidden',async()=>{
 const f=setup();try{
  const r=await f.call(f.create(),'move');
  assert.equal(r.status,200);assert.equal(r.body.purgeAt,NOW+TRASH_SECONDS);
  assert.equal(f.sql.prepare('SELECT removed FROM asc_feedback_cases').get().removed,1);
  assert.equal((await f.call(f.create(),'move')).status,409);
 }finally{f.close()}
});
test('Restore before deadline prevents deletion after 30 days',async()=>{
 const f=setup();try{
  assert.equal((await f.call(f.create(),'move')).status,200);
  assert.equal((await f.call(f.create(),'restore')).status,200);
  assert.equal(f.count('asc_feedback_unknown_trash'),0);
  assert.equal((await purgeExpiredUnknownTrash(f.db,NOW+TRASH_SECONDS+1)).purged,0);
 }finally{f.close()}
});
test('no deletion before deadline, but purge case and all linked history at expiry',async()=>{
 const f=setup();try{
  await f.call(f.create(),'move');
  for(const t of ['asc_feedback_history','asc_feedback_followup_history','asc_feedback_followup_details_history'])
   f.sql.prepare('INSERT INTO '+t+'(case_id,event_type) VALUES(?,?)').run(ID,'synthetic');
  assert.equal((await purgeExpiredUnknownTrash(f.db,NOW+TRASH_SECONDS-1)).purged,0);
  assert.equal((await purgeExpiredUnknownTrash(f.db,NOW+TRASH_SECONDS)).purged,1);
  for(const t of ['asc_feedback_cases','asc_feedback_unknown_trash','asc_feedback_history','asc_feedback_followup_history','asc_feedback_followup_details_history'])
   assert.equal(f.count(t),0,t+' not purged');
  assert.equal(f.sql.prepare('PRAGMA foreign_key_check').all().length,0);
 }finally{f.close()}
});
test('restore after deadline is denied; claimed identity appearing later blocks purge',async()=>{
 const f=setup();try{
  await f.call(f.create(),'move');
  assert.equal((await f.call(f.create(true,true,NOW+TRASH_SECONDS),'restore')).status,409);
  f.sql.prepare('UPDATE asc_feedback_cases SET claimed_user_id=?').run('12345');
  assert.equal((await purgeExpiredUnknownTrash(f.db,NOW+TRASH_SECONDS)).purged,0);
  assert.equal(f.count('asc_feedback_cases'),1);
 }finally{f.close()}
});
test('GET list needs admin and returns no Receipt hash or Admin Notes',async()=>{
 const f=setup();try{
  await f.call(f.create(),'move');
  const handler=f.create();
  const req=new Request('https://example.test'+TRASH_ROUTE,{headers:{Origin:'https://admin.example'}});
  const res=await handler(req,{DB:f.db});const body=await res.text();
  assert.equal(res.status,200);assert.equal(JSON.parse(body).items.length,1);
  assert.doesNotMatch(body,/synthetic_hash|receipt_hash|admin_note/);
 }finally{f.close()}
});

test('Cloudflare D1 meta.changes includes extra trigger and FK cascade writes',async()=>{
 const f=setup('feedback',null,0,true);
 try{
  const move=await f.call(f.create(),'move');
  assert.equal(move.status,200,'move must not reject meta.changes=2');
  const restore=await f.call(f.create(),'restore');
  assert.equal(restore.status,200,'restore must not reject meta.changes=2');
  assert.equal((await f.call(f.create(),'move')).status,200);
  assert.equal((await purgeExpiredUnknownTrash(f.db,NOW+TRASH_SECONDS)).purged,1,
   'cascade delete must still count as one purged CASE, not zero');
  assert.equal(f.count('asc_feedback_cases'),0);
  assert.equal(f.count('asc_feedback_unknown_trash'),0);
 }finally{f.close()}
});
