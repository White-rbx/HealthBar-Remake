import {reservePairGatewayBudget} from './isolated-pairing-quota-candidate.mjs';

// Domain-separate credentials issued here from those issued by the protected website.
export const gatewayDigest = (kind, value) => sha('eslogin-qa:' + kind + ':' + value);

const prefix='/api/v1/accounts/';
const pairingLabel='ExperienceSettings QA Gateway';
const paths=new Set(['pair/start','pair/poll']);
const hex=value=>typeof value==='string'&&/^[0-9a-f]{64}$/.test(value);
const security={
 'Cache-Control':'private, no-store, max-age=0',
 'Pragma':'no-cache',
 'X-Content-Type-Options':'nosniff',
 'Referrer-Policy':'no-referrer',
 'X-Robots-Tag':'noindex, nofollow',
};
const response=(status,body)=>new Response(JSON.stringify(body),{
 status,headers:{...security,'Content-Type':'application/json; charset=utf-8'},
});
const reject=(status,code)=>response(status,{ok:false,code});
const success=data=>response(200,{ok:true,...data});
const nowSeconds=()=>Math.floor(Date.now()/1000);
const randomHex=bytes=>Array.from(crypto.getRandomValues(new Uint8Array(bytes)),
 b=>b.toString(16).padStart(2,'0')).join('');
const sha=async value=>{
 const bytes=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(value));
 return Array.from(new Uint8Array(bytes),x=>x.toString(16).padStart(2,'0')).join('');
};
export const gatewayActive=env=>env?.ASC_PAIR_GATEWAY_MODE==='isolated-qa'
 &&env.ASC_PAIR_GATEWAY_LAUNCH_STATE==='explicit-test-enabled'
 &&typeof env.PAIR_DB?.prepare==='function'&&typeof env.PAIR_DB?.batch==='function'
 &&typeof env.PAIR_RATE?.limit==='function';

// Accept only small JSON objects. No query parameters or cross-site browser requests.
async function readBody(request){
 if(!/^application\/json(?:\s*;|$)/i.test(request.headers.get('content-type')||''))return null;
 if(Number(request.headers.get('content-length')||0)>512)return null;
 let body='', bytes=0;
 const decoder=new TextDecoder();
 const reader=request.body?.getReader();
 if(!reader)return null;
 try{
  while(true){
   const {done,value}=await reader.read();
   if(done)break;
   bytes+=value.byteLength;
   if(bytes>512)return null;
   body+=decoder.decode(value,{stream:true});
  }
  body+=decoder.decode();
 }finally{try{await reader.cancel()}catch{}}
 try{
  const parsed=JSON.parse(body);
  if(!parsed||typeof parsed!=='object'||Array.isArray(parsed))return null;
  return parsed;
 }catch{return null}
}
const exactKeys=(body,allowed)=>Object.keys(body).every(key=>allowed.includes(key));

export function createPairingGatewayCandidate({
 origin='https://pairing.qa.invalid',clock=nowSeconds,
}={}){
 if(!origin.startsWith('https://')||new URL(origin).origin!==origin)
  throw new Error('Explicit HTTPS Gateway origin required');
 return {async fetch(request,env={}){
  const url=new URL(request.url);
  if(url.origin!==origin||url.search||url.hash||request.method!=='POST'
   ||!url.pathname.startsWith(prefix))return reject(404,'not_found');
  const op=url.pathname.slice(prefix.length);
  if(!paths.has(op))return reject(404,'not_found');
  if(!gatewayActive(env))return reject(503,'pairing_gateway_locked');
  // The gateway is not a browser API. No authenticated website route is proxied.
  if(request.headers.has('origin')||request.headers.has('cookie')
   ||request.headers.has('authorization')||
   [...request.headers.keys()].some(k=>k.startsWith('cf-access-')))
   return reject(403,'forbidden');
  const body=await readBody(request);
  if(!body)return reject(400,'invalid_input');
  if(op==='pair/start'&&!exactKeys(body,[]))return reject(400,'invalid_input');
  if(op==='pair/poll'&&(!exactKeys(body,['secret'])||
   !hex(body.secret)))
   return reject(400,'invalid_input');

  // Cloudflare's edge-supplied IP is used only as an ephemeral throttle key;
  // never as identity, never persisted as an account field or a session.
  const ip=request.headers.get('CF-Connecting-IP')||'unknown';
  const limits=op==='pair/start'
   ?['pair:gateway:ip:'+ip,'pair:gateway:start:global']
   :['pair:gateway:ip:'+ip,'pair:gateway:poll:global'];
  const db=env.PAIR_DB,now=clock();
  try{
   for(const key of limits){
    const result=await env.PAIR_RATE.limit({key});
    if(result?.success!==true)return reject(429,'rate_limited');
   }
   const budget=await reservePairGatewayBudget(env,op,now);
   if(!budget.allowed)return reject(budget.status,budget.status===429?'rate_limited':'pairing_unavailable');
   if(op==='pair/start'){
    const secret=randomHex(32),code=randomHex(6).toUpperCase();
    await db.prepare('DELETE FROM asc_account_pairings WHERE expires_at<=? AND label=?').bind(now,pairingLabel).run();
    await db.prepare('INSERT INTO asc_account_pairings(code,digest,expires_at,label) VALUES(?,?,?,?)')
     .bind(code,await gatewayDigest('pair',secret),now+300,pairingLabel).run();
    return success({code,secret,expiresAt:now+300});
   }
   const digest=await gatewayDigest('pair',body.secret);
   const pair=await db.prepare('SELECT account_id,claimed_session_id,expires_at FROM asc_account_pairings WHERE digest=?')
    .bind(digest).first();
   if(!pair||pair.expires_at<=now||pair.claimed_session_id)return reject(410,'session_expired');
   if(!pair.account_id)return success({state:'pending'});
   // Same atomic, single-consumer session claim as the protected Worker.
   // No browser identity can be supplied by the anonymous caller.
   const session=randomHex(32),id=crypto.randomUUID(),ttl=14400;
   const [issued]=await db.batch([
    db.prepare(`INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at)
      SELECT ?1,p.account_id,?2,'loader',?3,?4 FROM asc_account_pairings p
      JOIN asc_account_sessions s ON s.id=p.authorizing_session_id AND s.account_id=p.account_id
      WHERE p.digest=?5 AND p.expires_at>?3 AND p.claimed_session_id IS NULL
       AND s.scope='web' AND s.revoked_at IS NULL AND s.expires_at>?3
      RETURNING account_id`).bind(id,await gatewayDigest('session',session),now,now+ttl,digest),
    db.prepare('UPDATE asc_account_pairings SET claimed_session_id=?1 WHERE digest=?2 AND EXISTS(SELECT 1 FROM asc_account_sessions WHERE id=?1)')
     .bind(id,digest),
   ]);
   if(!issued?.results?.length)return reject(410,'session_expired');
   return success({state:'ready',session,expiresAt:now+ttl});
  }catch{
   // Never expose SQL exceptions, body, code, secret, or account details.
   return reject(503,'pairing_unavailable');
  }
 }};
}
