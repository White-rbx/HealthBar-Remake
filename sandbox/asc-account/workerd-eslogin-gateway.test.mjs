import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {join} from 'node:path';
import {EDGE_QA_ORIGIN as website} from './eslogin-independent-edge-qa.mjs';

const root=fileURLToPath(new URL('../../',import.meta.url));
const gateway='https://arcscriptcenter-eslogin-pairing-qa.kogpasan14.workers.dev';
const runtime=process.env.ASC_ACCOUNT_WORKERD_PREFIX;
const path='/api/v1/accounts/';
const fixedTime=()=>Math.floor(Date.now()/1000);
const requireRuntime=()=>createRequire(join(runtime,'package.json'));

test('workerd: real website approval, independent D1 gateway, replay, expiry and capacity',
 {skip:!runtime && 'requires Miniflare', timeout:45000},async t=>{
 const {Miniflare}=requireRuntime()('miniflare');
 const worker=(name,bundle,bindings,d1Databases,ratelimits)=>({
  name,modules:true,scriptPath:join(root,'sandbox/asc-account/dist',bundle),
  compatibilityDate:'2026-08-06',compatibilityFlags:['nodejs_compat'],bindings,d1Databases,ratelimits,
 });
 const isolatedId='asc-gateway-workerd-isolated';
 const enabled={ASC_PAIR_GATEWAY_MODE:'isolated-qa',ASC_PAIR_GATEWAY_LAUNCH_STATE:'explicit-test-enabled'};
 const bundle='eslogin-pairing-edge-qa.mjs';
 const rate={PAIR_RATE:{namespace_id:'71128',simple:{limit:30,period:60}}};
 const mf=new Miniflare({workers:[
  worker('website','eslogin-edge-qa.mjs',{
   ASC_ACCOUNT_MODE:'isolated-qa',ASC_ACCOUNT_AUTH_MODE:'passkey',
   ASC_ACCOUNT_LAUNCH_STATE:'isolated-test-enabled',ACCOUNT_TOTP_KEY:'ab'.repeat(32),
   ACCOUNT_TURNSTILE_SITE_KEY:'fixture_site',ACCOUNT_TURNSTILE_SECRET:'fixture',
  },{ACCOUNT_DB:isolatedId},{ACCOUNT_RATE:{namespace_id:'20261125',simple:{limit:40,period:60}}}),
  worker('gateway',bundle,enabled,{PAIR_DB:isolatedId},rate),
  worker('locked',bundle,{...enabled,ASC_PAIR_GATEWAY_LAUNCH_STATE:'locked'},{PAIR_DB:isolatedId},rate),

 ]});
 t.after(()=>mf.dispose());

 const db=await mf.getD1Database('PAIR_DB','gateway');
 for(const name of ['asc_unified_account','asc_eslogin_gateway_budget']){
  const sql=readFileSync(join(root,'migrations',name+'_ISOLATED_QA_ONLY.sql'),'utf8');
  await db.batch(sql.replace(/^--.*$/gm,'').split(';').map(s=>s.trim()).filter(Boolean).map(s=>db.prepare(s)));
 }
 const entry=await mf.getWorker('gateway');
 const locked=await mf.getWorker('locked');
 const web={fetch:(url,init)=>mf.dispatchFetch(url,init)};
 const post=(target,origin,route,body={},headers={})=>target.fetch(origin+path+route,{
  method:'POST',headers:{'content-type':'application/json',...headers},body:JSON.stringify(body),
 });
 for(const op of ['pair/start','pair/poll','session','heartbeat','logout']){
  assert.equal((await post(locked,gateway,op)).status,503,op);
 }
 for(const op of ['pair/approve','passkey/login/options','register','history','appeal','admin']){
  assert.equal((await post(entry,gateway,op)).status,404,op);
 }
 const clock=fixedTime(),webToken='f'.repeat(64);
 const webHash=createHash('sha256').update(webToken).digest('hex');
 await db.prepare("INSERT INTO asc_accounts(id,username,password_hash,nickname,created_at) VALUES('synthetic','synthetic_gateway','unused','Synthetic',?)").bind(clock).run();
 await db.prepare("INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at) VALUES('browser','synthetic',?,'web',?,?)").bind(webHash,clock,clock+600).run();
 const started=await post(entry,gateway,'pair/start');
 assert.equal(started.status,200);
 const {secret,code}=await started.json();
 const pending=await post(entry,gateway,'pair/poll',{secret});
 assert.equal((await pending.json()).state,'pending');
 const approved=await post(web,website,'pair/approve',{code,confirm:true},{Origin:website,Cookie:'__Host-ascqa='+webToken});
 assert.equal(approved.status,200, await approved.text());
 const attempts=await Promise.all([post(entry,gateway,'pair/poll',{secret}),post(entry,gateway,'pair/poll',{secret})]);
 assert.deepEqual(attempts.map(r=>r.status).sort(),[200,410]);
 const session=(await attempts.find(r=>r.ok).json()).session;
 const bearer={Authorization:'Bearer '+session};
 const checked=await post(entry,gateway,'session',{},bearer);
 assert.equal(checked.status,200);
 assert.deepEqual((await checked.json()).account,{id:'synthetic',nickname:'Synthetic',status:'normal',image:null,banner:null,bannerColor:'#102757'});
 assert.equal((await post(web,website,'history',{},bearer)).status,401);
 await db.prepare("UPDATE asc_accounts SET profile_image='123',banner_image='456',banner_color='#445566' WHERE id='synthetic'").run();
 const heartbeat=await post(entry,gateway,'heartbeat',{},bearer);
 assert.equal(heartbeat.status,200);
 assert.deepEqual((await heartbeat.json()).account,{id:'synthetic',nickname:'Synthetic',status:'normal',image:'123',banner:'456',bannerColor:'#445566'});
 assert.equal((await post(entry,gateway,'profile/preview',{image:'123',banner:null},bearer)).status,404);
 await db.prepare("UPDATE asc_accounts SET status='restricted_mode'").run();
 const restricted=await post(entry,gateway,'session',{},bearer);
 assert.equal((await restricted.json()).account.status,'restricted_mode');
 assert.equal((await post(entry,gateway,'logout',{},bearer)).status,200);
 assert.equal((await post(entry,gateway,'session',{},bearer)).status,401);

 const expired=await post(entry,gateway,'pair/start');
 const expiring=await expired.json();
 await db.prepare('UPDATE asc_account_pairings SET expires_at=0 WHERE code=?').bind(expiring.code).run();
 assert.equal((await post(entry,gateway,'pair/poll',{secret:expiring.secret})).status,410);

 await db.prepare("DELETE FROM asc_qa_pair_gateway_budget WHERE op='pair/start'").run();
 const burst=await Promise.all(Array.from({length:22},()=>post(entry,gateway,'pair/start')));
 assert.equal(burst.filter(r=>r.status===200).length,20);
 assert.equal(burst.filter(r=>r.status===429).length,2);
 assert.equal((await db.prepare("SELECT minute_count FROM asc_qa_pair_gateway_budget WHERE op='pair/start'").first()).minute_count,20);
});
