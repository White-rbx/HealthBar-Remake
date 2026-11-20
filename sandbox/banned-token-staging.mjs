/**
 * ArcScriptCenter BANNEDTOKEN — STAGING server-side primitives.
 * This module does NOT authenticate Roblox users or expose a lookup endpoint.
 * The caller must independently establish a trusted, case-bound principal.
 * Never transmit full token, component codes, or raw secret to Roblox Luau.
 */
const enc = new TextEncoder();
const HEX6 = /^[0-9A-F]{6}$/;
const safeId = x => typeof x === 'string' && /^[0-9]{1,20}$/.test(x);
const safeUsername = x => typeof x === 'string' && /^[A-Za-z0-9_]{3,20}$/.test(x);
function hex(bytes) { return Array.from(bytes, b => b.toString(16).padStart(2,'0')).join('').toUpperCase(); }
async function hmac(key, value) {
  const k = await crypto.subtle.importKey('raw', enc.encode(key), {name:'HMAC',hash:'SHA-256'}, false, ['sign']);
  return hex(new Uint8Array(await crypto.subtle.sign('HMAC', k, enc.encode(value))));
}
export function maskBannedReference(code) {
  if (!HEX6.test(code)) throw new TypeError('Invalid HEX reference');
  return '••••' + code.slice(-2);
}
export async function issueBannedToken({userId,username,caseId,secret}) {
  if (!safeId(userId) || !safeUsername(username) || typeof caseId !== 'string' ||
      !/^[A-Za-z0-9_-]{8,100}$/.test(caseId) ||
      typeof secret !== 'string' || secret.length < 32)
    throw new TypeError('Invalid server-side issuance input');
  // HMAC codes are opaque references, NOT independent identity verification.
  const first = (await hmac(secret, 'uid:v1:' + userId)).slice(0,12);
  const second = (await hmac(secret, 'username:v1:' + userId + ':' + username.toLowerCase())).slice(0,11);
  const last = hex(crypto.getRandomValues(new Uint8Array(3)));
  const token = 'BANNTOKEN_' + first + '-' + second + '#' + last;
  const tokenHash = await crypto.subtle.digest('SHA-256', enc.encode(token));
  return {
    // SERVER ONLY: persist hash + caseId + independently verified subject; never send token to client.
    token, tokenHash: hex(new Uint8Array(tokenHash)).toLowerCase(),
    caseId, userId, username,
    // Only this masked field may be included in a restricted client notice.
    clientReference: maskBannedReference(last)
  };
}
export function publicRestrictionNotice(record) {
  if (!record || typeof record.clientReference !== 'string' ||
      !/^••••[0-9A-F]{2}$/.test(record.clientReference))
    throw new TypeError('Invalid server record');
  return {reference:record.clientReference};
}
