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
    notice('หมดเวลาการยืนยันแล้ว กรุณาเริ่มตรวจสอบรหัสใหม่');
    return;
  }
  el('approve').disabled = !eligible();
  if (preview) {
    const seconds = Math.max(0, Math.ceil((expiresAt - Date.now())/1000));
    el('expires').textContent = 'ยืนยันภายใน ' + seconds + ' วินาที';
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
  catch { throw Error('ไม่สามารถอ่านผลตอบกลับจาก Server'); }
  if(!response.ok || body?.ok !== true) {
    if(response.status===429) throw Error('ส่งคำขอมากเกินไป กรุณาลองอีกครั้งภายหลัง');
    if(response.status===403) throw Error('ไม่สามารถยืนยันบัญชีหรือรหัสนี้ได้');
    throw Error('ไม่สามารถดำเนินการได้ กรุณาลองใหม่');
  }
  return body;
}

el('lookup').addEventListener('submit',async(event)=>{
  event.preventDefault();
  reset();
  notice('');
  const entered=code(el('lookup-code').value);
  if(!codePattern.test(entered)) {
    notice('รูปแบบรหัสไม่ถูกต้อง');
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
      throw Error('Server ส่งข้อมูลการยืนยันไม่ถูกต้อง');
    }
    preview={code:r.pairingCode,confirmationToken:r.confirmationToken};
    expiresAt=Date.now()+r.expiresIn*1000;
    el('preview-code').textContent=r.pairingCode;
    // Never prefill the second field from the first field or server preview.
    el('confirmed-code').value='';
    el('own-device').checked=false;
    el('approval').hidden=false;
    notice('ตรวจสอบรหัสใน Arcsen ของคุณก่อนกดยืนยัน');
  } catch(e) {
    notice(e instanceof Error ? e.message : 'ไม่สามารถตรวจสอบรหัส');
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
    notice('รหัสถูกเปลี่ยน กรุณากดตรวจสอบรหัสอีกครั้ง');
  }
});
el('cancel').addEventListener('click',()=>{
  reset();
  notice('ยกเลิกการยืนยันแล้ว');
});
el('confirm').addEventListener('submit',async(event)=>{
  event.preventDefault();
  if(!eligible()) {
    notice('ตรวจสอบและกรอกรหัสด้วยตัวเอง พร้อมทำเครื่องหมายยืนยันก่อน');
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
    if(result.approved!==true) throw Error('การยืนยันไม่สำเร็จ');
    reset();
    el('lookup-code').value='';
    notice('อนุมัติการจับคู่แล้ว คุณสามารถปิดหน้านี้ได้');
  } catch(e) {
    notice(e instanceof Error ? e.message : 'การยืนยันไม่สำเร็จ');
  } finally {
    busy=false;
    update();
  }
});
setInterval(update,1000);
