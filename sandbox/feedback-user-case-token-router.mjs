import { CASE_TOKEN_ROUTES, createUserCaseTokenHandler } from './feedback-user-case-token-staging.mjs';

const paths = new Set(Object.values(CASE_TOKEN_ROUTES));
const encoder = new TextEncoder();

async function checkRateLimit({ action, request, env }) {
 const edgeNetwork = request.headers.get('CF-Connecting-IP');
 if (!request.cf?.colo || !edgeNetwork || !/^[0-9a-fA-F.:]{3,45}$/.test(edgeNetwork))
  throw new Error('Cloudflare edge metadata unavailable');
 if (typeof env.CASE_TOKEN_RATE?.limit !== 'function')
  throw new Error('Case Token rate binding unavailable');

 // An edge network only scopes the quota. It cannot authorize a case lookup.
 const hash = await crypto.subtle.digest('SHA-256', encoder.encode(edgeNetwork));
 const key = Array.from(new Uint8Array(hash), byte => byte.toString(16).padStart(2, '0')).join('');
 const { success } = await env.CASE_TOKEN_RATE.limit({ key: action + ':' + key });
 if (typeof success !== 'boolean') throw new Error('Unexpected rate binding result');
 return success;
}

const handleUserCaseToken = createUserCaseTokenHandler({ checkRateLimit });

export function mountUserCaseToken(legacy) {
 return {
  ...legacy,
  fetch(request, env, ctx) {
   if (paths.has(new URL(request.url).pathname)) {
    if (new URL(request.url).hostname !== env.CASE_TOKEN_HOST)
     return new Response(null, { status: 404 });
    return handleUserCaseToken(request, env);
   }
   return legacy.fetch(request, env, ctx);
  },
 };
}
