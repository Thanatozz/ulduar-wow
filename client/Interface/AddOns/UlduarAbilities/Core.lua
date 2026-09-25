UlduarAbilitiesUI = { abilities = {}, order = {}, rankMap = {}, selectedTab = 1 }
local UA = UlduarAbilitiesUI

function UA.SpellPresentation(spellID)
    local name, _, icon = GetSpellInfo(spellID)
    return name or ("Spell " .. spellID), icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function UA.Selected()
    return UA.abilities[UA.selectedAbility]
end

function UA.CanChange()
    return UA.ready and not UA.pending and UA.Selected() ~= nil
end

function UA.SetStatus(text)
    UA.status = text
    if UA.frame then UA.frame.status:SetText(text or "") end
end

function UA.Refresh()
    if not UA.frame then return end
    UA.RefreshList()
    UA.RefreshTree()
    UA.RefreshDetails()
    UA.RefreshPoints()
    UA.RefreshMicroButton()
    UA.RefreshSpellBook()
end

function UA.SelectAbility(id)
    if not UA.abilities[id] then return end
    if id == UA.selectedAbility then UA.SelectTab(1); return end
    UA.GuardDraftAction(function()
        UA.selectedAbility = id
        UA.BeginDraft()
        UA.SelectTab(1)
        UA.Refresh()
    end)
end

function UA.Open(id)
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage("Ulduar Abilities: open this window after combat.", 1, 0.82, 0)
        return
    end
    if not UA.frame:IsShown() then
        if id and UA.abilities[id] then UA.selectedAbility = id; UA.SelectTab(1) end
        UA.frame:Show()
    elseif id then UA.SelectAbility(id) end
end

function UA.Toggle()
    if UA.frame:IsShown() then UA.RequestClose() else UA.Open() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("CHAT_MSG_ADDON")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:RegisterEvent("SPELLS_CHANGED")
events:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and (...) == "UlduarAbilities" then
        if type(UlduarAbilitiesDB) ~= "table" then UlduarAbilitiesDB = {} end
        UA.CreateUlduarFrame()
        UA.CreateMicroButton()
        UA.CreateSpellBookIntegration()
        UA.InstallAbilityTooltips()
        SLASH_ULDUARABILITIES1 = "/ua"
        SlashCmdList.ULDUARABILITIES = function(message)
            if message == "resetposition" then UA.ResetWindowPosition()
            elseif message == "lab" then UA.Lab.Toggle()
            else UA.Toggle() end
        end
        -- Developer Ability Lab (server-gated: GM + UlduarAbilities.DebugEditor).
        SLASH_ULDUARABILITYLAB1 = "/ualab"
        SlashCmdList.ULDUARABILITYLAB = function() UA.Lab.Toggle() end
        UA.Refresh()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Loading screens invalidate outstanding transactions. Never replay a mutation.
        UA.pending = nil
        UA.draft, UA.afterApply = nil, nil
        UA.ready = false
        UA.token = "0"
        UA.handshakeAt = GetTime() + 1
        UA.Refresh()
    elseif event == "CHAT_MSG_ADDON" then
        UA.Receive(...)
        UA.Lab.Receive(...)
    elseif event == "PLAYER_REGEN_ENABLED" then
        UA.RefreshSpellBook()
        UA.LayoutMicroButton()
    elseif event == "SPELLS_CHANGED" then
        UA.refreshAt = GetTime() + 1
    elseif event == "DISPLAY_SIZE_CHANGED" and UA.frame then
        UA.FitFrame()
    end
end)
events:SetScript("OnUpdate", function(self, elapsed)
    UA.cancelModalClose = nil
    UA.Lab.Update()
    if UA.refreshAt and GetTime() >= UA.refreshAt and UA.ready and not UA.pending then
        UA.refreshAt = nil
        UA.Request("GET")
    end
    if UA.handshakeAt and GetTime() >= UA.handshakeAt then
        UA.handshakeAt = nil
        UA.Request("HELLO")
    end
    if UA.pending and GetTime() - UA.pending.started > 8 then
        UA.pending = nil
        UA.afterApply = nil
        UA.ready = false
        UA.SetStatus("No server response. Use Refresh to reconnect; no change has been retried.")
        UA.Refresh()
    end
end)
