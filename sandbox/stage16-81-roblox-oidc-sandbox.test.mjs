import test from 'node:test';
import assert from 'node:assert/strict';
import { OIDC, verifyRobloxIdToken, createOidcSandbox } from './stage16-81-roblox-oidc-sandbox.mjs';
import { createVerifiedHistoryHandler } from './stage16-80-verified-violation-history.mjs';

const CLIENT = '1234567890123456';
const REDIRECT = 'https://sandbox.example.test/oauth/callback';
let now = 1794910000;
const clock = () => now * 1000;

const pair = await crypto.subtle.generateKey({ name:'ECDSA', namedCurve:'P-256' }, true, ['sign','verify']);
const publicJwk = await crypto.subtle.exportKey('jwk', pair.publicKey);
const jwks = {keys:[{ ...publicJwk, kid:'test-good-key', alg:'ES256', use:'sig' }]};
const b64url = bytes => btoa(String.fromCharCode(...bytes)).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/g,'');
const enc = value => b64url(new TextEncoder().encode(JSON.stringify(value)));

async function sign(payload, { header = {}, signingKey = pair.privateKey } = {}) {
  const headerPart = enc({alg:'ES256',kid:'test-good-key',typ:'JWT',...header});
  const payloadPart = enc(payload);
  const input = headerPart + '.' + payloadPart;
  const signature = await crypto.subtle.sign({name:'ECDSA',hash:'SHA-256'}, signingKey, new TextEncoder().encode(input));
  return input + '.' + b64url(new Uint8Array(signature));
}
const claims = (nonce, changes={}) => ({
  iss:OIDC.issuer, aud:CLIENT, sub:'111', nonce,
  exp:now+600, iat:now-10, ...changes,
});

function memoryStore() {
  const map=new Map();
  return {
    map,
    async put(key,value) {map.set(key,value);},
    async get(key) {return map.get(key) ?? null;},
    async take(key) {const value=map.get(key)??null;map.delete(key);return value;},
  };
}
function createFixture() {
  const pendingStore=memoryStore();
  const sessionStore=memoryStore();
  let returnedToken;
  let exchangeCalls=0;
  const integration=createOidcSandbox({
    clientId:CLIENT, redirectUri:REDIRECT, pendingStore, sessionStore, clock,
    getRobloxJwks:async uri => {assert.equal(uri,OIDC.jwks);return jwks;},
    exchangeCode:async ({tokenEndpoint,clientId,redirectUri,code,codeVerifier}) => {
      exchangeCalls++;
      assert.equal(tokenEndpoint,OIDC.token);
      assert.equal(clientId,CLIENT);assert.equal(redirectUri,REDIRECT);
      assert.equal(code,'roblox-auth-code');
      assert.match(codeVerifier,/^[A-Za-z0-9_-]{43}$/);
      return {id_token:returnedToken,access_token:'do-not-persist',refresh_token:'do-not-persist'};
    },
  });
  return {integration,pendingStore,sessionStore,setToken:t=>returnedToken=t,getCalls:()=>exchangeCalls};
}
async function begin(f) {
  const start=await f.integration.start();
  const url=new URL(start.authorizationUrl);
  const state=url.searchParams.get('state');
  const nonce=f.pendingStore.map.get(state).nonce;
  const flowCookie=start.setCookie.split(';')[0];
  const request=new Request(REDIRECT,{headers:{Cookie:flowCookie}});
  return {start,url,state,nonce,request,flowCookie};
}
async function finish(f, b, claimsOverride={}, tokenOptions={}) {
  f.setToken(await sign(claims(b.nonce,claimsOverride),tokenOptions));
  return f.integration.callback({state:b.state,code:'roblox-auth-code',request:b.request});
}
const sessionRequest = cookie => new Request('https://sandbox.example.test/api/v1/violation/history',{headers:{Cookie:cookie.split(';')[0]}});

test('start issues OAuth code+PKCE S256, minimal scope and Secure HttpOnly cookie',async()=>{
  const f=createFixture(), b=await begin(f);
  for(const [k,v] of Object.entries({scope:'openid',response_type:'code',code_challenge_method:'S256',
      redirect_uri:REDIRECT,client_id:CLIENT})) assert.equal(b.url.searchParams.get(k),v);
  assert.match(b.url.searchParams.get('code_challenge'),/^[A-Za-z0-9_-]{43}$/);
  assert.equal(b.url.hostname,'apis.roblox.com');
  assert.match(b.start.setCookie,/HttpOnly; Secure; SameSite=Lax/);
  assert.equal(f.pendingStore.map.size,1);
});
test('one authenticated callback creates an opaque server-backed session',async()=>{
  const f=createFixture(),b=await begin(f);
  const result=await finish(f,b);
  assert.equal(result.sub,'111');assert.match(result.setCookie,/HttpOnly; Secure; SameSite=Lax/);
  assert.equal(f.pendingStore.map.size,0);
  assert.equal(f.sessionStore.map.size,1);
  assert.ok(!JSON.stringify([...f.sessionStore.map.values()]).includes('do-not-persist'));
  const principal=await f.integration.resolveVerifiedPrincipal(sessionRequest(result.setCookie));
  assert.deepEqual(principal,{verified:true,method:'roblox_oidc',sub:'111',expiresAt:now+900});
});
test('callback state cannot be replayed',async()=>{
  const f=createFixture(),b=await begin(f);await finish(f,b);
  await assert.rejects(()=>finish(f,b),/transaction invalid/);
  assert.equal(f.getCalls(),1);
});
test('wrong flow cookie prevents callback even when state/code are known',async()=>{
  const f=createFixture(),b=await begin(f);f.setToken(await sign(claims(b.nonce)));
  const badRequest=new Request(REDIRECT,{headers:{Cookie:'__Host-asc_oidc_flow='+'x'.repeat(43)}});
  await assert.rejects(()=>f.integration.callback({state:b.state,code:'roblox-auth-code',request:badRequest}),/transaction invalid/);
  assert.equal(f.getCalls(),0);
});
test('missing cookie prevents state takeover',async()=>{
  const f=createFixture(),b=await begin(f);
  await assert.rejects(()=>f.integration.callback({state:b.state,code:'roblox-auth-code',request:new Request(REDIRECT)}),/transaction invalid/);
});
test('expired OAuth state fails closed',async()=>{
  const f=createFixture(),b=await begin(f);now+=301;
  await assert.rejects(()=>f.integration.callback({state:b.state,code:'roblox-auth-code',request:b.request}),/transaction invalid/);
  now-=301;
});
test('forged bearer userId headers, query params and JSON do not create identity',async()=>{
  const f=createFixture();
  const forged=new Request('https://sandbox.example.test/?userId=222&identityVerified=true',{
    headers:{Cookie:'__Host-asc_oidc_session='+'x'.repeat(43),'x-roblox-user-id':'222'}
  });
  assert.equal(await f.integration.resolveVerifiedPrincipal(forged),null);
});
test('duplicate cookie names are rejected',async()=>{
  const f=createFixture(),b=await begin(f),r=await finish(f,b);
  const token=r.setCookie.split(';')[0];
  const request=new Request(REDIRECT,{headers:{Cookie:token+'; '+token}});
  assert.equal(await f.integration.resolveVerifiedPrincipal(request),null);
});
test('expired browser session fails closed',async()=>{
  const f=createFixture(),b=await begin(f),r=await finish(f,b);
  now+=901;
  assert.equal(await f.integration.resolveVerifiedPrincipal(sessionRequest(r.setCookie)),null);
  now-=901;
});
test('valid ES256 verifies Roblox subject',async()=>{
  const nonce='n'.repeat(43), token=await sign(claims(nonce));
  const result=await verifyRobloxIdToken({idToken:token,clientId:CLIENT,expectedNonce:nonce,jwks,clock});
  assert.deepEqual(result,{sub:'111',method:'roblox_oidc',verified:true});
});
for(const [label,changes] of [
  ['issuer',{iss:'https://evil.invalid/'}],['audience',{aud:'someone-else'}],
  ['nonce',{nonce:'wrong'}],['expired',{exp:now-120}],['future issue time',{iat:now+120}],
  ['subject',{sub:'abc'}],['not-before',{nbf:now+120}],['multi-audience without azp',{aud:[CLIENT,'other']}],
]) {
  test('rejects invalid signed token claim: '+label,async()=>{
    const nonce='n'.repeat(43),token=await sign(claims(nonce,changes));
    await assert.rejects(()=>verifyRobloxIdToken({idToken:token,clientId:CLIENT,expectedNonce:nonce,jwks,clock}),/Invalid identity token/);
  });
}
test('valid multi-audience token only with azp matching client',async()=>{
  const nonce='n'.repeat(43),token=await sign(claims(nonce,{aud:[CLIENT,'other'],azp:CLIENT}));
  const v=await verifyRobloxIdToken({idToken:token,clientId:CLIENT,expectedNonce:nonce,jwks,clock});
  assert.equal(v.sub,'111');
});
test('rejects tampered signature',async()=>{
  const nonce='n'.repeat(43),token=await sign(claims(nonce));
  const sections=token.split('.');
  sections[1]=enc(claims(nonce,{sub:'222'}));
  await assert.rejects(()=>verifyRobloxIdToken({idToken:sections.join('.'),clientId:CLIENT,expectedNonce:nonce,jwks,clock}),/Invalid identity token/);
});
test('rejects alg substitution',async()=>{
  const nonce='n'.repeat(43),token=await sign(claims(nonce),{header:{alg:'HS256'}});
  await assert.rejects(()=>verifyRobloxIdToken({idToken:token,clientId:CLIENT,expectedNonce:nonce,jwks,clock}),/Invalid identity token/);
});
test('rejects unknown kid',async()=>{
  const nonce='n'.repeat(43),token=await sign(claims(nonce),{header:{kid:'unknown'}});
  await assert.rejects(()=>verifyRobloxIdToken({idToken:token,clientId:CLIENT,expectedNonce:nonce,jwks,clock}),/Invalid identity token/);
});
test('rejects token signed by a different key with the same kid',async()=>{
  const other=await crypto.subtle.generateKey({name:'ECDSA',namedCurve:'P-256'},true,['sign','verify']);
  const nonce='n'.repeat(43),token=await sign(claims(nonce),{signingKey:other.privateKey});
  await assert.rejects(()=>verifyRobloxIdToken({idToken:token,clientId:CLIENT,expectedNonce:nonce,jwks,clock}),/Invalid identity token/);
});
test('rejects malformed token and JWKS errors',async()=>{
  const nonce='n'.repeat(43),token=await sign(claims(nonce));
  await assert.rejects(()=>verifyRobloxIdToken({idToken:token,clientId:CLIENT,expectedNonce:nonce,jwks:{keys:[]},clock}),/Invalid identity token/);
  await assert.rejects(()=>verifyRobloxIdToken({idToken:'not.a.jwt',clientId:CLIENT,expectedNonce:nonce,jwks,clock}),/Invalid identity token/);
});
test('Stage16.80 integration: only browser session can access account-bound history',async()=>{
  const f=createFixture(),b=await begin(f),r=await finish(f,b);
  const db={prepare:() => ({bind:sub => ({all:async()=>({results:sub==='111'?[]:[{id:'wrong-user'}]})})})};
  const history=createVerifiedHistoryHandler({db,resolveVerifiedPrincipal:f.integration.resolveVerifiedPrincipal,clock});
  const anonymous=await history(new Request('https://sandbox.example.test/api/v1/violation/history?userId=111'));
  assert.equal(anonymous.status,401);
  const verified=await history(sessionRequest(r.setCookie));
  assert.equal(verified.status,200);
  const payload=await verified.json();
  assert.equal(payload.identityVerified,true);assert.equal(payload.hasHistory,false);
});
