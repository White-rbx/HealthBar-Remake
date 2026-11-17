-- Stage 16.82 DRAFT — OFFLINE SANDBOX TESTS ONLY.
-- Create a SEPARATE Sandbox D1 database before considering application.
-- NEVER apply to arcscriptcenter-db, arcscriptcenter-staging, or shared production data.
-- Do not store OAuth access tokens, ID tokens, refresh tokens or Roblox passwords.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS asc_oidc_pending (
  state_key TEXT PRIMARY KEY NOT NULL CHECK (length(state_key) = 43),
  nonce TEXT NOT NULL CHECK (length(nonce) = 43),
  code_verifier TEXT NOT NULL CHECK (length(code_verifier) = 43),
  flow_cookie_hash TEXT NOT NULL CHECK (length(flow_cookie_hash) = 43),
  client_id TEXT NOT NULL,
  redirect_uri TEXT NOT NULL,
  expires_unix INTEGER NOT NULL CHECK (expires_unix > 0)
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS idx_asc_oidc_pending_expires ON asc_oidc_pending(expires_unix);

CREATE TABLE IF NOT EXISTS asc_oidc_sessions (
  session_hash TEXT PRIMARY KEY NOT NULL CHECK (length(session_hash) = 43),
  subject_user_id TEXT NOT NULL CHECK (length(subject_user_id) BETWEEN 1 AND 20),
  identity_method TEXT NOT NULL CHECK (identity_method = 'roblox_oidc'),
  created_unix INTEGER NOT NULL CHECK (created_unix > 0),
  expires_unix INTEGER NOT NULL CHECK (expires_unix > created_unix)
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS idx_asc_oidc_sessions_expires ON asc_oidc_sessions(expires_unix);
