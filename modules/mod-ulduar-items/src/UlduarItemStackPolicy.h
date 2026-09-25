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

#ifndef ULDUAR_ITEM_STACK_POLICY_H
#define ULDUAR_ITEM_STACK_POLICY_H

#include "Define.h"

struct ItemTemplate;

namespace Ulduar::ItemStacks
{
    enum class StackDecision : uint8
    {
        Multiplied,
        Disabled,          // multiplier <= 1
        Equippable,        // InventoryType != INVTYPE_NON_EQUIP
        SpecialValue,      // Stackable <= 0 or the 2147483647 "unlimited" sentinel
        InstanceState,     // Stackable == 1 and each copy carries its own state (see IsStackUnsafe)
        Max
    };

    // Pure function: returns the Stackable value an item template should have
    // under the Ulduar multiplier. It never reads or writes global state, so the
    // caller can apply it exactly once to the values freshly loaded from the DB.
    StackDecision ComputeStackable(ItemTemplate const& proto, uint32 multiplier, int32& outStackable);

    char const* DecisionName(StackDecision decision);
}

#endif
