# Isolated achievement storage candidate

Additive migration only. Account achievements use an account-scoped unique key and retain the first award timestamp. The feedback award helper reads native account feedback case rows and details from D1; the approval count comes from existing moderator-reviewed status, never from a client request. Legacy cases are excluded pending verified linking. The helper is not connected to a route or live worker yet.

Next integration must use an authenticated server-side account context, verify revocation/authorization, and keep private awards separate from public leaderboard consent. Usage/streak calculations still require trusted session aggregation, day-boundary policy and replay/concurrency handling. No real awards are issued; no database migration or deployment authorized by this candidate.
