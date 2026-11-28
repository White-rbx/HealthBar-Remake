/** ArcScriptCenter Feedback & Appeal: D1-backed, HMAC scoped limiter, REVIEW ONLY.
 * Requires a separately verified edge-ingress adapter. Never trust UserId/body/XFF.
 * HMAC secret stays in a private Worker binding; no raw IP stored in D1.
 */
const ENCODER=new TextEncoder();
export const QUOTAS=Object.freeze({network15m:6,networkDay:24,global15m:240,globalDay:4000});
export const CONSUME_SQL='INSERT INTO asc_feedback_rate_windows (scope_hash,window_start,hits,expires_unix) ' +
 'VALUES (?1,?2,1,?3) ON CONFLICT(scope_hash,window_start) DO UPDATE SET hits=hits+1 WHERE hits<?4 RETURNING hits';
function b64url(bytes){let s='';for(const x of bytes)s+=String.fromCharCode(x);return btoa(s).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/g,'');}
export function createReleaseFeedbackRateGuard({db,secret,verifyEdge,webcrypto=crypto,clock=()=>Date.now(),limits=QUOTAS}={}){
 if(!db?.prepare||typeof verifyEdge!=='function')throw TypeError('Trusted edge adapter and D1 binding required');
 if(typeof secret!=='string'||secret.length<32||secret.length>4096)throw TypeError('Private 32+ character HMAC secret required');
 for(const n of Object.keys(QUOTAS))if(!Number.isInteger(limits[n])||limits[n]<1||limits[n]>100000)throw TypeError('Invalid quota');
 const key=webcrypto.subtle.importKey('raw',ENCODER.encode(secret),{name:'HMAC',hash:'SHA-256'},false,['sign']);
 async function consume(secretKey,scope,period,limit,now){
  const start=Math.floor(now/period)*period;
  const signature=new Uint8Array(await webcrypto.subtle.sign('HMAC',secretKey,ENCODER.encode('ASC:FEEDBACK:LIMIT:v1:'+scope)));
  const digest=b64url(signature);
  if(!/^[a-zA-Z0-9_-]{43}$/.test(digest))throw Error('Malformed HMAC scope');
  const row=await db.prepare(CONSUME_SQL).bind(digest,start,start+period+86400,limit).first();
  return Number.isInteger(row?.hits)&&row.hits>=1&&row.hits<=limit;
 }
 return Object.freeze({
  async take(request){
   try {
    const edge=await verifyEdge(request);
    const network=edge?.networkId;
    if(edge?.verified!==true||typeof network!=='string'||network.length<3||network.length>128||/\s/.test(network))
      return {allowed:false,status:503,reason:'trusted-edge-unavailable'};
    const now=Math.floor(clock()/1000);
    if(!Number.isSafeInteger(now)||now<1)return {allowed:false,status:503,reason:'clock-unavailable'};
    const sk=await key;
    const scopes=[
     ['network:15m:'+network,900,limits.network15m],
     ['network:day:'+network,86400,limits.networkDay],
     ['global:15m',900,limits.global15m],
     ['global:day',86400,limits.globalDay]
    ];
    for(const [scope,period,limit] of scopes){
     if(!await consume(sk,scope,period,limit,now))return {allowed:false,status:429,reason:'rate-limited'};
    }
    return {allowed:true,status:200,reason:'accepted'};
   }catch{return {allowed:false,status:503,reason:'rate-unavailable'};}
  },
  async pruneExpired(){const now=Math.floor(clock()/1000);return db.prepare('DELETE FROM asc_feedback_rate_windows WHERE expires_unix<=?1').bind(now).run();}
 });
}
