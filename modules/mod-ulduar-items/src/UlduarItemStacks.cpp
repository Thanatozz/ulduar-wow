/*
 * This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "Config.h"
#include "ItemTemplate.h"
#include "Log.h"
#include "ObjectMgr.h"
#include "ScriptMgr.h"
#include "Timer.h"
#include "UlduarItemStackPolicy.h"
#include "WorldScript.h"
#include <array>

using namespace Ulduar::ItemStacks;

namespace
{
    // The multiplier is applied to the in-memory ItemTemplate store only; the
    // world DB is never written. Every process start re-reads the original
    // `item_template.stackable` values, so the result is 20 -> 200 on every
    // start and can never compound. ItemTemplate has no reload command, so the
    // store is populated exactly once per process; the guard below protects
    // against the hook ever running twice anyway.
    struct ItemStackState
    {
        uint32 multiplier = 1;
        bool bumpClientCache = true;
        bool applied = false;
        uint32 appliedMultiplier = 1;
    };

    ItemStackState sState;

    void ApplyStackMultiplier()
    {
        if (sState.applied)
            return;

        sState.applied = true;
        sState.appliedMultiplier = sState.multiplier;

        if (sState.multiplier <= 1)
        {
            LOG_INFO("module.ulduar.items", "[UlduarItems] Item stack multiplier disabled (Ulduar.ItemStackMultiplier = {}).", sState.multiplier);
            return;
        }

        uint32 const startMs = getMSTime();
        std::array<uint32, size_t(StackDecision::Max)> counts{};

        for (ItemTemplate* proto : *sObjectMgr->GetItemTemplateStoreFast())
        {
            if (!proto)
                continue;

            int32 newStackable = proto->Stackable;
            StackDecision const decision = ComputeStackable(*proto, sState.multiplier, newStackable);
            ++counts[size_t(decision)];

            if (decision != StackDecision::Multiplied)
                continue;

            LOG_DEBUG("module.ulduar.items", "[UlduarItems] Item {} '{}' stackable {} -> {}", proto->ItemId, proto->Name1, proto->Stackable, newStackable);
            proto->Stackable = newStackable;
        }

        LOG_INFO("module.ulduar.items", "[UlduarItems] Item stack multiplier x{} applied in {} ms: multiplied={} equippable={} special-value={} instance-state={}",
            sState.multiplier, GetMSTimeDiffToNow(startMs),
            counts[size_t(StackDecision::Multiplied)], counts[size_t(StackDecision::Equippable)],
            counts[size_t(StackDecision::SpecialValue)], counts[size_t(StackDecision::InstanceState)]);
    }
}

class UlduarItemStacksWorldScript : public WorldScript
{
public:
    UlduarItemStacksWorldScript() : WorldScript("UlduarItemStacksWorldScript",
        { WORLDHOOK_ON_AFTER_CONFIG_LOAD, WORLDHOOK_ON_BEFORE_WORLD_INITIALIZED, WORLDHOOK_ON_BEFORE_FINALIZE_PLAYER_WORLD_SESSION }) { }

    void OnAfterConfigLoad(bool reload) override
    {
        uint32 const multiplier = sConfigMgr->GetOption<uint32>("Ulduar.ItemStackMultiplier", 10);
        sState.bumpClientCache = sConfigMgr->GetOption<bool>("Ulduar.ItemStackMultiplier.BumpClientCache", true);

        // Templates were already rewritten; a new multiplier needs a restart.
        if (reload && sState.applied)
        {
            if (multiplier != sState.appliedMultiplier)
                LOG_WARN("module.ulduar.items", "[UlduarItems] Ulduar.ItemStackMultiplier changed to {} but x{} stays active until the worldserver restarts.",
                    multiplier, sState.appliedMultiplier);
            return;
        }

        sState.multiplier = multiplier;
    }

    // Runs after ObjectMgr::LoadItemTemplates() and every other DB load, and
    // before any grid is loaded or any session can query an item.
    void OnBeforeWorldInitialized() override
    {
        ApplyStackMultiplier();
    }

    // SMSG_ITEM_QUERY_SINGLE_RESPONSE sends Stackable, and the 3.3.5a client
    // caches it in WDB/itemcache.wdb. A different cache version makes the client
    // drop its WDB cache, so it learns the multiplied stack sizes. Adding the
    // multiplier keeps the version stable across restarts and changes it
    // whenever the multiplier changes (including back to 1).
    void OnBeforeFinalizePlayerWorldSession(uint32& cacheVersion) override
    {
        if (sState.bumpClientCache && sState.appliedMultiplier > 1)
            cacheVersion += sState.appliedMultiplier;
    }
};

void AddSC_ulduar_item_stacks()
{
    new UlduarItemStacksWorldScript();
}
