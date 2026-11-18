/**
 * ArcScriptCenter STAGING — Unknown Feedback Trash Admin Gateway.
 *
 * Separate Worker to avoid replacing the existing 300KB+ API Worker or
 * duplicating its Admin secret. Authorization is delegated through the
 * Cloudflare Service binding AUTH_API to EXISTING /admin/feedback/summary.
 * All Admin responses are private and no-store; public fetch cannot purge.
 *
 * Metadata:
 *  DB       (type d1, STAGING D1 ONLY)
 *  AUTH_API (type service, arcscriptcenter-api-staging ONLY)
 */
import {createUnknownCaseTrashHandler} from './feedback-unknown-case-trash.mjs';

const AUTH_URL='https://arcscriptcenter-api-staging.kogpasan14.workers.dev/api/v1/admin/feedback/summary';
const ORIGINS=Object.freeze(new Set([
 'https://arcscriptcenter-dashboard-staging.pages.dev',
 'https://50369475.arcscriptcenter-dashboard-staging.pages.dev',
 'https://352de034.arcscriptcenter-dashboard-staging.pages.dev',
 'https://416b162f.arcscriptcenter-dashboard-staging.pages.dev',
 'https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev'
]));
const deny=(message,status)=>new Response(JSON.stringify({ok:false,error:message}),{
 status,headers:{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff','Vary':'Origin'}});
const approvedOrigin=(request,origin)=>typeof origin==='string'&&ORIGINS.has(origin);
async function existingAdminAuthenticated(request,env){
 const key=request.headers.get('X-Admin-Key')||'';
 if(key.length<32||key.length>4096||typeof env.AUTH_API?.fetch!=='function')return false;
 const origin=request.headers.get('Origin');
 if(!approvedOrigin(request,origin))return false;
 // Authenticated GET to the existing STAGING Admin API. Do not copy or
 // log the key. No application code can set adminOnly=true by itself.
 const source=new Request(AUTH_URL,{method:'GET',headers:{
  'Origin':origin,'X-Admin-Key':key,'Accept':'application/json'
 },redirect:'error',cache:'no-store'});
 try{
  const out=await env.AUTH_API.fetch(source);
  if(out.status!==200)return false;
  const json=await out.json();
  return json?.ok===true&&json?.adminOnly===true&&
   Number.isSafeInteger(json?.summary?.total);
 }catch{return false}
}

export function createTrashAdminGateway({
 adminAuthenticated=existingAdminAuthenticated,originAllowed=approvedOrigin,
 clock=()=>Math.floor(Date.now()/1000)
}={}){
 const handler=createUnknownCaseTrashHandler({adminAuthenticated,originAllowed,clock});
 return {
  async fetch(request,env,ctx){
   const origin=request.headers.get('Origin');
   if(!originAllowed(request,origin))return deny('Origin not allowed',403);
   if(request.method==='OPTIONS'){
    const headers=new Headers({'Access-Control-Allow-Origin':origin,
     'Access-Control-Allow-Methods':'GET, POST, OPTIONS',
     'Access-Control-Allow-Headers':'Accept, Content-Type, X-Admin-Key',
     'Access-Control-Max-Age':'600',
     'Cache-Control':'no-store','Vary':'Origin'});
    return new Response(null,{status:204,headers});
   }
   let out;
   try{out=await handler(request,env)}
   catch{out=deny('Service unavailable',503)}
   const headers=new Headers(out.headers);
   headers.set('Access-Control-Allow-Origin',origin);
   headers.set('Vary','Origin');
   headers.set('Cache-Control','no-store');
   headers.set('X-Content-Type-Options','nosniff');
   headers.set('X-Robots-Tag','noindex');
   return new Response(out.body,{status:out.status,headers});
  }
 };
}
export default createTrashAdminGateway();
