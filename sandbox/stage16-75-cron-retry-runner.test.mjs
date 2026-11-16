// Stage 16.75 - isolated unit tests for the GitHub Cron runner draft.
// Run: node --test sandbox/stage16-75-cron-retry-runner.test.mjs
// No network access, no Cloudflare credentials, no real database writes or pushes.
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { webcrypto } from "node:crypto";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const source = fs.readFileSync(path.join(here, "stage16-75-cron-retry-runner.js"), "utf8");
const marker = "//__STAGE1675_ROUTES__";
assert.equal(source.split(marker).length, 2, "Cron helper and route marker must be unique");
const helpers = source.split(marker)[0];

function setup({
  version = "0.5.79.0-cron-retry-sandbox",
  mode = "sandbox-dummy",
  cron = "*/5 * * * *",
  shouldThrow = false,
  audience = "a".repeat(64),
  hasDb = true,
  result = { jobs: 2, attempted: 2, accepted: 1, failed: 1 },
} = {}) {
  const queries = [];
  let retryCalls = 0;
  const db = {
    prepare(sql) {
      const item = { sql, args: [] };
      return {
        bind(...args) {
          item.args = args;
          return this;
        },
        async run() {
          queries.push(item);
          return { success: true };
        },
      };
    },
  };
  const env = {
    ASC_TURNSTILE_MODE: mode,
    ASC_PUSH_ACCESS_AUD: audience,
    DB: hasDb ? db : undefined,
  };
  const context = vm.createContext({
    VERSION: version,
    asc1674RetryDue: async () => {
      retryCalls++;
      if (shouldThrow) throw Error("synthetic retry failure");
      return result;
    },
    Response,
    crypto: webcrypto,
    Date,
    Math,
    Number,
    String,
    Object,
  });
  vm.runInContext(helpers + "\n;globalThis.__runner = asc1675CronRunner;", context, {
    filename: "stage16-75-cron-retry-runner.js",
    timeout: 1500,
  });
  return {
    run: () => context.__runner({ cron }, env, {}),
    queries,
    get retryCalls() { return retryCalls; },
  };
}

test("valid Sandbox cron processes due work and writes aggregate health", async () => {
  const runner = setup();
  await runner.run();
  assert.equal(runner.retryCalls, 1);
  assert.equal(runner.queries.length, 3);
  assert.match(runner.queries[0].sql, /runs=runs\+1/);
  assert.match(runner.queries[1].sql, /attempts>=3/);
  assert.match(runner.queries[2].sql, /last_jobs=\?/);
  assert.deepEqual(runner.queries[2].args.slice(1), [2, 2, 1, 1]);
  assert.equal(runner.queries.every(q => !q.sql.includes("DELETE")), true);
});

test("cron refuses unknown schedule", async () => {
  const runner = setup({ cron: "* * * * *" });
  await runner.run();
  assert.equal(runner.retryCalls, 0);
  assert.equal(runner.queries.length, 0);
});

test("cron refuses non-Sandbox Worker version", async () => {
  const runner = setup({ version: "0.5.79.0-production" });
  await runner.run();
  assert.equal(runner.retryCalls, 0);
  assert.equal(runner.queries.length, 0);
});

test("cron refuses non-Sandbox Turnstile environment", async () => {
  const runner = setup({ mode: "production" });
  await runner.run();
  assert.equal(runner.retryCalls, 0);
  assert.equal(runner.queries.length, 0);
});

test("cron refuses missing Access audience binding", async () => {
  const runner = setup({ audience: null });
  await runner.run();
  assert.equal(runner.retryCalls, 0);
  assert.equal(runner.queries.length, 0);
});

test("cron refuses malformed or empty Access audience", async () => {
  for (const audience of ["", "short", "a".repeat(129), "invalid audience with spaces"]) {
    const runner = setup({ audience });
    await runner.run();
    assert.equal(runner.retryCalls, 0);
    assert.equal(runner.queries.length, 0);
  }
});

test("cron refuses missing D1 binding", async () => {
  const runner = setup({ hasDb: false });
  await runner.run();
  assert.equal(runner.retryCalls, 0);
  assert.equal(runner.queries.length, 0);
});

test("retry worker error is recorded without exposing exception message", async () => {
  const runner = setup({ shouldThrow: true });
  await runner.run();
  assert.equal(runner.retryCalls, 1);
  assert.equal(runner.queries.length, 3);
  assert.match(runner.queries[2].sql, /last_error='worker_error'/);
  assert.equal(JSON.stringify(runner.queries).includes("synthetic retry failure"), false);
});

test("draft is read-only except for bounded existing outbox retry and telemetry", () => {
  assert.match(helpers, /await asc1674RetryDue\(env\)/);
  assert.match(helpers, /controller\?\.cron!==['"]\*\/5 \* \* \* \*['"]/);
  assert.match(helpers, /async function asc1675Status/);
  assert.match(helpers, /await asc1674Allowed\(req,env,ctx\)/);
  assert.doesNotMatch(helpers, /process\.env|ADMIN_KEY|ASC_PUSH_VAPID_PRIVATE_JWK/);
});
