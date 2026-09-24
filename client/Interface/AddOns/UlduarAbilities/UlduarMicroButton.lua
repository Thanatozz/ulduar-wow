local UA = UlduarAbilitiesUI
local originalAchievementPoints

function UA.RestoreMicroButtonLayout()
    if InCombatLockdown() then return end
    local achievement = AchievementMicroButton
    if achievement and originalAchievementPoints then
        local _, relative = achievement:GetPoint(1)
        if relative == UA.microButton then
            achievement:ClearAllPoints()
            for _, point in ipairs(originalAchievementPoints) do achievement:SetPoint(unpack(point)) end
        end
    end
    originalAchievementPoints = nil
    if UA.microButton then UA.microButton:Hide() end
end

function UA.LayoutMicroButton()
    if InCombatLockdown() or not UA.microButton then return end
    local talent, achievement, button = TalentMicroButton, AchievementMicroButton, UA.microButton
    if not talent or not achievement or talent:GetParent() ~= MainMenuBarArtFrame or
        achievement:GetParent() ~= talent:GetParent() then
        UA.RestoreMicroButtonLayout()
        return
    end
    local point, relative, relativePoint, x, y = achievement:GetPoint(1)
    if relative == button then
        -- Native followers already use this chain. Never relocate a button during mouse handling.
        button:Show()
        return
    end
    if relative ~= button then
        -- Preserve third-party layouts; only insert into the native horizontal chain.
        if achievement:GetNumPoints() ~= 1 or relative ~= talent or point ~= "BOTTOMLEFT" or
            relativePoint ~= "BOTTOMRIGHT" then
            UA.RestoreMicroButtonLayout()
            return
        end
        originalAchievementPoints = { { point, relative, relativePoint, x, y } }
    end
    button:SetParent(talent:GetParent())
    button:SetSize(talent:GetWidth(), talent:GetHeight())
    button:ClearAllPoints()
    button:SetPoint(point, talent, relativePoint, x, y)
    achievement:ClearAllPoints()
    achievement:SetPoint(point, button, relativePoint, x, y)
    -- Quest and following vanilla buttons already anchor to their predecessor.
    button:Show()
end

function UA.RefreshMicroButton()
    local button = UA.microButton
    if not button or button.mouseDown then return end
    local pushed = UA.frame:IsShown()
    button:SetButtonState(pushed and "PUSHED" or "NORMAL", false)
    button.icon:ClearAllPoints()
    button.icon:SetPoint("TOP", pushed and 1 or 0, pushed and -29 or -28)
end

function UA.CreateMicroButton()
    local parent = MainMenuBarArtFrame or MainMenuBar
    local button = CreateFrame("Button", "UlduarMicroButton", parent, "MainMenuBarMicroButton")
    UA.microButton = button
    LoadMicroButtonTextures(button, "Spellbook")
    button.icon = button:CreateTexture(nil, "OVERLAY")
    button.icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_Pearl_06")
    button.icon:SetSize(18, 25)
    button.tooltipText = "Ulduar Abilities"
    button.newbieText = "Customize your abilities. Open with /ua."
    button:RegisterForClicks("LeftButtonUp")
    -- Let the native Button control its press/release. Locking PUSHED can consume OnClick.
    button:SetScript("OnMouseDown", function(self) self.mouseDown = true end)
    button:SetScript("OnMouseUp", function(self) self.mouseDown = nil end)
    button:SetScript("OnHide", function(self) self.mouseDown = nil end)
    button:SetScript("OnClick", function() UA.Toggle(); UA.RefreshMicroButton() end)
    button:SetScript("OnEvent", function() button.layoutPending = true end)
    button:RegisterEvent("PLAYER_ENTERING_WORLD")
    button:RegisterEvent("UI_SCALE_CHANGED")
    button:RegisterEvent("DISPLAY_SIZE_CHANGED")
    button:RegisterEvent("PLAYER_REGEN_ENABLED")
    button:SetScript("OnUpdate", function(self)
        if self.layoutPending and not InCombatLockdown() and not self.mouseDown then
            self.layoutPending = nil
            UA.LayoutMicroButton()
            UA.RefreshMicroButton()
        end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ulduar Abilities", 1, 1, 1)
        GameTooltip:AddLine("Customize your abilities. Open with /ua.", 1, 0.82, 0, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    hooksecurefunc("UpdateMicroButtons", function() button.layoutPending = true end)
    UA.LayoutMicroButton()
    UA.RefreshMicroButton()
end
