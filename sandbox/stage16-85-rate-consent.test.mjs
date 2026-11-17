import test from 'node:test';
import assert from 'node:assert/strict';
import {createD1PairingRateLimiter,stage1685RateLimitContract} from './stage16-85-d1-rate-limiter.mjs';
import {createStage1683PairingRouter} from './stage16-83-pairing-router.mjs';

const {SQL,ACTIONS,PERIOD,RETAIN}=stage1685RateLimitContract;
const secret='sandbox-only-test-secret-never-deploy'.repeat(2);
const startTime=1794910000;

function dbFixture() {
  const records=new Map(), calls=[];
  const db={prepare(sql) {
    return {
      bind(...params) {
        calls.push({sql,params});
        return {
          async run() {
            if(sql===SQL.prune) {
              let removed=0;
              for(const [key,row] of records) if(row.expiresAt<=params[0]) {records.delete(key);removed++;}
              return {success:true,meta:{changes:removed},results:[]};
            }
            if(sql!==SQL.consume) throw Error('Bad SQL');
            const [scope,windowStart,expiry,limit]=params;
            const id=scope+':'+windowStart;
            const row=records.get(id);
            if(row?.hits>=limit) return {success:true,results:[]};
            const hits=(row?.hits||0)+1;
            records.set(id,{hits,expiresAt:expiry});
            return {success:true,results:[{hits}]};
          },
        };
      },
    };
  }};
  return {db,records,calls};
}
function fixture({db,network='203.0.113.1'}={}) {
  let now=startTime;
  const d=db??dbFixture();
  const limiter=createD1PairingRateLimiter({
    db:d.db,secret,getTrustedNetworkId:request=>request?.trustedNetwork,
    clock:()=>now*1000,
  });
  return {
    ...d,limiter,
    check:(action,net=network)=>limiter.checkRateLimit({action,request:{trustedNetwork:net}}),
    advance:delta=>{now+=delta;},
    now:()=>now,
  };
}

test('five action names have distinct server owned per-network and global quotas',()=>{
  assert.deepEqual(Object.keys(ACTIONS).sort(),['approve','cancel','poll','preview','start']);
  for(const x of Object.values(ACTIONS)) {
    assert.ok(x.perNetwork>0);
    assert.ok(x.global>x.perNetwork);
  }
  assert.equal(PERIOD,60);
  assert.equal(RETAIN,600);
});

test('per-network quota atomic; no per-network bypass by repeated start',async()=>{
  const f=fixture();
  const results=await Promise.all(Array.from({length:40},()=>f.check('start')));
  assert.equal(results.filter(Boolean).length,ACTIONS.start.perNetwork);
  assert.equal(results.filter(x=>!x).length,40-ACTIONS.start.perNetwork);
  const sqlCalls=f.calls.filter(c=>c.sql===SQL.consume);
  assert.ok(sqlCalls.every(c=>typeof c.params[0]==='string'&&c.params[0].length===43));
  // After 4 accepted network attempts, no further global bucket consumption.
  assert.equal(sqlCalls.length,40+ACTIONS.start.perNetwork);
});

test('hashed network scopes do not reveal the real network address or secret',async()=>{
  const f=fixture();
  assert.equal(await f.check('start','198.51.100.42'),true);
  const allArgs=JSON.stringify(f.calls);
  assert.ok(!allArgs.includes('198.51.100.42'));
  assert.ok(!allArgs.includes(secret));
  const hashes=f.calls.map(c=>c.params[0]);
  assert.equal(hashes.length,2);
  assert.notEqual(hashes[0],hashes[1]);
});

test('different network scopes independent; all Worker instances share DB counters',async()=>{
  const d=dbFixture();
  const a=fixture({db:d});
  const b=fixture({db:d});
  for(let n=0;n<ACTIONS.approve.perNetwork;n++){
    assert.equal(await a.check('approve','192.0.2.5'),true);
  }
  assert.equal(await b.check('approve','192.0.2.5'),false);
  assert.equal(await b.check('approve','192.0.2.6'),true);
});

test('global quota eventually throttles distributed network sources',async()=>{
  const f=fixture();
  const flags=[];
  for(let n=0;n<ACTIONS.start.global+1;n++){
    flags.push(await f.check('start','198.51.100.'+n));
  }
  assert.equal(flags.filter(Boolean).length,ACTIONS.start.global);
  assert.equal(flags.at(-1),false);
});

test('fixed window rotates after one minute and expiry prune deletes stale counters',async()=>{
  const f=fixture();
  for(let n=0;n<ACTIONS.start.perNetwork;n++) assert.equal(await f.check('start'),true);
  assert.equal(await f.check('start'),false);
  f.advance(70);
  assert.equal(await f.check('start'),true);
  f.advance(650);
  await f.limiter.pruneExpired();
  assert.equal(f.records.size,0);
});

test('unknown action never hits D1',async()=>{
  const f=fixture();
  await assert.rejects(()=>f.check('feedback'),/Unsupported pairing action/);
  assert.equal(f.calls.length,0);
});

test('missing trusted edge identity fails closed (never trust X-Forwarded-For)',async()=>{
  const f=fixture();
  for(const network of [undefined,'',' ', 'x'.repeat(140)]) {
    await assert.rejects(()=>f.check('start',network),/Trusted client network ID unavailable/);
  }
  assert.equal(f.calls.length,0);
});

test('server secret length enforced and not silently replaced by a default',async()=>{
  const d=dbFixture();
  const f=createD1PairingRateLimiter({
    db:d.db,secret:'bad',getTrustedNetworkId:()=> '198.51.100.3',
  });
  await assert.rejects(()=>f.checkRateLimit({action:'start',request:{}}),/Private 32\+/);
});

test('D1 errors fail closed for the calling Worker',async()=>{
  const db={prepare:()=>({bind:()=>({run:async()=>{throw Error('D1 offline');}})})};
  const f=createD1PairingRateLimiter({db,secret,getTrustedNetworkId:()=> '198.51.100.1'});
  await assert.rejects(()=>f.checkRateLimit({action:'start'}),/D1 offline/);
});

test('unexpected D1 return shape does not allow bypass',async()=>{
  const db={prepare:()=>({bind:()=>({run:async()=>({success:true,results:undefined})})})};
  const f=createD1PairingRateLimiter({db,secret,getTrustedNetworkId:()=> '198.51.100.1'});
  assert.equal(await f.checkRateLimit({action:'start'}),false);
});

function routerFixture() {
  const events=[];
  const ceremony={
    async start(){events.push('start');return {pairingCode:'ABCD-ABCD-ABCD-ABCD',pollToken:'x'.repeat(43),expiresIn:300,verificationPath:'/pair/browser/preview'};},
    async poll(){events.push('poll');return {state:'pending'};},
    async cancel(){events.push('cancel');return {ok:true};},
    async preview(){events.push('preview');return {ok:true,confirmationToken:'x'.repeat(43),pairingCode:'ABCD-ABCD-ABCD-ABCD',expiresIn:60};},
    async approve(){events.push('approve');return {ok:true};},
  };
  const router=createStage1683PairingRouter({
    ceremony,publicOrigin:'https://sandbox.example.test',checkRateLimit:async()=>true,
  });
  const send=async(body, extra={})=>{
    const req=new Request('https://sandbox.example.test/pair/browser/approve',{
      method:'POST',
      headers:{'content-type':'application/json','origin':'https://sandbox.example.test',
        'sec-fetch-site':'same-origin',...extra},
      body:JSON.stringify(body),
    });
    const response=await router(req);
    return {status:response.status,body:await response.json()};
  };
  return {send,events};
}
const consentData={
  code:'ABCD-ABCD-ABCD-ABCD',
  confirmationToken:'x'.repeat(43),
  confirmedCode:'ABCD-ABCD-ABCD-ABCD',
  acknowledgeOwnDevice:true,
};

test('browser approval without deliberate consent checkbox is refused',async()=>{
  const f=routerFixture();
  const {acknowledgeOwnDevice,...without}=consentData;
  assert.equal((await f.send(without)).status,400);
  assert.equal((await f.send({...without,acknowledgeOwnDevice:false})).status,400);
  assert.deepEqual(f.events,[]);
});

test('browser approval requires retyping EXACT matching code',async()=>{
  const f=routerFixture();
  assert.equal((await f.send({...consentData,confirmedCode:'WXYZ-WXYZ-WXYZ-WXYZ'})).status,400);
  assert.equal((await f.send({...consentData,confirmedCode:'abcd-abcd-abcd-abcd'})).status,400);
  assert.equal((await f.send({...consentData,confirmedCode:''})).status,400);
  assert.deepEqual(f.events,[]);
});

test('valid explicit consent reaches the server approval ceremony',async()=>{
  const f=routerFixture();
  assert.equal((await f.send(consentData)).status,200);
  assert.deepEqual(f.events,['approve']);
});

test('consent cannot bypass browser same-origin protection',async()=>{
  const f=routerFixture();
  assert.equal((await f.send(consentData,{origin:'https://evil.example'})).status,403);
  assert.deepEqual(f.events,[]);
});
