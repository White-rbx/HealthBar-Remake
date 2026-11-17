import test from 'node:test';
import assert from 'node:assert/strict';
import { createD1PendingStore, createD1SessionStore, STAGE1682_SQL } from './stage16-82-d1-oauth-stores.mjs';
import { createStage1682BrowserRouter } from './stage16-82-oauth-browser-router.mjs';
import { createOidcSandbox, OIDC } from './stage16-81-roblox-oidc-sandbox.mjs';

const origin='https://sandbox.example.test', redirectUri=origin+'/oauth/callback';
const clientId='1234567890123456', now=1794910000, clock=()=>now*1000;
const key='a'.repeat(43), key2='b'.repeat(43);
function mockD1() {
  const pending=new Map(), sessions=new Map(), commands=[];
  const db={ prepare(sql) {
    return {
      bind(...values) {
        commands.push({sql,values});
        async function execute() {
          if (sql===STAGE1682_SQL.pendingPut) {
            const [state,nonce,codeVerifier,cookieHash,id,redirect,exp]=values;
            if(pending.has(state)) throw Error('UNIQUE');
            pending.set(state,{nonce,codeVerifier,cookieHash,clientId:id,redirectUri:redirect,expiresAt:exp});
            return {success:true,results:[]};
          }
          if (sql===STAGE1682_SQL.pendingTake) {
            const [state]=values, row=pending.get(state)??null;
            pending.delete(state);
            return {success:true,results:row?[row]:[]};
          }
          if (sql===STAGE1682_SQL.sessionPut) {
            const [sessionHash,sub,created,exp]=values;
            if(sessions.has(sessionHash)) throw Error('UNIQUE');
            sessions.set(sessionHash,{sub,method:'roblox_oidc',createdAt:created,expiresAt:exp});
            return {success:true,results:[]};
          }
          if (sql===STAGE1682_SQL.sessionGet) {
            const row=sessions.get(values[0]);
            return {success:true,results:row&&row.expiresAt>values[1]?[row]:[]};
          }
          if (sql===STAGE1682_SQL.sessionDelete) {
            sessions.delete(values[0]);return {success:true,results:[]};
          }
          if (sql===STAGE1682_SQL.prunePending) {
            for(const [state,row] of pending) if(row.expiresAt<=values[0]) pending.delete(state);
            return {success:true,results:[]};
          }
          if (sql===STAGE1682_SQL.pruneSessions) {
            for(const [hash,row] of sessions) if(row.expiresAt<=values[0]) sessions.delete(hash);
            return {success:true,results:[]};
          }
          throw Error('Unexpected SQL query');
        }
        return { run:execute, first:async()=> (await execute()).results?.[0]??null };
      },
    };
  }};
  return {db, pending, sessions, commands};
}
function pendingData(changes={}) {return {nonce:key,codeVerifier:key,cookieHash:key,clientId,redirectUri,expiresAt:now+300,...changes};}
function principal(changes={}) {return {sub:'111',verified:true,method:'roblox_oidc',expiresAt:now+900,...changes};}
test('pending OAuth state: put, one atomic DELETE RETURNING, replay fail',async()=>{
  const f=mockD1(),store=createD1PendingStore(f.db,{clock});
  await store.put(key,pendingData());
  const [first,second]=await Promise.all([store.take(key),store.take(key)]);
  assert.equal([first,second].filter(Boolean).length,1);
  assert.equal(await store.take(key),null);
  assert.equal(f.commands.filter(x=>x.sql===STAGE1682_SQL.pendingTake).length,3);
  assert.ok(STAGE1682_SQL.pendingTake.includes('DELETE FROM'));
  assert.ok(STAGE1682_SQL.pendingTake.includes('RETURNING'));
});
test('pending inputs reject weak state, wrong redirect and excessive TTL',async()=>{
  const f=mockD1(),store=createD1PendingStore(f.db,{clock});
  await assert.rejects(()=>store.put('short',pendingData()),/state/);
  await assert.rejects(()=>store.put(key,pendingData({redirectUri:'http://example.test/cb'})),/client/);
  await assert.rejects(()=>store.put(key,pendingData({expiresAt:now+400})),/expiry/);
  assert.equal(f.pending.size,0);
});
test('session store requires server-verified subject; revocation deletes entry',async()=>{
  const f=mockD1(),store=createD1SessionStore(f.db,{clock});
  await assert.rejects(()=>store.put(key,principal({verified:false})),/Unverified/);
  await assert.rejects(()=>store.put(key,principal({sub:'not-an-id'})),/Unverified/);
  await store.put(key,principal());
  assert.equal((await store.get(key)).sub,'111');
  await store.delete(key);
  assert.equal(await store.get(key),null);
});
test('expired session returns null (never client trusted)',async()=>{
  const f=mockD1();
  const a=createD1SessionStore(f.db,{clock});
  await a.put(key,principal());
  const b=createD1SessionStore(f.db,{clock:()=> (now+901)*1000});
  assert.equal(await b.get(key),null);
  await b.pruneExpired();assert.equal(f.sessions.size,0);
});
test('pruning expired flows and sessions uses indexed expiry',async()=>{
  const f=mockD1(),a=createD1PendingStore(f.db,{clock}),b=createD1SessionStore(f.db,{clock});
  await a.put(key,pendingData());await b.put(key2,principal());
  await createD1PendingStore(f.db,{clock:()=> (now+301)*1000}).pruneExpired();
  assert.equal(f.pending.size,0);
  await createD1SessionStore(f.db,{clock:()=> (now+901)*1000}).pruneExpired();
  assert.equal(f.sessions.size,0);
});
test('invalid session key never reads DB',async()=>{
  const f=mockD1(),store=createD1SessionStore(f.db,{clock});
  assert.equal(await store.get('spoof'),null);
  assert.equal(f.commands.length,0);
});

const keyPair=await crypto.subtle.generateKey({name:'ECDSA',namedCurve:'P-256'},true,['sign','verify']);
const pub=await crypto.subtle.exportKey('jwk',keyPair.publicKey);
const keys={keys:[{...pub,kid:'sandbox-key',alg:'ES256',use:'sig'}]};
function encode(obj) {return Buffer.from(JSON.stringify(obj)).toString('base64url');}
async function sign(nonce,changes={}) {
  const header=encode({alg:'ES256',kid:'sandbox-key',typ:'JWT'});
  const body=encode({iss:OIDC.issuer,aud:clientId,sub:'111',nonce,iat:now-5,exp:now+600,...changes});
  const raw=header+'.'+body;
  const sig=await crypto.subtle.sign({name:'ECDSA',hash:'SHA-256'},keyPair.privateKey,Buffer.from(raw));
  return raw+'.'+Buffer.from(sig).toString('base64url');
}
function browserFixture() {
  const f=mockD1();
  const pendingStore=createD1PendingStore(f.db,{clock});
  const sessionStore=createD1SessionStore(f.db,{clock});
  let incomingToken,exchangeCalls=0;
  const oidc=createOidcSandbox({
    clientId,redirectUri,pendingStore,sessionStore,clock,
    getRobloxJwks:async uri=>{assert.equal(uri,OIDC.jwks);return keys;},
    exchangeCode:async ({tokenEndpoint,code,codeVerifier})=>{
      assert.equal(tokenEndpoint,OIDC.token);
      assert.equal(code,'fake-roblox-code');
      assert.match(codeVerifier,/^[A-Za-z0-9_-]{43}$/);
      exchangeCalls++;
      return {id_token:incomingToken,access_token:'must-not-persist'};
    },
  });
  const handler=createStage1682BrowserRouter({oidc,publicOrigin:origin});
  return {f,oidc,handler,signToken:async nonce=> {incomingToken=await sign(nonce);},getExchangeCalls:()=>exchangeCalls};
}
async function begin(f) {
  const response=await f.handler(new Request(origin+'/auth/start'));
  assert.equal(response.status,302);
  const url=new URL(response.headers.get('location'));
  const state=url.searchParams.get('state');
  return {response,url,state,nonce:f.f.pending.get(state).nonce,
    flowCookie:response.headers.get('set-cookie').split(';')[0]};
}
function getCookies(response) {return response.headers.getSetCookie();}
test('browser end-to-end with fake Roblox signer never returns OAuth tokens',async()=>{
  const f=browserFixture(),a=await begin(f);
  assert.equal(a.url.origin,'https://apis.roblox.com');
  await f.signToken(a.nonce);
  const callbackRequest=new Request(origin+'/oauth/callback?state='+a.state+'&code=fake-roblox-code',
    {headers:{Cookie:a.flowCookie}});
  const c=await f.handler(callbackRequest);
  assert.equal(c.status,303);
  assert.equal(c.headers.get('location'),origin+'/auth/connected');
  assert.equal(c.headers.get('referrer-policy'),'no-referrer');
  const cookies=getCookies(c);
  assert.equal(cookies.length,2);
  const sessionCookie=cookies.find(s=>s.startsWith('__Host-asc_oidc_session='));
  assert.ok(sessionCookie);
  const session=await f.handler(new Request(origin+'/auth/session',{headers:{Cookie:sessionCookie.split(';')[0]}}));
  assert.equal(session.status,200);
  const body=await session.json();
  assert.deepEqual(body,{ok:true,authenticated:true,identityVerified:true,sub:'111'});
  assert.ok(!JSON.stringify([...f.f.sessions.values()]).includes('must-not-persist'));
  assert.ok(!session.headers.has('access-control-allow-origin'));
  const again=await f.handler(callbackRequest);
  assert.equal(again.status,400);
  const logout=await f.handler(new Request(origin+'/auth/logout',{
    method:'POST',
    headers:{Origin:origin,Cookie:sessionCookie.split(';')[0],'Sec-Fetch-Site':'same-origin'},
  }));
  assert.equal(logout.status,200);
  assert.equal(f.f.sessions.size,0);
  const revoked=await f.handler(new Request(origin+'/auth/session',{headers:{Cookie:sessionCookie.split(';')[0]}}));
  assert.equal(revoked.status,401);
});
test('wrong browser cannot redeem state, and state is consumed',async()=>{
  const f=browserFixture(),a=await begin(f);await f.signToken(a.nonce);
  const url=origin+'/oauth/callback?code=fake-roblox-code&state='+a.state;
  const bad=await f.handler(new Request(url,{headers:{Cookie:'__Host-asc_oidc_flow='+'z'.repeat(43)}}));
  assert.equal(bad.status,400);
  assert.equal(f.getExchangeCalls(),0);
  const retry=await f.handler(new Request(url,{headers:{Cookie:a.flowCookie}}));
  assert.equal(retry.status,400);
});
test('callback duplicates and error values are refused',async()=>{
  const f=browserFixture(),a=await begin(f);
  const bad=await f.handler(new Request(origin+'/oauth/callback?state='+a.state+'&state='+a.state+'&code=fake-roblox-code'));
  assert.equal(bad.status,400);
  const error=await f.handler(new Request(origin+'/oauth/callback?error=access_denied'));
  assert.equal(error.status,400);
  assert.equal(f.getExchangeCalls(),0);
});
test('same-origin logout CSRF checks reject missing/cross-site Origin',async()=>{
  const f=browserFixture();
  for(const hdr of [{},{Origin:'https://evil.example'},{Origin:origin,'Sec-Fetch-Site':'cross-site'}]) {
    const res=await f.handler(new Request(origin+'/auth/logout',{method:'POST',headers:hdr}));
    assert.equal(res.status,403);
  }
});
test('router never redirects to client-supplied next, userId or foreign hosts',async()=>{
  const f=browserFixture();
  assert.equal((await f.handler(new Request(origin+'/auth/start?next=https://evil.test'))).status,400);
  assert.equal((await f.handler(new Request('https://evil.test/auth/start'))).status,400);
  assert.equal((await f.handler(new Request(origin+'/auth/session?userId=222'))).status,400);
  assert.equal((await f.handler(new Request(origin+'/auth/logout'))).status,405);
});
