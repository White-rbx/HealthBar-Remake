import { ADMIN_BANS, GAME_BANS, BanError, createBanV2Integration, openVerifiedHistory, submitVerifiedAppeal } from './ban-v2-integration.mjs';
import { createStagingGitHubBanStore, d1BanQaStore } from './ban-v2-integration-stores.mjs';

export const STAGING_BAN_PREVIEW='https://banned-check-center-v2-staging.arcscriptcenter-dashboard-staging.pages.dev';
export const QA_BAN_IDS=['9007199254740901','9007199254740902','9007199254740903','9007199254740904',
 '9007199254740905','9007199254740906','9007199254740907'];

const legacyAdminOrigin='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev';
const legacyAdminUrl='https://arcscriptcenter-api-staging.kogpasan14.workers.dev/api/v1/admin/feedback/summary';

export async function qaAdminAuthenticated(request,env) {
 const key=request.headers.get('X-Admin-Key');
 if(typeof key!=='string'||key.length<32||key.length>4096||!env.AUTH_API?.fetch)return false;
 const result=await env.AUTH_API.fetch(new Request(legacyAdminUrl,{headers:{
  'X-Admin-Key':key,'Origin':legacyAdminOrigin,'Accept':'application/json',
 }}));
 if(result.status===401||result.status===403)return false;
 if(!result.ok)throw new BanError(503,'admin_unavailable','Admin authentication is unavailable.');
 const proof=await result.json();
 return proof.ok===true&&proof.adminOnly===true&&Number.isSafeInteger(proof.summary?.total);
}

async function rateLimit(env,scope,subject) {
 if(typeof env.BAN_V2_RATE?.limit!=='function')
  throw new BanError(503,'rate_unavailable','Ban service rate limit unavailable.');
 const r=await env.BAN_V2_RATE.limit({key:scope+':'+subject});
 if(typeof r.success!=='boolean')throw new BanError(503,'rate_unavailable','Ban service rate limit unavailable.');
 return r.success;
}

export function mountBanV2(legacy,{staging=false,adminAuthenticated=qaAdminAuthenticated}={}) {
 const scopedHandler=createBanV2Integration({
  store:staging?createStagingGitHubBanStore():d1BanQaStore,
  adminAuthenticated,
  adminOrigins:[STAGING_BAN_PREVIEW,legacyAdminOrigin],
  allowTarget:(id,env)=>staging
   ? env.BAN_MANAGEMENT_WRITE==='staging-github' && env.BAN_STAGING_ALLOWED_TEST_IDS?.split(',').includes(id)
   : QA_BAN_IDS.includes(id) || env.BAN_QA_ALLOWED_TEST_IDS?.split(',').includes(id),
  verifyHistory:openVerifiedHistory,submitAppeal:submitVerifiedAppeal,rateLimit,
 });
 return {
  ...legacy,
  fetch(request,env,ctx){
   const path=new URL(request.url).pathname;
   if(path===ADMIN_BANS||path.startsWith(GAME_BANS)){
    return scopedHandler(request,staging?env:{...env,DB:env.BAN_QA_DB});
   }
   return legacy.fetch(request,env,ctx);
  },
 };
}
