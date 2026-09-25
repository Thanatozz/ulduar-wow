# Ulduar Universal Ability Runtime

Status: 2026-09-25. Engine phases B-H implemented and unit-tested; runtime bridge partial (see status
matrix). Module: `Thanatozz/mod-ulduar-abilities`, branch `claude/practical-pascal-u2fl8o`.
Related: [components](ULDuar_ABILITY_COMPONENTS.md), [properties](ULDuar_ABILITY_PROPERTIES.md),
[modifier engine](ULDuar_MODIFIER_ENGINE.md), [zero semantics](ULDuar_ZERO_SEMANTICS.md),
[Ability Lab](ULDuar_ABILITY_LAB.md), [Essence contract](ULDuar_ESSENCE_MODIFIER_CONTRACT.md),
[migration](ULDuar_EXISTING_ABILITY_MIGRATION.md), [resolution pipeline](ULDuar_RESOLUTION_PIPELINE.md).

## 1. Current architecture audit (before this work)

| Area | Implementation | Notes |
| --- | --- | --- |
| Ability definitions | `AbilityDefinitions.cpp` registers 28 `AbilityDefinition`s (Frostbolt id 1 / spell 116, ...) into `AbilityManager` | Classification enums (cast, targeting, delivery, temporal, range, relation, effects), supported propagation modes, base element |
| Player state | `PlayerAbilityState`: rank, evolution points, element, propagation mode, Coverage/Potency/Damage/Cooldown/CastTime/ChainRebound ranks | Persisted in `character_ulduar_abilities`; synchronous upsert + read-back |
| Resolution | `ResolvePropagationStats` + `AbilityManager::BuildRuntimeContext` produce `AbilityRuntimeContext` per cast | Hardcoded balance: `MinCastTimeSeconds 0.5`, `MaxCastTimeReductionPct 50`, `MaxCooldownReductionPct 50`, cooldown floor 1 ms |
| Spell hooks | `spell_ulduar_ability_runtime` (Load/CheckCast/AfterCast/OnHit/AfterHit/effect hit) + `aura_ulduar_ability_runtime` (periodic amount) bound by negative first-rank `spell_script_names` rows | Per-Spell school override and cast-time multiplier via Ulduar core patches in `Spell.h` |
| Propagation | `AbilityPropagationResolver` (Impact/Split/Shatter/Nova/Chain), `AbilityTargetResolver` (legal enemy/friendly checks, grid search, stable sort), `SecondarySpellExecutor` (exact `Spell*` handoff, visual source, instant delivery) | Bounded: visited sets, reserved execution counts, queued chain hops |
| Forge Phase A | `AbilityInstance`, `ResolvedAbilityDefinition`, carrier registry/contract/catalog | 4 profiles, 1 Impact prototype socket, carrier leasing; no runtime grant |
| Protocol / UI | `AbilityAddonProtocol.cpp` (ULDAB1 whisper protocol v2), client addon `client/Interface/AddOns/UlduarAbilities` | Players edit their own node build; server authoritative |
| Commands | `.ua info/list/rank/element/delivery/coverage/potency/targets/mobile/reset/points` (GM) | |
| Tests | `tests/AbilityForgePhaseATest.cpp` (Forge Phase A, carriers, impact targets) | Registered to AC `unit_tests` when static |

## 2. Gap analysis against the master specification

| Requirement | Before | Now |
| --- | --- | --- |
| Base + modifier layers = resolved, base immutable | Legacy nodes computed directly into runtime context | `AbilityCore` + `AbilityModifier` layers -> `ResolvedAbility` (pure) |
| Typed universal property registry with metadata | None (fixed struct fields) | 162 properties, X-macro single source, typed (number/bool/enum) |
| Deterministic modifier engine, documented order | Per-node ad-hoc formulas | 9-stage order, precedence by source, order-independent |
| Zero semantics vs technical vs balance | 50% floors hardcoded in code/config/core | Centralized; zero is valid; balance limits configurable and visible |
| Components add/remove, effect lists | Fixed classification | Component set + effect list, structural modifiers |
| Proc / echo / periodic stacking with recursion bounds | Propagation bounds only | Pure planners with bounded depth/count (runtime scheduler not yet wired) |
| Conditions | None | 16 condition kinds, per-event evaluation of cached resolution |
| Requirements engine (ALL/ANY/NONE) | `IsPropagationCompatible` only | Generic requirement tree over resolved structure |
| Essence model (size vs quality vs unique) | None | `EssenceDefinition`; contract = modifier list |
| Developer Lab + inspector + presets | None | `.ua lab ...`, inspector with clamp display, 10 built-in presets |
| Per-player isolation, cache + invalidation | Per-player state map | Per-owner layer store, stamp/revision cache, invalidated on layer/rank/config |
| Configurable balance limits with absolute safety | Mixed hardcoded clamps | `UlduarAbilities.Limit.*` validated at startup |

## 3. Final architecture

```
                 ┌────────────── pure engine (src/engine, no AC headers) ─────────────┐
AbilityDefinition │ AbilityCore ──┐                                                   │
 + native SpellInfo│              ├─ AbilityResolver ── ResolvedAbility (cached) ─────┼─> EngineBridge ─> AbilityRuntimeContext ─> SpellScript/Propagation
 (EngineBridge)   │ Modifier layers┘   (registry, limits,          │                  │    (executes supported values)
                  │  DeveloperLab  │    validation, semantics)     └─ Inspector        │
                  │  Essence (next)│                                                   │
                  └───────────────────────────────────────────────────────────────────┘
```

- `src/engine/*` depends only on the C++ standard library. It never reads `SpellInfo`, `Unit` or the database.
- `AbilityEngineBridge` is the only translation point: `BuildCore` (definition + ranked `SpellInfo`,
  read once when a build changes) and `ApplyToRuntime` (resolved values -> per-cast context).
- The Lab is not special: it writes the `DeveloperLab` layer of `ModifierLayerStore`, the same store
  Essences will write (`Essence` layer). Precedence: `DeveloperLab` > `Essence` > `Aura` > `Equipment` >
  `Talent` > `GameMode` > `Core` for SET conflicts only; arithmetic is order independent.
- Shared `SpellInfo` is never mutated. Per-player values live in the resolved snapshot and are applied per
  `Spell` (school mask, cast-time multiplier) or per player (own cooldown timer).

## 4. TrinityCore/AzerothCore integration

| Value | Mechanism | Status |
| --- | --- | --- |
| Damage / healing scaling | `SpellScript::OnHit` `SetHitDamage` (existing) with `PrimaryDamageMultiplier` | RUNTIME |
| Cast time (incl. 0 = instant, > native = slower) | `Spell::SetCastTimeMultiplier` in `SpellScript::Load` | RUNTIME (core guard widened, see 6) |
| Cooldown (incl. 0 and adding one to a spell without) | `AfterCast`: `RemoveSpellCooldown` / `ModifySpellCooldown` / `AddSpellCooldown` + `SMSG_SPELL_COOLDOWN` | RUNTIME |
| School conversion | `Spell::SetSpellSchoolMask` (per Spell) | RUNTIME for definitions with `SupportsElementConversion` |
| Secondary targets (projectile targets/range/scaling, area around target) | Mapped onto existing propagation executor (Split / Shatter / Chain / Nova) | RUNTIME for compatible definitions |
| Min/max range | `Spell::SetRangeDelta` (core, section 6) shifts `CheckRange` after spell mods. The stock client still refuses targeted casts beyond its own DBC range, so a longer range only works up to that | RUNTIME (server check) |
| Resource cost | `Spell::SetPowerCostOverride` (core, section 6): native cost x resolved/core, or a flat cost for spells with a zero native cost. Percentage spells expose their percentage as the Core cost | RUNTIME |
| Resource type, gain, refund on failure | Client power bar and cost type are native | RESOLVED ONLY |
| Cast while moving | `Spell::SetCanCastWhileMoving` (core, section 6) skips the movement rejection in `prepare` and the cancel in `update`. Channels (aura interrupt flags) and falling casts are not covered; the stock client may still stop its own cast bar | RUNTIME (server, non-channeled) |
| Projectile speed / visual scale / hit radius | Native missile speed; custom speed needs delayed hit + visual packets | RESOLVED ONLY |
| Periodic conversion, spread | `AbilityPeriodicExecutor`: `Periodic.Conversion`% of the direct damage becomes server ticks on the caster's `m_Events`, dealt through `CalculateSpellDamageTaken` / `DealSpellDamage` (mitigation and absorbs apply). Interval is hasted at application and never below `MinPeriodicTickInterval`. Stacking uses `ApplyPeriodic`, spreading on tick uses `SpreadPeriodic`. Healing periodics and changes to native periodic timing are not executed | RUNTIME (damage, added Periodic only) |
| Echo | `AbilityEchoScheduler`: `PlanEchoes` at root impact, each echo a delayed `SecondarySpellExecutor` cast on the same target (revalidated, scaled, crit/proc flags). Echoes never plan echoes | RUNTIME (TargetRule SameTarget) |
| Procs | Chain guard implemented; trigger bus pending | GUARD ONLY |
| Conditions | `EngineBridge::BuildCombatContext` gathers only the facts the conditions reference (health, movement, stun, casting, distance, creature type, auras, element statuses, nearby units) and `ValueWithContext` scales each hit | RUNTIME for Primary.Damage / Primary.Healing |
| Threat, crit modifiers, avoidance flags | Unit hooks (`ModifyMeleeDamage`, threat hooks) | RESOLVED ONLY |

Everything marked RESOLVED ONLY is still computed, validated and shown in the inspector with a
`RESOLVED ONLY (not executed yet)` line, so nobody mistakes data for gameplay.

## 5. Status matrix (spec section 35)

| Feature | Data model | Resolution | Runtime | UI | Tested |
| --- | --- | --- | --- | --- | --- |
| Property registry + metadata | DONE | DONE | - | chat list | unit |
| Arithmetic ops / order / precedence | DONE | DONE | partial (above) | chat | unit |
| Zero semantics + validation | DONE | DONE | cast time/cooldown | inspector | unit |
| Balance/technical limits + config | DONE | DONE | via resolution | inspector | unit |
| Components add/remove | DONE | DONE | Area-around-target -> Nova | chat | unit |
| Effects (proc/aura) add/remove/modify | DONE | DONE | NO | chat (`addproc`, `effect`) | unit |
| Conditions | DONE | DONE (per-event API) | Primary.Damage/Healing per hit | inspector count | unit |
| Echo | DONE | DONE | same-target echoes | chat + Lab UI | unit (planner) |
| Periodic stacking/spread | DONE | DONE | added damage periodic (convert, stack, spread) | chat + Lab UI | unit (transitions) |
| Resource cost / range / moving cast | DONE | DONE | core overrides (section 6) | chat + Lab UI | syntax only |
| Requirements / Essence contract | DONE | DONE | n/a | NO | unit |
| Developer Lab backend + presets + inspector | DONE | DONE | via bridge | chat commands + Lab UI | unit (store); in-game untested |
| Developer Lab addon UI | - | - | - | `/ua lab` window over the core addon command channel | Lua 5.1 parse only |
| Per-player isolation + cache | DONE | DONE | DONE | - | unit |

None of the runtime rows were tested in game: no server was built or run for this change.

## 6. Core modification

`src/server/game/Spells/Spell.h|.cpp` (ulduar-wow, branch `claude/practical-pascal-u2fl8o`):
`Spell::SetCastTimeMultiplier` accepted only `[0.5, 1.0]`, a hidden 50% floor, and could only shorten casts.
It now accepts `[0, 10]`; `0` yields `m_casttime = 0` (instant, which also lifts the moving-cast rejection
exactly like any instant spell) and `> 1` lengthens. Legacy callers pass `[0.5, 1]` with their minimum and
get the identical result. There is no module-level alternative: the cast time is computed inside
`Spell::prepare` before any script hook can change it.

Second change, same files: per-cast overrides for the ability runtime, set from `SpellScript::Load` on root
player casts only, under the same guard (not triggered, before target selection):

- `SetPowerCostOverride(multiplier, flat)`: applied right after both `CalcPowerCost` call sites (non-item casts).
- `SetRangeDelta(min, max)`: added to the min/max range in `CheckRange`, after `SPELLMOD_RANGE`.
- `SetCanCastWhileMoving(bool)`: non-channeled only; skips the `SPELL_FAILED_MOVING` rejection in `prepare` and
  the movement cancel in `update`.

The default values leave behavior unchanged. There are no script hooks for these: the power cost is computed
inside `prepare` after `Load`, `CheckRange` has no hook, and the movement checks sit inline in `prepare`/`update`.

## 7. Performance decisions

- No string lookups in combat: properties are enum-indexed arrays; names are used by commands only.
- Resolution happens when a build changes; `BuildRuntimeContext` reads the cached `shared_ptr` (one map
  lookup under a mutex per cast for players with engine layers, none otherwise).
- Conditional modifiers are not baked; `ValueWithContext` re-evaluates one property from its stored
  pre-conditional value, not the whole ability.
- Echo/proc depth and counts are bounded by both the property and the absolute limit.
- The resolved snapshot is immutable and shared into the cast (`AbilityRuntimeContext::EngineAbility`), so a
  build change during projectile flight cannot alter that cast.

## 8. Server authority

The Lab UI/commands only *request* modifiers. `ModifierLayerStore::Add` validates each modifier against the
registry, the resolver validates the whole ability, and an invalid resolution never reaches combat (the
legacy/native context is kept). The client only displays server responses.

## 9. Test plan and results

`tests/AbilityEngineTest.cpp` (41 tests, standalone and AC `unit_tests`): registry consistency, ADD / SUBTRACT
/ MULTIPLY / PERCENT_ADD / SET, ENABLE/DISABLE, enums and invalid enums, delivery transformation, zero
transitions (cast time, cooldown, cost, min range, proc chance 0 and 100), negative times, active periodic with
zero tick (rejected) vs inactive, max targets 0, min > max range, balance clamp visibility, tick interval balance
minimum, configuration clamping, explicit clamps, component add/remove, effects add/remove, structural
conditions rejected, conditional execute bonus and element-status targets, multi-echo decay and bounds, proc
loop/depth/proc-from-proc, periodic stack behaviors and disease-style spread, requirements ALL/NONE with
reasons, Lab/Essence equivalence, two-player isolation, cache reuse/invalidation, inspector content.
Result: 41/41 passed (g++ 13, gtest 1.14). Module sources and patched `Spell.cpp` syntax-checked against the
core headers; no worldserver build or in-game test.

## 10. Remaining gaps / next steps

Done in order: conditions per hit, echo scheduler, periodic conversion, resource/range/moving-cast overrides,
and the Lab addon UI. Still open:

1. In-game validation of every RUNTIME row (build + live-stack e2e); nothing here was run on a server.
2. Healing periodics, native periodic retiming and Echo target rules other than SameTarget.
3. Projectile speed/visual scale/hit radius, displacement, threat/crit/avoidance, procs trigger bus.
4. Resource type/gain/refund, casting while falling, moving channels.
5. Persist Lab presets (character DB) if needed; Essences get their own persistence.
