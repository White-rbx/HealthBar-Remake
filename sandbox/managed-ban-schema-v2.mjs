/**
 * ArcScriptCenter — managed Ban schema v2 (STAGING review-only core).
 *
 * Explicit Selection is independent of Duration. Existing schema v1 rows
 * migrate to Selection='unassigned' (legacy effective behavior: SetUp-only)
 * and preserve all six existing fields. No network, D1 or GitHub writes here.
 *
 * CRITICAL: the currently deployed Worker only understands schema=1.
 * Do NOT write a v2 Lua block to branch 'loadstring' until a compatible
 * reader, signed UI policy, snapshot and trusted enforcement are released.
 */
export const BAN_SELECTIONS=Object.freeze(['ban_ingame','restricted_mode']);
export const BAN_DURATIONS=Object.freeze(['temporary','permanent']);
export const BAN_V2_LEGACY_SELECTION='unassigned';
const LEGACY_FIELDS=['userId','username','reason','description','startAt','expiresAt'];
const V2_FIELDS=[...LEGACY_FIELDS,'selection','duration'];
const BEGIN='-- ARCSCRIPT_BANS_BEGIN';
const END='-- ARCSCRIPT_BANS_END';
const MAX_BANS=200, USER_ID=/^[1-9][0-9]{0,15}$/;

function bad(msg){throw new Error(msg)}
function exactKeys(value,allowed){
 return value&&typeof value==='object'&&!Array.isArray(value)&&
  Object.keys(value).every(k=>allowed.includes(k))&&
  allowed.every(k=>Object.hasOwn(value,k));
}
export function timeICT(t){
 if(t==='')return null;
 if(typeof t!=='string')return null;
 const m=/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$/.exec(t);
 if(!m)return null;
 const [y,mo,d,h,mi]=m.slice(1).map(Number);
 if(y<2000||y>2100||mo<1||mo>12||d<1||d>31||h>23||mi>59)return null;
 const utc=Date.UTC(y,mo-1,d,h,mi);
 const dt=new Date(utc);
 if(dt.getUTCFullYear()!==y||dt.getUTCMonth()+1!==mo||dt.getUTCDate()!==d||dt.getUTCHours()!==h||dt.getUTCMinutes()!==mi)return null;
 return Math.floor(utc/1000)-7*3600;
}
export function validateBanEntryV1(e){
 if(!exactKeys(e,LEGACY_FIELDS))return false;
 return validateCommon(e);
}
function validateCommon(e){
 if(typeof e.userId!=='string'||!USER_ID.test(e.userId)||!Number.isSafeInteger(Number(e.userId)))return false;
 if(typeof e.username!=='string'||(e.username!==''&&!/^[A-Za-z0-9_]{3,20}$/.test(e.username)))return false;
 if(typeof e.reason!=='string'||e.reason.trim().length<3||e.reason.length>120||
    typeof e.description!=='string'||e.description.length>240||
    /[\x00-\x1f\x7f]/.test(e.reason+e.description))return false;
 if(typeof e.startAt!=='string'||typeof e.expiresAt!=='string')return false;
 const start=e.startAt?timeICT(e.startAt):null;
 const expires=e.expiresAt?timeICT(e.expiresAt):null;
 if((e.startAt&&start===null)||(e.expiresAt&&expires===null))return false;
 if(start!==null&&expires!==null&&expires<=start)return false;
 return true;
}
export function validateBanEntryV2(e,{allowUnassigned=true}={}){
 if(!exactKeys(e,V2_FIELDS)||!validateCommon(e))return false;
 const choices=allowUnassigned?[...BAN_SELECTIONS,BAN_V2_LEGACY_SELECTION]:BAN_SELECTIONS;
 if(!choices.includes(e.selection)||!BAN_DURATIONS.includes(e.duration))return false;
 return e.duration===(e.expiresAt?'temporary':'permanent');
}
export function parseBanDocument(obj){
 if(!obj||typeof obj!=='object'||Array.isArray(obj)||
    ![1,2].includes(obj.schema)||!Array.isArray(obj.entries)||
    obj.entries.length>MAX_BANS||Object.keys(obj).some(k=>!['schema','entries'].includes(k)))
    bad('Unsupported Ban schema');
 const validate=obj.schema===1?validateBanEntryV1:validateBanEntryV2;
 if(!obj.entries.every(e=>validate(e)))bad('Invalid Ban entry');
 if(new Set(obj.entries.map(e=>e.userId)).size!==obj.entries.length)bad('Duplicate Ban UserId');
 return {schema:obj.schema,entries:obj.entries.map(e=>({...e}))};
}
export function migrateBanDocument(obj){
 const current=parseBanDocument(obj);
 if(current.schema===2)return current;
 const entries=current.entries.map(e=>({
  ...e,
  selection:BAN_V2_LEGACY_SELECTION,
  duration:e.expiresAt?'temporary':'permanent'
 }));
 return parseBanDocument({schema:2,entries});
}
export function effectiveBanSelection(entry){
 if(!validateBanEntryV2(entry))bad('Invalid Ban entry');
 // Strict migration rule: existing legacy bans retain SetUp-only semantics.
 return entry.selection===BAN_V2_LEGACY_SELECTION?'ban_ingame':entry.selection;
}
export function selectActiveBan(entries,userId,nowUnix){
 const matches=entries.filter(e=>e.userId===userId);
 return matches.find(e=>{
  if(!validateBanEntryV2(e))return false;
  const start=e.startAt?timeICT(e.startAt):null;
  const expires=e.expiresAt?timeICT(e.expiresAt):null;
  return (start===null||nowUnix>=start)&&(expires===null||nowUnix<expires);
 })||null;
}
export function applyBanChange(document,change){
 const current=migrateBanDocument(document);
 if(!change||typeof change!=='object'||Array.isArray(change))bad('Invalid request');
 const action=change.action,entries=current.entries.map(e=>({...e}));
 if(action==='upsert'){
  if(!validateBanEntryV2(change.entry,{allowUnassigned:false}))
   bad('Invalid v2 Ban entry: explicit Selection and Duration required');
  if(Object.keys(change).some(k=>!['action','entry'].includes(k)))bad('Unsupported action fields');
  const i=entries.findIndex(e=>e.userId===change.entry.userId);
  if(i<0)entries.push({...change.entry});
  else entries[i]={...change.entry};
 }else if(action==='remove'){
  if(Object.keys(change).some(k=>!['action','userId'].includes(k))||!USER_ID.test(change.userId||''))
   bad('Invalid removal request');
  const i=entries.findIndex(e=>e.userId===change.userId);
  if(i<0)bad('Ban entry does not exist');
  entries.splice(i,1);
 }else bad('Invalid Ban action');
 if(entries.length>MAX_BANS)bad('Ban limit exceeded');
 entries.sort((a,b)=>a.userId.length-b.userId.length||a.userId.localeCompare(b.userId));
 return parseBanDocument({schema:2,entries});
}
export function parseBanLua(source){
 if(typeof source!=='string'||source.length>400000)bad('Invalid Setup source');
 if(source.split(BEGIN).length!==2||source.split(END).length!==2)bad('Missing or repeated ban markers');
 const begin=source.indexOf(BEGIN)+BEGIN.length,end=source.indexOf(END);
 if(end<=begin)bad('Out-of-order ban markers');
 const block=source.slice(begin,end).trim();
 const match=/^local _ASC_MANAGED_JSON = \[(=+)\[\s*([\s\S]*?)\s*\]\1\]$/.exec(block);
 if(!match)bad('Unexpected Lua ban block');
 let doc;try{doc=JSON.parse(match[2])}catch{bad('Invalid Ban JSON')}
 return {begin,end,document:parseBanDocument(doc)};
}
export function renderBanLua(document){
 const doc=parseBanDocument(document);
 if(doc.schema!==2)bad('Explicit Ban v2 document required');
 const text=JSON.stringify(doc);
 let equals='==';
 while(text.includes(']'+equals+']'))equals+='=';
 return '\nlocal _ASC_MANAGED_JSON = ['+equals+'[\n'+text+'\n]'+equals+']\n';
}
export function prepareBanV2LuaUpdate({source,sha,expectedSha,change}){
 if(typeof sha!=='string'||!/^[0-9a-f]{40}$/i.test(sha)||
    typeof expectedSha!=='string'||expectedSha!==sha)
   bad('GitHub SHA conflict; refresh before saving');
 const segment=parseBanLua(source);
 const next=applyBanChange(segment.document,change);
 const modified=source.slice(0,segment.begin)+renderBanLua(next)+source.slice(segment.end);
 return {document:next,modified,unchanged:modified===source};
}
