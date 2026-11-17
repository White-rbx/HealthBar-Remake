import test from 'node:test';
import assert from 'node:assert/strict';
import { createVerifiedHistoryHandler, stage1680TestContract } from './stage16-80-verified-violation-history.mjs';

const now = 1794900000;
const base = 'https://staging.example.test/api/v1/violation/history';
const request = (url = base, options) => new Request(url, options);
function fixture({ subject = '111', state = 'approved', mayReappeal = 1, noData = false, throwDB = false } = {}) {
  const calls = [];
  const db = {
    prepare(sql) {
      return {
        bind(value) {
          calls.push({ sql, value });
          return { async all() {
            if (throwDB) throw Error('D1 unavailable');
            if (noData || value !== subject) return { results: [] };
            if (sql === stage1680TestContract.noticeSQL) return { results: [
              { id: 'case-a', reason: 'Rules violation', moderatorMessage: 'Public explanation',
                appealStatus: state, mayReappeal, createdAt: 1794800000 },
            ] };
            return { results: [
              { noticeId: 'case-a', status: state, action: 'reviewed', publicNote: 'Reviewed by staff', createdAt: 1794850000 },
            ] };
          } };
        },
      };
    },
  };
  return { db, calls };
}
const principal = (sub = '111', changes = {}) => ({ verified: true, method: 'roblox_oidc', sub, expiresAt: now + 600, ...changes });
const create = (f, p = principal()) => createVerifiedHistoryHandler({db: f.db, resolveVerifiedPrincipal: async () => p, clock: () => now * 1000});

for (const invalid of [null, {}, principal('111', {verified:false}), principal('111', {method:'local_player'}), principal('111', {expiresAt: now}), principal('abc'), principal('0')]) {
  test('fails closed for invalid/expired/unverified principal', async () => {
    const f = fixture(); const response = await create(f,invalid)(request());
    assert.equal(response.status,401); assert.equal(f.calls.length,0);
    assert.equal((await response.json()).identityVerified,false);
  });
}

test('denies POST without querying database', async () => {
  const f=fixture();const res=await create(f)(request(base,{method:'POST',body:'{"userId":"111"}'}));
  assert.equal(res.status,405);assert.equal(f.calls.length,0);
});

test('uses session subject, never a forged query userId or headers', async () => {
  const f=fixture({subject:'222',state:'reviewing'});
  const res=await create(f,principal('111'))(request(base+'?userId=222&identityVerified=true',{headers:{'x-roblox-user-id':'222'}}));
  assert.equal(res.status,200);
  const data=await res.json(); assert.equal(data.hasHistory,false);
  assert.deepEqual(f.calls.map(x=>x.value),['111','111']);
  assert.ok(f.calls.every(x=>!x.sql.includes('claimed_user_id')));
});

test('no history hides tab despite verified identity', async()=>{
  const data=await (await create(fixture({noData:true}))(request())).json();
  assert.equal(data.identityVerified,true);assert.equal(data.hasHistory,false);assert.deepEqual(data.notices,[]);
});

for (const [state,order,allowed] of [['not_appealed',0,true],['reviewing',1,false],['denied',2,true],['approved',3,false]]) {
  test('status '+state+' → correct order + server appeal gate',async()=>{
    const data=await (await create(fixture({state}))(request())).json();
    assert.equal(data.notices[0].layoutOrder,order);
    assert.equal(data.notices[0].canAppealAgain,allowed);
    assert.equal(data.notices[0].history[0].status,state);
  });
}
test('denied only allows reappeal when server explicitly grants it',async()=>{
  const data=await (await create(fixture({state:'denied',mayReappeal:0}))(request())).json();
  assert.equal(data.notices[0].canAppealAgain,false);
});
test('D1 outage does not leak or fake violations',async()=>{
  const res=await create(fixture({throwDB:true}))(request());
  assert.equal(res.status,503);assert.equal((await res.json()).identityVerified,false);
});
test('verification resolver failure returns 503 without leaking user data',async()=>{
  const f=fixture();const h=createVerifiedHistoryHandler({db:f.db,resolveVerifiedPrincipal:async()=>{throw Error('auth offline')},clock:()=>now*1000});
  const res=await h(request()); assert.equal(res.status,503);assert.equal(f.calls.length,0);
});
test('missing trusted verifier is a configuration error',()=>{
  assert.throws(()=>createVerifiedHistoryHandler({db:fixture().db}),/verified principal resolver/);
});
