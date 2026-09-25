/*
 * This file is part of the mod-density-test project.
 */

#include "DensityPlacement.h"

#include "Creature.h"
#include "DensityConfig.h"
#include "GridDefines.h"
#include "Map.h"
#include "ModelIgnoreFlags.h"

#include <chrono>
#include <cmath>

namespace
{
constexpr float GOLDEN_ANGLE = 2.39996323f;
// Largest height difference accepted per yard of horizontal distance (~50 degrees).
constexpr float MAX_HEIGHT_STEP_PER_YARD = 1.2f;
constexpr float MIN_HEIGHT_STEP = 1.5f;
constexpr float HEIGHT_SEARCH_OFFSET = 4.0f;
constexpr float HEIGHT_SEARCH_DISTANCE = 12.0f;

float SeedToAngle(uint32 seed)
{
    // splitmix-style hash, stable across builds and platforms
    uint32 hash = seed * 0x9E3779B9u;
    hash ^= hash >> 16;
    hash *= 0x85EBCA6Bu;
    hash ^= hash >> 13;
    return float(hash % 36000u) * float(M_PI) / 18000.0f;
}
}

void PlacementStats::Add(PlacementStats const& other)
{
    candidates += other.candidates;
    accepted += other.accepted;
    for (size_t i = 0; i < rejects.size(); ++i)
        rejects[i] += other.rejects[i];
    timeUs += other.timeUs;
}

uint32 PlacementStats::TotalRejects() const
{
    uint32 total = 0;
    for (uint32 count : rejects)
        total += count;
    return total;
}

DensityPlacement::DensityPlacement(Position const& origin, uint32 seed, uint32 wantedClones)
    : _origin(origin), _baseAngle(SeedToAngle(seed)),
    _totalCandidates(wantedClones * DensityConfig::Instance().GetPositionAttemptsPerClone())
{
    _accepted.reserve(wantedClones);
}

bool DensityPlacement::Next(Creature const* probe, Position& result, PlacementStats& stats)
{
    auto const start = std::chrono::steady_clock::now();
    bool found = false;

    if (_originInWater < 0)
        _originInWater = probe->GetMap()->IsInWater(probe->GetPhaseMask(), _origin.GetPositionX(),
            _origin.GetPositionY(), _origin.GetPositionZ(), probe->GetCollisionHeight()) ? 1 : 0;

    while (_nextCandidate < _totalCandidates)
    {
        uint32 const index = _nextCandidate++;
        ++stats.candidates;

        PlacementReject reason = PlacementReject::Max;
        if (TryCandidate(probe, index, result, reason))
        {
            _accepted.push_back(result);
            ++stats.accepted;
            found = true;
            break;
        }

        ++stats.rejects[size_t(reason)];
    }

    stats.timeUs += uint64(std::chrono::duration_cast<std::chrono::microseconds>(
        std::chrono::steady_clock::now() - start).count());
    return found;
}

bool DensityPlacement::TryCandidate(Creature const* probe, uint32 index, Position& result,
    PlacementReject& reason) const
{
    DensityConfig const& config = DensityConfig::Instance();
    Map const* map = probe->GetMap();
    uint32 const phaseMask = probe->GetPhaseMask();

    // Golden-angle spiral: evenly spread, deterministic, no two candidates share a spot.
    float const minDistance = config.GetCloneMinDistance();
    float const maxDistance = config.GetCloneMaxDistance();
    float const radius = minDistance + (maxDistance - minDistance) *
        std::sqrt((float(index) + 0.5f) / float(std::max<uint32>(_totalCandidates, 1)));
    float const angle = _baseAngle + float(index) * GOLDEN_ANGLE;

    float x = _origin.GetPositionX() + radius * std::cos(angle);
    float y = _origin.GetPositionY() + radius * std::sin(angle);
    float z = _origin.GetPositionZ();

    if (!Acore::IsValidMapCoord(x, y) || !map->IsGridLoaded(Acore::ComputeGridCoord(x, y)))
    {
        reason = PlacementReject::GridNotLoaded;
        return false;
    }

    if (!IsSeparated(x, y))
    {
        reason = PlacementReject::Overlap;
        return false;
    }

    if (!probe->CanFly())
    {
        float const ground = map->GetHeight(phaseMask, x, y, z + HEIGHT_SEARCH_OFFSET, true, HEIGHT_SEARCH_DISTANCE);
        float const maxStep = std::max(MIN_HEIGHT_STEP, radius * MAX_HEIGHT_STEP_PER_YARD);
        if (ground <= INVALID_HEIGHT || std::fabs(ground - z) > maxStep)
        {
            reason = PlacementReject::NoGround;
            return false;
        }

        z = ground;
    }

    uint32 const originZone = map->GetZoneId(phaseMask, _origin.GetPositionX(), _origin.GetPositionY(),
        _origin.GetPositionZ());
    if (map->GetZoneId(phaseMask, x, y, z) != originZone || !config.IsZoneEnabled(originZone))
    {
        reason = PlacementReject::OutsideZone;
        return false;
    }

    float const collisionHeight = probe->GetCollisionHeight();
    bool const inWater = map->IsInWater(phaseMask, x, y, z, collisionHeight);
    if (inWater != (_originInWater == 1))
    {
        reason = PlacementReject::Water;
        return false;
    }

    // Static and dynamic geometry between the spawn point and the candidate:
    // rejects spots inside or behind walls, rocks and buildings.
    float const eyeHeight = collisionHeight * 0.5f;
    if (!map->isInLineOfSight(_origin.GetPositionX(), _origin.GetPositionY(), _origin.GetPositionZ() + eyeHeight,
        x, y, z + eyeHeight, phaseMask, LINEOFSIGHT_ALL_CHECKS, VMAP::ModelIgnoreFlags::Nothing))
    {
        reason = PlacementReject::LineOfSight;
        return false;
    }

    // One navmesh raycast, only for a candidate that already passed every cheap
    // check. Keeps clones on walkable polygons connected to the spawn point.
    if (config.ValidatePathing())
    {
        float pathX = x;
        float pathY = y;
        float pathZ = z;
        if (!map->CheckCollisionAndGetValidCoords(probe, _origin.GetPositionX(), _origin.GetPositionY(),
            _origin.GetPositionZ(), pathX, pathY, pathZ, false))
        {
            reason = PlacementReject::Path;
            return false;
        }

        // The raycast may stop short at the navmesh edge; keep the clamped point
        // only if it still respects the spacing rules.
        float const moved = std::hypot(pathX - _origin.GetPositionX(), pathY - _origin.GetPositionY());
        if (moved < minDistance * 0.5f || !IsSeparated(pathX, pathY))
        {
            reason = PlacementReject::Path;
            return false;
        }

        x = pathX;
        y = pathY;
        z = pathZ;
    }

    result.Relocate(x, y, z, Position::NormalizeOrientation(_origin.GetOrientation() + (angle - _baseAngle) * 0.1f));
    return true;
}

bool DensityPlacement::IsSeparated(float x, float y) const
{
    float const minSeparation = DensityConfig::Instance().GetCloneMinSeparation();
    if (minSeparation <= 0.0f)
        return true;

    float const minSeparationSq = minSeparation * minSeparation;
    auto const farEnough = [&](Position const& other)
    {
        float const dx = other.GetPositionX() - x;
        float const dy = other.GetPositionY() - y;
        return dx * dx + dy * dy >= minSeparationSq;
    };

    if (!farEnough(_origin))
        return false;

    for (Position const& accepted : _accepted)
        if (!farEnough(accepted))
            return false;

    return true;
}
