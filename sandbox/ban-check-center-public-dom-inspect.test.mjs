import test from 'node:test';
import assert from 'node:assert/strict';

test('inspect original STAGING Ban Center public HTML shape, without credentials',async()=>{
 const base='https://stage16-54-verified-unlock.arcscriptcenter-dashboard-staging.pages.dev/';
 const response=await fetch(base,{redirect:'error'});
 assert.equal(response.status,200);
 const body=await response.text();
 const markers=['Banned Check Center','Ban Management','Ban List','page-bans','banRender','banUserId','banUsername','banReason','banExpiry','adminKey','Ban type','Ban Type'];
 const found=markers.map(needle=>{
  const at=body.toLowerCase().indexOf(needle.toLowerCase());
  return {needle,present:at>=0,excerpt:at>=0?body.slice(Math.max(0,at-110),at+190).replace(/[^ -~]/g,' ').slice(0,300):''};
 });
 console.log('BAN_CENTER_DOM_PROBE '+JSON.stringify({bytes:body.length,markers:found}));
 assert.ok(body.includes('id="page-bans"'));
});
