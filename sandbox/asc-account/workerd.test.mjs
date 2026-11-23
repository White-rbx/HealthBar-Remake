import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';

const runtime = process.env.ASC_ACCOUNT_WORKERD_PREFIX;
const root = fileURLToPath(new URL('../../', import.meta.url));
const origin = 'https://arcscriptcenter-account-qa.kogpasan14.workers.dev';

test('Workers runtime: creates accounts through Siteverify, validates assets, and persists session revocation',
 {skip: !runtime && 'Set ASC_ACCOUNT_WORKERD_PREFIX to the directory with the Miniflare installation'}, async () => {
 const require = createRequire(join(runtime, 'package.json'));
 const {Miniflare, Response: MockResponse} = require('miniflare');
 const worker = new Miniflare({
  modules:true,scriptPath:join(root,'sandbox/asc-account/worker.mjs'),modulesRoot:root,
  compatibilityDate:'2026-08-06',compatibilityFlags:['nodejs_compat'],
  d1Databases:{ACCOUNT_DB:'asc-unified-account-local-workerd'},
  bindings:{ASC_ACCOUNT_MODE:'isolated-qa',ACCOUNT_TURNSTILE_SITE_KEY:'synthetic_site',ACCOUNT_TURNSTILE_SECRET:'synthetic_secret'},
  ratelimits:{ACCOUNT_RATE:{namespace_id:'32109',simple:{limit:40,period:60}}},
  outboundService:async request=>{
   const url = new URL(request.url);
   if (url.href === 'https://challenges.cloudflare.com/turnstile/v0/siteverify') {
    const body = await request.json();
    assert.equal(body.secret, 'synthetic_secret');
    if (body.response === 'redirected') return MockResponse.redirect('https://synthetic.invalid');
    return MockResponse.json({success:body.response==='valid',hostname:new URL(origin).hostname,action:'asc_register'});
   }
   assert.equal(url.origin,'https://thumbnails.roblox.com');
   assert.equal(url.searchParams.get('assetIds'),'123');
   return MockResponse.json({data:[{targetId:123,state:'Completed',imageUrl:'https://t0.rbxcdn.com/synthetic'}]});
  },
 });
 try {
  const db = await worker.getD1Database('ACCOUNT_DB');
  const ddl = readFileSync(join(root,'migrations/asc_unified_account_ISOLATED_QA_ONLY.sql'),'utf8');
  const statements = ddl.replace(/^--.*$/gm,'').split(';').map(s=>s.trim()).filter(Boolean);
  await db.batch(statements.map(s=>db.prepare(s)));
  const post = async (route, payload={}, headers={}) => {
   const response = await worker.dispatchFetch(origin+'/api/v1/accounts/'+route,{
    method:'POST',headers:{'Content-Type':'application/json',...headers},body:JSON.stringify(payload),
   });
   return {status:response.status,body:await response.json(),cookie:response.headers.get('Set-Cookie')?.split(';')[0]};
  };
  const page = await worker.dispatchFetch(origin+'/');
  assert.equal(page.status,200);
  assert.match(await page.text(),/data-action="asc_register"/);
  const browser = {Origin:origin};
  const password = 'Synthetic runtime password 123';
  const registration = {username:'workerd_qa',password,confirmation:password,presence:true};
  const register = turnstile => post('register',{...registration,turnstile},browser);
  assert.equal((await register('invalid')).status,400);
  assert.equal((await register('redirected')).status,503);
  assert.equal((await register('valid')).status,200);
  const login = await post('login',{username:registration.username,password},browser);
  assert.equal(login.status,200);
  const web = {...browser,Cookie:login.cookie};
  assert.equal((await post('profile',{nickname:'Synthetic QA',image:'123',banner:null,color:'#112233'},web)).status,200);
  const pair = await post('pair/start');
  assert.equal(pair.status,200);
  assert.equal((await post('pair/approve',{code:pair.body.code,confirm:true},web)).status,200);
  const loader = await post('pair/poll',{secret:pair.body.secret});
  assert.equal(loader.status,200);
  const auth = {Authorization:'Bearer '+loader.body.session};
  assert.equal((await post('heartbeat',{},auth)).body.account.nickname,'Synthetic QA');
  assert.equal((await post('history',{},auth)).body.notices.length,0);
  assert.equal((await post('logout',{},auth)).status,200);
  assert.equal((await post('session',{},auth)).status,401);
  assert.equal((await db.prepare('SELECT count(*) AS n FROM asc_account_sessions WHERE revoked_at IS NOT NULL').first()).n,1);
 } finally {
  await worker.dispose();
 }
});
