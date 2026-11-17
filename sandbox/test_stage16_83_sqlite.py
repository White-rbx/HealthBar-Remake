"""Stage16.83 actual SQLite SQL checks (OFFLINE ONLY; NO Cloudflare D1 writes)."""
import concurrent.futures
import json
import sqlite3
import subprocess
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parent.parent
MIGRATION=ROOT/'migrations/2026-11-17_stage1683_pairing_sandbox_only_DRAFT.sql'
CMD="import {PAIR_SQL} from './sandbox/stage16-83-pairing-d1.mjs'; console.log(JSON.stringify(PAIR_SQL))"
SQL=json.loads(subprocess.check_output(['node','--input-type=module','-e',CMD],cwd=ROOT,text=True))
NOW=1794910000
CODE='a'*43
DEVICE='b'*43
CONFIRM='c'*43
OTHER='d'*43

def connect(dbfile):
    conn=sqlite3.connect(dbfile,timeout=5,isolation_level=None)
    conn.row_factory=sqlite3.Row
    conn.execute('PRAGMA busy_timeout=5000')
    return conn

def query(dbfile,statement,args):
    with connect(dbfile) as conn:
        return [dict(x) for x in conn.execute(statement,args)]

def main():
    with tempfile.TemporaryDirectory() as folder:
        dbfile=str(Path(folder)/'pair-only.sqlite3')
        with connect(dbfile) as conn:
            conn.executescript(MIGRATION.read_text(encoding='utf-8'))
            conn.execute(SQL['create'],(CODE,DEVICE,NOW+300))

        # Browser previews code while authenticated. The state can be bound to only one subject.
        assert len(query(dbfile,SQL['preview'],(CODE,'111',CONFIRM,NOW+60,NOW)))==1
        assert not query(dbfile,SQL['preview'],(CODE,'222',OTHER,NOW+60,NOW))
        assert not query(dbfile,SQL['approve'],(CODE,'222',CONFIRM,NOW))
        assert not query(dbfile,SQL['approve'],(CODE,'111',OTHER,NOW))

        # Two approvals race on different connections; only one may transition state.
        def approve(_):
            return query(dbfile,SQL['approve'],(CODE,'111',CONFIRM,NOW))
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            raced=list(pool.map(approve,range(2)))
        assert sum(len(x) for x in raced)==1,raced

        # A device has only a non-identity-bearing status and can consume at most once.
        status=query(dbfile,SQL['state'],(DEVICE,NOW))
        assert status==[{'state':'approved'}],status
        def consume(_):
            return query(dbfile,SQL['consume'],(DEVICE,NOW))
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            consumed=list(pool.map(consume,range(2)))
        assert sum(len(x) for x in consumed)==1,consumed
        assert not query(dbfile,SQL['consume'],(DEVICE,NOW))
        assert not query(dbfile,SQL['state'],(DEVICE,NOW))

        # Expiry, cancellation and storage minimization checks.
        with connect(dbfile) as conn:
            conn.execute(SQL['create'],(OTHER,CONFIRM,NOW+300))
            conn.execute(SQL['prune'],(NOW+301,))
            assert conn.execute('SELECT COUNT(*) FROM asc_pairing_sandbox').fetchone()[0]==0
            conn.execute(SQL['create'],(CODE,DEVICE,NOW+300))
            assert len(query(dbfile,SQL['cancel'],(DEVICE,)))==1
            assert not query(dbfile,SQL['state'],(DEVICE,NOW))
            cols={r['name'] for r in conn.execute('PRAGMA table_info(asc_pairing_sandbox)')}
            assert not {'access_token','refresh_token','id_token','password','cookie','username'} & cols
            assert conn.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
    print('Stage16.83 SQLite: PASS (subject-bound preview, one-shot approval/poll, expiry, cancel, integrity)')

if __name__=='__main__':
    main()
