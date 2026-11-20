-- Apply to isolated synthetic QA D1 after the verified-violation migrations.
CREATE TABLE IF NOT EXISTS asc_banned_token_references (
  notice_id TEXT NOT NULL REFERENCES asc_verified_violation_subjects(notice_id) ON DELETE CASCADE,
  subject_user_id TEXT NOT NULL,
  token_hash TEXT NOT NULL CHECK(length(token_hash)=64 AND token_hash NOT GLOB '*[^0-9a-f]*'),
  reference_suffix TEXT NOT NULL CHECK(length(reference_suffix)=2 AND reference_suffix NOT GLOB '*[^0-9A-F]*'),
  ban_revision TEXT,
  PRIMARY KEY (notice_id, subject_user_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_asc_banned_token_revision
  ON asc_banned_token_references(subject_user_id, ban_revision) WHERE ban_revision IS NOT NULL;
