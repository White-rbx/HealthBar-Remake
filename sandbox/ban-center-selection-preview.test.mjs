import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';

const worker=readFileSync('sandbox/pages-native-ban-center-mode-preview-20261119.js','utf8');
const script=readFileSync('sandbox/ban-check-center-selection-preview.js','utf8');

test('Ban Center addon is valid JavaScript and preserves native UI IDs',()=>{
 new vm.Script(script,{filename:'ban-center-mode-preview.js'});
 const encoded=worker.match(/const BAN_MODE_SCRIPT = ("(?:\\.|[^"\\])*");/);
 assert.ok(encoded);
 assert.equal(JSON.parse(encoded[1]),script);
 for(const name of ['banEditorForm','banRecords','banAdminKey','banStart','banEnd','banSelection','banDuration','banSave'])
  assert.ok(script.includes(name),name);
 for(const choice of ['ban_ingame','restricted_mode','temporary','permanent'])
  assert.ok(script.includes(choice),choice);
});

test('Ban Selection UI never silently saves fields unsupported by STAGING schema 1',()=>{
 assert.match(script,/form\.addEventListener\('submit',e=>/);
 assert.match(script,/e\.preventDefault\(\);e\.stopImmediatePropagation\(\)/);
 assert.match(script,/saving is disabled until the Ban API supports Selection/);
 assert.match(script,/schema v1 remains read-only/);
 assert.match(script,/Ban in-game — SetUp only/);
 assert.match(script,/Restricted Mode — limited Main Loader/);
 assert.match(script,/Selection not set \(legacy: SetUp-only\)/);
 assert.doesNotMatch(script,/localStorage|sessionStorage|document\.cookie/);
});

test('Native Pages function serves addon as no-store first-party JS and preserves User’s Case',()=>{
 const source=worker.replace('export default {','const previewWorker = {');
 new vm.Script(source,{filename:'pages-native-ban-center-mode-preview.js'});
 assert.match(worker,/url\.pathname==='\/__asc1650\/ban-mode\.js'/);
 assert.match(worker,/new Response\(BAN_MODE_SCRIPT, \{headers:headers\('text\/javascript'\)\}\)/);
 assert.match(worker,/const BAN_MODE_TAG/);
 assert.match(worker,/on\('body',\{element\(e\)\{if\(addBanUI\)e\.append\(BAN_MODE_TAG/);
 assert.match(worker,/injected-users-case-native/);
 assert.match(worker,/injected-ban-selection-preview/);
 assert.match(worker,/env\.ASSETS\.fetch\(request\)/);
 assert.match(worker,/no-store/);
});
