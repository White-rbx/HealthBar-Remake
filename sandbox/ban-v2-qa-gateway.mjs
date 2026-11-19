/**
 * ArcScriptCenter — isolated QA Ban schema v2 Admin Gateway.
 * DB: dedicated QA table asc_ban_v2_qa, NOT the live GitHub ban list,
 * and NOT production or STAGING managed-ban snapshot.
 * AUTH_API: service binding to the existing admin-only STAGING Worker.
 *
 * The original Admin Key stays in memory; no secret is copied, logged or stored.
 * This server cannot affect a user's actual Roblox ExperienceSettings access.
 */
import {applyBanChange,parseBanDocument,migrateBanDocument} from './managed-ban-schema-v2.mjs';

const AUTH_URL='https://arcscriptcenter-api-staging.kogpasan14.workers.dev/api/v1/admin/feedback/summary';
const ROUTE='/api/v1/admin/bans/v2/qa';
const COMPAT_ROUTE='/api/v1/admin/bans/v2/compatibility';
const BANS_URL='https://arcscriptcenter-api-staging.kogpasan14.workers.dev/api/v1/admin/bans';
const ALLOWED_ORIGINS=new Set([
 'https://arcscriptcenter-dashboard-staging.pages.dev',
 'https://50369475.arcscriptcenter-dashboard-staging.pages.dev',
 'https://352de034.arcscriptcenter-dashboard-staging.pages.dev',
 'https://416b162f.arcscriptcenter-dashboard-staging.pages.dev',
 'https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev'
]);
const reply=(data,status=200,origin='')=>{
 const headers={'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store',
  'X-Content-Type-Options':'nosniff','X-Robots-Tag':'noindex','Vary':'Origin'};
 if(ALLOWED_ORIGINS.has(origin))headers['Access-Control-Allow-Origin']=origin;
 return new Response(JSON.stringify(data),{status,headers});
};
async function checkAdmin(request,env){
 const key=request.headers.get('X-Admin-Key')||'';
 const origin=request.headers.get('Origin')||'';
 if(!ALLOWED_ORIGINS.has(origin)||key.length<32||key.length>4096||
    typeof env.AUTH_API?.fetch!=='function')return false;
 try{
  const req=new Request(AUTH_URL,{method:'GET',headers:{
   'Origin':origin,'X-Admin-Key':key,'Accept':'application/json'
  }});
  const out=await env.AUTH_API.fetch(req);
  if(out.status!==200)return false;
  const data=await out.json();
  return data?.ok===true&&data?.adminOnly===true&&
    Number.isSafeInteger(data?.summary?.total);
 }catch{return false}
}
/**
 * Read the existing GitHub-managed Ban list through the ORIGINAL Admin API,
 * then perform a read-only migration preview. This never writes a new JSON
 * managed Ban block to GitHub or the existing STAGING D1 snapshot.
 */
async function previewLegacyCompatibility(request,env,origin){
 if(request.method!=='GET')return reply({ok:false,error:'Compatibility preview is read-only'},405,origin);
 const key=request.headers.get('X-Admin-Key')||'';
 try{
  if(typeof env.AUTH_API?.fetch!=='function')throw Error('Service binding missing');
  const req=new Request(BANS_URL,{method:'GET',headers:{
   'Origin':origin,'X-Admin-Key':key,'Accept':'application/json'
  }});
  const upstream=await env.AUTH_API.fetch(req);
  if(upstream.status!==200)throw Error('Existing Admin Ban source unavailable');
  const raw=await upstream.json();
  if(raw?.ok!==true||!Array.isArray(raw.entries)||
     typeof raw.sha!=='string'||!/^[0-9a-f]{40}$/i.test(raw.sha))
     throw Error('Original Ban source is incompatible');
  // The old deployed API is schema v1; once it upgrades, it will explicitly
  // return schema:2. Never guess a schema from entry contents.
  const sourceSchema=raw.schema===undefined?1:raw.schema;
  const v2=migrateBanDocument({schema:sourceSchema,entries:raw.entries});
  return reply({ok:true,adminOnly:true,qaOnly:true,readOnly:true,
   sourceSchema,sourceSha:raw.sha,
   entriesRead:v2.entries.length,document:v2,
   legacyUnassigned:v2.entries.filter(e=>e.selection==='unassigned').length},200,origin);
 }catch{return reply({ok:false,error:'Original Ban source unavailable or invalid'},503,origin)}
}
function validateRequest(body){
 if(!body||typeof body!=='object'||Array.isArray(body)||
    !Number.isSafeInteger(body.expectedRevision)||body.expectedRevision<0)throw Error('Invalid revision');
 if(body.action==='upsert'){
  if(Object.keys(body).sort().join(',')!=='action,entry,expectedRevision')
   throw Error('Unexpected request fields');
 }else if(body.action==='remove'){
  if(Object.keys(body).sort().join(',')!=='action,expectedRevision,userId'||
     typeof body.userId!=='string')throw Error('Unexpected request fields');
 }else throw Error('Unsupported action');
}
export function createBanV2QaGateway({adminAuthenticated=checkAdmin}={}){
 return {
  async fetch(request,env){
   const origin=request.headers.get('Origin')||'';
   if(!ALLOWED_ORIGINS.has(origin))return reply({ok:false,error:'Origin not allowed'},403);
   const url=new URL(request.url);
   if(url.pathname!==ROUTE&&url.pathname!==COMPAT_ROUTE)return reply({ok:false,error:'Not found'},404,origin);
   if(request.method==='OPTIONS'){
    return new Response(null,{status:204,headers:{
     'Access-Control-Allow-Origin':origin,
     'Access-Control-Allow-Methods':'GET, POST, OPTIONS',
     'Access-Control-Allow-Headers':'Accept, Content-Type, X-Admin-Key',
     'Access-Control-Max-Age':'600','Cache-Control':'no-store','Vary':'Origin'
    }});
   }
   if(!['GET','POST'].includes(request.method))return reply({ok:false,error:'Method not allowed'},405,origin);
   if(!await adminAuthenticated(request,env))return reply({ok:false,error:'Unauthorized'},401,origin);
   if(url.pathname===COMPAT_ROUTE)return previewLegacyCompatibility(request,env,origin);
   if(!env.DB||typeof env.DB.prepare!=='function')return reply({ok:false,error:'QA database unavailable'},503,origin);
   try{
    const row=await env.DB.prepare('SELECT document_json, revision FROM asc_ban_v2_qa WHERE id = 1').first();
    if(!row||!Number.isSafeInteger(row.revision)||row.revision<0)throw Error('QA fixture missing');
    const document=parseBanDocument(JSON.parse(row.document_json));
    if(document.schema!==2)throw Error('QA fixture schema mismatch');
    if(request.method==='GET')
     return reply({ok:true,adminOnly:true,qaOnly:true,revision:row.revision,document},200,origin);
    if(!(request.headers.get('Content-Type')||'').toLowerCase().startsWith('application/json'))
     return reply({ok:false,error:'Expected application/json'},415,origin);
    const raw=await request.text();
    if(new TextEncoder().encode(raw).length>4096)
     return reply({ok:false,error:'Request too large'},413,origin);
    let body;
    try{body=JSON.parse(raw)}catch{return reply({ok:false,error:'Malformed JSON'},400,origin)}
    try{validateRequest(body)}catch(e){return reply({ok:false,error:e.message},400,origin)}
    if(body.expectedRevision!==row.revision)
     return reply({ok:false,error:'QA revision conflict; refresh first'},409,origin);
    let next;
    // expectedRevision is concurrency metadata, not a Ban entry field.
    // Pass only the validated domain action into the strict schema engine.
    const change=body.action==='upsert'
     ?{action:'upsert',entry:body.entry}
     :{action:'remove',userId:body.userId};
    try{next=applyBanChange(document,change)}
    catch(e){return reply({ok:false,error:e.message},400,origin)}
    const updated=await env.DB.prepare(
      'UPDATE asc_ban_v2_qa SET document_json=?, revision=revision+1 WHERE id=1 AND revision=?'
    ).bind(JSON.stringify(next),row.revision).run();
    if(updated?.meta?.changes!==1)
     return reply({ok:false,error:'QA revision conflict; refresh first'},409,origin);
    return reply({ok:true,adminOnly:true,qaOnly:true,saved:true,
     revision:row.revision+1,document:next,action:body.action},200,origin);
   }catch(e){
    return reply({ok:false,error:'QA Ban service unavailable'},503,origin);
   }
  }
 };
}
export default createBanV2QaGateway();
