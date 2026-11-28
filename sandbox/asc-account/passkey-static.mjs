// Bundled only in the optional Passkey QA build (esbuild .txt -> text).
// Never import in the locked/legacy unbundled Workerd fixture.
import client from './passkey-client.txt';
import css from './passkey-style.txt';
import {passkeyPage} from './passkey-page.mjs';
const headers={
 'Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff',
 'X-Frame-Options':'DENY','Referrer-Policy':'no-referrer','X-Robots-Tag':'noindex, nofollow',
};
export function servePasskeyPage(path,siteKey,options){
 if(path==='/passkey-client.js')
  return new Response(client,{headers:{...headers,'Content-Type':'application/javascript; charset=utf-8'}});
 if(path==='/passkey-style.css')
  return new Response(css,{headers:{...headers,'Content-Type':'text/css; charset=utf-8'}});
 // Each route serves the same locked-down shell; /myaccount contents appear only
 // after the browser's POST /session succeeds with an HttpOnly session cookie.
 if(path==='/'||path==='/login'||path==='/signin'||path==='/myaccount')
  return new Response(passkeyPage(siteKey,options),{headers:{...headers,
   'Content-Type':'text/html; charset=utf-8',
   'Content-Security-Policy':"default-src 'none'; script-src 'self' https://challenges.cloudflare.com; style-src 'self'; connect-src 'self'; frame-src https://challenges.cloudflare.com; img-src 'self' https://*.rbxcdn.com; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
  }});
 return null;
}
