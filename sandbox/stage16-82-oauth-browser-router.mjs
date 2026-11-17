/**
 * Stage 16.82 — OPTIONAL browser-only HTTP adapter, NOT deployed.
 * One exact HTTPS origin; no browser-to-Luau token bridge; no CORS credentials.
 * Inject a Stage16.81 OIDC instance, built using authenticated server adapters.
 */
const SECURITY = Object.freeze({
  'Cache-Control': 'no-store, private',
  'Referrer-Policy': 'no-referrer',
  'Content-Security-Policy': "default-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
  'X-Frame-Options': 'DENY',
  'X-Content-Type-Options': 'nosniff',
});
function headers(extra = {}) {
  const output = new Headers(SECURITY);
  for (const [name,value] of Object.entries(extra)) output.set(name,value);
  return output;
}
function json(body, status = 200, extra = {}) {
  return new Response(JSON.stringify(body), {
    status, headers:headers({'Content-Type':'application/json; charset=utf-8', ...extra}),
  });
}
function plain(body, status = 200, extra = {}) {
  return new Response(body, {
    status, headers:headers({'Content-Type':'text/plain; charset=utf-8', ...extra}),
  });
}
function redirect(destination, status, cookies = []) {
  const h = headers({Location:destination});
  for(const cookie of cookies) if (cookie) h.append('Set-Cookie',cookie);
  return new Response(null,{status,headers:h});
}
function exactHttpsOrigin(value) {
  if (typeof value !== 'string') throw new TypeError('Sandbox HTTPS origin required');
  const url = new URL(value);
  if (url.protocol !== 'https:' || url.origin !== value ||
      url.username || url.password || url.hash || url.search) {
    throw new TypeError('Sandbox HTTPS origin required');
  }
}
function requireOidc(oidc) {
  for(const method of ['start','callback','resolveVerifiedPrincipal','logout']) {
    if (typeof oidc?.[method] !== 'function') throw new TypeError('OIDC server adapter required: '+method);
  }
}
function singleParam(search, name) {
  const values = search.getAll(name);
  if (values.length !== 1 || !values[0] || values[0].length > 8192) return null;
  return values[0];
}
function sameOriginPost(request, publicOrigin) {
  // Browsers send Origin on POST. Reject absent/foreign Origin (fail closed).
  if (request.headers.get('origin') !== publicOrigin) return false;
  const fetchSite = request.headers.get('sec-fetch-site');
  return !fetchSite || fetchSite === 'same-origin';
}

/** 
 * Browser-only routes; never directly use these handlers from an executor.
 *
 * GET  /auth/start       → Redirect to official Roblox consent
 * GET  /oauth/callback   → Consume one-time state, set HttpOnly session, 303
 * GET  /auth/session     → Minimal same-origin session status; never OAuth tokens
 * POST /auth/logout      → CSRF-aware session revocation
 * GET  /auth/connected   → Static confirmation text, no identity disclosure
 */
export function createStage1682BrowserRouter({oidc, publicOrigin}={}) {
  requireOidc(oidc);
  exactHttpsOrigin(publicOrigin);
  return async function browserRouter(request) {
    let url;
    try { url = new URL(request.url); }
    catch { return json({ok:false,error:'Invalid request'},400); }
    if (url.origin !== publicOrigin || url.username || url.password) {
      return json({ok:false,error:'Unexpected origin'},400);
    }
    if (url.pathname === '/auth/start' && request.method === 'GET') {
      if (url.search) return json({ok:false,error:'Invalid request'},400);
      try {
        const result = await oidc.start();
        // The redirect target must be the official Roblox OAuth authorize endpoint.
        const authUrl = new URL(result.authorizationUrl);
        if (authUrl.origin !== 'https://apis.roblox.com' ||
            authUrl.pathname !== '/oauth/v1/authorize') throw new Error('Invalid authorization target');
        return redirect(result.authorizationUrl,302,[result.setCookie]);
      } catch {
        return json({ok:false,error:'Authentication unavailable'},503);
      }
    }
    if (url.pathname === '/oauth/callback' && request.method === 'GET') {
      const state = singleParam(url.searchParams,'state');
      const code = singleParam(url.searchParams,'code');
      const allowed = [...url.searchParams.keys()].every(key=>key==='state'||key==='code');
      if (!state || !code || !allowed) {
        return json({ok:false,error:'Authentication failed'},400);
      }
      try {
        const result = await oidc.callback({state,code,request});
        // Do not redirect to any URL provided by the user or in the callback.
        // 303 removes the OAuth code and state from the address bar.
        return redirect(publicOrigin+'/auth/connected',303,[result.setCookie,result.clearFlowCookie]);
      } catch {
        // Never echo codes, state, token claims, UserId, session or stack traces.
        return json({ok:false,error:'Authentication failed'},400);
      }
    }
    if (url.pathname === '/auth/session' && request.method === 'GET') {
      if (url.search) return json({ok:false,error:'Invalid request'},400);
      try {
        const principal = await oidc.resolveVerifiedPrincipal(request);
        if (!principal || principal.verified !== true || principal.method !== 'roblox_oidc') {
          return json({ok:false,authenticated:false},401);
        }
        // Browser-only, same-origin response; no OAuth tokens or privileged details.
        return json({ok:true,authenticated:true,identityVerified:true,sub:principal.sub});
      } catch {
        return json({ok:false,error:'Session unavailable'},503);
      }
    }
    if (url.pathname === '/auth/logout' && request.method === 'POST') {
      if (url.search || !sameOriginPost(request, publicOrigin)) {
        return json({ok:false,error:'Forbidden'},403);
      }
      try {
        const result=await oidc.logout(request);
        return json({ok:true,authenticated:false},200,{'Set-Cookie':result.clearCookie});
      } catch {
        return json({ok:false,error:'Logout unavailable'},503);
      }
    }
    if (url.pathname === '/auth/connected' && request.method === 'GET') {
      return plain('Roblox account connected to this browser session. You may close this tab.');
    }
    const path = url.pathname;
    if (['/auth/start','/oauth/callback','/auth/session','/auth/logout','/auth/connected'].includes(path)) {
      return json({ok:false,error:'Method Not Allowed'},405,{'Allow': path==='/auth/logout'?'POST':'GET'});
    }
    return json({ok:false,error:'Not Found'},404);
  };
}
