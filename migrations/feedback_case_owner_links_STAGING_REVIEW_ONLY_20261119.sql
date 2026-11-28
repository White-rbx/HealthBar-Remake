-- ArcScriptCenter: STAGING REVIEW ONLY; do not execute in canonical or Production D1.
-- No automatic migration of claimed_user_id: it is unverified metadata.
-- The owner is the independently authenticated Roblox OIDC subject.
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS asc_feedback_case_owners (
  case_id TEXT PRIMARY KEY REFERENCES asc_feedback_cases(id) ON DELETE CASCADE,
  owner_sub TEXT NOT NULL CHECK (LENGTH(owner_sub) BETWEEN 1 AND 128),
  linked_unix INTEGER NOT NULL,
  proof_type TEXT NOT NULL CHECK (proof_type='verified_session_and_receipt')
);
CREATE INDEX IF NOT EXISTS idx_asc_feedback_case_owners_subject
  ON asc_feedback_case_owners(owner_sub,case_id);
