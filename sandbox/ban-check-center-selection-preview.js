/* ArcScriptCenter — Native Banned Check Center Ban Selection PREVIEW.
 * Adds fields to the EXISTING banEditorForm and labels to banRecords.
 * Reuses the existing Ban Center Admin Key input. Never logs or stores it.
 * IMPORTANT: Existing staging /admin/bans GET is read-only and its schema is v1.
 * This preview intentionally blocks all ban POSTs rather than claiming to save
 * Selection/Duration fields that the backend does not yet persist.
 */
(()=>{'use strict';
 const panel=document.getElementById('page-bans');
 const form=document.getElementById('banEditorForm');
 const records=document.getElementById('banRecords');
 const keyField=document.getElementById('banAdminKey');
 const endField=document.getElementById('banEnd');
 if(!panel||!form||!records||!keyField||!endField||document.getElementById('banSelection'))return;
 const grid=form.querySelector('.form-grid');
 if(!grid)return;
 const doc=panel.ownerDocument;
 const node=(tag,text,cls)=>{const el=doc.createElement(tag);if(text!==undefined)el.textContent=text;if(cls)el.className=cls;return el};
 const field=(id,labelText,options)=>{
  const wrap=node('div',undefined,'field');
  const label=node('label',labelText);label.htmlFor=id;
  const select=node('select');select.id=id;select.className='search';select.required=true;
  for(const [value,title] of options){const option=node('option',title);option.value=value;select.append(option)}
  wrap.append(label,select);return {wrap,select};
 };
 const selection=field('banSelection','Ban Selection *',[
  ['','Choose Ban Selection'],['ban_ingame','Ban in-game — SetUp only'],['restricted_mode','Restricted Mode — limited Main Loader']
 ]);
 const duration=field('banDuration','Ban Duration *',[
  ['temporary','Temporary — expires at the date below'],['permanent','Permanent — no expiry']
 ]);
 const note=node('p','STAGING Preview: GitHub saving is disabled until the Ban API supports Selection + Duration. Save to QA Sandbox stores test records only.','field-note');
 note.id='banModeNotice';note.setAttribute('role','status');note.style.gridColumn='1 / -1';
 grid.insertBefore(selection.wrap,grid.firstChild);
 grid.insertBefore(duration.wrap,selection.wrap.nextSibling);
 grid.insertBefore(note,duration.wrap.nextSibling);
 const list=new Map();let loadId=0;let locked=true;
 // The original native Ban Unlock handler clears its input after reading.
 // Capture that same key ONLY in this tab's closure, before it is cleared.
 // No second Login, URL parameters, cookies or browser storage.
 let sessionKey='';
 const qaEndpoint='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/qa';
 const compatEndpoint='https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/admin/bans/v2/compatibility';
 const qaState={revision:0,entries:[],loaded:false,busy:false};

 const idMatch=/User ID ([1-9][0-9]{0,15})/;
 const status=msg=>{note.textContent=msg};
 const classify=e=>{
  const mode=e?.selection==='ban_ingame'?'Ban in-game':
   e?.selection==='restricted_mode'?'Restricted Mode':'Selection not set (legacy: SetUp-only)';
  const length=e?.expiresAt?'Temporary':'Permanent';
  return {mode,length};
 };
 function syncDuration(){
  endField.required=duration.select.value==='temporary';
  if(duration.select.value==='permanent')endField.value='';
 }
 duration.select.addEventListener('change',syncDuration);
 endField.addEventListener('change',()=>{duration.select.value=endField.value?'temporary':'permanent';syncDuration()});
 function updateCards(){
  for(const card of records.querySelectorAll('.quick-row')){
   const name=card.querySelector('strong');
   const id=idMatch.exec(name?.textContent||'')?.[1];
   if(!id)continue;
   const item=list.get(id);
   const {mode,length}=classify(item);
   let label=card.querySelector('[data-ban-mode-label]');
   if(!label){label=node('small');label.dataset.banModeLabel='true';label.className='asc-ban-selection-label';label.style.display='block';label.style.marginTop='5px';name.parentElement?.append(label)}
   const value='Selection: '+mode+'  |  Duration: '+length;
   if(label.textContent!==value)label.textContent=value;
  }
 }
 async function reload(){
  const key=sessionKey;
  const generation=++loadId;
  if(typeof key!=='string'||key.length<32){
   locked=true;list.clear();updateCards();
   status('Unlock existing Banned Check Center Admin access to view saved Selection and Duration.');
   return;
  }
  try{
   const r=await fetch('https://arcscriptcenter-api-staging.kogpasan14.workers.dev/api/v1/admin/bans',{
    method:'GET',mode:'cors',credentials:'omit',cache:'no-store',redirect:'error',
    headers:{'Accept':'application/json','X-Admin-Key':key}
   });
   if(generation!==loadId||sessionKey!==key)return;
   const data=await r.json();
   if(!r.ok||data?.ok!==true||!Array.isArray(data.entries))throw Error('Not authorized or unavailable');
   list.clear();for(const entry of data.entries)if(/^[1-9][0-9]{0,15}$/.test(String(entry?.userId||'')))list.set(String(entry.userId),entry);
   locked=false;updateCards();
   status('Ban Selection and Duration are shown below. STAGING schema v1 remains read-only; no changes will be saved.');
  }catch{
   if(generation===loadId){locked=true;list.clear();updateCards();status('Cannot read Ban selections. Unlock Admin access again.')}
  }
 }
 function fillFromSelected(id){
  const item=list.get(id);
  if(!item){selection.select.value='';duration.select.value='permanent'}
  else{selection.select.value=['ban_ingame','restricted_mode'].includes(item.selection)?item.selection:'';
   duration.select.value=item.expiresAt?'temporary':'permanent';}
  syncDuration();
 }
 records.addEventListener('click',e=>{
  if(!(e.target instanceof Element)||e.target.textContent?.trim()!=='Edit')return;
  const card=e.target.closest('.quick-row');
  const id=idMatch.exec(card?.querySelector('strong')?.textContent||'')?.[1];
  if(id)queueMicrotask(()=>fillFromSelected(id));
 });
 const observer=new MutationObserver(()=>{updateCards()});
 observer.observe(records,{childList:true,subtree:true});
 document.getElementById('banUnlock')?.addEventListener('click',()=>{
  sessionKey=keyField.value.trim();
  if(sessionKey.length<32){sessionKey='';return;}
  setTimeout(()=>{void reload();void qaLoad();},850);
 },true);
 document.getElementById('banRefresh')?.addEventListener('click',()=>{
  setTimeout(()=>{void reload();void qaLoad();},150);
 });
 document.getElementById('banLock')?.addEventListener('click',()=>{
  loadId++;sessionKey='';list.clear();locked=true;
  qaState.entries=[];qaState.revision=0;qaState.loaded=false;renderQa();
  migrationResults.replaceChildren();
  selection.select.value='';duration.select.value='permanent';syncDuration();
  updateCards();status('Locked. Existing Admin session and list are cleared from this preview.');
 });
 document.getElementById('banClear')?.addEventListener('click',()=>{
  selection.select.value='';duration.select.value='permanent';syncDuration()
 });

 // Save to a separate QA D1 only. This never commits the live GitHub ban block.
 const actionRow=form.querySelector('.form-actions');
 const saveQa=node('button','Save to QA Sandbox');
 saveQa.type='button';saveQa.id='banSaveQaOnly';saveQa.className='btn btn-soft';
 const loadQaButton=node('button','Load QA Bans');
 loadQaButton.type='button';loadQaButton.id='banLoadQaOnly';loadQaButton.className='btn';
 const previewMigration=node('button','Preview Ban v1 → v2');
 previewMigration.type='button';previewMigration.id='banPreviewBanV2';previewMigration.className='btn btn-soft';
 if(actionRow)actionRow.append(saveQa,loadQaButton,previewMigration);
 const qaPanel=node('section',undefined,'panel panel-pad');
 qaPanel.id='banQaOnlyPanel';qaPanel.style.marginTop='18px';
 const qaHeading=node('h3','QA Sandbox — not active bans');
 const qaMessage=node('p','Unlock the existing Admin account to test saving Ban Selection v2. Nothing here affects Roblox users.','field-note');
 qaMessage.id='banQaStatus';qaMessage.setAttribute('role','status');
 const qaRecords=node('div');qaRecords.id='banQaRecords';qaRecords.className='list-stack';
 const migrationTitle=node('h4','GitHub Ban v1 → v2 Read-only Preview');
 migrationTitle.style.marginTop='15px';
 const migrationResults=node('div');migrationResults.id='banV2CompatibilityResults';
 const migrationNotice=node('p','Preview only. The original GitHub Ban List is never overwritten.','field-note');
 qaPanel.append(qaHeading,qaMessage,qaRecords,migrationTitle,migrationNotice,migrationResults);
 records.parentElement?.append(qaPanel);

 function qaStatus(message){qaMessage.textContent=String(message)}
 function renderQa(){
  qaRecords.replaceChildren();
  if(!qaState.loaded){qaRecords.append(node('p','QA list is locked or not loaded.'));return}
  if(qaState.entries.length===0){qaRecords.append(node('p','No QA entries.'));return}
  for(const entry of qaState.entries){
   const row=node('div',undefined,'fa-user-case-row');
   row.style.padding='10px';row.style.border='1px solid var(--line)';
   row.style.marginTop='8px';
   row.append(
    node('strong',(entry.username||'Unknown username')+' · UserId '+entry.userId+' [QA ONLY]'),
    node('p','Selection: '+(entry.selection==='restricted_mode'?'Restricted Mode':entry.selection==='ban_ingame'?'Ban in-game':'Unassigned legacy')),
    node('p','Duration: '+(entry.duration==='temporary'?'Temporary':'Permanent')+
      (entry.expiresAt?' · Until '+entry.expiresAt+' ICT':''))
   );
   const edit=node('button','Edit QA entry');edit.type='button';edit.className='btn btn-sm';
   edit.addEventListener('click',()=>{
    if(!sessionKey)return;
    doc.getElementById('banUserId').value=entry.userId;
    doc.getElementById('banUserId').readOnly=false;
    doc.getElementById('banUsername').value=entry.username;
    doc.getElementById('banReason').value=entry.reason;
    doc.getElementById('banDescription').value=entry.description;
    doc.getElementById('banStart').value=entry.startAt.replace(' ','T');
    endField.value=entry.expiresAt.replace(' ','T');
    selection.select.value=entry.selection==='unassigned'?'':entry.selection;
    duration.select.value=entry.duration;syncDuration();
    qaStatus('QA entry loaded into editor. No live ban is affected.');
   });
   row.append(edit);qaRecords.append(row);
  }
 }
 async function qaRequest(method,payload,target=qaEndpoint){
  const key=sessionKey,generation=loadId;
  if(!key||key.length<32)throw Error('Unlock the existing Admin account first');
  const response=await fetch(target,{
   method,mode:'cors',credentials:'omit',redirect:'error',cache:'no-store',
   headers:{Accept:'application/json','X-Admin-Key':key,
     ...(method==='POST'?{'Content-Type':'application/json'}:{})},
   ...(method==='POST'?{body:JSON.stringify(payload)}:{})
  });
  if(key!==sessionKey||loadId!==generation)throw Error('Admin session changed');
  let data;
  try{data=await response.json()}catch{throw Error('Invalid QA API response')}
  if(!response.ok||data?.ok!==true||data?.adminOnly!==true||data?.qaOnly!==true)
   throw Error(data?.error||'QA API returned '+response.status);
  return data;
 }
 async function qaLoad(){
  if(qaState.busy)return;
  qaState.busy=true;qaStatus('Loading isolated QA records…');
  try{
   const data=await qaRequest('GET');
   if(data.document?.schema!==2||!Array.isArray(data.document.entries)||
      !Number.isSafeInteger(data.revision))throw Error('Invalid QA schema');
   qaState.entries=data.document.entries;
   qaState.revision=data.revision;qaState.loaded=true;
   renderQa();qaStatus('QA Sandbox loaded. Revision '+data.revision+'. Never affects actual bans.');
  }catch(e){qaState.loaded=false;qaState.entries=[];renderQa();qaStatus('QA Load: '+e.message)}
  finally{qaState.busy=false}
 }
 function entryFromForm(){
  const value=id=>doc.getElementById(id).value.trim();
  return {userId:value('banUserId'),username:value('banUsername'),
   reason:value('banReason'),description:value('banDescription'),
   startAt:doc.getElementById('banStart').value.replace('T',' '),
   expiresAt:endField.value.replace('T',' '),
   selection:selection.select.value,duration:duration.select.value};
 }
 saveQa.addEventListener('click',async()=>{
  if(qaState.busy)return;
  if(!sessionKey){qaStatus('Unlock existing Admin access first.');return}
  const entry=entryFromForm();
  if(!/^[1-9][0-9]{0,15}$/.test(entry.userId)||
     !['ban_ingame','restricted_mode'].includes(entry.selection)||
     !['temporary','permanent'].includes(entry.duration)||
     (entry.duration==='temporary'&&!entry.expiresAt)||
     (entry.duration==='permanent'&&entry.expiresAt)||
     entry.reason.length<3){
   qaStatus('Invalid form: select Ban Type, Duration, and required fields.');
   return;
  }
  if(!window.confirm('Save UserId '+entry.userId+' to QA ONLY? This does not ban anyone or change GitHub.'))return;
  qaState.busy=true;saveQa.disabled=true;
  try{
   if(!qaState.loaded){qaState.busy=false;await qaLoad();qaState.busy=true}
   if(!qaState.loaded)throw Error('QA list could not be loaded');
   const result=await qaRequest('POST',{action:'upsert',entry,expectedRevision:qaState.revision});
   if(result.document?.schema!==2||!result.saved)throw Error('QA Save was not confirmed');
   qaState.entries=result.document.entries;qaState.revision=result.revision;
   qaState.loaded=true;renderQa();
   qaStatus('Saved to QA Sandbox, revision '+result.revision+'. No live ban was changed.');
  }catch(e){qaStatus('QA Save rejected: '+e.message+' (refresh QA records before retry)')}
  finally{qaState.busy=false;saveQa.disabled=false}
 });
 async function showBanMigrationPreview(){
  if(!sessionKey){qaStatus('Unlock existing Admin access first.');return}
  if(qaState.busy)return;
  qaState.busy=true;previewMigration.disabled=true;
  migrationResults.replaceChildren(node('p','Checking original Ban schema…'));
  try{
   const result=await qaRequest('GET',undefined,compatEndpoint);
   if(result.readOnly!==true||result.document?.schema!==2||
      !Array.isArray(result.document.entries)||
      ![1,2].includes(result.sourceSchema))
    throw Error('Unexpected compatibility response');
   migrationResults.replaceChildren();
   migrationResults.append(node('p',
    'Original schema: '+result.sourceSchema+' → Preview schema: 2. '+
    result.entriesRead+' entries, '+result.legacyUnassigned+
    ' legacy entries preserve SetUp-only mode.'));
   for(const e of result.document.entries){
    const row=node('div',undefined,'fa-user-case-row');
    row.style.padding='8px';row.style.marginTop='6px';
    row.append(
      node('strong',(e.username||'User')+' · UserId '+e.userId),
      node('small','Selection: '+(e.selection==='unassigned'?'Selection not set (SetUp-only)':e.selection)+
        ' · Duration: '+e.duration)
    );
    migrationResults.append(row);
   }
   qaStatus('Compatibility Preview succeeded. No GitHub changes were made.');
  }catch(e){
   migrationResults.replaceChildren(node('p','Compatibility check failed: '+e.message));
  }finally{qaState.busy=false;previewMigration.disabled=false}
 }
 previewMigration.addEventListener('click',()=>{void showBanMigrationPreview()});
 loadQaButton.addEventListener('click',()=>{void qaLoad()});
 renderQa();

 // PREVIEW-ONLY: The existing submit script serializes v1 fields and would
 // silently discard Selection; stop the submit BEFORE the original listener.
 form.addEventListener('submit',e=>{
  e.preventDefault();e.stopImmediatePropagation();
  status('GitHub Save is disabled while schema v1 is live. Use Save to QA Sandbox to test v2 only.');
 },true);
 duration.select.value='permanent';syncDuration();updateCards();
})();
