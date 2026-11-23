// Legacy linking is a trusted staff operation, after independent ownership
// verification. The unified account signup and login routes never call it.
export async function linkVerifiedLegacyCase(db,{source,caseId,verifiedOwner,kind,reason,moderatorMessage,status,now}){
 if(!['bannedtoken','feedback','appeal'].includes(source)||!['ban','violation','feedback'].includes(kind)||
    typeof caseId!=='string'||!caseId||caseId.length>100||
    typeof verifiedOwner?.subject!=='string'||verifiedOwner.provider!=='roblox_oidc'||
    typeof reason!=='string'||typeof moderatorMessage!=='string'||
    !['open','reviewing','approved','denied','closed'].includes(status))return false;
 // Resolve the account from the existing verified identity link. The caller
 // must obtain verifiedOwner and this case's ownership from trusted records.
 return Boolean(await db.prepare(`
  INSERT INTO asc_account_cases(id,account_id,kind,status,reason,moderator_message,legacy_source,legacy_id,created_at)
  SELECT ?1,account_id,?2,?3,?4,?5,?6,?7,?8 FROM asc_account_verified_links
  WHERE provider='roblox_oidc' AND subject=?9
  ON CONFLICT(legacy_source,legacy_id) DO NOTHING RETURNING id
 `).bind(crypto.randomUUID(),kind,status,reason.slice(0,1500),moderatorMessage.slice(0,2000),source,caseId,now,verifiedOwner.subject).first());
}

export function accountProfile(account){
 return {id:account.id,username:account.username,nickname:account.nickname,image:account.profile_image,
  banner:account.banner_image,bannerColor:account.banner_color,status:account.status,twoStep:!!account.totp,
  imageThumbnail:account.profile_thumbnail,bannerThumbnail:account.banner_thumbnail};
}
export async function validImage(value,fetcher=fetch){
 if(typeof value!=='string'||!(/^[1-9][0-9]{0,15}$/).test(value))return false;
 const url=new URL('https://thumbnails.roblox.com/v1/assets');
 url.search=new URLSearchParams({assetIds:value,size:'150x150',format:'Png',isCircular:'false'});
 const response=await fetcher(url,{redirect:'manual',signal:AbortSignal.timeout(5000)});
 if(!response.ok)return false;
 const data=(await response.json()).data;
 return Array.isArray(data)&&data.find(row=>String(row.targetId)===value&&row.state==='Completed'&&
  typeof row.imageUrl==='string'&&/^https:\/\/[a-z0-9-]+\.rbxcdn\.com\//i.test(row.imageUrl))?.imageUrl;
}
