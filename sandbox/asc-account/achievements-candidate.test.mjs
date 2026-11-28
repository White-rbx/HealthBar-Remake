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
import {awardVerifiedFeedback,readAccountAchievements,refreshOwnAchievements} from './achievements-storage-candidate.mjs';
test('isolated achievement storage is additive, account-scoped, idempotent and counts verified native feedback only',async()=>{
 const sqlite=new DatabaseSync(':memory:');
 sqlite.exec('PRAGMA foreign_keys=ON');
 for(const name of ['asc_unified_account_ISOLATED_QA_ONLY.sql','asc_passkey_account_actions_ISOLATED_QA_ONLY.sql','asc_achievements_ISOLATED_QA_ONLY.sql','asc_achievements_ISOLATED_QA_ONLY.sql']){
  sqlite.exec(readFileSync(new URL('../../migrations/'+name,import.meta.url),'utf8'));
 }
 const db={prepare(sql){return {bind(...args){return {
  all:async()=>({results:sqlite.prepare(sql).all(...args)}),
  run:()=>{const p=sqlite.prepare(sql);return p.columns().length?{results:p.all(...args)}:{meta:p.run(...args)};}
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
 // Owner route rechecks the verified web session atomically with awards.
 sqlite.prepare("INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at) VALUES(?,?,?,'web',?,?)").run('s','b','digest-b',1,100);
 const own={id:'b',session_id:'s',scope:'web'};
 assert.deepEqual((await refreshOwnAchievements(db,own,60)).map(x=>x.id),['feedback_first_sent']);
 assert.equal(await refreshOwnAchievements(db,{...own,id:'a'},60),null);
 assert.equal(await refreshOwnAchievements(db,own,100),null);
 await assert.rejects(refreshOwnAchievements(db,{...own,scope:'loader'},60),TypeError);
 sqlite.prepare("UPDATE asc_account_sessions SET revoked_at=61 WHERE id='s'").run();
 assert.equal(await refreshOwnAchievements(db,own,62),null);
 sqlite.close();
});

import {ownLeaderboardDraft,parseVisibility,projectCompactCard} from './leaderboard-visibility-candidate.mjs';
test('compact projection excludes identity and moderation data and shares only chosen fields',()=>{
 const row={listed:1,appearance:1,badges:1,status:'normal',nickname:'QA Card',username:'private',id:'private-id',profile_image:'123',banner_image:'456',banner_color:'#ABCDEF',password_hash:'private-hash',reason:'private-reason'};
 const earned=[{achievement_id:'feedback_first_sent',earned_at:1},{achievement_id:'unknown'}];
 const card=projectCompactCard(row,earned);
 assert.deepEqual(Object.keys(card),['nickname','image','banner','bannerColor','achievements']);
 assert.equal(card.image,'123');assert.equal(card.banner,'456');assert.equal(card.achievements.length,1);
 assert.doesNotMatch(JSON.stringify(card),/private|earned_at|unknown/);
 assert.equal(projectCompactCard({...row,listed:0},earned),null);
 assert.equal(projectCompactCard({...row,status:'banned'},earned),null);
 assert.deepEqual(projectCompactCard({...row,appearance:0,badges:0},earned),{nickname:'QA Card',image:null,banner:null,bannerColor:'#003264',achievements:[]});
 assert.equal(projectCompactCard({...row,banner_image:'https://example.invalid',banner_color:'bad'},earned).banner,null);
 assert.equal(parseVisibility({accountId:'other'}),undefined);
 assert.equal(parseVisibility({listed:true,appearance:false,badges:true,rank:1}),undefined);
 assert.deepEqual(parseVisibility({listed:false,appearance:true,badges:true}),{listed:false,appearance:false,badges:false});
});
test('visibility draft is private by default and rechecks owner, expiry and revocation',async()=>{
 const sqlite=new DatabaseSync(':memory:');
 sqlite.exec('PRAGMA foreign_keys=ON');
 for(const name of ['asc_unified_account','asc_achievements','asc_leaderboard_visibility']){
  sqlite.exec(readFileSync(new URL('../../migrations/'+name+'_ISOLATED_QA_ONLY.sql',import.meta.url),'utf8'));
 }
 const db={prepare(sql){return {bind(...args){return {execute(){const p=sqlite.prepare(sql);return p.columns().length?{results:p.all(...args)}:{meta:p.run(...args)}}};}};},async batch(ops){sqlite.exec('BEGIN');try{const r=ops.map(x=>x.execute());sqlite.exec('COMMIT');return r;}catch(e){sqlite.exec('ROLLBACK');throw e;}}};
 for(const id of ['a','b'])sqlite.prepare('INSERT INTO asc_accounts(id,username,password_hash,nickname,created_at) VALUES(?,?,?,?,?)').run(id,id,'synthetic','QA '+id,1);
 sqlite.prepare("INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at) VALUES(?,?,?,'web',1,100)").run('session-a','a','digest-a');
 sqlite.prepare('INSERT INTO asc_account_achievements VALUES(?,?,?)').run('a','feedback_first_sent',1);
 const owner={id:'a',session_id:'session-a',scope:'web'};
 const opt={listed:true,appearance:true,badges:true};
 assert.deepEqual(await ownLeaderboardDraft(db,owner,2),{visibility:{listed:false,appearance:false,badges:false},preview:null});
 assert.equal(await ownLeaderboardDraft(db,{...owner,id:'b'},2,opt),null);
 const saved=await ownLeaderboardDraft(db,owner,3,opt);assert.equal(saved.preview.nickname,'QA a');assert.equal(saved.preview.achievements.length,1);
 assert.equal(await ownLeaderboardDraft(db,owner,100,opt),null);
 sqlite.prepare("UPDATE asc_accounts SET status='restricted_mode' WHERE id='a'").run();
 assert.equal((await ownLeaderboardDraft(db,owner,4)).preview,null);
 assert.deepEqual(await ownLeaderboardDraft(db,owner,5,opt),{denied:true});
 assert.equal((await ownLeaderboardDraft(db,owner,6,{...opt,listed:false})).preview,null);
 sqlite.prepare("UPDATE asc_account_sessions SET revoked_at=7 WHERE id='session-a'").run();
 assert.equal(await ownLeaderboardDraft(db,owner,8,opt),null);
 assert.equal(sqlite.prepare('SELECT count(*) AS n FROM asc_account_leaderboard_visibility WHERE account_id=?').get('b').n,0);
 sqlite.close();
});
