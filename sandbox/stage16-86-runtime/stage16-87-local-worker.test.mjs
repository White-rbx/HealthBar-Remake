import test,{before,after} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {Miniflare} from 'miniflare';

const URLBASE='https://sandbox.example.test';
const PATH='/__stage1687/rate-probe';
let mf,db;
before(async()=>{
  mf=new Miniflare({
    scriptPath:fileURLToPath(new URL('../stage16-87-local-worker.mjs',import.meta.url)),
    modules:true,
    modulesRules:[{type:'ESModule',include:['**/*.mjs']}],
    compatibilityDate:'2026-08-06', // bounded by local workerd binary in CI
    d1Databases:['DB'],
    bindings:{
      STAGE1687_LOCAL_TEST_ONLY:'local-workerd-fixture',
      TEST_ACCESS_MODE:'local-ci',
      TEST_INGRESS_MODE:'local-ci',
      TEST_NETWORK_SCOPE:'isolated:network-ci',
      TEST_HMAC_SECRET:'not-for-production-use-only-local-workerd-fixture-test-secret-123456',
      TEST_NOW_MILLISECONDS:'1794910000000',
    },
  });
  await mf.ready;
  db=await mf.getD1Database('DB');
  const file=readFileSync(new URL('../../migrations/2026-11-17_stage1685_pairing_rate_sandbox_only_DRAFT.sql',import.meta.url),'utf8');
  const sql=file.split('\n').filter(x=>!x.trim().startsWith('--')).join('\n')
    .split(';').map(x=>x.trim()).filter(Boolean);
  assert.equal(sql.length,2);
  for(const statement of sql)await db.prepare(statement).run();
});
after(async()=>{if(mf)await mf.dispose();});
const request=(url=URLBASE+PATH,headers={})=>
  mf.dispatchFetch(url,{method:'POST',headers});
const approved=()=>request(undefined,{'x-local-access-test':'allow-fixture'});
const count=async()=> (await db.prepare('SELECT count(*) AS n FROM asc_pairing_rate_windows').first()).n;

test('unauthorized local request cannot consume D1 rate quota',async()=>{
  const r=await request();
  assert.equal(r.status,403);
  assert.equal(await count(),0);
});
test('forged CF/XFF/client identity headers cannot authenticate',async()=>{
  const r=await request(undefined,{
    'CF-Connecting-IP':'203.0.113.77',
    'X-Forwarded-For':'203.0.113.77',
    'Origin':URLBASE,
    'Authorization':'Bearer fake',
    'X-Roblox-UserId':'123456',
  });
  assert.equal(r.status,403);
  assert.equal(await count(),0);
});
test('same-zone Worker indicators force rejection even with test authorization',async()=>{
  const a=await request(undefined,{'x-local-access-test':'allow-fixture','X-Real-IP':'203.0.113.12'});
  const b=await request(undefined,{'x-local-access-test':'allow-fixture','CF-Worker':'example.test'});
  assert.equal(a.status,403);
  assert.equal(b.status,403);
  assert.equal(await count(),0);
});
test('sensitive routes stay dark even with test authorization',async()=>{
  for(const path of ['/api/v1/violation/history','/api/v1/feedback','/api/v1/appeal',
                     '/admin','/pair/start','/oauth/callback']){
    const r=await request(URLBASE+path,{'x-local-access-test':'allow-fixture'});
    assert.equal(r.status,404,path);
  }
  assert.equal(await count(),0);
});
test('local workerd + real D1 enforces rate caps after simulated independent checks',async()=>{
  const rs=await Promise.all(Array.from({length:12},()=>approved()));
  assert.equal(rs.filter(x=>x.status===200).length,4);
  assert.equal(rs.filter(x=>x.status===429).length,8);
  assert.equal(await count(),2);
  for(const r of rs){
    const payload=await r.json();
    assert.doesNotMatch(JSON.stringify(payload),/203\.0\.113|roblox|identity|network-ci/);
    assert.equal(r.headers.get('access-control-allow-origin'),null);
  }
  const rows=await db.prepare('SELECT scope_hash,hits FROM asc_pairing_rate_windows').all();
  assert.deepEqual(rows.results.map(x=>x.hits).sort(),[4,4]);
  assert.ok(rows.results.every(x=>/^[A-Za-z0-9_-]{43}$/.test(x.scope_hash)));
});
test('subsequent authorized local request remains limited',async()=>{
  const r=await approved();
  assert.equal(r.status,429);
  assert.equal((await r.json()).limited,true);
});
