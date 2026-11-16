-- ArcScriptCenter Production Candidate — Push + Cron schema-only additive migration.
-- DRAFT / REVIEW ONLY: NEVER apply to Production or Staging without owner approval.
-- Derived from live Sandbox D1 sqlite_master definitions (2026-11-16).
-- Exactly 3 tables + 2 indexes, no sample data, secrets, subscriptions or test controls.
-- Apply AFTER reviewing and rehearsing the separate Stage16.69 18-object Feedback/Appeal migration.
-- Requires independent backup/restore verification and source-code integration approval.

-- table: asc_admin_push_subscriptions_v1
CREATE TABLE asc_admin_push_subscriptions_v1(endpoint_hash TEXT PRIMARY KEY,endpoint TEXT NOT NULL UNIQUE,created_unix INTEGER NOT NULL,updated_unix INTEGER NOT NULL,last_sent_event_id INTEGER NOT NULL DEFAULT 0,last_test_unix INTEGER NOT NULL DEFAULT 0,enabled INTEGER NOT NULL DEFAULT 1 CHECK(enabled IN (0,1)));

-- table: asc_push_delivery_outbox_v1
CREATE TABLE asc_push_delivery_outbox_v1 (
  case_id TEXT NOT NULL,
  endpoint_hash TEXT NOT NULL,
  kind TEXT NOT NULL CHECK(kind IN ('feedback','appeal')),
  state TEXT NOT NULL DEFAULT 'pending' CHECK(state IN ('pending','sending','retry','delivered','dead','canceled')),
  attempts INTEGER NOT NULL DEFAULT 0 CHECK(attempts BETWEEN 0 AND 3),
  next_retry_unix INTEGER NOT NULL DEFAULT 0,
  lease_until_unix INTEGER NOT NULL DEFAULT 0,
  last_http_status INTEGER NOT NULL DEFAULT 0,
  created_unix INTEGER NOT NULL,
  updated_unix INTEGER NOT NULL,
  delivered_unix INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(case_id, endpoint_hash)
 );

-- table: asc_push_cron_health_v1
CREATE TABLE asc_push_cron_health_v1(scope TEXT PRIMARY KEY CHECK(scope='sandbox_push_cron'),runs INTEGER NOT NULL DEFAULT 0,last_started_unix INTEGER NOT NULL DEFAULT 0,last_finished_unix INTEGER NOT NULL DEFAULT 0,last_jobs INTEGER NOT NULL DEFAULT 0,last_attempted INTEGER NOT NULL DEFAULT 0,last_accepted INTEGER NOT NULL DEFAULT 0,last_failed INTEGER NOT NULL DEFAULT 0,last_error TEXT NOT NULL DEFAULT 'never' CHECK(last_error IN ('never','none','worker_error')));

-- index: idx_asc_push_outbox_due_v1
CREATE INDEX idx_asc_push_outbox_due_v1 ON asc_push_delivery_outbox_v1(state,next_retry_unix,lease_until_unix);

-- index: idx_asc_push_outbox_case_v1
CREATE INDEX idx_asc_push_outbox_case_v1 ON asc_push_delivery_outbox_v1(case_id);
