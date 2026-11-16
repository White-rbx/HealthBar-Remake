"""Real SQLite dry-run of Stage16.74/16.75 SQL; synthetic data only.

Run: python3 -m unittest discover -s sandbox -p 'test_stage16_75_sqlite.py' -v
No Cloudflare, no network, no Push API, no production database.
"""
from __future__ import annotations

import json
from pathlib import Path
import re
import sqlite3
import unittest

ROOT = Path(__file__).resolve().parents[1]
SQL_FILE = ROOT / "migrations" / "2026-11-16_stage1674_push_delivery_outbox_sandbox_draft.sql"
OUTBOX_FILE = ROOT / "sandbox" / "stage16-74-push-outbox-helpers.js"
CRON_FILE = ROOT / "sandbox" / "stage16-75-cron-retry-runner.js"
CASE_ID = "synthetic-case-do-not-send"
HASH = "a" * 64
NOW = 1_900_000_000


def embedded_statement(source_file: Path, prefix: str) -> str:
    """Use the exact SQL string present in the committed Worker helper."""
    code = source_file.read_text(encoding="utf-8")
    candidates = re.findall(r'\.prepare\(("(?:[^"\\]|\\.)*")\)', code)
    statements = [json.loads(js_string) for js_string in candidates]
    matches = [statement for statement in statements if statement.startswith(prefix)]
    if len(matches) != 1:
        raise AssertionError(f"Expected one actual SQL statement with prefix {prefix!r}, found {len(matches)}")
    return matches[0]


CLAIM = embedded_statement(OUTBOX_FILE, "UPDATE asc_push_delivery_outbox_v1 SET state='sending'")
DUE = embedded_statement(OUTBOX_FILE, "SELECT DISTINCT case_id FROM asc_push_delivery_outbox_v1")
STALE = embedded_statement(CRON_FILE, "UPDATE asc_push_delivery_outbox_v1 SET state='dead'")


class OutboxSqlContractTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:", isolation_level=None)
        self.db.execute("PRAGMA foreign_keys=ON")
        self.db.executescript(SQL_FILE.read_text(encoding="utf-8"))
        # Minimal related table needed by the Worker claim SQL, with entirely synthetic records.
        self.db.execute("CREATE TABLE asc_feedback_cases(id TEXT PRIMARY KEY, removed INTEGER NOT NULL, status TEXT NOT NULL)")
        self.db.execute("INSERT INTO asc_feedback_cases VALUES(?,?,?)", (CASE_ID, 0, "reviewing"))

    def tearDown(self):
        self.db.close()

    def row(self, endpoint_hash=HASH, *, state="pending", attempts=0, due=0, lease=0):
        self.db.execute(
            "INSERT INTO asc_push_delivery_outbox_v1 (case_id,endpoint_hash,kind,state,attempts,next_retry_unix,lease_until_unix,created_unix,updated_unix) "
            "VALUES(?,?,?,?,?,?,?,?,?)",
            (CASE_ID,endpoint_hash,"feedback",state,attempts,due,lease,NOW,NOW),
        )

    def claim(self, *, endpoint_hash=HASH, now=NOW):
        return self.db.execute(CLAIM, (now + 25, now, CASE_ID, endpoint_hash, now, now, CASE_ID)).fetchone()

    def test_migration_includes_due_index_and_unique_pair(self):
        indexes = {r[1] for r in self.db.execute("PRAGMA index_list('asc_push_delivery_outbox_v1')")}
        self.assertIn("idx_asc_push_outbox_due_v1", indexes)
        self.assertIn("idx_asc_push_outbox_case_v1", indexes)
        self.row()
        with self.assertRaises(sqlite3.IntegrityError):
            self.row()
        self.assertEqual(self.db.execute("SELECT count(*) FROM asc_push_delivery_outbox_v1").fetchone()[0], 1)

    def test_schema_rejects_invalid_states_and_attempt_counts(self):
        for state, attempts in [("sending-now", 0), ("pending", 4), ("pending", -1)]:
            with self.subTest(state=state, attempts=attempts):
                with self.assertRaises(sqlite3.IntegrityError):
                    self.row(state=state, attempts=attempts)
        self.assertEqual(self.db.execute("SELECT count(*) FROM asc_push_delivery_outbox_v1").fetchone()[0], 0)

    def test_atomic_claim_prevents_duplicate_and_enforces_retry_due(self):
        self.row()
        self.assertEqual(self.claim(), (1,))
        self.assertIsNone(self.claim())
        self.db.execute("UPDATE asc_push_delivery_outbox_v1 SET state='retry',next_retry_unix=?,lease_until_unix=0 WHERE case_id=?", (NOW+60,CASE_ID))
        self.assertIsNone(self.claim(now=NOW+59))
        self.assertEqual(self.claim(now=NOW+60), (2,))

    def test_success_cannot_be_reclaimed_even_after_lease_expires(self):
        self.row()
        self.assertEqual(self.claim(), (1,))
        self.db.execute("UPDATE asc_push_delivery_outbox_v1 SET state='delivered',lease_until_unix=0 WHERE case_id=?", (CASE_ID,))
        self.assertIsNone(self.claim(now=NOW+9999))

    def test_third_attempt_is_terminal_for_claims(self):
        self.row(attempts=2)
        self.assertEqual(self.claim(), (3,))
        self.db.execute("UPDATE asc_push_delivery_outbox_v1 SET state='retry',next_retry_unix=?,lease_until_unix=0 WHERE case_id=?", (NOW+60,CASE_ID))
        self.assertIsNone(self.claim(now=NOW+60))

    def test_claim_refuses_removed_and_spam_cases(self):
        self.row()
        self.db.execute("UPDATE asc_feedback_cases SET removed=1 WHERE id=?", (CASE_ID,))
        self.assertIsNone(self.claim())
        self.db.execute("UPDATE asc_feedback_cases SET removed=0,status='spam_mail' WHERE id=?", (CASE_ID,))
        self.assertIsNone(self.claim())
        self.assertEqual(self.db.execute("SELECT attempts FROM asc_push_delivery_outbox_v1").fetchone()[0], 0)

    def test_due_query_only_selects_ready_items(self):
        self.row(HASH, state="retry", due=NOW+50)
        self.row("b"*64, state="sending", attempts=1, lease=NOW+50)
        self.assertEqual(self.db.execute(DUE, (NOW,NOW)).fetchall(), [])
        self.assertEqual(self.db.execute(DUE, (NOW+50,NOW+50)).fetchall(), [(CASE_ID,)])

    def test_expired_exhausted_lease_is_dead_without_affecting_live_lease(self):
        self.row(HASH, state="sending", attempts=3, lease=NOW-1)
        self.row("b"*64, state="sending", attempts=2, lease=NOW+60)
        self.db.execute(STALE, (NOW,NOW))
        records = dict(self.db.execute("SELECT endpoint_hash,state FROM asc_push_delivery_outbox_v1"))
        self.assertEqual(records[HASH], "dead")
        self.assertEqual(records["b"*64], "sending")
        self.assertIsNone(self.claim(now=NOW+9999))

    def test_integrity_remains_ok_after_transition_tests(self):
        self.row()
        self.assertEqual(self.claim(), (1,))
        self.assertEqual(self.db.execute("PRAGMA quick_check").fetchone(), ("ok",))
        self.assertEqual(self.db.execute("PRAGMA foreign_key_check").fetchall(), [])


if __name__ == "__main__":
    unittest.main()
