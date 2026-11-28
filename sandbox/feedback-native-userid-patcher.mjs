/**
 * Minimal source-anchored patch for the ORIGINAL Stage16.54 Dashboard.
 * Do not duplicate the Feedback UI, add a second Admin Key, or grant identity.
 *
 * Requires BOTH original client JS and original Pages _worker.js.
 * The Pages worker's embedded MOD_SCRIPT must match the client JS byte for byte.
 */
const ORIGINAL = "    if(c.kind==='appeal')dl.append(faDetailLine('Claimed Roblox UserId',faText(c.claimed_user_id||'None')+' (unverified)'));";
const REPLACEMENT = "    if(c.kind==='feedback'||c.kind==='appeal')dl.append(faDetailLine('Claimed Roblox UserId',faText(c.claimed_user_id??'Not provided')+' (unverified)'));";
const EMBEDDED = /(^const MOD_SCRIPT = )("(?:\\.|[^"\\])*")(;)/m;
function one(source,match,label){
  if(source.split(match).length!==2)throw new Error(label+': expected one exact source anchor');
}
export function patchNativeClaimedUserId(clientJS,workerJS){
  if(typeof clientJS!=='string'||typeof workerJS!=='string'||clientJS.length<1000||workerJS.length<1000)
    throw new Error('Full original Stage16.54 JavaScript and Pages Worker are required');
  one(clientJS,ORIGINAL,'native case detail');
  if(!clientJS.includes('function faRenderDetail(c)')||
     !clientJS.includes('function faDetailLine(')||
     !clientJS.includes('async function faUnlock()'))
    throw new Error('Original Admin UI control anchors missing');
  const mod=EMBEDDED.exec(workerJS);
  if(!mod)throw new Error('Pages MOD_SCRIPT literal not found');
  const embedded=JSON.parse(mod[2]);
  if(embedded!==clientJS)throw new Error('Pages Worker embedded client JS differs from original; refuse to patch');
  const patchedJS=clientJS.replace(ORIGINAL,REPLACEMENT);
  const patchedWorker=workerJS.replace(mod[0],mod[1]+JSON.stringify(patchedJS)+mod[3]);
  if(!patchedWorker.includes('env.ASSETS.fetch(request)')||
     !patchedWorker.includes("url.pathname==='/__asc1649/feedback-appeal.js'"))
    throw new Error('Pages routing changed');
  return {clientJS:patchedJS,workerJS:patchedWorker};
}
export const CLAIMED_ID_COPY={original:ORIGINAL,replacement:REPLACEMENT};
