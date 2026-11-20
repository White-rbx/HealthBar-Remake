import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const p=n=>readFileSync('sandbox/'+n,'utf8');
const setup=p('ExperienceSettings-SetUp-BanMode-STAGING.lua');
const main=p('Loader-Main-BanMode-STAGING.lua');
const loader=p('Loader-UI-BanMode-STAGING.lua');
const arcsen=p('Arcsen-BanMode-STAGING.lua');
const topbar=p('RestrictedMode-Topbar-STAGING.lua');

test('SetUp translates Selection and Duration independently without reclassifying legacy bans',()=>{
 for(const t of ['ban_ingame','restricted_mode','temporary','permanent','SelectionAssigned','__ES_RESTRICTED_MODE','__ES_BAN_DURATION'])
  assert.ok(setup.includes(t),t);
 assert.match(setup,/getgenv\(\)\.__ES_BANNED = banData ~= nil and banData.Selection ~= "restricted_mode"/);
 assert.match(setup,/if banData and getgenv\(\)\.__ES_BANNED then/);
 assert.match(setup,/if banData and getgenv\(\)\.__ES_RESTRICTED_MODE and twarn then/);
 assert.match(setup,/selection = assigned and rawSelection or "ban_ingame"/);
 assert.match(setup,/Duration: <b>/);
});

test('Loader main routes selected restricted users through SetUp completion and MAIN, without Editor or Search',()=>{
 assert.ok(main.includes('ExperienceSettings-SetUp-BanMode-STAGING.lua'));
 assert.ok(main.includes('Loader-UI-BanMode-STAGING.lua'));
 assert.ok(main.includes('Arcsen-BanMode-STAGING.lua'));
 assert.ok(main.includes('RestrictedMode-Topbar-STAGING.lua'));
 assert.ok(main.includes('local isRestrictedMode = bootEnv.__ES_RESTRICTED_MODE == true'));
 assert.ok(main.includes('if not isRestrictedMode then'));
 assert.ok(main.includes('if not okGate or gateResult ~= true then'));
 assert.ok(main.includes('and not (bootEnv.__ES_RESTRICTED_MODE == true'));
 assert.ok(main.indexOf('RestrictedMode-Topbar-STAGING.lua') < main.indexOf('local arcsenUrl = isRestrictedMode'));
 assert.ok(main.includes('Only now is the Loader Rejoiner allowed to appear.'));
});

test('Loader UI rejects SetUp-only ban while accepting internally consistent Restricted Mode',()=>{
 assert.match(loader,/__ES_BANNED == true or _boot.__ES_READY ~= true/);
 assert.match(loader,/__ES_RESTRICTED_MODE == true/);
 assert.match(loader,/__ES_BAN_SELECTION ~= "restricted_mode"/);
 assert.match(loader,/__ES_SETUP_FINISHED == false/);
});

test('Restricted Mode UI preserves OpenClose/About/Arcsen, and records original button appearance for restoration',()=>{
 for(const k of ['a1_Open/Close','z7_About','z8_ChatGPT','z8_Arcsen','Interactable = false','BackgroundColor3 = disabledColor','TopButtons','DescendantAdded','saved','controller.stop'])
  assert.ok(topbar.includes(k),k);
 assert.ok(topbar.includes('Color3.fromRGB(89, 89, 89)'));
 assert.ok(topbar.includes('return false'));
});

test('Arcsen chat cannot be re-enabled by switching chats or pressing Send',()=>{
 assert.ok(arcsen.includes('local modeRestricted = env and env.__ES_RESTRICTED_MODE == true'));
 assert.ok(arcsen.includes('local restricted = status ~= "not_banned" or modeRestricted'));
 assert.ok(arcsen.includes('if modeRestricted and gate.wasModeRestricted ~= true then'));
 assert.ok(arcsen.includes('showSettings()'));
 assert.ok(arcsen.includes('c_b_send.Interactable = false'));
 assert.ok(arcsen.includes('c_box.TextEditable = false'));
 assert.ok(arcsen.includes('if loc.API.PolicyReadOnly == true\n        or (type(getgenv) == "function"'));
 assert.ok(arcsen.includes('loc.API.UpdateArcScriptCenterViolationBanState(false)'));
});

test('no live Production URL or service token inserted in the patch assets',()=>{
 for(const s of [setup,main,loader,arcsen,topbar]){
  assert.doesNotMatch(s,/gh[pousr]_[A-Za-z0-9]{25,}/);
  assert.doesNotMatch(s,/sk-[A-Za-z0-9]{24,}/);
 }
 assert.ok(main.includes('feedback-appeal-release-track/sandbox/'));
});
