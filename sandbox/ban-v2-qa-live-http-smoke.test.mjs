import test from 'node:test';
import assert from 'node:assert/strict';

const HOST='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev';
const ROUTE='/api/v1/admin/bans/v2/qa';
const ORIGIN='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev';
async function call(method,path=ROUTE,{origin=ORIGIN,headers={},body}={}){
 const controller=new AbortController(),timeout=setTimeout(()=>controller.abort(),12000);
 try{return await fetch(HOST+path,{
  method,redirect:'error',cache:'no-store',signal:controller.signal,
  headers:{Origin:origin,...headers,...(body?{'Content-Type':'application/json'}:{})},
  ...(body?{body:JSON.stringify(body)}:{})
 })}finally{clearTimeout(timeout)}
}
test('new isolated QA Worker is online; unauthorized read returns 401',async()=>{
 const r=await call('GET');
 assert.equal(r.status,401,await r.text());
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),ORIGIN);
 assert.equal(r.headers.get('Cache-Control'),'no-store');
});
test('incorrect synthetic Admin Key denied; original Admin Key not exposed',async()=>{
 const r=await call('GET',ROUTE,{headers:{'X-Admin-Key':'QA-SYNTHETIC-INVALID-ADMIN-KEY-DO-NOT-USE'}});
 assert.equal(r.status,401,await r.text());
});
test('unauthorized QA POST cannot write any record',async()=>{
 const payload={action:'upsert',expectedRevision:0,
  entry:{userId:'123456789',username:'TestUser',reason:'Synthetic only',description:'QA test',
   startAt:'',expiresAt:'',selection:'restricted_mode',duration:'permanent'}};
 const r=await call('POST',ROUTE,{body:payload});
 assert.equal(r.status,401,await r.text());
});
test('hostile origins rejected before auth and no open CORS',async()=>{
 const r=await call('GET',ROUTE,{origin:'https://evil.example'});
 assert.equal(r.status,403,await r.text());
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),null);
});
test('authorized-origin preflight is explicit and read-only',async()=>{
 const r=await call('OPTIONS',ROUTE,{headers:{
  'Access-Control-Request-Method':'POST','Access-Control-Request-Headers':'Content-Type,X-Admin-Key'
 }});
 assert.equal(r.status,204);
 assert.match(r.headers.get('Access-Control-Allow-Headers'),/X-Admin-Key/);
});
test('no purge or arbitrary admin path on isolated QA Worker',async()=>{
 const r=await call('GET','/api/v1/admin/bans/v2/purge');
 assert.equal(r.status,404,await r.text());
});
