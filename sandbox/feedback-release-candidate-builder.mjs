/**
 * ArcScriptCenter Feedback-only Production REVIEW CANDIDATE builder.
 * Never deploy automatically, never merge private Worker sources into GitHub.
 * Input: exact authorized live Worker source snapshots; output private file only.
 */
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
const SHA=source=>createHash('sha256').update(source,'utf8').digest('hex');
export const PIN=Object.freeze({
  production:'036a9f2410e877b51f5293315103e8a8f62ad940fb3f9e8d4efd0bd7e13e0a48',
  staging:'cbfad72cedb65247d49bc20e203e2f19769372f6ebc39474e86239102e4cdd62',
});
function once(source,anchor){if(source.split(anchor).length!==2)throw Error('Source drift: '+anchor)}
function between(source,a,b){once(source,a);once(source,b);const i=source.indexOf(a),j=source.indexOf(b);if(j<=i)throw Error('Incorrect source order');return source.slice(i,j)}
const ACTIONS=[
  ['/api/v1/feedback/submit','POST','fcSubmit(request,env,origin)'],
  ['/api/v1/feedback/status','POST','fcStatus(request,env,origin)'],
  ['/api/v1/feedback/manage','POST','fcManage(request,env,origin)'],
  ['/api/v1/admin/feedback/followup/details','POST','fcAdminFeedbackFollowupDetails(request,env,origin)'],
  ['/api/v1/admin/feedback/followup','POST','fcAdminFeedbackFollowup(request,env,origin)'],
  ['/api/v1/admin/feedback/activity','GET','fcAdminFeedbackActivity(request,env,origin,url)'],
  ['/api/v1/admin/feedback/case','GET','fcAdminFeedbackCase(request,env,origin,url)'],
  ['/api/v1/admin/feedback/list','GET','fcAdminFeedbackList(request,env,origin,url)'],
  ['/api/v1/admin/feedback/summary','GET','fcAdminFeedbackSummary(request,env,origin)'],
  ['/api/v1/admin/feedback/history','GET','fcAdminHistory(request,env,origin,url)'],
  ['/api/v1/admin/feedback','GET','fcAdmin(request,env,origin,url)'],
  ['/api/v1/admin/feedback','POST','fcAdmin(request,env,origin,url)'],
  ['/api/v1/client/violations/lookup','POST','vnLookup(request,env,origin)'],
  ['/api/v1/admin/violations','GET','vnAdmin(request,env,origin,url)'],
  ['/api/v1/admin/violations','POST','vnAdmin(request,env,origin,url)'],
];
const PROD_TRY="    try {\n      if (path === '/api/v1/client/ban-check' && request.method === 'POST')";
function stripStagingOrigins(s){
  for(const key of ['ALLOWED_PREVIEW_ORIGIN','ALLOWED_SECURITY_PREVIEW_ORIGIN','ALLOWED_STAGE1654_PREVIEW_ORIGIN','ALLOWED_STAGE1654_ALIAS_ORIGIN'])
    s=s.replaceAll(' && origin !== '+key,'');
  s=s.replaceAll(' && origin !== new URL(request.url).origin','');
  if(/ALLOWED_(?:PREVIEW_ORIGIN|SECURITY_PREVIEW_ORIGIN|STAGE1654)/.test(s))
    throw Error('Staging-only origin remains in candidate');
  return s;
}
export function prepareFeedbackCandidate({production,staging,rateModule}){
  if(typeof production!=='string'||typeof staging!=='string'||typeof rateModule!=='string')
    throw TypeError('Exact private Worker text and reviewed rate module required');
  if(SHA(production)!==PIN.production||SHA(staging)!==PIN.staging)
    throw Error('Strict Worker SHA pin mismatch — review source drift first');
  if(production.includes("const FC_STATUSES")||production.includes('/api/v1/feedback/submit'))
    throw Error('Production feature already installed; refuse duplicate');
  let core=stripStagingOrigins(between(staging,'const FC_STATUSES','const ASC_MODERATION_HTML'));
  const admin=stripStagingOrigins(between(staging,'async function fcAdminFeedbackSummary','export default {'));
  const begin='  // Global staging quotas, independent of personally identifying data.';
  const end='  const id=crypto.randomUUID();';
  once(core,begin);once(core,end);
  const left=core.indexOf(begin),right=core.indexOf(end,left);
  if(right<=left)throw Error('Invalid quota location');
  core=core.slice(0,left)+[
    '  // Per-network and global D1 quotas; never trust claimed UserId.',
    '  const limited=await ascFeedbackReleaseLimit(request,env);',
    "  if(limited!==null)return json({ok:false,error:limited===429?'Rate limited':'Feedback temporarily unavailable'},limited,origin);",
    '  const now=Math.floor(Date.now()/1000);',
  ].join('\n')+'\n'+core.slice(right);
  if(core.includes('Global staging quotas'))throw Error('Old quota not removed');
  if(!rateModule.includes('export function createReleaseFeedbackRateGuard('))
    throw Error('Rate limiter source mismatch');
  const inner=rateModule.replace(/^export /gm,'');
  if(/^\s*(?:import|export)\s/m.test(inner))throw Error('Dynamic Worker import prohibited');
  // The ingress adapter is intentionally conservative and must be independently
  // validated on the Production host/WAF before any Release approval.
  const rateWrapper=[
    'const ascFeedbackRateFactory=(()=>{',inner,
    'return createReleaseFeedbackRateGuard;})();',
    'async function ascFeedbackReleaseLimit(request,env){',
    " if(!env?.DB||typeof env.ASC_FEEDBACK_RATE_SECRET!=='string'||env.ASC_FEEDBACK_RATE_SECRET.length<32)return 503;",
    " if(new URL(request.url).hostname!=='arcscriptcenter-api.kogpasan14.workers.dev')return 503;",
    ' const verifyEdge=async req=>{',
    "   if(req.headers.has('CF-Worker')||req.headers.has('X-Real-IP'))return {verified:false};",
    "   if(!req.cf||typeof req.cf.tlsVersion!=='string')return {verified:false};",
    "   const ip=req.headers.get('CF-Connecting-IP');",
    "   if(!ip||ip.length>64||!/^[0-9a-f:.]+$/i.test(ip))return {verified:false};",
    '   return {verified:true,networkId:ip};',
    ' };',
    ' const result=await ascFeedbackRateFactory({db:env.DB,secret:env.ASC_FEEDBACK_RATE_SECRET,verifyEdge}).take(request);',
    ' return result.allowed?null:result.status;',
    '}',
  ].join('\n');
  once(production,'export default {');
  let output=production.replace('export default {',rateWrapper+'\n'+core+'\n'+admin+'\nexport default {');
  once(output,PROD_TRY);
  const routes=ACTIONS.map(([path,method,handler])=>
    "      if(path==='"+path+"'&&request.method==='"+method+"')return await "+handler+";");
  const methodPaths=Array.from(new Set(ACTIONS.map(x=>x[0]))).map(x=>"'"+x+"'").join(',');
  routes.push("      if(["+methodPaths+"].includes(path))return json({ok:false,error:'Method Not Allowed'},405,origin);");
  output=output.replace(PROD_TRY,"    try {\n"+routes.join('\n')+"\n      if (path === '/api/v1/client/ban-check' && request.method === 'POST')");
  if(output.split('export default {').length!==2||output.includes('ALLOWED_STAGE1654_')||
     !output.includes("receipt_hash=?")||!output.includes('adminAuthenticated(request,env)'))
    throw Error('Review candidate security/route validation failed');
  return {source:output,sha256:SHA(output),sourceSha:{production:SHA(production),staging:SHA(staging)},
    newRoutes:ACTIONS.length,ownerReleaseApproval:false,status:'REVIEW_ONLY_DO_NOT_DEPLOY'};
}
const current=import.meta.url.startsWith('file:')?fileURLToPath(import.meta.url):null;
if(process.argv[1]===current){
  const args=process.argv.slice(2);
  if(args.length!==6||args[0]!=='--production'||args[2]!=='--staging'||args[4]!=='--output')
    throw Error('Usage: node sandbox/feedback-release-candidate-builder.mjs --production PRIVATE_PROD.js --staging PRIVATE_STAGING.js --output PRIVATE_CANDIDATE.mjs');
  const rate=readFileSync(new URL('./feedback-release-rate-guard.mjs',import.meta.url),'utf8');
  const out=prepareFeedbackCandidate({production:readFileSync(args[1],'utf8'),staging:readFileSync(args[3],'utf8'),rateModule:rate});
  writeFileSync(args[5],out.source,{flag:'wx',mode:0o600});
  console.log(JSON.stringify({status:out.status,sha256:out.sha256,newRoutes:out.newRoutes,outputPrivate:true}));
}
