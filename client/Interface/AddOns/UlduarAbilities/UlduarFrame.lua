local UA = UlduarAbilitiesUI

function UA.FitFrame()
    local scale = math.min(1, (UIParent:GetWidth() - 32) / UA.Layout.width,
        (UIParent:GetHeight() - 54) / (UA.Layout.height + 30))
    UA.frame:SetScale(math.max(0.25, scale))
end

function UA.ResetWindowPosition()
    UlduarAbilitiesDB.framePosition = nil
    UA.frame:ClearAllPoints()
    UA.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

function UA.SaveWindowPosition()
    local point, _, relativePoint, x, y = UA.frame:GetPoint(1)
    UlduarAbilitiesDB.framePosition = { point = point, relativePoint = relativePoint, x = x, y = y }
end

function UA.RestoreWindowPosition()
    local p = UlduarAbilitiesDB.framePosition
    local anchors = { CENTER = true, TOP = true, BOTTOM = true, LEFT = true, RIGHT = true,
        TOPLEFT = true, TOPRIGHT = true, BOTTOMLEFT = true, BOTTOMRIGHT = true }
    if type(p) ~= "table" or not anchors[p.point] or not anchors[p.relativePoint] or
        type(p.x) ~= "number" or type(p.y) ~= "number" or p.x ~= p.x or p.y ~= p.y or
        math.abs(p.x) > 10000 or math.abs(p.y) > 10000 then
        UA.ResetWindowPosition()
        return
    end
    UA.frame:ClearAllPoints()
    UA.frame:SetPoint(p.point, UIParent, p.relativePoint, p.x, p.y)
end

function UA.RefreshPoints()
    local frame, a = UA.frame, UA.Preview()
    if not frame then return end
    frame.points:SetText("Evolution Points: " .. (a and (a.budget or (a.points + a.spent)) or "--"))
    local key = a and (a.id .. ":" .. a.points) or "none"
    if frame.pointsKey ~= key then
        frame.pointsKey = key
        ButtonPulse_StopPulse(frame.points)
        frame.points:UnlockHighlight()
        if a and a.points > 0 then SetButtonPulse(frame.points, 6, 0.8) end
    end
    if UA.CanEditDraft() then frame.reset:Enable() else frame.reset:Disable() end
    local dialogOpen = UA.leaveDialog:IsShown()
    if UA.pending or dialogOpen then frame.refresh:Disable() else frame.refresh:Enable() end
    if UA.CanConfirmDraft() and not dialogOpen then frame.confirm:Enable() else frame.confirm:Disable() end
    if UA.IsDraftDirty() and not UA.pending and not dialogOpen then frame.discard:Enable()
    else frame.discard:Disable() end
    local dirty, error = UA.IsDraftDirty(), UA.DraftError()
    if UA.pending and UA.pending.operation == "APPLY_BUILD" then
        frame.status:SetText("|cffffd100Confirming build...|r")
    elseif dirty then
        frame.status:SetText("|cffffd100Unsaved Changes|r" .. (error and ("  |cffff4040" .. error .. "|r") or ""))
    else frame.status:SetText(UA.status or "") end
end

function UA.CreateUlduarFrame()
    local frame = CreateFrame("Frame", "UlduarFrame", UIParent, "UlduarAbilitiesWindowTemplate")
    UA.frame = frame
    frame:Hide()
    UA.CreateDraftDialog()
    frame:SetSize(UA.Layout.width, UA.Layout.height)
    frame:SetBackdropColor(0.06, 0.05, 0.04, 1)
    frame:SetBackdropBorderColor(0.85, 0.78, 0.62, 1)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    local drag = CreateFrame("Frame", nil, frame)
    drag:SetPoint("TOPLEFT", 74, -8)
    drag:SetPoint("TOPRIGHT", -40, -8)
    drag:SetHeight(56)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() frame:StartMoving() end)
    drag:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        UA.SaveWindowPosition()
    end)
    local header = UA.Inset(frame, UA.Layout.width - 30, 56)
    header:SetPoint("TOPLEFT", 15, -12)
    header:SetBackdropColor(0.13, 0.105, 0.06, 1)
    -- Decorative header cannot intercept the dedicated drag handle.
    header:EnableMouse(false)
    local crest = header:CreateTexture(nil, "ARTWORK")
    crest:SetTexture(UA.Art.pearl)
    crest:SetSize(40, 40)
    crest:SetPoint("LEFT", 10, 0)
    local crestBorder = header:CreateTexture(nil, "OVERLAY")
    crestBorder:SetTexture(UA.Art.border)
    crestBorder:SetSize(64, 64)
    crestBorder:SetPoint("CENTER", crest, "CENTER")
    UA.Label(header, "Ulduar Abilities", "GameFontNormalLarge", 64, -10)
    UA.Label(header, "Shape your abilities", "GameFontHighlightSmall", 65, -32)
    drag:SetFrameLevel(header:GetFrameLevel() + 1)
    local close = CreateFrame("Button", "UlduarFrameCloseButton", frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -4)
    close:SetFrameLevel(drag:GetFrameLevel() + 2)
    close:SetScript("OnClick", UA.RequestClose)
    frame.points = CreateFrame("Button", nil, frame)
    frame.points:SetPoint("TOPRIGHT", -46, -28)
    frame.points:SetFrameLevel(drag:GetFrameLevel() + 1)
    frame.points:SetSize(240, 24)
    frame.points:SetNormalFontObject(GameFontNormal)
    frame.points:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    frame.points:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Evolution Points", 1, 0.82, 0)
        GameTooltip:AddLine("Preview your full budget. Changes affect gameplay only after Confirm.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    frame.points:SetScript("OnLeave", function() GameTooltip:Hide() end)
    UA.CreateTabs(frame)
    UA.CreateAbilityList(frame.pages[1])
    UA.CreateAbilityTree(frame.pages[1])
    UA.CreateAbilityDetails(frame.pages[1])
    frame.status = UA.Label(frame, "", "GameFontHighlightSmall", 24, -UA.Layout.height + 72)
    frame.status:SetSize(UA.Layout.contentWidth - 16, 26)
    frame.status:SetJustifyV("TOP")
    frame.status:SetJustifyH("LEFT")
    frame.refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.refresh:SetPoint("BOTTOMLEFT", 24, 20)
    frame.refresh:SetSize(100, 22)
    frame.refresh:SetText("Refresh")
    frame.refresh:SetScript("OnClick", function() UA.Request(UA.ready and "GET" or "HELLO") end)
    frame.reset = CreateFrame("Button", nil, frame.pages[1], "UIPanelButtonTemplate")
    frame.reset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 20)
    frame.reset:SetSize(122, 22)
    frame.reset:SetText("Reset Ability")
    frame.reset:SetScript("OnClick", function() UA.EditDraft("RESET") end)
    frame.discard = CreateFrame("Button", nil, frame.pages[1], "UIPanelButtonTemplate")
    frame.discard:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -308, 20)
    frame.discard:SetSize(140, 22)
    frame.discard:SetText("Discard Changes")
    frame.discard:SetScript("OnClick", UA.DiscardDraft)
    frame.confirm = CreateFrame("Button", nil, frame.pages[1], "UIPanelButtonTemplate")
    frame.confirm:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -170, 20)
    frame.confirm:SetSize(120, 22)
    frame.confirm:SetText("Confirm")
    frame.confirm:SetScript("OnClick", function() UA.ConfirmDraft() end)
    -- Standalone: UIPanel's center layout would overwrite the saved drag position.
    tinsert(UISpecialFrames, "UlduarFrame")
    frame:SetScript("OnShow", function()
        if UA.internalReopen then return end
        UA.FitFrame()
        UA.BeginDraft()
        frame.pointsKey = nil
        PlaySound("igCharacterInfoOpen")
        UA.Refresh()
        if not UA.pending then UA.Request(UA.ready and "GET" or "HELLO") end
    end)
    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        UA.SaveWindowPosition()
        if not UA.allowHide and (UA.IsDraftDirty() or UA.pending) then
            -- ESC hides UISpecialFrames directly. Reopen without a GET or resetting the draft.
            UA.internalReopen = true
            frame:Show()
            UA.internalReopen = nil
            if UA.cancelModalClose then return end
            UA.RequestClose()
            return
        end
        UA.leaveDialog:Hide()
        if UA.list then UA.list.search:ClearFocus() end
        UA.draft = nil
        GameTooltip:Hide()
        ButtonPulse_StopPulse(frame.points)
        frame.points:UnlockHighlight()
        PlaySound("igCharacterInfoClose")
        UA.RefreshMicroButton()
    end)
    UA.FitFrame()
    UA.RestoreWindowPosition()
end
