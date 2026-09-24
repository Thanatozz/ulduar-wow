# ULDuar Phase ART.1 — artifact authoring preflight

PHASE_ART1_STATUS: BLOCKED

ARTIFACT_GENERATION_GATE: PARTIAL

No carrier row has been generated. This is an incomplete authoring report, not an artifact acceptance certificate.
ART.1 section 2 requires stopping an affected family when a required raw value conflicts with frozen evidence.
All four families have the payload conflict described below. The pending contract-selection question has not
been answered; the instruction to continue did not select either conflicting encoding.

## Reservation and baseline

R1_RESERVATION: VERIFIED. Revision: R1-CARRIER-RESERVATION-001.
Exactly 24 ledger identities remain RESERVED, in the requested family/copy ordering, 90000..90023.

- Allocation ledger SHA-256: `9d626913347efd63755a8f4b96ad58d4b4e1d4b7626ae10f6bd0f2805ef77bd0`.
- Reservation certificate SHA-256: `a6505f7fcf8907fb6acb968c7fa970e9376607cbcfc7eb6286ce1c7485c80f8a`.
- Baseline Spell.dbc: 49,839 rows, 234 fields, 936-byte records.
- Baseline SHA-256: `d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3`.
- None of 90000..90023 occurs in the baseline Spell ID index.

All six primary DBC members were read directly from the canonical client MPQs through the existing read-only
StormLib backend, then parsed in memory. Their hashes match V.0 and the ART.1 request exactly. No V.0 fixture
was used. Eight auxiliary visual tables also match the A.9 graph hashes.
See [input preflight evidence](../audits/ULDuar_ART1_INPUT_PREFLIGHT.json).

## Required payload decision

[A.10 serialization gate](../audits/ULDuar_A10_SERIALIZATION_GATE.md), lines 38–40, requires a one-unit transport
seed: raw EffectBasePoints[0]=0 and EffectDieSides[0]=1. It explicitly says not to retain random dice, because
the future immutable snapshot owns the semantic roll.

ART.1 section 12 instead requires the reopened DBC itself to evaluate to the following native ranges:

| Family | A.10 base/die | A.10 standalone range | ART.1 required range | Raw base/die giving ART.1 range |
| --- | --- | --- | --- | --- |
| MeleeDamage | 0 / 1 | 1 | 25 | 24 / 1 |
| RangedProjectileDamage | 0 / 1 | 1 | 13..17 | 12 / 5 |
| MeleeHealing | 0 / 1 | 1 | 46..56 | 45 / 11 |
| RangedHealing | 0 / 1 | 1 | 50..60 | 49 / 11 |

These alternatives cannot both be serialized. This is a direct raw-field conflict, not a balance proposal.
The raw field indices are 80 (EffectBasePoints[0]) and 74 (EffectDieSides[0]).

Current `src/server/game/Spells/SpellInfo.cpp` around lines 410–449 starts with raw basepoints, then adds
1 for die=1 or a random integer 1..die for positive die>1. Level and combo coefficients would be zero.
The table above is source-derived arithmetic, not executed project code or a gameplay test.

The distinction also affects the future seam: `Spell.cpp:8674` calls `CalcBaseValue`, and
`SpellInfo.cpp:523` subtracts one when DieSides is nonzero. It does not suppress the subsequent die roll.
With die=5, a future setter value X can therefore produce X..X+4; with die=11, X..X+10,
before later modifiers. An isolated diagnostic fixture exception must not be mistaken for a completed
snapshot-safe Potency implementation.

Required decision: explicitly select the ART.1 standalone diagnostic ranges as an exception to the A.10
transport-seed encoding, or preserve A.10 and amend ART.1's standalone range requirement. The former matches
the stated diagnostic artifact goal, but requires recording the future Potency/dice integration issue.
No old report or frozen source seam has been edited.

## Independent preflight completed

- Reservation identity, status, family and copy mapping checked against the unchanged canonical ledger.
- Frozen attribute set-bit values, target constants, effect types, MAGIC class and Mana type checked in the
  current core header. Encoding the intended sets reproduces the A.10 words for all four families.
- Range2 exists with native contact flag1 and 0..5 stored bounds; Range5 exists with 0..40 bounds.
  Contact acquisition continues to mean native reach, not a fixed center-to-center distance guarantee.
- CastTimes1 is 0/0/0; CastTimes20 is 2500/0/2500. The V.0 2222ms fixture was not used.
- Visual342/7873/135/2936 and icon257/237/682/70 exist in the pinned tables.
- The recorded A.9 kit, effect-name, sound and animation rows were compared byte-for-field against the
  actual member tables. Recorded present model/skin/texture/sound assets were re-read and their hashes matched.
  Absent literal .mdx paths and client .m2 interpretation remain the documented runtime limitation.
- GCD category133 exists as row `[133,0]` in SpellCategory.dbc. Selected member is patch-enUS-2.MPQ,
  SHA-256 `0026cb005df9a7bc5f48c55fa453fc531c89fd28f50f217ffbc35684490b70c1`.
  No selected base/custom archive contains that member; selection applies the V.0 observed locale patch rule.

These are input checks. They are not reopened generated-row validation, full transitive rendering proof,
MPQ creation validation, or reproducibility evidence for ART.1.

## Coefficient and auxiliary-data review

Current `Unit.cpp:8906` and `Unit.cpp:9668` start caster damage/healing coefficients from the DBC effect
BonusMultiplier, with spell_bonus_data taking precedence. `Unit.cpp:9027` and `Unit.cpp:9796` obtain the
target-taken coefficient from spell_bonus_data and otherwise use native fallback calculations.
Positive diagnostic coefficients therefore require explicit auxiliary entries if they are to remain explicit
through those taken paths. Any future staged SQL must be restricted to reserved identities and never executed
in ART.1. No SQL has been generated while the four family rows are blocked.

A zero direct coefficient does not disable native taken-aura fallback: both taken paths use default coefficients
when coeff<=0 and a relevant taken benefit exists. MD SP0/AP0 describes caster contributions; it must not be
reported as isolation from all world target modifiers. No global suppression or data workaround is introduced.

All other auxiliary relationships remain intentionally absent under the frozen policy: threat overrides,
proc/controller entries, scripts, conditions, ranks, prerequisites, linked spells, trainer and skill-line rows.
This is a source review, not a fresh live-database query.

## Workspace and preservation

Workspace created: `C:\WoWProjecto\validation\ART1`, with the requested input, canonical, generated/client,
generated/server, generated/sql, mpq, manifests, reports, hashes, reproducibility and logs directories.
The generated/artifact directories are empty. No carrier canonical spec with unresolved raw fields was emitted.

Before the first write, 32,677 protected files were hashed: current source/module/SQL/docs, complete canonical
client and server Data trees, V.0 protected paths and validated tool inputs. Snapshot:
`C:\WoWProjecto\validation\ART1\hashes\pre.json`.
Post-review verification is recorded in [preservation evidence](../audits/ULDuar_ART1_PRESERVATION.json).
The pre-existing dirty source state, V.0 CTest correction and R.1 ledger are preserved.

New repository files for this incomplete phase are this report, the input-preflight JSON and preservation JSON.
No previous report is changed. No canonical artifact manifest, decoded carrier-row report, generation receipt,
SQL, DBC or MPQ is fabricated to stand in for unperformed generation.

## Current gate results

| Check | Result |
| --- | --- |
| R1 reservation | VERIFIED |
| Input table hashes | MATCH_PINNED |
| Input attribute/target constants | MATCH_FROZEN_SOURCE |
| Canonical carrier spec | NOT_EMITTED_PENDING_PAYLOAD_DECISION |
| Generated client/server Spell.dbc | NOT_GENERATED |
| New carrier rows / IDs | 0 / none |
| Existing baseline rows changed | 0 |
| Family copy equivalence | NOT_RUN_NO_GENERATED_ROWS |
| Reopened attribute / target / payload validation | NOT_RUN_NO_GENERATED_ROWS |
| Generated dependency/dangling-reference validation | NOT_RUN_NO_GENERATED_ROWS |
| Auxiliary SQL staging | NOT_GENERATED |
| MPQ staging | NOT_GENERATED |
| Reproducibility | NOT_RUN |
| ARTIFACT_GENERATION_GATE | PARTIAL |
| RUNTIME_READY | NO |
| CLIENT_VALIDATED_FOR_CUSTOM_CARRIERS | NO |

## Runtime boundaries and next action

The only authoring decision requested here is the raw payload conflict. R.1 reservation is already complete;
no new reservation, broad semantic audit or runtime approval is needed to resolve this document conflict.
After the choice, finish ART.1 generation and all required structural/semantic/reproducibility checks.
NEXT_SAFE_PHASE: ART.1 CORRECTION REQUIRED. Do not begin ART.2 from this partial report.

Both healing profiles retain RUNTIME_BLOCKED_BY_HEALING_THREAT_SEAM. All four retain
RUNTIME_BLOCKED_BY_POTENCY_SEAM and the original-target-intent integration gate. Native aura provenance,
lease lifecycle and deployment admission are not implemented by these input checks.
THIS IS A DIAGNOSTIC BASE-MANA MODEL, NOT FINAL CLASS-NEUTRAL BALANCE.

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO PROJECT TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO CLIENT WAS LAUNCHED.
NO LIVE SQL WAS EXECUTED.
NO CANONICAL CLIENT MPQ WAS MODIFIED.
NO CANONICAL SERVER DBC WAS MODIFIED.
NO CUSTOM CARRIER WAS ENABLED AT RUNTIME.
NO CUSTOM CARRIER WAS CAST.
NO RESERVED ID WAS PROMOTED TO INTRODUCED.
NO CARRIER WAS PROMOTED TO RuntimeEligible.
