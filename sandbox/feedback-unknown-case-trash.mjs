/**
 * STAGING review-only: unknown Feedback case Trash. Importing this file
 * does not register routes or activate Cron. Bind to EXISTING Admin auth.
 * A claimed UserId is never account authorization.
 */
export const TRASH_ROUTE='/api/v1/admin/feedback/unknown-trash';
export const TRASH_SECONDS=2592000;
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const NO_ID="(claimed_user_id IS NULL OR TRIM(claimed_user_id)='')";
const okTime=n=>Number.isSafeInteger(n)&&n>1000000000&&n<4102444800;
// Cloudflare D1 meta.changes may include FK cascades and trigger writes.\n// Treat at least one affected row as success, not an exact-one count.\nconst changedAtLeastOnce=r=>Number(r?.meta?.changes??r?.changes??0)>=1;
const response=(body,status=200)=>new Response(JSON.stringify(body),{status,headers:{'Content-Type':'application/json; charset=utf-8','Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff'}});
const pageIndex=q=>q===null?0:/^(0|[1-9][0-9]{0,3})$/.test(q)?Number(q):null;

export function createUnknownCaseTrashHandler({adminAuthenticated,originAllowed,clock=()=>Math.floor(Date.now()/1000)}={}){
 if(typeof adminAuthenticated!=='function'||typeof originAllowed!=='function')
  throw Error('Existing Admin authenticated session and exact origin policy required');
 return async function unknownCaseTrash(request,env){
  const url=new URL(request.url),method=request.method;
  if(url.pathname!==TRASH_ROUTE)return response({ok:false,error:'Not found'},404);
  if(!['GET','POST'].includes(method))return response({ok:false,error:'Method not allowed'},405);
  if(!originAllowed(request,request.headers.get('Origin')))return response({ok:false,error:'Origin not allowed'},403);
  if(!await adminAuthenticated(request,env))return response({ok:false,error:'Unauthorized'},401);
  const db=env?.DB;
  if(!db?.prepare||!db?.batch)return response({ok:false,error:'Database unavailable'},503);
  if(method==='GET'){
   const page=pageIndex(url.searchParams.get('page'));if(page===null)return response({ok:false,error:'Invalid page'},400);
   try{
    const sql="SELECT t.case_id,t.trashed_unix,t.purge_unix,c.topic FROM asc_feedback_unknown_trash t "+
      "JOIN asc_feedback_cases c ON c.id=t.case_id WHERE c.removed=1 AND c.kind='feedback' "+
      "AND (c.claimed_user_id IS NULL OR TRIM(c.claimed_user_id)='') "+
      "ORDER BY t.purge_unix ASC,t.case_id ASC LIMIT 26 OFFSET ?";
    const rows=(await db.prepare(sql).bind(page*25).all()).results||[];
    return response({ok:true,adminOnly:true,page,pageSize:25,hasMore:rows.length>25,
     items:rows.slice(0,25).map(r=>({id:r.case_id,topic:r.topic,kind:'feedback',trashedAt:Number(r.trashed_unix),purgeAt:Number(r.purge_unix)}))});
   }catch{return response({ok:false,error:'Trash list unavailable'},503)}
  }
  if(!/application\/json/i.test(request.headers.get('Content-Type')||''))
   return response({ok:false,error:'Expected JSON'},415);
  const raw=await request.text();
  if(raw.length>512)return response({ok:false,error:'Invalid payload size'},413);
  let body;try{body=JSON.parse(raw)}catch{return response({ok:false,error:'Invalid JSON'},400)}
  if(!body||typeof body!=='object'||Array.isArray(body)||
    Object.keys(body).some(k=>!['action','id','confirm'].includes(k)))
   return response({ok:false,error:'Invalid payload'},400);
  const {action,id,confirm}=body;
  if(!['move','restore'].includes(action)||!UUID.test(id||''))return response({ok:false,error:'Invalid action or ID'},400);
  if(confirm!==(action==='move'?'MOVE UNKNOWN CASE TO TRASH':'RESTORE UNKNOWN CASE'))
   return response({ok:false,error:'Explicit confirmation required'},400);
  const now=clock();if(!okTime(now))return response({ok:false,error:'Clock unavailable'},503);
  try{
   if(action==='move'){
    const c=await db.prepare('SELECT kind,claimed_user_id,removed FROM asc_feedback_cases WHERE id=?').bind(id).first();
    if(!c||c.kind!=='feedback'||Number(c.removed)!==0||
     !(c.claimed_user_id===null||String(c.claimed_user_id).trim()===''))
     return response({ok:false,error:'Only active Feedback with no UserId can be trashed'},409);
    const batch=await db.batch([
     db.prepare('INSERT INTO asc_feedback_unknown_trash(case_id,trashed_unix,purge_unix) '+
      'SELECT id,?,? FROM asc_feedback_cases WHERE id=? AND kind=\'feedback\' AND removed=0 AND '+NO_ID)
      .bind(now,now+TRASH_SECONDS,id),
     db.prepare('UPDATE asc_feedback_cases SET removed=1,updated_unix=MAX(updated_unix+1,?) WHERE id=? AND '+
      "kind='feedback' AND removed=0 AND "+NO_ID+' AND EXISTS(SELECT 1 FROM asc_feedback_unknown_trash WHERE case_id=? AND trashed_unix=?)')
      .bind(now,id,id,now)
    ]);
    if(!changedAtLeastOnce(batch[0])||!changedAtLeastOnce(batch[1]))throw Error('Move conflict');
    return response({ok:true,adminOnly:true,action,id,trashedAt:now,purgeAt:now+TRASH_SECONDS});
   }
   const c=await db.prepare('SELECT t.purge_unix,c.removed,c.kind,c.claimed_user_id FROM asc_feedback_unknown_trash t '+
    'JOIN asc_feedback_cases c ON c.id=t.case_id WHERE t.case_id=?').bind(id).first();
   if(!c||Number(c.removed)!==1||c.kind!=='feedback'||Number(c.purge_unix)<=now||
    !(c.claimed_user_id===null||String(c.claimed_user_id).trim()===''))
    return response({ok:false,error:'Case not restorable'},409);
   const batch=await db.batch([
    db.prepare('UPDATE asc_feedback_cases SET removed=0,updated_unix=MAX(updated_unix+1,?) WHERE id=? AND '+
      "removed=1 AND kind='feedback' AND "+NO_ID+' AND EXISTS(SELECT 1 FROM asc_feedback_unknown_trash t WHERE t.case_id=? AND t.purge_unix>?)')
     .bind(now,id,id,now),
    db.prepare('DELETE FROM asc_feedback_unknown_trash WHERE case_id=? AND purge_unix>? '+
      'AND EXISTS(SELECT 1 FROM asc_feedback_cases WHERE id=? AND removed=0)').bind(id,now,id)
   ]);
   if(!changedAtLeastOnce(batch[0])||!changedAtLeastOnce(batch[1]))throw Error('Restore conflict');
   return response({ok:true,adminOnly:true,action,id,restoredAt:now});
  }catch{return response({ok:false,error:'Unknown Trash case changed or operation failed'},409)}
 };
}

/** Call only from Worker scheduled() or trusted authenticated internal job.
 * Without a configured Cron, NO auto-purge happens. Never expose a public purge URL.
 */
export async function purgeExpiredUnknownTrash(db,now=Math.floor(Date.now()/1000),limit=50){
 if(!db?.prepare||!db?.batch||!okTime(now)||!Number.isInteger(limit)||limit<1||limit>100)
  throw Error('Invalid scheduled purge context');
 const elig='SELECT t.case_id FROM asc_feedback_unknown_trash t JOIN asc_feedback_cases c ON c.id=t.case_id '+
   "WHERE t.case_id=? AND t.purge_unix<=? AND c.removed=1 AND c.kind='feedback' "+
   "AND (c.claimed_user_id IS NULL OR TRIM(c.claimed_user_id)='')";
 const due=(await db.prepare('SELECT t.case_id FROM asc_feedback_unknown_trash t JOIN asc_feedback_cases c ON c.id=t.case_id '+
   "WHERE t.purge_unix<=? AND c.removed=1 AND c.kind='feedback' "+
   "AND (c.claimed_user_id IS NULL OR TRIM(c.claimed_user_id)='') "+
   'ORDER BY t.purge_unix,t.case_id LIMIT ?').bind(now,limit).all()).results||[];
 let purged=0;
 for(const {case_id:id} of due){
  if(!UUID.test(id))throw Error('Invalid case reference in Trash');
  const targets=['asc_feedback_followup_details_history','asc_feedback_followup_history','asc_feedback_history']
   .map(table=>db.prepare('DELETE FROM '+table+' WHERE case_id IN ('+elig+')').bind(id,now));
  targets.push(db.prepare('DELETE FROM asc_feedback_cases WHERE id IN ('+elig+')').bind(id,now));
  // Single D1 transaction, deletes all history + original case; FK cascades Trash marker.
  const result=await db.batch(targets);
  // A successful case deletion can report 2+ changes due to ON DELETE CASCADE.\n  if(changedAtLeastOnce(result[3]))purged++;
 }
 return {purged,examined:due.length,nowUnix:now};
}
