# Arcsen UIs 7.3.52 — Restricted Mode STAGING UI Preview (2026-11-19)

**Status: prepared; source/patch QA PASS, NOT deployed to Roblox/Cloudflare, Production untouched.** Owner requested to continue ArcScriptCenter Ban System Step 3/4.

## Actual source inspected
- Owner Library original **Arcsen_v7.3.51_UserId_Auto_Admin_STAGING.lua**, SHA-256:
  \`5ee699dd88ae6a2fd2da28e848ff74c7c6ffe41f6c9ac4c938c5929b93b0a448\`.
- Owner Library **Loader (main)(2).lua** and GitHub **ExperienceSettings.lua** were inspected to identify real button/GUI names. Arcsen 7.3.51 uses \`Menu.TopBar.Holder.z8_ChatGPT\`; newer naming \`z8_Arcsen\` is also supported. Do not blindly replace with an invented name.
- Existing 7.3.51 signed policy \`loc.API.PolicyReadOnly\` already gates SendMessage, CreateChat, New Chat, Chat Tabs and Retry; original UI policy is **advisory**, \`identityVerified=false\`. Old code can inadvertently re-enable \`ChatTextBox\` in \`loc.API.UpdateSendButton\`.

## Downloadable local artifacts (ChatGPT conversation)
- \`Arcsen_7.3.52_RestrictedMode_STAGING_REVIEW.zip\`: **complete updated Lua source**, unified patch, Thai readme and repeatable Python static QA.
- \`Arcsen_v7.3.52_RestrictedMode_STAGING_PREVIEW.lua\` SHA-256:
  \`8966c3eeb7468f78f25730a5c9912648c5e278e7e1b3719cfe0d4fab6c414826\`.
- Unified patch: \`Arcsen_7.3.51_to_7.3.52_RestrictedMode.patch\`; applies cleanly with \`git apply --check\` and \`git apply\` against exact v7.3.51. Patch replay verified byte-for-byte identical to generated v7.3.52.
- Local static QA: 21+ invariants passed; no Roblox runtime execution yet. File not yet committed in full to GitHub due to 1MB original size; this document tracks the reference and source hashes.

## UI behavior in Preview
1. During Restricted Mode Preview only, disable all \`GuiButton\` direct children of \`CoreGui.ExperienceSettings.Menu.TopBar.Holder\` **except** \`a1_Open/Close\`, \`z7_About\`, \`z8_ChatGPT\` and \`z8_Arcsen\`. Disabled buttons get \`Interactable=false\`, \`AutoButtonColor=false\`, \`BackgroundColor3=Color3.fromRGB(89,89,89)\`.
2. Preserve and restore original button colors, interactability and auto-color when Preview ends; watch new TopBar buttons; disconnect listener on controller stop.
3. Respect current signed \`PolicyReadOnly\` and add (never override) local preview restriction. Hide Chat History, Current Chat, Chat Input and New Chat, disable Send + TextBox; updateSendButton and send click are explicitly blocked. Current signed-policy failure stays restrictive, even when Preview is turned off.
4. Auto-open the **existing** Arcsen Settings and ArcScriptCenter Feedback & Appeal section for allowed Rules, Feedback and already independently verified Violation/Appeal. **Never fabricate a Violation**: the existing account notice remains hidden without trusted identity verification.
5. A dedicated preview-only method \`getgenv().ArcScriptPolicyGate.previewRestrictedMode(true|false)\` exists only when \`getgenv().ArcsenRestrictedPreviewAllowed == true\` was set explicitly before loading. This toggles local UI testing only; there is no ban API write, and no client authorization.
6. **Ban Selection is separate from Duration**: \`Restricted Mode\` can be Temporary or Permanent; \`Ban in-game\` can also be Temporary or Permanent but has its own *SetUp-only* experience gate (not implemented in this UI patch).

## Release gates still open
- Run the provided v7.3.52 source in a real Roblox **STAGING** environment; confirm every TopBar button, Settings/Appeal and restoration, and that Chat/API actions remain blocked.
- Implement a trusted server-side, account-bound restriction decision with secure Roblox identity proof and server-enforced AI/API blocking. Client-side Luau/LocalPlayer/UserId/boolean flags can be forged; the Preview method is **not** moderation security. Existing signed UI policy explicitly supplies identityVerified=false.
- Add verified Ban Selection/Duration to the real GitHub managed ban schema and the existing Admin form, with careful migration of legacy entries. STAGING managed bans are currently GET-only. No actual user ban has been changed.
- Production untouched; PR #16 stays Draft. Step 3/4 is **in progress**.
