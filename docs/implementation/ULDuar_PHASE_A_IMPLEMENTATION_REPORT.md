# ULDuar Phase A implementation report

Date: 2026-09-16. Project: `C:\WoWProjecto\ulduar-wow`.

## 1. Executive summary

PHASE_A_STATUS: IMPLEMENTED, subject to source inspection only. This is not runtime acceptance.

Phase A adds separate instance identity, four versioned semantic profiles, instance-local Impact composition,
deterministic resolution, reviewed carrier contracts, a per-player in-memory projection registry and a conservative
cast-dispatch seam. Existing execution, propagation, targeting and native validation remain authoritative.

Healing+Ranged has one source-reviewed carrier: the existing Holy Light first rank, native spell 635.
The other three profiles are represented but remain UNSUPPORTED_CARRIER. The four-profile vertical slice cannot ship.
No existing character is converted into Forge. There is no acquisition endpoint or caller that installs live bindings.

NOT COMPILED.
NOT TESTED AT RUNTIME.
NO SQL EXECUTED.
NO CLIENT PATCH APPLIED.

## 2. Files inspected and initial worktree

Required architecture documents reviewed under `docs/architecture/`:

- `ULDuar_ABILITY_FORGE_ARCHITECTURE.md`, `ULDuar_PROGRESSION_ARCHITECTURE.md`.
- `ULDuar_GAMEPLAY_ROADMAP_V2.md`, `ULDuar_VERTICAL_SLICE_V1.md`, `ULDuar_ARCHITECTURE_AMENDMENTS.md`.
- `ULDuar_SPELL_TAXONOMY.md`, `ULDuar_ABILITY_METADATA.md`, `ULDuar_GENERIC_STATS.md`.
- `ULDuar_GEM_COMPATIBILITY.md`, `ULDuar_RESOLUTION_PIPELINE.md`, `ULDuar_GAP_ANALYSIS.md`.
- `CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md`, `CLASSLESS_WILDCARD_PORTABILITY.md` as reference only.

Module source inspected: `AbilityTypes.h/.cpp`, `AbilityDefinitions.h/.cpp`, `AbilityManager.h/.cpp`,
`AbilityRuntime.h`, `AbilitySpellScript.cpp`, `AbilityPropagationResolver.h/.cpp`, `AbilityTargetResolver.h/.cpp`,
`SecondarySpellExecutor.h/.cpp`, `AbilityPlayerScript.cpp`, and registration/command/protocol boundaries.
Core inspection included `Spell.h/.cpp`, `SpellEffects.cpp`, `Unit.h/.cpp`, `SpellInfo`, `SpellMgr`, DBC structures,
native target/cost/cast checks and the existing Ulduar per-cast setters.

Build/test registration was READ, not executed: module and root `CMakeLists.txt`, `modules/CMakeLists.txt`,
`src/cmake/macros/ConfigureModules.cmake`, `src/test/CMakeLists.txt`, `IntegrationTestFixture.h`,
`SpellInfoTestHelper.h` and associated existing mocks. Repository agent/C++/review guidance was read.

Initial root status already contained these five modified core files:

```text
src/server/game/Entities/Unit/Unit.cpp
src/server/game/Entities/Unit/Unit.h
src/server/game/Spells/Spell.cpp
src/server/game/Spells/Spell.h
src/server/game/Spells/SpellEffects.cpp
```

It also contained untracked `client/`, `docs/`, and these pending SQL files:

```text
data/sql/updates/pending_db_characters/ulduar_abilities_004_characters_modifiers.sql
data/sql/updates/pending_db_world/ulduar_abilities_003_world_starters.sql
```

The nested module already had deleted skeleton files: `conf/my_custom.conf.dist`,
`data/sql/db-world/skeleton_module_acore_string.sql`, `src/MP_loader.cpp`, `src/MyPlayer.cpp`.
Its existing implementation was untracked: all 18 source files listed above, `CMakeLists.txt`,
`DRAFT_BUILD.md`, `MODIFIERS_BALANCE.md`, `PROPAGATION.md`, `README.md`, `STARTER_ABILITIES.md`,
`UI_CONSOLIDATION.md`, `conf/mod_ulduar_abilities.conf.dist`, and the three existing module SQL files:
`db-characters/ulduar_abilities_001_characters.sql`, `db-characters/ulduar_abilities_002_characters_propagation.sql`,
`db-world/ulduar_abilities_001_world.sql` under `data/sql/`.

A pre-edit SHA-256 inventory covered 139 existing files across module, client, docs, pending SQL and modified core.
Original contents of all 18 module source files were captured for comparison; Git alone cannot diff untracked content.
No existing deletions were restored, no unrelated modifications were overwritten and no commit was created.
Final comparison found exactly four changed existing files (Manager.h/.cpp, Runtime.h and SpellScript.cpp),
135 byte-identical files and no missing baseline files. Nine new files complete the 13-file change listed below.

## 3. Files changed

Paths below are relative to `modules/mod-ulduar-abilities/` unless stated otherwise.

| File | Change |
| --- | --- |
| `src/AbilityInstance.h` | New typed identities, profiles, base composition and resolution API |
| `src/AbilityInstance.cpp` | Four profiles, deterministic resolver and revision-aware modifier replacement |
| `src/AbilityCarrierContract.h` | New feasibility, ownership policy, diagnostics and binding types |
| `src/AbilityCarrierContract.cpp` | Native review, pure validation, runtime adapter and profile blockers |
| `src/AbilityCarrierRegistry.h` | New per-player projection service boundary |
| `src/AbilityCarrierRegistry.cpp` | Collision checks, generations, immutable snapshots and lookup |
| `src/AbilityManager.h` | Server-only registration/removal/lookup API and per-player registry storage |
| `src/AbilityManager.cpp` | Lifecycle cleanup, native eligibility and legacy collision protection |
| `src/AbilityRuntime.h` | Optional Forge binding and immutable resolved definition on existing cast |
| `src/AbilitySpellScript.cpp` | Root dispatch lookup, snapshot attachment and rejected-binding CheckCast |
| `tests/AbilityForgePhaseATest.cpp` | 24 authored tests; none compiled or executed |
| `mod-ulduar-abilities.cmake` | Source registration with existing AC unit_tests when statically linked |
| `docs/implementation/ULDuar_PHASE_A_IMPLEMENTATION_REPORT.md` (project root) | This report |

No core, SQL, client, configuration, existing architecture document or external reference file was changed.

## 4. New types/services

`AbilityInstanceId` is an explicitly constructed uint64 identity, distinct from `NativeSpellId`,
`AbilityDefinitionId`, `AbilitySlotId`, `CarrierGeneration`, native rank, custom rank and EP.
`AbilityProfileId` plus version identifies a semantic profile, not a native catalog entry.
The existing untyped legacy `AbilityId`/`BaseSpellId` aliases were not broadly refactored.

`AbilityInstance` contains owner GUID, stable identity, profile/version, revision, authoritative base composition
and at most one prototype modifier reference. Native magnitude, timing, speed and cost inheritance are explicit
parameter policies, not fabricated numeric zeroes. Melee composition requests contact reach; ranged requests native
acquisition range. All four initial profiles request Mana. No non-Mana resource adapter was added.

`ResolveAbilityInstance` validates exact supported composition and versions, then produces derived values separately.
`ReplaceAbilityModifiers` requires the current revision, increments it without changing identity and recomputes from
base; invalid edits and overflow leave the original object intact. Resolver v1 canonical debug input contains profile,
profile version, revision, native parameter policy, resource and Impact presence. Base fields are constrained by the
profile version. No cryptographic hash or persistence protocol was introduced. Changes to resolver/default rules
require version review; this representation is not a promise of cross-version replay without archived rules.

`CarrierContract` uses existing typed classification plus resource/range policies, school, native timing/range evidence,
attack policy, adapters and explicit support/client-constraint states. Unknown is rejected.
`AbilityCarrierRegistry` stores immutable semantic snapshots and value runtime adapters; it does not own entitlements.
Manager access is serialized with its existing mutex. No raw Player/Unit pointer is retained by the new registry.

## 5. Integration points reused

- Existing `AbilityClassification`, effect flags, target relation, activation, delivery and temporal enums.
- Existing `ResolvePropagationStats`, `AbilityPropagationResolver`, `AbilityTargetResolver` and secondary executor.
- Existing `AbilityCast -> AbilityPayloadEvent -> AbilityHitContext` ownership and logical-caster GUID semantics.
- Existing exact secondary context handoff, native healing/damage handling and per-cast core adapters.
- Existing login/load, logout/unload and delete manager lifecycle; Forge projections are cleared in memory.
- Existing native active-spell/class eligibility and native CheckCast; no school/resource/target bypass.

The legacy runtime's `Id` and `SpellId` remain adapter lookup identities. The cast's pre-existing `InstanceId` is
the map instance identifier; Forge identity is explicitly `ForgeBinding.InstanceId`/`ForgeAbility.InstanceId`.
Logical caster stays the player. Existing visual source handling does not transfer ownership to a visual proxy.

## 6. Four-profile carrier matrix

| Profile | Required semantics | Phase A carrier result |
| --- | --- | --- |
| Damage+Melee | Enemy, Instant, Direct, Physical, Mana, contact | UNSUPPORTED_CARRIER |
| Damage+Ranged | Enemy, CastTime, Projectile, Holy, Mana, native range | UNSUPPORTED_CARRIER |
| Healing+Melee | Friendly, Instant, Direct, Holy, Mana, contact | UNSUPPORTED_CARRIER |
| Healing+Ranged | Friendly, CastTime, Direct, Holy, Mana, native range | SUPPORTED_SOURCE_CONTRACT: Holy Light rank 1 |

All use unit targeting, point geometry and an instantaneous payload (activation time is a separate axis).
`GetPhaseAProfileBlockers` gives structured blockers; an empty Healing+Ranged list is not authorization to bind.
Registration still requires source review, semantic compatibility, ownership policy and live native eligibility.

## 7. Chosen candidate and evidence boundary

Existing catalog definition 9, `holylight`, uses native root 635. This existing ID was inspected, not invented.
The first-rank contract has friendly explicit unit target (`TARGET_UNIT_TARGET_ALLY`), one native heal effect,
no additional payload effects, Holy school, direct delivery/speed zero, 2500 ms base cast time, 0..40 yard native
range, Mana with 29% base-Mana cost, no equipment-class requirement and no required/excluded forms.
The cost is native and nonzero; no Forge cost display substitutes for actual power consumption.
Native caster bonuses, haste, cooldowns, GCD, target restrictions and healing calculations remain native.
Visual 2936 is preserved; there is no fabricated projectile visual or shared SpellInfo mutation.

Review checks the existing named definition and actual SpellInfo at registration and each new Forge root lookup.
It accepts only the inspected first rank, with root equality and the reviewed native fields unchanged.
Other ranks do not inherit support through the root chain. Phase A does not grant/downrank a spell or alter spellbooks.
The existing Paladin class gate and requirement that this exact native rank be active remain in place.

Read-only native data came from both `C:\WoWProjecto\a\Data\dbc` and
`C:\WoWProjecto\ulduar-build\bin\RelWithDebInfo\Data\dbc`; the inspected files match between copies:

```text
Spell.dbc          d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3
SpellRange.dbc     82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f
SpellCastTimes.dbc 919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec
```

DBC rows were interpreted against the repository's WotLK structures. These extracted data and native source establish
the source contract, not proof of the running client's effective MPQ/DBC contents. No world database was queried;
runtime overrides, client acceptance and healing/Impact presentation still require later authorized verification.
`ClientConstraints == Supported` means this reviewed native data/source case, not a client session acceptance result.

## 8. Unsupported carrier reasons

Damage+Melee: Raptor Strike 2973 has Physical/Mana/short-range characteristics, but queues the next melee swing
and uses a weapon payload. It cannot honestly implement the requested independent Instant ability. Other inspected
melee candidates involve Energy/combo points, Rage or Runes. No dedicated independent Mana contact-damage carrier
was proven. Existing weapon adapters are preserved, not reclassified as a new Forge activation contract.

Damage+Ranged: Smite 585 is Holy with cast time but has native speed zero/direct delivery. Existing projectile
candidates Lightning Bolt 403, Shadow Bolt 686 and Wrath 5176 are not Holy. No primary projectile conversion or
element conversion was added. Client missile behavior cannot be inferred from a tooltip or an addon label.

Healing+Melee: inspected Holy Light 635 and Lesser Heal 2050 use cast time and 40-yard friendly targeting.
No reviewed instant Holy heal with a native contact-range root contract was found. Secondary target radius checks
are not a substitute for primary client/server contact-range validation. Death Coil's mixed/undead-friendly,
Shadow and Runic Power restrictions do not solve this profile.

Lesser Heal is a plausible ranged-heal research candidate, not an additional allowlisted carrier in this phase.
Unknown ranks, forms, client constraints, mixed/periodic payloads and missing adapters remain unsupported.

## 9. Carrier collision policy

Binding contains owner, active slot, exact native carrier, generation, instance ID and instance revision.
There is one active slot per owner, but APIs retain explicit slot identity for later extension.
Lookup by native SpellID yields NONE, UNIQUE, AMBIGUOUS or INVALID; no first-match selection is permitted.

Register rejects duplicate carriers, a different instance in an occupied slot, an additional active slot, wrong owner,
unsupported contracts, stale generations, older revisions and same-revision composition changes. Removal advances
the generation. Tombstones and revision/debug-input history survive removal within the player session.
Generation overflow is rejected. These counters are session-local, not persistent receipt/replay protection.

The trusted server caller must explicitly assert `NativeCarrierOwnership::ForgeProjectionOnly`.
Unknown or independently owned native/legacy sources are rejected even if the player knows the spell.
This enum is an explicit collision policy, not proof supplied by a client and not a new ownership ledger.
No command, addon operation or existing character-loading path asserts it automatically.
Future Progression must establish ownership before using this seam.

Manager registration additionally refuses existing legacy custom rank, EP, spent modifiers or propagation.
New cast lookup repeats this protection: customization acquired after binding invalidates dispatch instead of being
silently ignored. Existing legacy write APIs are not rewritten. The projection must be explicitly removed to recover
native/legacy use after a collision. NONE continues the original behavior.

## 10. Instance/revision snapshot path

Normal native root cast -> manager lookup of exact native rank -> unique registry snapshot -> actual carrier review
-> existing immutable AbilityCast with optional ForgeBinding and shared const ForgeAbility -> existing event/hit path.

An invalid/ambiguous Forge mapping keeps the SpellScript attached and fails its OnCheckCast hook. It does not return
Load=false and silently execute as native. Disabling the module also rejects an existing bound normal root; an unbound
cast keeps the previous disabled-module behavior. Defensive hit hooks avoid dereferencing a rejected empty context.

Secondary context handoff precedes normal-root Forge lookup. Existing controller/payload behavior is unchanged.
Captured runtime, instance revision and binding generation travel with the cast/event; later modifier replacement
or unbinding cannot rewrite an in-flight snapshot. Secondary impact performs no live composition lookup.
This protects semantic composition, not a frozen copy of every native combat-world value such as caster health.

## 11. Impact prototype integration

One version-1 Impact reference belongs to one AbilityInstance. Baseline has no propagation; applying/removing it
recomputes the instance and requires a new revision while preserving identity. Another instance of the same profile
remains unchanged. Multiple sockets and all other prototype kinds/versions are rejected.

The resolver calls existing ResolvePropagationStats with a temporary rank-zero prototype input and default rules;
it does not read or save character EP. Current v1 output is at most one secondary, 10-yard search radius and a 0.10
secondary payload multiplier. Native primary magnitude is retained. These are prototype coefficients, not launch
balance or a claim of conserved total output budget. Live GM legacy config is not part of this semantic input.

Existing propagation reserves the secondary before execution, excludes the primary/visited target and permits Impact
only from the root event. A propagation cast cannot generate another Impact. There is no chain, split, nova or area
engine added. Existing legality selects hostile damage targets or friendly healing targets and revalidates native
target, map, phase, visibility, LOS and payload restrictions. No secondary is also a valid outcome.
Existing secondary execution avoids repeating root resource costs and preserves logical caster/native payload paths.

## 12. Legacy behavior preservation

Without a binding, the same BuildRuntimeContext path still derives legacy custom ranks, EP, element, timing,
propagation and magnitude. No learned spell is automatically a Forge spell. Native spell/rank and instance ownership
remain separate. Existing player persistence, SQL, addon messages, command behavior, secondary execution,
target selection, visual handling and the five pre-existing modified core files were preserved.

Only in-memory projection cleanup was added to player load/unload/delete lifecycle. No character rows were loaded
through a new persistence path, migrated, removed or rewritten by this task. Advanced legacy capabilities still exist;
Forge Phase A simply does not expose them.

## 13. Tests added but NOT RUN

`tests/AbilityForgePhaseATest.cpp` contains 24 tests in the existing GoogleTest infrastructure:

1. Strong identity non-convertibility and uint64 capacity.
2. Four representable profiles and their activation/relation/resource semantics.
3. Two distinct instances from the same profile with deterministic equivalent semantic debug input.
4. Modifier revision increment, stable identity and stale edit rejection.
5. Instance-local Impact and recomputation on removal.
6. Incompatible target relation rejection.
7. Incompatible activation rejection.
8. Resource substitution rejection.
9. Empty registry returns NONE.
10. One valid binding returns UNIQUE with exact identity/revision/generation.
11. Duplicate carrier binding rejection without replacing the original.
12. Stale generation and remove/re-add protection.
13. Unbound native spell remains outside Forge lookup.
14. Cast/event retains original revision and runtime after registry replacement.
15. Impact secondary cannot recursively trigger Impact through the actual propagation entry point.
16. Unknown/unsupported carriers and unknown client constraints cannot bind.
17. Independent native ownership cannot be hijacked.
18. Same-revision mutation rejected, including after unbinding.
19. Unsupported composition, multiple modifiers and revision overflow rejection.
20. Additional slot and cross-owner rejection.
21. Missing adapters, range and delivery rejection.
22. Actual target resolver rejects primary as its own secondary.
23. Actual target resolver rejects hostile healing secondary.
24. Actual target resolver rejects friendly damage secondary.

The final three reuse AC IntegrationTestFixture and negative legality checks, stopping before LOS/map search.
They do not demonstrate successful live target acquisition or actual native healing. Synthetic carrier IDs in unit
fixtures are test-only data, not proposed production spells. No parallel gameplay harness was created.

The optional module `.cmake` hook registers sources with the existing `unit_tests` target only when BUILD_TESTING
and static module linkage are selected. The production source scan stays under `src/`; tests are outside it.
Registration, compilation, linking and fixture behavior have not been validated by CMake or execution.

Read-only validation: module C++ codestyle linter passed after correcting new-file formatting. This is static lint,
not a test run. SQL lint is inapplicable because no SQL was changed. Static byte/hash comparisons and whitespace
inspection supplement source review; none substitute for compilation or runtime acceptance.

## 14. Remaining blockers

- Three profiles have no proven carrier. Healing+Ranged is source-compatible only, restricted to first rank/class gate.
- Effective client data, server database overrides, native costs/target acceptance and Impact visuals are untested.
- No acquisition/ownership authority supplies Forge-only provenance; the seam is not player-accessible.
- No persistence, reconnect reconciliation, global instance allocator or cross-session generation authority exists.
- Successful hostile/friendly secondary acquisition, native immunity/proc behavior and delayed-hit behavior require
  an authorized build/test/runtime phase. Authored tests are not evidence that these paths have passed.
- There is no general Potency/Coverage budget compiler; the bounded prototype uses current propagation semantics.

### ARCHITECTURE_DEVIATION

Expected contract: the vertical-slice document refers to a current CoverageResolver distribution policy with total
budget constraints. Observed source constraint: the module implements ResolvePropagationStats over legacy ranks;
it adds secondary magnitude and does not contain that general semantic budget compiler.
Proposed amendment: explicitly describe Phase A Impact as a versioned one-secondary prototype using current rules,
and require a separately reviewed distribution/budget policy before accepting vertical-slice balance. Do not change
legacy formulas or claim conservation. Existing architecture documents were not edited.

The unsupported profiles are an explicitly allowed Phase A outcome, not silently narrowed slice acceptance.
Native inherited base parameters, trusted server provenance and deferred persistence/UI are deliberate Phase A limits.

## 15. Exact Phase B prerequisites

Do not begin Phase B automatically. Before expanding the carrier implementation:

1. Obtain explicit authorization for the next phase and separately for any build/test/server/client work it requires.
2. Review this source-only change; configure/build and run authored tests only when authorized, including static
   module test registration and real manager/SpellScript integration checks.
3. Establish exact effective client DBC/MPQ and server SpellInfo/override evidence for each chosen rank, and exercise
   native target relation, range/contact, activation, delivery, resource, school and equipment checks.
4. Resolve the independent Mana melee-damage, Holy projectile-damage and instant contact-healing carrier blockers
   with narrow reviewed contracts. Do not reinterpret next-swing, direct delivery or ranged healing as compatibility.
5. Define the server ownership evidence and collision policy that an authorized caller must satisfy before binding;
   do not auto-bind existing learned spells. Native requests do not carry instance revision/generation.
6. Verify root and Impact results for all four profiles, exact-rank behavior, no-binding regression, invalid-binding
   rejection, logout cleanup, generation changes and in-flight immutable revision retention.
7. Resolve the documented Coverage/budget discrepancy before claiming vertical-slice acceptance or final balance.

Persistence remains Phase C; UI and later gameplay systems remain outside this change. No Phase B/C/D implementation
was started. No external repository was imported, modified or executed.

## 16. Execution statement

NO COMPILATION WAS PERFORMED.
NO TESTS WERE EXECUTED.
NO SQL WAS EXECUTED.
NO CLIENT PATCH WAS APPLIED.

No CMake configuration, Visual Studio build, server launch, database migration, client/MPQ/DBC modification,
character-data mutation or Git commit was performed.
