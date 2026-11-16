"""Review-only, real SQLite Cron bootstrap verification. No Cloudflare credentials."""
import re
import sqlite3
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATION = ROOT / "migrations" / "2026-11-16_stage1675_push_cron_additive_DRAFT.sql"
ASSEMBLER = ROOT / "sandbox" / "production-candidate-assembler.mjs"
SCOPE = "production_push_cron"


class ProductionCronBootstrapTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.executescript(MIGRATION.read_text(encoding="utf-8"))

    def tearDown(self):
        self.db.close()

    def test_has_exactly_one_initialized_production_scope(self):
        rows = self.db.execute(
            "SELECT scope,runs,last_started_unix,last_finished_unix,last_error FROM asc_push_cron_health_v1"
        ).fetchall()
        self.assertEqual(rows, [(SCOPE, 0, 0, 0, "never")])

    def test_scope_rejects_a_sandbox_row(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO asc_push_cron_health_v1(scope) VALUES(?)", ("sandbox_push_cron",))
        self.assertEqual(self.db.execute("SELECT count(*) FROM asc_push_cron_health_v1").fetchone()[0], 1)

    def test_cron_update_reaches_a_real_row(self):
        c = self.db.execute(
            "UPDATE asc_push_cron_health_v1 SET runs=runs+1,last_error='none' WHERE scope=?",
            (SCOPE,),
        )
        self.assertEqual(c.rowcount, 1)
        self.assertEqual(
            self.db.execute("SELECT runs,last_error FROM asc_push_cron_health_v1").fetchone(),
            (1, "none"),
        )

    def test_idempotent_bootstrap_does_not_reset_existing_telemetry(self):
        self.db.execute("UPDATE asc_push_cron_health_v1 SET runs=7 WHERE scope=?", (SCOPE,))
        self.db.execute("INSERT OR IGNORE INTO asc_push_cron_health_v1(scope) VALUES(?)", (SCOPE,))
        self.assertEqual(
            self.db.execute("SELECT runs FROM asc_push_cron_health_v1").fetchone()[0], 7
        )

    def test_migration_has_only_one_nonuser_insert_and_five_schema_objects(self):
        source = MIGRATION.read_text(encoding="utf-8")
        without_comments = "\n".join(
            line for line in source.splitlines() if not line.lstrip().startswith("--")
        )
        inserts = re.findall(r"\bINSERT\s+(?:OR\s+IGNORE\s+)?INTO\s+(\w+)", without_comments, re.I)
        self.assertEqual(inserts, ["asc_push_cron_health_v1"])
        objs = self.db.execute(
            "SELECT type,name FROM sqlite_master WHERE name LIKE 'asc_%' "
            "OR name LIKE 'idx_asc_push_%'"
        ).fetchall()
        self.assertEqual(len(objs), 5)
        self.assertEqual(len([t for t, _ in objs if t == "table"]), 3)
        self.assertEqual(len([t for t, _ in objs if t == "index"]), 2)

    def test_assembler_rewrites_all_four_cron_scope_references_fail_closed(self):
        source = ASSEMBLER.read_text(encoding="utf-8")
        self.assertIn('if(cron.split(sandboxCronScope).length!==5)', source)
        self.assertIn('cron=cron.replaceAll(sandboxCronScope,"\'production_push_cron\'")', source)
        self.assertIn("Stage16.75 Cron health scope markers changed", source)

    def test_sqlite_integrity(self):
        self.assertEqual(self.db.execute("PRAGMA quick_check").fetchone(), ("ok",))
        self.assertEqual(self.db.execute("PRAGMA foreign_key_check").fetchall(), [])


if __name__ == "__main__":
    unittest.main()
