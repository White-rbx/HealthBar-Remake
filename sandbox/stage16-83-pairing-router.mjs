/**
 * Stage16.83 HTTP contract: offline sandbox routes ONLY; not mounted/deployed.
 * No credentialed CORS. All credentialed browser operations require same Origin.
 * Untrusted clients may only start/poll/cancel a NON-PRIVILEGED pairing ceremony.
 * A deployment MUST supply a real distributed rate limiter, no bypass fallback.
 */
const HEADERS={
  'Cache-Control':'no-store, private',
  'Referrer-Policy':'no-referrer',
  'X-Content-Type-Options':'nosniff',
  'X-Frame-Options':'DENY',
  'Content-Security-Policy':"default-src 'none'; frame-ancestors 'none'; base-uri 'none'",
  'Content-Type':'application/json; charset=utf-8',
};
const ROUTES={
  '/pair/start':'start',
  '/pair/poll':'poll',
  '/pair/cancel':'cancel',
  '/pair/browser/preview':'preview',
  '/pair/browser/approve':'approve',
};
function reply(data,status=200) {
  return new Response(JSON.stringify(data),{status,headers:HEADERS});
}
async function strictJson(request) {
  const contentType=request.headers.get('content-type')||'';
  if(!/^application\/json(?:\s*;\s*charset=utf-8)?$/i.test(contentType)) throw new Error('type');
  const length=Number(request.headers.get('content-length'));
  if(Number.isFinite(length)&&length>512) throw new Error('large');
  if(!request.body) throw new Error('empty');
  const reader=request.body.getReader();
  let total=0;
  const chunks=[];
  try {
    for(;;){
      const {done,value}=await reader.read();
      if(done) break;
      total+=value.length;
      if(total>512) {await reader.cancel();throw new Error('large');}
      chunks.push(value);
    }
  } finally {reader.releaseLock();}
  const all=new Uint8Array(total);
  let offset=0;
  for(const chunk of chunks) {all.set(chunk,offset);offset+=chunk.length;}
  const parsed=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(all));
  if(!parsed||typeof parsed!=='object'||Array.isArray(parsed)) throw new Error('json');
  return parsed;
}
function onlyFields(body,keys) {
  return Object.keys(body).every(k=>keys.includes(k));
}
function browserOriginMatches(request,publicOrigin) {
  if(request.headers.get('origin')!==publicOrigin)return false;
  const site=request.headers.get('sec-fetch-site');
  return !site || site==='same-origin';
}
export function createStage1683PairingRouter({ceremony,publicOrigin,checkRateLimit}={}) {
  if(!ceremony||['start','poll','cancel','preview','approve'].some(k=>typeof ceremony[k]!=='function')) {
    throw new TypeError('Pairing ceremony required');
  }
  if(typeof checkRateLimit!=='function')throw new TypeError('Distributed rate limiter required');
  const origin=new URL(publicOrigin);
  if(origin.protocol!=='https:'||origin.origin!==publicOrigin||origin.username||origin.password) {
    throw new TypeError('Exact HTTPS public origin required');
  }
  return async function pairingRouter(request) {
    let url;
    try {url=new URL(request.url);} catch{return reply({ok:false,error:'Bad Request'},400);}
    if(url.origin!==publicOrigin||url.search||url.hash||url.username||url.password) {
      return reply({ok:false,error:'Bad Request'},400);
    }
    const action=ROUTES[url.pathname];
    if(!action) return reply({ok:false,error:'Not Found'},404);
    if(request.method!=='POST')return reply({ok:false,error:'Method Not Allowed'},405);
    const browser=action==='preview'||action==='approve';
    if(browser&&!browserOriginMatches(request,publicOrigin))return reply({ok:false,error:'Forbidden'},403);
    let allowed=false;
    try {allowed=await checkRateLimit({action,request});}
    catch {return reply({ok:false,error:'Rate limiter unavailable'},503);}
    if(allowed!==true)return reply({ok:false,error:'Too Many Requests'},429);
    let body;
    try {body=await strictJson(request);}
    catch {return reply({ok:false,error:'Invalid request'},400);}
    try {
      if(action==='start') {
        if(!onlyFields(body,[]))return reply({ok:false,error:'Invalid request'},400);
        const record=await ceremony.start();
        return reply({ok:true,pairingCode:record.pairingCode,
          pollToken:record.pollToken,expiresIn:record.expiresIn,verificationPath:record.verificationPath},201);
      }
      if(action==='poll') {
        if(!onlyFields(body,['pollToken'])||typeof body.pollToken!=='string')return reply({ok:false,error:'Invalid request'},400);
        const result=await ceremony.poll({pollToken:body.pollToken});
        return reply({ok:result.state!=='invalid',state:result.state});
      }
      if(action==='cancel') {
        if(!onlyFields(body,['pollToken'])||typeof body.pollToken!=='string')return reply({ok:false,error:'Invalid request'},400);
        const result=await ceremony.cancel({pollToken:body.pollToken});
        return reply({ok:result.ok});
      }
      if(action==='preview') {
        if(!onlyFields(body,['code'])||typeof body.code!=='string')return reply({ok:false,error:'Invalid request'},400);
        const result=await ceremony.preview({request,code:body.code});
        if(!result.ok)return reply({ok:false,error:'Pairing unavailable'},403);
        return reply(result);
      }
      if(!onlyFields(body,['code','confirmationToken'])||
         typeof body.code!=='string'||typeof body.confirmationToken!=='string') {
        return reply({ok:false,error:'Invalid request'},400);
      }
      const result=await ceremony.approve({request,code:body.code,confirmationToken:body.confirmationToken});
      return result.ok?reply({ok:true,approved:true}):reply({ok:false,error:'Pairing unavailable'},403);
    } catch {
      return reply({ok:false,error:'Pairing unavailable'},503);
    }
  };
}
