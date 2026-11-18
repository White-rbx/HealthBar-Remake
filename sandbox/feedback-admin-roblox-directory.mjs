/**
 * ArcScriptCenter STAGING: read-only public Roblox directory for a private Admin UI.
 * This NEVER authenticates a Roblox player or assigns ownership of a Feedback case.
 * The caller must independently authenticate the Admin BEFORE invoking this module.
 * It does not store account names in D1, KV, browser storage or logs.
 *
 * Roblox public API: users.roblox.com/v1/users/search (GET)
 * and users.roblox.com/v1/users (POST; batch public profile lookup).
 * Dependency-injected fetch makes integration/CI deterministic.
 */
const ROOT='https://users.roblox.com';
const DEFAULT_TTL=300000;
export const validClaimedId=id=>typeof id==='string'&&/^[1-9][0-9]{0,15}$/.test(id)&&Number.isSafeInteger(Number(id));
export function normalizeUserQuery(term){
 const q=String(term??'').trim();
 if(!q)return '';
 if([...q].length>40||![...q].every(ch=>/^[\p{L}\p{M}\p{N}_ .-]$/u.test(ch)))
  throw Error('Search must be a Username, Display Name or UserId (up to 40 characters)');
 if(/^\d+$/.test(q)&&!validClaimedId(q))throw Error('Invalid numeric UserId');
 return q;
}
function safePublicProfile(source) {
 const id=String(source?.id??'');
 if(!validClaimedId(id))return null;
 const username=typeof source?.name==='string'?source.name:source?.username;
 const displayName=source?.displayName;
 if(typeof username!=='string'||!/^[A-Za-z0-9_]{3,20}$/.test(username)||
    typeof displayName!=='string'||[...displayName].length>60||/[\p{Cc}]/u.test(displayName))return null;
 return {userId:id,username,displayName,source:'roblox_public_directory',ownershipVerified:false};
}
export function createRobloxPublicDirectory({fetchImpl=globalThis.fetch, now=()=>Date.now(), ttlMs=DEFAULT_TTL}={}){
 if(typeof fetchImpl!=='function'||typeof now!=='function'||!Number.isSafeInteger(ttlMs)||ttlMs<0||ttlMs>600000)
  throw Error('Invalid public Roblox directory dependencies');
 const cache=new Map();
 async function request(path,{method='GET',body}={}){
  const controller=new AbortController();
  const timeout=setTimeout(()=>controller.abort(),4500);
  try {
   const response=await fetchImpl(ROOT+path,{method,redirect:'error',credentials:'omit',cache:'no-store',
    headers:body?{'Accept':'application/json','Content-Type':'application/json'}:{'Accept':'application/json'},
    ...(body?{body:JSON.stringify(body)}:{}),signal:controller.signal});
   if(!response.ok)throw Error('Roblox directory service unavailable');
   const raw=await response.text();
   if(raw.length>75000)throw Error('Unexpected Roblox directory response size');
   return JSON.parse(raw);
  }finally{clearTimeout(timeout)}
 }
 function remember(profile){
  if(!profile)return;
  const id=profile.userId;
  if(cache.size>=160)cache.delete(cache.keys().next().value);
  cache.set(id,{profile,expiresAt:now()+ttlMs});
 }
 async function search(q){
  const query=normalizeUserQuery(q);
  if(!query)return [];
  if(validClaimedId(query))return getByIds([query]);
  const response=await request('/v1/users/search?keyword='+encodeURIComponent(query)+'&limit=10');
  if(!Array.isArray(response?.data))throw Error('Unexpected Roblox search result');
  // Roblox user search is not proof that a particular person owns a local case.
  const profiles=response.data.slice(0,10).map(safePublicProfile).filter(Boolean);
  profiles.forEach(remember);
  return profiles;
 }
 async function getByIds(values){
  const ids=[...new Set((Array.isArray(values)?values:[]).map(String))];
  if(ids.length>20||ids.some(id=>!validClaimedId(id)))throw Error('Invalid public profile lookup batch');
  if(!ids.length)return [];
  const ready=[],pending=[];
  for(const id of ids){const stored=cache.get(id);if(stored&&stored.expiresAt>now())ready.push(stored.profile);else pending.push(id)}
  if(!pending.length)return ids.map(id=>ready.find(p=>p.userId===id)).filter(Boolean);
  const response=await request('/v1/users',{method:'POST',body:{userIds:pending.map(Number),excludeBannedUsers:false}});
  if(!Array.isArray(response?.data))throw Error('Unexpected Roblox bulk user response');
  const approved=new Set(pending);
  for(const profile of response.data){const p=safePublicProfile(profile);if(p&&approved.has(p.userId)){ready.push(p);remember(p)}}
  return ids.map(id=>ready.find(p=>p.userId===id)).filter(Boolean);
 }
 return {search,getByIds};
}
