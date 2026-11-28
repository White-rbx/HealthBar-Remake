# ArcScriptCenter — recovered original Achievements criteria

Recovered from the owner discussion dated 2026-11-12. This records the existing Phase 3 scope, not a new phase or an authorization to deploy.

| Category | Name | Threshold |
| --- | --- | --- |
| Daily Streak | Beginner | 1 day |
| Daily Streak | User | 5 consecutive days |
| Daily Streak | Member | 10 consecutive days |
| Daily Streak | Enjoyer | 15 consecutive days |
| Daily Streak | Juror ArcScript Member | 20 consecutive days |
| Usage Time | First Hour | 1 accumulated hour |
| Usage Time | Three Hours | 3 accumulated hours |
| Usage Time | Seven Hours | 7 accumulated hours |
| Usage Time | Ten Hours | 10 accumulated hours |
| Usage Time | First Day | 24 accumulated hours |
| Usage Time | Member | 240 accumulated hours |
| Usage Time | ArcScript Member | 720 accumulated hours |
| Feedback | First sent | First submitted Feedback |
| Feedback | Bug Hunter / Supporter | 5 approved Feedback entries |

Total: 14. The final feedback label is retained as recovered; do not create a fifteenth award or invent rewards.

- A missed day resets the current streak; earned badges remain.
- Usage time is accumulated, not a continuous session.
- The Worker verifies awards; Cloudflare D1 is authoritative, not client JSON.
- Display earned badges on the website and Arcsen Leaderboard.
- Keep account ownership and moderation authorization server-side. Do not accept client-supplied duration, streak or feedback approval counts as evidence. Count distinct verified feedback records; deduplicate overlapping or replayed sessions.
- No requirement for engagement reminders, notifications or new collection of personal information.

## Candidate scope

The pure evaluator and threshold tests are QA-only. Internal IDs are distinct across categories. The candidate does not create D1 tables, award live badges, expose HTTP routes, or change any worker. The day boundary/timezone, trusted account-bound analytics mapping, storage migration, permissions and display integration still need verification against existing infrastructure. Preserve opt-in leaderboard privacy. No Production change or PR merge.
