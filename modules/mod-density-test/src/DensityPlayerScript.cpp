/*
 * This file is part of the mod-density-test project.
 */

#include "DensityManager.h"

#include "ScriptMgr.h"

namespace
{
class DensityPlayerScript final : public PlayerScript
{
public:
    DensityPlayerScript() : PlayerScript("DensityPlayerScript", {
        PLAYERHOOK_ON_LOGIN,
        PLAYERHOOK_ON_BEFORE_LOGOUT,
        PLAYERHOOK_ON_LOGOUT,
        PLAYERHOOK_ON_UPDATE_ZONE,
        PLAYERHOOK_ON_MAP_CHANGED
    })
    {
    }

    void OnPlayerLogin(Player* player) override
    {
        DensityManager::Instance().HandleLogin(player);
    }

    void OnPlayerBeforeLogout(Player* player) override
    {
        DensityManager::Instance().HandleBeforeLogout(player);
    }

    void OnPlayerLogout(Player* player) override
    {
        DensityManager::Instance().HandleLogout(player);
    }

    void OnPlayerUpdateZone(Player* player, uint32 /*newZone*/, uint32 /*newArea*/) override
    {
        DensityManager::Instance().HandleLocationChanged(player);
    }

    void OnPlayerMapChanged(Player* player) override
    {
        DensityManager::Instance().HandleLocationChanged(player);
    }
};
}

void AddDensityPlayerScripts()
{
    new DensityPlayerScript();
}
