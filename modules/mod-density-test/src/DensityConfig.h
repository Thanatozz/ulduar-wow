/*
 * This file is part of the mod-density-test project.
 */

#ifndef MOD_DENSITY_TEST_CONFIG_H
#define MOD_DENSITY_TEST_CONFIG_H

#include "ConfigValueCache.h"

#include <unordered_set>

enum class DensityConfigKey
{
    Enable,
    EnabledMaps,
    DisabledMaps,
    EnabledZones,
    DisabledZones,
    Multiplier,
    NormalPhaseMask,
    DensityPhaseMask,
    CloneMinDistance,
    CloneMaxDistance,
    CloneMinSeparation,
    PositionAttemptsPerClone,
    ValidatePathing,
    ActivationRadius,
    UnloadDelay,
    ScanInterval,
    WorkBudgetMs,
    GroupAggro,
    StatsLogInterval,
    Debug,

    Count
};

class DensityConfig final : private ConfigValueCache<DensityConfigKey>
{
public:
    static DensityConfig& Instance();

    void Load(bool reload);

    [[nodiscard]] bool IsEnabled() const;
    [[nodiscard]] bool IsDebugEnabled() const;

    // Map/zone filters. An empty "enabled" list means every map, or every zone of an
    // enabled map. "Disabled" lists always win. Instanceable maps are never eligible.
    [[nodiscard]] bool IsMapEnabled(uint32 mapId) const;
    [[nodiscard]] bool IsZoneEnabled(uint32 zoneId) const;
    [[nodiscard]] std::string_view GetEnabledZonesText() const;

    [[nodiscard]] uint32 GetMultiplier() const;
    [[nodiscard]] uint32 GetNormalPhaseMask() const;
    [[nodiscard]] uint32 GetDensityPhaseMask() const;
    [[nodiscard]] float GetCloneMinDistance() const;
    [[nodiscard]] float GetCloneMaxDistance() const;
    [[nodiscard]] float GetCloneMinSeparation() const;
    [[nodiscard]] uint32 GetPositionAttemptsPerClone() const;
    [[nodiscard]] bool ValidatePathing() const;
    [[nodiscard]] float GetActivationRadius() const;
    [[nodiscard]] uint32 GetUnloadDelayMs() const;
    [[nodiscard]] uint32 GetScanIntervalMs() const;
    [[nodiscard]] uint32 GetWorkBudgetUs() const;
    [[nodiscard]] bool IsGroupAggroEnabled() const;
    [[nodiscard]] uint32 GetStatsLogIntervalMs() const;

private:
    DensityConfig();

    void BuildConfigCache() override;
    void ParseFilters();
    void Validate();

    bool _valid = false;
    std::unordered_set<uint32> _enabledMaps;
    std::unordered_set<uint32> _disabledMaps;
    std::unordered_set<uint32> _enabledZones;
    std::unordered_set<uint32> _disabledZones;
};

#endif
