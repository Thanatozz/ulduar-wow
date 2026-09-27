# ULDuar allocation ledger policy

Effective date: 2026-09-21. Canonical ownership data:
[docs/data/ulduar_id_allocations.json](../data/ulduar_id_allocations.json).

## Authority and scope

The machine-readable ledger is the canonical Ulduar custom-ID ownership authority. The first transaction is
`R1-CARRIER-RESERVATION-001`, reserving Spell 90000..90023 for `mod-ulduar-abilities` / AbilityForge.
Its authority combines the explicit maintainer declaration, the R.1 bounded collision audits and the V.0
validated baseline. See the [reservation certificate](../audits/ULDuar_CARRIER_NAMESPACE_RESERVATION.md).

This operational policy implements the earlier [namespace design](ULDuar_CUSTOM_ID_NAMESPACE.md), refined by
A.10's CANONICAL_RELEASE_MANIFEST model and the explicit R.1 Closure request. That earlier document remains a
dated discovery/design record; it is not a competing allocation ledger. The three lifecycle statuses below
govern this canonical ledger. REQUESTED/FREE and other conceptual states from earlier design are not allocations.

No ownership authority or ledger existed for this interval before the maintainer-confirmed transaction.
The assertion is confined to this Spell interval; it does not erase unrelated editor or visual history.

## Typed identity and owner

The uniqueness key is `(namespace, id)`. `Spell` differs from `SpellVisual`, `SpellRange`, SpellIcon, items,
creatures and all other tables. A numeric match in another namespace is not ownership of a Spell ID.
Actual Spell references in those tables must nevertheless be collision-reviewed.

Each allocation records its responsible owner/module, system, semantic spec key, family, copy index, purpose,
release candidate, revision, evidence-manifest SHA-256, date and retirement state. Transport identity is not
AbilityInstance identity. Adjacent numbers imply neither rank chains nor gameplay entitlement.

Only the `Spell` namespace is allocated by this transaction. Existing native range/cast-time/visual/icon
dependencies are reused references, not new allocations in their namespaces.

## Append-only lifecycle

| Status | Meaning |
| --- | --- |
| RESERVED | Numeric identity is owned. A corresponding row need not exist. |
| INTRODUCED | A corresponding production artifact exists in an explicitly supported release. |
| RETIRED_TOMBSTONE | Inactive identity retained permanently; it must never be reused. |

Never delete an allocation, silently renumber an introduced identity, or recycle a retired identity.
An abandoned reservation is retained through an appended tombstone event, not removed or made FREE.
No module may allocate by `max(id)+1` or assume that an absent entry is available.

The initial objects under `namespaces.Spell` are immutable allocation records; each typed ID occurs once.
Future new allocations append objects. Lifecycle changes append records to `lifecycleEvents`, referencing
the existing typed ID and its prior event/revision rather than rewriting its initial status or provenance.
The current lifecycle status is the initial status followed by the latest authorized event in order.
The first ledger had no lifecycle events. Revision PC1-PERIODIC-CARRIER-RETIREMENT-003 appends the first 14 (tombstones, see below).

A future event must identify its immutable event/revision, typed ID, previous event or original reservation,
new status, release, timestamp, maintainer authority, reason and evidence hash. Corrections append explicit
superseding events; they do not rewrite history. An ownership/spec conflict requires a separately reviewed
decision and cannot reinterpret an introduced identity for another purpose.

One maintainer-controlled writer serializes transactions against the current ledger hash/revision.
A stale expected hash, duplicate typed ID or incompatible prior event rejects a transaction before publication.
Append-only is a semantic policy: old allocation/event objects remain unchanged even though appending JSON
requires rewriting closing delimiters. This phase implements no allocator, lifecycle resolver or admission tool.

`releaseIntroduced` in a RESERVED record identifies the approved reservation release candidate, not a claim
that a production artifact has shipped. Actual artifact introduction must be recorded by a later INTRODUCED
event and supported-release manifest. `retirementRelease=null` means no retirement has occurred.

## Evidence and release relationship

The reservation evidence manifest is hashed as exact UTF-8 file bytes including the final newline. Its SHA-256
is stored in every allocation. Input reports are individually hashed; mutable raw-log directories are not
the allocation identity. The evidence manifest does not hash the ledger or certificate, avoiding a hash cycle.
The certificate hashes that manifest and the resulting ledger. Future ledger appends must not rewrite this
certificate: it certifies the exact historical ledger snapshot/revision named within it.

Scope is `ULDuar-V1-PREVIEW-CANDIDATE`, WoW 3.3.5a build 12340/enUS, the selected 18-archive package and the
validated core/abilities-module working-tree state. Supporting another build, locale, module/data package
or release requires its own admission and compatibility evidence. A symbolic candidate is not a publication.

## Deployment admission and conflicts

**DEPLOYMENT ENVIRONMENT MUST STILL PASS MANIFEST ADMISSION.**

A future installation must verify:

1. The intended release manifest, client build, locale and selected package/archive hashes.
2. Effective DBC hashes, including the six pinned inputs and any explicitly introduced custom artifacts.
3. Core and module revisions plus approved working-tree/definition fingerprints.
4. Allocation ledger revision/hash and the ownership/status of every projected identity.
5. Expected SQL/update state and absence of conflicting effective Spell rows or foreign Spell references.

If an environment already owns any ID in 90000..90023 for a different purpose, **FAIL CLOSED**.
Unknown ownership/state also fails admission. Never overwrite, delete, auto-renumber or auto-migrate foreign
data to make it fit. Require explicit reconciliation. A V.0 empty installed-world observation is a dated
input, not permission to skip admission on that environment or any other environment later.

Absence from this ledger does not prove that an arbitrary foreign environment is collision-free.
Reservations do not imply Spell rows, RuntimeEligible status, player knowledge, working custom carriers,
implemented source seams or permission to deploy. Isolated carrier artifact authoring is a separate phase.

## Transaction PC1-PERIODIC-CARRIER-RESERVATION-002 (2026-09-26)

Appended to the canonical ledger. The earlier objects and the R.1 certificate are unchanged.

| Spell | Owner / system | Purpose | Status |
| --- | --- | --- | --- |
| 141344..141350 | mod-ulduar-abilities / PeriodicCarrier | native `SPELL_AURA_PERIODIC_DAMAGE` carriers, Physical..Arcane | RESERVED at this revision (rows in the now SUPERSEDED pending SQL 005, never applied or INTRODUCED); RETIRED_TOMBSTONE since revision 003 |
| 141351..141357 | mod-ulduar-abilities / PeriodicCarrier | future periodic healing carriers, Physical..Arcane | RESERVED at this revision, identity only; RETIRED_TOMBSTONE since revision 003 |

- **Authority:** explicit maintainer instruction (periodic carrier milestone).
- **Evidence:** `docs/audits/ULDuar_PC1_PERIODIC_CARRIER_EVIDENCE.json` (its SHA-256 is stored in each record).
  - Empty intersection with Spell.dbc rows and EffectTriggerSpell references (the pinned R.1 Spell table
    hash), base `spell_dbc`, and the 90000..90023 reservation.
  - Zero untyped literal occurrences in the five local repositories, outside the reservation's own files.
- **Limitation:** the `ulduar-client-patch` project and external environments were not screened. They must
  reconcile against this ledger before adding client rows.

**DEPLOYMENT ENVIRONMENT MUST STILL PASS MANIFEST ADMISSION.**

## PC1 supersession and generic pool proposal (2026-09-27)

- **Target change.** The periodic target moved from seven per-school carriers to a generic carrier pool
  ([PERIODIC_TARGET_ARCHITECTURE.md](PERIODIC_TARGET_ARCHITECTURE.md) §3). Runtime code no longer references
  141344..141357.
- **Tombstones appended (revision `PC1-PERIODIC-CARRIER-RETIREMENT-003`).** 14 `RETIRED_TOMBSTONE` events for
  141344..141357, evidence `docs/audits/ULDuar_PC1_PERIODIC_CARRIER_RETIREMENT_EVIDENCE.json`. None was ever
  INTRODUCED. They are never reused or reinterpreted as pool members. Pending SQL 005 is marked SUPERSEDED;
  pending SQL 007 deletes its rows/bindings in environments that applied it.
- **Pool proposal, NOT appended.** Spell 310272..312319 (2048 IDs) passed the screen in
  `docs/audits/ULDuar_PC2_GENERIC_CARRIER_POOL_EVIDENCE.json` (ledger, Spell.dbc rows, EffectTriggerSpell, all
  247 server DBC 32-bit fields (hits only in string-offset / non-spell columns), spell_dbc base + updates +
  pending SQL, typed SQL references, untyped literals in six local repositories including
  `ulduar-client-patch`, which has no DBC/MPQ output yet). The proposed transaction
  `PC2-GENERIC-PERIODIC-CARRIER-POOL-004` (2048 RESERVED records) is in
  `docs/audits/ULDuar_PC2_GENERIC_CARRIER_POOL_PROPOSAL.json`. The maintainer appends it to
  `namespaces.Spell` against expected revision `PC1-PERIODIC-CARRIER-RETIREMENT-003`; until then the pool is
  **not reserved**, and pending SQL 007 must not be applied.

**DEPLOYMENT ENVIRONMENT MUST STILL PASS MANIFEST ADMISSION.**
