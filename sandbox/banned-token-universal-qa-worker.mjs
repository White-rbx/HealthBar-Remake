import {BanError,createPublicBanStatus,openDocument,policyFor,readJson,submitVerifiedAppeal} from './ban-v2-integration.mjs';
import {QA_BAN_IDS} from './ban-v2-integration-worker.mjs';
import {d1BanQaStore} from './ban-v2-integration-stores.mjs';
import {ensureBannedReference,restrictionBannedReference} from './banned-token-staging.mjs';
import {createVerifiedHistoryHandler} from './stage16-80-verified-violation-history.mjs';

const origin='https://arcscriptcenter-banned-token-universal-qa.kogpasan14.workers.dev';
const routes='/api/v1/client/violation/';
const nowSeconds=()=>Math.floor(Date.now()/1000);
const encoder=new TextEncoder();
const hex=bytes=>Array.from(bytes,b=>b.toString(16).padStart(2,'0')).join('');
const digest=async value=>hex(new Uint8Array(await crypto.subtle.digest('SHA-256',encoder.encode(value))));
const credential=prefix=>prefix+hex(crypto.getRandomValues(new Uint8Array(32)));
const invitePattern=/^ASCVE_[0-9a-f]{64}$/;
const sessionPattern=/^ASCVS_[0-9a-f]{64}$/;
const eligible=(id,env)=>QA_BAN_IDS.includes(id)||env.BAN_PUBLIC_QA_TEST_IDS?.split(',').includes(id);
const response=(status,body)=>Response.json(body,{status,headers:{
 'Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff','Referrer-Policy':'no-referrer',
}});
const error=(status,code)=>response(status,{ok:false,code});
const limit=async (env,key)=>{
 if(typeof env.BAN_PUBLIC_QA_RATE?.limit!=='function')throw new Error('Rate limiter unavailable');
 return (await env.BAN_PUBLIC_QA_RATE.limit({key})).success===true;
};
const fromBrowser=request=>['Origin','Cookie'].some(key=>request.headers.has(key));
const publicPolicy=createPublicBanStatus({
 store:{read:(env,id)=>d1BanQaStore.read({DB:env.BAN_QA_DB},id)},
 allowTarget:eligible,
 publicReason:(reason,env)=>env.BAN_PUBLIC_QA_NOTICE_LABELS?.split(',').includes(reason)?reason:null,
 rateLimit:(request,env)=>limit(env,'policy:'+(request.headers.get('CF-Connecting-IP')||'unknown')),
});

// Server-side provisioning only. An authorized operator must verify the
// claimed recipient independently, or derive subject and username from
// verified Roblox OIDC. This function has no HTTP route.
export async function issueCaseEnrollment(db,{subject,noticeId,username},now=nowSeconds()){
 if(typeof subject!=='string'||!/^[1-9][0-9]{0,15}$/.test(subject)||
    typeof noticeId!=='string'||!/^[-\w]{1,70}$/.test(noticeId)||
    typeof username!=='string'||!/^[A-Za-z0-9_]{3,20}$/.test(username))return null;
 const code=credential('ASCVE_');
 const row=await db.prepare(`
  INSERT INTO asc_violation_case_sessions(credential_hash,state,notice_id,subject_user_id,verified_username,expires_unix)
  SELECT ?1,'enrollment',notice_id,subject_user_id,?4,?5
  FROM asc_verified_violation_subjects WHERE notice_id=?2 AND subject_user_id=?3
  RETURNING expires_unix
 `).bind(await digest(code),noticeId,subject,username,now+900).first();
 return row?code:null;
}

function resolveSession(db,tokenHash,now){
 return db.prepare(`
  SELECT s.notice_id AS noticeId,s.subject_user_id AS subject,s.verified_username AS username,s.expires_unix AS expiresAt
  FROM asc_violation_case_sessions s JOIN asc_verified_violation_subjects l USING(notice_id,subject_user_id)
  WHERE s.credential_hash=?1 AND s.state='session' AND s.expires_unix>?2
 `).bind(tokenHash,now).first();
}

export function createUniversalViolationWorker({publicOrigin=origin,clock=nowSeconds}={}){
 return {async fetch(request,env){
  const url=new URL(request.url);
  if(url.origin!==publicOrigin||url.search)return error(404,'not_found');
  if(url.pathname==='/api/v1/client/bans/v2/status')return publicPolicy(request,env);
  const op=url.pathname.slice(routes.length);
  if(!url.pathname.startsWith(routes)||!['enroll','history','reference','appeal','revoke'].includes(op))return error(404,'not_found');
  if(request.method!=='POST')return error(405,'method');
  if(fromBrowser(request))return error(403,'forbidden');
  try{
   const db=env.BAN_QA_DB;
   if(!await limit(env,'violation:'+op+':'+(request.headers.get('CF-Connecting-IP')||'unknown')))
    return error(429,'rate');
   const auth=request.headers.get('Authorization');
   if(op==='enroll'){
    const approvedIds=QA_BAN_IDS.concat((env.BAN_PUBLIC_QA_TEST_IDS||'').split(',').filter(x=>/^[1-9][0-9]{0,15}$/.test(x)));
    const code=auth?.slice(7);
    if(!auth?.startsWith('Bearer ')||!invitePattern.test(code))return error(401,'enrollment_required');
    const body=await readJson(request,64);
    if(!body||Array.isArray(body)||typeof body!=='object'||Object.keys(body).length)return error(400,'invalid_request');
    const now=clock(),token=credential('ASCVS_');
    // One conditional write burns the activation code before returning a session.
    const row=await db.prepare(`
      UPDATE asc_violation_case_sessions AS s
      SET credential_hash=?2,state='session',expires_unix=?4
      WHERE credential_hash=?1 AND state='enrollment' AND expires_unix>?3
        AND EXISTS (SELECT 1 FROM asc_verified_violation_subjects l
          WHERE l.notice_id=s.notice_id AND l.subject_user_id=s.subject_user_id)
        AND subject_user_id IN (${approvedIds.map(()=>'?').join(',')})
      RETURNING subject_user_id AS subject,expires_unix AS expiresAt
    `).bind(await digest(code),await digest(token),now,now+30*86400,...approvedIds).first();
    return row?response(201,{ok:true,session:token,subject:row.subject,expiresAt:row.expiresAt}):error(401,'enrollment_unavailable');
   }
   const token=auth?.slice(7);
   if(!auth?.startsWith('Bearer ')||!sessionPattern.test(token))return error(401,'session_required');
   const body=await readJson(request,op==='appeal'?24000:64);
   if(!body||Array.isArray(body)||typeof body!=='object')return error(400,'invalid_request');
   const tokenHash=await digest(token),now=clock();
   const grant=await resolveSession(db,tokenHash,now);
   if(!grant||!eligible(grant.subject,env))return error(401,'session_unavailable');
   if(op==='appeal'){
    if(Object.keys(body).length!==2||typeof body.description!=='string'||typeof body.noticeId!=='string')return error(400,'invalid_request');
    if(body.noticeId!==grant.noticeId)return error(403,'case_forbidden');
    return await submitVerifiedAppeal({DB:db},{userId:grant.subject,noticeId:grant.noticeId,description:body.description},now,{tokenHash});
   }
   if(Object.keys(body).length)return error(400,'invalid_request');
   if(op==='revoke'){
    await db.prepare("DELETE FROM asc_violation_case_sessions WHERE credential_hash=? AND state='session'").bind(tokenHash).run();
    return response(200,{ok:true});
   }
   if(op==='reference'){
    const record=await d1BanQaStore.read({DB:db},grant.subject);
    const policy=policyFor(openDocument(record).document,grant.subject,now);
    const reference=policy.ban && await restrictionBannedReference(db,{userId:grant.subject,revision:record.notice_revision,noticeId:grant.noticeId});
    return response(200,{ok:true,subject:grant.subject,state:policy.state,
     ...(reference?{reference,revision:(await digest(record.notice_revision)).slice(0,24)}:{})});
   }
   return await createVerifiedHistoryHandler({db,clock:()=>now*1000,
    resolveVerifiedPrincipal:async()=>({sub:grant.subject,noticeId:grant.noticeId,expiresAt:grant.expiresAt,method:'case_enrollment',verified:true}),
    decorateNotices:async(notices,subject)=>{
     if(typeof env.BANNED_TOKEN_SECRET!=='string'||env.BANNED_TOKEN_SECRET.length<32)return;
     for(const notice of notices){
      const reference=await ensureBannedReference(db,{userId:subject,username:grant.username,caseId:notice.id,secret:env.BANNED_TOKEN_SECRET});
      if(reference)notice.reference=reference;
     }
    },
   })(new Request('https://internal.invalid/history'));
  }catch(e){
   return e instanceof BanError?error(e.status,e.code):error(503,'case_service_unavailable');
  }
 }};
}

export default createUniversalViolationWorker();
