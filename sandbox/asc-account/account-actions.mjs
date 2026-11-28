const uuid = /^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/;
const activeWeb = `
 SELECT 1 FROM asc_account_sessions s JOIN asc_accounts a ON a.id=s.account_id
 WHERE s.id=? AND s.account_id=? AND s.scope='web' AND s.revoked_at IS NULL
 AND s.expires_at>?`;
const memberSession = `EXISTS (${activeWeb} AND a.status<>'banned')`;
const moderatorSession = `EXISTS (${activeWeb} AND a.status='normal')`;

export function mayModerate(account, env) {
 return account.status === 'normal' && typeof env.ACCOUNT_MODERATOR_IDS === 'string'
  && env.ACCOUNT_MODERATOR_IDS.split(',').includes(account.id);
}

export function readAction(body) {
 if (body.action === 'revoke_session' && typeof body.id === 'string' && uuid.test(body.id)) {
  return {action:body.action, id:body.id};
 }
 if (typeof body.message !== 'string' || body.message.length > 2000) return null;
 if (body.action === 'review_case' && typeof body.caseId === 'string' && uuid.test(body.caseId)
   && ['approved','denied'].includes(body.decision)) {
  return {action:body.action, caseId:body.caseId, decision:body.decision, message:body.message};
 }
 if (body.action === 'set_status' && typeof body.target === 'string' && uuid.test(body.target)
   && ['normal','restricted_mode','banned'].includes(body.status)
   && typeof body.reason === 'string' && body.reason.trim() && body.reason.length <= 1500) {
  return {action:body.action, target:body.target, status:body.status, reason:body.reason.trim(), message:body.message};
 }
 return null;
}

export async function executeAction(db, account, action, now, env) {
 const actor = [account.session_id, account.id, now];
 if (action.action === 'revoke_session') {
  // The separately supported logout operation handles the current browser.
  if (action.id === account.session_id) return false;
  return Boolean(await db.prepare(`
   UPDATE asc_account_sessions SET revoked_at=?
   WHERE id=? AND account_id=? AND scope IN ('web','loader')
   AND revoked_at IS NULL AND expires_at>? AND EXISTS (${activeWeb})
   RETURNING id
  `).bind(now, action.id, account.id, now, ...actor).first());
 }
 if (!mayModerate(account, env)) return false;
 if (action.action === 'review_case') {
  return Boolean(await db.prepare(`
   UPDATE asc_account_cases SET status=?,moderator_message=?
   WHERE id=? AND status='reviewing' AND ${moderatorSession}
   RETURNING id
  `).bind(action.decision, action.message, action.caseId, ...actor).first());
 }
 if (action.action !== 'set_status') return false;
 const kind = action.status === 'banned' ? 'ban' : 'violation';
 const [update] = await db.batch([
  db.prepare(`
   UPDATE asc_accounts SET status=? WHERE id=? AND status<>? AND ${moderatorSession} RETURNING id
  `).bind(action.status, action.target, action.status, ...actor),
  db.prepare(`
   INSERT INTO asc_account_cases(id,account_id,kind,reason,moderator_message,created_at)
   SELECT ?,id,?,?,?,? FROM asc_accounts WHERE id=? AND changes()=1 AND ?<>'normal'
  `).bind(crypto.randomUUID(), kind, action.reason, action.message, now, action.target, action.status),
 ]);
 return Boolean(update.results?.length);
}

export function feedbackInput(body) {
 if (typeof body.topic !== 'string' || typeof body.description !== 'string') return null;
 const topic = body.topic.trim(), description = body.description.trim();
 if (topic.length < 3 || topic.length > 50 || description.length < 50 || description.length > 1500) return null;
 return {topic, description};
}

export async function submitAccountFeedback(db, account, input, now) {
 const id = crypto.randomUUID();
 const [created] = await db.batch([
  db.prepare(`
   INSERT INTO asc_account_cases(id,account_id,kind,status,reason,created_at)
   SELECT ?,?,'feedback','reviewing',?,? WHERE ${memberSession} RETURNING id
  `).bind(id, account.id, input.description, now, account.session_id, account.id, now),
  db.prepare(`
   INSERT INTO asc_account_feedback_details(case_id,topic)
   SELECT id,? FROM asc_account_cases WHERE id=? AND changes()=1
  `).bind(input.topic, id),
 ]);
 return created.results?.[0]?.id;
}

export async function manageAccountFeedback(db, account, body, now) {
 if (typeof body.id !== 'string' || !uuid.test(body.id)) return null;
 const input = body.action === 'edit' ? feedbackInput(body) : null;
 if (!input && body.action !== 'remove') return null;
 const [updated] = await db.batch([
  db.prepare(`
   UPDATE asc_account_cases SET status=?,reason=COALESCE(?,reason)
   WHERE id=? AND account_id=? AND kind='feedback' AND status='reviewing'
   AND EXISTS (SELECT 1 FROM asc_account_feedback_details WHERE case_id=?)
   AND ${memberSession} RETURNING id
  `).bind(input ? 'reviewing' : 'closed', input?.description ?? null, body.id, account.id,
    body.id, account.session_id, account.id, now),
  db.prepare(`
   UPDATE asc_account_feedback_details SET topic=?
   WHERE case_id=? AND changes()=1 AND ? IS NOT NULL
  `).bind(input?.topic ?? null, body.id, input?.topic ?? null),
 ]);
 return Boolean(updated.results?.length);
}
