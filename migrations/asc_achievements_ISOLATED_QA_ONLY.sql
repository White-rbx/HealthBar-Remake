-- Additive isolated-QA candidate. Do not apply to production.
CREATE TABLE IF NOT EXISTS asc_account_achievements (
 account_id TEXT NOT NULL REFERENCES asc_accounts(id),
 achievement_id TEXT NOT NULL CHECK(achievement_id IN ('streak_beginner','streak_user','streak_member','streak_enjoyer','streak_juror','usage_first_hour','usage_three_hours','usage_seven_hours','usage_ten_hours','usage_first_day','usage_member','usage_arcscript_member','feedback_first_sent','feedback_approved_five')),
 earned_at INTEGER NOT NULL CHECK(earned_at >= 0),
 PRIMARY KEY(account_id,achievement_id)
);
