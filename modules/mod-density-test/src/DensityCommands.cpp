/*
 * This file is part of the mod-density-test project.
 */

#include "DensityConfig.h"
#include "DensityManager.h"

#include "Chat.h"
#include "Player.h"
#include "RBAC.h"
#include "ScriptMgr.h"

using namespace Acore::ChatCommands;

namespace
{
class DensityCommandScript final : public CommandScript
{
public:
    DensityCommandScript() : CommandScript("DensityCommandScript")
    {
    }

    ChatCommandTable GetCommands() const override
    {
        static ChatCommandTable densityCommandTable =
        {
            { "on", HandleDensityOn, rbac::RBAC_PERM_COMMAND_GM, Console::No },
            { "off", HandleDensityOff, rbac::RBAC_PERM_COMMAND_GM, Console::No },
            { "status", HandleDensityStatus, rbac::RBAC_PERM_COMMAND_GM, Console::No },
            { "stats", HandleDensityStats, rbac::RBAC_PERM_COMMAND_GM, Console::Yes },
            { "statsreset", HandleDensityStatsReset, rbac::RBAC_PERM_COMMAND_GM, Console::Yes }
        };

        static ChatCommandTable commandTable =
        {
            { "density", densityCommandTable }
        };

        return commandTable;
    }

private:
    static bool HandleDensityOn(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();
        switch (DensityManager::Instance().EnableFor(player))
        {
            case DensityManager::EnableResult::Enabled:
                handler->PSendSysMessage("[UlduarDensity] Density layer enabled. Combat creature density: x{}.",
                    DensityConfig::Instance().GetMultiplier());
                return true;
            case DensityManager::EnableResult::ModuleDisabled:
                handler->SendSysMessage("[UlduarDensity] The module is disabled by configuration.");
                return true;
            case DensityManager::EnableResult::OutsideTargetZone:
                handler->PSendSysMessage("[UlduarDensity] Density mode is not enabled here (enabled zones: {}).",
                    DensityConfig::Instance().GetEnabledZonesText());
                return true;
        }

        return false;
    }

    static bool HandleDensityOff(ChatHandler* handler)
    {
        DensityManager::Instance().DisableFor(handler->GetSession()->GetPlayer());
        handler->SendSysMessage("[UlduarDensity] Returned to normal layer.");
        return true;
    }

    static bool HandleDensityStatus(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();
        DensityConfig const& config = DensityConfig::Instance();
        DensityManager& manager = DensityManager::Instance();

        bool const enabled = manager.IsDensityEnabled(player->GetGUID());
        bool const active = enabled && manager.IsInTargetLocation(player) &&
            player->GetPhaseMask() == config.GetDensityPhaseMask();
        DensityManager::Status const status = manager.GetStatus();

        handler->PSendSysMessage("[UlduarDensity] {} | Map: {} | Zone: {} | Phase: {} ({}) | Multiplier: {}",
            enabled ? "ON" : "OFF", player->GetMapId(), player->GetZoneId(), player->GetPhaseMask(),
            active ? "Density" : "Normal", active ? config.GetMultiplier() : 1);
        handler->PSendSysMessage("[UlduarDensity] Grids: {} active, {} lingering | Queue: {} | Groups: {} | "
            "Creatures: {} | GameObjects: {}", status.activeGrids, status.lingeringGrids, status.queuedJobs,
            status.groups, status.creatureRepresentations, status.gameObjectRepresentations);
        return true;
    }

    static bool HandleDensityStats(ChatHandler* handler)
    {
        DensityStats const stats = DensityManager::Instance().GetStats();
        PlacementStats const& placement = stats.placement;

        handler->PSendSysMessage("[UlduarDensity] Grids: activations={} reuses={} releases={} "
            "activationWall(avg={}ms max={}ms)", stats.gridActivations, stats.gridReuses, stats.gridDeactivations,
            stats.gridActivations ? stats.activationWallMsTotal / stats.gridActivations : 0,
            stats.activationWallMsMax);
        handler->PSendSysMessage("[UlduarDensity] Creatures: inspected={} eligible={} mirrors={} clones={} "
            "unplaced={} createFailures={} cacheHits={} | GameObjects mirrored={} | removed={}",
            stats.creaturesInspected, stats.creaturesEligible, stats.mirrorsCreated, stats.clonesCreated,
            stats.clonesUnplaced, stats.createFailures, stats.positionCacheHits, stats.gameObjectsMirrored,
            stats.representationsRemoved);

        std::string rejected;
        for (size_t i = 0; i < stats.creaturesRejected.size(); ++i)
            if (i != size_t(DensityDecision::Multiply) && stats.creaturesRejected[i])
                rejected += Acore::StringFormat(" {}={}", DensityEligibility::DecisionName(DensityDecision(i)),
                    stats.creaturesRejected[i]);
        handler->PSendSysMessage("[UlduarDensity] Not multiplied (mirror only):{}",
            rejected.empty() ? " none" : rejected);

        handler->PSendSysMessage("[UlduarDensity] Placement: candidates={} accepted={} rejected(gridNotLoaded={} "
            "zone={} ground={} water={} overlap={} los={} path={}) time={}ms",
            placement.candidates, placement.accepted,
            placement.rejects[size_t(PlacementReject::GridNotLoaded)],
            placement.rejects[size_t(PlacementReject::OutsideZone)],
            placement.rejects[size_t(PlacementReject::NoGround)],
            placement.rejects[size_t(PlacementReject::Water)],
            placement.rejects[size_t(PlacementReject::Overlap)],
            placement.rejects[size_t(PlacementReject::LineOfSight)],
            placement.rejects[size_t(PlacementReject::Path)], placement.timeUs / 1000.0);
        handler->PSendSysMessage("[UlduarDensity] Work: total={}ms slices={} maxSlice={}us | jobs beforeReady={} "
            "afterReady={} | sources indexed beforeReady={} afterReady={}", stats.workUs / 1000.0, stats.slices,
            stats.maxSliceUs, stats.jobsBeforeReady, stats.jobsAfterReady, stats.sourcesIndexedBeforeReady,
            stats.sourcesIndexedAfterReady);
        handler->PSendSysMessage("[UlduarDensity] Map update diff max: busy={}ms idle={}ms | group aggro pulls={}",
            stats.maxDiffWhileBusy, stats.maxDiffWhileIdle, stats.groupAggroPulls);
        return true;
    }

    static bool HandleDensityStatsReset(ChatHandler* handler)
    {
        DensityManager::Instance().ResetStats();
        handler->SendSysMessage("[UlduarDensity] Statistics reset.");
        return true;
    }
};
}

void AddDensityCommands()
{
    new DensityCommandScript();
}
