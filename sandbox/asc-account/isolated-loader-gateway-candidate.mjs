import {createPairingGatewayCandidate,gatewayActive,gatewayDigest} from './isolated-pairing-gateway-candidate.mjs';
import {reservePairGatewayBudget} from './isolated-pairing-quota-candidate.mjs';

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
// Only return fields required to continue the Loader and apply UI policy.
const loaderProfile=({id,nickname,status})=>({id,nickname,status});
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
  if(!gatewayActive(env))return fail(503,'pairing_gateway_locked');

  // This is NOT Cloudflare Access browser authentication.
  // No Cookie, Origin or Access service token accepted from a Luau client.
  if(request.headers.has('Origin')||request.headers.has('Cookie')||
   [...request.headers.keys()].some(key=>key.startsWith('cf-access-')))
   return fail(403,'forbidden');
  const bearer=(request.headers.get('Authorization')||'').match(/^Bearer ([0-9a-f]{64})$/)?.[1];
  if(!bearer)return fail(401,'session_expired');
  if(!await emptyJson(request))return fail(400,'invalid_input');

  const limiter=env.PAIR_RATE,now=clock(),db=env.PAIR_DB;
  const digest=await gatewayDigest('session',bearer);
  const ip=request.headers.get('CF-Connecting-IP')||'unknown';
  try{
   for(const key of ['loader:'+op+':ip:'+ip,'loader:'+op+':session:'+digest]){
    const limited=await limiter.limit({key});
    if(limited?.success!==true)return fail(429,'rate_limited');
   }
   const budget=await reservePairGatewayBudget(env,op,now);
   if(!budget.allowed)return fail(budget.status,budget.status===429?'rate_limited':'pairing_unavailable');
   const account=await db.prepare(`
    SELECT a.id,a.nickname,a.status,s.id AS session_id,s.expires_at
    FROM asc_account_sessions s JOIN asc_accounts a ON a.id=s.account_id
    WHERE s.digest=?1 AND s.scope='loader' AND s.revoked_at IS NULL AND s.expires_at>?2
   `).bind(digest,now).first();
   if(!account)return fail(401,'session_expired');
   if(op==='session')return ok({account:loaderProfile(account),expiresAt:account.expires_at});
   if(op==='logout'){
    await db.prepare('UPDATE asc_account_sessions SET revoked_at=? WHERE id=?')
     .bind(now,account.session_id).run();
    return ok();
   }
   const current=await db.prepare(`
    UPDATE asc_account_sessions SET last_seen=?1
    WHERE id=?2 AND revoked_at IS NULL AND expires_at>?1
    AND EXISTS (SELECT 1 FROM asc_accounts WHERE id=?3 AND status<>'banned')
    RETURNING (SELECT status FROM asc_accounts WHERE id=?3) AS account_status
   `).bind(now,account.session_id,account.id).first();
   return current?ok({account:loaderProfile({...account,status:current.account_status})}):fail(403,'account_banned');
  }catch{
   // Never include DB errors or credentials in a public error response.
   return fail(503,'pairing_unavailable');
  }
 }};
}
