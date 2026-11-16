// ArcScriptCenter Stage16.75 — offline, fail-closed Worker source assembler.
// Does NOT connect to Cloudflare, read secrets, activate Cron, or deploy code.
// Usage: node sandbox/stage16-75-assemble.mjs --source /path/to/current-sandbox-worker.js \
//        --output /tmp/asc-stage1675-review.js
import {readFileSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {fileURLToPath} from 'node:url';

const PREVIOUS='0.5.78.0-durable-push-outbox-sandbox';
const NEXT='0.5.79.0-cron-retry-sandbox';
const ANCHOR="export default {\n  async fetch(request, env, ctx) {";
const ROUTE_ANCHOR="    if(path==='/__stage1674/push-health'&&request.method==='GET')";
const HELPERS_MARKER='//__STAGE1675_ROUTES__';

function occurrences(text,needle){return text.split(needle).length-1;}
function check(condition,message){if(!condition)throw new Error('Refused Stage16.75 assembly: '+message);}

export function assembleStage1675(source, runner) {
 check(typeof source==='string'&&source.length>1000&&source.length<1000000,'unexpected source size');
 check(typeof runner==='string'&&runner.length>3000&&runner.length<30000,'unexpected runner size');
 check(occurrences(source,PREVIOUS)===2,'expected precisely two Stage16.74 version markers');
 check(occurrences(source,ANCHOR)===1,'main export/fetch anchor must be unique');
 check(occurrences(source,ROUTE_ANCHOR)===1,'Stage16.74 health route must be unique');
 check(occurrences(runner,HELPERS_MARKER)===1,'Cron runner split marker must be unique');
 check(!source.includes('/__stage1675/')&&!source.includes('async function asc1675CronRunner'),
       'Cron runner is already present');
 check(!source.includes('async scheduled(controller, env, ctx)'),
       'scheduled handler is already present');
 check(source.includes('async function asc1674RetryDue(env)'),
       'verified Stage16.74 due queue missing');
 check(source.includes('async function asc1674Deliver(env,id)'),
       'verified Stage16.74 sender missing');
 check(source.includes('asc_push_delivery_outbox_v1'),
       'expected D1 outbox schema reference missing');
 check(source.includes('ascStage1671VerifiedAdmin'),
       'required Admin Access identity guard missing');
 check(source.includes("ctx.waitUntil(ascStage1671Broadcast(env,id))"),
       'existing nonblocking post-submit push invocation missing');
 check(!source.includes('const ASC1675_CRON_HTML'),
       'Cron page already present');

 const [helpers,routes]=runner.split(HELPERS_MARKER);
 check(helpers.includes('async function asc1675CronRunner(controller,env,ctx)'),
       'Cron handler missing');
 check(helpers.includes('await asc1674RetryDue(env)'),'Cron retry queue call missing');
 check(helpers.includes('await asc1674Allowed(req,env,ctx)'),'Admin Access guard missing');
 check(helpers.includes("controller?.cron!=='*/5 * * * *'"),
       'expected exact five-minute Cron guard missing');
 check(routes.includes('/__stage1675/cron-health')&&routes.includes('/__stage1675/status'),
       'health routes missing');
 check(!routes.includes('export default'),'route fragment unexpectedly contains export');

 let out=source.replace(ANCHOR,
  helpers+"\nexport default {\n  async scheduled(controller, env, ctx) {\n    await asc1675CronRunner(controller,env,ctx);\n  },\n  async fetch(request, env, ctx) {");
 out=out.replace(ROUTE_ANCHOR,routes+'\n'+ROUTE_ANCHOR);
 out=out.replaceAll(PREVIOUS,NEXT);

 check(occurrences(out,NEXT)===2,'new version string missing or duplicated');
 check(occurrences(out,'async scheduled(controller, env, ctx)')===1,'scheduled handler must be unique');
 check(occurrences(out,'async function asc1675CronRunner')===1,'Cron runner must be unique');
 check(occurrences(out,"path==='/__stage1675/status'")===1,'Cron status route must be unique');
 check(out.includes('/__stage1673/real-turnstile-push')&&
       out.includes('/__stage1672/background-push')&&
       out.includes('/__stage1671/android-push'),
       'existing mobile test routes were lost');

 return out;
}

function parseArgs(args){
 const result={};
 for(let i=0;i<args.length;i+=2){
  check(['--source','--output'].includes(args[i])&&args[i+1],'expected --source and --output arguments');
  check(!Object.hasOwn(result,args[i]),'duplicate CLI argument');
  result[args[i]]=args[i+1];
 }
 check(Object.keys(result).length===2&&result['--source']&&result['--output'],
       'both explicit source and output paths required');
 check(resolve(result['--source'])!==resolve(result['--output']),
       'refusing to overwrite source');
 return result;
}

const isMain=process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href;
if(isMain){
 try {
  const args=parseArgs(process.argv.slice(2));
  const runner=readFileSync(fileURLToPath(new URL('./stage16-75-cron-retry-runner.js',import.meta.url)),'utf8');
  const bundle=assembleStage1675(readFileSync(args['--source'],'utf8'),runner);
  const target=resolve(args['--output']);
  // Stage the reviewed candidate locally. No cloud upload, secrets, or remote access.
  writeFileSync(target,bundle,{mode:0o600,flag:'wx'});
  const checkResult=spawnSync(process.execPath,['--check',target],{encoding:'utf8',timeout:10000});
  if(checkResult.status!==0)throw new Error('Node syntax check failed; candidate is NOT deployable');
  console.log('Stage16.75 assembly OK: local candidate created and syntax-checked; NOT deployed.');
 }catch(e){
  console.error(String(e?.message||e));
  process.exitCode=1;
 }
}
