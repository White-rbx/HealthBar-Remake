/**
 * Stage 16.82 — isolated D1 adapter for Stage 16.81 OAuth pending state and sessions.
 * Sandbox only: NO migration/Worker deployed; NO Roblox app credentials.
 * OAuth state consumption uses one atomic DELETE ... RETURNING statement.
 * Never derive identity from a client-supplied Roblox UserId.
 */
const KEY_RE = /^[A-Za-z0-9_-]{43}$/;
const USER_RE = /^[1-9][0-9]{0,19}$/;
const CLIENT_RE = /^[1-9][0-9]{4,30}$/;

export const STAGE1682_SQL = Object.freeze({
  pendingPut: [
    'INSERT INTO asc_oidc_pending',
    '(state_key, nonce, code_verifier, flow_cookie_hash, client_id, redirect_uri, expires_unix)',
    'VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)',
  ].join(' '),
  pendingTake: [
    'DELETE FROM asc_oidc_pending WHERE state_key = ?1',
    'RETURNING nonce, code_verifier AS codeVerifier, flow_cookie_hash AS cookieHash,',
    'client_id AS clientId, redirect_uri AS redirectUri, expires_unix AS expiresAt',
  ].join(' '),
  sessionPut: [
    'INSERT INTO asc_oidc_sessions',
    '(session_hash, subject_user_id, identity_method, created_unix, expires_unix)',
    "VALUES (?1, ?2, 'roblox_oidc', ?3, ?4)",
  ].join(' '),
  sessionGet: [
    'SELECT subject_user_id AS sub, identity_method AS method, expires_unix AS expiresAt',
    'FROM asc_oidc_sessions WHERE session_hash = ?1 AND expires_unix > ?2 LIMIT 1',
  ].join(' '),
  sessionDelete: 'DELETE FROM asc_oidc_sessions WHERE session_hash = ?1',
  prunePending: 'DELETE FROM asc_oidc_pending WHERE expires_unix <= ?1',
  pruneSessions: 'DELETE FROM asc_oidc_sessions WHERE expires_unix <= ?1',
});

function expectKey(value, name) {
  if (typeof value !== 'string' || !KEY_RE.test(value)) {
    throw new TypeError(name + ' must be a random 256-bit base64url key');
  }
}
function expectExpiry(expiresAt, now, maxAge, name) {
  if (!Number.isSafeInteger(expiresAt) || expiresAt <= now || expiresAt > now + maxAge) {
    throw new TypeError('Invalid ' + name + ' expiry');
  }
}
function requireD1(db) {
  if (!db || typeof db.prepare !== 'function') throw new TypeError('D1 database binding required');
}
function validRedirect(value) {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && !url.username && !url.password &&
      !url.hash && !url.search && url.toString() === value;
  } catch { return false; }
}
function firstResult(result) { return result?.results?.[0] ?? null; }

/** Store random OAuth state. No read-only peek: take() consumes atomically. */
export function createD1PendingStore(db, { clock = () => Date.now() } = {}) {
  requireD1(db);
  return Object.freeze({
    async put(state, record) {
      const now = Math.floor(clock() / 1000);
      expectKey(state, 'state');
      expectKey(record?.nonce, 'nonce');
      expectKey(record?.codeVerifier, 'codeVerifier');
      expectKey(record?.cookieHash, 'cookieHash');
      if (!CLIENT_RE.test(record?.clientId) || !validRedirect(record?.redirectUri)) {
        throw new TypeError('Invalid OAuth client configuration');
      }
      expectExpiry(record.expiresAt, now, 300, 'pending');
      await db.prepare(STAGE1682_SQL.pendingPut).bind(
        state, record.nonce, record.codeVerifier, record.cookieHash,
        record.clientId, record.redirectUri, record.expiresAt,
      ).run();
    },
    async take(state) {
      if (typeof state !== 'string' || !KEY_RE.test(state)) return null;
      const result = await db.prepare(STAGE1682_SQL.pendingTake).bind(state).run();
      const row = firstResult(result);
      return row && {
        nonce: row.nonce, codeVerifier: row.codeVerifier, cookieHash: row.cookieHash,
        clientId: row.clientId, redirectUri: row.redirectUri, expiresAt: Number(row.expiresAt),
      };
    },
    async pruneExpired() {
      return db.prepare(STAGE1682_SQL.prunePending).bind(Math.floor(clock() / 1000)).run();
    },
  });
}

/** Store only a hash of the cookie. Server-side DELETE revokes a browser session. */
export function createD1SessionStore(db, { clock = () => Date.now() } = {}) {
  requireD1(db);
  return Object.freeze({
    async put(sessionHash, principal) {
      const now = Math.floor(clock() / 1000);
      expectKey(sessionHash, 'sessionHash');
      if (principal?.verified !== true || principal?.method !== 'roblox_oidc' ||
          typeof principal?.sub !== 'string' || !USER_RE.test(principal.sub)) {
        throw new TypeError('Unverified Roblox principal');
      }
      expectExpiry(principal.expiresAt, now, 900, 'session');
      await db.prepare(STAGE1682_SQL.sessionPut).bind(
        sessionHash, principal.sub, now, principal.expiresAt,
      ).run();
    },
    async get(sessionHash) {
      if (typeof sessionHash !== 'string' || !KEY_RE.test(sessionHash)) return null;
      const now = Math.floor(clock() / 1000);
      const row = await db.prepare(STAGE1682_SQL.sessionGet).bind(sessionHash, now).first();
      if (!row || typeof row.sub !== 'string' || !USER_RE.test(row.sub) ||
          row.method !== 'roblox_oidc' ||
          !Number.isSafeInteger(Number(row.expiresAt)) || Number(row.expiresAt) <= now) return null;
      return { verified:true, method:'roblox_oidc', sub:row.sub, expiresAt:Number(row.expiresAt) };
    },
    async delete(sessionHash) {
      if (typeof sessionHash !== 'string' || !KEY_RE.test(sessionHash)) return;
      await db.prepare(STAGE1682_SQL.sessionDelete).bind(sessionHash).run();
    },
    async pruneExpired() {
      return db.prepare(STAGE1682_SQL.pruneSessions).bind(Math.floor(clock() / 1000)).run();
    },
  });
}
