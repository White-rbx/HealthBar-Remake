import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
import {passkeyPage} from './passkey-page.mjs';

const source=new URL('./passkey-client.js',import.meta.url);
const bundled=new URL('./passkey-client.txt',import.meta.url);
const styles=new URL('./passkey-style.css',import.meta.url);
const bundledStyles=new URL('./passkey-style.txt',import.meta.url);

test('arcscriptcenter-login provides Login, Sign In and MyAccount shell without credential collection',()=>{
 const html=passkeyPage('synthetic_turnstile_public_key');
 for(const x of ['arcscriptcenter-login','id="landing"','id="sign-in"','id="account"',
  'id="tab-home"','id="tab-login"','id="tab-account"','href="/signin"',
  '<h2>Login page</h2>','<h2>Sign In page</h2>','<h2>MyAccount</h2>',
  'id="passkey-login"','id="register-form"','id="recovery-form"',
  'id="add-backup-passkey"','id="pair-form"']){
  assert.ok(html.includes(x),x);
 }
 assert.match(html,/<input type="password"[^>]*disabled>/);
 assert.match(html,/<input type="text"[^>]*disabled>/);
 assert.doesNotMatch(html,/name="password"|autocomplete="current-password"/);
 assert.throws(()=>passkeyPage('bad'),/public key/);
});

test('bundled browser JS and CSS exactly match reviewed sources',()=>{
 assert.equal(readFileSync(source,'utf8'),readFileSync(bundled,'utf8'));
 assert.equal(readFileSync(styles,'utf8'),readFileSync(bundledStyles,'utf8'));
});

async function visit(pathname,validSession){
 const dom=new Map();
 function element(id){
  if(!dom.has(id))dom.set(id,{id,hidden:false,textContent:'',disabled:false,onclick:null});
  return dom.get(id);
 }
 const location={pathname,hash:''};
 const writes=[];
 const history={
  pushState(_s,_t,route){writes.push(route);update(route)},
  replaceState(_s,_t,route){writes.push(route);update(route)},
 };
 function update(route){const [path,hash]=route.split('#');location.pathname=path;location.hash=hash?'#'+hash:''}
 const window={location,history,addEventListener(){},isSecureContext:true,PublicKeyCredential:function(){}};
 const document={getElementById:element,querySelectorAll:()=>[]};
 const fetch=async url=>{
  assert.match(String(url),/^\/api\/v1\/accounts\/session$/);
  return validSession
   ?{ok:true,json:async()=>({ok:true,account:{username:'qa_user',nickname:'QA User'}})}
   :{ok:false,json:async()=>({ok:false,code:'session_expired'})};
 };
 vm.runInNewContext(readFileSync(source,'utf8'),{
  window,document,fetch,AbortSignal,URL,console,
 },{timeout:1000});
 // Let the initial server session promise resolve.
 await new Promise(resolve=>setImmediate(resolve));
 return {dom,location,writes,element};
}

test('an unauthenticated /myaccount deep link is redirected to Sign In',async()=>{
 const result=await visit('/myaccount',false);
 assert.equal(result.location.pathname,'/signin');
 assert.equal(result.element('account').hidden,true);
 assert.equal(result.element('sign-in').hidden,false);
 assert.match(result.element('status').textContent,/Sign in before opening MyAccount/);
 assert.equal(result.element('tab-account').hidden,true);
});

test('a valid server session opens MyAccount and maintains the three-page navigation',async()=>{
 const result=await visit('/signin',true);
 assert.equal(result.location.pathname,'/myaccount');
 assert.equal(result.element('identity').textContent,'QA User (@qa_user)');
 assert.equal(result.element('tab-account').hidden,false);
 result.element('tab-home').onclick();
 assert.equal(result.location.pathname,'/login');
 assert.equal(result.element('landing').hidden,false);
 result.element('tab-login').onclick();
 assert.equal(result.location.pathname,'/signin');
 assert.equal(result.element('sign-in').hidden,false);
 result.element('tab-account').onclick();
 assert.equal(result.location.pathname,'/myaccount');
 assert.equal(result.element('account').hidden,false);
});

test('the first page is a landing page when there is no authenticated session',async()=>{
 const result=await visit('/',false);
 assert.equal(result.location.pathname,'/login');
 assert.equal(result.element('landing').hidden,false);
 assert.equal(result.element('account').hidden,true);
});

test('duplicate backup credential has a clear message and never submits a duplicate',async()=>{
 const dom=new Map();
 const get=id=>{
  if(!dom.has(id))dom.set(id,{id,hidden:false,textContent:'',disabled:false,onclick:null});
  return dom.get(id);
 };
 const history={pushState(){},replaceState(){}};
 const window={location:{pathname:'/myaccount',hash:''},history,addEventListener(){},
  isSecureContext:true,PublicKeyCredential:function(){}};
 const PublicKeyCredential=function(){};
 PublicKeyCredential.parseCreationOptionsFromJSON=options=>options;
 PublicKeyCredential.parseRequestOptionsFromJSON=options=>options;
 const navigator={credentials:{
  get:async()=>({toJSON:()=>({id:'synthetic-current-credential'})}),
  create:async()=>{
   const error=new Error('The user attempted to register an authenticator that contains one of the credentials already registered with the relying party.');
   error.name='InvalidStateError';
   throw error;
  },
 }};
 const requests=[];
 const fetch=async url=>{
  const route=String(url).replace('/api/v1/accounts/','');
  requests.push(route);
  if(route==='session')return {ok:true,json:async()=>({
   ok:true,account:{username:'synthetic_qa',nickname:'Synthetic QA'}})};
  if(route==='passkey/backup/options')return {ok:true,json:async()=>({
   ok:true,options:{challenge:'synthetic-options'}})};
  if(route==='passkey/backup/verify-current')return {ok:true,json:async()=>({
   ok:true,options:{challenge:'synthetic-backup-options'}})};
  assert.fail('Unexpected API call after duplicate credential: '+route);
 };
 vm.runInNewContext(readFileSync(source,'utf8'),{
  window,document:{getElementById:get,querySelectorAll:()=>[]},fetch,
  navigator,PublicKeyCredential,AbortSignal,URL,console,
 },{timeout:1000});
 await new Promise(resolve=>setImmediate(resolve));
 await get('add-backup-passkey').onclick();
 assert.match(get('status').textContent,/already has a passkey for your account/);
 assert.match(get('status').textContent,/existing passkey is unchanged/);
 assert.equal(get('account').hidden,false);
 assert.equal(get('add-backup-passkey').disabled,false);
 assert.deepEqual(requests,['session','passkey/backup/options','passkey/backup/verify-current']);
});
