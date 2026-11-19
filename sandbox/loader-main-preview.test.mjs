import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const src=readFileSync('sandbox/LoaderMainPreview.lua','utf8');

test('preview is local-only and does not call a Worker, GitHub or Roblox Remote',()=>{
  for(const forbidden of [
    /HttpGet\s*\(/, /PostAsync\s*\(/, /RequestAsync\s*\(/,
    /FireServer\s*\(/, /InvokeServer\s*\(/,
    /loadstring\s*\(/, /require\s*\(/,
    /__ES_(?:RESTRICTED_MODE|BANNED)\s*=(?!=)/
  ]) assert.doesNotMatch(src,forbidden);
  assert.match(src,/player:WaitForChild\("PlayerGui"/);
  assert.match(src,/playerGui:FindFirstChild\(NAME\)/);
  assert.match(src,/if previous then previous:Destroy\(\) end/);
  assert.match(src,/gui:Destroy\(\)/);
  assert.doesNotMatch(src,/CoreGui\s*:\s*WaitForChild/);
});

test('mode and duration are independent, all four visual QA combinations possible',()=>{
  for(const name of ['BanIngame','RestrictedMode','Temporary','Permanent'])
    assert.ok(src.includes('"'+name+'"'),name);
  assert.match(src,/local selection="restricted_mode"/);
  assert.match(src,/local duration="temporary"/);
  assert.match(src,/selection="ban_ingame"\s+render\(\)/);
  assert.match(src,/selection="restricted_mode"\s+render\(\)/);
  assert.match(src,/duration="temporary"\s+render\(\)/);
  assert.match(src,/duration="permanent"\s+render\(\)/);
  assert.match(src,/main.Visible=isRestricted/);
});

test('safe controls match actual named staging buttons and ordinary tools are disabled',()=>{
  for(const name of ['a1_Open/Close','z7_About','z8_ChatGPT','z8_Arcsen'])
    assert.ok(src.includes('["'+name+'"]=true'),name);
  for(const name of ['MockEditor','MockSearch','MockTools'])
    assert.ok(src.includes('"'+name+'"'),name);
  assert.match(src,/b.Interactable=allowed/);
  assert.match(src,/b.Active=allowed/);
  assert.match(src,/b.AutoButtonColor=allowed/);
  assert.match(src,/b.Visible=expanded or b==buttons\[1\]/);
});

test('account violation is only a labeled synthetic fixture and live audit is read-only',()=>{
  assert.match(src,/local syntheticVerified=false/);
  assert.match(src,/violation.Visible=expanded and syntheticVerified/);
  assert.match(src,/SYNTHETIC fixture only/);
  assert.match(src,/CoreGui:FindFirstChild\("ExperienceSettings"\)/);
  assert.match(src,/Observation only: NOT server enforcement evidence/);
});
