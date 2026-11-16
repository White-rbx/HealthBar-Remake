// Stage16.75 offline end-to-end reliability check against Stage16.74 Outbox + Stage16.75 Cron source.
// Entirely in memory: no Cloudflare network, real D1, user data, credentials, or real notifications.
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import {fileURLToPath} from "node:url";

const dir=path.dirname(fileURLToPath(import.meta.url));
const outboxSource=fs.readFileSync(path.join(dir,"stage16-74-push-outbox-helpers.js"),"utf8");
const cronSource=fs.readFileSync(path.join(dir,"stage16-75-cron-retry-runner.js"),"utf8");
const segment=(source,begin,end)=>{
 const i=source.indexOf(begin),j=source.indexOf(end,i+begin.length);
 assert.ok(i>=0&&j>i,"Expected code anchors: "+begin);
 return source.slice(i,j);
};
const implementation=
 segment(outboxSource,"async function asc1674Deliver(env,id){","function asc1674Json(data,status=200)")+
 "\n"+segment(cronSource,"async function asc1675CronRunner(controller,env,ctx){","async function asc1675Page(req,env,ctx){")+
 "\nglobalThis.testDeliver=asc1674Deliver;globalThis.testRetry=asc1674RetryDue;globalThis.testCron=asc1675CronRunner;";

function harness(outcomes=[{ok:true,status:201}],stateOverrides={}){
 let now=2000000,sendCount=0,seenSQL=[];
 const item={
  case_id:"case-isolated-test",endpoint_hash:"synthetic-hash",
  state:"pending",kind:"feedback",attempts:0,next_retry_unix:0,
  lease_until_unix:0,last_http_status:0,created_unix:now,updated_unix:now,
  delivered_unix:0,...stateOverrides
 };
 const caseRow={id:item.case_id,removed:0,status:"reviewing"};
 const subscriber={endpoint:"https://fcm.googleapis.com/fcm/send/synthetic-only",enabled:true,last_sent_event_id:0};
 const telemetry={runs:0,last_error:"never",last_attempted:0,last_accepted:0,last_failed:0,last_jobs:0};
 const result={item,caseRow,subscriber,telemetry,get now(){return now},set now(n){now=n},get sendCount(){return sendCount},get sql(){return seenSQL}};
 const activeCase=()=>caseRow.id===item.case_id&&caseRow.removed===0&&caseRow.status!=="spam_mail";
 const eligible=()=>item.attempts<3&&activeCase()&&
 (item.state==="pending"||(item.state==="retry"&&item.next_retry_unix<=now)||
 (item.state==="sending"&&item.lease_until_unix<=now));
 const query=(sql,args,method)=>{
  seenSQL.push({op:method,query:sql.slice(0,130)});
  if(sql.startsWith("SELECT o.endpoint_hash")){
   return {results:["pending","retry","sending"].includes(item.state)?[{
    endpoint_hash:item.endpoint_hash,endpoint:subscriber.enabled?subscriber.endpoint:null,
    active_case:caseRow.id,removed:caseRow.removed,case_status:caseRow.status,
   }]:[]};
  }
  if(sql.startsWith("SELECT DISTINCT case_id")){
   const due=(["pending","retry"].includes(item.state)&&item.next_retry_unix<=now)||
    (item.state==="sending"&&item.lease_until_unix<=now);
   return {results:due?[{case_id:item.case_id}]:[]};
  }
  if(sql.startsWith("UPDATE asc_push_delivery_outbox_v1 SET state='sending'")){
   if(!eligible())return null;
   item.state="sending";item.attempts++;
   item.lease_until_unix=args[0];item.updated_unix=now;
   return {attempts:item.attempts};
  }
  if(sql.startsWith("UPDATE asc_push_delivery_outbox_v1 SET state='delivered'")){
   if(item.state!=="sending"||item.attempts!==args[5]||item.lease_until_unix!==args[6])return null;
   item.state="delivered";item.last_http_status=args[0];item.delivered_unix=now;item.lease_until_unix=0;
   return {case_id:item.case_id};
  }
  if(sql.startsWith("SELECT MAX(event_id)"))return {event_id:99};
  if(sql.startsWith("UPDATE asc_admin_push_subscriptions_v1 SET last_sent_event_id=")){
   subscriber.last_sent_event_id=args[0];return {success:true};
  }
  if(sql.startsWith("UPDATE asc_push_delivery_outbox_v1 SET state=?,last_http_status=?")){
   if(item.state==="sending"&&item.attempts===args[6]&&item.lease_until_unix===args[7]){
    item.state=args[0];item.last_http_status=args[1];item.next_retry_unix=args[2];
    item.lease_until_unix=0;item.updated_unix=now;
   }
   return {success:true};
  }
  if(sql.startsWith("UPDATE asc_push_delivery_outbox_v1 SET state='canceled'")){
   item.state="canceled";item.lease_until_unix=0;return {success:true};
  }
  if(sql.startsWith("UPDATE asc_push_delivery_outbox_v1 SET state='dead',last_http_status=410")){
   item.state="dead";item.last_http_status=410;item.lease_until_unix=0;return {success:true};
  }
  if(sql.startsWith("DELETE FROM asc_admin_push_subscriptions_v1")){
   subscriber.enabled=false;return {success:true};
  }
  if(sql.startsWith("UPDATE asc_push_delivery_outbox_v1 SET state='dead',lease_until_unix=0")){
   if(item.state==="sending"&&item.attempts>=3&&item.lease_until_unix<=now){
    item.state="dead";item.lease_until_unix=0;
   }
   return {success:true};
  }
  if(sql.startsWith("UPDATE asc_push_cron_health_v1 SET runs=runs+1")){
   telemetry.runs++;telemetry.last_error="none";return {success:true};
  }
  if(sql.startsWith("UPDATE asc_push_cron_health_v1 SET last_finished_unix=?,last_jobs=?")){
   telemetry.last_jobs=args[1];telemetry.last_attempted=args[2];
   telemetry.last_accepted=args[3];telemetry.last_failed=args[4];
   telemetry.last_error="none";return {success:true};
  }
  if(sql.startsWith("UPDATE asc_push_cron_health_v1 SET last_finished_unix=?,last_error='worker_error'")){
   telemetry.last_error="worker_error";return {success:true};
  }
  throw Error("Unexpected simulated SQL: "+sql.slice(0,180));
 };
 const env={
  ASC_TURNSTILE_MODE:"sandbox-dummy",ASC_PUSH_ACCESS_AUD:"synthetic-audience",
  DB:{prepare(sql){let args=[];return {
   bind(...values){args=values;return this},
   async all(){return query(sql,args,"all")},
   async first(){return query(sql,args,"first")},
   async run(){return query(sql,args,"run")}
  }}}
 };
 const context=vm.createContext({
  VERSION:"0.5.79.0-cron-retry-sandbox",
  Date:class extends Date{static now(){return now*1000}},
  Math,Number,JSON,String,
  ascStage1671VapidSend:async()=>{
   sendCount++;
   return outcomes[Math.min(sendCount-1,outcomes.length-1)];
  }
 });
 vm.runInContext(implementation,context,{filename:"Stage16.74+16.75 assembled mock"});
 result.deliver=()=>context.testDeliver(env,item.case_id);
 result.retry=()=>context.testRetry(env);
 result.cron=(expr="*/5 * * * *")=>context.testCron({cron:expr},env,{});
 return result;
}
test("pending case sends once, marks delivered and cannot replay at later cron ticks",async()=>{
 const h=harness();
 const first=await h.deliver();
 assert.equal(first.accepted,1);
 assert.equal(first.attempted,1);
 assert.equal(h.item.state,"delivered");
 assert.equal(h.item.attempts,1);
 assert.equal(h.subscriber.last_sent_event_id,99);
 h.now+=3600;await h.cron();await h.cron();
 assert.equal(h.sendCount,1);
 assert.equal(h.telemetry.runs,2);
 assert.equal(h.telemetry.last_attempted,0);
});
test("transient 503 schedules 60s backoff and Cron later retries one time",async()=>{
 const h=harness([{ok:false,status:503},{ok:true,status:201}]);
 const first=await h.deliver();
 assert.equal(first.failed,1);
 assert.equal(h.item.state,"retry");
 assert.equal(h.item.attempts,1);
 assert.equal(h.item.next_retry_unix,h.now+60);
 h.now+=59;await h.cron();
 assert.equal(h.sendCount,1);
 h.now+=1;await h.cron();
 assert.equal(h.sendCount,2);
 assert.equal(h.item.state,"delivered");
 assert.equal(h.item.attempts,2);
 assert.equal(h.telemetry.last_accepted,1);
 h.now+=600;await h.cron();
 assert.equal(h.sendCount,2);
});
test("expired Push subscription 410 is dead and revoked, never retried",async()=>{
 const h=harness([{ok:false,status:410}]);
 const first=await h.deliver();
 assert.equal(first.failed,1);
 assert.equal(h.item.state,"dead");
 assert.equal(h.subscriber.enabled,false);
 h.now+=700;await h.cron();
 assert.equal(h.sendCount,1);
});
test("spam case is canceled without reaching the Push service",async()=>{
 const h=harness();
 h.caseRow.status="spam_mail";
 await h.deliver();
 assert.equal(h.item.state,"canceled");
 assert.equal(h.sendCount,0);
});
test("concurrent deliver calls respect one atomic outbox claim",async()=>{
 const h=harness();
 const [x,y]=await Promise.all([h.deliver(),h.deliver()]);
 assert.equal(x.accepted+y.accepted,1);
 assert.equal(h.sendCount,1);
 assert.equal(h.item.state,"delivered");
});
test("third failed attempt becomes dead and never exceeds 3 attempts",async()=>{
 const h=harness([{ok:false,status:503},{ok:false,status:503},{ok:false,status:503}]);
 await h.deliver();
 assert.equal(h.item.next_retry_unix,h.now+60);
 h.now+=60;await h.cron();
 assert.equal(h.item.next_retry_unix,h.now+300);
 h.now+=300;await h.cron();
 assert.equal(h.item.state,"dead");
 assert.equal(h.item.attempts,3);
 h.now+=3600;await h.cron();
 assert.equal(h.sendCount,3);
});
test("expired exhausted sending lease transitions to dead without sending again",async()=>{
 const h=harness([{ok:true,status:201}],{state:"sending",attempts:3,lease_until_unix:1999999});
 await h.cron();
 assert.equal(h.item.state,"dead");
 assert.equal(h.sendCount,0);
});
