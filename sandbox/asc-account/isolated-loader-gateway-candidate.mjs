// Stage 7 — UNDEPLOYED server-verified Loader transport for a separate QA gateway.
// No default export, routing, public Access rule, Cloudflare secret or actual deployment.
// Roblox clients get an opaque, scoped loader token ONLY after browser-approved pairing.
// Protected browser Passkey / MyAccount remains behind Cloudflare Access.
import {createPairingGatewayCandidate} from './isolated-pairing-gateway-candidate.mjs';
import {accountProfile} from './moderation.mjs';

const api='/api/v1/accounts/';
const pairPaths=new Set(['pair/start','pair/poll']);
const sessionPaths=new Set(['session','heartbeat','logout']);
const headers={
 'Cache-Control':'private, no-store, max-age=0',
 'X-Content-Type-Options':'nosniff',
 'X-Frame-Options':'DENY',
 'Referrer-Policy':'no-referrer',
 'X-Robots-Tag':'noindex, nofollow',
};
const result=(status,body)=>Response.json(body,{status,headers});
const fail=(status,code)=>result(status,{ok:false,code});
const ok=payload=>result(200,{ok:true,...payload});
const stamp=()=>Math.floor(Date.now()/1000);
const sha=async text=>{
 const hash=new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(text)));
 return Array.from(hash,x=>x.toString(16).padStart(2,'0')).join('');
};
const active=env=>env?.ASC_PAIR_GATEWAY_MODE==='isolated-qa'
 &&env.ASC_PAIR_GATEWAY_LAUNCH_STATE==='explicit-test-enabled'
 &&typeof env.PAIR_DB?.prepare==='function'
 &&typeof env.PAIR_DB?.batch==='function'
 &&typeof env.PAIR_RATE?.limit==='function';
async function emptyJson(request){
 if(!/^application\/json(?:\s*;|$)/i.test(request.headers.get('content-type')||''))return false;
 if(Number(request.headers.get('content-length')||0)>64)return false;
 const reader=request.body?.getReader();
 if(!reader)return false;
 let text='';
 try{
  while(true){
   const {done,value}=await reader.read();
   if(done)break;
   if(!(value instanceof Uint8Array)||text.length+value.length>64)return false;
   text+=new TextDecoder().decode(value);
  }
 }finally{try{await reader.cancel()}catch{}}
 try{
  const json=JSON.parse(text);
  return json!==null&&typeof json==='object'&&!Array.isArray(json)
   &&Object.keys(json).length===0;
 }catch{return false}
}

export function createLoaderGatewayCandidate({
 origin='https://pairing.qa.invalid',clock=stamp,
}={}){
 const pairing=createPairingGatewayCandidate({origin,clock});
 return {async fetch(request,env={}){
  const url=new URL(request.url);
  if(url.origin!==origin||request.method!=='POST'||url.search||url.hash
   ||!url.pathname.startsWith(api))return fail(404,'not_found');
  const op=url.pathname.slice(api.length);
  if(pairPaths.has(op))return pairing.fetch(request,env);
  if(!sessionPaths.has(op))return fail(404,'not_found');
  if(!active(env))return fail(503,'pairing_gateway_locked');

  // This is NOT Cloudflare Access browser authentication.
  // No Cookie, Origin or Access service token accepted from a Luau client.
  if(request.headers.has('Origin')||request.headers.has('Cookie')||
   [...request.headers.keys()].some(key=>key.startsWith('cf-access-')))
   return fail(403,'forbidden');
  const bearer=(request.headers.get('Authorization')||'').match(/^Bearer ([0-9a-f]{64})$/)?.[1];
  if(!bearer)return fail(401,'session_expired');
  if(!await emptyJson(request))return fail(400,'invalid_input');

  const limiter=env.PAIR_RATE,now=clock(),db=env.PAIR_DB;
  const digest=await sha(bearer);
  const ip=request.headers.get('CF-Connecting-IP')||'unknown';
  for(const key of ['loader:'+op+':ip:'+ip,'loader:'+op+':session:'+digest]){
   const limited=await limiter.limit({key});
   if(limited?.success!==true)return fail(429,'rate_limited');
  }
  try{
   const account=await db.prepare(`
    SELECT a.*,s.id AS session_id,s.scope,s.expires_at
    FROM asc_account_sessions s JOIN asc_accounts a ON a.id=s.account_id
    WHERE s.digest=?1 AND s.scope='loader' AND s.revoked_at IS NULL AND s.expires_at>?2
   `).bind(digest,now).first();
   if(!account)return fail(401,'session_expired');
   if(op==='session')return ok({account:accountProfile(account),expiresAt:account.expires_at});
   if(op==='logout'){
    await db.prepare('UPDATE asc_account_sessions SET revoked_at=? WHERE id=?')
     .bind(now,account.session_id).run();
    return ok();
   }
   const current=await db.prepare(`
    UPDATE asc_account_sessions SET last_seen=?1
    WHERE id=?2 AND revoked_at IS NULL AND expires_at>?1
    AND EXISTS (SELECT 1 FROM asc_accounts WHERE id=?3 AND status<>'banned')
    RETURNING id
   `).bind(now,account.session_id,account.id).first();
   return current?ok({account:accountProfile(account)}):fail(403,'account_banned');
  }catch{
   // Never include DB errors or credentials in a public error response.
   return fail(503,'pairing_unavailable');
  }
 }};
}
