local UA = UlduarAbilitiesUI
local markers = {}

local function updateMarker(index)
    if InCombatLockdown() then return end
    local marker = markers[index]
    if not marker then return end
    marker:Hide()
    if not UA.ready or not SpellBookFrame:IsShown() or SpellBookFrame.bookType ~= BOOKTYPE_SPELL then return end
    local spellButton = _G["SpellButton" .. index]
    if not spellButton or not spellButton:IsShown() then return end
    local slot = SpellBook_GetSpellID(spellButton:GetID())
    if not slot then return end
    -- In this client SpellBook_GetSpellID returns a book SLOT, not a Blizzard spell ID.
    local link = GetSpellLink(slot, BOOKTYPE_SPELL)
    local spellID = link and tonumber(string.match(link, "spell:(%d+)"))
    local abilityID = spellID and UA.rankMap[spellID]
    if abilityID and UA.abilities[abilityID] then
        marker.abilityID = abilityID
        marker:Show()
    end
end

function UA.RefreshSpellBook()
    for index = 1, SPELLS_PER_PAGE do updateMarker(index) end
end

function UA.CreateSpellBookIntegration()
    for index = 1, SPELLS_PER_PAGE do
        local spellButton = _G["SpellButton" .. index]
        if spellButton then
            -- Sibling, not a replacement or child of the protected spell action button.
            local marker = CreateFrame("Button", nil, SpellBookFrame)
            marker:SetSize(16, 16)
            -- Inside the text column, beside the rank line, away from the page edge.
            marker:SetPoint("TOPLEFT", spellButton, "TOPRIGHT", 88, -22)
            marker:SetNormalTexture("Interface\\Icons\\INV_Misc_Gem_Pearl_06")
            marker:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
            marker:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
            marker:SetScript("OnEnter", function(self)
                local a = UA.abilities[self.abilityID]
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Configure " .. (a and UA.SpellPresentation(a.spellID) or "ability"), 1, 0.82, 0)
                UA.AppendAbilityTooltip(GameTooltip, a)
                GameTooltip:Show()
            end)
            marker:SetScript("OnLeave", function() GameTooltip:Hide() end)
            marker:SetScript("OnClick", function(self) UA.Open(self.abilityID) end)
            marker:Hide()
            markers[index] = marker
        end
    end
    -- XML names are interleaved by column; GetID() is not the name suffix.
    hooksecurefunc("SpellButton_UpdateButton", function(button)
        local index = tonumber(string.match(button:GetName() or "", "^SpellButton(%d+)$"))
        if index then updateMarker(index) end
    end)
    SpellBookFrame:HookScript("OnShow", UA.RefreshSpellBook)
    local events = CreateFrame("Frame")
    events:RegisterEvent("SPELLS_CHANGED")
    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    events:SetScript("OnEvent", function(self, event)
        if event == "SPELLS_CHANGED" then UA.RefreshSpellBook() end
        -- Protected Spellbook updates are deferred until PLAYER_REGEN_ENABLED in Core.lua.
    end)
end
