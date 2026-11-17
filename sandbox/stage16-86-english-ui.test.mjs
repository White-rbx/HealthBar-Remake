import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const files = [
  'sandbox/production-feedback-appeal-form.html',
  'sandbox/stage16-76-arcsen-bridge.html',
  'sandbox/stage16-86-browser-demo/index.html',
  'sandbox/stage16-86-browser-demo/app.js',
];
const sources = files.map(path => ({
  path, content: readFileSync(new URL('../'+path, import.meta.url), 'utf8'),
}));

test('all included ArcScriptCenter reference UIs use English-only copy',()=>{
  for(const {path,content} of sources){
    assert.doesNotMatch(content,/\p{Script=Thai}/u,path+' contains Thai text');
    if(path.endsWith('.html')) assert.match(content,/<html lang="en">/,path+' must declare English');
  }
});
test('English UI copy preserves IDs, form endpoints and script integration',()=>{
  const form=sources[0].content;
  const bridge=sources[1].content;
  assert.match(form,/id="request-form"/);
  assert.match(form,/id="receipt-section"/);
  assert.match(form,/id="case-section"/);
  assert.match(form,/api\/v1\/feedback\/form\.js/);
  assert.match(bridge,/id="request-form"/);
  assert.match(bridge,/__stage1676\/bridge\.js/);
  assert.match(form+bridge,/challenges\.cloudflare\.com\/turnstile/);
});
test('no personal data requested in copy, and the sandbox is clearly labeled',()=>{
  const form=sources[0].content,bridge=sources[1].content;
  assert.match(form,/Never enter passwords, OTPs/);
  assert.match(bridge,/SANDBOX ONLY — Not Production/);
  assert.match(bridge,/Never enter passwords, OTPs/);
  assert.match(form+bridge,/claimed Roblox UserId.*does not prove account ownership/);
});
test('pairing browser keeps English-only consent labels and errors',()=>{
  const html=sources[2].content, js=sources[3].content;
  assert.match(html,/Confirm Arcsen Pairing/);
  assert.match(html,/Approve Pairing/);
  assert.match(js,/Pairing approved/);
});
