import test from 'node:test';
import assert from 'node:assert/strict';
import {classifyManagedBan} from './arcscriptcenter-ban-types-staging.mjs';

const NOW=1795000000;
const base={userId:'12345',username:'TestUser',reason:'QA only',description:'',startAt:'2026-11-01 10:00',expiresAt:''};

test('both independent Ban selections support both durations',()=>{
 for(const [selection,label] of [['ban_ingame','Ban in-game'],['restricted_mode','Restricted Mode']])
  for(const [duration,expiresAt] of [['temporary','2026-12-01 10:00'],['permanent','']]){
   const actual=classifyManagedBan({...base,selection,duration,expiresAt},NOW);
   assert.equal(actual.selection,selection);
   assert.equal(actual.duration,duration);
   assert.equal(actual.type,'active');
   assert.equal(actual.label,label+' · '+(duration==='temporary'?'Temporary':'Permanent'));
  }
});
test('old managed bans preserve duration but never assume their Selection',()=>{
 const temporary=classifyManagedBan({...base,expiresAt:'2026-12-01 10:00'},NOW);
 const permanent=classifyManagedBan({...base,expiresAt:''},NOW);
 assert.equal(temporary.selection,'unassigned');
 assert.equal(permanent.selection,'unassigned');
 assert.equal(temporary.label,'Selection not set · Temporary');
 assert.equal(permanent.label,'Selection not set · Permanent');
 assert.doesNotMatch(temporary.label,/Temporary Banned/);
});
test('contradictory or unknown Ban selection metadata fails closed',()=>{
 assert.throws(()=>classifyManagedBan({...base,selection:'unsupported'},NOW),/Invalid Ban Selection/);
 assert.throws(()=>classifyManagedBan({...base,selection:'restricted_mode',duration:'permanent',expiresAt:'2026-12-01 10:00'},NOW),/contradicts expiry/);
 assert.throws(()=>classifyManagedBan({...base,selection:'ban_ingame',duration:'temporary',expiresAt:''},NOW),/contradicts expiry/);
});
test('scheduled and expired statuses do not reinterpret duration as selection',()=>{
 const scheduled=classifyManagedBan({...base,selection:'restricted_mode',expiresAt:'2026-12-01 10:00',startAt:'2026-11-26 10:00'},NOW);
 assert.equal(scheduled.type,'scheduled');assert.equal(scheduled.selection,'restricted_mode');assert.equal(scheduled.duration,'temporary');
 const expired=classifyManagedBan({...base,selection:'ban_ingame',expiresAt:'2026-11-01 11:00'},NOW);
 assert.equal(expired.type,'expired');assert.equal(expired.selection,'ban_ingame');assert.equal(expired.duration,'temporary');
});
