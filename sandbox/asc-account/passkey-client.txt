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
 function account(info){
  if(!info||typeof info.username!=='string'||typeof info.nickname!=='string')
   throw new Error('Account session was not verified.');
  authenticated=true;
  byId('identity').textContent=info.nickname+' (@'+info.username+')';
  show('account');
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
  account(data.account);
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
   account(restored.account);
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
  show('home');
 });
 // MyAccount displays only account data from a successful, scoped server session.
 // A direct /myaccount link without a session redirects to /signin (no client trust).
 post('session').then(({account:profile})=>account(profile)).catch(()=>{
  const pathname=window.location.pathname,hash=window.location.hash;
  if(pathname==='/signin')
   show(hash==='#register'?'register':hash==='#recover'?'recover':'login',true);
  else if(pathname==='/myaccount'){
   show('login',true);status('Sign in before opening MyAccount.');
  }else show('home',true);
 });
})();
