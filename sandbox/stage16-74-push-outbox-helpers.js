// Stage16.74 Sandbox-only helper module — no secret literals, no production paths.
// Injection target: Cloudflare Worker source before "export default {".
// D1 table: asc_push_delivery_outbox_v1 (Sandbox only).
const ASC1674_HTML = `<!doctype html><html lang="th"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>ArcScriptCenter · Push Delivery Health</title><meta name="robots" content="noindex,nofollow"><style>:root{color-scheme:dark;font:16px system-ui;background:#111a28;color:#edf5ff}body{padding:18px;margin:auto;max-width:730px}section{border:1px solid #41536c;padding:16px;border-radius:12px;margin:14px 0;background:#1b293a}p{color:#c6d4e4;line-height:1.7}button{font:600 1rem system-ui;padding:12px;color:white;background:#207ab5;border:0;border-radius:8px;margin-right:8px}#state{background:#304159;padding:14px;border-radius:8px;white-space:pre-wrap}</style><script nonce="__NONCE__">(()=>{'use strict';let busy=false;const $=id=>document.getElementById(id);async function req(path,data){const opt={method:data?'POST':'GET',credentials:'same-origin',cache:'no-store',headers:{Accept:'application/json'}};if(data){opt.headers['Content-Type']='application/json';opt.body=JSON.stringify(data)}const r=await fetch(path,opt);if(!(r.headers.get('Content-Type')||'').includes('application/json'))throw Error('Cloudflare Access login expired');const d=await r.json();if(!r.ok||!d.ok)throw Error(d.error||('HTTP '+r.status));return d;}function set(s){$('state').textContent=s;}async function refresh(){try{const d=await req('/__stage1674/status'),c=d.counts;set('Registered Android devices: '+d.subscribers+'\\nPending: '+c.pending+'\\nScheduled retry: '+c.retry+'\\nSending: '+c.sending+'\\nAccepted: '+c.delivered+'\\nDead: '+c.dead+'\\nCanceled: '+c.canceled+'\\nDue now: '+d.dueCount)}catch(e){set(e.message)}}async function retry(){if(busy||!confirm('Retry due Push deliveries? This may send Android notifications.'))return;busy=true;$('retry').disabled=true;try{const d=await req('/__stage1674/retry-due',{confirm:true});set('Jobs processed: '+d.jobs+'\\nAttempted: '+d.attempted+'\\nPush accepted: '+d.accepted+'\\nFailed/retried: '+d.failed)}catch(e){set(e.message)}finally{busy=false;$('retry').disabled=false;}}document.addEventListener('DOMContentLoaded',()=>{$('refresh').onclick=refresh;$('retry').onclick=retry;refresh()});})();</script></head><body><small>SANDBOX / ACCESS ADMIN ONLY</small><h1>🔔 Android Push Delivery Health</h1><p>D1 Outbox บันทึกสถานะ Push, ป้องกันการส่งซ้อน และกำหนด Retry แบบหน่วงเวลา โดยไม่แสดงข้อมูลผู้ใช้หรือ Push Endpoint</p><section><div id="state">Loading…</div><button id="refresh">Refresh</button><button id="retry">Retry Due Now</button></section><section><p>Retry ขณะนี้ต้องกดโดยผู้ดูแลเอง ยังไม่ได้ตั้ง Cron หรือ Queue ให้ทำงานอัตโนมัติเมื่อปิดหน้าเว็บ จึงยังไม่รับประกัน exactly-once delivery</p></section></body></html>`;
async function asc1674Ensure(env,id){
 const now=Math.floor(Date.now()/1000);
 await env.DB.prepare("INSERT OR IGNORE INTO asc_push_delivery_outbox_v1(case_id,endpoint_hash,kind,state,created_unix,updated_unix,next_retry_unix) SELECT c.id,s.endpoint_hash,c.kind,'pending',?,?,? FROM asc_feedback_cases c JOIN asc_admin_push_subscriptions_v1 s ON s.enabled=1 WHERE c.id=? AND c.removed=0 AND c.status!='spam_mail' ORDER BY s.created_unix LIMIT 3").bind(now,now,now,id).run();
}
async function asc1674Deliver(env,id){
 const summary={attempted:0,accepted:0,failed:0};
 const result=await env.DB.prepare("SELECT o.endpoint_hash,s.endpoint,c.id AS active_case,c.removed,c.status AS case_status FROM asc_push_delivery_outbox_v1 o LEFT JOIN asc_admin_push_subscriptions_v1 s ON s.endpoint_hash=o.endpoint_hash AND s.enabled=1 LEFT JOIN asc_feedback_cases c ON c.id=o.case_id WHERE o.case_id=? AND o.state IN ('pending','retry','sending') LIMIT 3").bind(id).all();
 for(const item of result.results||[]){
  const hash=item.endpoint_hash,now=Math.floor(Date.now()/1000);
  if(!item.active_case||Number(item.removed)!==0||item.case_status==='spam_mail'){
   await env.DB.prepare("UPDATE asc_push_delivery_outbox_v1 SET state='canceled',updated_unix=?,lease_until_unix=0 WHERE case_id=? AND endpoint_hash=? AND state IN ('pending','retry','sending')").bind(now,id,hash).run();
   continue;
  }
  if(!item.endpoint){
   await env.DB.prepare("UPDATE asc_push_delivery_outbox_v1 SET state='dead',last_http_status=410,updated_unix=?,lease_until_unix=0 WHERE case_id=? AND endpoint_hash=? AND state IN ('pending','retry','sending')").bind(now,id,hash).run();
   summary.failed++;continue;
  }
  const lease=now+25;
  const claimed=await env.DB.prepare("UPDATE asc_push_delivery_outbox_v1 SET state='sending',attempts=attempts+1,lease_until_unix=?,updated_unix=? WHERE case_id=? AND endpoint_hash=? AND attempts<3 AND (state='pending' OR (state='retry' AND next_retry_unix<=?) OR (state='sending' AND lease_until_unix<=?)) AND EXISTS(SELECT 1 FROM asc_feedback_cases c WHERE c.id=? AND c.removed=0 AND c.status!='spam_mail') RETURNING attempts").bind(lease,now,id,hash,now,now,id).first();
  if(!claimed)continue;
  summary.attempted++;
  let send;
  try{send=await ascStage1671VapidSend(env,item.endpoint)}catch{send={ok:false,status:503}}
  const http=Number(send?.status||503),attempt=Number(claimed.attempts);
  if(send?.ok){
   const row=await env.DB.prepare("UPDATE asc_push_delivery_outbox_v1 SET state='delivered',last_http_status=?,delivered_unix=?,updated_unix=?,lease_until_unix=0 WHERE case_id=? AND endpoint_hash=? AND state='sending' AND attempts=? AND lease_until_unix=? RETURNING case_id").bind(http,now,now,id,hash,attempt,lease).first();
   if(row?.case_id===id){
    summary.accepted++;
    const event=await env.DB.prepare("SELECT MAX(event_id) AS event_id FROM asc_feedback_history WHERE case_id=? AND event_type='submitted'").bind(id).first();
    if(Number(event?.event_id)>0)await env.DB.prepare("UPDATE asc_admin_push_subscriptions_v1 SET last_sent_event_id=? WHERE endpoint_hash=? AND last_sent_event_id<?").bind(Number(event.event_id),hash,Number(event.event_id)).run();
   }
  }else{
   summary.failed++;
   const dead=attempt>=3||[400,401,403,404,410].includes(http);
   await env.DB.prepare("UPDATE asc_push_delivery_outbox_v1 SET state=?,last_http_status=?,next_retry_unix=?,updated_unix=?,lease_until_unix=0 WHERE case_id=? AND endpoint_hash=? AND state='sending' AND attempts=? AND lease_until_unix=?").bind(dead?'dead':'retry',http,dead?0:now+(attempt===1?60:300),now,id,hash,attempt,lease).run();
   if(http===404||http===410)await env.DB.prepare("DELETE FROM asc_admin_push_subscriptions_v1 WHERE endpoint_hash=?").bind(hash).run();
  }
 }
 return summary;
}
async function asc1674RetryDue(env){
 const now=Math.floor(Date.now()/1000);
 const q=await env.DB.prepare("SELECT DISTINCT case_id FROM asc_push_delivery_outbox_v1 WHERE (state IN ('pending','retry') AND next_retry_unix<=?) OR (state='sending' AND lease_until_unix<=?) ORDER BY updated_unix ASC LIMIT 2").bind(now,now).all();
 const total={jobs:0,attempted:0,accepted:0,failed:0};
 for(const r of q.results||[]){
  total.jobs++;
  try{const s=await asc1674Deliver(env,r.case_id);for(const key of ['attempted','accepted','failed'])total[key]+=Number(s[key]||0)}catch{total.failed++}
 }
 return total;
}
function asc1674Json(data,status=200){return new Response(JSON.stringify(data),{status,headers:{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store, private','X-Content-Type-Options':'nosniff'}})}
async function asc1674Allowed(req,env,ctx){return ascStage1671IsSandbox(req,env,ctx)&&await ascStage1671VerifiedAdmin(req,env,ctx)}
async function asc1674Page(req,env,ctx){
 if(!(await asc1674Allowed(req,env,ctx)))return new Response('Unauthorized',{status:401,headers:{'Cache-Control':'no-store'}});
 const b=crypto.getRandomValues(new Uint8Array(18)),nonce=btoa(Array.from(b,v=>String.fromCharCode(v)).join(''));
 return new Response(ASC1674_HTML.replaceAll('__NONCE__',nonce),{status:200,headers:{'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store, private','X-Content-Type-Options':'nosniff','Referrer-Policy':'no-referrer','X-Robots-Tag':'noindex,nofollow','Content-Security-Policy':"default-src 'none';script-src 'nonce-"+nonce+"';connect-src 'self';style-src 'unsafe-inline';base-uri 'none';form-action 'none';frame-ancestors 'none'"}});
}
async function asc1674Status(req,env,ctx){
 if(!(await asc1674Allowed(req,env,ctx)))return asc1674Json({ok:false,error:'Unauthorized'},401);
 const now=Math.floor(Date.now()/1000);
 const [groups,due,subs]=await Promise.all([
 env.DB.prepare("SELECT state,COUNT(*) AS n FROM asc_push_delivery_outbox_v1 GROUP BY state").all(),
 env.DB.prepare("SELECT COUNT(*) AS n FROM asc_push_delivery_outbox_v1 WHERE (state IN ('pending','retry') AND next_retry_unix<=?) OR (state='sending' AND lease_until_unix<=?)").bind(now,now).first(),
 env.DB.prepare("SELECT COUNT(*) AS n FROM asc_admin_push_subscriptions_v1 WHERE enabled=1").first()]);
 const counts={pending:0,sending:0,retry:0,delivered:0,dead:0,canceled:0};
 for(const r of groups.results||[])if(Object.prototype.hasOwnProperty.call(counts,r.state))counts[r.state]=Number(r.n||0);
 return asc1674Json({ok:true,counts,dueCount:Number(due?.n||0),subscribers:Number(subs?.n||0)});
}
async function asc1674Retry(req,env,ctx){
 if(!(await asc1674Allowed(req,env,ctx)))return asc1674Json({ok:false,error:'Unauthorized'},401);
 const url=new URL(req.url);
 if(req.headers.get('Origin')!==url.origin||req.headers.get('Content-Type')?.split(';')[0].trim().toLowerCase()!=='application/json')return asc1674Json({ok:false,error:'Same-origin JSON required'},403);
 const payload=await fcPayload(req,128);
 if(payload?.confirm!==true)return asc1674Json({ok:false,error:'Explicit confirmation required'},400);
 const result=await asc1674RetryDue(env);
 return asc1674Json({ok:true,...result});
}
//__ASC1674_ROUTE_INSERTION__
    if(path==='/__stage1674/push-health'&&request.method==='GET')return await asc1674Page(request,env,ctx);
    if(path==='/__stage1674/status'&&request.method==='GET')return await asc1674Status(request,env,ctx);
    if(path==='/__stage1674/retry-due'&&request.method==='POST')return await asc1674Retry(request,env,ctx);
    if(['/__stage1674/push-health','/__stage1674/status','/__stage1674/retry-due'].includes(path))return asc1674Json({ok:false,error:'Method Not Allowed'},405);
