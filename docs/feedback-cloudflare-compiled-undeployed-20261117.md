# Cloudflare-validated Production Candidate — Undeployed Version

**Date:** 2026-11-17 · **Release gate:** Syntax/upload accepted, **not deployed**, runtime data-flow acceptance still pending.

## Confirmed Cloudflare Workers Version upload

Cloudflare's authorized account API received a **review-only, unbound Worker module** assembled **in memory** from exact live Production and STAGING Worker source files. Both source SHA-256 pins were checked before assembly. No private source bytes or bindings/secret values were written into GitHub.

| Evidence | Result |
|---|---|
| Production Worker source SHA-256 | `036a9f2410e877b51f5293315103e8a8f62ad940fb3f9e8d4efd0bd7e13e0a48` (matched) |
| STAGING Worker source SHA-256 | `cbfad72cedb65247d49bc20e203e2f19769372f6ebc39474e86239102e4cdd62` (matched) |
| Combined review Worker SHA-256 | `8c67a2b1c4b3a916b843175c5b78ec324186ab48f74f96b2a2250af254f08928` |
| Candidate bytes (UTF-8) | **106,382** |
| Added route-handler clauses | **15** |
| Existing Production ban-check route | Preserved in source |
| Legacy global STAGING feedback quota | Removed from candidate |
| New HMAC D1 rate guard | Included in candidate |
| Worker receiving QA-only version | `arcscriptcenter-merge-sandbox-1658` |
| **Undeployed** version ID | `c066e912-3623-4c00-9c04-1184559a1b77` |
| Version annotations | `ASC-QA-NO-DEPLOY`, explicit warning |
| Version's D1/Secret bindings | **0** |
| Existing active Sandbox version | `bc4e8484-8901-4e0a-9d19-a20120f59ac8` at **100%** |
| New QA-only version active traffic | **0%** |
| Production and STAGING Worker/Pages/D1 deployment changes | **None** |

**Exact meaning of pass:** Cloudflare accepted the full combined Worker module through the official `POST /accounts/{account_id}/workers/scripts/{script_name}/versions` API. This uploads a version **without deploying it**; it proves successful API-side module acceptance, not that all application routes, secrets, D1 queries or Edge trust behave correctly at runtime.

Cloudflare then confirmed by a separate authenticated read that the new version existed, had its `QA-NO-DEPLOY` annotation, had no bindings, and did **not** replace the existing active Sandbox version.

## Safety and remaining test gates

1. The combined Worker has **NOT** been deployed to the existing Production, STAGING or Sandbox active endpoints. Do not hand out a fake live-testing URL.
2. The new rate guard has **NOT** been invoked end-to-end with a legitimate native Arcsen request and trusted Cloudflare Edge metadata. Its intended Production-only hostname check currently prevents testing on a different hostname without an separately reviewed Sandbox-specific variant.
3. The **isolated synthetic D1** `asc-feedback-release-qa-20261117` previously passed live D1 schema and HMAC-upsert checks; the Candidate Version uploaded here deliberately has **no DB or secret bindings** and therefore does not provide a connected runtime demonstration.
4. The actual Production D1 has no Feedback schema, so migration review/authorization is mandatory before any eventual release.
5. Confirm Host, CORS, Admin-only access, Receipt-scoped status/edit, anti-abuse, operational cleanup of rate windows and missing secret fail-closed using a separately authorized live Preview and synthetic data.
6. Do not merge or deploy without **explicit owner approval** and recovery/rollback acceptance. The earlier logical D1 restore check is documented but is not a full downloadable SQL import test.

## Test documents

- `docs/feedback-all-three-release-qa-20261117.md` — combined Anti-spam, Candidate, isolated D1 and rollback plan.
- `docs/feedback-production-code-review-20261117.md` — verified source/schema differences and security findings.
- `migrations/feedback_release_additive_REVIEW_ONLY_20261117.sql` — additive, source-attested draft.
- `sandbox/feedback-release-candidate-builder.mjs` and `sandbox/feedback-release-rate-guard.mjs` — reviewed source-only tools, not cloud deployment scripts.

**This is a material QA improvement: full Worker source accepted by Cloudflare, zero live deployment impact.** It is not Production launch authorization.
