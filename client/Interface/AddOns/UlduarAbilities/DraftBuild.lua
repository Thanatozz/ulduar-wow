local UA = UlduarAbilitiesUI
local fields = { "element", "mode", "coverage", "potency", "damage", "cooldown", "castTime", "rebound" }
UA.ModifierNodes = {
    { field = "damage", label = "Damage", flag = 1, icon = 133, section = "OFFENSE" },
    { field = "castTime", label = "Cast Time", flag = 4, icon = 12472, section = "OFFENSE" },
    { field = "cooldown", label = "Cooldown", flag = 2, icon = 11958, section = "OFFENSE" },
    { field = "coverage", label = "Coverage", flag = 8, icon = 1449, section = "PROPAGATION" },
    { field = "potency", label = "Potency", flag = 16, icon = 12042, section = "PROPAGATION" },
    { field = "rebound", label = "Rebound", flag = 32, icon = 421, section = "PROPAGATION" },
}

function UA.CalculateModifierPreview(a, r)
    a.primaryMultiplier = 1 + a.damage * r.damageStep / 100
    a.cooldownSeconds = math.max(0.001, a.baseCooldown - math.min(a.cooldown * r.cooldownStep,
        a.baseCooldown * r.cooldownCapPct / 100))
    a.castSeconds = math.min(a.baseCastTime, math.max(r.castFloor,
        a.baseCastTime - math.min(a.castTime * r.castStep, a.baseCastTime * r.castCapPct / 100)))
    a.reboundGap = 5 - math.min(math.floor(a.rebound / 3), 3)
end

local function copy(source)
    local target = {}
    for key, value in pairs(source) do target[key] = value end
    return target
end

function UA.BeginDraft()
    local committed = UA.Selected()
    UA.draft = committed and { base = copy(committed), view = copy(committed), rules = UA.rules } or nil
    if UA.draft then UA.draft.view.isDraft = true; UA.RecalculateDraft() end
end

function UA.IsDraftDirty()
    if not UA.draft then return false end
    for _, field in ipairs(fields) do
        if UA.draft.view[field] ~= UA.draft.base[field] then return true end
    end
    return false
end

function UA.Preview(id)
    if UA.draft and UA.draft.view.id == (id or UA.selectedAbility) then return UA.draft.view end
    if id then return UA.abilities[id] end
    return UA.Selected()
end

function UA.RecalculateDraft()
    if not UA.draft or not UA.draft.rules then return end
    local a, base, r = UA.draft.view, UA.draft.base, UA.draft.rules
    a.budget = base.points + base.spent
    a.spent = (a.element ~= 0 and r.elementCost or 0) + a.coverage * r.coverageCost + a.potency * r.potencyCost
        + (a.damage + a.cooldown + a.castTime + a.rebound) * r.modifierCost
    a.points = a.budget - a.spent
    a.multiplier = r.basePotency + a.potency * r.potencyStep
    if bit.band(a.modifiers, 16) == 0 then a.multiplier = 1 end
    a.targets, a.search, a.radius, a.limited = 0, 0, 0, false
    if a.mode == 4 then
        local radius = math.min(r.novaCap, r.baseNova + a.coverage * r.novaStep)
        a.radius, a.limited = math.min(radius, r.maxRange), radius > r.maxRange
    elseif a.mode ~= 0 then
        local targets = r.baseTargets + a.coverage
        local search = math.min((a.cast == 3 or a.range == 0) and r.meleeCap or r.propagationCap,
            r.baseSearch + a.coverage * (a.mode == 5 and r.chainStep or r.searchStep))
        a.targets, a.search = math.min(targets, r.maxTargets), math.min(search, r.maxRange)
        a.limited = targets > r.maxTargets or search > r.maxRange
    end
    UA.CalculateModifierPreview(a, r)
end

function UA.CanEditDraft()
    return UA.CanChange() and UA.draft and UA.draft.rules and not UA.leaveDialog:IsShown()
end

function UA.DraftError()
    local a, committed = UA.Preview(), UA.Selected()
    if not UA.draft or not a or not committed then return "No editable build." end
    if UA.draft.base.revision ~= committed.revision then return "Server state changed. Cancel Changes to reload." end
    if a.points < 0 then return "Draft exceeds the Evolution Point budget." end
    if a.limited then return "Draft exceeds server technical limits." end
end

function UA.CanConfirmDraft()
    return UA.CanChange() and UA.IsDraftDirty() and not UA.DraftError()
end

function UA.EditDraft(operation, value, mouseButton)
    if not UA.CanEditDraft() then return end
    local a, r = UA.draft.view, UA.draft.rules
    if operation == "MODIFIER" then
        local field, flag = value.field, value.flag
        local delta = mouseButton == "RightButton" and -1 or 1
        if delta > 0 and bit.band(a.modifiers, flag) == 0 then return end
        if field == "rebound" and a.mode ~= 5 then return end
        a[field] = math.max(0, math.min(r.maxRank, a[field] + delta))
    elseif operation == "ELEMENT" and UA.SupportsNode(a, 1) then
        -- Clicking the selected conversion again removes it in the draft, without a live respec.
        a.element = (value == a.element or value == a.baseElement) and 0 or value
    elseif operation == "MODE" and bit.band(a.modes, bit.lshift(1, value)) ~= 0 then
        a.mode = a.mode == value and 0 or value
        if a.mode ~= 5 then a.rebound = 0 end
    elseif operation == "RESET" then
        a.element, a.mode, a.coverage, a.potency = 0, 0, 0, 0
        a.damage, a.cooldown, a.castTime, a.rebound = 0, 0, 0, 0
    else return end
    UA.RecalculateDraft()
    UA.Refresh()
    local owner = GameTooltip:GetOwner()
    if GameTooltip:IsShown() and owner and owner.tooltip then
        local enter = owner:GetScript("OnEnter")
        if enter then enter(owner) end
    end
end

function UA.DiscardDraft()
    UA.BeginDraft()
    UA.SetStatus("Unconfirmed changes discarded. Gameplay was not changed.")
    UA.Refresh()
end

function UA.ConfirmDraft(afterApply)
    if not UA.CanConfirmDraft() then return end
    local a = UA.draft.view
    UA.afterApply = afterApply
    UA.Request("APPLY_BUILD", a.id, table.concat({ UA.draft.base.revision,
        a.element, a.mode, a.coverage, a.potency, a.damage, a.cooldown, a.castTime, a.rebound }, "|"))
end

function UA.ReconcileDraft(pending)
    local action = UA.afterApply
    UA.afterApply = nil
    if pending.operation == "APPLY_BUILD" or not UA.IsDraftDirty() or
        not UA.draft or UA.draft.view.id ~= UA.selectedAbility then
        UA.BeginDraft()
    end
    if pending.operation == "APPLY_BUILD" and not pending.error and action then action() end
end

function UA.GuardDraftAction(action)
    if UA.pending then UA.SetStatus("Waiting for server confirmation..."); return end
    if UA.leaveDialog:IsShown() then return end
    if not UA.IsDraftDirty() then action(); return end
    UA.leaveDialog.action = action
    if UA.CanConfirmDraft() then UA.leaveDialog.apply:Enable() else UA.leaveDialog.apply:Disable() end
    UA.leaveDialog:Show()
    UA.Refresh()
end

function UA.RequestClose()
    UA.GuardDraftAction(function()
        UA.allowHide = true
        UA.frame:Hide()
        UA.allowHide = nil
        UA.draft = nil
    end)
end

function UA.CreateDraftDialog()
    -- Full-screen mouse shield. ESC hides this dialog and preserves the draft.
    local dialog = CreateFrame("Frame", "UlduarDraftDialog", UIParent)
    UA.leaveDialog = dialog
    dialog:Hide()
    dialog:SetFrameStrata("FULLSCREEN_DIALOG")
    dialog:SetAllPoints(UIParent)
    dialog:EnableMouse(true)
    dialog:EnableMouseWheel(true)
    dialog:SetScript("OnMouseWheel", function() end)
    local shade = dialog:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints(UA.frame)
    shade:SetTexture(0, 0, 0, 0.7)
    local panel = CreateFrame("Frame", nil, dialog)
    panel:SetSize(370, 140)
    panel:SetPoint("CENTER", UA.frame, "CENTER")
    panel:EnableMouse(true)
    panel:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 } })
    panel:SetBackdropColor(0.12, 0.09, 0.05, 1)
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -25)
    title:SetText("Unconfirmed Changes")
    local text = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOP", 0, -52)
    text:SetText("Confirm this build or discard your changes?")
    for index, label in ipairs({ "Confirm", "Discard" }) do
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(130, 24)
        button:SetPoint("BOTTOMLEFT", 48 + (index - 1) * 144, 24)
        button:SetText(label)
        if index == 1 then
            dialog.apply = button
            button:SetScript("OnClick", function()
                local action = dialog.action
                dialog:Hide()
                UA.ConfirmDraft(action)
                UA.Refresh()
            end)
        else
            button:SetScript("OnClick", function()
                local action = dialog.action
                dialog:Hide()
                UA.DiscardDraft()
                if action then action() end
            end)
        end
    end
    tinsert(UISpecialFrames, "UlduarDraftDialog")
    dialog:SetScript("OnHide", function()
        -- WotLK CloseSpecialWindows hides every UISpecialFrame in the same call, not just the top one.
        UA.cancelModalClose = true
        dialog.action = nil
        UA.Refresh()
    end)
end
