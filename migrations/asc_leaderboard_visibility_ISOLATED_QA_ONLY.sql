-- Isolated QA candidate; no publication or deployment is enabled by this migration.
CREATE TABLE IF NOT EXISTS asc_account_leaderboard_visibility (
 account_id TEXT PRIMARY KEY NOT NULL REFERENCES asc_accounts(id),
 listed INTEGER NOT NULL DEFAULT 0 CHECK(listed IN (0,1)),
 appearance INTEGER NOT NULL DEFAULT 0 CHECK(appearance IN (0,1)),
 badges INTEGER NOT NULL DEFAULT 0 CHECK(badges IN (0,1)),
 updated_at INTEGER NOT NULL CHECK(updated_at>=0),
 CHECK(listed=1 OR (appearance=0 AND badges=0))
);
