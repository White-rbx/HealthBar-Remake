/**
 * ArcScriptCenter STAGING admin UX helper (REVIEW ONLY; no deploy).
 * Existing GitHub-managed Ban entries already store:
 * userId, username, reason, description, startAt, expiresAt.
 * This helper labels the existing records; it does not create bans,
 * verify Roblox identity, modify data, or make HTTP requests.
 */

/** Parse the already-validated 'YYYY-MM-DD HH:mm' ICT format to Unix seconds. */
export function fromICT(stamp) {
  if (stamp === '') return null;
  if (typeof stamp !== 'string') return NaN;
  const m = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(stamp);
  if (!m) return NaN;
  const [y,mo,day,h,min] = m.slice(1).map(Number);
  const unix = Date.UTC(y,mo-1,day,h,min)/1000 - 7*3600;
  const back = new Date((unix+7*3600)*1000);
  if (back.getUTCFullYear() !== y || back.getUTCMonth()+1 !== mo ||
      back.getUTCDate() !== day || back.getUTCHours() !== h || back.getUTCMinutes() !== min) return NaN;
  return unix;
}

export function classifyManagedBan(entry, nowUnix=Math.floor(Date.now()/1000)) {
  if (!entry || typeof entry !== 'object' || !/^[1-9][0-9]{0,15}$/.test(entry.userId||''))
    throw new Error('Invalid managed ban entry');
  if (typeof entry.startAt !== 'string' || typeof entry.expiresAt !== 'string')
    throw new Error('Invalid managed ban dates');
  const start=fromICT(entry.startAt), end=fromICT(entry.expiresAt);
  if (Number.isNaN(start)||Number.isNaN(end) || (start!==null&&end!==null&&end<=start))
    throw new Error('Invalid managed ban schedule');
  if (start!==null&&nowUnix<start)
    return {label:'Scheduled Ban',type:'scheduled',active:false,expiresAt:end,userId:entry.userId};
  if (end!==null&&nowUnix>=end)
    return {label:'Expired',type:'expired',active:false,expiresAt:end,userId:entry.userId};
  return {label:end===null?'Banned':'Temporary Banned',type:end===null?'banned':'temporary_banned',active:true,expiresAt:end,userId:entry.userId};
}

/**
 * Admin-side only. Append a status badge inside the EXISTING ban card.
 * Called by existing banRender() AFTER authenticated GET /api/v1/admin/bans;
 * do not duplicate Unlock or fetch public ban lists.
 */
export function appendAdminBanBadge(infoElement, entry, nowUnix=Math.floor(Date.now()/1000)) {
  if (!infoElement || typeof infoElement.append !== 'function' || !infoElement.ownerDocument)
    throw new Error('Requires an existing Admin card DOM element');
  const result=classifyManagedBan(entry,nowUnix);
  const badge=infoElement.ownerDocument.createElement('span');
  badge.className='asc-ban-type-badge';
  badge.dataset.banType=result.type;
  badge.textContent=result.label;
  badge.setAttribute('aria-label','Ban status: '+result.label);
  infoElement.append(badge);
  return result;
}

/**
 * Never create a confirmed user-facing Violation from a claimedUserId.
 * The server MUST independently prove the Roblox principal, and issue a
 * linked notice with case ID, reason and moderator message. Ban list fields
 * alone are insufficient to authenticate the person opening Arcsen.
 */
export function describeVerifiedBanNotice({entry, verifiedServerPrincipal, linkedNoticeId, reason, moderatorMessage, appealStatus, nowUnix}) {
  if (!verifiedServerPrincipal?.verified || verifiedServerPrincipal.userId !== entry?.userId)
    return null;
  if (typeof linkedNoticeId !== 'string' || !/^[0-9a-f-]{36}$/i.test(linkedNoticeId))
    return null;
  if (typeof reason !== 'string' || !reason.trim() || typeof moderatorMessage !== 'string' || !moderatorMessage.trim())
    return null;
  if (!['not_appealed','reviewing','approved','denied'].includes(appealStatus))
    return null;
  const ban=classifyManagedBan(entry,nowUnix);
  if (!ban.active) return null;
  return {id:linkedNoticeId,reason,moderatorMessage,appealStatus,banType:ban.type,expiresAt:ban.expiresAt,identityVerified:true};
}
