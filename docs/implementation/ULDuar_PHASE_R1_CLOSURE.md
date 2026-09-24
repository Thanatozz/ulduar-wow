# ULDuar Phase R.1 closure — formal carrier namespace reservation

Date: 2026-09-21. Documentation/ledger phase only. Spell 90000..90023 is now formally RESERVED.

## Decision

| Gate | Result |
| --- | --- |
| PHASE_R1_CLOSURE_STATUS | COMPLETE |
| MAINTAINER_HISTORY_AUTHORITY | CONFIRMED |
| V0_GATE | PASS |
| CLIENT_TABLE_GATE | PASS_RUNTIME_EVIDENCE |
| INSTALLED_WORLD_90000_90023 | EMPTY |
| STATIC_NAMESPACE_CONFLICTS | 0 in the reviewed R.1 evidence |
| COMPUTED_OWNER | NO_COMPUTED_OWNER_FOUND_STATIC |
| SUPPORTED_HISTORICAL_OWNER | NONE, by explicit maintainer declaration |
| NAMESPACE_GATE | PASS_STATIC |
| NAMESPACE_STATUS | NAMESPACE_RESERVED |
| RESERVATION_STATUS | RESERVED |
| RESERVATION_REVISION | R1-CARRIER-RESERVATION-001 |
| LEDGER / RESERVATION_CERTIFICATE | CREATED / ISSUED |
| ARTIFACT_AUTHORING_GATE | READY |
| DEPLOYMENT_ADMISSION | REQUIRED |

The maintainer explicitly confirmed the historical declaration after the technical checks were complete.
All conditions now pass, and the ledger contains the exact 24 independent carrier identities in one reservation
revision. No Spell row, SQL/DBC/MPQ artifact, runtime eligibility, entitlement or gameplay feature was created.

| Transition | Before | After this closure |
| --- | --- | --- |
| PHASE_R1_STATUS | PARTIAL | COMPLETE |
| NAMESPACE_GATE | PARTIAL | PASS_STATIC |
| RESERVATION_STATUS | NOT_RESERVED | RESERVED |

Original R.1/A.10/V.0 evidence is unchanged. The initial partial version of this closure report is preserved
byte-exact in [the pre-reservation report](../audits/ULDuar_R1_CLOSURE_BEFORE_RESERVATION.md).

## Explicit maintainer authority

Section 0 says: **"If the declaration above has NOT been explicitly confirmed: DO NOT RESERVE THE IDS."**

The maintainer replied **"confirmo que ninguna version asigna las ids"** to the question confirming the complete
declaration for this interval. The reply and context are recorded in
[the history declaration](../audits/ULDuar_R1_MAINTAINER_HISTORY_DECLARATION.json).
The original R.1 Closure request authorizes establishing the first formal ledger. The confirmed declaration is:

> Ulduar WoW has no published or currently supported release, and no supported rollback release, in which Spell IDs
> 90000 through 90023 were assigned to a different purpose.
>
> No known historical Ulduar allocation that remains supported owns any Spell ID inside 90000..90023.
>
> The allocation ledger created by this phase will become the first formal Ulduar ownership authority for this
> Spell-ID interval.

This authority comes from the explicit maintainer response and request, not file absence, successful tests
or an empty installed-world interval. No broader claim about unrelated historical namespaces is made.

## Verified technical evidence

Read the R.1 namespace report, A.10 release gate, V.0 validation report and relevant R.1/V.0 JSON companions.
The bounded checks are recorded with input report SHA-256 values in
[the technical gate review](../audits/ULDuar_R1_CLOSURE_GATE_REVIEW.json).

- V.0 explicitly reports COMPLETE and PRE_ARTIFACT_VALIDATION_GATE=PASS.
- V.0 reports PROVEN_BY_EXPERIMENT and PASS_RUNTIME_EVIDENCE for the selected build-12340/enUS package.
- Its database baseline reports EMPTY for 90000..90023, zero query errors and 349 numeric hits all classified as
  false positives in the inspected semantic fields. No database was contacted during this closure.
- The R.1 exact-range audit has all 24 IDs with no selected-row, typed-DBC-reference or literal Spell conflict.
- R.1's 784 literal lines are classified as FALSE_POSITIVE, TEST_FIXTURE or OTHER_NAMESPACE; none remains an
  actual Spell conflict or unknown literal line.
- Computed C++/SQL reference reviews retain NO_COMPUTED_OWNER_FOUND_STATIC within their documented scope.
- The narrow historical inventory has 173 files and zero interval claims. Its old missing-authority finding is
  retained; the new declaration independently closes supported-publication/rollback authority for this interval.
- The inherited source/SQL/addon/config corpus matches the validated V.0 state. The CTest fix is retained.

No new contradictory technical evidence was found. No alternative interval was searched. No broad architecture,
carrier semantics, live database, archive-loading or client experiment was reopened.

## Pinned release and six client tables

Release candidate: `ULDuar-V1-PREVIEW-CANDIDATE`; 3.3.5a build 12340; enUS; the existing selected 18 archives.
Core `d7ce67dc1800f092bac98aad680ece1c201b89a0` plus documented working-tree state; abilities module
`5f51c5e012b153b1edae00af2b0e11a9d45ba62d` plus its documented implementation. Only mod-ulduar-abilities is
the selected module. The V.0 CTest build-file correction remains part of that baseline.

| Table | Archive | SHA-256 carried forward from V.0 |
| --- | --- | --- |
| Spell | patch-enUS-3.MPQ | d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3 |
| SpellRange | patch-enUS-3.MPQ | 82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f |
| SpellCastTimes | patch-enUS-2.MPQ | 919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec |
| SpellVisual | patch-enUS-3.MPQ | 966db0c9944068475b31d2584d5db88456d1ab26d0ca0658d75d048f1e00a601 |
| SpellIcon | patch-enUS-3.MPQ | 2b12326641dba1554878b3f53c993e1211e50b3839ccdbeca378a23e7b3248db |
| SkillLineAbility | patch-enUS-3.MPQ | 4154b833d6a26b9b9ce53851d56cb594f0813c0936a72ec89f933cc69abe42c3 |

Every hash/archive pair matches the request and V.0 JSON. These DBC hashes were not recomputed or changed.
Spell and CastTimes had direct V.0 observations; the other four selections combine that archive rule with the
member inventory. No test-mutated table is adopted as a release input. No scope extension to other locales,
builds, foreign databases, Ascension/TrinityCore packages or unsupported history is implied.

## Reserved mapping

| IDs | Family | Copy indices | Status |
| --- | --- | --- | --- |
| 90000..90005 | MeleeDamage | 0..5 | RESERVED |
| 90006..90011 | RangedProjectileDamage | 0..5 | RESERVED |
| 90012..90017 | MeleeHealing | 0..5 | RESERVED |
| 90018..90023 | RangedHealing | 0..5 | RESERVED |

The mapping agrees with R.1. It reserves 24 independent identities, not ranks. The existing
24-bit and sparse-index analysis remains unchanged: 90023 fits the 24-bit action identity; the client max-index
illustration adds 9,159 positions, and the server SQL source model already reaches 100102. These facts do not
waive ownership or admission requirements.

## Ledger, certificate and append-only authority

The canonical [machine ledger](../data/ulduar_id_allocations.json) contains all 24 exact Spell IDs once,
with owner `mod-ulduar-abilities`, system AbilityForge, family/specKey, copy index, RESERVED status,
reservation date, release candidate, common revision/hash and null retirement release.
No other namespace is allocated. All entries share `R1-CARRIER-RESERVATION-001`.

- Evidence manifest: [ULDuar_R1_CLOSURE_EVIDENCE_MANIFEST.json](../audits/ULDuar_R1_CLOSURE_EVIDENCE_MANIFEST.json).
  SHA-256: `4fedec09b272197bf052a3940e351cfedcaf53a826f22046ce8b136012f6ca81`.
- Ledger SHA-256: `9d626913347efd63755a8f4b96ad58d4b4e1d4b7626ae10f6bd0f2805ef77bd0`.
- Machine certificate: [ULDuar_CARRIER_NAMESPACE_RESERVATION.json](../audits/ULDuar_CARRIER_NAMESPACE_RESERVATION.json).
  SHA-256: `a6505f7fcf8907fb6acb968c7fa970e9376607cbcfc7eb6286ce1c7485c80f8a`.
- Human certificate: [ULDuar_CARRIER_NAMESPACE_RESERVATION.md](../audits/ULDuar_CARRIER_NAMESPACE_RESERVATION.md).
- Operational policy: [ULDuar_ID_ALLOCATION_LEDGER.md](../architecture/ULDuar_ID_ALLOCATION_LEDGER.md).

The compact manifest individually hashes the R.1/V.0 input reports, release selection, new declaration,
preservation record and policy. It excludes the downstream ledger/certificate, so there is no hash cycle.
Raw-log directories are not the ledger identity. No fabricated Git revision is used.

The ledger is append-only in policy. Original allocation records remain immutable; lifecycle changes append
authorized events. INTRODUCED requires a supported production artifact; RETIRED_TOMBSTONE permanently retains
ownership. Never delete an allocation, reuse a retired identity or silently renumber an introduced identity.
The old A.7 namespace document remains a historical design record; the new operational policy implements its
ledger intent with the R.1-approved lifecycle. No competing numeric ledger existed.

## Preservation and exact next step

[The initial snapshot](../audits/ULDuar_R1_CLOSURE_PRE_SNAPSHOT.json) recorded 9,720 protected files before the
partial review. [The reservation snapshot](../audits/ULDuar_R1_RESERVATION_PRE_SNAPSHOT.json) then recorded
9,724 protected existing source/data/document hashes before reservation writes, with no baseline drift.
The only modified existing document is this closure report, updated from PARTIAL to COMPLETE; its old bytes
are archived. Original phase reports, prior audits and the historical namespace policy remain unchanged.
`src/test/CMakeLists.txt` retains the validated V.0 correction.

The exact pre/post report hashes, documentation diff and new-file inventory are recorded in
`ULDuar_R1_RESERVATION_PRESERVATION.json`. Only new ledger/policy/certificate/audit documents and this closure
report were written. There are no removed files or source/data changes.

Expected changes to existing CPP/LUA/SQL/DBC/MPQ/CLIENT/CONFIG files: zero. No runtime operation, compiler,
build system, project test, server, client, live database connection or data generator was used in this phase.

NEXT_SAFE_PHASE: **CARRIER ARTIFACT AUTHORING**, separately authorized and isolated. No next phase is started here.
ARTIFACT_AUTHORING_GATE=READY means specification, identity and input evidence are available for authoring;
it does not mean custom carriers are RuntimeEligible, runtime support is complete, custom-client behavior is
validated or deployment is authorized. The three source seams remain frozen, unimplemented proposals.

**DEPLOYMENT ENVIRONMENT MUST STILL PASS MANIFEST ADMISSION.**
Deployment must verify the intended release, build/locale, effective table
hashes, server/module state, ledger revision, expected SQL state and absence of conflicting foreign ownership.
Conflicts fail closed: no overwrite, deletion, silent renumbering or automatic foreign migration.

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO LIVE DATABASE WAS MODIFIED.
NO SQL WAS EXECUTED OR MODIFIED.
NO DBC WAS GENERATED OR MODIFIED.
NO MPQ WAS GENERATED OR MODIFIED.
NO CLIENT PATCH WAS APPLIED.
NO CARRIER SPELL ROW WAS CREATED.

SPELL IDS 90000..90023 ARE NOW RESERVED IN THE ULDUAR ALLOCATION LEDGER.
THEY ARE RESERVED IDENTITIES ONLY.
NO SPELL ROWS HAVE BEEN CREATED.
