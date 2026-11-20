import test from 'node:test';
import assert from 'node:assert/strict';
import {createTrashDashboardCallbacks} from './feedback-unknown-trash-dashboard-bridge.mjs';
const KEY='S'.repeat(48),ID='00000000-0000-4000-8000-000000000001';

test('bridge refuses calls while original Admin session is locked',async()=>{
 let calls=0;
 const bridge=createTrashDashboardCallbacks({getAdminKey:()=>'',fetchImpl:async()=>{calls++;throw Error('unexpected')}});
 await assert.rejects(()=>bridge.loadTrash(0),/Unlock existing Admin/);
 assert.equal(calls,0);
});

test('Trash list reuses current Admin Key without cookies, URL keys, or storage',async()=>{
 let count=0;
 const bridge=createTrashDashboardCallbacks({
  getAdminKey:()=>KEY,
  fetchImpl:async(url,req)=>{
   count++;
   assert.ok(url.endsWith('/api/v1/admin/feedback/unknown-trash?page=1'));
   assert.doesNotMatch(url,/S{12}/);
   assert.equal(req.headers['X-Admin-Key'],KEY);
   assert.equal(req.credentials,'omit');
   assert.equal(req.mode,'cors');
   assert.equal(req.cache,'no-store');
   assert.equal(req.method,'GET');
   assert.equal(req.body,undefined);
   return Response.json({ok:true,adminOnly:true,page:1,items:[]});
  }
 });
 const r=await bridge.loadTrash(1);
 assert.equal(r.page,1);assert.equal(count,1);
});

test('Move and Restore use exact server-required confirmation messages',async()=>{
 const received=[];
 const bridge=createTrashDashboardCallbacks({
  getAdminKey:()=>KEY,
  fetchImpl:async(url,req)=>{
   const data=JSON.parse(req.body);
   received.push(data);
   assert.equal(req.method,'POST');
   assert.equal(req.headers['Content-Type'],'application/json');
   assert.equal(req.headers['X-Admin-Key'],KEY);
   return Response.json({ok:true,adminOnly:true,id:ID,action:data.action});
  }
 });
 assert.equal((await bridge.moveUnknownCaseToTrash(ID)).action,'move');
 assert.equal((await bridge.restoreUnknownCase(ID)).action,'restore');
 assert.deepEqual(received,[
  {action:'move',id:ID,confirm:'MOVE UNKNOWN CASE TO TRASH'},
  {action:'restore',id:ID,confirm:'RESTORE UNKNOWN CASE'}
 ]);
});

test('invalid or ambiguous case identifiers rejected before network access',async()=>{
 let hits=0;
 const bridge=createTrashDashboardCallbacks({getAdminKey:()=>KEY,fetchImpl:async()=>{hits++;throw Error('should not fetch')}});
 await assert.rejects(()=>bridge.moveUnknownCaseToTrash(''),/Invalid Trash case/);
 await assert.rejects(()=>bridge.restoreUnknownCase('12345'),/Invalid Trash case/);
 await assert.rejects(()=>bridge.loadTrash(-1),/Invalid Trash page/);
 assert.equal(hits,0);
});

test('locking the Admin session during a pending request invalidates its response',async()=>{
 let key=KEY;
 const bridge=createTrashDashboardCallbacks({getAdminKey:()=>key,fetchImpl:async()=>{key='';return Response.json({ok:true,adminOnly:true,items:[{id:ID}]})}});
 await assert.rejects(()=>bridge.loadTrash(0),/Admin session changed/);
});

test('non-Admin and invalid responses never become successful UI operations',async()=>{
 const denied=createTrashDashboardCallbacks({getAdminKey:()=>KEY,fetchImpl:async()=>Response.json({ok:false,error:'Unauthorized'},{status:401})});
 await assert.rejects(()=>denied.loadTrash(0),/Unauthorized/);
 const noAdmin=createTrashDashboardCallbacks({getAdminKey:()=>KEY,fetchImpl:async()=>Response.json({ok:true,items:[]})});
 await assert.rejects(()=>noAdmin.loadTrash(0),/Trash API returned HTTP/);
});
