/**
 * ArcScriptCenter: narrow STAGING rate-guard candidate, REVIEW ONLY.
 * Never deploys or applies D1 changes. Source pin refers to extracted Worker JS,
 * not the multipart content/v2 response.
 */
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';

const hash=s=>createHash('sha256').update(s,'utf8').digest('hex');
export const STAGING_SOURCE_SHA256='cbfad72cedb65247d49bc20e203e2f19769372f6ebc39474e86239102e4cdd62';
export const STAGING_HOST='arcscriptcenter-api-staging.kogpasan14.workers.dev';
export const OLD_STAGING_QUOTA=[
  '  // Global staging quotas, independent of personally identifying data.',
  '  const now=Math.floor(Date.now()/1000);',
  "  for (const [key,limit] of [['m'+Math.floor(now/60),12],['d'+Math.floor(now/86400),200]]) {",
  '    const ok=await env.DB.prepare(',
  "      'INSERT INTO asc_feedback_quota(window_key,count) VALUES(?,1) '+",
  "      'ON CONFLICT(window_key) DO UPDATE SET count=count+1 WHERE count < ? RETURNING count'",
  '    ).bind(key,limit).first();',
  "    if (!ok) return json({ok:false,error:'Too many submissions. Try later.'},429,origin);",
  '  }',
  ''
].join('\n');

function once(haystack,needle) {
  if(haystack.split(needle).length!==2)throw Error('STAGING source anchor missing or duplicated');
}
export function patchStagingRateSource(staging,rateModule) {
  if(typeof staging!=='string'||typeof rateModule!=='string')throw TypeError('Exact Worker and limiter source required');
  once(staging,OLD_STAGING_QUOTA);
  once(staging,'async function fcSubmit(request,env,origin) {');
  once(staging,'async function fcStatus(request,env,origin) {');
  once(staging,'export default {');
  if(staging.includes('ASC_FEEDBACK_RATE_SECRET')||staging.includes('asc_feedback_rate_windows'))
    throw Error('Rate guard already installed; refusing duplicate');
  const start=staging.indexOf('async function fcSubmit(request,env,origin) {');
  const end=staging.indexOf('async function fcStatus(request,env,origin) {');
  const at=staging.indexOf(OLD_STAGING_QUOTA);
  if(at<=start||at>=end)throw Error('Old quota not inside fcSubmit');
  if(!rateModule.includes('export function createReleaseFeedbackRateGuard(') ||
     !rateModule.includes('asc_feedback_rate_windows'))throw Error('Reviewed D1 limiter missing');
  const inner=rateModule.replace(/^export /gm,'');
  if(/^\s*(?:import|export)\s/m.test(inner))throw Error('Rate module has unsupported imports or exports');
  const replacement=[
    '  // STAGING review guard: no client UserId/header is authentication.',
    '  const limited=await ascStagingFeedbackLimit(request,env);',
    "  if(limited!==null)return json({ok:false,error:limited===429?'Rate limited':'Feedback temporarily unavailable'},limited,origin);",
    '  const now=Math.floor(Date.now()/1000);',
    ''
  ].join('\n');
  const wrapper=[
    '// STAGING ONLY — REVIEW_ONLY_DO_NOT_DEPLOY; requires real ingress verification.',
    'const ascStagingRateFactory=(()=>{',
    inner,
    'return createReleaseFeedbackRateGuard;})();',
    'async function ascStagingFeedbackLimit(request,env){',
    "  if(!env?.DB||typeof env.ASC_FEEDBACK_RATE_SECRET!=='string'||env.ASC_FEEDBACK_RATE_SECRET.length<32)return 503;",
    '  const verifyEdge=async req=>{',
    "    if(new URL(req.url).hostname!=='"+STAGING_HOST+"')return {verified:false};",
    '    // X-Real-IP may be present on valid workers.dev requests; CF-Worker is the subrequest signal.',
    "    if(req.method!=='POST'||req.headers.has('CF-Worker'))return {verified:false};",
    "    if(!req.cf||typeof req.cf.tlsVersion!=='string')return {verified:false};",
    "    const ip=req.headers.get('CF-Connecting-IP');",
    "    if(!ip||ip.length>64||!/^[0-9a-f:.]+$/i.test(ip))return {verified:false};",
    "    return {verified:true,networkId:ip};",
    '  };',
    '  const result=await ascStagingRateFactory({db:env.DB,secret:env.ASC_FEEDBACK_RATE_SECRET,verifyEdge}).take(request);',
    '  return result.allowed?null:result.status;',
    '}',
    ''
  ].join('\n');
  const updated=staging.replace(OLD_STAGING_QUOTA,replacement)
    .replace('export default {',wrapper+'export default {');
  if(updated.includes('Global staging quotas')||!updated.includes('ascStagingFeedbackLimit(request,env)') ||
     !updated.includes('CF-Connecting-IP')||!updated.includes('asc_feedback_rate_windows') ||
     updated.includes("hostname!=='arcscriptcenter-api.kogpasan14.workers.dev'"))
    throw Error('STAGING rate guard patch failed');
  return updated;
}
export function prepareStagingRateCandidate({staging,rateModule}) {
  if(hash(staging)!==STAGING_SOURCE_SHA256)
    throw Error('STAGING source drift: stop and re-review');
  const source=patchStagingRateSource(staging,rateModule);
  return {source,sha256:hash(source),sourceSha256:hash(staging),
    status:'REVIEW_ONLY_DO_NOT_DEPLOY',authorizedForProduction:false,
    realIngressValidated:false};
}
const me=import.meta.url.startsWith('file:')?fileURLToPath(import.meta.url):null;
if(process.argv[1]===me){
  const a=process.argv.slice(2);
  if(a.length!==4||a[0]!=='--staging'||a[2]!=='--output')
    throw Error('Usage: node sandbox/feedback-staging-rate-rollout.mjs --staging PRIVATE_STAGING.js --output PRIVATE_STAGING_CANDIDATE.mjs');
  const staging=readFileSync(a[1],'utf8');
  const rateModule=readFileSync(new URL('./feedback-release-rate-guard.mjs',import.meta.url),'utf8');
  const candidate=prepareStagingRateCandidate({staging,rateModule});
  writeFileSync(a[3],candidate.source,{flag:'wx',mode:0o600});
  console.log(JSON.stringify({status:candidate.status,sourceSha256:candidate.sourceSha256,
    candidateSha256:candidate.sha256,realIngressValidated:false,outputPrivate:true}));
}
