# Ulduar gameplay roadmap V2

Date: 2026-09-15. Documentation-only decision set.
Current AzerothCore and existing Ulduar Abilities remain the base.
Primary loop: create an owned ability in Forge, use it, acquire a Gem and evolve the same instance.

## Decision and first implementation phase

**CLASSLESS_WILDCARD_DECISION: REFERENCE_ONLY.**
Do not adopt the module or fork as the gameplay base.
A possible future extraction of one action-button helper is not a decision to import the whole system.
See [audit](CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md) and
[portability](CLASSLESS_WILDCARD_PORTABILITY.md).

**First implementation phase: Phase A, instance composition and carrier feasibility contracts.**
The next bounded implementation should add the minimum versioned template/instance input contract,
pure resolution/compatibility boundary and explicit native carrier mapping design for the four Slice 1 profiles,
using existing Ulduar metadata and runtime adapters.
It must prove that a native SpellID can resolve unambiguously to one owned instance and that each profile's
client/server target, cost, activation and delivery constraints are satisfiable.
No ownership schema or UI purchase path should promise a profile whose carrier contract is unknown.
This phase is proposed for later authorization; the current task creates documentation only.

## Revised dependency order

| Phase | Scope | Exit condition |
| --- | --- | --- |
| A | Metadata/effect graph minimum; instance composition and carrier feasibility | Four profiles + one gem validate |
| B | Minimal classless compatibility: Mana, target/range and native grant projection | Safe unambiguous carrier cast |
| C | Core/instance/slot ownership, receipts, source grants and outbox | Durable idempotent create/reconcile |
| D | Forge tutorial and playable slice, including one socket and one gem | Full Slice 1 acceptance |
| E | Broader Gem collection, sockets, compatibility and additional slots | No ambiguous carriers or lost sources |
| F | First reviewed generalized talents | Semantic effects apply exactly once |
| G | Archetype discovery and collection | Semantic matches preserve instance identity |
| H | Advanced resources/mechanics: forms, pets, runes, combo points | Per-capability lifecycle acceptance |
| I | Optional Free Pick component acquisition | Common transactions; no native ownership takeover |
| J | Optional Wildcard Component Draft | Durable offers, rerolls, acceptance and reconnect |
| K | Independent QoL expansion | No dependency on foreign gameplay/client baseline |

Challenge to the earlier candidate order:
Phase D must include a minimal GemOwnership/socket path; otherwise it does not prove the actual game loop.
Phase E broadens that path rather than introducing the first gem.
Phase B is deliberately limited to Slice 1 capabilities. All resources/forms/pets before Forge would delay
the core game without proving instance identity. Phase A includes carrier dispatch feasibility early because
native cast packets cannot distinguish multiple instances sharing a SpellID.
QoL necessary for the slice (clear tooltips and stable buttons) ships within D; K is optional expansion.

A successful external sandbox is evidence for advanced compatibility decisions, not a prerequisite to writing
the semantic/ownership contracts or a reason to adopt external runtime code.

## Keep, defer, reduce, remove and replace

| Earlier work | Decision | Why / replacement |
| --- | --- | --- |
| Taxonomy and effect graph | KEEP | Independent axes support emergent player abilities |
| Potency/Coverage and deterministic snapshots | KEEP | Shared preview/runtime authority |
| Existing delivery/heal/weapon/native safety | KEEP | Existing investment remains execution foundation |
| EP/customization and character saves | KEEP | Legacy adapter and explicit later migration only |
| Source-counted grants and durable transactions | KEEP | Forge requires them immediately |
| Full native spell purchasing catalog | DEFER | Optional provider, not primary progression |
| Full Free Pick at launch | REMOVE from launch scope | Forge creation replaces onboarding purchase |
| All native talent purchasing | REPLACE as main design | Reviewed generalized semantic talents |
| Native-spell Wildcard rolls | REPLACE as target mode | Optional component offers |
| Class-based acquisition tabs as main UI | REPLACE | Purpose/method Forge and semantic collections |
| Native root SpellID as owned ability key | REMOVE for Forge | Stable AbilityInstance ID |
| Universal rank engine covering all spells before launch | REDUCE | Reviewed carrier projection first |
| All resources/forms/pets before ownership | DEFER | Add when a supported profile requires them |
| Source talent conversion inventory | KEEP, prioritize subset | Existing 2,358 rank reviews remain reference backlog |
| CoA gameplay base migration | REMOVE from consideration | QoL ideas only; no class/world adoption |
| Hero identity and class/stat/gear rewrite | REMOVE from target | Internal chassis with scoped mechanics |
| Archetype as automated native build purchase | REPLACE | Semantic discovery, optional visuals |

"REMOVE" removes an assumption or launch work item, not an existing file or saved character feature.
No architecture document or runtime system was deleted.

## First playable result

New Forge profile -> one Core -> Damage/Healing -> Melee/Ranged -> one persistent instance ->
native spellbook/action button -> safe cast -> one Impact Gem -> visible secondary impact ->
logout/login preserves state -> remove/reinstall gem deterministically.
Four reviewed profiles, one active slot, one socket, one compatible gem; no talents/drafts/advanced resources needed.
Exact scope and unsupported features are in [Vertical Slice V1](ULDuar_VERTICAL_SLICE_V1.md).

## Blockers and open evidence

- Four reviewed native carrier contracts, including contact-range healing and melee Mana cost.
- Explicit mapping/collision policy for a carrier already independently owned as a native/legacy spell.
- Existing Ulduar API integration points for profile/instance validation without changing native safety.
- Durable schema and transaction/outbox implementation; no such service is supplied by the reference.
- Full lifecycle proof for rune initialization, pet restoration and reactive/combo interactions before Phase H.
- Client feasibility for each enabled activation/cost/range/visual; generated data and addon hash contract.
- Exact provenance and per-file license compatibility before any future code/asset extraction.
- Legacy grant provenance and EP migration mapping before enabling Forge migration for existing characters.
- Missing published CoA canonical UI/assets prevent claiming whole-client QoL portability.

These are future implementation/experiment gates. They do not prevent completing this documentation audit.
No evidence was invented to close them.

## Document index

| Document | Purpose |
| --- | --- |
| [Experiment Audit](CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md) | Source findings, server/client/SQL, resources and risks |
| [Portability](CLASSLESS_WILDCARD_PORTABILITY.md) | Narrow extraction decisions and eight-package reassessment |
| [Ability Forge](ULDuar_ABILITY_FORGE_ARCHITECTURE.md) | Semantic instance architecture and native projection |
| [Progression](ULDuar_PROGRESSION_ARCHITECTURE.md) | Seven ownership types, transactions, slots and optional modes |
| [QoL Reference](ULDuar_QOL_REFERENCE_AUDIT.md) | CoA evidence and independent modernization ideas |
| [Experiment Plan](ULDuar_EXPERIMENT_PLAN.md) | Isolated future tests; none executed |
| [Gameplay Roadmap V2](ULDuar_GAMEPLAY_ROADMAP_V2.md) | Dependency order and dead work |
| [Vertical Slice V1](ULDuar_VERTICAL_SLICE_V1.md) | Exact initial player loop and acceptance |
| [Architecture Amendments](ULDuar_ARCHITECTURE_AMENDMENTS.md) | Explicit changes to the fourteen prior contracts |

## Request coverage map

The numbers refer to sections of the user's experimental reference audit request.

| Request sections | Primary document |
| --- | --- |
| 0 prior contracts | Architecture Amendments, Audit scope |
| 1-2 new gameplay and authority | Ability Forge |
| 3 classification | Portability |
| 4 experimental warnings | Audit experimental status and risk register |
| 5 server structure | Audit server source map |
| 6 Hero foundation | Audit foundation/restrictions |
| 7 resources | Audit eleven-dimension resource tables and service proposal |
| 8-9 mechanics and kits | Audit mechanic lifecycle and service proposal |
| 10 ranks/spellbook | Audit native ranks; Forge carrier contract |
| 11 Free Pick | Audit acquisition path; Progression optional provider |
| 12 Wildcard | Audit roll semantics; Progression component offers |
| 13 talents | Audit native-family distinction; Forge semantic pipeline |
| 14 client patch | Audit client inventory |
| 15 version contract | Ability Forge content manifest |
| 16 every SQL table | Audit SQL inventory and script appendix |
| 17 testability | Experiment Plan |
| 18-21 Forge/ownership/slots/archetypes | Ability Forge and Progression |
| 22 CoA QoL | QoL Reference Audit |
| 23 eight packages | Portability package reassessment |
| 24 dead work | This roadmap Keep/Defer/Reduce/Remove/Replace table |
| 25 module boundaries | Ability Forge service/dependency direction |
| 26 portability matrix | Portability |
| 27 risk matrix | Audit EXPERIMENT_RISK_REGISTER |
| 28 new order | This roadmap phases |
| 29 vertical slice | Vertical Slice V1 |
| 30 outputs / amendments | Nine documents and Architecture Amendments |
| 31 final decision fields | Report below and final response |
| 32 hard rules | Scope/preservation checks across all documents |

## Final decision record

| Required field | Decision |
| --- | --- |
| CLASSLESS_WILDCARD_DECISION | REFERENCE_ONLY |
| ABILITY_FORGE_IMPACT | Native buying/rolls leave launch; SpellID ownership replaced by stable instances |
| REUSABLE_COMPONENTS | Narrow missing-action recovery candidate; contextual/resource lifecycle concepts |
| REIMPLEMENT_COMPONENTS | Ownership, transactions, resources/mechanics, component draft and Forge UI |
| DO_NOT_IMPORT | Hero conversion, world SQL, stat rewrite, native family authority, installer/EXE changes |
| COA_QOL_CANDIDATES | Independent collection/search, cosmetic/journal concepts, charge arithmetic/display |
| FIRST_IMPLEMENTATION_PHASE | A: instance composition, semantic validation and carrier feasibility |
| FIRST_VERTICAL_SLICE | Four creation profiles; one instance/slot/socket/gem; cast, mutate, relog, restore |
| BLOCKERS | Carrier contracts, durable ownership, advanced mechanic proof, client/provenance gaps |
| EXPERIMENTS_REQUIRED | Isolated native resources/pets/ranks, failure/security, client and Forge lifecycle |

Validation in this phase is limited to documentation completeness, source correspondence and file preservation.
There are no build, SQL, patcher or runtime test results.
