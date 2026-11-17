# ArcScriptCenter — Stage 16.78: Violation Notice Visibility

Date: 2026-11-17 (Asia/Bangkok)
Status: **Arcsen UIs 7.3.42 client patch prepared; Roblox mobile runtime QA pending.**
Scope: Lua client only. **No Worker, D1, secret, Production, or Staging deployment changes.**

## User-requested correction

The user's Roblox screenshot showed `Feedback & Appeal → Violation` as an ordinary expandable category even while the signed UI policy displayed `not_banned`. Opening it displayed a blue `No violation notice available` card. This is undesirable: Violation is a conditional, actual moderation **notice**, not an always-visible Settings category.

## Client change

Derived from the user-visible v7.3.41 Arcsen client:
- Removed `o(panelScroll, ..., "Violation")`, its Open/Close category wrapper, and its unconditional presence in the settings list.
- Preserved the original developer-designed `buildViolationUI`, all nested controls, the fixed 350px ScrollingFrame, and Appeal **inside** the notice.
- Added `initiallyHidden=true` during creation so the viewport never appears even transiently before layout; standalone `VerifiedViolationNotice` is not visible by default.
- Removed public client preview entry points, avoiding accidental appearance of a fabricated violation.
- `Signed UI Policy` responses are **advisory** (`identityVerified=false`) and cannot trigger a confirmed violation just because a self-asserted UserId has a signed status.
- The existing Feedback/Appeal draft, Session Receipt, STAGING Submit/Status/Edit/Remove UI, native sender preview, and Settings remain available.
- A private `renderAuthenticatedViolation(details,identityVerified)` UI hook was prepared, but intentionally **not invoked**. It will need an **authenticated, account-bound, server-supplied** record with ID, reason, and moderator message before it can become the real automatic notice pathway. Passing `true` from Lua or displaying LocalPlayer data alone is insufficient.

## Validation

Static checks passed:
- No `o()` Violation category
- Hidden before `Parent` assignment
- 350px notice remains intact
- Appeal controls retained only in Violation viewport
- Public preview disabled; advisory ban cannot show confirmed violation
- No new HTTP/API endpoints, Worker deployments, or credential exposure

Roblox client runtime verification and backend identity attestation are **not** yet complete. Do not claim verified-violation auto-display works until server identity/provenance is implemented and tested.

## Deliverable

ChatGPT generated `Arcsen_v7.3.42_Violation_Only_When_Verified_STAGING.lua` and a companion unified patch based on the existing Arcsen v7.3.41 artifact.

## Next integration

The service must support authenticated Roblox identity (e.g. OAuth/OpenID Connect with server-side verification) and a user-bound violation record. Once that exists, the trusted response can route the verified ban notice into the private notice renderer and automatically open Settings → Feedback & Appeal. The user-visible `Violation` category should **not** return.

Production remains NO-GO.
