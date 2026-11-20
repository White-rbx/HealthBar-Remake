-- ArcScriptCenter Ban Selection v2 — QA-ONLY fixture.
-- Target: asc-unknown-trash-qa-20261118 (D1 UUID 3bf5266f-8ee0-4cbd-bf3f-c2de4ea45bfa).
-- Never run this on production or arcscriptcenter-staging D1.
-- This does not change GitHub-managed bans, the live ban snapshot, or real users.
CREATE TABLE IF NOT EXISTS asc_ban_v2_qa (
    id INTEGER PRIMARY KEY CHECK(id=1),
    document_json TEXT NOT NULL CHECK(json_valid(document_json)),
    revision INTEGER NOT NULL DEFAULT 0 CHECK(revision>=0)
);
INSERT INTO asc_ban_v2_qa (id,document_json,revision)
VALUES (1,'{"schema":2,"entries":[]}',0)
ON CONFLICT(id) DO NOTHING;
