/**
 * STAGING-only diagnostic adapter for the reviewed Feedback rate candidate.
 * Produces categorised 503 diagnostics for a synthetic QA User-Agent only.
 * Never includes raw client IP, secret text, UserId, Admin Key or case receipts.
 *
 * REVIEW ONLY. A 201 in a real network smoke plus review of trusted ingress
 * must precede any production consideration.
 */
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {prepareStagingRateCandidate,STAGING_HOST} from './feedback-staging-rate-rollout.mjs';

function swapOnce(source,from,to) {
  if(source.split(from).length!==2)throw Error('Diagnostic source drift: '+from.slice(0,64));
  return source.replace(from,to);
}
export function addStagingQADiagnostics(patched) {
  if(typeof patched!=='string'||patched.includes('stagingQA:'))
    throw Error('Expected an unmodified staging rate candidate');
  let output=patched;
  const oldResponse=[
    '  const limited=await ascStagingFeedbackLimit(request,env);',
    "  if(limited!==null)return json({ok:false,error:limited===429?'Rate limited':'Feedback temporarily unavailable'},limited,origin);"
  ].join('\n');
  const newResponse=[
    '  const limited=await ascStagingFeedbackLimit(request,env);',
    '  if(limited!==null)return json({',
    "    ok:false,error:limited.status===429?'Rate limited':'Feedback temporarily unavailable',",
    "    stagingQA:request.headers.get('User-Agent')==='ASC-Staging-Synthetic-Smoke/1.0' ? limited.reason : undefined",
    '  },limited.status,origin);'
  ].join('\n');
  output=swapOnce(output,oldResponse,newResponse);
  output=swapOnce(output,
    "  if(!env?.DB||typeof env.ASC_FEEDBACK_RATE_SECRET!=='string'||env.ASC_FEEDBACK_RATE_SECRET.length<32)return 503;",
    "  if(!env?.DB||typeof env.ASC_FEEDBACK_RATE_SECRET!=='string'||env.ASC_FEEDBACK_RATE_SECRET.length<32)return {status:503,reason:'dependency'};");
  for(const [source,code] of [
    ["    if(new URL(req.url).hostname!=='"+STAGING_HOST+"')return {verified:false};",'host'],
    ["    if(req.method!=='POST'||req.headers.has('CF-Worker')||req.headers.has('X-Real-IP'))return {verified:false};",'worker-or-method'],
    ["    if(!req.cf||typeof req.cf.tlsVersion!=='string')return {verified:false};",'tls-metadata'],
    ["    if(!ip||ip.length>64||!/^[0-9a-f:.]+$/i.test(ip))return {verified:false};",'ip-metadata']
  ]) {
    output=swapOnce(output,source,source.replace('{verified:false}','{verified:false,reason:"'+code+'"}'));
  }
  output=swapOnce(output,
    '  const result=await ascStagingRateFactory({db:env.DB,secret:env.ASC_FEEDBACK_RATE_SECRET,verifyEdge}).take(request);',
    [
      '  const edge=await verifyEdge(request);',
      "  if(edge.verified!==true)return {status:503,reason:'edge-'+edge.reason};",
      '  const result=await ascStagingRateFactory({db:env.DB,secret:env.ASC_FEEDBACK_RATE_SECRET,verifyEdge:async()=>edge}).take(request);'
    ].join('\n'));
  output=swapOnce(output,
    '  return result.allowed?null:result.status;',
    '  return result.allowed?null:{status:result.status,reason:result.reason};');
  if(!output.includes('stagingQA:')||!output.includes("edge-ip-metadata")||
     !output.includes("reason:'dependency'")||!output.includes("reason:result.reason"))
    throw Error('Diagnostic output missing one of the required fail-closed branches');
  return output;
}
export function prepareStagingDiagnostic({staging,rateModule}) {
  const prepared=prepareStagingRateCandidate({staging,rateModule});
  const source=addStagingQADiagnostics(prepared.source);
  const sha=createHash('sha256').update(source,'utf8').digest('hex');
  return {source,sha256:sha,sourceSha256:prepared.sourceSha256,
    status:'REVIEW_ONLY_DIAGNOSTIC_DO_NOT_DEPLOY',productionPermitted:false,
    realExternalSmokePassed:false,secretValuesLogged:false};
}
const me=import.meta.url.startsWith('file:')?fileURLToPath(import.meta.url):null;
if(process.argv[1]===me){
  const a=process.argv.slice(2);
  if(a.length!==4||a[0]!=='--staging'||a[2]!=='--output')
    throw Error('Usage: node sandbox/feedback-staging-qa-diagnostic.mjs --staging PRIVATE_STAGING.js --output PRIVATE_DIAGNOSTIC.mjs');
  const result=prepareStagingDiagnostic({
    staging:readFileSync(a[1],'utf8'),
    rateModule:readFileSync(new URL('./feedback-release-rate-guard.mjs',import.meta.url),'utf8')
  });
  writeFileSync(a[3],result.source,{flag:'wx',mode:0o600});
  console.log(JSON.stringify({status:result.status,sha256:result.sha256,productionPermitted:false}));
}
