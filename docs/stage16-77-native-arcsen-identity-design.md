# Stage16.77 — Native Arcsen Sender Identity (design correction)

Date: 2026-11-17 (Asia/Bangkok). Status: native sender preview prepared; backend identity authentication NOT yet implemented. Production NO-GO.

## Why the Browser Bridge is not sufficient

A Cloudflare Access/Turnstile-protected web form can accept Feedback/Appeal, but this does not prove the identity of the Roblox account that submitted it. Case ID + Receipt proves possession of a case-management credential, not the sender's Roblox identity. Names or UserIds asserted by a modified Luau client can be spoofed.

## Native UI correction

Arcsen UIs v7.3.41 was derived from the preserved v7.3.40 client and adds a **SenderIdentityPreview** frame within **Settings → ArcScriptCenter → Feedback & Appeal**. It shows `LocalPlayer.DisplayName`, `@LocalPlayer.Name`, and `LocalPlayer.UserId` with the explicit warning **Unverified by Server — not valid for Admin enforcement**. It removes the browser-handoff option from the main Arcsen UI while retaining Feedback and Appeal draft forms, original STAGING submit/status/edit/remove flows, private receipts, user-designed 350px nested Violation/Appeal UI, and Admin-only Spam Mail separation.

Client artifact: `Arcsen_v7.3.41_NativeSender_Preview_STAGING.lua` and corresponding patch, generated in ChatGPT. Static source checks passed. **Roblox client runtime QA still pending**. No Cloudflare Worker or Production deployment was changed for Stage16.77.

## Required trusted identity path

For a universal Arcsen/sUNC client, prefer explicit Roblox OAuth 2.0/OpenID Connect identity consent (browser once for account linking, not for Feedback form). After successful server-side authorization, store the validated Roblox UserId (OIDC `sub`), and display name/username as public metadata. Issue an appropriately scoped, expiring session, enforce case ownership and per-account quotas, and do not place OAuth client secrets or privileged keys inside Lua, browser URLs, or public GitHub.

For a Roblox experience you control, a trusted server could instead derive the Player identity and authenticate server-to-server using private secrets. That method is not available universally when client code runs in arbitrary third-party experiences.

Show **Verified** to Admin only for a server-attested identity; unverified client metadata must never be used to ban an asserted Roblox account. Avoid collecting unrelated email, age, IP, passwords or OTPs.

Cloudflare Turnstile itself requires browser-side JavaScript and Siteverify. A pure Luau HTTP request cannot complete it. Maintain server-side abuse prevention in any native submission path rather than silently bypassing Turnstile.

## Outstanding

- Set up or validate Roblox OAuth application (minimal openid scope; operator controls secret)
- Add server authorization/session endpoints in isolated Sandbox
- Connect native Submit/Status/Edit/Remove to verified identity; preserve Receipt privacy
- Verify Admin identity labels and spoofing-rejection checks
- Run Roblox mobile UX checks and full QA
- Production release remains NO-GO

References:
- https://create.roblox.com/docs/cloud/auth/oauth2-overview
- https://create.roblox.com/docs/cloud/auth/oauth2-reference
- https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/
