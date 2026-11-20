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
 let key='',sha='',entries=[],busy=false,generation=0,request;
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
 fields.expiresAt.parentElement.querySelector('.field-note')?.remove();
 const note=document.createElement('p');
 note.className='field-note';
 note.textContent=label+' bans. Use authorized test IDs. Date and time are in ICT (UTC+7).';
 form.prepend(note);
 save.textContent='Save '+label+' Ban';
 refresh.textContent='Load '+label+' Bans';

 function on(el,event,fn){el.addEventListener(event,e=>{e.preventDefault();e.stopImmediatePropagation();fn(e);},true);}
 function syncDuration(){
  const temporary=fields.duration.value==='temporary';
  fields.expiresAt.disabled=!temporary;
  fields.expiresAt.required=temporary;
  if(!temporary)fields.expiresAt.value='';
 }
 function clear(){
  form.reset();
  fields.userId.readOnly=false;
  syncDuration();
 }
 function setStatus(message,error=false){
  const label=byId('banConnectionStatus');
  label.textContent=message;
  label.style.color=error?'var(--danger)':'var(--muted)';
  byId('banBadge').textContent=sha?label+' SOURCE':(key?'LOAD REQUIRED':'LOCKED');
  byId('banCount').textContent=entries.length+' ENTRIES';
  byId('banNavCount').textContent=String(entries.length);
  byId('banLock').disabled=!key;
  refresh.disabled=!key||busy;
  save.disabled=!sha||busy;
 }
 function title(entry){
  return entry.selection==='restricted_mode'?'Restricted Mode':
   (entry.selection==='unassigned'?'Ban in-game · Legacy':'Ban in-game');
 }
 function edit(entry){
  for(const [name,field] of Object.entries(fields)) {
   field.value=name==='selection'&&entry[name]==='unassigned'?'':String(entry[name]??'');
   if(name==='startAt'||name==='expiresAt')field.value=field.value.replace(' ','T');
  }
  fields.userId.readOnly=true;
  syncDuration();
  fields.selection.focus();
 }
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
   for(const [label,handler] of [
    ['Edit',()=>edit(entry)],
    ['Remove',()=>{if(confirm('Remove the '+label+' ban for User ID '+entry.userId+'?')){
     load({action:'remove',userId:entry.userId,expectedSha:sha,confirmed:true});
    }}],
   ]){
    const button=document.createElement('button');button.type='button';button.className='btn btn-sm';
    button.textContent=label;button.disabled=busy;button.addEventListener('click',handler);actions.append(button);
   }
   card.append(content,actions);records.append(card);
  }
  if(!rows.length)records.textContent=entries.length?'No matching bans.':'No '+label+' bans saved.';
 }
 async function load(change){
  if(!key||busy||change&&!sha)return;
  const epoch=++generation;
  request=new AbortController();busy=true;
  const timeout=setTimeout(()=>request?.abort(),13000);
  setStatus(change?'Saving '+label+' ban…':'Loading '+label+' bans…');render();
  let message='',error=false;
  try{
   const headers={Accept:'application/json','X-Admin-Key':key};
   if(change)headers['Content-Type']='application/json';
   const response=await fetch(base+route,{
    method:change?'POST':'GET',headers,cache:'no-store',credentials:'omit',redirect:'error',
    body:change?JSON.stringify(change):undefined,signal:request.signal,
   });
   if(epoch!==generation)return;
   const data=await response.json();
   if(epoch!==generation)return;
   if(!response.ok||data.ok!==true){
    if(response.status===401){key='';sha='';entries=[];}
    if(response.status===409||response.status>=500){sha='';entries=[];}
    throw Error(data.error||'Could not complete request.');
   }
   if(!shaPattern.test(data.sha)||data.document?.schema!==2||!Array.isArray(data.document.entries))
    throw Error('Unexpected QA response.');
   sha=data.sha;entries=data.document.entries;
   if(change&&data.saved)clear();
   message=data.unchanged?'No changes to save.':(change?label+' ban saved.':label+' bans loaded.');
  }catch(e){
   if(epoch!==generation)return;
   error=true;
   message=change?'Save not confirmed. '+String(e?.message||'Load before trying again.'):String(e?.message||'Could not load ban records.');
   if(change){sha='';entries=[];}
  }finally{
   clearTimeout(timeout);
   if(epoch===generation){busy=false;request=null;setStatus(message,error);render();}
  }
 }
 // Capture the existing password field before the native Unlock handler clears it.
 // Keep its original listener for the Dashboard's other Admin panels. The Ban
 // records/form are then owned by the scoped v2 controller in this Preview.
 byId('banUnlock').addEventListener('click',()=>{
  const candidate=byId('banAdminKey').value.trim();
  if(candidate.length<32||candidate.length>4096)return;
  // Cancel an outstanding load/write before adopting a new admin session.
  generation++;request?.abort();busy=false;key=candidate;sha='';entries=[];
  queueMicrotask(()=>load());
 },true);
 byId('banLock').addEventListener('click',()=>{
  generation++;request?.abort();request=null;key='';sha='';entries=[];busy=false;
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
 }
 observer.observe(records,{childList:true});
 const nativeStatus=byId('banConnectionStatus');
 let ownStatus='';
 const statusObserver=new MutationObserver(()=>{
  if(nativeStatus.textContent!==ownStatus&&/Writing GitHub|Reading GitHub|Connected ·|Could not load bans/i.test(nativeStatus.textContent)){
   ownStatus=sha?label+' bans loaded.':(busy?'Loading '+label+' bans…':'Load bans to continue.');
   setStatus(ownStatus);
  }
 });
 statusObserver.observe(nativeStatus,{childList:true});
 on(refresh,'click',()=>load());
 on(byId('banClear'),'click',clear);
 on(filter,'input',refreshOwned);
 fields.duration.addEventListener('change',syncDuration);
 on(form,'submit',()=>{
  if(!sha||busy||!form.reportValidity())return;
  const entry=Object.fromEntries(Object.entries(fields).map(([name,field])=>[name,field.value.trim()]));
  entry.startAt=entry.startAt.replace('T',' ');entry.expiresAt=entry.expiresAt.replace('T',' ');
  if(confirm('Save '+title(entry)+' · '+entry.duration+' for User ID '+entry.userId+'?'))
   load({action:'upsert',entry,expectedSha:sha,confirmed:true});
 });
 clear();setStatus('Locked. Unlock to load '+label+' bans.');refreshOwned();
})();
