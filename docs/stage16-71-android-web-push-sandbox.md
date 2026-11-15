# ArcScriptCenter — Stage 16.71: Android System Push Notifications (Sandbox Pilot)

Date: 2026-11-15 (Asia/Bangkok)
Status: **Deployed to Sandbox and statically checked. Real Android browser/FCM push delivery tests PENDING.**
Production: **NO-GO.**

## Feature clarification

The requested alert is a genuine **Android OS notification** (Notification Shade / Lock Screen where permitted), including after the private Admin tab closes — not the Stage 16.70 in-page toast/browser Notification while the tab is open.

Uses standards-based **Web Push + Service Worker + VAPID**, targeted at Android Chrome. Web Push can wake a service worker in background on Android. Android/browser notification permission, internet connectivity, push-service reliability, OS energy policies and user settings affect eventual delivery.

Android setup: Open the protected Sandbox page using Chrome on Android, sign in via Cloudflare Access, enter the **existing Admin Key locally into the page only**, choose Connect, choose **Enable Android Notification** and accept the Chrome notification permission request. Choose **Send Test Android Push** and verify that an Android system notification actually appears. Close the tab and repeat with a new authorized Sandbox Feedback/Appeal submission. Do not supply Admin Keys, Push Subscription endpoints, Access tokens or credentials to the assistant or GitHub.

Setup page:
https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev/__stage1671/android-push

## Sandbox deployment details

- Worker: `arcscriptcenter-merge-sandbox-1658`.
- Version string: `0.5.75.1-android-web-push-sandbox`.
- Active Worker version ID: `b4fcec37-b3d8-43ed-bdd4-599b66f474cb` at 100% Sandbox traffic.
- Deployment ID: `b2c63927-7ac7-4082-9b36-8b26134f59f4`.
- Previous Sandbox version (no Web Push) remains available for rollback.
- Ten bindings: the previous eight preserved, plus `ASC_PUSH_VAPID_PRIVATE_JWK` (new `secret_text` value, generated during the version upload inside the Cloudflare tool and **not returned in tool outputs or committed**) and `ASC_PUSH_VAPID_PUBLIC_KEY` (plain public key).
- Additional D1 table: `asc_admin_push_subscriptions_v1` **in Sandbox D1 only**, to store a limited number of authorized push endpoints, their hashes, timestamps and de-duplication state. No existing production/staging D1 schemas or Worker deployments changed.
- D1 preflight checked the sandbox binding and Time Travel bookmark before table creation.

## HTTP endpoints and security

Protected Sandbox frontend:
- `GET /__stage1671/android-push`: enable/test/disable Android push, requires Cloudflare Access.
- `GET /__stage1671/sw.js`: same-origin Service Worker script with scope `/__stage1671/`; push event displays a native notification. Notification click opens the protected Admin Notifications page.
- `GET /__stage1671/key`: requires Cloudflare Access and existing `X-Admin-Key`; returns only the **public** VAPID key.
- `POST /__stage1671/subscription`: same-origin, requires Access + Admin Key and JSON action `subscribe`, `test` or `unsubscribe`.

Server limits stored active endpoints to **three** and accepts only HTTPS Google FCM endpoints on `fcm.googleapis.com`, with recognized Web Push path prefixes. This prevents arbitrary outbound addresses. Test sends are limited to once per registered endpoint per 60 seconds and do not create Feedback/Appeal records.

A successful Sandbox Feedback/Appeal submission schedules a background send via `ctx.waitUntil` **after D1 commit**. The service worker shows a generic Thai notification indicating a new Feedback or Appeal. There is **no push payload with user-provided text, identity, receipt, or complaint description**. Web Push uses a VAPID-signed request without a payload, so no encrypted-payload library is needed. The browser gets the push event and generates the generic visible notification locally.

On the browser, the Admin Key is held only in page JavaScript memory, cleared from the input after Connect and from memory on Disconnect. Unsubscribe removes the subscription from the server and browser. The subscription endpoint is a sensitive push capability and is stored in the **private Sandbox D1 table**, not in public code, logs, or GitHub.

## Verification performed

- New code uploaded and active in the Sandbox Worker; Cloudflare deployment confirmed 100% to the intended Worker.
- All ten binding names and types read back; new private key binding is a `secret_text`, value not read or disclosed.
- Sandbox D1 table exists and initial subscription count = **0**; Time Travel bookmark available.
- Read-back static checks confirmed page route, Service Worker route, browser registration and `navigator.serviceWorker.ready`, push-event handler, `registration.showNotification`, CSP `worker-src 'self'`, FCM endpoint validation, Admin Key and Access guards, notification logic wired to BOTH existing Feedback submit routes after commit, and no complaint text in push notification messages.
- No user device is registered yet: **real push send / receipt on Android has NOT been demonstrated**. Do not mark as end-to-end PASS.
- Stage 16.64/16.66/16.67/16.70 existing routes preserved.

## Outstanding user validation

1. Authorized Android Chrome page opens after Access login.
2. Existing Admin Key authenticates locally; browser supports Push API and service workers.
3. Android notification permission accepted; subscription registration returns success.
4. `Send Test Android Push` succeeds (Web Push service accepts request) and **Android OS actually displays a system notification**.
5. Close tab; create one **authorized synthetic Sandbox Feedback or Appeal** and verify **background notification on Android**. Clean any marked synthetic records after the test.
6. Disable Push and confirm no additional notifications to that device.

**Important:** Receiving push after closing a tab cannot be simulated convincingly through Cloudflare configuration checks alone; an actual Android device must confirm it. Notifications may be delayed or suppressed by battery/permission policies. Existing Admin in-page notifications remain available as fallback.

## Release gates

Production is still **NO-GO** pending verified Android delivery, explicit user permissions, independent Production backup restoration to an isolated destination, schema/code compatibility, the remaining Access denied-identity check and signed-off rollout.

References:
- https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Guides/Offline_and_background_operation
- https://www.w3.org/TR/push-api/
- https://developers.cloudflare.com/workers/configuration/cloudflare-access/
