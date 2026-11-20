-- Review for STAGING only. Audit is additive. QA source is provisioned separately.
CREATE TABLE IF NOT EXISTS asc_ban_v2_audit (
 request_id TEXT PRIMARY KEY,
 action TEXT NOT NULL CHECK(action IN ('upsert','remove')),
 target_user_id TEXT NOT NULL,
 old_sha TEXT NOT NULL,
 new_sha TEXT NOT NULL,
 created_unix INTEGER NOT NULL,
 outcome TEXT NOT NULL CHECK(outcome IN ('pending','saved','conflict','rejected','unconfirmed')),
 commit_sha TEXT
);
CREATE INDEX IF NOT EXISTS idx_asc_ban_v2_audit_created ON asc_ban_v2_audit(created_unix DESC);

-- Requires asc_verified_violation_subjects/history from the verified notice migration.
CREATE TABLE IF NOT EXISTS asc_ban_v2_verified_appeals (
 case_id TEXT PRIMARY KEY REFERENCES asc_feedback_cases(id) ON DELETE CASCADE,
 notice_id TEXT NOT NULL REFERENCES asc_verified_violation_subjects(notice_id) ON DELETE RESTRICT,
 created_unix INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_asc_ban_v2_appeal_notice ON asc_ban_v2_verified_appeals(notice_id,created_unix);
CREATE TRIGGER IF NOT EXISTS asc_ban_v2_appeal_created AFTER INSERT ON asc_ban_v2_verified_appeals
BEGIN
 UPDATE asc_verified_violation_subjects SET appeal_status='reviewing',may_reappeal=0,updated_unix=NEW.created_unix
 WHERE notice_id=NEW.notice_id;
 INSERT INTO asc_verified_violation_history(notice_id,event_status,event_type,created_unix)
 VALUES(NEW.notice_id,'reviewing','appeal_submitted',NEW.created_unix);
END;
CREATE TRIGGER IF NOT EXISTS asc_ban_v2_appeal_reviewed AFTER UPDATE OF status ON asc_feedback_cases
WHEN NEW.status IN ('approved','denied') AND OLD.status<>NEW.status
BEGIN
 UPDATE asc_verified_violation_subjects SET appeal_status=NEW.status,may_reappeal=0,updated_unix=NEW.updated_unix
 WHERE appeal_status<>'approved' AND notice_id IN (
  SELECT notice_id FROM asc_ban_v2_verified_appeals WHERE case_id=NEW.id
 ) AND NOT EXISTS (
  SELECT 1 FROM asc_ban_v2_verified_appeals older JOIN asc_ban_v2_verified_appeals newer
   ON newer.notice_id=older.notice_id
  WHERE older.case_id=NEW.id AND newer.rowid>older.rowid
 );
 INSERT INTO asc_verified_violation_history(notice_id,event_status,event_type,public_note,created_unix)
 SELECT link.notice_id,NEW.status,'appeal_reviewed',NEW.public_note,NEW.updated_unix
 FROM asc_ban_v2_verified_appeals link JOIN asc_verified_violation_subjects v ON v.notice_id=link.notice_id
 WHERE link.case_id=NEW.id AND v.appeal_status=NEW.status AND v.updated_unix=NEW.updated_unix;
END;
