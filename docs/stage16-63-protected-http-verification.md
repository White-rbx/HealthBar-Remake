# Stage 16.63 — Protected Sandbox HTTP Verification

This is a sandbox-only test note; the `main` branch, Production Cloudflare Worker, D1 and Pages remain unchanged.

- Sandbox Worker: `arcscriptcenter-merge-sandbox-1658`
- Version: `0.5.70.0-turnstile-sandbox-test` (official **dummy** Turnstile test keys only)
- Cloudflare Access: Worker-scoped self-hosted application, reusable allow policy for one authorized tester
- Sandbox workers.dev enabled **behind Access**; preview URLs remain disabled

## Observed browser result — 2026-11-15 (Asia/Bangkok)

**PASS — Authenticated health flow, user-confirmed.** The tester reported encountering the Cloudflare Access verification page and, after completing the verification, receiving the live JSON response:

```json
{"ok":true,"service":"ArcScriptCenter","version":"0.5.70.0-turnstile-sandbox-test","status":"online","database":"connected"}
```

This confirms the authorized browser's Access-to-Worker-to-D1 health flow. It **does not** independently confirm whether an unauthenticated incognito session was denied, whether an unauthorized identity is denied, or whether Feedback/Turnstile submit endpoints work live. The testing assistant cannot make direct external HTTP requests to the protected Worker via the connector.

## Outstanding manual smoke tests

1. In a new private/incognito browser with no Access session, open `https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/api/v1/health`.
2. Before authentication, the API health JSON must **not** be visible; Access login or denial must be shown.
3. Confirm an identity not on the allow policy is denied (do not use/share any credentials with ChatGPT).
4. With the authorized tester already signed in, verify the exact health JSON version and database fields.
5. Test HTTP error contracts and feedback/Turnstile only with synthetic cases after an agreed protected test procedure. Keep test receipts and Access/Admin credentials private.

## Release gate

**Production: NO-GO.** Do **not** promote until the anonymous/unauthorized access checks pass, Siteverify is tested with **real** Turnstile keys under the correct hostname and action (dummy keys do not provide anti-spam security), browser/Arcsen integration is finished, live Feedback API negative/positive paths pass, and an independently restorable Production D1 backup has been verified.
