import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {patchStagingRateSource,OLD_STAGING_QUOTA,STAGING_HOST} from './feedback-staging-rate-rollout.mjs';
import {addStagingQADiagnostics,prepareStagingDiagnostic} from './feedback-staging-qa-diagnostic.mjs';

const rateModule=readFileSync(new URL('./feedback-release-rate-guard.mjs',import.meta.url),'utf8');
const fixture=[
  "const LEGACY='preserve';",
  'async function fcSubmit(request,env,origin) {',
  "  const validated='already checked';",
  OLD_STAGING_QUOTA.slice(0,-1),
  '  const id=crypto.randomUUID();',
  '  return json({ok:true,id},201,origin);',
  '}',
  'async function fcStatus(request,env,origin) {return json({ok:true},200,origin);}',
  'export default {async fetch(){return new Response("ok");}};',
  ''
].join('\n');

test('diagnostic only adds categorised 503 results in the STAGING candidate',()=>{
  const patched=patchStagingRateSource(fixture,rateModule);
  const diagnosed=addStagingQADiagnostics(patched);
  assert.match(diagnosed,/const LEGACY='preserve'/);
  assert.match(diagnosed,/const id=crypto.randomUUID/);
  assert.match(diagnosed,/stagingQA:request\.headers\.get\('User-Agent'\)==='ASC-Staging-Synthetic-Smoke\/1\.0'/);
  assert.match(diagnosed,/reason:'dependency'/);
  for(const code of ['host','worker-or-method','tls-metadata','ip-metadata'])
    assert.ok(diagnosed.includes('reason:"'+code+'"'),code);
  assert.match(diagnosed,/reason:'edge-'\+edge\.reason/);
  assert.match(diagnosed,/reason:result\.reason/);
  assert.match(diagnosed,/return result\.allowed\?null:/);
  assert.ok(diagnosed.includes(STAGING_HOST));
  assert.doesNotMatch(diagnosed,/console\.log\(|console\.warn\(|JSON\.stringify\(\s*edge\s*\)/);
  assert.doesNotMatch(diagnosed,/API_KEY|ADMIN_KEY|SECRET_VALUE/);
});
test('diagnostics do not alter the existing rate limits or introduce new routes',()=>{
  const patched=patchStagingRateSource(fixture,rateModule);
  const diagnosed=addStagingQADiagnostics(patched);
  assert.match(diagnosed,/network15m:6,networkDay:24,global15m:240,globalDay:4000/);
  assert.equal((diagnosed.match(/export default \{/g)||[]).length,1);
  assert.doesNotMatch(diagnosed,/Global staging quotas/);
  assert.doesNotMatch(diagnosed,/X-Forwarded-For/);
});
test('fails on duplicated diagnostics and unreviewed private source drift',()=>{
  const patched=patchStagingRateSource(fixture,rateModule);
  assert.throws(()=>addStagingQADiagnostics('broken'),/source drift/);
  const checked=addStagingQADiagnostics(patched);
  assert.throws(()=>addStagingQADiagnostics(checked),/unmodified/);
  assert.throws(()=>prepareStagingDiagnostic({staging:fixture,rateModule}),/source drift/);
});
test('no automatic Cloudflare deployment, private data logging or D1 migration',()=>{
  const code=readFileSync(new URL('./feedback-staging-qa-diagnostic.mjs',import.meta.url),'utf8');
  assert.match(code,/REVIEW_ONLY_DIAGNOSTIC_DO_NOT_DEPLOY/);
  assert.match(code,/realExternalSmokePassed:false/);
  assert.doesNotMatch(code,/cloudflare\.request\(|wrangler deploy|DROP TABLE|console\.log\(.*receipt/);
});
