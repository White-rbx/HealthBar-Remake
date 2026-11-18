/**
 * ArcScriptCenter — native Admin Dashboard Trash callbacks (STAGING).
 * Plug into the EXISTING User's Case UI; do not add another Admin login.
 * Existing Admin Key remains in the dashboard's in-memory state only.
 * No key stored in URLs, localStorage, sessionStorage, cookies or logs.
 *
 * In the native app after Admin unlock:
 * const trashCallbacks=createTrashDashboardCallbacks({
 *   getAdminKey:()=>faState.key
 * });
 * mountUsersCaseSection(page,{
 *   ...existingAdminCallbacks,
 *   ...trashCallbacks
 * });
 * The service-bound Worker rechecks authorization server-side.
 */
const API_BASE='https://arcscriptcenter-trash-admin-staging.kogpasan14.workers.dev';
const API_ROUTE='/api/v1/admin/feedback/unknown-trash';
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function createTrashDashboardCallbacks({getAdminKey,fetchImpl=globalThis.fetch}={}){
 if(typeof getAdminKey!=='function'||typeof fetchImpl!=='function')
  throw new Error('Existing Admin session and fetch are required');
 async function invoke({page=0,method='GET',payload}={}){
  if(!Number.isSafeInteger(page)||page<0||page>9999)throw Error('Invalid Trash page');
  const key=getAdminKey();
  if(typeof key!=='string'||key.length<32)
   throw Error('Unlock existing Admin access first');
  const url=API_BASE+API_ROUTE+(method==='GET'?'?page='+page:'');
  const response=await fetchImpl(url,{
   method,mode:'cors',credentials:'omit',cache:'no-store',redirect:'error',
   headers:{Accept:'application/json','X-Admin-Key':key,
    ...(method==='POST'?{'Content-Type':'application/json'}:{})},
   ...(method==='POST'?{body:JSON.stringify(payload)}:{})
  });
  // A locked / switched tab cannot paint a stale sensitive response.
  if(getAdminKey()!==key)throw Error('Admin session changed');
  let data;
  try{data=await response.json()}catch{throw Error('Invalid Trash API response')}
  if(!response.ok||data?.ok!==true||data?.adminOnly!==true)
   throw Error(data?.error||('Trash API returned HTTP '+response.status));
  return data;
 }
 async function mutate(action,id){
  if(!['move','restore'].includes(action)||!UUID.test(id||''))
   throw Error('Invalid Trash case');
  const confirmation=action==='move'?'MOVE UNKNOWN CASE TO TRASH':'RESTORE UNKNOWN CASE';
  const r=await invoke({method:'POST',payload:{action,id,confirm:confirmation}});
  if(r.action!==action||r.id!==id)throw Error('Unexpected Trash operation response');
  return r;
 }
 return Object.freeze({
  loadTrash:page=>invoke({page}),
  moveUnknownCaseToTrash:id=>mutate('move',id),
  restoreUnknownCase:id=>mutate('restore',id)
 });
}
