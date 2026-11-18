import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
const file='sandbox/arcscriptcenter-pages-users-trash-preview-20261118.worker.js';
const source=readFileSync(file,'utf8');
function value(name){
 const re=new RegExp('const '+name+' = ("(?:\\\\.|[^"\\\\])*");');
 const m=source.match(re);
 assert.ok(m,name+' must be present exactly once');
 assert.equal((source.match(new RegExp('const '+name+' = ','g'))||[]).length,1);
 return JSON.parse(m[1]);
}
test('Pages Worker preserves original static assets and fails closed on changed DOM',()=>{
 assert.match(source,/env\.ASSETS\.fetch\(request\)/);
 assert.match(source,/skipped-unrecognized-layout/);
 assert.match(source,/skipped-already-installed/);
 assert.match(source,/new HTMLRewriter\(\)/);
 assert.match(source,/page-bans/);
 assert.match(source,/X-Robots-Tag/);
});
test('Native users and trash UI is inserted exactly once',()=>{
 const section=value('MOD_SECTION'),nav=value('MOD_NAV');
 assert.equal(section.split('id="faUsersCasePanel"').length-1,1);
 assert.equal(section.split('id="faAdminKey"').length-1,1);
 assert.equal(section.split('id="faTrashPanel"').length-1,1);
 assert.equal(section.split('id="faUsersSearch"').length-1,1);
 assert.equal(nav.split('Feedback &amp; Appeal (Beta Feature)').length-1,1);
 assert.ok(value('MOD_STYLES').includes('.fa-users-columns'));
});
test('Embedded JavaScript syntax and locked Admin UI lifecycle',()=>{
 const js=value('MOD_SCRIPT');
 new vm.Script(js,{filename:'feedback-appeal-native.js'});
 assert.match(js,/function faUsersClear\(/);
 assert.match(js,/faUsersClear\(\)/);
 assert.match(js,/void faUsersLoad\(\)/);
 assert.match(js,/faState\.generation/);
 assert.match(js,/faState\.key/);
 assert.match(js,/Admin session changed/);
 assert.match(js,/claimed_user_id/);
 assert.match(js,/Move Unknown Case To Trash/);
 assert.match(js,/RESTORE UNKNOWN CASE/);
 assert.match(js,/arcscriptcenter-trash-admin-staging\.kogpasan14\.workers\.dev/);
 assert.ok(!js.includes('localStorage.setItem("fa'));
});
test('Do not change original login, ban data or permit public deletion',()=>{
 const js=value('MOD_SCRIPT');
 assert.ok(js.includes('async function faUnlock()'));
 assert.ok(js.includes('function faLock()'));
 assert.ok(js.includes('/api/v1/admin/feedback/list'));
 assert.ok(!js.includes('action:"purge"'));
 assert.ok(!js.includes("action:'purge'"));
});
