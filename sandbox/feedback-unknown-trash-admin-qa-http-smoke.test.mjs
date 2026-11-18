import test from 'node:test';
import assert from 'node:assert/strict';
const HOST='https://arcscriptcenter-trash-admin-qa.kogpasan14.workers.dev';
const PATH='/api/v1/admin/feedback/unknown-trash';
const ORIGIN='https://arcscriptcenter-dashboard-staging.pages.dev';
async function call(method,path=PATH,{origin=ORIGIN,headers={},body}={}){
 const ctrl=new AbortController();
 const stop=setTimeout(()=>ctrl.abort(),10000);
 try{
  const response=await fetch(HOST+path,{
   method,redirect:'error',cache:'no-store',signal:ctrl.signal,
   headers:{...(origin?{'Origin':origin}:{}),...headers},
   ...(body===undefined?{}:{body:JSON.stringify(body)})
  });
  return response;
 }finally{clearTimeout(stop)}
}
test('QA Worker is online and denies unauthenticated Trash reads',async()=>{
 const r=await call('GET');
 assert.equal(r.status,401,await r.text());
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),ORIGIN);
 assert.equal(r.headers.get('Cache-Control'),'no-store');
});
test('existing Admin Service Binding denies synthetic incorrect key',async()=>{
 const r=await call('GET',PATH,{headers:{'X-Admin-Key':'SYNTHETIC_INVALID_ADMIN_KEY_1234567890'}});
 assert.equal(r.status,401,await r.text());
});
test('QA Worker CORS is exact-origin and denies hostile websites',async()=>{
 const r=await call('GET',PATH,{origin:'https://not-our-dashboard.example'});
 assert.equal(r.status,403,await r.text());
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),null);
});
test('CORS preflight is supported but cannot read private data',async()=>{
 const r=await call('OPTIONS',PATH,{headers:{
  'Access-Control-Request-Method':'POST',
  'Access-Control-Request-Headers':'X-Admin-Key, Content-Type'
 }});
 assert.equal(r.status,204);
 assert.match(r.headers.get('Access-Control-Allow-Headers'),/X-Admin-Key/);
});
test('unauthorized POST cannot move a synthetic case',async()=>{
 const body={action:'move',id:'00000000-0000-4000-8000-000000000001',confirm:'MOVE UNKNOWN CASE TO TRASH'};
 const r=await call('POST',PATH,{headers:{'Content-Type':'application/json'},body});
 assert.equal(r.status,401,await r.text());
});
test('no public deletion endpoint is exposed',async()=>{
 const r=await call('GET','/purge');
 assert.equal(r.status,404,await r.text());
});
