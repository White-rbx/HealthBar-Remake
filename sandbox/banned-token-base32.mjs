// Server-only envelope. No API accepts or returns a BANNEDTOKEN.
const alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
const encoder=new TextEncoder();
const decoder=new TextDecoder('utf-8',{fatal:true});
const context=encoder.encode('ArcScriptCenter:STAGING:BANNEDTOKEN:v2');
const ttl=86400;
const validUser=v=>typeof v==='string'&&/^[1-9][0-9]{0,19}$/.test(v);
const validUsername=v=>typeof v==='string'&&/^[a-z0-9_]{3,20}$/.test(v);
const validNotice=v=>typeof v==='string'&&/^[A-Za-z0-9_-]{1,70}$/.test(v);
const validRevision=v=>v===null||(typeof v==='string'&&/^[A-Za-z0-9_-]{1,128}$/.test(v));
const hex=bytes=>Array.from(bytes,b=>b.toString(16).padStart(2,'0')).join('');
const hash=async data=>hex(new Uint8Array(await crypto.subtle.digest('SHA-256',data)));
const validHash=h=>typeof h==='string'&&/^[0-9a-f]{64}$/.test(h);
function equalDigest(a,b){
 if(!validHash(a)||!validHash(b))return false;
 let diff=0;
 for(let i=0;i<64;i++)diff|=a.charCodeAt(i)^b.charCodeAt(i);
 return diff===0;
}
export function encodeBase32(bytes){
 let out='',bits=0,value=0;
 for(const byte of bytes){
  value=(value<<8)|byte;
  bits+=8;
  while(bits>=5){bits-=5;out+=alphabet[(value>>>bits)&31];}
  value&=(1<<bits)-1;
 }
 if(bits)out+=alphabet[(value<<(5-bits))&31];
 return out;
}
export function decodeBase32(text){
 if(typeof text!=='string'||text.length>4096||!/^[A-Z2-7]+$/.test(text))throw new Error('Invalid Base32');
 let bits=0,value=0;
 const bytes=[];
 for(const char of text){
  value=(value<<5)|alphabet.indexOf(char);
  bits+=5;
  if(bits>=8){bits-=8;bytes.push((value>>>bits)&255);value&=(1<<bits)-1;}
 }
 const result=Uint8Array.from(bytes);
 if(encodeBase32(result)!==text)throw new Error('Non-canonical Base32');
 return result;
}
async function deriveKeys(secret){
 if(typeof secret!=='string'||secret.length<32)throw new Error('Verification unavailable');
 const root=await crypto.subtle.importKey('raw',encoder.encode(secret),'HKDF',false,['deriveKey']);
 const derive=(label,algorithm,usages)=>crypto.subtle.deriveKey(
  {name:'HKDF',hash:'SHA-256',salt:context,info:encoder.encode(label)},root,algorithm,false,usages);
 const [sign,seal]=await Promise.all([
  derive('sign',{name:'HMAC',hash:'SHA-256',length:256},['sign','verify']),
  derive('seal',{name:'AES-GCM',length:256},['encrypt','decrypt']),
 ]);
 return {sign,seal};
}

async function makeRow(keys,{subject,username,noticeId,revision,now}){
 username=typeof username==='string'?username.toLowerCase():null;
 if(!validUser(subject)||!validUsername(username)||!validNotice(noticeId)||!validRevision(revision))
  throw new Error('Invalid verified case');
 const secret=crypto.getRandomValues(new Uint8Array(16));
 const expiresAt=now+ttl;
 const payload=encoder.encode(JSON.stringify([subject,username,noticeId,revision,encodeBase32(secret),expiresAt]));
 const sig=new Uint8Array(await crypto.subtle.sign('HMAC',keys.sign,payload));
 const token=encoder.encode('BANNTOKEN2_'+encodeBase32(payload)+'.'+encodeBase32(sig));
 const iv=crypto.getRandomValues(new Uint8Array(12));
 const ciphertext=new Uint8Array(await crypto.subtle.encrypt({name:'AES-GCM',iv,additionalData:context},keys.seal,token));
 const [tokenHash,secretHash]=await Promise.all([hash(token),hash(secret)]);
 return {username,expiresAt,tokenHash,secretHash,sealed:encodeBase32(iv)+'.'+encodeBase32(ciphertext)};
}

async function readRow(keys,row,{subject,noticeId,now}){
 const sealed=row.sealed?.split('.');
 if(sealed?.length!==2||sealed[0].length!==20)throw new Error('Invalid stored case token');
 const bytes=new Uint8Array(await crypto.subtle.decrypt({
  name:'AES-GCM',iv:decodeBase32(sealed[0]),additionalData:context,
 },keys.seal,decodeBase32(sealed[1])));
 const match=/^BANNTOKEN2_([A-Z2-7]{1,1024})\.([A-Z2-7]{52})$/.exec(decoder.decode(bytes));
 if(!match)throw new Error('Invalid stored case token');
 const packed=decodeBase32(match[1]), signature=decodeBase32(match[2]);
 if(!await crypto.subtle.verify('HMAC',keys.sign,signature,packed))throw new Error('Invalid stored case token');
 const payload=JSON.parse(decoder.decode(packed));
 if(!Array.isArray(payload)||payload.length!==6)throw new Error('Invalid stored case token');
 const [userId,username,caseId,revision,encodedSecret,expiresAt]=payload;
 if(!validUser(userId)||userId!==subject||!validUsername(username)||username!==row.username||
    !validNotice(caseId)||caseId!==noticeId||!validRevision(revision)||revision!==row.revision||
    !Number.isSafeInteger(expiresAt)||expiresAt!==row.expiresAt||!equalDigest(await hash(bytes),row.tokenHash))
  throw new Error('Invalid stored case token');
 const secret=decodeBase32(encodedSecret);
 if(secret.length!==16||!equalDigest(await hash(secret),row.secretHash))throw new Error('Invalid stored case token');
 return {reference:'••••'+hex(secret.subarray(15)).toUpperCase(), current:expiresAt>now&&revision===row.linkedRevision};
}

// The caller obtains the grant from checked D1 case-session ownership. This
// helper cannot authorize any request by itself.
export async function verifyOrIssueCaseToken(db,{subject,username,noticeId},secret,now){
 const read=()=>db.prepare(`
  SELECT t.username_snapshot AS username,t.ban_revision AS revision,t.expires_unix AS expiresAt,
    t.token_hash AS tokenHash,t.secret_hash AS secretHash,t.sealed_token AS sealed,r.ban_revision AS linkedRevision
  FROM asc_verified_violation_subjects l
  LEFT JOIN asc_banned_token_references r USING(notice_id,subject_user_id)
  LEFT JOIN asc_banned_tokens_v2 t USING(notice_id,subject_user_id)
  WHERE l.notice_id=?1 AND l.subject_user_id=?2
 `).bind(noticeId,subject).first();
 let row=await read();
 if(!row)return null;
 const keys=await deriveKeys(secret);
 if(row.sealed!==null){
  const verified=await readRow(keys,row,{subject,noticeId,now});
  if(verified.current)return {reference:verified.reference,revision:row.revision,tokenHash:row.tokenHash};
 }
 // Rotation is possible only after verifying any previous envelope and with
 // current ownership/link and CAS. An expired envelope cannot grant access.
 const fresh=await makeRow(keys,{subject,username,noticeId,revision:row.linkedRevision,now});
 await db.prepare(`
  INSERT INTO asc_banned_tokens_v2(notice_id,subject_user_id,username_snapshot,ban_revision,expires_unix,token_hash,secret_hash,sealed_token)
  SELECT l.notice_id,l.subject_user_id,?3,?4,?5,?6,?7,?8
  FROM asc_verified_violation_subjects l LEFT JOIN asc_banned_token_references r USING(notice_id,subject_user_id)
  WHERE l.notice_id=?1 AND l.subject_user_id=?2 AND r.ban_revision IS ?4
  ON CONFLICT(notice_id,subject_user_id) DO UPDATE SET username_snapshot=excluded.username_snapshot,
    ban_revision=excluded.ban_revision,expires_unix=excluded.expires_unix,token_hash=excluded.token_hash,
    secret_hash=excluded.secret_hash,sealed_token=excluded.sealed_token
  WHERE asc_banned_tokens_v2.token_hash=?9
 `).bind(noticeId,subject,fresh.username,row.linkedRevision,fresh.expiresAt,fresh.tokenHash,fresh.secretHash,fresh.sealed,row.tokenHash).run();
 row=await read();
 if(!row?.sealed)return null;
 const installed=await readRow(keys,row,{subject,noticeId,now});
 return installed.current?{reference:installed.reference,revision:row.revision,tokenHash:row.tokenHash}:null;
}
