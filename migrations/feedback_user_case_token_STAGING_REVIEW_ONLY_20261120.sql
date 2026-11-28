-- ArcScriptCenter — User Case Token, additive STAGING DDL. Production requires separate review.
-- User-consented, revocable bearer capability. Does not assert Roblox identity.
-- Do not derive token ownership from claimed_user_id, Username, HWID or IP.
-- Token plaintext is given to the client ONCE; D1 stores only SHA-256 hashes.
-- The case creator must prove private Case ID + Receipt to bind old/new Feedback.
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS asc_user_case_tokens (
 token_hash TEXT PRIMARY KEY NOT NULL
  CHECK (length(token_hash)=64 AND token_hash NOT GLOB '*[^0-9a-f]*'),
 created_unix INTEGER NOT NULL CHECK (created_unix>0),
 revoked_unix INTEGER DEFAULT NULL CHECK (revoked_unix IS NULL OR revoked_unix>=created_unix)
);
CREATE TABLE IF NOT EXISTS asc_user_case_links (
 case_id TEXT PRIMARY KEY NOT NULL REFERENCES asc_feedback_cases(id) ON DELETE CASCADE,
 token_hash TEXT NOT NULL REFERENCES asc_user_case_tokens(token_hash),
 linked_unix INTEGER NOT NULL CHECK(linked_unix>0)
);
CREATE INDEX IF NOT EXISTS idx_asc_user_case_links_hash
 ON asc_user_case_links(token_hash,case_id);
CREATE INDEX IF NOT EXISTS idx_asc_user_case_tokens_revoked
 ON asc_user_case_tokens(revoked_unix);
-- Do not delete revoked tokens or re-enable them. If a token was compromised,
-- a new token can be created using an independently held valid Case Receipt.
-- No inserts/selects using claimed_user_id are permitted.
