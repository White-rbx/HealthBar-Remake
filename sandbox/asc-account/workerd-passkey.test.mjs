import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';

const runtime=process.env.ASC_ACCOUNT_WORKERD_PREFIX;
const root=fileURLToPath(new URL('../../',import.meta.url));
const origin='https://arcscriptcenter-account-qa.kogpasan14.workers.dev';

test('Cloudflare workerd bundled Passkey QA has strict pages, challenge flow and no password endpoints',
 {skip:!runtime && 'ASC_ACCOUNT_WORKERD_PREFIX required'},async()=>{
 const require=createRequire(join(runtime,'package.json'));
 const {Miniflare,Response:MockResponse}=require('miniflare');
 const worker=new Miniflare({
  modules:true,
  scriptPath:join(root,'sandbox/asc-account/dist/account-passkey-worker.mjs'),
  modulesRoot:root,
  compatibilityDate:'2026-08-06',
  compatibilityFlags:['nodejs_compat'],
  d1Databases:{ACCOUNT_DB:'asc-passkey-isolated-local-workerd'},
  bindings:{
   ASC_ACCOUNT_MODE:'isolated-qa',ASC_ACCOUNT_AUTH_MODE:'passkey',
   ASC_ACCOUNT_LAUNCH_STATE:'isolated-test-enabled',
   ACCOUNT_TOTP_KEY:'ab'.repeat(32),
   ACCOUNT_TURNSTILE_SECRET:'synthetic-secret',
   ACCOUNT_TURNSTILE_SITE_KEY:'synthetic_site',
  },
  ratelimits:{ACCOUNT_RATE:{namespace_id:'32110',simple:{limit:40,period:60}}},
  outboundService:async request=>{
   if(request.url==='https://challenges.cloudflare.com/turnstile/v0/siteverify'){
    const input=await request.json();
    assert.equal(input.secret,'synthetic-secret');
    return MockResponse.json({success:['synthetic-valid','synthetic-recover'].includes(input.response),
     action:input.response==='synthetic-recover'?'asc_recover':'asc_register',
     hostname:new URL(origin).hostname});
   }
   throw Error('Unexpected external request in Passkey QA test');
  },
 });
 try{
  const db=await worker.getD1Database('ACCOUNT_DB');
  for(const file of ['asc_unified_account_ISOLATED_QA_ONLY.sql','asc_passkey_ISOLATED_QA_ONLY.sql','asc_passkey_recovery_ISOLATED_QA_ONLY.sql','asc_passkey_backup_ISOLATED_QA_ONLY.sql']){
   const ddl=readFileSync(join(root,'migrations',file),'utf8');
   const commands=ddl.replace(/^--.*$/gm,'').split(';').map(x=>x.trim()).filter(Boolean);
   await db.batch(commands.map(sql=>db.prepare(sql)));
  }
  const fetcher=(path,options={})=>worker.dispatchFetch(origin+path,options);
  const health=await fetcher('/health');
  assert.equal(health.status,200);
  const state=await health.json();
  assert.equal(state.authMode,'passkey');
  assert.equal(state.environment,'qa');
  const page=await fetcher('/');
  assert.equal(page.status,200);
  assert.match(page.headers.get('content-security-policy'),/script-src 'self'/);
  const html=await page.text();
  assert.match(html,/passkey-login/);
  assert.match(html,/cf-turnstile/);
  assert.match(html,/id="add-backup-passkey"/);
  assert.match(html,/id="recovery-form"/);
  assert.match(html,/id="recovery-codes"/);
  assert.match(html,/if you lose all passkeys and recovery codes/i);
  assert.doesNotMatch(html,/there is no account recovery yet/i);
  assert.match(html,/arcscriptcenter-login/);
  assert.match(html,/id="landing"/);
  assert.match(html,/id="tab-account"/);
  assert.match(html,/id="open-signin"/);
  assert.match(html,/<h2>Sign In page<\/h2>/);
  assert.match(html,/<h2>MyAccount<\/h2>/);
  // Password layout is visible but strictly disabled; only Passkey sends credentials.
  assert.match(html,/type="password"[^>]*disabled/i);
  assert.doesNotMatch(html,/name="password"|autocomplete="current-password"/i);
  for(const path of ['/login','/signin','/myaccount']){
   const page=await fetcher(path);
   assert.equal(page.status,200,path);
   assert.match(await page.text(),/arcscriptcenter-login/);
  }
  assert.equal((await fetcher('/not-a-qa-page')).status,404);

  const script=await fetcher('/passkey-client.js');
  assert.equal(script.status,200);
  const scriptContent=await script.text();
  assert.match(scriptContent,/navigator\.credentials\.get/);
  assert.match(scriptContent,/passkey\/backup\/verify-current/);
  assert.match(scriptContent,/passkey\/recovery\/verify/);
  const css=await fetcher('/passkey-style.css');
  assert.equal(css.status,200);
  assert.match(await css.text(),/color-scheme:dark/);

  const headers={Origin:origin,'Content-Type':'application/json'};
  const legacy=await fetcher('/api/v1/accounts/login',{
   method:'POST',headers,body:JSON.stringify({username:'testuser',password:'no-password-qa'}),
  });
  assert.equal(legacy.status,403);
  assert.equal((await legacy.json()).code,'password_flow_disabled');

  const backupUnauth=await fetcher('/api/v1/accounts/passkey/backup/options',{
   method:'POST',headers,body:'{}',
  });
  assert.equal(backupUnauth.status,401);
  assert.equal((await backupUnauth.json()).code,'session_expired');
  const badRecovery=await fetcher('/api/v1/accounts/passkey/recovery/options',{
   method:'POST',headers,body:JSON.stringify({
    username:'nosuchuser',code:'0'.repeat(32),presence:true,turnstile:'synthetic-recover',
   }),
  });
  assert.equal(badRecovery.status,401);
  assert.equal((await badRecovery.json()).code,'recovery_failed');
  const begin=await fetcher('/api/v1/accounts/passkey/login/options',{
   method:'POST',headers,body:'{}',
  });
  assert.equal(begin.status,200);
  const payload=await begin.json();
  assert.equal(payload.ok,true);
  assert.equal(payload.options.rpId,new URL(origin).hostname);
  assert.equal(payload.options.userVerification,'required');
  const cookie=begin.headers.get('Set-Cookie');
  assert.match(cookie,/__Host-ascqa-passkey-flow/);
  const invalid=await fetcher('/api/v1/accounts/passkey/login/verify',{
   method:'POST',headers:{...headers,Cookie:cookie.split(';')[0]},
   body:JSON.stringify({response:{id:'not-a-valid-credential'}}),
  });
  assert.equal(invalid.status,400);
  const used=await fetcher('/api/v1/accounts/passkey/login/verify',{
   method:'POST',headers:{...headers,Cookie:cookie.split(';')[0]},
   body:JSON.stringify({response:{id:'not-a-valid-credential'}}),
  });
  assert.equal(used.status,410);
  assert.equal((await db.prepare('SELECT COUNT(*) AS n FROM asc_accounts').first()).n,0);
 }finally{await worker.dispose()}
});

test('isolated preview uses its fixed WebAuthn origin and validates both Turnstile purposes',
 {skip:!runtime && 'ASC_ACCOUNT_WORKERD_PREFIX required'},async()=>{
 const require=createRequire(join(runtime,'package.json'));
 const {Miniflare,Response:MockResponse}=require('miniflare');
 const preview='https://arcscriptcenter-account-preview.qa.invalid';
 const module=readFileSync(join(root,'sandbox/asc-account/dist/account-passkey-worker.mjs'),'utf8');
 const verificationCalls=[];
 const worker=new Miniflare({
  modules:[
   {type:'ESModule',path:'entry.mjs',contents:
    'import {createAccountWorker} from "./candidate.mjs"; export default createAccountWorker({origin:'+JSON.stringify(preview)+'});'},
   {type:'ESModule',path:'candidate.mjs',contents:module},
  ],
  compatibilityDate:'2026-08-06',compatibilityFlags:['nodejs_compat'],
  d1Databases:{ACCOUNT_DB:'asc-eslogin-preview-origin-local'},
  bindings:{
   ASC_ACCOUNT_MODE:'isolated-qa',ASC_ACCOUNT_AUTH_MODE:'passkey',
   ASC_ACCOUNT_LAUNCH_STATE:'isolated-test-enabled',ACCOUNT_TOTP_KEY:'cd'.repeat(32),
   ACCOUNT_TURNSTILE_SECRET:'fixture-only',ACCOUNT_TURNSTILE_SITE_KEY:'fixture_site',
  },
  ratelimits:{ACCOUNT_RATE:{namespace_id:'32111',simple:{limit:40,period:60}}},
  outboundService:async request=>{
   assert.equal(request.url,'https://challenges.cloudflare.com/turnstile/v0/siteverify');
   const {secret,response}=await request.json();
   assert.equal(secret,'fixture-only');
   verificationCalls.push(response);
   return MockResponse.json({success:true,hostname:response==='canonical_host'
    ?new URL(origin).hostname:new URL(preview).hostname,
   action:response==='recover_action'?'asc_recover':'asc_register'});
  },
 });
 try {
  const db=await worker.getD1Database('ACCOUNT_DB');
  for(const file of ['asc_unified_account','asc_passkey','asc_passkey_recovery','asc_passkey_backup']){
   const ddl=readFileSync(join(root,'migrations',file+'_ISOLATED_QA_ONLY.sql'),'utf8');
   const statements=ddl.replace(/^--.*$/gm,'').split(';').map(x=>x.trim()).filter(Boolean);
   await db.batch(statements.map(sql=>db.prepare(sql)));
  }
  const post=(op,body,caller=preview)=>worker.dispatchFetch(preview+'/api/v1/accounts/'+op,{
   method:'POST',headers:{Origin:caller,'Content-Type':'application/json',
    'X-Forwarded-Host':new URL(origin).hostname},body:JSON.stringify(body),
  });
  assert.equal((await worker.dispatchFetch(origin+'/')).status,404);
  assert.equal((await post('passkey/login/options',{},origin)).status,404);
  const page=await worker.dispatchFetch(preview+'/');
  assert.equal(page.status,200);
  assert.match(await page.text(),/Sign in with a passkey/);
  const login=await post('passkey/login/options',{});
  assert.equal(login.status,200);
  assert.equal((await login.json()).options.rpId,new URL(preview).hostname);
  assert.match(login.headers.get('Set-Cookie'),/Path=\/; Secure; HttpOnly; SameSite=Strict/);
  const registration={username:'Preview_Only',presence:true};
  for(const token of ['canonical_host','recover_action']){
   const bad=await post('passkey/register/options',{...registration,turnstile:token});
   assert.equal(bad.status,400);
   assert.equal((await bad.json()).code,'verification_required');
  }
  const reg=await post('passkey/register/options',{...registration,turnstile:'register_action'});
  assert.equal(reg.status,200);
  assert.equal((await reg.json()).options.rp.id,new URL(preview).hostname);
  const recovery=await post('passkey/recovery/options',{...registration,code:'f'.repeat(32),turnstile:'register_action'});
  assert.equal(recovery.status,400);
  assert.equal((await recovery.json()).code,'verification_required');
  assert.deepEqual(verificationCalls,['canonical_host','recover_action','register_action','register_action']);
  assert.equal((await db.prepare('SELECT COUNT(*) AS n FROM asc_accounts').first()).n,0);
 }finally{await worker.dispose()}
});
