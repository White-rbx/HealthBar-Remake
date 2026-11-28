// STAGING ONLY: a locked Cloudflare Worker Preview entrypoint, NOT a login rollout.
// Cloudflare has a locked "eslogin" Preview with a separate fixed-origin main module,
// zero uploaded bindings and a deny-all Access application. Its URL remains disabled.
// Authenticated WebAuthn QA still requires a different isolated D1, reviewed Access
// allow policies, a separately pinned Origin/RP ID and test-only Turnstile.
import provisioning from './provisioning-worker.mjs';

const suffix='-arcscriptcenter-account-qa.kogpasan14.workers.dev';
const denied=()=>Response.json({ok:false,code:'not_found'},{status:404,
 headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});

export function validatePrivatePreviewOrigin(origin){
 if(typeof origin!=='string')throw new Error('PRIVATE PREVIEW LOCKED: pinned HTTPS origin required');
 let url;
 try{url=new URL(origin)}catch{throw new Error('PRIVATE PREVIEW LOCKED: invalid origin')}
 if(url.protocol!=='https:'||url.origin!==origin||url.username||url.password||
  url.port||!url.hostname.endsWith(suffix)){
  throw new Error('PRIVATE PREVIEW LOCKED: exact QA Preview HTTPS origin required');
 }
 const previewLabel=url.hostname.slice(0,-suffix.length);
 if(!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(previewLabel)){
  throw new Error('PRIVATE PREVIEW LOCKED: invalid Preview hostname');
 }
 return origin;
}

// The locked entrypoint never calls createAccountWorker or accesses env bindings.
// Explicitly pin the origin at build/review time; never trust request Host/Origin.
export function createLockedPrivatePreview({origin}={}){
 const expectedOrigin=validatePrivatePreviewOrigin(origin);
 return {
  async fetch(request){
   if(new URL(request.url).origin!==expectedOrigin)return denied();
   return provisioning.fetch(request);
  },
 };
}

// No default export by design. The locked Preview uses a separate main module
// which pins the exact expected origin. This module alone never enables account
// authentication, and no Preview URL is presently permitted to accept traffic.
