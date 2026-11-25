// STAGING ONLY: a locked Cloudflare Worker Preview entrypoint, NOT a login rollout.
// The real preview hostname is deliberately not set in this repository.
// Do not create a Preview until Access, isolated D1, and Origin have been reviewed.
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

// No default export by design: there is no approved deployed Preview hostname yet.
// When a protected Preview is approved, a separate reviewed entry file can call
// createLockedPrivatePreview({origin:'https://<exact-preview-host>'}) and export it.
// This source file cannot deploy a login or load any private account data.
