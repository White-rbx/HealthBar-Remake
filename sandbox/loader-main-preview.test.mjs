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

test('preview extends the real Loader and keeps the reviewed bootstrap and main UI', () => {
  const prefix=main.slice(main.indexOf('-- Well 4.12 | v0.5.36'));
  const original=stage.slice(stage.indexOf('-- Well 4.12 | v0.5.36'));
  // Preserve the existing native segments around the explicitly added QA policy gates.
  for(const [start,end] of [
    ['-- ===== ERROR SYSTEM =====','local function catch(err)'],
    ['-- Function_Two.lua','local asrt ='],
  ]){
    const a=original.indexOf(start),b=original.indexOf(end,a);
    assert.ok(a>=0 && b>a);
    assert.ok(prefix.includes(original.slice(a,b||undefined)));
  }
  assert.match(prefix,/__ASC_BAN_POLICY_ERROR == true/);
  assert.match(prefix,/local client = bootEnv.__ASC_BAN_V2_CLIENT/);
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
    main.indexOf('print("[ES][QA] Starting Arcsen-Preview.lua")'), 'lock before Arcsen');
});

test('in-game ban blocks real loader; restricted retains Editor dependency but skips search',()=>{
  assert.match(main,/getgenv\(\).__ES_BANNED == true or getgenv\(\)\[string\.char/);
  assert.match(main,/local isRestrictedMode = bootEnv.__ES_RESTRICTED_MODE == true/);
  assert.match(main,/if not isRestrictedMode then\s*\n\s*loadTool\("RecommendedScript\.lua/);
  assert.match(main,/loadTool\("Editor\.lua"\)\s*\nlocal notification/);
  assert.ok(main.indexOf('loadTool("Editor.lua")') <
    main.indexOf('RestrictedMode-Topbar-STAGING.lua'), 'Editor initializes before gate');
  assert.ok(main.indexOf('loadTool("Editor.lua")') <
    main.indexOf('print("[ES][QA] Starting Arcsen-Preview.lua")'), 'Editor initializes before Arcsen');
  assert.match(main,/notificationMenu:FindFirstChild\("Notification"\)/);
  assert.match(main,/if not isRestrictedMode then\s*\n\s*loadTool\("Search\.lua/);
  assert.equal(count(/return compiled\("ban_qa"\)/g,main),1);
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
  const oldDateParser=setupStage.slice(setupStage.indexOf('local function _banTime(value)'),setupStage.indexOf('-- ARCSCRIPT_BANS_BEGIN'));
  assert.ok(setup.includes(oldDateParser),'legacy parser and selection handling kept');
  assert.match(setup,/client and client.policy\(\)/);
  assert.match(setup,/Could not verify your restriction status with the server/);
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
  assert.doesNotMatch(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/admin\/bans"/);
});


test('Case Delivery UI has no manual account verification or duplicate Check Server Cases button',()=>{
  for(const removed of ['LinkVerifiedOwnerCase',
    'ServerCaseLinkId','ServerCaseLinkPrivateReceipt','RequestServerCases',
    'local linkButton','deliveryButton']) {
    assert.ok(!arcsen.includes(removed),'stale account verification control: '+removed);
  }
  assert.match(arcsen,/Automatic case sync is not deployed yet/);
  assert.match(arcsen,/The existing Refresh button is the ONLY manual server-check action/);
  assert.match(arcsen,/Refresh and Check Server's case/);
  assert.match(arcsen,/serverCaseToken\(\)/);
  assert.match(arcsen,/privateReceipts = \{\}/);
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
  assert.match(arcsen,/GetVerifiedCaseSessionToken/);
  assert.match(arcsen,/if not token then/);
  assert.match(arcsen,/if deliveryBusy or not gate.active or not serverCasesFrame.Parent then return end/);
  assert.match(arcsen,/pcall\(pollVerifiedServerCases,false\)/);
  assert.match(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/client\/cases\/poll"/);
  assert.match(arcsen,/\["Authorization"\]="Bearer "\.\.token/);
  assert.match(arcsen,/serverVerified~=true/);
  assert.match(arcsen,/deliveryResult\.RichText=false/);
  assert.doesNotMatch(arcsen,/CASE_STAGING_BASE\.\."\/api\/v1\/client\/cases\/poll"\s*\+.*UserId/);
});

test('server-delivered cases render as read-only cards with no receipt or account-claim shortcut',()=>{
  assert.match(arcsen,/local serverLinkedCases = \{\} -- Verified server response only/);
  assert.match(arcsen,/if not token then\s*\n\s*-- Clear previously authorized cards/);
  assert.match(arcsen,/if code==401 then\s*\n\s*-- Never keep presenting previously authorized cases after expiry/);
  assert.match(arcsen,/nextLinked\[item.id\]=\{/);
  assert.match(arcsen,/serverLinkedCases=nextLinked/);
  assert.match(arcsen,/Server-linked Feedback delivered:/);
  assert.match(arcsen,/for id,item in pairs\(serverLinkedCases\) do/);
  assert.match(arcsen,/not \(own and own.verified == true and type\(own.receipt\) == "string"\)/);
  assert.match(arcsen,/ServerLinkedCaseReadOnly/);
  assert.match(arcsen,/view.Interactable = record.serverLinked ~= true/);
  assert.match(arcsen,/if record.serverLinked ~= true then\s*\n\s*view.MouseButton1Click:Connect/);
  assert.match(arcsen,/local privateReceipts = \{\} -- Session only/);
  // Private Receipt-authenticated operations remain distinct from server-listed read-only cases.
  assert.match(arcsen,/casePost\("\/api\/v1\/feedback\/status",\{id=id,receipt=receipt\}\)/);
});

test('New Chat draft has no stale selected tab and only becomes a chat on Send',()=>{
  assert.match(arcsen,/new\.MouseButton1Click:Connect\(function\(\)/);
  assert.match(arcsen,/-- Clear the old selected tab.s scale even if it is still present/);
  assert.match(arcsen,/for _, item in ipairs\(loc\.API\.ChatList\) do\s*\n\s*local itemScale = item:FindFirstChildOfClass\("UIScale"\)\s*\n\s*if itemScale then Tween\(itemScale, \{Scale = 0\.8\}, 0\.2\) end/);
  assert.match(arcsen,/loc\.API\.ActiveChatID = nil\s*\n\s*c_box\.Text = ""/);
  assert.match(arcsen,/loc\.API\.RenderChat\(nil\)\s*\n\s*loc\.API\.ClearNewChatDraftTab\(\)/);
  assert.match(arcsen,/draft\.Name = "NewChatDraftPreview"/);
  assert.match(arcsen,/c_box:GetPropertyChangedSignal\("Text"\):Connect\(function\(\)/);
  assert.match(arcsen,/draft\.Text = loc\.API\.FormatTempChatTitle\(c_box\.Text\)/);
  assert.match(arcsen,/if loc\.API\.ActiveChatID ~= nil then return end/);
  assert.match(arcsen,/loc\.API\.ChatData\[loc\.API\.NewChatID\]\.Tab = addchat\(nil, tempTitle, loc\.API\.NewChatID\)/);
  assert.match(arcsen,/if selectedScale then Tween\(selectedScale, \{Scale = 1\}, 0\.2\) end/);
});

test('first message is temporary UTF-8 title until AI generates its own',()=>{
  assert.match(arcsen,/loc\.API\.FormatTempChatTitle = function\(value\)/);
  assert.match(arcsen,/pcall\(utf8\.offset,title,49\)/);
  assert.match(arcsen,/local tempTitle = loc\.API\.FormatTempChatTitle\(firstMessage\)/);
  assert.match(arcsen,/Title = tempTitle,/);
  assert.match(arcsen,/TitleGenerated = false/);
  assert.match(arcsen,/loc\.API\.TitleChat\(chatID,loc\.API\.ChatData\[chatID\]\.Messages\[1\]\.text\)/);
  assert.match(arcsen,/loc\.API\.ChatData\[tostring\(chatID\)\]\.Title = loc\.API\.TitleResult/);
  assert.match(arcsen,/loc\.API\.ChatData\[tostring\(chatID\)\]\.TitleGenerated = true/);
  assert.match(arcsen,/loc\.API\.ClearNewChatDraftTab\(\)/);
});

test('HereChat Age Group warning is opt-in to explicit status and replaces an existing notice',()=>{
  assert.match(arcsen,/loc\.API\.ShowHereChatAgeGroupWarning = function\(group\)/);
  assert.match(arcsen,/group ~= "Unchecked" and group ~= "<9" and group ~= "Unchecked - <9"/);
  assert.match(arcsen,/kind == "age-group" and "⚠️ Age Group \(Unchecked - <9\)"/);
  assert.match(arcsen,/-- Same warning already visible: suppress duplicates/);
  assert.match(arcsen,/if count==1 and same==1 then/);
  assert.match(arcsen,/for index=#chat\.Messages,1,-1 do/);
  assert.match(arcsen,/and chat\.Messages\[index\]\.role=="chat-safety" then\s*\n\s*table\.remove\(chat\.Messages,index\)/);
  assert.match(arcsen,/table\.insert\(chat\.Messages,item\)/);
  assert.match(arcsen,/chatAgeGroup = \(savedMessage\.role == "chat-safety"\) and savedMessage\.chatAgeGroup or nil/);
  assert.match(arcsen,/loc\.API\.ShowHereChatAgeGroupWarning\(status\.ageGroup\)/);
  assert.match(arcsen,/metadata\.source == "HereChat" and metadata\.kind == "chat_safety"/);
  assert.match(arcsen,/loc\.API\.ShowHereChatAgeGroupWarning\(metadata\.ageGroup\)/);
  assert.match(arcsen,/CanUserChatAsync\(player\.UserId\)/);
  assert.match(arcsen,/CanUserChatAsync\s*\n\s*-- does not identify an account.s age/);
  assert.match(arcsen,/if type\(loc\.API\.SaveChats\)=="function" then loc\.API\.SaveChats\(\) end/);
});


test('Rejoin without a verified case delivery backend never claims account has no cases',()=>{
  assert.match(arcsen,/Automatic case sync is not deployed yet/);
  assert.match(arcsen,/Automatic server sync is not ready/);
  assert.match(arcsen,/STAGING Case Delivery API not deployed/);
  assert.match(arcsen,/No case loaded\. Use Restore previous case/);
  assert.match(arcsen,/No Denied case loaded here; rejoin auto-sync is not connected/);
  assert.match(arcsen,/Restore previous case \(ID \+ Receipt\)/);
  assert.match(arcsen,/\/api\/v1\/feedback\/status/);
  assert.doesNotMatch(arcsen,/No completed Denied feedback case in this session/);
});
