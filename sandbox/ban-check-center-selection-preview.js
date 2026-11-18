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
 const note=node('p','STAGING Preview: selections are visible, but saving is disabled until the Ban API supports Selection + Duration. Existing bans are not modified.','field-note');
 note.id='banModeNotice';note.setAttribute('role','status');note.style.gridColumn='1 / -1';
 grid.insertBefore(selection.wrap,grid.firstChild);
 grid.insertBefore(duration.wrap,selection.wrap.nextSibling);
 grid.insertBefore(note,duration.wrap.nextSibling);
 const list=new Map();let loadId=0;let locked=true;
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
  const key=keyField.value;
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
   if(generation!==loadId||keyField.value!==key)return;
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
 document.getElementById('banUnlock')?.addEventListener('click',()=>setTimeout(reload,1500));
 document.getElementById('banRefresh')?.addEventListener('click',()=>setTimeout(reload,150));
 document.getElementById('banLock')?.addEventListener('click',()=>{
  loadId++;list.clear();locked=true;selection.select.value='';duration.select.value='permanent';syncDuration();
  updateCards();status('Locked. Existing Admin session and list are cleared from this preview.');
 });
 document.getElementById('banClear')?.addEventListener('click',()=>{
  selection.select.value='';duration.select.value='permanent';syncDuration()
 });
 // PREVIEW-ONLY: The existing submit script serializes v1 fields and would
 // silently discard Selection; stop the submit BEFORE the original listener.
 form.addEventListener('submit',e=>{
  e.preventDefault();e.stopImmediatePropagation();
  status('Preview only: no ban was saved. Backend schema v2 and a reviewed Admin POST are required.');
 },true);
 duration.select.value='permanent';syncDuration();updateCards();
})();
