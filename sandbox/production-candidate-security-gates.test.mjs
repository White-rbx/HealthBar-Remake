// ArcScriptCenter review-only security gate regression tests.
// Runs only the GitHub-stored release gate template with synthetic values.
// Does NOT read, publish, or execute a private deployed Worker source.
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('./production-candidate-assembler.mjs', import.meta.url), 'utf8');
const tick = String.fromCharCode(96);
const left = '  const envGate=' + tick;
const right = tick + ';\n  const feedbackStart=';
const start = source.indexOf(left);
const end = source.indexOf(right, start + left.length);
assert.ok(start >= 0 && end > start, 'Release gate template must be present');
const gateText = source.slice(start + left.length, end);

function gateForVersion(version) {
  return runInNewContext(
    'const VERSION=' + JSON.stringify(version) + ';\n' + gateText + '\nascReleaseEnvReady',
    {}, { timeout: 1000 }
  );
}
const ready = gateForVersion('0.5.80.0-production-candidate');

function validSynthetic() {
  return {
    ASC_RELEASE_CHANNEL: 'production',
    ASC_TURNSTILE_MODE: 'real',
    ASC_RELEASE_HOSTNAME: 'arcscriptcenter-api.kogpasan14.workers.dev',
    ASC_TURNSTILE_HOSTNAME: 'arcscriptcenter-api.kogpasan14.workers.dev',
    ASC_TURNSTILE_REAL_SECRET: 'synthetic-only-not-a-secret-123456',
    ASC_FEEDBACK_QUOTA_KEY: 'synthetic-only-quota-not-a-secret-123456',
    ASC_PUSH_ACCESS_AUD: 'a'.repeat(64),
    ASC_PUSH_ADMIN_EMAIL_SHA256: 'b'.repeat(64),
    ASC_PUSH_VAPID_PRIVATE_JWK: '{"kty":"EC","notARealKey":true}',
    ASC_PUSH_VAPID_PUBLIC_KEY: 'not-a-real-key',
    DB: { fakeD1: true }
  };
}
test('all synthetic fields present passes structural gate only', () => {
  assert.equal(ready(validSynthetic()), true);
});
test('missing environment fails closed', () => {
  assert.equal(ready(undefined), false);
  assert.equal(ready(null), false);
});
test('wrong release version fails closed', () => {
  assert.equal(gateForVersion('0.5.79.0-cron-retry-sandbox')(validSynthetic()), false);
});

const denyCases = [
  ['no channel', e => delete e.ASC_RELEASE_CHANNEL],
  ['sandbox channel', e => e.ASC_RELEASE_CHANNEL = 'sandbox'],
  ['dummy Turnstile mode', e => e.ASC_TURNSTILE_MODE = 'sandbox-dummy'],
  ['missing hostname', e => delete e.ASC_RELEASE_HOSTNAME],
  ['mismatched Turnstile host', e => e.ASC_TURNSTILE_HOSTNAME = 'other.example.invalid'],
  ['wrong host even when release and Turnstile host match each other', e => {e.ASC_RELEASE_HOSTNAME = 'unapproved.example.invalid';e.ASC_TURNSTILE_HOSTNAME = 'unapproved.example.invalid'}],
  ['malformed release hostname', e => e.ASC_RELEASE_HOSTNAME = 'bad/host'],
  ['missing real Siteverify secret', e => delete e.ASC_TURNSTILE_REAL_SECRET],
  ['short real Siteverify secret', e => e.ASC_TURNSTILE_REAL_SECRET = 'short'],
  ['missing quota key', e => delete e.ASC_FEEDBACK_QUOTA_KEY],
  ['short quota key', e => e.ASC_FEEDBACK_QUOTA_KEY = 'short'],
  ['missing Access audience', e => delete e.ASC_PUSH_ACCESS_AUD],
  ['bad Access audience', e => e.ASC_PUSH_ACCESS_AUD = '*'.repeat(64)],
  ['missing admin identity hash', e => delete e.ASC_PUSH_ADMIN_EMAIL_SHA256],
  ['invalid admin identity hash', e => e.ASC_PUSH_ADMIN_EMAIL_SHA256 = 'not-a-sha256'],
  ['missing VAPID private credential', e => delete e.ASC_PUSH_VAPID_PRIVATE_JWK],
  ['missing VAPID public key', e => delete e.ASC_PUSH_VAPID_PUBLIC_KEY],
  ['missing D1 binding', e => delete e.DB],
];
for (const [label, mutate] of denyCases) {
  test('fail-closed: ' + label, () => {
    const env = validSynthetic();
    mutate(env);
    assert.equal(ready(env), false);
  });
}
test('admin routing requires configured hostname and Access identity', () => {
  assert.ok(source.includes("env.ASC_RELEASE_HOSTNAME==='arcscriptcenter-api.kogpasan14.workers.dev'"));
  assert.ok(source.includes('if(url.hostname!==env.ASC_RELEASE_HOSTNAME)'));
  assert.ok(source.includes("if(path.startsWith('/api/v1/admin/push')"));
  assert.ok(source.includes('await ascStage1671VerifiedAdmin(request,env,ctx)'));
  assert.ok(source.includes('const human = await ascStage1667SiteVerify(b,env);'));
  assert.ok(source.includes('verdict.hostname!==env.ASC_TURNSTILE_HOSTNAME'));
});
test('assembler prohibits dummy challenge path after merge', () => {
  assert.ok(source.includes('if(candidate.includes("ascVerifyFeedbackChallenge")'));
});


test('production browser sitekey must match provisioned manifest value', () => {
  assert.ok(source.includes("formJs.includes(manifest.productionAccessTurnstileProvisioning.turnstile.publicSitekey)"));
});
