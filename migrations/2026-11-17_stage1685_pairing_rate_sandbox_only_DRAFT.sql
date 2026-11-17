-- Stage 16.85. SANDBOX-ONLY DRAFT: NO production or existing STAGING D1.
-- Apply ONLY to isolated asc-stage1684-identity-sandbox-20261117 after reviewing scope.
-- Stores HMAC pseudonyms, NOT IP addresses, Roblox UserIds, cookies or credentials.
-- The separate Worker secret is required; do not include the HMAC key in GitHub.
CREATE TABLE IF NOT EXISTS asc_pairing_rate_windows (
  scope_hash TEXT NOT NULL CHECK(length(scope_hash)=43),
  window_start INTEGER NOT NULL CHECK(window_start>0),
  hits INTEGER NOT NULL CHECK(hits>=1),
  expires_unix INTEGER NOT NULL CHECK(expires_unix>window_start),
  PRIMARY KEY(scope_hash, window_start)
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS idx_asc_pairing_rate_expires
  ON asc_pairing_rate_windows(expires_unix);
