// Isolated QA only: no public endpoint and no client-provided counters.
// The caller must obtain accountId from a verified account context.
import {achievements} from './achievements-candidate.mjs';
const feedbackAwards=achievements.filter(a=>a.category==='Feedback');
export async function awardVerifiedFeedback(db,accountId,now){
 if(typeof accountId!=='string'||!accountId||!Number.isSafeInteger(now)||now<0)throw new TypeError('invalid verified account context');
 // Count account-native feedback rows with details. Unlinked legacy cases,
 // appeals, bans and client-reported numbers cannot grant these awards.
 // One D1 batch is atomic; the primary key prevents duplicate grants.
 return db.batch(feedbackAwards.map(a=>db.prepare(`
  INSERT INTO asc_account_achievements(account_id,achievement_id,earned_at)
  SELECT ?,?,? WHERE (
   SELECT COUNT(*) FROM asc_account_cases c
   JOIN asc_account_feedback_details f ON f.case_id=c.id
   WHERE c.account_id=? AND c.kind='feedback'
    AND c.legacy_source IS NULL AND c.legacy_id IS NULL
    AND (?=0 OR c.status='approved')
  )>=?
  ON CONFLICT(account_id,achievement_id) DO NOTHING
 `).bind(accountId,a.id,now,accountId,a.metric==='feedbackApproved'?1:0,a.threshold)));
}
export async function readAccountAchievements(db,accountId){
 if(typeof accountId!=='string'||!accountId)throw new TypeError('invalid verified account context');
 const rows=await db.prepare('SELECT achievement_id,earned_at FROM asc_account_achievements WHERE account_id=? ORDER BY earned_at,achievement_id').bind(accountId).all();
 const catalog=new Map(achievements.map(a=>[a.id,a]));
 return (rows.results||[]).filter(r=>catalog.has(r.achievement_id)).map(r=>({
  id:r.achievement_id,label:catalog.get(r.achievement_id).label,category:catalog.get(r.achievement_id).category,earnedAt:r.earned_at,
 }));
}
