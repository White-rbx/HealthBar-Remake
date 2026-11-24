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
    return MockResponse.json({success:input.response==='synthetic-valid',
     action:'asc_register',hostname:new URL(origin).hostname});
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
  assert.doesNotMatch(html,/type=["']password["']|autocomplete=["']current-password["']/i);

  const script=await fetcher('/passkey-client.js');
  assert.equal(script.status,200);
  assert.match(await script.text(),/navigator\.credentials\.get/);
  const css=await fetcher('/passkey-style.css');
  assert.equal(css.status,200);
  assert.match(await css.text(),/color-scheme:dark/);

  const headers={Origin:origin,'Content-Type':'application/json'};
  const legacy=await fetcher('/api/v1/accounts/login',{
   method:'POST',headers,body:JSON.stringify({username:'testuser',password:'no-password-qa'}),
  });
  assert.equal(legacy.status,403);
  assert.equal((await legacy.json()).code,'password_flow_disabled');

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
