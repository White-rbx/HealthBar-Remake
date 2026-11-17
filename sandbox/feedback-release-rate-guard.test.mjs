import test from 'node:test';
import assert from 'node:assert/strict';
import {webcrypto} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {DatabaseSync} from 'node:sqlite';
import {QUOTAS,createReleaseFeedbackRateGuard} from './feedback-release-rate-guard.mjs';
const schema=readFileSync(new URL('../migrations/feedback_release_additive_REVIEW_ONLY_20261117.sql',import.meta.url),'utf8');
function fixture({badDB=false}={}){
  const sqlite=new DatabaseSync(':memory:');
  sqlite.exec('CREATE TABLE original_service (id INTEGER PRIMARY KEY, name TEXT); INSERT INTO original_service VALUES (1, "preserved");');
  sqlite.exec(schema);
  let network='synthetic-alpha',trusted=true,time=1763400000000;
  const db={prepare(sql){return {bind(...params){return {
    async first(){if(badDB)throw Error('private D1 secret failure');return sqlite.prepare(sql.replace(/\?[1-9]\d*/g,'?')).get(...params)??null},
    async run(){if(badDB)throw Error('private D1 secret failure');return sqlite.prepare(sql.replace(/\?[1-9]\d*/g,'?')).run(...params)}
  }}}}};
  const guard=createReleaseFeedbackRateGuard({db,secret:'synthetic test-only signing material'.padEnd(40,'!'),webcrypto,
    clock:()=>time,verifyEdge:async()=>({verified:trusted,networkId:network})});
  return {sqlite,guard,run:()=>guard.take(new Request('https://synthetic.invalid/api/v1/feedback/submit')),
    changeNetwork(x){network=x},trust(x){trusted=x},advance(ms){time+=ms}};
}
test('additive D1 schema works with legacy state and contains expected review-only objects',()=>{
  const f=fixture();
  const rows=f.sqlite.prepare("SELECT type FROM sqlite_master WHERE name NOT LIKE 'sqlite_%'").all();
  assert.equal(rows.filter(x=>x.type==='table').length,8); // seven new and one old
  assert.equal(rows.filter(x=>x.type==='index').length,10);
  assert.equal(rows.filter(x=>x.type==='trigger').length,4);
  assert.equal(f.sqlite.prepare('SELECT name FROM original_service WHERE id=1').get().name,'preserved');
  assert.equal(f.sqlite.prepare('PRAGMA quick_check').get().quick_check,'ok');
  assert.equal(f.sqlite.prepare('PRAGMA foreign_key_check').all().length,0);
  assert.doesNotMatch(schema,/DROP TABLE|DELETE FROM|UPDATE asc_/i);
});
test('one network is capped independently, others may submit',async()=>{
  const f=fixture();
  for(let n=0;n<QUOTAS.network15m;n++) assert.equal((await f.run()).allowed,true);
  assert.equal((await f.run()).status,429);
  f.changeNetwork('synthetic-beta');
  assert.equal((await f.run()).allowed,true);
  const scopes=f.sqlite.prepare('SELECT scope_hash FROM asc_feedback_rate_windows').all();
  assert.ok(scopes.every(x=>/^[A-Za-z0-9_-]{43}$/.test(x.scope_hash)));
  assert.ok(scopes.every(x=>!x.scope_hash.includes('synthetic')));
});
test('changing supplied UserId or spoofed XFF does not change independently attested network quota',async()=>{
  const f=fixture();
  for(let i=0;i<QUOTAS.network15m;i++){
    assert.equal((await f.guard.take(new Request('https://synthetic.invalid/',{
      headers:{'X-Roblox-UserId':String(i+100),'X-Forwarded-For':'198.51.100.'+(i+1)}
    }))).allowed,true);
  }
  assert.equal((await f.run()).status,429);
});
test('15-minute period resets while daily protection remains',async()=>{
  const f=fixture();
  for(let period=0;period<4;period++){
    for(let j=0;j<QUOTAS.network15m;j++)assert.equal((await f.run()).allowed,true);
    f.advance(900000);
  }
  assert.equal((await f.run()).status,429);
  f.advance(86400000);
  assert.equal((await f.run()).allowed,true);
});
test('missing edge trust and D1 errors fail closed, without exposing sensitive details',async()=>{
  const f=fixture();f.trust(false);
  assert.deepEqual(await f.run(),{allowed:false,status:503,reason:'trusted-edge-unavailable'});
  f.trust(true);f.changeNetwork('invalid net');
  assert.equal((await f.run()).status,503);
  const bad=fixture({badDB:true});
  assert.deepEqual(await bad.run(),{allowed:false,status:503,reason:'rate-unavailable'});
});
test('concurrent requests are atomically capped by D1 UPSERT',async()=>{
  const f=fixture();
  const responses=await Promise.all(Array.from({length:18},()=>f.run()));
  assert.equal(responses.filter(x=>x.allowed).length,QUOTAS.network15m);
  assert.equal(responses.filter(x=>x.status===429).length,18-QUOTAS.network15m);
});
test('trigger creates synthetic history without receipts or personal data',()=>{
  const f=fixture();
  f.sqlite.prepare('INSERT INTO asc_feedback_cases (id,receipt_hash,kind,topic,description,created_unix,updated_unix) VALUES (?,?,?,?,?,?,?)')
    .run('00000000-0000-4000-8000-000000000001','f'.repeat(64),'feedback','Test topic','Synthetic text to test the new history trigger on a disposable D1.',100,100);
  assert.deepEqual(f.sqlite.prepare('SELECT event_type FROM asc_feedback_history').all().map(x=>x.event_type),['submitted']);
});
