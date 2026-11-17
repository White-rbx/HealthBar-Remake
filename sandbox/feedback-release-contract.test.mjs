import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {FEEDBACK_RELEASE_CONTRACT as contract} from './feedback-release-contract.mjs';

const source = path => readFileSync(new URL('../'+path,import.meta.url),'utf8');
const files = {
  prodHtml:source('sandbox/production-feedback-appeal-form.html'),
  prodJs:source('sandbox/production-feedback-appeal-form.js'),
  sandboxHtml:source('sandbox/stage16-76-arcsen-bridge.html'),
  sandboxJs:source('sandbox/stage16-76-arcsen-bridge.js'),
};

test('Feedback is available without Roblox OAuth or account age gating',()=>{
  assert.equal(contract.feedback.requiresRobloxOidc,false);
  assert.equal(contract.feedback.requiresRobloxAccountAge,false);
  assert.equal(contract.feedback.requiresClaimedUserId,false);
  assert.equal(contract.feedback.acceptsOptionalClaimedUserId,true);
  assert.equal(contract.feedback.claimedUserIdIsNotIdentityProof,true);
  assert.equal(contract.feedback.requiresTurnstile,true);
  for(const js of [files.prodJs,files.sandboxJs]){
    assert.match(js,/claimedUserId:data\.kind==="appeal"\?userId\.value\.trim\(\):undefined/);
    assert.match(js,/turnstileToken:oneTimeToken/);
    assert.match(js,/action:kind\.value==="appeal"\?"appeal_submit":"feedback_submit"/);
    assert.doesNotMatch(js,/age[_-]?gate|account[_-]?age|birthdate|dateOfBirth|minAge|oauth\/callback|authorization_code/i);
  }
});
test('Existing Feedback and Appeal behavior stays receipt-scoped, no identity disclosure',()=>{
  for(const js of [files.prodJs,files.sandboxJs]){
    for(const path of ['/api/v1/feedback/status','/api/v1/feedback/manage']){
      assert.ok(js.includes(path),path);
    }
    assert.match(js,/if\(data\.kind==="appeal"/);
    assert.match(js,/userId\.value=/);
    assert.match(js,/loadedCase\?\.canManage/);
    assert.doesNotMatch(js,/localStorage|console\.(?:log|warn|error)|window\.location|location\.href/);
  }
  assert.equal(contract.appeal.claimedUserIdIsNotIdentityProof,true);
  assert.equal(contract.userInterface.noPrivateHistoryWithoutIdentity,true);
});
test('Browser UI is entirely English and reports are legible on mobile',()=>{
  for(const [key,text] of Object.entries(files)){
    assert.doesNotMatch(text,/\p{Script=Thai}/u,key+' contains unexpected Thai text');
    if(key.endsWith('Html')){
      assert.match(text,/<html lang="en">/);
      assert.match(text,/name="viewport"/);
      assert.match(text,/id="receipt-section"/);
    }
  }
  assert.match(files.prodJs,/Request submitted. Keep your Case ID and Receipt private/);
  assert.match(files.sandboxJs,/Submit a synthetic test request to Sandbox D1/);
});
test('Production and sandbox browser routes cannot be silently swapped',()=>{
  assert.ok(files.prodJs.includes(contract.browserRoutes.production.submit));
  assert.ok(!files.prodJs.includes(contract.browserRoutes.sandbox.submit));
  assert.ok(files.sandboxJs.includes(contract.browserRoutes.sandbox.submit));
  assert.ok(!files.sandboxJs.includes(contract.browserRoutes.production.submit));
  assert.match(files.sandboxHtml,/SANDBOX ONLY — Not Production/);
  assert.match(files.sandboxJs,/credentials:"same-origin"/);
  assert.match(files.prodJs,/credentials:"omit"/);
});
test('Do not expose admin spam mail or private violation through public form',()=>{
  assert.equal(contract.userInterface.spamMailAdminOnly,true);
  assert.equal(contract.userInterface.violationAppealNested,true);
  for(const html of [files.prodHtml,files.sandboxHtml]){
    assert.doesNotMatch(html,/\/api\/v1\/violation\/history|\/admin\/spam|secret[_-]?key/i);
    assert.match(html,/id="challenge"/);
    assert.match(html,/id="receipt-section"/);
  }
});
