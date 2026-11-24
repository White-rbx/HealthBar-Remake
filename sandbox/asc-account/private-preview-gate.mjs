// Offline-only safety preflight. Never creates Previews, deploys Workers, or opens login.
// A positive result checks a reviewed plan, not proof of a live Access policy.
export const PIN=Object.freeze({
 worker:'arcscriptcenter-account-qa',
 workerId:'bf038ed7c6fd47c8b227a9a29fcb2d1d',
 qaDb:'93d7dc3d-c196-40ee-a342-4144f0b85d50',
 deployed:'6b9420db-381c-4d53-8692-a82b76399b52',
 candidate:'2b34f5cb-0d89-42f0-8fa9-07b96d487d59',
 source:'2ac41e90aafc236edbb79a40cf0b8e352f319636',
 canonicalOrigin:'https://arcscriptcenter-account-qa.kogpasan14.workers.dev',
});
const req=(ok,message)=>{if(!ok)throw Error('PRIVATE QA PREVIEW BLOCKED: '+message)};
const uuid=x=>typeof x==='string'&&/^[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}$/.test(x);
const binding=(b,n,t)=>b.find(x=>x.name===n&&x.type===t);

export function verifyNoTrafficBaseline(snapshot){
 const {worker,bindings,deployments,versions}=snapshot||{};
 req(worker?.id===PIN.workerId&&worker?.name===PIN.worker,'unexpected Worker identity');
 req(Array.isArray(bindings)&&bindings.length===6,'unexpected binding count');
 req(binding(bindings,'ASC_ACCOUNT_MODE','plain_text')?.text==='isolated-qa','not isolated QA mode');
 req(binding(bindings,'ACCOUNT_DB','d1')?.id===PIN.qaDb,'QA D1 changed');
 for(const [name,type] of [['ACCOUNT_RATE','ratelimit'],['ACCOUNT_TOTP_KEY','secret_text'],
  ['ACCOUNT_TURNSTILE_SECRET','secret_text'],['ACCOUNT_TURNSTILE_SITE_KEY','plain_text']])
  req(!!binding(bindings,name,type),'missing binding: '+name);
 req(!bindings.some(b=>b.name==='ASC_ACCOUNT_AUTH_MODE'||b.name==='ASC_ACCOUNT_LAUNCH_STATE'),
  'real login must remain locked');
 req(Array.isArray(deployments)&&deployments.length>0,'no deployed version');
 req(deployments[0].versions?.length===1&&deployments[0].versions[0]?.version_id===PIN.deployed
  &&deployments[0].versions[0]?.percentage===100,'live deployment changed');
 req(Array.isArray(versions)&&versions.some(v=>v.id===PIN.candidate && v.number===11
  &&v.annotations?.['workers/commit_sha']===PIN.source),'candidate version/source mismatch');
 return {locked:true,activeVersion:PIN.deployed,candidateVersion:PIN.candidate,trafficPercent:0};
}

export function verifyPrivatePreviewPlan(plan,baseline){
 verifyNoTrafficBaseline(baseline);
 req(plan?.accountScope==='isolated-account-qa','preview must be scoped to QA');
 req(plan?.transport==='Cloudflare Worker Preview','must use Preview (not Version URL)');
 // A Version URL reuses its uploaded version's bindings and is not an isolated environment.
 req(plan?.sharedVersionUrl!==true,'Version URL cannot be used for isolated tests');
 const origin=plan?.origin;
 req(typeof origin==='string'&&origin!==PIN.canonicalOrigin,'must use separate QA preview origin');
 let url;
 try{url=new URL(origin)}catch{throw Error('PRIVATE QA PREVIEW BLOCKED: invalid preview origin')}
 req(url.protocol==='https:' && url.origin===origin && url.username==='' && url.password==='',
  'preview origin must be exact HTTPS origin');
 req(url.hostname.endsWith('.workers.dev') && url.hostname.includes('arcscriptcenter-account-qa'),
  'preview origin does not look scoped to the QA Worker');
 // Both WebAuthn expectedOrigin and RP ID are derived from the fixed origin.
 // Never trust an arbitrary request Host/Origin as the expected WebAuthn origin.
 req(plan?.originWiring==='fixed-explicit-createAccountWorker-origin',
  'Passkey origin/RP ID must be explicitly pinned at Worker entrypoint');
 req(plan?.access?.protected===true && plan.access.destination==='preview_worker'
  && plan.access.workerId===PIN.workerId && plan.access.reviewed===true,
  'private Access policy for the Preview has not been verified');
 req(plan?.previewD1?.type==='d1' && uuid(plan.previewD1.id)
  &&plan.previewD1.id!==PIN.qaDb,'Preview must use a separate synthetic-only D1');
 req(plan?.previewD1?.schemaVerified===true && plan?.previewD1?.syntheticOnly===true,
  'Preview D1 schema and synthetic-only scope not verified');
 req(plan?.turnstile?.hostname===url.hostname && plan.turnstile?.testOnly===true
  && plan.turnstile?.actions?.includes('asc_register')
  && plan.turnstile?.actions?.includes('asc_recover'),
  'preview Turnstile host, test-only keys and verification actions are not ready');
 req(plan?.previewRateLimiter?.isolated===true && plan?.syntheticSecretsOnly===true,
  'preview rate limiter and secret isolation not verified');
 req(plan?.defaultLaunchState==='locked'&&plan?.initialAuthMode===null,
  'Preview must start with login/registration disabled');
 req(plan?.usesRealUsers===false&&plan?.usesProductionBindings===false,
  'no real users or Production bindings');
 req(plan?.createsPublicRegistration===false&&plan?.editsDeployedTraffic===false,
  'public registration or traffic change requested');
 return {readyForLockedPreviewSetup:true,readyForLiveEnrollment:false};
}
