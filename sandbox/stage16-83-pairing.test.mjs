import test from 'node:test';
import assert from 'node:assert/strict';
import {createPairingCeremony,PAIR_TTL,CONFIRM_TTL} from './stage16-83-pairing-ceremony.mjs';
import {createStage1683PairingRouter} from './stage16-83-pairing-router.mjs';

const ORIGIN='https://sandbox.example.test';
function memoryStore() {
  const byCode=new Map(),byDevice=new Map();
  return {
    byCode,byDevice,
    async create(r) {
      if(byCode.has(r.codeHash)||byDevice.has(r.deviceHash))throw Error('collision');
      const v={...r,state:'pending',previewSub:null,confirmationHash:null,confirmationExpiresAt:0};
      byCode.set(r.codeHash,v);byDevice.set(r.deviceHash,v);
    },
    async preview({codeHash,sub,confirmationHash,confirmationExpiresAt,now}) {
      const r=byCode.get(codeHash);
      if(!r || r.state!=='pending'||r.expiresAt<=now ||
        (r.previewSub!==null&&r.previewSub!==sub))return false;
      r.previewSub=sub;r.confirmationHash=confirmationHash;
      r.confirmationExpiresAt=confirmationExpiresAt;
      return true;
    },
    async approve({codeHash,sub,confirmationHash,now}) {
      const r=byCode.get(codeHash);
      if(!r||r.state!=='pending'||r.expiresAt<=now||r.previewSub!==sub||
        r.confirmationHash!==confirmationHash||r.confirmationExpiresAt<=now)return false;
      r.state='approved';r.confirmationHash=null;r.confirmationExpiresAt=0;
      return true;
    },
    async getByDevice({deviceHash,now}) {
      const r=byDevice.get(deviceHash);
      return r&&r.expiresAt>now?r.state:null;
    },
    async consumeApproved({deviceHash,now}) {
      const r=byDevice.get(deviceHash);
      if(!r||r.expiresAt<=now||r.state!=='approved')return false;
      byDevice.delete(deviceHash);byCode.delete(r.codeHash);
      return true;
    },
    async cancel({deviceHash}) {
      const r=byDevice.get(deviceHash);if(!r)return false;
      byDevice.delete(deviceHash);byCode.delete(r.codeHash);return true;
    },
  };
}
function fixture({linkedBrowser=true,subject='111',rateLimit=async()=>true}={}) {
  let now=1794910000;
  const store=memoryStore();
  const resolver=async request=>{
    if(!linkedBrowser||request?.headers?.get('cookie')!=='__Host-asc_oidc_session=browser-only-secret')return null;
    return {sub:subject,verified:true,method:'roblox_oidc',expiresAt:now+600};
  };
  const ceremony=createPairingCeremony({store,resolveVerifiedPrincipal:resolver,clock:()=>now*1000});
  const router=createStage1683PairingRouter({ceremony,publicOrigin:ORIGIN,checkRateLimit:rateLimit});
  const advance=seconds=>{now+=seconds;};
  return {ceremony,store,router,advance,now:()=>now};
}
function req(path,body={}, {browser=false,origin=ORIGIN,cookie='__Host-asc_oidc_session=browser-only-secret',method='POST',extraHeaders={}}={}) {
  const h={'content-type':'application/json',...extraHeaders};
  if(browser)Object.assign(h,{origin,'sec-fetch-site':'same-origin',cookie});
  return new Request(ORIGIN+path,{method,headers:h,body:method==='POST'?JSON.stringify(body):undefined});
}
async function post(f,path,body,options) {
  const response=await f.router(req(path,body,options));
  return {response,body:await response.json()};
}
async function begin(f) {
  const result=await post(f,'/pair/start',{});
  assert.equal(result.response.status,201);
  return result.body;
}
async function preview(f,code,options={}) {
  return post(f,'/pair/browser/preview',{code},{browser:true,...options});
}
async function approve(f,code,confirmationToken,options={}) {
  return post(f,'/pair/browser/approve',{code,confirmationToken,confirmedCode:code,acknowledgeOwnDevice:true},{browser:true,...options});
}

test('start produces high entropy base32 pairingCode and unguessable poll-only capability',async()=>{
  const f=fixture(),a=await begin(f),b=await begin(f);
  assert.match(a.pairingCode,/^[A-Z2-7]{4}(?:-[A-Z2-7]{4}){3}$/);
  assert.match(a.pollToken,/^[A-Za-z0-9_-]{43}$/);
  assert.notEqual(a.pairingCode,b.pairingCode);
  assert.notEqual(a.pollToken,b.pollToken);
  assert.equal(a.expiresIn,PAIR_TTL);
  assert.equal(Object.values(a).some(v=>v==='111'),false);
  assert.equal(f.store.byCode.size,2);
  const stored=[...f.store.byCode.values()][0];
  assert.notEqual(stored.codeHash,a.pairingCode);
  assert.notEqual(stored.deviceHash,a.pollToken);
});

test('unverified browser cannot preview/approve pairing',async()=>{
  const f=fixture({linkedBrowser:false}),a=await begin(f);
  const p=await preview(f,a.pairingCode);
  assert.equal(p.response.status,403);
  assert.equal((await post(f,'/pair/poll',{pollToken:a.pollToken})).body.state,'pending');
});

test('browser must manually preview then explicitly approve using a one-time confirmation token',async()=>{
  const f=fixture(),a=await begin(f);
  const before=await approve(f,a.pairingCode,'x'.repeat(43));
  assert.equal(before.response.status,403);
  const p=await preview(f,a.pairingCode);
  assert.equal(p.response.status,200);
  assert.equal(p.body.pairingCode,a.pairingCode);
  assert.equal(p.body.expiresIn,CONFIRM_TTL);
  assert.match(p.body.warning,/own Arcsen UI/);
  assert.equal((await post(f,'/pair/poll',{pollToken:a.pollToken})).body.state,'pending');
  const approved=await approve(f,a.pairingCode,p.body.confirmationToken);
  assert.deepEqual(approved.body,{ok:true,approved:true});
  assert.equal(approved.response.status,200);
  const polled=await post(f,'/pair/poll',{pollToken:a.pollToken});
  assert.deepEqual(polled.body,{ok:true,state:'approved'});
  assert.ok(!JSON.stringify(polled.body).includes('111'));
  assert.ok(!JSON.stringify(polled.body).includes('token'));
  const replay=await post(f,'/pair/poll',{pollToken:a.pollToken});
  assert.equal(replay.body.state,'unavailable');
  assert.equal(f.store.byCode.size,0);
});

test('browser from a different Roblox account cannot take over an existing preview',async()=>{
  const f=fixture(),a=await begin(f);
  const p=await preview(f,a.pairingCode);
  assert.equal(p.response.status,200);
  // Simulate the browser session resolver returning a distinct verified subject.
  const other=createPairingCeremony({
    store:f.store,clock:()=>f.now()*1000,
    resolveVerifiedPrincipal:async()=>({sub:'222',verified:true,method:'roblox_oidc',expiresAt:f.now()+500}),
  });
  const browserReq=req('/pair/browser/preview',{code:a.pairingCode},{browser:true});
  const otherP=await other.preview({request:browserReq,code:a.pairingCode});
  assert.equal(otherP.ok,false);
  const otherApprove=await other.approve({request:browserReq,code:a.pairingCode,confirmationToken:p.body.confirmationToken});
  assert.equal(otherApprove.ok,false);
});

test('confirmation token can be used once and cannot approve a different pairing',async()=>{
  const f=fixture(),a=await begin(f),b=await begin(f);
  const p=await preview(f,a.pairingCode);
  assert.equal((await approve(f,b.pairingCode,p.body.confirmationToken)).response.status,403);
  const x=await Promise.all([
    approve(f,a.pairingCode,p.body.confirmationToken),
    approve(f,a.pairingCode,p.body.confirmationToken),
  ]);
  assert.deepEqual(x.map(r=>r.response.status).sort(),[200,403]);
});

test('confirmation expires in one minute even if pairing still pending',async()=>{
  const f=fixture(),a=await begin(f),p=await preview(f,a.pairingCode);
  f.advance(61);
  assert.equal((await approve(f,a.pairingCode,p.body.confirmationToken)).response.status,403);
  assert.equal((await post(f,'/pair/poll',{pollToken:a.pollToken})).body.state,'pending');
});

test('entire pairing expires after five minutes',async()=>{
  const f=fixture(),a=await begin(f);
  f.advance(301);
  assert.equal((await preview(f,a.pairingCode)).response.status,403);
  assert.equal((await post(f,'/pair/poll',{pollToken:a.pollToken})).body.state,'unavailable');
});

test('cancel irrevocably deletes pending pairing',async()=>{
  const f=fixture(),a=await begin(f);
  assert.equal((await post(f,'/pair/cancel',{pollToken:a.pollToken})).body.ok,true);
  assert.equal((await post(f,'/pair/poll',{pollToken:a.pollToken})).body.state,'unavailable');
  assert.equal((await preview(f,a.pairingCode)).response.status,403);
});

test('wrong poll token cannot retrieve or consume another pairing',async()=>{
  const f=fixture(),a=await begin(f);
  const p=await preview(f,a.pairingCode);
  await approve(f,a.pairingCode,p.body.confirmationToken);
  const bad=await post(f,'/pair/poll',{pollToken:'q'.repeat(43)});
  assert.equal(bad.body.state,'unavailable');
  const good=await post(f,'/pair/poll',{pollToken:a.pollToken});
  assert.equal(good.body.state,'approved');
});

test('browser approval requires matching Origin even with valid session cookie',async()=>{
  const f=fixture(),a=await begin(f);
  for (const origin of ['https://evil.invalid','', 'https://sandbox.example.test.evil.invalid']) {
    const p=await preview(f,a.pairingCode,{origin});
    assert.equal(p.response.status,403);
  }
  const good=await preview(f,a.pairingCode);
  assert.equal(good.response.status,200);
});

test('client cannot claim Roblox identity, set arbitrary status, or submit unknown fields',async()=>{
  const f=fixture();
  const attack=await post(f,'/pair/start',{userId:'222',identityVerified:true});
  assert.equal(attack.response.status,400);
  const started=await begin(f);
  const poll=await post(f,'/pair/poll',{pollToken:started.pollToken,sub:'222'});
  assert.equal(poll.response.status,400);
  const p=await post(f,'/pair/browser/preview',{code:started.pairingCode,claimedUserId:'222'},{browser:true});
  assert.equal(p.response.status,400);
});

test('expired/fake session blocks browser approval without exposing code existence',async()=>{
  const f=fixture(),a=await begin(f);
  const unauthorized=await preview(f,a.pairingCode,{cookie:'__Host-asc_oidc_session=fake'});
  assert.equal(unauthorized.response.status,403);
  assert.equal(unauthorized.body.error,'Pairing unavailable');
});

test('excessive JSON input is rejected before ceremony invocation',async()=>{
  const f=fixture();
  const response=await f.router(req('/pair/start',{padding:'x'.repeat(2000)}));
  assert.equal(response.status,400);
  assert.equal(f.store.byCode.size,0);
});

test('missing distributed limiter is a configuration error',()=>{
  const f=fixture();
  assert.throws(()=>createStage1683PairingRouter({ceremony:f.ceremony,publicOrigin:ORIGIN}),/Distributed rate limiter/);
});

test('rate limit prevents pairing actions',async()=>{
  const f=fixture({rateLimit:async()=>false});
  assert.equal((await post(f,'/pair/start',{})).response.status,429);
  assert.equal(f.store.byCode.size,0);
});

test('rate limiter unavailable fails closed',async()=>{
  const f=fixture({rateLimit:async()=>{throw Error('offline')}});
  assert.equal((await post(f,'/pair/start',{})).response.status,503);
});

test('POST only, no credentials CORS, no cache and no redirects from untrusted clients',async()=>{
  const f=fixture();
  const get=await f.router(req('/pair/start',{}, {method:'GET'}));
  assert.equal(get.status,405);
  const created=await post(f,'/pair/start',{});
  assert.equal(created.response.headers.get('cache-control'),'no-store, private');
  assert.equal(created.response.headers.get('referrer-policy'),'no-referrer');
  assert.equal(created.response.headers.get('access-control-allow-origin'),null);
  assert.equal(created.response.headers.get('location'),null);
  assert.equal((await post(f,'/pair/other',{})).response.status,404);
});

test('all parser and authorization errors are free of user IDs and session secrets',async()=>{
  const f=fixture();
  const fail=await post(f,'/pair/browser/approve',{code:'invalid',confirmationToken:'nope'},{browser:true});
  assert.equal(fail.response.status,403);
  const s=JSON.stringify(fail.body);
  assert.ok(!s.includes('111'));
  assert.ok(!s.includes('browser-only-secret'));
});
