// Stage 16.75 — offline Worker assembler contract tests; no Cloudflare network or secrets.
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,mkdtempSync,writeFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {assembleStage1675} from './stage16-75-assemble.mjs';

const runner=readFileSync(fileURLToPath(new URL('./stage16-75-cron-retry-runner.js',import.meta.url)),'utf8');
const before='0.5.78.0-durable-push-outbox-sandbox';
const after='0.5.79.0-cron-retry-sandbox';
function fixture(){
 return [
 "const VERSION = '"+before+"';",
 "const BUILD = '"+before+"';",
 "async function asc1674RetryDue(env){return {jobs:0,attempted:0,accepted:0,failed:0};}",
 "async function asc1674Deliver(env,id){return {accepted:0};}",
 "async function asc1674Allowed(req,env,ctx){return true;}",
 "function asc1674Json(o,status=200){return new Response(JSON.stringify(o),{status});}",
 "function ascStage1671VerifiedAdmin(){return true;}",
 "function ascStage1671Broadcast(env,id){return Promise.resolve();}",
 "function submit(env,ctx,id){ctx.waitUntil(ascStage1671Broadcast(env,id));}",
 "const marker='asc_push_delivery_outbox_v1';",
 "// Existing protected routes: /__stage1673/real-turnstile-push /__stage1672/background-push /__stage1671/android-push",
 "// "+'x'.repeat(1500),
 "export default {",
 "  async fetch(request, env, ctx) {",
 "    const path=new URL(request.url).pathname;",
 "    if(path==='/__stage1674/push-health'&&request.method==='GET')return new Response('health');",
 "    return new Response('not-found',{status:404});",
 "  }",
 "};"
 ].join('\n');
}

test('assembler adds one scheduled handler and two protected health routes',()=>{
 const built=assembleStage1675(fixture(),runner);
 assert.match(built,/async scheduled\(controller, env, ctx\)/);
 assert.match(built,/await asc1675CronRunner\(controller,env,ctx\)/);
 assert.match(built,/if\(path==='\/__stage1675\/cron-health'/);
 assert.match(built,/if\(path==='\/__stage1675\/status'/);
 assert.equal(built.split('async function asc1675CronRunner').length,2);
 assert.equal(built.split(after).length,3);
 assert.doesNotMatch(built,/0\.5\.78\.0-durable-push-outbox-sandbox/);
});

test('assembled Worker source passes real Node module syntax check',()=>{
 const dir=mkdtempSync(join(tmpdir(),'asc1675-ci-'));
 try{
  const name=join(dir,'worker-candidate.mjs');
  writeFileSync(name,assembleStage1675(fixture(),runner),{mode:0o600});
  const x=spawnSync(process.execPath,['--check',name],{encoding:'utf8',timeout:10000});
  assert.equal(x.status,0,x.stderr);
 }finally{rmSync(dir,{force:true,recursive:true})}
});

test('assembler refuses a changed Worker version',()=>{
 assert.throws(()=>assembleStage1675(fixture().replaceAll(before,'stage16.76-production'),runner),
  /two Stage16\.74 version markers/);
});

test('assembler refuses an existing scheduled handler (no accidental duplication)',()=>{
 const source=fixture().replace("export default {",
  "export default {\n  async scheduled(controller, env, ctx) {},");
 assert.throws(()=>assembleStage1675(source,runner),/scheduled handler is already present/);
});

test('assembler refuses missing or duplicated Stage16.74 route anchor',()=>{
 const route="    if(path==='/__stage1674/push-health'&&request.method==='GET')";
 assert.throws(()=>assembleStage1675(fixture().replace(route,''),runner),/route must be unique/);
 assert.throws(()=>assembleStage1675(fixture().replace(route,route+'\n'+route),runner),/route must be unique/);
});

test('assembler refuses missing Access guard and missing Outbox data layer',()=>{
 assert.throws(()=>assembleStage1675(fixture().replace('ascStage1671VerifiedAdmin','invalidIdentity'),runner),
  /Admin Access identity guard/);
 assert.throws(()=>assembleStage1675(fixture().replace('asc_push_delivery_outbox_v1','missing_outbox'),runner),
  /D1 outbox schema reference/);
});

test('assembler refuses modified Cron guard and broken route split',()=>{
 const changed=runner.replace("controller?.cron!=='*/5 * * * *'","controller?.cron!=='* * * * *'");
 assert.throws(()=>assembleStage1675(fixture(),changed),/expected exact five-minute Cron guard/);
 const noMarker=runner.replace('//__STAGE1675_ROUTES__','//NOT_A_ROUTE_MARKER');
 assert.throws(()=>assembleStage1675(fixture(),noMarker),/split marker must be unique/);
});
