local UA = UlduarAbilitiesUI
UA.ProtocolVersion = 2
UA.Prefix = "ULDAB1"
UA.sequence = 0
UA.token = "0"

local errors = {
    VERSION = "Client/server protocol versions differ.",
    UNAVAILABLE = "Ulduar Abilities is unavailable on this server.",
    THROTTLED = "Too many requests. Wait a moment, then Refresh.",
    SESSION = "Session expired. Use Refresh to reconnect.",
    REQUEST = "The server rejected this request format.",
    ABILITY = "This ability is not currently available.",
    REJECTED = "The complete build was rejected. Review the confirmed state.",
    STALE = "This ability changed on the server. Your draft was replaced with the current build.",
    BUDGET = "The server rejected the build's Evolution Point budget.",
    LIMIT = "The build exceeds the server's technical propagation limits.",
}

local function split(text)
    local fields = {}
    for field in string.gmatch(text .. "|", "(.-)|") do fields[#fields + 1] = field end
    return fields
end

function UA.Request(operation, abilityID, value)
    if UA.pending then return end
    if operation ~= "HELLO" and not UA.ready then return end
    UA.sequence = UA.sequence + 1
    local token = operation == "HELLO" and "0" or UA.token
    local message = UA.ProtocolVersion .. "|" .. operation .. "|" .. UA.sequence .. "|" .. token
    if abilityID then message = message .. "|" .. abilityID end
    if value ~= nil then message = message .. "|" .. value end
    if #UA.Prefix + 1 + #message > 255 then return end
    UA.pending = { sequence = tostring(UA.sequence), operation = operation, started = GetTime() }
    UA.SetStatus(operation == "HELLO" and "Connecting to Ulduar Abilities..." or "Waiting for server...")
    UA.Refresh()
    -- 3.3.5a global API; no C_ChatInfo or Retail prefix registration.
    SendAddonMessage(UA.Prefix, message, "WHISPER", UnitName("player"))
end

function UA.Receive(prefix, message, channel, sender)
    if prefix ~= UA.Prefix or channel ~= "WHISPER" or not UA.pending then return end
    local ownName = UnitName("player")
    if not ownName then return end
    if sender ~= ownName and sender ~= ownName .. "-" .. GetRealmName() then return end
    if #prefix + 1 + #message > 255 then return end
    local f = split(message)
    local pending = UA.pending
    if f[1] ~= tostring(UA.ProtocolVersion) or f[3] ~= pending.sequence then return end
    local kind = f[2]
    if kind == "WELCOME" and pending.operation == "HELLO" and #f == 4 then
        if not tonumber(f[4]) or tonumber(f[4]) == 0 then return end
        UA.token = f[4]
        return
    end
    if f[4] ~= UA.token and not (kind == "ERROR" and pending.operation == "HELLO" and f[4] == "0") then
        return
    end
    if kind == "ERROR" and #f == 6 then
        pending.error = errors[f[5]] or "Server rejected the change."
        UA.SetStatus(pending.error)
        if f[6] == "1" then
            UA.draft, UA.afterApply = nil, nil
            UA.pending = nil
            UA.ready = false
            UA.abilities, UA.order, UA.rankMap = {}, {}, {}
            UA.Refresh()
        end
        return
    end
    if kind == "BEGIN" and #f == 5 then
        local count = tonumber(f[5])
        if not count or count < 0 or count > 128 then return end
        pending.snapshot = { count = count, abilities = {}, rankMap = {} }
        return
    end
    local snapshot = pending.snapshot
    if not snapshot then return end
    if kind == "RULES" and #f == 17 then
        for i = 5, 17 do if not tonumber(f[i]) or tonumber(f[i]) < 0 then return end end
        snapshot.rules = { elementCost = tonumber(f[5]), coverageCost = tonumber(f[6]),
            potencyCost = tonumber(f[7]), maxRank = tonumber(f[8]), maxTargets = tonumber(f[9]),
            maxRange = tonumber(f[10]), baseTargets = tonumber(f[11]), baseSearch = tonumber(f[12]),
            searchStep = tonumber(f[13]), baseNova = tonumber(f[14]), novaStep = tonumber(f[15]),
            basePotency = tonumber(f[16]), potencyStep = tonumber(f[17]) }
    elseif kind == "BALANCE" and #f == 15 then
        if not snapshot.rules then return end
        local names = { "propagationCap", "meleeCap", "novaCap", "chainStep", "damageStep",
            "cooldownStep", "cooldownCapPct", "castStep", "castCapPct", "castFloor", "modifierCost" }
        for index, name in ipairs(names) do
            local value = tonumber(f[index + 4])
            if not value or value < 0 then return end
            snapshot.rules[name] = value
        end
        snapshot.rules.hasBalance = true
    elseif kind == "DEF" and #f == 14 then
        for i = 5, 14 do if not tonumber(f[i]) then return end end
        local id = tonumber(f[5])
        snapshot.abilities[id] = {
            id = id, spellID = tonumber(f[6]), cast = tonumber(f[7]), targeting = tonumber(f[8]),
            delivery = tonumber(f[9]), temporal = tonumber(f[10]), range = tonumber(f[11]),
            effects = tonumber(f[12]), relation = tonumber(f[13]), modes = tonumber(f[14]),
            nodes = 0,
        }
    elseif kind == "CAPS" and #f == 9 then
        for i = 5, 8 do if not tonumber(f[i]) then return end end
        local a = snapshot.abilities[tonumber(f[5])]
        if not a then return end
        a.nodes, a.classID, a.skillLine = tonumber(f[6]), tonumber(f[7]), tonumber(f[8])
        a.specialization = f[9]
    elseif kind == "MODIFIERS" and #f == 12 then
        for i = 5, 12 do if not tonumber(f[i]) or tonumber(f[i]) < 0 then return end end
        local a = snapshot.abilities[tonumber(f[5])]
        if not a then return end
        a.modifiers, a.damage, a.cooldown, a.castTime, a.rebound =
            tonumber(f[6]), tonumber(f[7]), tonumber(f[8]), tonumber(f[9]), tonumber(f[10])
        a.baseCooldown, a.baseCastTime = tonumber(f[11]) / 1000, tonumber(f[12]) / 1000
    elseif kind == "BASE" and #f == 6 then
        local a = snapshot.abilities[tonumber(f[5])]
        local element = tonumber(f[6])
        if a and element and element >= 1 and element <= 7 then a.baseElement = element end
    elseif kind == "REV" and #f == 6 then
        local a = snapshot.abilities[tonumber(f[5])]
        if a and string.match(f[6], "^%d+$") and f[6] ~= "0" then a.revision = f[6] end
    elseif kind == "STATE" and #f == 17 then
        for i = 5, 17 do if not tonumber(f[i]) then return end end
        local a = snapshot.abilities[tonumber(f[5])]
        if not a then return end
        a.rank, a.points, a.spent = tonumber(f[6]), tonumber(f[7]), tonumber(f[8])
        a.element, a.mode = tonumber(f[9]), tonumber(f[10])
        a.coverage, a.potency = tonumber(f[11]), tonumber(f[12])
        a.targets, a.search, a.radius = tonumber(f[13]), tonumber(f[14]), tonumber(f[15])
        a.multiplier, a.limited = tonumber(f[16]), tonumber(f[17]) == 1
        a.hasState = true
    elseif kind == "RANKS" and #f == 6 then
        local id = tonumber(f[5])
        if not snapshot.abilities[id] then return end
        for spell in string.gmatch(f[6], "%d+") do snapshot.rankMap[tonumber(spell)] = id end
    elseif kind == "END" and #f == 4 then
        local order = {}
        for id, ability in pairs(snapshot.abilities) do
            if not ability.hasState then return end
            if not ability.baseElement or not ability.revision or ability.modifiers == nil or
                not snapshot.rules or not snapshot.rules.hasBalance then
                UA.pending, UA.ready = nil, false
                UA.abilities, UA.order, UA.rankMap = {}, {}, {}
                UA.draft, UA.afterApply = nil, nil
                UA.SetStatus("Server draft metadata missing. Update the server and addon together.")
                UA.Refresh()
                return
            end
            UA.CalculateModifierPreview(ability, snapshot.rules)
            order[#order + 1] = id
        end
        if #order ~= snapshot.count then return end
        table.sort(order, function(left, right)
            local a, b = snapshot.abilities[left], snapshot.abilities[right]
            if (a.classID or 0) ~= (b.classID or 0) then return (a.classID or 0) < (b.classID or 0) end
            if (a.skillLine or 0) ~= (b.skillLine or 0) then return (a.skillLine or 0) < (b.skillLine or 0) end
            return left < right
        end)
        -- Commit atomically. Clicking nodes never mutates these values locally.
        UA.abilities, UA.order, UA.rankMap = snapshot.abilities, order, snapshot.rankMap
        UA.rules = snapshot.rules
        if not UA.abilities[UA.selectedAbility] then UA.selectedAbility = order[1] end
        UA.pending = nil
        UA.ready = true
        UA.SetStatus(pending.error or (#order == 0 and "No runtime abilities available." or "Configuration confirmed."))
        UA.ReconcileDraft(pending)
        UA.Refresh()
    end
end
