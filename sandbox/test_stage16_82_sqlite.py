"""Stage16.82: Offline SQLite execution of the same SQL used by the D1 Worker adapter.
NO access to any Cloudflare production or staging D1 database."""
import concurrent.futures
import json
import sqlite3
import subprocess
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parent.parent
SCHEMA=ROOT/'migrations/2026-11-17_stage1682_oidc_sandbox_only_DRAFT.sql'
JS=ROOT/'sandbox/stage16-82-d1-oauth-stores.mjs'
COMMAND="import {STAGE1682_SQL} from './sandbox/stage16-82-d1-oauth-stores.mjs'; console.log(JSON.stringify(STAGE1682_SQL))"
SQL=json.loads(subprocess.check_output(['node','--input-type=module','-e',COMMAND],cwd=ROOT,text=True))
NOW=1794910000
K1='a'*43
K2='b'*43

def open_db(path):
    conn=sqlite3.connect(path,timeout=5,isolation_level=None)
    conn.row_factory=sqlite3.Row
    conn.execute('PRAGMA busy_timeout=5000')
    return conn

def take_state(path):
    with open_db(path) as conn:
        return [dict(row) for row in conn.execute(SQL['pendingTake'],(K1,))]

def main():
    with tempfile.TemporaryDirectory() as tmp:
        path=str(Path(tmp)/'sandbox-only.sqlite3')
        with open_db(path) as conn:
            conn.executescript(SCHEMA.read_text(encoding='utf-8'))
            conn.execute(SQL['pendingPut'],(K1,K2,K2,K2,'1234567890123456',
                'https://sandbox.example.test/oauth/callback',NOW+300))
        # Distinct connections race to redeem exactly the same state.
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            redeemed=list(pool.map(take_state,[path,path]))
        assert sum(bool(x) for x in redeemed)==1,redeemed
        assert take_state(path)==[]
        with open_db(path) as conn:
            conn.execute(SQL['sessionPut'],(K1,'111',NOW,NOW+900))
            own=conn.execute(SQL['sessionGet'],(K1,NOW)).fetchone()
            assert dict(own)=={'sub':'111','method':'roblox_oidc','expiresAt':NOW+900}
            assert conn.execute(SQL['sessionGet'],(K2,NOW)).fetchone() is None
            assert conn.execute(SQL['sessionGet'],(K1,NOW+901)).fetchone() is None
            # Duplicate session insert MUST fail, not silently replace principal.
            try:
                conn.execute(SQL['sessionPut'],(K1,'222',NOW,NOW+900))
                raise AssertionError('duplicate session overwrote identity')
            except sqlite3.IntegrityError:
                pass
            assert conn.execute(SQL['sessionGet'],(K1,NOW)).fetchone()['sub']=='111'
            conn.execute(SQL['sessionDelete'],(K1,))
            assert conn.execute(SQL['sessionGet'],(K1,NOW)).fetchone() is None
            conn.execute(SQL['pendingPut'],(K2,K1,K1,K1,'1234567890123456',
                'https://sandbox.example.test/oauth/callback',NOW+300))
            conn.execute(SQL['prunePending'],(NOW+301,))
            assert conn.execute('SELECT COUNT(*) FROM asc_oidc_pending').fetchone()[0]==0
            conn.execute(SQL['sessionPut'],(K2,'333',NOW,NOW+900))
            conn.execute(SQL['pruneSessions'],(NOW+901,))
            assert conn.execute('SELECT COUNT(*) FROM asc_oidc_sessions').fetchone()[0]==0
            for table in ('asc_oidc_pending','asc_oidc_sessions'):
                fields={row['name'] for row in conn.execute('PRAGMA table_info('+table+')')}
                assert not {'access_token','refresh_token','id_token','password'} & fields
            assert conn.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
    print('Stage16.82 SQLite offline: PASS (atomic DELETE RETURNING race, expiry, isolation, revocation)')

if __name__=='__main__':
    main()
