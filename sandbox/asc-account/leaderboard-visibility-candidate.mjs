// Isolated QA: draft visibility settings and minimal Compact Card projection.
// No public endpoint, rank, time, daily streak, identity link or private case data.
import {achievements} from './achievements-candidate.mjs';
const asset=v=>typeof v==='string'&&/^[1-9][0-9]{0,15}$/.test(v)?v:null;
const color=v=>typeof v==='string'&&/^#[0-9a-f]{6}$/i.test(v)?v:'#003264';
const allowed=['listed','appearance','badges'];
export function parseVisibility(body){
 if(!body||typeof body!=='object'||Array.isArray(body))return undefined;
 const keys=Object.keys(body);
 if(keys.length===0)return null; // read draft
 if(keys.length!==3||!allowed.every(k=>typeof body[k]==='boolean'&&Object.hasOwn(body,k)))return undefined;
 return {listed:body.listed,appearance:body.listed&&body.appearance,badges:body.listed&&body.badges};
}
export function projectCompactCard(row,earned=[]){
 if(!row||row.status!=='normal'||row.listed!==1||typeof row.nickname!=='string'||!row.nickname.trim())return null;
 const nickname=Array.from(row.nickname.trim()).slice(0,40).join('');
 const ids=new Set(earned.map(x=>x.achievement_id));
 return {
  nickname,
  image:row.appearance===1?asset(row.profile_image):null,
  banner:row.appearance===1?asset(row.banner_image):null,
  bannerColor:row.appearance===1?color(row.banner_color):'#003264',
  achievements:row.badges===1?achievements.filter(a=>ids.has(a.id)).map(a=>({id:a.id,label:a.label,category:a.category})):[],
 };
}
export async function ownLeaderboardDraft(db,account,now,change=null){
 if(!account||account.scope!=='web'||typeof account.id!=='string'||!account.id||
 typeof account.session_id!=='string'||!account.session_id||!Number.isSafeInteger(now)||now<0)throw new TypeError('invalid verified session');
 if(change!==null&&(parseVisibility(change)===undefined||parseVisibility(change)===null))throw new TypeError('invalid visibility');
 const active=`EXISTS (SELECT 1 FROM asc_account_sessions s WHERE s.id=? AND s.account_id=? AND s.scope='web' AND s.revoked_at IS NULL AND s.expires_at>?)`;
 const args=[account.session_id,account.id,now];
 const stmts=[];
 if(change!==null){
  const v=parseVisibility(change);
  stmts.push(db.prepare(`
   INSERT INTO asc_account_leaderboard_visibility(account_id,listed,appearance,badges,updated_at)
   SELECT a.id,?,?,?,? FROM asc_accounts a WHERE a.id=? AND ${active}
   AND (?=0 OR a.status='normal')
   ON CONFLICT(account_id) DO UPDATE SET listed=excluded.listed,appearance=excluded.appearance,
    badges=excluded.badges,updated_at=excluded.updated_at
   RETURNING listed
  `).bind(+v.listed,+v.appearance,+v.badges,now,account.id,...args,+v.listed));
 }
 stmts.push(db.prepare(`
  SELECT a.nickname,a.status,a.profile_image,a.banner_image,a.banner_color,
   COALESCE(v.listed,0) AS listed,COALESCE(v.appearance,0) AS appearance,COALESCE(v.badges,0) AS badges
  FROM asc_accounts a LEFT JOIN asc_account_leaderboard_visibility v ON v.account_id=a.id
  WHERE a.id=? AND ${active}
 `).bind(account.id,...args));
 stmts.push(db.prepare(`
  SELECT achievement_id FROM asc_account_achievements WHERE account_id=? AND ${active}
 `).bind(account.id,...args));
 const result=await db.batch(stmts);
 const row=result.at(-2)?.results?.[0];
 if(!row)return null;
 if(change!==null&&!result[0]?.results?.length)return {denied:true};
 const listed=row.status==='normal'&&row.listed===1;
 return {visibility:{listed,appearance:listed&&row.appearance===1,badges:listed&&row.badges===1},
  preview:projectCompactCard(row,result.at(-1)?.results||[])};
}
