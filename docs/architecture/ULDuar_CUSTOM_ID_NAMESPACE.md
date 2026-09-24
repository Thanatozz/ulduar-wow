# ULDuar custom ID namespace policy

Date: 2026-09-19. Evidence: SOURCE_ONLY. NAMESPACE_STATUS: UNRESOLVED / NAMESPACE_UNRESOLVED.
Companion: [Phase A.7 carrier data specification](../implementation/ULDuar_PHASE_A7_CARRIER_DATA_SPEC.md).
This document defines policy and records observed occupancy. It allocates no ID or numeric interval.

## Scope and interpretation

Read-only discovery covered loose DBC files under C:/WoWProjecto, repository world SQL, pending Ulduar SQL,
all five local module directories, native/custom script references, Ulduar addon metadata and editor outputs.
SQL was read as text, never executed. WDBC headers/record IDs were decoded with Python struct from bytes;
no editor, extractor, project binary, generator, client or server was run. MPQ archives were not opened or modified.

USED means an ID is present in an inspected artifact or an identified reference; it does not mean deployed.
RESERVED means an explicit, authoritative allocation record exists. UNKNOWN means occupancy or release ownership
has not been established. Absence from one input is not FREE. Table IDs are typed: item/creature/visual IDs do not
directly consume Spell IDs, but their spell references do. These namespaces must never be conflated.

No existing project-wide append-only, release-aware numeric allocation ledger was found. A.5/A.6 prescribe a
future policy but do not reserve numbers. Editor-local registries record specific visual outputs, not a shared
Spell/Range/CastTime/Icon/SkillLineAbility allocation authority. Module ability-definition IDs and synthetic test
IDs are not reservations for client Spell.dbc.

## Loose DBC inventory

Paths below are relative to C:/WoWProjecto:

- A: `a/Data/dbc` — extracted data input; does not attest a currently loaded client.
- B: `ulduar-build/bin/RelWithDebInfo/Data/dbc` — deployed-build data copy, not evidence of a running server.
- E: `WoW Spell Editor/DBC_335_wotlk` — editor input/workspace, not authoritative production data.
- F: `M2 Editor/output/phase9-frost-registry/DBFilesClient` — generated historical visual artifact.
- M: `M2 Editor/output/arcane-shot-elements-registry/DBFilesClient` — historical multi-element visual artifact.

All inspected target rows use WDBC. Header lengths matched file lengths, and row IDs were unique in each file.
Min/max below are extrema of sparse sets, NOT occupied or free contiguous intervals.

| Table | A rows / observed extrema | B | E | Additional historical outputs |
| --- | --- | --- | --- | --- |
| Spell | 49,839 / 1..80864 | Byte-identical A | Same ID set; different contents | None found as loose Spell.dbc |
| SpellRange | 64 / 1..187 | Byte-identical A | Byte-identical A | None found |
| SpellCastTimes | 70 / 1..209 | Byte-identical A | Byte-identical A | None found |
| SpellVisual | 9,406 / 1..16679 | Byte-identical A | 9,407; adds 17000 | F adds 16680; M adds 16680..16684 |
| SpellIcon | 3,226 / 1..4375 | Byte-identical A | Byte-identical A | None found |
| SkillLineAbility | 10,219 / 69..21980 | Byte-identical A | File absent | None found |

The editor also contains DBC_112_vanilla and DBC_243_tbc copies of the first five tables: ten files belonging to
different client builds. They were discovered and hashed for preservation, excluded from WotLK occupancy conclusions.
There are 29 discovered loose copies of the six named tables: 19 target-build/artifact files plus those ten.

Spell.dbc record comparison: E and A differ in 49,836 raw records, mostly in fields 136..203 containing localized
text offsets/flags. Excluding that block leaves only Spell 5 differences at fields 102/103, EffectValueMultiplier
for the second/third effect (raw float bits 0 versus 1065353216). This is not proof that localized text is equivalent;
string blocks must be decoded and compared semantically in a later manifest review. Equal ID sets do not mean equal
rows. No E Spell row references visual 17000 in either visual slot, but its presence still marks it occupied.

M's element-map.json associates native Arcane Shot 3044 / visual 3299 with visual IDs 16680..16684 and visual-effect
IDs 7088..7092 for Frost/Fire/Nature/Holy/Shadow. F and M have identical raw visual row 16680 in this inspection.
This is shared historical content, not proof that a common allocator exists. Neither file attests active MPQ loading.
The visual-effect IDs belong to another dependent table and must also be audited before future asset allocation.

### Fingerprints of the observed row sets

Hashes cover complete files, including headers/string blocks. The exact USED row sets can be reconstructed from
these files; this inventory does not replace a future allocation audit's sorted row/reference sets.

```text
A/Spell.dbc (same B)
d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3
A/SpellRange.dbc (same B, E)
82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f
A/SpellCastTimes.dbc (same B, E)
919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec
A/SpellVisual.dbc (same B)
966db0c9944068475b31d2584d5db88456d1ab26d0ca0658d75d048f1e00a601
A/SpellIcon.dbc (same B, E)
2b12326641dba1554878b3f53c993e1211e50b3839ccdbeca378a23e7b3248db
A/SkillLineAbility.dbc (same B)
4154b833d6a26b9b9ce53851d56cb594f0813c0936a72ec89f933cc69abe42c3
E/Spell.dbc
21f40898a37db6a6d298d9749e29ba3c3a36cb9da9ed1db2699a957080d90c53
E/SpellVisual.dbc
bae77dc8f953cc536188e5093a63bc47b5c2ac6ae21e5b06b5f9a65276f9ff8f
F/SpellVisual.dbc
a579ef45b67655908c3efea9d92a342eb9515c20cec9b156d1a2427c41b08612
M/SpellVisual.dbc
e9d969104c4b25140a0ad20c4679e29b1971063427a7195dee65645f42347584
```

## SQL, source and client inventory

`data/sql/base/db_world/spell_dbc.sql` contains 4,491 literal row IDs, min 19, max 100102, with no ID intersection
with A's Spell.dbc. The combined observed set is therefore 54,330 Spell IDs. SQL rows above the DBC maximum are
100001, 100099, 100100, 100101 and 100102. This does not establish a free range above 100102 or in any gap.
Core source uses 100102 in `src/server/game/Maps/Map.cpp` and 100101 in
`src/server/scripts/Northrend/CrusadersColiseum/TrialOfTheCrusader/boss_twin_valkyr.cpp`.

Seven current db_world update files reference spell_dbc: 2026_04_05_01, 2026_06_16_07, 2026_06_17_00,
2026_07_11_00, 2026_07_24_04, 2026_08_03_06 and 2026_08_08_10. They edit effective targets, effects, ranges,
triggers and related conditions/scripts. Files on disk do not reveal which updates/extra custom SQL are installed.
The base spellrange_dbc, spellcasttimes_dbc, spellvisual_dbc and skilllineability_dbc files contain zero literal data
rows; no references to those table names were found in the inspected updates/module SQL. Their live contents remain
UNKNOWN. There is no base spellicon_dbc file in this checkout.

DBCStores.cpp loads these mapped DB tables after file data. DBCDatabaseLoader.cpp explicitly replaces matching
row indices and sizes the index by maximum ID + 1. High sparse IDs therefore need a storage-capacity and overflow
review as well as collision review; native packet uint32 capacity is not sufficient allocation evidence.

Ulduar's pending world starter SQL binds existing native rank roots to scripts; the module's original world SQL
binds Frostbolt. Neither creates custom Spell rows. Pending character modifier SQL does not allocate carrier IDs.
The five local module directories are mod-ulduar-abilities, mod-ulduar-editor, mod-ulduar-wave-survival,
mod-density-test and mod-citybuilder. Source/SQL search found no documented shared carrier-ID reservation there.
The citybuilder skeleton's 35410 is an acore_string key, not a Spell reservation. Editor object operations and
wave/density creature state are separate domains; live content created through them is outside this file inventory.

Ulduar addon Lua receives spellID values for presentation and references existing native spells for icons/tooltips;
it is not a carrier allocation ledger. Custom mount/item models/icons found in asset trees do not prove matching
Spell or item rows. Their effective row associations and any live mount/item grants remain UNKNOWN. No SQL files
were discovered outside the local AzerothCore/TrinityCore/reference repository trees in the workspace SQL search.
That observation does not exclude packed data, exported non-SQL formats or a live DB's custom rows.

`Client/Data/patch-U.MPQ` and other base/patch/locale MPQs exist; their effective Spell tables/load order were not
inspected through an archive reader. Work/ascension and Ascension-data contain external reference assets/addons and
patches. They are not Ulduar ID authorities. HeroFreePick filenames were not located in the workspace filename
search; its permitted conceptual UI/progression-reference role does not depend on locating or importing its code.
Neither third-party IDs nor Ability Essence/rarity metadata may seed allocations.

| Namespace | USED evidence | RESERVED evidence | UNKNOWN / allocation blocker |
| --- | --- | --- | --- |
| Spell | Raw rows + SQL rows + script/addon references | No authoritative Ulduar interval | Effective DB/MPQ/releases |
| SpellRange | 64 observed WotLK rows | None established | Effective DB and client overlays |
| SpellCastTimes | 70 observed WotLK rows | None established | Effective DB and client overlays |
| SpellVisual | Base plus 16680..16684 and 17000 | Editor occupancy, no shared reservation | MPQ/dependency ownership |
| SpellIcon | 3,226 observed rows | None established | Packed/client-specific records |
| SkillLineAbility | 10,219 observed rows | None established | Effective DB/skill-line projection |

All unproven IDs remain UNKNOWN, not tentatively available. Historical/test/reference artifacts are distinct from
production allocation evidence, but observed Ulduar artifacts must be reconciled before declaring an interval safe.

## Required allocation ledger

DESIGN ONLY; no production JSON/SQL or numeric reservation is created.

```text
UlduarIdAllocationEvent
  eventId, ledgerSchemaVersion, ledgerRevision, previousEventHash
  tableType, id                       # typed, nonzero, range-checked; absent until actual reservation
  ownerModule, responsibleMaintainer
  allocationDateUTC, purpose, specKey/specVersion, envelopeKey, copyIndex
  introducedRelease, retiredRelease   # explicit not-yet-introduced/not-retired states
  status, compatibilityStatus, supportedReleaseSet
  collisionAuditId/hash, inputManifestHashes, provenance, reviewRecord
  eventType, supersedesEventId, reason
```

Require every field or an explicit not-applicable/not-yet-known status at its lifecycle stage. Planned symbolic
requests are not allocated entries. Status events: REQUESTED -> RESERVED -> INTRODUCED -> DEPRECATED -> RETIRED;
ABANDONED and CONFLICTED are terminal exclusion records, not deletion or automatic recycling. A historical use can
be adopted only after ownership/release provenance review. Correct errors by appended superseding events.

One serialized allocator/reviewer owns the shared ledger; modules request capacity and never compute max(ID)+1.
Uniqueness key is (tableType,id) across all owners/releases. An atomic reservation batch names every ID, copy and
dependency and retains audit hashes. Disjoint owner blocks are allowed only after a complete collision audit.
Simultaneous module requests must be serialized against the same ledger revision; stale audits cannot reserve.

No reuse while any supported release, rollback package, ownership/projection record, queued operation or retained
artifact can reference the ID. Default Ulduar policy is never recycle introduced IDs. Retirement ends publication,
not identity history. Abandoned reserved IDs remain tombstoned until an explicit future policy is reviewed; this
document does not authorize their reuse. Never reinterpret an old SpellID as a different family on an old package.

Reuse of a native Range/CastTime/Visual/Icon reference is a dependency declaration, not a new allocation. Keep its
content hash/version in the manifest. If a reference must change, allocate a new reviewed row rather than mutate
a globally shared native row. Rank-chain and cooldown-category IDs need their own review; numeric equality across
different tables is not itself a collision. Packet field width alone does not prove client/store limits are safe.

## Collision audit required before reservation

1. Name the supported client build, locales, complete effective MPQ/DBC package and overlay order, with hashes.
2. Obtain an authorized read-only effective-world-data export including DBC override tables, scripts, conditions,
   procs, ranks/learning, item/mount spell references, creature casts and all installed custom modules.
3. Record applied update versions, core/module revisions and supported historical/rollback manifests.
4. Inventory all editor outputs and allocations across modules; reconcile 16680..16684/17000 provenance.
5. Decode typed ID sets and references, not untyped numbers from text; resolve SQL variables, negative rank-root
   references, ranges and generated assignments without executing SQL. Unknown dynamic references block approval.
6. Audit client/store/wire representability, sparse-store memory implications, dependency namespaces and capacity.
7. Prove candidate sets disjoint from the union of observed use, reservations, retired/tombstoned IDs and references.
8. Record reviewed sets, manifest hashes, interval rationale, owner and ledger revision; append reservation atomically.

Current inputs cannot satisfy steps 1–4 or complete effective interpretation. NAMESPACE_UNRESOLVED is the required
outcome. Later non-data planning may use the four symbolic spec keys; production IDs and emitting carrier rows must
wait. No final numeric interval is recommended from high-number heuristics.
