# ESLogin Stage 7 — Roblox Loader / Cloudflare Access boundary (2026-11-26)

**State:** PARTIAL / AUTHENTICATION PATH BLOCKED — do **not** claim mobile Roblox pairing, Loader continuation, Remember or Rejoin PASS.

## Existing verified pieces

- GitHub PR #16 remains Draft on `feedback-appeal-release-track`.
- `sandbox/LoaderMainPreview.lua` has a separate opt-in `account_qa` path that loads `sandbox/ESLogin.lua` followed by `sandbox/ASCAccountClientPreview.lua`; it does not continue to SetUp/Main unless `account.profile()` was server-verified.
- `sandbox/ESLogin.lua` retains X cancellation and a browser website handoff. The account adapter pins `https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev` and only uses isolated QA Account API routes.
- Real Android Chrome web Passkey enrollment and login were observed in Stage 6, but Chrome's Cloudflare Access identity **does not authenticate Roblox's independent HTTP transport**.
- Read-only isolated D1 aggregate at Stage 7: **1 account, 1 registered Passkey, 0 Loader sessions, 0 pairing rows**. This does not prove a Roblox pairing ever completed.
- Independent STAGING Worker Version 10 `d615ff9c-7631-499e-9031-b1b2ca2b96d5` remains at 100%. Cloudflare Access allows only one explicitly authorized QA email; `options_preflight_bypass=false`, no Everyone allow. Original Account QA stays Version 10 `6b9420db-381c-4d53-8692-a82b76399b52` 100%; Production is unchanged.

## Stage 7 fail-closed implementation

- `sandbox/ASCAccountClientPreview.lua`: classify HTTP 3xx redirects, Access login Location headers and followed Cloudflare Access HTML as `access_required`. Do not parse an Access login page as the Account JSON API; do not set a Roblox account identity or issue a Loader session.
- `sandbox/ESLogin.lua`: explain that Roblox HTTP cannot reuse Chrome's Access sign-in. Stop retrying pair/poll after `access_required`. Login's X still cancels and prevents downstream Loader.
- `sandbox/loader-main-preview.test.mjs`: static guard for fail-closed Access logic, no Access cookie/service-token injection and Loader bootstrap requiring a verified account.
- `sandbox/ban-v2-native-luau.test.mjs`: Luau VM checks 302/303, followed Access HTML, explicit Access Location, normal API JSON and unrelated HTML.
- CI workflow's live negative probe is named **anonymous Access denial** (not misleadingly “DENY ALL” with a limited Allow policy).
- Commits: `2f3894069d451b7cd7331b731d2b3ef8703c5dda` (client/UI/tests/workflow), `c1686d19d417aa3b6dddfba33daa3a69143db771` (Luau VM test).
- Changes are **GitHub-only**: do not deploy to Worker or change Access for Stage 7.

## Gate to make pairing actually work

Under the present Access email-only policy, an independent Roblox HTTP client without its own authorized Access identity receives Access denial even if the browser is logged in. A safe transport design must be chosen, implemented and audited before attempting live pairing. Do not copy browser cookies, Passkey material, Recovery Codes or Cloudflare service credentials into Luau, client-side Roblox assets, GitHub, console logs or executor storage.

An authorized trusted-server test design can be evaluated separately (e.g. a Roblox Studio game-owner test server with authenticated owner-controlled backend and per-session binding); it is **not** implemented here and is not automatically compatible with universal third-party games. Avoid treating `LocalPlayer.UserId`, website login alone, a pasted pairing code, or a locally forged token as account identity verification.

When the authenticated Roblox transport is available, complete the sequence with a synthetic test account:
1. Signed browser Passkey session; obtain an unexpired, one-time pair request from Roblox without Access bypass.
2. Approve *that* code only in the browser and poll to a verified Loader session, with no code/token logging.
3. Check session expiration, timeout, X cancellation, Rejoin/Remember ON/OFF, Logout and revocation against a real Roblox mobile client.
4. Confirm SetUp/Main only proceeds for the server-verified account and restricted modes remain enforced. Check no D1/Production crossing.

## Outstanding status

- Stage 6: Android registration/login/session PASS; backup on an independent authenticator and live Recovery remain blocked/pending.
- Stage 7: UI/Loader wiring and Access-denial diagnosis addressed; **real Roblox pairing, Loader continuation and rejoin remain BLOCKED**.
- Stage 9: NO-GO. PR #16 remains Draft.
