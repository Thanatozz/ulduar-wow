# ALE integration strategy (and ALE vs Eluna)

Date: 2026-09-27. Evidence: `azerothcore/mod-ale` at `bd74eae623ca`, `ElunaLuaEngine/ElunaAzerothCore` at
`ca08cb85a10a`, `ElunaLuaEngine/Eluna` at `58d765213888`. Nothing was installed or run.

## 1. What ALE is (source)

| Aspect | Finding |
| --- | --- |
| Integration | an AzerothCore **module** (`modules/mod-ale`); the core already ships the `ALEScript` hook class (`ScriptDefines/ALEScript.h` in this tree), so no core patch is needed |
| Hooks | wrappers over AzerothCore script classes (`ALE_SC.cpp`: AllCreature, AllGameObject, AllItem, AllMap, AuctionHouse, BG, GameEvent, Group, Guild, Loot, Misc, Pet, Player, Server, Vehicle, WorldObject, World, Ticket); Lua-side `Register*Event` families incl. packet send/receive and spell prepare/cast/cancel |
| API | ~30 method tables (Player, Unit, Creature, GameObject, Spell, SpellInfo, Aura, Map, Group, Guild, Item, Loot, Quest, WorldPacket, DB queries, ...) |
| Lua | 5.2 default; LuaJIT, 5.3, 5.4 selectable at CMake time |
| Lifecycle | scripts under `lua_scripts`; `.reload ale` reloads the whole state; optional file watcher (`ALE.AutoReload`, polling thread); bytecode cache |
| Threading | **one global Lua state** (`ALE::GALE`); every hook takes `LOCK_ALE` (46 sites). Safe with multi-threaded map updates, but every scripted hook serializes on one mutex |
| Database | synchronous `WorldDBQuery`/`CharDBQuery` (blocks the calling thread), async `Execute` |
| Extras | `HttpRequest` (worker thread) — outbound HTTP from gameplay scripts; must stay disabled/unused on production |
| Error isolation | Lua errors are caught and logged (`ALE.TraceBack`); a crash in C++ bindings still takes the server down |
| C++ interop | no stable way for a C++ module to publish its own typed service to Lua besides adding methods to ALE itself |

## 2. ALE vs Eluna

| Criterion | ALE (mod-ale) | ElunaAzerothCore |
| --- | --- | --- |
| Form | module | **full AzerothCore fork** with `#ifdef ELUNA` in 41 game files; Eluna itself as a submodule |
| Fit for Ulduar | drops into the existing Ulduar core | would require rebasing all Ulduar core changes onto another core: unacceptable |
| Script compatibility | self-declared incompatible with standard Eluna scripts | standard Eluna API |
| Maintenance | AzerothCore organization, `azerothcore/mod-eluna` redirects to it | tracks AzerothCore merges (latest "Merge AzerothCore 3.3.5") |
| Ecosystem | growing AC-specific (e.g. Paragon Anniversary targets ALE) | larger historical Eluna script base |

**Decision: ALE only**, and only if the prototype (§5) shows value. Never both. No third engine.

## 3. What belongs where

| Content | Where | Why |
| --- | --- | --- |
| Custom quests, world events, minigames, vendors, simple NPC behaviors, GM/admin tools, seasonal content, prototypes | ALE (candidate) | fast iteration, low coupling, content not on the combat hot path |
| mod-ulduar-abilities (resolver, modifiers, periodic carriers, echo, propagation, dispel) | C++ | hot combat path, ownership/persistence rules, core hooks, tests |
| Density/city systems, persistence-heavy services (collections, transmog) | C++ modules | performance, schema ownership, security |
| Client patch | native C++ | not server scripting |
| Configuration/orchestration of C++ services (e.g. a world-event calling a C++ "grant appearance") | ALE → narrow C++ service | Lua orchestrates, C++ owns the rule |

## 4. "Can existing C++ modules be moved to ALE without rebuilding the server?"

- **Rewriting gameplay logic in Lua:** possible for content-style modules (vendors, events), and then new
  content of that kind needs no rebuild. Not for mod-ulduar-abilities: its engine, hooks
  (`SpellScript`/`AuraScript`, `AllSpellScript`, core changes) and tests are C++.
- **Exposing a stable C++ service to Lua:** needs ALE method bindings, i.e. C++ code compiled into the
  server: **a rebuild**, once per API change.
- **Lua only as orchestration/config:** works without rebuilds after the binding exists.
- **Replacing a C++ module entirely:** only for modules whose logic is small and not on hot paths.

Installing ALE itself is a one-time server rebuild. After that, Lua-only content iterates with
`.reload ale` without a rebuild or restart.

## 5. Prototype (isolated, not installed)

`docs/research/ale-poc/ulduar_ale_poc.lua`: one GM command and one gossip NPC, reading nothing from
mod-ulduar-abilities. It is **not** installed anywhere. To evaluate on Windows (requires authorization to
build/start the server):

1. Clone `azerothcore/mod-ale` into `modules/`, re-run CMake, build (one rebuild).
2. Copy the file into `lua_scripts/`, start the server, run `.ulduarpoc` and talk to the NPC.
3. Edit the text, run `.reload ale`, measure the time until the new text shows (expected: seconds, no rebuild).
4. Introduce a Lua error on purpose: confirm it is logged and the server keeps running.
5. With `MapUpdate.Threads > 1`, run a load test with the NPC gossip to observe `LOCK_ALE` contention.

Record results in this document. Until then ALE is **DEFER / PROTOTYPE**.
