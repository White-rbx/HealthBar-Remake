import assert from 'node:assert/strict';
import test from 'node:test';
import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import {createUniversalViolationWorker,issueCaseEnrollment} from './banned-token-universal-qa-worker.mjs';
import {gitBlobSha} from './ban-v2-integration.mjs';
import {linkBannedReference} from './banned-token-staging.mjs';

const host='https://case.qa.invalid';
const uid='9007199254740901', stranger='9007199254740902',clear='9007199254740903';
const sample='This is an eligible synthetic appeal message with sufficient content for QA.';
const origin='/api/v1/client/';
const begin=1795194000;
async function fixture(){
 const sql=new DatabaseSync(':memory:');
 for(const file of ['feedback_release_additive_REVIEW_ONLY_20261117.sql','2026-11-17_stage1680_verified_violation_history_DRAFT.sql',
  'ban_v2_full_integration_STAGING_REVIEW.sql','ban_v2_full_integration_QA_ONLY.sql','banned_token_ISOLATED_QA_ONLY.sql','banned_token_universal_ISOLATED_QA_ONLY.sql'])
  sql.exec(readFileSync(new URL('../migrations/'+file,import.meta.url),'utf8'));
 const DB={
  prepare(q){
   const bind=(...args)=>({async first(){return sql.prepare(q).get(...args)??null;},
    async all(){return {results:sql.prepare(q).all(...args)};},
    async run(){return sql.prepare(q).run(...args);},
    invoke(){const s=sql.prepare(q);return s.columns().length?{results:s.all(...args)}:{meta:s.run(...args)};}});
   return {bind,first:()=>bind().first()};
  },
  async batch(ops){
   sql.exec('BEGIN IMMEDIATE');
   try{const out=ops.map(op=>op.invoke());sql.exec('COMMIT');return out;}
   catch(e){sql.exec('ROLLBACK');throw e;}
  },
 };
 const base=readFileSync(new URL('banned-check-center-source-STAGING.lua',import.meta.url),'utf8');
 const entries=[uid,stranger].map((userId,i)=>({userId,username:'FixtureQA',reason:'QA restriction',description:'Synthetic',
  startAt:'',expiresAt:'',duration:'permanent',selection:i?'ban_ingame':'restricted_mode'}));
 const source=base.replace('{"schema":1,"entries":[]}',JSON.stringify({schema:2,entries}));
 sql.prepare('INSERT INTO asc_ban_v2_qa_source(id,sha,source) VALUES(1,?,?)').run(await gitBlobSha(source),source);
 for(const [caseId,owner] of [['own-case',uid],['same-owner-elsewhere',uid],['other-case',stranger]]){
  sql.prepare(`INSERT INTO asc_violation_notices(id,lookup_hash,claimed_user_id,reason,moderator_message,created_unix,updated_unix)
   VALUES(?,?,?,?,'Synthetic moderator note',?,?)`).run(caseId,'hash:'+caseId,owner,'Synthetic QA restriction',begin,begin);
  sql.prepare(`INSERT INTO asc_verified_violation_subjects(notice_id,subject_user_id,identity_method,linked_unix,updated_unix)
   VALUES(?,?,'roblox_oidc',?,?)`).run(caseId,owner,begin,begin);
 }
 sql.prepare(`INSERT INTO asc_ban_v2_audit(request_id,action,target_user_id,old_sha,new_sha,created_unix,outcome)
  VALUES('current-ban','upsert',?,'a','b',?,'saved')`).run(uid,begin);
 const secret='synthetic-secret-for-unit-tests-only'.repeat(2);
 let now=begin;
 const api=createUniversalViolationWorker({publicOrigin:host,clock:()=>now});
 const env={BAN_QA_DB:DB,BANNED_TOKEN_SECRET:secret,BAN_PUBLIC_QA_RATE:{limit:async()=>({success:true})}};
 async function request(path,body={},bearer,headers={}){
  const r=await api.fetch(new Request(host+origin+path,{
   method:'POST',headers:{'Content-Type':'application/json',...(bearer?{Authorization:'Bearer '+bearer}:{}),...headers},body:JSON.stringify(body),
  }),env);
  assert.match(r.headers.get('cache-control'),/no-store/);
  const data=await r.json();
  assert.doesNotMatch(JSON.stringify(data),/BANNTOKEN_|token_hash|verified_username/);
  return [r.status,data];
 }
 const issue=(subject=uid,noticeId='own-case')=>issueCaseEnrollment(DB,{subject,noticeId,username:'FixtureQA'},now);
 return {sql,DB,secret,request,issue,move:v=>now+=v};
}

test('universal HTTP public policy is available without case proof or a Roblox server',async()=>{
 const f=await fixture();
 for(const [userId,state] of [[uid,'restricted_mode'],[stranger,'ban_ingame'],[clear,'clear']]){
  const [status,body]=await f.request('bans/v2/status',{userId});
  assert.equal(status,200);assert.equal(body.state,state);assert.equal(body.identityVerified,false);
  assert.equal(body.notice?.reference,undefined);
 }
 for(const bearer of [undefined,'ABC123','USERCASETOKEN_01_demo','ASCVS_'+'a'.repeat(64)]){
  const [status,body]=await f.request('violation/history',{userId:uid},bearer);
  assert.equal(status,401);assert.equal(body.notices,undefined);
 }
});

test('enrollment is one-use, case-scoped, independent of claimed IDs and revocable',async()=>{
 const f=await fixture();
 assert.equal(await f.issue(stranger,'own-case'),null);
 const invite=await f.issue();
 const browser=await f.request('violation/enroll',{},invite,{Origin:host});
 assert.equal(browser[0],403);
 const pair=await Promise.all([f.request('violation/enroll',{},invite),f.request('violation/enroll',{},invite)]);
 assert.deepEqual(pair.map(x=>x[0]).sort(),[201,401]);
 const {session,subject}=pair.find(x=>x[0]===201)[1];
 assert.equal(subject,uid);
 assert.equal((await f.request('violation/history',{userId:stranger},session))[0],400);
 const [status,history]=await f.request('violation/history',{},session);
 assert.equal(status,200);assert.equal(history.identityVerified,true);
 assert.deepEqual(history.notices.map(n=>n.id),['own-case']);
 const reference=history.notices[0].reference;
 assert.match(reference,/^••••[0-9A-F]{2}$/);
 assert.equal(await linkBannedReference(f.DB,{userId:uid,username:'FixtureQA',caseId:'own-case',secret:f.secret,revision:'current-ban'}),true);
 assert.equal((await f.request('violation/reference',{},session))[1].reference,reference);
 assert.equal((await f.request('violation/appeal',{noticeId:'same-owner-elsewhere',description:sample},session))[0],403);
 assert.equal((await f.request('violation/appeal',{noticeId:'other-case',description:sample},session))[0],403);
 const [created,item]=await f.request('violation/appeal',{noticeId:'own-case',description:sample},session);
 assert.equal(created,201);assert.equal(item.receipt,undefined);
 f.sql.prepare("UPDATE asc_feedback_cases SET status='approved',updated_unix=? WHERE id=?").run(begin+1,item.id);
 let own=(await f.request('violation/history',{},session))[1].notices[0];
 assert.equal(own.appealStatus,'approved');assert.equal(own.canAppealAgain,false);
 assert.equal((await f.request('violation/appeal',{noticeId:'own-case',description:sample},session))[0],409);
 assert.equal((await f.request('violation/revoke',{},session))[0],200);
 assert.equal((await f.request('violation/history',{},session))[0],401);
});

test('expired, reassigned and unavailable sessions fail closed',async()=>{
 const f=await fixture();
 const expired=await f.issue();f.move(901);
 assert.equal((await f.request('violation/enroll',{},expired))[0],401);
 let session=(await f.request('violation/enroll',{},await f.issue()))[1].session;
 f.sql.prepare('UPDATE asc_verified_violation_subjects SET subject_user_id=? WHERE notice_id=?').run(stranger,'own-case');
 assert.equal((await f.request('violation/history',{},session))[0],401);
 session=(await f.request('violation/enroll',{},await f.issue(stranger,'own-case')))[1].session;
 f.move(30*86400+1);
 assert.equal((await f.request('violation/history',{},session))[0],401);
 f.sql.close();
 assert.equal((await f.request('violation/history',{},session))[0],503);
});
