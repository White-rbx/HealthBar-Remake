import {
 applyBanChange, effectiveBanSelection, migrateBanDocument, parseBanLua, renderBanLua,
 selectActiveBan, timeICT, validateBanEntryV2,
} from './managed-ban-schema-v2.mjs';
import {createVerifiedHistoryHandler} from './stage16-80-verified-violation-history.mjs';

export const ADMIN_BANS = '/api/v1/admin/bans/v2/manage';
export const GAME_BANS = '/api/v1/roblox/bans/v2/';
const GAME_ROUTES = new Set(['policy','authorize','violation','appeal']);
const FEATURES = new Set(['editor','search','recommendations','arcsen_chat','feedback','violation','appeal']);
const LIMITED = new Set(['feedback','violation','appeal']);
const ID = /^[1-9][0-9]{0,15}$/;
const SHA = /^[a-f0-9]{40}$/;
const enc = new TextEncoder();
const validId = value => typeof value==='string' && ID.test(value) && Number.isSafeInteger(Number(value));
const hex = value => Array.from(new Uint8Array(value), byte => byte.toString(16).padStart(2,'0')).join('');
export async function gitBlobSha(source) {
 const bytes=enc.encode(source);
 const prefix=enc.encode('blob '+bytes.length+'\0');
 const object=new Uint8Array(prefix.length+bytes.length);
 object.set(prefix);
 object.set(bytes,prefix.length);
 return hex(await crypto.subtle.digest('SHA-1',object));
}

export class BanError extends Error {
 constructor(status,code,message){super(message);this.status=status;this.code=code;}
}
const fail=(status,code,message)=>{throw new BanError(status,code,message);};
const unavailable=()=>fail(503,'source_unavailable','Ban source unavailable. Refresh before trying again.');
const conflict=()=>fail(409,'sha_conflict','GitHub file changed. Load the list before saving again.');
const invalid=()=>fail(400,'invalid_request','Invalid request fields or values.');
function exact(value,fields) {
 return value && typeof value==='object' && !Array.isArray(value) &&
  Object.keys(value).length===fields.length && fields.every(key=>Object.hasOwn(value,key));
}
function json(data,status=200,origin) {
 const headers={'Content-Type':'application/json; charset=utf-8','Cache-Control':'private, no-store',
  'X-Content-Type-Options':'nosniff','Referrer-Policy':'no-referrer','Vary':'Origin'};
 if(origin)headers['Access-Control-Allow-Origin']=origin;
 return Response.json(data,{status,headers});
}
async function readJson(request) {
 if(!/^application\/json(?:\s*;\s*charset=utf-8)?$/i.test(request.headers.get('Content-Type')??''))
  fail(415,'content_type','Expected application/json.');
 if(!request.body || Number(request.headers.get('Content-Length'))>24000)
  fail(413,'body_size','Request is too large.');
 const reader=request.body.getReader();
 const chunks=[];
 let count=0;
 try{
  while(true){
   const {done,value}=await reader.read();
   if(done)break;
   count+=value.length;
   if(count>24000){await reader.cancel();fail(413,'body_size','Request is too large.');}
   chunks.push(value);
  }
 }finally{reader.releaseLock();}
 const bytes=new Uint8Array(count);
 let offset=0;
 for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
 try{return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));}catch{invalid();}
}
function openDocument(record) {
 if(!record || !SHA.test(record.sha)||typeof record.source!=='string')unavailable();
 try{return parseBanLua(record.source);}catch{
  fail(503,'source_invalid','Ban list format is invalid. Saving and policy checks are unavailable.');
 }
}
function parseChange(body) {
 const upsert=body?.action==='upsert';
 const fields=upsert?['action','expectedSha','entry','confirmed']:['action','expectedSha','userId','confirmed'];
 if(!exact(body,fields)||typeof body.expectedSha!=='string'||!SHA.test(body.expectedSha)||body.confirmed!==true)invalid();
 if(upsert){
  if(!validateBanEntryV2(body.entry))invalid();
  return {action:'upsert',entry:body.entry};
 }
 if(body.action!=='remove'||!validId(body.userId))invalid();
 return {action:'remove',userId:body.userId};
}

export function policyFor(document,userId,now) {
 const entries=migrateBanDocument(document).entries;
 const active=selectActiveBan(entries,userId,now);
 const record=entries.find(entry=>entry.userId===userId);
 const schedule=record?timeICT(record.startAt):null;
 const expires=active?timeICT(active.expiresAt):null;
 const nextCheckAt=Math.min(now+30,expires??Infinity,schedule>now?schedule:Infinity);
 if(!active)return {state:'clear',checkedAt:now,nextCheckAt,ban:null};
 return {state:effectiveBanSelection(active),checkedAt:now,nextCheckAt,ban:{
  selection:effectiveBanSelection(active),legacy:active.selection==='unassigned',duration:active.duration,
  reason:active.reason,description:active.description,startAt:timeICT(active.startAt),expiresAt:expires,
 }};
}

export async function verifyGameServer(request,env) {
 const supplied=request.headers.get('Authorization')?.match(/^Bearer ([A-Za-z0-9_-]{43,128})$/)?.[1];
 const secret=env.BAN_GAME_SERVER_SECRET;
 const universe=env.BAN_GAME_UNIVERSE_ID;
 if(typeof secret!=='string'||!/^[A-Za-z0-9_-]{43,128}$/.test(secret)||!validId(universe))
  fail(503,'identity_unavailable','Trusted game server is not configured.');
 if(!supplied||request.headers.has('Origin')||request.headers.has('Cookie'))return null;
 // Compare fixed-length digests. The credential is available only in Roblox server scripts.
 const [left,right]=await Promise.all([supplied,secret].map(value=>crypto.subtle.digest('SHA-256',enc.encode(value))));
 const a=new Uint8Array(left),b=new Uint8Array(right);
 let diff=0;
 for(let i=0;i<a.length;i++)diff|=a[i]^b[i];
 return diff===0?universe:null;
}

export function createBanV2Integration({store,adminAuthenticated,adminOrigins=[],authorizeServer=verifyGameServer,
 allowTarget=()=>true,verifyHistory,submitAppeal,rateLimit,clock=()=>Math.floor(Date.now()/1000)}={}) {
 if(typeof store?.read!=='function'||typeof store?.write!=='function'||
    typeof adminAuthenticated!=='function'||typeof rateLimit!=='function')throw new TypeError('Ban storage, authentication and rate limiting are required');
 const origins=new Set(adminOrigins);
 async function manage(request,env,origin,now) {
  if(origin&&!origins.has(origin))fail(403,'origin','Origin not allowed.');
  if(request.method==='OPTIONS'){
   if(!origin)fail(403,'origin','Origin not allowed.');
   return new Response(null,{status:204,headers:{
    'Access-Control-Allow-Origin':origin,'Access-Control-Allow-Methods':'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers':'Accept, Content-Type, X-Admin-Key','Cache-Control':'no-store','Vary':'Origin',
   }});
  }
  if(!['GET','POST'].includes(request.method))fail(405,'method','Method not allowed.');
  if(!await adminAuthenticated(request,env))fail(401,'admin_required','Unauthorized.');
  if(!await rateLimit(env,'admin',request.method))fail(429,'rate','Too many requests.');
  const body=request.method==='POST'?await readJson(request):null;
  const change=request.method==='POST'?parseChange(body):null;
  const record=await store.read(env),segment=openDocument(record);
  const reply=(sha,document,extra={})=>json({ok:true,sha,sourceSchema:document.schema,
   document:migrateBanDocument(document),source:store.label,...extra},200,origin);
  if(!change)return reply(record.sha,segment.document);
  const target=change.action==='upsert'?change.entry.userId:change.userId;
  if(!allowTarget(target,env))fail(403,'target_not_allowed','This environment accepts authorized test IDs only.');
  if(body.expectedSha!==record.sha)conflict();
  if(change.action==='upsert'){
   const expires=timeICT(change.entry.expiresAt);
   const existing=segment.document.entries.find(entry=>entry.userId===target);
   if(expires!==null&&expires<=now&&existing?.expiresAt!==change.entry.expiresAt)
    fail(400,'expired_entry','A new or changed end time must be in the future.');
  }
  let next;
  try{next=applyBanChange(segment.document,change,{preserveLegacy:true});}catch(error){
   if(change.action==='remove')fail(404,'not_found','Ban record does not exist.');
   fail(400,'invalid_change',error.message);
  }
  if(segment.document.schema===2&&JSON.stringify(next)===JSON.stringify(segment.document))
   return reply(record.sha,next,{saved:false,unchanged:true});
  const source=record.source.slice(0,segment.begin)+renderBanLua(next)+record.source.slice(segment.end);
  const result=await store.write(env,{source,expectedSha:record.sha,action:change.action,target,now});
  if(!result)conflict();
  return reply(result.sha,next,{saved:true,auditLogged:result.auditLogged!==false,commitSha:result.commitSha??null});
 }

 async function game(request,env,operation,now) {
  if(request.method!=='POST')fail(405,'method','Method not allowed.');
  const universe=await authorizeServer(request,env);
  if(!universe)fail(401,'server_required','Trusted Roblox server required.');
  const body=await readJson(request);
  const fields=['universeId','userId'];
  if(operation==='authorize')fields.push('feature');
  if(operation==='appeal')fields.push('noticeId','description');
  if(!exact(body,fields)||body.universeId!==universe||!validId(body.userId))invalid();
  if(!allowTarget(body.userId,env))fail(403,'target_not_allowed','This environment accepts authorized test IDs only.');
  if(!await rateLimit(env,operation,body.userId))fail(429,'rate','Too many requests.');
  const current=openDocument(await store.read(env));
  const policy=policyFor(current.document,body.userId,now);
  if(operation==='policy')return json({ok:true,identityVerified:true,subject:body.userId,...policy});
  if(operation==='authorize'&&!FEATURES.has(body.feature))invalid();
  const feature=operation==='authorize'?body.feature:operation;
  if(policy.state==='ban_ingame'||(policy.state==='restricted_mode'&&!LIMITED.has(feature)))
   fail(403,'ban_restricted','This feature is unavailable under the current ban.');
  if(operation==='authorize')return json({ok:true,allowed:true});
  if(operation==='violation' && typeof verifyHistory==='function')
   return verifyHistory(env,body.userId,now);
  if(operation==='appeal' && typeof submitAppeal==='function')
   return submitAppeal(env,body,now);
  fail(503,'feature_unavailable','Verified Violation and Appeal service is unavailable.');
 }

 return async (request,env={})=>{
  const url=new URL(request.url),origin=request.headers.get('Origin')||'';
  const admin=url.pathname===ADMIN_BANS;
  const operation=url.pathname.startsWith(GAME_BANS)?url.pathname.slice(GAME_BANS.length):null;
  try{
   if(url.search||(admin===false&&!GAME_ROUTES.has(operation)))fail(404,'route','Not found.');
   return admin?await manage(request,env,origin,clock()):await game(request,env,operation,clock());
  }catch(error){
   const e=error instanceof BanError?error:new BanError(503,'unavailable','Ban service unavailable. Refresh before trying again.');
   return json({ok:false,code:e.code,error:e.message},e.status,admin&&origins.has(origin)?origin:undefined);
  }
 };
}

export function openVerifiedHistory(env,subject,now) {
 return createVerifiedHistoryHandler({db:env.DB,clock:()=>now*1000,
  resolveVerifiedPrincipal:async()=>({verified:true,method:'trusted_game_server',sub:subject,expiresAt:now+30}),
 })(new Request('https://internal.invalid/api/v1/violation/history'));
}

export async function submitVerifiedAppeal(env,{userId,noticeId,description},now) {
 if(typeof noticeId!=='string'||!/^[-A-Za-z0-9_]{1,70}$/.test(noticeId)||
    typeof description!=='string'||Array.from(description.trim()).length<50||
    Array.from(description).length>5000||/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/.test(description))invalid();
 const DB=env.DB;
 const id=crypto.randomUUID();
 const receipt=hex(crypto.getRandomValues(new Uint8Array(32)).buffer);
 const hash=hex(await crypto.subtle.digest('SHA-256',enc.encode(receipt)));
 const [,,created]=await DB.batch([
  DB.prepare(`INSERT INTO asc_feedback_cases
   (id,receipt_hash,kind,claimed_user_id,topic,description,created_unix,updated_unix)
   SELECT ?,?,'appeal',?,'Violation appeal',?,?,?
   FROM asc_verified_violation_subjects
   WHERE notice_id=? AND subject_user_id=? AND (appeal_status='not_appealed'
    OR (appeal_status='denied' AND may_reappeal=1))`).bind(id,hash,userId,description.trim(),now,now,noticeId,userId),
  DB.prepare(`INSERT INTO asc_ban_v2_verified_appeals(case_id,notice_id,created_unix)
   SELECT id,?,? FROM asc_feedback_cases WHERE id=?`).bind(noticeId,now,id),
  DB.prepare('SELECT case_id FROM asc_ban_v2_verified_appeals WHERE case_id=?').bind(id),
 ]);
 if(created.results?.[0]?.case_id!==id)fail(409,'appeal_ineligible','Appeal is unavailable for this notice.');
 return json({ok:true,id,receipt,kind:'appeal',status:'reviewing'},201);
}
