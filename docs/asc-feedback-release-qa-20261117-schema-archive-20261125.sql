-- REVIEW_ONLY_ARCHIVED_SCHEMA_DO_NOT_DEPLOY

-- Old synthetic QA D1: asc-feedback-release-qa-20261117

-- Old D1 ID: fb828e2b-b10b-41ac-95bd-3873ff3cccd5

-- Captured 2026-11-25 (read-only). All seven app tables contained 0 rows.

-- Cloudflare-managed _cf_KV intentionally excluded; no personal rows exported.

-- This is a reconstruction aid, not a verified restorable full SQL dump.



CREATE TABLE "asc_feedback_cases" (
 id TEXT PRIMARY KEY,
 receipt_hash TEXT NOT NULL UNIQUE,
 kind TEXT NOT NULL CHECK(kind IN ('feedback','appeal')),
 claimed_user_id TEXT,
 topic TEXT NOT NULL CHECK(length(topic) BETWEEN 3 AND 50),
 description TEXT NOT NULL CHECK(
    (kind='feedback' AND length(description) BETWEEN 50 AND 1500)
    OR (kind='appeal' AND length(description) BETWEEN 50 AND 5000)
 ),
 status TEXT NOT NULL DEFAULT 'reviewing'
   CHECK(status IN ('reviewing','approved','denied','violation','spam_mail')),
 created_unix INTEGER NOT NULL, updated_unix INTEGER NOT NULL,
 revision INTEGER NOT NULL DEFAULT 0,
 public_note TEXT NOT NULL DEFAULT '',
 admin_note TEXT NOT NULL DEFAULT '',
 removed INTEGER NOT NULL DEFAULT 0
, followup INTEGER NOT NULL DEFAULT 0 CHECK(followup IN (0,1)), followup_updated_unix INTEGER NOT NULL DEFAULT 0, followup_note TEXT NOT NULL DEFAULT '' CHECK(length(followup_note)<=500), followup_due_unix INTEGER NOT NULL DEFAULT 0 CHECK(followup_due_unix>=0));

CREATE TABLE asc_feedback_followup_details_history (
event_id INTEGER PRIMARY KEY AUTOINCREMENT,
case_id TEXT NOT NULL,
event_type TEXT NOT NULL CHECK(event_type IN ('updated','cleared')),
created_unix INTEGER NOT NULL
);

CREATE TABLE asc_feedback_followup_history (
  event_id INTEGER PRIMARY KEY AUTOINCREMENT,
  case_id TEXT NOT NULL,
  enabled INTEGER NOT NULL CHECK(enabled IN (0,1)),
  created_unix INTEGER NOT NULL
);

CREATE TABLE asc_feedback_history(
event_id INTEGER PRIMARY KEY AUTOINCREMENT,
case_id TEXT NOT NULL,
event_type TEXT NOT NULL CHECK(event_type IN ('imported','submitted','edited','reviewed','removed')),
status TEXT NOT NULL CHECK(status IN ('reviewing','approved','denied','violation','spam_mail')),
revision INTEGER NOT NULL,
public_note TEXT NOT NULL DEFAULT '',
created_unix INTEGER NOT NULL
);

CREATE TABLE asc_feedback_quota(window_key TEXT PRIMARY KEY, count INTEGER NOT NULL DEFAULT 0);

CREATE TABLE asc_feedback_rate_windows (scope_hash TEXT NOT NULL CHECK(length(scope_hash)=43), window_start INTEGER NOT NULL, hits INTEGER NOT NULL CHECK(hits>=1), expires_unix INTEGER NOT NULL, PRIMARY KEY(scope_hash,window_start));

CREATE TABLE asc_violation_notices(id TEXT PRIMARY KEY,lookup_hash TEXT NOT NULL UNIQUE,claimed_user_id TEXT NOT NULL,reason TEXT NOT NULL,moderator_message TEXT NOT NULL,created_unix INTEGER NOT NULL,updated_unix INTEGER NOT NULL,status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','resolved')));

CREATE INDEX idx_asc_feedback_claim ON asc_feedback_cases(claimed_user_id,created_unix DESC);

CREATE INDEX idx_asc_feedback_followup ON asc_feedback_cases(status,followup,removed,created_unix DESC,id DESC);

CREATE INDEX idx_asc_feedback_followup_details_history_case ON asc_feedback_followup_details_history(case_id,event_id DESC);

CREATE INDEX idx_asc_feedback_followup_due ON asc_feedback_cases(status,removed,followup,followup_due_unix);

CREATE INDEX idx_asc_feedback_followup_history_case ON asc_feedback_followup_history(case_id,event_id DESC);

CREATE INDEX idx_asc_feedback_history_case ON asc_feedback_history(case_id,event_id DESC);

CREATE INDEX idx_asc_feedback_queue ON asc_feedback_cases(status,kind,removed,created_unix DESC,id DESC);

CREATE INDEX idx_asc_feedback_rate_expiry ON asc_feedback_rate_windows(expires_unix);

CREATE INDEX idx_asc_feedback_status ON asc_feedback_cases(status,created_unix DESC);

CREATE INDEX idx_asc_violation_user_status ON asc_violation_notices(claimed_user_id,status,created_unix DESC);

CREATE TRIGGER trg_asc_feedback_followup_changed
AFTER UPDATE OF followup ON asc_feedback_cases
WHEN NEW.followup != OLD.followup
BEGIN
  INSERT INTO asc_feedback_followup_history(case_id,enabled,created_unix)
  VALUES(NEW.id,NEW.followup,NEW.followup_updated_unix);
END;

CREATE TRIGGER trg_asc_feedback_followup_details_changed
AFTER UPDATE OF followup_note,followup_due_unix ON asc_feedback_cases
WHEN NEW.followup_note<>OLD.followup_note OR NEW.followup_due_unix<>OLD.followup_due_unix
BEGIN
 INSERT INTO asc_feedback_followup_details_history(case_id,event_type,created_unix)
 VALUES(NEW.id,CASE WHEN NEW.followup_note='' AND NEW.followup_due_unix=0 THEN 'cleared' ELSE 'updated' END,NEW.followup_updated_unix);
END;

CREATE TRIGGER trg_asc_feedback_history_change
AFTER UPDATE OF status,revision,public_note,removed ON asc_feedback_cases
WHEN NEW.status != OLD.status OR NEW.revision != OLD.revision
  OR NEW.public_note != OLD.public_note OR NEW.removed != OLD.removed
BEGIN
 INSERT INTO asc_feedback_history(case_id,event_type,status,revision,public_note,created_unix)
 VALUES(NEW.id,
   CASE WHEN NEW.removed=1 AND OLD.removed=0 THEN 'removed'
        WHEN NEW.status!=OLD.status OR NEW.public_note!=OLD.public_note THEN 'reviewed'
        ELSE 'edited' END,
   NEW.status,NEW.revision,
   CASE WHEN NEW.status='spam_mail' THEN '' WHEN NEW.status!=OLD.status OR NEW.public_note!=OLD.public_note THEN NEW.public_note ELSE '' END,
   NEW.updated_unix);
END;

CREATE TRIGGER trg_asc_feedback_history_create AFTER INSERT ON asc_feedback_cases
BEGIN
 INSERT INTO asc_feedback_history(case_id,event_type,status,revision,public_note,created_unix)
 VALUES(NEW.id,'submitted',NEW.status,NEW.revision,'',NEW.created_unix);
END;

