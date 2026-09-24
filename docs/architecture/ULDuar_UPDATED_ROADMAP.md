# Ulduar updated roadmap after classless base evaluation

Decision date: 2026-09-14. Proposed future work only.
This document supplements existing architecture documents; it does not rewrite them or authorize implementation.

## Base decision and immediate consequence

**KEEP_CURRENT_BASE.** Retain the current AzerothCore checkout, existing Ulduar Abilities implementation,
core extensions and client addon. Implement `mod-ulduar-classless` as the owner of acquisition and entitlements.

The [CoA audit](ASCENSION_CLASSLESS_BASE_AUDIT.md) found custom-class progression, native talent catalogs,
temporary grants, class resources and extensive client/core integration.
It did not establish a complete universal Free Pick/Wildcard backend or equivalent Ulduar semantic abstractions.
The [weighted comparison](CLASSLESS_BASE_COMPARISON.md) favors retaining the base.
The [port matrix](CLASSLESS_PORT_MATRIX.md) maps all 39 unresolved gaps and the migration conflict surface.

The missing community project remains **PENDING_EXTERNAL_SOURCE**.
Its absence blocks selecting it as an implementation dependency; it does not block the owned classless design.
An exact source can be evaluated later against the same acquisition contract without changing the ability runtime.

## Explicit amendments to prior assumptions

These are proposed amendments recorded here; the linked documents remain unchanged.

| Existing document/assumption | Amendment from new evidence | Implementation consequence |
| --- | --- | --- |
| Gap audit: Astoria reference | Add CoA; restoration source pending | Treat projects separately |
| Classless: native gate adapter | CoA retains class/spec policy | Keep ownership/grant boundary |
| Classless: source-counted grants | CoA temporary/permanent distinction | Add reconciliation cases |
| Classless: native rank versus EP | CoA class-bound rank catalog | Preserve lookup; review provenance |
| Generic stats: cooldown adapter | CoA charge utility/settings | Assess later within Ulduar timer design |
| Resolution: cast/scaling ledger | CoA cast values/damage flags | Add review cases; retain typed contracts |
| Talent library: UI missing | CoA client catalogs need custom APIs | Extend existing addon |
| Conversion: native access insufficient | CoA learns native rank SpellIDs | Semantic conversion remains |
| Metadata: custom native data | CoA fixers/external generators | Require manifests before new DBC IDs |
| Roadmap: no external dependency selected | No complete new backend verified | Keep current base |

The original separation of classless ownership, Abilities structure, individual gems, generalized rules and
keystones remains valid. New evidence does not make those abstractions obsolete.
The superseded assumption is that an Ascension-oriented AC repository necessarily provides portable classless
ownership or can be installed as a module without a matched custom client and core.

## Work-package estimates

Counts below use explicit subsystem groups. They are scope estimates, not promises about delivery dates,
lines of code, test coverage or complete production readiness.

### ESTIMATED_REUSED_SYSTEMS

Six existing Ulduar groups are retained and extended only where required:

1. Ability catalog/native rank resolution and current source spell bindings.
2. Ability customization state, custom ranks and EP persistence.
3. Immutable cast/event/hit contexts and secondary native-spell execution.
4. Propagation/target resolution, caster attribution and presentation proxies.
5. Existing core school, delivery, ammo, target-validator and cast-time extensions.
6. Addon protocol, drafts, ability views, widgets, tooltips and spellbook integration.

Four external **acquisition pattern candidates**, not four approved code imports:

1. CoA's generated native catalog identity/rank structure.
2. CoA's root-owned, level-gated rank progression synchronization.
3. CoA's temporary taught-ability reconciliation, preserving permanent native grants.
4. CoA's temporary replacement projection and stale-child removal behavior.

Expected direct external reuse at this decision: **0 complete systems**.
CoA charge arithmetic and cast/scaling examples remain separate later references, outside the acquisition count.
No claim is made that importing any of these is cheaper than implementing the required small adapter.

### ESTIMATED_REWRITTEN_SYSTEMS

**0 existing Ulduar systems replaced wholesale.**
Eight new classless work packages remain:

1. Entitlement catalog, owned definitions/ranks and source-counted grants.
2. Server-authoritative point budgets, generic prerequisites and build validation.
3. Durable ownership transactions, revisions, receipts and native-reconciliation outbox.
4. Native grant/rank/spellbook adapter and centralized availability provider.
5. Free Pick purchase, unlearn, downgrade and respec flow.
6. Wildcard/Wild Draft pools, offers, locks, rerolls and persisted choices.
7. Mechanic eligibility for resources, skills, weapons, forms/stances and pets.
8. Universal acquisition/library UI with versioned, bounded catalog transport.

Package 7 governs eligibility and required mechanic grants; it does not take ownership of Abilities' resource
execution or generic resource resolution. Package 8 presents owned state; generalized semantic compilation
remains a separate design responsibility.
The 39-gap list includes additional semantic/gem/runtime work beyond these eight classless packages.

If CoA were imported wholesale, its acquisition command, authority/persistence and client integration would need
substantial replacement or redesign. That rejected path is not included as promised reuse.

## Phase 0: contracts and legacy preservation

Goal: define the smallest stable boundary that lets ownership progress without changing existing spell behavior.

Inputs remain the existing taxonomy, ability metadata, classless architecture and resolution-pipeline documents.
Specify canonical ability/talent/source-rank IDs, ownership snapshot revision, grant-source identity,
availability queries and native adapter results. Keep native spell rank, talent rank and custom rank/EP distinct.
Introduce effect metadata and capability contracts sufficient for the first supported cohort.

Exit criteria for a later implementation:

- Each of the 28 enabled legacy definitions has a traceable native binding and explicit support state.
- Metadata-only examples remain disabled; unsupported mechanics cannot be purchased as working abilities.
- Existing customization rows and EP have an explicit preservation/migration contract.
- Ownership authorization is shared by UI and runtime availability checks.
- Immutable effect metadata and native source signatures are distinct from ownership state.
- A representative legacy build resolves identically before and after adding the ownership interface.

This phase is the next foundation work; a complete universal semantic talent library is not a prerequisite
for proving the native acquisition transaction on a deliberately small cohort.

## Phase 1: durable acquisition service and cross-class slice

Implement packages 1-4 for a small reviewed set of spells from multiple source classes.
Use `CoreSpellGrantAdapter` and an immutable ownership snapshot; do not globally bypass CheckCast.
Use separate acquisition/talent ledgers and preserve per-ability EP.

Commit bounded build changes through one validator shared by preview and commit.
Persist ownership, trusted costs/refunds, revision, receipt and reconciliation intent atomically.
If native SaveToDB cannot share that transaction, use the outbox and prevent activation of pending state.
A reconnect/retry must return or finish the original operation without charging again.

Exit criteria:

- Cross-class learn, rank upgrade, downgrade and unlearn survive logout/login and restart.
- A spell granted by two independent sources remains until the final valid source is removed.
- Temporary aura/talent grants cannot overwrite permanent entitlement provenance.
- Invalid rank, unknown definition, stale revision, insufficient budget and invalid prerequisite are rejected.
- Crash after durable commit but before native application recovers to one published build revision.
- Duplicate request IDs are idempotent; reuse with different payload is rejected.
- Native spells, action bars and spellbook show the intended active rank.
- Existing Abilities EP, school conversion and secondary attribution retain their prior behavior.

CoA's local talent command is an example of why catalog validation alone is insufficient.
Do not copy its class/spec authorization or assume AE/TE fields implement a budget.

## Phase 2: Free Pick and generalized talent foundation

Build Free Pick and respec on the Phase 1 service. The UI submits choices; it does not supply trusted costs.
Validate complete unlearn/downgrade cascades before applying refunds or revocations.
Keep raw native talents in an explicit legacy/source mode until their generalized semantics are reviewed.

In a separate semantic workstream, implement the shared selector/modifier compiler from the existing talent design.
Convert a small reviewed numeric cohort across source classes.
Publish ACTIVE/DORMANT reasons based on semantic compatibility without treating zero current matches as loss
of talent ownership. Prevent native passive and generalized versions of the same effect from applying together.

Extend the existing addon with bounded catalog pages, version/checksum handling, search/filter and owned views.
Protocol2's existing small-message format is a starting transport pattern, not permission to send a whole catalog.

Exit criteria:

- Free Pick learn/unlearn/respec uses the same durable authority as Phase 1.
- Paid native source talents cannot bypass budgets by entering through a diagnostic/local command.
- A generalized Fire + CastTime rule matches eligible effects across source classes.
- A zero-match owned talent becomes active after acquiring a compatible ability.
- UI previews and commit validation resolve the same candidate revision.
- Catalog updates do not silently reinterpret paid ownership or leave stale native grants.

## Phase 3: mechanic compatibility and breadth

Expand package 7 alongside reviewed ability/talent coverage.
For Mana, Rage, Energy and Runic Power define available pools, activation, regeneration and cast eligibility.
For Runes and Combo Points define native ownership/state and target dependencies explicitly.
For weapons/skills/forms/stances define required unlocks and meaningful cast restrictions.
For pets/summons define control, lifetime and source grants without treating cosmetic visual proxies as owners.

Retain existing generic resource, potency, geometry, scaling and event designs.
Assess CoA's resource events, charge arithmetic and native aura handlers as references only where they clarify a gap.
Any actual runtime reuse requires equivalent or superior behavior against the Ulduar abstraction, independently
of the classless-base decision.

Exit criteria include unsupported mechanic rejection, valid mechanic grants, no double debit/refund,
rank-consistent cooldowns, pet ownership preservation and distinct logical/visual caster behavior.

## Phase 4: Wildcard / Wild Draft

Use the shared ownership service rather than introducing a second grant/budget authority.
Server-defined pools specify supported ability versus talent offers, weights, rank upgrade and duplicate rules.
Persist offer identity, pool/catalog version, accepted choice, locks, reroll budget and resulting build revision.

RNG is server-owned. If reproducibility is required, retain enough server-side state to audit the draw;
do not let a client select or reset the seed. Reconnecting must return the same outstanding offer.
Changing pools requires a versioned policy for existing offers and owned ranks.

Exit criteria:

- Duplicate requests cannot produce extra offers, refunds, rerolls or grants.
- Locked choices survive reroll/reconnect according to the declared rules.
- Offer acceptance and its entitlement/budget changes are atomic or durably reconciled.
- Talent rolls and ability rolls use explicit, independently validated pools.
- Duplicate known abilities and rank upgrades follow one documented policy.
- A draft offer cannot grant an unsupported resource/form/pet mechanic.
- Catalog migration invalidates or translates pending offers explicitly.

Original Ascension Wildcard client events may inform terminology and interaction references.
They do not provide this server implementation.

## Phase 5: gems, broad semantic conversion and keystones

Continue the existing roadmap for gem definitions/rarity/ranks, signed sidegrades, hybrid compatibility,
global event ancestry, bounded proc execution, aura lifecycle and broader geometry.
Review every source-rank record in the existing conversion inventory; native acquisition does not reduce that audit.

Keystones remain structural character rules validated before publishing the final immutable build snapshot.
No classless package takes ownership of structural conversions or changes the deterministic resolution order.

Exit criteria follow the existing gem, talent conversion and resolution documents, with explicit unsupported
reports and runtime evidence for each newly enabled adapter.
CoA's custom classes do not count as completed Ulduar keystones.

## MAJOR_CONFLICTS and BLOCKERS

| Item | What it blocks | Resolution |
| --- | --- | --- |
| Missing exact restoration project | Selecting B/C | Obtain exact source/revision, audit it |
| Missing matched CoA client inputs | Reproducible CoA client/server migration | Establish complete versioned package |
| Incomplete CoA paid authority | Using its local command as Free Pick | Replace with durable ownership validator |
| Class/spec-bound progression | Universal acquisition via CoA unchanged | Use Ulduar eligibility/grant adapter |
| Spell/Unit overlapping semantics | Assuming clean merge means parity | Review school/scaling/attribution/timing |
| Native versus generalized talents | Double-applying paid behavior | Source mode and conversion ownership |
| World baseline/schema coupling | Treating bootstrap as a module migration | Separate content IDs and migration |

These blockers do not require replacing AzerothCore or abandoning the existing Ulduar architecture.
Balance choices such as currencies, point curves, respec fees and draft weights remain configurable product policy;
they must become explicit before their corresponding implementation is enabled.

## Validation and decision boundary

Completed audit validation is documentation-only: artifact presence, complete 39-row mapping,
weighted-score arithmetic, local/reference link structure, text formatting and preservation hashes.
No compilation, SQL application, client patch test, live packet test or behavioral regression result is claimed.

Results: four requested documents present; all 39 gap rows preserve their original fields and have candidate
evaluations; weighted totals recompute correctly; all checked links and text-format rules pass.
All 120 existing files in the preservation manifest retain their original SHA-256 hashes.

When implementation is separately requested, use tests that exercise transaction failures, grant-source interactions
and legacy behavior. Builds and live-stack execution remain subject to the project's explicit authorization rules.
This audit performed neither.

**NEXT_IMPLEMENTATION_PHASE:** Phase 0 metadata/ownership contract foundation, followed by Phase 1's small,
durable cross-class acquisition slice on the current checkout.

**Final recommendation: KEEP_CURRENT_BASE.**
