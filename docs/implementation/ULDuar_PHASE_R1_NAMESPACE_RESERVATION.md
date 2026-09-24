# ULDuar Phase R.1 - Release closure and carrier namespace reservation

Date: 2026-09-20. SOURCE_ONLY. Bounded review of client precedence and Spell 90000..90023.

## 1. Executive summary

**PHASE_R1_STATUS=PARTIAL. RESERVATION_STATUS=NOT_RESERVED.**
The interval has no identified collision in the reviewed typed data and source references, but the
required release/history evidence is not complete. No allocation ledger or reservation certificate was issued.

| Independent gate | Decision |
| --- | --- |
| CLIENT_TABLE_GATE | PARTIAL |
| Effective six client tables | CONDITIONAL; unchanged A.10 selections and hashes |
| NAMESPACE_GATE | PARTIAL; no actual Spell collision found, supported-history authority missing |
| NAMESPACE_RANGE | NOT_RESERVED; only 90000..90023 was evaluated |
| ARTIFACT_AUTHORING_GATE | BLOCKED |
| DEPLOYMENT_ADMISSION | REQUIRED under CANONICAL_RELEASE_MANIFEST / MODEL B |

The new evidence closes the previously unclassified decimal literal hits and adds typed DBC-reference,
computed-source and narrow historical screens. It does not establish a publication history from absence
of local files. The existing A.10 history requirement has not been weakened.

All four carriers retain STATIC_SERIALIZATION_READY=YES, RUNTIME_READY=NO, CLIENT_VALIDATED=NO.
There is no new carrier semantic research or runtime approval.

## 2. Scope and preservation

Read the full A.10 report and its audit companions, including the membership, effective table, candidate,
candidate-evidence, attribute and serialization records. A.6/A.7 ordering and namespace policy remain the
design baseline. Existing reports were not edited.

Fresh initial hashes covered 10,062 existing protected source/data/document files; 25 additional historical
reference files were hashed during read-only discovery before semantic review. Final comparison covered
**10,087 files / 18,408,666,446 bytes: zero changed, zero missing**. The preservation scope is enumerated,
not every unrelated file on the machine. The 10,043-entry A.10 initial baseline also matches the R.1 baseline.

- [Initial hashes](../audits/ULDuar_R1_PROTECTED_FILE_HASHES.json)
- [Supplemental hashes](../audits/ULDuar_R1_SUPPLEMENTAL_HASHES.json)
- [Inherited evidence comparison](../audits/ULDuar_R1_INHERITED_EVIDENCE_CHECK.json)
- [Final preservation result](../audits/ULDuar_R1_PRESERVATION_RESULT.json)

MODIFIED_CPP=0; MODIFIED_LUA=0; MODIFIED_SQL=0; MODIFIED_DBC=0; MODIFIED_MPQ=0;
MODIFIED_CLIENT=0; MODIFIED_CONFIG=0. No existing file was intentionally changed and none was removed.
Only the new R.1 report/audit files listed in [the file manifest](../audits/ULDuar_R1_FILES_CHANGED.json) were written.

PowerShell, rg and standalone Python byte/text inspection were used. SQL was never submitted to an engine;
DBC bytes were decoded in memory without emitting DBC files. No project binary, generator, test, client,
server, database or build system was run. An inefficient text-inspection process was stopped and replaced
with a bounded parser; an audit-output encoding error was corrected without touching its source inputs.
These were inspection-tool issues, not project test results.

## 3. Frozen A.10 inputs

Release candidate: `ULDuar-V1-PREVIEW-CANDIDATE`, a documentation name; releaseId remains null.
V1_SUPPORTED_LOCALE=enUS. Client `C:/WoWProjecto/Client`, build 3.3.5a/12340.
Exactly the 18 archives selected by A.10 remain selected; backup-enUS remains excluded.
No Ascension, TrinityCore, unrelated client, editor workspace or staging package was added to the release.

| Identity | Pinned value |
| --- | --- |
| Core revision | d7ce67dc1800f092bac98aad680ece1c201b89a0 |
| Existing dirty core fingerprint | 4ebe2a2d6c2fd709c9822e0a38fb73733c36bea59cf8b455c02695320f4d3768 |
| Abilities module fingerprint | 7401078d905d4eb2879d7e79f01c7b253d8bf657958c8d6e5fbc1141590d5773 |
| Wow.exe SHA-256 | aa63a5750d60ef16746c686b3d5e26876d98953eab08b1c026cd0faf78e88cb8 |

The [R.1 evidence revision](../audits/ULDuar_R1_RELEASE_EVIDENCE_MANIFEST.json) links the exact A.10
membership source hashes, archive hashes and new audit hashes. It is not the production CarrierManifest.
The A.10 membership remains authoritative for source selection; repository SQL is a source closure, not
proof of installed update state. The two selected pending files remain exactly
`ulduar_abilities_003_world_starters.sql` and `ulduar_abilities_004_characters_modifiers.sql`.

HYBRID, four families, six future copies per family, exact numeric envelopes, attributes, visuals, Mana,
GCD, damage class, coefficients and Holy Light replacement policy are unchanged. The three A.9 source
seams remain FROZEN_DESIGN_PROPOSAL and unimplemented.

## 4. Native client precedence evidence

[The precedence audit](../audits/ULDuar_R1_CLIENT_PRECEDENCE_EVIDENCE.md) separates native-version evidence,
already-cited community client research, extractor behavior and editor policy. The existing M2 documentation
explicitly cites [the WotLK client-loading article](https://wotlkdev.github.io/wiki/theory/client), inspected
read-only on 2026-09-20. It provides relevant English/locale/numbered-patch rules, but leaves the exact
build applicability and unnumbered locale-patch position insufficiently explicit for this gate.

Extractor/editor conventions corroborate the A.10 choices. They are not promoted into proof of proprietary
client behavior. No new external tool or binary was downloaded or executed. The review did not expand into
general modding research.

## 5. Effective client table gate

CLIENT_TABLE_GATE=PARTIAL. The full member paths, SHA-256 hashes, row counts and ID-set fingerprints are in
[the six-table R.1 revision](../audits/ULDuar_R1_EFFECTIVE_CLIENT_TABLES.json). All members are named
`DBFilesClient\<Table>.dbc`; archives are under the selected client's `Data/enUS` directory.

| Table | Conditional selected archive | Rows | SHA-256 |
| --- | --- | ---: | --- |
| Spell | patch-enUS-3.MPQ | 49839 | d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3 |
| SpellRange | patch-enUS-3.MPQ | 64 | 82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f |
| SpellCastTimes | patch-enUS-2.MPQ | 70 | 919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec |
| SpellVisual | patch-enUS-3.MPQ | 9406 | 966db0c9944068475b31d2584d5db88456d1ab26d0ca0658d75d048f1e00a601 |
| SpellIcon | patch-enUS-3.MPQ | 3226 | 2b12326641dba1554878b3f53c993e1211e50b3839ccdbeca378a23e7b3248db |
| SkillLineAbility | patch-enUS-3.MPQ | 10219 | 4154b833d6a26b9b9ce53851d56cb594f0813c0936a72ec89f933cc69abe42c3 |

Each remains CONDITIONAL, not EFFECTIVE_CLIENT_STATIC. The A.9 direct member inventory was reused only
with its preserved source/archive hashes. No archive was repacked or normalized. Negative Spell occupancy
was also screened across all inspected locale versions, so it does not depend on choosing one winner.

## 6. Exact 90000..90023 audit

[The per-ID result](../audits/ULDuar_R1_NAMESPACE_90000_90023.json) contains all 24 IDs separately, their
proposed family/copy index and negative screens. These are candidate records, not allocation ledger entries.

The decimal search covered selected core source/scripts, repository base/archive/old/update/pending SQL,
the abilities module and canonical addon. The hexadecimal spelling of the same interval was also searched:
no matches. Signed decimal occurrences were retained; they were not assumed to be unsigned identities.

The [raw search](../audits/ULDuar_R1_LITERAL_HITS.json) found 784 lines in 76 files. The
[typed review](../audits/ULDuar_R1_TYPED_REFERENCE_REVIEW.json) classifies every line:

| Classification | Lines | Meaning |
| --- | ---: | --- |
| FALSE_POSITIVE | 609 | Money, time, coordinates, effect magnitudes or comments |
| TEST_FIXTURE | 121 | Native test faction/cooldown data; tests were read, never run |
| OTHER_NAMESPACE | 54 | Creature GUID, menu/path keys and references |
| Actual Spell conflict / UNKNOWN literal line | 0 / 0 | No identified Spell identity conflict in those matches |

SQL tuple positions were associated with explicit INSERT column lists or the corresponding base CREATE
TABLE schema; UPDATE/DELETE matches were reviewed by named field. Important ambiguous-looking cases:

- `spell_dbc`: spell 27742 has EffectAuraPeriod_1=90000; spell 30521 has EffectBasePoints_1=-90001.
  Neither is a row ID or trigger Spell reference.
- `spell_proc`/`spell_proc_event` and cooldown overrides: 90000 is cooldown duration, not the Spell key.
- `trainer_spell`/`npc_trainer`: 90000 is MoneyCost. Item hits are prices, loot money or cooldowns;
  none is an item SpellID reference in the matched rows.
- SmartAI event fields are initial/repeat timers; action12 parameter3 is summon duration, action50
  parameter2 is object despawn time, action41 parameter1 is despawn delay. Source definitions are in
  `SmartScriptMgr.h:99-174,554-592`. Event-script command10 datalong2 is despawn delay (`ObjectMgr.h:105`).
- GameObject type10 Data3 is autoCloseTime, not the separate spellId field (`GameObjectData.h:160-176`).
- Native script matches are timed despawns or timers; test 90001/90002 values are faction fixtures.

| Authority / reference class | Result for the interval |
| --- | --- |
| Selected Spell.dbc, all inspected locale Spell copies | Empty row intersection; conservative union has 50,656 IDs |
| Base spell_dbc, conservative SQL overrides | Empty identity intersection; prior screens cover 4,491 / 4,554 IDs |
| spell_script_names, spell_proc, spell_bonus_data, spell_threat | No candidate identity/binding; proc duration hits classified above |
| conditions, spell ranks, trainer references | No candidate Spell reference found; trainer cost hits classified |
| SkillLineAbility Spell and SupercededBySpell | Direct binary field scan, columns2/8: empty intersection |
| Spell EffectTriggerSpell[0..2] | Direct binary field scan, columns116..118: empty intersection |
| Items, creatures/templates, SmartAI, script literals | No candidate Spell reference among reviewed hits; typed distinctions retained |
| Selected Ulduar module, addon, two pending files | No literal candidate claim or Spell allocator found |
| Prior bindings/reference guards | Empty intersections with 2,801 binding roots and 19,463 referenced numbers |

Binary scans used preserved B copies with hashes identical to the conditional selected members; no DBC was
extracted or written. The reference screens are bounded evidence, not execution of every historical migration.

## 7. Computed-reference audit

Result: **NO_COMPUTED_OWNER_FOUND_STATIC**, limited to reviewed source paths. This is not a theorem about
arbitrary expressions or foreign database contents.

[Computed-source evidence](../audits/ULDuar_R1_COMPUTED_REFERENCE_SEARCH.json) records 58 search sites,
their nearby context and named bases. Examples include native recall ranges60323..60335, pet service bases
67376/68849 plus0..2, pollen28703 plus0..4, shield63130 plus bounded stack indices, and native encounter
summon/rank offsets. No reviewed arithmetic site establishes ownership of 90000..90023.

`AbilityCarrierCatalog.cpp:GetPhaseA6CarrierCatalog` has native635 and custom entries without assigned
CarrierSpell values. Catalog order is allocation priority, not numeric generation. Manager/protocol rank
loops use GetNextSpellInChain; AbilityInstance IDs are a separate namespace. The addon consumes server/native
spell metadata; it is not an allocator. `SpellMgr.cpp:3022` constructs SpellInfo for loaded SpellEntry IDs
and skips sparse gaps; `DBCStores.cpp:240,355` loads the supplied spell_dbc overlay. Neither makes the gap owned.

[SQL-expression evidence](../audits/ULDuar_R1_SQL_EXPRESSION_SEARCH.json) narrows a lexical search to 59
statement lines: native Spell variables outside the interval, masks/magnitudes/GUID variables,
identity-preserving table/creature-spell projections, and prepared schema/character-data migrations.
The inspected PREPARE/EXECUTE strings do not allocate Spell identities. They were read as text only.
The two selected pending files bind known native roots or add character modifier columns.

Database-derived IDs remain subject to the canonical release and deployment admission. No blanket claim
is made that a search recognizes every possible encoding, macro or SQL transformation. This scoped result
does not replace missing historical ownership evidence.

## 8. Historical ownership audit

[The narrow historical inventory](../audits/ULDuar_R1_HISTORY_90000_90023.json) hashes 173 known local
editor registry/receipt/manifest and old-addon/reference files. It found no decimal or hexadecimal claim
to any SpellID in the proposed interval. No broad editor archaeology or offline-world search was repeated.

| Source group | Classification / relevance |
| --- | --- |
| M2 output registries and patch receipts | EXPERIMENT_UNKNOWN; local authorship/installation is not publication authority |
| Old UlduarAbilities metadata/source | EXPERIMENT_UNKNOWN; no candidate ownership found |
| WoW Spell Editor family metadata | REFERENCE_ONLY; not a Ulduar allocation ledger |
| F/M visual allocations retained from A.10 | NOT_SPELL_NAMESPACE; their historical uncertainty is not a Spell collision |
| Selected client patch-U | Asset-only for the probed primary tables; does not establish candidate Spell ownership |
| Published / rollback-supported allocation ledger | No authoritative source found in the reviewed evidence |

A.10 explicitly requires a maintainer-backed supported-publication/rollback statement or conservative
typed reconciliation before final reservation. No such statement was present in the reviewed documents.
The user was asked specifically about this interval; no attestation has been received at report completion.
No prior release is inferred retired. No undiscovered allocation is inferred absent.

## 9. Namespace gate

NAMESPACE_GATE=PARTIAL. It is not FAIL: no actual conflicting Spell owner was identified. It is not
PASS_STATIC: supported historical ownership has not been closed under the existing canonical policy.
Independently, CLIENT_TABLE_GATE remains PARTIAL. Both gates therefore follow outcome D: **no reservation**.

90023 is below the action-button exclusive 24-bit limit16777216. Relative to client maximum80864, an
ID-indexed representation adds9,159 positions; illustrative pointer storage is36,636 bytes at4 bytes or
73,272 at8 bytes. This is not a measurement of client memory. The base SQL source model already reaches
100102, so this interval does not raise its maximum index. Sparse extent is not collision proof.

No alternative range was searched or proposed. The allocation policy was not relaxed to accept conditional
inputs or missing history.

## 10. Ledger authority

LEDGER=NOT_WRITTEN. No authoritative existing ledger was found. The following is the required future
documentation format, not a ledger entry or reservation:

| Field | Contract |
| --- | --- |
| namespace / id | Typed table namespace and exact integer; Spell distinct from SpellVisual |
| owner | Single responsible Ulduar module/authority |
| specKey / family / copyIndex | Canonical transport specification and independent copy index0..5 |
| purpose | Transport identity ownership; no rank chain implied |
| releaseIntroduced | Explicit approved candidate/release identity; no fabricated published release |
| status | RESERVED, INTRODUCED, RETIRED_TOMBSTONE only |
| reservationRevision | Monotonic allocation decision revision |
| evidenceManifestHash | SHA-256 of closed reservation evidence |
| reservationDate | Actual successful reservation date |
| retirementRelease | Null until retirement; retirement never authorizes reuse while a supported release refers to it |
| notes | Limitations, provenance, superseding append-only events |

The eventual canonical ledger should use `docs/architecture/ULDuar_ID_ALLOCATION_LEDGER.md` with an optional
machine companion. Updates append events; old reservations and tombstones cannot be silently rewritten.
There is no FREE status. Absence from the ledger does not prove safety in an arbitrary environment.

## 11. Reservation mapping

No A.6/A.7/A.10 numeric ordering overrides the user's proposed mapping. A.6 has symbolic custom entries,
and A.10 explicitly assigned no per-family numeric mapping. Preserve this proposal if the gate later closes:

| Candidate IDs | Family | Copy indices | Current state |
| --- | --- | --- | --- |
| 90000..90005 | MeleeDamage | 0..5 | NOT_RESERVED |
| 90006..90011 | RangedProjectileDamage | 0..5 | NOT_RESERVED |
| 90012..90017 | MeleeHealing | 0..5 | NOT_RESERVED |
| 90018..90023 | RangedHealing | 0..5 | NOT_RESERVED |

All 24 proposed identities appear individually in the namespace audit. They are independent transport
copies, not ranks. No Spell row, catalog runtime entry, entitlement or teaching operation was emitted.

## 12. Reservation certificate

NOT_ISSUED. A failed-to-close gate must not produce a success-shaped reservation receipt.
The new release-evidence manifest records reviewed hashes and negative screens, not ownership.
A later successful certificate must include exact mappings, ledger revision/hash, all collision-source
fingerprints, computed/history results, 24-bit and sparse-index checks, and this requirement:

**DEPLOYMENT ENVIRONMENT MUST STILL PASS MANIFEST ADMISSION.**

RESERVED would mean identity ownership only. It would not mean the Spell exists, is known by a player,
is RuntimeEligible or has been demonstrated to execute correctly.

## 13. Deployment admission policy

MODEL B remains CANONICAL_RELEASE_MANIFEST. A future deployment must check client/package and effective
DBC hashes, selected module fingerprints, selected SQL/update state, effective Spell identities and foreign
references, and allocation-ledger revision. Unknown additions are not implicitly admitted.

If an environment uses any reserved candidate ID for another purpose: **FAIL CLOSED**. Do not overwrite,
delete or silently renumber. Reconcile explicitly before deployment. No admission tool was implemented.
NO_OFFLINE_EFFECTIVE_WORLD_SNAPSHOT remains an existing-world adoption/deployment input requirement;
it does not trigger another broad file search or a live database connection in R.1.

## 14. Artifact-authoring gate

ARTIFACT_AUTHORING_GATE=BLOCKED. All four semantic specifications remain statically serializable, but
zero IDs were reserved and effective client inputs remain conditional. Exact byte hashes alone do not
establish that those bytes are the selected client's effective tables.

Healing threat, original target intent and pre-native Potency injection remain frozen design proposals.
They were not implemented or declared solved by data. The same holds for runtime eligibility, lease
quarantine, cooldown authority and client acceptance. No source-seam or semantic phase was started.

## 15. Remaining blockers

1. **Client selection:** build-applicable native evidence for the unnumbered-versus-numbered locale patch
   rule. Existing tool conventions and the cited WotLK article are recorded, not discarded or overstated.
2. **Historical authority:** a responsible maintainer's supported-release/rollback statement for exactly
   Spell90000..90023, or manifests identifying/reconciling any prior owners. The local negative inventory is ready.

These are release/ownership evidence inputs, not requests to redesign carriers. Changed source/data hashes
would require reviewing the changed inputs before a later reservation decision. No claim of exhaustive
symbolic proof or arbitrary installed-world safety is made.

## 16. Exact next phase

Complete **R.1 evidence closure for the two inputs above**, then reevaluate the two independent gates against
the existing exact-interval audit and current hashes. Only a successful namespace decision may append the
24 reservations; artifact authoring additionally requires sufficiently pinned effective client inputs.
Do not begin another broad carrier-design audit. No next phase has been started automatically.

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO LIVE DATABASE WAS CONNECTED OR QUERIED.
NO SQL WAS EXECUTED OR MODIFIED.
NO DBC WAS GENERATED OR MODIFIED.
NO MPQ WAS GENERATED OR MODIFIED.
NO CLIENT PATCH WAS APPLIED.
NO CARRIER SPELL ROW WAS CREATED.
