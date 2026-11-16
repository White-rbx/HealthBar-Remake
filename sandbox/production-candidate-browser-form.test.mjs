// Review-only HTML/JS contract and synthetic browser behavior. No external HTTP requests.
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {runInNewContext} from 'node:vm';

const read=name=>readFileSync(new URL(name,import.meta.url),'utf8');
const html=read('./production-feedback-appeal-form.html');
const js=read('./production-feedback-appeal-form.js');
const builder=read('./production-candidate-assembler.mjs');

test('HTML has UTF-8, mobile viewport and both Feedback/Appeal controls',()=>{
 assert.match(html,/<meta charset="utf-8">/);
 assert.match(html,/name="viewport"/);
 for(const x of ['id="request-form"','id="kind"','value="feedback"','value="appeal"','id="topic"','id="description"','id="user-id"','id="challenge"']){
  assert.ok(html.includes(x),x);
 }
});
test('public production sitekey and documented Turnstile JS only',()=>{
 assert.ok(js.includes('0x4AAAAAAGDcKTGgG4P3F1I4'));
 assert.ok(html.includes('https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'));
 assert.ok(!html.includes('0x4AAAAAAGCDj9GkRoOQYbsL'),'no Sandbox sitekey');
 assert.ok(!js.includes('0x4AAAAAAGCDj9GkRoOQYbsL'),'no Sandbox sitekey');
});
test('both protected Turnstile actions are tied to form kind',()=>{
 assert.ok(js.includes('action:kind.value==="appeal"?"appeal_submit":"feedback_submit"'));
 assert.ok(js.includes('turnstileToken:oneTimeToken'));
 assert.ok(js.includes('token=null;'));
 assert.ok(js.includes('resetChallenge()'));
});
test('receipt is never stored persistently, URL or console',()=>{
 assert.ok(!/localStorage/.test(js),'no long-lived user receipt storage');
 assert.ok(!/console\.(log|warn|error)/.test(js),'no accidental token/receipt logging');
 assert.ok(!/window\.location|location\.href|new URLSearchParams/.test(js),'no URL token/receipt transport');
 assert.ok(js.includes('sessionStorage.setItem("asc-feedback-anon-v1",clientKey)'));
 assert.ok(js.includes('credentials:"omit"'));
});
test('same-origin browser API contract includes receipt-scoped endpoints',()=>{
 for(const route of ['/api/v1/feedback/submit','/api/v1/feedback/status','/api/v1/feedback/manage']){
  assert.ok(js.includes(route),route);
 }
 assert.ok(js.includes('body:JSON.stringify(data)'));
 assert.ok(js.includes('mode:"same-origin"'));
 assert.ok(js.includes('cache:"no-store"'));
});
test('form receipt is not mixed into a GET link',()=>{
 assert.ok(html.includes('id="created-id" readonly'));
 assert.ok(html.includes('id="created-receipt" readonly'));
 assert.ok(js.includes('navigator.clipboard.writeText("Case ID: "+id+"\\nReceipt: "+receipt)'));
 assert.ok(!/href=.*receipt/i.test(html));
});
test('server-only credential never committed in frontend template',()=>{
 for(const x of ['ASC_TURNSTILE_REAL_SECRET','ASC_FEEDBACK_QUOTA_KEY','ASC_PUSH_VAPID_PRIVATE_JWK','ARCSCRIPT_ADMIN_KEY','GITHUB_TOKEN']){
  assert.ok(!html.includes(x)&&!js.includes(x),x);
 }
});
test('form handles successful and expired Turnstile tokens explicitly',()=>{
 for(const x of ['callback:t=>','"expired-callback":','"error-callback":','"timeout-callback":','window.turnstile.remove','window.turnstile.reset']){
  assert.ok(js.includes(x),x);
 }
});
test('backend assembles files from source-controlled artifacts, no external dependencies',()=>{
 assert.ok(builder.includes('new URL("./production-feedback-appeal-form.html",import.meta.url)'));
 assert.ok(builder.includes('new URL("./production-feedback-appeal-form.js",import.meta.url)'));
 assert.ok(builder.includes('const formServe="const ASC_RELEASE_FEEDBACK_FORM_HTML="'));
 assert.ok(builder.includes("function ascReleaseFeedbackFormPage()"));
 assert.ok(builder.includes("function ascReleaseFeedbackFormScript()"));
});
test('new HTML and JS routes are in the release allowlist and hostname gate',()=>{
 assert.ok(builder.includes('"/api/v1/feedback/form","/api/v1/feedback/form.js"'));
 assert.ok(builder.includes("if(path==='/api/v1/feedback/form'&&request.method==='GET')"));
 assert.ok(builder.includes("if(path==='/api/v1/feedback/form.js'&&request.method==='GET')"));
 assert.ok(builder.includes('if(url.hostname!==env.ASC_RELEASE_HOSTNAME)'));
 assert.ok(builder.includes('if(!ascReleaseEnvReady(env))'));
});
test('browser page security headers prevent embedding and leaked credentials',()=>{
 for(const x of ["'Cache-Control':'no-store, private'","'X-Content-Type-Options':'nosniff'","'Referrer-Policy':'no-referrer'","'X-Frame-Options':'DENY'","frame-ancestors 'none'","script-src 'self' https://challenges.cloudflare.com","frame-src https://challenges.cloudflare.com","form-action 'self'"]){
  assert.ok(builder.includes(x),x);
 }
});
test('no browser-side JS injection shortcuts',()=>{
 assert.ok(!/\b(innerHTML|insertAdjacentHTML|eval|new Function)\b/.test(js));
 assert.ok(js.includes('.textContent='));
});
test('synthetic browser initial load renders Feedback action without real fetch',()=>{
 const map=new Map(),listeners={};
 const get=id=>{
  if(!map.has(id))map.set(id,{
   value:'',disabled:false,hidden:false,textContent:'',dataset:{},replaceChildren(){},
   addEventListener(name,fn){listeners[id+':'+name]=fn}
  });
  return map.get(id);
 };
 get('kind').value='feedback';
 const ts={
  render(el,opts){listeners.widget=opts;return 'widget-1'},
  remove(){},reset(){}
 };
 let network=0;
 const windowObj={turnstile:ts,addEventListener(name,fn){listeners['window:'+name]=fn}};
 const context={document:{getElementById:get},window:windowObj,crypto:{getRandomValues(a){a.fill(10);return a}},sessionStorage:{getItem(){return null},setItem(){}},fetch(){network++;throw Error('HTTP not permitted')},navigator:{clipboard:{}},setTimeout,clearTimeout,confirm(){return false}};
 runInNewContext(js,context,{timeout:1000});
 listeners['window:load']();
 assert.equal(listeners.widget.action,'feedback_submit');
 assert.equal(get('submit').disabled,true);
 assert.equal(network,0);
 get('kind').value='appeal';
 listeners['kind:change']();
 assert.equal(listeners.widget.action,'appeal_submit');
 assert.equal(get('userid-group').hidden,false);
 assert.equal(network,0);
});


function mockBrowser(responses={}) {
 const elements=new Map(), listeners=new Map(), requests=[], widgets=[];
 const element=id=>{
  if(!elements.has(id)){
   const e={value:'',disabled:false,hidden:false,textContent:'',dataset:{},
     replaceChildren(){},addEventListener(event,callback){listeners.set(id+':'+event,callback)}};
   elements.set(id,e);
  }
  return elements.get(id);
 };
 element('kind').value='feedback';
 const turnstile={
  render(_container,opts){widgets.push(opts);return 'widget-'+widgets.length},
  remove(){},reset(){}
 };
 const confirmCalls=[];
 const w={turnstile,addEventListener(event,callback){listeners.set('window:'+event,callback)}};
 const ctx={
  document:{getElementById:element},
  window:w,
  crypto:{getRandomValues(array){array.fill(0x2a);return array}},
  sessionStorage:{getItem(){return null},setItem(){}},
  AbortController,
  fetch:async(path,options)=>{
   requests.push({path,body:JSON.parse(options.body),method:options.method,
     mode:options.mode,credentials:options.credentials,cache:options.cache});
   const answer=responses[path];
   if(!answer)throw Error('UNEXPECTED API: '+path);
   const payload=typeof answer==='function'?answer():answer;
   return{ok:payload.ok,status:payload.ok?200:400,json:async()=>payload};
  },
  navigator:{clipboard:{writeText:async()=>{}}},
  confirm:message=>{confirmCalls.push(message);return true},
  setTimeout,clearTimeout
 };
 runInNewContext(js,ctx,{timeout:1000});
 listeners.get('window:load')();
 return {element,listeners,requests,widgets,confirmCalls,click:id=>listeners.get(id+':click')()};
}

test('appeal receipt can edit without re-entering unexposed Roblox UserId',async()=>{
 const id='11111111-2222-4333-8444-555555555555';
 const receipt='b'.repeat(64);
 const responses={
  '/api/v1/feedback/status':{ok:true,case:{id,kind:'appeal',
    topic:'Existing appeal',description:'D'.repeat(60),status:'reviewing',
    revision:0,canManage:true,publicNote:''},history:[]},
  '/api/v1/feedback/manage':{ok:true,removed:false,revision:1}
 };
 const b=mockBrowser(responses);
 b.element('lookup-id').value=id;
 b.element('lookup-receipt').value=receipt;
 await b.click('check-status');
 assert.equal(b.requests.length,1);
 assert.equal(b.element('kind').value,'appeal');
 assert.equal(b.element('user-id').value,'','status API does not expose claimed UserId');
 assert.equal(b.element('edit-case').disabled,false);
 b.element('topic').value='Corrected appeal';
 b.element('description').value='E'.repeat(65);
 await b.click('edit-case');
 assert.equal(b.requests.length,2,'edit must post even without a claim');
 const update=b.requests[1];
 assert.equal(update.path,'/api/v1/feedback/manage');
 assert.equal(update.body.operation,'edit');
 assert.equal(update.body.id,id);
 assert.equal(update.body.receipt,receipt);
 assert.equal(update.body.topic,'Corrected appeal');
 assert.equal(update.body.description,'E'.repeat(65));
 assert.equal(Object.hasOwn(update.body,'claimedUserId'),false);
 assert.equal(Object.hasOwn(update.body,'turnstileToken'),false);
 assert.equal(update.mode,'same-origin');
 assert.equal(update.credentials,'omit');
 assert.equal(update.cache,'no-store');
 assert.equal(b.element('case-section').hidden,true,'refresh status after edit');
});

test('new appeal still requires claimed Roblox UserId and valid Turnstile token',async()=>{
 const id='11111111-2222-4333-8444-555555555555',receipt='a'.repeat(64);
 const b=mockBrowser({'/api/v1/feedback/submit':{ok:true,id,receipt,status:'reviewing'}});
 b.element('kind').value='appeal';
 b.listeners.get('kind:change')();
 b.element('topic').value='New appeal request';
 b.element('description').value='A'.repeat(65);
 const widget=b.widgets.at(-1);
 assert.equal(widget.action,'appeal_submit');
 widget.callback('synthetic-test-token');
 assert.equal(b.element('submit').disabled,false);
 const submit=b.listeners.get('request-form:submit');
 await submit({preventDefault(){}});
 assert.equal(b.requests.length,0,'invalid missing user ID must not send API request');
 assert.match(b.element('message').textContent,/UserId/);
 b.element('user-id').value='123456789';
 await submit({preventDefault(){}});
 assert.equal(b.requests.length,1);
 const data=b.requests[0];
 assert.equal(data.path,'/api/v1/feedback/submit');
 assert.equal(data.body.kind,'appeal');
 assert.equal(data.body.claimedUserId,'123456789');
 assert.equal(data.body.turnstileToken,'synthetic-test-token');
 assert.match(data.body.clientKey,/^[a-f0-9]{64}$/i);
 assert.equal(b.element('created-receipt').value,receipt);
 assert.equal(b.element('created-id').value,id);
 assert.equal(b.element('submit').disabled,true,'token must be reset after consumption');
});

test('removing a receipt-scoped case clears displayed secret receipt',async()=>{
 const id='11111111-2222-4333-8444-555555555555',receipt='c'.repeat(64);
 const b=mockBrowser({
  '/api/v1/feedback/status':{ok:true,case:{id,kind:'feedback',
    topic:'Existing problem',description:'D'.repeat(55),status:'reviewing',
    revision:0,canManage:true,publicNote:''},history:[]},
  '/api/v1/feedback/manage':{ok:true,removed:true,revision:1}
 });
 b.element('created-id').value=id;
 b.element('created-receipt').value=receipt;
 b.element('receipt-section').hidden=false;
 b.element('lookup-id').value=id;
 b.element('lookup-receipt').value=receipt;
 await b.click('check-status');
 await b.click('remove-case');
 assert.equal(b.requests.length,2);
 assert.equal(b.requests[1].body.operation,'remove');
 assert.equal(b.element('created-id').value,'');
 assert.equal(b.element('created-receipt').value,'');
 assert.equal(b.element('receipt-section').hidden,true);
 assert.equal(b.element('lookup-receipt').value,'');
 assert.equal(b.element('case-summary').textContent,'');
});
