// Local Chromium plus a virtual authenticator. No request goes to an edge Worker.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {join} from 'node:path';
import test from 'node:test';
import {fileURLToPath} from 'node:url';
import {EDGE_QA_ORIGIN as origin} from './eslogin-independent-edge-qa.mjs';

const runtime = process.env.ASC_ACCOUNT_WORKERD_PREFIX;
const root = fileURLToPath(new URL('../../',import.meta.url));
const api = '/api/v1/accounts/';

// These are synthetic browser profiles, not real Google Password Manager devices.
// Each case starts with an independent in-memory Worker and D1 fixture.
for(const profile of [
 {name:'Mobile Chromium',viewport:{width:393,height:852},isMobile:true,hasTouch:true},
 {name:'Desktop Chromium',viewport:{width:1280,height:900},isMobile:false,hasTouch:false},
]){
test(`isolated ESLogin ${profile.name} registers, signs in, adds a backup, pairs, and recovers`, {
 skip: !runtime && 'requires Miniflare, playwright-core and Chromium', timeout: 90000,
}, async t => {
 const require = createRequire(join(runtime,'package.json'));
 const {Miniflare,Response:LocalResponse} = require('miniflare');
 const {chromium} = require('playwright-core');
 const worker = new Miniflare({
  modules:true,scriptPath:join(root,'sandbox/asc-account/dist/eslogin-edge-qa.mjs'),
  compatibilityDate:'2026-08-06',compatibilityFlags:['nodejs_compat'],
  d1Databases:{ACCOUNT_DB:'browser-fixture'},
  ratelimits:{ACCOUNT_RATE:{namespace_id:'20261125',simple:{limit:40,period:60}}},
  bindings:{ASC_ACCOUNT_MODE:'isolated-qa',ASC_ACCOUNT_AUTH_MODE:'passkey',
   ASC_ACCOUNT_LAUNCH_STATE:'isolated-test-enabled',ASC_ACCOUNT_ACHIEVEMENTS:'isolated-qa-enabled',ACCOUNT_TOTP_KEY:'ab'.repeat(32),
   ACCOUNT_TURNSTILE_SECRET:'fixture',ACCOUNT_TURNSTILE_SITE_KEY:'fixture_site'},
  outboundService:async request=>{
   if(new URL(request.url).origin==='https://thumbnails.roblox.com'){
    return LocalResponse.json({data:[{targetId:123,state:'Completed',imageUrl:'https://t0.rbxcdn.com/qa-fixture'}]});
   }
   assert.equal(request.url,'https://challenges.cloudflare.com/turnstile/v0/siteverify');
   const {response,secret}=await request.json();
   return LocalResponse.json({success:secret==='fixture'&&['asc_register','asc_recover'].includes(response),
    hostname:new URL(origin).hostname,action:response});
  },
 });
 t.after(()=>worker.dispose());
 const db=await worker.getD1Database('ACCOUNT_DB');
 for(const name of ['asc_unified_account','asc_passkey','asc_passkey_recovery','asc_passkey_backup','asc_passkey_account_actions','asc_achievements']){
  const sql=readFileSync(join(root,'migrations',name+'_ISOLATED_QA_ONLY.sql'),'utf8');
  await db.batch(sql.replace(/^--.*$/gm,'').split(';').map(s=>s.trim()).filter(Boolean).map(s=>db.prepare(s)));
 }
 const browser=await chromium.launch({executablePath:process.env.ASC_CHROMIUM_BIN});
 t.after(()=>browser.close());
 const context=await browser.newContext({viewport:profile.viewport,isMobile:profile.isMobile,hasTouch:profile.hasTouch,serviceWorkers:'block'});
 const page=await context.newPage();
 page.setDefaultTimeout(9000);
 const cdp=await context.newCDPSession(page);
 await cdp.send('WebAuthn.enable');
 async function authenticator(){
  const {authenticatorId}=await cdp.send('WebAuthn.addVirtualAuthenticator',{options:{
   protocol:'ctap2',transport:'usb',hasResidentKey:true,hasUserVerification:true,
   automaticPresenceSimulation:true,isUserVerified:true,
  }});
  return authenticatorId;
 }
 let device=await authenticator();
 async function replaceDevice(){
  await cdp.send('WebAuthn.removeVirtualAuthenticator',{authenticatorId:device});
  device=await authenticator();
 }
 const fixtureRoute=async route=>{
  const req=route.request(),url=new URL(req.url());
  if(url.origin!==origin)return route.abort();
  const headers=await req.allHeaders();
  const response=await worker.dispatchFetch(url.href,{method:req.method(),headers,body:req.postData()??undefined});
  const h=Object.fromEntries(response.headers);
  if(response.headers.has('set-cookie'))h['set-cookie']=response.headers.getSetCookie().join('\n');
  if(url.pathname===api+'passkey/backup/verify-current'&&response.ok)await replaceDevice();
  // Playwright relays Chromium's own Origin and cookie headers without overriding them.
  await route.fulfill({status:response.status,headers:h,body:Buffer.from(await response.arrayBuffer())});
 };
 await context.route('**/*',fixtureRoute);
 async function submit(form,action){
  // Fixture replaces only Turnstile output in the disconnected local browser.
  await form.evaluate((form,action)=>{
   const field=document.createElement('input');
   field.type='hidden';field.name='cf-turnstile-response';field.value=action;form.append(field);
  },action);
  await form.locator('[name=presence]').check();
  await form.locator('[type=submit]').click();
 }
 const status=fragment=>page.locator('#status').filter({hasText:fragment}).waitFor();
 const loader=(op,body={},session)=>worker.dispatchFetch(origin+api+op,{
  method:'POST',headers:{'Content-Type':'application/json',...(session?{Authorization:'Bearer '+session}:{})},
  body:JSON.stringify(body),
 });
 async function pair(){
  const begin=await loader('pair/start');assert.equal(begin.status,200);
  const {code,secret}=await begin.json();
  const form=page.locator('#pair-form');
  await form.locator('[name=code]').evaluate((field,value)=>{field.value=value;},code);
  await form.locator('[name=confirm]').check();
  await form.locator('button').click();
  await status('Pairing approved');
  const response=await loader('pair/poll',{secret,remember:true});
  assert.equal(response.status,200);
  const result=await response.json();
  assert.equal(result.state,'ready');
  assert.equal((await loader('pair/poll',{secret,remember:true})).status,410);
  return result.session;
 }
 await page.goto(origin+'/login');
 await page.locator('#open-signin').click();
 await page.locator('#tab-register').click();
 const reg=page.locator('#register-form');
 await reg.locator('[name=username]').fill('SyntheticBrowser');
 await submit(reg,'asc_register');
 await status('Passkey registered');
 const codes=(await page.locator('#recovery-code-list').textContent()).trim().split('\n');
 assert.equal(codes.length,8);
 await page.locator('#sign-out').click();
 await status('Signed out');
 await page.locator('#open-signin').click();
 await page.locator('#passkey-login').click();
 await status('Signed in using a passkey');
 await page.locator('#add-backup-passkey').click();
 await status('Backup passkey added');
 await page.locator('#sign-out').click();
 await status('Signed out');
 await page.locator('#open-signin').click();
 await page.locator('#passkey-login').click();
 await status('Signed in using a passkey');
 await page.getByText('Profile',{exact:true}).click();
 await page.locator('#profile-nickname').fill('Browser QA');
 await page.locator('#profile-image').fill('123');
 await page.locator('#profile-banner-id').fill('123');
 await page.getByRole('button',{name:'Preview images'}).click();
 await status('Image preview. Save profile to apply.');
 assert.equal(await page.locator('#avatar-image').getAttribute('src'),'https://t0.rbxcdn.com/qa-fixture');
 assert.equal(await page.locator('#banner-image').getAttribute('src'),'https://t0.rbxcdn.com/qa-fixture');
 assert.equal((await db.prepare("SELECT profile_image FROM asc_accounts WHERE username='syntheticbrowser'").first()).profile_image,null);
 await page.getByRole('button',{name:'Save profile'}).click();
 await status('Profile saved');
 assert.equal(await page.locator('#identity').textContent(),'Browser QA (@syntheticbrowser)');
 assert.match(await page.locator('#arc-id').textContent(),/^ArcID [0-9a-f-]{36}$/);
 assert.equal(await page.locator('#avatar-image').getAttribute('src'),'https://t0.rbxcdn.com/qa-fixture');
 assert.equal(await page.locator('#violation-history').isVisible(),false);
 assert.equal(await page.locator('#moderator').isVisible(),false);
 await page.getByText('Feedback and case history',{exact:true}).click();
 await page.locator('#feedback-topic').fill('Synthetic feedback');
 await page.locator('#feedback-description').fill('Synthetic account feedback long enough for the approved submission form.');
 await page.locator('#send-feedback').click();
 await status('Feedback submitted for review');
 await page.locator('#account-achievements summary').click();
 await page.locator('#load-achievements').click();
 await status('Achievements refreshed');
 assert.match(await page.locator('#achievement-list').textContent(),/Feedback · First sent/);
 assert.doesNotMatch(await page.locator('#achievement-list').textContent(),/Bug Hunter/);
 const anonymousAwards=await worker.dispatchFetch(origin+api+'achievements',{
  method:'POST',headers:{Origin:origin,'Content-Type':'application/json'},body:'{}',
 });
 assert.equal(anonymousAwards.status,401);
 const loaderAwards=await worker.dispatchFetch(origin+api+'achievements',{
  method:'POST',headers:{'Content-Type':'application/json'},body:'{}',
 });
 assert.equal(loaderAwards.status,404);
 await page.locator('#feedback-history').getByRole('button',{name:'Edit'}).click();
 await page.locator('#feedback-topic').fill('Updated synthetic feedback');
 await page.locator('#send-feedback').click();
 await status('Feedback updated');
 assert.match(await page.locator('#feedback-history').textContent(),/Updated synthetic feedback/);
 await page.locator('#feedback-history').getByRole('button',{name:'Remove'}).click();
 await status('Feedback removed');
 assert.equal(await page.locator('#feedback-history').getByRole('button',{name:'Edit'}).count(),0);
 const accountId=(await db.prepare('SELECT id FROM asc_accounts WHERE username=?').bind('syntheticbrowser').first()).id;
 await db.prepare("INSERT INTO asc_account_cases(id,account_id,kind,reason,created_at) VALUES(?,?,'violation',?,?)")
  .bind(crypto.randomUUID(),accountId,'Synthetic moderation case',1800000000).run();
 await page.locator('#load-cases').click();
 await status('Cases refreshed');
 await page.locator('#violation-history summary').click();
 await page.locator('#violations textarea').fill('Synthetic appeal asking the moderator to review this account violation.');
 await page.locator('#violations').getByRole('button',{name:'Submit appeal'}).click();
 await status('Appeal submitted for review');
 assert.equal(await page.locator('#violations').getByRole('button',{name:'Submit appeal'}).count(),0);

 const browserRevoked=await pair();
 await page.getByText('Security and active sessions',{exact:true}).click();
 await page.locator('#load-sessions').click();
 await status('Sessions refreshed');
 await page.getByRole('button',{name:'Revoke session'}).click();
 await status('Session revoked');
 assert.equal((await loader('session',{},browserRevoked)).status,401);
 const first=await pair();
 assert.equal((await (await loader('session',{},first)).json()).account.status,'normal');
 await db.prepare("UPDATE asc_accounts SET status='restricted_mode' WHERE username=?").bind('syntheticbrowser').run();
 assert.equal((await (await loader('session',{},first)).json()).account.status,'restricted_mode');
 await db.prepare("UPDATE asc_account_sessions SET expires_at=0 WHERE scope='loader'").run();
 assert.equal((await loader('session',{},first)).status,401);
 const second=await pair();
 assert.equal((await loader('logout',{},second)).status,200);
 assert.equal((await loader('session',{},second)).status,401);
 const third=await pair();
 await page.locator('#sign-out').click();
 await status('Signed out');
 await page.locator('#open-signin').click();
 await page.locator('#tab-recovery').click();
 const recover=page.locator('#recovery-form');
 await recover.locator('[name=username]').fill('SyntheticBrowser');
 await recover.locator('[name=code]').evaluate((field,value)=>{field.value=value;},codes[0]);
 await replaceDevice();
 await submit(recover,'asc_recover');
 await status('Account recovered');
 assert.equal((await loader('session',{},third)).status,401);
 assert.equal((await db.prepare('SELECT count(*) AS n FROM asc_account_passkeys').first()).n,1);
 const challenge=await worker.dispatchFetch(origin+api+'passkey/login/options',{
  method:'POST',headers:{Origin:origin,'Content-Type':'application/json'},body:'{}',
 });
 assert.equal(challenge.status,200);
 const challengeCookie=challenge.headers.getSetCookie()[0].split(';',1)[0];
 await db.prepare('UPDATE asc_account_passkey_flows SET created_at=1, expires_at=2').run();
 const expired=await worker.dispatchFetch(origin+api+'passkey/login/verify',{
  method:'POST',headers:{Origin:origin,Cookie:challengeCookie,'Content-Type':'application/json'},
  body:JSON.stringify({response:{id:'expired-local-fixture'}}),
 });
 assert.equal(expired.status,410);
 const newCodes=(await page.locator('#recovery-code-list').textContent()).trim().split('\n');
 assert.equal(newCodes.length,8);
 assert.ok(!newCodes.some(code=>codes.includes(code)));
 // Synthetic cross-context reuse of one resident credential, not Google sync.
 // Only locally generated virtual credentials are copied; never print or persist them.
 if(profile.isMobile){
  const before=await db.prepare('SELECT id FROM asc_accounts').first();
  const virtual=await cdp.send('WebAuthn.getCredentials',{authenticatorId:device});
  assert.equal(virtual.credentials.length,1);
  await page.locator('#sign-out').click();
  await status('Signed out');
  const desktop=await browser.newContext({viewport:{width:1280,height:900},serviceWorkers:'block'});
  try{
   await desktop.route('**/*',fixtureRoute);
   const other=await desktop.newPage();
   other.setDefaultTimeout(9000);
   const otherCDP=await desktop.newCDPSession(other);
   await otherCDP.send('WebAuthn.enable');
   const {authenticatorId}=await otherCDP.send('WebAuthn.addVirtualAuthenticator',{options:{
    protocol:'ctap2',transport:'usb',hasResidentKey:true,hasUserVerification:true,
    automaticPresenceSimulation:true,isUserVerified:true,
   }});
   // Transfer the test-only resident key in memory to simulate availability on
   // another device. This does not exercise a real password-manager sync service.
   await otherCDP.send('WebAuthn.addCredential',{authenticatorId,credential:virtual.credentials[0]});
   await other.goto(origin+'/login');
   await other.locator('#open-signin').click();
   await other.locator('#passkey-login').click();
   await other.locator('#status').filter({hasText:'Signed in using a passkey'}).waitFor();
   assert.equal((await db.prepare('SELECT count(*) AS n FROM asc_accounts').first()).n,1);
   assert.equal((await db.prepare('SELECT count(*) AS n FROM asc_account_passkeys').first()).n,1);
   assert.equal((await db.prepare('SELECT id FROM asc_accounts').first()).id,before.id);
   const active=await db.prepare("SELECT account_id FROM asc_account_sessions WHERE scope='web' AND revoked_at IS NULL AND expires_at>?").bind(Math.floor(Date.now()/1000)).first();
   assert.equal(active?.account_id,before.id);
   await other.locator('#sign-out').click();
   await other.locator('#status').filter({hasText:'Signed out'}).waitFor();
  } finally {await desktop.close();}
 }

});
}
