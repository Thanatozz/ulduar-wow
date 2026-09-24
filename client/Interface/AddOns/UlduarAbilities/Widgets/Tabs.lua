local UA = UlduarAbilitiesUI

function UA.SelectTab(id)
    if UA.leaveDialog and UA.leaveDialog:IsShown() then return end
    UA.selectedTab = id
    PanelTemplates_SetTab(UA.frame, id)
    for index, page in ipairs(UA.frame.pages) do
        if index == id then page:Show() else page:Hide() end
    end
    if UA.list then UA.list.search:ClearFocus() end
end

function UA.CreateTabs(frame)
    frame.pages = {}
    local names = { "Abilities", "Builds", "Codex", "Progression" }
    for id, title in ipairs(names) do
        local tab = CreateFrame("Button", "UlduarFrameTab" .. id, frame, "CharacterFrameTabButtonTemplate")
        -- Replace the inherited OnShow: CharacterFrame_TabBoundsCheck only belongs to CharacterFrame.
        tab:SetScript("OnShow", function(self) PanelTemplates_TabResize(self, 0) end)
        tab:SetID(id)
        tab:SetText(title)
        PanelTemplates_TabResize(tab, 0)
        if id == 1 then tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 22, 5)
        else tab:SetPoint("LEFT", _G["UlduarFrameTab" .. (id - 1)], "RIGHT", -12, 0) end
        tab:SetScript("OnClick", function(self) UA.SelectTab(self:GetID()); PlaySound("igCharacterInfoTab") end)
        local page = CreateFrame("Frame", nil, frame)
        page:SetPoint("TOPLEFT", 16, -80)
        page:SetSize(UA.Layout.contentWidth, UA.Layout.contentHeight)
        if id ~= 1 then
            local panel = UA.Panel(page, UA.Layout.contentWidth, UA.Layout.contentHeight)
            panel:SetAllPoints()
            UA.DecorateParchment(panel)
            UA.Section(panel, title, 18, UA.Layout.contentWidth)
            local icon = panel:CreateTexture(nil, "ARTWORK")
            icon:SetTexture(UA.Art.pearl)
            icon:SetSize(56, 56)
            icon:SetPoint("CENTER", 0, 42)
            local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            text:SetPoint("CENTER", 0, -18)
            text:SetText("Coming later")
        end
        frame.pages[id] = page
    end
    PanelTemplates_SetNumTabs(frame, #names)
    UA.SelectTab(1)
end
