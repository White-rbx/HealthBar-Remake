export function website(siteKey,nonce){
 return String.raw`<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>ArcScriptCenter Account · Staging</title>
<style nonce="${nonce}">
:root{color-scheme:dark;font:16px system-ui;background:#090e1c;color:#e8efff}
[hidden]{display:none!important} *{box-sizing:border-box} body{margin:0} main{max-width:860px;margin:auto;padding:clamp(18px,5vw,42px)}
h1,h2{line-height:1.1} h1{margin:0 0 4px} h2{font-size:1.26rem;margin:0 0 15px} p{line-height:1.4}
nav{display:flex;gap:8px;flex-wrap:wrap;margin:22px 0} section{background:#111b32;padding:22px;border:1px solid #2a3a5a;border-radius:12px;margin-bottom:15px}
form{display:grid;gap:12px;margin:16px 0} label{display:grid;gap:5px} input,select,textarea,button{font:inherit}
input,select,textarea{padding:10px;border-radius:6px;background:#090f21;border:1px solid #617295;width:100%}
input[type=checkbox]{width:auto} .check{display:block} button{border:0;border-radius:6px;padding:9px 14px;background:#a5d7ff;color:#0b1831;cursor:pointer}
button:disabled{opacity:.5;cursor:wait} #status{min-height:1.5em;color:#a8d8ff} small{color:#afbedb}
#setup-output{overflow-wrap:anywhere;white-space:pre-wrap;background:#0b1325;padding:.8em} #profile-banner{height:100px;background-color:#102757;border-radius:8px;overflow:hidden;display:grid;align-items:end}
#profile-banner img{width:100%;height:100%;object-fit:cover} #profile-icon{width:48px;height:48px;border-radius:50%;object-fit:cover}
article{border-top:1px solid #314360;padding-top:12px;margin-top:12px} .approved{color:#70dc99}
</style>
<main>
<header><h1>ArcScriptCenter Account</h1><small>Staging</small></header>
<nav aria-label="Account pages"><button id="login-tab">Sign in</button><button id="register-tab">Register</button><button id="signout" hidden>Sign out</button></nav>
<p id="status" role="status" aria-live="polite"></p>
<section id="login"><h2>Sign in</h2>
<form id="login-form"><label>Username<input name="username" autocomplete="username" required maxlength="24"></label>
<label>Password<input name="password" type="password" autocomplete="current-password" required maxlength="128"></label><button>Sign in</button></form>
<form id="factor" hidden><label>Authenticator or recovery code<input name="code" autocomplete="one-time-code" maxlength="24" required></label><button>Verify</button></form></section>
<section id="registration" hidden><h2>Create an account</h2>
<form id="register-form"><label>Username<input name="username" autocomplete="username" pattern="[A-Za-z0-9_]{3,24}" required></label>
<label>Password<input name="password" type="password" autocomplete="new-password" minlength="15" maxlength="128" required></label>
<label>Confirm password<input name="confirmation" type="password" autocomplete="new-password" minlength="15" maxlength="128" required></label>
<label class="check"><input name="presence" type="checkbox" required> I understand that ArcScriptCenter tracks whether my authenticated ExperienceSettings sessions are active. This presence is used internally and is private.</label>
${siteKey?'<div class="cf-turnstile" data-sitekey="'+siteKey+'" data-action="asc_register"></div>':'<p>Registration is unavailable until Turnstile is configured for this staging site.</p>'}
<button ${siteKey?'':'disabled'}>Register</button></form></section>
<div id="account" hidden>
<section><div id="profile-banner"><img id="banner-preview" alt="" hidden></div><img id="profile-icon" alt="" hidden><h2 id="account-label"></h2>
<form id="pair-form"><label>Code shown by ExperienceSettings<input name="code" autocomplete="off" pattern="[0-9A-Fa-f]{12}" maxlength="12" required></label>
<label class="check"><input name="confirm" type="checkbox" required> This code is on my own ExperienceSettings screen.</label><button>Link ExperienceSettings</button></form></section>
<section><h2>Profile</h2><form id="profile"><label>Nickname<input name="nickname" maxlength="24" required></label>
<label>Profile image asset ID<input name="image" inputmode="numeric" maxlength="16"></label><label>Banner image asset ID<input name="banner" inputmode="numeric" maxlength="16"></label>
<label>Banner color<input name="color" type="color"></label><button>Save profile</button></form></section>
<section><h2>Account security</h2>
<form id="security"><label>Current password<input name="password" type="password" autocomplete="current-password" required></label>
<label>Authenticator or recovery code<input name="code" autocomplete="one-time-code" maxlength="24"></label>
<label>New password<input name="newPassword" type="password" autocomplete="new-password" minlength="15" maxlength="128"></label>
<label>Confirm new password<input name="confirmation" type="password" autocomplete="new-password" minlength="15" maxlength="128"></label>
<label>Session to revoke<select name="id" id="session-id"></select></label>
<button name="action" value="setup">Get authenticator setup key</button><button name="action" value="enable">Enable two-step verification</button>
<button name="action" value="disable">Disable two-step verification</button><button name="action" value="password">Change password</button>
<button name="action" value="revoke">Revoke selected session</button></form>
<p id="session-summary"></p><pre id="setup-output" hidden></pre></section>
<section><h2>Cases</h2><div id="cases"></div>
<form id="feedback"><label>Feedback<textarea name="description" minlength="50" maxlength="1500" required></textarea></label><button>Send feedback</button></form></section>
</div>
<script nonce="${nonce}">
const get=id=>document.getElementById(id);
const status=text=>{get('status').textContent=text};
const errors={session_expired:'Session expired. Sign in again.',rate_limited:'Too many requests. Try again shortly.',
verification_required:'Complete the verification and try again.',registration_unavailable:'Registration is not configured.',
verification_failed:'The verification code could not be accepted.',login_failed:'The username or password could not be accepted.',
image_unavailable:'The Roblox asset is unavailable.',setup_required:'Start authenticator setup first.',
reauth_required:'Confirm your password and verification code.',service_unavailable:'Service unavailable. Try again shortly.',
appeal_unavailable:'This case cannot be appealed.'};
async function post(path,data={}){
 const response=await fetch('/api/v1/accounts/'+path,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data),signal:AbortSignal.timeout(12000)});
 const result=await response.json();
 if(!response.ok||!result.ok){const error=new Error(errors[result.code]||'The request could not be completed.');error.code=result.code;throw error}
 return result;
}
let challenge=null;
function show(mode){
 get('login').hidden=mode!=='login';get('registration').hidden=mode!=='register';get('account').hidden=mode!=='account';
 get('register-tab').hidden=get('login-tab').hidden=mode==='account';get('signout').hidden=mode!=='account';
}
function signedOut(){challenge=null;get('factor').hidden=true;get('login-form').hidden=false;get('setup-output').textContent='';get('setup-output').hidden=true;show('login')}
get('login-tab').onclick=()=>{status('');signedOut()};get('register-tab').onclick=()=>{status('');show('register')};
function form(id,handler){
 const form=get(id);
 form.addEventListener('submit',async e=>{
  e.preventDefault();
  const data=Object.fromEntries(new FormData(form));
  const buttons=[...form.querySelectorAll('button:not(:disabled)')];buttons.forEach(x=>x.disabled=true);
  status('Working…');
  try{await handler(data,e.submitter,form)}catch(error){if(error.code==='session_expired')signedOut();status(error.message||'Service unavailable.')}
  finally{for(const input of form.querySelectorAll('input[type=password],input[autocomplete=one-time-code]'))input.value='';buttons.forEach(x=>x.disabled=false);}
 });
}
form('login-form',async d=>{
 const result=await post('login',d);
 if(result.state==='verification_required'){challenge=result.challenge;get('factor').hidden=false;get('login-form').hidden=true;status('Enter your verification code.')}
 else await loadAccount();
});
form('factor',async d=>{await post('factor',{challenge,code:d.code});challenge=null;await loadAccount()});
form('register-form',async d=>{
 try{await post('register',{...d,turnstile:d['cf-turnstile-response'],presence:d.presence==='on'});show('login');status('If the username was available, your account is ready. Sign in to continue.')}
 finally{globalThis.turnstile?.reset()}
});
form('pair-form',async (d,button,f)=>{await post('pair/approve',{code:d.code.trim().toUpperCase(),confirm:d.confirm==='on'});f.reset();status('Linked. Return to ExperienceSettings.')});
form('feedback',async (d,b,f)=>{await post('feedback',d);f.reset();await loadCases();status('Feedback sent.')});
form('profile',async d=>{await post('profile',{nickname:d.nickname,image:d.image||null,banner:d.banner||null,color:d.color});await loadAccount();status('Profile saved.')});
form('security',async(d,b)=>{
 get('setup-output').hidden=true;get('setup-output').textContent='';
 const reply=await post('security/'+b.value,d);
 if(reply.setupKey){get('setup-output').textContent='Add this key to your authenticator as a time-based entry, then enter a code to enable it.\u000a'+reply.setupKey;get('setup-output').hidden=false}
 if(reply.recovery){get('setup-output').textContent='Save these one-use recovery codes securely. They are shown once.\u000a'+reply.recovery.join('\u000a');get('setup-output').hidden=false}
 if(['disable','password'].includes(b.value)){signedOut();status('Security settings changed. Sign in again.');return}
 await loadSessions();status('Security settings updated.')
});
get('signout').onclick=async()=>{try{await post('logout');signedOut();status('Signed out.')}catch(e){status(e.message)}};
async function loadSessions(){
 const {current,sessions}=await post('security/sessions');const list=get('session-id');list.replaceChildren();
 for(const s of sessions){const option=document.createElement('option');option.value=s.id;
 option.textContent=(s.scope==='web'?'Website':'ExperienceSettings')+(s.id===current?' (current)':'')+' · '+new Date(s.createdAt*1000).toLocaleString();list.append(option)}
 get('session-summary').textContent=sessions.length+' active session'+(sessions.length===1?'':'s');
}
async function loadCases(){
 const {cases}=await post('history');const list=get('cases');list.replaceChildren();
 for(const c of cases){const row=document.createElement('article'),heading=document.createElement('strong'),text=document.createElement('p');
 heading.textContent=c.kind+' · '+c.status;if(c.status==='approved')heading.className='approved';
 text.textContent=c.reason+(c.moderatorMessage?' — '+c.moderatorMessage:'');row.append(heading,text);
 if(c.kind!=='feedback'&&c.status==='open'){const f=document.createElement('form'),box=document.createElement('textarea'),button=document.createElement('button');
 box.required=true;box.minLength=50;box.maxLength=1500;box.setAttribute('aria-label','Appeal reason');button.textContent='Submit appeal';f.append(box,button);row.append(f);
 f.onsubmit=async e=>{e.preventDefault();try{await post('appeal',{id:c.id,description:box.value});await loadCases();status('Appeal submitted.')}catch(error){status(error.message)}}}
 list.append(row)}
}
async function loadAccount(){
 const {account}=await post('session');get('account-label').textContent=account.nickname+' (@'+account.username+')';
 const f=get('profile');f.elements.nickname.value=account.nickname;f.elements.image.value=account.image||'';
 f.elements.banner.value=account.banner||'';f.elements.color.value=account.bannerColor;
 get('profile-banner').style.backgroundColor=account.bannerColor;
 for(const [id,url] of [['profile-icon',account.imageThumbnail],['banner-preview',account.bannerThumbnail]]){
  const image=get(id);image.hidden=!url;if(url){image.src=url;image.onerror=()=>{image.hidden=true}}else image.removeAttribute('src');
 }
 get('feedback').hidden=account.status==='banned';show('account');status(account.status.replaceAll('_',' '));
 await Promise.all([loadSessions(),loadCases()]);
}
loadAccount().catch(()=>signedOut());
</script>
${siteKey?'<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>':''}
</main></html>`;
}
