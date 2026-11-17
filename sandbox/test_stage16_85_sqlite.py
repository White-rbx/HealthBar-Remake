"""Stage16.85: execute the JS D1 limiter's REAL SQL using offline SQLite.
Only temporary local SQLite; no Cloudflare secrets, resources or user data.
"""
import concurrent.futures
import json
import sqlite3
import subprocess
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parent.parent
MIGRATION=ROOT/'migrations/2026-11-17_stage1685_pairing_rate_sandbox_only_DRAFT.sql'
CMD="import {stage1685RateLimitContract as c} from './sandbox/stage16-85-d1-rate-limiter.mjs'; console.log(JSON.stringify(c.SQL))"
SQL=json.loads(subprocess.check_output(['node','--input-type=module','-e',CMD],cwd=ROOT,text=True))
WINDOW=1794909960
FIRST='A'*43
SECOND='B'*43
GLOBAL='C'*43

def connect(path):
    c=sqlite3.connect(path,timeout=10,isolation_level=None)
    c.row_factory=sqlite3.Row
    c.execute('PRAGMA busy_timeout=10000')
    return c

def consume(path, scope, limit, window=WINDOW):
    with connect(path) as c:
        return [dict(row) for row in c.execute(SQL['consume'],(scope,window,window+600,limit))]

def main():
    with tempfile.TemporaryDirectory() as folder:
        path=str(Path(folder)/'stage16-85-rate.sqlite3')
        with connect(path) as c:
            c.executescript(MIGRATION.read_text())
            c.execute('PRAGMA foreign_keys=ON')
        # Simulate multiple different Workers racing on one network and one D1.
        with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
            a=list(pool.map(lambda _: consume(path,FIRST,4),range(20)))
        assert sum(bool(result) for result in a)==4,a
        assert sorted(result[0]['hits'] for result in a if result)==[1,2,3,4]
        assert not consume(path,FIRST,4)
        assert len(consume(path,SECOND,4))==1

        # A global bucket shared by many networks is independently atomic.
        with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
            g=list(pool.map(lambda _: consume(path,GLOBAL,5),range(40)))
        assert sum(bool(result) for result in g)==5,g
        assert sorted(result[0]['hits'] for result in g if result)==[1,2,3,4,5]

        # New window permits re-entry without changing past bucket.
        assert len(consume(path,FIRST,4,WINDOW+60))==1
        with connect(path) as c:
            current=c.execute('SELECT count(*) FROM asc_pairing_rate_windows').fetchone()[0]
            assert current==4,current
            c.execute(SQL['prune'],(WINDOW+601,))
            remains=c.execute('SELECT count(*) FROM asc_pairing_rate_windows').fetchone()[0]
            assert remains==1,remains
            c.execute(SQL['prune'],(WINDOW+661,))
            assert c.execute('SELECT count(*) FROM asc_pairing_rate_windows').fetchone()[0]==0
            fields={row['name'] for row in c.execute('PRAGMA table_info(asc_pairing_rate_windows)')}
            assert fields=={'scope_hash','window_start','hits','expires_unix'}
            assert c.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
    print('Stage16.85 SQLite: PASS (atomic burst concurrency, quota caps, global bucket, expiry, data minimization)')
if __name__=='__main__':
    main()
