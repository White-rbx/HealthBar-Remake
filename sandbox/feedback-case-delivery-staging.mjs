/**
 * ArcScriptCenter — active-client Case Delivery, STAGING REVIEW ONLY.
 * This module registers NOTHING by import. Mount only after reviewed OAuth
 * browser confirmation + a short-lived, server-issued DEVICE session verifier.
 * Never authorize via LocalPlayer.UserId, claimed_user_id, headers or an
 * "active" analytics record. A request from a verified active client polls.
 *
 * Routes: POST /api/v1/client/cases/poll  body {}
 *         POST /api/v1/client/cases/link  body {id,receipt}
 * Independent of Analytics / Active User counts and Admin dashboard.
 */
export const CASE_DELIVERY_POLL='/api/v1/client/cases/poll';
export const CASE_DELIVERY_LINK='/api/v1/client/cases/link';
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const RECEIPT=/^[a-f0-9]{64}$/i;
const SUBJECT=/^[a-zA-Z0-9._:-]{1,128}$/;
const VALID_STATE=new Set(['reviewing','approved','denied','violation','spam_mail']);
const H={
 'Content-Type':'application/json; charset=utf-8',
 'Cache-Control':'private, no-store',
 'X-Content-Type-Options':'nosniff',
 'Referrer-Policy':'no-referrer',
 'Vary':'Authorization'
};
const result=(data,status=200)=>new Response(JSON.stringify(data),{status,headers:H});
const nowUnix=()=>Math.floor(Date.now()/1000);
const safePrincipal=(p,now)=>p?.verified===true&&p?.active===true
 && p?.method==='roblox_oidc_device_verified'
 && typeof p.subject==='string'&&SUBJECT.test(p.subject)
 && Number.isSafeInteger(p.expiresAt)&&p.expiresAt>now&&p.expiresAt<=now+3600
 && p.scope==='cases:read'
 ?p.subject:null;
async function bodyJson(request,maximum=300){
 if(!/^application\/json(?:;\s*charset=utf-8)?$/i.test(request.headers.get('content-type')||''))
  return null;
 const raw=await request.text();
 if(raw.length>maximum)return null;
 try{
  const obj=JSON.parse(raw);
  return obj&&typeof obj==='object'&&!Array.isArray(obj)?obj:null;
 }catch{return null;}
}
async function digest(receipt){
 const bytes=new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(receipt)));
 return Array.from(bytes,x=>x.toString(16).padStart(2,'0')).join('');
}
const cleanCase=row=>({
 id:row.id,kind:'feedback',
 status:row.status==='spam_mail'?'reviewing':(VALID_STATE.has(row.status)?row.status:'reviewing'),
 topic:String(row.topic||'').slice(0,50),
 updatedAt:Number(row.updated_unix)||0,
 revision:Number(row.revision)||0,
 publicNote:row.status==='spam_mail'?'':String(row.public_note||'').slice(0,800)
});
/**
 * resolveActivePrincipal MUST validate a server-minted, short-lived device
 * token derived from independently verified Roblox OAuth subject and an
 * explicit pairing ceremony. Never accept a self-reported subject.
 * checkRateLimit MUST use an independent server-enforced bucket.
 */
export function createCaseDeliveryHandler({resolveActivePrincipal,checkRateLimit,clock=nowUnix}={}){
 if(typeof resolveActivePrincipal!=='function'||typeof checkRateLimit!=='function')
  throw new TypeError('Trusted session verifier and distributed limiter required');
 return async function handleCaseDelivery(request,env){
  let url;
  try{url=new URL(request.url);}catch{return result({ok:false},404);}
  if(url.search||url.hash||url.username||url.password
     ||![CASE_DELIVERY_POLL,CASE_DELIVERY_LINK].includes(url.pathname))
   return result({ok:false},404);
  if(request.method!=='POST')return result({ok:false,error:'Method not allowed'},405);
  if(request.headers.has('cookie'))return result({ok:false,error:'Client device session required'},401);
  let principal;
  try{principal=await resolveActivePrincipal(request,env);}
  catch{return result({ok:false,error:'Session verifier unavailable'},503);}
  const current=clock();
  const subject=safePrincipal(principal,current);
  if(!subject)return result({ok:false,error:'Verified active session required'},401);
  try{
   const allowed=await checkRateLimit({subject,action:url.pathname===CASE_DELIVERY_POLL?'poll':'link',request,env});
   if(allowed!==true)return result({ok:false,error:'Too many requests'},429);
  }catch{return result({ok:false,error:'Rate limiter unavailable'},503);}
  const body=await bodyJson(request);
  if(!body)return result({ok:false,error:'Invalid JSON'},400);
  if(!env?.DB||typeof env.DB.prepare!=='function')
   return result({ok:false,error:'Database unavailable'},503);

  if(url.pathname===CASE_DELIVERY_POLL){
   if(Object.keys(body).length!==0)return result({ok:false,error:'Unexpected fields'},400);
   try{
    const sql="SELECT c.id,c.kind,c.status,c.topic,c.updated_unix,c.revision,c.public_note "
      +"FROM asc_feedback_case_owners o JOIN asc_feedback_cases c ON c.id=o.case_id "
      +"WHERE o.owner_sub=? AND c.kind='feedback' AND c.removed=0 "
      +"ORDER BY c.updated_unix DESC,c.id ASC LIMIT 30";
    const query=await env.DB.prepare(sql).bind(subject).all();
    const rows=(query.results||[]).map(cleanCase);
    return result({ok:true,serverVerified:true,delivery:'active-poll',cases:rows});
   }catch{return result({ok:false,error:'Case delivery unavailable'},503);}
  }
  if(Object.keys(body).length!==2||!Object.hasOwn(body,'id')
     ||!Object.hasOwn(body,'receipt')||typeof body.id!=='string'
     ||!UUID.test(body.id)||typeof body.receipt!=='string'
     ||!RECEIPT.test(body.receipt))
   return result({ok:false,error:'Invalid case credentials'},400);
  try{
   const hashed=await digest(body.receipt);
   // Claim only with BOTH verified account session and receipt possession.
   // No match on claimed_user_id. No reassignment of an existing owner.
   const sql="INSERT OR IGNORE INTO asc_feedback_case_owners (case_id,owner_sub,linked_unix,proof_type) "
    +"SELECT id,?,?, 'verified_session_and_receipt' FROM asc_feedback_cases "
    +"WHERE id=? AND receipt_hash=? AND kind='feedback' AND removed=0";
   await env.DB.prepare(sql).bind(subject,current,body.id,hashed).run();
   const owner=await env.DB.prepare(
    "SELECT owner_sub FROM asc_feedback_case_owners WHERE case_id=?").bind(body.id).first();
   // Deliberately indistinguishable: invalid/removed receipt or linked to another account.
   if(!owner||owner.owner_sub!==subject)
    return result({ok:false,error:'Case could not be linked'},404);
   return result({ok:true,linked:true});
  }catch{return result({ok:false,error:'Case linking unavailable'},503);}
 };
}
