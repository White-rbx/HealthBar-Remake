import test from 'node:test';
import assert from 'node:assert/strict';
import {
  ORIGINAL_CLAIM_BLOCK,
  NEW_CLAIM_BLOCK,
  prepareOptionalUnverifiedSenderClaimPatch,
  displayUnverifiedClaim,
} from './feedback-unverified-claim-worker-patch.mjs';

const INSERT="    'INSERT INTO asc_feedback_cases(id,receipt_hash,kind,claimed_user_id,topic,description,status,created_unix,updated_unix) '+";
const SELECT="'SELECT id,kind,claimed_user_id,topic,description,status,created_unix,updated_unix,revision,public_note,admin_note,followup,followup_updated_unix '";
const fixture=()=> [
  '// Controlled synthetic Worker source fixture: NO real tokens or user data',
  '// '.repeat(500),
  'async function fcSubmit(request,env,origin) {',
  '  const b=await fcPayload(request, 32000);',
  ORIGINAL_CLAIM_BLOCK,
  '  const id=crypto.randomUUID();',
  '  await env.DB.prepare(',
  INSERT,
  "    \u0022VALUES(?,?,?,?,?,?,'reviewing',?,?)\u0022",
  '  );',
  '}',
  'async function fcStatus() {',
  '  // Return only one case when authorized with its separate secret Receipt.',
  '}',
  'async function fcManage() {',
  '  // Case ID + receipt only; requires reviewing status; no Roblox account scope.',
  '}',
  'async function fcAdmin() {',
  SELECT,
  '}',
].join('\n');

function interpretClaim(b) {
  // Run ONLY the trusted fixture fragment with synthetic input.
  const fn=new Function('b','validUserId','json','origin',
    'return (async()=>{\n'+NEW_CLAIM_BLOCK+'\nreturn {claimedId};\n})();');
  return fn(b,(v)=>typeof v==='string' && /^[1-9]\d{0,15}$/.test(v),
    (body,status)=>({body,status}), 'https://sandbox.invalid');
}

test('strictly patches ONE existing fcSubmit block and preserves D1/Admin queries',()=>{
  const source=fixture();
  const rewritten=prepareOptionalUnverifiedSenderClaimPatch(source);
  assert.notEqual(rewritten,source);
  assert.ok(rewritten.includes(NEW_CLAIM_BLOCK));
  assert.ok(!rewritten.includes(ORIGINAL_CLAIM_BLOCK));
  assert.ok(rewritten.includes(INSERT));
  assert.ok(rewritten.includes(SELECT));
  assert.equal(rewritten.slice(rewritten.indexOf('async function fcStatus(')),
    source.slice(source.indexOf('async function fcStatus(')));
});
test('id claim in regular Feedback is optional and never requires OAuth',async()=>{
  assert.deepEqual(await interpretClaim({kind:'feedback'}),{claimedId:null});
  assert.deepEqual(await interpretClaim({kind:'feedback',claimedUserId:null}),{claimedId:null});
  assert.deepEqual(await interpretClaim({kind:'feedback',claimedUserId:'123456'}),{claimedId:'123456'});
});
test('Appeal still requires a claimed numeric ID, but no ownership proof',async()=>{
  assert.deepEqual(await interpretClaim({kind:'appeal',claimedUserId:'123456'}),{claimedId:'123456'});
  const rejected=await interpretClaim({kind:'appeal'});
  assert.equal(rejected.status,400);
  assert.match(rejected.body.error,/claimed UserId/);
});
test('malformed numeric claims are rejected as format errors, not auth denial',async()=>{
  for(const id of ['somebody','0','-5','123 4','9'.repeat(20)]){
    const result=await interpretClaim({kind:'feedback',claimedUserId:id});
    assert.equal(result.status,400,id);
    assert.match(result.body.error,/format/);
  }
});
test('Admin metadata is never described as verified',()=>{
  assert.equal(displayUnverifiedClaim({claimed_user_id:'123456'}),'Claimed UserId: 123456 (Unverified)');
  assert.equal(displayUnverifiedClaim({claimed_user_id:null}),'Not provided');
});
test('source drift and duplicate anchors fail closed rather than silent patching',()=>{
  const source=fixture();
  assert.throws(()=>prepareOptionalUnverifiedSenderClaimPatch(source.replace(ORIGINAL_CLAIM_BLOCK,'')),/original claim block/i);
  assert.throws(()=>prepareOptionalUnverifiedSenderClaimPatch(source+ORIGINAL_CLAIM_BLOCK),/original claim block/i);
  assert.throws(()=>prepareOptionalUnverifiedSenderClaimPatch(source.replace(SELECT,'no admin list')),/schema or Admin list/i);
  assert.throws(()=>prepareOptionalUnverifiedSenderClaimPatch(source+'async function fcSubmit() {}'),/source signature/i);
});
