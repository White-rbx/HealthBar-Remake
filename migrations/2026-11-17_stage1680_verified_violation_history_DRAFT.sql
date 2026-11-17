-- Stage 16.80 — DRAFT / OFFLINE ONLY. Do NOT run against Production or Staging yet.
-- Account-bound violations must be linked by a trusted server-side identity process.
-- Do not populate this table from client-supplied claimedUserId or an unverified Lua flag.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS asc_verified_violation_subjects (
  notice_id TEXT PRIMARY KEY NOT NULL,
  subject_user_id TEXT NOT NULL,
  identity_method TEXT NOT NULL CHECK (identity_method IN ('roblox_oidc', 'trusted_game_server')),
  appeal_status TEXT NOT NULL DEFAULT 'not_appealed'
    CHECK (appeal_status IN ('not_appealed', 'reviewing', 'denied', 'approved')),
  may_reappeal INTEGER NOT NULL DEFAULT 0 CHECK (may_reappeal IN (0, 1)),
  linked_unix INTEGER NOT NULL CHECK (linked_unix > 0),
  updated_unix INTEGER NOT NULL CHECK (updated_unix > 0),
  FOREIGN KEY (notice_id) REFERENCES asc_violation_notices(id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_asc_vvs_subject ON asc_verified_violation_subjects(subject_user_id, updated_unix DESC);

CREATE TABLE IF NOT EXISTS asc_verified_violation_history (
  event_id INTEGER PRIMARY KEY AUTOINCREMENT,
  notice_id TEXT NOT NULL,
  event_status TEXT NOT NULL CHECK (event_status IN ('not_appealed', 'reviewing', 'denied', 'approved')),
  event_type TEXT NOT NULL,
  public_note TEXT NOT NULL DEFAULT '',
  created_unix INTEGER NOT NULL CHECK (created_unix > 0),
  FOREIGN KEY (notice_id) REFERENCES asc_verified_violation_subjects(notice_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_asc_vvh_notice_time ON asc_verified_violation_history(notice_id, created_unix DESC, event_id DESC);
