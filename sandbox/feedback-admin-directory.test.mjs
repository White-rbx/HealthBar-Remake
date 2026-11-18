import test from 'node:test';
import assert from 'node:assert/strict';
import {createRobloxPublicDirectory,normalizeUserQuery} from './feedback-admin-roblox-directory.mjs';
import {createAdminUsersCaseHandler,USERS_ROUTE} from './feedback-admin-users-case.mjs';
import {normalizeUserSearch,userLabel} from './feedback-admin-users-case-ui.mjs';
import {decorateManagedBanEntries,findManagedBansByName} from './arcscriptcenter-admin-ban-directory.mjs';

const BASE='https://arcscriptcenter-api-staging.kogpasan14.workers.dev';
const ORIGIN='https://arcscriptcenter-dashboard-staging.pages.dev';
const profile={id:12345,name:'ChangedUsername',displayName:'Snow Wolf'};
const other={id:67890,name:'OtherUser',displayName:'Snow Wolf'};
const admin={adminAuthenticated:async r=>r.headers.get('X-Synthetic-Admin')==='true',originAllowed:(r,o)=>o===ORIGIN};
const req=(s,allowed=true)=>new Request(BASE+s,{headers:{Origin:ORIGIN,...(allowed?{'X-Synthetic-Admin':'true'}:{})}});
const rows=[{claimed_user_id:'12345',total:2,reviewing:1,approved:1,denied:0,flagged:0,last_updated:3}];
const mockDB=()=>({prepare(sql){return {bind(...params){return {all:async()=>({results:rows})}}}}});
function directory(){
 const calls=[];
 const api=createRobloxPublicDirectory({fetchImpl:async (url,opts)=>{
  calls.push({url,method:opts.method,body:opts.body});
  const path=new URL(url).pathname;
  if(path==='/v1/users/search')return Response.json({data:[profile,other]});
  if(path==='/v1/users')return Response.json({data:[profile]});
  throw Error('Unexpected Roblox outbound request');
 }});
 return {...api,calls};
}
test('search supports Username, Display Name and UserId, rejects unsafe search',()=>{
 assert.equal(normalizeUserSearch('Snow Wolf'),'Snow Wolf');
 assert.equal(normalizeUserSearch(' 12345 '),'12345');
 assert.equal(normalizeUserQuery('นิกเนม'),'นิกเนม');
 assert.throws(()=>normalizeUserSearch('<script>'),/Search/);
});
test('Admin authorization is checked before Roblox public fetch and D1 lookup',async()=>{
 const d=directory(),handler=createAdminUsersCaseHandler(admin,{directory:d});
 const denied=await handler(req(USERS_ROUTE+'?search=Snow',false),{DB:mockDB()});
 assert.equal(denied.status,401);
 assert.equal(d.calls.length,0);
});
test('ambiguous public display names map to multiple IDs, not automatic ownership',async()=>{
 const d=directory();
 assert.deepEqual((await d.search('Snow Wolf')).map(p=>p.userId),['12345','67890']);
 const handler=createAdminUsersCaseHandler(admin,{directory:d});
 const result=await handler(req(USERS_ROUTE+'?search=Snow%20Wolf'),{DB:mockDB()});
 assert.equal(result.status,200);
 const body=await result.json();
 assert.equal(body.identityVerified,false);
 assert.equal(body.users[0].profile.ownershipVerified,false);
 assert.match(userLabel(body.users[0]),/ChangedUsername.*unverified case claim/);
});
test('unlinked Feedback does not invent a username or account',()=>{
 assert.equal(userLabel({unlinked:true}), 'Unknown / Unlinked');
 assert.equal(userLabel({claimedUserId:'12345'}),'UserId 12345 (unverified)');
});
test('Ban Directory classification and ambiguity preserve exact UserId',async()=>{
 const d=directory();
 const permanent={userId:'12345',username:'OldUsername',reason:'Spam',description:'',startAt:'2026-11-01 10:00',expiresAt:''};
 const temporary={userId:'67890',username:'OtherUser',reason:'Spam',description:'',startAt:'2026-11-01 10:00',expiresAt:'2026-11-30 10:00'};
 const list=await decorateManagedBanEntries([permanent,temporary],{directory:d,nowUnix:1795000000});
 assert.deepEqual(list.map(r=>r.ban.label),['Banned','Temporary Banned']);
 assert.ok(list.every(r=>r.ownerVerified===false));
 const matches=await findManagedBansByName([permanent,temporary],'Snow Wolf',{directory:d});
 assert.deepEqual(matches.map(x=>x.userId),['12345','67890']);
});
test('offline Roblox falls back safely to saved Admin Ban names',async()=>{
 const entry={userId:'12345',username:'OldUsername',reason:'Spam',description:'',startAt:'',expiresAt:''};
 const bad={search:async()=>{throw Error('Vendor down')},getByIds:async()=>{throw Error('Vendor down')}};
 assert.deepEqual(await findManagedBansByName([entry],'OldUsername',{directory:bad}),[entry]);
 const rows=await decorateManagedBanEntries([entry],{directory:bad});
 assert.equal(rows[0].publicProfile,null);
});
