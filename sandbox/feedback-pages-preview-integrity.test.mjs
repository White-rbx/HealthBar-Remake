/**
 * Immutable Cloudflare Pages STAGING Preview asset attestation.
 * Only PUBLIC static assets are downloaded. No Admin Key, private data,
 * account identity, case records, receipts, or Production endpoints.
 *
 * These hashes were compared against the owner's archived Stage16.54 source.
 * A hosted Pages deploy needs separate Pages Write authorization.
 */
import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

const ORIGIN='https://416b162f.arcscriptcenter-dashboard-staging.pages.dev';
const EXPECTED=[
  {path:'/',sha256:'13d370b533b052f218883954e8a6115abc7f2230676a3fed16ca3f1be2f82bce',bytes:163763,mime:'text/html'},
  {path:'/__asc1649/feedback-appeal.js',sha256:'28853de16436acb3145259e2deba9a9cf5a24d4164659d6d8fa790df48736f24',bytes:35666,mime:'text/javascript'},
  {path:'/__asc1649/feedback-appeal.css',sha256:'4e429fc23a981bfa1667ec1d89cfcaad8297cdcce0d00353d1e59b6da1f4f219',bytes:8851,mime:'text/css'},
];

test('PINNED STAGING Preview has the authentic Stage16.54 Dashboard assets', {timeout:65000},async()=>{
  const texts=new Map();
  for(const entry of EXPECTED){
    const res=await fetch(new URL(entry.path,ORIGIN),{
      headers:{Accept:'*/*'},
      cache:'no-store',
      redirect:'error',
      signal:AbortSignal.timeout(15000)
    });
    assert.equal(res.status,200,entry.path+' HTTP status');
    assert.ok(res.headers.get('content-type')?.startsWith(entry.mime),
      entry.path+' MIME: '+res.headers.get('content-type'));
    const b=Buffer.from(await res.arrayBuffer());
    assert.equal(b.length,entry.bytes,entry.path+' byte length');
    assert.equal(createHash('sha256').update(b).digest('hex'),entry.sha256,
      entry.path+' SHA-256 drift; STOP and review');
    texts.set(entry.path,b.toString('utf8'));
  }
  const html=texts.get('/');
  const js=texts.get('/__asc1649/feedback-appeal.js');
  assert.equal(html.split('id="page-feedback-appeal"').length-1,1,
    'Native Feedback page must exist exactly once');
  assert.equal(html.split('data-page="feedback-appeal"').length-1,1,
    'Native Feedback navigation must exist exactly once');
  assert.doesNotMatch(html,/id="page-feedback"|data-page="feedback"/,
    'No duplicate Feedback page');
  assert.match(html,/\/__asc1649\/feedback-appeal\.js/,
    'Native client JS must load from Pages Functions');
  assert.match(js,/function faRenderDetail\(c\)/);
  assert.match(js,/if\(c\.kind==='appeal'\)dl\.append/,
    'Historical Preview renders sender ID only for Appeal; patched candidate is NOT yet deployed');
});

test('the archive and actual preview are independently pinned; Production is out of scope',()=>{
  assert.equal(new URL(ORIGIN).hostname,'416b162f.arcscriptcenter-dashboard-staging.pages.dev');
  assert.equal(EXPECTED.length,3);
  assert.ok(EXPECTED.every(x=>/^[0-9a-f]{64}$/.test(x.sha256)));
});
