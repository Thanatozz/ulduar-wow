-- Ulduar ALE proof of concept (ALE_INTEGRATION_STRATEGY.md §5). NOT INSTALLED: evaluation only.
-- Requires azerothcore/mod-ale (API as of commit bd74eae623ca). Reads nothing from mod-ulduar-abilities.
-- Copy into lua_scripts/ on a development server, then iterate with `.reload ale`.

local PLAYER_EVENT_ON_COMMAND = 42
local GOSSIP_EVENT_ON_HELLO = 1
local GOSSIP_EVENT_ON_SELECT = 2

-- Set to the entry of a creature you spawned for testing. nil keeps the gossip part disabled, so the
-- script never takes over a real NPC and allocates no id.
local POC_NPC_ENTRY = nil
local POC_VERSION = "1" -- edit, `.reload ale`, and time until the new value shows

-- 1. GM command: `.ulduarpoc` (GM accounts only). Returning false stops core command handling.
local function OnCommand(event, player, command)
    if command ~= "ulduarpoc" then
        return
    end
    if player and not player:IsGM() then
        return
    end
    local text = "[Ulduar ALE POC] version " .. POC_VERSION .. ", reloaded at " .. os.date("%H:%M:%S")
    if player then
        player:SendBroadcastMessage(text)
    else
        print(text)
    end
    return false
end
RegisterPlayerEvent(PLAYER_EVENT_ON_COMMAND, OnCommand)

-- 2. Gossip NPC: one menu, one reply. npc_text 100 is the stock default header.
if POC_NPC_ENTRY then
    local function OnHello(event, player, creature)
        player:GossipClearMenu()
        player:GossipMenuAddItem(0, "Ulduar ALE POC (version " .. POC_VERSION .. ")", 1, 1)
        player:GossipSendMenu(100, creature)
    end

    local function OnSelect(event, player, creature, sender, intid)
        player:SendBroadcastMessage("[Ulduar ALE POC] selected " .. intid)
        player:GossipComplete()
    end

    RegisterCreatureGossipEvent(POC_NPC_ENTRY, GOSSIP_EVENT_ON_HELLO, OnHello)
    RegisterCreatureGossipEvent(POC_NPC_ENTRY, GOSSIP_EVENT_ON_SELECT, OnSelect)
end
