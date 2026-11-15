-- ArcScriptCenter Stage 16.74 -- Sandbox Push Delivery Outbox schema draft.
-- DO NOT apply directly to Production or Staging.
-- Requires review of Stage16.69 Feedback/Appeal schema and Stage16.71 Push
-- subscriptions dependencies, verified backup/restore and explicit release approval.
-- This is a schema-only change. It does not contain personal data or secrets.
CREATE TABLE asc_push_delivery_outbox_v1 (
 case_id TEXT NOT NULL,
 endpoint_hash TEXT NOT NULL,
 kind TEXT NOT NULL CHECK(kind IN ('feedback','appeal')),
 state TEXT NOT NULL DEFAULT 'pending'
  CHECK(state IN ('pending','sending','retry','delivered','dead','canceled')),
 attempts INTEGER NOT NULL DEFAULT 0 CHECK(attempts BETWEEN 0 AND 3),
 next_retry_unix INTEGER NOT NULL DEFAULT 0,
 lease_until_unix INTEGER NOT NULL DEFAULT 0,
 last_http_status INTEGER NOT NULL DEFAULT 0,
 created_unix INTEGER NOT NULL,
 updated_unix INTEGER NOT NULL,
 delivered_unix INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY(case_id,endpoint_hash)
);
CREATE INDEX idx_asc_push_outbox_due_v1
 ON asc_push_delivery_outbox_v1(state,next_retry_unix,lease_until_unix);
CREATE INDEX idx_asc_push_outbox_case_v1
 ON asc_push_delivery_outbox_v1(case_id);
