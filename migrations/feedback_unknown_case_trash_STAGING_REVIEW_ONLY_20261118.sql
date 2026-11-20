-- ArcScriptCenter STAGING Feedback Unknown Case Trash — additive, review only.
-- DO NOT apply to Production or live STAGING without authorized migration review.
-- A case becomes eligible for purge ONLY after explicit Admin move.
CREATE TABLE IF NOT EXISTS asc_feedback_unknown_trash (
  case_id TEXT PRIMARY KEY
    REFERENCES asc_feedback_cases(id) ON DELETE CASCADE,
  trashed_unix INTEGER NOT NULL CHECK (trashed_unix > 0),
  purge_unix INTEGER NOT NULL,
  CHECK (purge_unix - trashed_unix = 2592000)
);
CREATE INDEX IF NOT EXISTS idx_asc_feedback_unknown_trash_expiry
  ON asc_feedback_unknown_trash(purge_unix, case_id);
