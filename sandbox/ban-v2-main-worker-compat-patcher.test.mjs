import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {patchOriginalWorkerForBanV2} from './ban-v2-main-worker-compat-patcher.mjs';

const ENTRY={userId:'123456789',username:'ExampleUser',reason:'Synthetic test',
 description:'',startAt:'',expiresAt:''};
const source='/* '+'.'.repeat(250010)+' */\n'+"\nconst VERSION = '0.5.67.1-cors-response-staging';\nconst MAX_BANS=200, GITHUB_BRANCH='loadstring';\nconst BANS_START='-- ARCSCRIPT_BANS_BEGIN',BANS_END='-- ARCSCRIPT_BANS_END';\nfunction apiError(m){throw new Error(m)}\nfunction managedSegment(source) {\n const start=source.indexOf(BANS_START)+BANS_START.length;\n const end=source.indexOf(BANS_END);\n const block=source.slice(start,end).trim();\n const m=block.match(/^local _ASC_MANAGED_JSON = \\[(=+)\\[\\s*([\\s\\S]*?)\\s*\\]\\1\\]$/);\n if(!m)apiError('Bad managed source');\n const payload=JSON.parse(m[2]);\n if (payload?.schema !== 1 || !Array.isArray(payload.entries) || payload.entries.length > MAX_BANS)apiError('Unsupported');\n if (!payload.entries.every(e => validBanEntry(e))) apiError('Invalid managed ban entry in GitHub file', 409);\n return {start,end,entries:payload.entries};\n}\nfunction timeToUnix(value){return value?1:null}\nfunction validBanEntry(e) {return Boolean(e)}\nfunction renderManagedSegment(entries) {\n const value = JSON.stringify({schema:1,entries});\n return value;\n}\nasync function adminBans(request,env,origin) {\n if(request.method!=='GET')return 'GitHub ban changes are disabled in staging';\n const managed=managedSegment(env.source),sha='a'.repeat(40);\n if (request.method === 'GET') return json({ok:true,sha,branch:GITHUB_BRANCH,\n      file:'ExperienceSettings-SetUp.lua',entries:managed.entries},200,origin);\n}\nfunction validatedSnapshot(payload) {\n if(!payload||payload.schema!==1)throw Error('invalid');\n return payload.entries;\n}\nasync function saveBanSnapshot(env, entries, sha, now = Math.floor(Date.now()/1000)) {\n validatedSnapshot({schema:1, entries});\n return env.DB.prepare('INSERT').bind(JSON.stringify({schema:1,entries}), sha, now).run();\n}\nasync function readManagedBanSnapshot(env,now=Math.floor(Date.now()/1000)) {\n if(env.row){\n  const row=env.row;\n  return {entries:validatedSnapshot(JSON.parse(row.payload_json)),source:'d1_fresh_snapshot'};\n }\n const {sha,source}=await githubRead(env);\n const entries = managedSegment(source).entries;\n await saveBanSnapshot(env, entries, sha, now);\n return {entries,source:'github_refreshed'};\n}\nasync function adminBansWithAudit(request,env,origin){\n const data=env.data;\n try {await saveBanSnapshot(env,data.entries,data.sha);snapshotSynced=true;}catch(e){}\n try {await saveBanSnapshot(env,data.entries,data.sha);snapshotSynced=true;}catch(e){}\n}\nasync function verifyUserPolicy(request,env,origin){}\nconst policy={schema:1,subjectUserId:'123'};\nfunction json(x){return x}\nasync function githubRead(env){return {sha:'a'.repeat(40),source:env.source}}\n";

test('refuses incomplete or changed Worker source',()=>{
 assert.throws(()=>patchOriginalWorkerForBanV2('partial'),/Incomplete/);
 assert.throws(()=>patchOriginalWorkerForBanV2(source.replace('0.5.67.1-cors-response-staging','broken')),/Worker drift/);
});
test('review Worker parses and keeps Signed Policy schema1 plus disabled GitHub writes',()=>{
 const patched=patchOriginalWorkerForBanV2(source);
 assert.ok(patched.length>250000);
 assert.match(patched,/schema:managed.schema/);
 assert.match(patched,/compatibleSchemas:\[1,2\]/);
 assert.match(patched,/saveBanSnapshot\(env,data.entries,data.sha,undefined,data.schema\|\|1\)/);
 assert.match(patched,/const policy=\{schema:1,subjectUserId:/);
 assert.match(patched,/GitHub ban changes are disabled in staging/);
 new vm.Script(patched,{filename:'review-worker.js'});
});
test('validates schema1 and schema2 independently',()=>{
 const patched=patchOriginalWorkerForBanV2(source);
 const ctx=vm.createContext({});
 vm.runInContext(patched,ctx);
 const v2={...ENTRY,selection:'restricted_mode',duration:'permanent'};
 for(const [entry,schema,result] of [
  [ENTRY,1,true],[ENTRY,2,false],[v2,2,true],[v2,1,false],
  [{...v2,duration:'temporary'},2,false],[{...v2,selection:'bad'},2,false]
 ]){
  assert.equal(vm.runInContext('validBanEntry('+JSON.stringify(entry)+','+schema+')',ctx),result);
 }
});
test('snapshot supports v1/v2 and rejects mixed fields',()=>{
 const ctx=vm.createContext({});
 vm.runInContext(patchOriginalWorkerForBanV2(source),ctx);
 const v2={...ENTRY,selection:'ban_ingame',duration:'permanent'};
 assert.equal(vm.runInContext('validatedSnapshot('+JSON.stringify({schema:1,entries:[ENTRY]})+').length',ctx),1);
 assert.equal(vm.runInContext('validatedSnapshot('+JSON.stringify({schema:2,entries:[v2]})+').length',ctx),1);
 assert.throws(()=>vm.runInContext('validatedSnapshot('+JSON.stringify({schema:2,entries:[ENTRY]})+')',ctx),/Invalid/);
 assert.throws(()=>vm.runInContext('validatedSnapshot('+JSON.stringify({schema:1,entries:[v2]})+')',ctx),/Invalid/);
});
