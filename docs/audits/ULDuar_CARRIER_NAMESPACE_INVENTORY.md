# ULDuar A.8 namespace and preservation inventory

Date: 2026-09-19. SOURCE_ONLY. NAMESPACE_UNRESOLVED. No allocation ledger was written.

## Scope and reproducible evidence

[Main review](../implementation/ULDuar_PHASE_A8_EFFECTIVE_DATA_REVIEW.md).
[Raw inventory](ULDuar_A8_DATA_INVENTORY.json).
[External metadata/container inventory](ULDuar_A8_EXTERNAL_INVENTORY.json).
[Protected baseline](ULDuar_A8_PROTECTED_FILE_HASHES.json).

These are read-only audit inventories, not carrier manifests for a loader or production generators.
Paths, sizes and full SHA-256 hashes are recorded per discovered relevant data file in the JSON companions.
WDBC row sets, extrema and holes are decoded; SQL literal subsets are labelled separately from effective rows.
No ID absence in this inventory establishes availability. No live database was connected to or queried.

## Data sets

A=a/Data/dbc; B=ulduar-build/bin/RelWithDebInfo/Data/dbc;
E=WoW Spell Editor/DBC_335_wotlk; F=M2 Editor/output/phase9-frost-registry/DBFilesClient;
M=M2 Editor/output/arcane-shot-elements-registry/DBFilesClient. Paths are relative to C:/WoWProjecto.
A/B are UNKNOWN release authority; E and other-build editor inputs are REFERENCE_ONLY.
F/M are UNKNOWN supported-release status, with observed historical custom rows. No set is silently merged as TARGET.
The inventory initially found 68 relevant DBC files; 15 auxiliary dependency tables bring the total to 83.
The external inventory hashes 215 files, including 38 MPQ containers and supporting manifests/bindings.
It covers 17266391519 bytes. Hash equality groups in the JSON preserve duplicate evidence.

## Six primary namespaces

| Table | A rows | Min..max | Holes within extrema | Dependency decision |
| --- | --- | --- | --- | --- |
| Spell | 49839 | 1..80864 | 31025 | NEW_ROW_REQUIRED; IDs unresolved |
| SpellRange | 64 | 1..187 | 123 | REUSE_EXISTING 2/5 candidates |
| SpellCastTimes | 70 | 1..209 | 139 | REUSE_EXISTING 1/20 candidates |
| SpellVisual | 9406 | 1..16679 | 7273 | REUSE_EXISTING candidates; closure UNKNOWN |
| SpellIcon | 3226 | 1..4375 | 1149 | REUSE_EXISTING 257/237/682/70 candidates |
| SkillLineAbility | 10219 | 69..21980 | 11693 | OPTIONAL / client mapping UNKNOWN |

Range2=(min0/0,max5/5,flags1) supplies native contact reach; it is not a fixed five-yard center-distance rule.
Range5=(min0/0,max40/40,flags0). CastTimes1=(0,0,0), CastTimes20=(2500,0,2500).
Client friendly contact still needs evidence; do not allocate another range row solely because healing is friendly.
No new Range/CastTime/Icon row is presently justified. Visual reuse avoids new rows only after complete closure.
SkillLineAbility/custom skill-line allocation remains conditional, not an entitlement mechanism.

## Hash groups and observed row differences

### Spell

SHA-256: d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3

- a/Data/dbc/Spell.dbc; 48967121 bytes; 49839 rows; 1..80864.
- ulduar-build/bin/RelWithDebInfo/Data/dbc/Spell.dbc; 48967121 bytes; 49839 rows; 1..80864.

SHA-256: 7849dd756cf19366b39ca07dcfd633b08973cd53cc952d378747d6c543926fec

- WoW Spell Editor/DBC_112_vanilla/Spell.dbc; 16300699 bytes; 22351 rows; 1..32061.

SHA-256: 98fd9daf5e67c486a94d31d35acb5f0c81a6475cbb4ef08ae45401706e8b467a

- WoW Spell Editor/DBC_243_tbc/Spell.dbc; 25650628 bytes; 28315 rows; 1..53085.

SHA-256: 21f40898a37db6a6d298d9749e29ba3c3a36cb9da9ed1db2699a957080d90c53

- WoW Spell Editor/DBC_335_wotlk/Spell.dbc; 48967192 bytes; 49839 rows; 1..80864.

### SpellRange

SHA-256: 82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f

- a/Data/dbc/SpellRange.dbc; 11480 bytes; 64 rows; 1..187.
- ulduar-build/bin/RelWithDebInfo/Data/dbc/SpellRange.dbc; 11480 bytes; 64 rows; 1..187.
- WoW Spell Editor/DBC_335_wotlk/SpellRange.dbc; 11480 bytes; 64 rows; 1..187.

SHA-256: 8e45482ad8d4c913304062c2de202cf36f2c0babb9a0d2bdb2064983424a3f9e

- WoW Spell Editor/DBC_112_vanilla/SpellRange.dbc; 2979 bytes; 28 rows; 1..136.

SHA-256: 499d5ce507e054dc7b87a2a2f936a59e5e081f860254cfb4ef28395df390f805

- WoW Spell Editor/DBC_243_tbc/SpellRange.dbc; 5946 bytes; 35 rows; 1..157.

### SpellCastTimes

SHA-256: 919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec

- a/Data/dbc/SpellCastTimes.dbc; 1141 bytes; 70 rows; 1..209.
- ulduar-build/bin/RelWithDebInfo/Data/dbc/SpellCastTimes.dbc; 1141 bytes; 70 rows; 1..209.
- WoW Spell Editor/DBC_335_wotlk/SpellCastTimes.dbc; 1141 bytes; 70 rows; 1..209.

SHA-256: d80af2009fd1acd0a2c78a7af1604703c2639796ceb2267747c49f1d234ba27f

- WoW Spell Editor/DBC_112_vanilla/SpellCastTimes.dbc; 853 bytes; 52 rows; 1..191.

SHA-256: 8067ecf876a63172ab25d970aecf4054b73fd89437bc7b37bd6cbe5594fa6c1a

- WoW Spell Editor/DBC_243_tbc/SpellCastTimes.dbc; 981 bytes; 60 rows; 1..199.

### SpellVisual

SHA-256: 966db0c9944068475b31d2584d5db88456d1ab26d0ca0658d75d048f1e00a601

- a/Data/dbc/SpellVisual.dbc; 1203989 bytes; 9406 rows; 1..16679.
- ulduar-build/bin/RelWithDebInfo/Data/dbc/SpellVisual.dbc; 1203989 bytes; 9406 rows; 1..16679.

SHA-256: e9d969104c4b25140a0ad20c4679e29b1971063427a7195dee65645f42347584

- M2 Editor/output/arcane-shot-elements-registry/DBFilesClient/SpellVisual.dbc; 1204629 bytes; 9411 rows; 1..16684.

SHA-256: a579ef45b67655908c3efea9d92a342eb9515c20cec9b156d1a2427c41b08612

- M2 Editor/output/phase9-frost-registry/DBFilesClient/SpellVisual.dbc; 1204117 bytes; 9407 rows; 1..16680.

SHA-256: d201bc25cc5e70c53869e97d34ca908f4a6a7a82642e8e9306727c4cbf42bb7e

- WoW Spell Editor/DBC_112_vanilla/SpellVisual.dbc; 138581 bytes; 2165 rows; 1..7891.

SHA-256: 0dcf7b7665ede72fa1571e300a12ff40d9ba7fe6a629880414dff401b6b7fb4f

- WoW Spell Editor/DBC_243_tbc/SpellVisual.dbc; 474621 bytes; 4746 rows; 1..11460.

SHA-256: bae77dc8f953cc536188e5093a63bc47b5c2ac6ae21e5b06b5f9a65276f9ff8f

- WoW Spell Editor/DBC_335_wotlk/SpellVisual.dbc; 1204117 bytes; 9407 rows; 1..17000.

### SpellIcon

SHA-256: 2b12326641dba1554878b3f53c993e1211e50b3839ccdbeca378a23e7b3248db

- a/Data/dbc/SpellIcon.dbc; 151540 bytes; 3226 rows; 1..4375.
- ulduar-build/bin/RelWithDebInfo/Data/dbc/SpellIcon.dbc; 151540 bytes; 3226 rows; 1..4375.
- WoW Spell Editor/DBC_335_wotlk/SpellIcon.dbc; 151540 bytes; 3226 rows; 1..4375.

SHA-256: 938e8c333fe914938994fc331c04655d7eb5719bc2d1b29eaf5fad4239abdfdc

- WoW Spell Editor/DBC_112_vanilla/SpellIcon.dbc; 46442 bytes; 1033 rows; 1..2035.

SHA-256: f4551ffb617b4b86d3df031a376b8aab07882499e501c605c6ab5aba4f35b4ab

- WoW Spell Editor/DBC_243_tbc/SpellIcon.dbc; 77771 bytes; 1712 rows; 1..2717.

### SkillLineAbility

SHA-256: 4154b833d6a26b9b9ce53851d56cb594f0813c0936a72ec89f933cc69abe42c3

- a/Data/dbc/SkillLineAbility.dbc; 572285 bytes; 10219 rows; 69..21980.
- ulduar-build/bin/RelWithDebInfo/Data/dbc/SkillLineAbility.dbc; 572285 bytes; 10219 rows; 69..21980.

## SQL/source approximation

All 7,617 repository SQL files are protected by the baseline. Of them and module SQL, the keyword selection
identified 3369 relevant SQL source files. An inventory record does not imply an installed statement.
Another 123 base table files, including every additional *_dbc file and spell/skill support tables, have a separate
inventory. Their table keys are never automatically added to the Spell namespace.
Literal first-column extraction recognizes ordinary numeric ID-leading INSERT/REPLACE rows only. It does not
evaluate SQL, replay history, resolve variables or interpret every column order. Counts are a conservative textual
subset; UPDATE/DELETE and dynamic predicates remain UNKNOWN. Comments and archived sources require reconciliation.
The 4,491 base spell_dbc rows are a directly inspected conventional ID-leading definition set. A/B raw+base union
is 54,330. Other literal spell_dbc sources raise the observed override-ID set to 4,554; this includes history.
Seven current db_world spell_dbc update files were identified in A.7 and remain inventoried with hashes here:
2026_04_05_01, 2026_06_16_07, 2026_06_17_00, 2026_07_11_00, 2026_07_24_04, 2026_08_03_06, 2026_08_08_10.
No installed/applied update state is inferred. Pending Ulduar root bindings do not define custom Spell rows.

The source scan recorded 8141 lexical spell-reference sites. Enum names and call arguments
are potential REFERENCED evidence, not proven definitions. Non-ID enum values/synthetic test IDs can overapproximate;
this cannot be used as a free-ID certificate. Typed item and trainer extraction adds 25821 reference occurrences.
Base item_template spellid_1..5 were read for 46,096 conventional rows; npc_trainer SpellID for 4,934 rows.
Creature template records in this schema do not have those numbered spell columns; spell lists elsewhere remain
a missing effective-data class. Mount models alone do not identify a Spell. Conditions/SmartAI/script relationships
and item spell triggers require their typed effective export, not treating every number as a Spell ID.

The broad observed union is 54648 distinct candidate Spell numbers. It combines raw rows, literal SQL and references,
so it is neither a row count nor a precise installed namespace. Unknown sources remain outside this union.

| Occupancy class | Evidence | Limitation |
| --- | --- | --- |
| ROW_DEFINED | Loose DBC row IDs | Package authority unknown |
| SQL_OVERRIDE | Literal spell_dbc source rows | History/dynamic/effective ordering unresolved |
| SCRIPT_BOUND | spell_script_names numeric roots | Negative root means rank-chain semantics |
| REFERENCED | Source calls/enums; item/trainer spell fields | References do not create rows |
| EDITOR_RESERVED | Visual registry 16680..16684; editor row17000 | Observed use; no global reservation authority |
| HISTORICAL_PUBLISHED | No authoritative publication manifest established | Staged output is not publication proof |
| UNKNOWN | MPQ tables, effective DB, other modules/live editor history | Cannot declare gaps safe |

## Namespace resolution attempt

The contiguous-interval and explicit-ID alternatives both fail the same missing-evidence gates. Sparse gap counts
are reported above; none is promoted to PROPOSED_RESERVATION. No numeric production candidate is nominated.
Missing: pinned supported release, complete effective SQL export, effective MPQ tables/overlays and historical
allocation/publication reconciliation. This is NAMESPACE_UNRESOLVED, not NAMESPACE_RESOLVED_STATIC.
No max(ID)+1 rule is allowed. Action buttons impose a 24-bit value bound and sparse DBC loaders have memory costs.
Retain A.7 append-only allocation, explicit owner/spec/release/status and no reuse of introduced IDs.

## Editor and client evidence

Historical registry.json records build12340 and an enUS patch-enUS-3.MPQ input with hashes matching A.
Client/Data/patch-U.MPQ matches a staged output by container hash only where the external hash grouping says so.
That does not prove effective table contents, patch order, intended production release or complete dependency closure.
Specifically, it matches build-d2f8dda3/patch-U.MPQ and that staging manifest's declared archive hash:

    45e72ae9152f94290be0b3632c12a983a67a91edbd505b7540b74e5ac87b2497

The matching patch-manifest lists 16 M2/skin members under Spells/Ulduar/Projectiles and metadata (listfile),
with no declared DBC member. This is stronger manifest evidence for this one custom archive; it is not an
independent member decode or a complete effective-client inventory. Other archives/overlays still require review.
Client/Wow.exe reports 3,3,5,12340 in its version resource; Config.wtf sets enUS. Both are hashed separately
in the external inventory. Neither was executed or changed, and no account/connection settings were copied.
F/M custom visuals and dependent effect rows remain occupied until explicitly reconciled. The presence of backups
makes retirement assumptions unsafe. No external Ascension ID, rarity or AP value informs these namespaces.

## Preservation report

The [final comparison](ULDuar_A8_PRESERVATION_RESULT.json) records 9,724 initial protected files and 268 additional
external/dependency/client evidence files: 9,992 total, all byte-identical at their final comparison.
Existing files intentionally changed: 0. Removed files: 0. New documentation/audit files: 9.
MODIFIED_SOURCE=0; MODIFIED_SQL=0; MODIFIED_DBC=0; MODIFIED_CLIENT=0; MODIFIED_MPQ=0.
Existing unrelated files in the protected scope are unchanged. This is not a claim about uninspected workspace files.
The five pre-existing dirty core files and module's pre-existing deletions/untracked implementation remain intact.

New files under docs/:

- implementation/ULDuar_PHASE_A8_EFFECTIVE_DATA_REVIEW.md
- audits/ULDuar_CARRIER_NAMESPACE_INVENTORY.md
- audits/ULDuar_CARRIER_REFERENCE_ROWS.md
- audits/ULDuar_CARRIER_SPEC_COMPLETION_MATRIX.md
- audits/ULDuar_A8_DATA_INVENTORY.json
- audits/ULDuar_A8_EXTERNAL_INVENTORY.json
- audits/ULDuar_A8_PROTECTED_FILE_HASHES.json
- audits/ULDuar_A8_SPEC_MATRIX.json
- audits/ULDuar_A8_PRESERVATION_RESULT.json

Static documentation inspection confirmed 24 main sections, 204 matrix field rows (51 per family), readable audit
JSON, resolved local document links and the absence of trailing whitespace. This is not a project test execution.
