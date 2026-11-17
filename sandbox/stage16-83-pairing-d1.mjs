/**
 * Stage 16.83: D1 adapter for sandbox-only pairing ceremony (no deployments).
 * All transitions that can race use single conditional UPDATE/DELETE RETURNING.
 * The untrusted device polling token NEVER allows reading subject_user_id.
 */
const HASH_RE=/^[A-Za-z0-9_-]{43}$/;
const SUB_RE=/^[1-9][0-9]{0,19}$/;
function checkHash(v){if(typeof v!=='string'||!HASH_RE.test(v))throw new TypeError('Invalid hashed capability');}
function checkNow(now){if(!Number.isSafeInteger(now)||now<=0)throw new TypeError('Invalid time');}
function yes(result){return Array.isArray(result?.results)&&result.results.length===1;}
export const PAIR_SQL=Object.freeze({
 create:[
  'INSERT INTO asc_pairing_sandbox',
  '(code_hash,device_hash,state,expires_unix)',
  "VALUES (?1,?2,'pending',?3)",
 ].join(' '),
 preview:[
  'UPDATE asc_pairing_sandbox',
  'SET preview_subject = ?2, confirmation_hash = ?3, confirmation_expires_unix = ?4',
  "WHERE code_hash = ?1 AND state = 'pending' AND expires_unix > ?5",
  'AND (preview_subject IS NULL OR preview_subject = ?2)',
  'RETURNING code_hash',
 ].join(' '),
 approve:[
  'UPDATE asc_pairing_sandbox',
  "SET state = 'approved', confirmation_hash = NULL, confirmation_expires_unix = NULL",
  "WHERE code_hash = ?1 AND state = 'pending' AND expires_unix > ?4",
  'AND preview_subject = ?2 AND confirmation_hash = ?3',
  'AND confirmation_expires_unix > ?4',
  'RETURNING code_hash',
 ].join(' '),
 state:[
  'SELECT state FROM asc_pairing_sandbox',
  'WHERE device_hash = ?1 AND expires_unix > ?2 LIMIT 1',
 ].join(' '),
 consume:[
  'DELETE FROM asc_pairing_sandbox',
  "WHERE device_hash = ?1 AND state = 'approved' AND expires_unix > ?2",
  'RETURNING state',
 ].join(' '),
 cancel:'DELETE FROM asc_pairing_sandbox WHERE device_hash = ?1 RETURNING code_hash',
 prune:'DELETE FROM asc_pairing_sandbox WHERE expires_unix <= ?1',
});
export function createPairingD1Store(db,{clock=()=>Date.now()}={}) {
 if(typeof db?.prepare!=='function')throw new TypeError('Separate sandbox D1 binding required');
 return Object.freeze({
  async create({codeHash,deviceHash,expiresAt}) {
   checkHash(codeHash);checkHash(deviceHash);
   const now=Math.floor(clock()/1000);checkNow(now);
   if(!Number.isSafeInteger(expiresAt)||expiresAt<=now||expiresAt>now+300)throw new TypeError('Invalid TTL');
   await db.prepare(PAIR_SQL.create).bind(codeHash,deviceHash,expiresAt).run();
  },
  async preview({codeHash,sub,confirmationHash,confirmationExpiresAt,now}) {
   checkHash(codeHash);checkHash(confirmationHash);checkNow(now);
   if(typeof sub!=='string'||!SUB_RE.test(sub) ||
      !Number.isSafeInteger(confirmationExpiresAt) || confirmationExpiresAt<=now ||
      confirmationExpiresAt>now+60) return false;
   const r=await db.prepare(PAIR_SQL.preview).bind(
    codeHash,sub,confirmationHash,confirmationExpiresAt,now
   ).run();
   return yes(r);
  },
  async approve({codeHash,sub,confirmationHash,now}) {
   checkHash(codeHash);checkHash(confirmationHash);checkNow(now);
   if(typeof sub!=='string'||!SUB_RE.test(sub))return false;
   return yes(await db.prepare(PAIR_SQL.approve).bind(codeHash,sub,confirmationHash,now).run());
  },
  async getByDevice({deviceHash,now}) {
   checkHash(deviceHash);checkNow(now);
   const row=await db.prepare(PAIR_SQL.state).bind(deviceHash,now).first();
   return row?.state==='pending'||row?.state==='approved'?row.state:null;
  },
  async consumeApproved({deviceHash,now}) {
   checkHash(deviceHash);checkNow(now);
   return yes(await db.prepare(PAIR_SQL.consume).bind(deviceHash,now).run());
  },
  async cancel({deviceHash}) {
   checkHash(deviceHash);
   return yes(await db.prepare(PAIR_SQL.cancel).bind(deviceHash).run());
  },
  async pruneExpired() {
   return db.prepare(PAIR_SQL.prune).bind(Math.floor(clock()/1000)).run();
  },
 });
}
