// Live, read-only STAGING Access probes. They create no accounts or sessions.
// This is negative-edge coverage only; passing does NOT prove Passkey login works.
// No credentials, cookies, tokens, recovery codes, or D1 mutations are used.
import test from 'node:test';
import assert from 'node:assert/strict';
import {EDGE_QA_ORIGIN} from './eslogin-independent-edge-qa.mjs';

const ACCESS_HOST='https://arcscriptcenter-dashboard-pages.cloudflareaccess.com';
const protectedPaths=[
 {path:'/',method:'GET'},
 {path:'/health',method:'GET'},
 {path:'/login',method:'GET'},
 {path:'/myaccount',method:'GET'},
 {path:'/passkey-client.js',method:'GET'},
 {path:'/api/v1/accounts/passkey/register/options',method:'POST'},
 {path:'/api/v1/accounts/passkey/login/options',method:'POST'},
 {path:'/api/v1/accounts/passkey/recovery/options',method:'POST'},
 {path:'/api/v1/accounts/pair/start',method:'POST'},
 {path:'/api/v1/accounts/pair/poll',method:'POST'},
 {path:'/api/v1/accounts/session',method:'POST'},
];

async function expectAccessDenial({path,method}){
 const options={
  method,redirect:'manual',signal:AbortSignal.timeout(15000),
  headers:method==='POST'?{'Content-Type':'application/json'}:{},
 };
 if(method==='POST')options.body='{}';
 const response=await fetch(EDGE_QA_ORIGIN+path,options);
 const status=response.status,redirected=response.headers.get('location');
 const target=redirected?new URL(redirected,EDGE_QA_ORIGIN):null;
 console.info('ESLogin locked edge:',method,path,status,'redirect-host:',target?.hostname||'none');
 assert.ok([302,303,307,308,401,403].includes(status),
  'Anonymous request reached application or returned unexpected status: '+method+' '+path+' '+status);
 if(status>=300&&status<400){
  assert.ok(target,'Access redirect must contain a Location');
  assert.equal(target.origin,ACCESS_HOST,'Only the expected Access tenant may challenge');
  assert.ok(target.pathname.startsWith('/cdn-cgi/access/login/'),'Expected Access login challenge');
 }
 assert.notEqual(status,200,'Anonymous request must not reach app: '+method+' '+path);
 assert.notEqual(status,503,'Anonymous request must not reach provisioning: '+method+' '+path);
 const sessionHeaders=response.headers.getSetCookie?.()||[];
 assert.ok(sessionHeaders.every(h=>!/(?:__Host-ascqa|__Host-ascqa-passkey-flow)=/.test(h)),
  'No application session or WebAuthn flow cookie may leak to anonymous clients');
}

test('STAGING Edge Access denies all anonymous account, web Passkey and Loader routes',async t=>{
 for(const endpoint of protectedPaths){
  await t.test(endpoint.method+' '+endpoint.path,()=>expectAccessDenial(endpoint));
 }
});

test('STAGING Edge Access protects the OPTIONS preflight route',async()=>{
 const response=await fetch(EDGE_QA_ORIGIN+'/api/v1/accounts/passkey/register/options',{
  method:'OPTIONS',redirect:'manual',signal:AbortSignal.timeout(15000),
  headers:{'Origin':'https://untrusted.invalid','Access-Control-Request-Method':'POST'},
 });
 const location=response.headers.get('location');
 console.info('ESLogin locked edge OPTIONS:',response.status,
  'redirect-host:',location?new URL(location,EDGE_QA_ORIGIN).hostname:'none');
 assert.ok([302,303,307,308,401,403].includes(response.status),
  'OPTIONS must not bypass Access or reach application');
 if(response.status>=300&&response.status<400){
  const target=new URL(location,EDGE_QA_ORIGIN);
  assert.equal(target.origin,ACCESS_HOST);
  assert.ok(target.pathname.startsWith('/cdn-cgi/access/login/'));
 }
 assert.equal(response.headers.get('access-control-allow-origin'),null,
  'Anonymous preflight must not be allowed through Access');
});
