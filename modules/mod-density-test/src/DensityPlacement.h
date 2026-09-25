/*
 * This file is part of the mod-density-test project.
 */

#ifndef MOD_DENSITY_TEST_PLACEMENT_H
#define MOD_DENSITY_TEST_PLACEMENT_H

#include "Define.h"
#include "Position.h"

#include <array>
#include <vector>

class Creature;

enum class PlacementReject : uint8
{
    GridNotLoaded,   // candidate lies in a grid the core has not loaded: never force a load
    OutsideZone,     // candidate left the enabled zone
    NoGround,        // no terrain height, or height step too steep
    Water,           // water state differs from the spawn point
    Overlap,         // too close to the spawn or an accepted clone
    LineOfSight,     // blocked by static or dynamic geometry
    Path,            // navmesh raycast rejected the segment

    Max
};

struct PlacementStats
{
    uint32 candidates = 0;
    uint32 accepted = 0;
    std::array<uint32, size_t(PlacementReject::Max)> rejects{};
    uint64 timeUs = 0;

    void Add(PlacementStats const& other);
    [[nodiscard]] uint32 TotalRejects() const;
};

// Finds clone positions around one spawn point. Candidates follow a
// deterministic golden-angle spiral seeded by the spawn id, so the same spawn
// always tries the same offsets and results can be cached. Cheap checks run
// first (grid loaded, zone, height, water, overlap); line of sight and the
// optional navmesh raycast run only for candidates that survive them.
class DensityPlacement
{
public:
    DensityPlacement(Position const& origin, uint32 seed, uint32 wantedClones);

    // Searches for the next clone position. `probe` is a live creature standing on
    // the spawn point (the density mirror); it is only used for the duration of the
    // call, so the placement can be resumed on a later update with a fresh pointer.
    // Returns false once the candidate budget (wantedClones * PositionAttemptsPerClone)
    // is exhausted.
    bool Next(Creature const* probe, Position& result, PlacementStats& stats);

    [[nodiscard]] bool IsExhausted() const { return _nextCandidate >= _totalCandidates; }
    [[nodiscard]] std::vector<Position> const& GetAccepted() const { return _accepted; }

private:
    [[nodiscard]] bool TryCandidate(Creature const* probe, uint32 index, Position& result,
        PlacementReject& reason) const;
    [[nodiscard]] bool IsSeparated(float x, float y) const;

    Position _origin;
    float _baseAngle;
    uint32 _nextCandidate = 0;
    uint32 _totalCandidates;
    int8 _originInWater = -1; // lazily computed on the first Next() call
    std::vector<Position> _accepted;
};

#endif
