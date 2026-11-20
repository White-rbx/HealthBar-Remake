import test from 'node:test';
import assert from 'node:assert/strict';

const PREVIEW='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev';
const ARCHIVE='https://1a395835.arcscriptcenter-dashboard-staging.pages.dev';
const QA_API='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/qa';
async function req(url,opts={}){
 const ctl=new AbortController(),timeout=setTimeout(()=>ctl.abort(),12000);
 try{return await fetch(url,{redirect:'error',cache:'no-store',signal:ctl.signal,...opts})}
 finally{clearTimeout(timeout)}
}
test('live Preview still preserves Banned Check Center, User Case, and original form',async()=>{
 const r=await req(PREVIEW+'/');
 assert.equal(r.status,200);
 const html=await r.text();
 for(const s of ['id="page-bans"','id="banEditorForm"','id="banRecords"',
  'id="banAdminKey"','id="page-feedback-appeal"','id="faUsersCase"',
  '/__asc1650/ban-mode.js'])assert.ok(html.includes(s),s);
 assert.equal((html.match(/\/__asc1650\/ban-mode\.js/g)||[]).length,1);
});
test('first-party Ban Selection addon includes QA Save/Load, same Unlock, and no browser storage',async()=>{
 const r=await req(PREVIEW+'/__asc1650/ban-mode.js');
 assert.equal(r.status,200);
 assert.match(r.headers.get('content-type')||'',/javascript/);
 const js=await r.text();
 for(const s of ["Save '+label+' Ban","Load '+label+' Bans",'banV2Selection','banV2Duration',
  "byId('banAdminKey').value.trim()",'/api/v1/admin/bans/v2/manage',
  'expectedSha:sha','confirmed:true','preventDefault','stopImmediatePropagation',
  'arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev']){
  assert.ok(js.includes(s),s);
 }
 assert.doesNotMatch(js,/localStorage|sessionStorage|document\.cookie/);
});
test('original logo still renders in the preview',async()=>{
 const r=await req(PREVIEW+'/acs-logo.png');
 assert.equal(r.status,200);
 const bin=new Uint8Array(await r.arrayBuffer());
 assert.deepEqual([...bin.slice(0,8)],[137,80,78,71,13,10,26,10]);
});
test('isolated QA Save API denies unauthorized GET and POST',async()=>{
 const origin=PREVIEW;
 const r=await req(QA_API,{headers:{Origin:origin}});
 assert.equal(r.status,401,await r.text());
 const w=await req(QA_API,{method:'POST',headers:{Origin:origin,'Content-Type':'application/json'},
  body:JSON.stringify({action:'upsert',expectedRevision:0,entry:{
   userId:'123456789',username:'QAUser',reason:'QA only',description:'',
   startAt:'',expiresAt:'',selection:'restricted_mode',duration:'permanent'
  }})});
 assert.equal(w.status,401,await w.text());
});
test('QA API CORS only allows existing approved origin',async()=>{
 const bad=await req(QA_API,{headers:{Origin:'https://evil.example'}});
 assert.equal(bad.status,403);
 assert.equal(bad.headers.get('Access-Control-Allow-Origin'),null);
});


test('immutable rollback Preview still serves read-only v1 to v2 Compatibility',async()=>{
 const r=await req(ARCHIVE+'/__asc1650/ban-mode.js');
 assert.equal(r.status,200);
 const js=await r.text();
 for(const word of ['Preview Ban v1 → v2','banPreviewBanV2','banV2CompatibilityResults',
  'compatEndpoint','Original schema:','No GitHub changes were made',
  'sourceSchema','readOnly!==true']){
  assert.ok(js.includes(word),word);
 }
});
test('read-only source compatibility HTTP route denies unauthenticated requests',async()=>{
 const url='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/compatibility';
 const r=await req(url,{headers:{Origin:PREVIEW}});
 assert.equal(r.status,401,await r.text());
 assert.equal(r.headers.get('Cache-Control'),'no-store');
});

test('current Pages origin is allowed and the new writer still requires actual Admin authentication',async()=>{
 const route='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/manage';
 const preflight=await req(route,{method:'OPTIONS',headers:{Origin:PREVIEW,'Access-Control-Request-Method':'POST'}});
 assert.equal(preflight.status,204);
 assert.equal(preflight.headers.get('Access-Control-Allow-Origin'),PREVIEW);
 const wrong=await req(route,{headers:{Origin:PREVIEW,'X-Admin-Key':'synthetic-invalid-admin-key-for-ci-000000000000'}});
 assert.equal(wrong.status,401);
 const originalFeedback='https://arcscriptcenter-api-staging.kogpasan14.workers.dev/api/v1/admin/feedback/summary';
 const unchanged=await req(originalFeedback,{headers:{Origin:PREVIEW,'X-Admin-Key':'synthetic-invalid-admin-key-for-ci-000000000000'}});
 assert.equal(unchanged.status,401);
 assert.equal(unchanged.headers.get('Access-Control-Allow-Origin'),PREVIEW);
});
