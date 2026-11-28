import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import * as gatewayModule from './isolated-pairing-gateway-candidate.mjs';
import {createLoaderGatewayCandidate} from './isolated-loader-gateway-candidate.mjs';

const {createPairingGatewayCandidate}=gatewayModule;
const origin='https://pairing.qa.invalid';
const prefix='/api/v1/accounts/';
const now=1795440001;

function fixture(withQuota=true){
 const sqlite=new DatabaseSync(':memory:');
 sqlite.exec(readFileSync(new URL('../../migrations/asc_unified_account_ISOLATED_QA_ONLY.sql',import.meta.url),'utf8'));
 if(withQuota)sqlite.exec(quotaSchema);
 const db={prepare(sql){
  return {bind(...params){
   return {
    async first(){return sqlite.prepare(sql).get(...params)??null},
    async run(){return sqlite.prepare(sql).run(...params)},
    execute(){const p=sqlite.prepare(sql);
     return p.columns().length?{results:p.all(...params)}:{meta:p.run(...params)};
    },
   };
  }};
 },async batch(ops){
  sqlite.exec('BEGIN IMMEDIATE');
  try{const result=ops.map(x=>x.execute());sqlite.exec('COMMIT');return result}
  catch(error){sqlite.exec('ROLLBACK');throw error}
 }};
 let allowed=true, time=now;
 const calls=[];
 const env={
  ASC_PAIR_GATEWAY_MODE:'isolated-qa',
  ASC_PAIR_GATEWAY_LAUNCH_STATE:'explicit-test-enabled',
  PAIR_DB:db,
  PAIR_RATE:{async limit({key}){calls.push(key);return {success:allowed}}},
 };
 const handler=createPairingGatewayCandidate({origin,clock:()=>time});
 const post=async(op,body={},headers={})=>{
  const r=await handler.fetch(new Request(origin+prefix+op,{
   method:'POST',headers:{'Content-Type':'application/json',...headers},body:JSON.stringify(body),
  }),env);
  return {status:r.status,body:await r.json(),response:r};
 };
 const grant=()=>{
  sqlite.prepare('INSERT INTO asc_accounts(id,username,password_hash,nickname,created_at) VALUES(?,?,?,?,?)')
   .run('account-a','synthetic_qatest','synthetic-only','Synthetic QA',now);
  sqlite.prepare('INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at) VALUES(?,?,?,?,?,?)')
   .run('web-a','account-a','f'.repeat(64),'web',now,now+3000);
 };
 const approve=code=>sqlite.prepare(`UPDATE asc_account_pairings
 SET account_id='account-a',authorizing_session_id='web-a' WHERE code=?`).run(code);
 return {sqlite,env,handler,post,grant,approve,calls,deny:()=>allowed=false,
  advance:seconds=>{time+=seconds}};
}

test('Candidate is not a deployable default Worker; no endpoint is active without explicit flags',async()=>{
 assert.equal('default' in gatewayModule,false);
 assert.throws(()=>createPairingGatewayCandidate({origin:'http://pairing.qa.invalid'}),/HTTPS/);
 const f=fixture();
 for(const variable of ['ASC_PAIR_GATEWAY_MODE','ASC_PAIR_GATEWAY_LAUNCH_STATE','PAIR_DB','PAIR_RATE']){
  const env={...f.env};delete env[variable];
  const r=await f.handler.fetch(new Request(origin+prefix+'pair/start',{
   method:'POST',headers:{'Content-Type':'application/json'},body:'{}',
  }),env);
  assert.equal(r.status,503,variable);
  assert.equal((await r.json()).code,'pairing_gateway_locked');
 }
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_pairings').get().n,0);
});

test('Only two pairing routes work; browser cookies, Authorization, or Origin never pass',async()=>{
 const f=fixture();
 for(const path of ['/', '/health','/login','/signin','/api/v1/accounts/session',
  '/api/v1/accounts/pair/approve','/api/v1/accounts/passkey/register/options',
  '/api/v1/accounts/history','/api/v1/accounts/feedback']){
  const r=await f.handler.fetch(new Request(origin+path,{method:'POST',
   headers:{'Content-Type':'application/json'},body:'{}'}),f.env);
  assert.equal(r.status,404,path);
 }
 for(const url of [origin+prefix+'pair/start?debug=true',
  origin+prefix+'pair/start#secret',
  'https://untrusted.invalid'+prefix+'pair/start']){
  const r=await f.handler.fetch(new Request(url,{
   method:'POST',headers:{'Content-Type':'application/json'},body:'{}'}),f.env);
  assert.equal(r.status,404,url);
 }
 const get=await f.handler.fetch(new Request(origin+prefix+'pair/start'),f.env);
 assert.equal(get.status,404);
 for(const headers of [
  {Origin:'https://account.qa.invalid'},{Cookie:'__Host-ascqa=token'},
  {Authorization:'Bearer fake'},{'CF-Access-Jwt-Assertion':'fake'},
 ]){
  assert.equal((await f.post('pair/start',{},headers)).status,403,JSON.stringify(headers));
 }
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_pairings').get().n,0);
});

test('Strict JSON validation and fail-closed throttling cannot create sessions',async()=>{
 const f=fixture();
 for(const body of [{account_id:'account-a'},{redirect:'https://evil.invalid'},
  {identityVerified:true},{code:'ABC'}]){
  assert.equal((await f.post('pair/start',body)).status,400);
 }
 for(const body of [{},{secret:'f'.repeat(64),account_id:'account-a'},
  {secret:'g'.repeat(64)},{secret:'a'.repeat(64),remember:'true'}]){
  assert.equal((await f.post('pair/poll',body)).status,400);
 }
 const raw=await f.handler.fetch(new Request(origin+prefix+'pair/start',{
  method:'POST',headers:{'Content-Type':'text/plain'},body:'{}',
 }),f.env);
 assert.equal(raw.status,400);
 const oversized=await f.handler.fetch(new Request(origin+prefix+'pair/start',{
  method:'POST',headers:{'Content-Type':'application/json'},body:' '.repeat(700),
 }),f.env);
 assert.equal(oversized.status,400);
 f.deny();
 const blocked=await f.post('pair/start');
 assert.equal(blocked.status,429);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_pairings').get().n,0);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_sessions').get().n,0);
});

test('Browser-confirmed 5-minute code yields one scoped loader session to secret holder only',async()=>{
 const f=fixture();
 const start=await f.post('pair/start');
 assert.equal(start.status,200);
 assert.equal(start.body.ok,true);
 assert.match(start.body.code,/^[0-9A-F]{12}$/);
 assert.match(start.body.secret,/^[0-9a-f]{64}$/);
 assert.equal(start.body.expiresAt,now+300);
 const before=f.sqlite.prepare('SELECT * FROM asc_account_pairings').get();
 assert.notEqual(before.digest,start.body.secret,'only a digest is stored in D1');
 assert.equal(before.code,start.body.code);
 assert.equal(before.account_id,null);
 assert.equal((await f.post('pair/poll',{secret:start.body.secret})).body.state,'pending');
 assert.equal((await f.post('pair/poll',{secret:'b'.repeat(64)})).status,410);
 f.grant();
 f.approve(start.body.code);
 const [first,second]=await Promise.all([
  f.post('pair/poll',{secret:start.body.secret}),
  f.post('pair/poll',{secret:start.body.secret}),
 ]);
 assert.deepEqual([first.status,second.status].sort(),[200,410]);
 const ready=first.status===200?first:second;
 assert.equal(ready.body.state,'ready');
 assert.match(ready.body.session,/^[0-9a-f]{64}$/);
 assert.equal(ready.body.expiresAt,now+14400);
 const loader=f.sqlite.prepare("SELECT * FROM asc_account_sessions WHERE scope='loader'").get();
 assert.equal(loader.account_id,'account-a');
 assert.equal(loader.expires_at,now+14400);
 assert.notEqual(loader.digest,ready.body.session,'the raw loader token must never be stored');
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_sessions WHERE scope=\'loader\'').get().n,1);
 assert.equal((await f.post('pair/poll',{secret:start.body.secret})).status,410);
 assert.equal(ready.response.headers.get('access-control-allow-origin'),null);
 assert.match(ready.response.headers.get('cache-control'),/no-store/);
});

test('Revoked browser authorization, expiry and reused code never issue loader tokens',async()=>{
 const f=fixture();
 f.grant();
 const start=await f.post('pair/start');
 f.approve(start.body.code);
 f.sqlite.prepare("UPDATE asc_account_sessions SET revoked_at=? WHERE id='web-a'").run(now);
 const denied=await f.post('pair/poll',{secret:start.body.secret});
 assert.equal(denied.status,410);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_sessions WHERE scope=\'loader\'').get().n,0);
 const second=await f.post('pair/start');
 f.approve(second.body.code);
 f.advance(301);
 const expired=await f.post('pair/poll',{secret:second.body.secret});
 assert.equal(expired.status,410);
 const never=f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_sessions WHERE scope=\'loader\'').get();
 assert.equal(never.n,0);
});

test('Full candidate: paired loader bearer is server-verified, heartbeat-scoped and revocable',async()=>{
 const f=fixture();
 const handler=createLoaderGatewayCandidate({origin,clock:()=>now});
 const loader=async(op,token,body={},extra={})=>{
  const request=new Request(origin+prefix+op,{
   method:'POST',headers:{'Content-Type':'application/json',
    ...(token?{Authorization:'Bearer '+token}:{}),...extra},body:JSON.stringify(body),
  });
  const response=await handler.fetch(request,f.env);
  return {status:response.status,body:await response.json(),response};
 };
 const start=await f.post('pair/start');
 f.grant();
 f.approve(start.body.code);
 const approved=await f.post('pair/poll',{secret:start.body.secret});
 assert.equal(approved.status,200);
 const token=approved.body.session;
 const profile=await loader('session',token);
 assert.equal(profile.status,200);
 assert.equal(profile.body.account.id,'account-a');
 assert.deepEqual(profile.body.account,{id:'account-a',nickname:'Synthetic QA',status:'normal',image:null,banner:null,bannerColor:'#102757'});
 assert.equal(profile.body.expiresAt,now+14400);
 assert.equal(profile.response.headers.get('Access-Control-Allow-Origin'),null);
 assert.equal(profile.response.headers.get('Set-Cookie'),null);
 assert.doesNotMatch(JSON.stringify(profile.body),/synthetic-only|f{64}/);
 f.sqlite.prepare("UPDATE asc_accounts SET profile_image='123',banner_image='456',banner_color='#112233' WHERE id='account-a'").run();
 const heartbeat=await loader('heartbeat',token);
 assert.equal(heartbeat.status,200);
 assert.deepEqual(heartbeat.body.account,{id:'account-a',nickname:'Synthetic QA',status:'normal',image:'123',banner:'456',bannerColor:'#112233'});
 assert.deepEqual((await loader('session',token)).body.account,heartbeat.body.account);
 const seen=f.sqlite.prepare("SELECT last_seen FROM asc_account_sessions WHERE scope='loader'").get();
 assert.equal(seen.last_seen,now);
 assert.equal((await loader('session','b'.repeat(64))).status,401);
 assert.equal((await loader('session',token,{userId:1})).status,400);
 assert.equal((await loader('session',token,{}, {Cookie:'__Host-ascqa=synthetic'})).status,403);
 assert.equal((await loader('session',token,{}, {Origin:'https://protected.qa.invalid'})).status,403);
 const loggedOut=await loader('logout',token);
 assert.equal(loggedOut.status,200);
 assert.equal(loggedOut.body.ok,true);
 assert.equal((await loader('session',token)).status,401);
 assert.equal((await loader('heartbeat',token)).status,401);
 assert.equal((await loader('logout',token)).status,401);
 assert.equal(f.sqlite.prepare("SELECT COUNT(*) AS n FROM asc_account_sessions WHERE scope='loader' AND revoked_at IS NOT NULL").get().n,1);
});

test('Full candidate: session endpoint denies missing launch flags and never proxies web/admin routes',async()=>{
 const f=fixture(),handler=createLoaderGatewayCandidate({origin,clock:()=>now});
 const webPaths=['/signin','/myaccount','/api/v1/accounts/security/sessions',
  '/api/v1/accounts/passkey/login/options','/api/v1/accounts/history',
  '/api/v1/accounts/feedback','/api/v1/accounts/appeal'];
 for(const path of webPaths){
  const resp=await handler.fetch(new Request(origin+path,{
   method:'POST',headers:{'Content-Type':'application/json',
    Authorization:'Bearer '+'a'.repeat(64)},body:'{}',
  }),f.env);
  assert.equal(resp.status,404,path);
 }
 const payload=()=>new Request(origin+prefix+'session',{method:'POST',
  headers:{'Content-Type':'application/json',
   Authorization:'Bearer '+'a'.repeat(64)},body:'{}'});
 for(const binding of ['PAIR_DB','PAIR_RATE','ASC_PAIR_GATEWAY_MODE','ASC_PAIR_GATEWAY_LAUNCH_STATE']){
  const env={...f.env};delete env[binding];
  const r=await handler.fetch(payload(),env);
  assert.equal(r.status,503,binding);
  assert.equal((await r.json()).code,'pairing_gateway_locked');
 }
 assert.equal((await handler.fetch(payload(),f.env)).status,401);
 const raw=await handler.fetch(new Request(origin+prefix+'session',{
  method:'POST',headers:{'Content-Type':'application/json',
   Authorization:'Bearer '+'a'.repeat(64)},body:'{}',
 }),f.env);
 assert.equal(raw.status,401);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_sessions').get().n,0);
});

test('Full candidate: revoked or banned account cannot extend live presence',async()=>{
 const f=fixture(),handler=createLoaderGatewayCandidate({origin,clock:()=>now});
 f.grant();
 const start=await f.post('pair/start');
 f.approve(start.body.code);
 const poll=await f.post('pair/poll',{secret:start.body.secret});
 assert.equal(poll.status,200);
 const request=op=>new Request(origin+prefix+op,{
  method:'POST',headers:{'Content-Type':'application/json',
   Authorization:'Bearer '+poll.body.session},body:'{}',
 });
 f.sqlite.prepare("UPDATE asc_accounts SET status='banned' WHERE id='account-a'").run();
 const denied=await handler.fetch(request('heartbeat'),f.env);
 assert.equal(denied.status,403);
 assert.equal((await denied.json()).code,'account_banned');
 const profile=await handler.fetch(request('session'),f.env);
 assert.equal(profile.status,200);
 assert.equal((await profile.json()).account.status,'banned');
 f.sqlite.prepare("UPDATE asc_account_sessions SET revoked_at=? WHERE scope='loader'").run(now);
 assert.equal((await handler.fetch(request('session'),f.env)).status,401);
});

import {quotaSchema,reservePairGatewayBudget} from './isolated-pairing-quota-candidate.mjs';

test('Stage 7 durable QA budget: concurrent admission, per-route isolation and minute reset',async()=>{
 const f=fixture();
 f.sqlite.exec(quotaSchema);
 const result=await Promise.all(Array.from({length:25},()=>reservePairGatewayBudget(f.env,'pair/start',now)));
 assert.equal(result.filter(x=>x.allowed).length,20);
 assert.equal(result.filter(x=>x.status===429).length,5);
 assert.equal((await reservePairGatewayBudget(f.env,'logout',now)).allowed,true);
 assert.equal((await reservePairGatewayBudget(f.env,'pair/start',now+60)).allowed,true);
 assert.equal((await reservePairGatewayBudget(f.env,'pair/start',now)).status,429);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_qa_pair_gateway_budget').get().n,2);
});

test('Stage 7 durable QA budget: daily ceiling and UTC rollover',async()=>{
 const f=fixture();
 f.sqlite.exec(quotaSchema);
 const start=Math.floor(now/86400)*86400;
 for(let minute=0;minute<10;minute++){
  for(let j=0;j<20;j++)assert.equal((await reservePairGatewayBudget(f.env,'pair/start',start+minute*60)).allowed,true);
 }
 assert.equal((await reservePairGatewayBudget(f.env,'pair/start',start+600)).status,429);
 assert.equal((await reservePairGatewayBudget(f.env,'pair/start',start+86400)).allowed,true);
 assert.deepEqual({...f.sqlite.prepare("SELECT minute_count,day_count FROM asc_qa_pair_gateway_budget WHERE op='pair/start'").get()},{minute_count:1,day_count:1});
});

test('Stage 7 durable QA budget: unavailable schema, locked flag and unexpected route fail closed',async()=>{
 const f=fixture(false);
 assert.equal((await f.post('pair/start')).status,503);
 assert.equal((await reservePairGatewayBudget(f.env,'pair/start',now)).status,503);
 f.sqlite.exec(quotaSchema);
 for(const op of ['history','__proto__','constructor','pair/approve']){
  assert.equal((await reservePairGatewayBudget(f.env,op,now)).status,503);
 }
 const locked={...f.env,ASC_PAIR_GATEWAY_LAUNCH_STATE:'locked'};
 assert.equal((await reservePairGatewayBudget(locked,'pair/start',now)).status,503);
 assert.equal((await reservePairGatewayBudget(f.env,'pair/start',NaN)).status,503);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_qa_pair_gateway_budget').get().n,0);
});

 test('Gateway admission caps concurrent starts before business writes',async()=>{
 const f=fixture();
 const responses=await Promise.all(Array.from({length:25},()=>f.post('pair/start')));
 assert.equal(responses.filter(r=>r.status===200).length,20);
 assert.equal(responses.filter(r=>r.status===429).length,5);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_pairings').get().n,20);
 const ddl=readFileSync(new URL('../../migrations/asc_eslogin_gateway_budget_ISOLATED_QA_ONLY.sql',import.meta.url),'utf8');
 assert.equal(ddl.split('\n').slice(1).join('\n').trim(),quotaSchema+';');
});

test('Gateway does not accept a Loader bearer issued by the protected website',async()=>{
 const f=fixture();
 f.grant();
 const {createHash}=await import('node:crypto');
 const raw='a'.repeat(64);
 f.sqlite.prepare("INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at) VALUES('legacy','account-a',?,'loader',?,?)")
  .run(createHash('sha256').update(raw).digest('hex'),now,now+3600);
 const r=await createLoaderGatewayCandidate({origin,clock:()=>now}).fetch(
  new Request(origin+prefix+'session',{method:'POST',headers:{Authorization:'Bearer '+raw,
   'Content-Type':'application/json'},body:'{}'}),f.env);
 assert.equal(r.status,401);
});
