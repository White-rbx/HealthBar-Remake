import test from 'node:test';
import assert from 'node:assert/strict';
import {inspectBanPolicy,describeBanSelection} from './arcscriptcenter-ban-selection-duration.mjs';

test('both selections support temporary AND permanent independently',()=>{
 let count=0;
 for(const selection of ['ban_ingame','restricted_mode'])
  for(const duration of ['temporary','permanent']){
   const expiresAt=duration==='temporary'?'2026-12-01 00:00':'';
   const resolved=inspectBanPolicy({selection,duration,expiresAt});
   assert.equal(resolved.selection,selection);
   assert.equal(resolved.duration,duration);
   assert.ok(describeBanSelection(resolved).effect);
   count++;
  }
 assert.equal(count,4);
});
test('existing legacy bans do not get a guessed selection',()=>{
 const r=inspectBanPolicy({userId:'123',expiresAt:'2026-12-01 00:00'});
 assert.equal(r.selection,'unassigned');
 assert.equal(r.migrationRequired,true);
});
test('duration contradicting expiry fails closed',()=>{
 assert.throws(()=>inspectBanPolicy({selection:'restricted_mode',duration:'temporary',expiresAt:''}));
 assert.throws(()=>inspectBanPolicy({selection:'ban_ingame',duration:'permanent',expiresAt:'2026-12-01 00:00'}));
});
test('unrecognized selections fail closed',()=>{
 assert.throws(()=>inspectBanPolicy({selection:'other',duration:'temporary',expiresAt:'2026-12-01 00:00'}));
});
