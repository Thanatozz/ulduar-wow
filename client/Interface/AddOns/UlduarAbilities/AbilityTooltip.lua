local UA = UlduarAbilitiesUI
local classes = { [1] = "Warrior", [2] = "Paladin", [3] = "Hunter", [4] = "Rogue", [5] = "Priest",
    [6] = "Death Knight", [7] = "Shaman", [8] = "Mage", [9] = "Warlock", [11] = "Druid" }

function UA.SupportsNode(ability, flag)
    return ability and bit.band(ability.nodes or 0, flag) ~= 0
end

function UA.CatalogLabel(ability)
    if not ability or not ability.specialization then return "" end
    return (classes[ability.classID] or "") .. " / " .. ability.specialization
end
UA.Elements = {
    { id = 5, name = "Frost", spell = 116 },
    { id = 3, name = "Fire", spell = 133 }, { id = 4, name = "Nature", spell = 403 },
    { id = 7, name = "Arcane", spell = 30451 }, { id = 6, name = "Shadow", spell = 686 },
    { id = 2, name = "Holy", spell = 2061 },
}
UA.Modes = {
    { id = 1, name = "Impact", spell = 30451,
      description = "Secondary targets are struck instantly when the primary target is hit." },
    { id = 2, name = "Split", spell = 2643,
      description = "Launches additional copies from the caster toward secondary targets." },
    { id = 3, name = "Shatter", spell = 30455,
      description = "After striking the primary target, additional projectiles spread from the impact target." },
    { id = 4, name = "Nova", spell = 1449,
      description = "The primary impact releases an area effect around the target." },
    { id = 5, name = "Chain", spell = 421,
      description = "The spell jumps sequentially from target to target." },
}

function UA.ElementName(id)
    if id == 1 then return "Physical" end
    for _, e in ipairs(UA.Elements) do if e.id == id then return e.name end end
    return "Unknown"
end

function UA.EffectiveElement(a)
    return a.element == 0 and a.baseElement or a.element
end

function UA.ElementText(a)
    local current = UA.EffectiveElement(a)
    local text = UA.ElementName(current)
    if current ~= a.baseElement then text = text .. "\n|cffffd100Base Element|r  " .. UA.ElementName(a.baseElement) end
    return text
end

function UA.SecondaryEffectLabel(a)
    local damage, healing = bit.band(a.effects, 1) ~= 0, bit.band(a.effects, 2) ~= 0
    if damage and not healing then return "Secondary Damage" end
    if healing and not damage then return "Secondary Healing" end
    return "Secondary Effect"
end

-- Committed numbers come from STATE; explicitly labelled draft previews use server RULES.
-- Never modifies native tooltip text or treats a preview as a successful commit.
function UA.AbilityTooltipDescriptor(a)
    return { baseElement = a.baseElement, currentElement = UA.EffectiveElement(a),
        mode = a.mode, coverageRank = a.coverage, potencyRank = a.potency,
        targets = a.targets, search = a.search, radius = a.radius, multiplier = a.multiplier,
        cast = a.cast, targeting = a.targeting, delivery = a.delivery, temporal = a.temporal,
        effects = a.effects, range = a.range, relation = a.relation,
        damageRank = a.damage, cooldownRank = a.cooldown, castTimeRank = a.castTime, reboundRank = a.rebound,
        primaryMultiplier = a.primaryMultiplier, cooldownSeconds = a.cooldownSeconds,
        castSeconds = a.castSeconds, reboundGap = a.reboundGap }
end

function UA.PropagationTooltipText(a, mode)
    local d = UA.AbilityTooltipDescriptor(a)
    mode = mode or d.mode
    local relation = d.relation == 0 and "enemies" or (d.relation == 1 and "allies" or "valid targets")
    if mode == 0 then return "No propagation selected." end
    -- Non-selected delivery nodes must not present another mode's STATE numbers as their own.
    if mode ~= d.mode then
        for _, m in ipairs(UA.Modes) do if m.id == mode then return m.description end end
    end
    if mode == 1 then
        return string.format("On impact, instantly affects up to %d additional %s within %.0f yd.",
            d.targets, relation, d.search)
    elseif mode == 2 then
        return string.format("Launches additional copies toward up to %d secondary targets within %.0f yd.",
            d.targets, d.search)
    elseif mode == 3 then
        return string.format("After striking the primary target, launches additional projectiles from " ..
            "the impact target toward up to %d %s within %.0f yd.", d.targets, relation, d.search)
    elseif mode == 4 then
        return string.format("On impact, affects all valid %s within %.0f yd.", relation, d.radius)
    elseif mode == 5 then
        return string.format("Jumps sequentially to up to %d additional targets. " ..
            "Each jump searches within %.0f yd of the previous target.", d.targets, d.search)
    end
    return ""
end

-- Mirror of the server's SecondaryOutputLines: one common line, signed lines only where a component
-- differs. Projectile/Area/Echo scaling stay separate on the server; this is presentation only.
function UA.SecondaryOutputLines(o)
    local noun = o.healing and "Healing" or "Damage"
    local parts = { { "Projectile", o.projectile }, { "Area", o.area }, { "Echo", o.echo } }
    local common
    for _, part in ipairs(parts) do
        if part[2] and part[2] >= 0 and not common then common = part[2] end
    end
    if not common then return {} end
    local lines = { string.format("Secondary %s: %.0f%%", noun, common) }
    for _, part in ipairs(parts) do
        local value = part[2]
        if value and value >= 0 and math.floor(value + 0.5) ~= math.floor(common + 0.5) then
            lines[#lines + 1] = string.format("%s %s: %+.0f%%", part[1], noun, value - common)
        end
    end
    return lines
end

-- Three levels (server PRIMARY_OUTPUT.md): the normal line says what the ability does in WoW language;
-- Shift adds resolved numbers; engine properties and formulas belong to the Forge/Lab only.
function UA.AppendOutputLines(tooltip, a)
    local o = a.output
    if not o then return end
    local element = (o.element and o.element > 0) and UA.ElementName(o.element) or UA.ElementName(a.baseElement)
    if o.direct and o.direct > 0 then
        local text
        if o.healing then
            text = string.format("Heals the target for %d", o.direct)
            if o.periodic > 0 then
                text = text .. string.format(" and an additional %d over %s sec", o.periodic, o.duration)
            end
        else
            text = string.format("Deals %d %s damage", o.direct, element)
            if o.periodic > 0 then
                text = text .. string.format(" and an additional %d %s damage over %s sec", o.periodic, element,
                    o.duration)
            end
        end
        tooltip:AddLine(text .. ".", 1, 0.82, 0, true)
    end
    local secondary = UA.SecondaryOutputLines(o)
    if IsShiftKeyDown() then
        local noun = o.healing and "Healing" or "Damage"
        if o.direct > 0 then tooltip:AddLine(string.format("Direct %s: %d", noun, o.direct), 1, 1, 1) end
        if o.periodic > 0 then
            tooltip:AddLine(string.format("Periodic %s: %d", noun, o.periodic), 1, 1, 1)
            tooltip:AddLine(string.format("Periodic Duration: %s sec", o.duration), 1, 1, 1)
            tooltip:AddLine(string.format("Tick Interval: %s sec", o.interval), 1, 1, 1)
        end
        for _, line in ipairs(secondary) do tooltip:AddLine(line, 1, 1, 1) end
    elseif o.periodic > 0 or #secondary > 0 then
        tooltip:AddLine("Hold Shift for details.", 0.5, 0.5, 0.5)
    end
end

-- Re-show the hovered tooltip when Shift changes, so the advanced lines appear/disappear.
local modifierWatcher = CreateFrame("Frame")
modifierWatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
modifierWatcher:SetScript("OnEvent", function()
    if not GameTooltip:IsShown() or not GameTooltip.ulduarAbilityAdded then return end
    local owner = GameTooltip:GetOwner()
    local onEnter = owner and owner:GetScript("OnEnter")
    if onEnter then onEnter(owner) end
end)

function UA.AppendAbilityTooltip(tooltip, a)
    if not UA.ready or not a or tooltip.ulduarAbilityAdded then return end
    local owner = tooltip:GetOwner()
    while owner do
        if owner == UA.frame then a = UA.Preview(a.id); break end
        owner = owner:GetParent()
    end
    tooltip.ulduarAbilityAdded = true
    tooltip:AddLine(" ")
    UA.AppendOutputLines(tooltip, a)
    tooltip:AddLine("Ulduar Abilities - Rank " .. a.rank, 1, 0.82, 0)
    tooltip:AddLine(a.isDraft and "Draft preview - not applied" or "Committed build", 1, 0.82, 0)
    tooltip:AddLine("Element: " .. UA.ElementName(UA.EffectiveElement(a)), 1, 1, 1)
    if UA.EffectiveElement(a) ~= a.baseElement then
        tooltip:AddLine("Base Element: " .. UA.ElementName(a.baseElement), 1, 1, 1)
        tooltip:AddLine("Element conversion does not replace the original aura's school.", 0.75, 0.75, 0.75, true)
    end
    tooltip:AddLine(UA.ModeName(a.mode), 1, 0.82, 0)
    tooltip:AddLine(UA.PropagationTooltipText(a), 1, 1, 1, true)
    tooltip:AddLine("Coverage Rank " .. a.coverage .. " / Potency Rank " .. a.potency, 1, 0.82, 0)
    if a.mode ~= 0 then
        local potency = UA.SupportsNode(a, 4) and
            string.format("%s: %.0f%%", UA.SecondaryEffectLabel(a), a.multiplier * 100) or
            "Secondary Effect: original strength"
        tooltip:AddLine(potency, 1, 1, 1, true)
    end
    if a.damage and a.damage > 0 then
        tooltip:AddLine(string.format("Primary Damage: %.0f%%", a.primaryMultiplier * 100), 1, 1, 1)
    end
    if a.cooldown and a.cooldown > 0 then
        tooltip:AddLine(string.format("Base cooldown after modifier: %.2f sec", a.cooldownSeconds), 1, 1, 1)
    end
    if a.castTime and a.castTime > 0 then
        tooltip:AddLine(string.format("Base cast time after modifier: %.2f sec (before haste)", a.castSeconds),
            1, 1, 1, true)
    end
    if a.mode == 5 then
        tooltip:AddLine(a.rebound > 0 and ("Rebound: " .. a.reboundGap .. " other hops between hits") or
            "Rebound locked: no revisits", 1, 1, 1, true)
    end
    if a.isDraft then
        tooltip:AddLine("Remaining after Confirm: " .. a.points, 1, 0.82, 0)
    elseif a.points > 0 then tooltip:AddLine(a.points .. " Evolution Points available", 0.2, 1, 0.2) end
end

function UA.InstallAbilityTooltips()
    local tooltip = GameTooltip
    tooltip:HookScript("OnTooltipCleared", function(self) self.ulduarAbilityAdded = nil end)
    tooltip:HookScript("OnTooltipSetSpell", function(self)
        local _, _, id = self:GetSpell()
        UA.AppendAbilityTooltip(self, UA.abilities[UA.rankMap[id]])
    end)
    hooksecurefunc(tooltip, "SetSpell", function(self, slot, bookType)
        if bookType ~= BOOKTYPE_SPELL then return end
        local link = GetSpellLink(slot, bookType)
        local id = link and tonumber(string.match(link, "spell:(%d+)"))
        UA.AppendAbilityTooltip(self, UA.abilities[UA.rankMap[id]])
    end)
    hooksecurefunc(tooltip, "SetAction", function(self, slot)
        local kind, id, bookType = GetActionInfo(slot)
        if kind ~= "spell" then return end
        -- WotLK action indices can refer to book slots; GetSpell() remains the preferred hook.
        local abilityID = UA.rankMap[id]
        if not abilityID and id then
            local link = GetSpellLink(id, bookType or BOOKTYPE_SPELL)
            local spellID = link and tonumber(string.match(link, "spell:(%d+)"))
            abilityID = UA.rankMap[spellID]
        end
        UA.AppendAbilityTooltip(self, UA.abilities[abilityID])
    end)
end

function UA.ModeName(id)
    for _, mode in ipairs(UA.Modes) do if mode.id == id then return mode.name end end
    return "None"
end

function UA.CoverageText(a)
    if a.mode == 0 then return "Select a Delivery to activate propagation." end
    if a.mode == 4 then
        return string.format("%.0f yd radius\nAll valid targets inside the area", a.radius)
    elseif a.mode == 5 then
        return string.format("%d secondary jumps\n%.0f yd per jump", a.targets, a.search)
    end
    return string.format("%d secondary targets\n%.0f yd acquisition range", a.targets, a.search)
end

function UA.CoverageTooltip()
    local a = UA.Preview()
    GameTooltip:SetText("Coverage", 1, 0.82, 0)
    if not a then return end
    if not UA.SupportsNode(a, 2) then
        GameTooltip:AddLine("Propagation is unavailable for this ability.", 1, 0.82, 0, true)
        return
    end
    GameTooltip:AddLine("Rank " .. a.coverage, 1, 1, 1)
    GameTooltip:AddLine("Draft preview (not applied):", 1, 0.82, 0)
    GameTooltip:AddLine(UA.CoverageText(a), 1, 1, 1, true)
    GameTooltip:AddLine("Next rank:", 1, 0.82, 0)
    local rules = UA.draft and UA.draft.rules or UA.rules
    if not rules then return end
    local cap = a.mode == 4 and rules.novaCap or
        ((a.cast == 3 or a.range == 0) and rules.meleeCap or rules.propagationCap)
    local current = a.mode == 4 and a.radius or a.search
    local step = a.mode == 4 and rules.novaStep or (a.mode == 5 and rules.chainStep or rules.searchStep)
    local gain = math.max(0, math.min(step, cap - current))
    local nextText = a.mode ~= 4 and ("+1 " .. (a.mode == 5 and "jump" or "secondary target") .. "\n") or ""
    nextText = nextText .. string.format("+%.0f yd (maximum %.0f yd)", gain, cap)
    GameTooltip:AddLine(nextText, 0.2, 1, 0.2, true)
    if a.limited then GameTooltip:AddLine("Server safety limits may cap the next increase.", 1, 0.3, 0.2, true) end
    GameTooltip:AddLine("Cost per rank: " .. rules.coverageCost .. " Evolution Points", 1, 0.82, 0)
    GameTooltip:AddLine("Left click +1 / Right click -1. Confirm to apply.", 1, 1, 1, true)
end

function UA.ModifierTooltip(spec)
    if spec.field == "coverage" then UA.CoverageTooltip(); return end
    if spec.field == "potency" then UA.PotencyTooltip(); return end
    local a, r = UA.Preview(), UA.draft and UA.draft.rules or UA.rules
    GameTooltip:SetText(spec.label, 1, 0.82, 0)
    if not a or not r then return end
    GameTooltip:AddLine("Draft Rank " .. a[spec.field] .. " - Confirm to apply", 1, 0.82, 0)
    local committed = UA.Selected()
    if committed and committed[spec.field] ~= a[spec.field] then
        GameTooltip:AddLine("Pending (committed rank " .. committed[spec.field] .. ")", 1, 0.82, 0)
    end
    if spec.field == "damage" then
        GameTooltip:AddLine(string.format("Primary Damage: %.0f%%\n+%.0f%% per rank. Secondary Potency is applied afterwards.",
            a.primaryMultiplier * 100, r.damageStep), 1, 1, 1, true)
    elseif spec.field == "cooldown" then
        GameTooltip:AddLine(string.format("Cooldown: %.2f sec\n-%.2f sec per rank, maximum %.0f%% of base cooldown.",
            a.cooldownSeconds, r.cooldownStep, r.cooldownCapPct), 1, 1, 1, true)
        GameTooltip:AddLine("Other spells' category cooldowns and GCD remain unchanged.", 0.75, 0.75, 0.75, true)
    elseif spec.field == "castTime" then
        GameTooltip:AddLine(string.format("Base Cast Time: %.2f sec\n-%.2f sec per rank, maximum %.0f%%. Floor: %.2f sec.",
            a.castSeconds, r.castStep, r.castCapPct, r.castFloor), 1, 1, 1, true)
        GameTooltip:AddLine("Before haste and talents. Does not reduce the GCD or channel duration.", 0.75, 0.75, 0.75, true)
    elseif spec.field == "rebound" then
        GameTooltip:AddLine(a.rebound == 0 and "Locked: no revisits." or
            ("Previously hit targets become eligible after " .. a.reboundGap .. " other hops."), 1, 1, 1, true)
        local nextGap = 5 - math.min(math.floor((a.rebound + 1) / 3), 3)
        GameTooltip:AddLine("Next Rank: " .. nextGap .. " other hops. Minimum: 2.", 0.2, 1, 0.2, true)
        GameTooltip:AddLine("Every 3 ranks reduces the gap. New targets have priority. Coverage still limits total hops.",
            0.75, 0.75, 0.75, true)
    end
    GameTooltip:AddLine("Cost per rank: " .. r.modifierCost .. " Evolution Point", 1, 0.82, 0)
    GameTooltip:AddLine("Left click +1 / Right click -1", 1, 1, 1)
end

function UA.PotencyTooltip()
    local a = UA.Preview()
    GameTooltip:SetText("Potency", 1, 0.82, 0)
    if not a then return end
    if not UA.SupportsNode(a, 4) then
        GameTooltip:AddLine("Potency is unavailable for this ability. Secondary effects keep their original strength.",
            1, 0.82, 0, true)
        return
    end
    GameTooltip:AddLine("Rank " .. a.potency, 1, 1, 1)
    GameTooltip:AddLine(string.format("Draft Secondary Effect: %.0f%%", a.multiplier * 100), 1, 1, 1)
    local rules = UA.draft and UA.draft.rules or UA.rules
    if not rules then return end
    GameTooltip:AddLine(string.format("Next Rank: +%.0f percentage points", rules.potencyStep * 100), 0.2, 1, 0.2)
    GameTooltip:AddLine("Cost per rank: " .. rules.potencyCost .. " Evolution Points", 1, 0.82, 0)
    GameTooltip:AddLine("Left click +1 / Right click -1. Confirm to apply.", 1, 1, 1, true)
end
