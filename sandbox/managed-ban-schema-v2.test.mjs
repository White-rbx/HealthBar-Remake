import test from 'node:test';
import assert from 'node:assert/strict';
import {
 parseBanDocument,migrateBanDocument,validateBanEntryV2,
 effectiveBanSelection,selectActiveBan,applyBanChange,
 parseBanLua,renderBanLua,prepareBanV2LuaUpdate
} from './managed-ban-schema-v2.mjs';

const legacy={userId:'123456789',username:'ExampleUser',reason:'Testing policy',
 description:'A public test note',startAt:'2026-11-01 10:00',expiresAt:'2026-11-30 10:00'};
const initial={schema:1,entries:[legacy]};
const setup=doc=>[
 'local prefix = "keep";','-- ARCSCRIPT_BANS_BEGIN',
 'local _ASC_MANAGED_JSON = [==[',JSON.stringify(doc),']==]',
 '-- ARCSCRIPT_BANS_END','local suffix = "untouched";',''
].join('\n');
const SHA='a'.repeat(40);

test('v1→v2 preserves all six source fields and marks Selection unassigned',()=>{
 const migrated=migrateBanDocument(initial);
 assert.equal(migrated.schema,2);
 assert.deepEqual(Object.fromEntries(Object.keys(legacy).map(k=>[k,migrated.entries[0][k]])),legacy);
 assert.equal(migrated.entries[0].selection,'unassigned');
 assert.equal(migrated.entries[0].duration,'temporary');
 assert.equal(effectiveBanSelection(migrated.entries[0]),'ban_ingame');
 assert.equal(initial.schema,1);
 assert.equal(initial.entries[0].selection,undefined);
 assert.deepEqual(migrateBanDocument(migrated),migrated);
});

test('new Ban entries require explicit Selection independently of Duration: four combinations',()=>{
 for(const selection of ['ban_ingame','restricted_mode']){
  for(const duration of ['temporary','permanent']){
   const entry={...legacy,userId:selection==='restricted_mode'?'234567891':'345678912',
    selection,duration,expiresAt:duration==='temporary'?'2026-12-01 10:00':''};
   assert.equal(validateBanEntryV2(entry,{allowUnassigned:false}),true);
   const doc=applyBanChange(initial,{action:'upsert',entry});
   const row=doc.entries.find(x=>x.userId===entry.userId);
   assert.equal(row.selection,selection);
   assert.equal(row.duration,duration);
   assert.equal(effectiveBanSelection(row),selection);
   assert.equal(doc.entries.find(x=>x.userId===legacy.userId).selection,'unassigned');
  }
 }
});

test('Duration and Expires are consistent; reject unsupported Selection and missing explicit type',()=>{
 const valid={...legacy,selection:'ban_ingame',duration:'temporary'};
 for(const changed of [
  {...valid,selection:'other'}, {...valid,selection:'unassigned'},
  {...valid,selection:undefined},{...valid,duration:undefined},
  {...valid,duration:'permanent'}, {...valid,duration:'temporary',expiresAt:''},
  {...valid,expiresAt:'2026-02-30 15:00'},
  {...valid,startAt:'2026-12-10 00:00',expiresAt:'2026-12-01 10:00'},
  {...valid,userId:'9999999999999999'},
  {...valid,reason:'\x00a'},
  {...valid,unexpected:'field'}
 ])assert.throws(()=>applyBanChange(initial,{action:'upsert',entry:changed}),/Invalid v2 Ban entry/);
});

test('legacy permanent bans remain SetUp-only and duration remains permanent',()=>{
 const doc=migrateBanDocument({schema:1,entries:[{...legacy,expiresAt:''}]});
 assert.equal(doc.entries[0].selection,'unassigned');
 assert.equal(doc.entries[0].duration,'permanent');
 assert.equal(effectiveBanSelection(doc.entries[0]),'ban_ingame');
});

test('start and expiration apply to either Selection, and expire without changing mode',()=>{
 const entry={...legacy,selection:'restricted_mode',duration:'temporary'};
 const doc={schema:2,entries:[entry]};
 const time=t=>Math.floor(Date.parse(t)/1000);
 assert.equal(selectActiveBan(doc.entries,entry.userId,time('2026-10-31T23:59:00Z')),null);
 assert.equal(selectActiveBan(doc.entries,entry.userId,time('2026-11-10T10:00:00Z')).selection,'restricted_mode');
 assert.equal(selectActiveBan(doc.entries,entry.userId,time('2026-12-01T10:00:00Z')),null);
});

test('reject duplicate users and unrecognized payloads; no silent dropping of fields',()=>{
 assert.throws(()=>parseBanDocument({schema:1,entries:[legacy,legacy]}),/Duplicate/);
 assert.throws(()=>parseBanDocument({schema:3,entries:[]}),/Unsupported/);
 assert.throws(()=>parseBanDocument({schema:1,entries:[{...legacy,selection:'restricted_mode'}]}),/Invalid/);
 assert.throws(()=>parseBanDocument({schema:2,entries:[legacy]}),/Invalid/);
 assert.throws(()=>parseBanDocument({schema:2,entries:Array(201).fill({...legacy,selection:'unassigned',duration:'temporary'})}),/Unsupported/);
});

test('Setup Lua managed block upgraded once, preserving other Lua and markers',()=>{
 const original=setup(initial);
 const out=prepareBanV2LuaUpdate({source:original,sha:SHA,expectedSha:SHA,change:{
  action:'upsert',entry:{...legacy,userId:'234567891',selection:'restricted_mode',duration:'permanent',expiresAt:''}
 }});
 assert.equal(out.document.schema,2);
 assert.equal(out.document.entries.length,2);
 assert.equal(out.modified.split('-- ARCSCRIPT_BANS_BEGIN').length-1,1);
 assert.equal(out.modified.split('-- ARCSCRIPT_BANS_END').length-1,1);
 assert.ok(out.modified.startsWith('local prefix = "keep";'));
 assert.ok(out.modified.endsWith('local suffix = "untouched";\n'));
 assert.deepEqual(parseBanLua(out.modified).document,out.document);
 assert.equal(renderBanLua(out.document).includes('"schema":2'),true);
});

test('refuse stale or invalid GitHub SHA before editing Lua, no fetch or write',()=>{
 assert.throws(()=>prepareBanV2LuaUpdate({source:setup(initial),sha:SHA,expectedSha:'b'.repeat(40),change:{action:'remove',userId:legacy.userId}}),/SHA conflict/);
 assert.throws(()=>prepareBanV2LuaUpdate({source:setup(initial),sha:'not-sha',expectedSha:'not-sha',change:{action:'remove',userId:legacy.userId}}),/SHA conflict/);
});

test('preserve existing bans when editing one; reject accidental missing removal',()=>{
 const current={schema:2,entries:[{...legacy,selection:'unassigned',duration:'temporary'},
  {...legacy,userId:'234567891',selection:'ban_ingame',duration:'temporary'}]};
 const changed=applyBanChange(current,{action:'upsert',entry:{...current.entries[1],selection:'restricted_mode'}});
 assert.equal(changed.entries[0].selection,'unassigned');
 assert.equal(changed.entries[1].selection,'restricted_mode');
 assert.throws(()=>applyBanChange(current,{action:'remove',userId:'77777777'}),/does not exist/);
 assert.throws(()=>applyBanChange(current,{action:'remove',userId:'not-an-id'}),/Invalid removal/);
});

test('malformed or repeated Lua markers fail closed',()=>{
 const source=setup(initial);
 assert.throws(()=>parseBanLua(source+'-- ARCSCRIPT_BANS_END\n'),/Missing or repeated/);
 assert.throws(()=>parseBanLua(source.replace('[==[','[[ ')),/Unexpected Lua ban block/);
 assert.throws(()=>parseBanLua('no markers'),/Missing or repeated/);
});
