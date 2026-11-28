-- New isolated QA source. Do not run on the canonical STAGING or Production databases.
CREATE TABLE IF NOT EXISTS asc_ban_v2_qa_source (
 id INTEGER PRIMARY KEY CHECK(id=1),
 sha TEXT NOT NULL,
 source TEXT NOT NULL,
 action TEXT,
 target_user_id TEXT,
 changed_unix INTEGER,
 request_id TEXT
);
CREATE TRIGGER IF NOT EXISTS asc_ban_v2_qa_audit AFTER UPDATE OF sha ON asc_ban_v2_qa_source
WHEN OLD.sha<>NEW.sha
BEGIN
 INSERT INTO asc_ban_v2_audit(request_id,action,target_user_id,old_sha,new_sha,created_unix,outcome)
 VALUES(NEW.request_id,NEW.action,NEW.target_user_id,OLD.sha,NEW.sha,NEW.changed_unix,'saved');
END;
