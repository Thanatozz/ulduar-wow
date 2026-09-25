/*
 * This file is part of the mod-density-test project.
 */

#ifndef MOD_DENSITY_TEST_ELIGIBILITY_H
#define MOD_DENSITY_TEST_ELIGIBILITY_H

#include "Define.h"

class Creature;
struct CreatureData;
struct CreatureTemplate;

// Every phase-normal DB spawn inside an active density grid gets exactly one
// representation in the density phase (the "mirror"), so density players still
// see vendors, quest givers, critters and objects. Only creatures classified as
// DensityDecision::Multiply get the configured number of representations.
enum class DensityDecision : uint8
{
    Multiply,            // hostile, or neutral combat creature
    Critter,             // CREATURE_TYPE_CRITTER
    NonCombatPet,        // CREATURE_TYPE_NON_COMBAT_PET
    ServiceNpc,          // any npcflag: vendor, trainer, flight master, quest giver, spirit healer...
    GuardCivilianTrigger,// flags_extra guard / civilian / trigger
    BossOrRare,          // world boss, dungeon boss, rare, rare elite
    NotAttackable,       // non-attackable, not selectable, immune to players
    FriendlyFaction,     // friendly to players or reputation faction (e.g. Bloodhoof)
    NoCombatReward,      // neutral creature without XP, loot or money: ambient, not a combat mob

    Max
};

namespace DensityEligibility
{
    // Single source of truth for "does this spawn get a density pack".
    // Pure function over static spawn data, so the decision is identical on every
    // grid activation and never depends on transient runtime state.
    [[nodiscard]] DensityDecision Classify(CreatureTemplate const* creatureTemplate, CreatureData const* data);

    // Whether a live creature may act as the source of a density group at all:
    // a phase-normal persistent DB spawn that is not a pet, summon, guardian,
    // totem, vehicle accessory or an existing density representation.
    [[nodiscard]] bool IsPersistentSpawn(Creature const* creature);

    [[nodiscard]] char const* DecisionName(DensityDecision decision);
}

#endif
