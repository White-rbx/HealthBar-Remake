-- Stage 16.83 DRAFT. OFFLINE ONLY.
-- Only for a separate D1 sandbox; NEVER apply to production/staging.
-- No OAuth token, Roblox password or browser cookie stored here.
-- Do not use pairing as proof of a Roblox Player identity in an untrusted Luau client.
CREATE TABLE IF NOT EXISTS asc_pairing_sandbox (
  code_hash TEXT PRIMARY KEY NOT NULL CHECK(length(code_hash)=43),
  device_hash TEXT NOT NULL UNIQUE CHECK(length(device_hash)=43),
  state TEXT NOT NULL DEFAULT 'pending' CHECK(state IN ('pending','approved')),
  expires_unix INTEGER NOT NULL CHECK(expires_unix > 0),
  preview_subject TEXT DEFAULT NULL CHECK(preview_subject IS NULL OR length(preview_subject) BETWEEN 1 AND 20),
  confirmation_hash TEXT DEFAULT NULL CHECK(confirmation_hash IS NULL OR length(confirmation_hash)=43),
  confirmation_expires_unix INTEGER DEFAULT NULL
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS idx_asc_pairing_sandbox_expires ON asc_pairing_sandbox(expires_unix);
CREATE INDEX IF NOT EXISTS idx_asc_pairing_sandbox_device ON asc_pairing_sandbox(device_hash);
