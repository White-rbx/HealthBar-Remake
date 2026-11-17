# Stage 16.85 — Mobile Browser Pairing Consent UX Specification

Status: **UX contract / draft only**, not a deployed page. Existing ExperienceSettings UI remains owned by the project designer.

## Safety message (Thai default)

**ยืนยันการจับคู่ Arcsen**

“ให้อนุมัติเฉพาะรหัสที่ปรากฏบน Arcsen ในอุปกรณ์ของคุณเองเท่านั้น อย่าใช้รหัสที่คนอื่นส่งมาให้ในแชทหรือเว็บไซต์อื่น หากคุณไม่ได้เริ่มจับคู่นี้ ให้กดยกเลิกทันที”

**แสดงรหัส** — Show the pairing code retrieved from server browser-only `/pair/browser/preview`. Read-only, visually large and easy to compare on mobile.

**ช่องกรอกรหัสอีกครั้ง** — The owner manually types the code visible on their own Arcsen UI into `confirmedCode`. Do NOT pre-fill, auto-paste, auto-complete, or populate from URL/query, device, previous response, or clipboard.

**Checkbox (unchecked by default):** “ฉันเป็นผู้เริ่มจับคู่บนอุปกรณ์ของตัวเอง และยืนยันว่ารหัสทั้งสองตรงกัน”

Only enable **ยืนยันการจับคู่ / Approve Pairing** if the full code matches exactly, the browser has a verified server-side session and the checkbox is explicitly checked. Server must independently enforce those same conditions.

Provide **ยกเลิก / Cancel** and a clear “Expires in 60 seconds” indicator on the browser. Pairing expires after 5 minutes overall.

## Browser request

```json
{
  "code": "ABCD-EFGH-IJKL-MNOP",
  "confirmedCode": "ABCD-EFGH-IJKL-MNOP",
  "acknowledgeOwnDevice": true,
  "confirmationToken": "server-issued-browser-only-token"
}
```

The preview, authenticated Roblox subject, and confirmation token MUST stay inside the **browser**. Luau gets only the 5-minute display code and an independent 256-bit poll-only token; it cannot read OAuth credentials, session cookies, private account data or the browser confirmation token.

The browser must send approval from the same HTTPS origin using JSON POST. Do not add user-supplied return URLs or redirect to domains embedded in codes/messages.

## Explicit limits / warnings

- These checks help reduce accidental approval and casual social engineering but **cannot eliminate phishing**. A user could be persuaded to approve a stranger's code.
- Browser confirmation proves only a verified Roblox browser account explicitly approved a code. It does **not** prove the executor currently runs under the same Roblox account.
- A pairing status of `approved` must NEVER allow reading private Violation History, unverified account-bound Appeal updates, admin operations, or changing the claimed Roblox UserId.
- The browser page is still unimplemented; the Stage16.85 server route changes are only a contract. Do not market this as a completed Roblox account login.
- **Feedback & Appeal Rules have no additional account-age restriction.** OAuth provider eligibility and identity proof are separate constraints.

## Acceptance checks for future real browser UI

1. Confirmation is never pre-checked, code re-entry never pre-filled, and Approve is disabled before explicit consent.
2. Missing, incorrect, expired or repeated code/confirmation is rejected by the server even if client UI is modified.
3. Wrong Origin, missing OAuth browser session or cross-account takeover is rejected.
4. Wrong-account/code scenarios explain the risk with neutral language and no account data leaked.
5. Large text and accessible controls work on narrow Android mobile screens.
6. No private data, browser tokens, credentials or analytics identifiers appear in Luau or URL query strings.
