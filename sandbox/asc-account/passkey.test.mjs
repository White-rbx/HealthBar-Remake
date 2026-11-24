import test from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import {Buffer} from 'node:buffer';
import {createPasskeyCeremonies} from './passkey.mjs';

const origin='https://arcscriptcenter-account-qa.kogpasan14.workers.dev';
const rpID=new URL(origin).hostname;
const encoder=new TextEncoder();
const b64=x=>Buffer.from(x).toString('base64url');
const concat=(...parts)=>Buffer.concat(parts.map(x=>Buffer.from(x)));
const h=(major,n)=>n<24?Buffer.from([(major<<5)|n]):
 n<256?Buffer.from([(major<<5)|24,n]):
 n<65536?Buffer.from([(major<<5)|25,n>>8,n&255]):null;
const cbor=v=>{
 if(Number.isInteger(v))return v>=0?h(0,v):h(1,-v-1);
 if(typeof v==='string'){const x=encoder.encode(v);return concat(h(3,x.length),x)}
 if(v instanceof Uint8Array||Buffer.isBuffer(v))return concat(h(2,v.length),v);
 if(v instanceof Map){const arr=[h(5,v.size)];for(const [k,val] of v){arr.push(cbor(k),cbor(val))}return concat(...arr)}
 throw Error('Unsupported synthetic test CBOR item');
};
function authData(rpHash,flags,signCount,tail=Buffer.alloc(0)){
 const counter=Buffer.alloc(4);counter.writeUInt32BE(signCount);
 return concat(rpHash,Buffer.from([flags]),counter,tail);
}
function fixture(){
 const sqlite=new DatabaseSync(':memory:');
 sqlite.exec(readFileSync(new URL('../../migrations/asc_unified_account_ISOLATED_QA_ONLY.sql',import.meta.url),'utf8'));
 sqlite.exec(readFileSync(new URL('../../migrations/asc_passkey_ISOLATED_QA_ONLY.sql',import.meta.url),'utf8'));
 const db={
  prepare(sql){return {bind(...args){return{
   first:async()=>sqlite.prepare(sql).get(...args)||null,
   run:async()=>sqlite.prepare(sql).run(...args),
   all:async()=>({results:sqlite.prepare(sql).all(...args)}),
   execute(){const stmt=sqlite.prepare(sql);return stmt.columns().length?{results:stmt.all(...args)}:{meta:stmt.run(...args)}},
  }}}},
  async batch(operations){sqlite.exec('BEGIN IMMEDIATE');
   try{const data=operations.map(x=>x.execute());sqlite.exec('COMMIT');return data}
   catch(error){sqlite.exec('ROLLBACK');throw error}
  },
 };
 const env={ACCOUNT_DB:db};
 let now=1795440001;
 const service=createPasskeyCeremonies({
  origin,clock:()=>now,rate:async()=>true,
  siteverify:async(req,body)=>body.turnstile==='synthetic_qa_token',
  issueSession:async()=> 'a'.repeat(64),
 });
 const req=(flow,headers={})=>new Request(origin+'/api/v1/accounts/passkey/register/verify',{
  method:'POST',headers:{Origin:origin,...(flow?{Cookie:'__Host-ascqa-passkey-flow='+flow}:{}),...headers},
  body:'{}',
 });
 return{sqlite,db,env,service,req,advance:n=>{now+=n}};
}
function flowFrom(response){
 const cookie=response.headers.get('set-cookie')||'';
 const result=cookie.match(/__Host-ascqa-passkey-flow=([0-9a-f]{64})/);
 assert.ok(result,'passkey flow cookie missing');
 return result[1];
}

test('passkey QA schema is additive and does not change existing case/pairing tables',()=>{
 const f=fixture();
 const all=f.sqlite.prepare("SELECT name FROM sqlite_master WHERE type='table'").all().map(x=>x.name);
 for(const name of ['asc_accounts','asc_account_sessions','asc_account_cases',
 'asc_account_pairings','asc_account_verified_links','asc_account_passkeys','asc_account_passkey_flows'])
  assert.ok(all.includes(name),name);
 assert.deepEqual(f.sqlite.prepare('PRAGMA integrity_check').all(),[{integrity_check:'ok'}]);
});

test('passkey challenge binds to the browser, uses strict origin and cannot be replayed',async()=>{
 const f=fixture();
 assert.equal((await f.service.handle('passkey/register/options',{
  username:'qatest_account',presence:true,turnstile:'incorrect',
 },f.req(),f.env)).status,400);
 const started=await f.service.handle('passkey/register/options',{
  username:'qatest_account',presence:true,turnstile:'synthetic_qa_token',
 },f.req(),f.env);
 assert.equal(started.status,200);
 const options=(await started.json()).options;
 assert.equal(options.rp.id,rpID);
 assert.equal(options.authenticatorSelection.userVerification,'required');
 assert.equal(options.authenticatorSelection.residentKey,'required');
 const flow=flowFrom(started);
 const noCookie=await f.service.handle('passkey/register/verify',{response:{}},f.req(),f.env);
 assert.equal(noCookie.status,410);
 const wrongOrigin=await f.service.handle('passkey/register/verify',{response:{}},
  f.req(flow,{Origin:'https://attacker.invalid'}),f.env);
 assert.equal(wrongOrigin.status,403);
 const invalid=await f.service.handle('passkey/register/verify',{response:{}},f.req(flow),f.env);
 assert.equal(invalid.status,400);
 const replay=await f.service.handle('passkey/register/verify',{response:{}},f.req(flow),f.env);
 assert.equal(replay.status,410);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_accounts').get().n,0);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_passkey_flows').get().n,0);
});

test('synthetic P-256 passkey registers, signs in and rejects replayed assertions',async()=>{
 const f=fixture();
 const reg=await f.service.handle('passkey/register/options',{
  username:'NewPasskeyUser',presence:true,turnstile:'synthetic_qa_token',
 },f.req(),f.env);
 assert.equal(reg.status,200);
 const {options}=await reg.json();
 const flow=flowFrom(reg);
 const key=await crypto.subtle.generateKey({name:'ECDSA',namedCurve:'P-256'},true,['sign','verify']);
 const jwk=await crypto.subtle.exportKey('jwk',key.publicKey);
 const cose=cbor(new Map([[1,2],[3,-7],[-1,1],[-2,Buffer.from(jwk.x,'base64url')],[-3,Buffer.from(jwk.y,'base64url')]]));
 const credId=Buffer.from(Array.from({length:32},(_,i)=>i+1));
 const len=Buffer.alloc(2);len.writeUInt16BE(credId.length);
 const hash=new Uint8Array(await crypto.subtle.digest('SHA-256',encoder.encode(rpID)));
 const registrationData=authData(hash,0x45,0,concat(Buffer.alloc(16),len,credId,cose));
 const attestation=cbor(new Map([['fmt','none'],['attStmt',new Map()],['authData',registrationData]]));
 const clientData=encoder.encode(JSON.stringify({type:'webauthn.create',challenge:options.challenge,origin,crossOrigin:false}));
 const registration={
  id:b64(credId),rawId:b64(credId),type:'public-key',authenticatorAttachment:'platform',
  response:{clientDataJSON:b64(clientData),attestationObject:b64(attestation),transports:['internal']},
  clientExtensionResults:{},
 };
 const finish=await f.service.handle('passkey/register/verify',{response:registration},f.req(flow),f.env);
 assert.equal(finish.status,200,await finish.text().catch(()=>'')); // inspect status before JSON
 const account=(await finish.clone().json()).account;
 assert.equal(account.username,'newpasskeyuser');
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_accounts').get().n,1);
 assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM asc_account_passkeys').get().n,1);

 const loginStart=await f.service.handle('passkey/login/options',{},f.req(),f.env);
 assert.equal(loginStart.status,200);
 const loginOptions=(await loginStart.json()).options;
 const loginFlow=flowFrom(loginStart);
 const authenticationData=authData(hash,0x05,1);
 const signedClient=encoder.encode(JSON.stringify({
  type:'webauthn.get',challenge:loginOptions.challenge,origin,crossOrigin:false,
 }));
 const clientHash=new Uint8Array(await crypto.subtle.digest('SHA-256',signedClient));
 const rawSig=new Uint8Array(await crypto.subtle.sign({name:'ECDSA',hash:'SHA-256'},key.privateKey,
  concat(authenticationData,clientHash)));
 const derInteger=part=>{
  let x=Buffer.from(part);
  while(x.length>1&&x[0]===0)x=x.subarray(1);
  if(x[0]>=0x80)x=concat(Buffer.from([0]),x);
  return concat(Buffer.from([0x02,x.length]),x);
 };
 const r=derInteger(rawSig.slice(0,32)),s=derInteger(rawSig.slice(32));
 const sig=concat(Buffer.from([0x30,r.length+s.length]),r,s);
 const assertion={id:b64(credId),rawId:b64(credId),type:'public-key',
  response:{clientDataJSON:b64(signedClient),authenticatorData:b64(authenticationData),
   signature:b64(sig),userHandle:b64(encoder.encode(account.id))},
  clientExtensionResults:{},
 };
 const authenticated=await f.service.handle('passkey/login/verify',{response:assertion},
  f.req(loginFlow),f.env);
 assert.equal(authenticated.status,200);
 assert.equal((await authenticated.json()).account.id,account.id);
 assert.equal(f.sqlite.prepare('SELECT counter FROM asc_account_passkeys').get().counter,1);
 const replay=await f.service.handle('passkey/login/verify',{response:assertion},f.req(loginFlow),f.env);
 assert.equal(replay.status,410);
});
