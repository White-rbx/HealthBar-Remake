import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import {ADMIN_BANS,GAME_BANS,createBanV2Integration,gitBlobSha,openVerifiedHistory,submitVerifiedAppeal} from './ban-v2-integration.mjs';
import {createStagingGitHubBanStore,d1BanQaStore} from './ban-v2-integration-stores.mjs';
import {QA_BAN_IDS,STAGING_BAN_PREVIEW,qaAdminAuthenticated} from './ban-v2-integration-worker.mjs';
import {buildBanV2PagesWorker} from './ban-v2-pages-builder.mjs';

const files=p=>readFileSync(p,'utf8');
const now=Date.UTC(2026,10,20,12,0)/1000;
const past='2026-11-20 18:00', upcoming='2026-11-20 20:00';
const key='synthetic-admin-test-key-only-000000000000';
const serverKey='g'.repeat(48);
const universe='100000001';
const desc='A synthetic request to review the verified violation decision in the isolated test.';
const seedFor=entries=>files('sandbox/banned-check-center-source-STAGING.lua').replace('{"schema":1,"entries":[]}',JSON.stringify({schema:1,entries}));
const legacy={userId:QA_BAN_IDS[4],username:'ASC_QA_Legacy',reason:'Synthetic legacy ban',description:'QA fixture',startAt:'',expiresAt:''};
const entry=(i,selection='ban_ingame',duration='permanent',overrides={})=>({
 ...legacy,userId:QA_BAN_IDS[i],username:'ASC_QA_'+i,selection,duration,
 startAt:past,expiresAt:duration==='temporary'?upcoming:'',...overrides,
});

function setupSqlite(){
 const db=new DatabaseSync(':memory:');
 for(const file of ['feedback_release_additive_REVIEW_ONLY_20261117.sql','2026-11-17_stage1680_verified_violation_history_DRAFT.sql',
  'ban_v2_full_integration_STAGING_REVIEW.sql','ban_v2_full_integration_QA_ONLY.sql'])
  db.exec(files('migrations/'+file));
 const DB={
  prepare(sql){const bind=(...args)=>{
   const statement=db.prepare(sql);
   return {async first(){return statement.get(...args)??null;},async all(){return {results:statement.all(...args)};},
    syncRun(){return statement.columns().length?{results:statement.all(...args)}:{meta:statement.run(...args)};},async run(){return this.syncRun();}};
  };return {bind,first:()=>bind().first()};},
  async batch(statements){
   db.exec('BEGIN IMMEDIATE');
   try{const out=statements.map(statement=>statement.syncRun());db.exec('COMMIT');return out;}
   catch(error){db.exec('ROLLBACK');throw error;}
  },
 };
 return {db,DB};
}

async function fixture() {
 const {db,DB}=setupSqlite(), source=seedFor([legacy]);
 db.prepare('INSERT INTO asc_ban_v2_qa_source(id,sha,source) VALUES(1,?,?)').run(await gitBlobSha(source),source);
 let clock=now, offline=false;
 const env={DB,BAN_GAME_SERVER_SECRET:serverKey,BAN_GAME_UNIVERSE_ID:universe};
 const handler=createBanV2Integration({
  clock:()=>clock,
  store:{...d1BanQaStore,read:env=>{if(offline)throw Error('offline');return d1BanQaStore.read(env);}},
  adminAuthenticated:async request=>request.headers.get('X-Admin-Key')===key,
  adminOrigins:[STAGING_BAN_PREVIEW],rateLimit:async()=>true,
  allowTarget:id=>QA_BAN_IDS.includes(id),verifyHistory:openVerifiedHistory,submitAppeal:submitVerifiedAppeal,
 });
 async function request(path,body,headers,method=body===undefined?'GET':'POST'){
  const response=await handler(new Request('https://qa.invalid'+path,{
   method,headers:{'Content-Type':'application/json',...headers},body:body===undefined?undefined:JSON.stringify(body),
  }),env);
  return {code:response.status,body:response.status===204?{}:await response.json(),headers:response.headers};
 }
 const admin=(body,headers={})=>request(ADMIN_BANS,body,{'X-Admin-Key':key,Origin:STAGING_BAN_PREVIEW,...headers});
 const game=(operation,userId,body={},headers={})=>request(GAME_BANS+operation,{userId,universeId:universe,...body},
  {Authorization:'Bearer '+serverKey,...headers});
 const put=async(row,expectedSha)=>admin({action:'upsert',entry:row,confirmed:true,expectedSha:expectedSha??(await admin()).body.sha});
 return {db,env,admin,game,put,request,clock:t=>clock=t,offline:()=>offline=true};
}

test('four combinations, legacy access, and fresh checks after expiry and removal',async()=>{
 const f=await fixture();
 const state=await f.admin();
 assert.equal(state.body.sourceSchema,1);
 assert.equal(state.body.document.entries[0].selection,'unassigned');
 assert.equal((await f.game('policy',legacy.userId)).body.state,'ban_ingame');
 for(let i=0;i<4;i++){
  const mode=i<2?'ban_ingame':'restricted_mode',duration=i%2?'permanent':'temporary';
  const ban=entry(i,mode,duration);
  assert.equal((await f.put(ban)).body.saved,true);
  for(let rejoin=0;rejoin<2;rejoin++){
   const status=await f.game('policy',ban.userId);
   assert.equal(status.body.state,mode);
   assert.equal(status.body.ban.duration,duration);
   assert.equal(status.body.ban.reason,ban.reason);
  }
 }
 const snapshot=await f.admin();
 assert.equal(snapshot.body.sourceSchema,2);
 assert.equal(snapshot.body.document.entries.find(row=>row.userId===legacy.userId).selection,'unassigned');
 f.clock(now+3600);
 assert.equal((await f.game('policy',QA_BAN_IDS[0])).body.state,'clear');
 assert.equal((await f.game('policy',QA_BAN_IDS[2])).body.state,'clear');
 assert.equal((await f.game('policy',QA_BAN_IDS[3])).body.state,'restricted_mode');
 const removal=await f.admin({action:'remove',userId:QA_BAN_IDS[3],expectedSha:snapshot.body.sha,confirmed:true});
 assert.equal(removal.body.saved,true);
 assert.equal((await f.game('policy',QA_BAN_IDS[3])).body.state,'clear');
 assert.equal(f.db.prepare('SELECT count(*) AS n FROM asc_ban_v2_audit').get().n,5);
});

test('validates ICT dates, start, expiry, explicit confirmation and authorized QA IDs',async()=>{
 const f=await fixture();
 const first=await f.admin();
 for(const row of [entry(0,'restricted_mode','temporary',{expiresAt:'2026-02-30 12:00'}),
  entry(0,'restricted_mode','permanent',{expiresAt:upcoming}),
  entry(0,'restricted_mode','temporary',{expiresAt:past}),entry(0,'restricted_mode','temporary',{startAt:upcoming,expiresAt:past}),
  entry(0,'unassigned','permanent')])assert.equal((await f.put(row,first.body.sha)).code,400);
 assert.equal((await f.put(entry(0,'ban_ingame','permanent',{userId:'123'}),first.body.sha)).code,403);
 assert.equal((await f.admin({action:'upsert',entry:entry(0),expectedSha:first.body.sha,confirmed:false})).code,400);
 assert.equal((await f.admin(null)).code,400);
 assert.equal((await f.put(entry(0,'restricted_mode','permanent',{startAt:upcoming}))).code,200);
 assert.equal((await f.game('policy',QA_BAN_IDS[0])).body.state,'clear');
 f.clock(now+3600);
 assert.equal((await f.game('policy',QA_BAN_IDS[0])).body.state,'restricted_mode');
});

test('stale Git SHA and concurrent duplicate writes have one audit event',async()=>{
 const f=await fixture(),sha=(await f.admin()).body.sha;
 const results=await Promise.all([f.put(entry(0),sha),f.put(entry(0),sha)]);
 assert.deepEqual(results.map(x=>x.code).sort(),[200,409]);
 const repeated=await f.put(entry(0));
 assert.equal(repeated.body.unchanged,true);
 assert.equal(f.db.prepare('SELECT count(*) AS n FROM asc_ban_v2_audit').get().n,1);
});

test('authorization denies client identity assertions, Feedback tokens, invalid Admin, and unavailable source',async()=>{
 const f=await fixture();
 assert.equal((await f.admin(undefined,{'X-Admin-Key':'wrong'})).code,401);
 assert.equal((await f.admin(undefined,{Origin:'https://unknown.invalid'})).code,403);
 assert.equal((await f.game('policy',QA_BAN_IDS[0],{},{Authorization:'Bearer USERCASETOKEN_01_example'})).code,401);
 assert.equal((await f.game('policy',QA_BAN_IDS[0],{identityVerified:true})).code,400);
 assert.equal((await f.game('policy',QA_BAN_IDS[0],{universeId:'123'})).code,400);
 assert.equal((await f.game('policy',QA_BAN_IDS[0],{},{Origin:STAGING_BAN_PREVIEW})).code,401);
 f.offline();
 const outcome=await f.game('policy',QA_BAN_IDS[0]);
 assert.equal(outcome.code,503);
 assert.equal(outcome.body.state,undefined);
});

test('Restricted Mode gates protected features but retains Feedback and subject-bound history/appeal',async()=>{
 const f=await fixture(),user=QA_BAN_IDS[0],other=QA_BAN_IDS[1];
 for(const id of [0,1])await f.put(entry(id,'restricted_mode','permanent'));
 const denied=await f.game('authorize',user,{feature:'arcsen_chat'});
 assert.equal(denied.code,403);
 for(const feature of ['editor','search','recommendations'])assert.equal((await f.game('authorize',user,{feature})).code,403);
 for(const feature of ['feedback','appeal','violation'])assert.equal((await f.game('authorize',user,{feature})).body.allowed,true);
 assert.deepEqual((await f.game('violation',user)).body.notices,[]);
 f.db.prepare(`INSERT INTO asc_violation_notices(id,lookup_hash,claimed_user_id,reason,moderator_message,created_unix,updated_unix)
   VALUES('qa-notice','synthetic-receipt-hash',?,'QA notice','Public moderator message',?,?)`).run(user,now,now);
 f.db.prepare(`INSERT INTO asc_verified_violation_subjects(notice_id,subject_user_id,identity_method,linked_unix,updated_unix)
   VALUES('qa-notice',?,'trusted_game_server',?,?)`).run(user,now,now);
 assert.deepEqual((await f.game('violation',other)).body.notices,[]);
 assert.equal((await f.game('appeal',other,{noticeId:'qa-notice',description:desc})).code,409);
 const attempts=await Promise.all([0,1].map(()=>f.game('appeal',user,{noticeId:'qa-notice',description:desc})));
 assert.deepEqual(attempts.map(x=>x.code).sort(),[201,409]);
 const item=attempts.find(x=>x.code===201).body;
 assert.match(item.receipt,/^[a-f0-9]{64}$/);
 assert.equal((await f.game('violation',user)).body.notices[0].appealStatus,'reviewing');
 f.db.prepare("UPDATE asc_feedback_cases SET status='approved',updated_unix=? WHERE id=?").run(now+1,item.id);
 assert.equal((await f.game('violation',user)).body.notices[0].appealStatus,'approved');
 assert.equal((await f.game('appeal',user,{noticeId:'qa-notice',description:desc})).code,409);
 await f.put(entry(0,'ban_ingame','permanent'));
 assert.equal((await f.game('violation',user)).code,403);
});

test('GitHub CAS preserves exact source outside managed block, scopes target, audits and detects a race',async()=>{
 const {db,DB}=setupSqlite();
 const original=seedFor([legacy]);
 const originalSha=await gitBlobSha(original),commitSha='a'.repeat(40);
 let source=original,expected=originalSha,requests=[];
 const fetcher=async(url,options)=>{
  requests.push([url,options.method??'GET']);
  if(options.method==='PUT'){
   const body=JSON.parse(options.body);
   assert.equal(body.branch,'banned-check-center-staging-data');
   if(body.sha!==expected)return Response.json({}, {status:409});
   source=Buffer.from(body.content,'base64').toString('utf8');
   expected=await gitBlobSha(source);
   return Response.json({content:{sha:expected},commit:{sha:commitSha}});
  }
  return Response.json({type:'file',encoding:'base64',content:Buffer.from(source).toString('base64'),sha:expected});
 };
 const store=createStagingGitHubBanStore(fetcher);
 const env={DB,GITHUB_TOKEN:'synthetic-credential-test-only','BAN_MANAGEMENT_WRITE':'staging-github'};
 assert.equal((await store.read(env)).sha,originalSha);
 const changed=source.replace('entries":[','entries":[ ').replace('QA fixture','Synthetic legacy case');
 assert.equal(await store.write(env,{source:changed,expectedSha:originalSha,action:'upsert',target:legacy.userId,now}).then(x=>x.commitSha),commitSha);
 assert.equal(await store.write(env,{source:changed,expectedSha:originalSha,action:'remove',target:legacy.userId,now}),null);
 assert.deepEqual(db.prepare('SELECT outcome FROM asc_ban_v2_audit ORDER BY rowid').all().map(x=>x.outcome),['saved','conflict']);
 assert.ok(requests.every(([url])=>url.startsWith('https://api.github.com/repos/White-rbx/HealthBar-Remake/contents/sandbox/banned-check-center-source-STAGING.lua')));
 assert.equal(source.split('-- ARCSCRIPT_BANS_END')[1],original.split('-- ARCSCRIPT_BANS_END')[1]);
});

test('QA reuses original Admin proof and Pages only replaces the Ban addon',async()=>{
 const request=new Request('https://qa.invalid'+ADMIN_BANS,{headers:{'X-Admin-Key':key}});
 const auth={AUTH_API:{fetch:async delivered=>{
  assert.equal(delivered.headers.get('X-Admin-Key'),key);
  assert.match(delivered.url,/api\/v1\/admin\/feedback\/summary$/);
  return Response.json({ok:true,adminOnly:true,summary:{total:0}});
 }}};
 assert.equal(await qaAdminAuthenticated(request,auth),true);
 assert.equal(await qaAdminAuthenticated(new Request('https://qa.invalid'),auth),false);
 const base=files('sandbox/pages-native-ban-center-mode-preview-20261119.js');
 const old=JSON.parse(base.match(/^const BAN_MODE_SCRIPT = (.*);$/m)[1]);
 const addon=files('sandbox/ban-v2-dashboard.js');
 const worker=buildBanV2PagesWorker(base,old,addon);
 assert.equal(worker.replace(/^const BAN_MODE_SCRIPT = .*;$/m,''),base.replace(/^const BAN_MODE_SCRIPT = .*;$/m,''));
 assert.throws(()=>buildBanV2PagesWorker(base,old+'drift',addon),/changed/);
});

test('native QA entry is opt-in and the Loader restores features only after an authenticated clear',()=>{
 const setup=files('sandbox/ExperienceSettings-SetUp-Preview.lua');
 const loader=files('sandbox/LoaderMainPreview.lua');
 const arcsen=files('sandbox/Arcsen-Preview.lua');
 const server=files('sandbox/ArcScriptCenterBanBridge.server.lua');
 const client=files('sandbox/BanPolicyClientPreview.lua');
 assert.match(server,/OnServerInvoke = function\(player, operation, noticeId, description\)/);
 assert.match(server,/userId = tostring\(player.UserId\)/);
 assert.match(server,/GetSecret\("BAN_GAME_SERVER_SECRET"\)/);
 assert.doesNotMatch(server,/USERCASETOKEN|GetVerifiedCaseSessionToken/);
 assert.match(client,/data.subject ~= tostring\(player.UserId\)/);
 assert.match(setup,/qaEnv.__ASC_BAN_POLICY_ERROR = status == nil/);
 assert.match(loader,/if bootEnv.__ASC_BAN_POLICY_ERROR == true then[\s\S]+?return/);
 assert.match(loader,/if status.state == "clear" and isRestrictedMode then[\s\S]+?controller.stop\(\)/);
 assert.match(loader,/if not status then[\s\S]+?showBlocked\("Ban status unavailable/);
 assert.match(arcsen,/trustedBanClient.appeal\(target, description\)/);
 assert.match(arcsen,/#notices == 0 then[\s\S]+?hideViolationNotice\(\)/);
 assert.match(arcsen,/status=="not_appealed"\) or[\s\S]+?status=="denied" and details.canAppealAgain==true/);
});
