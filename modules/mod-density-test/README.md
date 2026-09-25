# mod-density-test

Density layer for AzerothCore WotLK 3.3.5a (Ulduar WoW). Density players are moved to a separate
phase where combat creatures appear several times. Normal players keep the vanilla world. No map
instances, no database writes: every density object is a runtime object (`spawnId = 0`).

Design, measurements and limitations: `docs/implementation/ULDuar_DENSITY_SYSTEM.md` in the
Ulduar WoW repository.

## Scope

- Test area: map 1 (Kalimdor), zone 215 (Mulgore). Filters are map/zone lists, so enabling more
  of the world is a configuration change (see `conf/mod_density_test.conf.dist`).
- Normal players: phase 1, vanilla population.
- Density players: phase 2, one mirror of every spawn and object, combat creatures x`Multiplier`.
- Stats, AI, loot and spells of the creatures are unchanged.
- The toggle is per session.

## Architecture

| File | Responsibility |
| --- | --- |
| `DensityConfig` | Cached config, map/zone filters, validation |
| `DensityEligibility` | The single "does this spawn get a density pack" decision |
| `DensityPlacement` | Deterministic clone positions, cheap checks first |
| `DensityManager` | Player layer state, source index, grid activation, work queue, density groups, stats |
| `Density*Script` | Hook adapters only |

1. **Source index.** When the core adds a phase-normal DB spawn of an enabled zone to the world,
   its spawn id is recorded under the grid of its spawn point. Nothing is created.
2. **Grid activation.** Every `ScanInterval` the manager computes, for each map, which grids are
   within `ActivationRadius` of a density player. A needed grid that the core has already loaded is
   activated: one job per indexed spawn is queued. Density never loads a grid.
3. **Work queue.** Jobs run in the map's own update, until `WorkBudgetMs` is used, then continue on
   the next update. One spawn job creates the mirror, then clones one by one.
4. **Sharing.** A grid has one population no matter how many density players need it.
5. **Cleanup.** A grid nobody needs lingers for `UnloadDelay` seconds, then its representations
   are removed through the same queue. Coming back during the delay reuses the population.
6. **Density groups.** All representations of one spawn form a group. When one of them engages a
   target, the other idle members engage the same target (formation-style assist). Other spawns
   are not pulled.

## Commands (GM)

- `.density on` / `.density off` / `.density status`
- `.density stats` / `.density statsreset` — aggregated counters (also from the console)

## Manual tests

Run `.gm off` on test accounts first: an active GM sees every phase.

1. **Startup.** No per-spawn density lines; one `[UlduarDensity] World ready: ... 0 density jobs
   executed before ready` line.
2. **Normal player.** Walk Mulgore without `.density on`: `.density status` shows 0 active grids.
3. **Activation.** `.density on` in Mulgore. Within ~1 s one `Grid activated` line per grid around
   the player. Critters/NPCs appear once, hostile and neutral combat creatures x`Multiplier`.
4. **Movement.** Walk across Mulgore: new grids activate as they come within 150 yards.
5. **Reuse.** Leave and come back within `UnloadDelay`: no new `Grid activated` line
   (`.density stats` reuses increases).
6. **Sharing.** A second density player in the same grid adds no representations.
7. **Cleanup.** Leave the zone or `.density off`, wait `UnloadDelay` + a few seconds:
   `.density status` returns to 0 creatures.
8. **Group aggro.** Attack a neutral Plainstrider (also with a hunter pet): its pack engages you,
   the neighbouring pack does not.
9. **Isolation.** A normal player at the same spot sees none of the density objects or players.

## Known limitations

- Phase 2 is not globally reserved; spawns that already use the density bit are skipped with a warning.
- The module replaces the player's phase mask inside enabled zones; quest phasing there is not composed.
- Scripts keyed on a DB spawn guid, `creature_addon` spawn auras and formations do not apply to
  representations (they have `spawnId = 0`). Waypoint paths are kept on the mirror; extra clones of
  a patrol roam around their own spot instead.
