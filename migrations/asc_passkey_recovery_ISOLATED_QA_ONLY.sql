-- STAGING ONLY. Additive recovery infrastructure for Passkey-only accounts.
-- Never grant recovery from an unverified Roblox UserId, username alone or a client claim.
-- Codes are independent 128-bit secrets; store SHA-256 digests only.
CREATE TABLE IF NOT EXISTS asc_account_passkey_recovery_codes (
 account_id TEXT NOT NULL REFERENCES asc_accounts(id),
 code_digest TEXT NOT NULL CHECK(length(code_digest)=64),
 created_at INTEGER NOT NULL,
 PRIMARY KEY(account_id,code_digest)
);
CREATE TABLE IF NOT EXISTS asc_account_passkey_recovery_flows (
 flow_hash TEXT PRIMARY KEY NOT NULL CHECK(length(flow_hash)=64),
 account_id TEXT NOT NULL REFERENCES asc_accounts(id),
 challenge TEXT NOT NULL,
 recovery_digest TEXT NOT NULL CHECK(length(recovery_digest)=64),
 created_at INTEGER NOT NULL,
 expires_at INTEGER NOT NULL CHECK(expires_at>created_at)
);
CREATE INDEX IF NOT EXISTS asc_account_passkey_recovery_flows_expiry
 ON asc_account_passkey_recovery_flows(expires_at);
