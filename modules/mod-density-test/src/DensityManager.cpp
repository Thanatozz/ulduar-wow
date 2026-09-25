/*
 * This file is part of the mod-density-test project.
 */

#include "DensityManager.h"

#include "Creature.h"
#include "CreatureData.h"
#include "DensityConfig.h"
#include "GameObject.h"
#include "GridDefines.h"
#include "Log.h"
#include "Map.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "Timer.h"

#include <chrono>

namespace
{
char const DENSITY_OBJECT_DATA_KEY[] = "mod-density-test.object";

enum class DensityObjectKind : uint8
{
    Creature,
    GameObject
};

// Attached to every density representation. Identifies it as ours (no recursion,
// never indexed as a source) and links it back to its density group.
class DensityObjectData final : public DataMap::Base
{
public:
    DensityObjectData(DensityObjectKind objectKind, ObjectGuid::LowType spawn, uint32 grid, uint32 gen,
        uint32 index) : kind(objectKind), spawnId(spawn), gridId(grid), generation(gen), copyIndex(index)
    {
    }

    DensityObjectKind kind;
    ObjectGuid::LowType spawnId;
    uint32 gridId;
    uint32 generation;
    uint32 copyIndex;
};

DensityObjectData const* GetDensityObjectData(WorldObject const* object)
{
    return object->CustomData.Get<DensityObjectData>(DENSITY_OBJECT_DATA_KEY);
}

uint64 NowUs()
{
    return uint64(std::chrono::duration_cast<std::chrono::microseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count());
}

uint32 GridIdFor(float x, float y)
{
    return Acore::ComputeGridCoord(x, y).GetId();
}

GridCoord GridCoordFor(uint32 gridId)
{
    return GridCoord(gridId % MAX_NUMBER_OF_GRIDS, gridId / MAX_NUMBER_OF_GRIDS);
}

// Prevents OnCreatureEngaged -> EngageWithTarget -> AtEngage -> OnCreatureEngaged
// recursion. Map updates run on several threads, so the flag is per thread.
thread_local bool t_propagatingGroupAggro = false;
}

void DensityStats::Add(DensityStats const& other)
{
    sourcesIndexedBeforeReady += other.sourcesIndexedBeforeReady;
    sourcesIndexedAfterReady += other.sourcesIndexedAfterReady;
    jobsBeforeReady += other.jobsBeforeReady;
    jobsAfterReady += other.jobsAfterReady;
    workUs += other.workUs;
    maxSliceUs = std::max(maxSliceUs, other.maxSliceUs);
    slices += other.slices;
    gridActivations += other.gridActivations;
    gridReuses += other.gridReuses;
    gridDeactivations += other.gridDeactivations;
    activationWallMsTotal += other.activationWallMsTotal;
    activationWallMsMax = std::max(activationWallMsMax, other.activationWallMsMax);
    creaturesInspected += other.creaturesInspected;
    creaturesEligible += other.creaturesEligible;
    for (size_t i = 0; i < creaturesRejected.size(); ++i)
        creaturesRejected[i] += other.creaturesRejected[i];
    mirrorsCreated += other.mirrorsCreated;
    clonesCreated += other.clonesCreated;
    clonesUnplaced += other.clonesUnplaced;
    createFailures += other.createFailures;
    gameObjectsMirrored += other.gameObjectsMirrored;
    representationsRemoved += other.representationsRemoved;
    positionCacheHits += other.positionCacheHits;
    placement.Add(other.placement);
    groupAggroPulls += other.groupAggroPulls;
    maxDiffWhileBusy = std::max(maxDiffWhileBusy, other.maxDiffWhileBusy);
    maxDiffWhileIdle = std::max(maxDiffWhileIdle, other.maxDiffWhileIdle);
}

DensityManager& DensityManager::Instance()
{
    static DensityManager instance;
    return instance;
}

// ---------------------------------------------------------------------------
// Player layer membership. Unchanged behaviour: the toggle is per session, the
// density phase only applies inside an enabled map/zone.
// ---------------------------------------------------------------------------

DensityManager::EnableResult DensityManager::EnableFor(Player* player)
{
    DensityConfig const& config = DensityConfig::Instance();
    if (!config.IsEnabled())
        return EnableResult::ModuleDisabled;

    if (!IsInTargetLocation(player))
        return EnableResult::OutsideTargetZone;

    {
        std::lock_guard lock(_mutex);
        _densityPlayers.insert(player->GetGUID());
    }

    ApplyPlayerPhase(player, config.GetDensityPhaseMask(), true);

    if (config.IsDebugEnabled())
        LOG_INFO("module.density_test", "[UlduarDensity] Player {} entered density layer.", player->GetName());

    return EnableResult::Enabled;
}

void DensityManager::DisableFor(Player* player)
{
    DensityConfig const& config = DensityConfig::Instance();
    {
        std::lock_guard lock(_mutex);
        _densityPlayers.erase(player->GetGUID());
    }

    ApplyPlayerPhase(player, config.GetNormalPhaseMask(), true);

    if (config.IsDebugEnabled())
        LOG_INFO("module.density_test", "[UlduarDensity] Player {} returned to normal layer.", player->GetName());
}

void DensityManager::HandleLogin(Player* player)
{
    DensityConfig const& config = DensityConfig::Instance();
    {
        std::lock_guard lock(_mutex);
        _densityPlayers.erase(player->GetGUID());
    }

    if (player->GetPhaseMask() == config.GetDensityPhaseMask())
        ApplyPlayerPhase(player, config.GetNormalPhaseMask(), false);
}

void DensityManager::HandleBeforeLogout(Player* player)
{
    bool wasEnabled = false;
    {
        std::lock_guard lock(_mutex);
        wasEnabled = _densityPlayers.erase(player->GetGUID()) != 0;
    }

    DensityConfig const& config = DensityConfig::Instance();
    if (wasEnabled || player->GetPhaseMask() == config.GetDensityPhaseMask())
        ApplyPlayerPhase(player, config.GetNormalPhaseMask(), false);
}

void DensityManager::HandleLogout(Player* player)
{
    std::lock_guard lock(_mutex);
    _densityPlayers.erase(player->GetGUID());
}

void DensityManager::HandleLocationChanged(Player* player)
{
    DensityConfig const& config = DensityConfig::Instance();
    if (!config.IsEnabled())
        return;

    bool const densityEnabled = IsDensityEnabled(player->GetGUID());
    if (densityEnabled && IsInTargetLocation(player))
    {
        ApplyPlayerPhase(player, config.GetDensityPhaseMask(), true);
        return;
    }

    if (densityEnabled || player->GetPhaseMask() == config.GetDensityPhaseMask())
        ApplyPlayerPhase(player, config.GetNormalPhaseMask(), true);
}

bool DensityManager::IsDensityEnabled(ObjectGuid playerGuid) const
{
    std::lock_guard lock(_mutex);
    return _densityPlayers.contains(playerGuid);
}

bool DensityManager::IsInTargetLocation(WorldObject const* object) const
{
    return object && object->FindMap() && IsLocationEnabled(object->FindMap(), object->GetZoneId());
}

bool DensityManager::IsLocationEnabled(Map const* map, uint32 zoneId) const
{
    DensityConfig const& config = DensityConfig::Instance();
    return map && !map->Instanceable() && config.IsMapEnabled(map->GetId()) && config.IsZoneEnabled(zoneId);
}

void DensityManager::ApplyPlayerPhase(Player* player, uint32 phaseMask, bool stopCombat) const
{
    if (!player || player->GetPhaseMask() == phaseMask)
        return;

    if (stopCombat)
        player->CombatStopWithPets(true);

    player->SetPhaseMask(phaseMask, true);
}

// ---------------------------------------------------------------------------
// Source index. Every phase-normal DB spawn of an enabled map/zone is recorded
// under the grid of its spawn point. This is the only work done when grids
// load: nothing is created until a density player needs the grid.
// ---------------------------------------------------------------------------

void DensityManager::OnCreatureAddWorld(Creature* creature)
{
    DensityConfig const& config = DensityConfig::Instance();
    if (!config.IsEnabled() || !creature || GetDensityObjectData(creature))
        return;

    Map* map = creature->GetMap();
    if (!map || map->Instanceable() || !config.IsMapEnabled(map->GetId()))
        return;

    if (!DensityEligibility::IsPersistentSpawn(creature))
        return;

    CreatureData const* data = creature->GetCreatureData();
    if (data->phaseMask != config.GetNormalPhaseMask())
    {
        if ((data->phaseMask & config.GetDensityPhaseMask()) &&
            IsLocationEnabled(map, map->GetZoneId(data->phaseMask, data->posX, data->posY, data->posZ)))
            LOG_WARN("module.density_test", "[UlduarDensity] Creature spawn {} already uses density phase bit {} "
                "(phase mask {}). It will not be mirrored and may violate layer isolation.", data->spawnId,
                config.GetDensityPhaseMask(), data->phaseMask);
        return;
    }

    if (!config.IsZoneEnabled(map->GetZoneId(data->phaseMask, data->posX, data->posY, data->posZ)))
        return;

    uint32 const gridId = GridIdFor(data->posX, data->posY);

    std::lock_guard lock(_mutex);
    MapState& state = _maps[map->GetId()];
    SourceRecord& record = state.creatureSources[data->spawnId];
    record.gridId = gridId;
    record.guid = creature->GetGUID();
    state.creaturesByGrid[gridId].insert(data->spawnId);

    DensityStats& stats = StatsLocked(state);
    if (_worldReady)
        ++stats.sourcesIndexedAfterReady;
    else
        ++stats.sourcesIndexedBeforeReady;

    // A spawn that appears inside an already active grid (pool, game event,
    // first spawn after a dynamic respawn) gets its group now.
    auto gridItr = state.grids.find(gridId);
    if (gridItr != state.grids.end() && gridItr->second.status != GridStatus::Inactive &&
        !state.creatureGroups.contains(data->spawnId))
        EnqueueLocked(state, JobType::SpawnCreature, data->spawnId, gridId, gridItr->second.generation);
}

void DensityManager::OnCreatureRemoveWorld(Creature* creature)
{
    if (!creature)
        return;

    if (DensityObjectData const* objectData = GetDensityObjectData(creature))
    {
        std::lock_guard lock(_mutex);
        auto mapItr = _maps.find(creature->GetMapId());
        if (mapItr == _maps.end())
            return;

        auto group = mapItr->second.creatureGroups.find(objectData->spawnId);
        if (group != mapItr->second.creatureGroups.end() && group->second.generation == objectData->generation)
            std::erase(group->second.members, creature->GetGUID());
        return;
    }

    if (!DensityEligibility::IsPersistentSpawn(creature))
        return;

    std::lock_guard lock(_mutex);
    auto mapItr = _maps.find(creature->GetMapId());
    if (mapItr == _maps.end())
        return;

    MapState& state = mapItr->second;
    auto record = state.creatureSources.find(creature->GetSpawnId());
    if (record == state.creatureSources.end() || record->second.guid != creature->GetGUID())
        return;

    // Dynamic respawn removes the corpse from the world and later adds a new
    // object for the same spawn. That is not a reason to touch the density
    // group, whose representations follow their own death/respawn cycle.
    if (!creature->IsAlive())
    {
        record->second.guid.Clear();
        return;
    }

    // Removed while alive: pool rotation, game event end or map unload.
    uint32 const gridId = record->second.gridId;
    state.creaturesByGrid[gridId].erase(creature->GetSpawnId());
    state.creatureSources.erase(record);

    auto group = state.creatureGroups.find(creature->GetSpawnId());
    if (group != state.creatureGroups.end())
        EnqueueLocked(state, JobType::DespawnCreature, creature->GetSpawnId(), group->second.gridId,
            group->second.generation);
}

void DensityManager::OnGameObjectAddWorld(GameObject* gameObject)
{
    DensityConfig const& config = DensityConfig::Instance();
    if (!config.IsEnabled() || !gameObject || GetDensityObjectData(gameObject))
        return;

    Map* map = gameObject->GetMap();
    if (!map || map->Instanceable() || !config.IsMapEnabled(map->GetId()))
        return;

    GameObjectData const* data = gameObject->GetGameObjectData();
    if (!gameObject->GetSpawnId() || !data || !data->dbData || data->spawnId != gameObject->GetSpawnId() ||
        gameObject->IsTransport())
        return;

    if (data->phaseMask != config.GetNormalPhaseMask())
    {
        if ((data->phaseMask & config.GetDensityPhaseMask()) &&
            IsLocationEnabled(map, map->GetZoneId(data->phaseMask, data->posX, data->posY, data->posZ)))
            LOG_WARN("module.density_test", "[UlduarDensity] GameObject spawn {} already uses density phase bit {} "
                "(phase mask {}). It will not be mirrored and may violate layer isolation.", data->spawnId,
                config.GetDensityPhaseMask(), data->phaseMask);
        return;
    }

    if (!config.IsZoneEnabled(map->GetZoneId(data->phaseMask, data->posX, data->posY, data->posZ)))
        return;

    uint32 const gridId = GridIdFor(data->posX, data->posY);

    std::lock_guard lock(_mutex);
    MapState& state = _maps[map->GetId()];
    SourceRecord& record = state.gameObjectSources[data->spawnId];
    record.gridId = gridId;
    record.guid = gameObject->GetGUID();
    state.gameObjectsByGrid[gridId].insert(data->spawnId);

    DensityStats& stats = StatsLocked(state);
    if (_worldReady)
        ++stats.sourcesIndexedAfterReady;
    else
        ++stats.sourcesIndexedBeforeReady;

    auto gridItr = state.grids.find(gridId);
    if (gridItr != state.grids.end() && gridItr->second.status != GridStatus::Inactive &&
        !state.gameObjectGroups.contains(data->spawnId))
        EnqueueLocked(state, JobType::SpawnGameObject, data->spawnId, gridId, gridItr->second.generation);
}

void DensityManager::OnGameObjectRemoveWorld(GameObject* gameObject)
{
    if (!gameObject)
        return;

    if (DensityObjectData const* objectData = GetDensityObjectData(gameObject))
    {
        std::lock_guard lock(_mutex);
        auto mapItr = _maps.find(gameObject->GetMapId());
        if (mapItr == _maps.end())
            return;

        auto group = mapItr->second.gameObjectGroups.find(objectData->spawnId);
        if (group != mapItr->second.gameObjectGroups.end() && group->second.mirror == gameObject->GetGUID())
            group->second.mirror.Clear();
        return;
    }

    if (!gameObject->GetSpawnId())
        return;

    std::lock_guard lock(_mutex);
    auto mapItr = _maps.find(gameObject->GetMapId());
    if (mapItr == _maps.end())
        return;

    MapState& state = mapItr->second;
    auto record = state.gameObjectSources.find(gameObject->GetSpawnId());
    if (record == state.gameObjectSources.end() || record->second.guid != gameObject->GetGUID())
        return;

    // Looted/used objects despawn until their respawn time; keep the mirror.
    if (!gameObject->isSpawned())
    {
        record->second.guid.Clear();
        return;
    }

    uint32 const gridId = record->second.gridId;
    state.gameObjectsByGrid[gridId].erase(gameObject->GetSpawnId());
    state.gameObjectSources.erase(record);

    auto group = state.gameObjectGroups.find(gameObject->GetSpawnId());
    if (group != state.gameObjectGroups.end())
        EnqueueLocked(state, JobType::DespawnGameObject, gameObject->GetSpawnId(), group->second.gridId,
            group->second.generation);
}

// ---------------------------------------------------------------------------
// Map update: grid scan (every ScanInterval) and a time-budgeted work queue.
// ---------------------------------------------------------------------------

void DensityManager::OnMapUpdate(Map* map, uint32 diff)
{
    DensityConfig const& config = DensityConfig::Instance();
    if (!config.IsEnabled() || !map || map->Instanceable() || !config.IsMapEnabled(map->GetId()))
        return;

    bool scan = false;
    bool busy = false;
    {
        std::lock_guard lock(_mutex);
        auto mapItr = _maps.find(map->GetId());
        if (mapItr == _maps.end())
            return;

        MapState& state = mapItr->second;
        busy = !state.queue.empty();
        DensityStats& stats = StatsLocked(state);
        if (busy)
            stats.maxDiffWhileBusy = std::max(stats.maxDiffWhileBusy, diff);
        else
            stats.maxDiffWhileIdle = std::max(stats.maxDiffWhileIdle, diff);

        state.scanTimer += diff;
        if (state.scanTimer >= config.GetScanIntervalMs())
        {
            state.scanTimer = 0;
            scan = true;
        }

        if (uint32 const statsInterval = config.GetStatsLogIntervalMs())
        {
            state.statsTimer += diff;
            if (state.statsTimer >= statsInterval)
            {
                state.statsTimer = 0;
                LogStatsLocked(map, state);
            }
        }
    }

    if (scan)
    {
        std::lock_guard lock(_mutex);
        ScanGrids(map, _maps[map->GetId()]);
    }

    ProcessQueue(map, diff);
}

void DensityManager::OnDestroyMap(Map* map)
{
    if (!map || map->Instanceable())
        return;

    std::lock_guard lock(_mutex);
    _maps.erase(map->GetId());
}

void DensityManager::OnWorldReady()
{
    std::lock_guard lock(_mutex);
    _worldReady = true;

    DensityStats total;
    for (auto const& [mapId, state] : _maps)
        total.Add(state.stats);

    LOG_INFO("module.density_test", "[UlduarDensity] World ready: {} density sources indexed during startup, "
        "{} density jobs executed before ready (expected 0). Density is generated lazily per grid.",
        total.sourcesIndexedBeforeReady, total.jobsBeforeReady);
}

void DensityManager::ScanGrids(Map* map, MapState& state)
{
    DensityConfig const& config = DensityConfig::Instance();
    uint32 const densityPhase = config.GetDensityPhaseMask();
    float const radius = config.GetActivationRadius();

    // Reference count = number of density players whose activation square
    // touches the grid. Recomputed at a fixed interval instead of tracked per
    // movement packet, which also makes it robust against teleports, deaths and
    // disconnects that would otherwise leak a reference.
    std::unordered_map<uint32, uint32> needed;
    for (auto const& ref : map->GetPlayers())
    {
        Player* player = ref.GetSource();
        if (!player || !player->IsInWorld() || player->GetPhaseMask() != densityPhase ||
            !_densityPlayers.contains(player->GetGUID()) || !IsLocationEnabled(map, player->GetZoneId()))
            continue;

        // Grid coordinates grow as world coordinates shrink, so compare both corners.
        GridCoord const a = Acore::ComputeGridCoord(player->GetPositionX() + radius, player->GetPositionY() + radius);
        GridCoord const b = Acore::ComputeGridCoord(player->GetPositionX() - radius, player->GetPositionY() - radius);
        uint32 const maxGrid = MAX_NUMBER_OF_GRIDS - 1;
        uint32 const lowX = std::min({ a.x_coord, b.x_coord, maxGrid });
        uint32 const highX = std::min(std::max(a.x_coord, b.x_coord), maxGrid);
        uint32 const lowY = std::min({ a.y_coord, b.y_coord, maxGrid });
        uint32 const highY = std::min(std::max(a.y_coord, b.y_coord), maxGrid);
        for (uint32 x = lowX; x <= highX; ++x)
            for (uint32 y = lowY; y <= highY; ++y)
                ++needed[GridCoord(x, y).GetId()];
    }

    uint32 const now = getMSTime();

    for (auto const& [gridId, count] : needed)
    {
        GridState& grid = state.grids[gridId];
        grid.neededBy = count;

        switch (grid.status)
        {
            case GridStatus::Inactive:
                // Density never loads grids. The core loads every grid within
                // MAX_VISIBILITY_DISTANCE of a player; anything else waits.
                if (map->IsGridLoaded(GridCoordFor(gridId)))
                    ActivateGridLocked(map, state, gridId, grid);
                break;
            case GridStatus::Lingering:
                grid.status = GridStatus::Active;
                ++StatsLocked(state).gridReuses;
                if (config.IsDebugEnabled())
                    LOG_INFO("module.density_test", "[UlduarDensity] Grid reused: map={} grid={}:{} players={}",
                        map->GetId(), GridCoordFor(gridId).x_coord, GridCoordFor(gridId).y_coord, count);
                break;
            case GridStatus::Active:
                break;
        }
    }

    for (auto itr = state.grids.begin(); itr != state.grids.end();)
    {
        uint32 const gridId = itr->first;
        GridState& grid = itr->second;

        if (!needed.contains(gridId))
        {
            grid.neededBy = 0;
            if (grid.status == GridStatus::Active)
            {
                grid.status = GridStatus::Lingering;
                grid.lingerStartMs = now;
            }
            else if (grid.status == GridStatus::Lingering &&
                getMSTimeDiff(grid.lingerStartMs, now) >= config.GetUnloadDelayMs())
                DeactivateGridLocked(state, gridId, grid);
        }

        // Forget inactive grids once their cleanup has drained.
        if (grid.status == GridStatus::Inactive && !grid.pendingJobs && grid.creatureGroups.empty() &&
            grid.gameObjectGroups.empty())
            itr = state.grids.erase(itr);
        else
            ++itr;
    }
}

void DensityManager::ActivateGridLocked(Map* map, MapState& state, uint32 gridId, GridState& grid)
{
    grid.status = GridStatus::Active;
    ++grid.generation;
    grid.pendingJobs = 0;
    grid.activation = GridActivation();
    grid.activation.startMs = getMSTime();
    ++StatsLocked(state).gridActivations;

    // Objects first: their mirrors provide the density-phase dynamic collision
    // (doors, fences) that clone placement tests against.
    if (auto sources = state.gameObjectsByGrid.find(gridId); sources != state.gameObjectsByGrid.end())
        for (SpawnId spawnId : sources->second)
            EnqueueLocked(state, JobType::SpawnGameObject, spawnId, gridId, grid.generation);

    if (auto sources = state.creaturesByGrid.find(gridId); sources != state.creaturesByGrid.end())
        for (SpawnId spawnId : sources->second)
            EnqueueLocked(state, JobType::SpawnCreature, spawnId, gridId, grid.generation);

    if (!grid.pendingJobs)
        ReportGridLocked(map, gridId, grid);
}

void DensityManager::DeactivateGridLocked(MapState& state, uint32 gridId, GridState& grid)
{
    grid.status = GridStatus::Inactive;
    ++grid.generation; // queued spawn jobs of the old activation become stale
    grid.pendingJobs = 0;
    ++StatsLocked(state).gridDeactivations;

    for (SpawnId spawnId : grid.gameObjectGroups)
    {
        auto group = state.gameObjectGroups.find(spawnId);
        if (group != state.gameObjectGroups.end())
            EnqueueLocked(state, JobType::DespawnGameObject, spawnId, gridId, group->second.generation);
    }

    for (SpawnId spawnId : grid.creatureGroups)
    {
        auto group = state.creatureGroups.find(spawnId);
        if (group != state.creatureGroups.end())
            EnqueueLocked(state, JobType::DespawnCreature, spawnId, gridId, group->second.generation);
    }

    if (DensityConfig::Instance().IsDebugEnabled())
        LOG_INFO("module.density_test", "[UlduarDensity] Grid released: grid={}:{} creatureGroups={} "
            "gameObjects={}", GridCoordFor(gridId).x_coord, GridCoordFor(gridId).y_coord,
            grid.creatureGroups.size(), grid.gameObjectGroups.size());
}

void DensityManager::EnqueueLocked(MapState& state, JobType type, SpawnId spawnId, uint32 gridId, uint32 generation)
{
    Job job{ type, spawnId, gridId, generation, nullptr };
    if (type == JobType::SpawnCreature)
        job.progress = std::make_shared<CreatureJobProgress>();

    state.queue.push_back(std::move(job));

    if (type == JobType::SpawnCreature || type == JobType::SpawnGameObject)
    {
        auto grid = state.grids.find(gridId);
        if (grid != state.grids.end() && grid->second.generation == generation)
            ++grid->second.pendingJobs;
    }
}

bool DensityManager::IsCurrentLocked(MapState const& state, uint32 gridId, uint32 generation) const
{
    auto grid = state.grids.find(gridId);
    return grid != state.grids.end() && grid->second.status != GridStatus::Inactive &&
        grid->second.generation == generation;
}

DensityStats& DensityManager::StatsLocked(MapState& state)
{
    return state.stats;
}

void DensityManager::ProcessQueue(Map* map, uint32 /*diff*/)
{
    uint64 const start = NowUs();
    uint64 const deadline = start + DensityConfig::Instance().GetWorkBudgetUs();
    uint32 executed = 0;
    bool worked = false;

    while (true)
    {
        Job job;
        {
            std::lock_guard lock(_mutex);
            MapState& state = _maps[map->GetId()];
            if (state.queue.empty())
                break;

            job = std::move(state.queue.front());
            state.queue.pop_front();
        }

        worked = true;

        // Objects are only touched here, in the map's own update, without holding
        // _mutex: creating/removing objects re-enters the Add/RemoveWorld hooks.
        bool const finished = ExecuteJob(map, job, deadline);

        {
            std::lock_guard lock(_mutex);
            MapState& state = _maps[map->GetId()];
            if (!finished)
            {
                state.queue.push_front(std::move(job));
                break;
            }

            ++executed;
            FinishJobLocked(map, state, job);
        }

        if (NowUs() >= deadline)
            break;
    }

    if (!worked)
        return;

    uint32 const sliceUs = uint32(NowUs() - start);
    std::lock_guard lock(_mutex);
    DensityStats& stats = StatsLocked(_maps[map->GetId()]);
    stats.workUs += sliceUs;
    stats.maxSliceUs = std::max(stats.maxSliceUs, sliceUs);
    ++stats.slices;
    if (_worldReady)
        stats.jobsAfterReady += executed;
    else
        stats.jobsBeforeReady += executed;
}

bool DensityManager::ExecuteJob(Map* map, Job& job, uint64 deadlineUs)
{
    switch (job.type)
    {
        case JobType::SpawnCreature:
            return ExecuteSpawnCreature(map, job, deadlineUs);
        case JobType::SpawnGameObject:
            ExecuteSpawnGameObject(map, job);
            return true;
        case JobType::DespawnCreature:
            ExecuteDespawnCreature(map, job);
            return true;
        case JobType::DespawnGameObject:
            ExecuteDespawnGameObject(map, job);
            return true;
    }

    return true;
}

void DensityManager::FinishJobLocked(Map* map, MapState& state, Job const& job)
{
    if (job.type != JobType::SpawnCreature && job.type != JobType::SpawnGameObject)
        return;

    auto gridItr = state.grids.find(job.gridId);
    if (gridItr == state.grids.end() || gridItr->second.generation != job.generation)
        return;

    GridState& grid = gridItr->second;
    if (job.type == JobType::SpawnCreature && job.progress && job.progress->initialized)
        grid.activation.placement.Add(job.progress->placementStats);

    if (grid.pendingJobs)
        --grid.pendingJobs;

    if (!grid.pendingJobs && grid.status != GridStatus::Inactive)
        ReportGridLocked(map, job.gridId, grid);
}

void DensityManager::ReportGridLocked(Map* map, uint32 gridId, GridState& grid)
{
    GridActivation& activation = grid.activation;
    if (activation.reported)
        return;

    activation.reported = true;
    uint32 const wallMs = GetMSTimeDiffToNow(activation.startMs);

    DensityStats& stats = StatsLocked(_maps[map->GetId()]);
    stats.activationWallMsTotal += wallMs;
    stats.activationWallMsMax = std::max(stats.activationWallMsMax, wallMs);

    GridCoord const coord = GridCoordFor(gridId);
    LOG_INFO("module.density_test", "[UlduarDensity] Grid activated: map={} grid={}:{} base={} eligible={} "
        "mirrors={} clones={} unplaced={} gameobjects={} cacheHits={} rejectedCandidates={} placement={}ms "
        "work={}ms wall={}ms players={}", map->GetId(), coord.x_coord, coord.y_coord, activation.creatures,
        activation.eligible, activation.mirrors, activation.clones, activation.unplaced, activation.gameObjects,
        activation.cacheHits, activation.placement.TotalRejects(), activation.placement.timeUs / 1000.0,
        activation.workUs / 1000.0, wallMs, grid.neededBy);
}

// ---------------------------------------------------------------------------
// Jobs
// ---------------------------------------------------------------------------

bool DensityManager::ExecuteSpawnCreature(Map* map, Job& job, uint64 deadlineUs)
{
    DensityConfig const& config = DensityConfig::Instance();
    CreatureJobProgress& progress = *job.progress;
    uint64 const start = NowUs();

    if (!progress.initialized)
    {
        progress.initialized = true;

        ObjectGuid sourceGuid;
        {
            std::lock_guard lock(_mutex);
            MapState& state = _maps[map->GetId()];
            if (!IsCurrentLocked(state, job.gridId, job.generation) || state.creatureGroups.contains(job.spawnId))
                return true;

            auto record = state.creatureSources.find(job.spawnId);
            if (record == state.creatureSources.end())
                return true;

            sourceGuid = record->second.guid;

            CreatureGroup& group = state.creatureGroups[job.spawnId];
            group.gridId = job.gridId;
            group.generation = job.generation;
            state.grids[job.gridId].creatureGroups.insert(job.spawnId);

            if (auto cache = state.positionCache.find(job.spawnId); cache != state.positionCache.end())
            {
                progress.cached = cache->second.positions;
                progress.cacheComplete = cache->second.wanted >= config.GetMultiplier() - 1;
            }
        }

        progress.data = sObjectMgr->GetCreatureData(job.spawnId);
        if (!progress.data)
            return true;

        // Keep the original's rolled entry (id1/id2/id3) when it is in the world.
        Creature const* source = sourceGuid ? map->GetCreature(sourceGuid) : nullptr;
        progress.entry = source ? source->GetEntry() : progress.data->id;
        progress.decision = DensityEligibility::Classify(sObjectMgr->GetCreatureTemplate(progress.entry),
            progress.data);
        progress.wanted = progress.decision == DensityDecision::Multiply ? config.GetMultiplier() : 1;

        if (config.IsDebugEnabled())
            LOG_INFO("module.density_test", "[UlduarDensity] Spawn {} entry {}: {} ({} representations).",
                job.spawnId, progress.entry, DensityEligibility::DecisionName(progress.decision), progress.wanted);
    }

    Position const origin(progress.data->posX, progress.data->posY, progress.data->posZ,
        progress.data->orientation);

    uint32 createdMirrors = 0;
    uint32 createdClones = 0;
    uint32 createFailures = 0;
    uint32 unplaced = 0;
    uint32 cacheHits = 0;
    bool finished = true;

    while (progress.nextCopy < progress.wanted)
    {
        // Always make progress on a fresh job; otherwise respect the budget.
        if (progress.nextCopy > 0 && NowUs() >= deadlineUs)
        {
            finished = false;
            break;
        }

        {
            std::lock_guard lock(_mutex);
            if (!IsCurrentLocked(_maps[map->GetId()], job.gridId, job.generation))
                break; // grid released while this job was queued/resumed
        }

        uint32 const copyIndex = progress.nextCopy;
        Position position = origin;
        if (copyIndex > 0)
        {
            if (copyIndex - 1 < progress.cached.size())
            {
                position = progress.cached[copyIndex - 1];
                ++cacheHits;
            }
            else if (progress.cacheComplete)
            {
                unplaced += progress.wanted - copyIndex;
                break;
            }
            else
            {
                Creature const* probe = progress.mirror ? map->GetCreature(progress.mirror) : nullptr;
                if (!probe)
                {
                    unplaced += progress.wanted - copyIndex;
                    break;
                }

                if (!progress.placement)
                    progress.placement = std::make_unique<DensityPlacement>(origin, uint32(job.spawnId),
                        progress.wanted - 1);

                if (!progress.placement->Next(probe, position, progress.placementStats))
                {
                    unplaced += progress.wanted - copyIndex;
                    if (config.IsDebugEnabled())
                        LOG_INFO("module.density_test", "[UlduarDensity] Spawn {}: {} of {} clones placed.",
                            job.spawnId, copyIndex - 1, progress.wanted - 1);
                    break;
                }
            }
        }

        ++progress.nextCopy;

        Creature* copy = CreateCreatureRepresentation(map, progress, job.spawnId, position, copyIndex, job.gridId,
            job.generation);
        if (!copy)
        {
            ++createFailures;
            if (copyIndex == 0)
            {
                unplaced += progress.wanted - 1;
                break;
            }
            continue;
        }

        if (copyIndex == 0)
        {
            progress.mirror = copy->GetGUID();
            ++createdMirrors;
        }
        else
            ++createdClones;

        bool tracked = false;
        {
            std::lock_guard lock(_mutex);
            auto group = _maps[map->GetId()].creatureGroups.find(job.spawnId);
            if (group != _maps[map->GetId()].creatureGroups.end() && group->second.generation == job.generation)
            {
                group->second.members.push_back(copy->GetGUID());
                tracked = true;
            }
        }

        // Never under _mutex: removal re-enters OnCreatureRemoveWorld synchronously.
        if (!tracked)
            copy->AddObjectToRemoveList();
    }

    uint64 const workUs = NowUs() - start;

    std::lock_guard lock(_mutex);
    MapState& state = _maps[map->GetId()];
    DensityStats& stats = StatsLocked(state);
    stats.mirrorsCreated += createdMirrors;
    stats.clonesCreated += createdClones;
    stats.clonesUnplaced += unplaced;
    stats.createFailures += createFailures;
    stats.positionCacheHits += cacheHits;

    auto gridItr = state.grids.find(job.gridId);
    GridActivation* activation = gridItr != state.grids.end() && gridItr->second.generation == job.generation ?
        &gridItr->second.activation : nullptr;
    if (activation)
    {
        activation->mirrors += createdMirrors;
        activation->clones += createdClones;
        activation->unplaced += unplaced;
        activation->cacheHits += cacheHits;
        activation->workUs += workUs;
    }

    if (!finished)
        return false;

    // Count the spawn once, when its job completes.
    if (progress.decision != DensityDecision::Max)
    {
        ++stats.creaturesInspected;
        if (progress.decision == DensityDecision::Multiply)
            ++stats.creaturesEligible;
        else
            ++stats.creaturesRejected[size_t(progress.decision)];

        stats.placement.Add(progress.placementStats);

        if (activation)
        {
            ++activation->creatures;
            if (progress.decision == DensityDecision::Multiply)
                ++activation->eligible;
        }
    }

    // Terrain is static: remember the search result so the next activation of
    // this grid (or a respawned source) reuses it without any geometry query.
    // Only a finished search is cached: one cut short by a grid release would
    // otherwise pin the spawn to fewer clones forever.
    if (progress.placement && (progress.placement->IsExhausted() ||
        progress.placement->GetAccepted().size() >= progress.wanted - 1))
    {
        CachedPositions& cache = state.positionCache[job.spawnId];
        cache.positions = progress.placement->GetAccepted();
        cache.wanted = progress.wanted - 1;
    }

    return true;
}

void DensityManager::ExecuteSpawnGameObject(Map* map, Job& job)
{
    uint64 const start = NowUs();
    {
        std::lock_guard lock(_mutex);
        MapState& state = _maps[map->GetId()];
        if (!IsCurrentLocked(state, job.gridId, job.generation) || state.gameObjectGroups.contains(job.spawnId) ||
            !state.gameObjectSources.contains(job.spawnId))
            return;

        GameObjectGroup& group = state.gameObjectGroups[job.spawnId];
        group.gridId = job.gridId;
        group.generation = job.generation;
        state.grids[job.gridId].gameObjectGroups.insert(job.spawnId);
    }

    GameObject* mirror = CreateGameObjectRepresentation(map, job.spawnId, job.gridId, job.generation);

    bool tracked = false;
    {
        std::lock_guard lock(_mutex);
        MapState& state = _maps[map->GetId()];
        DensityStats& stats = StatsLocked(state);
        if (!mirror)
        {
            ++stats.createFailures;
            return;
        }

        ++stats.gameObjectsMirrored;
        auto group = state.gameObjectGroups.find(job.spawnId);
        if (group != state.gameObjectGroups.end() && group->second.generation == job.generation)
        {
            group->second.mirror = mirror->GetGUID();
            tracked = true;
        }

        auto grid = state.grids.find(job.gridId);
        if (grid != state.grids.end() && grid->second.generation == job.generation)
        {
            ++grid->second.activation.gameObjects;
            grid->second.activation.workUs += NowUs() - start;
        }
    }

    if (!tracked)
        mirror->AddObjectToRemoveList();
}

void DensityManager::ExecuteDespawnCreature(Map* map, Job& job)
{
    GuidVector members;
    {
        std::lock_guard lock(_mutex);
        MapState& state = _maps[map->GetId()];
        auto group = state.creatureGroups.find(job.spawnId);
        if (group == state.creatureGroups.end() || group->second.generation != job.generation)
            return;

        members = std::move(group->second.members);
        state.creatureGroups.erase(group);

        auto grid = state.grids.find(job.gridId);
        if (grid != state.grids.end())
            grid->second.creatureGroups.erase(job.spawnId);

        StatsLocked(state).representationsRemoved += members.size();
    }

    for (ObjectGuid const& guid : members)
        if (Creature* copy = map->GetCreature(guid))
            copy->AddObjectToRemoveList();
}

void DensityManager::ExecuteDespawnGameObject(Map* map, Job& job)
{
    ObjectGuid mirror;
    {
        std::lock_guard lock(_mutex);
        MapState& state = _maps[map->GetId()];
        auto group = state.gameObjectGroups.find(job.spawnId);
        if (group == state.gameObjectGroups.end() || group->second.generation != job.generation)
            return;

        mirror = group->second.mirror;
        state.gameObjectGroups.erase(group);

        auto grid = state.grids.find(job.gridId);
        if (grid != state.grids.end())
            grid->second.gameObjectGroups.erase(job.spawnId);

        if (mirror)
            ++StatsLocked(state).representationsRemoved;
    }

    if (mirror)
        if (GameObject* gameObject = map->GetGameObject(mirror))
            gameObject->AddObjectToRemoveList();
}

Creature* DensityManager::CreateCreatureRepresentation(Map* map, CreatureJobProgress const& progress,
    SpawnId spawnId, Position const& position, uint32 copyIndex, uint32 gridId, uint32 generation) const
{
    DensityConfig const& config = DensityConfig::Instance();
    CreatureData const* data = progress.data;

    Creature* copy = new Creature();
    if (!copy->Create(map->GenerateLowGuid<HighGuid::Unit>(), map, config.GetDensityPhaseMask(), progress.entry, 0,
        position.GetPositionX(), position.GetPositionY(), position.GetPositionZ(), position.GetOrientation(), data))
    {
        delete copy;
        return nullptr;
    }

    copy->SetHomePosition(position);
    copy->SetRespawnDelay(data->spawntimesecs);

    MovementGeneratorType const movementType = MovementGeneratorType(data->movementType);
    if (copyIndex == 0)
    {
        // The mirror stands in for the original and keeps its movement.
        copy->SetWanderDistance(data->wander_distance);
        copy->SetDefaultMovementType(movementType);
        if (CreatureAddon const* addon = sObjectMgr->GetCreatureAddon(spawnId))
            copy->LoadPath(addon->path_id);
    }
    else if (movementType == WAYPOINT_MOTION_TYPE)
    {
        // Extra clones of a patrol would stack on the same path and, since waypoint
        // movers are always updated, could walk into (and load) other grids.
        // They roam around their own spot instead.
        copy->SetWanderDistance(std::max(data->wander_distance, config.GetCloneMaxDistance()));
        copy->SetDefaultMovementType(RANDOM_MOTION_TYPE);
    }
    else
    {
        copy->SetWanderDistance(data->wander_distance);
        copy->SetDefaultMovementType(movementType);
    }

    copy->CustomData.Set(DENSITY_OBJECT_DATA_KEY,
        new DensityObjectData(DensityObjectKind::Creature, spawnId, gridId, generation, copyIndex));

    if (!map->AddToMap(copy))
    {
        delete copy;
        return nullptr;
    }

    return copy;
}

GameObject* DensityManager::CreateGameObjectRepresentation(Map* map, SpawnId spawnId, uint32 gridId,
    uint32 generation) const
{
    GameObjectData const* data = sObjectMgr->GetGameObjectData(spawnId);
    if (!data)
        return nullptr;

    DensityConfig const& config = DensityConfig::Instance();
    GameObject* copy = new GameObject();
    if (!copy->Create(map->GenerateLowGuid<HighGuid::GameObject>(), data->id, map, config.GetDensityPhaseMask(),
        data->posX, data->posY, data->posZ, data->orientation, data->rotation, data->animprogress, data->go_state,
        data->artKit))
    {
        delete copy;
        return nullptr;
    }

    // Same meaning as GameObject::LoadGameObjectFromDB: a negative spawntimesecs is
    // an object that stays despawned until something spawns it.
    copy->SetRespawnDelay(std::abs(data->spawntimesecs));
    copy->SetSpawnedByDefault(data->spawntimesecs >= 0);
    copy->CustomData.Set(DENSITY_OBJECT_DATA_KEY,
        new DensityObjectData(DensityObjectKind::GameObject, spawnId, gridId, generation, 0));

    if (!map->AddToMap(copy))
    {
        delete copy;
        return nullptr;
    }

    return copy;
}

// ---------------------------------------------------------------------------
// Density group aggro
// ---------------------------------------------------------------------------

void DensityManager::OnCreatureEngaged(Creature* creature, Unit* target)
{
    if (t_propagatingGroupAggro || !creature || !target || !DensityConfig::Instance().IsGroupAggroEnabled())
        return;

    DensityObjectData const* objectData = GetDensityObjectData(creature);
    if (!objectData || objectData->kind != DensityObjectKind::Creature)
        return;

    GuidVector members;
    {
        std::lock_guard lock(_mutex);
        auto mapItr = _maps.find(creature->GetMapId());
        if (mapItr == _maps.end())
            return;

        auto group = mapItr->second.creatureGroups.find(objectData->spawnId);
        if (group == mapItr->second.creatureGroups.end() || group->second.generation != objectData->generation)
            return;

        members = group->second.members;
    }

    // Same assist rule as CreatureGroup::MemberEngagingTarget (formations): idle,
    // living members engage the unit this member engaged. That unit is whatever
    // AzerothCore passed to AtEngage: the player, or the pet/guardian/charmed unit
    // that attacked; its owner joins through the core's own combat propagation.
    t_propagatingGroupAggro = true;
    uint32 pulled = 0;
    for (ObjectGuid const& guid : members)
    {
        if (guid == creature->GetGUID())
            continue;

        Creature* member = creature->GetMap()->GetCreature(guid);
        if (!member || !member->IsInWorld() || !member->IsAlive() || member->IsInCombat() || member->GetVictim())
            continue;

        if (!member->IsValidAttackTarget(target))
            continue;

        member->EngageWithTarget(target);
        ++pulled;
    }
    t_propagatingGroupAggro = false;

    if (pulled)
    {
        std::lock_guard lock(_mutex);
        StatsLocked(_maps[creature->GetMapId()]).groupAggroPulls += pulled;
    }
}

// ---------------------------------------------------------------------------
// Status and statistics
// ---------------------------------------------------------------------------

DensityManager::Status DensityManager::GetStatus() const
{
    Status status;
    std::lock_guard lock(_mutex);
    for (auto const& [mapId, state] : _maps)
    {
        for (auto const& [gridId, grid] : state.grids)
        {
            if (grid.status == GridStatus::Active)
                ++status.activeGrids;
            else if (grid.status == GridStatus::Lingering)
                ++status.lingeringGrids;
        }

        status.queuedJobs += uint32(state.queue.size());
        status.groups += uint32(state.creatureGroups.size());
        for (auto const& [spawnId, group] : state.creatureGroups)
            status.creatureRepresentations += uint32(group.members.size());
        for (auto const& [spawnId, group] : state.gameObjectGroups)
            if (group.mirror)
                ++status.gameObjectRepresentations;
    }

    return status;
}

DensityStats DensityManager::GetStats() const
{
    DensityStats total;
    std::lock_guard lock(_mutex);
    for (auto const& [mapId, state] : _maps)
        total.Add(state.stats);
    return total;
}

void DensityManager::ResetStats()
{
    std::lock_guard lock(_mutex);
    for (auto& [mapId, state] : _maps)
        state.stats = DensityStats();
}

void DensityManager::LogStatsLocked(Map* map, MapState const& state) const
{
    DensityStats const& stats = state.stats;
    LOG_INFO("module.density_test", "[UlduarDensity] Stats map={}: activations={} reuses={} releases={} "
        "inspected={} eligible={} mirrors={} clones={} unplaced={} rejectedCandidates={} placement={}ms "
        "work={}ms maxSlice={}us jobs(beforeReady={} afterReady={}) maxDiff(busy={}ms idle={}ms) aggroPulls={}",
        map->GetId(), stats.gridActivations, stats.gridReuses, stats.gridDeactivations, stats.creaturesInspected,
        stats.creaturesEligible, stats.mirrorsCreated, stats.clonesCreated, stats.clonesUnplaced,
        stats.placement.TotalRejects(), stats.placement.timeUs / 1000.0, stats.workUs / 1000.0, stats.maxSliceUs,
        stats.jobsBeforeReady, stats.jobsAfterReady, stats.maxDiffWhileBusy, stats.maxDiffWhileIdle,
        stats.groupAggroPulls);
}
