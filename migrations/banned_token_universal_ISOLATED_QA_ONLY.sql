-- Apply only after the isolated BANNEDTOKEN and verified violation migrations.
CREATE TABLE IF NOT EXISTS asc_violation_case_sessions (
  credential_hash TEXT PRIMARY KEY NOT NULL CHECK(length(credential_hash)=64),
  state TEXT NOT NULL CHECK(state IN ('enrollment','session')),
  notice_id TEXT NOT NULL REFERENCES asc_verified_violation_subjects(notice_id) ON DELETE CASCADE,
  subject_user_id TEXT NOT NULL,
  verified_username TEXT NOT NULL,
  expires_unix INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_asc_violation_sessions_expiry
  ON asc_violation_case_sessions(expires_unix);
