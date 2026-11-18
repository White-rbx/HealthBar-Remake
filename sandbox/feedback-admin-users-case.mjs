/**
 * ArcScriptCenter STAGING — admin-only grouped User's Case API adapter.
 * REVIEW ONLY: mount behind EXISTING authenticated admin route and origin policy.
 * A claimed Roblox UserId is an unverified input, NOT authenticated identity.
 * No route is registered by importing this module.
 */
export const USERS_ROUTE='/api/v1/admin/feedback/users';
export const USER_CASES_ROUTE='/api/v1/admin/feedback/users/cases';
import {normalizeUserQuery,validClaimedId} from './feedback-admin-roblox-directory.mjs';
const USER_LIMIT=20, CASE_LIMIT=25;
const isUserId=validClaimedId;
const result=(body,status=200)=>new Response(JSON.stringify(body),{status,headers:{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store, private','X-Content-Type-Options':'nosniff'}});
const integerPage=v=>v===null?0:/^(0|[1-9][0-9]{0,3})$/.test(v)?Number(v):null;
function mapGroup(r){
 const claimedId=r.claimed_user_id||null;
 return {claimedUserId:claimedId,identityVerified:false,unlinked:!claimedId,
  total:Number(r.total)||0,reviewing:Number(r.reviewing)||0,
  approved:Number(r.approved)||0,denied:Number(r.denied)||0,
  flagged:Number(r.flagged)||0,lastUpdatedAt:Number(r.last_updated)||0};
}
/**
 * @param {{adminAuthenticated:(request:Request, env:any)=>Promise<boolean>,
 *          originAllowed:(request:Request,origin:string|null)=>boolean}} auth
 */
export function createAdminUsersCaseHandler(auth,{directory=null}={}){
 if(typeof auth?.adminAuthenticated!=='function'||typeof auth?.originAllowed!=='function')
  throw Error('A verified admin session AND approved origin policy are required');
 return async function handleAdminUsersCase(request,env){
  if(request.method!=='GET')return result({ok:false,error:'Method Not Allowed'},405);
  const url=new URL(request.url);
  if(url.pathname!==USERS_ROUTE&&url.pathname!==USER_CASES_ROUTE)
   return result({ok:false,error:'Not Found'},404);
  const origin=request.headers.get('Origin');
  if(!auth.originAllowed(request,origin))return result({ok:false,error:'Origin not allowed'},403);
  if(!await auth.adminAuthenticated(request,env))return result({ok:false,error:'Unauthorized'},401);
  if(!env?.DB||typeof env.DB.prepare!=='function')return result({ok:false,error:'Unavailable'},503);
  const page=integerPage(url.searchParams.get('page'));
  if(page===null)return result({ok:false,error:'Invalid page'},400);
  try{
   if(url.pathname===USERS_ROUTE){
    let search;
    try{search=normalizeUserQuery(url.searchParams.get('search'))}
    catch{return result({ok:false,error:'Invalid search'},400)}
    let profiles=[];
    let matching=[];
    const numeric=search!==''&&/^\d+$/.test(search);
    if(search&&!numeric){
     if(!directory||typeof directory.search!=='function')
      return result({ok:false,error:'Public Roblox directory unavailable'},503);
     try{profiles=await directory.search(search)}
     catch{return result({ok:false,error:'Roblox profile search unavailable'},503)}
     matching=[...new Set(profiles.map(p=>String(p.userId)).filter(isUserId))].slice(0,10);
     if(!matching.length)return result({ok:true,adminOnly:true,search,page,pageSize:USER_LIMIT,
      users:[],hasMore:false,identityVerified:false,namesArePublicReferenceOnly:true});
    }
    const where=numeric?' AND claimed_user_id LIKE ?':search?' AND claimed_user_id IN ('+matching.map(()=>'?').join(',')+')':'';
    const query=`SELECT NULLIF(TRIM(claimed_user_id),'') AS claimed_user_id, COUNT(*) AS total,
       SUM(CASE WHEN status='reviewing' THEN 1 ELSE 0 END) AS reviewing,
       SUM(CASE WHEN status='approved' THEN 1 ELSE 0 END) AS approved,
       SUM(CASE WHEN status='denied' THEN 1 ELSE 0 END) AS denied,
       SUM(CASE WHEN status='violation' THEN 1 ELSE 0 END) AS flagged,
       MAX(updated_unix) AS last_updated
       FROM asc_feedback_cases WHERE removed=0 ${where}
       GROUP BY NULLIF(TRIM(claimed_user_id),'')
       ORDER BY last_updated DESC, claimed_user_id ASC LIMIT ? OFFSET ?`;
    const params=numeric?[search+'%',USER_LIMIT+1,page*USER_LIMIT]:search?[...matching,USER_LIMIT+1,page*USER_LIMIT]:[USER_LIMIT+1,page*USER_LIMIT];
    const rows=(await env.DB.prepare(query).bind(...params).all()).results||[];
    const groups=rows.slice(0,USER_LIMIT).map(mapGroup);
    if(directory?.getByIds){
     // Enrichment is optional: failed Roblox requests must not hide existing cases.
     try{
      const loaded=await directory.getByIds(groups.map(x=>x.claimedUserId).filter(isUserId));
      const byId=new Map([...profiles,...loaded].map(x=>[String(x.userId),x]));
      for(const group of groups){
       const profile=byId.get(group.claimedUserId);
       if(profile)group.profile={username:profile.username,displayName:profile.displayName,
        source:'roblox_public_directory',ownershipVerified:false};
      }
     }catch{/* gracefully fall back to unverified numeric IDs */}
    }
    return result({ok:true,adminOnly:true,search,page,pageSize:USER_LIMIT,
     users:groups,hasMore:rows.length>USER_LIMIT,
     identityVerified:false,namesArePublicReferenceOnly:true});
   }
   const subject=url.searchParams.get('subject');
   if(subject!=='unlinked'&&!isUserId(subject||''))
    return result({ok:false,error:'Invalid claimed UserId'},400);
   const unlinked=subject==='unlinked';
   const where=unlinked?"(claimed_user_id IS NULL OR TRIM(claimed_user_id)='')":"claimed_user_id=?";
   const sql=`SELECT id,kind,topic,status,revision,created_unix,updated_unix
    FROM asc_feedback_cases WHERE removed=0 AND ${where}
    ORDER BY updated_unix DESC,id DESC LIMIT ? OFFSET ?`;
   const params=unlinked?[CASE_LIMIT+1,page*CASE_LIMIT]:[subject,CASE_LIMIT+1,page*CASE_LIMIT];
   const rows=(await env.DB.prepare(sql).bind(...params).all()).results||[];
   return result({ok:true,adminOnly:true,subject,identityVerified:false,page,pageSize:CASE_LIMIT,
    hasMore:rows.length>CASE_LIMIT,cases:rows.slice(0,CASE_LIMIT).map(x=>({
     id:x.id,kind:x.kind,topic:x.topic,status:x.status,
     revision:Number(x.revision)||0,createdAt:Number(x.created_unix)||0,
     updatedAt:Number(x.updated_unix)||0}))});
  }catch{
   // Do not return SQL, secrets, receipt, submitted body or raw DB details.
   return result({ok:false,error:'Admin query unavailable'},503);
  }
 };
}
