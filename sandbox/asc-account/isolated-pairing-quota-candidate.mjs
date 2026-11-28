// Stage 7 review-only isolated QA admission counter; not deployed or wired.
// Apply schema only to the dedicated QA database after review. Never Production.
export const quotaSchema = `CREATE TABLE IF NOT EXISTS asc_qa_pair_gateway_budget (
 op TEXT PRIMARY KEY CHECK(op IN ('pair/start','pair/poll','session','heartbeat','logout')),
 minute_bucket INTEGER NOT NULL, minute_count INTEGER NOT NULL CHECK(minute_count>0),
 day_bucket INTEGER NOT NULL, day_count INTEGER NOT NULL CHECK(day_count>0)
)`;
const limits=Object.freeze({
 'pair/start':Object.freeze([20,200]),
 'pair/poll':Object.freeze([120,4000]),
 session:Object.freeze([120,5000]),
 heartbeat:Object.freeze([120,5000]),
 logout:Object.freeze([60,500]),
});
const sql=`INSERT INTO asc_qa_pair_gateway_budget
 (op,minute_bucket,minute_count,day_bucket,day_count)
 VALUES (?1,?2,1,?3,1)
 ON CONFLICT(op) DO UPDATE SET
 minute_bucket=excluded.minute_bucket,
 minute_count=CASE WHEN excluded.minute_bucket>minute_bucket THEN 1 ELSE minute_count+1 END,
 day_bucket=excluded.day_bucket,
 day_count=CASE WHEN excluded.day_bucket>day_bucket THEN 1 ELSE day_count+1 END
 WHERE excluded.minute_bucket>=minute_bucket AND excluded.day_bucket>=day_bucket
 AND (excluded.minute_bucket>minute_bucket OR minute_count<?4)
 AND (excluded.day_bucket>day_bucket OR day_count<?5)
 RETURNING minute_count,day_count`;

// Call once per admitted operation AFTER route/body validation and native edge
// throttle, BEFORE business SQL. A rejected call must not enter the gateway.
// UTC fixed windows, one row per route; no IP, tokens, or user IDs persisted.
// This bounds admitted operations, not Worker invocations or rejected D1 writes.
export async function reservePairGatewayBudget(env,op,now=Math.floor(Date.now()/1000)){
 if(env?.ASC_PAIR_GATEWAY_MODE!=='isolated-qa'||
    env.ASC_PAIR_GATEWAY_LAUNCH_STATE!=='explicit-test-enabled'||
    !Object.hasOwn(limits,op)||!Number.isSafeInteger(now)||now<0||
    typeof env.PAIR_DB?.prepare!=='function')
  return {allowed:false,status:503};
 const [minuteCap,dayCap]=limits[op];
 try {
  const row=await env.PAIR_DB.prepare(sql).bind(op,Math.floor(now/60),Math.floor(now/86400),minuteCap,dayCap).first();
  return row?{allowed:true,status:200}:{allowed:false,status:429};
 } catch {
  return {allowed:false,status:503};
 }
}
