-- Universal synthetic QA only. Existing Violation records and v1 references stay intact.
CREATE TABLE IF NOT EXISTS asc_banned_tokens_v2 (
  notice_id TEXT NOT NULL REFERENCES asc_verified_violation_subjects(notice_id) ON DELETE CASCADE,
  subject_user_id TEXT NOT NULL,
  username_snapshot TEXT NOT NULL,
  ban_revision TEXT,
  expires_unix INTEGER NOT NULL,
  token_hash TEXT NOT NULL CHECK(length(token_hash)=64),
  secret_hash TEXT NOT NULL CHECK(length(secret_hash)=64),
  sealed_token TEXT NOT NULL,
  PRIMARY KEY (notice_id, subject_user_id)
);
