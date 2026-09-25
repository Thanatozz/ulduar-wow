/*
 * This file is part of the mod-density-test project.
 */

#include "DensityEligibility.h"

#include "Creature.h"
#include "CreatureData.h"
#include "DBCStores.h"

namespace DensityEligibility
{
DensityDecision Classify(CreatureTemplate const* creatureTemplate, CreatureData const* data)
{
    if (!creatureTemplate)
        return DensityDecision::FriendlyFaction;

    if (creatureTemplate->type == CREATURE_TYPE_CRITTER)
        return DensityDecision::Critter;

    if (creatureTemplate->type == CREATURE_TYPE_NON_COMBAT_PET)
        return DensityDecision::NonCombatPet;

    uint32 const npcFlags = creatureTemplate->npcflag | (data ? data->npcflag : 0);
    if (npcFlags != UNIT_NPC_FLAG_NONE)
        return DensityDecision::ServiceNpc;

    if (creatureTemplate->HasFlagsExtra(CREATURE_FLAG_EXTRA_GUARD | CREATURE_FLAG_EXTRA_CIVILIAN |
        CREATURE_FLAG_EXTRA_TRIGGER))
        return DensityDecision::GuardCivilianTrigger;

    if (creatureTemplate->rank == CREATURE_ELITE_WORLDBOSS || creatureTemplate->rank == CREATURE_ELITE_RARE ||
        creatureTemplate->rank == CREATURE_ELITE_RAREELITE ||
        creatureTemplate->HasFlagsExtra(CREATURE_FLAG_EXTRA_DUNGEON_BOSS))
        return DensityDecision::BossOrRare;

    uint32 const unitFlags = creatureTemplate->unit_flags | (data ? data->unit_flags : 0);
    if (unitFlags & (UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_IMMUNE_TO_PC))
        return DensityDecision::NotAttackable;

    // Same faction semantics as Unit::IsHostileToPlayers()/Unit::IsNeutralToAll():
    // reputation factions (town factions such as Bloodhoof) are neither.
    FactionTemplateEntry const* factionTemplate = sFactionTemplateStore.LookupEntry(creatureTemplate->faction);
    if (!factionTemplate || !factionTemplate->faction)
        return DensityDecision::FriendlyFaction;

    if (FactionEntry const* faction = sFactionStore.LookupEntry(factionTemplate->faction))
        if (faction->reputationListID >= 0)
            return DensityDecision::FriendlyFaction;

    if (factionTemplate->IsHostileToPlayers())
        return DensityDecision::Multiply;

    if (!factionTemplate->IsNeutralToAll())
        return DensityDecision::FriendlyFaction;

    // Neutral creature: only a combat mob if killing it is rewarded. Ambient
    // neutral NPCs (no XP, no loot, no money) are left at normal population.
    bool const givesXp = !creatureTemplate->HasFlagsExtra(CREATURE_FLAG_EXTRA_NO_XP);
    bool const givesLoot = creatureTemplate->lootid || creatureTemplate->SkinLootId ||
        creatureTemplate->pickpocketLootId || creatureTemplate->maxgold;
    if (!givesXp || !givesLoot)
        return DensityDecision::NoCombatReward;

    return DensityDecision::Multiply;
}

bool IsPersistentSpawn(Creature const* creature)
{
    if (!creature || !creature->GetSpawnId())
        return false;

    CreatureData const* data = creature->GetCreatureData();
    if (!data || !data->dbData || data->spawnId != creature->GetSpawnId())
        return false;

    return !creature->IsPet() && !creature->IsSummon() && !creature->IsGuardian() && !creature->IsTotem() &&
        !creature->IsVehicle() && !creature->GetTransport();
}

char const* DecisionName(DensityDecision decision)
{
    switch (decision)
    {
        case DensityDecision::Multiply:
            return "multiply";
        case DensityDecision::Critter:
            return "critter";
        case DensityDecision::NonCombatPet:
            return "non-combat-pet";
        case DensityDecision::ServiceNpc:
            return "service-npc";
        case DensityDecision::GuardCivilianTrigger:
            return "guard/civilian/trigger";
        case DensityDecision::BossOrRare:
            return "boss/rare";
        case DensityDecision::NotAttackable:
            return "not-attackable";
        case DensityDecision::FriendlyFaction:
            return "friendly-faction";
        case DensityDecision::NoCombatReward:
            return "no-combat-reward";
        default:
            return "unknown";
    }
}
}
