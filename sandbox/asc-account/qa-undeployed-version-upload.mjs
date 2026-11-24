// ArcScriptCenter Account: one-way, undeployed STAGING version upload gate.
// The default CLI action performs ONLY an offline digest check.
// No deployment creation, auth-mode activation, account writes or Production access.
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';

export const PIN=Object.freeze({
 account:'f6e7dcd28b584b86d147edba3b269837',
 name:'arcscriptcenter-account-qa',
 workerId:'bf038ed7c6fd47c8b227a9a29fcb2d1d',
 d1:'93d7dc3d-c196-40ee-a342-4144f0b85d50',
 rateNamespace:'8728',
 activeVersion:'6b9420db-381c-4d53-8692-a82b76399b52',
 sourceCommit:'2ac41e90aafc236edbb79a40cf0b8e352f319636',
 digest:'d58ea8031e31c8561af8b6721491483c4f403ce28402f63e6f18c4cfeaa18776',
});
const API='https://api.cloudflare.com/client/v4/accounts/'+PIN.account;
const expectedNames=[
 ['ACCOUNT_DB','d1'],['ACCOUNT_RATE','ratelimit'],['ACCOUNT_TOTP_KEY','secret_text'],
 ['ACCOUNT_TURNSTILE_SECRET','secret_text'],['ACCOUNT_TURNSTILE_SITE_KEY','plain_text'],
 ['ASC_ACCOUNT_MODE','plain_text'],
];
function assert(condition,message){if(!condition)throw new Error('QA guard: '+message)}
export function verifyBundle(bytes){
 const sum=createHash('sha256').update(bytes).digest('hex');
 assert(bytes.length===900711,'unexpected module size');
 assert(sum===PIN.digest,'compiled module digest differs from pinned CI artifact');
 return sum;
}
export function extractDeployment(data){
 const ds=Array.isArray(data?.result)?data.result:data?.result?.deployments;
 assert(Array.isArray(ds)&&ds.length,'missing QA deployments');
 const d=ds[0];
 assert(d.versions?.length===1,'QA deployment must have exactly one version');
 assert(d.versions[0].version_id===PIN.activeVersion,'deployed QA version changed');
 assert(d.versions[0].percentage===100,'QA deployment is not 100% pinned');
 return d.id;
}
export function verifyRemote(worker,settings,deployments){
 assert(worker?.success===true&&worker?.result?.id===PIN.workerId,'unexpected Worker identity');
 assert(worker.result.name===PIN.name,'unexpected Worker name');
 assert(settings?.success===true,'missing QA settings');
 const bs=settings.result?.bindings;
 assert(Array.isArray(bs)&&bs.length===expectedNames.length,'QA binding count changed');
 const observed=new Map(bs.map(b=>[b.name,b]));
 assert(observed.size===bs.length,'duplicate QA bindings');
 for(const [name,type] of expectedNames){
  const b=observed.get(name);
  assert(b?.type===type,'missing or changed binding: '+name);
 }
 assert(observed.get('ACCOUNT_DB').id===PIN.d1,'QA D1 is not pinned isolated database');
 assert(String(observed.get('ACCOUNT_RATE').namespace_id)===PIN.rateNamespace,'QA limiter namespace drifted');
 assert(observed.get('ASC_ACCOUNT_MODE').text==='isolated-qa','QA environment flag drifted');
 assert(!observed.has('ASC_ACCOUNT_AUTH_MODE')&&!observed.has('ASC_ACCOUNT_LAUNCH_STATE'),
  'Login activation flag must remain absent');
 return extractDeployment(deployments);
}
export function makeVersion(bytes){
 verifyBundle(bytes);
 return {
  main_module:'account-passkey-worker.mjs',
  compatibility_date:'2026-08-06',
  compatibility_flags:['nodejs_compat'],
  annotations:{'workers/message':'ASC-QA-UNDEPLOYED-ONLY; source '+PIN.sourceCommit,
   'workers/tag':'ASC-PASSKEY-LOCKED-CANDIDATE'},
  bindings:expectedNames.map(([name])=>({name,type:'inherit',version_id:PIN.activeVersion})),
  modules:[{name:'account-passkey-worker.mjs',content_type:'application/javascript+module',
   content_base64:bytes.toString('base64')}],
 };
}
export async function uploadUndeployed(bytes,{fetcher=fetch,token,enabled=false}={}){
 verifyBundle(bytes);
 assert(enabled===true,'upload requires explicit --upload flag');
 assert(typeof token==='string'&&token.length>20,'a private Cloudflare API token is required');
 const headers={Authorization:'Bearer '+token,Accept:'application/json'};
 async function request(method,path,body){
  const result=await fetcher(API+path,{method,headers:{...headers,...(body?{'Content-Type':'application/json'}:{})},
   ...(body?{body:JSON.stringify(body)}:{})});
  assert(result.ok,'Cloudflare API refused '+method+' '+path+' ('+result.status+')');
  const value=await result.json();
  assert(value?.success===true,'Cloudflare API returned unsuccessful response');
  return value;
 }
 const workerPath='/workers/workers/'+PIN.name;
 const scriptPath='/workers/scripts/'+PIN.name;
 const [worker,settings,before]=await Promise.all([
  request('GET',workerPath),request('GET',scriptPath+'/settings'),
  request('GET',scriptPath+'/deployments'),
 ]);
 const deploymentId=verifyRemote(worker,settings,before);
 const created=await request('POST',workerPath+'/versions',makeVersion(bytes));
 const id=created.result?.id;
 assert(typeof id==='string'&&/^[a-f0-9-]{36}$/.test(id),'no valid uploaded version ID returned');
 const after=await request('GET',scriptPath+'/deployments');
 assert(extractDeployment(after)===deploymentId,'deployment changed during QA version upload');
 return {uploadedVersion:id,deployedVersion:PIN.activeVersion,trafficPercent:0};
}
const entry=process.argv[1]&&pathToFileURL(resolve(process.argv[1])).href;
if(entry===import.meta.url){
 const args=process.argv.slice(2);
 const flag=args.includes('--upload');
 const file=args.find(x=>x.startsWith('--bundle='))?.slice(9)||'sandbox/asc-account/dist/account-passkey-worker.mjs';
 if(args.some(x=>x!=='--upload'&&!x.startsWith('--bundle=')))throw Error('Unknown CLI argument');
 const bytes=await readFile(file);
 verifyBundle(bytes);
 if(!flag){console.log('PASS: pinned QA module digest. Offline-only dry run; NO upload.');}
 else{
  assert(process.env.ASC_ALLOW_ACCOUNT_QA_VERSION_UPLOAD==='YES_QA_UNDEPLOYED_ONLY',
   'explicit QA upload environment guard missing');
  const result=await uploadUndeployed(bytes,{enabled:true,token:process.env.CLOUDFLARE_API_TOKEN});
  console.log('Undeployed Account QA candidate uploaded:',result.uploadedVersion);
  console.log('Original deployed Account QA version unchanged:',result.deployedVersion,'100%');
 }
}
