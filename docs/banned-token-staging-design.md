# BANNEDTOKEN — STAGING design (not deployed)

Format: `BANNTOKEN_XXXXXXXXXXXX-XXXXXXXXXXX#XXXXXX` (the user's specified spelling is retained).
- Segment 1: 12-character server-HMAC pseudonym of Roblox UserId.
- Segment 2: 11-character server-HMAC pseudonym of UserId and username.
- Segment 3: six randomly generated uppercase hexadecimal characters.
- Client display: only `••••XX`, showing the last two HEX characters. No Copy button.
- Full token and HMAC secret are server-only; do not include them in Luau, responses, browser pages, telemetry, or logs.
- Segment 1 and segment 2 are **not** two-factor authentication. Public Roblox account attributes do not prove ownership.
- The masked reference is **not** authorization or proof of identity. It only helps users identify a restriction notice.
- A server-side trusted account/case binding must authorize Violation/Appeal independently. The currently deployed public policy lookup and unverified LocalPlayer.UserId are insufficient.
- Server must track case status, expiry, revocation, history, and appeal eligibility. Recheck writes atomically.
- A username change must not orphan a case: canonical case ownership is keyed to a trusted stable Roblox UserId, not the username segment.
- The six-HEX suffix can collide; regenerate on collision if enforcing uniqueness in a scoped table. Do not rely on the suffix as a secret.
- Keep USERCASETOKEN separate for Feedback. Never infer Violation ownership from USERCASETOKEN.
- UI should receive a server-generated masked reference only; avoid client-side masking of the full token.
- No new endpoint or database migration is included. Integration requires independent verified-principal and case-issuance design review.

Implementation primitives: `sandbox/banned-token-staging.mjs`. This is **not** connected to the Cloudflare Worker, Arcsen UI, or D1 yet.
