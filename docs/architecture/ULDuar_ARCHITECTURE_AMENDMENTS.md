# Ulduar architecture amendments

Date: 2026-09-15. Applies to the proposed Ability Forge direction.
This document explicitly amends design assumptions; it does not edit or invalidate existing runtime behavior.
All fourteen prior documents remain unchanged.

Status vocabulary:
CONFIRMS retains a contract; AMENDS narrows/changes it; OBSOLETE replaces a specific assumption;
ADDS creates a new requirement. A status never declares an entire document obsolete by implication.

## Prior contract index

| ID | Existing document |
| --- | --- |
| D01 | [Spell Taxonomy](ULDuar_SPELL_TAXONOMY.md) |
| D02 | [Ability Metadata](ULDuar_ABILITY_METADATA.md) |
| D03 | [Generic Stats](ULDuar_GENERIC_STATS.md) |
| D04 | [Gem Compatibility](ULDuar_GEM_COMPATIBILITY.md) |
| D05 | [Generalized Talents](ULDuar_GENERALIZED_TALENTS.md) |
| D06 | [Universal Talent Library](ULDuar_UNIVERSAL_TALENT_LIBRARY.md) |
| D07 | [Talent Conversion Pipeline](ULDuar_TALENT_CONVERSION_PIPELINE.md) |
| D08 | [Classless Architecture](ULDuar_CLASSLESS_ARCHITECTURE.md) |
| D09 | [Resolution Pipeline](ULDuar_RESOLUTION_PIPELINE.md) |
| D10 | [Gap Analysis](ULDuar_GAP_ANALYSIS.md) |
| D11 | [Ascension Classless Base Audit](ASCENSION_CLASSLESS_BASE_AUDIT.md) |
| D12 | [Classless Base Comparison](CLASSLESS_BASE_COMPARISON.md) |
| D13 | [Classless Port Matrix](CLASSLESS_PORT_MATRIX.md) |
| D14 | [Updated Roadmap](ULDuar_UPDATED_ROADMAP.md) |

## Old assumption to new decision

The two matrices join by amendment ID and provide old assumption, new decision, why, affected documents,
implementation impact and explicit status. "Old" refers to the particular prior model or unresolved item,
not to all content in the referenced document.

| ID / status | Old assumption |
| --- | --- |
| A01 CONFIRMS | Current AC plus Ulduar runtime is the base |
| A02 CONFIRMS | Taxonomy axes are independent of class |
| A03 AMENDS | Stable ability definition commonly maps a native spell chain |
| A04 OBSOLETE | Native/root ability identity can key owned custom ability |
| A05 CONFIRMS | Potency/Coverage and generic rules own derived values |
| A06 AMENDS | Gem compatibility targets an ability definition/build |
| A07 CONFIRMS | Generalized talents select semantic properties |
| A08 AMENDS | Broad native conversion library precedes expanded acquisition |
| A09 AMENDS | Classless acquisition centers native grants |
| A10 ADDS | No primary Core creation entitlement loop |
| A11 ADDS | Definition/rank identifiers describe execution inputs |
| A12 CONFIRMS | Deterministic immutable cast/event/hit snapshots |
| A13 AMENDS | Classless eligibility work is broad |
| A14 ADDS | Mechanic grant provenance not fully implemented |
| A15 ADDS | Native pools and display need compatibility work |
| A16 AMENDS | Eight packages ordered around acquisition modes |
| A17 OBSOLETE | Full native Free Pick is launch foundation |
| A18 OBSOLETE | Native-spell Wildcard is target randomized progression |
| A19 AMENDS | Class acquisition tabs are universal library's front door |
| A20 AMENDS | Exact classless repository was unavailable/pending |
| A21 CONFIRMS | CoA is unsuitable as the gameplay base |
| A22 AMENDS | Cosmetic collections outside earlier audit scope |
| A23 ADDS | Archetype may refer to native/class build grouping |
| A24 ADDS | Slot/Core/socket progression not separated explicitly |
| A25 AMENDS | Addon protocol and generated data require matching |
| A26 CONFIRMS | Preserve EP and existing customization |
| A27 ADDS | New instance system has no explicit legacy bridge |
| A28 CONFIRMS | Native safety remains active for custom execution |
| A29 ADDS | Experiment/install scope could be conflated with audit |

Additional fields for the same entries:

| ID / status | New decision |
| --- | --- |
| A01 CONFIRMS | Retain current base and local work |
| A02 CONFIRMS | Keep semantic taxonomy as authority |
| A03 AMENDS | Template can create many owned instances |
| A04 OBSOLETE | Forge ownership key is stable instance ID |
| A05 CONFIRMS | Preserve resolver authority and units |
| A06 AMENDS | Validate each versioned owned instance |
| A07 CONFIRMS | Native cross-class talents are not a substitute |
| A08 AMENDS | Prioritize reviewed semantic subset after Forge |
| A09 AMENDS | Progression owns Core/instance/component entitlements |
| A10 ADDS | New profile starts zero instances plus one Core |
| A11 ADDS | Native carrier dispatch must resolve an owned instance |
| A12 CONFIRMS | Include instance/content revision; preserve snapshot semantics |
| A13 AMENDS | Start minimal Mana/carrier needs; expand by capability |
| A14 ADDS | Explicit multi-source MechanicEntitlementService |
| A15 ADDS | ResourceService separates cost, amount and UI choice |
| A16 AMENDS | Forge phases A-D first; minimal gem inside D |
| A17 OBSOLETE | Optional component provider after core loop |
| A18 OBSOLETE | Optional durable component draft |
| A19 AMENDS | Purpose/method Forge and semantic collections |
| A20 AMENDS | Exact DustinHendrickson source now inspected |
| A21 CONFIRMS | Keep gameplay exclusion |
| A22 AMENDS | QoL-only reference inventory now requested |
| A23 ADDS | Semantic discovery does not replace instance ownership |
| A24 ADDS | Three independently owned/unlocked objects |
| A25 AMENDS | Enforced content manifest, revisions and receipts |
| A26 CONFIRMS | No silent currency/character conversion |
| A27 ADDS | Legacy view/provenance migration is separate and reversible |
| A28 CONFIRMS | No global class/CheckCast/SpellInfo bypass |
| A29 ADDS | Dedicated disposable later experiment only |

| ID | Why | Affected docs |
| --- | --- | --- |
| A01 | Existing work already supplies semantic execution | D10-D14 |
| A02 | Emergent abilities cannot depend on original class | D01-D02 |
| A03 | Same template can produce multiple player abilities | D01-D02,D08 |
| A04 | Reforging must preserve ownership identity | D02,D08,D13-D14 |
| A05 | External Hero stat policy solves a different game | D03,D09 |
| A06 | Local gems mutate one persistent owned object | D04,D09 |
| A07 | Family masks still restrict native talent effects | D05-D07,D11 |
| A08 | All 2,358 source ranks are not launch blockers | D06-D07,D14 |
| A09 | Native learnSpell is projection, not acquisition | D08,D12-D14 |
| A10 | User explicitly changed onboarding/game loop | D08,D14 |
| A11 | Native cast packet only contains SpellID identity | D02,D08-D10 |
| A12 | Delayed effects must retain cast composition | D09 |
| A13 | Advanced mechanics are not needed by first slice | D08,D10,D14 |
| A14 | External one-source enum loses overlapping grants | D08,D10,D13 |
| A15 | Class resource policy cannot author Energy-to-Health | D01-D03,D08 |
| A16 | First game proof must include visible gem mutation | D14 |
| A17 | Buying Frostbolt is not the new onboarding | D08,D12-D14 |
| A18 | External roll engine is native-ID coupled | D08,D12-D14 |
| A19 | Player chooses behavior, not original class | D08,D14 |
| A20 | Reference cloned outside modules and pinned | D11-D13 |
| A21 | CoA remains a custom-class restoration | D11-D14 |
| A22 | Scope expanded to Classic-style modernization | D11,D13 |
| A23 | Pattern recognition is collection metadata | D01-D02,D08 |
| A24 | Active capacity is not ability/gem ownership | D08,D14 |
| A25 | Upstream version stamps are not enforcement | D08-D10,D13 |
| A26 | EP data is already meaningful saved progress | D03,D08-D10 |
| A27 | Unknown native sources cannot be safely stripped | D08,D10,D14 |
| A28 | Broad bypasses break unrelated native behavior | D01,D09-D13 |
| A29 | Source inspection provides no runtime guarantee | D11-D14 |

Additional fields for the same entries:

| ID | Implementation impact |
| --- | --- |
| A01 | No base switch or source replacement |
| A02 | OriginClass stays provenance |
| A03 | Separate definition, instance and carrier |
| A04 | Remove owner+root uniqueness for Forge |
| A05 | No imported AGI/INT stat rewrite |
| A06 | Validate sockets and instance revision |
| A07 | Semantic compiler; one executor per effect |
| A08 | Keep inventory; stage conversion workload |
| A09 | Seven ownership types and durable source ledger |
| A10 | One-time Core receipt and Forge tutorial |
| A11 | Unique active carrier mapping and secure button |
| A12 | Add identity to snapshots, not live mutable reads |
| A13 | Smaller first compatibility phase |
| A14 | Source graph and idempotent projection |
| A15 | Native adapters; explicit spend ownership |
| A16 | Move minimal socket/collection ahead of expansion |
| A17 | Remove full native shop from launch scope |
| A18 | Persist offer/acceptance, roll components |
| A19 | New UI on existing Ulduar transport contracts |
| A20 | New matrix replaces pending status for this repo only |
| A21 | No 21-class/world/native-client migration |
| A22 | Separate QoL candidates and missing-evidence labels |
| A23 | Discovery predicates and optional visuals |
| A24 | Versioned unlock policy, no fixed level schedule |
| A25 | Protocol/content negotiation and fail-safe mismatch |
| A26 | LegacyCustomization adapter; no reset/refund inference |
| A27 | Explicit migration plan before old profiles opt in |
| A28 | Capability-scoped adapters and reviewed carriers |
| A29 | Fresh DB/client/config/build for later experiments |

## Precedence and non-changes

For the new primary gameplay direction, apply Forge/Progression/V2 roadmap decisions to the specific
assumptions listed above. Retain all unaffected prior contracts.
Existing implemented behavior is not silently relabeled as already conforming to the new design.
No old document, source file, SQL migration, client file or saved character data is changed by these amendments.

The old external-source pending entries are historical facts about the previous audit.
This audit resolves that gap only for mod-classless-wildcard at the pinned commit, not for other unnamed modules.
The new port matrix is not a claim that all earlier Ulduar runtime gaps are solved.
The CoA audit's gameplay conclusions remain; its collections exclusion was scoped to the prior task.

## New authority map

- [Ability Forge](ULDuar_ABILITY_FORGE_ARCHITECTURE.md): stable instances, semantic structure and native mapping.
- [Progression](ULDuar_PROGRESSION_ARCHITECTURE.md): ownership, transactions, slots/sockets and optional modes.
- [Experiment Audit](CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md): observed external code, SQL and risk evidence.
- [Portability](CLASSLESS_WILDCARD_PORTABILITY.md): evidence-backed classifications and eight-package changes.
- [QoL](ULDuar_QOL_REFERENCE_AUDIT.md): independent CoA concepts with explicit evidence limitations.
- [Experiment Plan](ULDuar_EXPERIMENT_PLAN.md): future isolated work, never a claim of tests run.
- [Roadmap V2](ULDuar_GAMEPLAY_ROADMAP_V2.md): new implementation order and request coverage.
- [Slice 1](ULDuar_VERTICAL_SLICE_V1.md): exact initial gameplay acceptance.

## Preservation record

The audit began with a SHA256 baseline over 126 existing architecture, Ulduar module, client,
pending custom SQL and modified core files. That baseline is used only for read-only preservation checks.
This task adds nine architecture documents and a separate reference clone.
No compilation, CMake configuration, SQL execution, client patch execution, external installation,
runtime implementation or character migration belongs to this change.

Final documentation verification, 2026-09-16: all 126 baseline files retain their original SHA256.
All nine new documents pass UTF-8/LF, line-length, local-link and Markdown-reference checks.
The SQL appendix covers all 25 inspected SQL files and all 39 distinct direct mutation table names,
including temporary, legacy uninstall and updater tables. No runtime experiment was executed.
