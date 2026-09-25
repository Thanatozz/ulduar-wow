/*
 * This file is part of the mod-density-test project.
 */

#include "DensityManager.h"

#include "ScriptMgr.h"

namespace
{
class DensityGameObjectScript final : public AllGameObjectScript
{
public:
    DensityGameObjectScript() : AllGameObjectScript("DensityGameObjectScript")
    {
    }

    void OnGameObjectAddWorld(GameObject* gameObject) override
    {
        DensityManager::Instance().OnGameObjectAddWorld(gameObject);
    }

    void OnGameObjectRemoveWorld(GameObject* gameObject) override
    {
        DensityManager::Instance().OnGameObjectRemoveWorld(gameObject);
    }
};
}

void AddDensityGameObjectScripts()
{
    new DensityGameObjectScript();
}
