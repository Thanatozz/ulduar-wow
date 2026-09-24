# ULDuar carrier namespace reservation certificate

Date: 2026-09-21. Revision: `R1-CARRIER-RESERVATION-001`. Namespace: **Spell**. Status: **RESERVED**.

**THESE IDS ARE RESERVED IDENTITIES ONLY.**
**NO SPELL ROWS HAVE BEEN CREATED.**

## Authority and gates

The maintainer explicitly confirmed: "confirmo que ninguna version asigna las ids" in response to the
complete historical declaration for this interval. The original request authorizes the first formal ledger.
V.0 gate PASS; client-table gate PASS_RUNTIME_EVIDENCE; installed-world interval EMPTY;
static Spell conflicts 0; computed owner NO_COMPUTED_OWNER_FOUND_STATIC;
supported historical owner NONE by maintainer declaration. NAMESPACE_GATE=PASS_STATIC.

## Exact independent identities

| Spell ID | Family | Copy | Status |
| --- | --- | ---: | --- |
| 90000 | MeleeDamage | 0 | RESERVED |
| 90001 | MeleeDamage | 1 | RESERVED |
| 90002 | MeleeDamage | 2 | RESERVED |
| 90003 | MeleeDamage | 3 | RESERVED |
| 90004 | MeleeDamage | 4 | RESERVED |
| 90005 | MeleeDamage | 5 | RESERVED |
| 90006 | RangedProjectileDamage | 0 | RESERVED |
| 90007 | RangedProjectileDamage | 1 | RESERVED |
| 90008 | RangedProjectileDamage | 2 | RESERVED |
| 90009 | RangedProjectileDamage | 3 | RESERVED |
| 90010 | RangedProjectileDamage | 4 | RESERVED |
| 90011 | RangedProjectileDamage | 5 | RESERVED |
| 90012 | MeleeHealing | 0 | RESERVED |
| 90013 | MeleeHealing | 1 | RESERVED |
| 90014 | MeleeHealing | 2 | RESERVED |
| 90015 | MeleeHealing | 3 | RESERVED |
| 90016 | MeleeHealing | 4 | RESERVED |
| 90017 | MeleeHealing | 5 | RESERVED |
| 90018 | RangedHealing | 0 | RESERVED |
| 90019 | RangedHealing | 1 | RESERVED |
| 90020 | RangedHealing | 2 | RESERVED |
| 90021 | RangedHealing | 3 | RESERVED |
| 90022 | RangedHealing | 4 | RESERVED |
| 90023 | RangedHealing | 5 | RESERVED |

These are 24 independent identities; there are no rank relationships or allocations in other namespaces.

## Immutable evidence and ledger snapshot

- Reservation revision: `R1-CARRIER-RESERVATION-001`.
- Evidence manifest: [ULDuar_R1_CLOSURE_EVIDENCE_MANIFEST.json](ULDuar_R1_CLOSURE_EVIDENCE_MANIFEST.json).
  SHA-256: `4fedec09b272197bf052a3940e351cfedcaf53a826f22046ce8b136012f6ca81`.
- Ledger: [ulduar_id_allocations.json](../data/ulduar_id_allocations.json).
  SHA-256 at reservation: `9d626913347efd63755a8f4b96ad58d4b4e1d4b7626ae10f6bd0f2805ef77bd0`.
- Machine certificate: [ULDuar_CARRIER_NAMESPACE_RESERVATION.json](ULDuar_CARRIER_NAMESPACE_RESERVATION.json).
  SHA-256: `a6505f7fcf8907fb6acb968c7fa970e9376607cbcfc7eb6286ce1c7485c80f8a`.

The manifest individually hashes R.1 range/reference/history evidence, V.0 reports, current preservation
and the explicit maintainer declaration. It is not a mutable raw-log-directory identity.

## Selected release and tables

ULDuar-V1-PREVIEW-CANDIDATE; WoW 3.3.5a build 12340; enUS; the 18 selected A.10 archives.
Only mod-ulduar-abilities is selected. The machine certificate carries the exact archive hashes, core/module
revisions and dirty-source evidence, including the retained V.0 CTest correction. No foreign scope is implied.

- Spell: `patch-enUS-3.MPQ` / `DBFilesClient\Spell.dbc`.
  SHA-256: `d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3`.
- SpellRange: `patch-enUS-3.MPQ` / `DBFilesClient\SpellRange.dbc`.
  SHA-256: `82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f`.
- SpellCastTimes: `patch-enUS-2.MPQ` / `DBFilesClient\SpellCastTimes.dbc`.
  SHA-256: `919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec`.
- SpellVisual: `patch-enUS-3.MPQ` / `DBFilesClient\SpellVisual.dbc`.
  SHA-256: `966db0c9944068475b31d2584d5db88456d1ab26d0ca0658d75d048f1e00a601`.
- SpellIcon: `patch-enUS-3.MPQ` / `DBFilesClient\SpellIcon.dbc`.
  SHA-256: `2b12326641dba1554878b3f53c993e1211e50b3839ccdbeca378a23e7b3248db`.
- SkillLineAbility: `patch-enUS-3.MPQ` / `DBFilesClient\SkillLineAbility.dbc`.
  SHA-256: `4154b833d6a26b9b9ce53851d56cb594f0813c0936a72ec89f933cc69abe42c3`.

Spell and CastTimes have direct V.0 observations. The other four selections combine the observed archive
order with member inventory; they are not four additional runtime read traces. These are original table hashes.

## Capacity, limitations and deployment

90023 is below the exclusive 24-bit action identity limit 16777216. The inherited client index illustration
adds 9,159 positions; the source SQL model already reaches 100102. No actual client-memory claim is made.

**DEPLOYMENT ENVIRONMENT MUST STILL PASS MANIFEST ADMISSION.**

Check the intended manifest, build/locale, effective DBC/package hashes, core/module state, ledger revision,
expected SQL/update state and conflicting installed Spell ownership/references. Conflicts or unknown ownership
fail closed: no overwrite, deletion, automatic renumbering or foreign migration. Reconciliation must be explicit.

ARTIFACT_AUTHORING_GATE=READY for a separately authorized isolated authoring phase only.
RUNTIME_READY=NO; custom-carrier CLIENT_VALIDATED=NO. No carrier row, entitlement, RuntimeEligible entry,
source seam or admission implementation is created by this certificate. The phase ends at reservation.
