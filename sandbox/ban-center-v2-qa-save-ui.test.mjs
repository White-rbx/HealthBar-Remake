import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const js=fs.readFileSync('sandbox/ban-check-center-selection-preview.js','utf8');
const worker=fs.readFileSync('sandbox/pages-native-ban-center-mode-preview-20261119.js','utf8');
test('Save to QA UI script is valid and injected exactly once',()=>{
 new vm.Script(js,{filename:'ban-center-selection-preview.js'});
 const match=worker.match(/const BAN_MODE_SCRIPT = ("(?:\\.|[^"\\])*");/);
 assert.ok(match,'Embedded addon found');
 assert.equal(JSON.parse(match[1]),js,'Embedded addon syncs exactly');
 new vm.Script(worker.replace('export default {','const qaWorker={'),{filename:'pages-worker.js'});
 assert.equal((worker.match(/const BAN_MODE_SCRIPT/g)||[]).length,1);
 assert.equal((js.match(/id='banSaveQaOnly'/g)||[]).length,1);
});
test('original live GitHub Ban Save still intercepted before native handler',()=>{
 assert.match(js,/form\.addEventListener\('submit',e=>\{/);
 assert.match(js,/e\.preventDefault\(\);e\.stopImmediatePropagation\(\)/);
 assert.match(js,/GitHub Save is disabled while schema v1 is live/);
 assert.match(js,/Save to QA Sandbox stores test records only/);
 assert.doesNotMatch(js,/fetch\(\s*['"]https:\/\/api\.github\.com/);
});
test('existing Admin Unlock is reused before original clears input; no second login or storage',()=>{
 assert.match(js,/document\.getElementById\('banUnlock'\)\?\.addEventListener\('click',\(\)=>\{/);
 assert.match(js,/sessionKey=keyField\.value\.trim\(\)/);
 assert.match(js,/\},true\);/);
 assert.match(js,/const key=sessionKey/);
 assert.match(js,/loadId\+\+;sessionKey='';list\.clear\(\)/);
 assert.doesNotMatch(js,/localStorage|sessionStorage|document\.cookie/);
 assert.doesNotMatch(js,/console\.log\(sessionKey/);
});
test('QA-only records stay in a distinct panel and cannot be presented as live bans',()=>{
 assert.match(js,/qaPanel\.id='banQaOnlyPanel'/);
 assert.match(js,/qaRecords\.id='banQaRecords'/);
 assert.match(js,/qaEndpoint='https:\/\/arcscriptcenter-ban-v2-qa/);
 assert.match(js,/data\?\.adminOnly!==true\|\|data\?\.qaOnly!==true/);
 assert.match(js,/expectedRevision:qaState\.revision/);
 assert.match(js,/No live ban was changed/);
 assert.match(js,/QA ONLY/);
 assert.match(js,/sessionKey!==key/);
});
test('Ban in-game and Restricted Mode are distinct from Temporary/Permanent',()=>{
 for(const mode of ['ban_ingame','restricted_mode'])
  assert.ok(js.includes(mode));
 for(const dur of ['temporary','permanent'])
  assert.ok(js.includes(dur));
 assert.match(js,/duration:duration\.select\.value/);
 assert.match(js,/selection:selection\.select\.value/);
 assert.match(js,/duration==='temporary'&&!entry\.expiresAt/);
});


test('v1/v2 migration Preview is read-only and shares the original private Admin session',()=>{
 assert.match(js,/id='banPreviewBanV2'/);
 assert.match(js,/Preview Ban v1 → v2/);
 assert.match(js,/compatEndpoint='https:\/\/arcscriptcenter-ban-v2-qa/);
 assert.match(js,/readOnly!==true/);
 assert.match(js,/result\.document\?\.schema!==2/);
 assert.match(js,/Original schema:/);
 assert.match(js,/No GitHub changes were made/);
 assert.match(js,/migrationResults\.replaceChildren\(\)/);
 assert.match(js,/qaRequest\('GET',undefined,compatEndpoint\)/);
 assert.doesNotMatch(js,/localStorage|sessionStorage|document\.cookie/);
});
