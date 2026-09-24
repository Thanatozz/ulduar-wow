# Ulduar architecture audit and gap analysis

Audit date: 2026-09-14. Documentation-only deliverable; no compile, CMake configuration, SQL execution, runtime
implementation or deployment. Findings describe inspected source, not verified live-server behavior.

## Executive assessment

Ulduar already has a substantive ability customization implementation: a registered multi-class catalog,
native rank-chain lookup, per-character custom ranks/EP, element overrides, five propagation modes, selected
damage/heal/periodic/weapon execution adapters, per-cast snapshots, target revalidation, visual proxies and a
custom addon with authoritative build submission. Preserve and generalize this work.

The missing foundation is effect-level metadata and a shared selector/modifier system. The current flat
classification cannot correctly distinguish every payload in mixed spells. There is no universal talent ownership,
rule library, DORMANT/ACTIVE evaluation, gem definition/rarity/variant catalog or classless acquisition module.
Mobile casting is explicitly disabled. Enum entries for beams, fields, summons and control are not proof of
implemented generic transformation support.

Implement immutable spell/effect graphs, capability/adapter manifests and deterministic resolvers first. Add
classless ownership and transaction-safe grants next, then generalized numeric talents and their library UI.
Stateful procs, resource mechanics, summons and broad transformations follow incrementally with runtime validation.

Astoria offers useful source catalog/rank structures and UI acquisition flows. Its inspected Lua handlers lack
server-side budget/rank/prerequisite validation, its client catalog omits Death Knight, and its talent path learns
original native spells rather than generalized rules. A selective conceptual/data port is reasonable. A wholesale
port or replacing the core would not meet this design. Eluna/AIO are not required for Ulduar's existing C++/addon
architecture. See the [pinned source audit](ASTORIA_CLASSLESS_AUDIT.md).

## Evidence scope and repository identity

Target: `C:/WoWProjecto/ulduar-wow`. Git HEAD `d7ce67dc1800f092bac98aad680ece1c201b89a0`;
origin `Thanatozz/ulduar-wow`, upstream `azerothcore/azerothcore-wotlk`. AGENTS.md, module hooks and sources also
identify AzerothCore. The request's TrinityCore wording is treated as lineage, not an instruction to move trees.
The separate `C:/WoWProjecto/TrinityCore` directory is not the target of this design.

The Abilities module has its own Git root at commit `5f51c5e012b153b1edae00af2b0e11a9d45ba62d`, with existing
untracked implementation files and template deletions. Root already has changes in Spell.cpp/.h,
SpellEffects.cpp and Unit.cpp/.h, plus untracked client/docs/pending SQL. The audit includes those working files;
neither commit alone reconstructs the inspected implementation. Existing changes were not reset or overwritten.

Existing architecture docs, module README/PROPAGATION/DRAFT_BUILD/MODIFIERS_BALANCE/STARTER_ABILITIES and addon
protocol sources were cross-referenced with implementation. Source takes precedence where they disagree.
No live DB was queried; SQL files prove intended bindings/schema, not applied migrations or server readiness.

## Document map

| Document | Decision scope |
| --- | --- |
| [Spell taxonomy](ULDuar_SPELL_TAXONOMY.md) | Full dimension dictionary and spell/effect boundaries |
| [Ability metadata](ULDuar_ABILITY_METADATA.md) | Identity, provenance, conversions and world schema |
| [Generic stats](ULDuar_GENERIC_STATS.md) | Deterministic abstract stat profiles and geometry resolution |
| [Gem compatibility](ULDuar_GEM_COMPATIBILITY.md) | Capability requirements, sidegrades, ranks and groups |
| [Generalized talents](ULDuar_GENERALIZED_TALENTS.md) | Intent, selectors, triggers, classification and blockers |
| [Universal library](ULDuar_UNIVERSAL_TALENT_LIBRARY.md) | Ownership states, UI data, talent schemas |
| [Conversion pipeline](ULDuar_TALENT_CONVERSION_PIPELINE.md) | Converter design and all 2,358 source-rank records |
| [Astoria audit](ASTORIA_CLASSLESS_AUDIT.md) | Fifteen audit answers and KEEP/PORT/REWRITE/IGNORE |
| [Classless layer](ULDuar_CLASSLESS_ARCHITECTURE.md) | Module boundaries, grants, budgets and persistence |
| [Resolution pipeline](ULDuar_RESOLUTION_PIPELINE.md) | Compilation/execution order and loop/scaling prevention |

## Source key

Paths are relative to this repository; links resolve to actual inspected files. Symbols remain the primary anchors
because the working tree may evolve after the audit.

| Key | Existing implementation/file |
| --- | --- |
| T | [AbilityTypes.h](../../modules/mod-ulduar-abilities/src/AbilityTypes.h) |
| TC | [AbilityTypes.cpp](../../modules/mod-ulduar-abilities/src/AbilityTypes.cpp) |
| D | [AbilityDefinitions.cpp](../../modules/mod-ulduar-abilities/src/AbilityDefinitions.cpp) |
| M | [AbilityManager.cpp](../../modules/mod-ulduar-abilities/src/AbilityManager.cpp) |
| R | [AbilityRuntime.h](../../modules/mod-ulduar-abilities/src/AbilityRuntime.h) |
| S | [AbilitySpellScript.cpp](../../modules/mod-ulduar-abilities/src/AbilitySpellScript.cpp) |
| P | [AbilityPropagationResolver.cpp](../../modules/mod-ulduar-abilities/src/AbilityPropagationResolver.cpp) |
| Q | [AbilityTargetResolver.cpp](../../modules/mod-ulduar-abilities/src/AbilityTargetResolver.cpp) |
| E | [SecondarySpellExecutor.cpp](../../modules/mod-ulduar-abilities/src/SecondarySpellExecutor.cpp) |
| A | [AbilityAddonProtocol.cpp](../../modules/mod-ulduar-abilities/src/AbilityAddonProtocol.cpp) |
| L | [AbilityPlayerScript.cpp](../../modules/mod-ulduar-abilities/src/AbilityPlayerScript.cpp) |
| SH | [Core Spell.h](../../src/server/game/Spells/Spell.h) |
| SC | [Core Spell.cpp](../../src/server/game/Spells/Spell.cpp) |
| SE | [Core SpellEffects.cpp](../../src/server/game/Spells/SpellEffects.cpp) |
| U | [Core Unit.cpp](../../src/server/game/Entities/Unit/Unit.cpp) |
| SI | [Core SpellInfo.h](../../src/server/game/Spells/SpellInfo.h) |
| DB | [DBCStructure.h](../../src/server/shared/DataStores/DBCStructure.h) |
| PL | [Core Player.cpp](../../src/server/game/Entities/Player/Player.cpp) |
| UI | [Addon entry manifest](../../client/Interface/AddOns/UlduarAbilities/UlduarAbilities.toc) |
| W3 | [Starter bindings](../../data/sql/updates/pending_db_world/ulduar_abilities_003_world_starters.sql) |
| C4 | [Modifier columns](../../data/sql/updates/pending_db_characters/ulduar_abilities_004_characters_modifiers.sql) |

## Exact current concept audit

| Concept | Actual representation and behavior | Limit / distinction |
| --- | --- | --- |
| Cast | T `AbilityCastType`: Instant, CastTime, Channel, MeleeAttack, RangedAttack | One value per definition |
| Targeting | T enum: Unit, Ground, Self, AreaAroundCaster, AreaAroundTarget, Direction | Not all have adapters |
| Delivery | T enum: Direct, Projectile, Beam, Area, PersistentArea | Enum != width/field execution |
| Temporal | T: Instant, Periodic, ChannelTicks, PersistentAreaTicks, Delayed | Mixed payloads share one label |
| Effect | T bit flags: Damage, Healing, Aura, Dispel, Summon, Displacement, Resource | No indexed metadata |
| Range | TC `GetReferenceRange`: Melee dynamic pair; Low10/Mid20/Long30 yards | Labels, not native min/max |
| Element | T Original + seven schools; M rejects Physical; T maps six magic schools | Partial identity |
| Original propagation | T `None`, P returns without secondary dispatch | Preserve native behavior |
| Impact | P OnImpact, instant secondary dispatch from impact neighborhood | Melee supports Impact only |
| Split | P OnRootLaunch, siblings at launch; E original player visual source | Does not wait for primary hit |
| Shatter | T projectile requirement; P hit-origin dispatch; E proxy/missile logic | Requires legal payload |
| Chain | P one successor on successful AfterHit, scheduled event | Bounded count; optional revisit gap |
| Nova | T radius profile; P/Q acquire all eligible units in radius | No gameplay count limit |
| Additional targets | T SecondaryTargetCount = CoverageRank+1 except Nova | Historical additional_targets migrated |
| Propagation range | T base10 + rank*2, Chain configurable step default1 | Caps40yd, melee15yd; not cast range |
| Nova radius | T base5 + CoverageRank*1, capped25yd by default | Safety radius checked separately |
| Secondary damage | T/M PotencyRank stored as secondary_damage_rank; default10%+5%/rank | Applies heal/periodic too |
| Primary damage | T DamageRank; M default +5%/rank; S OnHit/periodic aura scaling | Also scales propagated damage |
| Cooldown | M TimeReductionMs; S AfterLaunch modifies own spell timer | Category siblings/GCD stay native |
| Cast time | M reduction default0.1s/rank, cap50%, min0.5s; S/SH per-cast setter | CastTime definitions only |
| Rebound | T ChainRevisitGap; Q unseen first then eligible revisits | Count budget still bounds execution |
| Mobile casting | T state/node; M Normalize forces false, SpendPoint rejects enable | Unavailable, costs nothing |
| Ability ranks | M custom rank1..1000000; earned EP=rank-1 | Separate from native spell rank |
| Native ranks | M FindAbilityBySpell/GetKnownSpell use SpellMgr chains | Preserves highest active known rank |
| EP/state | M validated row upsert/readback; cache; L load/logout/delete hooks | No universal point ledger |
| UI | UI addon1.5, Protocol2, list/tree/details/tooltips, draft/committed separation | Per-ability fixed nodes |
| Protocol | A self-whisper, 255-byte limit, 8 requests/2s, token/sequence/revision | No classless API yet |
| Availability | M IsAbilityAvailableForPlayer checks ClassId and active rank | Current acquisition not universal |
| Runtime snapshots | R immutable cast + shared event + hit; E exact prepare handoff | No universal talent rule trace |
| Target legality | Q map/instance/phase/alive/LOS, native target, relation and PvP checks | Unit payload scope |
| Visual/audio | E DBC missile data + proxy; SH/SC presentation overrides | DBC-kit sound/FX not fully separable |

In current defaults, non-Nova secondary count safety cap is 1024, search safety radius 1024 yards; gameplay range
caps normally dominate. Nova does not consult secondary count to limit its all-in-area selection. Do not report
the configured count guard as a universal root work limit. A proposed root-wide ceiling is documented separately.

Physical remains a valid native school, but is not an available conversion destination. School override flows
through selected direct damage bonus, hit/crit/immunity/proc calculations in SH/SC/SE/U; native family, aura
identity and scripts consulting SpellInfo directly still retain source semantics. Full school conversion is PARTIAL.

S provides heal scaling, weapon-impact eligibility, periodic damage/heal aura amount adjustment and exact
controller payload handling. Ordinary periodic auras are not a generalized OnTick propagation bus: the current
DoT path can propagate aura applications and scale their ticks. Some event kinds in R are declarations only.
Judgement's separate secondary payload and Death Coil's mixed relation explicitly demonstrate existing special
adapters that must survive generalized metadata.

## Registered source catalog

D contains 30 definitions: 28 marked RuntimeEnabled and two metadata-only examples. W3 binds the 28 enabled
roots plus Arcane Missiles payload 7268 and Judgement secondary 20185. M CheckDatabase verifies negative root
script bindings and required aura bindings before enabling the module. This does not prove SQL has been applied.

| IDs | Enabled definitions |
| --- | --- |
| 1,3,5 | Frostbolt; Arcane Missiles (controller/payload); Fireball |
| 9 | Holy Light |
| 13,14 | Arcane Shot; Raptor Strike |
| 16,19,20 | Sinister Strike; Lesser Heal; Shadow Word: Pain |
| 21,22,23 | Blood Strike; Icy Touch; Plague Strike |
| 24,26,27 | Lightning Bolt; Healing Wave; Corruption |
| 29,30,31,32 | Shadow Bolt; Wrath; Maul; Healing Touch |
| 33,34,35,36 | Death Coil; Moonfire; Claw; Serpent Sting |
| 37,38,39,40,41 | Judgement of Light; Smite; Eviscerate; Earth Shock; Immolate |

IDs 2 Flash Heal and 4 Blizzard are metadata-only (`RuntimeEnabled=false`). These must not be described as
working transformation adapters. The enabled catalog has no Warrior ability. Eviscerate explicitly disables
propagation/potency; Death Coil and Judgement disable potency. Several abilities preserve original school.
The broader architecture must cover all ten classes' source material and abilities beyond this starter set.

## Documentation/source discrepancies

- Module README says the implemented payload adapter only applies potency to direct damage, and reports no
  melee/healing hook.
  Current D/S/W3 include additional abilities, healing/weapon handling and periodic scaling. Treat README's
  historical restrictions as historical, while retaining its explicit lack of runtime verification.
- README describes a possible need for visual proxies; E now creates presentation-only WORLD_TRIGGER proxies.
  Their actual client rendering remains unverified. Do not delete them based on an older design statement.
- Historical no-revisit chain prose is superseded by T/Q ChainReboundRank, with a gap and finite budget.
- DRAFT_BUILD records Protocol1 and points readers to MODIFIERS_BALANCE. A and client Protocol.lua implement
  Protocol2 including damage/cooldown/cast-time/rebound ranks. Use code and the newer document for current shape.
- Existing architecture directory is a 2026-09-08 snapshot. It provides useful boundaries, but proposed folders
  and architecture terms are not implemented components. No existing document was rewritten in this phase.

## Feature matrix

Status meanings: DONE = observed source implementation for the named existing scope; PARTIAL = some required
behavior exists; MISSING = required Ulduar abstraction absent; NEEDS_REFACTOR = existing behavior needs separation
or generalized policy. DONE does not claim compilation, applied SQL or in-game validation.
Risk: H/M/L. Priority: P0 foundation, P1 initial library, P2 broad mechanics, P3 later extensions.
File keys above resolve the existing-implementation column without repeating long paths.

| Feature | Current status | Existing implementation/file | Required abstraction | Missing work | Risk | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| Native rank lookup | DONE | M/SpellMgr | Stable bindings | Preserve importer parity | M | P0 |
| Custom rank/EP | DONE | T/M/L/C4 | Legacy profile | Migration mapping | H | P0 |
| Cast/target/time taxonomy | NEEDS_REFACTOR | T/D | Spell/effect graph | Scoped fields | H | P0 |
| Native effect input | PARTIAL | DB/SI | Effect importer | Payload graph/provenance | H | P0 |
| Geometry | PARTIAL | T/P/Q | Geometry profiles | Cone/line/ring/arc adapters | H | P2 |
| Capability compatibility | PARTIAL | T/D/M | Typed requirements | AST + adapter manifest | H | P0 |
| Root/event/hit split | DONE | R/P/E | Effect-aware context | Extend provenance | M | P0 |
| Impact/Split/Shatter | DONE | P/Q/E | Strategy adapters | General payload bundles | H | P1 |
| Chain/rebound | DONE | T/P/Q | Strategy policy | Generic bounce variants | H | P1 |
| Nova | PARTIAL | T/P/Q | Radius/work policy | Root-wide safety bound | H | P0 |
| Spread/repeat | MISSING | R event foundation | Bounded strategy | Aura/timer adapters | H | P2 |
| Generic Coverage | PARTIAL | T ResolvePropagationStats | CoverageResolver | Geometry profiles/trade-offs | M | P0 |
| Generic Potency | PARTIAL | T/M/S | Typed potency domain | Absorb/control/resource scope | H | P1 |
| Min/max range | PARTIAL | TC/DB/SI | Numeric range profile | Friendly/hostile/reach adapters | M | P1 |
| Duration/Frequency | MISSING | Native auras/S amount | Lifetime/schedule resolver | Refresh/tick policies | H | P2 |
| Cast speed | PARTIAL | M/S/SH | SpeedResolver | Multi-axis ownership | M | P1 |
| Projectile speed | PARTIAL | E native Speed read | Velocity override | Generic editable axis | H | P2 |
| Cost/resources | PARTIAL | Native core/S/E | Typed ledger/resolver | Runes/combo/health/refunds | H | P1 |
| Cooldown | PARTIAL | M/S | Timer ownership | Categories/GCD/charge adapters | H | P1 |
| School conversion | PARTIAL | T/S/SH/SC/SE/U | Effect school policy | Identity/proc/aura coverage | H | P1 |
| Other conversions | MISSING | No general graph | Typed conversion DAG | Legality/conservation adapters | H | P2 |
| Healing/weapon payloads | PARTIAL | D/S/E | Typed payload bundles | Broad source coverage | H | P1 |
| DoT/HoT execution | PARTIAL | S/native auras | Lifecycle adapter | General events/frequency | H | P2 |
| Ground persistent fields | MISSING | D Blizzard disabled | Field owner/geometry | Runtime adapter | H | P2 |
| Crit/reliability | PARTIAL | Native core/R flags | Outcome policies | Generic modifier exposure | H | P1 |
| Scaling | PARTIAL | Native core/S | Domain ledger | Avoid duplicate SP/AP/proc scaling | H | P0 |
| Aura/control/dispel | PARTIAL | Native core/T/S | Mechanic contracts | Stacks/DR/lockout selectors | H | P2 |
| Movement/mobile | MISSING | M explicitly disables | Movement adapter | Cast/channel/turn checks | H | P2 |
| Threat | PARTIAL | E logical caster/native core | Threat policy | Generic override/forced aggro | H | P2 |
| Pets/summons/traps | MISSING | Native core; T flags | Ownership/inheritance | Ulduar adapters | H | P2 |
| Visual/audio taxonomy | PARTIAL | T/E/SH/SC | Presentation profile | Asset mapping/client validation | M | P2 |
| Gem entities/rarity/ranks | MISSING | T fixed node ranks | Gem catalog | Definitions/variants/groups | M | P1 |
| Signed sidegrade stats | MISSING | T unsigned rank nodes | Signed resolvers | Effective drawback validation | H | P1 |
| Ability draft commit | DONE | A/M/UI | Reusable draft model | Multi-entity transactions | M | P1 |
| Classless ownership | MISSING | M ClassId gate/PL | Classless service | Grants + native reconciliation | H | P0 |
| Universal talent definitions | MISSING | Native DB/PL only | Ulduar catalog | Shared rule compiler | H | P0 |
| Source-rank inventory | DONE | Local DBC; conversion doc | Provenance ledger | Semantic review of 2358 rows | M | P1 |
| Semantic conversion | MISSING | Sample script audit | Reviewable converter | Masks/scripts/proc analysis | H | P1 |
| Talent ACTIVE/DORMANT | MISSING | No ownership model | Compatibility index | Invalidation and recompute | M | P1 |
| Universal talent UI | MISSING | Ability UI | Catalog/owned view model | Search/filter/state protocol | M | P1 |
| Universal event triggers | PARTIAL | S/R/P local hooks | Combat event bus | Defense/resource/lifecycle | H | P2 |
| Proc recursion control | PARTIAL | S root guards/P budget | Global event ancestry | Root budget/dedup/ICD | H | P0 |
| Ownership persistence | PARTIAL | M single-row upsert | Transaction ledger | Multi-table/outbox/receipts | H | P0 |
| Schema versioning | MISSING | C4 migration only | Versioned catalog | Published FK/review manifests | H | P0 |
| Large catalog transport | MISSING | A 255-byte protocol | Bounded paging/chunking | Catalog cache/integrity | M | P1 |
| Keystone system | MISSING | Concept only | Structural character tier | Conflicts/validation/snapshot | H | P2 |

## Recommended implementation phases

1. **P0: establish the metadata foundation.** Import immutable native facts and effect/payload graphs; retain
   registered IDs and native rank bindings. Implement capability manifests, selector type checking and traceable
   legacy profiles. Exit: every enabled legacy build resolves identically, and mixed-effect false matches fail.
2. **P0/P1: classless ownership and grants.** Introduce independent budgets, generic prerequisites, grant sources,
   revisions, idempotent transactions and native reconciliation. Remove class availability gates via an adapter.
   Exit: cross-class learn/unlearn/rank/refund survives reconnect and crash recovery without altering EP.
3. **P1: shared modifiers and basic talent library.** Implement scoped numeric rules and DORMANT/ACTIVE indexing,
   then reviewed damage/healing/defense/sustain talents from multiple classes. Extend existing UI with search,
   filters, authoritative previews and compatibility reasons. Exit: zero-match ownership activates automatically.
4. **P1: data-driven gems and sidegrades.** Wrap existing nodes in gem definitions, add signed resolver profiles,
   rank/rarity/variant catalogs and atomic drawback validation. Exit: chain/area trade-offs and legacy node
   migration preserve ownership, EP and documented behavior.
5. **P2: event and mechanic breadth.** Build bounded event/proc ledgers, aura lifetime, shields, control, resources,
   pets, weapons/forms and movement adapters. Extend periodic/ground geometry and school/conversion coverage.
   Exit: each enabled adapter has explicit source cases, loop/scale/target checks and actual runtime evidence.
6. **P2/P3: complete semantic conversion and polish.** Process/review every source-rank ledger record, alias only
   proven duplicates and retain unsupported/legacy reports. Add structural keystones and later geometry profiles,
   balance sidegrades and refine UI layout from stable data. Exit: no unresolved source rank is silently discarded.

Runtime tests and compilation belong to later explicitly authorized implementation phases. The initial absence
of runtime validation is not a reason to remove the existing implementation or redesign its working behavior.

## Assumptions and decisions still requiring evidence

- The local DBC corpus is the audit input; full retail completeness/custom modification history remains unverified.
- The exhaustive rank ledger is a blocker inventory, not 2,358 approved generalized definitions. All semantic
  reviews remain pending; core script examples cannot establish all native proc/condition behavior.
- Published talent classification, rarity values, point curves, PvP caps and keystone balance require later review.
- Existing school, timing and visual changes were inspected statically only. Client render/sound and native
  restriction interactions need later in-game validation across more than the starter catalog.
- Effective finite work budgets can change legacy high-target Nova behavior; introduce that change with an
  explicit migration/balance note instead of silently treating a new bound as already implemented.

## Documentation validation

Validation for this phase checks the eleven requested artifacts, relative source/document links, DBC identity and
one-to-one source-rank ledger coverage, and preservation of existing source/client/document file hashes.
No C++/SQL tests or runtime claims are inferred from those documentation checks.

Completed results: all 11 documents present; 59 inline links resolve; reference links have defined targets;
all files pass UTF-8/LF, trailing-whitespace, 120-column and code-fence checks. The 2,358 ledger keys, native spell
IDs, names and effect/aura slots match the local DBC records exactly. All 78 preexisting files in the preservation
manifest retain their original SHA-256. Root Git status retains the same preexisting code changes.

## Working-source fingerprint

These SHA-256 values pin the principal inspected working files, including changes not represented by Git HEAD.
Keys refer to the source map above. Validation compared the initial fingerprints with the files after documentation.

| Source | SHA-256 |
| --- | --- |
| T | `a4630fe50a1228c8f018dd2e17edc1526fa6c29d731c2589e569fd7bd4afb868` |
| D | `ae73e221b5d7484a99626a9277253c7aa53749807abf6a0ee7633d6ecdcf094f` |
| M | `a68a726f3537c63df8ca188418c52be551eb3edd87ad244de96a796a6293ea77` |
| S | `a20d1440646ce0e7909a52b71ef014a2a916ae4a78db0e5edd41f88fed594f5c` |
| P | `508883c501a12336fdbdab112254603e338e5e47c549e93b17b5140df1377050` |
| Q | `dbf57a46ed9de562ef204d1ee3ff0c49ce6f4db33a97117ac6c87543fba7b223` |
| E | `1afc454b02de6f359a85155a884521bce8d57d6936af8585ee0f9dc41d2bbeba` |
| A | `71ba59585d0caa9b87a4847f44677d444b979f699e53c7aa578d9645c06b403d` |
| SH | `ee511de6c8b9f8a0cc2509d04aee5d61f2d7d17335bae75ce9c72eb0bb2b0a9a` |
| SC | `8c25be9212263ca2ac335d099e502c428823bc823cff6e243b4fdd03ca2c032f` |
| SE | `a924795551aae276e8224adf87f6a546b53449c7177046677b1f8ed2c98da8a5` |
| U | `f15146db35cf89c01fe31d9d0c74b101f0baf655cf5786ef597d9b3d835e303f` |
