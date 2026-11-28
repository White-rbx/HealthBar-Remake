import test from 'node:test';
import assert from 'node:assert/strict';
import { achievements, evaluateAchievements } from './achievements-candidate.mjs';
const zero={streakDays:0,usageSeconds:0,feedbackSent:0,feedbackApproved:0};
test('original catalog has 14 distinct IDs and all threshold boundaries',()=>{
 assert.equal(achievements.length,14);
 assert.equal(new Set(achievements.map(a=>a.id)).size,14);
 assert.deepEqual(evaluateAchievements(zero),[]);
 for(const a of achievements){
  const snapshot=n=>({...zero,[a.metric]:n,...(a.metric==='feedbackApproved'?{feedbackSent:n}:{})});
  assert.ok(!evaluateAchievements(snapshot(a.threshold-1)).includes(a.id));
  assert.ok(evaluateAchievements(snapshot(a.threshold)).includes(a.id));
 }
});
test('all earned badges persist even after a streak reset; unknown IDs never grant an award',()=>{
 const all=evaluateAchievements({streakDays:20,usageSeconds:2592000,feedbackSent:5,feedbackApproved:5});
 assert.equal(all.length,14);
 assert.deepEqual(evaluateAchievements(zero,[...all,'unknown']),all);
});
test('reject missing, negative, fractional and inconsistent counters',()=>{
 for(const value of [null,-1,1.5,NaN,Infinity,'5',Number.MAX_SAFE_INTEGER+1]){
  assert.throws(()=>evaluateAchievements({...zero,usageSeconds:value}),TypeError);
 }
 assert.throws(()=>evaluateAchievements({}),TypeError);
 assert.throws(()=>evaluateAchievements({...zero,feedbackApproved:5}),TypeError);
});

import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import {awardVerifiedFeedback,readAccountAchievements} from './achievements-storage-candidate.mjs';
test('isolated achievement storage is additive, account-scoped, idempotent and counts verified native feedback only',async()=>{
 const sqlite=new DatabaseSync(':memory:');
 sqlite.exec('PRAGMA foreign_keys=ON');
 for(const name of ['asc_unified_account_ISOLATED_QA_ONLY.sql','asc_passkey_account_actions_ISOLATED_QA_ONLY.sql','asc_achievements_ISOLATED_QA_ONLY.sql','asc_achievements_ISOLATED_QA_ONLY.sql']){
  sqlite.exec(readFileSync(new URL('../../migrations/'+name,import.meta.url),'utf8'));
 }
 const db={prepare(sql){return {bind(...args){return {
  all:async()=>({results:sqlite.prepare(sql).all(...args)}),
  run:()=>sqlite.prepare(sql).run(...args)
 };}};},async batch(ops){
  sqlite.exec('BEGIN');
  try{const out=ops.map(x=>x.run());sqlite.exec('COMMIT');return out;}catch(e){sqlite.exec('ROLLBACK');throw e;}
 }};
 for(const id of ['a','b'])sqlite.prepare('INSERT INTO asc_accounts(id,username,password_hash,nickname,created_at) VALUES(?,?,?,?,?)').run(id,id,'synthetic',id,1);
 function add(id,owner,status='approved',kind='feedback',details=true,legacy=null){
  sqlite.prepare('INSERT INTO asc_account_cases(id,account_id,kind,status,reason,created_at,legacy_source,legacy_id) VALUES(?,?,?,?,?,?,?,?)').run(id,owner,kind,status,'synthetic',1,legacy,legacy?id:null);
  if(details)sqlite.prepare('INSERT INTO asc_account_feedback_details(case_id,topic) VALUES(?,?)').run(id,'QA topic');
 }
 add('other','b');
 add('legacy','a','approved','feedback',true,'feedback');
 add('no-details','a','approved','feedback',false);
 add('ban','a','approved','ban');
 await awardVerifiedFeedback(db,'a',10);
 assert.deepEqual(await readAccountAchievements(db,'a'),[]);
 for(let i=0;i<4;i++)add('case-'+i,'a');
 add('pending','a','reviewing');
 await awardVerifiedFeedback(db,'a',20);
 assert.deepEqual((await readAccountAchievements(db,'a')).map(x=>x.id),['feedback_first_sent']);
 sqlite.prepare("UPDATE asc_account_cases SET status='approved' WHERE id='pending'").run();
 await awardVerifiedFeedback(db,'a',30);
 await awardVerifiedFeedback(db,'a',40);
 const earned=await readAccountAchievements(db,'a');
 assert.deepEqual(earned.map(x=>[x.id,x.earnedAt]),[['feedback_first_sent',20],['feedback_approved_five',30]]);
 assert.deepEqual(await readAccountAchievements(db,'b'),[]);
 sqlite.prepare("UPDATE asc_account_cases SET status='closed' WHERE account_id='a'").run();
 await awardVerifiedFeedback(db,'a',50);
 assert.deepEqual(await readAccountAchievements(db,'a'),earned);
 assert.throws(()=>sqlite.prepare('INSERT INTO asc_account_achievements VALUES(?,?,?)').run('a','unknown',1));
 assert.throws(()=>sqlite.prepare('INSERT INTO asc_account_achievements VALUES(?,?,?)').run('missing','streak_user',1));
 sqlite.close();
});
