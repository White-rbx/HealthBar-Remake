/**
 * Stage16.86 browser-only consent demo — NOT DEPLOYED.
 * Never stores OAuth tokens, session cookies, Roblox UserIds, or pairing codes
 * in localStorage, URL parameters, telemetry, logs or Luau. HttpOnly browser
 * session cookies are sent by the browser through same-origin POST only.
 * This is a UX reference; designers can replace visual styling freely.
 */
const el = (id) => document.getElementById(id);
const codePattern = /^[A-Z2-7]{4}(?:-[A-Z2-7]{4}){3}$/;
let preview = null;
let busy = false;
let expiresAt = 0;

function code(input) { return input.trim().toUpperCase(); }
function notice(message) { el('status').textContent = message; }
function reset() {
  preview = null;
  busy = false;
  expiresAt = 0;
  el('approval').hidden = true;
  el('preview-code').textContent = '';
  el('confirmed-code').value = '';
  el('own-device').checked = false;
  el('approve').disabled = true;
  el('lookup-button').disabled = false;
  el('expires').textContent = '';
}
function eligible() {
  return !busy && preview !== null && Date.now() < expiresAt &&
    code(el('confirmed-code').value) === preview.code &&
    el('own-device').checked === true;
}
function update() {
  if (preview && Date.now() >= expiresAt) {
    reset();
    notice('Confirmation expired. Please check your pairing code again.');
    return;
  }
  el('approve').disabled = !eligible();
  if (preview) {
    const seconds = Math.max(0, Math.ceil((expiresAt - Date.now())/1000));
    el('expires').textContent = 'Confirm within ' + seconds + ' seconds';
  }
}
async function post(path, data) {
  const response = await fetch(path,{
    method:'POST',
    credentials:'same-origin',
    cache:'no-store',
    redirect:'error',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify(data),
  });
  let body;
  try { body = await response.json(); }
  catch { throw Error('Could not read the server response.'); }
  if(!response.ok || body?.ok !== true) {
    if(response.status===429) throw Error('Too many requests. Please try again later.');
    if(response.status===403) throw Error('Unable to verify this account or pairing code.');
    throw Error('Something went wrong. Please try again.');
  }
  return body;
}

el('lookup').addEventListener('submit',async(event)=>{
  event.preventDefault();
  reset();
  notice('');
  const entered=code(el('lookup-code').value);
  if(!codePattern.test(entered)) {
    notice('Invalid pairing code format.');
    return;
  }
  busy = true;
  el('lookup-button').disabled = true;
  try {
    const r=await post('/pair/browser/preview',{code:entered});
    if(!codePattern.test(r.pairingCode) ||
       r.pairingCode!==entered ||
       typeof r.confirmationToken!=='string' ||
       !/^[A-Za-z0-9_-]{43}$/.test(r.confirmationToken) ||
       typeof r.expiresIn!=='number' || r.expiresIn<=0 || r.expiresIn>60) {
      throw Error('The server returned an invalid confirmation.');
    }
    preview={code:r.pairingCode,confirmationToken:r.confirmationToken};
    expiresAt=Date.now()+r.expiresIn*1000;
    el('preview-code').textContent=r.pairingCode;
    // Never prefill the second field from the first field or server preview.
    el('confirmed-code').value='';
    el('own-device').checked=false;
    el('approval').hidden=false;
    notice('Compare this code with the one shown in your Arcsen before approving.');
  } catch(e) {
    notice(e instanceof Error ? e.message : 'Unable to check the code.');
  } finally {
    busy=false;
    el('lookup-button').disabled=false;
    update();
  }
});

el('confirmed-code').addEventListener('input',update);
el('own-device').addEventListener('change',update);
el('lookup-code').addEventListener('input',()=>{
  if(preview) {
    reset();
    notice('The pairing code changed. Check the new code again.');
  }
});
el('cancel').addEventListener('click',()=>{
  reset();
  notice('Confirmation canceled.');
});
el('confirm').addEventListener('submit',async(event)=>{
  event.preventDefault();
  if(!eligible()) {
    notice('Re-enter the matching code and confirm that this is your own device.');
    return;
  }
  busy=true;
  update();
  try {
    const result=await post('/pair/browser/approve',{
      code:preview.code,
      confirmedCode:code(el('confirmed-code').value),
      confirmationToken:preview.confirmationToken,
      acknowledgeOwnDevice:true,
    });
    if(result.approved!==true) throw Error('Pairing approval failed.');
    reset();
    el('lookup-code').value='';
    notice('Pairing approved. You can close this page now.');
  } catch(e) {
    notice(e instanceof Error ? e.message : 'Pairing approval failed.');
  } finally {
    busy=false;
    update();
  }
});
setInterval(update,1000);
