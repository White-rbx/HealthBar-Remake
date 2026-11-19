/**
 * ArcScriptCenter original Worker Ban v1/v2 reader patch — REVIEW ONLY.
 * Applies exact anchored replacements to the complete original STAGING
 * Worker, preserving Signed UI Policy schema:1 and disabled GitHub writes.
 * Never deploys or makes network calls.
 */
export function patchOriginalWorkerForBanV2(source){
 if(typeof source!=='string'||source.length<250000||source.length>450000)
  throw new Error('Incomplete original Worker; refusing partial content');
 let s=source;
 const once=(oldText,newText)=>{
  if(s.split(oldText).length!==2)
   throw new Error('Worker drift at '+oldText.slice(0,72));
  s=s.replace(oldText,newText);
 };
 once("const VERSION = '0.5.67.1-cors-response-staging';",
      "const VERSION = '0.5.68.0-ban-v1-v2-dualreader-REVIEW';");
 once("if (payload?.schema !== 1 || !Array.isArray(payload.entries) || payload.entries.length > MAX_BANS)",
      "if (![1,2].includes(payload?.schema) || !Array.isArray(payload.entries) || payload.entries.length > MAX_BANS)");
 once("if (!payload.entries.every(e => validBanEntry(e))) apiError('Invalid managed ban entry in GitHub file', 409);",
      "if (!payload.entries.every(e => validBanEntry(e,payload.schema))) apiError('Invalid managed ban entry in GitHub file', 409);");
 once('return {start,end,entries:payload.entries};','return {start,end,entries:payload.entries,schema:payload.schema};');
 const begin='function validBanEntry(e) {',end='function renderManagedSegment(entries) {';
 const i=s.indexOf(begin),j=s.indexOf(end,i+begin.length);
 if(i<0||j<=i||s.split(begin).length!==2||s.split(end).length!==2)
  throw new Error('Unexpected Ban validator anchor');
 s=s.slice(0,i)+"function validBanEntry(e,schema=1) {\n  const base=['userId','username','reason','description','startAt','expiresAt'];\n  const fields=schema===1?base:schema===2?[...base,'selection','duration']:null;\n  if(!fields||!e||typeof e!=='object'||Array.isArray(e)||\n     Object.keys(e).length!==fields.length||!fields.every(k=>Object.hasOwn(e,k)))return false;\n  if(typeof e.userId!=='string'||!/^[1-9][0-9]{0,15}$/.test(e.userId)||\n     !Number.isSafeInteger(Number(e.userId)))return false;\n  if(typeof e.username!=='string'||(e.username!==''&&!/^[A-Za-z0-9_]{3,20}$/.test(e.username)))return false;\n  if(typeof e.reason!=='string'||e.reason.trim().length<3||e.reason.length>120||\n     typeof e.description!=='string'||e.description.length>240||\n     /[\\x00-\\x1F\\x7F]/.test(e.reason+e.description))return false;\n  if(typeof e.startAt!=='string'||typeof e.expiresAt!=='string')return false;\n  const start=e.startAt?timeToUnix(e.startAt):null;\n  const expires=e.expiresAt?timeToUnix(e.expiresAt):null;\n  if((e.startAt&&start===null)||(e.expiresAt&&expires===null)||\n     (start!==null&&expires!==null&&expires<=start))return false;\n  if(schema===2){\n    if(!['ban_ingame','restricted_mode','unassigned'].includes(e.selection))return false;\n    if(!['temporary','permanent'].includes(e.duration))return false;\n    if(e.duration!==(e.expiresAt?'temporary':'permanent'))return false;\n  }\n  return true;\n}\n"+s.slice(j);
 once('function renderManagedSegment(entries) {','function renderManagedSegment(entries,schema=2) {');
 once('const value = JSON.stringify({schema:1,entries});','const value = JSON.stringify({schema,entries});');
 const snapBegin='function validatedSnapshot(payload) {';
 const snapEnd='async function saveBanSnapshot(env, entries, sha, now = Math.floor(Date.now()/1000)) {';
 const si=s.indexOf(snapBegin),sj=s.indexOf(snapEnd,si+snapBegin.length);
 if(si<0||sj<=si||s.split(snapBegin).length!==2||s.split(snapEnd).length!==2)
  throw new Error('Unexpected Snapshot validator anchor');
 s=s.slice(0,si)+"function validatedSnapshot(payload) {\n  if (!payload || ![1,2].includes(payload.schema) ||\n      !Array.isArray(payload.entries) || payload.entries.length > MAX_BANS ||\n      Object.keys(payload).some(k=>!['schema','entries'].includes(k)) ||\n      !payload.entries.every(e=>validBanEntry(e,payload.schema)) ||\n      new Set(payload.entries.map(x=>x.userId)).size!==payload.entries.length)\n    throw new Error('Invalid ban snapshot schema');\n  return payload.entries;\n}"+'\n'+s.slice(sj);
 once('async function saveBanSnapshot(env, entries, sha, now = Math.floor(Date.now()/1000)) {',
      'async function saveBanSnapshot(env, entries, sha, now = Math.floor(Date.now()/1000), schema = 1) {');
 once('validatedSnapshot({schema:1, entries});','validatedSnapshot({schema,entries});');
 once('.bind(JSON.stringify({schema:1,entries}), sha, now).run();',
      '.bind(JSON.stringify({schema,entries}), sha, now).run();');
 once("return {entries:validatedSnapshot(JSON.parse(row.payload_json)),source:'d1_fresh_snapshot'};",
      "const doc=JSON.parse(row.payload_json);return {entries:validatedSnapshot(doc),schema:doc.schema,source:'d1_fresh_snapshot'};");
 once("const entries = managedSegment(source).entries;\n  await saveBanSnapshot(env, entries, sha, now);\n  return {entries,source:'github_refreshed'};",
      "const managed=managedSegment(source);\n  await saveBanSnapshot(env,managed.entries,sha,now,managed.schema);\n  return {entries:managed.entries,schema:managed.schema,source:'github_refreshed'};");
 once("file:'ExperienceSettings-SetUp.lua',entries:managed.entries},200,origin);",
      "file:'ExperienceSettings-SetUp.lua',schema:managed.schema,compatibleSchemas:[1,2],entries:managed.entries},200,origin);");
 const audit='await saveBanSnapshot(env,data.entries,data.sha);';
 if(s.split(audit).length!==3)throw new Error('Ban audit snapshot callsites changed');
 s=s.replaceAll(audit,'await saveBanSnapshot(env,data.entries,data.sha,undefined,data.schema||1);');
 if(!s.includes("const policy={schema:1,subjectUserId:")||
    !s.includes("GitHub ban changes are disabled in staging")||
    !s.includes("async function verifyUserPolicy(request,env,origin)")||
    s.length<250000)throw new Error('Security/signed policy contract changed');
 return s;
}
