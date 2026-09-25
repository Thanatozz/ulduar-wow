/*
 * This file is part of the mod-density-test project.
 */

#include "DensityConfig.h"
#include "DensityManager.h"

#include "ScriptMgr.h"

namespace
{
class DensityWorldScript final : public WorldScript
{
public:
    DensityWorldScript() : WorldScript("DensityWorldScript", {
        WORLDHOOK_ON_BEFORE_CONFIG_LOAD,
        WORLDHOOK_ON_STARTUP
    })
    {
    }

    void OnBeforeConfigLoad(bool reload) override
    {
        DensityConfig::Instance().Load(reload);
    }

    // Fired by worldserver right before it reports ready.
    void OnStartup() override
    {
        DensityManager::Instance().OnWorldReady();
    }
};

class DensityMapScript final : public AllMapScript
{
public:
    DensityMapScript() : AllMapScript("DensityMapScript", {
        ALLMAPHOOK_ON_MAP_UPDATE,
        ALLMAPHOOK_ON_DESTROY_MAP
    })
    {
    }

    void OnMapUpdate(Map* map, uint32 diff) override
    {
        DensityManager::Instance().OnMapUpdate(map, diff);
    }

    void OnDestroyMap(Map* map) override
    {
        DensityManager::Instance().OnDestroyMap(map);
    }
};
}

void AddDensityConfigScripts()
{
    new DensityWorldScript();
    new DensityMapScript();
}
