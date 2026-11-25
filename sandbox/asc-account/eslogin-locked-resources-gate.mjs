// Read-only source-level control-plane assertions for ESLogin isolated QA.
// This validates the locked D1 + independent Rate Limiter phase ONLY.
// It does not prove Passkey enrollment, Turnstile, login or authenticated edge access.
export const LOCKED_EDGE=Object.freeze({
 worker:'arcscriptcenter-eslogin-edge-qa',
 workerId:'45dc479f0856439bb004c31dc6a48642',
 db:'04715765-050f-4e26-b4f6-6101bba9dc97',
 dbName:'asc-eslogin-passkey-isolated-qa-20261125',
 rateNamespace:'20261125',
 accessApp:'ea0346cb-02fb-44dc-a5dd-5ada7c60977f',
 deployedQa:'6b9420db-381c-4d53-8692-a82b76399b52',
 oldQaDb:'93d7dc3d-c196-40ee-a342-4144f0b85d50',
});
export const REQUIRED_ACCOUNT_TABLES=Object.freeze([
 'asc_account_cases','asc_account_pairings','asc_account_passkey_backup_flows',
 'asc_account_passkey_flows','asc_account_passkey_recovery_codes',
 'asc_account_passkey_recovery_flows','asc_account_passkeys',
 'asc_account_recovery','asc_account_sessions','asc_account_verified_links','asc_accounts',
]);
const ensure=(test,message)=>{if(!test)throw Error('ESLOGIN_LOCKED_EDGE_BLOCKED: '+message);};
export function verifyLockedEdgeResources(s){
 const {worker,bindings,access,policies,subdomain,qaDeployment,qaSubdomain,
  database,databaseRows,foreignKeyViolations}=s||{};
 ensure(worker?.name===LOCKED_EDGE.worker&&worker?.id===LOCKED_EDGE.workerId,
  'wrong independent Worker identity');
 ensure(Array.isArray(bindings)&&bindings.length===2,
  'only isolated D1 and isolated Rate Limiter are permitted in this phase');
 const db=bindings.find(b=>b.name==='ACCOUNT_DB');
 const limit=bindings.find(b=>b.name==='ACCOUNT_RATE');
 ensure(db?.type==='d1'&&db.id===LOCKED_EDGE.db&&db.id!==LOCKED_EDGE.oldQaDb,
  'wrong D1 ID or original QA D1 reused');
 ensure(limit?.type==='ratelimit'&&limit.namespace_id===LOCKED_EDGE.rateNamespace
  &&limit.simple?.limit===40&&limit.simple?.period===60,
  'wrong isolated rate limiting namespace/configuration');
 ensure(!bindings.some(b=>['ASC_ACCOUNT_AUTH_MODE','ASC_ACCOUNT_LAUNCH_STATE'].includes(b.name)),
  'real authentication launch flags must not be present');
 ensure(access?.id===LOCKED_EDGE.accessApp&&access.type==='self_hosted'
  &&access.options_preflight_bypass===false
  &&access.destinations?.length===1
  &&access.destinations[0].type==='worker'
  &&access.destinations[0].worker_id===LOCKED_EDGE.workerId
  &&!access.destinations[0].overrides?.length,
  'locked Access app must protect the exact new Worker including OPTIONS');
 ensure(Array.isArray(policies)&&policies.length===1
  &&policies[0].decision==='deny'
  &&policies[0].include?.some(x=>x.everyone!=null)
  &&!policies[0].exclude?.length&&!policies[0].require?.length,
  'Access must remain DENY Everyone without exceptions');
 ensure(subdomain?.enabled===true&&subdomain?.previews_enabled===false
  &&qaSubdomain?.previews_enabled===false,
  'QA and independent Worker Version URLs must remain disabled');
 ensure(qaDeployment?.length===1&&qaDeployment[0].version_id===LOCKED_EDGE.deployedQa
  &&qaDeployment[0].percentage===100,
  'existing Account QA Version 10 traffic must remain unchanged');
 ensure(database?.name===LOCKED_EDGE.dbName&&database?.id===LOCKED_EDGE.db,
  'wrong synthetic database identity');
 const names=Object.keys(databaseRows||{}).sort();
 ensure(names.length===REQUIRED_ACCOUNT_TABLES.length
  &&REQUIRED_ACCOUNT_TABLES.every(name=>databaseRows[name]===0),
  'isolated D1 must contain only the 11 expected empty account tables');
 ensure(foreignKeyViolations===0,'foreign key errors');
 return {
  d1Isolated:true,rateLimiterIsolated:true,accessDenyAll:true,
  version10Unchanged:true,accountTableCount:11,accountRowCount:0,
  loginEnabled:false,readyForPasskey:false,
 };
}
