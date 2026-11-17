/**
 * Stage 16.87 — closed-by-default security gateway CONTRACT, not deployed.
 *
 * This is NOT a Roblox OAuth login, trusted Roblox game-server identity
 * verifier, Cloudflare Access JWT verifier or real Cloudflare ingress attestor.
 *
 * No public pairing, Feedback/Appeal, Violation, user-profile or admin routes.
 * Injection of BOTH independently verified trust signals is mandatory.
 *
 * IMPORTANT: Request headers (CF-Connecting-IP, CF-Worker, X-Real-IP,
 * X-Forwarded-For, Authorization, Origin) are NOT identity attestation by
 * themselves. A protected infrastructure routing review is mandatory.
 */
const RESPONSE_HEADERS = Object.freeze({
  'content-type': 'application/json; charset=utf-8',
  'cache-control': 'no-store, private',
  'referrer-policy': 'no-referrer',
  'x-content-type-options': 'nosniff',
  'x-frame-options': 'DENY',
  'content-security-policy': "default-src 'none'; frame-ancestors 'none'; base-uri 'none'",
});
const ONLY_ROUTE = '/__stage1687/rate-probe';
const ALLOWED_METHOD = 'POST';
function reply(status, body) {
  return new Response(JSON.stringify(body),{status,headers:RESPONSE_HEADERS});
}
function validNetworkScope(v) {
  return typeof v === 'string' && /^[A-Za-z0-9:._-]{3,128}$/.test(v);
}
function isRequestFromDisallowedHop(request) {
  // Defense in depth; these checks alone are NOT provenance verification.
  // Same-zone Worker subrequests can influence CF-Connecting-IP, so upstream
  // Cloudflare/WAF routing enforcement is a separate mandatory release gate.
  return request.headers.has('cf-worker') || request.headers.has('x-real-ip');
}
export function createStage1687RestrictedGateway({
  verifyTrustedIngress,
  verifySandboxAccess,
  checkRateLimit,
} = {}) {
  if (typeof verifyTrustedIngress !== 'function' ||
      typeof verifySandboxAccess !== 'function' ||
      typeof checkRateLimit !== 'function') {
    throw new TypeError('Independent trusted ingress, Access and D1 limiter verifiers required');
  }
  return Object.freeze({
    async fetch(request, env) {
      // No deployment with a real 'enable' setting in this stage. This is only
      // a test fixture; a hosted release needs a separate reviewed entrypoint.
      if (env?.STAGE1687_LOCAL_TEST_ONLY !== 'local-workerd-fixture') {
        return reply(404,{ok:false});
      }
      let url;
      try {url=new URL(request.url);}catch{return reply(404,{ok:false});}
      // A single non-privileged probe is the ENTIRE allowlist.
      if (url.pathname!==ONLY_ROUTE || url.search!=='' || request.method!==ALLOWED_METHOD ||
          url.username!=='' || url.password!=='' || url.hash!=='') {
        return reply(404,{ok:false});
      }
      if (isRequestFromDisallowedHop(request)) return reply(403,{ok:false});
      let access, ingress;
      try {
        // Even a valid header or a browser's Origin/CF metadata alone does not
        // establish provenance or authorization. Require external verified results.
        [access,ingress] = await Promise.all([
          verifySandboxAccess(request),
          verifyTrustedIngress(request),
        ]);
      } catch {return reply(503,{ok:false,error:'Verification unavailable'});}
      if(access!==true || ingress?.verified!==true ||
         !validNetworkScope(ingress.networkId)) {
        return reply(403,{ok:false});
      }
      try {
        const allowed = await checkRateLimit({action:'start',networkId:ingress.networkId});
        if(allowed!==true) return reply(429,{ok:false,limited:true});
      } catch {
        return reply(503,{ok:false,error:'Rate limit unavailable'});
      }
      return reply(200,{ok:true,probe:true});
    },
  });
}
export const STAGE1687_GATEWAY_ALLOWLIST = Object.freeze({
  path:ONLY_ROUTE,
  method:ALLOWED_METHOD,
  disabledWithoutBinding:'STAGE1687_LOCAL_TEST_ONLY',
});
