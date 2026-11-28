CREATE TABLE IF NOT EXISTS asc_accounts (
  id TEXT PRIMARY KEY NOT NULL,
  username TEXT NOT NULL UNIQUE COLLATE NOCASE,
  password_hash TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'normal' CHECK(status IN ('normal','restricted_mode','banned')),
  nickname TEXT NOT NULL,
  profile_image TEXT,
  profile_thumbnail TEXT,
  banner_image TEXT,
  banner_thumbnail TEXT,
  banner_color TEXT NOT NULL DEFAULT '#102757',
  totp TEXT,
  totp_pending TEXT,
  totp_pending_until INTEGER,
  last_totp_step INTEGER NOT NULL DEFAULT -1,
  epoch INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS asc_account_sessions (
  id TEXT PRIMARY KEY NOT NULL,
  account_id TEXT NOT NULL REFERENCES asc_accounts(id),
  digest TEXT NOT NULL UNIQUE,
  scope TEXT NOT NULL CHECK(scope IN ('web','loader','second_factor')),
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  last_seen INTEGER,
  revoked_at INTEGER
);
CREATE INDEX IF NOT EXISTS asc_account_session_presence ON asc_account_sessions(scope,last_seen,expires_at,revoked_at);
CREATE TABLE IF NOT EXISTS asc_account_recovery (
  account_id TEXT NOT NULL REFERENCES asc_accounts(id),
  digest TEXT NOT NULL,
  PRIMARY KEY(account_id,digest)
);
CREATE TABLE IF NOT EXISTS asc_account_pairings (
  code TEXT PRIMARY KEY NOT NULL,
  digest TEXT NOT NULL UNIQUE,
  expires_at INTEGER NOT NULL,
  account_id TEXT REFERENCES asc_accounts(id),
  authorizing_session_id TEXT REFERENCES asc_account_sessions(id),
  claimed_session_id TEXT REFERENCES asc_account_sessions(id) DEFERRABLE INITIALLY DEFERRED,
  label TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS asc_account_pairings_expiry ON asc_account_pairings(expires_at);
CREATE TABLE IF NOT EXISTS asc_account_cases (
  id TEXT PRIMARY KEY NOT NULL,
  account_id TEXT NOT NULL REFERENCES asc_accounts(id),
  kind TEXT NOT NULL CHECK(kind IN ('ban','violation','feedback')),
  status TEXT NOT NULL DEFAULT 'open' CHECK(status IN ('open','reviewing','approved','denied','closed')),
  reason TEXT NOT NULL,
  moderator_message TEXT NOT NULL DEFAULT '',
  appeal TEXT,
  legacy_source TEXT,
  legacy_id TEXT,
  created_at INTEGER NOT NULL,
  UNIQUE(legacy_source,legacy_id)
);
CREATE INDEX IF NOT EXISTS asc_account_cases_owner ON asc_account_cases(account_id,kind,created_at);
CREATE TABLE IF NOT EXISTS asc_account_verified_links (
  provider TEXT NOT NULL CHECK(provider='roblox_oidc'),
  subject TEXT NOT NULL,
  account_id TEXT NOT NULL UNIQUE REFERENCES asc_accounts(id),
  verified_at INTEGER NOT NULL,
  PRIMARY KEY(provider,subject)
);
