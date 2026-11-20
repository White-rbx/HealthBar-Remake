'use strict';
(() => {
 const byId=id=>document.getElementById(id);
 const form=byId('banEditorForm');
 if(!form||!byId('page-bans')||!byId('banUnlock')||!byId('banRecords'))return;
 const stagingGitHub=false;
 const label=stagingGitHub?'STAGING GitHub':'QA';
 const base=stagingGitHub?'https://arcscriptcenter-api-staging.kogpasan14.workers.dev':
  'https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev';
 const route='/api/v1/admin/bans/v2/manage';
 const shaPattern=/^[a-f0-9]{40}$/;
 const expectedSource=stagingGitHub?'staging-github':'isolated-qa';
 let key='',sha='',entries=[],busy=false,generation=0,request;
 let pending=null, editingId=null, editSha='', needsReload=false, ownStatus='';
 const formFields=form.querySelector('.form-grid');
 const save=byId('banSave'),refresh=byId('banRefresh'),records=byId('banRecords');
 const filter=byId('banSearch');
 const fields={userId:byId('banUserId'),username:byId('banUsername'),reason:byId('banReason'),
  description:byId('banDescription'),startAt:byId('banStart'),expiresAt:byId('banEnd')};
 if(!formFields||!save||!refresh||!filter||Object.values(fields).some(field=>!field))return;

 const panel=byId('page-bans');
 function copy(selector,text){
  const element=panel.querySelector(selector);
  if(element)element.textContent=text;
 }
 copy('.page-head .eyebrow','Moderation / '+label);
 copy('.page-head p','Manage ExperienceSettings access for authorized test accounts.');
 copy('.readonly-ribbon',stagingGitHub
  ?'Saves update the dedicated STAGING GitHub test source.'
  :'Saves update the isolated QA ban list.');
 copy('.split .info-strip > div','The Roblox test server checks this policy when a player starts or rejoins.');
 const oldSource=panel.querySelector('a[href$="/blob/loadstring/ExperienceSettings-SetUp.lua"]');
 if(oldSource){
  const target=oldSource.parentElement;
  if(stagingGitHub){
   oldSource.href='https://github.com/White-rbx/HealthBar-Remake/blob/banned-check-center-staging-data/sandbox/banned-check-center-source-STAGING.lua';
   oldSource.textContent='Dedicated STAGING GitHub ban source';
   target.replaceChildren(oldSource);
  }else target.textContent='Data source: isolated QA D1';
 }
 const listPanel=records.closest('.panel');
 const listTitle=listPanel?.querySelector('h3');
 const listDescription=listPanel?.querySelector('.panel-top p');
 if(listTitle)listTitle.textContent=label+' ban records';
 if(listDescription)listDescription.textContent='Legacy entries retain Ban in-game behavior.';

 function addSelect(id,label,options) {
  const field=document.createElement('div');field.className='field';
  const caption=document.createElement('label');caption.htmlFor=id;caption.textContent=label;
  const selection=document.createElement('select');selection.id=id;selection.required=true;
  for(const [value,text] of options){
   const option=new Option(text,value);
   selection.add(option);
  }
  field.append(caption,selection);
  formFields.prepend(field);
  return selection;
 }
 fields.duration=addSelect('banV2Duration','Ban Duration',[['permanent','Permanent'],['temporary','Temporary']]);
 fields.selection=addSelect('banV2Selection','Ban Selection',[['','Choose Ban Selection'],['ban_ingame','Ban in-game'],['restricted_mode','Restricted Mode']]);
 const legacyOption=new Option('Legacy · Ban in-game','unassigned');
 fields.expiresAt.parentElement.querySelector('.field-note')?.remove();
 const note=document.createElement('p');
 note.className='field-note';
 note.textContent=label+' bans. Use authorized test IDs. Date and time are in ICT (UTC+7).';
 form.prepend(note);
 save.textContent='Save '+label+' Ban';
 refresh.textContent='Load '+label+' Bans';

 const confirmation=document.createElement('section');
 confirmation.id='banV2Confirmation';
 confirmation.className='panel panel-pad';
 confirmation.hidden=true;
 confirmation.setAttribute('aria-labelledby','banV2ConfirmTitle');
 const confirmTitle=document.createElement('h3');
 confirmTitle.id='banV2ConfirmTitle';
 const confirmSummary=document.createElement('p');
 const confirmActions=document.createElement('div');confirmActions.className='form-actions';
 const cancelButton=document.createElement('button');
 cancelButton.type='button';cancelButton.className='btn';cancelButton.textContent='Cancel';
 const confirmButton=document.createElement('button');
 confirmButton.type='button';confirmButton.className='btn btn-primary';
 confirmActions.append(cancelButton,confirmButton);
 confirmation.append(confirmTitle,confirmSummary,confirmActions);
 form.after(confirmation);
 const draftStatus=document.createElement('p');
 draftStatus.className='field-note';
 draftStatus.setAttribute('aria-live','polite');
 note.after(draftStatus);

 function on(el,event,fn){el.addEventListener(event,e=>{e.preventDefault();e.stopImmediatePropagation();fn(e);},true);}
 function syncDuration(){
  const temporary=fields.duration.value==='temporary';
  fields.expiresAt.disabled=!temporary;
  fields.expiresAt.required=temporary;
  if(!temporary)fields.expiresAt.value='';
 }
 function clear(){
  form.reset();
  legacyOption.remove();
  editingId=null;editSha='';
  fields.userId.readOnly=false;
  draftStatus.textContent='';
  syncDuration();
 }
 function updateControls(){
  byId('banLock').disabled=!key;
  refresh.disabled=!key||busy||!!pending;
  const canWrite=!!sha&&!needsReload&&!busy&&!pending;
  save.disabled=!canWrite||!!editingId&&editSha!==sha;
  save.textContent=editingId?'Review Edit':'Save '+label+' Ban';
  byId('banClear').disabled=busy||!!pending;
  for(const button of records.querySelectorAll('button'))button.disabled=!canWrite;
 }
 function setStatus(message,error=false){
  const status=byId('banConnectionStatus');
  ownStatus=message;
  status.textContent=message;
  status.style.color=error?'var(--danger)':'var(--muted)';
  byId('banBadge').textContent=needsReload?'RELOAD REQUIRED':(sha?label+' SOURCE':(key?'LOAD REQUIRED':'LOCKED'));
  byId('banCount').textContent=entries.length+' ENTRIES';
  const navCount=byId('banNavCount');
  if(navCount)navCount.textContent=String(entries.length);
  updateControls();
 }
 function title(entry){
  return entry.selection==='restricted_mode'?'Restricted Mode':
   (entry.selection==='unassigned'?'Ban in-game · Legacy':'Ban in-game');
 }
 function edit(entry){
  if(!sha||needsReload||busy||pending)return;
  clear();
  editingId=entry.userId;
  editSha=sha;
  if(entry.selection==='unassigned')fields.selection.add(legacyOption);
  for(const [name,field] of Object.entries(fields)){
   const value=String(entry[name]??'');
   field.value=name==='startAt'||name==='expiresAt'?value.replace(' ','T'):value;
  }
  fields.userId.readOnly=true;
  syncDuration();
  draftStatus.textContent='Editing User ID '+entry.userId+'. Select Review Edit to confirm your changes.';
  updateControls();
  form.scrollIntoView({block:'start'});
  fields.selection.focus({preventScroll:true});
 }
 function closeConfirmation(restoreFocus=false){
  const trigger=pending?.trigger;
  pending=null;
  confirmation.hidden=true;
  updateControls();
  if(restoreFocus&&trigger?.isConnected)trigger.focus();
 }
 function review(change,entry,trigger){
  if(!sha||needsReload||busy||pending)return;
  const removing=change.action==='remove';
  pending={change,trigger};
  confirmTitle.textContent=removing?'Confirm removal':(editingId?'Confirm edit':'Confirm new ban');
  confirmSummary.textContent=[(entry.username||'User ID')+' · '+entry.userId,title(entry),
   entry.duration==='temporary'?'Temporary':'Permanent',entry.startAt?'Starts '+entry.startAt+' ICT':'',
   entry.expiresAt?'Expires '+entry.expiresAt+' ICT':'',entry.reason].filter(Boolean).join(' · ');
  confirmButton.textContent=removing?'Confirm Remove':(editingId?'Confirm Edit':'Confirm Save');
  confirmButton.className=removing?'btn btn-danger':'btn btn-primary';
  confirmation.hidden=false;
  updateControls();
  confirmation.scrollIntoView({block:'nearest'});
  cancelButton.focus({preventScroll:true});
 }
 cancelButton.addEventListener('click',()=>closeConfirmation(true));
 confirmation.addEventListener('keydown',event=>{
  if(event.key==='Escape'){event.preventDefault();closeConfirmation(true);}
 });
 confirmButton.addEventListener('click',()=>{
  if(!pending||busy)return;
  const {change}=pending;
  closeConfirmation();
  void load({...change,confirmed:true});
 });
 function render(){
  records.replaceChildren();
  const needle=filter.value.trim().toLowerCase();
  if(!sha){records.textContent=key?'Load the '+label+' list before editing.':'Unlock to load bans.';return;}
  const rows=entries.filter(entry=>[entry.userId,entry.username,entry.reason].some(text=>text.toLowerCase().includes(needle)));
  for(const entry of rows){
   const card=document.createElement('div');card.className='quick-row';
   const content=document.createElement('div');
   const name=document.createElement('strong');name.textContent=[entry.username,entry.userId].filter(Boolean).join(' · ');
   const type=document.createElement('div');
   type.textContent=[title(entry),entry.duration==='temporary'?'Temporary':'Permanent',
    entry.startAt?'From '+entry.startAt+' ICT':'',entry.expiresAt?'Until '+entry.expiresAt+' ICT':''].filter(Boolean).join(' · ');
   const reason=document.createElement('div');reason.textContent=entry.reason;
   const description=document.createElement('small');description.textContent=entry.description;
   content.append(name,type,reason,description);
   const actions=document.createElement('div');
   const editButton=document.createElement('button');
   editButton.type='button';editButton.className='btn btn-sm';editButton.textContent='Edit';
   editButton.addEventListener('click',()=>edit(entry));
   const removeButton=document.createElement('button');
   removeButton.type='button';removeButton.className='btn btn-sm';removeButton.textContent='Remove';
   removeButton.addEventListener('click',()=>review({action:'remove',userId:entry.userId,expectedSha:sha},entry,removeButton));
   actions.append(editButton,removeButton);
   card.append(content,actions);records.append(card);
  }
  if(!rows.length)records.textContent=entries.length?'No matching bans.':'No '+label+' bans saved.';
 }
 async function fetchList(adminKey,sessionSignal,change){
  const headers={Accept:'application/json','X-Admin-Key':adminKey};
  if(change)headers['Content-Type']='application/json';
  const controller=new AbortController();
  const abort=()=>controller.abort();
  if(sessionSignal.aborted)abort();
  else sessionSignal.addEventListener('abort',abort,{once:true});
  const timeout=setTimeout(abort,20000);
  try{
   const response=await fetch(base+route,{
    method:change?'POST':'GET',headers,cache:'no-store',credentials:'omit',redirect:'error',
    body:change?JSON.stringify(change):undefined,signal:controller.signal,
   });
   const data=await response.json().catch(()=>null);
   if(!response.ok||data?.ok!==true){
    throw Object.assign(Error(data?.error||'Request failed (HTTP '+response.status+').'),{status:response.status,code:data?.code});
   }
   if(data.source!==expectedSource||!shaPattern.test(data.sha)||data.document?.schema!==2||!Array.isArray(data.document.entries)){
    throw Error('The server returned an unexpected ban source or list.');
   }
   return data;
  }finally{clearTimeout(timeout);sessionSignal.removeEventListener('abort',abort);}
 }
 const useList=data=>{sha=data.sha;entries=data.document.entries;needsReload=false;};
 function verifyChange(data,change){
  const target=change.userId??change.entry.userId;
  const saved=data.document.entries.find(row=>row.userId===target);
  return change.action==='remove'?!saved:!!saved&&Object.entries(change.entry).every(([field,value])=>saved[field]===value);
 }
 async function load(change){
  if(!key||busy||pending||change&&(!sha||needsReload||change.expectedSha!==sha))return;
  const epoch=++generation;
  const adminKey=key;
  request=new AbortController();busy=true;
  const signal=request.signal;
  setStatus(change?'Submitting confirmed change…':'Loading '+label+' bans…');
  let message='',error=false;
  let submitted=false;
  try{
   if(change){
    const written=await fetchList(adminKey,signal,change);
    if(epoch!==generation)return;
    if(written.saved!==true&&written.unchanged!==true)throw Error('The server did not confirm the write.');
    submitted=true;
    setStatus('Checking the saved state on the server…');
   }
   const fresh=await fetchList(adminKey,signal);
   if(epoch!==generation)return;
   useList(fresh);
   if(change){
    if(!verifyChange(fresh,change)){
     if(editingId)editSha='';
     throw new Error('The server list did not match the confirmed change. Review the current list before retrying.');
    }
    if(change.action!=='remove'||editingId===change.userId)clear();
    else if(editingId&&editSha!==sha)draftStatus.textContent='The list changed. Edit the row again or clear this draft.';
    message=change.action==='remove'?'Ban removed. The server list confirms it is gone.':'Ban saved and verified from the server.';
   }else{
    if(editingId&&editSha!==sha)draftStatus.textContent='The list changed. Edit the row again or clear this draft.';
    message=label+' bans loaded.';
   }
  }catch(e){
   if(epoch!==generation)return;
   error=true;
   if(e.status===401){
    key='';sha='';entries=[];needsReload=false;
    clear();
    message='Admin authentication failed. Unlock again.';
   }else if(e.status===409){
    needsReload=true;
    message='The list changed on the server. Load bans, then edit the row again.';
   }else if(e.code==='target_not_allowed'){
    message='This User ID is outside the authorized QA test scope.';
   }else if(e.status===400&&!submitted){
    message='Change rejected. '+e.message;
   }else{
    needsReload=true;
    message=change?(submitted?'The server accepted the request, but the result was not verified. Load bans to check. ':'Change not confirmed. Load bans before retrying. ')+e.message
     :'Could not load bans. '+e.message;
   }
  }finally{
   if(epoch===generation){busy=false;request=null;refreshOwned();setStatus(message,error);}
  }
 }
 // Capture the existing password field before the native Unlock handler clears it.
 // Keep its original listener for the Dashboard's other Admin panels. The Ban
 // records/form are then owned by the scoped v2 controller in this Preview.
 byId('banUnlock').addEventListener('click',()=>{
  const candidate=byId('banAdminKey').value.trim();
  if(candidate.length<32||candidate.length>4096)return;
  // Cancel an outstanding load/write before adopting a new admin session.
  generation++;request?.abort();busy=false;key=candidate;sha='';entries=[];needsReload=false;closeConfirmation();clear();
  queueMicrotask(()=>load());
 },true);
 byId('banLock').addEventListener('click',()=>{
  generation++;request?.abort();request=null;key='';sha='';entries=[];busy=false;needsReload=false;closeConfirmation();
  // Allow the original lock listener to clear its key for the other Admin panels.
  byId('banAdminKey').value='';
  queueMicrotask(()=>{clear();setStatus('Locked.');refreshOwned();});
 },true);
 // Native unlock also fetches the original read-only list for other panels.
 // Ignore its rendering while our controller owns the Ban Center list.
 const observer=new MutationObserver(()=>{
  if(records.dataset.banV2Rendered!=='1'||!records.firstChild||!owned.has(records.firstChild))refreshOwned();
 });
 const owned=new WeakSet();
 function refreshOwned(){
  render();
  records.dataset.banV2Rendered='1';
  if(records.firstChild)owned.add(records.firstChild);
  updateControls();
 }
 observer.observe(records,{childList:true});
 const nativeStatus=byId('banConnectionStatus');
 const statusObserver=new MutationObserver(()=>{
  if(nativeStatus.textContent!==ownStatus&&/Writing GitHub|Reading GitHub|Connected ·|Could not load bans/i.test(nativeStatus.textContent)){
   nativeStatus.textContent=ownStatus;
   updateControls();
  }
 });
 statusObserver.observe(nativeStatus,{childList:true});
 on(refresh,'click',()=>load());
 on(byId('banClear'),'click',()=>{if(!busy&&!pending){clear();updateControls();}});
 on(filter,'input',refreshOwned);
 fields.duration.addEventListener('change',syncDuration);
 function reviewForm(event){
  if(!sha||needsReload||busy||pending||editingId&&editSha!==sha||!form.reportValidity())return;
  const entry=Object.fromEntries(Object.entries(fields).map(([name,field])=>[name,field.value.trim()]));
  entry.startAt=entry.startAt.replace('T',' ');entry.expiresAt=entry.expiresAt.replace('T',' ');
  review({action:'upsert',entry,expectedSha:editingId?editSha:sha},entry,event.submitter??save);
 }
 on(form,'submit',reviewForm);
 on(save,'click',reviewForm);
 clear();setStatus('Locked. Unlock to load '+label+' bans.');refreshOwned();
})();
