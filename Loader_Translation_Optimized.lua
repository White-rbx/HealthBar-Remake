--// =====================================================
--// TEXT-DETECTION LOCALIZATION ENGINE v2 (OPTIMIZED)
--// Enhanced performance and accurate dynamic text matching
--// =====================================================

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local ExperienceSettings

local CurrentLanguage = "EN"
local SelectedLanguage = "EN"
local latestClick = "EN"
local TranslationBusy = false
local TranslationCooldown = 2
local LastApiRequest = 0

local TranslationCacheFile =
    "ExperienceSettings/translation_cache.json"

-- Local-only translation mode.
-- No external translation provider is used.
local REMOTE_CACHE_URL = nil

local HTTP_REQUEST =
    request
    or http_request
    or (syn and syn.request)

local LanguageButtons = {}
local RefreshLanguageButtons

local TranslationSource =
    setmetatable({}, {__mode = "k"})

local TranslationApplied =
    setmetatable({}, {__mode = "k"})

local TranslationConnections =
    setmetatable({}, {__mode = "k"})

local TranslationCache = {
    ["EN"] = {},
    ["ES"] = {},
    ["TH"] = {},
    ["PT-BR"] = {},
    ["PT-PT"] = {},
    ["RU"] = {},
    ["KO"] = {},
}

local TranslationDB = {
    ["ES"] = {
        ["Type /Help to show all commands or Say something..."] = "Escribe /Help para mostrar todos los comandos o di algo...",
        ["Confirm API"] = "Confirmar API",
        ["Unsaved API"] = "API no guardada",
        ["[ Your API here (ChatGPT or Gemini) ]"] = "[ Tu API aquí (ChatGPT o Gemini) ]",
        ["Status: No key"] = "Estado: Sin clave",
        ["Hide"] = "Ocultar",
        ["Leave"] = "Salir",
        ["Reset character"] = "Reiniciar personaje",
        ["Resume"] = "Continuar",
        ["Open Roblox Settings"] = "Abrir configuración de Roblox",
        ["Player :"] = "Jugador :",
        ["Enable ValueLabels"] = "Activar ValueLabels",
        ["Enable HealthBar"] = "Activar HealthBar",
        ["Disable Death Sound"] = "Desactivar sonido de muerte",
        ["Loading"] = "Cargando",
        ["Starting ExperienceSettings. Please wait..."] = "Iniciando ExperienceSettings. Por favor espera...",
    },
    ["TH"] = {
        ["Type /Help to show all commands or Say something..."] = "พิมพ์ /Help เพื่อดูคำสั่งทั้งหมด หรือพิมพ์อะไรสักอย่าง...",
        ["Confirm API"] = "ยืนยัน API",
        ["Unsaved API"] = "API ยังไม่บันทึก",
        ["Status: No key"] = "สถานะ: ไม่มีคีย์",
        ["Hide"] = "ซ่อน",
        ["Leave"] = "ออก",
        ["Reset character"] = "รีเซ็ตตัวละคร",
        ["Resume"] = "กลับเข้าเกม",
        ["Enable ValueLabels"] = "เปิด ValueLabels",
        ["Enable HealthBar"] = "เปิด HealthBar",
        ["Disable Death Sound"] = "ปิดเสียงตาย",
        ["Loading"] = "กำลังโหลด",
    },
    ["PT-BR"] = {
        ["Type /Help to show all commands or Say something..."] = "Digite /Ajuda para ver todos os comandos ou diga algo...",
        ["Confirm API"] = "Confirmar API",
        ["Unsaved API"] = "API não salva",
        ["Status: No key"] = "Status: Sem chave",
        ["Hide"] = "Ocultar",
        ["Leave"] = "Sair",
        ["Reset character"] = "Resetar personagem",
        ["Resume"] = "Continuar",
        ["Enable ValueLabels"] = "Ativar ValueLabels",
        ["Enable HealthBar"] = "Ativar HealthBar",
        ["Disable Death Sound"] = "Desativar som de morte",
        ["Loading"] = "Carregando",
    },
    ["PT-PT"] = {
        ["Type /Help to show all commands or Say something..."] = "Escreve /Ajuda para ver todos os comandos ou diz algo...",
        ["Confirm API"] = "Confirmar API",
        ["Unsaved API"] = "API não guardada",
        ["Status: No key"] = "Estado: Sem chave",
        ["Hide"] = "Ocultar",
        ["Leave"] = "Sair",
        ["Reset character"] = "Reiniciar personagem",
        ["Resume"] = "Continuar",
        ["Enable ValueLabels"] = "Ativar ValueLabels",
        ["Enable HealthBar"] = "Ativar HealthBar",
        ["Disable Death Sound"] = "Desativar som de morte",
        ["Loading"] = "A carregar",
    },
    ["RU"] = {
        ["Type /Help to show all commands or Say something..."] = "Введите /Help, чтобы показать все команды, или напишите что-нибудь...",
        ["Confirm API"] = "Подтвердить API",
        ["Unsaved API"] = "API не сохранён",
        ["Status: No key"] = "Статус: нет ключа",
        ["Hide"] = "Скрыть",
        ["Leave"] = "Выйти",
        ["Reset character"] = "Сбросить персонажа",
        ["Resume"] = "Продолжить",
        ["Enable ValueLabels"] = "Включить ValueLabels",
        ["Enable HealthBar"] = "Включить HealthBar",
        ["Disable Death Sound"] = "Отключить звук смерти",
        ["Loading"] = "Загрузка",
    },
    ["KO"] = {
        ["Type /Help to show all commands or Say something..."] = "모든 명령을 보려면 /Help를 입력하거나 아무 말이나 해보세요...",
        ["Confirm API"] = "API 확인",
        ["Unsaved API"] = "저장되지 않은 API",
        ["Status: No key"] = "상태: 키 없음",
        ["Hide"] = "숨기기",
        ["Leave"] = "나가기",
        ["Reset character"] = "캐릭터 초기화",
        ["Resume"] = "계속하기",
        ["Enable ValueLabels"] = "ValueLabels 활성화",
        ["Enable HealthBar"] = "HealthBar 활성화",
        ["Disable Death Sound"] = "죽음 소리 비활성화",
        ["Loading"] = "로딩 중",
    },
}

-- Import the static TranslationDB.
for language, entries in pairs(TranslationDB) do
    for sourceText, translatedText in pairs(entries) do
        TranslationCache[language][sourceText] = translatedText
    end
end

--// =====================================================
--// IMPROVED TEXT PROTECTION & RESTORATION
--// =====================================================

local function SelectTextToTranslateOnly(text)
    local source = tostring(text or "")
    local protected = {}
    local counter = 0

    local function protect(value)
        counter += 1
        protected[counter] = value
        return string.format("__DYNAMIC_%d__", counter)
    end

    -- Protect HTML tags
    source = source:gsub("<[^>]+>", function(tag)
        return protect(tag)
    end)

    -- Protect URLs
    source = source:gsub("https?://%S+", function(value)
        return protect(value)
    end)

    -- Protect Roblox asset IDs
    source = source:gsub("rbxassetid://%d+", function(value)
        return protect(value)
    end)

    -- Protect mentions
    source = source:gsub("@[%w_]+", function(value)
        return protect(value)
    end)

    -- Protect common placeholders
    source = source:gsub("%f[%a](VER|COUNT|DATE|TIME|ASIX|ENUM|RIGTYPE|ITEM|MATERIAL|NUM|NAME|ID|AMOUNT)%f[%A]", function(value)
        return protect(value)
    end)

    -- Protect numbers and percentages
    source = source:gsub("[%+%-]?%d[%d,%.]*%%?", function(value)
        return protect(value)
    end)

    return source, protected
end

local function RestoreSelectedText(text, protected)
    local result = tostring(text or "")

    for index = #protected, 1, -1 do
        local token = string.format("__DYNAMIC_%d__", index)
        result = result:gsub(token, function()
            return protected[index]
        end, 1)
    end

    return result
end

--// =====================================================
--// OPTIMIZED DYNAMIC TEMPLATE MATCHING
--// =====================================================

local function MatchDynamicTemplate(template, text)
    template = tostring(template or "")
    text = tostring(text or "")

    if template == text then
        return {}  -- Exact match
    end

    -- Parse template to find dynamic placeholders
    local parts = {}
    local lastPos = 1

    for startPos, endPos, index in template:gmatch("()__DYNAMIC_(%d+)__()") do
        -- Add static part before this dynamic
        if startPos > lastPos then
            table.insert(parts, {
                type = "static",
                value = template:sub(lastPos, startPos - 1)
            })
        end

        -- Add dynamic part
        table.insert(parts, {
            type = "dynamic",
            index = tonumber(index)
        })

        lastPos = endPos
    end

    -- Add remaining static part
    if lastPos <= #template then
        table.insert(parts, {
            type = "static",
            value = template:sub(lastPos)
        })
    end

    -- If no dynamics found, exact match required
    if #parts == 0 then
        return nil
    end

    -- Try to match text against parts
    local textPos = 1
    local capturedValues = {}

    for i, part in ipairs(parts) do
        if part.type == "static" then
            local staticLen = #part.value
            if text:sub(textPos, textPos + staticLen - 1) ~= part.value then
                return nil  -- Mismatch
            end
            textPos = textPos + staticLen
        else
            -- Find next static part (or end of string)
            local endOfDynamic = #text + 1

            for j = i + 1, #parts do
                if parts[j].type == "static" then
                    local nextStaticPos = text:find(parts[j].value, textPos, true)
                    if nextStaticPos then
                        endOfDynamic = nextStaticPos
                    end
                    break
                end
            end

            if endOfDynamic > #text + 1 then
                endOfDynamic = #text + 1
            end

            local captured = text:sub(textPos, endOfDynamic - 1)
            capturedValues[part.index] = captured
            textPos = endOfDynamic
        end
    end

    return capturedValues
end

--// =====================================================
--// TRANSLATION STATE MANAGEMENT
--// =====================================================

local TranslationState = setmetatable({}, {__mode = "k"})

local function GetState(obj, property)
    TranslationState[obj] = TranslationState[obj] or {}
    TranslationState[obj][property] = TranslationState[obj][property] or {}
    return TranslationState[obj][property]
end

local function BuildSourceState(obj, property, sourceText)
    local state = GetState(obj, property)

    local template, protected = SelectTextToTranslateOnly(sourceText)

    state.SourceTemplate = template
    state.DynamicValues = protected
    state.SourceText = RestoreSelectedText(template, protected)

    return state
end

local function GetStateTranslation(state, language)
    if not state or not state.SourceTemplate or state.SourceTemplate == "" then
        return nil
    end

    if language == "EN" then
        return RestoreSelectedText(
            state.SourceTemplate,
            state.DynamicValues or {}
        )
    end

    local translatedTemplate =
        TranslationCache[language]
        and TranslationCache[language][state.SourceTemplate]

    if not translatedTemplate then
        return nil
    end

    return RestoreSelectedText(
        translatedTemplate,
        state.DynamicValues or {}
    )
end

--// =====================================================
--// UTILITY FUNCTIONS
--// =====================================================

local function IsTranslationSkipped(obj)
    local current = obj

    while current do
        if current:GetAttribute("SkipAutoTranslate") == true then
            return true
        end

        if current == ExperienceSettings then
            break
        end

        current = current.Parent
    end

    return false
end

local function SaveTranslationCache()
    if not writefile then
        return false
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode({
            Version = 2,
            Languages = TranslationCache
        })
    end)

    if not ok then
        return false
    end

    local saveOk = pcall(function()
        if not isfolder("ExperienceSettings") then
            makefolder("ExperienceSettings")
        end
        writefile(TranslationCacheFile, encoded)
    end)

    return saveOk
end

local function LoadTranslationCache()
    if not readfile or not isfile or not isfile(TranslationCacheFile) then
        return
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(TranslationCacheFile))
    end)

    if not ok or type(decoded) ~= "table" or type(decoded.Languages) ~= "table" then
        return
    end

    for language, entries in pairs(decoded.Languages) do
        if TranslationCache[language] and type(entries) == "table" then
            for sourceText, translatedText in pairs(entries) do
                if type(sourceText) == "string" and type(translatedText) == "string" then
                    TranslationCache[language][sourceText] = translatedText
                end
            end
        end
    end
end

LoadTranslationCache()

--// =====================================================
--// OPTIMIZED LANGUAGE APPLICATION (BATCHED)
--// =====================================================

local function ApplyStateToObject(obj, property, language)
    if not obj or not obj.Parent or IsTranslationSkipped(obj) then
        return false
    end

    local state = TranslationState[obj] and TranslationState[obj][property]

    if not state then
        return false
    end

    local rendered = GetStateTranslation(state, language)

    if rendered == nil then
        return false
    end

    if property == "Text" and obj:IsA("TextBox") and obj.TextEditable then
        return false
    end

    TranslationApplied[obj] = TranslationApplied[obj] or {}
    TranslationApplied[obj][property] = rendered

    obj[property] = rendered
    return true
end

local function ApplyCachedLanguage(language)
    CurrentLanguage = language

    -- Collect objects to process
    local objectsToProcess = {}
    for obj in pairs(TranslationState) do
        if obj and obj.Parent and not IsTranslationSkipped(obj) then
            table.insert(objectsToProcess, obj)
        end
    end

    -- Process in batches to avoid frame lag
    local batchSize = 50
    local totalObjects = #objectsToProcess

    for batchStart = 1, totalObjects, batchSize do
        for i = batchStart, math.min(batchStart + batchSize - 1, totalObjects) do
            local obj = objectsToProcess[i]

            for property, state in pairs(TranslationState[obj]) do
                if property == "Text" and obj:IsA("TextBox") and obj.TextEditable then
                    continue
                end

                local rendered = GetStateTranslation(state, language)

                if rendered then
                    TranslationApplied[obj] = TranslationApplied[obj] or {}
                    TranslationApplied[obj][property] = rendered

                    obj[property] = rendered

                    TranslationSource[obj] = TranslationSource[obj] or {}
                    TranslationSource[obj][property] = state.SourceText
                end
            end
        end

        -- Yield to prevent frame drops
        task.wait()
    end
end

local function UpdateDynamicState(obj, property, currentValue)
    local state = TranslationState[obj] and TranslationState[obj][property]

    if not state then
        return false
    end

    -- Try matching against translated template first
    if CurrentLanguage ~= "EN" then
        local translatedTemplate =
            TranslationCache[CurrentLanguage]
            and TranslationCache[CurrentLanguage][state.SourceTemplate]

        if translatedTemplate then
            local translatedDynamic = MatchDynamicTemplate(
                translatedTemplate,
                currentValue
            )

            if translatedDynamic then
                state.DynamicValues = translatedDynamic
                return true
            end
        end
    end

    -- Try matching against source template
    local sourceDynamic = MatchDynamicTemplate(
        state.SourceTemplate,
        currentValue
    )

    if sourceDynamic then
        state.DynamicValues = sourceDynamic
        state.SourceText = RestoreSelectedText(
            state.SourceTemplate,
            sourceDynamic
        )
        return true
    end

    return false
end

--// =====================================================
--// UI BINDING & SCANNING
--// =====================================================

local function BindProperty(obj, property)
    if not obj or not obj.Parent or IsTranslationSkipped(obj) then
        return
    end

    TranslationSource[obj] = TranslationSource[obj] or {}
    TranslationApplied[obj] = TranslationApplied[obj] or {}
    TranslationConnections[obj] = TranslationConnections[obj] or {}

    if TranslationConnections[obj][property] then
        return
    end

    if property == "Text" and obj:IsA("TextBox") and obj.TextEditable then
        return
    end

    local currentValue = tostring(obj[property] or "")

    local state = BuildSourceState(obj, property, currentValue)

    TranslationSource[obj][property] = state.SourceText
    TranslationApplied[obj][property] = currentValue

    TranslationConnections[obj][property] =
        obj:GetPropertyChangedSignal(property):Connect(function()
            local changedValue = tostring(obj[property] or "")

            local applied = TranslationApplied[obj] and TranslationApplied[obj][property]

            if applied == changedValue then
                return
            end

            if property == "Text" and obj:IsA("TextBox") and obj.TextEditable then
                return
            end

            -- English is always the canonical source
            if CurrentLanguage == "EN" then
                local newState = BuildSourceState(obj, property, changedValue)
                TranslationSource[obj][property] = newState.SourceText
                TranslationApplied[obj][property] = changedValue
                return
            end

            -- Try updating dynamic state
            if UpdateDynamicState(obj, property, changedValue) then
                local rendered = GetStateTranslation(
                    TranslationState[obj][property],
                    CurrentLanguage
                )

                if rendered then
                    TranslationApplied[obj][property] = rendered
                    if rendered ~= changedValue then
                        obj[property] = rendered
                    end
                end
                return
            end

            -- Genuine new string appeared
            local newState = BuildSourceState(obj, property, changedValue)
            TranslationSource[obj][property] = newState.SourceText
            TranslationApplied[obj][property] = changedValue
        end)
end

local function BindTextBoxEditable(obj)
    if not obj:IsA("TextBox") or not obj.Parent then
        return
    end

    TranslationConnections[obj] = TranslationConnections[obj] or {}

    if TranslationConnections[obj]._TextEditable then
        return
    end

    TranslationConnections[obj]._TextEditable =
        obj:GetPropertyChangedSignal("TextEditable"):Connect(function()
            if obj.TextEditable then
                if TranslationSource[obj] then
                    TranslationSource[obj].Text = nil
                end
                if TranslationApplied[obj] then
                    TranslationApplied[obj].Text = nil
                end
                if TranslationState[obj] then
                    TranslationState[obj].Text = nil
                end
                return
            end

            BindProperty(obj, "Text")
        end)
end

local function ScanInstance(obj)
    if not obj or IsTranslationSkipped(obj) then
        return
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        BindProperty(obj, "Text")
    elseif obj:IsA("TextBox") then
        BindProperty(obj, "PlaceholderText")
        BindTextBoxEditable(obj)
        if not obj.TextEditable then
            BindProperty(obj, "Text")
        end
    end

    -- Scan descendants
    for _, child in ipairs(obj:GetDescendants()) do
        if not IsTranslationSkipped(child) then
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                BindProperty(child, "Text")
            elseif child:IsA("TextBox") then
                BindProperty(child, "PlaceholderText")
                BindTextBoxEditable(child)
                if not child.TextEditable then
                    BindProperty(child, "Text")
                end
            end
        end
    end
end

--// =====================================================
--// LANGUAGE SWITCHING
--// =====================================================

local SetLanguageButtonsLocked

local function ChangeLanguage(language)
    if not ExperienceSettings then
        return
    end

    if TranslationBusy then
        return
    end

    if latestClick == language then
        return
    end

    latestClick = language
    SelectedLanguage = language
    RefreshLanguageButtons()
    TranslationBusy = true

    SetLanguageButtonsLocked(true)

    task.spawn(function()
        -- Re-scan for new elements
        ScanInstance(ExperienceSettings)

        if language == "EN" then
            ApplyCachedLanguage("EN")
            TranslationBusy = false
            SetLanguageButtonsLocked(false)
            SelectedLanguage = CurrentLanguage
            RefreshLanguageButtons()
            return
        end

        -- Apply cached translations
        ApplyCachedLanguage(language)

        -- Save cache
        SaveTranslationCache()

        -- Re-apply to catch any new elements
        ApplyCachedLanguage(language)

        TranslationBusy = false
        SetLanguageButtonsLocked(false)
        SelectedLanguage = CurrentLanguage
        RefreshLanguageButtons()
    end)
end

SetLanguageButtonsLocked = function(locked)
    for _, button in pairs(LanguageButtons) do
        if button and button.Parent then
            button.Active = not locked
            button.AutoButtonColor = not locked
        end
    end
end

--// =====================================================
--// INITIALIZATION
--// =====================================================

task.spawn(function()
    ExperienceSettings = CoreGui:WaitForChild("ExperienceSettings")

    -- Initial scan
    ScanInstance(ExperienceSettings)

    -- Scan new descendants
    ExperienceSettings.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if not obj or not obj.Parent or IsTranslationSkipped(obj) then
                return
            end

            ScanInstance(obj)

            if CurrentLanguage ~= "EN" then
                ApplyCachedLanguage(CurrentLanguage)
            end
        end)
    end)
end)

return {
    ChangeLanguage = ChangeLanguage,
    ApplyCachedLanguage = ApplyCachedLanguage,
    SaveTranslationCache = SaveTranslationCache,
    CurrentLanguage = function() return CurrentLanguage end,
}
