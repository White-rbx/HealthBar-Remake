import test from 'node:test';
import assert from 'node:assert/strict';
import {Script} from 'node:vm';
import {CLAIMED_ID_COPY,patchNativeClaimedUserId} from './feedback-native-userid-patcher.mjs';

const fixture=()=>{
  const clientJS=[
    "'use strict';",
    '// Full-size synthetic fixture for source-anchored contract checks only.',
    'const fakeBody = '+JSON.stringify('abc'.repeat(500))+';',
    '  function faDetailLine(label,value){return {label,value};}',
    '  function faRenderDetail(c){',
    '    const dl={items:[],append(x){this.items.push(x);}};',
    '    const faText=v=>String(v??"");',
    CLAIMED_ID_COPY.original,
    '    return dl.items;',
    '  }',
    '  async function faUnlock(){}',
    '  // Not a real Admin key, no real network endpoints.',
    '})();'
  ].join('\n');
  const workerJS=[
    'const MOD_SCRIPT = '+JSON.stringify(clientJS)+';',
    'const assetRoute = "env.ASSETS.fetch(request)";',
    'const jsRoute = "url.pathname===\'/__asc1649/feedback-appeal.js\'";',
    '// immutable source fixture, not a deployable Worker',
    '/* '+'.'.repeat(1200)+' */'
  ].join('\n');
  return {clientJS,workerJS};
};
test('patches existing Feedback & Appeal detail, and embedded Pages Worker, exactly once',()=>{
  const {clientJS,workerJS}=fixture();
  const o=patchNativeClaimedUserId(clientJS,workerJS);
  assert.notEqual(o.clientJS,clientJS);
  assert.notEqual(o.workerJS,workerJS);
  assert.equal(o.clientJS.includes(CLAIMED_ID_COPY.original),false);
  assert.equal(o.clientJS.includes(CLAIMED_ID_COPY.replacement),true);
  const embedded=JSON.parse(o.workerJS.match(/^const MOD_SCRIPT = (".*");$/m)?.[1]);
  assert.equal(embedded,o.clientJS);
  assert.doesNotThrow(()=>new Script(o.clientJS.replace(/^\(\)\);$/m,'')+''));
});
test('user-provided ID renders for BOTH Feedback and Appeal without granting ownership',()=>{
  const o=patchNativeClaimedUserId(...Object.values(fixture()));
  const line=o.clientJS.split('\n').find(x=>x.includes('Claimed Roblox UserId'));
  const render=new Function('c','dl','faDetailLine','faText',line);
  const visit=(kind,claimed_user_id)=>{
    const dl={rows:[],append(row){this.rows.push(row);}};
    render({kind,claimed_user_id},dl,(label,value)=>({label,value}),v=>String(v??''));
    return dl.rows;
  };
  assert.deepEqual(visit('feedback','123456789'),[{label:'Claimed Roblox UserId',value:'123456789 (unverified)'}]);
  assert.deepEqual(visit('appeal','987654321'),[{label:'Claimed Roblox UserId',value:'987654321 (unverified)'}]);
  assert.deepEqual(visit('feedback',null),[{label:'Claimed Roblox UserId',value:'Not provided (unverified)'}]);
  assert.deepEqual(visit('unknown','123'),[]);
});
test('fail closed on source mismatch, already patched files, duplicates, or missing routing',()=>{
  const {clientJS,workerJS}=fixture();
  assert.throws(()=>patchNativeClaimedUserId(clientJS.replace(CLAIMED_ID_COPY.original,''),workerJS),/native case detail/);
  assert.throws(()=>patchNativeClaimedUserId(clientJS+CLAIMED_ID_COPY.original,workerJS),/native case detail/);
  assert.throws(()=>patchNativeClaimedUserId(clientJS,workerJS.replace('env.ASSETS.fetch(request)','missing')),/Pages routing/);
  assert.throws(()=>patchNativeClaimedUserId(clientJS,workerJS.replace('abc','def')),/embedded client JS differs/);
  const once=patchNativeClaimedUserId(clientJS,workerJS);
  assert.throws(()=>patchNativeClaimedUserId(once.clientJS,once.workerJS),/native case detail/);
});
test('does not add unauthenticated case routes or any UserId-based authorization',()=>{
  const {clientJS,workerJS}=fixture();
  const revised=patchNativeClaimedUserId(clientJS,workerJS);
  assert.doesNotMatch(revised.clientJS,/\/api\/v1\/client\/violations\/lookup|\/api\/v1\/violation\/history|oauth\/authorize/i);
  assert.doesNotMatch(CLAIMED_ID_COPY.replacement,/fetch|Authorization|localStorage|adminAuthenticated|identityVerified/i);
  assert.ok(revised.clientJS.includes('function faRenderDetail(c)'));
  assert.ok(revised.clientJS.includes('async function faUnlock()'));
});
