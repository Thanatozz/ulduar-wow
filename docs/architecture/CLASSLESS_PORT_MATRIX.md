# Classless port and gap matrix

Read-only assessment, 2026-09-14. CoA snapshot:
`feb155c82c754f7190ffebc9843cab581ccda7b7`.
Sources and limits are in [ASCENSION_CLASSLESS_BASE_AUDIT.md](ASCENSION_CLASSLESS_BASE_AUDIT.md).

## Complete extension of the previous gap analysis

The original [feature matrix](ULDuar_GAP_ANALYSIS.md#feature-matrix) has exactly 39 rows whose status is
MISSING, PARTIAL or NEEDS_REFACTOR. All 39 appear below, in original order.
DONE rows are preserved in the original document and are not downgraded by this comparison.

To keep the matrix readable, its columns are split into three tables joined one-to-one by G01-G39:
original identity/evidence, original required work, and the eight new evaluation columns.
Together they preserve every original field and add every requested comparison field.
Original file keys resolve through the source key in the previous gap audit.

### Original identity and evidence columns

| ID | Feature | Current status | Existing file | Risk | Priority |
| --- | --- | --- | --- | --- | --- |
| G01 | Cast/target/time taxonomy | NEEDS_REFACTOR | T/D | H | P0 |
| G02 | Native effect input | PARTIAL | DB/SI | H | P0 |
| G03 | Geometry | PARTIAL | T/P/Q | H | P2 |
| G04 | Capability compatibility | PARTIAL | T/D/M | H | P0 |
| G05 | Nova | PARTIAL | T/P/Q | H | P0 |
| G06 | Spread/repeat | MISSING | R event foundation | H | P2 |
| G07 | Generic Coverage | PARTIAL | T ResolvePropagationStats | M | P0 |
| G08 | Generic Potency | PARTIAL | T/M/S | H | P1 |
| G09 | Min/max range | PARTIAL | TC/DB/SI | M | P1 |
| G10 | Duration/Frequency | MISSING | Native auras/S amount | H | P2 |
| G11 | Cast speed | PARTIAL | M/S/SH | M | P1 |
| G12 | Projectile speed | PARTIAL | E native Speed read | H | P2 |
| G13 | Cost/resources | PARTIAL | Native core/S/E | H | P1 |
| G14 | Cooldown | PARTIAL | M/S | H | P1 |
| G15 | School conversion | PARTIAL | T/S/SH/SC/SE/U | H | P1 |
| G16 | Other conversions | MISSING | No general graph | H | P2 |
| G17 | Healing/weapon payloads | PARTIAL | D/S/E | H | P1 |
| G18 | DoT/HoT execution | PARTIAL | S/native auras | H | P2 |
| G19 | Ground persistent fields | MISSING | D Blizzard disabled | H | P2 |
| G20 | Crit/reliability | PARTIAL | Native core/R flags | H | P1 |
| G21 | Scaling | PARTIAL | Native core/S | H | P0 |
| G22 | Aura/control/dispel | PARTIAL | Native core/T/S | H | P2 |
| G23 | Movement/mobile | MISSING | M explicitly disables | H | P2 |
| G24 | Threat | PARTIAL | E logical caster/native core | H | P2 |
| G25 | Pets/summons/traps | MISSING | Native core; T flags | H | P2 |
| G26 | Visual/audio taxonomy | PARTIAL | T/E/SH/SC | M | P2 |
| G27 | Gem entities/rarity/ranks | MISSING | T fixed node ranks | M | P1 |
| G28 | Signed sidegrade stats | MISSING | T unsigned rank nodes | H | P1 |
| G29 | Classless ownership | MISSING | M ClassId gate/PL | H | P0 |
| G30 | Universal talent definitions | MISSING | Native DB/PL only | H | P0 |
| G31 | Semantic conversion | MISSING | Sample script audit | H | P1 |
| G32 | Talent ACTIVE/DORMANT | MISSING | No ownership model | M | P1 |
| G33 | Universal talent UI | MISSING | Ability UI | M | P1 |
| G34 | Universal event triggers | PARTIAL | S/R/P local hooks | H | P2 |
| G35 | Proc recursion control | PARTIAL | S root guards/P budget | H | P0 |
| G36 | Ownership persistence | PARTIAL | M single-row upsert | H | P0 |
| G37 | Schema versioning | MISSING | C4 migration only | H | P0 |
| G38 | Large catalog transport | MISSING | A 255-byte protocol | M | P1 |
| G39 | Keystone system | MISSING | Concept only | H | P2 |

### Original abstraction and remaining work columns

| ID | Required abstraction | Missing work |
| --- | --- | --- |
| G01 | Spell/effect graph | Scoped fields |
| G02 | Effect importer | Payload graph/provenance |
| G03 | Geometry profiles | Cone/line/ring/arc adapters |
| G04 | Typed requirements | AST + adapter manifest |
| G05 | Radius/work policy | Root-wide safety bound |
| G06 | Bounded strategy | Aura/timer adapters |
| G07 | CoverageResolver | Geometry profiles/trade-offs |
| G08 | Typed potency domain | Absorb/control/resource scope |
| G09 | Numeric range profile | Friendly/hostile/reach adapters |
| G10 | Lifetime/schedule resolver | Refresh/tick policies |
| G11 | SpeedResolver | Multi-axis ownership |
| G12 | Velocity override | Generic editable axis |
| G13 | Typed ledger/resolver | Runes/combo/health/refunds |
| G14 | Timer ownership | Categories/GCD/charge adapters |
| G15 | Effect school policy | Identity/proc/aura coverage |
| G16 | Typed conversion DAG | Legality/conservation adapters |
| G17 | Typed payload bundles | Broad source coverage |
| G18 | Lifecycle adapter | General events/frequency |
| G19 | Field owner/geometry | Runtime adapter |
| G20 | Outcome policies | Generic modifier exposure |
| G21 | Domain ledger | Avoid duplicate SP/AP/proc scaling |
| G22 | Mechanic contracts | Stacks/DR/lockout selectors |
| G23 | Movement adapter | Cast/channel/turn checks |
| G24 | Threat policy | Generic override/forced aggro |
| G25 | Ownership/inheritance | Ulduar adapters |
| G26 | Presentation profile | Asset mapping/client validation |
| G27 | Gem catalog | Definitions/variants/groups |
| G28 | Signed resolvers | Effective drawback validation |
| G29 | Classless service | Grants + native reconciliation |
| G30 | Ulduar catalog | Shared rule compiler |
| G31 | Reviewable converter | Masks/scripts/proc analysis |
| G32 | Compatibility index | Invalidation and recompute |
| G33 | Catalog/owned view model | Search/filter/state protocol |
| G34 | Combat event bus | Defense/resource/lifecycle |
| G35 | Global event ancestry | Root budget/dedup/ICD |
| G36 | Transaction ledger | Multi-table/outbox/receipts |
| G37 | Versioned catalog | Published FK/review manifests |
| G38 | Bounded paging/chunking | Catalog cache/integrity |
| G39 | Structural character tier | Conflicts/validation/snapshot |

### Added candidate evaluation columns

Column expansion:

- Candidate = **Candidate project**.
- Impl = **Existing implementation**, resolved in the implementation key below.
- Cov = **Coverage** of the named Ulduar gap, not of CoA's own class behavior.
- Port = **Port difficulty** of the closest candidate mechanism.
- Core = **Core edits required** to bring that mechanism into current Ulduar.
- Client = **Client edits required** for that mechanism.
- Conflict = **Conflicts with Ulduar**, resolved in the conflict key.
- Rec = **Recommendation** for that gap.

| ID | Candidate | Impl | Cov | Port | Core | Client | Conflict | Rec |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| G01 | CoA | None | 0 | NA | - | - | N | KEEP |
| G02 | CoA | K01 | R | H | Y | D | I | REF |
| G03 | CoA | K02 | R | H | Y | ? | S | REF |
| G04 | CoA | None | 0 | NA | - | - | N | KEEP |
| G05 | CoA | None | 0 | NA | - | - | N | KEEP |
| G06 | CoA | K03 | R | H | Y | D | S | REF |
| G07 | CoA | None | 0 | NA | - | - | N | KEEP |
| G08 | CoA | K06 | R | H | Y | D | S | REF |
| G09 | CoA | K01 | R | H | Y | D | I | REF |
| G10 | CoA | K03 | R | H | Y | D | S | REF |
| G11 | CoA | K07 | R | H | Y | D | S | REF |
| G12 | CoA | K10 | R | H | Y | X | V | REF |
| G13 | CoA | K04 | R | H | Y | X | S | REF |
| G14 | CoA | K05 | P | M-H | Y | A | S | DEFER |
| G15 | CoA | K06 | R | H | Y | D | S | KEEP |
| G16 | CoA | K11 | R | H | Y | A | S | KEEP |
| G17 | CoA | K06 | R | H | Y | D | S | REF |
| G18 | CoA | K03 | R | H | Y | D | S | REF |
| G19 | CoA | K02 | R | H | Y | D | S | REF |
| G20 | CoA | K06 | R | H | Y | D | S | REF |
| G21 | CoA | K07 | R | H | Y | - | S | REF |
| G22 | CoA | K03 | R | H | Y | D | S | REF |
| G23 | CoA | K08 | R | H | Y | D | S | KEEP |
| G24 | CoA | None | 0 | NA | - | - | N | KEEP |
| G25 | CoA | K09 | R | H | Y | X | S | REF |
| G26 | CoA | K10 | R | H | Y | X | V | REF |
| G27 | CoA | None | 0 | NA | - | - | N | KEEP |
| G28 | CoA | None | 0 | NA | - | - | N | KEEP |
| G29 | CoA | K11 | P | H | ? | A | O | ADAPT |
| G30 | CoA | K12 | R | H | ? | A | S | ADAPT |
| G31 | CoA | K06 | R | H | ? | - | S | REF |
| G32 | CoA | None | 0 | NA | - | - | N | KEEP |
| G33 | CoA | K13 | R | H | Y | X | V | KEEP |
| G34 | CoA | K07 | P | H | Y | ? | S | REF |
| G35 | CoA | K07 | R | H | Y | - | S | KEEP |
| G36 | CoA | K14 | P | H | ? | A | O | ADAPT |
| G37 | CoA | K15 | R | H | ? | D | I | KEEP |
| G38 | CoA | K13 | R | H | Y | X | V | KEEP |
| G39 | CoA | None | 0 | NA | - | - | N | KEEP |

Coverage: 0 = no counterpart found; R = related reference only; P = partial implementation of a subproblem.
No row is fully covered. A P does not promote the original row to DONE.

Port: M-H = moderate isolated utility, high end-to-end integration; H = high semantic/data integration work;
NA = no implementation to port. No calendar estimates or performed merge results are implied.
Core: Y = required by the observed implementation; ? = extraction might avoid edits, not yet demonstrated;
- = no candidate change. Client: A = addon/data adapter; D = matching custom DBC/data;
X = custom executable/UI/protocol coupling; ? = mechanism-dependent; - = none for that isolated mechanism.
These columns assess importing CoA's mechanism, not requirements for implementing the Ulduar abstraction independently.

Conflict: N = no candidate conflict because nothing is imported; I = native ID/schema/provenance assumptions;
S = combat/structural semantics differ; O = ownership/authority differs; V = visual/client protocol differs.

Recommendation: KEEP = retain the Ulduar design and implement its gap;
REF = use the candidate as evidence only, with no runtime replacement;
ADAPT = assess a bounded acquisition/data adapter while retaining Ulduar authority;
DEFER = postpone utility extraction until the relevant Ulduar contract exists.
ADAPT/DEFER are future evaluation candidates, not approved code changes in this phase.

For **each G01-G39**, the separate Free Pick/Wildcard project has Candidate =
PENDING_EXTERNAL_SOURCE; Impl, Cov, Port, Core, Client and Conflict = UNKNOWN;
Rec = WAIT_FOR_EXACT_SOURCE. This applies to all 39 rows without substituting CoA evidence for that project.
The unspecified classless distribution has the same unknown status.

### Implementation key and limits

| Key | Closest CoA implementation | Why it does not close the complete gap |
| --- | --- | --- |
| None | No equivalent abstraction found | Required Ulduar feature remains |
| K01 | Native DBC/SpellInfo and exact-record fixers | No immutable indexed effect graph or provenance importer |
| K02 | Custom class target/area scripts | No generic geometry or persistent-field owner |
| K03 | Aura refresh/stack/duration/delayed native effects | No shared lifecycle/frequency/control contracts |
| K04 | Class resource tables and resource service | No universal cost/refund ledger |
| K05 | SpellChargeState and Player charge settings | No complete Ulduar timer/GCD/category ownership adapter |
| K06 | Exact-ID healing/combat/class scripts | No universal effect selector, potency or conversion engine |
| K07 | Spell script values, event hooks, damage flags | No global ancestry, root work budget or scaling ledger |
| K08 | Class-specific cast/movement exceptions | Ulduar mobile policy cannot inherit global exceptions |
| K09 | Custom summon/pet scripts and native Player logic | No generalized grant/inheritance contract |
| K10 | Spell packets, custom client and DBC dependencies | No Ulduar visual/audio profile abstraction |
| K11 | Taught abilities, replacement and progression sync | No durable multi-source classless ownership |
| K12 | CoATalentEntry/native rank catalog | No generalized definitions/compiler |
| K13 | Generated client talent data and extension protocol | No portable Ulduar library/paging implementation |
| K14 | Player settings, native spells, cosmetic collections | No atomic entitlement/budget/outbox/receipt service |
| K15 | Generated catalogs and fork world baseline | No Ulduar published semantic catalog/version contract |

K11 deliberately distinguishes native replacement from structural conversion in G16:
replacing a SpellID does not implement effect-graph conversion, so G16 remains KEEP.
K12's ADAPT in G30 means import source identity/rank provenance if useful; definitions and semantics remain Ulduar's.
K14's ADAPT in G36 concerns projection/login recovery integration, not copying the cosmetic schema as ownership.
K05 is outside the CLASSLESS replacement boundary: its utility may be assessed later under the existing cooldown
design, but classless adoption does not authorize replacing cooldown execution.

### Important residual obligations by feature group

- G01-G04: custom classes and native effect codes do not supply spell/effect separation or typed capability matching.
- G05-G12: preserve existing propagation behavior while defining bounds, geometry and time domains.
  A delayed native trigger is not a spread/repeat strategy or editable projectile-speed resolver.
- G13-G18: keep resource debit ownership, native rank identity and generalized conversion ownership distinct.
  Charge recovery and native replacement are partial mechanisms with separate lifecycle assumptions.
- G19-G26: each execution adapter needs outcome, scaling, control, movement, threat and caster attribution contracts.
  Existing native/class scripts cannot silently become universal adapters.
- G27-G28: neither gem entities nor meaningful signed sidegrades are established by the candidate.
- G29-G33: cataloging or learning a native talent does not establish semantic conversion or ACTIVE/DORMANT rules.
- G34-G35: local first-hit flags and recursion guards do not prove a cross-system event budget or deduplication policy.
- G36-G39: settings, client-generated tables and world dumps do not provide transaction-safe versioned builds,
  bounded large-catalog synchronization or keystone compilation.

## Acquisition features emphasized by the request

These entries supplement, rather than replace, the 39-row mapping.

| Feature | Current / candidate evidence | Port decision and remaining authority |
| --- | --- | --- |
| Classless ownership | Missing / K11 temporary grants | Adapt lifecycle lessons; build grant-source ledger |
| Universal spell acquisition | Class gate / class-bound ranks | New cross-class eligibility and native grant adapter |
| Universal talent acquisition | Missing / K12 class/spec native IDs | Import provenance; own generalized purchases |
| Point budgets | Ability EP / AE-TE fields only | New trusted acquisition ledgers; never repurpose EP |
| Ranks | Existing native chains / 2,709 class-bound rows | Preserve adapter; separate custom/native/talent ranks |
| Prerequisites | Proposed / automatic dependency subset | New generic graph, downgrade/cascade validation |
| Resources | Native mechanics / K04 custom class policies | Explicit coexistence and mechanic unlock adapters |
| Persistence | Ability rows / K14 native/settings state | Atomic ownership, budgets, receipts and outbox |
| Grant reconciliation | Native known state / K11 temporary rules | Multi-source ownership and login/crash repair |
| Universal talent browsing | Proposed / K13 custom class UI | Own searchable library with ACTIVE/DORMANT reasons |
| Large catalog UI | Existing small list / generated client data | Versioned paging/filter/cache; bounded messages |
| Client patch | Existing addon / native v4 dependencies | No CoA executable migration for first ownership slice |
| DBC modifications | Native input / targeted fixers | Stock native grants first; custom content later versioned |
| Free Pick | Missing / no complete inspected backend | Purchase flow over shared atomic ownership service |
| Wildcard | Missing / original client events only | Server-owned offers, locks, rerolls and durable choices |
| Respec | Per-ability customization / native spec switching | Preview/commit full entitlement diff and refunds |
| Spellbook integration | Ulduar addon / temporary replacements | Preserve ranks, action bars and mixed grants |

For all rows above, the related restoration project's implementation remains PENDING_EXTERNAL_SOURCE.
No source-based conclusion about its client, SQL, core edits or production readiness is possible.

## Core merge-risk matrix

This is a static conflict assessment, not a merge attempt. Probability is qualitative:
H = overlapping ownership of the same behavior; M = interface or integration overlap; U = unknown source.
It describes likely conflict pressure, not a measured percentage.

The original requested columns are split into two joined tables by M01-M12:
File/system, Current Ulduar changes, Candidate base changes, Conflict probability, Semantic conflict and Port strategy.
All five currently modified core files appear individually.

| ID | File/system | Current Ulduar changes | Candidate CoA changes |
| --- | --- | --- | --- |
| M01 | Spell.cpp | Delivery, visual packets, school, timing, ammo, target checks | Hooks, class rules, health cost |
| M02 | Spell.h | Per-cast school/delivery/timing/validator state | Script values, attack context, custom effects |
| M03 | SpellEffects.cpp | School override in direct damage bonus calls | Extended effects, triggers, resources |
| M04 | Unit.cpp | School-aware bonus/hit/crit/immunity/proc paths | Derived damage, conditional combat, powers |
| M05 | Unit.h | School-aware function signatures/defaults | Class masks, conditional combat interfaces |
| M06 | Ability definitions/types | 30 definitions; 28 runtime-enabled; fixed nodes | Custom IDs and native families |
| M07 | Ability runtime/resolvers | Contexts, propagation, legality, secondaries | New callbacks and cast behavior |
| M08 | Manager/player hooks | Ranks/EP, persistence, lifecycle, availability | Progression and learn/forget sync |
| M09 | Module integration | Loader, commands, conf, bindings, CMake/include | Expanded script/core interfaces |
| M10 | Client addon/data | Protocol2, drafts, list/tree/tooltips, spellbook | Custom APIs, native v4, generated data |
| M11 | SQL and state | Module schemas, starter bindings, modifier columns | Full world baseline and custom schemas |
| M12 | Other installed modules | Citybuilder, density, editor, wave survival | Map/scaling/creature/player changes |

| ID | Conflict probability | Semantic conflict | Port strategy if migration were later chosen |
| --- | --- | --- | --- |
| M01 | H | Travel time, caster attribution, cost timing | Reapply each invariant around destination hooks |
| M02 | M-H | Lifecycle/state ownership and callback ordering | Keep typed Ulduar state; explicit API mapping |
| M03 | H | Scaling twice; school differing from SpellInfo | Trace each effect's amount and school once |
| M04 | H | Mitigation/crit/immunity/derived amounts diverge | Audit all callers and secondary execution stages |
| M05 | M | Defaults hide native-school fallbacks | Preserve signatures and audit new call sites |
| M06 | M-H | IDs, rank roots, class gates, effect layouts | Content manifest and source-signature validation |
| M07 | H | Recursive triggers, work bounds, visual proxy ownership | Keep Ulduar runtime and prove adapter parity |
| M08 | H | Grant removal versus owned EP/talents | Separate entitlements from customization state |
| M09 | M | Hook registration/order and script binding overlap | Inventory all module interfaces and SQL bindings |
| M10 | H | Wire format, spellbook, charge and missile display | Matched client profile plus authoritative UI contract |
| M11 | H | Existing data overwritten or entitlements lost | Explicit migration; no baseline import over live |
| M12 | M-H | Maps, level scaling and lifecycle hooks change | Independently assess each module before migration |

### Complete current core-change checklist

The five-file local diff totals 287 additions and 47 removals.
CoA's base-to-tip textual changes in the same files total approximately:
Spell.cpp +123/-16, Spell.h +52/-0, SpellEffects.cpp +337/-3, Unit.cpp +592/-55, Unit.h +18/-3.
These are different baselines and are not a three-way conflict count or an effort estimate.

Spell.cpp/.h changes that must survive a hypothetical migration:

- `SpellCastTargets::SetSrc(SpellDestination const&)` for preserving presentation source coordinates.
- Per-cast school override, set before targeting, without mutating shared SpellInfo.
- Optional target validator at acquisition/range and immediately before hit-side effects.
- Direct-trigger-only instant delivery and travel-time override, with matching server arrival and visual timing.
- Snapshot visual source GUID/destination and separate visual-only SpellGo emission.
- Suppression of inappropriate SpellStart/SpellGo for instant secondary payloads.
- Visual targets that preserve explicit channel payload targets and transport-aware source positions.
- Per-cast ammo bypass for synthetic copies, retaining normal weapon checks and native shot behavior.
- Cast-time multiplier/minimum applied in prepare within existing nontriggered/nonchannel guards.
- School override forwarded through hit, delayed immunity, damage and critical calculation paths.

SpellEffects.cpp must preserve override school in both damage bonus done and taken.
Unit.cpp/.h must preserve override-aware damage calculation, percent/flat bonuses, critical damage,
magic hit, reflection and resistance, damage/spell immunity, and ProcEventInfo school reporting.
Default arguments preserve native callers; new CoA callers still require inspection.
The current implementation remains partial for consumers that read native SpellInfo directly.

CoA additionally modifies Player, SpellInfo, SpellMgr, Aura effects, ScriptMgr hooks, network handling,
creation/class masks, DB loaders, maps and stats. Moving just the five Ulduar files would miss those dependencies.
A textual merge could be clean while secondary casts receive duplicate scaling or native resource debits.

### Complete current module/client/data inventory to carry

The inventory concerns existing working content, including files absent from the root commit.
It is not an instruction to copy, merge or delete anything.

| Group | Existing artifacts requiring preservation |
| --- | --- |
| Definition/model | AbilityTypes.h/.cpp, AbilityDefinitions.h/.cpp |
| State/availability | AbilityManager.h/.cpp, AbilityPlayerScript.cpp, AbilityCommands.cpp |
| Runtime | AbilityRuntime.h, AbilitySpellScript.cpp |
| Propagation/targets | AbilityPropagationResolver.h/.cpp, AbilityTargetResolver.h/.cpp |
| Secondary execution | SecondarySpellExecutor.h/.cpp |
| Protocol/loader | AbilityAddonProtocol.cpp, UlduarAbilities.cpp |
| Module packaging | CMakeLists.txt, include.sh, configuration, existing supporting files |
| Module world SQL | ulduar_abilities_001_world.sql |
| Module character SQL | ulduar_abilities_001_characters.sql, ulduar_abilities_002_characters_propagation.sql |
| Pending root SQL | ulduar_abilities_003_world_starters.sql, ulduar_abilities_004_characters_modifiers.sql |
| Client state/protocol | Core.lua, Protocol.lua, DraftBuild.lua |
| Client views | AbilityList/Tree/Details/Tooltip.lua, UlduarFrame.lua, UlduarTemplates.xml |
| Client integration | SpellBookIntegration.lua, UlduarMicroButton.lua, UlduarAbilities.toc |
| Client widgets | Connections.lua, Node.lua, ScrollList.lua, Tabs.lua, Theme.lua |
| Client/reference data | Existing asset mappings and DBC-derived native identity; validate against candidate records |
| Documentation/config | Existing module/client/architecture documents, balance and starter contracts |

The inspected client tree does not establish a deployable Ulduar binary/MPQ patch artifact.
Migrating to CoA would add that reproducibility burden rather than simply copying an existing matched package.

Key current contracts to preserve: Protocol2's 255-byte message bound, 8 requests per two seconds,
token/sequence/revision handling, draft/committed separation, highest-known native rank lookup,
custom rank/EP state, selected healing/periodic/weapon adapters, five propagation modes and target revalidation.
Flash Heal and Blizzard remain metadata-only; a base migration must not imply those adapters became enabled.

## Relative port cost and stop conditions

KEEP_CURRENT_BASE removes the migration work above from the immediate classless critical path.
The remaining work is the ownership layer itself, plus deliberate class-availability and addon integration.
CoA does not eliminate that ownership work sufficiently to compensate for the additional integration surface.

A future acquisition module port should be stopped or redesigned if it requires replacing the Ulduar runtime,
reusing ability EP as talent currency, storing only native known-spell state as purchase authority,
globally disabling spell requirements, or exposing client-calculated costs.
Those are concrete incompatibilities with the requested architecture.

For the unknown module/distribution, every merge probability and port-cost estimate remains U.
The current CoA matrix must not be reused as if it described an unseen Free Pick/Wildcard repository.
