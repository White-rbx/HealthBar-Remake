import test from 'node:test';
import assert from 'node:assert/strict';
import { achievements, evaluateAchievements } from './achievements-candidate.mjs';
const zero={streakDays:0,usageSeconds:0,feedbackSent:0,feedbackApproved:0};
test('original catalog has 14 distinct IDs and all threshold boundaries',()=>{
 assert.equal(achievements.length,14);
 assert.equal(new Set(achievements.map(a=>a.id)).size,14);
 assert.deepEqual(evaluateAchievements(zero),[]);
 for(const a of achievements){
  const snapshot=n=>({...zero,[a.metric]:n,...(a.metric==='feedbackApproved'?{feedbackSent:n}:{})});
  assert.ok(!evaluateAchievements(snapshot(a.threshold-1)).includes(a.id));
  assert.ok(evaluateAchievements(snapshot(a.threshold)).includes(a.id));
 }
});
test('all earned badges persist even after a streak reset; unknown IDs never grant an award',()=>{
 const all=evaluateAchievements({streakDays:20,usageSeconds:2592000,feedbackSent:5,feedbackApproved:5});
 assert.equal(all.length,14);
 assert.deepEqual(evaluateAchievements(zero,[...all,'unknown']),all);
});
test('reject missing, negative, fractional and inconsistent counters',()=>{
 for(const value of [null,-1,1.5,NaN,Infinity,'5',Number.MAX_SAFE_INTEGER+1]){
  assert.throws(()=>evaluateAchievements({...zero,usageSeconds:value}),TypeError);
 }
 assert.throws(()=>evaluateAchievements({}),TypeError);
 assert.throws(()=>evaluateAchievements({...zero,feedbackApproved:5}),TypeError);
});
