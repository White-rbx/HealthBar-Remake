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
 function show(which){
  byId('sign-in').hidden=which!=='login';
  byId('registration').hidden=which!=='register';
  byId('recovery').hidden=which!=='recover';
  byId('account').hidden=which!=='account';
  byId('tab-login').hidden=which==='account';
  byId('tab-register').hidden=which==='account';
  byId('tab-recovery').hidden=which==='account';
 }
 function account(info){
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
 byId('tab-login').onclick=()=>{status('');show('login')};
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
  show('login');
 });
 post('session').then(({account:profile})=>account(profile)).catch(()=>show('login'));
})();
