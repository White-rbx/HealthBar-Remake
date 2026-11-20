// Standalone read-only STAGING Worker. Its only datastore is the isolated
// Ban Center QA source. It has no Admin, account-identity or case bindings.
import {BanError,createPublicBanStatus} from './ban-v2-integration.mjs';
import {d1BanQaStore} from './ban-v2-integration-stores.mjs';
import {QA_BAN_IDS} from './ban-v2-integration-worker.mjs';

const status=createPublicBanStatus({
 store:{read:env=>d1BanQaStore.read({DB:env.BAN_QA_DB})},
 allowTarget:(id,env)=>QA_BAN_IDS.includes(id) || env.BAN_PUBLIC_QA_TEST_IDS?.split(',').includes(id),
 async rateLimit(request,env){
  if(typeof env.BAN_PUBLIC_QA_RATE?.limit!=='function')
   throw new BanError(503,'rate_unavailable','Ban lookup unavailable.');
  // Cloudflare's ingress address limits callers rotating claimed IDs. This
  // Worker does not include it in responses or persist it in application data.
  const caller=request.headers.get('CF-Connecting-IP') || 'unknown';
  const result=await env.BAN_PUBLIC_QA_RATE.limit({key:caller});
  if(typeof result.success!=='boolean')throw new BanError(503,'rate_unavailable','Ban lookup unavailable.');
  return result.success;
 },
});

export default {fetch:status};
