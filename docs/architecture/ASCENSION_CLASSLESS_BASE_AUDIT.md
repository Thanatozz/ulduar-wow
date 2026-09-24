# Ascension and CoA classless base audit

Audit date: 2026-09-14. Static, read-only evaluation of source and repository history.
No build, merge, SQL execution, module installation or client patching was performed.
Only the four requested architecture documents are new deliverables.

## Finding

CoA is a substantial restoration of Ascension's custom-class environment on AzerothCore.
It contains useful native spell, rank, temporary-grant and custom-content mechanisms.
It is not evidence of a complete universal Free Pick/Wildcard acquisition backend.
Its custom talent access still checks class and specialization, and applies native SpellIDs.

The related community Free Pick/Wildcard server project is **PENDING_EXTERNAL_SOURCE**.
Workspace searches found original Ascension client UI, but no matching restoration checkout or exact project URL.
No repository URL was guessed. Missing source is unknown capability, not evidence of a defective implementation.

Recommendation: retain the current AzerothCore base and implement the independent Ulduar classless service.
The [comparison](CLASSLESS_BASE_COMPARISON.md), [port matrix](CLASSLESS_PORT_MATRIX.md) and
[roadmap](ULDuar_UPDATED_ROADMAP.md) provide the decision, complete gap mapping and next-phase boundaries.

## Evidence identity and limits

| Item | Inspected identity |
| --- | --- |
| Ulduar root HEAD | `d7ce67dc1800f092bac98aad680ece1c201b89a0` |
| Ulduar module HEAD | `5f51c5e012b153b1edae00af2b0e11a9d45ba62d` |
| CoA repository | [jealous-sound/azerothcore-wotlk-coa][repo] |
| CoA main snapshot | `feb155c82c754f7190ffebc9843cab581ccda7b7` |
| CoA commit timestamp | 2026-09-14 14:39:42 UTC |
| CoA upstream base | `084c9e2bf116723f541deae5a04b025fa6396509` |
| Upstream comparison tip | `e1823bb2db751a7cc0a90a8543e778449ebf7d84` |

Ulduar's working source is not reconstructible from HEAD alone: five modified core files, module implementation,
client data and pending SQL already exist. The prior [gap audit](ULDuar_GAP_ANALYSIS.md) records those changes.
This evaluation used the actual working files and captured SHA-256 hashes of 120 existing files for preservation.

GitHub metadata reports CoA as a standalone repository, rather than a GitHub fork-network member.
Git ancestry nevertheless establishes its AzerothCore origin: the parent of initial CoA main customization
`d077a19a6fc02a426e7eb9b3b4fd15ac8ccc5e30` is the upstream base above.

GitHub comparisons from that base report 116 commits to the CoA tip, 164 to Ulduar's committed HEAD and
274 to the inspected upstream tip. These are separate base-to-tip ancestry counts, not an assertion that CoA
is exactly 116 ahead and 274 behind the current upstream branch. Direct cross-repository tip comparison was
unavailable through the fork-network compare endpoint. Ulduar's uncommitted changes are additional.

Comparing the complete Git trees at the CoA base and tip found 713 differing paths:
430 under modules, 116 under data, 83 under src, 53 under .github, 18 under apps, seven under .agents,
and six other paths. A changed path includes additions and deletions; counts do not measure merge difficulty.
The recursive tip tree contained 11,401 entries and was not truncated.
[Base commit][base], [CoA commit][tip] and the source map below anchor this snapshot.

Repository documents describe intended deployment and upstream tests; this audit did not reproduce those tests.
Generated data and SQL establish available definitions, not applied databases or complete live behavior.
The public tree does not supply a complete reproducible client package.

## Repository and deployment infrastructure

| Area | Observed implementation | Ulduar implication |
| --- | --- | --- |
| Module | Vendored `mod-ascension-compat` with class scripts and generated headers | Not a standalone drop-in |
| Core | 83 changed src paths, including Player, Spell, Unit, networking and DB loaders | Broad integration surface |
| World DB | Custom classes, race rules, starts, stats, spells, scripts and progression SQL | ID and content migration |
| Character DB | Appearance/vanity collections; Manastorm state; existing player settings | No universal grant ledger |
| Auth DB/protocol | Login DB, SRP6 and AuthSession changes appear in the tree delta | Requires separate auth review |
| DBC input | Custom class/spell records expected; generated server metadata | Matching client/server data |
| DBC tools | Targeted Python spell record fixers under apps/coa-spells | Not a full content compiler |
| Client binaries | Native v4 client and Extensions.dll compatibility documented | Stock client parity unproven |
| Client endpoint | Hash-checked world-address patch utility | Client-specific deployment step |
| UI | Generated talent data and custom FrameXML resources referenced | Companion inputs required |
| Transport | Extension opcodes, altered spell-modifier layout, addon charge messages | Multiple coupled protocols |
| Distribution | Client tooling delegated to a companion repository | No complete public patch pipeline |
| Launcher | Repository organization says surrounding launcher is not required | Matching executable still needed |

The world bootstrap includes `data/coa-world/coa-world-20260912.zip` (93,237,616 bytes) and a baseline manifest.
This is a fork-specific world baseline, not a narrow classless migration to apply over Ulduar.
The archive was not downloaded or executed. The bootstrap README and manifest were inspected descriptively.
See [world bootstrap][world] and [repository organization][organization].

The class schema defines `ascension_custom_class` and `ascension_custom_class_race`, including fallback class,
power type and primary stat. SQL also adjusts custom-class player creation and native fallback stat curves.
Do not assume every descriptive table drives a runtime loader: generated C++ catalogs remain significant.

Collection SQL defines `account_appearance_collection`, `character_appearance`,
`character_appearance_settings` and `account_vanity_collection`. Cosmetic entitlement persistence is not
transactional ability/talent purchase persistence. Player settings also store specialization and charge state.
None of these observations establishes a general classless purchase/refund/outbox model.

## Custom classes, spells and talents

### Class identity and creation

CoA recognizes 21 custom class IDs, 12 through 32. `IsAscensionCustomClass` and progression code enforce that scope.
Creation initializes class-specific baselines, starter kits, race rules, resources and proficiencies.
Core changes extend class masks and assumptions in SharedDefines, Player, Unit, DBC loading and creation handlers.
Fallback class behavior supports stats, equipment and native compatibility; it is not a universal rule exemption.

The configuration option `AscensionCompat.MapClass10ToWarrior` explicitly describes reserved classless ID 10
as using a Warrior shell until a classless progression backend is added.
A shell that permits login is not proof of universal spell acquisition, budgets, respec or Wildcard.
See the [module configuration][config] and `AscensionClassService` in [AscensionCompat.cpp][compat].

### Native spell and talent catalogs

`AscensionCoATalentData.h` declares 3,618 entries, including automatic progression records.
Each has EntryId, ClassId, SpecId, SpellCount, AECost, TECost, RequiredLevel and up to three native SpellIDs.
This count is not 3,618 generalized talents or proof that all effects are implemented.
`AscensionSpellProgressionData.h` declares 2,709 class-bound native rank records.
Progression requires ownership of the root and sufficient level; it preserves native rank-chain behavior.

`HandleLocalTalentCommand` resolves a catalog entry, checks the player's class, selects/checks specialization,
validates rank and level, checks nonzero existing SpellIDs and handles mutually exclusive free selections.
The path removes old native rank spells and invokes `player->learnSpell`; it does not invoke
`Player::LearnTalent` to purchase through native TalentTab tiers.

The distinction matters: bypassing native LearnTalent does not create generalized semantics.
The resulting spells and passive auras still execute native masks, families, effect IDs and scripts.
The handler's own ClassId and SpecId checks also prevent treating it as all-class acquisition.
Source anchor: [AscensionCompat.cpp][compat], `HandleLocalTalentCommand`, approximately lines 3325-3438.

AECost/TECost fields exist, but the inspected command does not compute/debit a complete paid AE/TE budget.
Its automatic-entry branch checks zero-cost progression prerequisites; equivalent full paid-tree validation,
original native tier spend enforcement, a durable request receipt and atomic build transaction are not present there.
Do not expose that local command as a production Free Pick purchase API without replacing the validation path.

`SwitchSpecialization` stores a specialization setting, removes catalog talent ranks and resynchronizes progression.
Its refund message is not evidence of a currency ledger or transaction-safe universal respec.
Paid shared-tree dependency behavior is intentionally adjusted in the documented generator.
Native tier/prerequisite equivalence must therefore not be assumed.
See [talent catalog][talents] and the [module README][module].

### Grants and reconciliation

`SynchronizeTaughtAbilities` uses 14 explicit class/spec/level/parent-to-child rules.
It grants children temporarily and distinguishes existing permanent ownership from temporary entries,
including pending removals. Dual-wield state is reconciled.
This is a useful model for grant lifecycle edge cases, but not a reference-counted source ledger.

`SynchronizeTalentReplacements` uses 12 explicit native replacement rules. It selects eligible rank families,
uses temporary spell replacement state and removes stale temporary children while preserving native originals.
This may inform spellbook projections; it does not implement a typed structural conversion DAG.

Automatic talents synchronize through bounded passes over a catalog and known-spell dependencies.
Login, level, learn/forget and specialization hooks trigger synchronization.
Ulduar still needs durable ownership by source, dependency invalidation, atomic budgets and crash recovery.
See [taught abilities][taught], [replacement data][replacements] and [AscensionCompat.cpp][compat].

### Spell execution and custom effects

CoA expands the native effect dispatch space through effect IDs 165-198. Some entries remain EffectNULL.
Implemented examples include cooldown modification/reset, base mana/health restoration, aura refresh,
stack and duration changes, delayed trigger spells and charge restoration.
These are concrete native adapters, not evidence that arbitrary new effects work without engine support.

Class scripts and exact-ID correction tables cover custom combat behavior. `AscensionHealingStatSelectors.cpp`
checks nine exact spell signatures, including family and all three effect slots, before changing selected fields.
Despite its name, it is not a general selector AST over arbitrary spell/effect graphs.
Conditional combat similarly uses native family, aura and effect conventions, including class-family coupling.

Spell-local script values and Pooled Vitality snapshots preserve selected cast decisions.
Derived-damage flags avoid repeating particular scaling/mitigation steps.
Those mechanisms are relevant references for Ulduar's scaling ledger, but do not establish an equivalent
universal taxonomy, conversion pipeline, CoverageResolver, PotencyResolver or deterministic rule compiler.
See [spell implementation][spell], [effect handlers][effects] and [module sources][sources].

### Resources and charges

Resource data defines class-bound displays and gain/consumption events. Runtime rules inspect class, spell,
required/forbidden auras and event occurrence, then mutate aura stacks or trigger native resource spells.
Probabilistic resource gains use server random helpers. This is combat proc RNG, not Wildcard draft generation.

Native Mana, Rage, Energy, Runic Power, Runes and Combo Points remain native mechanics with class-specific adapters.
CoA adds custom aura resources and regeneration rules; for example, Ranger focus policy and Reaper soul state.
It does not establish a universal simultaneous-resource ledger with cross-class cost/refund arbitration.
Forms, stances and pets have native/class-script support; universal ownership and inheritance are not demonstrated.

`SpellChargeState.h` provides isolated charge arithmetic with sequential recovery.
Player integrates charge consumption, restoration and persistence through `core.spell_charge.<key>` settings,
and emits `ASC_LOCAL_CHARGES` messages. Ability rank families and restore categories have distinct behavior.
The utility is portable with an adapter; the complete feature additionally changes Player, SpellInfo, effects and UI.
Its invalid/legacy-state recovery policy must be reviewed before reuse; it is not Ulduar ownership persistence.
See [charge utility][charges] and [Player integration][player].

## Client coupling and reproducibility

WorldSocket accepts a configured extension opcode range (defaults 0x051F-0x09D3), can use plaintext world headers,
and adjusts ping handling for Extensions.dll. Compatibility is gated by loopback/AllowRemoteClients and configuration.
The module handles selected extension packets, such as collection and Manastorm operations, and consumes others.
Consuming a packet without implementing its gameplay is not a restored feature.

Player's custom spell-modifier packet layout has its own loopback plus Enable condition.
This differs from WorldSocket's optional remote-client gate, so enabling remote connections alone does not
prove every custom UI protocol works remotely. The local acquisition command is registered for player access;
its missing paid-budget validation must be treated as an unfinished authority boundary.

The documented world-endpoint utility patches a known client DLL after validating its binary identity.
No executable patch was run. The public tree does not contain the matching client DBC/MPQ/Lua package or
the complete native v4 executable/Extensions.dll distribution.
The targeted spell DBC scripts check a specific WDBC shape and spell signature before emitting a changed file;
they are not arbitrary spell allocation, MPQ packaging, release manifest or updater systems.
See [client compatibility][client], [DBC tools][dbc] and [WorldSocket][socket].

The repository organization document names a private companion, `jealous-sound/coa-local-kit`,
for client tooling and historical generators. It also says both repositories are private; that historical
statement conflicts with the currently readable public server repository. This audit relies only on the public
snapshot and does not claim to have inspected the companion.
Generated headers reference external Tools inputs, including `Generate-LocalCoATalentData.ps1`,
which generates matching server and client talent data.
Full client/server reproduction remains an external dependency, not an assumed completed port.

## Component classification

Classification evaluates reuse in the existing Ulduar checkout, not quality for CoA's own restoration target.
No complete external classless subsystem qualifies as DIRECTLY_REUSABLE in this snapshot.

| Component | Classification | Reason |
| --- | --- | --- |
| Arbitrary/custom spell path | USEFUL_REFERENCE | DBC + native effects/scripts, not semantic ability graphs |
| 21 custom classes | NOT_RELEVANT | Ulduar ownership does not require adopting new class identities |
| Class masks/fallback gates | CONFLICTS_WITH_ULDuar | Class-bound eligibility cannot authorize universal ownership |
| Custom talent catalog | PORTABLE_WITH_ADAPTER | Import shape/provenance; replace class, budget and rule policy |
| Native talent effects | USEFUL_REFERENCE | Exact spells/scripts need separate semantic conversion |
| Custom spell scripts | USEFUL_REFERENCE | Useful source cases; no replacement for Abilities adapters |
| Resource rule tables | USEFUL_REFERENCE | Event examples; class and spell coupling remain |
| Universal resources | CONFLICTS_WITH_ULDuar | Replacing Ulduar's typed ledger with class policy is unsuitable |
| Temporary taught grants | PORTABLE_WITH_ADAPTER | Preserve native edge cases; add durable grant-source ledger |
| Native replacements | PORTABLE_WITH_ADAPTER | Spellbook adapter only; preserve conversion ownership |
| Rank progression catalog | PORTABLE_WITH_ADAPTER | Replace source-class gate; preserve root/rank distinctions |
| Local talent command | CONFLICTS_WITH_ULDuar | Missing paid transaction authority; class/spec restrictions |
| Charge arithmetic | PORTABLE_WITH_ADAPTER | Isolate timing policy; supply core, persistence and UI adapter |
| DBC record fixers | USEFUL_REFERENCE | Signature checks useful; complete generator absent |
| Client patch distribution | USEFUL_REFERENCE | Partial tooling/dependency model; no full public package |
| Custom UI packets | CONFLICTS_WITH_ULDuar | Different executable and transport contract |
| Cosmetic collections | NOT_RELEVANT | Outside requested classless ownership |
| Full world bootstrap | CONFLICTS_WITH_ULDuar | Replaces much more content than the requested layer |

PORTABLE_WITH_ADAPTER is a candidate classification, not an instruction to port or evidence of lower total cost.
Runtime components outside CLASSLESS remain references until an equivalent or superior Ulduar abstraction is proven.

## Free Pick / Wildcard source status

**PENDING_EXTERNAL_SOURCE** applies to the related restoration server project and all implementation questions below.
Searches covered local project/document/code files for exact repository URLs and project names.
Original Ascension UI exists at `C:/WoWProjecto/Work/ascension/Interface`, also with files under `Work/Interface`.
That client extraction is not the missing restoration server.

Observed `Ascension_WildCard/WildCard.lua` registers roll-ready, unlearn-result, dice-used,
entry-learned and rapid-roll events. `FrameXML/Util/WildCardUtil.lua` uses
`C_CharacterAdvancement.IsMastery`, `IsKnownID` and `C_Wildcard.CanRollAbilities`.
These prove a client-facing vocabulary and dependency on custom native APIs.
They do not establish the server algorithm, ownership ledger, validation, persistence or an available AC module.

| Requested check | Restoration project | Closest verified evidence; remaining distinction |
| --- | --- | --- |
| Learn all classes | PENDING_EXTERNAL_SOURCE | CoA talent/progression ClassId checks prevent that inference |
| Spell catalog | PENDING_EXTERNAL_SOURCE | CoA has generated class/spec/native-ID catalogs |
| Native ranks/upgrades | PENDING_EXTERNAL_SOURCE | CoA has root-owned, level-gated ranks |
| Spell prerequisites | PENDING_EXTERNAL_SOURCE | CoA automatic grant dependencies are a bounded subset |
| Class restriction bypass | PENDING_EXTERNAL_SOURCE | CoA fallbacks are scoped; classless ID is a shell |
| Skills/weapons/forms | PENDING_EXTERNAL_SOURCE | CoA proficiency tables and native checks remain |
| Active/passive distinction | PENDING_EXTERNAL_SOURCE | Native spell/aura behavior; no universal entitlement type |
| All-class talents | PENDING_EXTERNAL_SOURCE | CoA local purchase path rejects a different class |
| Player::LearnTalent usage | PENDING_EXTERNAL_SOURCE | CoA command directly learns native SpellIDs |
| Passive rank SpellIDs | PENDING_EXTERNAL_SOURCE | CoA uses catalog native rank spells, not generalized rules |
| TalentTab mask bypass | PENDING_EXTERNAL_SOURCE | CoA avoids LearnTalent but imposes its own class/spec gates |
| Talent prerequisites/tiers | PENDING_EXTERNAL_SOURCE | Automatic dependencies do not prove full paid-tree rules |
| Point budgets | PENDING_EXTERNAL_SOURCE | AE/TE metadata without complete debit in inspected command |
| Free Pick selection flow | PENDING_EXTERNAL_SOURCE | Original UI references; no verified server purchase flow |
| Currencies/points | PENDING_EXTERNAL_SOURCE | No reusable atomic cross-class budget service verified |
| Learn/unlearn/respec | PENDING_EXTERNAL_SOURCE | CoA native rank removal/spec sync is not universal respec |
| Rank progression | PENDING_EXTERNAL_SOURCE | CoA class-bound rank logic is a reference |
| Server validation | PENDING_EXTERNAL_SOURCE | Local command validation is insufficient for paid builds |
| Roll generation | PENDING_EXTERNAL_SOURCE | UI events do not reveal server pools or weighting |
| Rerolls | PENDING_EXTERNAL_SOURCE | Dice/rapid-roll events do not reveal server debit rules |
| Locks | PENDING_EXTERNAL_SOURCE | No inspected restoration lock authority |
| Deterministic/server RNG | PENDING_EXTERNAL_SOURCE | Combat proc RNG does not establish draft RNG |
| Acquisition ownership | PENDING_EXTERNAL_SOURCE | Native known spell state does not prove entitlement source |
| Persistence | PENDING_EXTERNAL_SOURCE | No restoration roll/choice transaction source |
| Duplicate protection | PENDING_EXTERNAL_SOURCE | No verified draft deduplication implementation |
| Draft rank upgrades | PENDING_EXTERNAL_SOURCE | No verified roll-to-rank upgrade policy |
| Talent and ability rolls | PENDING_EXTERNAL_SOURCE | Client labels/events do not prove either server path |
| Mana/Rage/Energy | PENDING_EXTERNAL_SOURCE | Native core exists; universal coexistence unverified |
| Runic Power/Runes | PENDING_EXTERNAL_SOURCE | Native mechanics exist; cross-class policy unverified |
| Combo Points | PENDING_EXTERNAL_SOURCE | Native target-bound mechanic; universal adapter unverified |
| Forms/stances | PENDING_EXTERNAL_SOURCE | Class-specific CoA behavior is not broad classless support |
| Pet support | PENDING_EXTERNAL_SOURCE | CoA/native pet scripts do not prove cross-class pet ownership |
| Addon/UI | PENDING_EXTERNAL_SOURCE | Extracted original UI; no matched restoration addon revision |
| MPQ/DBC/assets | PENDING_EXTERNAL_SOURCE | No matching restoration client package established |
| Protocol | PENDING_EXTERNAL_SOURCE | Original C_ APIs require a matched client/server implementation |
| Server module/core edits | PENDING_EXTERNAL_SOURCE | No source on which to count or classify edits |
| Hooks/PlayerScript | PENDING_EXTERNAL_SOURCE | CoA hooks are verified separately, not this project |
| Database | PENDING_EXTERNAL_SOURCE | No restoration schema/migration inspected |
| Validation/security assumptions | PENDING_EXTERNAL_SOURCE | No restoration authority or replay model inspected |

## Separation of ownership and semantics

| Layer | Authoritative responsibility | CoA/classless reuse boundary |
| --- | --- | --- |
| CLASSLESS | Which abilities and talents the player owns | Catalogs, grants, ranks and acquisition adapters |
| ULDuar ABILITIES | Ability structure and execution | Retain taxonomy, effect metadata and resolvers |
| ABILITY GEMS | Customization of an individual ability | Retain gems, hybrid compatibility and conversions |
| GENERALIZED TALENTS | Global semantic build rules | Retain shared selector/compiler and ACTIVE/DORMANT model |
| KEYSTONE | Fundamental character rule changes | Retain structural validation and deterministic snapshots |

Learning Improved Fireball's native passive SpellID still changes the native family/mask behavior.
A Ulduar rule such as selector Fire + CastTime with a CastSpeed modifier requires semantic interpretation,
effect scoping, unit conversion, capability validation and deterministic resolution.
Neither the CoA native talent catalog nor classless access alone performs that conversion.
The old 2,358 source-rank inventory remains a separate review workload.

No inspected component demonstrates an equivalent abstraction that warrants replacing the protected Ulduar layers.
References to useful runtime mechanisms in this audit authorize no runtime replacement.

## Pinned source map

Symbols and relative paths are stable audit anchors; line numbers are approximate within the pinned revision.
Long paths are grouped beneath their pinned source directory to keep the document readable.

- [Module sources][sources]: AscensionCompat.cpp, AscensionHealingStatSelectors.cpp,
  AscensionConditionalCombat.cpp, AscensionCustomResourceData.h and AscensionSpellProgressionData.h.
- [Module SQL][sql]: db-world custom classes and db-characters appearance/vanity collections.
- [Core spell sources][spell-dir]: Spell.cpp, Spell.h, SpellEffects.cpp, SpellInfo.cpp/.h and SpellChargeState.h.
- [Player integration][player]: learnSpell, charge settings, resource defaults and spell-modifier packets.
- [Class policy][resource-dir]: LiveClassResourcePolicy.h.
- [Client compatibility][client], [world bootstrap][world] and [repository organization][organization].

[repo]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa
[base]:
  https://github.com/azerothcore/azerothcore-wotlk/commit/084c9e2bf1167
[tip]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/commit/feb155c82c75
[module]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/modules/mod-ascension-compat/README.md
[config]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/conf
[sources]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/src
[compat]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/src
[talents]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/src
[taught]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/src
[replacements]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/src
[sql]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/data/sql
[spell-dir]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/src/server/game/Spells
[spell]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/src/server/game/Spells/Spell.cpp
[effects]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/src/server/game/Spells/SpellEffects.cpp
[charges]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/src/server/game/Spells/SpellChargeState.h
[player]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/src/server/game/Entities/Player/Player.cpp
[resource-dir]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/src/server/game/Entities/Player
[socket]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/src/server/game/Server
[client]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/apps/client-compat
[dbc]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/apps/coa-spells
[world]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/apps/coa-world
[organization]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/docs/repository-organization.md
