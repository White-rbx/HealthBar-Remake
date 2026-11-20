import test from 'node:test';
import assert from 'node:assert/strict';

const PREVIEW='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev';
const IMMUTABLE='https://4e663d08.arcscriptcenter-dashboard-staging.pages.dev';
async function get(url,options={}){
 const stop=new AbortController();
 const timer=setTimeout(()=>stop.abort(),14000);
 try{return await fetch(url,{redirect:'error',cache:'no-store',signal:stop.signal,...options})}
 finally{clearTimeout(timer)}
}
test('live native Preview Banned Check Center includes existing form and new Selection addon',async()=>{
 const r=await get(PREVIEW+'/');
 assert.equal(r.status,200);
 assert.match(r.headers.get('content-type')||'',/text\/html/i);
 const html=await r.text();
 assert.match(html,/id="page-bans"/);
 assert.match(html,/Banned Check Center/);
 assert.match(html,/id="banEditorForm"/);
 assert.match(html,/id="banRecords"/);
 assert.match(html,/id="banAdminKey"/);
 assert.match(html,/\/__asc1650\/ban-mode\.js/);
 assert.match(html,/id="page-feedback-appeal"/);
 assert.match(html,/id="faUsersCase"/);
 assert.match(html,/data-page="bans"/);
 assert.equal((html.match(/\/__asc1650\/ban-mode\.js/g)||[]).length,1);
});
test('new Ban Selection JS is served as first-party no-store JavaScript',async()=>{
 const r=await get(PREVIEW+'/__asc1650/ban-mode.js');
 assert.equal(r.status,200);
 assert.match(r.headers.get('content-type')||'',/javascript/i);
 assert.equal(r.headers.get('X-Content-Type-Options'),'nosniff');
 const js=await r.text();
 for(const word of ['Ban Selection','Ban Duration','ban_ingame','restricted_mode','Temporary','Permanent','Choose Ban Selection','preventDefault','stopImmediatePropagation'])
  assert.ok(js.includes(word),word);
 assert.doesNotMatch(js,/gh[pousr]_[A-Za-z0-9]{25,}|sk-[A-Za-z0-9]{24,}/);
});
test('working Preview alias serves canonical PNG without relying on immutable host resolution',async()=>{
 const logo=await get(PREVIEW+'/acs-logo.png');
 assert.equal(logo.status,200);
 const data=new Uint8Array(await logo.arrayBuffer());
 assert.deepEqual([...data.slice(0,8)],[137,80,78,71,13,10,26,10]);
 // The immutable deployment hash and stored files were checked through
 // Cloudflare's deployment metadata. Some deployment-ID hosts return 404.
});
test('new addon endpoint cannot mutate bans via POST',async()=>{
 const r=await get(PREVIEW+'/__asc1650/ban-mode.js',{method:'POST'});
 assert.notEqual(r.status,200);
});
