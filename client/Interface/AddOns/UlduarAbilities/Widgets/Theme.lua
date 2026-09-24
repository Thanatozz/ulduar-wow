local UA = UlduarAbilitiesUI

-- Presentation tokens only. Costs, capabilities and preview values belong to the existing state layer.
UA.Layout = {
    width = 1100, height = 752, contentWidth = 1068, contentHeight = 596,
    listWidth = 214, treeWidth = 560, detailsWidth = 274, gap = 10,
    listRows = 9, rowHeight = 50,
}
UA.Art = {
    pearl = "Interface\\Icons\\INV_Misc_Gem_Pearl_06",
    parchment = "Interface\\AchievementFrame\\UI-Achievement-AchievementBackground",
    highlight = "Interface\\QuestFrame\\UI-QuestTitleHighlight",
    border = "Interface\\Buttons\\UI-Quickslot2",
}

function UA.Inset(parent, width, height)
    local panel = CreateFrame("Frame", nil, parent, "UlduarAbilitiesInsetTemplate")
    panel:SetSize(width, height)
    panel:SetBackdropColor(0.075, 0.066, 0.052, 1)
    panel:SetBackdropBorderColor(0.56, 0.47, 0.31, 1)
    return panel
end

function UA.DecorateParchment(panel)
    local art = panel:CreateTexture(nil, "BACKGROUND")
    art:SetPoint("TOPLEFT", 5, -5)
    art:SetPoint("BOTTOMRIGHT", -5, 5)
    art:SetTexture(UA.Art.parchment)
    art:SetVertexColor(0.44, 0.39, 0.29, 1)
    return art
end

function UA.Section(parent, title, top, width)
    local section = CreateFrame("Frame", nil, parent)
    section:SetPoint("TOPLEFT", 18, -top)
    section:SetSize(width - 36, 22)
    local background = section:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetTexture(0.05, 0.035, 0.015, 0.72)
    local label = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    label:SetText(title)
    for _, edge in ipairs({ "TOP", "BOTTOM" }) do
        local line = section:CreateTexture(nil, "BORDER")
        line:SetPoint(edge .. "LEFT")
        line:SetPoint(edge .. "RIGHT")
        line:SetHeight(1)
        line:SetTexture(0.55, 0.42, 0.2, 0.7)
    end
    return section
end

function UA.CenterNodes(nodes, parent, top, size, spacing)
    local width = parent:GetWidth()
    local columns = math.max(1, math.floor((width - 48 - size) / spacing) + 1)
    for index, node in ipairs(nodes) do
        local row = math.floor((index - 1) / columns)
        local column = (index - 1) % columns
        local count = math.min(columns, #nodes - row * columns)
        node:ClearAllPoints()
        node:SetPoint("TOPLEFT", (width - ((count - 1) * spacing + size)) / 2 + column * spacing,
            -top - row * 92)
    end
    return math.ceil(#nodes / columns) * 92
end

function UA.BindScrollWheel(region, scroll, step)
    region:EnableMouseWheel(true)
    region:SetScript("OnMouseWheel", function(_, delta)
        local bar = _G[scroll:GetName() .. "ScrollBar"]
        local minimum, maximum = bar:GetMinMaxValues()
        bar:SetValue(math.max(minimum, math.min(maximum, bar:GetValue() - delta * step)))
    end)
end
