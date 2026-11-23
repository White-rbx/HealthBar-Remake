import {scrypt as nativeScrypt, timingSafeEqual} from 'node:crypto';

const encode=new TextEncoder();
const bytes=hex=>Uint8Array.from(hex.match(/../g)||[],part=>parseInt(part,16));
export const hex=data=>Array.from(data,byte=>byte.toString(16).padStart(2,'0')).join('');
export const randomHex=length=>hex(crypto.getRandomValues(new Uint8Array(length)));
export const sha=async value=>hex(new Uint8Array(await crypto.subtle.digest('SHA-256',encode.encode(value))));
export const strongPassword=value=>typeof value==='string'&&[...value].length>=15&&encode.encode(value).length<=128;
export const loginPassword=value=>typeof value==='string'&&value.length>0&&encode.encode(value).length<=128;
export async function passwordHash(pass,salt=randomHex(16)){
 const key=await new Promise((resolve,reject)=>nativeScrypt(pass,bytes(salt),32,{N:32768,r:8,p:3,maxmem:48*1024*1024},
  (error,result)=>error?reject(error):resolve(result)));
 return 'scrypt-32768-8-3:'+salt+':'+hex(key);
}
const dummy='scrypt-32768-8-3:'+'0'.repeat(32)+':'+'0'.repeat(64);
export async function passwordMatches(pass,stored){
 const valid=/^scrypt-32768-8-3:[0-9a-f]{32}:[0-9a-f]{64}$/.test(stored||'');
 const [,salt,digest]=(valid?stored:dummy).split(':');
 const candidate=(await passwordHash(pass,salt)).split(':')[2];
 return timingSafeEqual(bytes(candidate),bytes(digest))&&valid;
}

const alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
export function base32(value){
 let out='',remaining=0,buffer=0;
 for(const byte of value){
  buffer=(buffer<<8)|byte;remaining+=8;
  while(remaining>=5){remaining-=5;out+=alphabet[(buffer>>>remaining)&31];}
 }
 if(remaining)out+=alphabet[(buffer<<(5-remaining))&31];
 return out;
}
export const newTotpSecret=()=>randomHex(20);
async function sealKey(value){
 if(typeof value!=='string'||!/^[0-9a-f]{64}$/.test(value))throw new Error('TOTP key unavailable');
 return crypto.subtle.importKey('raw',bytes(value),'AES-GCM',false,['encrypt','decrypt']);
}
const aad=id=>encode.encode('asc-accounts-staging:totp:v1:'+id);
export async function sealTotp(value,key,id){
 const iv=crypto.getRandomValues(new Uint8Array(12));
 const encrypted=await crypto.subtle.encrypt({name:'AES-GCM',iv,additionalData:aad(id)},await sealKey(key),bytes(value));
 return hex(iv)+'.'+hex(new Uint8Array(encrypted));
}
export async function readTotp(value,key,id){
 const [iv,encrypted]=value.split('.');
 return new Uint8Array(await crypto.subtle.decrypt({name:'AES-GCM',iv:bytes(iv),additionalData:aad(id)},await sealKey(key),bytes(encrypted)));
}
export async function totpCode(secret,step){
 const counter=new ArrayBuffer(8);
 new DataView(counter).setBigUint64(0,BigInt(step));
 const key=await crypto.subtle.importKey('raw',secret,{name:'HMAC',hash:'SHA-1'},false,['sign']);
 const mac=new Uint8Array(await crypto.subtle.sign('HMAC',key,counter));
 const offset=mac[mac.length-1]&15;
 const number=new DataView(mac.buffer).getUint32(offset)&0x7fffffff;
 return String(number%1000000).padStart(6,'0');
}
export async function matchingTotpStep(code,secret,now,last){
 if(typeof code!=='string'||!/^\d{6}$/.test(code))return null;
 const step=Math.floor(now/30);
 for(const candidate of [step,step-1,step+1]){
  if(candidate>last&&timingSafeEqual(encode.encode(code),encode.encode(await totpCode(secret,candidate))))return candidate;
 }
 return null;
}
export const displayTotp=value=>base32(bytes(value));
