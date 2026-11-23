// ArcScriptCenter Account QA: non-authenticating STAGING holding Worker.
// Intentionally no D1 bindings, credentials, login forms, account writes or redirects.
// Replace this deployment with the reviewed account Worker only after isolated QA is ready.
const security = {
  'Cache-Control':'no-store, max-age=0',
  'Content-Security-Policy':"default-src 'none'; style-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
  'Referrer-Policy':'no-referrer',
  'X-Content-Type-Options':'nosniff',
  'X-Frame-Options':'DENY'
};
const reply = (status, body, contentType, extra={}) =>
  new Response(body, {status,headers:{...security,'Content-Type':contentType,...extra}});
const json = (status, value) => reply(status,JSON.stringify(value),'application/json; charset=utf-8');
const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow"><title>ArcScriptCenter Account · QA Provisioning</title>
<link rel="stylesheet" href="/style.css"></head><body><main>
<p class="tag">STAGING ONLY · Account QA</p>
<h1>ArcScriptCenter Account</h1><h2>Registration and login are not available yet.</h2>
<p>The ExperienceSettings login interface is ready for mobile UI testing, but the isolated account database and authenticated API have not been deployed.</p>
<p>No account has been banned by this message. Pairing, new registrations, and 2-step verification are unavailable until the QA backend is provisioned.</p>
<p class="notice">Do not enter or share your password, pairing credentials, or verification codes here.</p>
<p class="foot">Service state: <strong>Provisioning</strong> · This is not the production account service.</p>
</main></body></html>`;
const css=`:root{color-scheme:dark;font:16px system-ui,sans-serif;background:#090e1c;color:#e8efff}body{margin:0;min-height:100vh;display:grid;place-items:center}main{box-sizing:border-box;margin:20px;max-width:640px;padding:clamp(20px,5vw,40px);border:1px solid #304568;border-radius:18px;background:#111b32;box-shadow:0 16px 55px #03050b77}h1{font-size:clamp(1.6rem,5vw,2.4rem);margin:16px 0 10px}h2{font-size:1.2rem;font-weight:600;color:#9ed6ff}p{line-height:1.55}.tag{display:inline-block;color:#9fd6ff;font-size:.8rem;letter-spacing:.08em;font-weight:bold}.notice{border-left:3px solid #65bfff;padding:10px 14px;background:#182947}.foot{margin-top:28px;font-size:.88rem;color:#bdc9df}`;
export default {
  async fetch(request){
    const url=new URL(request.url);
    if(url.search)return json(404,{ok:false,code:'not_found'});
    if(request.method==='GET'&&url.pathname==='/')
      return reply(200,html,'text/html; charset=utf-8');
    if(request.method==='GET'&&url.pathname==='/style.css')
      return reply(200,css,'text/css; charset=utf-8');
    if(request.method==='GET'&&url.pathname==='/health')
      return json(503,{ok:false,service:'ArcScriptCenter Account QA',status:'provisioning',registrationEnabled:false,loginEnabled:false});
    if(url.pathname.startsWith('/api/v1/accounts/'))
      return json(503,{ok:false,code:'account_qa_provisioning'});
    return json(404,{ok:false,code:'not_found'});
  }
};
