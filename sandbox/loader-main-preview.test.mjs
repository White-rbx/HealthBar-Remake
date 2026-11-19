import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const p = 'sandbox/LoaderMainPreview.lua';
const main = readFileSync(p,'utf8');
const stage = readFileSync('sandbox/Loader-Main-BanMode-STAGING.lua','utf8');
const setup = readFileSync('sandbox/ExperienceSettings-SetUp-Preview.lua','utf8');
const setupStage = readFileSync('sandbox/ExperienceSettings-SetUp-BanMode-STAGING.lua','utf8');
const arcsen = readFileSync('sandbox/Arcsen-Preview.lua','utf8');
const arcsenStage = readFileSync('sandbox/Arcsen-BanMode-STAGING.lua','utf8');

const previewUrl = 'https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/';
const count = (re,s) => [...s.matchAll(re)].length;

test('preview contains the real Loader.lua body, not the previous fake GUI fixture', () => {
  assert.ok(main.split('\n').length >= 1600, 'full original Loader retained');
  assert.match(main, /Well 4\.12 \| v0\.5\.36: Strict SetUp -> Loader -> Main serialization/);
  assert.match(main, /Upstream blob 9d6af20cf93610adf9be2e49bf61edabe8903f38/);
  for(const fragment of ['__ES_BOOTSTRAP_BUSY', '__ES_SETUP_FINISHED', 'ES.done = true',
    'PHASE 3: Only now is the Loader Rejoiner allowed to appear.',
    'Get Load', 'WaitForChild("ExperienceSettings", 10)', 'SetZIndexRecursive(asrt)'])
    assert.ok(main.includes(fragment), 'original Loader invariant: '+fragment);
  for(const mock of ['ArcScriptCenter_LoaderMainPreview_QA', 'SetUpFixture',
    'MockEditor','MockSearch','MockTools','QAViewport'])
    assert.ok(!main.includes(mock), 'mock must be removed: '+mock);
});

test('real Loader source was reused faithfully with only preview-target substitutions', () => {
  const prefix=main.slice(main.indexOf('-- Well 4.12 | v0.5.36'));
  const scanFromStage=stage.replace(
    'table.insert(queue, "'+previewUrl+'Loader-UI-BanMode-STAGING.lua")',
    'table.insert(queue, "'+previewUrl+'LoaderMainPreview.lua")'
  );
  const protectedArcsen=scanFromStage.replace(
    /local arcsenUrl = isRestrictedMode\s*\n\s*and "https:\/\/raw\.githubusercontent\.com\/White-rbx\/HealthBar-Remake\/refs\/heads\/feedback-appeal-release-track\/sandbox\/Arcsen-BanMode-STAGING\.lua"\s*\n\s*or "https:\/\/raw\.githubusercontent\.com\/White-rbx\/HealthBar-Remake\/refs\/heads\/loadstring\/Arcsen\.lua"/,
    '-- This PREVIEW always uses the STAGING Arcsen source, including for unbanned QA\n'+
    '-- accounts, to avoid accidentally invoking the normal live Arcsen in a test.\n'+
    'local arcsenUrl = "'+previewUrl+'Arcsen-BanMode-STAGING.lua"'
  );
  const isolated=protectedArcsen
    .replace(previewUrl+'ExperienceSettings-SetUp-BanMode-STAGING.lua',
      previewUrl+'ExperienceSettings-SetUp-Preview.lua')
    .replace(previewUrl+'Arcsen-BanMode-STAGING.lua',
      previewUrl+'Arcsen-Preview.lua');
  assert.equal(prefix, isolated, 'unexpected drift from reviewed real Loader/BanMode source');
});

test('SetUp, UI Loader, topbar guard and Arcsen are all connected to staging',()=>{
  for(const file of ['ExperienceSettings-SetUp-Preview.lua',
    'Loader-UI-BanMode-STAGING.lua','RestrictedMode-Topbar-STAGING.lua',
    'Arcsen-Preview.lua','LoaderMainPreview.lua'])
    assert.ok(main.includes(previewUrl+file), 'staging URL missing: '+file);
  assert.doesNotMatch(main,/heads\/loadstring\/ExperienceSettings-SetUp\.lua/);
  assert.doesNotMatch(main,/heads\/loadstring\/Arcsen\.lua/);
  assert.match(main, /if bootEnv.__ES_RESTRICTED_MODE == true then/);
  assert.match(main, /if bootEnv.__ES_BAN_SELECTION ~= "restricted_mode" or bootEnv.__ES_BANNED == true then/);
  assert.match(main, /if not okGate or gateResult ~= true then/);
  assert.ok(main.indexOf('RestrictedMode-Topbar-STAGING.lua') <
    main.indexOf('loadstring(game:HttpGet(arcsenUrl))()'), 'lock before Arcsen');
});

test('in-game ban blocks real loader; restricted skips editor/search and preserves Arcsen',()=>{
  assert.match(main,/getgenv\(\).__ES_BANNED == true or getgenv\(\)\[string\.char/);
  assert.match(main,/local isRestrictedMode = bootEnv.__ES_RESTRICTED_MODE == true/);
  assert.match(main,/if not isRestrictedMode then\s*\n\s*loadstring\(game:HttpGet\("https:.*RecommendedScript\.lua/);
  assert.match(main,/if not isRestrictedMode then\s*\n\s*loadstring\(game:HttpGet\("https:.*Search\.lua/);
  assert.equal(count(/loadstring\(game:HttpGet\(arcsenUrl\)\)\(\)/g,main),1);
  assert.match(setup,/getgenv\(\).__ES_BANNED = banData ~= nil and banData.Selection ~= "restricted_mode"/);
  assert.match(setup,/__ES_BAN_DURATION = banData and banData.Duration or nil/);
  assert.match(setup,/local duration = expiresAt and "temporary" or "permanent"/);
});

test('reviewed preview never writes managed bans or live server policy',()=>{
  assert.doesNotMatch(main,/\/api\/v1\/admin\/bans\/v2\/qa/);
  assert.doesNotMatch(main,/arcscriptcenter-ban-v2-qa\.kogpasan14\.workers\.dev/);
  assert.doesNotMatch(main,/getgenv\(\)\.ArcsenRestrictedPreviewAllowed/);
  // This is still a real loader. Runtime and server authorization QA remain necessary.
});

test('SetUp Preview is a full isolated copy of the BanMode SetUp and preserves both choices',()=>{
  assert.ok(setup.includes(setupStage),'review source copied without removing SetUp');
  assert.match(setup,/__ES_BAN_SELECTION/);
  assert.match(setup,/__ES_BAN_DURATION/);
  assert.match(setup,/__ES_RESTRICTED_MODE/);
});

test('Arcsen Preview extends the full staged Arcsen while staying on the staging feedback endpoint',()=>{
  assert.ok(arcsen.length>arcsenStage.length,'full Arcsen source retained');
  assert.match(arcsen,/arcscriptcenter-api-staging\.kogpasan14\.workers\.dev/);
  assert.match(arcsen,/loc\.API\.PolicyReadOnly/);
  assert.match(arcsen,/identityVerified=false/);
  assert.match(arcsen,/PrivateCaseReceipt/);

});

test('Arcsen Preview no longer exposes Remember or on-device Case Receipt storage',()=>{
  for(const forbidden of [
    'caseVault','caseVaultConsent','caseVaultPath','caseVaultSave',
    'caseVaultRestore','RememberCasesOnThisDevice','RememberCasesNotice',
    'CaseReceipts-STAGING-','rememberPending','paintRemember'
  ]) assert.ok(!arcsen.includes(forbidden),'stale Remember artifact: '+forbidden);
  assert.match(arcsen,/local privateReceipts = \{\}/);
  assert.match(arcsen,/casePost\("\/api\/v1\/feedback\/status",\{id=id,receipt=receipt\}\)/);
  assert.match(arcsen,/Restore previous case \(ID \+ Receipt\)/);
});

test('active Case Delivery requires verified session, never claimed Roblox UserId',()=>{
  assert.match(arcsen,/GetVerifiedCaseSessionToken/);
  assert.match(arcsen,/No UserId parameter, no Admin key, no receipt persistence/);
  assert.match(arcsen,/if not token then/);
  assert.match(arcsen,/while gate.active and serverCasesFrame.Parent do/);
  assert.match(arcsen,/pcall\(pollVerifiedServerCases,false\)/);
  assert.match(arcsen,/task.wait\(45\)/);
  assert.match(arcsen,/Method="POST",Body='\{"active":true\}'/);
  assert.match(arcsen,/if not force and os.clock\(\)-lastDeliveryRequest<30 then return end/);
  assert.match(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/client\/cases\/poll"/);
  assert.match(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/client\/cases\/link"/);
  assert.doesNotMatch(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/admin\/bans"/);
});

test('refresh button checks both session receipts and server Case Delivery without early exit',()=>{
  assert.equal(count(/refreshCaseButton.Text="Refresh and Check Server's case"/g,arcsen),2);
  assert.match(arcsen,/pcall\(pollVerifiedServerCases,true\)/);
  assert.match(arcsen,/pcall\(refreshKnownFeedbackCases\)/);
  assert.doesNotMatch(arcsen,/refreshCaseButton.Text="Refresh Case Status \(STAGING\)"/);
  assert.doesNotMatch(arcsen,/if not hasCases then/);
});

test('Arcsen server-linked Case Delivery is active-only, verified-token-only and STAGING-only',()=>{
  assert.match(arcsen,/ServerCaseDeliveryPreview/);
  assert.match(arcsen,/RequestServerCases/);
  assert.match(arcsen,/GetVerifiedCaseSessionToken/);
  assert.match(arcsen,/if not token then/);
  assert.match(arcsen,/if deliveryBusy or not gate.active or not serverCasesFrame.Parent then return end/);
  assert.match(arcsen,/pcall\(pollVerifiedServerCases,false\)/);
  assert.match(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/client\/cases\/poll"/);
  assert.match(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/client\/cases\/link"/);
  assert.match(arcsen,/\["Authorization"\]="Bearer "\.\.token/);
  assert.match(arcsen,/LinkVerifiedOwnerCase/);
  assert.match(arcsen,/linkReceipt\.Text=""/);
  assert.match(arcsen,/serverVerified~=true/);
  assert.match(arcsen,/deliveryResult\.RichText=false/);
  assert.doesNotMatch(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/client\/cases\/poll"\s*\+.*UserId/);
});
