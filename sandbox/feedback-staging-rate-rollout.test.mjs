import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {
  OLD_STAGING_QUOTA,STAGING_SOURCE_SHA256,STAGING_HOST,
  patchStagingRateSource,prepareStagingRateCandidate
} from './feedback-staging-rate-rollout.mjs';

const limiter=readFileSync(new URL('./feedback-release-rate-guard.mjs',import.meta.url),'utf8');
const fixture=[
  "const KEEP_LEGACY='keep-current-staging-services';",
  'async function fcSubmit(request,env,origin) {',
  "  const parsed='validated-input';",
  OLD_STAGING_QUOTA.slice(0,-1),
  '  const id=crypto.randomUUID();',
  '  return json({ok:true,id},201,origin);',
  '}',
  'async function fcStatus(request,env,origin) {return json({ok:true},200,origin);}',
  'export default {async fetch(request,env) {return fcStatus(request,env,null);}};',
  ''
].join('\n');

test('retains STAGING endpoints and unrelated legacy implementation',()=>{
  const updated=patchStagingRateSource(fixture,limiter);
  assert.match(updated,/KEEP_LEGACY='keep-current-staging-services'/);
  assert.match(updated,/const id=crypto.randomUUID/);
  assert.match(updated,/async function fcStatus\(request,env,origin\)/);
  assert.match(updated,/export default \{/);
  assert.doesNotMatch(updated,/Global staging quotas|count=count\+1 WHERE count/);
  assert.match(updated,/ascStagingFeedbackLimit\(request,env\)/);
  assert.match(updated,/asc_feedback_rate_windows/);
});
test('fail-closed guard targets only the reviewed STAGING hostname',()=>{
  const updated=patchStagingRateSource(fixture,limiter);
  assert.match(updated,new RegExp(STAGING_HOST.replace(/\./g,'\\.')));
  assert.match(updated,/ASC_FEEDBACK_RATE_SECRET/);
  assert.match(updated,/CF-Worker/);
  assert.doesNotMatch(updated,/req\.headers\.has\('X-Real-IP'\)/);
  assert.match(updated,/request\.cf|req\.cf/);
  assert.match(updated,/CF-Connecting-IP/);
  assert.match(updated,/return 503/);
  assert.match(updated,/Rate limited/);
  assert.doesNotMatch(updated,/hostname!=='arcscriptcenter-api\.kogpasan14\.workers\.dev'/);
});
test('rejects source drift, missing anchors and duplicate installation',()=>{
  assert.equal(STAGING_SOURCE_SHA256,'cbfad72cedb65247d49bc20e203e2f19769372f6ebc39474e86239102e4cdd62');
  assert.throws(()=>prepareStagingRateCandidate({staging:fixture,rateModule:limiter}),/source drift/);
  assert.throws(()=>patchStagingRateSource(fixture.replace(OLD_STAGING_QUOTA,''),limiter),/anchor/);
  const installed=patchStagingRateSource(fixture,limiter);
  assert.throws(()=>patchStagingRateSource(installed,limiter),/anchor|already installed/);
  assert.throws(()=>patchStagingRateSource(fixture,limiter+'\nimport x from \"bad\";'),/unsupported imports/);
});
test('this source contains no automatic Cloudflare deployment or D1 migration',()=>{
  const code=readFileSync(new URL('./feedback-staging-rate-rollout.mjs',import.meta.url),'utf8');
  assert.match(code,/REVIEW_ONLY_DO_NOT_DEPLOY/);
  assert.match(code,/realIngressValidated:false/);
  assert.doesNotMatch(code,/cloudflare\.request\(|wrangler deploy|d1 migrations apply|DROP TABLE/);
});
