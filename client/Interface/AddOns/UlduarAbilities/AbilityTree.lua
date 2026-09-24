local UA = UlduarAbilitiesUI

function UA.CreateAbilityTree(parent)
    local panel = UA.Panel(parent, UA.Layout.treeWidth, UA.Layout.contentHeight)
    panel:SetPoint("TOPLEFT", UA.Layout.listWidth + UA.Layout.gap, 0)
    UA.DecorateParchment(panel)
    local scroll = CreateFrame("ScrollFrame", "UlduarAbilityEditorScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -52)
    scroll:SetPoint("BOTTOMRIGHT", -30, 12)
    panel.empty = UA.Label(panel, "Select an ability to begin.", "GameFontHighlight", 24, -260)
    panel.empty:SetWidth(UA.Layout.treeWidth - 48)
    panel.empty:SetJustifyH("CENTER")
    local tree = CreateFrame("Frame", nil, scroll)
    tree:SetSize(UA.Layout.treeWidth - 42, 608)
    tree.panel, tree.scroll = panel, scroll
    scroll:SetScrollChild(tree)
    UA.BindScrollWheel(tree, scroll, 40)
    tree.abilityID = nil
    tree.title = UA.Label(panel, "Ability configuration", "GameFontNormalLarge", 18, -16)
    tree.title:SetWidth(UA.Layout.treeWidth - 36)
    tree.title:SetHeight(22)
    tree.title:SetJustifyH("LEFT")
    UA.Section(tree, "BASE ELEMENT", 0, tree:GetWidth())
    -- Informational frame, deliberately not a purchasable node or free respec button.
    tree.base = CreateFrame("Frame", nil, tree)
    tree.base:SetSize(44, 44)
    tree.base:SetPoint("TOP", 0, -36)
    tree.base:EnableMouse(true)
    UA.BindScrollWheel(tree.base, scroll, 40)
    tree.base.icon = tree.base:CreateTexture(nil, "ARTWORK")
    tree.base.icon:SetAllPoints()
    local border = tree.base:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    border:SetPoint("TOPLEFT", -8, 8)
    border:SetPoint("BOTTOMRIGHT", 8, -8)
    tree.base.label = UA.Label(tree, "", "GameFontHighlightSmall", 0, -90)
    tree.base.label:SetWidth(tree:GetWidth())
    tree.base.label:SetJustifyH("CENTER")
    tree.base:SetScript("OnEnter", function(self)
        local a = UA.Preview()
        if not a then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Base Element: " .. UA.ElementName(a.baseElement), 1, 0.82, 0)
        GameTooltip:AddLine("The native element. Reset stages its restoration; Confirm applies it.", 1, 1, 1, true)
        UA.AppendAbilityTooltip(GameTooltip, a)
        GameTooltip:Show()
    end)
    tree.base:SetScript("OnLeave", function() GameTooltip:Hide() end)
    tree.conversionSection = UA.Section(tree, "ELEMENT CONVERSION", 130, tree:GetWidth())
    tree.elements = {}
    for _, element in ipairs(UA.Elements) do
        local data = element
        local node = UA.CreateNode(tree, data.name, data.spell, 36)
        UA.BindScrollWheel(node, scroll, 40)
        node.elementID = data.id
        node.tooltip = function()
            local a = UA.Preview()
            GameTooltip:SetText(data.name, 1, 0.82, 0)
            if a and not UA.SupportsNode(a, 1) then
                GameTooltip:AddLine("This ability keeps its original school. Element conversion is unavailable.",
                    1, 0.82, 0, true)
                return
            end
            GameTooltip:AddLine("Convert the direct effect's school. The original aura remains.", 1, 1, 1, true)
            GameTooltip:AddLine("Draft cost: " .. (UA.rules and UA.rules.elementCost or "--") ..
                " Evolution Points", 1, 0.82, 0, true)
            if a then GameTooltip:AddLine("Draft Element: " .. UA.ElementName(UA.EffectiveElement(a)), 1, 1, 1) end
            GameTooltip:AddLine("Click to select; click again to remove. Commit with Confirm.", 0.2, 1, 0.2, true)
        end
        node:SetScript("OnClick", function(self)
            if self.available then UA.EditDraft("ELEMENT", self.elementID) end
        end)
        tree.elements[#tree.elements + 1] = node
    end
    tree.deliverySection = UA.Section(tree, "DELIVERY", 244, tree:GetWidth())
    tree.modes = {}
    for _, mode in ipairs(UA.Modes) do
        local data = mode
        local node = UA.CreateNode(tree, data.name, data.spell, 36)
        node.modeID = data.id
        UA.BindScrollWheel(node, scroll, 40)
        node.tooltip = function()
            GameTooltip:SetText(data.name, 1, 0.82, 0)
            local selected = UA.Preview()
            GameTooltip:AddLine("Draft preview. Confirm to apply.", 1, 0.82, 0)
            local description = selected and UA.PropagationTooltipText(selected, data.id) or data.description
            GameTooltip:AddLine(description, 1, 1, 1, true)
            GameTooltip:AddLine("Cost: Free", 1, 0.82, 0)
            local a = UA.Preview()
            if UA.SupportsNode(a, 8) then
                GameTooltip:AddLine("Applies to each native missile or retaliation hit. " ..
                    "Recast the ability after changing its build.",
                    1, 0.82, 0, true)
            end
            if UA.SupportsNode(a, 16) then
                GameTooltip:AddLine("Propagates the aura only. Seal damage remains on the primary target.",
                    1, 0.82, 0, true)
            end
            if a and bit.band(a.modes, bit.lshift(1, data.id)) == 0 then
                GameTooltip:AddLine("Not supported by this ability.", 1, 0.3, 0.2)
            end
        end
        node:SetScript("OnClick", function(self)
            if self.available then UA.EditDraft("MODE", self.modeID) end
        end)
        tree.modes[#tree.modes + 1] = node
    end
    tree.sections = {}
    tree.sections.OFFENSE = UA.Section(tree, "OFFENSE", 358, tree:GetWidth())
    tree.sections.PROPAGATION = UA.Section(tree, "PROPAGATION", 474, tree:GetWidth())
    tree.modifiers = {}
    for _, data in ipairs(UA.ModifierNodes) do
        local spec = data
        local node = UA.CreateNode(tree, spec.label, spec.icon, 36)
        UA.BindScrollWheel(node, scroll, 40)
        node.spec = spec
        node.rankBorder:Show()
        node:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        node.tooltip = function() UA.ModifierTooltip(spec) end
        node:SetScript("OnClick", function(self, button)
            if self.available then UA.EditDraft("MODIFIER", spec, button) end
        end)
        tree.modifiers[#tree.modifiers + 1] = node
    end
    UA.tree = tree
end

function UA.RefreshTree()
    if not UA.tree then return end
    local tree, a = UA.tree, UA.Preview()
    local active = UA.CanEditDraft()
    if tree.abilityID ~= (a and a.id) then
        tree.abilityID = a and a.id
        tree.scroll:SetVerticalScroll(0)
    end
    tree.title:SetText(a and UA.SpellPresentation(a.spellID) or "Ability configuration")
    if not a then
        tree.scroll:Hide()
        tree.panel.empty:Show()
        return
    end
    tree.scroll:Show()
    tree.panel.empty:Hide()
    local _, baseIcon
    baseIcon = UA.Art.pearl
    if a then _, baseIcon = UA.SpellPresentation(a.spellID) end
    for _, element in ipairs(UA.Elements) do
        if a and element.id == a.baseElement then _, baseIcon = UA.SpellPresentation(element.spell) end
    end
    tree.base.icon:SetTexture(baseIcon)
    tree.base.label:SetText(a and (UA.ElementName(a.baseElement) .. "\n|cffffd100" ..
        (UA.EffectiveElement(a) == a.baseElement and "CURRENT" or "BASE") .. "|r") or "")
    local elements = {}
    local committed = UA.Selected()
    for _, node in ipairs(tree.elements) do
        local selected = a and a.element == node.elementID
        if a and node.elementID ~= a.baseElement then
            elements[#elements + 1] = node
            node:Show()
        else node:Hide() end
        UA.SetNodeState(node, selected, active and UA.SupportsNode(a, 1) and node.elementID ~= a.baseElement)
        UA.SetNodePending(node, selected and committed and a.element ~= committed.element)
    end
    local top = 166 + UA.CenterNodes(elements, tree, 166, 36, 96)
    tree.deliverySection:ClearAllPoints()
    tree.deliverySection:SetPoint("TOPLEFT", 18, -top)
    top = top + 36
    top = top + UA.CenterNodes(tree.modes, tree, top, 36, 96)
    for _, node in ipairs(tree.modes) do
        local supported = a and bit.band(a.modes, bit.lshift(1, node.modeID)) ~= 0
        UA.SetNodeState(node, a and a.mode == node.modeID, active and supported)
        UA.SetNodePending(node, a and committed and a.mode == node.modeID and a.mode ~= committed.mode)
    end
    for _, section in ipairs({ "OFFENSE", "PROPAGATION" }) do
        local visible = {}
        for _, node in ipairs(tree.modifiers) do
            local spec = node.spec
            local supported = a and bit.band(a.modifiers, spec.flag) ~= 0
            local show = spec.section == section and supported and (spec.field ~= "rebound" or a.mode == 5)
            if spec.section == section then
                if show then visible[#visible + 1] = node else node:Hide() end
            end
        end
        tree.sections[section]:ClearAllPoints()
        tree.sections[section]:SetPoint("TOPLEFT", 18, -top)
        tree.sections[section]:SetAlpha(#visible > 0 and 1 or 0)
        local used = UA.CenterNodes(visible, tree, top + 36, 36, 124)
        if #visible > 0 then top = top + 36 + used end
        for _, node in ipairs(visible) do
            local field = node.spec.field
            local changed = committed and a[field] ~= committed[field]
            node:Show()
            node.label:SetText((changed and "|cffffd100" or "") .. node.spec.label .. (changed and "|r" or ""))
            node.rankText:SetText(a[field])
            UA.SetNodeState(node, a[field] > 0, active)
            UA.SetNodePending(node, changed)
        end
    end
    tree:SetHeight(math.max(tree.scroll:GetHeight(), top + 12))
    tree.scroll:UpdateScrollChildRect()
    tree.scroll:SetVerticalScroll(math.min(tree.scroll:GetVerticalScroll(), tree.scroll:GetVerticalScrollRange()))
end
