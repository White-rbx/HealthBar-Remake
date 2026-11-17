/**
 * ArcScriptCenter Stage16.86 — LOCAL WORKERD TEST FIXTURE ONLY.
 * This file MUST NOT BE DEPLOYED. No OAuth, no pairing, no user data.
 * It exercises the real Stage16.85 D1 rate limiter in the Worker runtime.
 * Its synthetic network identifier and fixed clock come from harness-only
 * server bindings; it makes NO claim of real Cloudflare edge attestation.
 */
import { createD1PairingRateLimiter } from './stage16-85-d1-rate-limiter.mjs';

const NO_CACHE = {
  'cache-control': 'no-store',
  'content-type': 'application/json; charset=utf-8',
  'x-content-type-options': 'nosniff',
};
function response(data, status) {
  return new Response(JSON.stringify(data), {status, headers:NO_CACHE});
}
export default {
  async fetch(request, env) {
    // A deliberate fail-closed guard: this is only for local tests.
    if (env?.STAGE1686_LOCAL_ONLY !== 'enabled-for-workerd-tests' ||
        env?.TEST_HARNESS_KEY !== 'sandbox-local-fixture-only') {
      return response({ok:false},404);
    }
    const url = new URL(request.url);
    if (url.pathname !== '/__stage1686/test-rate' ||
        url.search || request.method !== 'POST') {
      return response({ok:false},404);
    }
    if (request.headers.get('x-offline-fixture') !== env.TEST_HARNESS_KEY) {
      return response({ok:false},403);
    }
    try {
      // No UserId, cookies, requester headers or payload used as identity.
      const limiter = createD1PairingRateLimiter({
        db: env.DB,
        secret: env.TEST_HMAC_SECRET,
        getTrustedNetworkId: () => env.TEST_NETWORK_FIXTURE,
        clock: () => Number(env.TEST_NOW_MILLISECONDS),
      });
      const allowed = await limiter.checkRateLimit({action:'start',request});
      return response({ok:allowed,limited:!allowed},allowed?200:429);
    } catch {
      // D1, crypto, or missing bindings cannot cause an allow.
      return response({ok:false,error:'Unavailable'},503);
    }
  },
};
