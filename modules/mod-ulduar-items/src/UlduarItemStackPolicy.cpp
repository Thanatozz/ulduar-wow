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

#include "UlduarItemStackPolicy.h"
#include "ItemTemplate.h"
#include "Mail.h"
#include <algorithm>
#include <limits>

namespace
{
    // ItemTemplate::GetMaxStackSize() maps both Stackable <= 0 and INT32_MAX to
    // "unlimited" (0x7FFFFFFE). The largest finite value we may produce is one
    // below the sentinel, so a multiplied stack never turns into "unlimited".
    constexpr int64 MaxFiniteStackable = std::numeric_limits<int32>::max() - 1;

    // Items that never stacked before (Stackable == 1) may carry state that is
    // stored per item instance. Item::CanBeMergedPartlyWith() only compares the
    // entry and free space, so merging two such copies would silently discard
    // the state of one of them. Several core paths also only track that state
    // when GetMaxStackSize() == 1. Keep those items at 1.
    bool IsStackUnsafe(ItemTemplate const& proto)
    {
        // Per-instance charges are only persisted when Stackable == 1
        // (Spell::TakeCastItem). Charges of -1 mean "consume one item per use",
        // which is exactly how stacked consumables work.
        for (_Spell const& spell : proto.Spells)
            if (spell.SpellId && spell.SpellCharges != 0 && spell.SpellCharges != -1)
                return true;

        // Per-instance expiry timer (ITEM_FIELD_DURATION).
        if (proto.Duration)
            return true;

        // Per-instance lock state (ITEM_FIELD_FLAG_UNLOCKED) and stored loot.
        if (proto.LockID || proto.HasFlag(ITEM_FLAG_HAS_LOOT))
            return true;

        // Wrapped gifts (character_gifts), petitions (petition keyed by item guid),
        // extended-cost refund records (only created for GetMaxStackSize() == 1).
        if (proto.HasFlag(ITEM_FLAG_IS_WRAPPER) || proto.HasFlag(ITEM_FLAG_PETITION) ||
            proto.HasFlag(ITEM_FLAG_ITEM_PURCHASE_RECORD))
            return true;

        // Mail letters carry ITEM_FIELD_ITEM_TEXT_ID per instance.
        if (proto.ItemId == MAIL_BODY_ITEM_TEMPLATE)
            return true;

        // Group loot trade window (2h, allowed looter list per instance) is only
        // granted when GetMaxStackSize() == 1 (Group.cpp, PlayerStorage.cpp).
        if (proto.Bonding == BIND_WHEN_PICKED_UP || proto.Bonding == BIND_QUEST_ITEM ||
            proto.Bonding == BIND_QUEST_ITEM1)
            return true;

        return false;
    }
}

namespace Ulduar::ItemStacks
{
    StackDecision ComputeStackable(ItemTemplate const& proto, uint32 multiplier, int32& outStackable)
    {
        outStackable = proto.Stackable;

        if (multiplier <= 1)
            return StackDecision::Disabled;

        if (proto.InventoryType != INVTYPE_NON_EQUIP)
            return StackDecision::Equippable;

        // ObjectMgr::LoadItemTemplates already rewrote 0 -> 1 and < -1 -> -1.
        // -1 and INT32_MAX mean "no stacking limit" and must stay untouched.
        if (proto.Stackable <= 0 || proto.Stackable == std::numeric_limits<int32>::max())
            return StackDecision::SpecialValue;

        if (proto.Stackable == 1 && IsStackUnsafe(proto))
            return StackDecision::InstanceState;

        int64 const scaled = int64(proto.Stackable) * int64(multiplier);
        outStackable = int32(std::min(scaled, MaxFiniteStackable));
        return StackDecision::Multiplied;
    }

    char const* DecisionName(StackDecision decision)
    {
        switch (decision)
        {
            case StackDecision::Multiplied:
                return "multiplied";
            case StackDecision::Disabled:
                return "disabled";
            case StackDecision::Equippable:
                return "equippable";
            case StackDecision::SpecialValue:
                return "special-value";
            case StackDecision::InstanceState:
                return "instance-state";
            default:
                return "unknown";
        }
    }
}
