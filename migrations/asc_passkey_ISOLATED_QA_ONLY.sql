-- STAGING ONLY: independent passkey credential and one-time challenge tables.
-- Additive: the existing account, case, moderation and legacy tables remain untouched.
-- Do not apply this to production or before validating a QA D1 snapshot.
CREATE TABLE IF NOT EXISTS asc_account_passkeys (
 credential_id TEXT PRIMARY KEY NOT NULL,
 account_id TEXT NOT NULL REFERENCES asc_accounts(id),
 public_key_b64url TEXT NOT NULL,
 counter INTEGER NOT NULL DEFAULT 0 CHECK(counter>=0),
 transports_json TEXT NOT NULL DEFAULT '[]',
 created_at INTEGER NOT NULL,
 last_used_at INTEGER
);
CREATE INDEX IF NOT EXISTS asc_account_passkeys_owner ON asc_account_passkeys(account_id);
CREATE TABLE IF NOT EXISTS asc_account_passkey_flows (
 flow_hash TEXT PRIMARY KEY NOT NULL CHECK(length(flow_hash)=64),
 challenge TEXT NOT NULL,
 purpose TEXT NOT NULL CHECK(purpose IN ('register','login')),
 username TEXT,
 proposed_account_id TEXT,
 created_at INTEGER NOT NULL,
 expires_at INTEGER NOT NULL CHECK(expires_at>created_at),
 CHECK((purpose='register' AND username IS NOT NULL AND proposed_account_id IS NOT NULL)
    OR (purpose='login' AND username IS NULL AND proposed_account_id IS NULL))
);
CREATE INDEX IF NOT EXISTS asc_account_passkey_flows_expiry ON asc_account_passkey_flows(expires_at);
