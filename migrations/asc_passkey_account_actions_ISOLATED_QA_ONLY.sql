-- Additive schema for the protected ESLogin QA database.
CREATE TABLE IF NOT EXISTS asc_account_feedback_details (
  case_id TEXT PRIMARY KEY NOT NULL REFERENCES asc_account_cases(id) ON DELETE CASCADE,
  topic TEXT NOT NULL CHECK(length(topic) BETWEEN 3 AND 50)
);

CREATE TABLE IF NOT EXISTS asc_account_passkey_actions (
  flow_hash TEXT PRIMARY KEY NOT NULL CHECK(length(flow_hash)=64),
  account_id TEXT NOT NULL REFERENCES asc_accounts(id),
  session_id TEXT NOT NULL REFERENCES asc_account_sessions(id),
  challenge TEXT NOT NULL,
  action TEXT NOT NULL CHECK(action IN ('revoke_session','review_case','set_status')),
  payload TEXT NOT NULL,
  expires_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS asc_account_passkey_actions_expiry ON asc_account_passkey_actions(expires_at);
