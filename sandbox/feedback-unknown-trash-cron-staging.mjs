/** ArcScriptCenter STAGING — D1 Unknown Feedback Trash scheduled GC only.
 * Separate Worker avoids touching the existing 300KB+ STAGING API Worker
 * or changing its secrets. Never expose a public purge route.
 * Keep this script bound ONLY to arcscriptcenter-staging D1.
 */
import {purgeExpiredUnknownTrash} from './feedback-unknown-case-trash.mjs';

export default {
 async fetch() {
  return new Response('Not found',{status:404,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
 },
 async scheduled(controller,env,ctx) {
  if(controller.cron!=='0 * * * *') {
   console.error('[ASC Trash GC] Unexpected Cron trigger; ignoring');
   return;
  }
  if(!env.DB?.prepare||!env.DB?.batch)throw Error('STAGING D1 DB binding unavailable');
  const now=Math.floor(Date.now()/1000);
  ctx.waitUntil(
   purgeExpiredUnknownTrash(env.DB,now,50)
    .then(result=>console.log('[ASC Trash GC] finished',JSON.stringify({purged:result.purged,examined:result.examined})))
    .catch(err=>{
     console.error('[ASC Trash GC] scheduled run failed:',String(err?.message||'error'));
     throw err;
    })
  );
 }
};
