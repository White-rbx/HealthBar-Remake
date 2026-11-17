import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const files = [
  'migrations/2026-11-17_stage1682_oidc_sandbox_only_DRAFT.sql',
  'migrations/2026-11-17_stage1683_pairing_sandbox_only_DRAFT.sql',
];
const migrations=files.map(f=>readFileSync(new URL('../'+f,import.meta.url),'utf8'));

function scrub(sql) {
  return sql.split('\n').filter(line=>!line.trimStart().startsWith('--')).join('\n');
}
const sql=migrations.map(scrub).join('\n');
const allowedTables=['asc_oidc_pending','asc_oidc_sessions','asc_pairing_sandbox'];
const allowedIndexes=[
  'idx_asc_oidc_pending_expires','idx_asc_oidc_sessions_expires',
  'idx_asc_pairing_sandbox_expires','idx_asc_pairing_sandbox_device',
];
test('D1 sandbox migration files cannot be mistaken for Production',()=>{
  for(const file of files) assert.match(file,/sandbox_only_DRAFT/);
  for(const text of migrations) assert.match(text,/NEVER|Never/i);
});
test('exactly three isolated tables and four indexes',()=>{
  const tables=[...sql.matchAll(/CREATE TABLE IF NOT EXISTS\s+([a-z_]+)/gi)].map(x=>x[1]);
  const indexes=[...sql.matchAll(/CREATE INDEX IF NOT EXISTS\s+([a-z_]+)/gi)].map(x=>x[1]);
  assert.deepEqual(tables.sort(),allowedTables.slice().sort());
  assert.deepEqual(indexes.sort(),allowedIndexes.slice().sort());
});
test('no destructive changes, data writes, or touching production schemas',()=>{
  assert.doesNotMatch(sql,/\b(DROP|ALTER|TRUNCATE|DELETE|INSERT|UPDATE|ATTACH|DETACH|VACUUM|REPLACE|GRANT)\b/i);
  assert.doesNotMatch(sql,/\b(arcscriptcenter-db|arcscriptcenter-staging|asc_feedback_cases|asc_violation_notices)\b/i);
  assert.doesNotMatch(sql,/\b(access_token|refresh_token|id_token|password|date_of_birth)\s+(TEXT|BLOB|INTEGER)\b/i);
});
test('short expiry and one-time constraints remain defined',()=>{
  assert.match(sql,/expires_unix\s+INTEGER\s+NOT NULL/i);
  assert.match(sql,/PRIMARY KEY/i);
  assert.match(sql,/CHECK\s*\(\s*length\(code_hash\)\s*=\s*43/i);
  assert.match(sql,/CHECK\s*\(\s*identity_method\s*=\s*'roblox_oidc'/i);
});
