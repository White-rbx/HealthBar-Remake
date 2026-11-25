// Offline-only safety preflight. Never creates Previews, deploys Workers, or opens login.
// A positive result checks a reviewed plan, not proof of a live Access policy.
export const PIN=Object.freeze({
 worker:'arcscriptcenter-account-qa',
 workerId:'bf038ed7c6fd47c8b227a9a29fcb2d1d',
 qaDb:'93d7dc3d-c196-40ee-a342-4144f0b85d50',
 previewDb:'04715765-050f-4e26-b4f6-6101bba9dc97',
 deployed:'6b9420db-381c-4d53-8692-a82b76399b52',
 candidate:'2b34f5cb-0d89-42f0-8fa9-07b96d487d59',
 source:'2ac41e90aafc236edbb79a40cf0b8e352f319636',
 canonicalOrigin:'https://arcscriptcenter-account-qa.kogpasan14.workers.dev',
 accessApp:'75bf5130-77b0-4add-b59f-0fca6825fe5e',
 lockedPreview:'c7bbd14fd43a4e9a87a308fcab659699',
 lockedDeployment:'fc8f71e9-cf0f-498b-97b3-181ba01f3576',
 qaDeployment:'4400fc76-f4aa-4e24-98d4-fdca11bcff56',
 previewOrigin:'https://eslogin-arcscriptcenter-account-qa.kogpasan14.workers.dev',
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
 req(origin===PIN.previewOrigin,'origin must match the pinned eslogin Preview hostname exactly');
 // Both WebAuthn expectedOrigin and RP ID are derived from the fixed origin.
 // Never trust an arbitrary request Host/Origin as the expected WebAuthn origin.
 req(plan?.originWiring==='fixed-explicit-createAccountWorker-origin',
  'Passkey origin/RP ID must be explicitly pinned at Worker entrypoint');
 req(plan?.access?.protected===true && plan.access.destination==='preview_worker'
  && plan.access.workerId===PIN.workerId && plan.access.reviewed===true,
  'private Access policy for the Preview has not been verified');
 req(plan?.previewD1?.type==='d1' && uuid(plan.previewD1.id)
  &&plan.previewD1.id===PIN.previewDb && plan.previewD1.id!==PIN.qaDb,
  'Preview must use the pinned isolated synthetic-only D1');
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


/**
 * Read-only Access app inventory check. This validates the destination shape,
 * NOT its authentication policies or proof that an anonymous Preview request
 * is actually denied. Never infer protection merely from an app name.
 */
export function verifyPreviewAccessDestination(applications){
 req(Array.isArray(applications),'Access application listing unavailable');
 const candidates=applications.filter(app=>app?.type==='self_hosted'
  &&Array.isArray(app.destinations)
  &&app.destinations.some(dest=>dest?.type==='preview_worker'&&dest.worker_id===PIN.workerId));
 req(candidates.length===1,'exactly one Account QA preview_worker Access destination required');
 const application=candidates[0];
 req(typeof application.id==='string'&&application.id!=='','Access application ID missing');
 req(application.destinations.length===1&&
  application.destinations[0].type==='preview_worker'&&
  application.destinations[0].worker_id===PIN.workerId,
  'Access application must target only the exact Account QA Preview Worker');
 req(!application.destinations[0].overrides?.length,
  'Access preview destination must not have public path overrides');
 req(application.options_preflight_bypass!==true,'Access must not bypass OPTIONS requests');
 return {
  destinationVerified:true,applicationId:application.id,
  policiesVerified:false,unauthorizedProbeVerified:false,readyForLogin:false,
 };
}

/**
 * Verify a fresh READ-ONLY Cloudflare control-plane snapshot of the LOCKED
 * Preview (no account session, no Preview URL) from the actual API responses.
 * The Preview is not an authenticated test environment; this check never
 * approves enabling Version URLs or real Passkey enrollment.
 */
export function verifyLockedPreviewControlPlane(state){
 const {accessApp,accessPolicies,subdomain,preview,previewDeployments,qaDeployments}=state||{};
 req(accessApp?.id===PIN.accessApp && accessApp?.type==='self_hosted',
  'expected locked QA Access application missing');
 req(Array.isArray(accessApp.destinations)&&accessApp.destinations.length===1
  &&accessApp.destinations[0]?.type==='preview_worker'
  &&accessApp.destinations[0]?.worker_id===PIN.workerId
  &&!accessApp.destinations[0]?.overrides?.length,
  'Access must guard only the exact Account QA preview_worker');
 req(accessApp.options_preflight_bypass===false,
  'locked Access must explicitly disable OPTIONS bypass');
 req(Array.isArray(accessPolicies)&&accessPolicies.length===1
  &&accessPolicies[0]?.decision==='deny'
  &&Array.isArray(accessPolicies[0]?.include)
  &&accessPolicies[0].include.length===1&&accessPolicies[0].include[0]?.everyone!=null
  &&(!accessPolicies[0].exclude||accessPolicies[0].exclude.length===0)
  &&(!accessPolicies[0].require||accessPolicies[0].require.length===0),
  'Access must retain a DENY Everyone policy with no exceptions');
 req(subdomain?.enabled===true&&subdomain?.previews_enabled===false,
  'Version URLs must stay disabled while Version 11 shares Account QA bindings');
 req(preview?.id===PIN.lockedPreview&&preview?.name==='eslogin'
  &&Array.isArray(preview.urls)&&preview.urls.length===0
  &&typeof preview.deployed_on==='string'&&preview.deployed_on.length>0,
  'locked Preview identity or URL status changed');
 req(Array.isArray(previewDeployments)&&previewDeployments.length===1
  &&previewDeployments[0]?.id===PIN.lockedDeployment
  &&Array.isArray(previewDeployments[0].urls)&&previewDeployments[0].urls.length===0,
  'unexpected locked Preview deployment or deployment URL');
 req(Array.isArray(qaDeployments)&&qaDeployments[0]?.id===PIN.qaDeployment
  &&qaDeployments[0]?.versions?.length===1
  &&qaDeployments[0].versions[0].version_id===PIN.deployed
  &&qaDeployments[0].versions[0].percentage===100,
  'active Account QA deployment changed');
 return {lockedPreviewCreated:true,accessDenyAll:true,
  versionUrlsDisabled:true,livePreviewUrl:false,readyForAuthentication:false};
}
