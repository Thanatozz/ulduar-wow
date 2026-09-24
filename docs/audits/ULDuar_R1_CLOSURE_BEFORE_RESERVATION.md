# ULDuar Phase R.1 closure — authority gate pending

Date: 2026-09-21. Documentation/evidence review only. No reservation was made.

## Decision

| Gate | Result |
| --- | --- |
| PHASE_R1_CLOSURE_STATUS | PARTIAL |
| MAINTAINER_HISTORY_AUTHORITY | MISSING |
| V0_GATE | PASS |
| CLIENT_TABLE_GATE | PASS_RUNTIME_EVIDENCE |
| INSTALLED_WORLD_90000_90023 | EMPTY |
| STATIC_NAMESPACE_CONFLICTS | 0 in the reviewed R.1 evidence |
| COMPUTED_OWNER | NO_COMPUTED_OWNER_FOUND_STATIC |
| SUPPORTED_HISTORICAL_OWNER | Not attested; no claim found in the prior local screen |
| NAMESPACE_GATE | PARTIAL |
| RESERVATION_STATUS | NOT_RESERVED |
| LEDGER / RESERVATION_CERTIFICATE | NOT_WRITTEN / NOT_ISSUED |
| ARTIFACT_AUTHORING_GATE | BLOCKED |
| DEPLOYMENT_ADMISSION | REQUIRED |

The technical inputs satisfy the requested closure checks. The missing condition is the explicit project-maintainer
declaration required by section 0 of the request. Its conditional sample is not treated as a confirmed attestation.
The maintainer was asked to confirm the complete declaration in this conversation; no confirmation had been received
when this partial report was written. No production allocation entry, reservation revision or certificate is issued.

## Explicit authority required

Section 0 says: **"If the declaration above has NOT been explicitly confirmed: DO NOT RESERVE THE IDS."**

The declaration still requiring explicit confirmation is:

> Ulduar WoW has no published or currently supported release, and no supported rollback release, in which Spell IDs
> 90000 through 90023 were assigned to a different purpose.
>
> No known historical Ulduar allocation that remains supported owns any Spell ID inside 90000..90023.
>
> The allocation ledger created by this phase will become the first formal Ulduar ownership authority for this
> Spell-ID interval.

This is a project-governance fact, not another request to authorize the already requested documentation work.
File absence, successful V.0 tests and an empty installed-world interval cannot establish it.

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
- The narrow historical inventory has 173 files and zero interval claims. Its publication/rollback authority was
  explicitly missing; this historical finding is retained, not silently promoted to a maintainer declaration.
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

## Proposed mapping, not ownership

| IDs | Family | Copy indices | Status |
| --- | --- | --- | --- |
| 90000..90005 | MeleeDamage | 0..5 | NOT_RESERVED |
| 90006..90011 | RangedProjectileDamage | 0..5 | NOT_RESERVED |
| 90012..90017 | MeleeHealing | 0..5 | NOT_RESERVED |
| 90018..90023 | RangedHealing | 0..5 | NOT_RESERVED |

The proposed mapping agrees with R.1. It describes 24 independent future identities, not ranks. The existing
24-bit and sparse-index analysis remains unchanged: 90023 fits the 24-bit action identity; the client max-index
illustration adds 9,159 positions, and the server SQL source model already reaches 100102. These facts do not
waive ownership or admission requirements.

No ledger or success-shaped certificate was created. The compact final reservation evidence manifest and immutable
reservation revision remain unwritten until the authority gate closes. The technical review is expressly not
the reservation evidence manifest or the production ledger.

## Preservation and exact next step

[The pre-write snapshot](../audits/ULDuar_R1_CLOSURE_PRE_SNAPSHOT.json) records 9,720 protected existing
source/data/document hashes and no inherited V.0 source-data drift. No prior report or allocation policy was edited.
The only writes are new closure audit/report files. In particular `src/test/CMakeLists.txt` is not reverted.
The post-review preservation result is recorded in `ULDuar_R1_CLOSURE_PRESERVATION.json`.

Expected changes to existing CPP/LUA/SQL/DBC/MPQ/CLIENT/CONFIG files: zero. No runtime operation, compiler,
build system, project test, server, client, live database connection or data generator was used in this phase.

NEXT_SAFE_PHASE: **R1 CLOSURE REQUIRED**. Obtain the explicit declaration above, then finish the already requested
manifest/ledger/certificate transaction using these checked inputs. Until then the namespace is NOT_RESERVED.
After any eventual reservation, deployment must still verify the intended release, build/locale, effective table
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
