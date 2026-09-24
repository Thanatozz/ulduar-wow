local UA = UlduarAbilitiesUI
local casts = { "Instant", "Cast Time", "Channel", "Melee Attack", "Ranged Attack" }
local targets = { "Unit", "Ground", "Self", "Area Around Caster", "Area Around Target", "Direction" }
local deliveries = { "Direct", "Projectile", "Beam", "Area", "Persistent Area" }
local temporal = { "Instant", "Periodic", "Channel Ticks", "Persistent Area Ticks", "Delayed" }
local ranges = { "Melee", "Low", "Mid", "Long" }
local relations = { "Enemy", "Friendly", "Self", "Any" }
local effects = { "Damage", "Healing", "Aura", "Dispel", "Summon", "Displacement", "Resource" }

function UA.CreateAbilityDetails(parent)
    local width, height = UA.Layout.detailsWidth, UA.Layout.contentHeight
    local panel = UA.Panel(parent, width, height)
    panel:SetPoint("TOPRIGHT")
    panel.title = UA.Label(panel, "Current Build", "GameFontNormal", 16, -18)
    panel.title:SetWidth(width - 32)
    panel.title:SetJustifyH("CENTER")
    panel.scroll = CreateFrame("ScrollFrame", "UlduarBuildDetailsScroll", panel, "UIPanelScrollFrameTemplate")
    panel.scroll:SetPoint("TOPLEFT", 16, -48)
    panel.scroll:SetPoint("BOTTOMRIGHT", -32, 132)
    local content = CreateFrame("Frame", nil, panel.scroll)
    content:SetSize(width - 52, 480)
    panel.scroll:SetScrollChild(content)
    UA.BindScrollWheel(content, panel.scroll, 40)
    panel.content = content
    panel.summary = UA.Label(content, "", "GameFontHighlightSmall", 0, 0)
    panel.summary:SetWidth(width - 54)
    panel.summary:SetJustifyH("LEFT")
    panel.summary:SetSpacing(3)
    panel.detailsButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    panel.detailsButton:SetSize(120, 22)
    panel.detailsButton:SetText("Details -")
    UA.BindScrollWheel(panel.detailsButton, panel.scroll, 40)
    panel.expanded = true
    panel.detailsButton:SetScript("OnClick", function()
        panel.expanded = not panel.expanded
        UA.RefreshDetails()
    end)
    panel.details = UA.Label(content, "", "GameFontHighlightSmall", 0, -300)
    panel.details:SetWidth(width - 54)
    panel.details:SetJustifyH("LEFT")
    panel.details:SetSpacing(5)
    UA.Section(panel, "EVOLUTION POINTS", height - 120, width)
    panel.budget = UA.Label(panel, "", "GameFontHighlightSmall", 18, -height + 86)
    panel.budget:SetWidth(width - 36)
    panel.budget:SetJustifyH("LEFT")
    panel.budget:SetSpacing(5)
    UA.details = panel
end

local function layoutDetails(panel)
    local summaryHeight = panel.summary:GetStringHeight()
    panel.detailsButton:ClearAllPoints()
    panel.detailsButton:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -summaryHeight - 18)
    panel.details:ClearAllPoints()
    panel.details:SetPoint("TOPLEFT", panel.detailsButton, "BOTTOMLEFT", 0, -14)
    local total = summaryHeight + 64 + (panel.expanded and panel.details:GetStringHeight() or 0)
    panel.content:SetHeight(math.max(panel.scroll:GetHeight(), total + 12))
    panel.scroll:UpdateScrollChildRect()
    panel.scroll:SetVerticalScroll(math.min(panel.scroll:GetVerticalScroll(), panel.scroll:GetVerticalScrollRange()))
end

function UA.RefreshDetails()
    if not UA.details then return end
    local panel, a = UA.details, UA.Preview()
    panel.title:SetText(UA.IsDraftDirty() and "Draft Build - Preview" or "Current Build")
    if panel.abilityID ~= (a and a.id) then
        panel.abilityID = a and a.id
        panel.scroll:SetVerticalScroll(0)
    end
    if not a then
        panel.summary:SetText("Select an ability.")
        panel.details:SetText("")
        panel.budget:SetText("")
        panel.detailsButton:Hide()
        layoutDetails(panel)
        return
    end
    panel.detailsButton:Show()
    local committed = UA.Selected()
    panel.budget:SetText(string.format("Committed Spent: %d\nDraft Spent: %d\n%sRemaining after Confirm: %d|r",
        committed.spent, a.spent, a.points < 0 and "|cffff4040" or "|cffffd100", a.points))
    local name = UA.SpellPresentation(a.spellID)
    local potencyLabel = UA.SecondaryEffectLabel(a)
    local potency = UA.SupportsNode(a, 4) and string.format("%.0f%% %s", a.multiplier * 100, potencyLabel) or
        "Original effect strength"
    panel.summary:SetText(string.format(
        "|cffffd100%s|r\nRank %d\n\n|cffffd100Element|r  %s\n|cffffd100Propagation|r  %s\n\n" ..
        "|cffffd100Coverage|r\n%s\n\n|cffffd100Potency|r  %s",
        name, a.rank, UA.ElementText(a), UA.ModeName(a.mode), UA.CoverageText(a),
        potency))
    local offense = {}
    if a.damage > 0 then offense[#offense + 1] = string.format("Damage: %.0f%%", a.primaryMultiplier * 100) end
    if a.castTime > 0 then offense[#offense + 1] = string.format("Cast: %.2fs", a.castSeconds) end
    if a.cooldown > 0 then offense[#offense + 1] = string.format("Cooldown: %.2fs", a.cooldownSeconds) end
    if a.mode == 5 and a.rebound > 0 then offense[#offense + 1] = "Rebound gap: " .. a.reboundGap end
    if #offense > 0 then panel.summary:SetText(panel.summary:GetText() .. "\n" .. table.concat(offense, " / ")) end
    local names = {}
    for index, label in ipairs(effects) do
        if bit.band(a.effects, bit.lshift(1, index - 1)) ~= 0 then names[#names + 1] = label end
    end
    panel.details:SetText(string.format(
        "|cffffd100CAST|r  %s\n|cffffd100TARGET|r  %s / %s\n|cffffd100DELIVERY|r  %s\n" ..
        "|cffffd100TEMPORAL|r  %s\n|cffffd100RANGE|r  %s\n|cffffd100EFFECTS|r  %s",
        casts[a.cast + 1] or "Unknown", relations[a.relation + 1] or "Unknown",
        targets[a.targeting + 1] or "Unknown", deliveries[a.delivery + 1] or "Unknown",
        temporal[a.temporal + 1] or "Unknown", ranges[a.range + 1] or "Unknown", table.concat(names, " + ")))
    panel.detailsButton:SetText(panel.expanded and "Details -" or "Details +")
    if panel.expanded then panel.details:Show() else panel.details:Hide() end
    layoutDetails(panel)
end
