import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const read = name => readFileSync(new URL(name, import.meta.url), 'utf8');
const client = read('BanPolicyClientPreview.lua');
const server = read('ArcScriptCenterBanBridge.server.lua');
const topbar = read('RestrictedMode-Topbar-STAGING.lua');
const setup = read('ExperienceSettings-SetUp-Preview.lua');
const main = read('LoaderMainPreview.lua');
const arcsen = read('Arcsen-Preview.lua');
const section = (source, start, end) => {
 const first = source.indexOf(start);
 const last = source.indexOf(end, first + start.length);
 assert.ok(first >= 0 && last > first, start);
 return source.slice(first, last);
};
const files = {
 client, server, topbar,
 setup: section(setup, 'local function renderBanBlock(item)', '-- Restricted Mode is NOT SetUp-only.') +
  '\nreturn banData',
 startup: section(main, 'local function canStartMain()', 'if not canStartMain() then') + '\nreturn canStartMain',
 main: section(main, '-- ASC BAN V2 MAIN REFRESH BEGIN', '-- ASC BAN V2 MAIN REFRESH END'),
 arcsen: section(arcsen, '    local function apply(status, reason)', '    -- Use a fixed production origin') +
  '\nreturn apply',
};

const fakeRuntime = String.raw`
local now = 0
local queue = {}
local runtime = {
    os = { clock = function() return now end, time = function() return math.floor(now) end, date = os.date },
    warn = function() end,
}
local function post(delay, thread, ...)
    table.insert(queue, { at = now + delay, thread = thread, args = table.pack(...) })
end
runtime.task = {
    spawn = function(fn, ...) post(0, coroutine.create(fn), ...) end,
    delay = function(delay, fn, ...) post(delay, coroutine.create(fn), ...) end,
    wait = function(delay)
        post(delay or 0.01, coroutine.running())
        coroutine.yield()
    end,
}
local function advance(to)
    while true do
        local index
        for k, event in ipairs(queue) do
            if event.at <= to and (not index or event.at < queue[index].at) then index = k end
        end
        if not index then break end
        local event = table.remove(queue, index)
        now = event.at
        local ok, why = coroutine.resume(event.thread, table.unpack(event.args, 1, event.args.n))
        assert(ok, why)
    end
    now = to
end

local function run(name, additions)
    local env = table.clone(runtime)
    for key, value in pairs(additions or {}) do env[key] = value end
    return setfenv(assert(loadstring(sources[name], name)), setmetatable(env, { __index = getfenv() }))()
end
local function policy(state, checkedAt, nextCheckAt, duration, expires)
    return {
        ok = true, identityVerified = true, subject = "451", checkedAt = checkedAt, nextCheckAt = nextCheckAt,
        state = state,
        ban = state ~= "clear" and {
            selection = state, reason = "Synthetic <record>", description = "QA only",
            duration = duration or "permanent", expiresAt = expires,
        } or nil,
    }
end
local function signal()
    local callbacks, waiting = {}, nil
    return {
        Connect = function(_, fn)
            callbacks[fn] = true
            return { Disconnect = function() callbacks[fn] = nil end }
        end,
        Wait = function()
            waiting = coroutine.running()
            coroutine.yield()
        end,
        Fire = function(_, ...)
            if waiting then post(0, waiting); waiting = nil end
            for fn in pairs(callbacks) do fn(...) end
        end,
    }
end
`;

function luau(script) {
 const tmp = mkdtempSync(join(tmpdir(), 'asc-ban-luau-'));
 try {
  const path = join(tmp, 'run.luau');
  const lines = Object.entries(files).map(([name, source]) => {
   const bracket = '='.repeat(15);
   assert.ok(!source.includes(']' + bracket + ']'));
   return name + '=[' + bracket + '[' + source + ']' + bracket + ']';
  });
  writeFileSync(path, 'local sources = {\n' + lines.join(',\n') + '\n}\n' + fakeRuntime + script);
  const result = spawnSync(process.env.LUAU_BIN || 'luau', [path], { encoding: 'utf8', timeout: 10000 });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stderr || result.stdout);
 } finally {
  rmSync(tmp, { recursive: true, force: true });
 }
}

test('Luau VM: bridge derives the subject, enforces one request in flight, and fails closed', () => {
 luau(String.raw`
local players = { PlayerRemoving = signal() }
local player = { Parent = players, UserId = 451 }
local remote = { SetAttribute = function(self, key, value) self[key] = value end }
local requests, response = 0, policy("clear", 100, 130)
local services = {
    Players = players,
    ReplicatedStorage = {},
    HttpService = {
        GetSecret = function(_, name)
            assert(name == "BAN_GAME_SERVER_SECRET")
            return { AddPrefix = function(_, prefix) assert(prefix == "Bearer "); return "mock only" end }
        end,
        JSONEncode = function(_, body)
            assert(body.userId == "451" and body.universeId == "999")
            assert(body.noticeId == nil and body.description == nil)
            return "mock request body"
        end,
        RequestAsync = function(_, request)
            assert(request.Url:match("arcscriptcenter%-ban%-v2%-qa.+/policy$"))
            assert(request.Method == "POST" and request.Headers.Authorization == "mock only")
            requests += 1
            runtime.task.wait(3)
            return { Success = response.ok, Body = "mock response body" }
        end,
        JSONDecode = function() return response end,
    },
}
run("server", {
    game = { GameId = 999, GetService = function(_, name) return services[name] end },
    script = { GetAttribute = function() return nil end },
    Instance = { new = function(class) assert(class == "RemoteFunction"); return remote end },
})
assert(remote.Parent == services.ReplicatedStorage and remote.IsolatedQA == true)
assert(remote.OnServerInvoke(player, "admin").code == "invalid_request")
assert(remote.OnServerInvoke(player, "appeal", {}, "invalid").code == "invalid_request")
runtime.task.spawn(function()
    assert(remote.OnServerInvoke(player, "policy", "999999", "spoof").state == "clear")
end)
advance(2.5)
assert(remote.OnServerInvoke(player, "policy").code == "rate")
advance(3)
assert(requests == 1)
response = { ok = false, code = "identity_unavailable" }
runtime.task.spawn(function()
    assert(remote.OnServerInvoke(player, "policy").code == "identity_unavailable")
end)
advance(6)
runtime.task.spawn(function()
    assert(remote.OnServerInvoke(player, "policy").code == "server_unavailable")
end)
advance(7)
player.Parent = nil
players.PlayerRemoving:Fire(player)
advance(9)
`);
});

test('Luau VM: policy rejects stale, wrong-subject and expired results, including a late HTTP reply', () => {
 luau(String.raw`
local response, delay, invoked = nil, 0, 0
local bridge = {
    IsA = function(_, name) return name == "RemoteFunction" end,
    GetAttribute = function() return true end,
    InvokeServer = function(_, op)
        assert(op == "policy")
        invoked += 1
        local body = response
        if delay > 0 then runtime.task.wait(delay) end
        return body
    end,
}
local client = run("client", {
    game = { GetService = function(_, name)
        if name == "Players" then return { LocalPlayer = { UserId = 451 } } end
        return { WaitForChild = function() return bridge end }
    end },
    Instance = { new = function()
        local event = signal()
        return { Event = event, Fire = function() event:Fire() end, Destroy = function() end }
    end },
})
local function call()
    local result
    runtime.task.spawn(function() result = client.policy() end)
    return function() return result end
end
response = policy("restricted_mode", 100, 130)
local first = call()
advance(0)
assert(first().state == "restricted_mode" and client.secondsRemaining(first()) == 29)
response = policy("clear", 102, 132)
response.subject = "452"
local subject = call()
advance(2)
assert(subject() == nil and client.secondsRemaining(first()) == 0)
response = policy("clear", 99, 129)
local stale = call()
advance(4)
assert(stale() == nil)
response = policy("ban_ingame", 103, 106, "temporary", 106)
delay = 2.5
local expired = call()
advance(5)
assert(client.policy() == nil and invoked == 4)
advance(7)
assert(expired() == nil)
response = policy("clear", 110, 140)
delay = 10
local late = call()
advance(15)
assert(late() == nil)
response = policy("clear", 118, 148)
delay = 0
local renewed = call()
advance(16)
assert(renewed().state == "clear")
advance(18)
assert(client.secondsRemaining(renewed()) == 26)
`);
});

test('Luau VM: Ban in-game stays in SetUp through outage and only resumes on a server change', () => {
 luau(String.raw`
local function simulate(mode, duration, updated)
    local reason = policy(mode, 100, 103, duration, duration == "temporary" and 103 or nil)
    local seen, completed = 0, false
    local ui = { Folder = { Parent = true }, twarn = { Text = "Loading" }, Canvas = {}, btnBar = {}, CanBar = {} }
    local env = {
        __ASC_BAN_V2_PREVIEW = true,
        __ASC_BAN_V2_CLIENT = {
            secondsRemaining = function() return 2 end,
            policy = function()
                seen += 1
                if seen == 1 then return reason end
                if seen == 2 then return nil end
                return updated
            end,
        },
    }
    ui.getgenv, ui.qaEnv = function() return env end, env
    ui.UDim2 = { new = function() return {} end }
    ui.Enum = { AutomaticSize = { Y = true, None = false }, ScrollingDirection = { Y = true },
        TextYAlignment = { Top = 1, Center = 2 } }
    ui.Instance = { new = function() return { Destroy = function() end } end }
    runtime.task.spawn(function() run("setup", ui); completed = true end)
    local start = now
    advance(start)
    if mode == "ban_ingame" then
        assert(not completed and env.__ES_BANNED and ui.btnBar.Visible)
        assert(ui.twarn.Text:find(duration) and ui.twarn.Text:find("Synthetic &lt;record&gt;"))
        advance(start + 2)
        assert(not completed and env.__ASC_BAN_POLICY_ERROR)
        assert(ui.twarn.Text:find("Could not verify"))
        assert(not ui.twarn.Text:find("unbanned"))
        advance(start + 7)
    end
    assert(completed and not env.__ES_BANNED and not env.__ASC_BAN_POLICY_ERROR)
    assert(env.__ES_RESTRICTED_MODE == (mode == "restricted_mode" or updated.state == "restricted_mode"))
end
simulate("ban_ingame", "temporary", policy("clear", 109, 139))
simulate("ban_ingame", "permanent", policy("restricted_mode", 109, 139))
simulate("restricted_mode", "temporary", policy("clear", 109, 139))
simulate("restricted_mode", "permanent", policy("clear", 109, 139))
`);
});

test('Luau VM: Restricted Loader tools restore only while clear is fresh; tighter status needs Rejoin', () => {
 luau(String.raw`
local mode = policy("restricted_mode", 100, 130)
mode.lease = 6
local env = { __ASC_BAN_V2_STATE = mode, __ES_RESTRICTED_MODE = true }
local ui = { Enabled = true }
local holder = { Parent = true }
local failed, restored, didStop, checked = false, 0, false, 0
env.__ASC_BAN_V2_CLIENT = {
    secondsRemaining = function(status) return status and math.max(0, status.lease - now) or 0 end,
    policy = function()
        checked += 1
        if checked == 1 then
            runtime.task.wait(3)
            return nil
        elseif checked == 2 then
            local clear = policy("clear", 112, 142)
            clear.lease = now + 2
            return clear
        elseif checked == 3 then
            local clear = policy("clear", 116, 146)
            clear.lease = now + 10
            return clear
        else
            local restricted = policy("restricted_mode", 130, 160)
            restricted.lease = now + 10
            return restricted
        end
    end,
}
env.ESRestrictedTopbarController = { stop = function() didStop = true end }
run("main", {
    asrt = holder, bootEnv = env, display = ui, displayProperty = "Enabled",
    isRestrictedMode = true, priorDisplay = true,
    loadTool = function()
        assert(ui.Enabled == false and env.__ES_RESTRICTED_MODE)
        if restored < 3 then restored += 1; runtime.task.wait(1) end
    end,
    warn = function() failed = true end,
})
advance(5)
assert(ui.Enabled and checked == 1)
advance(6)
assert(not ui.Enabled and failed)
advance(12)
assert(not ui.Enabled and restored == 1 and not didStop)
advance(14.5)
assert(not ui.Enabled and restored == 3 and not didStop)
advance(15.5)
assert(ui.Enabled and didStop and env.__ES_RESTRICTED_MODE == false)
env.__ASC_REQUEST_BAN_REFRESH()
advance(17.5)
assert(not ui.Enabled and checked == 4)
holder.Parent = nil
advance(20)
`);
});

test('Luau VM: TopBar and Arcsen Chat lock and restore original interaction and color', () => {
 luau(String.raw`
local function button(name, parent)
    return { Name = name, Parent = parent, Visible = true, Active = true, Interactable = true,
        AutoButtonColor = true, BackgroundColor3 = "original",
        IsA = function(_, kind) return kind == "GuiButton" end }
end
local holder = { DescendantAdded = signal() }
local allowed = button("z8_ChatGPT", holder)
local editor = button("Editor", holder)
holder.GetChildren = function() return { allowed, editor } end
holder.GetDescendants = holder.GetChildren
local top = { ChildAdded = signal(), FindFirstChild = function(_, name)
    if name == "Holder" then return holder end
end }
local function parent(child) return { FindFirstChild = function() return child end } end
local color = { fromRGB = function(r, g, b) assert(r == 89 and g == 89 and b == 89); return "gray" end }
local env = { __ES_RESTRICTED_MODE = true, __ES_BAN_SELECTION = "restricted_mode" }
assert(run("topbar", {
    Color3 = color, getgenv = function() return env end,
    game = { GetService = function() return parent(parent(parent(top))) end },
}))
local newButton = button("Search", holder)
holder.DescendantAdded:Fire(newButton)
assert(allowed.Interactable and editor.Interactable == false and newButton.BackgroundColor3 == "gray")
env.ESRestrictedTopbarController.stop()
assert(editor.Interactable and editor.BackgroundColor3 == "original" and newButton.Interactable)

local new, send, history, input, chat, box = button("New", {}), button("Send", {}), {}, {}, {}, { TextEditable = true }
local opened, loc = false, { API = {} }
local apply = run("arcsen", {
    env = env, loc = loc, gate = {}, new = new, c_b_send = send, scr = history, c_input = input, c_scr = chat,
    c_box = box, overlay = {}, saved = { newVisible = true, textEditable = true },
    Color3 = color, showSettings = function() opened = true end,
})
apply("banned")
assert(opened and loc.API.PolicyReadOnly and not new.Interactable and not send.Interactable)
assert(new.BackgroundColor3 == "gray" and not box.TextEditable)
env.__ES_RESTRICTED_MODE = false
apply("not_banned")
assert(new.Interactable and send.Interactable and new.BackgroundColor3 == "original" and box.TextEditable)
`);
});

test('Luau VM: Get Load never grants main from an expired SetUp decision', () => {
 luau(String.raw`
local stale = policy("clear", 100, 130)
local latest
local checks = 0
local env = {
    __ASC_BAN_V2_PREVIEW = true, __ASC_BAN_V2_STATE = stale, __ES_LOAD_GRANTED = true,
    __ASC_BAN_V2_CLIENT = {
        secondsRemaining = function(status) return status == latest and status ~= nil and 15 or 0 end,
        policy = function() checks += 1; return latest end,
    },
}
local canStart = run("startup", { bootEnv = env })
assert(not canStart() and checks == 1 and env.__ASC_BAN_POLICY_ERROR and not env.__ES_LOAD_GRANTED)
latest = policy("restricted_mode", 131, 161)
assert(canStart() and checks == 2 and env.__ES_RESTRICTED_MODE and not env.__ES_BANNED)
assert(canStart() and checks == 2)
latest = policy("ban_ingame", 140, 170)
assert(not canStart() and checks == 3 and env.__ES_BANNED and not env.__ASC_BAN_POLICY_ERROR)
`);
});
