import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const source=readFileSync('sandbox/Arcsen-Preview.lua','utf8');
function section(from,to){
 const start=source.indexOf(from);
 const end=source.indexOf(to,start+from.length);
 assert.ok(start>=0,from+' not found');
 assert.ok(end>start,to+' not found');
 return source.slice(start,end);
}

test('Remember Token toggle is opt-in and stored under opaque basename',()=>{
 const storage=section('local TOKEN_FILE = ','    local updateTokenPanel = function() end');
 assert.match(storage,/local TOKEN_FILE = "ExperienceSettings\/Arcsen\/Cache\/[a-f0-9]{16}\.json"/);
 assert.match(storage,/local function validUserCaseToken\(value\)/);
 assert.match(storage,/local function savedTokenExists\(\)/);
 assert.match(storage,/local function loadRememberedToken\(\)/);
 assert.match(storage,/local function removeRememberedToken\(\)/);
 assert.match(storage,/local function storeRememberedToken\(\)/);
 assert.match(storage,/pcall\(s\.HttpService\.JSONEncode,s\.HttpService,\{v=1,t=userCaseToken\}\)/);
 assert.match(storage,/pcall\(writefile,TOKEN_FILE,encoded\)/);
 assert.match(storage,/pcall\(delfile,TOKEN_FILE\)/);
 assert.match(storage,/if not savedTokenExists\(\) or type\(readfile\)~="function" then return false end/);
 assert.doesNotMatch(storage,/UserId|player\.Name|HWID|Fingerprint|claimedUserId/);
 assert.doesNotMatch(storage,/JSONEncode[^\n]*receipt|JSONEncode[^\n]*admin/);
});
test('Remember ON creates file only with a validated token; OFF requires actual file deletion',()=>{
 const ui=section('-- User Case Token: opt-in bearer key','-- SERVER CASE DELIVERY (STAGING Preview ONLY)');
 assert.match(ui,/Remember Token \[OFF\]/);
 assert.match(ui,/rememberTokenEnabled=true\s*\n\s*if validUserCaseToken\(userCaseToken\) then/);
 assert.match(ui,/storeRememberedToken\(\)/);
 assert.match(ui,/local ok,err=removeRememberedToken\(\)/);
 assert.match(ui,/if not ok then updateTokenPanel\(err\);return end/);
 assert.match(ui,/rememberTokenEnabled=false/);
 assert.match(ui,/caseTokenConsent=not caseTokenConsent/);
 assert.match(ui,/if not validUserCaseToken\(candidate\) then/);
 assert.match(ui,/local ok,err=refreshTokenCases\(\)/);
 assert.match(ui,/if not ok then\s*\n\s*userCaseToken,tokenLinkedCases=priorToken,priorCases/);
 assert.match(ui,/pcall\(setclipboard,userCaseToken\)/);
 assert.match(ui,/tokenPost\("revoke",\{token=target,confirm=true\}\)/);
 assert.match(ui,/confirmRevokeUntil=os\.clock\(\)\+15/);
 assert.doesNotMatch(ui,/gethwid|HWID=|deviceId=|GetClientId/);
});
test('case token creation follows a successful, explicitly opted-in feedback',()=>{
 const token=section('local function registerFeedbackWithToken(item)','    loc.API.ArcScriptCenterCaseSession');
 assert.match(token,/if not caseTokenConsent or not item or item.kind~="feedback"/);
 assert.match(token,/tokenPost\("create",\{id=item.id,receipt=item.receipt,consent=true\}\)/);
 assert.match(token,/tokenPost\("attach",\{token=userCaseToken,id=item.id,receipt=item.receipt\}\)/);
 assert.match(token,/if rememberTokenEnabled then/);
 assert.match(source,/if caseTokenConsent then\s*\n\s*task\.spawn\(function\(\)\s*\n\s*registerFeedbackWithToken\(item\)/);
});
test('Rejoin and Refresh use only token-authorized read-only Feedback',()=>{
 assert.match(source,/loadRememberedToken\(\)/);
 assert.match(source,/while gate.active and serverCasesFrame.Parent do\s*\n\s*pcall\(pollVerifiedServerCases,false\)\s*\n\s*if validUserCaseToken\(userCaseToken\) then\s*\n\s*local ok,err=refreshTokenCases\(\)/);
 assert.match(source,/pcall\(pollVerifiedServerCases,true\)\s*\n\s*if validUserCaseToken\(userCaseToken\) then/);
 assert.match(source,/local function acceptTokenCases\(data\)/);
 assert.match(source,/data\.tokenAccepted~=true/);
 assert.match(source,/data\.identityVerified~=false/);
 assert.match(source,/data\.delivery~="user-case-token"/);
 assert.match(source,/serverLinked=true,tokenLinked=true,verified=true/);
 assert.match(source,/view\.Text = record\.tokenLinked and "Token-linked case \(read-only\)"/);
 assert.match(source,/view\.Interactable = record\.serverLinked ~= true/);
 assert.match(source,/for id,item in pairs\(tokenLinkedCases\) do/);
 assert.match(source,/serverLinkedCases\[id\]==nil/);
 assert.match(source,/type\(own\.receipt\)=="string"/);
 assert.doesNotMatch(source,/SERVER CASE DELIVERY[^\n]*claimedUserId/);
});
