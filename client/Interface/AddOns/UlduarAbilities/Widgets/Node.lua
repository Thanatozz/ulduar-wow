local UA = UlduarAbilitiesUI

function UA.Label(parent, text, font, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetText(text)
    return label
end

function UA.CreateNode(parent, title, spellID, size)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size or 36, size or 36)
    local _, icon = UA.SpellPresentation(spellID)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints(button)
    button.icon:SetTexture(icon)
    button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
    button:GetNormalTexture():ClearAllPoints()
    button:GetNormalTexture():SetPoint("TOPLEFT", -10, 10)
    button:GetNormalTexture():SetPoint("BOTTOMRIGHT", 10, -10)
    button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    button.selected = button:CreateTexture(nil, "OVERLAY")
    button.selected:SetAllPoints(button)
    button.selected:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    button.selected:SetBlendMode("ADD")
    button.selected:SetVertexColor(1, 0.8, 0.25, 0.7)
    button.selected:Hide()
    button.rankBorder = button:CreateTexture(nil, "OVERLAY")
    button.rankBorder:SetTexture("Interface\\TalentFrame\\TalentFrame-RankBorder")
    button.rankBorder:SetSize(32, 32)
    button.rankBorder:SetPoint("CENTER", button, "BOTTOMRIGHT", 0, 0)
    button.rankBorder:Hide()
    button.rankText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.rankText:SetPoint("CENTER", button.rankBorder)
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.label:SetPoint("TOP", button, "BOTTOM", 0, -8)
    button.label:SetText(title)
    button.label:SetWidth(96)
    button.label:SetHeight(28)
    button.label:SetJustifyH("CENTER")
    button.label:SetJustifyV("TOP")
    button.pending = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.pending:SetPoint("TOP", button.label, "BOTTOM", 0, -1)
    button.pending:SetText("Pending")
    button.pending:Hide()
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.tooltip then self.tooltip(self) else GameTooltip:SetText(title) end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return button
end

function UA.SetNodeState(node, selected, enabled)
    if selected then node.selected:Show() else node.selected:Hide() end
    if selected then node:GetNormalTexture():SetVertexColor(1, 0.85, 0.45)
    elseif enabled then node:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8)
    else node:GetNormalTexture():SetVertexColor(0.45, 0.45, 0.45) end
    -- Keep mouseover tooltips on locked nodes; actions also check this flag before sending.
    node.available = enabled
    node.icon:SetDesaturated(not enabled and not selected)
    node.icon:SetVertexColor(1, 1, 1, (enabled or selected) and 1 or 0.55)
end

function UA.Panel(parent, width, height)
    return UA.Inset(parent, width, height)
end

function UA.SetNodePending(node, pending)
    if pending then node.pending:Show() else node.pending:Hide() end
end
