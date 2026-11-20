import test from 'node:test';
import assert from 'node:assert/strict';
import {createBanV2QaGateway} from './ban-v2-qa-gateway.mjs';

const ORIGIN='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev';
const URL='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/qa';
const KEY='Q'.repeat(40);
const entry={userId:'123456789',username:'TestAccount',reason:'Test restriction',description:'QA only',
 startAt:'2026-11-01 10:00',expiresAt:'2026-12-31 10:00',
 selection:'restricted_mode',duration:'temporary'};
function mockDB(){
 let value=JSON.stringify({schema:2,entries:[]}),rev=0,hits=0;
 const db={
  prepare(sql){
   hits++;
   if(sql.startsWith('SELECT'))return{first:async()=>({document_json:value,revision:rev})};
   assert.match(sql,/UPDATE asc_ban_v2_qa SET/);
   return{bind(next,expected){return{run:async()=>{
    if(expected!==rev)return{meta:{changes:0}};
    value=next;rev++;return{meta:{changes:1}};
   }}}};
  },
  state:()=>({document:JSON.parse(value),revision:rev,hits})
 };
 return db;
}
function request(method='GET',{path=URL,origin=ORIGIN,body,adminKey=KEY}={}){
 return new Request(path,{method,headers:{Origin:origin,'X-Admin-Key':adminKey,
  ...(body===undefined?{}:{'Content-Type':'application/json'})},
  ...(body===undefined?{}:{body:JSON.stringify(body)})});
}
const allowed=async()=>true,denied=async()=>false;
async function read(resp){return{status:resp.status,data:await resp.json(),headers:resp.headers}}

test('admin-only QA read returns v2 document and isolated revision 0',async()=>{
 const db=mockDB(),gate=createBanV2QaGateway({adminAuthenticated:allowed});
 const res=await read(await gate.fetch(request(),{DB:db}));
 assert.equal(res.status,200);
 assert.equal(res.data.qaOnly,true);
 assert.equal(res.data.adminOnly,true);
 assert.equal(res.data.document.schema,2);
 assert.deepEqual(res.data.document.entries,[]);
 assert.equal(res.data.revision,0);
 assert.equal(res.headers.get('Access-Control-Allow-Origin'),ORIGIN);
});

test('four independent Selection/Duration combinations persist in QA only',async()=>{
 for(const selection of ['ban_ingame','restricted_mode'])
  for(const duration of ['temporary','permanent']){
   const db=mockDB(),gate=createBanV2QaGateway({adminAuthenticated:allowed});
   const e={...entry,selection,duration,expiresAt:duration==='temporary'?entry.expiresAt:''};
   const saved=await read(await gate.fetch(request('POST',{body:{action:'upsert',expectedRevision:0,entry:e}}),{DB:db}));
   assert.equal(saved.status,200);
   assert.equal(saved.data.saved,true);
   assert.equal(saved.data.qaOnly,true);
   assert.equal(db.state().revision,1);
   assert.deepEqual(db.state().document.entries,[e]);
   const list=await read(await gate.fetch(request(),{DB:db}));
   assert.equal(list.data.document.entries[0].selection,selection);
   assert.equal(list.data.document.entries[0].duration,duration);
  }
});

test('stale revision, invalid Selection, and contradictory expiry never write',async()=>{
 const db=mockDB(),gate=createBanV2QaGateway({adminAuthenticated:allowed});
 const base={action:'upsert',expectedRevision:0,entry};
 const save=await read(await gate.fetch(request('POST',{body:base}),{DB:db}));
 assert.equal(save.status,200);
 for(const body of [
  {...base,entry:{...entry,selection:'unassigned'},expectedRevision:1},
  {...base,entry:{...entry,duration:'permanent'},expectedRevision:1},
  {...base,expectedRevision:0},
  {...base,entry:{...entry,password:'not allowed'},expectedRevision:1},
  {...base,extra:true,expectedRevision:1}
 ]){
  const resp=await read(await gate.fetch(request('POST',{body}),{DB:db}));
  assert.ok([400,409].includes(resp.status),resp.status);
  assert.equal(db.state().revision,1);
 }
});

test('missing/invalid Admin authorization denies before reading QA D1',async()=>{
 const db=mockDB(),gate=createBanV2QaGateway({adminAuthenticated:denied});
 const r=await read(await gate.fetch(request(),{DB:db}));
 assert.equal(r.status,401);assert.equal(db.state().hits,0);
 const p=await read(await gate.fetch(request('POST',{body:{action:'upsert',entry,expectedRevision:0}}),{DB:db}));
 assert.equal(p.status,401);assert.equal(db.state().hits,0);
});

test('cross-origin attempts are denied; CORS preflight only for allowlist',async()=>{
 const gate=createBanV2QaGateway({adminAuthenticated:allowed});
 const bad=await gate.fetch(request('GET',{origin:'https://evil.example'}),{DB:mockDB()});
 assert.equal(bad.status,403);
 assert.equal(bad.headers.get('Access-Control-Allow-Origin'),null);
 const good=await gate.fetch(request('OPTIONS'),{DB:mockDB()});
 assert.equal(good.status,204);
 assert.match(good.headers.get('Access-Control-Allow-Headers'),/X-Admin-Key/);
});

test('no public deletion path or unrelated route; removal changes QA only',async()=>{
 const db=mockDB(),gate=createBanV2QaGateway({adminAuthenticated:allowed});
 assert.equal((await gate.fetch(request('GET',{path:URL.replace('/qa','/purge')}),{DB:db})).status,404);
 const create=await gate.fetch(request('POST',{body:{action:'upsert',entry,expectedRevision:0}}),{DB:db});
 assert.equal(create.status,200);
 const rm=await read(await gate.fetch(request('POST',{body:{
  action:'remove',userId:entry.userId,expectedRevision:1
 }}),{DB:db}));
 assert.equal(rm.status,200);
 assert.equal(db.state().revision,2);
 assert.deepEqual(db.state().document.entries,[]);
});

test('existing Admin secret delegated through AUTH_API Service Binding',async()=>{
 const db=mockDB();
 let forwarded;
 const AUTH_API={fetch:async request=>{
  forwarded={url:request.url,method:request.method,key:request.headers.get('X-Admin-Key'),
   origin:request.headers.get('Origin')};
  return Response.json({ok:true,adminOnly:true,summary:{total:0}});
 }};
 const gate=createBanV2QaGateway();
 const r=await read(await gate.fetch(request(),{DB:db,AUTH_API}));
 assert.equal(r.status,200);
 assert.match(forwarded.url,/arcscriptcenter-api-staging/);
 assert.match(forwarded.url,/\/api\/v1\/admin\/feedback\/summary$/);
 assert.equal(forwarded.key,KEY);
 assert.equal(forwarded.origin,ORIGIN);
});
