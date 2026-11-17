/**
 * ArcScriptCenter Stage 16.85 — D1-backed distributed pairing limiter (OFFLINE DRAFT).
 *
 * Every Worker instance must share the SAME ISOLATED SANDBOX D1 binding and secret.
 * Never deploy with production DB, API tokens or an in-memory "rate limiter".
 * Network identifiers are derived from TRUSTED Cloudflare edge metadata by a
 * separately audited adapter; never X-Forwarded-For, JSON or a client-supplied ID.
 * Raw IP / browser cookies / Roblox UserId / tokens never enter database columns.
 */
const ACTIONS = Object.freeze({
  start:   Object.freeze({ perNetwork: 4,  global: 150 }),
  poll:    Object.freeze({ perNetwork: 45, global: 3000 }),
  cancel:  Object.freeze({ perNetwork: 8,  global: 400 }),
  preview: Object.freeze({ perNetwork: 8,  global: 350 }),
  approve: Object.freeze({ perNetwork: 6,  global: 300 }),
});
const PERIOD = 60;                  // fixed one-minute bucket
const RETAIN = 600;                 // delete completed buckets after 10 minutes
const HMAC_BIT_LENGTH = 256;
const KEY_RE = /^[A-Za-z0-9_-]{43}$/;

const SQL = Object.freeze({
  consume: [
    'INSERT INTO asc_pairing_rate_windows (scope_hash, window_start, hits, expires_unix)',
    'VALUES (?1, ?2, 1, ?3)',
    'ON CONFLICT(scope_hash, window_start) DO UPDATE SET hits = hits + 1',
    'WHERE hits < ?4',
    'RETURNING hits',
  ].join(' '),
  prune: 'DELETE FROM asc_pairing_rate_windows WHERE expires_unix <= ?1',
});
export const stage1685RateLimitContract = Object.freeze({ SQL, ACTIONS, PERIOD, RETAIN });

function b64url(bytes) {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
}
async function importSecret(webcrypto, secret) {
  if (typeof secret !== 'string' || secret.length < 32 || secret.length > 4096) {
    throw new TypeError('Private 32+ byte Worker rate-limit secret is required');
  }
  return webcrypto.subtle.importKey('raw',new TextEncoder().encode(secret),
    {name:'HMAC',hash:'SHA-256'},false,['sign']);
}
async function hashScope(webcrypto,key,value) {
  const signature = new Uint8Array(await webcrypto.subtle.sign('HMAC',key,
    new TextEncoder().encode('ArcScriptCenter:Stage1685:' + value)));
  return b64url(signature);
}
/**
 * Inject getTrustedNetworkId(request) *server side*, based solely on Cloudflare
 * edge-authoritative metadata; fail closed for missing or unverifiable identity.
 * Do not accept X-Forwarded-For, client body, UserId or a custom arbitrary header.
 * Reuse one limiter across all pairing actions; caller MUST pass the exact action.
 */
export function createD1PairingRateLimiter({
  db, secret, getTrustedNetworkId, clock = () => Date.now(), webcrypto = crypto,
} = {}) {
  if (!db?.prepare || typeof getTrustedNetworkId !== 'function') {
    throw new TypeError('Isolated D1 and trusted network identity adapter required');
  }
  // Promise resolves to CryptoKey; initialization failure rejects each request.
  const signingKey = importSecret(webcrypto, secret);
  async function consume(scope, windowStart, limit, key) {
    const hash = await hashScope(webcrypto,key,scope);
    if (!KEY_RE.test(hash)) throw new Error('Invalid rate limiter key');
    const result = await db.prepare(SQL.consume).bind(
      hash, windowStart, windowStart + RETAIN, limit,
    ).run();
    // D1 must return exactly one row. Any unknown response fails closed.
    return result?.success === true &&
      Array.isArray(result.results) && result.results.length === 1 &&
      Number.isInteger(result.results[0]?.hits) &&
      result.results[0].hits >= 1 && result.results[0].hits <= limit;
  }
  return Object.freeze({
    async checkRateLimit({action,request}={}) {
      if (typeof action !== 'string' || !Object.hasOwn(ACTIONS,action)) {
        throw new Error('Unsupported pairing action');
      }
      const network = await getTrustedNetworkId(request);
      if (typeof network !== 'string' || network.length < 3 || network.length > 128 ||
          /\s/.test(network)) {
        throw new Error('Trusted client network ID unavailable');
      }
      const now = Math.floor(clock()/1000);
      if (!Number.isSafeInteger(now) || now <= 0) throw new Error('Invalid server time');
      const windowStart = Math.floor(now/PERIOD)*PERIOD;
      const key = await signingKey;
      const quota = ACTIONS[action];
      // Consume per-network FIRST; a single abusive network cannot drain global
      // quota above its own limit. Both steps use SQLite atomic upsert.
      const networkAccepted = await consume('network:' + action + ':' + network,
        windowStart, quota.perNetwork, key);
      if (!networkAccepted) return false;
      return consume('global:' + action, windowStart, quota.global, key);
    },
    async pruneExpired() {
      const now = Math.floor(clock()/1000);
      if (!Number.isSafeInteger(now) || now <= 0) throw new Error('Invalid server time');
      return db.prepare(SQL.prune).bind(now).run();
    },
  });
}
