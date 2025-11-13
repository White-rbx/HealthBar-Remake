-- loadstringChecker_enhanced.lua
-- Enhanced loadstring inspector (executor LocalScript)
-- Features: Info/Warning/Error lists, optional follow-links, language heuristics,
-- improved Instance/Function detection, auto-summary, stores results to _G.LastLoadstringCheckFull

-- 

-- ========== CONFIG ==========
local url = "" -- <<< ใส่ RAW file URL ที่จะตรวจสอบ
local PREVIEW = false
local PREVIEW_LINES = 2000
local RUN_FULL_AFTER_PREVIEW = false
local SHOW_LINES_LIMIT = 40000
local AUTO_EXECUTE = false
local CONTEXT_LINES = 8
local PROGRESS_INTERVAL = 2000
local YIELD_PER_LINE = true

-- Follow linked scripts (may fetch external files). Use with caution.
local FOLLOW_LINKS = false
local MAX_FOLLOW_LINKS = 6
local MAX_FOLLOW_DEPTH = 2

-- thresholds
local MAX_PRINT_LINES = SHOW_LINES_LIMIT

-- ========== helpers ==========
local function info(...) pcall(print, "[CHECKER][INFO]", table.concat({...}, " ")) end
local function warnInfo(...) pcall(warn, "[CHECKER][WARN]", table.concat({...}, " ")) end
local function errInfo(...) pcall(warn, "[CHECKER][ERROR]", table.concat({...}, " ")) end

if not url or url == "" then
    warnInfo("ERROR: url is empty. Set url to the raw file you want to inspect.")
    return
end

local tick0 = tick()
info("Starting enhanced loadstring checker. url=", url)

-- safe httpget
local function safeHttpGet(u)
    local ok, res = pcall(function() return game:HttpGet(u) end)
    if ok then return true, tostring(res) else return false, tostring(res) end
end

-- quick heuristics to detect file-language
local function detectLanguage(sample)
    sample = sample:lower()
    -- HTML
    if sample:find("<!doctype") or sample:find("<html") or sample:find("<body") then return "html" end
    -- JS (browser/node)
    if sample:find("console%.log") or sample:find("document%.") or sample:find("window%.") or sample:find("var%s+") or sample:find("let%s+") then return "javascript" end
    -- Python
    if sample:find("^%s*def%s+") or sample:find("^%s*import%s+") or sample:find("print%(") and sample:find(":$") == nil then return "python" end
    -- Lua-ish heuristics (Luau)
    local luakey = 0
    for _,k in ipairs({"local%s+function","local%s+%w+%s*=","function%s+%w+%s*%(","end%s*$","then%s*$"}) do
        if sample:find(k) then luakey = luakey + 1 end
    end
    if luakey >= 2 then return "luau" end
    -- fallback: unknown
    return "unknown"
end

-- extract urls from a line (very permissive)
local function extractUrls(line)
    local urls = {}
    for u in line:gmatch("https?://[%w_%%&%?%-%.:/=#]+") do
        table.insert(urls, u)
    end
    return urls
end

-- token patterns (extended)
local tokenPatterns = {
    loadstring = "%f[%w]loadstring%f[%W]",
    load = "%f[%w]load%f[%W]",
    dofile = "%f[%w]dofile%f[%W]",
    require = "%f[%w]require%f[%W]",
    HttpGet = "%f[%w]HttpGet%f[%W]",
    gameHttpGet = "game%s*:%s*HttpGet",
    xpcall = "%f[%w]xpcall%f[%W]",
    pcall = "%f[%w]pcall%f[%W]",
    coroutine = "%f[%w]coroutine%f[%W]",
    task_spawn = "%f[%w]task%.spawn%f[%W]",
    spawn = "%f[%w]spawn%f[%W]",
    setmetatable = "%f[%w]setmetatable%f[%W]",
    getfenv = "%f[%w]getfenv%f[%W]",
    debug = "%f[%w]debug%f[%W]",
    XMLHttp = "XMLHttpRequest",
    Instance_new = "Instance%.new%s*%(",
    WaitForChild = "%:WaitForChild%(",
    FindFirstChild = "%:FindFirstChild%(",
    GetService = "%:GetService%(",
    CoreGui = "%f[%w]CoreGui%f[%W]",
}

-- analysis containers
local counts = {}
local totalLocalDeclLines = 0
local totalLocalVars = 0
local totalFunctionDefs = 0
local topFunctions = {}
local funcStack = {}
local inBlockComment = false
local instanceTypes = {}
local instancesCount = 0
local infoList, warnList, errorList = {}, {}, {}
local linksFound = {}
local urlsToFollow = {}

-- helpers for function frames
local function pushFunc(name, ln)
    totalFunctionDefs = totalFunctionDefs + 1
    local f = { name = name or ("<anon@"..ln..">"), startLine = ln, endLine = nil, locals = 0, localDeclLines = 0 }
    table.insert(funcStack, f)
    return f
end
local function popFunc(ln)
    local f = table.remove(funcStack)
    if not f then return end
    f.endLine = ln
    table.insert(topFunctions, f)
    return f
end

local function addToken(k, n) counts[k] = (counts[k] or 0) + (n or 1) end
local function pushInfo(s) table.insert(infoList, s) end
local function pushWarn(s) table.insert(warnList, s) end
local function pushErr(s) table.insert(errorList, s) end

-- parse local var left side to count vars
local function countLocalVars(decl)
    local left = decl:match("^%s*local%s+(.+)$") or ""
    left = left:match("^(.-)%s*=") or left
    left = left:gsub("%b()", "") -- strip parentheses
    local cnt = 0
    for v in left:gmatch("[^,]+") do
        if v:match("%S") then cnt = cnt + 1 end
    end
    return cnt
end

local function extractFunctionName(line)
    local name = line:match("^%s*local%s+function%s+([%w_%.:]+)")
    if name then return name end
    name = line:match("^%s*function%s+([%w_%.:]+)%s*%(")
    if name then return name end
    name = line:match("^%s*local%s+([%w_]+)%s*=%s*function%s*%(")
    if name then return name end
    return nil
end

-- download main URL
local ok, body_or_err = safeHttpGet(url)
if not ok then
    pushErr("HttpGet failed: "..tostring(body_or_err))
    return
end
local src = tostring(body_or_err)
if not src or #src == 0 then
    pushWarn("Downloaded source is empty.")
    return
end
info("Downloaded bytes:", #src)

-- split into lines
local lines = {}
for ln in src:gmatch("([^\n]*)\n?") do table.insert(lines, ln) end
local totalLines = #lines
info("Total lines in remote script:", totalLines)

-- decide scan range
local scanFrom, scanTo = 1, totalLines
if PREVIEW then
    scanTo = math.min(PREVIEW_LINES, totalLines)
    info("Preview mode: scanning lines 1.." .. tostring(scanTo))
end

-- scanning loop
local t0_scan = tick()
info("Beginning enhanced scan of lines", scanFrom, "to", scanTo)
for i = scanFrom, scanTo do
    if YIELD_PER_LINE then task.wait(0) end
    local raw = lines[i] or ""
    local line = raw

    -- handle block comments
    if inBlockComment then
        local s,e = line:find("%]%]")
        if s then
            line = line:sub(e+1)
            inBlockComment = false
        else
            line = ""
        end
    end
    local startBlock = line:find("%-%-%[%[")
    if startBlock then
        local s,e = line:find("%]%]", startBlock+4)
        if s then
            line = line:sub(1, startBlock-1) .. (line:sub(e+1) or "")
        else
            line = line:sub(1, startBlock-1)
            inBlockComment = true
        end
    end

    -- strip inline comments
    local stripped = line:gsub("%-%-.*$", "")

    -- token counts
    for k,pat in pairs(tokenPatterns) do
        if stripped:find(pat) then addToken(k) end
    end

    -- Instance.new detection with class literal
    for cls in stripped:gmatch('Instance%.new%s*%(%s*["\']([%w_%:%.%-]+)["\']%s*%)') do
        instancesCount = instancesCount + 1
        instanceTypes[cls] = (instanceTypes[cls] or 0) + 1
    end
    if stripped:find("Instance%.new") then
        instancesCount = instancesCount + 0 -- mark presence
    end

    -- find URLs
    local ulist = extractUrls(stripped)
    if #ulist > 0 then
        for _,u in ipairs(ulist) do
            linksFound[u] = (linksFound[u] or 0) + 1
            table.insert(urlsToFollow, {url=u, line=i})
        end
    end

    -- detect loadstring(game:HttpGet("...")) and variants
    local lsurl = stripped:match('loadstring%s*%(%s*game%s*:%s*HttpGet%s*%(%s*["\']([^"\']+)["\']%s*%)%s*%)')
    if lsurl then
        addToken("loadstring_httpget") 
        pushWarn(("Found loadstring(game:HttpGet(...)) referencing %s at line %d"):format(lsurl, i))
        table.insert(urlsToFollow, {url=lsurl, line=i})
    end

    -- detect plain game:HttpGet("URL") usage
    for u in stripped:gmatch('game%s*:%s*HttpGet%s*%(%s*["\']([^"\']+)["\']%s*%)') do
        addToken("gameHttpGet")
        pushInfo(("Found game:HttpGet referencing %s at line %d"):format(u, i))
        table.insert(urlsToFollow, {url=u, line=i})
    end

    -- function detection
    if stripped:find("%f[%w]function%f[%W]") then
        local fname = extractFunctionName(stripped)
        pushFunc(fname, i)
    end

    -- local declarations
    if stripped:find("^%s*local%s+") then
        local vars = countLocalVars(stripped)
        totalLocalDeclLines = totalLocalDeclLines + 1
        totalLocalVars = totalLocalVars + vars
        if #funcStack > 0 then
            local top = funcStack[#funcStack]
            top.locals = top.locals + vars
            top.localDeclLines = top.localDeclLines + 1
        end
    end

    -- balance ends
    local ends = 0
    for _ in stripped:gmatch("%f[%w]end%f[%W]") do ends = ends + 1 end
    for _ = 1, ends do
        if #funcStack > 0 then popFunc(i) end
    end

    -- quick suspicious patterns -> warnings/errors
    if stripped:find("setfenv") or stripped:find("getfenv") or stripped:find("debug%.") then
        pushWarn(("Suspicious environment/debug usage at line %d"):format(i))
    end
    if stripped:find("CoreGui") and stripped:find("Parent%s*:=") then
        pushWarn(("Possible CoreGui parent change at line %d"):format(i))
    end
    if stripped:find("Instance%.new%s*%(%s*['\"]Sound['\"]%s*%)") and stripped:find("SoundId") then
        pushInfo(("Sound instance creation detected at line %d"):format(i))
    end

    -- progress logs
    if PROGRESS_INTERVAL > 0 and (i % PROGRESS_INTERVAL) == 0 then
        info(("Scanned %d/%d lines..."):format(i, scanTo))
    end
end

local t1_scan = tick()
info("Scan phase completed in", string.format("%.3f", t1_scan - t0_scan), "seconds")

-- post-scan: close any open func frames
while #funcStack > 0 do popFunc(totalLines) end

-- print preview / content (streamed)
local printLimit = math.min(totalLines, MAX_PRINT_LINES)
info(("Printing script lines 1..%d (limit=%d)."):format(printLimit, MAX_PRINT_LINES))
local t0_print = tick()
for i = 1, printLimit do
    if YIELD_PER_LINE then task.wait(0) end
    pcall(print, string.format("%6d: %s", i, lines[i] or ""))
end
local t1_print = tick()
info("Printing phase completed in", string.format("%.3f", t1_print - t0_print), "seconds")

-- follow links optionally (shallow, limited)
local followed = {}
local followedCount = 0
local function followUrls(list, depth)
	if not FOLLOW_LINKS then return end
	depth = depth or 1
	if depth > MAX_FOLLOW_DEPTH then return end
	for _, entry in ipairs(list) do
		if followedCount >= MAX_FOLLOW_LINKS then break end
		local u = entry.url
		if not u or followed[u] then continue end  -- ✅ ใช้ continue แทน goto

		local ok2, body = safeHttpGet(u)
		if not ok2 then
			pushWarn(("Failed to fetch linked URL %s (source line %d): %s"):format(u, entry.line or -1, body))
			followed[u] = true
			followedCount = followedCount + 1
			continue  -- ✅ แทน goto อีกที่
		end

		local lang = detectLanguage((body:sub(1,800) or ""))
		pushInfo(("Followed URL %s (from line %d) -> detected language: %s / bytes: %d"):format(u, entry.line or -1, lang, #body))
		followed[u] = true
		followedCount = followedCount + 1
		table.insert(followed, {url=u, lang=lang, bytes=#body})

		-- if it's a Lua-like file and contains loadstring/game:HttpGet, optionally add to urlsToFollow next depth
		if (lang == "luau" or lang == "unknown") then
			for ls in body:gmatch('game%s*:%s*HttpGet%s*%(%s*["\']([^"\']+)["\']%s*%)') do
				table.insert(urlsToFollow, {url=ls, line = entry.line})
			end
		end
	end
end

if FOLLOW_LINKS and #urlsToFollow > 0 then
    followUrls(urlsToFollow, 1)
end

-- summary & scoring
local summary = {
    total_lines = totalLines,
    scanned_lines = (scanTo - scanFrom + 1),
    local_decl_lines = totalLocalDeclLines,
    local_variables = totalLocalVars,
    function_defs = #topFunctions,
    instance_new_literal_types = instanceTypes,
    instance_new_total_literals = 0,
    token_counts = counts,
    scan_time = t1_scan - t0_scan,
    print_time = t1_print - t0_print,
}
for k,v in pairs(instanceTypes) do summary.instance_new_total_literals = summary.instance_new_total_literals + v end

-- danger scoring (improved weights)
local score = 0
local weights = {
    loadstring = 35,
    loadstring_httpget = 45,
    gameHttpGet = 20,
    HttpGet = 12,
    require = 8,
    debug = 40,
    getfenv = 40,
    setmetatable = 6,
    XMLHttp = 60,
    Coroutine = 4,
    task_spawn = 3,
    spawn = 6,
    Instance_new = 1,
    Instance_risky_classes = 8,
}

for k,v in pairs(counts) do
    local w = weights[k] or 1
    score = score + (w * v)
end
if summary.local_variables > 400 then score = score + 40 end
for _,f in ipairs(topFunctions) do
    if f.locals >= 150 then score = score + 50 end
end

local level = "[ Peaceful ]"; local level_key = "peaceful"
if score < 20 then level = "[ Peaceful ]"; level_key = "peaceful"
elseif score < 60 then level = "[ Low ]"; level_key = "low"
elseif score < 150 then level = "[ Mid ]"; level_key = "mid"
elseif score < 300 then level = "[ High ]"; level_key = "high"
elseif score < 600 then level = "[ Insane ]"; level_key = "insane"
else level = "[ Danger ]"; level_key = "danger"
end

info("Danger heuristic score:", score, "Level:", level)

if level_key == "high" or level_key == "insane" or level_key == "danger" then
    pushWarn("AUTORUN DENIED: Threat level is "..level.." - DO NOT EXECUTE automatically.")
else
    pushInfo("Threat level "..level..". Script may be executed manually if you trust the source.")
end

-- attempt compilation (detect parse errors)
local t0_compile = tick()
local chunk, compileErr = loadstring(src)
local t1_compile = tick()
info("Compile attempt time:", string.format("%.3f", t1_compile - t0_compile), "seconds")
if not chunk then
    pushErr("Compile error: "..tostring(compileErr))
    local lineno = tonumber(compileErr:match("%[string \"[^\"]*\"%]:(%d+):")) or tonumber(compileErr:match(":(%d+):"))
    if lineno then
        pushWarn(("Compile error appears at line %d; showing context +/- %d"):format(lineno, CONTEXT_LINES))
        local startL = math.max(1, lineno - CONTEXT_LINES)
        local endL = math.min(totalLines, lineno + CONTEXT_LINES)
        for j = startL, endL do
            local mark = (j == lineno) and ">>" or "  "
            pcall(print, string.format("%s %6d: %s", mark, j, lines[j] or ""))
        end
    end
else
    pushInfo("No compile-time parse errors detected.")
end

-- print categorized messages (limited)
info("===== MESSAGES (Info/Warning/Error) =====")
for _,m in ipairs(infoList) do info("[I]", m) end
for _,m in ipairs(warnList) do warnInfo("[W]", m) end
for _,m in ipairs(errorList) do errInfo("[E]", m) end

-- top tokens
info("Token/API counts (top):")
local toklist = {}
for k,v in pairs(counts) do table.insert(toklist, {k=k,v=v}) end
table.sort(toklist, function(a,b) return a.v > b.v end)
for _,t in ipairs(toklist) do info(string.format("  %-18s : %d", t.k, t.v)) end

info("Top functions by local variable count (approx):")
table.sort(topFunctions, function(a,b) return a.locals > b.locals end)
for i=1, math.min(12, #topFunctions) do
    local f = topFunctions[i]
    info(string.format(" %2d) %s  locals=%d  localDeclLines=%d  range=%d-%d",
        i, tostring(f.name), f.locals, f.localDeclLines, f.startLine, f.endLine))
end

-- store results
_G.LastLoadstringCheckFull = {
    url = url,
    summary = summary,
    top_functions = topFunctions,
    score = score,
    level = level,
    canRun = (level_key ~= "high" and level_key ~= "insane" and level_key ~= "danger"),
    compile_error = compileErr,
    scanned_range = { from = scanFrom, to = scanTo },
    printed_lines = printLimit,
    timings = { scan = t1_scan - t0_scan, print = t1_print - t0_print, compile = t1_compile - t0_compile, total = tick() - tick0 },
    messages = { info = infoList, warn = warnList, error = errorList },
    links_followed = followed,
}

info("Results stored in _G.LastLoadstringCheckFull")
info("Completed Time (total):", string.format("%.3f", tick() - tick0), "seconds")
-- End
