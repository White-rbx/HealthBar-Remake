import test from 'node:test';
import assert from 'node:assert/strict';
import {prepareFeedbackDashboardStagingHtml} from './feedback-dashboard-staging-adapter.mjs';

const NAV='<button type="button" class="nav-item" data-page="feedback-appeal" id="asc1649FeedbackNav" aria-label="Feedback and Appeal">Feedback &amp; Appeal</button>';
const SECTION='<section class="page" id="page-feedback-appeal">';
const SCRIPT='<script defer src="/__asc1649/feedback-appeal.js"></script>';
const WARNING='<div class="fa-muted-warning" role="note"><b>Private admin workspace.</b> Do not share your Admin Key or screenshots containing personal submissions. A claimed Roblox UserId is not verified identity. Spam Mail is admin-only.</div>';
const original=()=>[
 '<!doctype html><html lang="en"><body>',
 '<nav>'+NAV+'</nav>',
 SECTION,
 WARNING,
 '<input id="faAdminKey" type="password"><button id="faUnlock">Unlock</button>',
 '<div id="faCaseList"></div><div id="faCaseDetail"></div>',
 '</section>',
 '<script>',
 "const API_BASE = 'https://arcscriptcenter-api-staging.kogpasan14.workers.dev';",
 '</script>',
 SCRIPT,
 '<!-- '+ 'EXACT-STAGING-SOURCE-FIXTURE '.repeat(280)+' -->',
 '</body></html>'
].join('\n');

test('existing Feedback navigation, case editor and Pages JS remain unchanged',()=>{
 const before=original(),after=prepareFeedbackDashboardStagingHtml(before);
 for(const anchor of [NAV,SECTION,SCRIPT,'id="faAdminKey"','id="faCaseDetail"','id="faUnlock"']){
  assert.equal(after.split(anchor).length,before.split(anchor).length,'Native UI anchor changed: '+anchor);
 }
 assert.equal(after.split('data-page="feedback-appeal"').length,2);
 assert.equal(after.split('id="page-feedback-appeal"').length,2);
 assert.equal(after.split('id="faAdminKey"').length,2);
 assert.doesNotMatch(after,/id="page-feedback"|data-page="feedback"/);
 assert.match(after,/Feedback and Appeal UserIds are user-provided, unverified claims/);
 assert.match(after,/Spam Mail is admin-only/);
});

test('fail closed for earlier mistakenly duplicated Feedback panel',()=>{
 assert.throws(()=>prepareFeedbackDashboardStagingHtml(original()+'<section class="page" id="page-feedback"></section>'),/Duplicate Feedback/);
 assert.throws(()=>prepareFeedbackDashboardStagingHtml(original().replace(SECTION,'')),/native Feedback page/);
 assert.throws(()=>prepareFeedbackDashboardStagingHtml(original().replace(NAV,'')),/native sidebar/);
 assert.throws(()=>prepareFeedbackDashboardStagingHtml(original().replace(SCRIPT,'')),/native Pages JS/);
 assert.throws(()=>prepareFeedbackDashboardStagingHtml(original().replace('staging.kogpasan14','kogpasan14')),/non-STAGING/);
});

test('no new authentication, network requests, browser storage or case access added',()=>{
 const before=original(),after=prepareFeedbackDashboardStagingHtml(before);
 const delta=after.length-before.length;
 assert.ok(delta>0&&delta<200,'Only warning copy should change');
 assert.equal(after.includes('ascFbLoad'),false);
 assert.equal(after.includes('asc-fb-key'),false);
 assert.equal(after.includes('X-Admin-Key'),false);
 assert.equal(after.includes('localStorage'),false);
 assert.equal(after.includes('claimed_user_id'),false); // native JS owns data rendering
});

test('source drift stops auto-enhancement instead of inventing alternate UI',()=>{
 assert.throws(()=>prepareFeedbackDashboardStagingHtml(original().replace(WARNING,'Different security warning')),/warning changed/);
 assert.throws(()=>prepareFeedbackDashboardStagingHtml(original()+WARNING),/warning changed/);
});
