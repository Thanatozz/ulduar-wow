local UA = UlduarAbilitiesUI
local Lab = UA.Lab

-- Developer Ability Lab window: a form over the `.ua lab` commands (see LabProtocol.lua). It keeps no
-- modifier state of its own; every result shown is the server's inspector output.
local Operations = { "set", "add", "subtract", "multiply", "percent_add", "enable", "disable",
    "clamp_min", "clamp_max" }
local Components = { "projectile", "beam", "area", "periodic", "echo", "displacement" }
local Presets = { "instant", "nocooldown", "movingcast", "chain", "split", "shatter", "nova", "dot",
    "spreaddot", "echo", "execute" }

local function Settings()
    UlduarAbilitiesDB.lab = type(UlduarAbilitiesDB.lab) == "table" and UlduarAbilitiesDB.lab or {}
    return UlduarAbilitiesDB.lab
end

local function Trim(text)
    return (string.gsub(text or "", "^%s*(.-)%s*$", "%1"))
end

local function EditBox(parent, name, width, x, y, label)
    UA.Label(parent, label, "GameFontNormalSmall", x, y)
    local box = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    box:SetAutoFocus(false)
    box:SetSize(width, 20)
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 6, y - 14)
    box:SetMaxLetters(64)
    box:SetScript("OnEscapePressed", box.ClearFocus)
    return box
end

local function Button(parent, text, width, anchor, relative, x, y, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    button:SetPoint(anchor, relative, anchor == "TOPLEFT" and "TOPRIGHT" or anchor, x, y)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function Dropdown(parent, name, width, x, y, label, values, key)
    UA.Label(parent, label, "GameFontNormalSmall", x, y)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", x - 16, y - 10)
    UIDropDownMenu_SetWidth(dropdown, width)
    dropdown.value = Settings()[key] or values[1]
    UIDropDownMenu_Initialize(dropdown, function()
        for _, value in ipairs(values) do
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = value, value
            info.checked = dropdown.value == value
            info.func = function(self)
                dropdown.value = self.value
                Settings()[key] = self.value
                UIDropDownMenu_SetSelectedValue(dropdown, self.value)
                UIDropDownMenu_SetText(dropdown, self.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(dropdown, dropdown.value)
    UIDropDownMenu_SetText(dropdown, dropdown.value)
    return dropdown
end

function Lab.SetStatus(text)
    if Lab.frame then Lab.frame.status:SetText(text or "") end
end

function Lab.Echo(text)
    if Lab.frame then Lab.frame.output:AddMessage((string.gsub(text, "|", "||")), 0.6, 0.6, 0.6) end
end

-- Server text is displayed literally (pipes escaped) and colored by its inspector prefix.
function Lab.Output(text)
    if not Lab.frame then return end
    local r, g, b = 0.95, 0.92, 0.82
    if string.find(text, "^RUNTIME:") then r, g, b = 0.35, 1, 0.35
    elseif string.find(text, "^RESOLVED ONLY") then r, g, b = 1, 0.6, 0.15
    elseif string.find(text, "Rejected") or string.find(text, "INVALID") or string.find(text, "Unknown") or
        string.find(text, "Disabled") or string.find(text, "Usage") then r, g, b = 1, 0.3, 0.3
    elseif string.find(text, "^%[AbilityLab%]") or string.find(text, "^===") then r, g, b = 1, 0.82, 0 end
    Lab.frame.output:AddMessage((string.gsub(text, "|", "||")), r, g, b)
end

local function Ability()
    local ability = string.lower(Trim(Lab.frame.ability:GetText()))
    Settings().ability = ability
    return ability
end

-- Mutations print the inspector themselves; a clear prints only a confirmation, so re-inspect.
local function Inspect() Lab.Run({ "inspect", Ability() }) end
local function AfterClear(ok) if ok then Inspect() end end

local function ApplyModifier()
    local property = Trim(Lab.frame.property:GetText())
    local operation = Lab.frame.operation.value
    local value = Trim(Lab.frame.value:GetText())
    Settings().property = property
    if value == "" and (operation == "enable" or operation == "disable") then value = "1" end
    Lab.Run({ "set", Ability(), property, operation, value })
end

function Lab.Create()
    local frame = CreateFrame("Frame", "UlduarAbilityLabFrame", UIParent, "UlduarAbilitiesWindowTemplate")
    Lab.frame = frame
    frame:Hide()
    frame:SetSize(660, 560)
    frame:SetBackdropColor(0.06, 0.05, 0.04, 1)
    frame:SetBackdropBorderColor(0.85, 0.78, 0.62, 1)
    frame:SetPoint("CENTER", 0, 20)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    tinsert(UISpecialFrames, "UlduarAbilityLabFrame")

    UA.Label(frame, "Ability Lab", "GameFontNormalLarge", 24, -20)
    UA.Label(frame, "Developer modifiers on your own character. GM + UlduarAbilities.DebugEditor only.",
        "GameFontHighlightSmall", 24, -40)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)

    local settings = Settings()
    frame.ability = EditBox(frame, "UlduarAbilityLabAbility", 150, 24, -62, "Ability")
    frame.ability:SetText(settings.ability or "frostbolt")
    frame.ability:SetScript("OnEnterPressed", function(self) self:ClearFocus(); Inspect() end)
    local inspect = Button(frame, "Inspect", 80, "TOPLEFT", frame.ability, 8, 0, Inspect)
    local list = Button(frame, "List", 60, "TOPLEFT", inspect, 4, 0,
        function() Lab.Run({ "list", Ability() }) end)
    local clear = Button(frame, "Clear", 60, "TOPLEFT", list, 4, 0,
        function() Lab.Run({ "clear", Ability() }, AfterClear) end)
    Button(frame, "Clear all", 80, "TOPLEFT", clear, 4, 0, function() Lab.Run({ "clear", "all" }) end)

    frame.property = EditBox(frame, "UlduarAbilityLabProperty", 170, 24, -104, "Property")
    frame.property:SetText(settings.property or "Casting.CastTime")
    -- Find lists registry properties whose name contains the typed text.
    local find = Button(frame, "Find", 50, "TOPLEFT", frame, 0, 0, function()
        local filter = Trim(frame.property:GetText())
        Lab.Run(filter ~= "" and { "properties", filter } or { "properties" })
    end)
    find:ClearAllPoints()
    find:SetPoint("TOPLEFT", frame, "TOPLEFT", 90, -100)
    find:SetHeight(18)
    frame.operation = Dropdown(frame, "UlduarAbilityLabOperation", 100, 230, -104, "Operation", Operations,
        "operation")
    frame.value = EditBox(frame, "UlduarAbilityLabValue", 80, 380, -104, "Value (2.5s, 40, frost)")
    frame.value:SetScript("OnEnterPressed", function(self) self:ClearFocus(); ApplyModifier() end)
    Button(frame, "Apply", 70, "TOPLEFT", frame.value, 8, 0, ApplyModifier)

    frame.preset = Dropdown(frame, "UlduarAbilityLabPreset", 110, 24, -146, "Preset", Presets, "preset")
    local loadPreset = Button(frame, "Load", 60, "TOPLEFT", frame.preset, -10, -2,
        function() Lab.Run({ "preset", Ability(), frame.preset.value }) end)
    Button(frame, "Presets", 70, "TOPLEFT", loadPreset, 4, 0, function() Lab.Run({ "presets" }) end)
    frame.saveName = EditBox(frame, "UlduarAbilityLabSaveName", 110, 330, -146, "Save layer as")
    frame.saveName:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    Button(frame, "Save", 60, "TOPLEFT", frame.saveName, 8, 0, function()
        local name = string.lower(Trim(frame.saveName:GetText()))
        Lab.Run({ "save", name, Ability() }, function(ok)
            if not ok then return end
            -- Saved presets live in server memory for this run; offer them in this session's dropdown.
            if not tContains(Presets, name) then Presets[#Presets + 1] = name end
            frame.preset.value = name
            UIDropDownMenu_SetSelectedValue(frame.preset, name)
            UIDropDownMenu_SetText(frame.preset, name)
        end)
    end)

    frame.component = Dropdown(frame, "UlduarAbilityLabComponent", 110, 24, -188, "Component", Components,
        "component")
    local add = Button(frame, "Add", 60, "TOPLEFT", frame.component, -10, -2,
        function() Lab.Run({ "component", Ability(), "add", frame.component.value }) end)
    Button(frame, "Remove", 70, "TOPLEFT", add, 4, 0,
        function() Lab.Run({ "component", Ability(), "remove", frame.component.value }) end)
    frame.index = EditBox(frame, "UlduarAbilityLabIndex", 40, 330, -188, "Modifier #")
    frame.index:SetNumeric(true)
    Button(frame, "Remove #", 80, "TOPLEFT", frame.index, 8, 0, function()
        local index = Trim(frame.index:GetText())
        Lab.Run({ "remove", Ability(), index ~= "" and index or "-" })
    end)

    local inset = UA.Inset(frame, 612, 280)
    inset:SetPoint("TOPLEFT", 24, -236)
    local output = CreateFrame("ScrollingMessageFrame", "UlduarAbilityLabOutput", inset)
    output:SetPoint("TOPLEFT", 10, -8)
    output:SetPoint("BOTTOMRIGHT", -10, 8)
    output:SetFontObject(GameFontHighlightSmall)
    output:SetJustifyH("LEFT")
    output:SetFading(false)
    output:SetMaxLines(500)
    output:SetInsertMode("BOTTOM")
    output:EnableMouseWheel(true)
    output:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
            if IsShiftKeyDown() then self:ScrollToTop() else self:ScrollUp() end
        elseif IsShiftKeyDown() then self:ScrollToBottom() else self:ScrollDown() end
    end)
    frame.output = output
    Button(frame, "Clear output", 100, "BOTTOMRIGHT", frame, -24, 18, function() output:Clear() end)
    frame.status = UA.Label(frame, "", "GameFontHighlightSmall", 24, -526)
    frame.status:SetWidth(500)
    frame.status:SetJustifyH("LEFT")

    frame:SetScript("OnShow", function() PlaySound("igCharacterInfoOpen") end)
    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        PlaySound("igCharacterInfoClose")
    end)
end

function Lab.Toggle()
    if not Lab.frame then Lab.Create() end
    if Lab.frame:IsShown() then Lab.frame:Hide() else Lab.frame:Show() end
end
