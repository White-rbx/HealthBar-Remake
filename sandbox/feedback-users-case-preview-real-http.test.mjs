import test from 'node:test';
import assert from 'node:assert/strict';

const BRANCH='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev';
const IMMUTABLE='https://da89f55b.arcscriptcenter-dashboard-staging.pages.dev';
const API='https://arcscriptcenter-api-staging.kogpasan14.workers.dev';
const TRASH='https://arcscriptcenter-trash-admin-staging.kogpasan14.workers.dev';
async function request(url,options={}){
 const ctrl=new AbortController(),timer=setTimeout(()=>ctrl.abort(),14000);
 try{return await fetch(url,{redirect:'follow',cache:'no-store',signal:ctrl.signal,...options})}
 finally{clearTimeout(timer)}
}
async function getBranchPage(){
 let last;
 for(let i=0;i<7;i++){
  last=await request(BRANCH+'/');
  const body=await last.text();
  if(body.includes('id="faUsersCase"'))return{response:last,body};
  if(i<6)await new Promise(resolve=>setTimeout(resolve,1500));
 }
 return{response:last,body:'Preview branch did not deliver new User\'s Case panel'};
}
test('branch Preview has canonical static assets and injected native User Case panel',async()=>{
 const {response,body}=await getBranchPage();
 assert.equal(response.status,200);
 assert.match(response.headers.get('content-type')||'',/text\/html/i);
 assert.equal(response.headers.get('X-ASC1649-Integration'),'injected-users-case-native');
 assert.ok(body.includes('id="faUsersCase"'),'missing native User Case section');
 assert.ok(body.includes('id="faUsersLoad"'),'missing Load Users button');
 assert.ok(body.includes('id="faTrashLoad"'),'missing Trash button');
 assert.ok(body.includes('id="faUnknownTrash"'),'missing Trash panel');
 assert.ok(body.includes('data-page="bans"'),'missing Ban Management');
 assert.ok(body.includes('id="page-bans"'),'missing Ban page');
 assert.ok(body.includes('data-page="feedback-appeal"'),'missing native Feedback nav');
 assert.equal((body.match(/id="faUsersCase"/g)||[]).length,1);
});
test('native Feedback and User Case JS/CSS endpoints are served with correct MIME',async()=>{
 const js=await request(BRANCH+'/__asc1649/feedback-appeal.js');
 assert.equal(js.status,200);
 assert.match(js.headers.get('content-type')||'',/javascript/);
 assert.equal(js.headers.get('X-Content-Type-Options'),'nosniff');
 const text=await js.text();
 assert.match(text,/Move Unknown Case To Trash/);
 assert.match(text,/faTrashRequest/);
 assert.match(text,/faUsersLoad/);
 assert.match(text,/faUsersReset/);
 const css=await request(BRANCH+'/__asc1649/feedback-appeal.css');
 assert.equal(css.status,200);
 assert.match(css.headers.get('content-type')||'',/text\/css/);
 assert.match(await css.text(),/\.fa-users-grid/);
});
test('canonical image asset exists in new Preview deployment',async()=>{
 const r=await request(IMMUTABLE+'/acs-logo.png');
 assert.equal(r.status,200);
 const bytes=new Uint8Array(await r.arrayBuffer());
 assert.deepEqual([...bytes.slice(0,8)],[137,80,78,71,13,10,26,10]);
});
test('existing Admin API accepts only known branch Preview origin for CORS',async()=>{
 const r=await request(API+'/api/v1/admin/feedback/list',{method:'OPTIONS',headers:{
  Origin:BRANCH,'Access-Control-Request-Method':'GET',
  'Access-Control-Request-Headers':'X-Admin-Key, Content-Type'
 }});
 assert.equal(r.status,204);
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),BRANCH);
});
test('new Trash Gateway also accepts known branch Preview origin',async()=>{
 const r=await request(TRASH+'/api/v1/admin/feedback/unknown-trash',{method:'OPTIONS',headers:{
  Origin:BRANCH,'Access-Control-Request-Method':'POST',
  'Access-Control-Request-Headers':'X-Admin-Key, Content-Type'
 }});
 assert.equal(r.status,204);
 assert.equal(r.headers.get('Access-Control-Allow-Origin'),BRANCH);
});
test('new Trash Gateway denies unauthenticated list and move requests',async()=>{
 const url=TRASH+'/api/v1/admin/feedback/unknown-trash';
 const unauthorized=await request(url,{headers:{Origin:BRANCH}});
 assert.equal(unauthorized.status,401);
 const moved=await request(url,{method:'POST',headers:{
  Origin:BRANCH,'Content-Type':'application/json'
 },body:JSON.stringify({action:'move',id:'00000000-0000-4000-8000-000000000001',confirm:'MOVE UNKNOWN CASE TO TRASH'})});
 assert.equal(moved.status,401);
});
test('noncanonical Preview is immutable while API denies its unknown Origin',async()=>{
 const r=await request(IMMUTABLE+'/');
 assert.equal(r.status,200);
 assert.ok((await r.text()).includes('id="faUsersCase"'),'immutable Preview missing User Case');
 const denied=await request(API+'/api/v1/admin/feedback/summary',{headers:{Origin:IMMUTABLE}});
 assert.equal(denied.status,403);
});
