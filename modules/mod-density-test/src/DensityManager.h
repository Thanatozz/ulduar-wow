/*
 * This file is part of the mod-density-test project.
 */

#ifndef MOD_DENSITY_TEST_MANAGER_H
#define MOD_DENSITY_TEST_MANAGER_H

#include "DensityEligibility.h"
#include "DensityPlacement.h"
#include "ObjectGuid.h"

#include <array>
#include <deque>
#include <memory>
#include <mutex>
#include <unordered_map>
#include <unordered_set>

class Creature;
class GameObject;
class Map;
class Player;
class Unit;
class WorldObject;

// Aggregated, cheap counters. Everything the old per-spawn log lines reported
// is summed here instead, and read through `.density stats` or the periodic
// StatsLogInterval summary.
struct DensityStats
{
    // Source index (hooks)
    uint64 sourcesIndexedBeforeReady = 0;
    uint64 sourcesIndexedAfterReady = 0;

    // Queue work
    uint64 jobsBeforeReady = 0;
    uint64 jobsAfterReady = 0;
    uint64 workUs = 0;
    uint32 maxSliceUs = 0;
    uint32 slices = 0;

    // Grid lifecycle
    uint32 gridActivations = 0;
    uint32 gridReuses = 0;
    uint32 gridDeactivations = 0;
    uint64 activationWallMsTotal = 0;
    uint32 activationWallMsMax = 0;

    // Creatures
    uint64 creaturesInspected = 0;
    uint64 creaturesEligible = 0;
    std::array<uint64, size_t(DensityDecision::Max)> creaturesRejected{};
    uint64 mirrorsCreated = 0;
    uint64 clonesCreated = 0;
    uint64 clonesUnplaced = 0;
    uint64 createFailures = 0;
    uint64 gameObjectsMirrored = 0;
    uint64 representationsRemoved = 0;
    uint64 positionCacheHits = 0;
    PlacementStats placement;

    // Combat
    uint64 groupAggroPulls = 0;

    // Map update latency observed by the module (diff passed to OnMapUpdate)
    uint32 maxDiffWhileBusy = 0;
    uint32 maxDiffWhileIdle = 0;

    void Add(DensityStats const& other);
};

class DensityManager final
{
public:
    enum class EnableResult
    {
        Enabled,
        ModuleDisabled,
        OutsideTargetZone
    };

    struct Status
    {
        uint32 activeGrids = 0;
        uint32 lingeringGrids = 0;
        uint32 queuedJobs = 0;
        uint32 creatureRepresentations = 0;
        uint32 gameObjectRepresentations = 0;
        uint32 groups = 0;
    };

    static DensityManager& Instance();

    // Player layer membership
    EnableResult EnableFor(Player* player);
    void DisableFor(Player* player);
    void HandleLogin(Player* player);
    void HandleBeforeLogout(Player* player);
    void HandleLogout(Player* player);
    void HandleLocationChanged(Player* player);

    [[nodiscard]] bool IsDensityEnabled(ObjectGuid playerGuid) const;
    [[nodiscard]] bool IsInTargetLocation(WorldObject const* object) const;

    // Source index. Cheap; may run on any thread that adds objects to a map.
    void OnCreatureAddWorld(Creature* creature);
    void OnCreatureRemoveWorld(Creature* creature);
    void OnGameObjectAddWorld(GameObject* gameObject);
    void OnGameObjectRemoveWorld(GameObject* gameObject);

    // Grid activation scan + budgeted work queue. Runs in the map's own update.
    void OnMapUpdate(Map* map, uint32 diff);
    void OnDestroyMap(Map* map);
    void OnWorldReady();

    // Density group aggro
    void OnCreatureEngaged(Creature* creature, Unit* target);

    [[nodiscard]] Status GetStatus() const;
    [[nodiscard]] DensityStats GetStats() const;
    void ResetStats();

private:
    using SpawnId = ObjectGuid::LowType;

    enum class JobType : uint8
    {
        SpawnGameObject,
        SpawnCreature,
        DespawnGameObject,
        DespawnCreature
    };

    struct CreatureJobProgress
    {
        bool initialized = false;
        CreatureData const* data = nullptr;
        uint32 entry = 0;
        DensityDecision decision = DensityDecision::Max;
        uint32 wanted = 0;
        uint32 nextCopy = 0;
        ObjectGuid mirror;
        std::vector<Position> cached;
        bool cacheComplete = false;
        std::unique_ptr<DensityPlacement> placement;
        PlacementStats placementStats;
    };

    struct Job
    {
        JobType type;
        SpawnId spawnId;
        uint32 gridId;
        uint32 generation;
        std::shared_ptr<CreatureJobProgress> progress;
    };

    struct SourceRecord
    {
        uint32 gridId = 0;
        ObjectGuid guid;            // empty while the source is out of the world (dynamic respawn)
    };

    struct CreatureGroup
    {
        uint32 gridId = 0;
        uint32 generation = 0;
        GuidVector members;         // every density-phase representation of the spawn
    };

    struct GameObjectGroup
    {
        uint32 gridId = 0;
        uint32 generation = 0;
        ObjectGuid mirror;
    };

    struct CachedPositions
    {
        std::vector<Position> positions;
        uint32 wanted = 0;
    };

    enum class GridStatus : uint8
    {
        Inactive,
        Active,
        Lingering
    };

    struct GridActivation
    {
        uint32 startMs = 0;
        uint32 creatures = 0;
        uint32 eligible = 0;
        uint32 mirrors = 0;
        uint32 clones = 0;
        uint32 unplaced = 0;
        uint32 gameObjects = 0;
        uint32 cacheHits = 0;
        PlacementStats placement;
        uint64 workUs = 0;
        bool reported = false;
    };

    struct GridState
    {
        GridStatus status = GridStatus::Inactive;
        uint32 generation = 0;
        uint32 neededBy = 0;
        uint32 lingerStartMs = 0;
        uint32 pendingJobs = 0;
        GridActivation activation;
        std::unordered_set<SpawnId> creatureGroups;
        std::unordered_set<SpawnId> gameObjectGroups;
    };

    struct MapState
    {
        std::unordered_map<SpawnId, SourceRecord> creatureSources;
        std::unordered_map<SpawnId, SourceRecord> gameObjectSources;
        std::unordered_map<uint32, std::unordered_set<SpawnId>> creaturesByGrid;
        std::unordered_map<uint32, std::unordered_set<SpawnId>> gameObjectsByGrid;
        std::unordered_map<uint32, GridState> grids;
        std::unordered_map<SpawnId, CreatureGroup> creatureGroups;
        std::unordered_map<SpawnId, GameObjectGroup> gameObjectGroups;
        std::unordered_map<SpawnId, CachedPositions> positionCache;
        std::deque<Job> queue;
        uint32 scanTimer = 0;
        uint32 statsTimer = 0;
        DensityStats stats;
    };

    DensityManager() = default;

    void ApplyPlayerPhase(Player* player, uint32 phaseMask, bool stopCombat) const;
    [[nodiscard]] bool IsLocationEnabled(Map const* map, uint32 zoneId) const;

    // All *Locked functions require _mutex to be held.
    void ScanGrids(Map* map, MapState& state);
    void ActivateGridLocked(Map* map, MapState& state, uint32 gridId, GridState& grid);
    void DeactivateGridLocked(MapState& state, uint32 gridId, GridState& grid);
    void EnqueueLocked(MapState& state, JobType type, SpawnId spawnId, uint32 gridId, uint32 generation);
    void FinishJobLocked(Map* map, MapState& state, Job const& job);
    void ReportGridLocked(Map* map, uint32 gridId, GridState& grid);
    void LogStatsLocked(Map* map, MapState const& state) const;

    void ProcessQueue(Map* map, uint32 diff);
    // Returns false when the job ran out of budget and must resume next update.
    bool ExecuteJob(Map* map, Job& job, uint64 deadlineUs);
    bool ExecuteSpawnCreature(Map* map, Job& job, uint64 deadlineUs);
    void ExecuteSpawnGameObject(Map* map, Job& job);
    void ExecuteDespawnCreature(Map* map, Job& job);
    void ExecuteDespawnGameObject(Map* map, Job& job);

    [[nodiscard]] Creature* CreateCreatureRepresentation(Map* map, CreatureJobProgress const& progress,
        SpawnId spawnId, Position const& position, uint32 copyIndex, uint32 gridId, uint32 generation) const;
    [[nodiscard]] GameObject* CreateGameObjectRepresentation(Map* map, SpawnId spawnId, uint32 gridId,
        uint32 generation) const;

    [[nodiscard]] bool IsCurrentLocked(MapState const& state, uint32 gridId, uint32 generation) const;
    [[nodiscard]] DensityStats& StatsLocked(MapState& state);

    mutable std::mutex _mutex;
    GuidUnorderedSet _densityPlayers;
    std::unordered_map<uint32, MapState> _maps;
    bool _worldReady = false;
};

#endif
