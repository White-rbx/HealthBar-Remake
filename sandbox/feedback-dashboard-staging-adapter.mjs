/**
 * ArcScriptCenter native STAGING Pages Feedback & Appeal — in-place review.
 *
 * This Pages version ALREADY contains its own Feedback & Appeal navigation,
 * case editor, summary, follow-up, moderation controls and admin session.
 *
 * Previous adapter wrongly injected a second sidebar tab and separate
 * Admin Key field. Never duplicate or replace the owner's UI.
 *
 * This exact-source enhancement changes security copy only, and deliberately
 * DOES NOT claim to render claimed_user_id for Feedback: the native external
 * Pages Functions JS needs a separate, reviewed code change for that.
 *
 * Review-only. Never deploy automatically.
 */
const EXISTING_NAV='data-page="feedback-appeal" id="asc1649FeedbackNav"';
const EXISTING_PAGE='<section class="page" id="page-feedback-appeal">';
const EXISTING_JS='<script defer src="/__asc1649/feedback-appeal.js"></script>';
const WARNING='<div class="fa-muted-warning" role="note"><b>Private admin workspace.</b> Do not share your Admin Key or screenshots containing personal submissions. A claimed Roblox UserId is not verified identity. Spam Mail is admin-only.</div>';
const UPDATED_WARNING='<div class="fa-muted-warning" role="note"><b>Private admin workspace.</b> Do not share your Admin Key or screenshots containing personal submissions. Feedback and Appeal UserIds are user-provided, unverified claims. Never use a claimed UserId alone for account authorization. Spam Mail is admin-only.</div>';

export function prepareFeedbackDashboardStagingHtml(html) {
  if (typeof html!=='string' || html.length<5000) {
    throw new TypeError('Exact STAGING Pages HTML is required');
  }
  if (!html.includes("const API_BASE = 'https://arcscriptcenter-api-staging.kogpasan14.workers.dev';")) {
    throw new Error('Refuse non-STAGING Dashboard source');
  }
  for (const [anchor,label] of [[EXISTING_NAV,'native sidebar'],[EXISTING_PAGE,'native Feedback page'],[EXISTING_JS,'native Pages JS']]) {
    if(html.split(anchor).length!==2)throw new Error(label+' anchor missing or duplicated; stop');
  }
  if(html.includes('id="page-feedback"')||html.includes('data-page="feedback"')) {
    throw new Error('Duplicate Feedback page found; review and remove extra UI');
  }
  if (html.split(WARNING).length!==2) {
    throw new Error('Native private-admin warning changed; manual review required');
  }
  return html.replace(WARNING,UPDATED_WARNING);
}