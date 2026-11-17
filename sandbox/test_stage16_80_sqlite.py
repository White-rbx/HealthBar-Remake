import sqlite3
from pathlib import Path

root=Path(__file__).resolve().parent
migration=(root.parent/'migrations/2026-11-17_stage1680_verified_violation_history_DRAFT.sql').read_text()
js=(root/'stage16-80-verified-violation-history.mjs').read_text()
notice_sql=js.split('const NOTICE_SQL = ')[1].split(chr(96))[1]
history_sql=js.split('const HISTORY_SQL = ')[1].split(chr(96))[1]

def run():
    db=sqlite3.connect(':memory:')
    db.row_factory=sqlite3.Row
    db.execute('PRAGMA foreign_keys=ON')
    db.executescript("""
    CREATE TABLE asc_violation_notices (
      id TEXT PRIMARY KEY, lookup_hash TEXT UNIQUE NOT NULL,
      claimed_user_id TEXT NOT NULL, reason TEXT NOT NULL, moderator_message TEXT NOT NULL,
      created_unix INTEGER NOT NULL, updated_unix INTEGER NOT NULL, status TEXT NOT NULL
    );""")
    db.executescript(migration)
    now=1794900000
    db.executemany('INSERT INTO asc_violation_notices VALUES (?,?,?,?,?,?,?,?)',[
        ('a','hash-a','222','Rule A','Message A',now,now,'violation'),
        ('b','hash-b','111','Rule B','Message B',now,now,'violation'),
    ])
    db.executemany('INSERT INTO asc_verified_violation_subjects VALUES (?,?,?,?,?,?,?)',[
        ('a','111','roblox_oidc','approved',0,now,now),
        ('b','222','roblox_oidc','reviewing',0,now,now),
    ])
    db.execute('INSERT INTO asc_verified_violation_history(notice_id,event_status,event_type,public_note,created_unix) VALUES (?,?,?,?,?)',
        ('a','approved','reviewed','Approved',now))
    assert [r['id'] for r in db.execute(notice_sql,('111',))]==['a']
    assert [r['id'] for r in db.execute(notice_sql,('222',))]==['b']
    assert not list(db.execute(notice_sql,('333',)))
    assert [r['noticeId'] for r in db.execute(history_sql,('111',))]==['a']
    assert not list(db.execute(history_sql,('222',)))
    try:
        db.execute('INSERT INTO asc_verified_violation_subjects VALUES (?,?,?,?,?,?,?)',
            ('missing','333','roblox_oidc','approved',0,now,now))
        raise AssertionError('Foreign key constraint missing')
    except sqlite3.IntegrityError:
        pass
    assert db.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
    assert not db.execute('PRAGMA foreign_key_check').fetchall()
    print('Stage16.80 SQLite: PASS')

if __name__=='__main__':
    run()
