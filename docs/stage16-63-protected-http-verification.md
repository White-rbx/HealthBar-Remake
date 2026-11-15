# Stage 16.63 — Protected Sandbox HTTP Verification

This is a sandbox-only test note; the `main` branch, Production Cloudflare Worker, D1 and Pages remain unchanged.

- Sandbox Worker: `arcscriptcenter-merge-sandbox-1658`
- Version: `0.5.70.0-turnstile-sandbox-test` (uses only official dummy Turnstile testing keys)
- Cloudflare Access: Worker-scoped self-hosted application, reusable allow policy for one authorized tester
- Sandbox workers.dev enabled **behind Access**; preview URLs remain disabled

## Manual smoke test

1. In a private/incognito browser, visit `https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/api/v1/health`.
2. Without Access authentication the API health JSON **must not** be visible; the visitor should see the Access login or an Access denial.
3. With the tester identity authenticated via Access, the health JSON should show `database: connected` and version `0.5.70.0-turnstile-sandbox-test`.
4. A different identity must not be allowed. Do not paste passwords, cookies, Access tokens, Admin Keys or receipts in issues or logs.

**NOT YET VERIFIED:** This conversation's tools cannot reach the protected URL over HTTP, so browser E2E has not been claimed or performed.

## Release gate

Do **not** promote to Production until access control has been verified in a browser, Siteverify is tested with real Turnstile keys on the correct hostname/action, the browser/Arcsen flow is integrated, and an independently restorable Production D1 backup exists.
