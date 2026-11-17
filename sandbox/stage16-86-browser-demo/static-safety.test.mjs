import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const html=readFileSync(new URL('./index.html',import.meta.url),'utf8');
const js=readFileSync(new URL('./app.js',import.meta.url),'utf8');

test('demo never embeds OAuth credentials or user identity in Luau or links',()=>{
  // Ignore the explanatory safety comment, but inspect all executable JS.
  const executableJs=js.replace(/\/\*[\s\S]*?\*\//g,'').replace(/^\s*\/\/.*$/gm,'');
  assert.doesNotMatch(html+executableJs,/localStorage|sessionStorage|document\.cookie|innerHTML|oauth\/v1\/token|refresh_token|access_token|id_token|claimedUserId|window\.location\s*=/i);
  assert.doesNotMatch(html,/<script[^>]+src=["']https?:/i);
  assert.match(js,/credentials:'same-origin'/);
  assert.match(js,/redirect:'error'/);
});
test('mandatory second code field and unchecked consent control exist',()=>{
  assert.match(html,/<input id="confirmed-code"/);
  assert.match(html,/<input type="checkbox" id="own-device"/);
  assert.doesNotMatch(html,/<input type="checkbox" id="own-device"[^>]*\schecked(?:\s|=|>)/);
  assert.match(js,/el\('confirmed-code'\)\.value=''/);
  assert.match(js,/el\('own-device'\)\.checked=false/);
  assert.match(js,/acknowledgeOwnDevice:true/);
  assert.match(js,/Date\.now\(\) < expiresAt/);
  assert.match(js,/code\(el\('confirmed-code'\)\.value\) === preview\.code/);
});
test('demo only contacts documented same-origin pairing endpoints',()=>{
  assert.match(js,/post\('\/pair\/browser\/preview'/);
  assert.match(js,/post\('\/pair\/browser\/approve'/);
  assert.doesNotMatch(js,/fetch\(['"]https?:\/\//);
  assert.match(html,/Pairing code from your Arcsen/);
});
test('demo uses textContent instead of HTML insertion of server fields',()=>{
  assert.match(js,/el\('preview-code'\)\.textContent=r\.pairingCode/);
  assert.doesNotMatch(js,/(?:outer|inner)HTML|insertAdjacentHTML/);
  assert.match(html,/role="status" aria-live="polite"/);
});
test('reference page is explicitly non-live and does not replace designer UI',()=>{
  assert.match(html,/not available for live use/);
  assert.match(html,/does not verify the Roblox client's identity/);
  assert.match(js,/UX reference/);
});

test('all visible HTML and JavaScript messages are in English',()=>{
  assert.match(html,/<html lang="en">/);
  assert.doesNotMatch(html+js,/\p{Script=Thai}/u);
  assert.match(html,/Confirm Arcsen Pairing/);
  assert.match(html,/Approve Pairing/);
  assert.match(html,/do not approve it/i);
  assert.match(js,/Confirmation expired/);
  assert.match(js,/Pairing approved/);
});
