// Read-only STAGING edge probe. Uses no cookies, credentials or D1.
// A 200 landing or a 503 provisioning API means the Access boundary was bypassed.
// This test must never be used as evidence of authentication readiness.
import test from 'node:test';
import assert from 'node:assert/strict';
import {EDGE_QA_ORIGIN} from './eslogin-independent-edge-qa.mjs';

async function expectAccessDenial(path,init={}){
 const response=await fetch(EDGE_QA_ORIGIN+path,{
  redirect:'manual',signal:AbortSignal.timeout(15000),...init,
 });
 const status=response.status;
 const redirected=response.headers.get('location');
 const host=redirected?new URL(redirected,EDGE_QA_ORIGIN).hostname:null;
 console.info('ESLogin locked edge status:',status,'redirect-host:',host||'none');
 assert.ok([302,303,307,308,401,403].includes(status),
  'Unauthenticated request reached app or unexpected edge response: HTTP '+status);
 if(status>=300&&status<400){
  assert.ok((redirected||'').includes('cloudflareaccess.com')||
   (redirected||'').includes('/cdn-cgi/access/'),
   'Redirect did not resemble a Cloudflare Access challenge');
 }
 assert.notEqual(status,200,'Access must block public landing');
 assert.notEqual(status,503,'Provisioning origin must not be reached anonymously');
}

test('independent locked HTTPS QA Access blocks anonymous GET and POST at the edge',async()=>{
 await expectAccessDenial('/');
 await expectAccessDenial('/api/v1/accounts/passkey/login/options',{
  method:'POST',headers:{'Content-Type':'application/json'},body:'{}',
 });
});
