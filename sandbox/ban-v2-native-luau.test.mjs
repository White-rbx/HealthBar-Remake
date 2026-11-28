import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const read = name => readFileSync(new URL(name, import.meta.url), 'utf8');
const entry = read('BannedCenterLoaderPreview.lua');
const client = read('BanPolicyClientPreview.lua');
const server = read('ArcScriptCenterBanBridge.server.lua');
const topbar = read('RestrictedMode-Topbar-STAGING.lua');
const setup = read('ExperienceSettings-SetUp-Preview.lua');
const main = read('LoaderMainPreview.lua');
const rejoiner = read('Loader-UI-BanMode-STAGING.lua');
const arcsen = read('Arcsen-Preview.lua');
const section = (source, start, end) => {
 const first = source.indexOf(start);
 const last = source.indexOf(end, first + start.length);
 assert.ok(first >= 0 && last > first, start);
 return source.slice(first, last);
};
const files = {
 entry, client, server, topbar,
 accountUi: read('ESLogin.lua'), accountClient: read('ASCAccountClientPreview.lua'),
 accountAccessChallenge: section(read('ASCAccountClientPreview.lua'),
   'local function accessChallenge(reply, status, raw)',
   'local function send(route, body, authenticated)') + '\nreturn accessChallenge',
 testerUi: read('ESLoginTesterPreview.lua'), testerEntry: read('ASCAccountTesterPreview.lua'),
 boot: section(main, 'local policyMode =', '-- ASC BAN V2 BOOTSTRAP END') + '\nreturn policyMode',
 waiting: section(rejoiner, 'local function canContinue()', '-- Continue (ONE TIME)') + '\nreturn canContinue',
 warning: section(main, '-- ASC POLICY WARNING BEGIN', '-- ASC POLICY WARNING END') + '\nsetupWarningReady = true; return syncPolicyWarning',
 renderer: main.split('local sourceUI = [=====[')[1].split(']=====]')[0],
 warningQueue: section(main, 'local function showNext()', '-- Server warnings are already-verified') + '\nreturn api',
 gateCheck: section(arcsen, '    local function check()', '    local controller = {') + '\nreturn check',
 setup: section(setup, 'local function renderBanBlock(item)', '-- Restricted Mode is NOT SetUp-only.') +
  '\nreturn banData',
 startup: section(main, 'local function canStartMain()', 'if not canStartMain() then') + '\nreturn canStartMain',
 main: section(main, '-- ASC BAN V2 MAIN REFRESH BEGIN', '-- ASC BAN V2 MAIN REFRESH END'),
 signOut: section(main, '-- Ban in-game never reaches here. Restricted Mode deliberately loads MAIN',
    'local isRestrictedMode =') + '\nreturn bootEnv.__ASC_ACCOUNT_SIGN_OUT',
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
    defer = function(fn, ...) post(0, coroutine.create(fn), ...) end,
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

local function run(name, additions, ...)
    local env = table.clone(runtime)
    for key, value in pairs(additions or {}) do env[key] = value end
    return setfenv(assert(loadstring(sources[name], name)), setmetatable(env, { __index = getfenv() }))(...)
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
    c_box = box, overlay = {}, saved = { newVisible = true, textEditable = true, interaction = { true, true, true, true } },
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

test('Luau VM: default QA entry needs no Roblox server or login and rechecks on each launch', () => {
 luau(String.raw`
local userId, lookups = 9777206932, 0
local state = "restricted_mode"
local response, received
local additions = {
    getgenv = function() return {} end,
    game = { GetService = function(_, name)
        if name == "Players" then return { LocalPlayer = { UserId = userId } } end
        assert(name == "HttpService", "the public policy must not access ReplicatedStorage")
        return {
            JSONEncode = function(_, value)
                assert(value.userId == tostring(userId) and next(value, "userId") == nil)
                return "mock body"
            end,
            JSONDecode = function(_, raw) assert(raw == "mock policy");return response end,
        }
    end },
    request = function(req)
        assert(req.Url:match("arcscriptcenter%-ban%-policy%-qa.+/status$"))
        assert(req.Method == "POST" and req.Body == "mock body")
        assert(req.Headers.Authorization == nil and req.Headers.Cookie == nil)
        lookups += 1
        return { StatusCode = 200, Body = "mock policy" }
    end,
    Instance = { new = function()
        local event = signal()
        return { Event = event, Fire = function() event:Fire() end, Destroy = function() end }
    end },
}
local published
local internal = {}
run("entry", {
    getgenv = function() return internal end,
    game = { HttpGet = function(_, url)
        assert(url:match("/LoaderMainPreview%.lua$"))
        return 'local mode = ...; capture(mode)'
    end },
    loadstring = function(source) return setfenv(assert(loadstring(source)), { capture = function(mode)
        assert(internal.__ASC_BAN_V2_PREVIEW == true)
        published = mode
    end }) end,
})
assert(published == "public_qa" and internal.__ASC_BAN_V2_PREVIEW == nil)
local function launch(state)
    response = policy(state, 100 + math.floor(now), 130 + math.floor(now))
    response.subject, response.identityVerified, response.ban = tostring(userId), false, nil
    response.notice = state ~= "clear" and { duration = "permanent", reason = "Footsteps" } or nil
    local client = run("client", additions, published)
    assert(client.publicLookup)
    local result
    runtime.task.spawn(function() result = client.policy() end)
    advance(now)
    assert(result and result.identityVerified == false and result.state == state)
    local env = {
        __ASC_BAN_V2_PREVIEW = true, __ASC_BAN_V2_CLIENT = client, __ASC_BAN_V2_STATE = result,
    }
    local canStart = run("startup", { bootEnv = env })
    assert(canStart() == (state ~= "ban_ingame"))
    assert(env.__ES_RESTRICTED_MODE == (state == "restricted_mode"))
    assert(env.__ES_BAN_SELECTION == (state ~= "clear" and state or nil))
    local setupEnv = {
        __ASC_BAN_V2_PREVIEW = true,
        __ASC_BAN_V2_CLIENT = {
            publicLookup = true,
            policy = function() return result end,
            secondsRemaining = function() return 10 end,
        },
    }
    local setupUi = { Folder = { Parent = true }, twarn = { Text = "Setup" }, Canvas = {}, btnBar = {}, CanBar = {},
        getgenv = function() return setupEnv end, qaEnv = setupEnv,
        UDim2 = { new = function() return {} end },
        Enum = { AutomaticSize = { Y = true }, ScrollingDirection = { Y = true }, TextYAlignment = { Top = 1 } },
        Instance = { new = function() return {} end },
    }
    runtime.task.spawn(function() run("setup", setupUi) end)
    advance(now)
    assert(setupEnv.__ES_BANNED == (state == "ban_ingame"))
    if state == "ban_ingame" then
        assert(setupUi.twarn.Text:find("Ban in%-game") and setupUi.twarn.Text:find("Footsteps"))
        setupUi.Folder.Parent = nil
        advance(now + 0.25)
    end
end
launch(state)
advance(4)
launch("clear")
advance(7)
launch("ban_ingame")
assert(lookups == 3)
`);
});

test('Luau VM: direct Loader boot uses public QA, restricted continues, and Arcsen fails closed', () => {
 luau(String.raw`
local env = {}
local mode = run("boot", {
    getgenv = function() return env end,
    game = { HttpGet = function(_, url)
        assert(url:match("/BanPolicyClientPreview%.lua$"))
        return 'return {mode=...}'
    end },
})
assert(mode == "public_qa" and env.__ASC_BAN_V2_CLIENT.mode == mode and env.__ASC_BAN_V2_PREVIEW)
local setup = { __ASC_BAN_V2_PREVIEW = true, __ES_RESTRICTED_MODE = true }
local waiting = run("waiting", {
    _boot = setup, loc = { canLoad = function() return true end },
    Data = { Loader = { AlwaysLoad = false } }, manualLoadRequested = false,
})
assert(waiting())
setup.__ES_RESTRICTED_MODE = false
assert(not waiting())
local gate, applied = {}, nil
local check = run("gateCheck", {
    gate = gate, run = true, loc = { BanQAPolicyExpected = true },
    apply = function(state) applied = state end,
    post = function() error("QA must not fall back to the Signed UI Policy") end,
})
assert(not check() and not gate.policyValid and applied == "unknown")
local restricted = { state = "restricted_mode", identityVerified = false }
check = run("gateCheck", {
    gate = gate, run = true, loc = { BanQAPolicyExpected = true }, env = { __ASC_BAN_V2_STATE = restricted },
    banPolicyClient = { secondsRemaining = function() return 29 end },
    apply = function(state) applied = state end,
})
assert(check() and applied == "restricted_mode" and gate.policyValid and not gate.identityVerified)
`);
});

test('Luau VM: Client WarningUI displays the four combinations, suppresses polling repeats and can retry errors', () => {
 luau(String.raw`
local warnings, dismissed = {}, 0
local env = {}
local fail = false
env.WarningUI = {
    dismissClient = function(key)
        assert(key == "ArcScriptCenterBanPolicy")
        dismissed += 1
    end,
    showClient = function(payload)
        if fail then error("synthetic renderer failure") end
        table.insert(warnings, payload)
        return true
    end,
}
local publish = run("warning", { bootEnv = env })
publish({state="clear"})
advance(0)
assert(#warnings == 0)
local function submit(state, duration, expires, revision)
    publish({ state = state, notice = { reason = "Footsteps", duration = duration, expiresAt = expires, revision = revision } })
end
for _, mode in ipairs({"restricted_mode", "ban_ingame"}) do
    submit(mode, "permanent")
    advance(now)
    local latest = warnings[#warnings]
    assert(latest.description:find("Footsteps") and latest.description:find("Permanent"))
    assert(latest.compact == (mode == "restricted_mode"))
    submit(mode, "temporary", 1795189200)
    advance(now)
    assert(warnings[#warnings].description:find("Temporary") and warnings[#warnings].description:find("ICT"))
end
assert(#warnings == 4)
submit("ban_ingame", "temporary", 1795189200)
publish(nil)
advance(now)
assert(#warnings == 4)
fail = true
submit("ban_ingame", "temporary", 1795189200, "new case")
advance(now)
assert(#warnings == 4)
fail = false
submit("ban_ingame", "temporary", 1795189200, "new case")
advance(now)
assert(#warnings == 5)
local before = dismissed
publish({state="clear"})
advance(now)
assert(dismissed == before + 1 and #warnings == 5)
submit("ban_ingame", "temporary", 1795189200, "new case")
advance(now)
assert(#warnings == 6)
`);
});

test('Luau VM: existing WarningUI replaces only its matching Client warning', () => {
 luau(String.raw`
local called, lifecycle = {}, {}
local state = { queue = {} }
local api = run("warningQueue", {
    api = {}, state = state,
    makeButtonCallback = function() return nil end,
    pop = function(title, _, _, _, _, onClose, _, _, compact)
        table.insert(called, { title = title, compact = compact })
        local closed = false
        local close = function()
            if closed then return end
            closed = true
            table.insert(lifecycle, title)
            onClose()
        end
        return { close = close }
    end,
})
assert(api.showClient({title="Independent",description="An existing unrelated warning."}))
assert(api.showClient({title="Old policy",description="First",clientKey="ban",compact=true}))
api.dismissClient("ban")
assert(#called == 1 and #lifecycle == 0)
assert(api.showClient({title="New policy",description="Second",clientKey="ban",compact=true}))
state.active.close()
advance(now)
assert(#called == 2 and called[2].title == "[CLIENT] New policy" and called[2].compact)
api.dismissClient("ban")
advance(now)
assert(#lifecycle == 2 and state.active == nil)
`);
});

test('Luau VM: full WarningUI renders with no global Workspace alias and replaces its popup', () => {
 luau(String.raw`
local env, instances, deferred = {}, {}, {}
local function make(class)
    local obj = { class = class, BackgroundTransparency = 0, Rotation = 0, MouseButton1Click = { Connect = function(self, fn) self.fn = fn end } }
    function obj:FindFirstChildOfClass(kind)
        for _, child in ipairs(instances) do if child.Parent == self and child.class == kind then return child end end
    end
    function obj:FindFirstChild(name)
        for _, child in ipairs(instances) do if child.Parent == self and child.Name == name then return child end end
    end
    function obj:Destroy() self.Parent = nil end
    table.insert(instances, obj)
    return obj
end
local root=make("CoreGui")
local tween={Create=function(_,target,_,props)
    return { Play=function() for k,v in pairs(props) do target[k]=v end end }
end}
local function enum()
    return setmetatable({}, {__index=function(t,k) local v=enum();rawset(t,k,v);return v end})
end
local enums=enum()
local ctor={new=function(...)return table.pack(...) end,fromRGB=function(...)return table.pack(...) end}
local globals=setmetatable({
    game={GetService=function(_,name)return name=="CoreGui" and root or (name=="TweenService" and tween or {}) end},
    Instance={new=make},Enum=enums,getgenv=function()return env end,
    task={spawn=function()end,delay=function(_,fn)table.insert(deferred,fn) end,defer=function(fn)fn() end},
}, {__index=getfenv()})
for _, typeName in ipairs({"UDim","UDim2","Vector2","Color3","ColorSequenceKeypoint","ColorSequence","NumberSequenceKeypoint","NumberSequence","TweenInfo"}) do
    globals[typeName]=ctor
end
local ui=run("renderer",globals)
assert(ui.showClient({title="Restricted Mode",description="Reason: Footsteps",clientKey="ban",compact=true}))
local folder=root:FindFirstChild("WarningUI-ByArcScript")
local holder=folder:FindFirstChild("main"):FindFirstChild("Holder")
local first=holder:FindFirstChild("PopUp")
assert(first:FindFirstChild("Title").Text=="[CLIENT] Restricted Mode")
assert(holder.BackgroundTransparency==1)
assert(holder:FindFirstChildOfClass("UIListLayout").VerticalAlignment == enums.VerticalAlignment.Bottom)
ui.dismissClient("ban")
assert(ui.showClient({title="Ban in-game",description="Duration: Permanent",clientKey="ban"}))
table.remove(deferred,1)()
assert(first.Parent==nil)
local second=holder:FindFirstChild("PopUp")
assert(second:FindFirstChild("Title").Text=="[CLIENT] Ban in-game")
assert(holder.BackgroundTransparency==0.2)
assert(holder:FindFirstChildOfClass("UIListLayout").VerticalAlignment == enums.VerticalAlignment.Center)
`);
});

test('Luau VM: universal policy and remembered private case work on executor HTTP without Roblox bridge',()=>{
 luau(String.raw`
local invite, token = "ASCVE_" .. string.rep("a",64), "ASCVS_" .. string.rep("b",64)
local saved, encoded, decoded, failHistory, claimedAccount = nil, nil, {}, nil, 451
local displayedReference = "••••AB"
local options = {
    getgenv = function() return {} end,
    readfile = function() assert(saved); return "local session" end,
    writefile = function(_,body) assert(body=="request"); saved=encoded end,
    delfile = function() saved=nil end,
    game = { GetService = function(_, name)
        if name == "Players" then return {LocalPlayer={UserId=claimedAccount}} end
        assert(name=="HttpService", "universal path must not access Roblox server services")
        return {
            JSONEncode=function(_,v) encoded=v;return "request" end,
            JSONDecode=function(_,s) return s=="local session" and saved or decoded[s] end,
        }
    end },
    http_request = function(req)
        assert(req.Method=="POST" and req.Timeout==8)
        local route=req.Url:match("/([^/]+)$")
        local status=200
        if route=="status" then
            assert(req.Headers.Authorization==nil and encoded.userId==tostring(claimedAccount))
            decoded[route]={ok=true,identityVerified=false,subject=tostring(claimedAccount),checkedAt=100,nextCheckAt=130,
                state="restricted_mode",notice={duration="permanent",reason="QA",revision=string.rep("a",24)}}
        elseif route=="enroll" then
            assert(req.Headers.Authorization=="Bearer "..invite and next(encoded)==nil)
            status=201
            decoded[route]={ok=true,session=token,subject="451",expiresAt=10000}
        else
            assert(req.Headers.Authorization=="Bearer "..token)
            if route=="history" and failHistory=="timeout" then runtime.task.wait(9) end
            if route=="history" and failHistory=="api" then status=503;decoded[route]={ok=false}
            elseif route=="history" then
                assert(next(encoded)==nil)
                decoded[route]={ok=true,identityVerified=true,notices={{id="fixture-case",reference=displayedReference}}}
            elseif route=="reference" then
                decoded[route]={ok=true,subject="451",state="restricted_mode",reference="••••AB",revision=string.rep("a",24)}
            elseif route=="revoke" then decoded[route]={ok=true} end
        end
        return { StatusCode=status, Body=route }
    end,
    Instance = { new=function()
        local e=signal()
        return {Event=e,Fire=function()e:Fire()end,Destroy=function()end}
    end },
}
local function runAsync(fn)
    local value
    runtime.task.spawn(function() value=fn() end)
    advance(now)
    return value
end
local ui=run("client", options, "public_qa")
assert(not ui.hasPrivateCaseChannel() and ui.history()==nil)
local public=runAsync(ui.policy)
assert(public.state=="restricted_mode" and public.identityVerified==false)
assert(runAsync(function() return ui.enrollCase(invite,true) end))
assert(saved and saved.subject=="451")
local restored=run("client",options,"public_qa")
assert(restored.hasPrivateCaseChannel())
assert(runAsync(restored.history)[1].reference=="••••AB")
displayedReference = "BANNTOKEN2_NOT_A_DISPLAY_REFERENCE"
assert(runAsync(restored.history)[1].reference==nil)
displayedReference = "••••AB"
assert(runAsync(function()return restored.restrictionReference(public)end)=="••••AB")
failHistory="api"
assert(runAsync(restored.history)==nil and restored.hasPrivateCaseChannel())
failHistory="timeout"
local checked=false
runtime.task.spawn(function() assert(restored.history()==nil);checked=true end)
advance(now+8)
assert(checked and restored.hasPrivateCaseChannel() and public.state=="restricted_mode")
claimedAccount=452
assert(not run("client",options,"public_qa").hasPrivateCaseChannel())
assert(runAsync(restored.disconnectCase) and saved==nil and not restored.hasPrivateCaseChannel())
`);
});

test('Luau VM: WarningUI displays only validated references from authenticated policy',()=>{
 luau(String.raw`
local warning
local env={WarningUI={dismissClient=function()end,showClient=function(payload) warning=payload;return true end}}
local publish=run("warning", {bootEnv=env})
local function publishCase(verified,reference)
    publish({state="restricted_mode",identityVerified=verified,
        notice={reason="Fixture",duration="permanent",reference=reference}})
    advance(now)
end
publishCase(false,"••••AB")
assert(not warning.description:find("Reference"))
publishCase(true,"BANNTOKEN_001122334455-00112233445#AABBCC")
assert(not warning.description:find("BANNTOKEN"))
publishCase(true,"••••AB")
assert(warning.description:find("Reference: ••••AB",1,true))
`);
});

test('Luau VM: ESLogin keeps its layout and automatically completes website pairing', () => {
 luau(String.raw`
local objects = {}
local function instance(class)
    local item = {ClassName=class,Activated=signal()}
    function item:Destroy() self.Parent=nil end
    function item:FindFirstChild(name)
        for _,child in ipairs(objects) do if child.Parent==self and child.Name==name then return child end end
    end
    function item:FindFirstChildOfClass(name)
        for _,child in ipairs(objects) do if child.Parent==self and child.ClassName==name then return child end end
    end
    function item:Clone()
        local copy=instance(self.ClassName)
        for key,value in pairs(self) do if key~='Activated' then copy[key]=value end end
        return copy
    end
    table.insert(objects,item)
    return item
end
local tuple=function(...) return {...} end
local root=instance('PlayerGui')
local copied,polls,done
local client={website='https://synthetic.test',begin=function() return {code='ABCDEF123456',expiresAt=10} end,
 poll=function(pair,remember) assert(pair.code=='ABCDEF123456' and remember); polls=(polls or 0)+1; if polls>1 then return {state='ready'} end return {state='pending'} end}
local enum=setmetatable({},{__index=function() return setmetatable({},{__index=function(_,k) return k end}) end})
local guiEnv={
 game={GetService=function(_,name) assert(name=='TweenService'); return {} end},
 Instance={new=instance},Enum=enum,UDim={new=tuple},UDim2={new=tuple},Vector2={new=tuple},
 Color3={new=tuple,fromRGB=tuple},ColorSequence={new=tuple},ColorSequenceKeypoint={new=tuple},
 NumberSequence={new=tuple},NumberSequenceKeypoint={new=tuple},typeof=function(v) return type(v)=='table' and 'Color3' or type(v) end,
 setclipboard=function(url) copied=url end,
}
runtime.task.spawn(function() done=run('accountUi',guiEnv,client,root,'session_expired') end)
advance(0)
local screen=assert(root:FindFirstChild('ESLoginGui'))
local main=screen:FindFirstChild('Main')
assert(main.Position[1]==0.5 and main.Size[1]==0.84 and main.BackgroundColor3[3]==52)
assert(main:FindFirstChild('Holder'):FindFirstChild('Logo').Image=='rbxassetid://120500539322715')
local inside=main:FindFirstChild('Inside')
assert(inside:FindFirstChild('Username').Text=='Username')
assert(inside:FindFirstChild('Password').Text=='Password')
assert(inside:FindFirstChild('Username').TextSize==18)
assert(inside:FindFirstChild('Password').TextSize==18)
assert(inside:FindFirstChild('UserInput').Text=='')
assert(inside:FindFirstChild('PassInput').Text=='')
assert(inside:FindFirstChild('PairingInput').Text=='')
assert(inside:FindFirstChild('UserInput').TextEditable==false)
assert(inside:FindFirstChild('SignInStatus').Text=='Session expired. Sign in again.')
assert(inside:FindFirstChild('PassInput').TextEditable==false)
local buttons=inside:FindFirstChild('Buttons')
buttons:FindFirstChild('Remember').Activated:Fire()
buttons:FindFirstChild('Login').Activated:Fire()
advance(0)
assert(inside:FindFirstChild('PairingInput').Text=='ABCDEF123456')
assert(copied==client.website)
advance(7)
assert(polls==2 and done and root:FindFirstChild('ESLoginGui')==nil)

local opened,lockedResult
local lockedClient={website=client.website,
    openWebsite=function(url) opened=url; return true end,
    begin=function() assert(opened==client.website); return nil,'account_qa_provisioning' end}
runtime.task.spawn(function() lockedResult=run('accountUi',guiEnv,lockedClient,root,'no_session') end)
advance(7)
local locked=assert(root:FindFirstChild('ESLoginGui')):FindFirstChild('Main')
local lockedInside=locked:FindFirstChild('Inside')
lockedInside:FindFirstChild('Buttons'):FindFirstChild('Login').Activated:Fire()
advance(7)
assert(opened==client.website and lockedInside:FindFirstChild('PairingInput').Text=='')
assert(lockedInside:FindFirstChild('SignInStatus').Text:find('STAGING sign-in is locked',1,true))
locked:FindFirstChild('Close').Activated:Fire()
advance(8)
assert(lockedResult==false and root:FindFirstChild('ESLoginGui')==nil)

local resumed
local savedClient={website=client.website,hasSession=function() return true end,
    refresh=function() return {id='saved-qa-profile'} end,
    begin=function() error('saved session must not start another pair') end}
runtime.task.spawn(function() resumed=run('accountUi',guiEnv,savedClient,root,'unavailable') end)
advance(8)
root:FindFirstChild('ESLoginGui'):FindFirstChild('Main'):FindFirstChild('Inside')
    :FindFirstChild('Buttons'):FindFirstChild('Login').Activated:Fire()
advance(9)
assert(resumed==true and root:FindFirstChild('ESLoginGui')==nil)

local manualEnv=table.clone(guiEnv)
manualEnv.setclipboard=nil
manualEnv.game={GetService=function(_,name)
    if name=='TweenService' then return {} end
    if name=='CoreGui' then error('CoreGui access denied') end
    assert(name=='Players')
    return {LocalPlayer={WaitForChild=function(_,child) assert(child=='PlayerGui');return root end}}
end}
local manualResult
local manualClient={website=client.website,begin=function()
    task.wait(2)
    return {code='ABCDEF123456',expiresAt=20}
end}
runtime.task.spawn(function() manualResult=run('accountUi',manualEnv,manualClient,nil,'no_session') end)
advance(9)
local manual=assert(root:FindFirstChild('ESLoginGui')):FindFirstChild('Main')
local manualInside=manual:FindFirstChild('Inside')
manualInside:FindFirstChild('Buttons'):FindFirstChild('Login').Activated:Fire()
assert(manualInside:FindFirstChild('SignInStatus').Text:find(client.website,1,true))
manual:FindFirstChild('Close').Activated:Fire()
advance(13)
assert(manualResult==false and root:FindFirstChild('ESLoginGui')==nil)

-- A tester-only UI cannot activate Remember even if a misleading client
-- method were to report persistence capability.
local testerResult
local testerClient={website=client.website,testerPreview=true,
 canRemember=function() return true end,
 begin=function() return nil,'tester_preview_only' end}
runtime.task.spawn(function()
 testerResult=run('accountUi',guiEnv,testerClient,root,'tester_preview_only')
end)
advance(13)
local tester=assert(root:FindFirstChild('ESLoginGui')):FindFirstChild('Main')
local testerInside=tester:FindFirstChild('Inside')
assert(testerInside:FindFirstChild('SignInStatus').Text:find('TESTER PREVIEW',1,true))
local testerRemember=testerInside:FindFirstChild('Buttons'):FindFirstChild('Remember')
assert(testerRemember.Interactable==false)
assert(testerRemember.Text=='Remember unavailable on this client')
tester:FindFirstChild('Close').Activated:Fire()
advance(14)
assert(testerResult==false and root:FindFirstChild('ESLoginGui')==nil)
`);
});

test('Luau VM: ESLogin sign-out hides the old Loader even if remote revocation fails',()=>{
 luau(String.raw`
local warned, notices, reopened, stopped, logoutCalls=0,0,0,0,0
local account={logged=true}
function account.hasSession() return account.logged end
function account.logout()
 logoutCalls+=1
 account.logged=false
 return false -- network outage: credential erased locally, remote revocation unconfirmed
end
function account.heartbeat() error('heartbeat should not run after shutdown') end
local state={__ASC_ACCOUNT_QA=account,__ASC_BAN_V2_CLIENT=account,
 ArcScriptPolicyGate={stop=function() stopped+=1 end}}
local screen={Visible=true}
local env={
 policyMode='account_qa',bootEnv=state,display=screen,displayProperty='Visible',
 accountLoginSource='qa-login-source',asrt={Parent=nil},
 warn=function(message) assert(message:find('revocation',1,true)); warned+=1 end,
 game={
  HttpGet=function(_,url) assert(url=='qa-login-source');return 'qa-script' end,
  GetService=function(_,name)
   assert(name=='StarterGui')
   return {SetCore=function(_,name,data)
    assert(name=='SendNotification')
    assert(data.Text:find('Server revocation could not be confirmed',1,true))
    notices+=1
   end}
  end,
 },
 loadstring=function(src)
  assert(src=='qa-script')
  return function(client) assert(client==account);reopened+=1;return false end
 end,
}
local signOut=run('signOut',env)
assert(type(signOut)=='function' and signOut()==true)
assert(logoutCalls==1 and not account.hasSession())
assert(state.__ASC_ACCOUNT_QA==nil and state.__ASC_BAN_V2_CLIENT==nil)
assert(screen.Visible==false and stopped==1 and warned==1 and notices==1)
advance(0)
assert(reopened==1,'sign-out must offer ESLogin again')
assert(signOut()==false,'repeat sign-out must not reopen the Loader')
`);
});

test('Luau VM: Gateway account policy, memory-only sessions, and logout', () => {
 luau(String.raw`
local values={}
local session=string.rep('a',64)
local status='restricted_mode'
local fail,cancelWhilePolling=false,false
local slowSession,remoteExpired=false,false
local accessRedirect=false
local revoked=0
local auth={
 getgenv=function() return {} end,
 game={GetService=function(_,name) assert(name=='HttpService'); return {
    JSONEncode=function(_,body) table.insert(values,body); return tostring(#values) end,
    JSONDecode=function(_,id) if id=='{}' then return {} end return assert(values[tonumber(id)]) end,
 } end},
 Instance={new=function(name) assert(name=='BindableEvent');local event=signal();return {Event=event,Fire=function() event:Fire() end,Destroy=function() end} end},
 request=function(r)
    local op=r.Url:match('/accounts/(.+)$')
    assert(r.Url:find('https://arcscriptcenter-eslogin-pairing-qa.kogpasan14.workers.dev/',1,true)==1)
    assert(r.Method=='POST' and r.Headers.Origin==nil and r.Headers.Cookie==nil)
    local v={ok=true}
    if op=='pair/start' then
        if accessRedirect then return {StatusCode=302,Body=''} end
        assert(r.Headers.Authorization==nil); v.code='ABCDEF123456'; v.secret=session; v.expiresAt=100
    elseif op=='pair/poll' then
        assert(values[tonumber(r.Body)].remember==nil)
        if cancelWhilePolling then runtime.task.wait(2) end
        v.session=session; v.state='ready'; v.expiresAt=100
    else
        assert(r.Headers.Authorization=='Bearer '..session)
        if fail then error('Synthetic network error') end
        if op=='session' and slowSession then runtime.task.wait(10) end
        if op=='session' and remoteExpired then
            table.insert(values,{ok=false,code='session_expired'})
            return {StatusCode=401,Body=tostring(#values)}
        end
        if op~='logout' then v.account={id='account-qa',nickname='Synthetic',status=status} else revoked+=1 end
    end
    table.insert(values,v)
    return {StatusCode=200,Body=tostring(#values)}
 end,
 writefile=function() error('must never write credentials') end,
 readfile=function() error('must never read credentials') end,

}
local progress=0
runtime.task.spawn(function()
    local c=run('accountClient',auth)
    assert(not c.hasSession() and c.refresh()==nil)
    assert(c.poll(assert(c.begin()),true).saved==false and not c.canRemember())
    assert(not run('accountClient',auth).hasSession(),'rejoin starts without a credential')
    assert(not c.hasPrivateCaseChannel() and c.history()==nil)
    assert(c.policy().state=='restricted_mode')
    status='banned'; assert(c.policy().state=='ban_ingame')
    status='normal'; assert(c.policy().state=='clear')
    accessRedirect=true
    local denied,why=c.begin()
    assert(not denied and why=='access_required')
    accessRedirect=false
    fail=true
    assert(c.policy()==nil and c.hasSession() and c.profile()==nil)
    assert(c.logout()==false and not c.hasSession())
    fail=false
    assert(c.poll(assert(c.begin()),false).state=='ready')
    assert(c.logout() and revoked==1)
    cancelWhilePolling=true
    local open=true
    local pair=assert(c.begin())
    runtime.task.delay(1,function() open=false end)
    local result,reason=c.poll(pair,true,function() return open end)
    assert(not result and reason=='cancelled' and not c.hasSession() and revoked==2)
    cancelWhilePolling=false
    assert(c.poll(assert(c.begin()),false).state=='ready')
    slowSession=true
    local profile,reason=c.refresh()
    assert(profile==nil and reason=='unavailable' and c.profile()==nil and c.hasSession())
    runtime.task.wait(3)
    assert(c.profile()==nil)
    slowSession=false
    assert(c.refresh())
    remoteExpired=true
    profile,reason=c.refresh()
    assert(not profile and reason=='session_expired' and not c.hasSession())
    progress=1
end)
advance(30)
assert(progress==1)
`);
});

test('Luau VM: Account QA bootstrap shows ESLogin, stops on X, and skips it only for a verified session',()=>{
 luau(String.raw`
local global={}
local launches=0
local mode
local account={}
function account.refresh()
    if mode=='saved' then return {id='verified'} end
    return nil,'no_session'
end
function account.profile()
    return mode=='paired' and {id='verified'} or nil
end
local env={
    getgenv=function() return global end,
    game={HttpGet=function(_,url)
        if url:match('/ESLogin%.lua$') then return 'login-source' end
        if url:match('/ASCAccountClientPreview%.lua$') then return 'account-source' end
        error('Unexpected URL')
    end},
    loadstring=function(source)
        if source=='account-source' then return function() return account end end
        assert(source=='login-source')
        return function(client,parent,reason)
            assert(client==account and parent==nil and reason=='no_session')
            launches+=1
            return mode~='closed'
        end
    end,
}
mode='closed'
assert(run('boot',env,'account_qa')==nil and launches==1)
assert(global.__ES_BOOTSTRAP_BUSY==nil and global.__ASC_ACCOUNT_QA==nil)
mode='unverified'
assert(run('boot',env,'account_qa')==nil and launches==2)
assert(global.__ASC_BAN_V2_CLIENT==nil and global.__ES_BOOTSTRAP_BUSY==nil)
mode='paired'
assert(run('boot',env,'account_qa')=='account_qa' and launches==3)
assert(global.__ASC_ACCOUNT_QA==account and global.__ASC_BAN_V2_CLIENT==account)
table.clear(global)
mode='saved'
assert(run('boot',env,'account_qa')=='account_qa' and launches==3)
assert(global.__ASC_ACCOUNT_QA==account and global.__ASC_BAN_V2_CLIENT==account)
`);
});

test('Luau VM: tester identity gates a UI-only ESLogin and never authenticates or continues Loader',()=>{
 luau(String.raw`
local player={UserId=0}
local loads=0
local uiOpened=0
local env={
 game={
  GetService=function(_,name)
   assert(name=='Players')
   return {LocalPlayer=player}
  end,
  HttpGet=function(_,url)
   loads+=1
   assert(url:match('/ESLogin%.lua$'))
   return 'tester-ui-source'
  end,
 },
 loadstring=function(source)
  assert(source=='tester-ui-source')
  return function(client,parent,reason)
   uiOpened+=1
   assert(parent==nil and reason=='tester_preview_only')
   assert(client.testerPreview==true and client.accountMode==false)
   assert(client.website:match('/signin$'))
   assert(client.canRemember()==false and client.hasSession()==false)
   assert(client.refresh()==nil and client.profile()==nil)
   local pair,why=client.begin()
   assert(pair==nil and why=='tester_preview_only')
   local ok=pcall(client.poll)
   assert(ok==false,'no pairing is permitted')
   return true -- even a fake successful UI return must not unlock Loader.
  end
 end,
}
assert(run('testerUi',env)==false)
assert(loads==0 and uiOpened==0,'non-testers cannot load ESLogin')
player.UserId=8728964745
assert(run('testerUi',env)==false)
assert(loads==1 and uiOpened==1,'tester sees one mock GUI and no account auth')
local entryLoads=0
local entryEnv={
 game={HttpGet=function(_,url)
  entryLoads+=1
  assert(url:match('/LoaderMainPreview%.lua$'))
  return 'main-source'
 end},
 loadstring=function(source)
  assert(source=='main-source')
  return function(mode)
   assert(mode=='account_qa_tester')
   return false
  end
 end,
}
assert(run('testerEntry',entryEnv)==false and entryLoads==1)
`);
});

test('Luau VM: Roblox HTTP Access responses are fail-closed without browser cookies',()=>{
 luau(String.raw`
local accessChallenge = run('accountAccessChallenge', {})
assert(accessChallenge({Headers={}}, 302, '') == true, '302 must stop at Access')
assert(accessChallenge({Headers={Location='https://qa.cloudflareaccess.com/cdn-cgi/access/login/'}}, 200, '') == true, 'followed Access redirect must be rejected')
assert(accessChallenge({Headers={}}, 200, '<!doctype html><title>Cloudflare Access - Sign in</title>') == true, 'Access HTML must not be treated as account JSON')
assert(accessChallenge({headers={}}, 403, '<html>please sign in to qa.cloudflareaccess.com</html>') == true, 'Access denial HTML must be rejected')
assert(accessChallenge({Headers={}}, 200, '{"ok":true,"account":{"id":"fake"}}') == false, 'Normal JSON is not Access HTML')
assert(accessChallenge({Headers={}}, 401, '{"ok":false,"code":"session_expired"}') == false, 'Normal API session errors are distinct from Access')
assert(accessChallenge({Headers={}}, 503, '<html>Temporary outage</html>') == false, 'Unrelated HTML is not falsely authenticated as Access')
assert(accessChallenge({Headers={}}, 303, nil) == true, 'Redirect cannot become an account session')
`);
});
