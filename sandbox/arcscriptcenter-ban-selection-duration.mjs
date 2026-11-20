/**
 * ArcScriptCenter — proposed Ban Management selection + duration contract.
 * REVIEW ONLY. Existing live GitHub ban record has no selection field yet;
 * never guess a legacy record's selection or deploy this validation as-is.
 */
export const BAN_SELECTIONS=Object.freeze(['ban_ingame','restricted_mode']);
export const BAN_DURATIONS=Object.freeze(['temporary','permanent']);

export function inspectBanPolicy(entry){
 if(!entry||typeof entry!=='object')throw Error('Missing Ban record');
 const selection=entry.selection;
 if(selection===undefined||selection===null||selection==='')
  return {selection:'unassigned',duration:entry.expiresAt?'temporary':'permanent',migrationRequired:true};
 if(!BAN_SELECTIONS.includes(selection))throw Error('Unknown Ban Selection');
 const duration=entry.duration;
 if(!BAN_DURATIONS.includes(duration))throw Error('Unknown Ban Duration');
 const expiresAt=entry.expiresAt??'';
 if(typeof expiresAt!=='string')throw Error('Invalid Ban expiry');
 if(duration==='temporary'&&!expiresAt)throw Error('Temporary Ban requires an expiry');
 if(duration==='permanent'&&expiresAt)throw Error('Permanent Ban must not have expiry');
 return {selection,duration,expiresAt,migrationRequired:false};
}

export function describeBanSelection({selection,duration}){
 if(!BAN_SELECTIONS.includes(selection)||!BAN_DURATIONS.includes(duration))
  throw Error('Unknown Ban Selection / Duration');
 return {
  effect:selection==='ban_ingame'?'Show ExperienceSettings SetUp only':'Keep UI open, disable selected features',
  selectionLabel:selection==='ban_ingame'?'Ban in-game':'Restricted Mode',
  durationLabel:duration==='temporary'?'Temporary':'Permanent'
 };
}
