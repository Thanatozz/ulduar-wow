# Ulduar density system

Module: `Thanatozz/mod-density-test` (own repository, cloned into `modules/mod-density-test`).
Work branch: `claude/practical-pascal-u2fl8o` on that repository. Base analysed: commit `347faa7` ("v0").
Core files modified: **none**.

> On the `WIP` branch the module source is committed as regular files under `modules/mod-density-test`
> (it replaced a submodule pointer to the skeleton commit `e94bc3a`). It matches module commit `98781e9`.

## 1. Architecture discovered (v0)

| Question | v0 answer |
| --- | --- |
| Where copies are generated | `DensityManager::OnCreatureAddWorld` / `OnGameObjectAddWorld` (AllCreatureScript / AllGameObjectScript) |
| When | Synchronously, inside the hook, whenever the core adds a phase-1 DB spawn of map 1 zone 215 to the world, i.e. inside every grid load |
| Density mode assignment | GM command `.density on/off/status`; session-only set of player GUIDs; player phase mask set to 2 inside the zone (`OnPlayerUpdateZone`, `OnPlayerMapChanged`) |
| Isolation | Phasing: normal players phase 1, density players and all copies phase 2. Every spawn and object gets at least one phase-2 copy ("representation") so the layer is not empty |
| Original/copy relation | `WorldObject::CustomData` on the copy (source GUID, index); manager maps source GUID -> copy GUIDs |
| Positions | 12 random attempts per copy: `MovePositionToFirstCollision` + `Map::CanReachPositionAndGetValidCoords` + zone check |
| Reachability | Two full collision checks per attempt, each with a detour raycast (`PathGenerator`), vmap and dynamic-tree queries, water and ground height |
| Respawn | Copies are runtime creatures (`spawnId = 0`, compatibility respawn in place) |
| Cleanup | Only when the *source* object is removed from the world (`OnCreatureRemoveWorld`) |
| Persistence | Runtime only; nothing is saved |
| Forced grid loads | Not directly, but see root cause 3 |
| Mulgore | `MapId`/`ZoneId` config values plus a hard-coded "only in Mulgore" message |
| Multiplied creatures | `IsHostileToPlayers()` with no npcflags; neutral creatures excluded (`IsNeutralToAll()` returned early) |

## 2. Root cause of the startup / loading cost

1. **Eager and unconditional.** Copies were created for every Mulgore spawn as soon as its grid loaded,
   whether or not any density player existed. A normal player walking through Mulgore generated the
   full density population.
2. **This AzerothCore version never unloads object grids at runtime.** `Map::UnloadGrid` is only called
   from `Map::UnloadAll` (map destruction). Once a grid was loaded its copies lived forever; the only
   cleanup path (source removal) almost never fired.
3. **Grids load without players.** `Map::CreatureRelocation` calls `EnsureGridLoaded` whenever *any*
   creature crosses a grid border, and creatures on waypoint paths are always updated
   (`Creature::IsUpdateNeeded`), players or not. v0 copied the waypoint path onto every copy (`LoadPath`),
   multiplying patrols that walk into neighbouring grids, loading them, and triggering more copying. This
   is why generation continued after "worldserver ready" with no one online. (Flight path end-grid preloads,
   `SummonCreature` and SmartAI `LoadGrid` also load grids without a player.)
4. **Expensive synchronous placement.** Up to `12 attempts x 2 collision checks` per copy, each check
   running a navmesh raycast plus vmap/dynamic-tree queries, all inside the grid load. The second check
   (`failOnCollision = true`) retraces the ray the first one already cut at a wall, so positions near
   geometry fail repeatedly, hence the flood of `No reachable position found`.
5. **Logging.** `Debug = 1` by default printed one line per spawn and one warning per failed copy.
6. **Bug found:** groups were keyed by the source *object* GUID. With dynamic respawn (the core default
   for spawn groups without the compatibility flag) the original is removed from the world when its corpse
   despawns, which deleted the whole phase-2 group, including copies in combat with density players.

## 3. Files

Module repository (`mod-density-test`):

| File | Change |
| --- | --- |
| `src/DensityConfig.{h,cpp}` | map/zone allow/deny lists, queue, grid and placement options |
| `src/DensityEligibility.{h,cpp}` | new: single eligibility decision |
| `src/DensityPlacement.{h,cpp}` | new: deterministic clone placement |
| `src/DensityManager.{h,cpp}` | rewritten: source index, grid activation, work queue, groups, stats |
| `src/DensityCreatureScript.cpp` | + `UnitScript` for group aggro |
| `src/DensityWorldScript.cpp` | + `OnStartup` (world ready), `AllMapScript` (map update, destroy) |
| `src/DensityCommands.cpp` | `.density stats`, `.density statsreset`, richer status |
| `conf/mod_density_test.conf.dist`, `README.md` | new options and procedure |

This repository: this document.

## 4. Eligibility rules (`DensityEligibility::Classify`)

Pure function over `CreatureTemplate` + `CreatureData`, so the answer is identical on every activation and
never depends on transient state (a creature switching faction mid-fight). In order:

| Rule | Result |
| --- | --- |
| type critter / non-combat pet | mirror only |
| any npcflag (template or spawn): vendor, trainer, flight master, quest giver, spirit healer, gossip... | mirror only |
| flags_extra guard, civilian or trigger | mirror only |
| rank world boss, rare, rare elite; dungeon boss | mirror only |
| unit_flags non-attackable, not selectable, immune to players | mirror only |
| faction with a reputation list (town factions) or friendly to players | mirror only |
| faction hostile to players | **multiply** |
| faction neutral to all, gives XP and has loot/skinning/pickpocket/money | **multiply** |
| neutral without XP or loot (ambient) | mirror only |

Before classification, `IsPersistentSpawn` requires a DB spawn (`dbData`, matching spawn id) that is not a
pet, summon, guardian, totem, vehicle or on a transport. Density representations are never sources
(`CustomData` marker).

Rationale for the faction test: it is the same test as `Unit::IsHostileToPlayers()` /
`Unit::IsNeutralToAll()`, read from the template's faction. Template 7 (neutral beasts) and 14 (monsters)
qualify, 35 (friendly to all) and reputation factions do not; 190 (ambient) is neutral but ambient
creatures carry no XP/loot.

## 5. Density groups

- A group is **all phase-2 representations of one spawn id** (mirror + clones), stored as
  `MapState::creatureGroups[spawnId]`. The phase-1 original is not a member: density players cannot
  reach it, and a normal player attacking it must not pull invisible phase-2 creatures.
- Hook: `UnitScript::OnUnitEnterCombat`, fired by `Creature::AtEngage` right after formation assist.
- Rule (same as `CreatureGroup::MemberEngagingTarget`): every other member that is alive, in world, not in
  combat, has no victim and for which `IsValidAttackTarget(target)` holds calls `EngageWithTarget(target)`.
- Attacker semantics: `target` is whatever the core passed to `AtEngage`: the player, or the pet /
  guardian / charmed unit that attacked. The owner enters combat through the core's own propagation,
  exactly as for formations.
- No recursion: members engaging re-enter the hook; a `thread_local` guard stops propagation (map
  updates run on several threads). Members already engaged are skipped, so each pull is O(group size).
- Other spawns are never looked up, so neighbouring groups are not pulled.
- Cleanup: a member removed from the world is erased from its group (`OnCreatureRemoveWorld`); the group
  is erased with its grid's cleanup. Group lookups also check the activation generation stored on the
  representation, so a stale representation can never join a newer group.

## 6. Lazy grid activation

```
core loads grid ──> AddToWorld hooks ──> source index (spawnId -> grid of spawn point)   [cheap, no objects]

every ScanInterval, in the map's own update:
  density players (phase 2, enabled zone) ──> grids within ActivationRadius ──> refcount per grid
    Inactive + needed + IsGridLoaded ──> Active: queue one job per indexed spawn/object
    Lingering + needed               ──> Active (population reused)
    Active + not needed              ──> Lingering (timer starts)
    Lingering > UnloadDelay          ──> Inactive: queue removal jobs
```

- **Never loads grids.** A needed grid that is not loaded is skipped until the core loads it. The core loads
  grids within 250 yards of players, and the default radius is 150.
- **Reference count** is recomputed per scan (1 s) from player positions instead of being incremented and
  decremented on movement. It is cheap (players on the map), is not tied to movement packets, and cannot
  leak on teleport, death, logout or crash.
- **Shared population:** grid state is per map, not per player. A second density player only raises the count.
- **Unload delay:** 60 s default. Crossing a grid border back and forth or a short detour reuses the
  population. It is well under the 5 minute grid timeout AzerothCore historically used.
- **Generations:** every activation/deactivation bumps the grid generation. Queued jobs from an older
  generation are dropped, so a quick leave/return never duplicates a group.
- New sources that appear in an already active grid (pool rotation, events) are queued immediately.
- Dynamic respawn: groups are keyed by spawn id. A source removed while dead only clears its GUID. A
  source removed while alive (pool/event despawn) removes its group.

## 7. Work queue

- One `std::deque<Job>` per map; job types: spawn object, spawn creature group, despawn creature group,
  despawn object. Objects are queued before creatures so the phase-2 dynamic collision exists when clones
  are placed.
- Processed in `AllMapScript::OnMapUpdate`, i.e. inside that map's update thread; no worker threads touch
  `Map`/`Creature` objects.
- **Time budget:** jobs run until `WorkBudgetMs` (default 2 ms, `steady_clock`) is used. A creature job
  creates its mirror first, then one clone at a time, checking the budget between clones; an unfinished
  job goes back to the front of the queue with its progress (`CreatureJobProgress`) intact.
- **Locking:** a single `std::mutex` protects module state. It is never held while creating or removing
  objects: `Map::AddObjectToRemoveList` calls `RemoveFromWorld` synchronously, which re-enters the hooks.
- Per-grid `pendingJobs` counts the activation's jobs; when it reaches zero one summary line is logged.

## 8. Clone position generation

`DensityPlacement`, per spawn, lazily, one clone at a time:

1. **Deterministic candidates:** golden-angle spiral between `CloneMinDistance` and `CloneMaxDistance`,
   rotated by a hash of the spawn id. Candidates are evenly spread and never repeat.
2. **Bounded:** `wantedClones x PositionAttemptsPerClone` candidates (default 4 x 3 = 12 per spawn,
   against v0's up to 48 attempts x 2 checks).
3. **Cheapest first:** grid loaded (never creates grids), minimum separation from the spawn point and
   accepted clones, ground height with a slope limit, same zone, same water state; then static + dynamic
   line of sight; then (optional) **one** navmesh raycast, whose clamped end point is kept if it still
   respects spacing.
4. **Partial success is fine:** a spawn that fits only 2 of 4 clones keeps 2; the rest count as
   `unplaced`.
5. **Cache:** a finished search is stored per spawn id for the life of the process (terrain is static).
   Reactivating a grid, or a spawn reappearing, costs no geometry query.
6. **Patrols:** the mirror keeps the waypoint path; extra clones of a patrol roam around their own spot, so
   they never add grid-crossing walkers.

## 9. Logging

- Normal operation: one line per grid activation. Format (values are placeholders, not measurements):
  `[UlduarDensity] Grid activated: map=1 grid=33:29 base=112 eligible=61 mirrors=112 clones=231 unplaced=13 gameobjects=40 cacheHits=0 rejectedCandidates=58 placement=6.4ms work=19.8ms wall=412ms players=1`,
  and one `World ready` line at startup.
- `.density stats` prints aggregated counters: activations, reuses, releases, inspected, eligible,
  rejected per reason, mirrors, clones, unplaced, rejected candidates per reason, placement time, work time,
  max slice, jobs before/after ready, max map diff while busy/idle, group aggro pulls. `StatsLogInterval`
  can print them periodically.
- `Debug = 1` (default 0) adds per-spawn decisions, placement shortfalls, grid reuse/release and player
  toggles.

## 10. Before / after measurements

No worldserver could be run in the development container (no MySQL, no world DB, no client-extracted
maps/vmaps/mmaps), so no live numbers are claimed here. The counters above exist to produce them.

Expected by construction:

| Metric | v0 | Now |
| --- | --- | --- |
| Density work before world ready | all copies of every Mulgore grid loaded at startup, synchronous | 0 jobs (`World ready` line prints the count) |
| Density work with no density player | full population of every loaded Mulgore grid | 0 jobs; only the source index |
| Placement calls per multiplied spawn (x5) | up to 4 x 12 x 2 = 96 collision checks, each with a navmesh raycast | at most 12 candidates and 12 raycasts (only for candidates passing the cheap checks); 0 when cached |
| Work per map update | unbounded (whole grid inside the grid load) | `WorkBudgetMs` (2 ms) + at most one clone |
| Console lines per grid | one per spawn + one per failed copy | one |
| Copies after leaving | forever (grids never unload) | removed after `UnloadDelay` |

How to measure on the real server:

1. Start v0, note startup time and count `[DensityTest]` lines. Then start the new build and read the
   `World ready` line and the absence of per-spawn lines.
2. `.density statsreset`, `.density on` in Mulgore, walk the zone, `.density stats`: activation wall time,
   work ms, max slice, inspected/eligible/clones, rejected candidates and placement ms.
3. Compare `maxDiff(busy)` with `maxDiff(idle)`: world update spikes caused by density generation.
4. Compare v0's `.density status` counts after walking the zone once without density enabled.

## 11. Global density preparation (not enabled)

Filters: `EnabledMaps`, `DisabledMaps`, `EnabledZones`, `DisabledZones`; also `Multiplier`,
`ActivationRadius`, `WorkBudgetMs`, `UnloadDelay`, `ScanInterval`, placement options and `Debug`.
A global configuration would be `EnabledMaps = "0,1,530,571"`, `EnabledZones = ""` with capital cities in
`DisabledZones`. Global density does not mean global preloading: the source index only covers grids the
core has loaded, and populations exist only around density players.

## 12. Known limitations

- Not compiled into a worldserver or run: the module sources were syntax-checked against this core's
  headers and pass the repository C++ linter. Everything in section 10 and the validation list below needs
  a live test.
- The isolation model is unchanged: the density layer needs a mirror of every spawn and object in active
  grids. A lighter model (density players see phases 1|2, only clones in phase 2) would skip mirrors but
  share originals and players between layers; not done without a decision.
- Reputation-faction mobs that are hostile by default (e.g. Timbermaw) are not multiplied: they fail the
  same faction test the core uses.
- Group aggro applies to hostile packs too: pulling one creature of a spawn pulls its whole group.
- Clones are runtime creatures: spawn-guid scripts, spawn `creature_addon` auras, formations and pools do
  not apply to them (unchanged from v0).
- The position cache grows with visited spawns (about 16 bytes per clone position) and is never evicted
  during a run.
- Player phase handling is unchanged: the module overwrites the player's phase mask in enabled zones.

## Validation checklist

| Check | How |
| --- | --- |
| No synchronous startup population, no startup spam | `World ready ... 0 density jobs executed before ready` |
| Normal player loads nothing | walk Mulgore without `.density on`; `.density status` 0 grids |
| Activation only around needed grids | `.density on`; `Grid activated` lines only for nearby grids |
| Incremental activation | walk; new lines appear per grid |
| No duplication on return | `reuses` increases, no new activation line |
| Shared by two players | second player: no new activation, creature count unchanged |
| Delayed cleanup | leave, wait `UnloadDelay`; representations go to 0 |
| Critters normal, hostile and neutral x`Multiplier` | inspect; `.density stats` rejected reasons |
| Group aggro, no neighbour pull, pets | attack a Plainstrider with and without a pet |
| Nothing saved to DB | `creature` / `gameobject` row counts unchanged after a session |
| No leaks | after cleanup `.density status` groups/creatures return to 0 |
| Stable update latency | `maxDiff(busy)` close to `maxDiff(idle)` |

## Recommended next step before enabling global density

Run the validation checklist on Mulgore with two accounts and record `.density stats`. Then run one
continent-scale soak test with the zone filter widened to a whole continent but `Multiplier = 1`
(mirrors only) to measure the mirror cost and memory without clone placement. Only then enable clones on a
second zone. Before going global, also decide on quest phasing inside density zones and reserve the
density phase bit project-wide.
