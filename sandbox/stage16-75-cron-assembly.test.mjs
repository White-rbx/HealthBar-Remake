// Stage16.75 - validate assembled draft routes, access guards and data redaction.
// Sandboxed VM; no external requests, secrets, D1 or push service access.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { webcrypto } from 'node:crypto';
import { fileURLToPath } from 'node:url';

const base = path.dirname(fileURLToPath(import.meta.url));
const text = fs.readFileSync(path.join(base, 'stage16-75-cron-retry-runner.js'), 'utf8');
const [helper, routes, ...rest] = text.split('//__STAGE1675_ROUTES__');
assert.equal(rest.length, 0);

const assembled = helper + '\nasync function simulatedFetch(request,env,ctx) {\n' +
  'const path=new URL(request.url).pathname;\n' + routes +
  '\nreturn new Response("Not found",{status:404});\n}\n' +
  'globalThis.__fetch=simulatedFetch;\n';

function init(isAuthorized = false) {
  const sqlCalls = [];
  const sandbox = vm.createContext({
    VERSION: '0.5.79.0-cron-retry-sandbox',
    asc1674RetryDue: async () => ({jobs:0,attempted:0,accepted:0,failed:0}),
    asc1674Allowed: async () => isAuthorized,
    asc1674Json: (data,status=200) => new Response(JSON.stringify(data), {
      status,headers:{'Content-Type':'application/json'},
    }),
    crypto:webcrypto, Response, URL, Date, Math, Number, String, Object,
    btoa: b => Buffer.from(b,'binary').toString('base64'),
  });
  new vm.Script(assembled, { filename: 'assembled-stage16-75.js' }).runInContext(sandbox);
  const env={DB:{prepare(sql){sqlCalls.push(sql);return {
    bind(){return this},
    async first(){return sql.includes('asc_push_cron_health')?{
      runs:3,last_started_unix:2000,last_finished_unix:2002,last_jobs:1,
      last_attempted:1,last_accepted:1,last_failed:0,last_error:'none',
    }:sql.includes('asc_admin_push_subscriptions')?{n:1}:{n:0}},
    async all(){return {results:[{state:'delivered',n:5}]}}
  }}}};
  return {sandbox,env,sqlCalls};
}
const url='https://arcscriptcenter-merge-sandbox-1658.kogpasan14.workers.dev';

test('staged helper and route fragment compile as a fetch-handler body',()=>{
  assert.ok(new vm.Script(assembled));
});

test('unapproved identity gets 401 for Cron page and API without any D1 read',async()=>{
  const {sandbox,env,sqlCalls}=init(false);
  for(const pathname of ['/__stage1675/cron-health','/__stage1675/status']){
    const res=await sandbox.__fetch(new Request(url+pathname),env,{});
    assert.equal(res.status,401);
  }
  assert.equal(sqlCalls.length,0);
});

test('authorized Cron status shows only aggregate counts and no sensitive strings',async()=>{
  const {sandbox,env}=init(true);
  const res=await sandbox.__fetch(new Request(url+'/__stage1675/status'),env,{});
  assert.equal(res.status,200);
  const data=await res.json();
  assert.equal(data.cronRuns,3);
  assert.equal(data.subscribers,1);
  assert.equal(data.counts.delivered,5);
  assert.equal(data.counts.pending,0);
  for(const key of Object.keys(data))assert.doesNotMatch(key,/email|endpoint|token|receipt|description|topic|secret|key/i);
});

test('authorized health page returns HTML with no-store and restrictive CSP',async()=>{
  const {sandbox,env}=init(true);
  const res=await sandbox.__fetch(new Request(url+'/__stage1675/cron-health'),env,{});
  assert.equal(res.status,200);
  assert.match(res.headers.get('Cache-Control'),/no-store/);
  assert.match(res.headers.get('Content-Security-Policy'),/frame-ancestors 'none'/);
  const html=await res.text();
  assert.match(html,/Automatic Push Retry/);
  assert.match(html,/__stage1675\/status/);
  assert.doesNotMatch(html,/<input[^>]*type=['"]password/);
});

test('unexpected method on health endpoint is rejected; other path not intercepted',async()=>{
  const {sandbox,env}=init(true);
  const bad=await sandbox.__fetch(new Request(url+'/__stage1675/status',{method:'POST'}),env,{});
  assert.equal(bad.status,405);
  const missing=await sandbox.__fetch(new Request(url+'/__stage1675/unused'),env,{});
  assert.equal(missing.status,404);
});
