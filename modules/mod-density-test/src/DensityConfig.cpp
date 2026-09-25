/*
 * This file is part of the mod-density-test project.
 */

#include "DensityConfig.h"

#include "Log.h"
#include "ObjectDefines.h"
#include "Tokenize.h"

#include <charconv>

namespace
{
bool IsSinglePhaseBit(uint32 phaseMask)
{
    return phaseMask != 0 && (phaseMask & (phaseMask - 1)) == 0;
}

std::unordered_set<uint32> ParseIdList(std::string_view text, char const* optionName)
{
    std::unordered_set<uint32> ids;
    for (std::string_view token : Acore::Tokenize(text, ',', false))
    {
        while (!token.empty() && token.front() == ' ')
            token.remove_prefix(1);
        while (!token.empty() && token.back() == ' ')
            token.remove_suffix(1);

        uint32 id = 0;
        auto const [ptr, error] = std::from_chars(token.data(), token.data() + token.size(), id);
        if (error != std::errc() || ptr != token.data() + token.size())
        {
            LOG_ERROR("module.density_test", "[UlduarDensity] Ignoring invalid id '{}' in {}.", token, optionName);
            continue;
        }

        ids.insert(id);
    }

    return ids;
}
}

DensityConfig& DensityConfig::Instance()
{
    static DensityConfig instance;
    return instance;
}

DensityConfig::DensityConfig() : ConfigValueCache(DensityConfigKey::Count)
{
}

void DensityConfig::Load(bool reload)
{
    Initialize(reload);
    ParseFilters();
    Validate();
}

void DensityConfig::BuildConfigCache()
{
    using Reloadable = ConfigValueCache<DensityConfigKey>::Reloadable;

    SetConfigValue<bool>(DensityConfigKey::Enable, "mod_density_test.Enable", true, Reloadable::No);

    // Filters. The test keeps density restricted to Mulgore (map 1, zone 215).
    SetConfigValue<std::string>(DensityConfigKey::EnabledMaps, "mod_density_test.EnabledMaps", "1", Reloadable::No);
    SetConfigValue<std::string>(DensityConfigKey::DisabledMaps, "mod_density_test.DisabledMaps", "", Reloadable::No);
    SetConfigValue<std::string>(DensityConfigKey::EnabledZones, "mod_density_test.EnabledZones", "215", Reloadable::No);
    SetConfigValue<std::string>(DensityConfigKey::DisabledZones, "mod_density_test.DisabledZones", "", Reloadable::No);

    SetConfigValue<uint32>(DensityConfigKey::Multiplier, "mod_density_test.Multiplier", 5, Reloadable::No,
        [](uint32 value) { return value >= 1 && value <= 100; }, "value must be between 1 and 100");
    SetConfigValue<uint32>(DensityConfigKey::NormalPhaseMask, "mod_density_test.NormalPhaseMask", 1,
        Reloadable::No, [](uint32 value) { return value != 0; }, "value must be non-zero");
    SetConfigValue<uint32>(DensityConfigKey::DensityPhaseMask, "mod_density_test.DensityPhaseMask", 2,
        Reloadable::No, [](uint32 value) { return value != 0; }, "value must be non-zero");

    // Placement
    SetConfigValue<float>(DensityConfigKey::CloneMinDistance, "mod_density_test.CloneMinDistance", 1.5f,
        Reloadable::No, [](float value) { return value >= 0.5f && value <= 20.0f; },
        "value must be between 0.5 and 20.0");
    SetConfigValue<float>(DensityConfigKey::CloneMaxDistance, "mod_density_test.CloneMaxDistance", 5.0f,
        Reloadable::No, [](float value) { return value >= 0.5f && value <= 20.0f; },
        "value must be between 0.5 and 20.0");
    SetConfigValue<float>(DensityConfigKey::CloneMinSeparation, "mod_density_test.CloneMinSeparation", 1.0f,
        Reloadable::No, [](float value) { return value >= 0.0f && value <= 10.0f; },
        "value must be between 0.0 and 10.0");
    SetConfigValue<uint32>(DensityConfigKey::PositionAttemptsPerClone, "mod_density_test.PositionAttemptsPerClone",
        3, Reloadable::No, [](uint32 value) { return value >= 1 && value <= 12; }, "value must be between 1 and 12");
    SetConfigValue<bool>(DensityConfigKey::ValidatePathing, "mod_density_test.ValidatePathing", true);

    // Lazy grid activation and work queue
    SetConfigValue<float>(DensityConfigKey::ActivationRadius, "mod_density_test.ActivationRadius", 150.0f,
        Reloadable::No, [](float value) { return value >= 0.0f && value <= MAX_VISIBILITY_DISTANCE; },
        "value must be between 0 and 250 (grids further away are never loaded by the core)");
    SetConfigValue<uint32>(DensityConfigKey::UnloadDelay, "mod_density_test.UnloadDelay", 60,
        Reloadable::Yes, [](uint32 value) { return value <= 3600; }, "value must be between 0 and 3600 seconds");
    SetConfigValue<uint32>(DensityConfigKey::ScanInterval, "mod_density_test.ScanInterval", 1000,
        Reloadable::Yes, [](uint32 value) { return value >= 100 && value <= 10000; },
        "value must be between 100 and 10000 ms");
    SetConfigValue<float>(DensityConfigKey::WorkBudgetMs, "mod_density_test.WorkBudgetMs", 2.0f,
        Reloadable::Yes, [](float value) { return value >= 0.1f && value <= 50.0f; },
        "value must be between 0.1 and 50 ms");

    SetConfigValue<bool>(DensityConfigKey::GroupAggro, "mod_density_test.GroupAggro", true);
    SetConfigValue<uint32>(DensityConfigKey::StatsLogInterval, "mod_density_test.StatsLogInterval", 0,
        Reloadable::Yes, [](uint32 value) { return value <= 86400; }, "value must be between 0 and 86400 seconds");
    SetConfigValue<bool>(DensityConfigKey::Debug, "mod_density_test.Debug", false);
}

void DensityConfig::ParseFilters()
{
    _enabledMaps = ParseIdList(GetConfigValue(DensityConfigKey::EnabledMaps), "mod_density_test.EnabledMaps");
    _disabledMaps = ParseIdList(GetConfigValue(DensityConfigKey::DisabledMaps), "mod_density_test.DisabledMaps");
    _enabledZones = ParseIdList(GetConfigValue(DensityConfigKey::EnabledZones), "mod_density_test.EnabledZones");
    _disabledZones = ParseIdList(GetConfigValue(DensityConfigKey::DisabledZones), "mod_density_test.DisabledZones");
}

void DensityConfig::Validate()
{
    uint32 const normalPhaseMask = GetNormalPhaseMask();
    uint32 const densityPhaseMask = GetDensityPhaseMask();

    _valid = true;
    if (!IsSinglePhaseBit(normalPhaseMask) || !IsSinglePhaseBit(densityPhaseMask))
    {
        LOG_ERROR("module.density_test", "[UlduarDensity] NormalPhaseMask and DensityPhaseMask must each contain "
            "exactly one phase bit. The module has been disabled.");
        _valid = false;
    }

    if ((normalPhaseMask & densityPhaseMask) != 0)
    {
        LOG_ERROR("module.density_test", "[UlduarDensity] NormalPhaseMask ({}) and DensityPhaseMask ({}) overlap. "
            "The module has been disabled.", normalPhaseMask, densityPhaseMask);
        _valid = false;
    }

    if (GetCloneMinDistance() > GetCloneMaxDistance())
    {
        LOG_ERROR("module.density_test", "[UlduarDensity] CloneMinDistance ({}) is greater than CloneMaxDistance ({}). "
            "The module has been disabled.", GetCloneMinDistance(), GetCloneMaxDistance());
        _valid = false;
    }

    if (IsEnabled())
    {
        LOG_INFO("module.density_test", "[UlduarDensity] Enabled: maps [{}], zones [{}], density phase {}, "
            "multiplier x{}, radius {}, unload delay {}s, budget {}ms/update.",
            GetConfigValue(DensityConfigKey::EnabledMaps), GetEnabledZonesText(), densityPhaseMask, GetMultiplier(),
            GetActivationRadius(), GetUnloadDelayMs() / IN_MILLISECONDS, GetWorkBudgetUs() / 1000.0f);
    }
}

bool DensityConfig::IsEnabled() const
{
    return _valid && GetConfigValue<bool>(DensityConfigKey::Enable);
}

bool DensityConfig::IsDebugEnabled() const
{
    return GetConfigValue<bool>(DensityConfigKey::Debug);
}

bool DensityConfig::IsMapEnabled(uint32 mapId) const
{
    if (_disabledMaps.contains(mapId))
        return false;

    return _enabledMaps.empty() || _enabledMaps.contains(mapId);
}

bool DensityConfig::IsZoneEnabled(uint32 zoneId) const
{
    if (!zoneId || _disabledZones.contains(zoneId))
        return false;

    return _enabledZones.empty() || _enabledZones.contains(zoneId);
}

std::string_view DensityConfig::GetEnabledZonesText() const
{
    std::string_view const zones = GetConfigValue(DensityConfigKey::EnabledZones);
    return zones.empty() ? std::string_view("all") : zones;
}

uint32 DensityConfig::GetMultiplier() const
{
    return GetConfigValue<uint32>(DensityConfigKey::Multiplier);
}

uint32 DensityConfig::GetNormalPhaseMask() const
{
    return GetConfigValue<uint32>(DensityConfigKey::NormalPhaseMask);
}

uint32 DensityConfig::GetDensityPhaseMask() const
{
    return GetConfigValue<uint32>(DensityConfigKey::DensityPhaseMask);
}

float DensityConfig::GetCloneMinDistance() const
{
    return GetConfigValue<float>(DensityConfigKey::CloneMinDistance);
}

float DensityConfig::GetCloneMaxDistance() const
{
    return GetConfigValue<float>(DensityConfigKey::CloneMaxDistance);
}

float DensityConfig::GetCloneMinSeparation() const
{
    return GetConfigValue<float>(DensityConfigKey::CloneMinSeparation);
}

uint32 DensityConfig::GetPositionAttemptsPerClone() const
{
    return GetConfigValue<uint32>(DensityConfigKey::PositionAttemptsPerClone);
}

bool DensityConfig::ValidatePathing() const
{
    return GetConfigValue<bool>(DensityConfigKey::ValidatePathing);
}

float DensityConfig::GetActivationRadius() const
{
    return GetConfigValue<float>(DensityConfigKey::ActivationRadius);
}

uint32 DensityConfig::GetUnloadDelayMs() const
{
    return GetConfigValue<uint32>(DensityConfigKey::UnloadDelay) * IN_MILLISECONDS;
}

uint32 DensityConfig::GetScanIntervalMs() const
{
    return GetConfigValue<uint32>(DensityConfigKey::ScanInterval);
}

uint32 DensityConfig::GetWorkBudgetUs() const
{
    return uint32(GetConfigValue<float>(DensityConfigKey::WorkBudgetMs) * 1000.0f);
}

bool DensityConfig::IsGroupAggroEnabled() const
{
    return GetConfigValue<bool>(DensityConfigKey::GroupAggro);
}

uint32 DensityConfig::GetStatsLogIntervalMs() const
{
    return GetConfigValue<uint32>(DensityConfigKey::StatsLogInterval) * IN_MILLISECONDS;
}
