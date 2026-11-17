import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {Script} from 'node:vm';
import {prepareFeedbackCandidate,PIN} from './feedback-release-candidate-builder.mjs';
const builder=readFileSync(new URL('./feedback-release-candidate-builder.mjs',import.meta.url),'utf8');
const guard=readFileSync(new URL('./feedback-release-rate-guard.mjs',import.meta.url),'utf8');
const sha=s=>createHash('sha256').update(s).digest('hex');
function fixture(){
  const production=[
    "const ALLOWED_ORIGIN='https://arcscriptcenter-dashboard.pages.dev';",
    "const VERSION = '0.5.41.5-phase1';",
    "function json(data){return data}",
    "function adminAuthenticated(request,env){return true}",
    "function options(origin){return null}",
    "async function userBanCheck(){return {ok:true}}",
    "export default {",
    "  async fetch(request,env){",
    "    const url=new URL(request.url);",
    "    const path=url.pathname;",
    "    const origin=request.headers.get('Origin')||'';",
    "    if(request.method==='OPTIONS')return options(origin);",
    "    if(!env.DB)return json({ok:false});",
    "    try {",
    "      if (path === '/api/v1/client/ban-check' && request.method === 'POST')",
    "        return await userBanCheck(request,env,origin);",
    "      return json({ok:false});",
    "    }catch{return json({ok:false});}",
    "  }",
    "};"
  ].join('\n');
  const staging=[
    "const FC_STATUSES=['reviewing'];",
    "async function fcPayload(request){}",
    "async function fcDigest(){}",
    "async function fcCheckReceipt(){const q='receipt_hash=?';}",
    "async function fcSubmit(request,env,origin){",
    "  // Global staging quotas, independent of personally identifying data.",
    "  const now=Math.floor(Date.now()/1000);",
    "  for (const [key,limit] of [['m'+Math.floor(now/60),12],['d'+Math.floor(now/86400),200]]) {}",
    "  const id=crypto.randomUUID();",
    "  const receipt=crypto.getRandomValues(new Uint8Array(32));",
    "  return json({ok:true,id,receipt});",
    "}",
    "async function fcStatus(){}",
    "async function fcManage(){}",
    "async function fcAdmin(request,env,origin,url){",
    "  if (origin && origin !== ALLOWED_ORIGIN && origin !== ALLOWED_PREVIEW_ORIGIN && origin !== ALLOWED_SECURITY_PREVIEW_ORIGIN && origin !== ALLOWED_STAGE1654_PREVIEW_ORIGIN && origin !== ALLOWED_STAGE1654_ALIAS_ORIGIN && origin !== new URL(request.url).origin) return json({ok:false});",
    "  return await adminAuthenticated(request,env);",
    "}",
    "async function fcAdminHistory(){}",
    "const ASC_MODERATION_HTML='existing original moderation not imported';",
    "async function fcAdminFeedbackSummary(){}",
    "async function fcAdminFeedbackList(){}",
    "async function fcAdminFeedbackCase(){}",
    "async function fcAdminFeedbackActivity(){}",
    "async function fcAdminFeedbackFollowup(){}",
    "async function fcAdminFeedbackFollowupDetails(){}",
    "async function vnLookup(){}",
    "async function vnAdmin(){}",
    "export default { async fetch(){} };"
  ].join('\n');
  return {production,staging};
}
test('strict original source pins are 64-bit hex digests and real source cannot be bypassed',()=>{
  assert.match(PIN.production,/^[a-f0-9]{64}$/);
  assert.match(PIN.staging,/^[a-f0-9]{64}$/);
  const f=fixture();
  assert.throws(()=>prepareFeedbackCandidate({...f,rateModule:guard}),/Strict Worker SHA pin mismatch/);
});
test('synthetic substitution of pins verifies additive output while shipped builder pins stay unchanged',async()=>{
  const f=fixture();
  const experimental=builder.replace(PIN.production,sha(f.production)).replace(PIN.staging,sha(f.staging));
  const module=await import('data:text/javascript;base64,'+Buffer.from(experimental).toString('base64'));
  const out=module.prepareFeedbackCandidate({...f,rateModule:guard});
  assert.equal(out.status,'REVIEW_ONLY_DO_NOT_DEPLOY');
  assert.equal(out.ownerReleaseApproval,false);
  assert.equal(out.newRoutes,15);
  assert.ok(out.source.includes('/api/v1/client/ban-check'));
  assert.ok(out.source.includes('/api/v1/admin/feedback/list'));
  assert.ok(out.source.includes('ASC_FEEDBACK_RATE_SECRET'));
  assert.ok(out.source.includes('CF-Connecting-IP'));
  assert.ok(!out.source.includes('Global staging quotas'));
  assert.ok(!out.source.includes('ALLOWED_STAGE1654_'));
  assert.ok(!out.source.includes('const ASC_MODERATION_HTML'));
  assert.equal(out.source.split('export default {').length-1,1);
  assert.doesNotThrow(()=>new Script(out.source.replace('export default {','const __worker = {')));
});
test('migrated route prefixes have no production deployment automation',()=>{
  assert.match(builder,/Source drift|Strict Worker SHA pin mismatch/);
  assert.match(builder,/status:'REVIEW_ONLY_DO_NOT_DEPLOY'/);
  assert.doesNotMatch(builder,/wrangler deploy|pages deploy|productionDeploymentPermitted:true/);
});
