import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import {Script} from 'node:vm';
import {activeAccounts,createAccountWorker} from './worker.mjs';
import {linkVerifiedLegacyCase} from './moderation.mjs';
import {readTotp,totpCode} from './security.mjs';
import {website} from './website.mjs';

const origin='https://account.qa.invalid';
const password='Synthetic test passphrase 1';
const pass2='Synthetic replacement passphrase 2';
const desc='This is a synthetic feedback or appeal with more than fifty characters.';
const user='Example_QA';
const key='ac'.repeat(32);
function fixture(){
 const sqlite=new DatabaseSync(':memory:');
 sqlite.exec(readFileSync(new URL('../../migrations/asc_unified_account_ISOLATED_QA_ONLY.sql',import.meta.url),'utf8'));
 const db={prepare(sql){
  const bind=(...params)=>({
   async first(){return sqlite.prepare(sql).get(...params)??null;},
   async run(){return sqlite.prepare(sql).run(...params);},
   async all(){return {results:sqlite.prepare(sql).all(...params)};},
   execute(){const p=sqlite.prepare(sql);return p.columns().length?{results:p.all(...params)}:{meta:p.run(...params)};},
  });return {bind};
 },async batch(ops){
  sqlite.exec('BEGIN IMMEDIATE');
  try{const values=ops.map(v=>v.execute());sqlite.exec('COMMIT');return values;}
  catch(e){sqlite.exec('ROLLBACK');throw e;}
 }};
 let now=1795440001;
 let throttled=false;
 const env={ASC_ACCOUNT_MODE:'isolated-qa',ACCOUNT_DB:db,ACCOUNT_TOTP_KEY:key,ACCOUNT_TURNSTILE_SITE_KEY:'synthetic_public_key',
  ACCOUNT_TURNSTILE_SECRET:'test-only',ACCOUNT_RATE:{limit:async()=>({success:!throttled})}};
 const handler=createAccountWorker({origin,clock:()=>now,fetcher:async(input,options)=>{
  if(String(input).startsWith('https://challenges.cloudflare.com/')){
   const payload=JSON.parse(options.body);
   assert.equal(payload.secret,'test-only');
   return Response.json({success:payload.response==='valid'||payload.response==='wrong-host',
    hostname:payload.response==='wrong-host'?'wrong.example':'account.qa.invalid',action:'asc_register'});
  }
  const u=new URL(input);assert.equal(u.origin,'https://thumbnails.roblox.com');
  const targetId=Number(u.searchParams.get('assetIds'));
  return Response.json({data:[{targetId,state:targetId===123?'Completed':'Blocked',imageUrl:'https://t0.rbxcdn.com/test'}]});
 }});
 async function post(op,body={},auth,web=true){
  const r=await handler.fetch(new Request(origin+'/api/v1/accounts/'+op,{method:'POST',headers:{
   'Content-Type':'application/json',...(web?{Origin:origin}:{}),
   ...(auth?(web?{Cookie:auth}:{Authorization:'Bearer '+auth}):{}),
  },body:JSON.stringify(body)}),env);
  assert.match(r.headers.get('cache-control'),/no-store/);
  const data=await r.json();
  assert.doesNotMatch(JSON.stringify(data),/password_hash|totp_pending|Synthetic test passphrase/);
  return {status:r.status,data,cookie:r.headers.get('set-cookie')?.split(';')[0]};
 }
 const signup=(name=user,turnstile='valid')=>post('register',{username:name,password,confirmation:password,turnstile,presence:true});
 const login=(name=user,secret=password)=>post('login',{username:name,password:secret});
 async function pair(web,remember=true){
  const p=await post('pair/start',{},null,false);
  assert.equal(p.status,200);
  assert.equal((await post('pair/poll',{secret:p.data.secret},null,false)).data.state,'pending');
  assert.equal((await post('pair/approve',{code:p.data.code,confirm:true},web)).status,200);
  const tries=await Promise.all(Array.from({length:2},()=>post('pair/poll',{secret:p.data.secret,remember},null,false)));
  assert.deepEqual(tries.map(t=>t.status).sort(),[200,410]);
  return tries.find(t=>t.status===200).data.session;
 }
 return {sqlite,db,env,post,signup,login,pair,advance:n=>now+=n,now:()=>now,throttle:()=>{throttled=true}};
}

test('missing any required Account QA binding never exposes a credential form or accepts login',async()=>{
 const f=fixture();
 const handler=createAccountWorker({origin});
 for(const binding of ['ACCOUNT_DB','ACCOUNT_RATE','ACCOUNT_TOTP_KEY','ACCOUNT_TURNSTILE_SITE_KEY','ACCOUNT_TURNSTILE_SECRET']){
  const incomplete={...f.env};
  delete incomplete[binding];
  const page=await handler.fetch(new Request(origin+'/'),incomplete);
  assert.equal(page.status,200,binding+' provisioning page');
  const html=await page.text();
  assert.match(html,/Registration and login are not available yet/);
  assert.doesNotMatch(html,/<form|<input|name="password"/i);
  const login=await handler.fetch(new Request(origin+'/api/v1/accounts/login',{
   method:'POST',headers:{Origin:origin,'Content-Type':'application/json'},
   body:JSON.stringify({username:user,password}),
  }),incomplete);
  assert.equal(login.status,503,binding+' denies credentials');
  assert.deepEqual(await login.json(),{ok:false,code:'account_qa_provisioning'});
 }
});

test('registration requires server-verified Turnstile, applies rate limits, and conceals duplicates',async()=>{
 const f=fixture();
 assert.equal((await f.signup(user,'invalid')).status,400);
 assert.equal((await f.signup(user,'wrong-host')).status,400);
 assert.equal((await f.signup()).status,200);
 assert.deepEqual((await f.signup(user.toLowerCase())).data,{ok:true});
 assert.equal(f.sqlite.prepare('SELECT count(*) AS n FROM asc_accounts').get().n,1);
 assert.match(f.sqlite.prepare('SELECT password_hash FROM asc_accounts').get().password_hash,/^scrypt-32768-8-3:/);
 assert.equal((await f.login(user,'incorrect')).status,401);
 assert.deepEqual((await f.login('nosuchuser')).data,(await f.login(user,'incorrect')).data);
 f.throttle();assert.equal((await f.login()).status,429);
});

test('pairing issues only a scoped revocable session, and presence counts distinct live accounts',async()=>{
 const f=fixture();
 await f.signup();
 const {cookie,data}=await f.login();
 assert.ok(data.account.id);
 const a=await f.pair(cookie),b=await f.pair(cookie);
 assert.equal((await f.post('session',{},a,false)).data.account.id,data.account.id);
 assert.equal((await f.post('security/sessions',{},a,false)).status,404);
 for(const session of [a,b])assert.equal((await f.post('heartbeat',{},session,false)).status,200);
 assert.equal(await activeAccounts(f.db,f.now()),1);
 f.advance(91);assert.equal(await activeAccounts(f.db,f.now()),0);
 await f.post('heartbeat',{},b,false);
 assert.equal((await f.post('logout',{},a,false)).status,200);
 assert.equal((await f.post('session',{},a,false)).status,401);
 const pair=await f.post('pair/start',{},null,false);
 assert.equal((await f.post('pair/approve',{code:pair.data.code,confirm:true},cookie)).status,200);
 assert.equal((await f.post('logout',{},cookie)).status,200);
 assert.equal((await f.post('pair/poll',{secret:pair.data.secret},null,false)).status,410);
 f.advance(43201);
 assert.equal((await f.post('session',{},b,false)).status,401);
});

test('TOTP enablement, replay, recovery, change password, and disable',async()=>{
 const f=fixture();await f.signup();
 const first=await f.login();
 const cookie=first.cookie;
 const account=first.data.account.id;
 const setup=await f.post('security/setup',{password},cookie);
 assert.match(setup.data.setupKey,/^[A-Z2-7]{32}$/);
 const row=f.sqlite.prepare('SELECT totp_pending FROM asc_accounts').get();
 assert.ok(!row.totp_pending.includes(setup.data.setupKey));
 const secret=await readTotp(row.totp_pending,key,account);
 assert.equal((await f.post('security/enable',{password,code:'123456'},cookie)).status,401);
 const code=()=>totpCode(secret,Math.floor(f.now()/30));
 const result=await f.post('security/enable',{password,code:await code()},cookie);
 assert.equal(result.status,200);assert.equal(result.data.recovery.length,8);
 const challenge=await f.login();
 assert.equal(challenge.status,202);assert.equal(challenge.cookie,undefined);
 assert.equal((await f.post('factor',{challenge:challenge.data.challenge,code:await code()})).status,401);
 f.advance(31);
 const valid=await f.post('factor',{challenge:challenge.data.challenge,code:await code()});
 assert.ok(valid.cookie);
 assert.equal((await f.post('factor',{challenge:challenge.data.challenge,code:await code()})).status,401);
 const backup=(await f.login()).data.challenge;
 assert.equal((await f.post('factor',{challenge:backup,code:result.data.recovery[0]})).status,200);
 const another=(await f.login()).data.challenge;
 assert.equal((await f.post('factor',{challenge:another,code:result.data.recovery[0]})).status,401);
 f.advance(31);
 assert.equal((await f.post('security/password',{password,newPassword:pass2,confirmation:pass2,code:await code()},valid.cookie)).status,200);
 assert.equal((await f.post('session',{},valid.cookie)).status,401);
 const changed=await f.login(user,pass2);
 assert.equal(changed.status,202);
 const recovery=await f.post('factor',{challenge:changed.data.challenge,code:result.data.recovery[1]});
 f.advance(31);
 assert.equal((await f.post('security/disable',{password:pass2,code:await code()},recovery.cookie)).status,200);
 const after=await f.login(user,pass2);
 assert.equal(after.status,200);assert.ok(after.cookie);assert.equal(after.data.account.twoStep,false);
});

test('case ownership, approved appeal, legacy link, and profile synchronization',async()=>{
 const f=fixture();await f.signup();await f.signup('Other_QA');
 const {cookie,data}=await f.login();
 const other=(await f.login('Other_QA')).cookie;
 const session=await f.pair(cookie);
 const accountId=data.account.id;
 assert.deepEqual((await f.post('history',{},session,false)).data.notices,[]);
 const change=f.sqlite.prepare('UPDATE asc_accounts SET status=? WHERE id=?');
 change.run('restricted_mode',accountId);
 assert.equal((await f.post('session',{},session,false)).data.account.status,'restricted_mode');
 const common={source:'bannedtoken',caseId:'legacy-1',verifiedOwner:{provider:'roblox_oidc',subject:'321'},
  kind:'violation',reason:'Synthetic case',moderatorMessage:'Synthetic moderator message',status:'open',now:f.now()};
 assert.equal(await linkVerifiedLegacyCase(f.db,common),false);
 f.sqlite.prepare('INSERT INTO asc_account_verified_links VALUES(?,?,?,?)').run('roblox_oidc','321',accountId,f.now());
 assert.equal(await linkVerifiedLegacyCase(f.db,common),true);
 assert.equal(await linkVerifiedLegacyCase(f.db,common),false);
 const [notice]=(await f.post('history',{},session,false)).data.notices;
 assert.equal(notice.appealStatus,'not_appealed');
 assert.deepEqual((await f.post('history',{accountId},other)).data.notices,[]);
 assert.equal((await f.post('appeal',{id:notice.id,description:desc},other)).status,409);
 const result=await Promise.all(Array.from({length:2},()=>f.post('appeal',{id:notice.id,description:desc},session,false)));
 assert.deepEqual(result.map(x=>x.status).sort(),[200,409]);
 f.sqlite.prepare("UPDATE asc_account_cases SET status='approved' WHERE id=?").run(notice.id);
 assert.equal((await f.post('appeal',{id:notice.id,description:desc},session,false)).status,409);
 const approved=(await f.post('history',{},session,false)).data.notices[0];
 assert.equal(approved.appealStatus,'approved');assert.equal(approved.canAppealAgain,false);
 assert.equal((await f.post('feedback',{description:desc},session,false)).status,200);
 assert.equal((await f.post('profile',{nickname:'Private nick',image:'0',banner:null,color:'#112233'},cookie)).status,400);
 assert.equal((await f.post('profile',{nickname:'Private nick',image:'124',banner:null,color:'#112233'},cookie)).status,400);
 assert.equal((await f.post('profile',{nickname:'Private nick',image:'123',banner:null,color:'#112233'},cookie)).status,200);
 const profile=(await f.post('session',{},session,false)).data.account;
 assert.equal(profile.nickname,'Private nick');assert.equal(profile.image,'123');assert.equal(profile.bannerColor,'#112233');
 change.run('banned',accountId);
 assert.equal((await f.post('heartbeat',{},session,false)).status,403);
 assert.equal((await f.post('feedback',{description:desc},session,false)).status,403);
 assert.equal((await f.post('session',{},session,false)).data.account.status,'banned');
 assert.equal((await f.post('history',{},session,false)).data.notices.length,1);
});

test('website has a syntactically valid login client and refuses registration without widget configuration',()=>{
 const html=website('','syntheticNonce');
 new Script(html.split('<script nonce="syntheticNonce">')[1].split('</script>')[0]);
 assert.match(html,/Registration is unavailable/);
 assert.doesNotMatch(html,/class="cf-turnstile"/);
 const configured=website('synthetic_public_key','syntheticNonce');
 assert.match(configured,/data-action="asc_register"/);
});
