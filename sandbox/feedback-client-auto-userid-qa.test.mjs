import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const patch=readFileSync(new URL('./arcsen-v7.3.51-auto-userid-admin.patch',import.meta.url),'utf8');
const lines=patch.split('\n');
const inserted=lines.filter(l=>l.startsWith('+')&&!l.startsWith('+++')).map(l=>l.slice(1)).join('\n');
const removed=lines.filter(l=>l.startsWith('-')&&!l.startsWith('---')).map(l=>l.slice(1)).join('\n');

test('client visibly discloses new Feedback UserId inclusion and removes opt-in toggle',()=>{
 assert.match(inserted,/UIs 7\.3\.51/);
 assert.match(inserted,/RobloxUserIdSubmissionNotice/);
 assert.match(inserted,/Your Roblox UserId is included for Admin review \(unverified\)/);
 assert.match(removed,/shareClaim=false/);
 assert.match(removed,/ShareOptionalRobloxUserId/);
 assert.doesNotMatch(inserted,/shareClaim|ShareOptionalRobloxUserId|Include Roblox UserId: OFF/);
});
test('client requires LocalPlayer UserId and includes it in Feedback payload',()=>{
 assert.match(inserted,/if kind == "feedback" then/);
 assert.match(inserted,/localPlayer\.UserId <= 0/);
 assert.match(patch,/payload\.claimedUserId=tostring\(localPlayer\.UserId\)/);
 assert.match(inserted,/if not idClaim then/);
 assert.match(inserted,/Roblox UserId unavailable. Rejoin and retry/);
});
test('new UserId claim stays unverified and cannot authorize account control',()=>{
 assert.match(inserted,/UNVERIFIED \/ claimed/);
 assert.match(inserted,/never authorize/);
 assert.match(inserted,/ban/);
 assert.doesNotMatch(inserted,/identityVerified=true|verifiedByServer=true/);
});
test('no Cloudflare deployment, D1 schema edit or new public endpoint',()=>{
 assert.doesNotMatch(inserted,/wrangler deploy|cloudflare\.request\(|CREATE TABLE|DROP TABLE|\/api\/v1\/admin\/feedback\/users/);
});
