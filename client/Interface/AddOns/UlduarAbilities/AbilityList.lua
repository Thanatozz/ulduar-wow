local UA = UlduarAbilitiesUI

function UA.CreateAbilityList(parent)
    local layout = UA.Layout
    local panel = UA.Panel(parent, layout.listWidth, layout.contentHeight)
    panel:SetPoint("TOPLEFT")
    UA.Section(panel, "ABILITIES", 12, layout.listWidth)
    panel.search = CreateFrame("EditBox", "UlduarAbilitySearch", panel, "InputBoxTemplate")
    panel.search:SetPoint("TOPLEFT", 22, -47)
    panel.search:SetSize(layout.listWidth - 48, 24)
    panel.search:SetAutoFocus(false)
    panel.search:SetMaxLetters(64)
    panel.search:SetFontObject(GameFontHighlightSmall)
    panel.search.hint = UA.Label(panel.search, "Search abilities", "GameFontDisableSmall", 3, -5)
    panel.search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    panel.search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    panel.search:SetScript("OnTextChanged", function(self)
        if self:GetText() == "" then self.hint:Show() else self.hint:Hide() end
        if not panel.scroll then return end
        FauxScrollFrame_SetOffset(panel.scroll, 0)
        _G[panel.scroll:GetName() .. "ScrollBar"]:SetValue(0)
        UA.RefreshList()
    end)
    panel.scroll = UA.CreateScrollList(panel, "UlduarAbilityListScroll",
        layout.listRows, layout.rowHeight, UA.RefreshList)
    panel.scroll:ClearAllPoints()
    panel.scroll:SetPoint("TOPLEFT", 8, -84)
    panel.scroll:SetPoint("BOTTOMRIGHT", -28, 54)
    UA.BindScrollWheel(panel, panel.scroll, layout.rowHeight)
    panel.rows = {}
    for index = 1, layout.listRows do
        local row = CreateFrame("Button", nil, panel)
        row:SetPoint("TOPLEFT", 10, -86 - (index - 1) * layout.rowHeight)
        row:SetSize(layout.listWidth - 40, layout.rowHeight - 2)
        row:SetHighlightTexture(UA.Art.highlight, "ADD")
        UA.BindScrollWheel(row, panel.scroll, layout.rowHeight)
        row.selection = row:CreateTexture(nil, "BACKGROUND")
        row.selection:SetAllPoints()
        row.selection:SetTexture(UA.Art.highlight)
        row.selection:SetVertexColor(0.95, 0.72, 0.28, 0.8)
        row.selection:SetBlendMode("ADD")
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetPoint("LEFT", 4, 0)
        row.icon:SetSize(32, 32)
        local border = row:CreateTexture(nil, "OVERLAY")
        border:SetTexture(UA.Art.border)
        border:SetSize(48, 48)
        border:SetPoint("CENTER", row.icon, "CENTER")
        row.name = UA.Label(row, "", "GameFontNormalSmall", 46, -2)
        row.name:SetSize(layout.listWidth - 88, 28)
        row.name:SetJustifyH("LEFT")
        row.name:SetJustifyV("TOP")
        row.info = UA.Label(row, "", "GameFontHighlightSmall", 46, -32)
        row.info:SetWidth(layout.listWidth - 88)
        row.info:SetJustifyH("LEFT")
        row:SetScript("OnClick", function(self)
            panel.search:ClearFocus()
            UA.SelectAbility(self.abilityID)
        end)
        row:SetScript("OnEnter", function(self)
            local a = UA.Preview(self.abilityID)
            if not a then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("spell:" .. a.spellID)
            UA.AppendAbilityTooltip(GameTooltip, a)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.rows[index] = row
    end
    panel.empty = UA.Label(panel, "Waiting for server", "GameFontHighlightSmall", 18, -100)
    panel.empty:SetWidth(layout.listWidth - 36)
    panel.empty:SetJustifyH("CENTER")
    panel.count = UA.Label(panel, "", "GameFontDisableSmall", 16, -layout.contentHeight + 35)
    panel.count:SetWidth(layout.listWidth - 32)
    panel.count:SetJustifyH("CENTER")
    UA.list = panel
end

function UA.RefreshList()
    if not UA.list then return end
    local list, layout = UA.list, UA.Layout
    local query = string.lower(list.search:GetText() or "")
    local ids = {}
    -- Search only the server-authorized catalog. It never expands ability eligibility.
    for _, id in ipairs(UA.order) do
        local a = UA.abilities[id]
        if a then
            local name = UA.SpellPresentation(a.spellID)
            if query == "" or string.find(string.lower(name), query, 1, true) then ids[#ids + 1] = id end
        end
    end
    local offset = math.min(FauxScrollFrame_GetOffset(list.scroll), math.max(0, #ids - layout.listRows))
    FauxScrollFrame_SetOffset(list.scroll, offset)
    FauxScrollFrame_Update(list.scroll, #ids, layout.listRows, layout.rowHeight)
    for index, row in ipairs(list.rows) do
        local a = UA.abilities[ids[index + offset]]
        if row.abilityID ~= (a and a.id) and GameTooltip:GetOwner() == row then GameTooltip:Hide() end
        row.abilityID = a and a.id
        if a then
            local name, icon = UA.SpellPresentation(a.spellID)
            row.icon:SetTexture(icon)
            row.name:SetText(name)
            row.info:SetText("Rank " .. a.rank .. (a.points > 0 and ("  |cffffd100+" .. a.points .. " EP|r") or ""))
            if UA.selectedAbility == a.id then row.selection:Show() else row.selection:Hide() end
            row:Show()
        else row:Hide() end
    end
    list.empty:SetText(not UA.ready and "Waiting for server" or
        (#UA.order == 0 and "No known abilities" or "No matching abilities"))
    if #ids == 0 then list.empty:Show() else list.empty:Hide() end
    list.count:SetText(string.format("%d / %d abilities", #ids, #UA.order))
end
