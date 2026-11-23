import {readJson,BanError} from '../ban-v2-integration.mjs';
import {accountProfile,validImage} from './moderation.mjs';
import {displayTotp,loginPassword,matchingTotpStep,newTotpSecret,passwordHash,passwordMatches,randomHex,readTotp,sealTotp,sha,strongPassword} from './security.mjs';
import {website} from './website.mjs';

const defaultOrigin='https://arcscriptcenter-account-qa.kogpasan14.workers.dev';
const prefix='/api/v1/accounts/';
const loginName=/^[A-Za-z0-9_]{3,24}$/;
const credentialPattern=/^[0-9a-f]{64}$/;
const pairCode=/^[0-9A-F]{12}$/;
const seconds=()=>Math.floor(Date.now()/1000);
const webCookie='__Host-ascqa';
const parseBody=async request=>{
 const value=await readJson(request,8192);
 if(!value||typeof value!=='object'||Array.isArray(value))throw new BanError(400,'invalid_input','Invalid input');
 return value;
};
const displayName=v=>typeof v==='string'&&/^[A-Za-z0-9 _.-]{1,24}$/.test(v)&&v===v.trim();
const asset=v=>v===null||typeof v==='string'&&/^[1-9][0-9]{0,15}$/.test(v);
const token=()=>randomHex(32);
const securityHeaders={
 'Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff','X-Frame-Options':'DENY',
 'Referrer-Policy':'no-referrer',
};
const json=(status,body,headers={})=>Response.json(body,{status,headers:{...securityHeaders,...headers}});
const fail=(status,code)=>json(status,{ok:false,code});
const ok=(body={})=>json(200,{ok:true,...body});
const cookie=(value,age)=>webCookie+'='+value+'; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age='+age;
const browserToken=request=>{
 const tokens=(request.headers.get('Cookie')||'').split(';').map(v=>v.trim()).filter(v=>v.startsWith(webCookie+'='));
 return tokens.length===1?tokens[0].slice(webCookie.length+1):'';
};
const loadSession=(db,digest,scope,now)=>db.prepare(`
 SELECT a.*,s.id AS session_id,s.scope,s.expires_at
 FROM asc_account_sessions s JOIN asc_accounts a ON a.id=s.account_id
 WHERE s.digest=?1 AND s.scope=?2 AND s.revoked_at IS NULL AND s.expires_at>?3
`).bind(digest,scope,now).first();

async function issueSession(db,account,scope,now,ttl){
 const value=token();
 const row=await db.prepare(`
 INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at)
 SELECT ?1,id,?2,?3,?4,?5 FROM asc_accounts WHERE id=?6 AND epoch=?7
 RETURNING id
 `).bind(crypto.randomUUID(),await sha(value),scope,now,now+ttl,account.id,account.epoch).first();
 return row?value:null;
}

async function checkFactor(db,account,code,key,now){
 if(!account.totp)return false;
 if(typeof code!=='string')return false;
 if(/^[0-9a-f]{24}$/i.test(code)){
  const row=await db.prepare(`
   DELETE FROM asc_account_recovery WHERE account_id=? AND digest=?
   AND EXISTS(SELECT 1 FROM asc_accounts WHERE id=? AND epoch=?)
   RETURNING digest
  `).bind(account.id,await sha(code.toLowerCase()),account.id,account.epoch).first();
  return !!row;
 }
 const secret=await readTotp(account.totp,key,account.id);
 const step=await matchingTotpStep(code,secret,now,account.last_totp_step);
 return step!==null&&!!await db.prepare(`
  UPDATE asc_accounts SET last_totp_step=?1 WHERE id=?2 AND epoch=?3 AND last_totp_step<?1 RETURNING id
 `).bind(step,account.id,account.epoch).first();
}

async function rate(env,key){
 const limiter=env.ACCOUNT_RATE;
 if(typeof limiter?.limit!=='function')throw new Error('Rate limiter missing');
 return (await limiter.limit({key})).success===true;
}

async function siteverify(request,body,env,origin,fetcher){
 if(typeof env.ACCOUNT_TURNSTILE_SECRET!=='string'||!env.ACCOUNT_TURNSTILE_SITE_KEY)return null;
 if(typeof body.turnstile!=='string'||body.turnstile.length<1||body.turnstile.length>2048)return false;
 const reply=await fetcher('https://challenges.cloudflare.com/turnstile/v0/siteverify',{
  method:'POST',headers:{'Content-Type':'application/json'},redirect:'error',signal:AbortSignal.timeout(5000),
  body:JSON.stringify({secret:env.ACCOUNT_TURNSTILE_SECRET,response:body.turnstile}),
 });
 if(!reply.ok)return null;
 const verified=await reply.json();
 return verified.success===true&&verified.hostname===new URL(origin).hostname&&verified.action==='asc_register';
}

function siteKey(env){
 return /^[A-Za-z0-9_-]{8,100}$/.test(env.ACCOUNT_TURNSTILE_SITE_KEY||'')?env.ACCOUNT_TURNSTILE_SITE_KEY:'';
}

const webOps=new Set(['register','login','factor','pair/approve','security/sessions','security/revoke','security/setup','security/enable',
 'security/disable','security/password','profile','moderation']);
const loaderOps=new Set(['pair/start','pair/poll','session','heartbeat','history','appeal','feedback','logout']);
const commonOps=new Set(['session','history','appeal','feedback','logout']);

export function createAccountWorker({origin=defaultOrigin,clock=seconds,fetcher=fetch}={}){
 return {async fetch(request,env){
  const url=new URL(request.url);
  if(url.origin!==origin||url.search||env.ASC_ACCOUNT_MODE!=='isolated-qa')return fail(404,'not_found');
  if(request.method==='GET'&&url.pathname==='/'){
   const nonce=randomHex(16);
   return new Response(website(siteKey(env),nonce),{headers:{...securityHeaders,'Content-Type':'text/html; charset=utf-8',
    'Content-Security-Policy':`default-src 'none'; script-src 'nonce-${nonce}' https://challenges.cloudflare.com; style-src 'nonce-${nonce}'; connect-src 'self'; frame-src https://challenges.cloudflare.com; img-src 'self' https://*.rbxcdn.com; base-uri 'none'; frame-ancestors 'none'; form-action 'none'`,
   }});
  }
  if(request.method!=='POST'||!url.pathname.startsWith(prefix))return fail(404,'not_found');
  const op=url.pathname.slice(prefix.length);
  const web=request.headers.get('Origin')===origin;
  if(!(web?(webOps.has(op)||commonOps.has(op)):loaderOps.has(op)))return fail(404,'not_found');
  if(!web&&(request.headers.has('Origin')||request.headers.has('Cookie')))return fail(403,'forbidden');
  if(web&&request.headers.has('Sec-Fetch-Site')&&request.headers.get('Sec-Fetch-Site')!=='same-origin')return fail(403,'forbidden');
  try{
   const db=env.ACCOUNT_DB,now=clock(),ip=request.headers.get('CF-Connecting-IP')||'unknown';
   if(!await rate(env,op+':ip:'+ip))return fail(429,'rate_limited');
   const body=await parseBody(request);
   if(op==='register'||op==='login'){
    const {username,password}=body;
    if(typeof username!=='string'||!loginName.test(username)||!loginPassword(password))return fail(400,'invalid_input');
    const normalized=username.toLowerCase();
    if(!await rate(env,op+':name:'+await sha(normalized)))return fail(429,'rate_limited');
    if(op==='register'){
     if(!strongPassword(password)||body.confirmation!==password||body.presence!==true)return fail(400,'invalid_input');
     const checked=await siteverify(request,body,env,origin,fetcher);
     if(checked===null)return fail(503,'registration_unavailable');
     if(!checked)return fail(400,'verification_required');
     const digest=await passwordHash(password);
     await db.prepare(`
      INSERT INTO asc_accounts(id,username,password_hash,nickname,created_at) VALUES(?,?,?,?,?)
      ON CONFLICT(username) DO NOTHING
     `).bind(crypto.randomUUID(),normalized,digest,username,now).run();
     // Identical acknowledgement for existing and newly created usernames.
     return ok();
    }
    const account=await db.prepare('SELECT * FROM asc_accounts WHERE username=?').bind(normalized).first();
    if(!await passwordMatches(password,account?.password_hash))return fail(401,'login_failed');
    if(account.totp){
     const challenge=await issueSession(db,account,'second_factor',now,300);
     return challenge?json(202,{ok:true,state:'verification_required',challenge}):fail(401,'login_failed');
    }
    const session=await issueSession(db,account,'web',now,28800);
    return session?json(200,{ok:true,account:accountProfile(account)},{'Set-Cookie':cookie(session,28800)}):fail(401,'login_failed');
   }
   if(op==='factor'){
    if(typeof body.challenge!=='string'||!credentialPattern.test(body.challenge))return fail(401,'verification_failed');
    const digest=await sha(body.challenge);
    const pending=await loadSession(db,digest,'second_factor',now);
    if(!pending||!await rate(env,'factor:account:'+pending.id))return fail(pending?429:401,'verification_failed');
    if(!await checkFactor(db,pending,body.code,env.ACCOUNT_TOTP_KEY,now))return fail(401,'verification_failed');
    const consumed=await db.prepare(`
     UPDATE asc_account_sessions SET revoked_at=? WHERE id=? AND revoked_at IS NULL AND expires_at>? RETURNING id
    `).bind(now,pending.session_id,now).first();
    const session=consumed&&await issueSession(db,pending,'web',now,28800);
    return session?json(200,{ok:true,account:accountProfile(pending)},{'Set-Cookie':cookie(session,28800)}):fail(401,'verification_failed');
   }
   if(op==='pair/start'){
    if(!await rate(env,'pair:start:global'))return fail(429,'rate_limited');
    const secret=token(),code=randomHex(6).toUpperCase();
    await db.prepare('DELETE FROM asc_account_pairings WHERE expires_at<=?').bind(now).run();
    await db.prepare('INSERT INTO asc_account_pairings(code,digest,expires_at,label) VALUES(?,?,?,?)')
     .bind(code,await sha(secret),now+300,'ExperienceSettings').run();
    return ok({code,secret,expiresAt:now+300});
   }
   if(op==='pair/poll'){
    if(typeof body.secret!=='string'||!credentialPattern.test(body.secret))return fail(400,'invalid_input');
    const digest=await sha(body.secret);
    const pair=await db.prepare('SELECT account_id,claimed_session_id,expires_at FROM asc_account_pairings WHERE digest=?')
     .bind(digest).first();
    if(!pair||pair.expires_at<=now||pair.claimed_session_id)return fail(410,'session_expired');
    if(!pair.account_id)return ok({state:'pending'});
    const session=token(),id=crypto.randomUUID();
    const ttl=body.remember===true?43200:14400;
    const [issued]=await db.batch([
     db.prepare(`
      INSERT INTO asc_account_sessions(id,account_id,digest,scope,created_at,expires_at)
      SELECT ?1,p.account_id,?2,'loader',?3,?4 FROM asc_account_pairings p
      JOIN asc_account_sessions s ON s.id=p.authorizing_session_id AND s.account_id=p.account_id
      WHERE p.digest=?5 AND p.expires_at>?3 AND p.claimed_session_id IS NULL
        AND s.scope='web' AND s.revoked_at IS NULL AND s.expires_at>?3
      RETURNING account_id
     `).bind(id,await sha(session),now,now+ttl,digest),
     db.prepare(`UPDATE asc_account_pairings SET claimed_session_id=?1
      WHERE digest=?2 AND EXISTS(SELECT 1 FROM asc_account_sessions WHERE id=?1)`).bind(id,digest),
    ]);
    return issued.results?.length?ok({state:'ready',session,expiresAt:now+ttl}):fail(410,'session_expired');
   }
   const raw=web?browserToken(request):(request.headers.get('Authorization')||'').match(/^Bearer ([0-9a-f]{64})$/)?.[1];
   if(!credentialPattern.test(raw||''))return fail(401,'session_expired');
   const scope=web?'web':'loader';
   const account=await loadSession(db,await sha(raw),scope,now);
   if(!account)return fail(401,'session_expired');
   if(!await rate(env,op+':account:'+account.id))return fail(429,'rate_limited');
   if(op==='session')return ok({account:accountProfile(account),expiresAt:account.expires_at});
   if(op==='logout'){
    await db.prepare('UPDATE asc_account_sessions SET revoked_at=? WHERE id=?').bind(now,account.session_id).run();
    return json(200,{ok:true},web?{'Set-Cookie':cookie('',0)}:{});
   }
   if(op==='heartbeat'){
    const r=await db.prepare(`
     UPDATE asc_account_sessions SET last_seen=?1 WHERE id=?2 AND revoked_at IS NULL AND expires_at>?1
       AND EXISTS(SELECT 1 FROM asc_accounts WHERE id=?3 AND status<>'banned') RETURNING id
    `).bind(now,account.session_id,account.id).first();
    return r?ok({account:accountProfile(account)}):fail(403,'account_banned');
   }
   if(op==='history'){
    const result=await db.prepare(`
     SELECT id,kind,status,reason,moderator_message AS moderatorMessage,created_at AS createdAt
     FROM asc_account_cases WHERE account_id=? ORDER BY created_at DESC,id DESC LIMIT 100
    `).bind(account.id).all();
    const cases=result.results||[];
    return ok({cases,notices:cases.filter(x=>x.kind==='violation'||x.kind==='ban').map(x=>({...x,
     appealStatus:x.status==='open'?'not_appealed':x.status,canAppealAgain:x.status==='open',
    })).filter(x=>x.appealStatus!=='closed')});
   }
   if(op==='appeal'){
    if(typeof body.id!=='string'||body.id.length>100||typeof body.description!=='string'||
       body.description.trim().length<50||body.description.length>1500)return fail(400,'invalid_input');
    const changed=await db.prepare(`
     UPDATE asc_account_cases SET appeal=?1,status='reviewing'
     WHERE id=?2 AND account_id=?3 AND kind IN ('ban','violation') AND status='open'
      AND EXISTS(SELECT 1 FROM asc_account_sessions WHERE id=?4 AND revoked_at IS NULL AND expires_at>?5)
     RETURNING id
    `).bind(body.description.trim(),body.id,account.id,account.session_id,now).first();
    return changed?ok({id:changed.id}):fail(409,'appeal_unavailable');
   }
   if(op==='feedback'){
    if(account.status==='banned')return fail(403,'account_banned');
    if(typeof body.description!=='string'||body.description.trim().length<50||body.description.length>1500)
     return fail(400,'invalid_input');
    const row=await db.prepare(`
     INSERT INTO asc_account_cases(id,account_id,kind,reason,created_at)
     SELECT ?1,a.id,'feedback',?2,?3 FROM asc_accounts a JOIN asc_account_sessions s ON s.account_id=a.id
     WHERE a.id=?4 AND a.status<>'banned' AND s.id=?5 AND s.revoked_at IS NULL AND s.expires_at>?3 RETURNING id
    `).bind(crypto.randomUUID(),body.description.trim(),now,account.id,account.session_id).first();
    return row?ok({id:row.id}):fail(403,'account_banned');
   }
   if(op==='pair/approve'){
    if(typeof body.code!=='string'||!pairCode.test(body.code)||body.confirm!==true)return fail(400,'invalid_input');
    const changed=await db.prepare(`
     UPDATE asc_account_pairings SET account_id=?1,authorizing_session_id=?2
     WHERE code=?3 AND expires_at>?4 AND account_id IS NULL
     AND EXISTS(SELECT 1 FROM asc_account_sessions WHERE id=?2 AND revoked_at IS NULL AND expires_at>?4)
     RETURNING code
    `).bind(account.id,account.session_id,body.code,now).first();
    return changed?ok():fail(409,'pairing_unavailable');
   }
   if(op==='security/sessions'){
    const sessions=await db.prepare(`
     SELECT id,scope,created_at AS createdAt,last_seen AS lastSeen,expires_at AS expiresAt
     FROM asc_account_sessions WHERE account_id=? AND expires_at>? AND revoked_at IS NULL
     AND scope<>'second_factor' ORDER BY created_at DESC LIMIT 40
    `).bind(account.id,now).all();
    return ok({current:account.session_id,sessions:sessions.results});
   }
   if(op==='profile'){
    if(account.status==='banned')return fail(403,'account_banned');
    if(!displayName(body.nickname)||!asset(body.image)||!asset(body.banner)||typeof body.color!=='string'||
       !/^#[0-9a-f]{6}$/i.test(body.color))return fail(400,'invalid_input');
    const images=new Map([[null,null]]);
    for(const value of new Set([body.image,body.banner])){
     if(!value)continue;
     const thumbnail=await validImage(value,fetcher);
     if(!thumbnail)return fail(400,'image_unavailable');
     images.set(value,thumbnail);
    }
    const changed=await db.prepare(`
     UPDATE asc_accounts SET nickname=?1,profile_image=?2,banner_image=?3,banner_color=?4,
      profile_thumbnail=?5,banner_thumbnail=?6
     WHERE id=?7 AND status<>'banned'
     AND EXISTS(SELECT 1 FROM asc_account_sessions WHERE id=?8 AND revoked_at IS NULL AND expires_at>?9)
     RETURNING id
    `).bind(body.nickname,body.image,body.banner,body.color,images.get(body.image),images.get(body.banner),account.id,account.session_id,now).first();
    return changed?ok():fail(403,'account_banned');
   }
   if(op==='moderation'){
    if(account.status!=='normal'||typeof env.ACCOUNT_MODERATOR_IDS!=='string'||!env.ACCOUNT_MODERATOR_IDS.split(',').includes(account.id))
     return fail(403,'forbidden');
    if(body.decision!==undefined){
     if(!['approved','denied'].includes(body.decision)||typeof body.caseId!=='string'||body.caseId.length>100||
        typeof body.message!=='string'||body.message.length>2000)return fail(400,'invalid_input');
     if(!loginPassword(body.password)||!await passwordMatches(body.password,account.password_hash)||
        !account.totp||!await checkFactor(db,account,body.code,env.ACCOUNT_TOTP_KEY,now))return fail(401,'reauth_required');
     const reviewed=await db.prepare(`
      UPDATE asc_account_cases SET status=?,moderator_message=? WHERE id=? AND status='reviewing' RETURNING id
     `).bind(body.decision,body.message,body.caseId).first();
     return reviewed?ok():fail(409,'no_status_change');
    }
    if(!['normal','restricted_mode','banned'].includes(body.status)||typeof body.target!=='string'||
       !/^[a-f0-9-]{36}$/.test(body.target)||typeof body.reason!=='string'||!body.reason.trim()||body.reason.length>1500||
       typeof body.message!=='string'||body.message.length>2000)return fail(400,'invalid_input');
    if(!loginPassword(body.password)||!await passwordMatches(body.password,account.password_hash)||
       !account.totp||!await checkFactor(db,account,body.code,env.ACCOUNT_TOTP_KEY,now))return fail(401,'reauth_required');
    const kind=body.status==='banned'?'ban':'violation';
    const [change]=await db.batch([
     db.prepare('UPDATE asc_accounts SET status=? WHERE id=? AND status<>? RETURNING id').bind(body.status,body.target,body.status),
     db.prepare(`INSERT INTO asc_account_cases(id,account_id,kind,reason,moderator_message,created_at)
      SELECT ?,id,?,?,?,? FROM asc_accounts WHERE id=? AND changes()=1 AND ?<>'normal'
     `).bind(crypto.randomUUID(),kind,body.reason,body.message,now,body.target,body.status),
    ]);
    return change.results?.length?ok():fail(409,'no_status_change');
   }
   if(!op.startsWith('security/'))return fail(404,'not_found');
   if(!loginPassword(body.password)||!await passwordMatches(body.password,account.password_hash))
    return fail(401,'reauth_required');
   if(account.totp&&!await checkFactor(db,account,body.code,env.ACCOUNT_TOTP_KEY,now))
    return fail(401,'reauth_required');
   if(op==='security/revoke'){
    if(typeof body.id!=='string'||body.id.length>40)return fail(400,'invalid_input');
    await db.prepare('UPDATE asc_account_sessions SET revoked_at=? WHERE id=? AND account_id=?')
     .bind(now,body.id,account.id).run();
    return ok();
   }
   if(op==='security/setup'){
    if(account.totp)return fail(409,'already_enabled');
    const secret=newTotpSecret();
    const sealed=await sealTotp(secret,env.ACCOUNT_TOTP_KEY,account.id);
    const pending=await db.prepare(`
     UPDATE asc_accounts SET totp_pending=?,totp_pending_until=?
     WHERE id=? AND epoch=? AND totp IS NULL RETURNING id
    `).bind(sealed,now+600,account.id,account.epoch).first();
    return pending?ok({setupKey:displayTotp(secret)}):fail(409,'retry');
   }
   if(op==='security/enable'){
    if(account.totp||!account.totp_pending||account.totp_pending_until<=now)return fail(409,'setup_required');
    const secret=await readTotp(account.totp_pending,env.ACCOUNT_TOTP_KEY,account.id);
    const step=await matchingTotpStep(body.code,secret,now,-1);
    if(step===null)return fail(401,'verification_failed');
    const recovery=Array.from({length:8},()=>randomHex(12));
    const hashes=await Promise.all(recovery.map(sha));
    const [updated]=await db.batch([
     db.prepare(`UPDATE asc_accounts SET totp=totp_pending,totp_pending=NULL,totp_pending_until=NULL,last_totp_step=?,epoch=epoch+1
      WHERE id=? AND epoch=? AND totp_pending=? AND totp_pending_until>? RETURNING id
     `).bind(step,account.id,account.epoch,account.totp_pending,now),
     db.prepare(`INSERT INTO asc_account_recovery(account_id,digest)
      SELECT ?1,value FROM json_each(?2) WHERE changes()=1`).bind(account.id,JSON.stringify(hashes)),
     db.prepare(`UPDATE asc_account_sessions SET revoked_at=? WHERE account_id=? AND id<>? AND changes()=8`)
      .bind(now,account.id,account.session_id),
    ]);
    return updated.results?.length?ok({recovery}):fail(409,'retry');
   }
   if(op==='security/disable'||op==='security/password'){
    if(op==='security/password'&&(!strongPassword(body.newPassword)||body.newPassword!==body.confirmation))
     return fail(400,'invalid_input');
    const digest=op==='security/password'?await passwordHash(body.newPassword):account.password_hash;
    const [updated]=await db.batch([
     db.prepare(`UPDATE asc_accounts SET password_hash=?1,totp=?2,totp_pending=NULL,totp_pending_until=NULL,epoch=epoch+1
        WHERE id=?3 AND epoch=?4 RETURNING id`).bind(digest,op==='security/disable'?null:account.totp,account.id,account.epoch),
     db.prepare(`UPDATE asc_account_sessions SET revoked_at=? WHERE account_id=? AND changes()=1`).bind(now,account.id),
     db.prepare(`DELETE FROM asc_account_recovery WHERE account_id=?
      AND EXISTS(SELECT 1 FROM asc_accounts WHERE id=? AND totp IS NULL)`).bind(account.id,account.id),
    ]);
    return updated.results?.length?json(200,{ok:true},{'Set-Cookie':cookie('',0)}):fail(409,'retry');
   }
   return fail(404,'not_found');
  }catch(error){
   if(error instanceof BanError)return fail(error.status,error.code);
   return fail(503,'service_unavailable');
  }
 }};
}

// Internal count. Presence is private and independent of public visibility.
export async function activeAccounts(db,now=seconds()){
 const result=await db.prepare(`SELECT COUNT(DISTINCT s.account_id) AS total
  FROM asc_account_sessions s JOIN asc_accounts a ON a.id=s.account_id
  WHERE s.scope='loader' AND s.revoked_at IS NULL AND s.expires_at>?1
   AND s.last_seen>?2 AND a.status<>'banned'`).bind(now,now-90).first();
 return result.total;
}

export default createAccountWorker();
