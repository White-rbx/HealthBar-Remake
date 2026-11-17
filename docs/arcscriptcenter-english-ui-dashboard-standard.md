# ArcScriptCenter — UI Language Standard (English)

Status: **Design contract for future Dashboard and Arcsen releases.** No live Pages project is modified by this document.

## Global rule

**English is the default language for every ArcScriptCenter and Arcsen interface**, including all user-facing dashboards and administrative dashboards.

Applies to navigation, titles, buttons, forms, placeholders, tooltips, warnings, loading states, toast notifications, error messages, confirmation dialogues, empty states, status labels, chart labels, analytics, moderation and feedback history. Keep technical error codes, API identifiers, user-generated content and immutable backend enum values unchanged.

This change is **UI copy only**. Do not change permission rules, authentication, age policy, the account-owner verification model or database schema while translating text.

## Pages projects located on Cloudflare

| Project | UI scope | Target copy |
|---|---|---|
| `arcscriptcenter-dashboard-staging` | Staging Admin Dashboard and testing views | English |
| `arcscriptcenter-dashboard` | Production Admin Dashboard | English, after owner-reviewed staging QA |
| `arcscriptcenter-webchat` | WebChat, if still retained | English; do not reactivate removed features |
| ExperienceSettings → Arcsen | Mobile client, Settings, Feedback & Appeal, Violation | English |
| Pairing Browser Demo | Pairing approval, errors and warnings | English |

**Important:** These Pages projects were verified to exist, but their full deployed source files were not available in the current GitHub branch. This document and the GitHub HTML edits do **not** translate or deploy the currently hosted Dashboards. Any live change requires retrieving the authoritative source or making a separately reviewed staging deployment. Do not overwrite a current Pages deployment based on an incomplete copy.

## Suggested shared dashboard vocabulary

| UI item | English copy |
|---|---|
| Home | Overview |
| Numbers | Analytics |
| Users online | Active Users |
| Unique daily users | Daily Unique Users |
| Unique yearly users | Yearly Unique Users |
| Incoming submissions | Feedback & Appeals |
| Waiting for review | Reviewing |
| Accepted | Approved |
| Rejected | Denied |
| Rule breaches | Violations |
| Archived actions | History |
| Filtered spam reports | Spam Mail *(admin only)* |
| Requests for reopening violation | Appeal *(inside Violation)* |
| Review | Review |
| Remove | Remove |
| Reported users | Reported Users |
| Moderation list | Moderation Queue |
| Account restrictions | Restricted |
| Security alerts | Global Warnings |
| View detail | View Details |
| Search records | Search |
| No entries | No records found |
| An in-progress request | Request in progress… |
| Failed network request | Request failed. Please try again. |

Do **not** accidentally make Spam Mail visible in normal Feedback & Appeal UI. Appeal belongs **inside Violation** (not a new top-level category). Preserve Rules / Feedback / Violation UX separation, color statuses and security restrictions.

## Forms and readability

- Use `<html lang="en">` for English HTML views.
- Use concise English in User Dashboard, Admin Dashboard, WebChat, and Luau GUI.
- Mobile: readable font size, full text wrapping, generous touch targets.
- Do not expose API secrets, OAuth browser tokens, Roblox credentials or private user information in UI strings.
- Translation must never invent an account-age limit. Existing Feedback & Appeal Rules have **no account age restriction** introduced by this work.
- Keep Roblox user-generated messages **as entered**; do not force-translate chat, Appeals, feedback, Moderator comments or case details.
- Keep scripts' identifiers, API fields, route names, database keys, Cloudflare bindings and enum constants unchanged to avoid breaking behavior.

## Stage16.86 implementation scope

- `sandbox/stage16-86-browser-demo/index.html` and `app.js`: English.
- `sandbox/production-feedback-appeal-form.html`: English reference copy only, **not deployed**.
- `sandbox/stage16-76-arcsen-bridge.html`: English Sandbox reference copy only, **not deployed**.
- `sandbox/stage16-86-english-ui.test.mjs`: regression check for English reference HTML.

This standard is the source of UI copy direction for subsequent Dashboard changes. For actual Dashboard translation: obtain the exact current source for each Cloudflare Pages project, create a staging preview, review all controls at mobile and desktop widths, then deploy only with owner approval.
