/**
 * Stage16.86: REAL local workerd + D1 binding test via Miniflare.
 * GitHub Actions starts no public server, sets no Cloudflare credentials,
 * and never connects to remote D1. Synthetic records only.
 */
import test, { before, after } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { Miniflare } from 'miniflare';

const TARGET='https://test.local/__stage1686/test-rate';
const HEADER_KEY='sandbox-local-fixture-only';
const SECRET='a-generated-test-secret-of-at-least-32-characters-no-production-use';
const NOW=1794910000000;
let mf, db;

before(async () => {
  mf = new Miniflare({
    scriptPath:fileURLToPath(new URL('../stage16-86-test-worker.mjs',import.meta.url)),
    modules:true,
    modulesRules:[{type:'ESModule',include:['**/*.mjs']}],
    compatibilityDate:'2026-11-13',
    d1Databases:['DB'],
    bindings:{
      STAGE1686_LOCAL_ONLY:'enabled-for-workerd-tests',
      TEST_HARNESS_KEY:HEADER_KEY,
      TEST_HMAC_SECRET:SECRET,
      TEST_NETWORK_FIXTURE:'isolated:workerd-test-network',
      TEST_NOW_MILLISECONDS:String(NOW),
    },
  });
  await mf.ready;
  db=await mf.getD1Database('DB');
  const source=readFileSync(new URL('../../migrations/2026-11-17_stage1685_pairing_rate_sandbox_only_DRAFT.sql',import.meta.url),'utf8');
  const statements=source.split('\n').filter(line=>!line.trim().startsWith('--')).join('\n')
    .split(';').map(s=>s.trim()).filter(Boolean);
  assert.equal(statements.length,2);
  for(const statement of statements) await db.prepare(statement).run();
});

after(async()=>{ if(mf) await mf.dispose(); });

function hit(key=HEADER_KEY,path=TARGET) {
  return mf.dispatchFetch(path,{method:'POST',headers:{'x-offline-fixture':key}});
}
async function countRows() {
  const row=await db.prepare('SELECT count(*) AS n FROM asc_pairing_rate_windows').first();
  return row?.n;
}
test('worker runtime rejects an invalid fixture credential without database access',async()=>{
  const r=await hit('wrong');
  assert.equal(r.status,403);
  assert.deepEqual(await r.json(),{ok:false});
  assert.equal(await countRows(),0);
});
test('worker runtime rejects unknown path and unsafe method',async()=>{
  const r=await hit(HEADER_KEY,'https://test.local/user/history');
  assert.equal(r.status,404);
  const get=await mf.dispatchFetch(TARGET,{method:'GET',headers:{'x-offline-fixture':HEADER_KEY}});
  assert.equal(get.status,404);
  assert.equal(await countRows(),0);
});
test('real workerd D1 binding enforces 4 of 12 concurrent POST attempts',async()=>{
  const requests=Array.from({length:12},()=>hit());
  const responses=await Promise.all(requests);
  const codes=responses.map(r=>r.status);
  assert.equal(codes.filter(c=>c===200).length,4,JSON.stringify(codes));
  assert.equal(codes.filter(c=>c===429).length,8,JSON.stringify(codes));
  assert.ok(codes.every(c=>c===200||c===429),JSON.stringify(codes));
  const counters=await db.prepare('SELECT hits FROM asc_pairing_rate_windows ORDER BY hits DESC').all();
  assert.deepEqual(counters.results.map(r=>r.hits),[4,4]);
});
test('rate limiting stays effective across subsequent Worker requests',async()=>{
  const r=await hit();
  assert.equal(r.status,429);
  assert.equal((await r.json()).limited,true);
});
test('runtime stores only opaque network HMAC scopes, not fixture identifier',async()=>{
  const rows=await db.prepare('SELECT scope_hash,window_start,hits FROM asc_pairing_rate_windows').all();
  assert.equal(rows.results.length,2);
  for(const row of rows.results) {
    assert.match(row.scope_hash,/^[A-Za-z0-9_-]{43}$/);
    assert.ok(!row.scope_hash.includes('workerd-test-network'));
    assert.equal(row.hits,4);
  }
});
