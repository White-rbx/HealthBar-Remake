// ArcScriptCenter: additive, review-only Feedback tab for existing STAGING Pages HTML.
// No Deployment. Admin key kept in JS memory, never persisted or placed into URLs.
const NAV='<button class="nav-item" data-page="warnings"><svg><use href="#i-bell"></use></svg> Global Warnings <span class="mini" id="warningNavCount">0</span></button>';
const PAGES="const pages = {dashboard:'Dashboard','active-users':'Active Users',warnings:'Global Warnings',bans:'Ban Management',audit:'Audit Logs',api:'API & Security'};";
const PAGE='<section class="page" id="page-api">';
const GO='  function go(page) {';
const AUDIT="    if(page==='audit' && typeof auditState !== 'undefined' && auditState.key) auditLoad(false);";
const HTML=[
  '<section class="page" id="page-feedback">',
  '<div class="page-head"><div><div class="eyebrow">Moderation / Inbox</div><h1>Feedback &amp; Appeal</h1>',
  '<p>Account identifiers are user-provided and unverified.</p></div><span class="tag blue">ADMIN ONLY</span></div>',
  '<div class="panel panel-pad"><div class="panel-top"><div><h3>Admin Case Inbox</h3>',
  '<p>Existing server Admin authorization is required. The key stays in browser memory only.</p></div></div>',
  '<div class="monitor-unlock"><label class="field">Admin Key <input id="asc-fb-key" type="password" autocomplete="off"></label>',
  '<button class="btn btn-primary" id="asc-fb-unlock" type="button">Unlock</button>',
  '<button class="btn" id="asc-fb-lock" type="button">Lock</button></div>',
  '<p id="asc-fb-status" role="status" aria-live="polite">Locked.</p></div>',
  '<div class="panel panel-pad"><div class="panel-top"><h3>Feedback &amp; Appeals</h3></div>',
  '<label class="field">Status <select id="asc-fb-filter">',
  '<option value="reviewing">Reviewing</option><option value="approved">Approved</option>',
  '<option value="denied">Denied</option><option value="violation">Violations</option>',
  '<option value="spam_mail">Spam Mail (Admin Only)</option></select></label>',
  '<button class="btn btn-primary" id="asc-fb-refresh" type="button" disabled>Refresh</button>',
  '<div id="asc-fb-results" aria-live="polite" style="display:grid;gap:12px;margin-top:16px"></div>',
  '</div></section>'
].join('\n');
const JS=[
"  // Feedback & Appeal panel: uses ONLY the existing authenticated Admin GET.",
"  const ascFb={key:'',busy:false,revision:0,openedAt:0};",
"  const ascFbMsg=t=>{$('asc-fb-status').textContent=String(t);};",
"  const ascFbText=(tag,t)=>{const e=document.createElement(tag);e.textContent=String(t??'');return e;};",
"  function ascFbLock(){ascFb.key='';ascFb.revision++;ascFb.openedAt=0;$('asc-fb-key').value='';",
"    $('asc-fb-results').replaceChildren();$('asc-fb-refresh').disabled=true;ascFbMsg('Locked.');}",
"  async function ascFbLoad(){",
"    if(!ascFb.key||ascFb.busy)return;",
"    if(Date.now()-ascFb.openedAt>600000){ascFbLock();return;}",
"    const status=$('asc-fb-filter').value;",
"    if(!['reviewing','approved','denied','violation','spam_mail'].includes(status))return;",
"    ascFb.busy=true;const rev=ascFb.revision;$('asc-fb-refresh').disabled=true;ascFbMsg('Loading cases…');",
"    const abort=new AbortController(),timer=setTimeout(()=>abort.abort(),10000);",
"    try{const r=await fetch(API_BASE+'/api/v1/admin/feedback?status='+encodeURIComponent(status),",
"      {method:'GET',mode:'cors',credentials:'omit',cache:'no-store',referrerPolicy:'no-referrer',",
"       headers:{Accept:'application/json','X-Admin-Key':ascFb.key},signal:abort.signal});",
"      if(r.status===401||r.status===403){ascFbLock();return;}",
"      if(!r.ok)throw Error('HTTP '+r.status);",
"      const data=await r.json();",
"      if(data?.ok!==true||data.adminOnly!==true||!Array.isArray(data.cases))throw Error('Unexpected Admin response');",
"      if(rev!==ascFb.revision||!ascFb.key)return;",
"      const host=$('asc-fb-results');host.replaceChildren();",
"      for(const c of data.cases.slice(0,100)){",
"        const card=document.createElement('article');card.className='panel panel-pad';",
"        card.append(ascFbText('h3',(c.kind==='appeal'?'Appeal':'Feedback')+' — '+(c.topic??'Untitled')));",
"        const claimed=c.claimed_user_id;",
"        card.append(ascFbText('p','Claimed UserId: '+",
"          (claimed==null||claimed===''?'Not provided':String(claimed))+' (Unverified)'));",
"        // The present Admin API does not return Username or Nickname.",
"        card.append(ascFbText('p','Username / Nickname: Not provided by API'));",
"        card.append(ascFbText('p','Status: '+String(c.status??'Unknown')));",
"        const detail=ascFbText('p',c.description??'');detail.style.whiteSpace='pre-wrap';",
"        detail.style.overflowWrap='anywhere';card.append(detail);host.append(card);",
"      }",
"      if(!data.cases.length)host.append(ascFbText('p','No cases found.'));",
"      ascFbMsg('Loaded '+data.cases.length+' case(s).');",
"    }catch(e){if(rev===ascFb.revision)ascFbMsg('Unable to load cases: '+String(e.message||'Request failed'));}",
"    finally{clearTimeout(timer);ascFb.busy=false;$('asc-fb-refresh').disabled=!ascFb.key;}",
"  }",
"  $('asc-fb-unlock').addEventListener('click',()=>{",
"    const key=$('asc-fb-key').value.trim();$('asc-fb-key').value='';",
"    if(!key){ascFbLock();return;}",
"    ascFb.key=key;ascFb.revision++;ascFb.openedAt=Date.now();void ascFbLoad();",
"  });",
"  $('asc-fb-lock').addEventListener('click',ascFbLock);",
"  $('asc-fb-refresh').addEventListener('click',()=>void ascFbLoad());",
"  $('asc-fb-filter').addEventListener('change',()=>void ascFbLoad());",
].join('\n');
function once(s,match,replacement,label){
  if(s.split(match).length!==2)throw Error('Dashboard source anchor changed: '+label);
  return s.replace(match,replacement);
}
export function prepareFeedbackDashboardStagingHtml(html){
  if(typeof html!=='string'||html.length<5000)throw Error('Exact current Dashboard HTML required');
  if(html.includes('id="page-feedback"'))throw Error('Duplicate feedback page');
  if(!html.includes("const API_BASE = 'https://arcscriptcenter-api-staging.kogpasan14.workers.dev';"))
    throw Error('STAGING only: refusing mismatched API');
  let s=once(html,NAV,NAV+'\n<button class="nav-item" data-page="feedback"><svg><use href="#i-list"></use></svg> Feedback &amp; Appeal</button>','sidebar');
  s=once(s,PAGES,PAGES.replace("warnings:'Global Warnings',","warnings:'Global Warnings',feedback:'Feedback & Appeal',"),'nav map');
  s=once(s,PAGE,HTML+'\n'+PAGE,'page content');
  s=once(s,AUDIT,AUDIT+"\n    if(page==='feedback' && ascFb.key)void ascFbLoad();",'router');
  return once(s,GO,JS+'\n'+GO,'script logic');
}
