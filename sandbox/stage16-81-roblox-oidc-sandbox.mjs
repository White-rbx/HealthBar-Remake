/**
 * Stage 16.81: Roblox OIDC sandbox integration (NOT mounted / NOT deployed).
 * Only use after registering a Roblox OAuth app through Roblox's official
 * eligibility process. Do not put Roblox secrets, session cookies, or
 * access/refresh tokens in Luau, browser JS, URLs, logs, or GitHub.
 *
 * This module consumes a trusted Roblox-issued ID token, validates ES256,
 * then issues an opaque, browser-bound session for Stage 16.80.
 * It deliberately has no active routing, credentials, or Cloudflare writes.
 */
export const OIDC = Object.freeze({
  issuer: 'https://apis.roblox.com/oauth/',
  authorize: 'https://apis.roblox.com/oauth/v1/authorize',
  token: 'https://apis.roblox.com/oauth/v1/token',
  jwks: 'https://apis.roblox.com/oauth/v1/certs',
  scope: 'openid',
});
const FLOW_COOKIE = '__Host-asc_oidc_flow';
const SESSION_COOKIE = '__Host-asc_oidc_session';
const FLOW_SECONDS = 300;
const SESSION_SECONDS = 900;
const SUB_RE = /^[1-9][0-9]{0,19}$/;
const CLIENT_ID_RE = /^[1-9][0-9]{4,30}$/;
const SAFE_TOKEN_RE = /^[A-Za-z0-9_-]{32,256}$/;
const safeSeconds = milliseconds => Math.floor(milliseconds / 1000);

function bytesToB64url(bytes) {
  let bin = '';
  for (const value of bytes) bin += String.fromCharCode(value);
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
}
function fromB64url(encoded) {
  if (typeof encoded !== 'string' || encoded.length < 1 || !/^[A-Za-z0-9_-]+$/.test(encoded)) {
    throw new Error('Invalid identity token');
  }
  const base64 = encoded.replace(/-/g, '+').replace(/_/g, '/');
  const binary = atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '='));
  return Uint8Array.from(binary, char => char.charCodeAt(0));
}
function randomString(webcrypto) {
  const bytes = new Uint8Array(32);
  webcrypto.getRandomValues(bytes);
  return bytesToB64url(bytes);
}
async function sha256Base64url(text, webcrypto) {
  const hash = await webcrypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
  return bytesToB64url(new Uint8Array(hash));
}
function safeConfig(clientId, redirectUri) {
  if (typeof clientId !== 'string' || !CLIENT_ID_RE.test(clientId)) throw new TypeError('OAuth client ID is missing/invalid');
  if (typeof redirectUri !== 'string') throw new TypeError('Exact HTTPS callback URI required');
  const url = new URL(redirectUri);
  if (url.protocol !== 'https:' || url.username || url.password || url.hash || url.search || url.toString() !== redirectUri) {
    throw new TypeError('Exact HTTPS callback URI required');
  }
}
function secureCookie(name, value, age) {
  return name + '=' + value + '; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=' + age;
}
function readUniqueCookie(request, name) {
  const header = request?.headers?.get('cookie');
  if (typeof header !== 'string' || header.length > 4096) return null;
  const matches = header.split(';').map(x => x.trim()).filter(x => x.startsWith(name + '='));
  if (matches.length !== 1) return null;
  const value = matches[0].slice(name.length + 1);
  return SAFE_TOKEN_RE.test(value) ? value : null;
}
function checkEqual(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string') return false;
  const ab = new TextEncoder().encode(a);
  const bb = new TextEncoder().encode(b);
  let wrong = ab.length ^ bb.length;
  for (let i = 0; i < Math.max(ab.length, bb.length); i++) wrong |= (ab[i] || 0) ^ (bb[i] || 0);
  return wrong === 0;
}

/**
 * Server-side ES256 ID-token verification. jwks MUST be fetched exclusively
 * from the pinned Roblox URL by trusted Worker code, with a reasonable cache.
 * Never trust a JWKS URI taken from the token's header or untrusted input.
 */
export async function verifyRobloxIdToken({
  idToken, clientId, expectedNonce, jwks,
  clock = () => Date.now(), webcrypto = crypto,
} = {}) {
  safeConfig(clientId, 'https://sandbox.invalid/oauth/callback');
  if (typeof expectedNonce !== 'string' || !SAFE_TOKEN_RE.test(expectedNonce)) throw new Error('Invalid identity token');
  if (typeof idToken !== 'string' || idToken.length > 12000) throw new Error('Invalid identity token');
  const parts = idToken.split('.');
  if (parts.length !== 3 || parts.some(x => !x)) throw new Error('Invalid identity token');
  let header, payload, signature;
  try {
    header = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(fromB64url(parts[0])));
    payload = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(fromB64url(parts[1])));
    signature = fromB64url(parts[2]);
  } catch { throw new Error('Invalid identity token'); }
  if (header?.alg !== 'ES256' || typeof header.kid !== 'string' ||
      header.kid.length > 256 || !header.kid || signature.length !== 64) throw new Error('Invalid identity token');
  const keys = jwks?.keys;
  if (!Array.isArray(keys) || keys.length > 64) throw new Error('Identity keys unavailable');
  const matching = keys.filter(key =>
    key && key.kid === header.kid && key.kty === 'EC' && key.crv === 'P-256' &&
    (!key.alg || key.alg === 'ES256') && (!key.use || key.use === 'sig') &&
    (!key.key_ops || (Array.isArray(key.key_ops) && key.key_ops.includes('verify')))
  );
  if (matching.length !== 1) throw new Error('Invalid identity token');
  let signatureValid = false;
  try {
    const publicKey = await webcrypto.subtle.importKey('jwk', matching[0], { name: 'ECDSA', namedCurve: 'P-256' }, false, ['verify']);
    signatureValid = await webcrypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' },
      publicKey, signature, new TextEncoder().encode(parts[0] + '.' + parts[1]));
  } catch { throw new Error('Invalid identity token'); }
  if (!signatureValid) throw new Error('Invalid identity token');
  const now = safeSeconds(clock());
  const aud = payload?.aud;
  const audienceOk = typeof aud === 'string'
    ? aud === clientId
    : Array.isArray(aud) && aud.includes(clientId) && aud.every(a => typeof a === 'string')
      && payload.azp === clientId;
  if (!audienceOk || payload?.iss !== OIDC.issuer || typeof payload.sub !== 'string' || !SUB_RE.test(payload.sub) ||
      payload.nonce !== expectedNonce || !Number.isSafeInteger(payload.exp) || !Number.isSafeInteger(payload.iat) ||
      payload.exp <= now - 60 || payload.iat > now + 60 || payload.iat > payload.exp ||
      (payload.nbf !== undefined && (!Number.isSafeInteger(payload.nbf) || payload.nbf > now + 60))) {
    throw new Error('Invalid identity token');
  }
  return Object.freeze({ sub: payload.sub, method: 'roblox_oidc', verified: true });
}

/**
 * These are sandbox adapter contracts, not secure storage implementations:
 * pendingStore.put(key, data), pendingStore.take(key) [ATOMIC one-time delete]
 * sessionStore.put(key, data), sessionStore.get(key).
 * Neither store may trust user-provided identity fields.
 */
export function createOidcSandbox({
  clientId, redirectUri, pendingStore, sessionStore, exchangeCode, getRobloxJwks,
  clock = () => Date.now(), webcrypto = crypto,
} = {}) {
  safeConfig(clientId, redirectUri);
  if (typeof pendingStore?.put !== 'function' || typeof pendingStore?.take !== 'function' ||
      typeof sessionStore?.put !== 'function' || typeof sessionStore?.get !== 'function' ||
      typeof sessionStore?.delete !== 'function' ||
      typeof exchangeCode !== 'function' || typeof getRobloxJwks !== 'function') {
    throw new TypeError('Server-side OAuth stores and trusted adapters required');
  }
  return Object.freeze({
    async start() {
      const state = randomString(webcrypto);
      const nonce = randomString(webcrypto);
      const verifier = randomString(webcrypto);
      const flowCookieToken = randomString(webcrypto);
      const challenge = await sha256Base64url(verifier, webcrypto);
      const now = safeSeconds(clock());
      const cookieHash = await sha256Base64url(flowCookieToken, webcrypto);
      await pendingStore.put(state, {
        nonce, codeVerifier: verifier, cookieHash, clientId, redirectUri, expiresAt: now + FLOW_SECONDS,
      });
      const url = new URL(OIDC.authorize);
      const params = { client_id: clientId, redirect_uri: redirectUri, scope: OIDC.scope, response_type: 'code',
        state, nonce, code_challenge: challenge, code_challenge_method: 'S256' };
      for (const [k,v] of Object.entries(params)) url.searchParams.set(k,v);
      return { authorizationUrl: url.toString(), setCookie: secureCookie(FLOW_COOKIE, flowCookieToken, FLOW_SECONDS) };
    },
    async callback({ state, code, request }) {
      if (typeof state !== 'string' || !SAFE_TOKEN_RE.test(state)) throw new Error('OAuth state invalid');
      // The adapter must atomically consume state; replay must always fail.
      const pending = await pendingStore.take(state);
      const now = safeSeconds(clock());
      if (!pending || !Number.isSafeInteger(pending.expiresAt) || pending.expiresAt <= now ||
          pending.clientId !== clientId || pending.redirectUri !== redirectUri) throw new Error('OAuth transaction invalid');
      const flowCookie = readUniqueCookie(request, FLOW_COOKIE);
      const cookieHash = flowCookie ? await sha256Base64url(flowCookie, webcrypto) : null;
      if (!checkEqual(cookieHash, pending.cookieHash)) throw new Error('OAuth transaction invalid');
      if (typeof code !== 'string' || !code || code.length > 8192) throw new Error('OAuth code invalid');
      const tokenResult = await exchangeCode({ tokenEndpoint: OIDC.token, clientId, redirectUri,
        code, codeVerifier: pending.codeVerifier });
      // No access/refresh token needs to be persisted for identity-only sessions.
      const verified = await verifyRobloxIdToken({
        idToken: tokenResult?.id_token, clientId, expectedNonce: pending.nonce,
        jwks: await getRobloxJwks(OIDC.jwks), clock, webcrypto,
      });
      const sessionToken = randomString(webcrypto);
      const sessionKey = await sha256Base64url(sessionToken, webcrypto);
      const expiresAt = now + SESSION_SECONDS;
      await sessionStore.put(sessionKey, { sub: verified.sub, verified: true, method: 'roblox_oidc', expiresAt });
      return {
        sub: verified.sub,
        setCookie: secureCookie(SESSION_COOKIE, sessionToken, SESSION_SECONDS),
        clearFlowCookie: secureCookie(FLOW_COOKIE, '', 0),
      };
    },
    async resolveVerifiedPrincipal(request) {
      const sessionCookie = readUniqueCookie(request, SESSION_COOKIE);
      if (!sessionCookie) return null;
      const key = await sha256Base64url(sessionCookie, webcrypto);
      const session = await sessionStore.get(key);
      const now = safeSeconds(clock());
      if (!session || session.verified !== true || session.method !== 'roblox_oidc' ||
          typeof session.sub !== 'string' || !SUB_RE.test(session.sub) ||
          !Number.isSafeInteger(session.expiresAt) || session.expiresAt <= now) return null;
      return { verified: true, method: 'roblox_oidc', sub: session.sub, expiresAt: session.expiresAt };
    },
    async logout(request) {
      // Clearing the browser cookie alone is not session revocation.
      const sessionCookie = readUniqueCookie(request, SESSION_COOKIE);
      if (sessionCookie) {
        const sessionKey = await sha256Base64url(sessionCookie, webcrypto);
        await sessionStore.delete(sessionKey);
      }
      return { clearCookie: secureCookie(SESSION_COOKIE, '', 0) };
    },
  });
}
