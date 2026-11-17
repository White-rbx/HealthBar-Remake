/**
 * Stage 16.80 — server-only Cloudflare Worker handler (draft / not deployed).
 * IMPORTANT: resolveVerifiedPrincipal must come from a trusted server-side
 * OAuth/OIDC session verifier, NOT request headers, query params or Lua JSON.
 * The module intentionally cannot create/sign sessions or grant links.
 */
const STATES = new Set(['not_appealed', 'reviewing', 'denied', 'approved']);
const SUBJECT_RE = /^[1-9][0-9]{0,19}$/;
const AUTH_SOURCE = new Set(['roblox_oidc', 'trusted_game_server']);
const MAX_NOTICES = 50;
const MAX_HISTORY_PER_NOTICE = 20;

const NOTICE_SQL = `
SELECT l.notice_id AS id, n.reason AS reason,
       n.moderator_message AS moderatorMessage,
       l.appeal_status AS appealStatus,
       l.may_reappeal AS mayReappeal,
       n.created_unix AS createdAt
FROM asc_verified_violation_subjects AS l
JOIN asc_violation_notices AS n ON n.id = l.notice_id
WHERE l.subject_user_id = ?1
ORDER BY n.created_unix DESC, l.notice_id ASC
LIMIT 50`;

const HISTORY_SQL = `
SELECT e.notice_id AS noticeId, e.event_status AS status, e.event_type AS action,
       e.public_note AS publicNote, e.created_unix AS createdAt
FROM (
  SELECT h.*, ROW_NUMBER() OVER (
    PARTITION BY h.notice_id ORDER BY h.created_unix DESC, h.event_id DESC
  ) AS rank_in_notice
  FROM asc_verified_violation_history AS h
  JOIN asc_verified_violation_subjects AS l ON l.notice_id = h.notice_id
  WHERE l.subject_user_id = ?1
) AS e
WHERE e.rank_in_notice <= 20
ORDER BY e.created_unix DESC, e.notice_id ASC`;

function resultJson(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store, private',
      'x-content-type-options': 'nosniff',
    },
  });
}

function verifiedSubject(principal, nowUnix) {
  if (!principal || typeof principal !== 'object' || principal.verified !== true) return null;
  if (!AUTH_SOURCE.has(principal.method)) return null;
  if (typeof principal.sub !== 'string' || !SUBJECT_RE.test(principal.sub)) return null;
  if (!Number.isSafeInteger(principal.expiresAt) || principal.expiresAt <= nowUnix) return null;
  return principal.sub;
}

async function loadSubjectNotices(db, subject) {
  const [a, b] = await Promise.all([
    db.prepare(NOTICE_SQL).bind(subject).all(),
    db.prepare(HISTORY_SQL).bind(subject).all(),
  ]);
  const noticeRows = a?.results ?? [];
  const historyRows = b?.results ?? [];
  const history = new Map();
  for (const row of historyRows) {
    if (typeof row.noticeId !== 'string' || !STATES.has(row.status)) continue;
    if (!history.has(row.noticeId)) history.set(row.noticeId, []);
    const events = history.get(row.noticeId);
    if (events.length >= MAX_HISTORY_PER_NOTICE) continue;
    events.push({
      status: row.status,
      action: String(row.action ?? '').slice(0,60),
      publicNote: String(row.publicNote ?? '').slice(0,800),
      createdAt: Number(row.createdAt) || 0,
    });
  }

  const notices = [];
  for (const row of noticeRows.slice(0, MAX_NOTICES)) {
    if (typeof row.id !== 'string' || !STATES.has(row.appealStatus)) continue;
    const state = row.appealStatus;
    notices.push({
      id: row.id.slice(0,70),
      reason: String(row.reason ?? '').slice(0,120),
      moderatorMessage: String(row.moderatorMessage ?? '').slice(0,800),
      appealStatus: state,
      layoutOrder: {not_appealed: 0, reviewing: 1, denied: 2, approved: 3}[state],
      canAppealAgain: state === 'not_appealed' || (state === 'denied' && row.mayReappeal === 1),
      createdAt: Number(row.createdAt) || 0,
      history: history.get(row.id) ?? [],
    });
  }
  return notices;
}

/**
 * Create a GET /api/v1/violation/history handler, but only mount it AFTER
 * integrating a real session verifier as resolveVerifiedPrincipal.
 * Request userId/claimedUserId/identityVerified arguments are NEVER used.
 * A case receipt proves case possession, not identity; it is not accepted.
 */
export function createVerifiedHistoryHandler({ db, resolveVerifiedPrincipal, clock = () => Date.now() } = {}) {
  if (!db?.prepare || typeof resolveVerifiedPrincipal !== 'function') {
    throw new TypeError('Trusted DB binding and verified principal resolver required');
  }
  return async function handleVerifiedHistory(request) {
    if (request.method !== 'GET') return resultJson({ ok: false, error: 'Method Not Allowed' }, 405);
    let principal;
    try {
      principal = await resolveVerifiedPrincipal(request);
    } catch {
      return resultJson({ ok: false, identityVerified: false, error: 'Authentication unavailable' }, 503);
    }
    const subject = verifiedSubject(principal, Math.floor(clock() / 1000));
    if (!subject) return resultJson({ ok: false, identityVerified: false, error: 'Authentication required' }, 401);
    try {
      const notices = await loadSubjectNotices(db, subject);
      return resultJson({
        ok: true,
        identityVerified: true,
        hasHistory: notices.length > 0,
        notices,
      });
    } catch {
      // Fail closed. Never fall back to a client-supplied Roblox UserId.
      return resultJson({ ok: false, identityVerified: false, error: 'Verified history unavailable' }, 503);
    }
  };
}

export const stage1680TestContract = Object.freeze({ noticeSQL: NOTICE_SQL, historySQL: HISTORY_SQL });
