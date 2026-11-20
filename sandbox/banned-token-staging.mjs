/**
 * ArcScriptCenter BANNEDTOKEN — STAGING server-side primitives.
 * This module does NOT authenticate Roblox users or expose a lookup endpoint.
 * The caller must independently establish a trusted, case-bound principal.
 * Never transmit full token, component codes, or raw secret to Roblox Luau.
 */
const enc = new TextEncoder();
const HEX6 = /^[0-9A-F]{6}$/;
const safeId = x => typeof x === 'string' && /^[1-9][0-9]{0,19}$/.test(x);
const safeUsername = x => typeof x === 'string' && /^[A-Za-z0-9_]{3,20}$/.test(x);
function hex(bytes) { return Array.from(bytes, b => b.toString(16).padStart(2,'0')).join('').toUpperCase(); }
async function hmac(key, value) {
  const k = await crypto.subtle.importKey('raw', enc.encode(key), {name:'HMAC',hash:'SHA-256'}, false, ['sign']);
  return hex(new Uint8Array(await crypto.subtle.sign('HMAC', k, enc.encode(value))));
}
export function maskBannedReference(code) {
  if (!HEX6.test(code)) throw new TypeError('Invalid HEX reference');
  return '••••' + code.slice(-2);
}
export async function issueBannedToken({userId,username,caseId,secret}) {
  if (!safeId(userId) || !safeUsername(username) || typeof caseId !== 'string' ||
      !/^[A-Za-z0-9_-]{1,70}$/.test(caseId) ||
      typeof secret !== 'string' || secret.length < 32)
    throw new TypeError('Invalid server-side issuance input');
  // HMAC codes are opaque references, NOT independent identity verification.
  const first = (await hmac(secret, 'uid:v1:' + userId)).slice(0,12);
  const second = (await hmac(secret, 'username:v1:' + userId + ':' + username.toLowerCase())).slice(0,11);
  const last = hex(crypto.getRandomValues(new Uint8Array(3)));
  const token = 'BANNTOKEN_' + first + '-' + second + '#' + last;
  const tokenHash = await crypto.subtle.digest('SHA-256', enc.encode(token));
  return {
    // SERVER ONLY: persist hash + caseId + independently verified subject; never send token to client.
    token, tokenHash: hex(new Uint8Array(tokenHash)).toLowerCase(),
    caseId, userId, username,
    // Only this masked field may be included in a restricted client notice.
    clientReference: maskBannedReference(last)
  };
}
export function publicRestrictionNotice(record) {
  if (!record || typeof record.clientReference !== 'string' ||
      !/^••••[0-9A-F]{2}$/.test(record.clientReference))
    throw new TypeError('Invalid server record');
  return {reference:record.clientReference};
}

// The only callers are authenticated server routes using the verified subject.
// Read through the current ownership row even when a reference already exists.
export async function ensureBannedReference(db, {userId, username, caseId, secret}) {
  const read = () => db.prepare(`
    SELECT r.reference_suffix AS suffix
    FROM asc_banned_token_references AS r
    JOIN asc_verified_violation_subjects AS l USING (notice_id, subject_user_id)
    WHERE r.notice_id=?1 AND r.subject_user_id=?2`).bind(caseId, userId).first();
  let record = await read();
  if (!record && safeUsername(username)) {
    const issued = await issueBannedToken({userId, username, caseId, secret});
    await db.prepare(`
      INSERT INTO asc_banned_token_references(notice_id,subject_user_id,token_hash,reference_suffix)
      SELECT notice_id,subject_user_id,?3,?4
      FROM asc_verified_violation_subjects WHERE notice_id=?1 AND subject_user_id=?2
      ON CONFLICT(notice_id,subject_user_id) DO NOTHING
    `).bind(caseId, userId, issued.tokenHash, issued.clientReference.slice(-2)).run();
    record = await read();
  }
  return record ? '••••' + record.suffix : undefined;
}

// An explicit case-to-restriction link, provisioned by server-side moderation,
// prevents a historic notice's reference from appearing on an unrelated ban.
export async function restrictionBannedReference(db, {userId, revision}) {
  if (typeof revision !== 'string' || revision === '') return undefined;
  const row = await db.prepare(`
    SELECT r.reference_suffix AS suffix
    FROM asc_banned_token_references AS r
    JOIN asc_verified_violation_subjects AS l USING (notice_id, subject_user_id)
    WHERE r.subject_user_id=?1 AND r.ban_revision=?2
  `).bind(userId, revision).first();
  return row ? '••••' + row.suffix : undefined;
}

// Called by independently authorized moderation tooling after establishing the
// exact notice ownership and active ban revision. No public route invokes it.
export async function linkBannedReference(db, {userId, caseId, username, secret, revision}) {
  const reference = await ensureBannedReference(db, {userId, caseId, username, secret});
  if (!reference || typeof revision !== 'string' || !revision) return false;
  const row = await db.prepare(`
    UPDATE asc_banned_token_references AS r SET ban_revision=?3
    WHERE r.notice_id=?1 AND r.subject_user_id=?2
    AND EXISTS (SELECT 1 FROM asc_verified_violation_subjects AS l
      WHERE l.notice_id=r.notice_id AND l.subject_user_id=r.subject_user_id)
    AND ?3=(SELECT request_id FROM asc_ban_v2_audit WHERE target_user_id=?2 AND outcome='saved'
      ORDER BY created_unix DESC, rowid DESC LIMIT 1)
    AND EXISTS (SELECT 1 FROM asc_ban_v2_audit
      WHERE request_id=?3 AND target_user_id=?2 AND action='upsert')
    RETURNING ban_revision
  `).bind(caseId, userId, revision).first();
  return row?.ban_revision === revision;
}
