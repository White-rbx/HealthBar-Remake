// Isolated QA passkey ceremonies. NEVER activate without staged schema and runtime QA.
// No password hashing on Workers Free; only authenticated, user-verified WebAuthn.
// The verifier is the maintained @simplewebauthn/server library, not custom CBOR/COSE.
import {
 generateRegistrationOptions, verifyRegistrationResponse,
 generateAuthenticationOptions, verifyAuthenticationResponse,
} from '@simplewebauthn/server';
import {Buffer} from 'node:buffer';
import {randomHex,sha} from './security.mjs';

const usernameRE=/^[A-Za-z0-9_]{3,24}$/;
const credentialRE=/^[A-Za-z0-9_-]{8,2048}$/;
const recoveryCodeRE=/^[0-9a-f]{32}$/;
const recoveryCodes=()=>Array.from({length:8},()=>randomHex(16));
const FLOW_COOKIE='__Host-ascqa-passkey-flow';
const ttl=300;
const textEncoder=new TextEncoder();
const headers={
 'Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff',
 'X-Frame-Options':'DENY','Referrer-Policy':'no-referrer','X-Robots-Tag':'noindex, nofollow',
};
const flowCookie=(value,age)=>FLOW_COOKIE+'='+value+'; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age='+age;
function readFlowCookie(request){
 const tokens=(request.headers.get('Cookie')||'').split(';').map(x=>x.trim()).filter(x=>x.startsWith(FLOW_COOKIE+'='));
 return tokens.length===1?tokens[0].slice(FLOW_COOKIE.length+1):null;
}
function send(status,body,{issuedSession,clearFlow=false,setFlow}={}){
 const h=new Headers({...headers,'Content-Type':'application/json; charset=utf-8'});
 if(issuedSession)h.append('Set-Cookie','__Host-ascqa='+issuedSession+'; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=28800');
 if(clearFlow)h.append('Set-Cookie',flowCookie('',0));
 if(setFlow)h.append('Set-Cookie',flowCookie(setFlow,ttl));
 return new Response(JSON.stringify(body),{status,headers:h});
}
const reject=(status,code,options={})=>send(status,{ok:false,code},options);
const approve=(body,options={})=>send(200,{ok:true,...body},options);

function validResponse(x){
 return x&&typeof x==='object'&&!Array.isArray(x)
  && typeof x.id==='string'&&credentialRE.test(x.id)
  && typeof x.type==='string'&&x.type==='public-key'
  && x.response&&typeof x.response==='object'&&!Array.isArray(x.response);
}
function limitedTransports(x){
 const arr=Array.isArray(x)?x.filter(v=>typeof v==='string'&&/^[a-z-]{2,30}$/.test(v)).slice(0,8):[];
 return JSON.stringify(arr);
}
function flowRow(db,token,now,purpose){
 return db.prepare('DELETE FROM asc_account_passkey_flows WHERE flow_hash=? AND purpose=? AND expires_at>? RETURNING *')
  .bind(token,purpose,now).first();
}

export function createPasskeyCeremonies({
 origin='https://arcscriptcenter-account-qa.kogpasan14.workers.dev',
 clock=()=>Math.floor(Date.now()/1000),
 siteverify,
 issueSession,
 rate,
}={}){
 if(typeof siteverify!=='function'||typeof issueSession!=='function'||typeof rate!=='function')
  throw new Error('Passkey QA requires its trusted account gateway');
 const rpID=new URL(origin).hostname;
 async function startFlow(db,purpose,username,accountId,challenge,now){
  const value=randomHex(32),hash=await sha(value);
  // Opportunistic cleanup. No established Account Case or session is deleted here.
  await db.prepare('DELETE FROM asc_account_passkey_flows WHERE expires_at<=?').bind(now).run();
  await db.prepare('INSERT INTO asc_account_passkey_flows(flow_hash,challenge,purpose,username,proposed_account_id,created_at,expires_at) VALUES(?,?,?,?,?,?,?)')
   .bind(hash,challenge,purpose,username,accountId,now,now+ttl).run();
  return value;
 }
 async function consume(db,request,now,purpose){
  const token=readFlowCookie(request);
  if(!token||!/^[0-9a-f]{64}$/.test(token))return null;
  return flowRow(db,await sha(token),now,purpose);
 }
 return {
  async handle(op,body,request,env){
   const db=env.ACCOUNT_DB,now=clock();
   if(request.headers.get('Origin')!==origin)return reject(403,'forbidden');
   if(request.headers.has('Sec-Fetch-Site')&&request.headers.get('Sec-Fetch-Site')!=='same-origin')
    return reject(403,'forbidden');
   if(!await rate(env,'passkey:'+op+':ip'))return reject(429,'rate_limited');
   if(op==='passkey/register/options'){
    if(!usernameRE.test(body.username||'')||body.presence!==true)return reject(400,'invalid_input');
    if(!await rate(env,'passkey:register:name:'+await sha(body.username.toLowerCase())))
     return reject(429,'rate_limited');
    const verified=await siteverify(request,body,env,origin,fetch);
    if(verified===null)return reject(503,'verification_unavailable');
    if(!verified)return reject(400,'verification_required');
    const username=body.username.toLowerCase();
    if(await db.prepare('SELECT id FROM asc_accounts WHERE username=?').bind(username).first())
     return reject(409,'username_unavailable');
    const proposed=crypto.randomUUID();
    const options=await generateRegistrationOptions({
     rpName:'ArcScriptCenter Account QA',rpID,
     userID:textEncoder.encode(proposed),userName:username,userDisplayName:body.username,
     attestationType:'none',timeout:60000,
     supportedAlgorithmIDs:[-7],
     authenticatorSelection:{residentKey:'required',requireResidentKey:true,userVerification:'required'},
    });
    const flow=await startFlow(db,'register',username,proposed,options.challenge,now);
    return approve({options},{setFlow:flow});
   }
   if(op==='passkey/recovery/options'){
    if(!usernameRE.test(body.username||'')||typeof body.code!=='string'||
       !recoveryCodeRE.test(body.code.toLowerCase())||body.presence!==true)
     return reject(400,'invalid_input');
    if(!await rate(env,'passkey:recovery:name:'+await sha(body.username.toLowerCase())))
     return reject(429,'rate_limited');
    const verified=await siteverify(request,body,env,origin,fetch,'asc_recover');
    if(verified===null)return reject(503,'verification_unavailable');
    if(!verified)return reject(400,'verification_required');
    const username=body.username.toLowerCase(),digest=await sha(body.code.toLowerCase());
    const account=await db.prepare(`
     SELECT a.id,a.username FROM asc_accounts a
     JOIN asc_account_passkey_recovery_codes r ON r.account_id=a.id
     WHERE a.username=? AND a.password_hash='passkey-only' AND r.code_digest=?
    `).bind(username,digest).first();
    if(!account)return reject(401,'recovery_failed');
    const options=await generateRegistrationOptions({
     rpName:'ArcScriptCenter Account QA',rpID,
     userID:textEncoder.encode(account.id),userName:account.username,userDisplayName:account.username,
     attestationType:'none',timeout:60000,
     supportedAlgorithmIDs:[-7],
     authenticatorSelection:{residentKey:'required',requireResidentKey:true,userVerification:'required'},
    });
    const cookieValue=randomHex(32),hash=await sha(cookieValue);
    await db.prepare('DELETE FROM asc_account_passkey_recovery_flows WHERE expires_at<=?').bind(now).run();
    await db.prepare(`
     INSERT INTO asc_account_passkey_recovery_flows
      (flow_hash,account_id,challenge,recovery_digest,created_at,expires_at)
     VALUES(?,?,?,?,?,?)
    `).bind(hash,account.id,options.challenge,digest,now,now+ttl).run();
    return approve({options},{setFlow:cookieValue});
   }
   if(op==='passkey/login/options'){
    const options=await generateAuthenticationOptions({
     rpID,timeout:60000,userVerification:'required',allowCredentials:[],
    });
    const flow=await startFlow(db,'login',null,null,options.challenge,now);
    return approve({options},{setFlow:flow});
   }
   if(op==='passkey/register/verify'){
    const flow=await consume(db,request,now,'register');
    if(!flow)return reject(410,'challenge_expired',{clearFlow:true});
    if(!validResponse(body.response))return reject(400,'invalid_input',{clearFlow:true});
    let verified;
    try{
     verified=await verifyRegistrationResponse({
      response:body.response,expectedChallenge:flow.challenge,
      expectedOrigin:origin,expectedRPID:rpID,requireUserVerification:true,
     });
    }catch{return reject(400,'passkey_verification_failed',{clearFlow:true})}
    const credential=verified.registrationInfo?.credential;
    if(!verified.verified||!credential||!credentialRE.test(credential.id))
     return reject(400,'passkey_verification_failed',{clearFlow:true});
    const publicKey=Buffer.from(credential.publicKey).toString('base64url');
    if(!publicKey||publicKey.length>2048)return reject(400,'passkey_verification_failed',{clearFlow:true});
    const codes=recoveryCodes(),digests=await Promise.all(codes.map(sha));
    const [account,passkey,...stored]=await db.batch([
     db.prepare('INSERT INTO asc_accounts(id,username,password_hash,nickname,created_at) VALUES(?,?,?,?,?) ON CONFLICT(username) DO NOTHING RETURNING id')
      .bind(flow.proposed_account_id,flow.username,'passkey-only',flow.username,now),
     db.prepare('INSERT INTO asc_account_passkeys(credential_id,account_id,public_key_b64url,counter,transports_json,created_at) SELECT ?,id,?,?,?,? FROM asc_accounts WHERE id=? AND changes()=1 RETURNING credential_id')
      .bind(credential.id,publicKey,credential.counter,limitedTransports(body.response.response.transports),now,flow.proposed_account_id),
     ...digests.map(digest=>db.prepare(`
      INSERT INTO asc_account_passkey_recovery_codes(account_id,code_digest,created_at)
      SELECT ?1,?2,?3 WHERE EXISTS(SELECT 1 FROM asc_account_passkeys WHERE credential_id=?4 AND account_id=?1)
      RETURNING code_digest
     `).bind(flow.proposed_account_id,digest,now,credential.id)),
    ]);
    if(!account.results?.length||!passkey.results?.length||stored.some(x=>!x.results?.length))
     return reject(409,'username_unavailable',{clearFlow:true});
    const row=await db.prepare('SELECT * FROM asc_accounts WHERE id=?').bind(flow.proposed_account_id).first();
    const session=row&&await issueSession(db,row,'web',now,28800);
    if(!session)return reject(503,'session_unavailable',{clearFlow:true});
    // One-time offline recovery codes are shown ONLY in this response.
    return approve({account:{id:row.id,username:row.username,nickname:row.nickname},
     recoveryCodes:codes},{issuedSession:session,clearFlow:true});
   }
   if(op==='passkey/login/verify'){
    const flow=await consume(db,request,now,'login');
    if(!flow)return reject(410,'challenge_expired',{clearFlow:true});
    if(!validResponse(body.response))return reject(400,'invalid_input',{clearFlow:true});
    const row=await db.prepare('SELECT a.*,p.credential_id,p.public_key_b64url,p.counter,p.transports_json FROM asc_account_passkeys p JOIN asc_accounts a ON a.id=p.account_id WHERE p.credential_id=?')
     .bind(body.response.id).first();
    if(!row)return reject(401,'passkey_verification_failed',{clearFlow:true});
    const handle=body.response.response?.userHandle;
    if(handle!=null){
     if(typeof handle!=='string'||Buffer.from(handle,'base64url').toString('utf8')!==row.id)
      return reject(401,'passkey_verification_failed',{clearFlow:true});
    }
    let verified;
    try{
     verified=await verifyAuthenticationResponse({
      response:body.response,expectedChallenge:flow.challenge,
      expectedOrigin:origin,expectedRPID:rpID,requireUserVerification:true,
      credential:{
       id:row.credential_id,publicKey:new Uint8Array(Buffer.from(row.public_key_b64url,'base64url')),
       counter:row.counter,transports:JSON.parse(row.transports_json),
      },
     });
    }catch{return reject(401,'passkey_verification_failed',{clearFlow:true})}
    if(!verified.verified)return reject(401,'passkey_verification_failed',{clearFlow:true});
    const updated=await db.prepare('UPDATE asc_account_passkeys SET counter=?,last_used_at=? WHERE credential_id=? AND counter=? RETURNING credential_id')
     .bind(verified.authenticationInfo.newCounter,now,row.credential_id,row.counter).first();
    if(!updated)return reject(409,'retry',{clearFlow:true});
    const session=await issueSession(db,row,'web',now,28800);
    if(!session)return reject(503,'session_unavailable',{clearFlow:true});
    return approve({account:{id:row.id,username:row.username,nickname:row.nickname}},
     {issuedSession:session,clearFlow:true});
   }
   if(op==='passkey/recovery/verify'){
    const token=readFlowCookie(request);
    if(!token||!/^[0-9a-f]{64}$/.test(token))
     return reject(410,'challenge_expired',{clearFlow:true});
    const flow=await db.prepare(`
     DELETE FROM asc_account_passkey_recovery_flows
     WHERE flow_hash=? AND expires_at>? RETURNING *
    `).bind(await sha(token),now).first();
    if(!flow)return reject(410,'challenge_expired',{clearFlow:true});
    if(!validResponse(body.response))return reject(400,'invalid_input',{clearFlow:true});
    let result;
    try{
     result=await verifyRegistrationResponse({
      response:body.response,expectedChallenge:flow.challenge,
      expectedOrigin:origin,expectedRPID:rpID,requireUserVerification:true,
     });
    }catch{return reject(400,'passkey_verification_failed',{clearFlow:true})}
    const credential=result.registrationInfo?.credential;
    if(!result.verified||!credential||!credentialRE.test(credential.id))
     return reject(400,'passkey_verification_failed',{clearFlow:true});
    const publicKey=Buffer.from(credential.publicKey).toString('base64url');
    if(!publicKey||publicKey.length>2048)return reject(400,'passkey_verification_failed',{clearFlow:true});
    const [used,added]=await db.batch([
     db.prepare(`DELETE FROM asc_account_passkey_recovery_codes
      WHERE account_id=? AND code_digest=? RETURNING code_digest`)
      .bind(flow.account_id,flow.recovery_digest),
     db.prepare(`INSERT INTO asc_account_passkeys
      (credential_id,account_id,public_key_b64url,counter,transports_json,created_at)
      SELECT ?1,?2,?3,?4,?5,?6 WHERE changes()=1 RETURNING credential_id`)
      .bind(credential.id,flow.account_id,publicKey,credential.counter,
       limitedTransports(body.response.response.transports),now),
     db.prepare(`UPDATE asc_account_sessions SET revoked_at=?1
      WHERE account_id=?2 AND EXISTS(SELECT 1 FROM asc_account_passkeys
       WHERE credential_id=?3 AND account_id=?2)`)
      .bind(now,flow.account_id,credential.id),
     db.prepare(`UPDATE asc_accounts SET epoch=epoch+1
      WHERE id=?1 AND EXISTS(SELECT 1 FROM asc_account_passkeys
       WHERE credential_id=?2 AND account_id=?1)`)
      .bind(flow.account_id,credential.id),
    ]);
    if(!used.results?.length||!added.results?.length)
     return reject(409,'recovery_failed',{clearFlow:true});
    const account=await db.prepare('SELECT * FROM asc_accounts WHERE id=?')
     .bind(flow.account_id).first();
    const session=account&&await issueSession(db,account,'web',now,28800);
    if(!session)return reject(503,'session_unavailable',{clearFlow:true});
    return approve({account:{id:account.id,username:account.username,nickname:account.nickname}},
     {issuedSession:session,clearFlow:true});
   }
   return reject(404,'not_found');
  },
 };
}
