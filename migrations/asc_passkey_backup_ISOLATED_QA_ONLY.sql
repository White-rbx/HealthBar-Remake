-- STAGING ONLY: fresh user-verified assertion before adding a second passkey.
-- This does NOT modify existing user, recovery, case, ban, or session tables.
CREATE TABLE IF NOT EXISTS asc_account_passkey_backup_flows (
 flow_hash TEXT PRIMARY KEY NOT NULL CHECK(length(flow_hash)=64),
 account_id TEXT NOT NULL REFERENCES asc_accounts(id),
 session_id TEXT NOT NULL REFERENCES asc_account_sessions(id),
 challenge TEXT NOT NULL,
 step TEXT NOT NULL CHECK(step IN ('reauth','enroll')),
 created_at INTEGER NOT NULL,
 expires_at INTEGER NOT NULL CHECK(expires_at>created_at)
);
CREATE INDEX IF NOT EXISTS asc_account_passkey_backup_expiry
 ON asc_account_passkey_backup_flows(expires_at);
