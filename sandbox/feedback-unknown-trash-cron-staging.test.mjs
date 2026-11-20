import test from 'node:test';
import assert from 'node:assert/strict';
import cronWorker from './feedback-unknown-trash-cron-staging.mjs';

test('HTTP requests can never trigger deletion',async()=>{
 const res=await cronWorker.fetch(new Request('https://any.example/cron/delete'));
 assert.equal(res.status,404);
 assert.equal(await res.text(),'Not found');
});

test('wrong Cron does not touch D1',async()=>{
 let scheduled=false;
 await cronWorker.scheduled({cron:'* * * * *'}, {DB:{prepare(){throw Error('must not be invoked')}}},
  {waitUntil(){scheduled=true}});
 assert.equal(scheduled,false);
});

test('scheduled worker fails closed without STAGING D1 binding',async()=>{
 await assert.rejects(()=>cronWorker.scheduled({cron:'0 * * * *'}, {},
  {waitUntil(){throw Error('not called')}}),/STAGING D1 DB binding unavailable/);
});

test('hourly schedule only queries eligible records and returns no data to visitors',async()=>{
 let query='',bound=[],task;
 const db={prepare(sql){query=sql;return{bind(...params){bound=params;return{all:async()=>({results:[]})}}}},batch:async()=>{throw Error('must not run with no due cases')}};
 await cronWorker.scheduled({cron:'0 * * * *'}, {DB:db}, {waitUntil(p){task=p}});
 await task;
 assert.match(query,/asc_feedback_unknown_trash/);
 assert.match(query,/c\.removed=1/);
 assert.match(query,/claimed_user_id IS NULL/);
 assert.equal(bound[1],50);
});
