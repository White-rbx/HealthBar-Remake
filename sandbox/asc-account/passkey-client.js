// Isolated Account QA: native WebAuthn credential ceremony and existing pairing.
// No secrets, passwords or private keys are exposed to this script.
(() => {
 'use strict';
 const byId=id=>document.getElementById(id);
 const status=text=>{byId('status').textContent=String(text||'')};
 let busy=false;
 const errMessages={
  challenge_expired:'That passkey attempt expired. Start again.',
  username_unavailable:'That username cannot be registered.',
  verification_required:'Complete the verification challenge.',
  passkey_verification_failed:'The passkey could not be verified.',
  rate_limited:'Too many attempts. Try again later.',
  session_expired:'Session expired. Sign in again.',
  pairing_unavailable:'The pairing code is invalid or expired.',
  recovery_failed:'That account or recovery code could not be verified.',
  verification_unavailable:'Verification is temporarily unavailable.',
  account_qa_provisioning:'This Account QA service is not ready yet.',
  account_banned:'This account is restricted from making that change.',
  no_status_change:'That item is no longer available for this action.',
  image_unavailable:'Enter an asset ID with a public Roblox thumbnail.',
  invalid_input:'Check the fields and try again.',
  appeal_unavailable:'That violation is unavailable for appeal.',
  forbidden:'You do not have access to that action.',
 };
 async function post(route,data={}){
  const res=await fetch('/api/v1/accounts/'+route,{
   method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/json'},
   body:JSON.stringify(data),signal:AbortSignal.timeout(12000),redirect:'error',
  });
  const result=await res.json();
  if(!res.ok||result.ok!==true){
   const error=new Error(errMessages[result.code]||'Request could not be completed.');
   error.code=result.code;
   throw error;
  }
  return result;
 }
 const decode=value=>{
  const base64=value.replace(/-/g,'+').replace(/_/g,'/')+'='.repeat((4-value.length%4)%4);
  return Uint8Array.from(atob(base64),c=>c.charCodeAt(0));
 };
 const encode=data=>{
  const bytes=new Uint8Array(data),chunk=0x4000;
  let binary='';
  for(let i=0;i<bytes.length;i+=chunk)binary+=String.fromCharCode(...bytes.subarray(i,i+chunk));
  return btoa(binary).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
 };
 const checkPasskey=()=>{
  if(!window.isSecureContext||typeof window.PublicKeyCredential!=='function'||!navigator.credentials)
   throw new Error('This browser does not support passkeys on this secure page.');
 };
 // Only for backup registration. Keep the server's WebAuthn excludeCredentials
 // check intact; the error is expected if the same authenticator is selected.
 function backupCreationError(error){
  const message=String(error?.message||'');
  if(error?.name==='InvalidStateError'||
     /authenticator that contains one of the credentials already registered/i.test(message))
   return new Error('This passkey manager already has a passkey for your account. Use another trusted authenticator to add a backup. Your existing passkey is unchanged.');
  return error;
 }
 function registrationOptions(json){
  if(typeof PublicKeyCredential.parseCreationOptionsFromJSON==='function')
   return PublicKeyCredential.parseCreationOptionsFromJSON(json);
  return {...json,challenge:decode(json.challenge),
   user:{...json.user,id:decode(json.user.id)},
   excludeCredentials:(json.excludeCredentials||[]).map(x=>({...x,id:decode(x.id)}) )};
 }
 function authenticationOptions(json){
  if(typeof PublicKeyCredential.parseRequestOptionsFromJSON==='function')
   return PublicKeyCredential.parseRequestOptionsFromJSON(json);
  return {...json,challenge:decode(json.challenge),
   allowCredentials:(json.allowCredentials||[]).map(x=>({...x,id:decode(x.id)}) )};
 }
 function credentialJSON(cred){
  if(typeof cred.toJSON==='function')return cred.toJSON();
  const response={clientDataJSON:encode(cred.response.clientDataJSON)};
  if(cred.response.attestationObject){
   response.attestationObject=encode(cred.response.attestationObject);
   response.transports=typeof cred.response.getTransports==='function'?cred.response.getTransports():[];
  }else{
   response.authenticatorData=encode(cred.response.authenticatorData);
   response.signature=encode(cred.response.signature);
   response.userHandle=cred.response.userHandle?encode(cred.response.userHandle):null;
  }
  return {id:cred.id,rawId:encode(cred.rawId),type:cred.type,response,
   clientExtensionResults:cred.getClientExtensionResults(),authenticatorAttachment:cred.authenticatorAttachment};
 }
 // Three explicit UI pages: /login (welcome), /signin (Passkey), /myaccount (session-verified).
 // Register and Recovery are subviews of Sign In, not new top-level pages.
 let authenticated=false;
 let accountId=null, editId=null;
 const paths={home:'/login',login:'/signin',register:'/signin#register',
  recover:'/signin#recover',account:'/myaccount'};
 function show(which,replace=false){
  if(which==='account'&&!authenticated)which='login';
  byId('landing').hidden=which!=='home';
  byId('sign-in').hidden=which!=='login';
  byId('registration').hidden=which!=='register';
  byId('recovery').hidden=which!=='recover';
  byId('account').hidden=which!=='account';
  byId('tab-account').hidden=!authenticated;
  byId('tab-register').hidden=which==='account'||which==='home';
  byId('tab-recovery').hidden=which==='account'||which==='home';
  const route=paths[which]||'/login';
  if(window.location.pathname+window.location.hash!==route){
   (replace?window.history.replaceState:window.history.pushState).call(
    window.history,{page:which},'',route);
  }
 }
 function previewImage(id,url){
  const image=byId(id);
  image.hidden=typeof url!=='string'||!/^https:\/\/[a-z0-9-]+\.rbxcdn\.com\//i.test(url);
  if(!image.hidden)image.src=url;
 }
 function account(info,canModerate=false){
  if(!info||typeof info.username!=='string'||typeof info.nickname!=='string')
   throw new Error('Account session was not verified.');
  authenticated=true;
  accountId=info.id||null;
  byId('identity').textContent=info.nickname+' (@'+info.username+')';
  byId('arc-id').textContent=accountId?'ArcID '+accountId:'';
  byId('profile-nickname').value=info.nickname;
  byId('profile-image').value=info.image||'';
  byId('profile-banner-id').value=info.banner||'';
  const color=/^#[0-9a-f]{6}$/i.test(info.bannerColor||'')?info.bannerColor:'#102757';
  byId('profile-color').value=color;
  if(byId('profile-banner').style)byId('profile-banner').style.backgroundColor=color;
  previewImage('avatar-image',info.imageThumbnail);
  previewImage('banner-image',info.bannerThumbnail);
  byId('moderator').hidden=!canModerate;
  byId('profile-form').hidden=info.status==='banned';
  byId('feedback-form').hidden=info.status==='banned';
  show('account');
  if(accountId)void loadCases().catch(()=>{});
 }
 function displayRecoveryCodes(codes){
  const valid=Array.isArray(codes)&&codes.length===8&&codes.every(x=>/^[0-9a-f]{32}$/.test(x));
  if(!valid)throw new Error('Recovery codes were not issued correctly. Do not sign out.');
  byId('recovery-code-list').textContent=codes.join('\n');
  byId('recovery-codes').hidden=false;
 }
 async function action(fn){
  if(busy)return;
  busy=true;status('Working…');
  for(const b of document.querySelectorAll('button'))b.disabled=true;
  try{await fn()}catch(error){status(error.message||'Request failed')}
  finally{for(const b of document.querySelectorAll('button'))b.disabled=false;busy=false}
 }
 const field=(form,name)=>String(form.get(name)||'').trim();
 const append=(parent,tag,text)=>{
  const node=document.createElement(tag);
  node.textContent=text;
  parent.append(node);
  return node;
 };
 const button=(parent,label,fn)=>{
  const control=append(parent,'button',label);
  control.type='button';
  control.className='secondary';
  control.onclick=fn;
 };
 const stateLabels={open:'Not appealed yet',reviewing:'Reviewing',approved:'Approved',denied:'Denied',closed:'Closed'};
 const stateOrder={open:0,reviewing:1,denied:2,approved:3,closed:4};
 function caseCard(parent,item,heading){
  const card=append(parent,'article','');
  append(card,'strong',heading);
  const state=append(card,'p',stateLabels[item.status]||item.status);
  state.dataset.caseStatus=item.status;
  if(item.reason)append(card,'p',item.reason);
  if(item.moderatorMessage)append(card,'p',item.moderatorMessage);
  return card;
 }
 function resetFeedback(){
  editId=null;
  byId('feedback-form').reset();
  byId('send-feedback').textContent='Submit Feedback';
  byId('cancel-feedback-edit').hidden=true;
 }
 async function loadCases(){
  const owner=accountId;
  const data=await post('history');
  if(accountId!==owner||!authenticated)return;
  const feedback=byId('feedback-history'),violations=byId('violations');
  feedback.replaceChildren();
  violations.replaceChildren();
  const entries=data.cases.filter(item=>item.kind==='feedback');
  if(!entries.length)append(feedback,'p','No Feedback history.');
  for(const item of entries){
   const card=caseCard(feedback,item,item.topic||'Feedback');
   if(item.status!=='reviewing'||!item.topic||byId('feedback-form').hidden)continue;
   button(card,'Edit',()=>{
    editId=item.id;
    byId('feedback-topic').value=item.topic;
    byId('feedback-description').value=item.reason;
    byId('send-feedback').textContent='Save edit';
    byId('cancel-feedback-edit').hidden=false;
    byId('feedback-topic').focus();
   });
   button(card,'Remove',()=>action(async()=>{
    await post('feedback/manage',{action:'remove',id:item.id});
    if(editId===item.id)resetFeedback();
    await loadCases();
    status('Feedback removed.');
   }));
  }
  byId('violation-history').hidden=data.notices.length===0;
  for(const item of [...data.notices].sort((a,b)=>stateOrder[a.status]-stateOrder[b.status])){
   const card=caseCard(violations,item,item.kind==='ban'?'Ban in-game':'Violation');
   if(!item.canAppealAgain)continue;
   const form=append(card,'form','');
   const label=append(form,'label','Appeal');
   const description=append(label,'textarea','');
   description.required=true;
   description.minLength=50;
   description.maxLength=1500;
   const submit=append(form,'button','Submit appeal');
   submit.type='submit';
   form.onsubmit=e=>{
    e.preventDefault();
    action(async()=>{
     await post('appeal',{id:item.id,description:description.value.trim()});
     await loadCases();
     status('Appeal submitted for review.');
    });
   };
  }
 }
 async function stepUp(request){
  checkPasskey();
  const {options}=await post('passkey/action/options',request);
  const credential=await navigator.credentials.get({publicKey:authenticationOptions(options)});
  if(!credential)throw new Error('Passkey verification was cancelled.');
  await post('passkey/action/verify',{response:credentialJSON(credential)});
 }
 async function loadSessions(){
  const {current,sessions}=await post('security/sessions');
  const panel=byId('active-sessions');
  panel.replaceChildren();
  for(const session of sessions){
   const row=append(panel,'article','');
   const title=session.scope==='loader'?'ExperienceSettings':'Browser';
   append(row,'strong',session.id===current?'This browser':title);
   append(row,'p','Expires '+new Date(session.expiresAt*1000).toLocaleString());
   if(session.id!==current)button(row,'Revoke session',()=>action(async()=>{
    await stepUp({action:'revoke_session',id:session.id});
    await loadSessions();
    status('Session revoked.');
   }));
  }
 }
 async function loadModeration(){
  const {cases,activeUsers}=await post('moderation/queue');
  const queue=byId('review-queue');
  queue.replaceChildren();
  byId('active-users').textContent='Active Users '+activeUsers;
  if(!cases.length)append(queue,'p','No cases under review.');
  for(const item of cases){
   const card=caseCard(queue,{...item,status:'reviewing'},item.topic||(item.appeal?'Appeal':'Feedback'));
   append(card,'p','ArcID '+item.arcId);
   if(item.appeal)append(card,'p',item.appeal);
   const label=append(card,'label','Moderator message');
   const message=append(label,'textarea','');
   message.maxLength=2000;
   for(const [decision,label] of [['approved','Approve'],['denied','Deny']]){
    button(card,label,()=>action(async()=>{
     await stepUp({action:'review_case',caseId:item.id,decision,message:message.value});
     await loadModeration();
     status('Review saved.');
    }));
   }
  }
 }
 byId('profile-color').oninput=()=>{
  const color=byId('profile-color').value;
  if(/^#[0-9a-f]{6}$/i.test(color)&&byId('profile-banner').style)
   byId('profile-banner').style.backgroundColor=color;
 };
 byId('preview-profile').onclick=()=>action(async()=>{
  const form=new FormData(byId('profile-form'));
  const data=await post('profile/preview',{image:field(form,'image')||null,banner:field(form,'banner')||null});
  previewImage('avatar-image',data.imageThumbnail);
  previewImage('banner-image',data.bannerThumbnail);
  status('Image preview. Save profile to apply.');
 });
 byId('profile-form').onsubmit=e=>{
  e.preventDefault();
  action(async()=>{
   const form=new FormData(e.currentTarget);
   await post('profile',{nickname:field(form,'nickname'),image:field(form,'image')||null,
    banner:field(form,'banner')||null,color:field(form,'color')});
   const data=await post('session');
   account(data.account,data.canModerate);
   status('Profile saved.');
  });
 };
 byId('load-cases').onclick=()=>action(async()=>{await loadCases();status('Cases refreshed.')});
 byId('load-sessions').onclick=()=>action(async()=>{await loadSessions();status('Sessions refreshed.')});
 byId('load-moderation').onclick=()=>action(async()=>{await loadModeration();status('Review queue refreshed.')});
 byId('cancel-feedback-edit').onclick=resetFeedback;
 byId('feedback-form').onsubmit=e=>{
  e.preventDefault();
  action(async()=>{
   const form=new FormData(e.currentTarget);
   const input={topic:field(form,'topic'),description:field(form,'description')};
   if(editId)await post('feedback/manage',{...input,action:'edit',id:editId});
   else await post('feedback',input);
   const edited=Boolean(editId);
   resetFeedback();
   await loadCases();
   status(edited?'Feedback updated.':'Feedback submitted for review.');
  });
 };
 byId('moderation-form').onsubmit=e=>{
  e.preventDefault();
  action(async()=>{
   const form=e.currentTarget,data=new FormData(form);
   await stepUp({action:'set_status',target:field(data,'target'),status:field(data,'status'),
    reason:field(data,'reason'),message:field(data,'message')});
   form.reset();
   await loadModeration();
   status('Account status updated.');
  });
 };
 byId('tab-home').onclick=()=>{status('');show('home')};
 byId('tab-login').onclick=()=>{status('');show('login')};
 byId('tab-account').onclick=()=>{status('');if(authenticated)show('account')};
 window.addEventListener('popstate',()=>{
  const page=window.location.pathname,hash=window.location.hash;
  if(page==='/myaccount')show(authenticated?'account':'login',true);
  else if(page==='/signin')show(hash==='#register'?'register':
   hash==='#recover'?'recover':'login',true);
  else show('home',true);
 });
 byId('tab-register').onclick=()=>{status('');show('register')};
 byId('tab-recovery').onclick=()=>{status('');show('recover')};
 byId('passkey-login').onclick=()=>action(async()=>{
  checkPasskey();
  const {options}=await post('passkey/login/options');
  const credential=await navigator.credentials.get({publicKey:authenticationOptions(options)});
  if(!credential)throw new Error('No passkey was selected.');
  const data=await post('passkey/login/verify',{response:credentialJSON(credential)});
  account(data.account,data.canModerate);
  status('Signed in using a passkey.');
 });
 byId('register-form').onsubmit=e=>{
  e.preventDefault();
  action(async()=>{
   checkPasskey();
   const form=byId('register-form'),data=new FormData(form);
   const username=(data.get('username')||'').toString().trim();
   const {options}=await post('passkey/register/options',{
    username,presence:data.get('presence')==='on',
    turnstile:(data.get('cf-turnstile-response')||'').toString(),
   });
   const credential=await navigator.credentials.create({publicKey:registrationOptions(options)});
   if(!credential)throw new Error('Passkey registration was cancelled.');
   const created=await post('passkey/register/verify',{response:credentialJSON(credential)});
   form.reset();
   globalThis.turnstile?.reset();
   account(created.account);
   displayRecoveryCodes(created.recoveryCodes);
   status('Passkey registered. Save your recovery codes before leaving this page.');
  });
 };
 byId('recovery-form').onsubmit=e=>{
  e.preventDefault();
  action(async()=>{
   checkPasskey();
   const form=byId('recovery-form'),data=new FormData(form);
   const {options}=await post('passkey/recovery/options',{
    username:(data.get('username')||'').toString().trim(),
    code:(data.get('code')||'').toString().trim().toLowerCase(),
    presence:data.get('presence')==='on',
    turnstile:(data.get('cf-turnstile-response')||'').toString(),
   });
   const credential=await navigator.credentials.create({publicKey:registrationOptions(options)});
   if(!credential)throw new Error('Recovery was cancelled.');
   const restored=await post('passkey/recovery/verify',{response:credentialJSON(credential)});
   form.reset();
   globalThis.turnstile?.reset();
   account(restored.account,restored.canModerate);
   displayRecoveryCodes(restored.recoveryCodes);
   status('Account recovered. Previous passkeys and sessions were revoked. Save the new recovery codes.');
  });
 };
 byId('add-backup-passkey').onclick=()=>action(async()=>{
  checkPasskey();
  const {options}=await post('passkey/backup/options');
  const current=await navigator.credentials.get({publicKey:authenticationOptions(options)});
  if(!current)throw new Error('Reauthentication with your current passkey was cancelled.');
  const enrolment=await post('passkey/backup/verify-current',{response:credentialJSON(current)});
  let backup;
  try{
   backup=await navigator.credentials.create({publicKey:registrationOptions(enrolment.options)});
  }catch(error){
   throw backupCreationError(error);
  }
  if(!backup)throw new Error('Backup passkey creation was cancelled.');
  await post('passkey/backup/verify',{response:credentialJSON(backup)});
  status('Backup passkey added. Your original passkey is still valid. Keep both safe.');
 });
 byId('pair-form').onsubmit=e=>{
  e.preventDefault();
  action(async()=>{
   const form=byId('pair-form'),data=new FormData(form);
   await post('pair/approve',{
    code:(data.get('code')||'').toString().trim().toUpperCase(),
    confirm:data.get('confirm')==='on',
   });
   form.reset();
   status('Pairing approved. Return to ESLogin in Roblox.');
  });
 };
 byId('sign-out').onclick=()=>action(async()=>{
  await post('logout');
  byId('recovery-code-list').textContent='';
  byId('recovery-codes').hidden=true;
  status('Signed out.');
  authenticated=false;
  accountId=null;
  resetFeedback();
  for(const id of ['active-sessions','feedback-history','violations','review-queue'])byId(id).replaceChildren();
  for(const id of ['moderator','violation-history'])byId(id).hidden=true;
  show('home');
 });
 // MyAccount displays only account data from a successful, scoped server session.
 // A direct /myaccount link without a session redirects to /signin (no client trust).
 post('session').then(({account:profile,canModerate})=>account(profile,canModerate)).catch(()=>{
  const pathname=window.location.pathname,hash=window.location.hash;
  if(pathname==='/signin')
   show(hash==='#register'?'register':hash==='#recover'?'recover':'login',true);
  else if(pathname==='/myaccount'){
   show('login',true);status('Sign in before opening MyAccount.');
  }else show('home',true);
 });
})();
