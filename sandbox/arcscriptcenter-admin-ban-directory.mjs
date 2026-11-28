/**
 * ArcScriptCenter STAGING — existing GitHub-managed Ban List name enrichment.
 * Must be called only AFTER existing Admin unlock and GET /api/v1/admin/bans.
 * No new ban/unban API, no Client authentication assertion, no secret storage.
 */
import {classifyManagedBan} from './arcscriptcenter-ban-types-staging.mjs';
import {normalizeUserQuery,validClaimedId} from './feedback-admin-roblox-directory.mjs';
const PUBLIC='roblox_public_directory';

export function banCardLabel(record){
 const name=record.publicProfile?.displayName;
 const username=record.publicProfile?.username||record.username||null;
 const id=record.userId;
 return `${name?name+' ':''}${username?'@'+username+' · ':''}UserId ${id}`;
}
/** No external network calls when directory unavailable. Treat Roblox names as public reference only. */
export async function decorateManagedBanEntries(entries,{directory=null,nowUnix=Math.floor(Date.now()/1000)}={}){
 if(!Array.isArray(entries)||entries.length>20||entries.some(x=>!validClaimedId(x?.userId)))
  throw Error('Invalid Ban List page (max 20 entries)');
 let resolved=[];
 if(directory?.getByIds){try{resolved=await directory.getByIds(entries.map(x=>x.userId))}catch{/* fallback to saved Usernames */}}
 const profiles=new Map(resolved.filter(p=>p?.source===PUBLIC&&p?.ownershipVerified===false)
  .map(p=>[p.userId,{username:p.username,displayName:p.displayName,source:p.source,ownershipVerified:false}]));
 return entries.map(entry=>({
  userId:entry.userId,username:entry.username||null,reason:entry.reason,
  ban:classifyManagedBan(entry,nowUnix),
  publicProfile:profiles.get(entry.userId)||null,
  ownerVerified:false,
  source:'existing_gitHub_managed_ban'
 }));
}
/**
 * Usernames can change, Display Names may repeat. Search returns *every*
 * matching managed Ban entry; never auto-select or ban someone based on a name.
 */
export async function findManagedBansByName(entries,query,{directory=null}={}){
 if(!Array.isArray(entries)||entries.length>200)throw Error('Ban List exceeds existing cap');
 const q=normalizeUserQuery(query).toLocaleLowerCase();
 if(!q)return entries;
 const matches=new Set();
 for(const b of entries){
  if(!validClaimedId(b?.userId))throw Error('Invalid managed Ban List record');
  if(b.userId.startsWith(q)||String(b.username||'').toLocaleLowerCase().includes(q))matches.add(b.userId);
 }
 if(directory?.search){try{
  const profiles=await directory.search(query);
  const ids=new Set(profiles.map(x=>x.userId));
  for(const b of entries)if(ids.has(b.userId))matches.add(b.userId);
 }catch{/* fail safely to local ban-record names */}}
 return entries.filter(b=>matches.has(b.userId));
}
