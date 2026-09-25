/*
 * This file is part of the mod-density-test project.
 */

#include "DensityManager.h"

#include "Creature.h"
#include "ScriptMgr.h"

namespace
{
class DensityCreatureScript final : public AllCreatureScript
{
public:
    DensityCreatureScript() : AllCreatureScript("DensityCreatureScript")
    {
    }

    void OnCreatureAddWorld(Creature* creature) override
    {
        DensityManager::Instance().OnCreatureAddWorld(creature);
    }

    void OnCreatureRemoveWorld(Creature* creature) override
    {
        DensityManager::Instance().OnCreatureRemoveWorld(creature);
    }
};

// Creature::AtEngage fires OnUnitEnterCombat once a creature engages a target,
// right after formation assist; density groups use the same point.
class DensityUnitScript final : public UnitScript
{
public:
    DensityUnitScript() : UnitScript("DensityUnitScript", true, { UNITHOOK_ON_UNIT_ENTER_COMBAT })
    {
    }

    void OnUnitEnterCombat(Unit* unit, Unit* victim) override
    {
        if (Creature* creature = unit->ToCreature())
            DensityManager::Instance().OnCreatureEngaged(creature, victim);
    }
};
}

void AddDensityCreatureScripts()
{
    new DensityCreatureScript();
    new DensityUnitScript();
}
