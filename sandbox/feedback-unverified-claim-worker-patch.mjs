/**
 * ArcScriptCenter: review-only, source-anchored Worker adaptation.
 * Purpose: accept an optional UNVERIFIED claimedUserId for ordinary Feedback
 * as well as Appeal, using the EXISTING asc_feedback_cases.claimed_user_id.
 *
 * Apply only after reviewing the EXACT Worker source of a dedicated sandbox.
 * Does not deploy or contact Cloudflare; throws on source drift/duplicates.
 * No identity verification, no new schema, no new sensitive read endpoint.
 */
export const ORIGINAL_CLAIM_BLOCK = [
  "  const claimedId=b.kind==='appeal'?String(b.claimedUserId||''):null;",
  "  if (b.kind==='appeal' && !validUserId(claimedId))",
  "    return json({ok:false,error:'Appeal needs a valid claimed UserId'},400,origin);",
].join('\n');
export const NEW_CLAIM_BLOCK = [
  '  // Client-supplied identifier is a label for Admin review, not identity proof.',
  "  const claimedId=b.claimedUserId===undefined || b.claimedUserId===null ||",
  "      b.claimedUserId==='' ? null : String(b.claimedUserId);",
  "  if (claimedId!==null && !validUserId(claimedId))",
  "    return json({ok:false,error:'Invalid claimed UserId format'},400,origin);",
  "  if (b.kind==='appeal' && claimedId===null)",
  "    return json({ok:false,error:'Appeal needs a claimed UserId'},400,origin);",
].join('\n');

export function prepareOptionalUnverifiedSenderClaimPatch(source) {
  if(typeof source!=='string' || source.length<1000) {
    throw new TypeError('Inspected Worker source text required');
  }
  if(source.split('async function fcSubmit(').length!==2)
    throw new Error('Unexpected fcSubmit source signature; review needed');
  if(source.split(ORIGINAL_CLAIM_BLOCK).length!==2)
    throw new Error('Unexpected/missing original claim block; review needed');
  const originalInsert="    'INSERT INTO asc_feedback_cases(id,receipt_hash,kind,claimed_user_id,topic,description,status,created_unix,updated_unix) '+";
  const originalAdminSelect="'SELECT id,kind,claimed_user_id,topic,description,status,created_unix,updated_unix,revision,public_note,admin_note,followup,followup_updated_unix '";
  if(!source.includes(originalInsert) || !source.includes(originalAdminSelect))
    throw new Error('Current case schema or Admin list no longer matches; abort');
  const revised=source.replace(ORIGINAL_CLAIM_BLOCK,NEW_CLAIM_BLOCK);
  if(!revised.includes(originalInsert)||!revised.includes(originalAdminSelect))
    throw new Error('Unexpected Worker source change; abort');
  if(source.length===revised.length) throw new Error('Patch had no effect');
  return revised;
}

/** UI labeling reference, not a server-verified account. */
export function displayUnverifiedClaim(row) {
  const raw=row&&row.claimed_user_id;
  if(raw==null || raw==='')return 'Not provided';
  return 'Claimed UserId: '+String(raw)+' (Unverified)';
}
