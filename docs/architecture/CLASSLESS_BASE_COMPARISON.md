# Classless base comparison

Decision date: 2026-09-14. Documentation-only assessment.
Evidence: [pinned Ascension/CoA audit](ASCENSION_CLASSLESS_BASE_AUDIT.md).
All 39 unresolved prior gap rows are extended in the [port matrix](CLASSLESS_PORT_MATRIX.md).

## Decision

**KEEP_CURRENT_BASE**: keep the current AzerothCore checkout and build an independent
`mod-ulduar-classless` behind the contracts in [Classless architecture](ULDuar_CLASSLESS_ARCHITECTURE.md).

CoA has useful restoration mechanisms, but the inspected source does not supply the missing universal purchase
authority, safe point ledger or Wildcard backend. Moving the existing ability implementation to that fork would
also require reconciling its custom spell effects, combat semantics, character classes, DB baseline and client.
The alternative Free Pick/Wildcard restoration project remains PENDING_EXTERNAL_SOURCE.
Its missing source prevents a justified decision to port it or migrate to its distribution.

This recommendation permits future evidence to change the acquisition implementation.
It does not select an external code port now. Studying source patterns is not the same as adopting a hybrid runtime.

## Architectures considered

| Key | Architecture | Evidence and scope |
| --- | --- | --- |
| A | CURRENT AC + BUILD ULDuar CLASSLESS | Existing Ulduar inspected; new ownership layer required |
| B | CURRENT AC + PORT FREE PICK/WILDCARD MODULE | PENDING_EXTERNAL_SOURCE; no exact module source available |
| C | FORK CLASSLESS AC DISTRIBUTION | No verified distribution with the required backend identified |
| COA | FORK COA | Pinned public source; custom-class restoration, not complete classless backend |
| D | OTHER HYBRID | Current AC plus selective CoA/native acquisition adapters and prior references |

Astoria is already assessed in [ASTORIA_CLASSLESS_AUDIT.md](ASTORIA_CLASSLESS_AUDIT.md).
Its catalog/UI concepts do not supply the missing authoritative transaction implementation.
It is a reference within D, not assumed to be the unavailable Free Pick/Wildcard project.

A and D keep the same base. A owns the new implementation and may use documented lessons.
D means committing to external component imports and maintaining adapter compatibility.
Until the extraction benefit is demonstrated, that extra obligation has no verified time advantage.

## Scoring method

Scores are 1-5, with 5 favorable: low risk/complexity, high compatibility/completeness, or less development work.
These are engineering estimates, not runtime benchmarks or measured calendar durations.
Maintainability and existing Ulduar compatibility each receive weight 5; generalized talents and gems receive 4.
Feature completeness means the required authoritative classless flow, not quantity of native custom content.

For B/C, `1*` is the conservative evidence floor of an unknown 1-5 interval, not a quality judgment.
Their floor totals cannot be ranked against verified alternatives; both are ineligible until source is audited.
Giving unknown projects invented midpoint scores would imply evidence that does not exist.

| Criterion | Weight | A | B | C | COA | D |
| --- | --- | --- | --- | --- | --- | --- |
| Development time | 2 | 3 | 1* | 1* | 2 | 3 |
| Upstream maintainability | 5 | 5 | 1* | 1* | 2 | 4 |
| Current Ulduar compatibility | 5 | 5 | 1* | 1* | 2 | 4 |
| Core conflict risk | 3 | 5 | 1* | 1* | 1 | 4 |
| Client complexity | 2 | 5 | 1* | 1* | 1 | 4 |
| Free Pick completeness | 2 | 1 | 1* | 1* | 1 | 1 |
| Wildcard completeness | 2 | 1 | 1* | 1* | 1 | 1 |
| Talent flexibility | 3 | 5 | 1* | 1* | 3 | 5 |
| Ability flexibility | 3 | 5 | 1* | 1* | 4 | 5 |
| Generalized talent compatibility | 4 | 5 | 1* | 1* | 2 | 5 |
| Gem-system compatibility | 4 | 5 | 1* | 1* | 2 | 5 |
| Future custom content | 2 | 5 | 1* | 1* | 4 | 5 |
| Debugging complexity | 2 | 4 | 1* | 1* | 1 | 3 |
| Migration risk | 3 | 5 | 1* | 1* | 1 | 4 |

- A: 188/210, weighted mean 4.48/5.
- B: 42/210, weighted mean 1.00/5 at the evidence floor; possible interval 1.00-5.00, NOT RANKABLE.
- C: 42/210, weighted mean 1.00/5 at the evidence floor; possible interval 1.00-5.00, NOT RANKABLE.
- COA: 83/210, weighted mean 1.98/5.
- D: 168/210, weighted mean 4.00/5.

Formula: sum(weight x score) / sum(weight). Total weight is 42.
Among assessable alternatives, A ranks first, D second and COA third.
Changing scores cannot make a missing source or absent matched client reproducible.

### Reasons for the scores

- A receives 3 for development time because the acquisition service must be built, while existing ranks,
  customization, execution and addon infrastructure remain usable. Its maintainability and compatibility scores
  reflect avoiding a new fork dependency; they do not mean the current five core patches need no upkeep.
- A's Free Pick and Wildcard completeness scores are 1 because neither flow is implemented.
  Talent/ability flexibility scores measure freedom to satisfy Ulduar's defined contracts, not completed features.
  The semantic rule engine and gem catalog remain missing work.
- COA also receives 1 for the required Free Pick/Wildcard backend: its catalog and local command do not provide
  complete universal budgets, respec transactions or draft persistence. A large native talent catalog alone
  does not raise these completeness scores.
- COA's 4 for ability flexibility/future custom content credits real custom native spell/class infrastructure.
  Its 2 for generalized talents and gems reflects adaptation cost, not a proven equivalent abstraction.
  Scores of 1 for client, core conflicts and migration reflect overlapping runtime changes plus external client data.
- D keeps Ulduar's semantic design flexibility but adds integration and maintenance obligations.
  It receives no completeness bonus for importing partial acquisition mechanisms.
  Its 3 for development time assumes small adapters; it is not a claim that a full module port is cheap.
- B and C have no independently verified ranks, transactions, roll logic, client requirements or core delta.
  No authoritative completeness or maintenance score can be assigned beyond the explicit unknown interval.

A and D both score 1 for the two missing game modes, so increasing only those feature weights does not make
D cheaper or more complete. D would need evidence of an actual portable backend or measured avoided implementation.
A verified B could change the result materially; it must first pass the source and authority checks below.

## Capability comparison

| Required result | Current Ulduar | CoA snapshot | Consequence |
| --- | --- | --- | --- |
| Universal spell ownership | Missing; class gate remains | Class-bound progression | New classless authority |
| Universal native talent access | Missing | Native-ID access within class/spec | Adaptation, not universal |
| Generalized talent semantics | Proposed, not implemented | Exact-ID/family/scripts | Ulduar compiler still required |
| Paid point budgets | Existing ability EP only | AE/TE fields; incomplete command debit | Separate acquisition ledger |
| Rank progression | Native chains and separate custom rank/EP | Class/level/root catalog | Preserve native adapter |
| Generic prerequisites | Proposed | Partial automatic dependencies | New graph and cascade policy |
| Grant ownership | Proposed | Temporary taught grants and replacements | New durable source ledger |
| Persistence | Ability row state; native spells | Settings, native spells, collections | New atomic build/outbox |
| Universal talent browsing | Proposed library | Client-coupled custom class talent data | Extend Ulduar addon |
| Large catalog transport | Missing in Protocol2 | Generated local data/custom APIs | Versioned paging/cache |
| Free Pick | Missing | No complete verified backend | Implement on ownership service |
| Wildcard/Wild Draft | Missing | No verified draft backend | Separate durable draft state |
| Respec | Ability customization mechanisms only | Native spec switch/remove/sync | Atomic entitlement refunds |
| Spellbook integration | Native known-rank mapping | Temporary replacements | Validate mixed grant/rank cases |
| Client/DBC content | Existing addon/native data | Native v4 plus matching custom data | Avoid migration dependency |
| Universal resources/pets/forms | Native mechanics/partial adapters | Custom class mechanics | Eligibility adapters |

The missing restoration source is UNKNOWN for every row. The audit lists its requested checks individually;
CoA's behavior must not be attributed to that separate project.

## Does changing bases reduce total work?

There is no evidence that it does for the requested Ulduar design.

A requires catalog/entitlement authority, budgets and prerequisites, persistence and reconciliation, native grant
compatibility, Free Pick/respec, later Wildcard, mechanic eligibility, and catalog UI/protocol.
CoA still requires those Ulduar-specific ownership contracts. Moving to CoA adds a second work package:
five overlapping core files, broader Player/SpellInfo changes, custom IDs and DB content,
custom client reproduction, module-hook compatibility and regression assessment for existing game modules.

The costly conflicts are semantic: damage can scale twice; school identity can split between Spell and SpellInfo;
native learned auras can apply alongside generalized rules; temporary removal can revoke another entitlement;
and a client can show a different rank or cooldown state from the server.
A clean textual merge would not establish correctness in any of those cases.

Bringing in a future verified classless subsystem could be cheaper than migration if it stays behind the ownership
contract and leaves existing runtime hooks intact. That claim is conditional on inspecting the actual module.
The current evidence supports neither importing CoA wholesale nor treating its local talent command as that subsystem.

## Scope that candidates cannot replace

The following existing design contracts remain authoritative:
[spell taxonomy](ULDuar_SPELL_TAXONOMY.md), [effect metadata](ULDuar_ABILITY_METADATA.md),
[generic stats/resolvers](ULDuar_GENERIC_STATS.md), [gem compatibility](ULDuar_GEM_COMPATIBILITY.md),
[generalized talents](ULDuar_GENERALIZED_TALENTS.md), [talent library](ULDuar_UNIVERSAL_TALENT_LIBRARY.md),
[conversion pipeline](ULDuar_TALENT_CONVERSION_PIPELINE.md) and
[deterministic resolution](ULDuar_RESOLUTION_PIPELINE.md).

No inspected candidate proves equivalent effect selectors, Geometry/CoverageResolver, PotencyResolver,
typed conversions, hybrid gems, global generalized talent rules or structural keystones.
Native classless talent access solves acquisition only.
Native spell snapshots and damage flags are references to assess within Ulduar's design, not replacement authority.

## Conditions that could change the decision

A later exact Free Pick/Wildcard repository can qualify for B only after source establishes:

1. Server-authoritative cross-class catalogs, rank/prerequisite checks and separate budget accounting.
2. Durable entitlement sources, atomic purchase/refund, safe respec and replay/crash reconciliation.
3. Server-owned draft offers, duplicate policy, locks, rerolls and persisted accepted choices.
4. Explicit resource, skill, weapon, form, pet and native spellbook compatibility.
5. A bounded core delta compatible with Ulduar, plus a reproducible client/protocol package.
6. An adapter boundary that preserves ability execution, gems, generalized semantics and EP.

C additionally needs a measured total migration advantage across Ulduar's current modules, SQL and client.
CoA would need an actual universal ownership backend and matching client reproduction before reevaluation as a base.
No implementation, merge experiment or migration is authorized by this document.

## Required decision report

**Recommendation: KEEP_CURRENT_BASE.**

- **ESTIMATED_REUSED_SYSTEMS:** six existing Ulduar subsystem groups retained; four external acquisition pattern
  candidates for later assessment; zero external systems approved as directly reusable implementations.
- **ESTIMATED_REWRITTEN_SYSTEMS:** zero existing Ulduar systems replaced wholesale. Eight new classless work
  packages remain, with bounded extensions to availability, native grant integration and the addon.
- **MAJOR_CONFLICTS:** Spell/Unit school and scaling behavior, cast snapshots/secondary attribution,
  native versus generalized talents, class-bound grants, client packets/assets and world/character data.
- **BLOCKERS:** missing exact restoration source blocks B/C evaluation; missing matched CoA client inputs
  blocks reproducible migration; missing authority/transactions blocks using CoA's talent command as Free Pick.
  These do not block designing or building the owned classless layer on the current base.
- **NEXT_IMPLEMENTATION_PHASE:** metadata/ownership contract foundation, then a small cross-class acquisition
  slice with budgets, grant sources, durable receipts and reconciliation. Implementation remains a later phase.

The [roadmap](ULDuar_UPDATED_ROADMAP.md) defines the counting units, ordering, acceptance criteria and
explicit amendments to older documents. Counts are work-package estimates, not completed feature counts or timelines.
