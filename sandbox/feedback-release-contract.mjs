/**
 * Consolidated Feedback & Appeal release-track contract (sandbox only).
 * Regular Feedback is anonymous (no Roblox OAuth, account-age or claimed UserId).
 * Appeal claims are *unverified*, and the only account-specific moderation data
 * permitted to a client remains NONE until server-verified subject auth exists.
 * The existing Turnstile and case-receipt workflows remain authoritative.
 */
export const FEEDBACK_RELEASE_CONTRACT = Object.freeze({
  feedback: Object.freeze({
    requiresRobloxOidc: false,
    requiresRobloxAccountAge: false,
    requiresTurnstile: true,
    requiresClaimedUserId: false,
    acceptsOptionalClaimedUserId: true,
    claimedUserIdIsNotIdentityProof: true,
    topicMin: 3, topicMax: 50,
    descriptionMin: 50, descriptionMax: 1500,
    allowedOperations: ['submit','status-by-receipt','edit-by-receipt','remove-by-receipt'],
  }),
  appeal: Object.freeze({
    requiresRobloxOidcToSubmitClaim: false,
    requiresTurnstile: true,
    claimedUserIdIsNotIdentityProof: true,
    userSpecificViolationHistoryRequiresVerifiedPrincipal: true,
    topicMin:3,topicMax:50,descriptionMin:50,descriptionMax:5000,
    allowedOperations: ['submit-unverified-claim','status-by-receipt','edit-by-receipt','remove-by-receipt'],
  }),
  userInterface: Object.freeze({
    language: 'en',
    categoryPath: 'Arcsen > Settings > ArcScriptCenter > Feedback & Appeal',
    violationAppealNested: true,
    spamMailAdminOnly: true,
    noPrivateHistoryWithoutIdentity: true,
    noProductionDeployment: true,
  }),
  browserRoutes: Object.freeze({
    production: Object.freeze({
      page:'/api/v1/feedback/form',
      submit:'/api/v1/feedback/submit',
      status:'/api/v1/feedback/status',
      manage:'/api/v1/feedback/manage',
    }),
    sandbox: Object.freeze({
      page:'/__stage1676/arcsen-bridge',
      submit:'/__stage1667/submit',
      status:'/api/v1/feedback/status',
      manage:'/api/v1/feedback/manage',
    }),
  }),
});
