// ArcScriptCenter — local-only source merge REVIEW candidate. NEVER deploy directly.
// Requires current Worker source files obtained privately by an authorized operator.
// Does not fetch secrets, contact Cloudflare or write to GitHub.
import fs from "node:fs";
import {createHash} from "node:crypto";
import {spawnSync} from "node:child_process";

(function () {
  const manifest=JSON.parse(fs.readFileSync(new URL("./production-candidate-merge-manifest.json",import.meta.url),"utf8"));
  const flags=process.argv.slice(2);
  if(flags.length!==6||flags[0]!=="--production"||flags[2]!=="--sandbox"||flags[4]!=="--output"){
    throw Error("Usage: node sandbox/production-candidate-assembler.mjs --production ./production.worker.mjs --sandbox ./sandbox.worker.mjs --output ./candidate.review-only.mjs");
  }
  const [productionPath,sandboxPath,output]=[flags[1],flags[3],flags[5]];
  const prod=fs.readFileSync(productionPath,"utf8"),sb=fs.readFileSync(sandboxPath,"utf8");
  const sha=x=>createHash("sha256").update(x,"utf8").digest("hex");
  const stop=x=>{throw Error("RELEASE CANDIDATE STOP: "+x);};
  const requireOnce=(s,needle,label)=>{
    if(!needle||s.split(needle).length!==2)stop(label+" anchor absent or duplicated");
  };
  const replaceOnce=(s,needle,replacement,label)=>{
    requireOnce(s,needle,label);return s.replace(needle,replacement);
  };
  const between=(s,start,end,label)=>{
    requireOnce(s,start,label+" START");requireOnce(s,end,label+" END");
    const i=s.indexOf(start),j=s.indexOf(end);
    if(j<=i)stop(label+" wrong boundary order");
    return s.slice(i,j);
  };
  if(manifest.status!=="REVIEW_ONLY_NOT_DEPLOYABLE"||sha(prod)!==manifest.base.sha256||
     sha(sb)!==manifest.featureSource.sha256)stop("unpinned Worker source, use inspected exact snapshots");
  if(!prod.includes("const VERSION = '0.5.41.5-phase1';")||
     !sb.includes("const VERSION = '0.5.79.0-cron-retry-sandbox';"))stop("unexpected Worker versions");
  const entryProd="export default {\n  async fetch(request, env) {";
  requireOnce(prod,entryProd,"Production default export");
  const prodTry="    try {\n      if (path === '/api/v1/client/ban-check' && request.method === 'POST')";
  requireOnce(prod,prodTry,"legacy route entry");
  const find=name=>{const entry=manifest.selectedComponents.find(x=>x.key===name);
    if(!entry)stop("manifest missing component "+name);
    return between(sb,entry.startAnchor,entry.endAnchor,name);
  };
  let feedback=find("feedbackApi");
  const startDummy="async function ascVerifyFeedbackChallenge";
  const endDummy="async function fcSubmit";
  const toRemove=between(feedback,startDummy,endDummy,"dummy Turnstile");
  feedback=replaceOnce(feedback,toRemove,"","remove dummy Siteverify");
  feedback=replaceOnce(feedback,
    "async function fcSubmit(request,env,origin,verifyMode='dummy',ctx=null)",
    "async function fcSubmit(request,env,origin,ctx=null)","enforce real fcSubmit signature");
  feedback=replaceOnce(feedback,
    "const human = verifyMode === 'real-stage1667' ? await ascStage1667SiteVerify(b,env) : await ascVerifyFeedbackChallenge(b,env);",
    "const human = await ascStage1667SiteVerify(b,env);","enforce real Siteverify on all submissions");
  feedback=feedback.replace("Stage 16.60 SANDBOX ONLY:","Release candidate:").replace("Production release remains blocked until independent anti-abuse verification is ready.","Separate production anti-abuse approval is required before deployment.");
  let verifier=find("realTurnstileVerifier");
  verifier=replaceOnce(verifier,
    "verdict.hostname!=='arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev'",
    "verdict.hostname!==env.ASC_TURNSTILE_HOSTNAME","real Siteverify hostname check");
  let adminPush=find("adminNotificationsAndPush");
  adminPush=replaceOnce(adminPush,
    "const ASC_STAGE1671_HOST='arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev';",
    "","strip Sandbox VAPID JWT subject hostname");
  adminPush=replaceOnce(adminPush,
    "sub:'https://'+ASC_STAGE1671_HOST",
    "sub:'https://'+String(env.ASC_RELEASE_HOSTNAME)","dynamic VAPID subject");
  const originalGate="function ascStage1671IsSandbox(request,env,ctx){\n const u=new URL(request.url);\n return !!ctx?.access && VERSION.includes('-sandbox') &&\n  env.ASC_TURNSTILE_MODE==='sandbox-dummy' && u.hostname===ASC_STAGE1671_HOST;\n}";
  const releaseGate="function ascReleaseDomainGate(request,env,ctx){\n const u=new URL(request.url);\n return !!ctx?.access && ascReleaseEnvReady(env) && u.hostname===env.ASC_RELEASE_HOSTNAME;\n}";
  adminPush=replaceOnce(adminPush,originalGate,releaseGate,"replace Sandbox domain authorization");
  adminPush=replaceOnce(adminPush,
    "function ascStage1670Page(request,env,ctx){",
    "async function ascStage1670Page(request,env,ctx){","admin notifications Page authorization");
  adminPush=replaceOnce(adminPush,
    "if(!ctx?.access || !VERSION.includes('-sandbox') ||\n    url.hostname!=='arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev')",
    "if(!(await ascStage1671VerifiedAdmin(request,env,ctx)))","admin notifications page verified identity");
  adminPush=replaceOnce(adminPush,
    "if(!ctx?.access||!VERSION.includes('-sandbox')||url.hostname!=='arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev')",
    "if(!(await ascStage1671VerifiedAdmin(request,env,ctx)))","admin notifications API verified identity");
  for(const [name,label] of [["ascStage1671Document","push setup page"],["ascStage1671Worker","push service worker"]]){
    adminPush=replaceOnce(adminPush,
      "function "+name+"(request,env,ctx){\n if(!ascStage1671IsSandbox(request,env,ctx))",
      "async function "+name+"(request,env,ctx){\n if(!(await ascStage1671VerifiedAdmin(request,env,ctx)))",
      label+" verified identity");
  }
  adminPush=adminPush.replaceAll("ascStage1671IsSandbox","ascReleaseDomainGate");
  let outbox=find("durableOutbox");
  outbox=outbox.replaceAll("ascStage1671IsSandbox","ascReleaseDomainGate");
  let cron=find("cronRunner");
  cron=replaceOnce(cron,
    "if(!VERSION.includes('-sandbox')||env.ASC_TURNSTILE_MODE!=='sandbox-dummy'||\n    typeof env.ASC_PUSH_ACCESS_AUD!=='string'||\n    !/^[A-Za-z0-9_-]{32,128}$/.test(env.ASC_PUSH_ACCESS_AUD)||!env.DB||\n    controller?.cron!=='*/5 * * * *')return;",
    "if(!ascReleaseEnvReady(env)||controller?.cron!=='*/5 * * * *')return;",
    "replace Sandbox Cron guard");
  const routeMap={
    "/__stage1670/admin-notifications":"/api/v1/admin/push/notifications",
    "/__stage1670/api/notifications":"/api/v1/admin/push/events",
    "/__stage1671/android-push":"/api/v1/admin/push",
    "/__stage1671/sw.js":"/api/v1/admin/push/sw.js",
    "/__stage1671/key":"/api/v1/admin/push/key",
    "/__stage1671/subscription":"/api/v1/admin/push/subscription",
    "/__stage1674/push-health":"/api/v1/admin/push/health",
    "/__stage1674/status":"/api/v1/admin/push/status",
    "/__stage1674/retry-due":"/api/v1/admin/push/retry",
    "/__stage1675/cron-health":"/api/v1/admin/push/cron",
    "/__stage1675/status":"/api/v1/admin/push/cron/status",
    "/__stage1671/":"/api/v1/admin/push/"
  };
  let features=[feedback,verifier,adminPush,outbox,cron].join("\n");
  for(const [from,to] of Object.entries(routeMap).sort((a,b)=>b[0].length-a[0].length)){
    features=features.replaceAll(from,to);
  }
  features=features.replaceAll("SANDBOX","RELEASE CANDIDATE");
  features=features.replaceAll("Sandbox","Release Candidate");
  const envGate=`
// Release candidate gate: fail-closed until all production-specific bindings are
// independently reviewed and supplied by the authorized owner in Cloudflare.
// Never publish or embed secret values in this source.
function ascReleaseEnvReady(env){
 return VERSION==='0.5.80.0-production-candidate' &&
  env?.ASC_RELEASE_CHANNEL==='production' &&
  env?.ASC_TURNSTILE_MODE==='real' &&
  typeof env.ASC_RELEASE_HOSTNAME==='string' &&
  /^[a-z0-9.-]{4,253}$/i.test(env.ASC_RELEASE_HOSTNAME) &&
  env.ASC_TURNSTILE_HOSTNAME===env.ASC_RELEASE_HOSTNAME &&
  typeof env.ASC_TURNSTILE_REAL_SECRET==='string' &&
  env.ASC_TURNSTILE_REAL_SECRET.length>=20 &&
  typeof env.ASC_FEEDBACK_QUOTA_KEY==='string' &&
  env.ASC_FEEDBACK_QUOTA_KEY.length>=32 &&
  typeof env.ASC_PUSH_ACCESS_AUD==='string' &&
  /^[A-Za-z0-9_-]{32,128}$/.test(env.ASC_PUSH_ACCESS_AUD) &&
  typeof env.ASC_PUSH_ADMIN_EMAIL_SHA256==='string' &&
  /^[0-9a-f]{64}$/i.test(env.ASC_PUSH_ADMIN_EMAIL_SHA256) &&
  typeof env.ASC_PUSH_VAPID_PRIVATE_JWK==='string' &&
  !!env.ASC_PUSH_VAPID_PUBLIC_KEY && !!env.DB;
}
`;
  const feedbackStart=sb.indexOf("if (path === '/api/v1/feedback/submit' && request.method === 'POST')");
  const feedbackEnd=sb.indexOf("if (path === '/api/v1/client/ban-check' && request.method === 'POST')",feedbackStart);
  if(feedbackStart<0||feedbackEnd<=feedbackStart)stop("Feedback router boundaries changed");
  let feedbackRoutes=sb.slice(feedbackStart,feedbackEnd);
  feedbackRoutes=replaceOnce(feedbackRoutes,
    "fcSubmit(request,env,origin,'dummy',ctx)",
    "fcSubmit(request,env,origin,ctx)","production Feedback submit routes");
  if(/stage1664|stage1666|stage1667|stage1672|stage1673|sandbox-dummy|arcscriptcenter-merge-sandbox/.test(feedbackRoutes))
    stop("test-only names in Feedback routes");
  const pushRoutes=[
    "      if(path==='/api/v1/admin/push/cron'&&request.method==='GET')return await asc1675Page(request,env,ctx);",
    "      if(path==='/api/v1/admin/push/cron/status'&&request.method==='GET')return await asc1675Status(request,env,ctx);",
    "      if(path==='/api/v1/admin/push/health'&&request.method==='GET')return await asc1674Page(request,env,ctx);",
    "      if(path==='/api/v1/admin/push/status'&&request.method==='GET')return await asc1674Status(request,env,ctx);",
    "      if(path==='/api/v1/admin/push/retry'&&request.method==='POST')return await asc1674Retry(request,env,ctx);",
    "      if(path==='/api/v1/admin/push/notifications'&&request.method==='GET')return await ascStage1670Page(request,env,ctx);",
    "      if(path==='/api/v1/admin/push/events'&&request.method==='GET')return await ascStage1670Notifications(request,env,ctx);",
    "      if(path==='/api/v1/admin/push'&&request.method==='GET')return await ascStage1671Document(request,env,ctx);",
    "      if(path==='/api/v1/admin/push/sw.js'&&request.method==='GET')return await ascStage1671Worker(request,env,ctx);",
    "      if((path==='/api/v1/admin/push/key'&&request.method==='GET')||(path==='/api/v1/admin/push/subscription'&&request.method==='POST'))return await ascStage1671Api(request,env,ctx);"
  ].join("\n");
  const allNewPaths=[
    "/api/v1/feedback/submit","/api/v1/feedback/status","/api/v1/feedback/manage",
    "/api/v1/admin/feedback","/api/v1/admin/feedback/history","/api/v1/admin/feedback/summary",
    "/api/v1/admin/feedback/list","/api/v1/admin/feedback/case","/api/v1/admin/feedback/activity",
    "/api/v1/admin/feedback/followup","/api/v1/admin/feedback/followup/details",
    ...Object.values(routeMap).filter(x=>x.startsWith("/api/v1/admin/push")&&!x.endsWith("/"))
  ];
  const routeGate=`
      // Additive release-candidate routes; legacy Production routes follow unchanged.
      if(ASC_RELEASE_NEW_PATHS.has(path)){
        if(!ascReleaseEnvReady(env))
          return json({ok:false,error:'Feature not configured'},503,origin);
        if(url.hostname!==env.ASC_RELEASE_HOSTNAME)
          return json({ok:false,error:'Not Found'},404,origin);
        if(path.startsWith('/api/v1/admin/push') &&
           !(await ascStage1671VerifiedAdmin(request,env,ctx)))
          return json({ok:false,error:'Authorized admin identity required'},401,origin);
${pushRoutes}
        ${feedbackRoutes.trimStart()}
        return json({ok:false,error:'Method Not Allowed'},405,origin);
      }
`;
  const declarations=`const ASC_RELEASE_NEW_PATHS = new Set(${JSON.stringify([...new Set(allNewPaths)])});\n`;
  let candidate=replaceOnce(prod,
    "const VERSION = '0.5.41.5-phase1';",
    "const VERSION = '0.5.80.0-production-candidate';",
    "candidate version update");
  candidate=replaceOnce(candidate,entryProd,
    "export default {\n  async scheduled(controller, env, ctx) {\n    await asc1675CronRunner(controller,env,ctx);\n  },\n  async fetch(request, env, ctx) {",
    "add scheduled handler and ctx");
  candidate=replaceOnce(candidate,
    "    try {\n      if (path === '/api/v1/client/ban-check' && request.method === 'POST')",
    "    try {\n"+routeGate+"      if (path === '/api/v1/client/ban-check' && request.method === 'POST')",
    "inject new routes while preserving legacy Production");
  requireOnce(candidate,"\nexport default {\n","single Production default export");
  candidate=replaceOnce(candidate,"\nexport default {\n",
    "\n"+envGate+"\n"+declarations+"\n"+features+"\nexport default {\n",
    "add reviewed subset only");
  const forbidden=[
    "XXXX.DUMMY.TOKEN.XXXX","sandbox-dummy","arcscriptcenter-merge-sandbox-1658",
    "/__stage1664/","/__stage1666/","/__stage1667/","/__stage1672/","/__stage1673/",
    "ASC_STAGE1664_HTML","ASC_STAGE1666_REAL_HTML","ASC_STAGE1667_HTML",
    "ASC_STAGE1672_PAGE","ASC_STAGE1673_PAGE","ascStage1667Page"
  ];
  const violations=forbidden.filter(token=>candidate.includes(token));
  if(violations.length)stop("forbidden test-only references: "+violations.join(", "));
  if(candidate.includes("ascVerifyFeedbackChallenge")||candidate.includes("ascStage1671IsSandbox"))
    stop("unsafe verification or Sandbox auth helper survived");
  const invariant=[
    "async function adminWarningWrite",
    "function adminAuthenticated",
    "async function fcSubmit",
    "async function asc1674Deliver",
    "async function asc1675CronRunner",
    "async scheduled(controller, env, ctx)",
    "env?.ASC_RELEASE_CHANNEL==='production'",
    "url.hostname!==env.ASC_RELEASE_HOSTNAME",
    "verdict.hostname!==env.ASC_TURNSTILE_HOSTNAME",
    "ASC_RELEASE_NEW_PATHS.has(path)"
  ];
  for(const item of invariant)if(!candidate.includes(item))stop("candidate missing invariant "+item);
  const legacyStart=prod.indexOf("if (path === '/api/v1/client/ban-check' && request.method === 'POST')");
  if(legacyStart<0||!candidate.includes(prod.slice(legacyStart)))stop("original legacy Production route body was changed");
  if(fs.existsSync(output))stop("output path already exists");
  fs.writeFileSync(output,candidate,{flag:"wx",mode:0o600});
  const check=spawnSync(process.execPath,["--check",output],{encoding:"utf8"});
  if(check.status!==0){
    fs.unlinkSync(output);
    stop("Node syntax check failed: "+(check.stderr||"").slice(0,600));
  }
  process.stdout.write(JSON.stringify({
    status:"REVIEW_ONLY_NOT_DEPLOYABLE",output,
    productionSha256:manifest.base.sha256,sandboxSha256:manifest.featureSource.sha256,
    candidateSha256:sha(candidate),candidateBytes:Buffer.byteLength(candidate),
    legacyRoutesPreserved:true,realSiteverifyOnly:true,testRoutesExcluded:true,
    productionDeploymentPermitted:false
  },null,2)+"\n");
})();
