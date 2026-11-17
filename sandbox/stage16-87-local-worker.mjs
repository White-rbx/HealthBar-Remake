/**
 * Stage16.87 local-only Worker fixture for Miniflare integration tests.
 * INTENTIONALLY NON-DEPLOYABLE: The "Access" and ingress verifiers below are
 * SIMULATED and must never be reused for a Cloudflare hosted release.
 * There are NO auth, pairing, violations, Appeal or admin endpoints here.
 */
import {createStage1687RestrictedGateway} from './stage16-87-restricted-gateway.mjs';
import {createD1PairingRateLimiter} from './stage16-85-d1-rate-limiter.mjs';

export default {
  async fetch(request,env) {
    const gate=createStage1687RestrictedGateway({
      // TEST STUB ONLY. A production implementation MUST verify Access JWT
      // with issuer/audience/signature/expiry using official Cloudflare keys.
      verifySandboxAccess:async req=>
        env?.TEST_ACCESS_MODE==='local-ci' &&
        req.headers.get('x-local-access-test')==='allow-fixture',
      // TEST STUB ONLY. This is synthetic server-owned context, not edge proof.
      verifyTrustedIngress:async()=>({
        verified:env?.TEST_INGRESS_MODE==='local-ci',
        networkId:env?.TEST_NETWORK_SCOPE,
      }),
      checkRateLimit:async ({action,networkId})=>{
        const limiter=createD1PairingRateLimiter({
          db:env.DB,
          secret:env.TEST_HMAC_SECRET,
          getTrustedNetworkId:()=>networkId,
          clock:()=>Number(env.TEST_NOW_MILLISECONDS),
        });
        return limiter.checkRateLimit({action,request});
      },
    });
    return gate.fetch(request,env);
  },
};
