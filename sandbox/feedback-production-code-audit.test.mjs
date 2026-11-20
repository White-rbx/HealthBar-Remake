import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const read=path=>readFileSync(new URL('../'+path,import.meta.url),'utf8');
const manifest=JSON.parse(read('sandbox/production-candidate-merge-manifest.json'));
const migration=read('migrations/2026-11-15_stage1669_feedback_appeal_additive.sql');
const contract=read('sandbox/feedback-release-contract.mjs');

test('Production deployment remains deliberately disabled in source-reviewed manifest',()=>{
  assert.equal(manifest.status,'REVIEW_ONLY_NOT_DEPLOYABLE');
  assert.equal(manifest.base.worker,'arcscriptcenter-api');
  assert.equal(manifest.base.sha256,'036a9f2410e877b51f5293315103e8a8f62ad940fb3f9e8d4efd0bd7e13e0a48');
  assert.equal(manifest.base.preserveAllLegacyRoutes,true);
  assert.equal(manifest.featureSource.doNotCopyWholeWorker,true);
  assert.equal(manifest.releaseGates.productionDeploymentPermitted,false);
  assert.equal(manifest.releaseGates.ownerProductionApproval,false);
  assert.equal(manifest.releaseGates.candidateSourceCodeBuiltAndReviewed,false);
});
test('Existing migration must be explicitly reviewed before release',()=>{
  assert.equal((migration.match(/^CREATE TABLE\b/gm)||[]).length,6,'Expected six draft tables');
  assert.equal((migration.match(/^CREATE INDEX\b/gm)||[]).length,8,'Expected eight draft indexes');
  assert.equal((migration.match(/^CREATE TRIGGER\b/gm)||[]).length,4,'Expected four draft triggers');
  assert.match(migration,/CREATE TABLE ["\x27]?asc_feedback_cases/);
  assert.match(migration,/CREATE TABLE asc_feedback_quota_v2/);
  assert.doesNotMatch(migration,/CREATE TABLE ["\x27]?asc_violation_notices/);
  assert.match(migration,/DO NOT RUN AGAINST PRODUCTION/);
  assert.doesNotMatch(migration,/^DROP TABLE\b|^DELETE FROM\b|^UPDATE\b/mi);
});
test('Frontend contract never permits claimed UserId as authorization',()=>{
  assert.match(contract,/requiresRobloxOidc:\s*false/);
  assert.match(contract,/requiresRobloxAccountAge:\s*false/);
  assert.match(contract,/acceptsOptionalClaimedUserId:\s*true/);
  assert.match(contract,/claimedUserIdIsNotIdentityProof:\s*true/);
  assert.match(contract,/noPrivateHistoryWithoutIdentity:\s*true/);
  assert.match(contract,/spamMailAdminOnly:\s*true/);
  assert.match(contract,/violationAppealNested:\s*true/);
});
test('No automatic production promotion is installed in the Feedback workflow',()=>{
  const workflow=read('.github/workflows/feedback-appeal-release-track.yml');
  assert.match(workflow,/pull_request:/);
  assert.doesNotMatch(workflow,/wrangler deploy|pages deploy|cloudflare\/wrangler-action/);
});
