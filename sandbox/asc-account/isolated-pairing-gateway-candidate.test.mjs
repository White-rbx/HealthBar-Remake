import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import * as gatewayModule from './isolated-pairing-gateway-candidate.mjs';

const {createPairingGatewayCandidate}=gatewayModule;
const origin='https://pairing.qa.invalid';
const prefix='/api/v1/accounts/';
const now=1795440001;

function fixture(){
 const sqlite=new DatabaseSync(':memory:');
 sqlite.exec(readFileSync(new URL('../../migrations/asc_unified_account_ISOLATED_QA_ONLY.sql',import.meta.url),'utf8'));
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
  f.post('pair/poll',{secret:start.body.secret,remember:true}),
  f.post('pair/poll',{secret:start.body.secret,remember:true}),
 ]);
 assert.deepEqual([first.status,second.status].sort(),[200,410]);
 const ready=first.status===200?first:second;
 assert.equal(ready.body.state,'ready');
 assert.match(ready.body.session,/^[0-9a-f]{64}$/);
 assert.equal(ready.body.expiresAt,now+43200);
 const loader=f.sqlite.prepare("SELECT * FROM asc_account_sessions WHERE scope='loader'").get();
 assert.equal(loader.account_id,'account-a');
 assert.equal(loader.expires_at,now+43200);
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
