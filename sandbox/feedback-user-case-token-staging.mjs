/**
 * ArcScriptCenter — User Case Token (STAGING).
 * An opt-in, revocable bearer capability for previously submitted Feedback.
 * This is NOT Roblox identity verification, a device fingerprint, or an OIDC session.
 * Possession of the token authorizes only the public-facing Feedback case list.
 * Never use claimed_user_id / username / HWID / IP as ownership proof.
 *
 * POST /api/v1/client/user-case-token/create {id,receipt,consent:true}
 * POST /api/v1/client/user-case-token/attach {token,id,receipt}
 * POST /api/v1/client/user-case-token/list   {token,after?}
 * POST /api/v1/client/user-case-token/revoke {token,confirm:true}
 *
 * Every route MUST be mounted behind a genuine independent rate limiter.
 * Server stores SHA-256 token hash ONLY. Token is displayed exactly once.
 */
export const CASE_TOKEN_ROUTES=Object.freeze({
 create:'/api/v1/client/user-case-token/create',
 attach:'/api/v1/client/user-case-token/attach',
 list:'/api/v1/client/user-case-token/list',
 revoke:'/api/v1/client/user-case-token/revoke',
});
const TOKEN_RE=/^USERCASETOKEN_01_[A-Za-z0-9_-]{43}-[a-f0-9]{8}$/;
const RECEIPT_RE=/^[a-f0-9]{64}$/i;
const UUID_RE=/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i;
const STATES=new Set(['reviewing','approved','denied','violation','spam_mail']);
const HEADERS={
 'Content-Type':'application/json; charset=utf-8','Cache-Control':'private, no-store',
 'Referrer-Policy':'no-referrer','X-Content-Type-Options':'nosniff',
 'X-Frame-Options':'DENY','Vary':'Origin'
};
const respond=(data,status=200)=>new Response(JSON.stringify(data),{status,headers:HEADERS});
function exact(body,keys){
 return body && !Array.isArray(body) && typeof body==='object'
   && Object.keys(body).length===keys.length
   && keys.every(k=>Object.hasOwn(body,k));
}
async function readJSON(request,limit=4096){
 if(!/^application\/json(?:\s*;\s*charset=utf-8)?$/i.test(request.headers.get('content-type')||''))return null;
 if(Number(request.headers.get('content-length'))>limit)return null;
 if(!request.body)return null;
 const reader=request.body.getReader(),chunks=[];let length=0;
 try{
  for(;;){
   const {done,value}=await reader.read();if(done)break;
   length+=value.byteLength;if(length>limit){await reader.cancel();return null;}
   chunks.push(value);
  }
 }finally{reader.releaseLock();}
 const all=new Uint8Array(length);let offset=0;
 for(const chunk of chunks){all.set(chunk,offset);offset+=chunk.byteLength;}
 try{
  const parsed=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(all));
  return parsed && typeof parsed==='object'&&!Array.isArray(parsed)?parsed:null;
 }catch{return null;}
}
function hex(bytes){return Array.from(bytes,x=>x.toString(16).padStart(2,'0')).join('');}
function base64url(bytes){
 let bin='';for(const x of bytes)bin+=String.fromCharCode(x);
 return btoa(bin).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
}
async function sha(text){
 const digest=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(text));
 return hex(new Uint8Array(digest));
}
async function issueToken(){
 const random=crypto.getRandomValues(new Uint8Array(32));
 const core='USERCASETOKEN_01_'+base64url(random);
 return core+'-'+(await sha(core)).slice(0,8);
}
async function hashedToken(token){
 if(typeof token!=='string'||!TOKEN_RE.test(token))return null;
 const core=token.slice(0,-9);
 if((await sha(core)).slice(0,8)!==token.slice(-8))return null;
 return sha(token);
}
const validId=id=>typeof id==='string'&&UUID_RE.test(id);
const validCase=(id,receipt)=>validId(id)
 &&typeof receipt==='string'&&RECEIPT_RE.test(receipt);
const safeCase=row=>({
 id:row.id,kind:'feedback',status:row.status==='spam_mail'?'reviewing'
   :(STATES.has(row.status)?row.status:'reviewing'),
 topic:String(row.topic||'').slice(0,50),
 publicNote:row.status==='spam_mail'?'':String(row.public_note||'').slice(0,800),
 updatedAt:Number(row.updated_unix)||0,revision:Number(row.revision)||0,
});
async function validReceiptCase(db,id,receipt){
 return db.prepare("SELECT id FROM asc_feedback_cases WHERE id=? AND receipt_hash=? AND kind='feedback' AND removed=0 LIMIT 1")
  .bind(id,await sha(receipt)).first();
}
async function liveToken(db,hash){
 return db.prepare('SELECT token_hash FROM asc_user_case_tokens WHERE token_hash=? AND revoked_unix IS NULL LIMIT 1')
  .bind(hash).first();
}
const tokenNotFound=()=>respond({ok:false,code:'token_not_found',error:'Token not found'},404);
const LINK_SQL=`INSERT INTO asc_user_case_links(case_id,token_hash,linked_unix)
 SELECT c.id,t.token_hash,? FROM asc_feedback_cases c CROSS JOIN asc_user_case_tokens t
 WHERE c.id=? AND c.receipt_hash=? AND c.kind='feedback' AND c.removed=0
   AND t.token_hash=? AND t.revoked_unix IS NULL
 ON CONFLICT(case_id) DO UPDATE SET token_hash=excluded.token_hash,linked_unix=excluded.linked_unix
 WHERE asc_user_case_links.token_hash=excluded.token_hash OR EXISTS (
   SELECT 1 FROM asc_user_case_tokens old
   WHERE old.token_hash=asc_user_case_links.token_hash AND old.revoked_unix IS NOT NULL
 )`;
function changed(result){return Number(result?.meta?.changes)===1;}
/**
 * checkRateLimit MUST be a real, fail-closed server-side network limiter.
 * Token is intentionally NOT sent to the limiter callback or logged.
 */
export function createUserCaseTokenHandler({checkRateLimit,clock=()=>Math.floor(Date.now()/1000)}={}){
 if(typeof checkRateLimit!=='function')throw new TypeError('Distributed rate limiter required');
 return async function handleUserCaseToken(request,env){
  let url;try{url=new URL(request.url);}catch{return respond({ok:false},404);}
  const action=Object.entries(CASE_TOKEN_ROUTES).find(([,path])=>path===url.pathname)?.[0];
  if(!action||url.search||url.hash||url.username||url.password)return respond({ok:false},404);
  if(request.method!=='POST')return respond({ok:false,error:'Method not allowed'},405);
  // Never accept browser cookies, token-bearing query strings or browser cross-site posts.
  if(request.headers.has('cookie')||request.headers.has('origin'))
   return respond({ok:false,error:'Unsupported request context'},403);
  try{
   if(await checkRateLimit({action,request,env})!==true)
    return respond({ok:false,error:'Too many requests'},429);
  }catch{return respond({ok:false,error:'Rate limiter unavailable'},503);}
  const body=await readJSON(request).catch(()=>null);
  if(!body)return respond({ok:false,error:'Invalid request'},400);
  if(typeof env?.DB?.prepare!=='function')return respond({ok:false,error:'Database unavailable'},503);
  const db=env.DB,now=clock();
  if(!Number.isSafeInteger(now)||now<1)return respond({ok:false,error:'Clock unavailable'},503);
  try{
   if(action==='create'){
    if(!exact(body,['id','receipt','consent'])||body.consent!==true
       ||!validCase(body.id,body.receipt))
     return respond({ok:false,error:'Explicit consent and private Case ID + Receipt required'},400);
    if(!await validReceiptCase(db,body.id,body.receipt))
     return respond({ok:false,error:'Case not found'},404);
    const token=await issueToken(),hash=await sha(token);
    const [,linked]=await db.batch([
     db.prepare('INSERT INTO asc_user_case_tokens(token_hash,created_unix,revoked_unix) VALUES(?,?,NULL)')
       .bind(hash,now),
     db.prepare(LINK_SQL).bind(now,body.id,await sha(body.receipt),hash),
     db.prepare('DELETE FROM asc_user_case_tokens WHERE token_hash=? AND NOT EXISTS '
       +'(SELECT 1 FROM asc_user_case_links WHERE token_hash=?)').bind(hash,hash),
    ]);
    if(!changed(linked))
     return respond({ok:false,error:'Case already linked or no longer available'},409);
    return respond({ok:true,token,tokenVersion:1,revocable:true,
      expiresAt:null,linkedCaseId:body.id,showOnlyOnce:true,identityVerified:false},201);
   }
   if(action==='list'){
    if(!exact(body,['token'])&&!(exact(body,['token','after'])&&validId(body.after)))
     return respond({ok:false,error:'Invalid request'},400);
    const hash=await hashedToken(body.token);
    if(!hash)return tokenNotFound();
    // Start at the live token so an empty successful page is distinct from
    // a revoked token, even if revocation races the list request.
    const sql=`SELECT c.id,c.kind,c.status,c.topic,c.public_note,c.updated_unix,c.revision
      FROM asc_user_case_tokens t LEFT JOIN (
        SELECT c.id,c.kind,c.status,c.topic,c.public_note,c.updated_unix,c.revision,l.token_hash
        FROM asc_user_case_links l JOIN asc_feedback_cases c ON c.id=l.case_id
        WHERE l.token_hash=? AND l.case_id>? AND c.kind='feedback' AND c.removed=0
        ORDER BY l.case_id LIMIT 31
      ) c ON c.token_hash=t.token_hash
      WHERE t.token_hash=? AND t.revoked_unix IS NULL ORDER BY c.id`;
    const {results=[]}=await db.prepare(sql).bind(hash,body.after??'',hash).all();
    if(results.length===0)return tokenNotFound();
    const cases=results.filter(row=>row.id!==null).slice(0,30).map(safeCase);
    return respond({ok:true,tokenAccepted:true,identityVerified:false,delivery:'user-case-token',
      cases,nextCursor:results.length>30?cases.at(-1).id:null});
   }
   if(action==='attach'){
    if(!exact(body,['token','id','receipt'])||!validCase(body.id,body.receipt))
     return respond({ok:false,error:'Invalid request'},400);
    const hash=await hashedToken(body.token);
    if(!hash)return tokenNotFound();
    const linked=await db.prepare(LINK_SQL).bind(now,body.id,await sha(body.receipt),hash).run();
    if(!changed(linked)){
     if(!await liveToken(db,hash))return tokenNotFound();
     if(!await validReceiptCase(db,body.id,body.receipt))
      return respond({ok:false,error:'Case not found'},404);
     return respond({ok:false,error:'Case already linked to a different token'},409);
    }
    return respond({ok:true,linked:true});
   }
   if(!exact(body,['token','confirm'])||body.confirm!==true)
    return respond({ok:false,error:'Explicit revoke confirmation required'},400);
   const hash=await hashedToken(body.token);
   if(!hash)return tokenNotFound();
   const revoked=await db.prepare(
    'UPDATE asc_user_case_tokens SET revoked_unix=? WHERE token_hash=? AND revoked_unix IS NULL'
   ).bind(now,hash).run();
   if(!changed(revoked))return tokenNotFound();
   // Keep case links for audit; revoked token cannot list or attach any case.
   return respond({ok:true,revoked:true,irreversible:true});
  }catch{
   return respond({ok:false,error:'Case Token service unavailable'},503);
  }
 };
}
