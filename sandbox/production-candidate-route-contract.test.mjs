// Static route and Service Worker scope contracts for the review-only assembler.
// Does not contain Cloudflare source, secrets, tokens, Push endpoints or D1 records.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { runInNewContext } from 'node:vm';
import test from 'node:test';

const src = readFileSync(new URL('./production-candidate-assembler.mjs', import.meta.url), 'utf8');
const match = src.match(/  const routeMap=\{\n([\s\S]*?)\n  \};/);
assert.ok(match, 'One source-controlled routeMap is required');
const map = runInNewContext('({' + match[1] + '})');
const page = map['/__stage1671/android-push'];
const sw = map['/__stage1671/sw.js'];
const scope = map['/__stage1671/'];

test('Android Push page is inside Service Worker registration scope', () => {
  assert.equal(page, '/api/v1/admin/push/');
  assert.equal(scope, '/api/v1/admin/push/');
  assert.ok(page.startsWith(scope), 'The setup page must be controlled by the registered Service Worker');
  assert.notEqual(page, '/api/v1/admin/push', 'The bare path is OUTSIDE /push/ scope');
});

test('Service Worker script and scope share one same-origin path prefix', () => {
  assert.equal(sw, '/api/v1/admin/push/sw.js');
  assert.ok(sw.startsWith(scope));
  assert.ok(page.startsWith(scope));
});

test('Candidate registers the new page path in the GET router', () => {
  assert.ok(src.includes("if(path==='/api/v1/admin/push/'&&request.method==='GET')return await ascStage1671Document(request,env,ctx);"));
  assert.ok(!src.includes("if(path==='/api/v1/admin/push'&&request.method==='GET')"));
});

test('Candidate allowlist does not silently exclude the slash-terminated page', () => {
  assert.ok(src.includes('x==="/api/v1/admin/push/"||!x.endsWith("/")'));
  assert.ok(src.includes('if(ASC_RELEASE_NEW_PATHS.has(path))'));
  assert.ok(src.includes("if(path.startsWith('/api/v1/admin/push')"));
});

test('Sandbox registration URLs all rewrite into the same Service Worker scope', () => {
  const template = "const page='/__stage1671/android-push';navigator.serviceWorker.register('/__stage1671/sw.js',{scope:'/__stage1671/'})";
  const mapped = Object.entries(map)
    .sort(([a], [b]) => b.length - a.length)
    .reduce((s, [a, b]) => s.replaceAll(a, b), template);
  assert.ok(mapped.includes("page='/api/v1/admin/push/'"));
  assert.ok(mapped.includes("register('/api/v1/admin/push/sw.js',{scope:'/api/v1/admin/push/'})"));
  assert.ok(!mapped.includes('/__stage1671/'));
});

test('Review-only builder retains fail-closed production host and Access checks', () => {
  assert.ok(src.includes('if(url.hostname!==env.ASC_RELEASE_HOSTNAME)'));
  assert.ok(src.includes("await ascStage1671VerifiedAdmin(request,env,ctx)"));
  assert.ok(src.includes("const human = await ascStage1667SiteVerify(b,env);"));
});
