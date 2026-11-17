import test from 'node:test';
import assert from 'node:assert/strict';
import {Script} from 'node:vm';
import {prepareFeedbackDashboardStagingHtml} from './feedback-dashboard-staging-adapter.mjs';

const NAV='<button class="nav-item" data-page="warnings"><svg><use href="#i-bell"></use></svg> Global Warnings <span class="mini" id="warningNavCount">0</span></button>';
const PAGES="const pages = {dashboard:'Dashboard','active-users':'Active Users',warnings:'Global Warnings',bans:'Ban Management',audit:'Audit Logs',api:'API & Security'};";
const fixture=()=>[
  '<!doctype html><html lang="en"><body>',
  '<div class="sidebar">'+NAV+'</div>',
  '<main class="content"><section class="page" id="page-dashboard"></section><section class="page" id="page-api"></section></main>',
  '<script>(() => {',
  "  const API_BASE = 'https://arcscriptcenter-api-staging.kogpasan14.workers.dev';",
  "  const $=id=>document.getElementById(id);",
  PAGES,
  "  function closeMenu() {}",
  "  function go(page) {",
  "    if(page==='audit' && typeof auditState !== 'undefined' && auditState.key) auditLoad(false);",
  "  }",
  "})();</script>",
  '<!-- '+ 'SYNTHETIC-CI-FIXTURE '.repeat(260)+' -->',
  '</body></html>'
].join('\n');

test('additive new Feedback tab keeps original nav and pages intact',()=>{
  const old=fixture(),html=prepareFeedbackDashboardStagingHtml(old);
  for(const x of ['data-page="warnings"','data-page="feedback"','id="page-dashboard"','id="page-api"','id="page-feedback"']){
    assert.ok(html.includes(x),x);
  }
  assert.ok(html.includes("feedback:'Feedback & Appeal'"));
  assert.match(html,/Claimed UserId: /);
  assert.match(html,/Unverified/);
  assert.match(html,/Spam Mail \(Admin Only\)/);
  assert.ok(html.length>old.length);
});
test('new inline JS is syntactically valid and never stores credentials or executes raw case HTML',()=>{
  const html=prepareFeedbackDashboardStagingHtml(fixture());
  const script=html.match(/<script>([\s\S]*?)<\/script>/)?.[1];
  assert.ok(script);
  assert.doesNotThrow(()=>new Script(script));
  assert.match(script,/headers:\{Accept:'application\/json','X-Admin-Key':ascFb.key\}/);
  assert.match(script,/data\.adminOnly!==true/);
  assert.match(script,/credentials:'omit'/);
  assert.match(script,/ascFbText\('p'/);
  assert.match(script,/\.textContent=/);
  assert.doesNotMatch(script,/localStorage\.setItem|sessionStorage\.setItem|innerHTML\s*=\s*c\./);
});
test('missing/mismatched anchors and production HTML are rejected',()=>{
  const src=fixture();
  assert.throws(()=>prepareFeedbackDashboardStagingHtml(src.replace("arcscriptcenter-api-staging","arcscriptcenter-api")),/STAGING only/);
  assert.throws(()=>prepareFeedbackDashboardStagingHtml(src.replace(NAV,'')),/sidebar/);
  const patched=prepareFeedbackDashboardStagingHtml(src);
  assert.throws(()=>prepareFeedbackDashboardStagingHtml(patched),/Duplicate/);
});
test('request is read-only: no case submission, moderation mutations or public data access',()=>{
  const html=prepareFeedbackDashboardStagingHtml(fixture());
  assert.match(html,/\/api\/v1\/admin\/feedback\?status=/);
  assert.match(html,/method:'GET'/);
  assert.doesNotMatch(html,/\/api\/v1\/feedback\/submit|\/api\/v1\/violation\/history/);
  assert.match(html,/Account name:|Username \/ Nickname: Not provided by API/);
});
