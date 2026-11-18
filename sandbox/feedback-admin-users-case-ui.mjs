/**
 * ArcScriptCenter STAGING: small native Admin Dashboard User's Case section.
 * REVIEW ONLY — mount inside existing authenticated Feedback & Appeal page.
 * No new admin key field/session, no public case list, no credentials in storage.
 */
import {normalizeUserQuery} from './feedback-admin-roblox-directory.mjs';
export const MAX_USER_QUERY=40;
export function normalizeUserSearch(s){return normalizeUserQuery(s)}
export function userLabel(u){
 if(u?.unlinked||!u?.claimedUserId)return 'Unknown / Unlinked';
 const p=u.profile;
 if(p&&p.source==='roblox_public_directory'&&p.ownershipVerified===false&&
    typeof p.username==='string'&&typeof p.displayName==='string')
  return `${p.displayName} (@${p.username}) · UserId ${u.claimedUserId} — unverified case claim`;
 return `UserId ${u.claimedUserId} (unverified)`;
}
export function caseStatus(s){
 return ({reviewing:'Reviewing',approved:'Approved · Closed',denied:'Denied · Closed',
  violation:'Flagged (Policy) · Closed',spam_mail:'Spam Mail · Admin only'})[s]||'Unknown status';
}
function el(doc,tag,text,className){
 const node=doc.createElement(tag);
 if(text!==undefined&&text!==null)node.textContent=String(text);
 if(className)node.className=className;
 return node;
}
/**
 * @param {HTMLElement} host existing private Feedback & Appeal page
 * @param {{loadUsers:(search:string,page:number)=>Promise<any>,
 * loadCases:(subject:string,page:number)=>Promise<any>,
 * onOpenCase:(caseId:string)=>void,
 * isAdminUnlocked:()=>boolean}} api
 */
export function mountUsersCaseSection(host,api){
 if(!host||!api||['loadUsers','loadCases','onOpenCase','isAdminUnlocked'].some(k=>typeof api[k]!=='function'))
  throw Error('Existing Admin Dashboard callbacks required');
 if(host.querySelector('[data-asc-users-case]'))throw Error("User's Case already mounted");
 const doc=host.ownerDocument;
 const section=el(doc,'section',null,'fa-users-case');
 section.dataset.ascUsersCase='true';section.hidden=true;
 const heading=el(doc,'h3',"User's Case");
 const help=el(doc,'p','Search Username, Display Name or UserId. Leave blank to show all. Names come from public Roblox profiles; case ownership remains unverified.','fa-help');
 const form=el(doc,'form');form.setAttribute('role','search');
 const search=el(doc,'input');search.type='search';search.placeholder='Search Username / Display Name / UserId (empty = all)';
 search.inputMode='search';search.autocomplete='off';search.maxLength=MAX_USER_QUERY;
 search.setAttribute('aria-label','Search User');
 const find=el(doc,'button','Search');find.type='submit';
 form.append(search,find);
 const message=el(doc,'p','','fa-muted');message.setAttribute('role','status');
 const list=el(doc,'div');list.setAttribute('aria-label','User case list');
 const cases=el(doc,'div');cases.setAttribute('aria-label','Selected user cases');
 const prev=el(doc,'button','Previous');prev.type='button';
 const next=el(doc,'button','Next');next.type='button';
 const paging=el(doc,'div');paging.append(prev,next);
 section.append(heading,help,form,message,list,cases,paging);
 host.append(section);
 let generation=0,currentQuery='',page=0,activeSubject=null,busy=false;
 function clear(node){node.replaceChildren()}
 function locked(){if(api.isAdminUnlocked())return false;section.hidden=true;clear(list);clear(cases);message.textContent='';return true}
 async function loadUsers(){
  if(locked())return;
  const stamp=++generation;busy=true;find.disabled=prev.disabled=next.disabled=true;
  clear(list);clear(cases);message.textContent='Loading users…';
  try{
   const data=await api.loadUsers(currentQuery,page);
   if(stamp!==generation||locked())return;
   if(data?.ok!==true||data?.adminOnly!==true||!Array.isArray(data.users))throw Error('Unexpected admin API result');
   for(const u of data.users){
    const button=el(doc,'button');button.type='button';button.className='fa-user-row';
    const user=userLabel(u);const caption=`${u.total||0} cases · Review ${u.reviewing||0} · Approved ${u.approved||0} · Denied ${u.denied||0} · Flagged ${u.flagged||0}`;
    button.append(el(doc,'span',user),el(doc,'small',caption));
    const subject=u.unlinked||!u.claimedUserId?'unlinked':String(u.claimedUserId);
    button.addEventListener('click',()=>loadCases(subject,0));list.append(button);
   }
   if(!data.users.length)message.textContent='No matching users.';
   else message.textContent=`Showing page ${page+1} · ${data.users.length} groups`;
   prev.disabled=page===0;next.disabled=!data.hasMore;
  }catch{
   if(stamp===generation)message.textContent='Cannot load users. Check Admin login and retry.';
  }finally{if(stamp===generation){busy=false;find.disabled=false;}}
 }
 async function loadCases(subject,userPage){
  if(locked())return;
  const stamp=++generation;activeSubject=subject;clear(cases);
  const title=el(doc,'h4',subject==='unlinked'?'Unknown / Unlinked':`UserId ${subject} (unverified)`);cases.append(title);
  const status=el(doc,'p','Loading cases…');cases.append(status);
  try{
   const data=await api.loadCases(subject,userPage);
   if(stamp!==generation||locked())return;
   status.textContent=data.cases?.length?'Select a case to open the existing Admin review.':'No cases found.';
   if(data?.ok!==true||data?.adminOnly!==true||!Array.isArray(data.cases))throw Error('Invalid case list');
   for(const item of data.cases){
    const row=el(doc,'button');row.type='button';row.className='fa-case-row';
    row.append(el(doc,'span',`${item.kind} · ${caseStatus(item.status)}`),el(doc,'small',item.topic||'Untitled case'));
    row.addEventListener('click',()=>{if(!locked())api.onOpenCase(item.id)});
    cases.append(row);
   }
   const navigation=el(doc,'div');
   const back=el(doc,'button','Previous');back.type='button';back.disabled=userPage===0;
   back.addEventListener('click',()=>loadCases(subject,userPage-1));
   const forward=el(doc,'button','Next');forward.type='button';forward.disabled=!data.hasMore;
   forward.addEventListener('click',()=>loadCases(subject,userPage+1));
   navigation.append(back,forward);cases.append(navigation);
  }catch{if(stamp===generation)status.textContent='Unable to load cases.';}
 }
 form.addEventListener('submit',event=>{
  event.preventDefault();if(busy||locked())return;
  try{currentQuery=normalizeUserSearch(search.value);page=0;activeSubject=null;loadUsers()}
  catch(e){message.textContent=e.message;}
 });
 prev.addEventListener('click',()=>{if(page>0&&!busy){page--;loadUsers();}});
 next.addEventListener('click',()=>{if(!busy){page++;loadUsers();}});
 return {refresh(){if(locked())return;section.hidden=false;return loadUsers()},
   close(){generation++;section.hidden=true;clear(list);clear(cases);search.value='';currentQuery='';activeSubject=null;page=0},
   destroy(){generation++;section.remove()}};
}
