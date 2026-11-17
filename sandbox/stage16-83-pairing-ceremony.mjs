/**
 * Stage 16.83: short-lived, browser-confirmed pairing ceremony.
 * SANDBOX DRAFT ONLY. NOT A ROBLOX AUTHENTICATION API FOR EXECUTOR CLIENTS.
 *
 * Roblox OAuth verification stays in browser-only HttpOnly session (Stage16.81/82).
 * Untrusted Luau receives a random poll-only capability, NEVER a Roblox session,
 * user ID, moderator note, access token or permanent authorization.
 * This module does not assert that an executor can prove the current Roblox Player.
 */
const KEY_RE = /^[A-Za-z0-9_-]{43}$/;
const CODE_RE = /^[A-Z2-7]{4}(?:-[A-Z2-7]{4}){3}$/;
const SUBJECT_RE = /^[1-9][0-9]{0,19}$/;
const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
export const PAIR_TTL = 300;
export const CONFIRM_TTL = 60;

function b64(bytes) {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/g,'');
}
function randomBytes(length, webcrypto) {
  const bytes = new Uint8Array(length);
  webcrypto.getRandomValues(bytes);
  return bytes;
}
function displayCode(webcrypto) {
  const bytes = randomBytes(10, webcrypto); // 80 CSPRNG bits, 16 base32 chars
  let bits = 0, buffer = 0, output = '';
  for (const b of bytes) {
    buffer = (buffer << 8) | b;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      output += ALPHABET[(buffer >>> bits) & 31];
      buffer &= (1 << bits) - 1;
    }
  }
  return output.match(/.{4}/g).join('-');
}
function token(webcrypto) { return b64(randomBytes(32, webcrypto)); }
async function hash(value, webcrypto) {
  const digest = await webcrypto.subtle.digest('SHA-256',new TextEncoder().encode(value));
  return b64(new Uint8Array(digest));
}
function normalizeCode(code) {
  if(typeof code !== 'string') return null;
  const candidate = code.trim().toUpperCase();
  return CODE_RE.test(candidate) ? candidate : null;
}
function trustedSub(principal, now) {
  if(principal?.verified !== true || principal?.method !== 'roblox_oidc' ||
    typeof principal.sub !== 'string' || !SUBJECT_RE.test(principal.sub) ||
    !Number.isSafeInteger(principal.expiresAt) || principal.expiresAt <= now) return null;
  return principal.sub;
}
/**
 * Required adapter contracts (each conditional operation must be one atomic D1 statement):
 * store.create({codeHash,deviceHash,expiresAt})
 * store.preview({codeHash,sub,confirmationHash,confirmationExpiresAt,now}) -> boolean
 * store.approve({codeHash,sub,confirmationHash,now}) -> boolean
 * store.getByDevice({deviceHash,now}) -> 'pending'|'approved'|null
 * store.consumeApproved({deviceHash,now}) -> boolean
 * store.cancel({deviceHash}) -> boolean
 *
 * Browser authorization is valid only if resolveVerifiedPrincipal comes from
 * Stage16.81/82 server session, never JSON / headers / LocalPlayer.UserId.
 */
export function createPairingCeremony({store,resolveVerifiedPrincipal,clock=()=>Date.now(),webcrypto=crypto}={}) {
  if(!store || ['create','preview','approve','getByDevice','consumeApproved','cancel']
    .some(name=>typeof store[name]!=='function') || typeof resolveVerifiedPrincipal!=='function') {
    throw new TypeError('Trusted pairing store and browser principal resolver required');
  }
  const now=()=>Math.floor(clock()/1000);
  return Object.freeze({
    async start() {
      const code=displayCode(webcrypto);
      const pollToken=token(webcrypto);
      const expiresAt=now()+PAIR_TTL;
      await store.create({codeHash:await hash(code,webcrypto),deviceHash:await hash(pollToken,webcrypto),expiresAt});
      return {pairingCode:code,pollToken,expiresIn:PAIR_TTL,verificationPath:'/pair/browser/preview'};
    },
    async preview({request,code}) {
      const normalized=normalizeCode(code);
      const subject=trustedSub(await resolveVerifiedPrincipal(request),now());
      if(!subject || !normalized) return {ok:false};
      const confirmationToken=token(webcrypto);
      const accepted=await store.preview({
        codeHash:await hash(normalized,webcrypto),sub:subject,
        confirmationHash:await hash(confirmationToken,webcrypto),
        confirmationExpiresAt:now()+CONFIRM_TTL,now:now(),
      });
      if(!accepted) return {ok:false};
      return {
        ok:true, confirmationToken, pairingCode:normalized, expiresIn:CONFIRM_TTL,
        warning:'Approve only if this code is shown in your own Arcsen UI. Never approve a code sent by someone else.',
      };
    },
    async approve({request,code,confirmationToken}) {
      const normalized=normalizeCode(code);
      const subject=trustedSub(await resolveVerifiedPrincipal(request),now());
      if(!normalized || !subject || typeof confirmationToken!=='string' || !KEY_RE.test(confirmationToken)) {
        return {ok:false};
      }
      const accepted=await store.approve({
        codeHash:await hash(normalized,webcrypto),sub:subject,
        confirmationHash:await hash(confirmationToken,webcrypto),now:now(),
      });
      return {ok:accepted};
    },
    async poll({pollToken}) {
      if(typeof pollToken !== 'string' || !KEY_RE.test(pollToken)) return {state:'invalid'};
      const deviceHash=await hash(pollToken,webcrypto);
      const status=await store.getByDevice({deviceHash,now:now()});
      if(status==='pending') return {state:'pending'};
      if(status!=='approved') return {state:'unavailable'};
      // Exactly one poll can consume an approved result. No subject or token returned.
      return {state:await store.consumeApproved({deviceHash,now:now()})?'approved':'unavailable'};
    },
    async cancel({pollToken}) {
      if(typeof pollToken!=='string'||!KEY_RE.test(pollToken)) return {ok:false};
      return {ok:await store.cancel({deviceHash:await hash(pollToken,webcrypto)})};
    },
  });
}
