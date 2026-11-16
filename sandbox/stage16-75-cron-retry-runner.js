// Stage16.75 Sandbox-only Cron trigger runner and aggregate admin health. No secrets.
const ASC1675_CRON_HTML= "<!doctype html><html lang=\"th\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><meta name=\"robots\" content=\"noindex,nofollow\"><title>ArcScriptCenter Cron Retry Health</title><style>:root{color-scheme:dark;background:#0e1927;color:#f0f6ff;font:16px system-ui,sans-serif}body{max-width:700px;margin:auto;padding:18px 13px}section{border:1px solid #3f5872;border-radius:12px;background:#1b2d43;padding:16px;margin:14px 0}p{color:#c1d2e5;line-height:1.6}button{background:#1979b7;padding:12px 16px;color:white;border:0;border-radius:8px;font:600 1rem system-ui}pre{padding:13px;border-radius:9px;background:#283c55;white-space:pre-wrap;overflow-wrap:anywhere;font:15px system-ui}small{color:#aebfd3}a{color:#a4d8ff}</style><script nonce=\"__NONCE__\">(()=>{'use strict';async function refresh(){const box=document.getElementById('state');try{const r=await fetch('/__stage1675/status',{credentials:'same-origin',cache:'no-store',headers:{Accept:'application/json'}});if(!(r.headers.get('Content-Type')||'').includes('application/json'))throw Error('Cloudflare Access session expired');const x=await r.json();if(!r.ok||!x.ok)throw Error(x.error||'HTTP '+r.status);box.textContent='Cron: every 5 min (UTC)\\nRuns: '+x.cronRuns+'\\nLast result: '+x.lastError+'\\nLast tick: '+(x.lastStartedUnix?new Date(x.lastStartedUnix*1000).toLocaleString():'Not yet')+'\\nJobs: '+x.lastJobs+'\\nPush attempts: '+x.lastAttempted+'\\nAccepted: '+x.lastAccepted+'\\nFailed: '+x.lastFailed+'\\n\\nDue: '+x.due+'\\nPending: '+x.counts.pending+'\\nRetry: '+x.counts.retry+'\\nSending: '+x.counts.sending+'\\nDelivered: '+x.counts.delivered+'\\nDead: '+x.counts.dead+'\\nSubscriptions: '+x.subscribers;}catch(e){box.textContent='Error: '+e.message}}document.addEventListener('DOMContentLoaded',()=>{document.getElementById('refresh').onclick=refresh;refresh()});})();</script></head><body><small>ACCESS ADMIN ONLY · SANDBOX</small><h1>🔔 Automatic Push Retry</h1><p>ตรวจงานที่ถึงกำหนดผ่าน Cloudflare Cron ทุก 5 นาที ระบบใช้ D1 Outbox เดิมพร้อมล็อกป้องกันการส่งซ้อน</p><section><pre id=\"state\">Loading…</pre><button id=\"refresh\">Refresh Status</button></section><p>Push Service ตอบรับ ไม่ได้แปลว่า Android แสดง Notification อย่างแน่นอน และไม่รับประกัน exactly-once</p><p><a href=\"/__stage1674/push-health\">Manual Retry Health</a></p><small>หน้าเว็บไม่มี Push Endpoint, User ID, Admin Key หรือเนื้อหาคำร้อง</small></body></html>";
async function asc1675CronRunner(controller,env,ctx){
 if(!VERSION.includes('-sandbox')||env.ASC_TURNSTILE_MODE!=='sandbox-dummy'||
    typeof env.ASC_PUSH_ACCESS_AUD!=='string'||
    !/^[A-Za-z0-9_-]{32,128}$/.test(env.ASC_PUSH_ACCESS_AUD)||!env.DB||
    controller?.cron!=='*/5 * * * *')return;
 const now=Math.floor(Date.now()/1000);
 await env.DB.prepare("UPDATE asc_push_cron_health_v1 SET runs=runs+1,last_started_unix=?,last_error='none' WHERE scope='sandbox_push_cron'").bind(now).run();
 try{
  await env.DB.prepare("UPDATE asc_push_delivery_outbox_v1 SET state='dead',lease_until_unix=0,updated_unix=? WHERE state='sending' AND attempts>=3 AND lease_until_unix<=?").bind(now,now).run();
  const r=await asc1674RetryDue(env);
  await env.DB.prepare("UPDATE asc_push_cron_health_v1 SET last_finished_unix=?,last_jobs=?,last_attempted=?,last_accepted=?,last_failed=?,last_error='none' WHERE scope='sandbox_push_cron'").bind(Math.floor(Date.now()/1000),Number(r.jobs||0),Number(r.attempted||0),Number(r.accepted||0),Number(r.failed||0)).run();
 }catch{
  try{await env.DB.prepare("UPDATE asc_push_cron_health_v1 SET last_finished_unix=?,last_error='worker_error' WHERE scope='sandbox_push_cron'").bind(Math.floor(Date.now()/1000)).run()}catch{}
 }
}
async function asc1675Page(req,env,ctx){
 if(!(await asc1674Allowed(req,env,ctx)))return new Response('Unauthorized',{status:401,headers:{'Cache-Control':'no-store'}});
 const random=crypto.getRandomValues(new Uint8Array(18)),nonce=btoa(Array.from(random,b=>String.fromCharCode(b)).join(''));
 return new Response(ASC1675_CRON_HTML.replaceAll('__NONCE__',nonce),{status:200,headers:{
  'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store, private','X-Content-Type-Options':'nosniff','Referrer-Policy':'no-referrer','X-Robots-Tag':'noindex,nofollow',
  'Content-Security-Policy':"default-src 'none';script-src 'nonce-"+nonce+"';connect-src 'self';style-src 'unsafe-inline';base-uri 'none';form-action 'none';frame-ancestors 'none'"
 }});
}
async function asc1675Status(req,env,ctx){
 if(!(await asc1674Allowed(req,env,ctx)))return asc1674Json({ok:false,error:'Unauthorized'},401);
 const now=Math.floor(Date.now()/1000);
 const [h,rows,due,subs]=await Promise.all([
  env.DB.prepare("SELECT runs,last_started_unix,last_finished_unix,last_jobs,last_attempted,last_accepted,last_failed,last_error FROM asc_push_cron_health_v1 WHERE scope='sandbox_push_cron'").first(),
  env.DB.prepare('SELECT state,COUNT(*) AS n FROM asc_push_delivery_outbox_v1 GROUP BY state').all(),
  env.DB.prepare("SELECT COUNT(*) AS n FROM asc_push_delivery_outbox_v1 WHERE (state IN ('pending','retry') AND next_retry_unix<=?) OR (state='sending' AND lease_until_unix<=?)").bind(now,now).first(),
  env.DB.prepare('SELECT COUNT(*) AS n FROM asc_admin_push_subscriptions_v1 WHERE enabled=1').first()
 ]);
 const counts={pending:0,retry:0,sending:0,delivered:0,dead:0,canceled:0};
 for(const row of rows.results||[])if(Object.prototype.hasOwnProperty.call(counts,row.state))counts[row.state]=Number(row.n||0);
 return asc1674Json({ok:true,cronRuns:Number(h?.runs||0),lastStartedUnix:Number(h?.last_started_unix||0),
  lastFinishedUnix:Number(h?.last_finished_unix||0),lastJobs:Number(h?.last_jobs||0),
  lastAttempted:Number(h?.last_attempted||0),lastAccepted:Number(h?.last_accepted||0),
  lastFailed:Number(h?.last_failed||0),lastError:String(h?.last_error||'never'),
  due:Number(due?.n||0),counts,subscribers:Number(subs?.n||0)});
}
//__STAGE1675_ROUTES__
    if(path==='/__stage1675/cron-health'&&request.method==='GET')return await asc1675Page(request,env,ctx);
    if(path==='/__stage1675/status'&&request.method==='GET')return await asc1675Status(request,env,ctx);
    if(['/__stage1675/cron-health','/__stage1675/status'].includes(path))
      return asc1674Json({ok:false,error:'Method Not Allowed'},405);
