// Isolated Cloudflare Worker for testing Access at an independent HTTPS hostname.
// A dedicated empty QA D1 and isolated limiter are bound, but intentionally UNUSED.
// NO account secrets, NO sessions, NO Passkey registration, NO pairing.
// This is not a deployment of the Account QA Version 11 candidate.
import provisioning from './provisioning-worker.mjs';

export const EDGE_QA_WORKER='arcscriptcenter-eslogin-edge-qa';
export const EDGE_QA_ORIGIN='https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev';

const notFound=()=>new Response(JSON.stringify({ok:false,code:'not_found'}),{
 status:404,headers:{'Content-Type':'application/json; charset=utf-8',
  'Cache-Control':'no-store, max-age=0','X-Content-Type-Options':'nosniff'},
});

export default {
 async fetch(request){
  // The intended URL is constant, never dynamically derived from Origin or Host.
  if(new URL(request.url).origin!==EDGE_QA_ORIGIN)return notFound();
  // The Provisioning Worker intentionally ignores all env bindings and never
  // creates accounts, issues credentials, returns sessions, or reads D1.
  return provisioning.fetch(request);
 },
};
