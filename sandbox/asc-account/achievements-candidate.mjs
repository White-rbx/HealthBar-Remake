// Isolated QA candidate. This is a pure evaluator, not an HTTP endpoint.
// Only a trusted server-side caller may supply account-bound verified counters.
const rows = [
 ['streak_beginner','Daily Streak','Beginner','streakDays',1],
 ['streak_user','Daily Streak','User','streakDays',5],
 ['streak_member','Daily Streak','Member','streakDays',10],
 ['streak_enjoyer','Daily Streak','Enjoyer','streakDays',15],
 ['streak_juror','Daily Streak','Juror ArcScript Member','streakDays',20],
 ['usage_first_hour','Usage Time','First Hour','usageSeconds',3600],
 ['usage_three_hours','Usage Time','Three Hours','usageSeconds',10800],
 ['usage_seven_hours','Usage Time','Seven Hours','usageSeconds',25200],
 ['usage_ten_hours','Usage Time','Ten Hours','usageSeconds',36000],
 ['usage_first_day','Usage Time','First Day','usageSeconds',86400],
 ['usage_member','Usage Time','Member','usageSeconds',864000],
 ['usage_arcscript_member','Usage Time','ArcScript Member','usageSeconds',2592000],
 ['feedback_first_sent','Feedback','First sent','feedbackSent',1],
 ['feedback_approved_five','Feedback','Bug Hunter / Supporter','feedbackApproved',5],
];
export const achievements = Object.freeze(rows.map(([id,category,label,metric,threshold]) =>
 Object.freeze({id,category,label,metric,threshold})));
export function evaluateAchievements(counters, existingIds = []) {
 if (!counters || typeof counters !== 'object' || !Array.isArray(existingIds)) throw new TypeError('invalid server snapshot');
 for (const key of ['streakDays','usageSeconds','feedbackSent','feedbackApproved']) {
  if (!Number.isSafeInteger(counters[key]) || counters[key] < 0) throw new TypeError('invalid server counter');
 }
 if (counters.feedbackApproved > counters.feedbackSent) throw new TypeError('inconsistent feedback snapshot');
 const existing = new Set(existingIds);
 return achievements.filter(a=>existing.has(a.id)||counters[a.metric]>=a.threshold).map(a=>a.id);
}
