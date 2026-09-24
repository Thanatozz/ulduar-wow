# Ulduar talent conversion pipeline and source-rank ledger

Status: tool design plus read-only DBC inventory, 2026-09-14. No production converter or runtime code implemented.
The inventory below was generated with a temporary in-memory Python inspection, without executing game code.

## Input corpus and provenance

Primary local directory: `C:/WoWProjecto/ulduar-build/bin/RelWithDebInfo/Data/dbc/`.
This is the locally available corpus, not independently certified as pristine retail data. Other local Spell.dbc
copies exist; do not mix them implicitly. Preserve source checksums and locale/build metadata in every import.

| File | Rows | Fields | Record bytes | SHA-256 |
| --- | --- | --- | --- | --- |
| Talent.dbc | 892 | 23 | 92 | `23aefff3add151bf504c4d0bab247e2e622f9cf29a473d091cb9f11127d99d68` |
| TalentTab.dbc | 33 | 24 | 96 | `b9249642e06b2baa17793e50e6719f33b1f89729f6c31ea623d4a39e84660e31` |
| Spell.dbc | 49839 | 234 | 936 | `d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3` |
| SpellIcon.dbc | 3226 | 2 | 8 | `2b12326641dba1554878b3f53c993e1211e50b3839ccdbeca378a23e7b3248db` |

Verified WDBC magic, record/field widths and referential presence for every nonzero talent rank SpellID.
There are 2,358 `(TalentID, rank)` entries and 2,310 unique rank SpellIDs. Shared IDs must not be collapsed before
source mapping; pet trees can share native ranks. All 33 tabs are retained, including three pet talent tabs.

The layout is verified against
[DBCStructure.h](../../src/server/shared/DataStores/DBCStructure.h) and
[DBCfmt.h](../../src/server/shared/DataStores/DBCfmt.h). Talent fields 4..8 hold five native rank slots;
13 and 16 hold first prerequisite talent/rank. TalentTab fields 20/21 distinguish class and pet masks.
Spell fields 71..73, 95..97, 98..100, 110..118 and 122..130 carry per-effect operation/aura/time/misc/trigger/masks;
136..151 name and 170..185 description string offsets. Parse signed values and floats by schema, not as unsigned
gameplay amounts. SpellBasePoints often needs native CalcValue semantics; raw field plus one is not universal.

## Designed processing stages

1. **Import:** validate signature, exact record size, counts, endianness, bounded string offsets/terminators,
   duplicate IDs and referential integrity. Read all nonzero rank slots. Retain empty slots as provenance.
   Preserve original class/tab/row/column without installing them as restrictions.
2. **Native analysis:** join Spell.dbc, SpellIcon, SpellCastTimes, SpellDuration, SpellRange, SpellRadius,
   SpellRuneCost and SkillLineAbility. Join native rank chains, `spell_proc`, `spell_bonus_data`, `spell_threat`,
   `spell_script_names`, conditions and SpellMgr corrections. Follow controller/trigger/learn-spell edges with
   cycle/depth detection. Report every unavailable input; no database was queried during this audit.
3. **Source selector reconstruction:** for ADD_FLAT/PCT_MODIFIER resolve SpellModOp, family and 96-bit masks to
   actual affected native spells/effects. Compare that set to candidate predicates over Ulduar metadata. Evaluate
   false positives and negatives; a large source ID set is offline evidence, not a runtime allowlist.
4. **Semantic classification:** identify subject, operation, event, condition, mechanic identity and scale basis.
   Inspect native scripts and proc data. Assign classification plus blockers, and a distinct semantic confidence.
   A passive aura's school/family does not determine the target selector. Never use tooltip keyword replacement
   as sole evidence. A source rank changing its operation gets an explicit rank-specific semantic branch.
5. **Candidate generation:** emit normalized selector/trigger/condition/effect/modifier ASTs and full rank values.
   Preserve source references and unresolved edges; mark unsupported output unpublishable. Active talents produce
   ability-grant effects through classless ownership, not disguised passive auras.
6. **Confidence and review:** score evidence, ambiguity and adapter coverage, attach counterexamples and affected
   source sets. Route uncertain behavior to humans. Semantic review and runtime support validation are independent.
7. **Canonicalization:** compare normalized semantics, rank curves, subjects, event policies and limits. Alias only
   proven equivalents. Keep split mappings and redundancy reasons; no source talent/rank may vanish.
8. **Validation/publication:** schema/type/unit validation, acyclic dependencies/conversions, adapter manifest,
   rank budget checks, corpus coverage, trace fixtures, balance review and native/Ulduar double-application audit.
   Only a reviewed catalog version can be enabled. Retain prior versions and reproducible rollback mapping.

Future tool invocation could be `audit`, `candidates`, `review`, `validate`, `publish-artifact` subcommands; no
runtime database import is implicit in generating an artifact. Inputs, tool version, core revision, schema version,
review overrides and output hashes define a deterministic build. Re-running unchanged inputs gives identical IDs
and candidate payloads, excluding report timestamps.

## Confidence model

Proposed integer score 0..100: source operation understood (0..25), source target-set reconstruction (0..25),
script/proc dependency review (0..25), rank consistency/evidence agreement (0..25). Store each component and reason.

| Confidence | Threshold | Review policy |
| --- | --- | --- |
| HIGH | >=90, no unknown operation/script/edge | Automatic candidate generation; publication still needs approval |
| MEDIUM | 60..89, bounded semantic ambiguity | Human reviews selector expansion, coefficients and side effects |
| LOW | <60 or any opaque script/missing critical data | Explicit semantic review; no automatic playable definition |

Hard gates override the score: unsupported adapter, unresolved dependency, unsafe target conversion, missing proc
filter, unknown cost basis or contradictory rank semantics prevents publication. High confidence does not mean
implemented. A simple school-damage aura can be HIGH after checking masks and scripts yet still NEEDS_ENGINE_SUPPORT
until the generic executor exists.

Human review is required for name-to-mechanic expansion, family-mask source sets with mixed intent, weapon/form
restrictions, pet ownership, triggered cost provenance, proc merging, shields, resource conversion, multi-effect
talents, active grants, duplicate equivalence, legacy script behavior and new balance trade-offs.

## Candidate artifact and coverage invariants

```text
sourceKey = corpusHash/TalentID/rank/SpellID
rawSource = tab, classMask, petMask, family, effect slots, masks, trigger edges, native prerequisites
candidate = canonicalDefinition?, rank, selectors[], triggers[], conditions[], modifiers[], effects[]
assessment = classification, candidateSemanticClass?, confidence, scoreBreakdown, blockers[], reviewer, reason
trace = sourceSet, expectedGeneralizedSet, additions[], losses[], nativeScriptRefs[], adapterRequirements[]
```

Coverage must satisfy `sourceRankCount = mapped + unresolved + explicitlyInvalid`, with pairwise disjoint source
keys. A mapping to multiple effects is counted once by source key. Every rank has exactly one classification and
review state. Unknown/unsupported categories get counts and individual rows. Native rank IDs shared between pet
tabs remain separate source records; canonicalization is a later reviewed decision.

Fixture groups for later implementation: direct/periodic healing; Fire direct plus Frost slow false match;
weapon/finisher; controller projectile ticks; field/cone/line; shield; pet/totem/trap; stealth; rune/combo;
base-cost refund proc; effect-index changes across ranks; script-only behavior; duplicates and removed talents.
Validate all classes and pet tabs. No tests requiring a build are part of this documentation phase.

## Audit ledger interpretation

The appended ledger enumerates every local Talent.dbc rank. All entries have current classification
`NEEDS_ENGINE_SUPPORT` (shown as **N** in rows), blocker **G0**: universal ownership, selectors and character rule
execution do not yet exist. This is a conservative current implementation status, not a completed semantic
conversion. All have semantic confidence **LOW**, review state **PENDING**, and no published candidate.
No entry is silently INVALID_OR_REDUNDANT. Future review assigns candidate semantic classes and additional
blockers, then updates classification when the required engine exists.

Routing codes below are evidence-based triage, not inferred selectors. Multiple routes can apply to one rank:

| Route | Source evidence | Required review |
| --- | --- | --- |
| F | Aura 107/108 (native flat/percent family modifier) | Reconstruct family-mask source set and SpellModOp |
| P | Proc flags, trigger spell edge, proc aura 42/231 | Event basis, trigger graph, ICD and recursion |
| X | Dummy/script effect or dummy aura | Native script and data binding review |
| M | Pet tab, equipment/form requirement or native mechanic field | Preserve subject/mechanic restriction |
| A | Native learn-spell effect | Active ability grant, rank and entitlement ownership |
| V | Other parsed operation | Typed magnitude/target/lifecycle and native script check |

Each row lists slot `index:effect/aura` from Spell.dbc; zeros are omitted. This is enough to locate a native
operation, not enough to infer its gameplay intent. Source class/tab are printed in group headings for developer
traceability only. The following inventory is source-complete for the checksummed corpus, semantically unreviewed.

## Complete source inventory

| Origin | Talents | Rank entries |
| --- | --- | --- |
| Death Knight | 88 | 231 |
| Druid | 85 | 233 |
| Hunter | 81 | 227 |
| Mage | 86 | 228 |
| Paladin | 78 | 211 |
| Pet | 63 | 115 |
| Priest | 82 | 220 |
| Rogue | 83 | 224 |
| Shaman | 80 | 225 |
| Warlock | 81 | 216 |
| Warrior | 85 | 228 |
| **Total** | **892** | **2358** |

Classification totals: NEEDS_ENGINE_SUPPORT = 2358; FULL_GENERIC = 0; MECHANIC_GENERIC = 0;
LEGACY_SPECIAL = 0; INVALID_OR_REDUNDANT = 0. These are current implementation classifications, not semantic verdicts.

Review-route counts overlap: A=20, F=1053, M=363, P=646, V=413, X=389.

Row key is `TalentID/rank`; rank is one-based. Every N row inherits G0, LOW and PENDING as defined above.

### Mage: Fire (source tab 41)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 23/1 | 11083 | Burning Soul | 0:6/108,1:6/10 | N | F |
| 23/2 | 12351 | Burning Soul | 0:6/108,1:6/10 | N | F |
| 24/1 | 11094 | Molten Shields | 0:6/107 | N | F |
| 24/2 | 13043 | Molten Shields | 0:6/107 | N | F |
| 25/1 | 11095 | Improved Scorch | 0:6/42,1:6/107 | N | FP |
| 25/2 | 12872 | Improved Scorch | 0:6/42,1:6/107 | N | FP |
| 25/3 | 12873 | Improved Scorch | 0:6/42,1:6/107 | N | FP |
| 26/1 | 11069 | Improved Fireball | 0:6/107 | N | F |
| 26/2 | 12338 | Improved Fireball | 0:6/107 | N | F |
| 26/3 | 12339 | Improved Fireball | 0:6/107 | N | F |
| 26/4 | 12340 | Improved Fireball | 0:6/107 | N | F |
| 26/5 | 12341 | Improved Fireball | 0:6/107 | N | F |
| 27/1 | 11078 | Improved Fire Blast | 0:6/107 | N | F |
| 27/2 | 11080 | Improved Fire Blast | 0:6/107 | N | F |
| 28/1 | 11100 | Flame Throwing | 0:6/107 | N | F |
| 28/2 | 12353 | Flame Throwing | 0:6/107 | N | F |
| 29/1 | 11366 | Pyroblast | 0:2/0,1:6/3 | N | V |
| 30/1 | 11103 | Impact | 0:6/42 | N | P |
| 30/2 | 12357 | Impact | 0:6/42 | N | P |
| 30/3 | 12358 | Impact | 0:6/42 | N | P |
| 31/1 | 11108 | World in Flames | 0:6/107 | N | F |
| 31/2 | 12349 | World in Flames | 0:6/107 | N | F |
| 31/3 | 12350 | World in Flames | 0:6/107 | N | F |
| 32/1 | 11113 | Blast Wave | 0:2/0,1:6/33,2:98/0 | N | M |
| 33/1 | 11115 | Critical Mass | 0:6/71 | N | V |
| 33/2 | 11367 | Critical Mass | 0:6/71 | N | V |
| 33/3 | 11368 | Critical Mass | 0:6/71 | N | V |
| 34/1 | 11119 | Ignite | 0:6/4 | N | PX |
| 34/2 | 11120 | Ignite | 0:6/4 | N | PX |
| 34/3 | 12846 | Ignite | 0:6/4 | N | PX |
| 34/4 | 12847 | Ignite | 0:6/4 | N | PX |
| 34/5 | 12848 | Ignite | 0:6/4 | N | PX |
| 35/1 | 11124 | Fire Power | 0:6/108,1:6/108 | N | F |
| 35/2 | 12378 | Fire Power | 0:6/108,1:6/108 | N | F |
| 35/3 | 12398 | Fire Power | 0:6/108,1:6/108 | N | F |
| 35/4 | 12399 | Fire Power | 0:6/108,1:6/108 | N | F |
| 35/5 | 12400 | Fire Power | 0:6/108,1:6/108 | N | F |
| 36/1 | 11129 | Combustion | 0:6/108,1:64/0 | N | FP |
| 1141/1 | 18459 | Incineration | 0:6/107 | N | F |
| 1141/2 | 18460 | Incineration | 0:6/107 | N | F |
| 1141/3 | 54734 | Incineration | 0:6/107 | N | F |
| 1639/1 | 29074 | Master of Elements | 0:6/4 | N | PX |
| 1639/2 | 29075 | Master of Elements | 0:6/4 | N | PX |
| 1639/3 | 29076 | Master of Elements | 0:6/4 | N | PX |
| 1730/1 | 31638 | Playing with Fire | 0:6/79,1:6/87 | N | V |
| 1730/2 | 31639 | Playing with Fire | 0:6/79,1:6/87 | N | V |
| 1730/3 | 31640 | Playing with Fire | 0:6/79,1:6/87 | N | V |
| 1731/1 | 31641 | Blazing Speed | 0:6/42 | N | P |
| 1731/2 | 31642 | Blazing Speed | 0:6/42 | N | P |
| 1732/1 | 31679 | Molten Fury | 0:6/112 | N | V |
| 1732/2 | 31680 | Molten Fury | 0:6/112 | N | V |
| 1733/1 | 34293 | Pyromaniac | 0:6/71,1:6/134 | N | V |
| 1733/2 | 34295 | Pyromaniac | 0:6/71,1:6/134 | N | V |
| 1733/3 | 34296 | Pyromaniac | 0:6/71,1:6/134 | N | V |
| 1734/1 | 31656 | Empowered Fire | 0:6/107 | N | FP |
| 1734/2 | 31657 | Empowered Fire | 0:6/107 | N | FP |
| 1734/3 | 31658 | Empowered Fire | 0:6/107 | N | FP |
| 1735/1 | 31661 | Dragon's Breath | 0:2/0,1:6/5,2:6/33 | N | PM |
| 1848/1 | 64353 | Fiery Payback | 0:36/0,1:36/0 | N | PA |
| 1848/2 | 64357 | Fiery Payback | 0:36/0,1:36/0 | N | PA |
| 1849/1 | 44442 | Firestarter | 0:6/42 | N | P |
| 1849/2 | 44443 | Firestarter | 0:6/42 | N | P |
| 1850/1 | 44445 | Hot Streak | 0:6/4,1:6/4 | N | PX |
| 1850/2 | 44446 | Hot Streak | 0:6/4,1:6/4 | N | PX |
| 1850/3 | 44448 | Hot Streak | 0:6/4,1:6/4 | N | PX |
| 1851/1 | 44449 | Burnout | 0:6/108,1:6/4 | N | FPX |
| 1851/2 | 44469 | Burnout | 0:6/108,1:6/4 | N | FPX |
| 1851/3 | 44470 | Burnout | 0:6/108,1:6/4 | N | FPX |
| 1851/4 | 44471 | Burnout | 0:6/108,1:6/4 | N | FPX |
| 1851/5 | 44472 | Burnout | 0:6/108,1:6/4 | N | FPX |
| 1852/1 | 44457 | Living Bomb | 0:6/3,1:6/4 | N | X |
| 2212/1 | 54747 | Burning Determination | 0:6/42 | N | P |
| 2212/2 | 54749 | Burning Determination | 0:6/42 | N | P |

### Mage: Frost (source tab 61)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 37/1 | 11070 | Improved Frostbolt | 0:6/107 | N | F |
| 37/2 | 12473 | Improved Frostbolt | 0:6/107 | N | F |
| 37/3 | 16763 | Improved Frostbolt | 0:6/107 | N | F |
| 37/4 | 16765 | Improved Frostbolt | 0:6/107 | N | F |
| 37/5 | 16766 | Improved Frostbolt | 0:6/107 | N | F |
| 38/1 | 11071 | Frostbite | 0:6/109 | N | P |
| 38/2 | 12496 | Frostbite | 0:6/109 | N | P |
| 38/3 | 12497 | Frostbite | 0:6/109 | N | P |
| 61/1 | 11151 | Piercing Ice | 0:6/79 | N | V |
| 61/2 | 12952 | Piercing Ice | 0:6/79 | N | V |
| 61/3 | 12953 | Piercing Ice | 0:6/79 | N | V |
| 62/1 | 31670 | Ice Floes | 0:6/108 | N | F |
| 62/2 | 31672 | Ice Floes | 0:6/108 | N | F |
| 62/3 | 55094 | Ice Floes | 0:6/108 | N | F |
| 63/1 | 11185 | Improved Blizzard | 0:6/112 | N | V |
| 63/2 | 12487 | Improved Blizzard | 0:6/112 | N | V |
| 63/3 | 12488 | Improved Blizzard | 0:6/112 | N | V |
| 64/1 | 11190 | Improved Cone of Cold | 0:6/108 | N | F |
| 64/2 | 12489 | Improved Cone of Cold | 0:6/108 | N | F |
| 64/3 | 12490 | Improved Cone of Cold | 0:6/108 | N | F |
| 65/1 | 11175 | Permafrost | 0:6/107,1:6/107,2:6/107 | N | FP |
| 65/2 | 12569 | Permafrost | 0:6/107,1:6/107,2:6/107 | N | FP |
| 65/3 | 12571 | Permafrost | 0:6/107,1:6/107,2:6/107 | N | FP |
| 66/1 | 11160 | Frost Channeling | 0:6/72,1:6/10 | N | V |
| 66/2 | 12518 | Frost Channeling | 0:6/72,1:6/10 | N | V |
| 66/3 | 12519 | Frost Channeling | 0:6/72,1:6/10 | N | V |
| 67/1 | 11170 | Shatter | 0:6/112 | N | V |
| 67/2 | 12982 | Shatter | 0:6/112 | N | V |
| 67/3 | 12983 | Shatter | 0:6/112 | N | V |
| 68/1 | 11180 | Winter's Chill | 0:6/42,1:6/107 | N | FP |
| 68/2 | 28592 | Winter's Chill | 0:6/42,1:6/107 | N | FP |
| 68/3 | 28593 | Winter's Chill | 0:6/42,1:6/107 | N | FP |
| 69/1 | 12472 | Icy Veins | 0:6/65,1:6/108 | N | F |
| 70/1 | 11189 | Frost Warding | 0:6/108,1:3/0 | N | FX |
| 70/2 | 28332 | Frost Warding | 0:6/108,1:3/0 | N | FX |
| 71/1 | 11426 | Ice Barrier | 0:6/69 | N | V |
| 72/1 | 11958 | Cold Snap | 0:3/0 | N | X |
| 73/1 | 11207 | Ice Shards | 0:6/108 | N | F |
| 73/2 | 12672 | Ice Shards | 0:6/108 | N | F |
| 73/3 | 15047 | Ice Shards | 0:6/108 | N | F |
| 741/1 | 16757 | Arctic Reach | 0:6/108,1:6/108 | N | F |
| 741/2 | 16758 | Arctic Reach | 0:6/108,1:6/108 | N | F |
| 1649/1 | 29438 | Precision | 0:6/55,1:6/72 | N | V |
| 1649/2 | 29439 | Precision | 0:6/55,1:6/72 | N | V |
| 1649/3 | 29440 | Precision | 0:6/55,1:6/72 | N | V |
| 1736/1 | 31667 | Frozen Core | 0:6/87 | N | V |
| 1736/2 | 31668 | Frozen Core | 0:6/87 | N | V |
| 1736/3 | 31669 | Frozen Core | 0:6/87 | N | V |
| 1737/1 | 55091 | Cold as Ice | 0:6/108 | N | F |
| 1737/2 | 55092 | Cold as Ice | 0:6/108 | N | F |
| 1738/1 | 31674 | Arctic Winds | 0:6/184,1:6/185,2:6/79 | N | V |
| 1738/2 | 31675 | Arctic Winds | 0:6/184,1:6/185,2:6/79 | N | V |
| 1738/3 | 31676 | Arctic Winds | 0:6/184,1:6/185,2:6/79 | N | V |
| 1738/4 | 31677 | Arctic Winds | 0:6/184,1:6/185,2:6/79 | N | V |
| 1738/5 | 31678 | Arctic Winds | 0:6/184,1:6/185,2:6/79 | N | V |
| 1740/1 | 31682 | Empowered Frostbolt | 0:6/107,1:6/107 | N | F |
| 1740/2 | 31683 | Empowered Frostbolt | 0:6/107,1:6/107 | N | F |
| 1741/1 | 31687 | Summon Water Elemental | 0:3/0 | N | X |
| 1853/1 | 44543 | Fingers of Frost | 0:6/42 | N | P |
| 1853/2 | 44545 | Fingers of Frost | 0:6/42 | N | P |
| 1854/1 | 44546 | Brain Freeze | 0:6/42 | N | P |
| 1854/2 | 44548 | Brain Freeze | 0:6/42 | N | P |
| 1854/3 | 44549 | Brain Freeze | 0:6/42 | N | P |
| 1855/1 | 44557 | Enduring Winter | 0:6/107,1:6/42 | N | FP |
| 1855/2 | 44560 | Enduring Winter | 0:6/107,1:6/42 | N | FP |
| 1855/3 | 44561 | Enduring Winter | 0:6/107,1:6/42 | N | FP |
| 1856/1 | 44566 | Chilled to the Bone | 0:6/108,1:6/107 | N | F |
| 1856/2 | 44567 | Chilled to the Bone | 0:6/108,1:6/107 | N | F |
| 1856/3 | 44568 | Chilled to the Bone | 0:6/108,1:6/107 | N | F |
| 1856/4 | 44570 | Chilled to the Bone | 0:6/108,1:6/107 | N | F |
| 1856/5 | 44571 | Chilled to the Bone | 0:6/108,1:6/107 | N | F |
| 1857/1 | 44572 | Deep Freeze | 0:6/12 | N | M |
| 2214/1 | 44745 | Shattered Barrier | 0:6/4 | N | X |
| 2214/2 | 54787 | Shattered Barrier | 0:6/4 | N | X |

### Mage: Arcane (source tab 81)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 74/1 | 11210 | Arcane Subtlety | 0:6/10,1:6/107 | N | F |
| 74/2 | 12592 | Arcane Subtlety | 0:6/10,1:6/107 | N | F |
| 75/1 | 11213 | Arcane Concentration | 0:6/42 | N | P |
| 75/2 | 12574 | Arcane Concentration | 0:6/42 | N | P |
| 75/3 | 12575 | Arcane Concentration | 0:6/42 | N | P |
| 75/4 | 12576 | Arcane Concentration | 0:6/42 | N | P |
| 75/5 | 12577 | Arcane Concentration | 0:6/42 | N | P |
| 76/1 | 11222 | Arcane Focus | 0:6/107,1:6/72 | N | F |
| 76/2 | 12839 | Arcane Focus | 0:6/107,1:6/72 | N | F |
| 76/3 | 12840 | Arcane Focus | 0:6/107,1:6/72 | N | F |
| 77/1 | 11232 | Arcane Mind | 0:6/137 | N | V |
| 77/2 | 12500 | Arcane Mind | 0:6/137 | N | V |
| 77/3 | 12501 | Arcane Mind | 0:6/137 | N | V |
| 77/4 | 12502 | Arcane Mind | 0:6/137 | N | V |
| 77/5 | 12503 | Arcane Mind | 0:6/137 | N | V |
| 80/1 | 11237 | Arcane Stability | 0:6/108 | N | F |
| 80/2 | 12463 | Arcane Stability | 0:6/108 | N | F |
| 80/3 | 12464 | Arcane Stability | 0:6/108 | N | F |
| 80/4 | 16769 | Arcane Stability | 0:6/108 | N | F |
| 80/5 | 16770 | Arcane Stability | 0:6/108 | N | F |
| 81/1 | 11242 | Spell Impact | 0:6/108 | N | F |
| 81/2 | 12467 | Spell Impact | 0:6/108 | N | F |
| 81/3 | 12469 | Spell Impact | 0:6/108 | N | F |
| 82/1 | 11247 | Magic Attunement | 0:6/108,1:6/107 | N | F |
| 82/2 | 12606 | Magic Attunement | 0:6/108,1:6/107 | N | F |
| 83/1 | 11252 | Arcane Shielding | 0:6/108,1:6/108 | N | F |
| 83/2 | 12605 | Arcane Shielding | 0:6/108,1:6/108 | N | F |
| 85/1 | 28574 | Arcane Fortitude | 0:6/182 | N | V |
| 85/2 | 54658 | Arcane Fortitude | 0:6/182 | N | V |
| 85/3 | 54659 | Arcane Fortitude | 0:6/182 | N | V |
| 86/1 | 12043 | Presence of Mind | 0:6/108 | N | FP |
| 87/1 | 12042 | Arcane Power | 0:6/108,1:6/108,2:6/108 | N | F |
| 88/1 | 11255 | Improved Counterspell | 0:6/42 | N | P |
| 88/2 | 12598 | Improved Counterspell | 0:6/42 | N | P |
| 421/1 | 15058 | Arcane Instability | 0:6/79,1:6/71 | N | V |
| 421/2 | 15059 | Arcane Instability | 0:6/79,1:6/71 | N | V |
| 421/3 | 15060 | Arcane Instability | 0:6/79,1:6/71 | N | V |
| 1142/1 | 18462 | Arcane Meditation | 0:6/134 | N | V |
| 1142/2 | 18463 | Arcane Meditation | 0:6/134 | N | V |
| 1142/3 | 18464 | Arcane Meditation | 0:6/134 | N | V |
| 1650/1 | 29441 | Magic Absorption | 0:6/4,1:6/22 | N | PX |
| 1650/2 | 29444 | Magic Absorption | 0:6/4,1:6/22 | N | PX |
| 1724/1 | 31569 | Improved Blink | 0:6/108,1:6/42 | N | FP |
| 1724/2 | 31570 | Improved Blink | 0:6/108,1:6/42 | N | FP |
| 1725/1 | 31571 | Arcane Potency | 0:6/4 | N | X |
| 1725/2 | 31572 | Arcane Potency | 0:6/4 | N | X |
| 1726/1 | 31574 | Prismatic Cloak | 0:6/87,1:6/107 | N | F |
| 1726/2 | 31575 | Prismatic Cloak | 0:6/87,1:6/107 | N | F |
| 1726/3 | 54354 | Prismatic Cloak | 0:6/87,1:6/107 | N | F |
| 1727/1 | 31579 | Arcane Empowerment | 0:6/107,1:65/79 | N | F |
| 1727/2 | 31582 | Arcane Empowerment | 0:6/107,1:65/79 | N | F |
| 1727/3 | 31583 | Arcane Empowerment | 0:6/107,1:65/79 | N | F |
| 1728/1 | 31584 | Mind Mastery | 0:6/174 | N | V |
| 1728/2 | 31585 | Mind Mastery | 0:6/174 | N | V |
| 1728/3 | 31586 | Mind Mastery | 0:6/174 | N | V |
| 1728/4 | 31587 | Mind Mastery | 0:6/174 | N | V |
| 1728/5 | 31588 | Mind Mastery | 0:6/174 | N | V |
| 1729/1 | 31589 | Slow | 0:6/33,1:6/218,2:6/216 | N | M |
| 1826/1 | 35578 | Spell Power | 0:6/108 | N | F |
| 1826/2 | 35581 | Spell Power | 0:6/108 | N | F |
| 1843/1 | 44378 | Arcane Flows | 0:6/108,1:6/107 | N | F |
| 1843/2 | 44379 | Arcane Flows | 0:6/108,1:6/107 | N | F |
| 1844/1 | 44394 | Incanter's Absorption | 0:6/4 | N | PX |
| 1844/2 | 44395 | Incanter's Absorption | 0:6/4 | N | X |
| 1844/3 | 44396 | Incanter's Absorption | 0:6/4 | N | X |
| 1845/1 | 44397 | Student of the Mind | 0:6/137 | N | V |
| 1845/2 | 44398 | Student of the Mind | 0:6/137 | N | V |
| 1845/3 | 44399 | Student of the Mind | 0:6/137 | N | V |
| 1846/1 | 44400 | Netherwind Presence | 0:6/65 | N | V |
| 1846/2 | 44402 | Netherwind Presence | 0:6/65 | N | V |
| 1846/3 | 44403 | Netherwind Presence | 0:6/65 | N | V |
| 1847/1 | 44425 | Arcane Barrage | 0:2/0 | N | V |
| 2209/1 | 44404 | Missile Barrage | 0:6/42 | N | P |
| 2209/2 | 54486 | Missile Barrage | 0:6/42 | N | P |
| 2209/3 | 54488 | Missile Barrage | 0:6/42 | N | P |
| 2209/4 | 54489 | Missile Barrage | 0:6/42 | N | P |
| 2209/5 | 54490 | Missile Barrage | 0:6/42 | N | P |
| 2211/1 | 54646 | Focus Magic | 0:6/57,1:3/0 | N | PX |
| 2222/1 | 29447 | Torment the Weak | 0:6/4 | N | X |
| 2222/2 | 55339 | Torment the Weak | 0:6/4 | N | X |
| 2222/3 | 55340 | Torment the Weak | 0:6/4 | N | X |

### Warrior: Arms (source tab 161)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 121/1 | 12834 | Deep Wounds | 0:6/42 | N | PM |
| 121/2 | 12849 | Deep Wounds | 0:6/42 | N | PM |
| 121/3 | 12867 | Deep Wounds | 0:6/42 | N | PM |
| 123/1 | 12281 | Sword Specialization | 0:6/42 | N | PM |
| 123/2 | 12812 | Sword Specialization | 0:6/42 | N | PM |
| 123/3 | 12813 | Sword Specialization | 0:6/42 | N | PM |
| 123/4 | 12814 | Sword Specialization | 0:6/42 | N | PM |
| 123/5 | 12815 | Sword Specialization | 0:6/42 | N | PM |
| 124/1 | 12282 | Improved Heroic Strike | 0:6/107 | N | F |
| 124/2 | 12663 | Improved Heroic Strike | 0:6/107 | N | F |
| 124/3 | 12664 | Improved Heroic Strike | 0:6/107 | N | F |
| 125/1 | 12284 | Mace Specialization | 0:6/280 | N | M |
| 125/2 | 12701 | Mace Specialization | 0:6/280 | N | M |
| 125/3 | 12702 | Mace Specialization | 0:6/280 | N | M |
| 125/4 | 12703 | Mace Specialization | 0:6/280 | N | M |
| 125/5 | 12704 | Mace Specialization | 0:6/280 | N | M |
| 126/1 | 12285 | Improved Charge | 0:6/107 | N | F |
| 126/2 | 12697 | Improved Charge | 0:6/107 | N | F |
| 127/1 | 12286 | Improved Rend | 0:6/108 | N | F |
| 127/2 | 12658 | Improved Rend | 0:6/108 | N | F |
| 128/1 | 12295 | Tactical Mastery | 0:6/4,1:6/108,2:6/108 | N | FXM |
| 128/2 | 12676 | Tactical Mastery | 0:6/4,1:6/108,2:6/108 | N | FXM |
| 128/3 | 12677 | Tactical Mastery | 0:6/4,1:6/108,2:6/108 | N | FXM |
| 129/1 | 12289 | Improved Hamstring | 0:6/42 | N | P |
| 129/2 | 12668 | Improved Hamstring | 0:6/42 | N | P |
| 129/3 | 23695 | Improved Hamstring | 0:6/42 | N | P |
| 130/1 | 16462 | Deflection | 0:6/47 | N | V |
| 130/2 | 16463 | Deflection | 0:6/47 | N | V |
| 130/3 | 16464 | Deflection | 0:6/47 | N | V |
| 130/4 | 16465 | Deflection | 0:6/47 | N | V |
| 130/5 | 16466 | Deflection | 0:6/47 | N | V |
| 131/1 | 12290 | Improved Overpower | 0:6/107 | N | F |
| 131/2 | 12963 | Improved Overpower | 0:6/107 | N | F |
| 132/1 | 12700 | Poleaxe Specialization | 0:6/52,1:6/163 | N | M |
| 132/2 | 12781 | Poleaxe Specialization | 0:6/52,1:6/163 | N | M |
| 132/3 | 12783 | Poleaxe Specialization | 0:6/52,1:6/163 | N | M |
| 132/4 | 12784 | Poleaxe Specialization | 0:6/52,1:6/163 | N | M |
| 132/5 | 12785 | Poleaxe Specialization | 0:6/52,1:6/163 | N | M |
| 133/1 | 12328 | Sweeping Strikes | 0:6/4 | N | PXM |
| 134/1 | 20504 | Weapon Mastery | 0:6/248,1:6/234 | N | V |
| 134/2 | 20505 | Weapon Mastery | 0:6/248,1:6/234 | N | V |
| 135/1 | 12294 | Mortal Strike | 0:6/118,1:121/0 | N | M |
| 136/1 | 12163 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 136/2 | 12711 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 136/3 | 12712 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 137/1 | 12296 | Anger Management | 0:6/85 | N | V |
| 641/1 | 12300 | Iron Will | 0:6/232,1:6/232 | N | V |
| 641/2 | 12959 | Iron Will | 0:6/232,1:6/232 | N | V |
| 641/3 | 12960 | Iron Will | 0:6/232,1:6/232 | N | V |
| 662/1 | 16493 | Impale | 0:6/108 | N | F |
| 662/2 | 16494 | Impale | 0:6/108 | N | F |
| 1661/1 | 29623 | Endless Rage | 0:6/213 | N | V |
| 1662/1 | 29723 | Sudden Death | 0:6/42 | N | P |
| 1662/2 | 29725 | Sudden Death | 0:6/42 | N | P |
| 1662/3 | 29724 | Sudden Death | 0:6/42 | N | P |
| 1663/1 | 29834 | Second Wind | 0:6/4 | N | PX |
| 1663/2 | 29838 | Second Wind | 0:6/4 | N | PX |
| 1664/1 | 29836 | Blood Frenzy | 0:6/109,1:6/138 | N | P |
| 1664/2 | 29859 | Blood Frenzy | 0:6/109,1:6/138 | N | P |
| 1824/1 | 35446 | Improved Mortal Strike | 0:6/108,1:6/107 | N | F |
| 1824/2 | 35448 | Improved Mortal Strike | 0:6/108,1:6/107 | N | F |
| 1824/3 | 35449 | Improved Mortal Strike | 0:6/108,1:6/107 | N | F |
| 1859/1 | 46854 | Trauma | 0:6/42 | N | P |
| 1859/2 | 46855 | Trauma | 0:6/42 | N | P |
| 1860/1 | 46859 | Unrelenting Assault | 0:6/107,1:6/108 | N | F |
| 1860/2 | 46860 | Unrelenting Assault | 0:6/107,1:6/107,2:6/108 | N | F |
| 1862/1 | 46865 | Strength of Arms | 0:6/137,1:6/137,2:6/240 | N | V |
| 1862/2 | 46866 | Strength of Arms | 0:6/137,1:6/137,2:6/240 | N | V |
| 1863/1 | 46924 | Bladestorm | 0:6/23,1:6/147,2:6/263 | N | PM |
| 2231/1 | 46867 | Wrecking Crew | 0:6/42 | N | P |
| 2231/2 | 56611 | Wrecking Crew | 0:6/42 | N | P |
| 2231/3 | 56612 | Wrecking Crew | 0:6/42 | N | P |
| 2231/4 | 56613 | Wrecking Crew | 0:6/42 | N | P |
| 2231/5 | 56614 | Wrecking Crew | 0:6/42 | N | P |
| 2232/1 | 56636 | Taste for Blood | 0:6/42 | N | P |
| 2232/2 | 56637 | Taste for Blood | 0:6/42 | N | P |
| 2232/3 | 56638 | Taste for Blood | 0:6/42 | N | P |
| 2233/1 | 12862 | Improved Slam | 0:6/107 | N | F |
| 2233/2 | 12330 | Improved Slam | 0:6/107 | N | F |
| 2283/1 | 64976 | Juggernaut | 0:6/262,1:6/42,2:6/107 | N | FP |

### Warrior: Protection (source tab 163)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 138/1 | 12297 | Anticipation | 0:6/49 | N | V |
| 138/2 | 12750 | Anticipation | 0:6/49 | N | V |
| 138/3 | 12751 | Anticipation | 0:6/49 | N | V |
| 138/4 | 12752 | Anticipation | 0:6/49 | N | V |
| 138/5 | 12753 | Anticipation | 0:6/49 | N | V |
| 140/1 | 12299 | Toughness | 0:6/142,1:6/232 | N | V |
| 140/2 | 12761 | Toughness | 0:6/142,1:6/232 | N | V |
| 140/3 | 12762 | Toughness | 0:6/142,1:6/232 | N | V |
| 140/4 | 12763 | Toughness | 0:6/142,1:6/232 | N | V |
| 140/5 | 12764 | Toughness | 0:6/142,1:6/232 | N | V |
| 141/1 | 12287 | Improved Thunder Clap | 0:6/107,1:6/108,2:6/108 | N | F |
| 141/2 | 12665 | Improved Thunder Clap | 0:6/107,1:6/108,2:6/108 | N | F |
| 141/3 | 12666 | Improved Thunder Clap | 0:6/107,1:6/108,2:6/108 | N | F |
| 142/1 | 12301 | Improved Bloodrage | 0:6/108 | N | F |
| 142/2 | 12818 | Improved Bloodrage | 0:6/108 | N | F |
| 144/1 | 50685 | Incite | 0:6/107 | N | F |
| 144/2 | 50686 | Incite | 0:6/107 | N | F |
| 144/3 | 50687 | Incite | 0:6/107 | N | F |
| 146/1 | 12308 | Puncture | 0:6/107 | N | F |
| 146/2 | 12810 | Puncture | 0:6/107 | N | F |
| 146/3 | 12811 | Puncture | 0:6/107 | N | F |
| 147/1 | 12797 | Improved Revenge | 0:6/107,1:6/108,2:6/108 | N | FP |
| 147/2 | 12799 | Improved Revenge | 0:6/107,1:6/108 | N | FP |
| 148/1 | 50720 | Vigilance | 0:6/42 | N | P |
| 149/1 | 12311 | Gag Order | 0:6/4,1:6/108 | N | FPX |
| 149/2 | 12958 | Gag Order | 0:6/4,1:6/108 | N | FPX |
| 150/1 | 12312 | Improved Disciplines | 0:6/107 | N | F |
| 150/2 | 12803 | Improved Disciplines | 0:6/107 | N | F |
| 151/1 | 12313 | Improved Disarm | 0:6/107,1:6/107 | N | F |
| 151/2 | 12804 | Improved Disarm | 0:6/107,1:6/107 | N | F |
| 152/1 | 12809 | Concussion Blow | 0:6/12,1:2/0,2:3/0 | N | XM |
| 153/1 | 12975 | Last Stand | 0:3/0 | N | X |
| 702/1 | 16538 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 702/2 | 16539 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 702/3 | 16540 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 702/4 | 16541 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 702/5 | 16542 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 1601/1 | 12298 | Shield Specialization | 0:6/51,1:6/42 | N | P |
| 1601/2 | 12724 | Shield Specialization | 0:6/51,1:6/42 | N | P |
| 1601/3 | 12725 | Shield Specialization | 0:6/51,1:6/42 | N | P |
| 1601/4 | 12726 | Shield Specialization | 0:6/51,1:6/42 | N | P |
| 1601/5 | 12727 | Shield Specialization | 0:6/51,1:6/42 | N | P |
| 1652/1 | 29593 | Improved Defensive Stance | 0:6/87,1:6/42 | N | PM |
| 1652/2 | 29594 | Improved Defensive Stance | 0:6/87,1:6/42 | N | PM |
| 1653/1 | 29140 | Vitality | 0:6/137,1:6/137,2:6/240 | N | V |
| 1653/2 | 29143 | Vitality | 0:6/137,1:6/137,2:6/240 | N | V |
| 1653/3 | 29144 | Vitality | 0:6/137,1:6/137,2:6/240 | N | V |
| 1654/1 | 29598 | Shield Mastery | 0:6/150,1:6/107 | N | F |
| 1654/2 | 29599 | Shield Mastery | 0:6/150,1:6/107 | N | F |
| 1660/1 | 29787 | Focused Rage | 0:6/107 | N | F |
| 1660/2 | 29790 | Focused Rage | 0:6/107 | N | F |
| 1660/3 | 29792 | Focused Rage | 0:6/107 | N | F |
| 1666/1 | 20243 | Devastate | 1:31/0,2:121/0 | N | M |
| 1870/1 | 46945 | Safeguard | 1:6/42 | N | P |
| 1870/2 | 46949 | Safeguard | 1:6/42 | N | P |
| 1871/1 | 46951 | Sword and Board | 0:6/42,1:6/107 | N | FP |
| 1871/2 | 46952 | Sword and Board | 0:6/42,1:6/107 | N | FP |
| 1871/3 | 46953 | Sword and Board | 0:6/42,1:6/107 | N | FP |
| 1872/1 | 46968 | Shockwave | 0:6/12,1:2/0,2:3/0 | N | XM |
| 1893/1 | 47294 | Critical Block | 0:6/253,1:6/107 | N | F |
| 1893/2 | 47295 | Critical Block | 0:6/253,1:6/107 | N | F |
| 1893/3 | 47296 | Critical Block | 0:6/253,1:6/107 | N | F |
| 2236/1 | 57499 | Warbringer | 0:6/262,1:6/275,2:6/112 | N | V |
| 2246/1 | 58872 | Damage Shield | 0:6/4 | N | PXM |
| 2246/2 | 58874 | Damage Shield | 0:6/4 | N | PXM |
| 2247/1 | 59088 | Improved Spell Reflection | 1:6/4,2:6/186 | N | X |
| 2247/2 | 59089 | Improved Spell Reflection | 1:6/4,2:6/186 | N | X |

### Warrior: Fury (source tab 164)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 154/1 | 12318 | Commanding Presence | 0:6/108 | N | F |
| 154/2 | 12857 | Commanding Presence | 0:6/108 | N | F |
| 154/3 | 12858 | Commanding Presence | 0:6/108 | N | F |
| 154/4 | 12860 | Commanding Presence | 0:6/108 | N | F |
| 154/5 | 12861 | Commanding Presence | 0:6/108 | N | F |
| 155/1 | 12317 | Enrage | 0:6/42 | N | P |
| 155/2 | 13045 | Enrage | 0:6/42 | N | P |
| 155/3 | 13046 | Enrage | 0:6/42 | N | P |
| 155/4 | 13047 | Enrage | 0:6/42 | N | P |
| 155/5 | 13048 | Enrage | 0:6/42 | N | P |
| 156/1 | 12319 | Flurry | 0:6/42 | N | P |
| 156/2 | 12971 | Flurry | 0:6/42 | N | P |
| 156/3 | 12972 | Flurry | 0:6/42 | N | P |
| 156/4 | 12973 | Flurry | 0:6/42 | N | P |
| 156/5 | 12974 | Flurry | 0:6/42 | N | P |
| 157/1 | 12320 | Cruelty | 0:6/52 | N | M |
| 157/2 | 12852 | Cruelty | 0:6/52 | N | M |
| 157/3 | 12853 | Cruelty | 0:6/52 | N | M |
| 157/4 | 12855 | Cruelty | 0:6/52 | N | M |
| 157/5 | 12856 | Cruelty | 0:6/52 | N | M |
| 158/1 | 12321 | Booming Voice | 0:6/108,1:6/108 | N | F |
| 158/2 | 12835 | Booming Voice | 0:6/108,1:6/108 | N | F |
| 159/1 | 12322 | Unbridled Wrath | 0:6/42 | N | PM |
| 159/2 | 12999 | Unbridled Wrath | 0:6/42 | N | PM |
| 159/3 | 13000 | Unbridled Wrath | 0:6/42 | N | PM |
| 159/4 | 13001 | Unbridled Wrath | 0:6/42 | N | PM |
| 159/5 | 13002 | Unbridled Wrath | 0:6/42 | N | PM |
| 160/1 | 12323 | Piercing Howl | 0:6/33 | N | M |
| 161/1 | 12324 | Improved Demoralizing Shout | 0:6/108 | N | F |
| 161/2 | 12876 | Improved Demoralizing Shout | 0:6/108 | N | F |
| 161/3 | 12877 | Improved Demoralizing Shout | 0:6/108 | N | F |
| 161/4 | 12878 | Improved Demoralizing Shout | 0:6/108 | N | F |
| 161/5 | 12879 | Improved Demoralizing Shout | 0:6/108 | N | F |
| 165/1 | 12292 | Death Wish | 0:6/79,2:6/87 | N | M |
| 166/1 | 12329 | Improved Cleave | 0:6/108 | N | F |
| 166/2 | 12950 | Improved Cleave | 0:6/108 | N | F |
| 166/3 | 20496 | Improved Cleave | 0:6/108 | N | F |
| 167/1 | 23881 | Bloodthirst | 0:2/0,1:3/0 | N | XM |
| 661/1 | 16487 | Blood Craze | 0:6/42 | N | P |
| 661/2 | 16489 | Blood Craze | 0:6/42 | N | P |
| 661/3 | 16492 | Blood Craze | 0:6/42 | N | P |
| 1541/1 | 20500 | Improved Berserker Rage | 0:6/42 | N | P |
| 1541/2 | 20501 | Improved Berserker Rage | 0:6/42 | N | P |
| 1542/1 | 20502 | Improved Execute | 0:6/107 | N | F |
| 1542/2 | 20503 | Improved Execute | 0:6/107 | N | F |
| 1543/1 | 29888 | Improved Intercept | 0:6/107 | N | F |
| 1543/2 | 29889 | Improved Intercept | 0:6/107 | N | F |
| 1581/1 | 23584 | Dual Wield Specialization | 0:6/122 | N | V |
| 1581/2 | 23585 | Dual Wield Specialization | 0:6/122 | N | V |
| 1581/3 | 23586 | Dual Wield Specialization | 0:6/122 | N | V |
| 1581/4 | 23587 | Dual Wield Specialization | 0:6/122 | N | V |
| 1581/5 | 23588 | Dual Wield Specialization | 0:6/122 | N | V |
| 1655/1 | 29721 | Improved Whirlwind | 0:6/108 | N | F |
| 1655/2 | 29776 | Improved Whirlwind | 0:6/108 | N | F |
| 1657/1 | 29590 | Precision | 0:6/54 | N | M |
| 1657/2 | 29591 | Precision | 0:6/54 | N | M |
| 1657/3 | 29592 | Precision | 0:6/54 | N | M |
| 1658/1 | 29759 | Improved Berserker Stance | 0:6/137,1:6/107 | N | FM |
| 1658/2 | 29760 | Improved Berserker Stance | 0:6/137,1:6/107 | N | FM |
| 1658/3 | 29761 | Improved Berserker Stance | 0:6/137,1:6/107 | N | FM |
| 1658/4 | 29762 | Improved Berserker Stance | 0:6/137,1:6/107 | N | FM |
| 1658/5 | 29763 | Improved Berserker Stance | 0:6/137,1:6/107 | N | FM |
| 1659/1 | 29801 | Rampage | 0:65/52 | N | V |
| 1864/1 | 46908 | Intensify Rage | 0:6/108 | N | F |
| 1864/2 | 46909 | Intensify Rage | 0:6/108 | N | F |
| 1864/3 | 56924 | Intensify Rage | 0:6/108 | N | F |
| 1865/1 | 46910 | Furious Attacks | 0:6/42 | N | P |
| 1865/2 | 46911 | Furious Attacks | 0:6/42 | N | P |
| 1866/1 | 46913 | Bloodsurge | 0:6/42 | N | P |
| 1866/2 | 46914 | Bloodsurge | 0:6/42 | N | P |
| 1866/3 | 46915 | Bloodsurge | 0:6/42 | N | P |
| 1867/1 | 46917 | Titan's Grip | 0:155/0,1:140/0 | N | PM |
| 1868/1 | 60970 | Heroic Fury | 2:6/77 | N | V |
| 2234/1 | 56927 | Unending Fury | 1:6/108 | N | F |
| 2234/2 | 56929 | Unending Fury | 1:6/108 | N | F |
| 2234/3 | 56930 | Unending Fury | 1:6/108 | N | F |
| 2234/4 | 56931 | Unending Fury | 1:6/108 | N | F |
| 2234/5 | 56932 | Unending Fury | 1:6/108 | N | F |
| 2250/1 | 61216 | Armored to the Teeth | 0:6/285,1:3/0 | N | X |
| 2250/2 | 61221 | Armored to the Teeth | 0:6/285,1:3/0 | N | X |
| 2250/3 | 61222 | Armored to the Teeth | 0:6/285,1:3/0 | N | X |

### Rogue: Combat (source tab 181)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 181/1 | 13705 | Precision | 0:6/54,1:6/55 | N | M |
| 181/2 | 13832 | Precision | 0:6/54,1:6/55 | N | M |
| 181/3 | 13843 | Precision | 0:6/54,1:6/55 | N | M |
| 181/4 | 13844 | Precision | 0:6/54,1:6/55 | N | M |
| 181/5 | 13845 | Precision | 0:6/54,1:6/55 | N | M |
| 182/1 | 13706 | Close Quarters Combat | 0:6/52 | N | M |
| 182/2 | 13804 | Close Quarters Combat | 0:6/52 | N | M |
| 182/3 | 13805 | Close Quarters Combat | 0:6/52 | N | M |
| 182/4 | 13806 | Close Quarters Combat | 0:6/52 | N | M |
| 182/5 | 13807 | Close Quarters Combat | 0:6/52 | N | M |
| 184/1 | 13709 | Mace Specialization | 0:6/280 | N | M |
| 184/2 | 13800 | Mace Specialization | 0:6/280 | N | M |
| 184/3 | 13801 | Mace Specialization | 0:6/280 | N | M |
| 184/4 | 13802 | Mace Specialization | 0:6/280 | N | M |
| 184/5 | 13803 | Mace Specialization | 0:6/280 | N | M |
| 186/1 | 13712 | Lightning Reflexes | 0:6/49,1:6/138 | N | V |
| 186/2 | 13788 | Lightning Reflexes | 0:6/49,1:6/138 | N | V |
| 186/3 | 13789 | Lightning Reflexes | 0:6/49,1:6/138 | N | V |
| 187/1 | 13713 | Deflection | 0:6/47 | N | V |
| 187/2 | 13853 | Deflection | 0:6/47 | N | V |
| 187/3 | 13854 | Deflection | 0:6/47 | N | V |
| 201/1 | 13732 | Improved Sinister Strike | 0:6/107 | N | F |
| 201/2 | 13863 | Improved Sinister Strike | 0:6/107 | N | F |
| 203/1 | 13741 | Improved Gouge | 0:6/107 | N | F |
| 203/2 | 13793 | Improved Gouge | 0:6/107 | N | F |
| 203/3 | 13792 | Improved Gouge | 0:6/107 | N | F |
| 204/1 | 13742 | Endurance | 0:6/107,1:6/137 | N | F |
| 204/2 | 13872 | Endurance | 0:6/107,1:6/137 | N | F |
| 205/1 | 13750 | Adrenaline Rush | 0:6/110 | N | V |
| 206/1 | 13754 | Improved Kick | 0:6/42 | N | P |
| 206/2 | 13867 | Improved Kick | 0:6/42 | N | P |
| 221/1 | 13715 | Dual Wield Specialization | 0:6/122 | N | V |
| 221/2 | 13848 | Dual Wield Specialization | 0:6/122 | N | V |
| 221/3 | 13849 | Dual Wield Specialization | 0:6/122 | N | V |
| 221/4 | 13851 | Dual Wield Specialization | 0:6/122 | N | V |
| 221/5 | 13852 | Dual Wield Specialization | 0:6/122 | N | V |
| 222/1 | 13743 | Improved Sprint | 0:6/109 | N | P |
| 222/2 | 13875 | Improved Sprint | 0:6/109 | N | P |
| 223/1 | 13877 | Blade Flurry | 0:6/138 | N | P |
| 242/1 | 13960 | Hack and Slash | 0:6/42 | N | PM |
| 242/2 | 13961 | Hack and Slash | 0:6/42 | N | PM |
| 242/3 | 13962 | Hack and Slash | 0:6/42 | N | PM |
| 242/4 | 13963 | Hack and Slash | 0:6/42 | N | PM |
| 242/5 | 13964 | Hack and Slash | 0:6/42 | N | PM |
| 301/1 | 14251 | Riposte | 0:31/0,1:6/138,2:80/0 | N | M |
| 1122/1 | 18427 | Aggression | 0:6/108 | N | F |
| 1122/2 | 18428 | Aggression | 0:6/108 | N | F |
| 1122/3 | 18429 | Aggression | 0:6/108 | N | F |
| 1122/4 | 61330 | Aggression | 0:6/108 | N | F |
| 1122/5 | 61331 | Aggression | 0:6/108 | N | F |
| 1703/1 | 30919 | Weapon Expertise | 0:6/240 | N | V |
| 1703/2 | 30920 | Weapon Expertise | 0:6/240 | N | V |
| 1705/1 | 31122 | Vitality | 0:6/110 | N | V |
| 1705/2 | 31123 | Vitality | 0:6/110 | N | V |
| 1705/3 | 61329 | Vitality | 0:6/110 | N | V |
| 1706/1 | 31124 | Blade Twisting | 0:6/42,1:6/108 | N | FPM |
| 1706/2 | 31126 | Blade Twisting | 0:6/42,1:6/108 | N | FPM |
| 1707/1 | 31130 | Nerves of Steel | 0:6/69 | N | V |
| 1707/2 | 31131 | Nerves of Steel | 0:6/69 | N | V |
| 1709/1 | 32601 | Surprise Attacks | 0:6/202,1:6/108 | N | F |
| 1825/1 | 35541 | Combat Potency | 0:6/42 | N | P |
| 1825/2 | 35550 | Combat Potency | 0:6/42 | N | P |
| 1825/3 | 35551 | Combat Potency | 0:6/42 | N | P |
| 1825/4 | 35552 | Combat Potency | 0:6/42 | N | P |
| 1825/5 | 35553 | Combat Potency | 0:6/42 | N | P |
| 1827/1 | 14165 | Improved Slice and Dice | 0:6/108 | N | F |
| 1827/2 | 14166 | Improved Slice and Dice | 0:6/108 | N | F |
| 2072/1 | 5952 | Throwing Specialization | 0:6/107,1:6/42 | N | FP |
| 2072/2 | 51679 | Throwing Specialization | 0:6/107,1:6/42 | N | FP |
| 2073/1 | 51672 | Unfair Advantage | 0:6/42 | N | P |
| 2073/2 | 51674 | Unfair Advantage | 0:6/42 | N | P |
| 2074/1 | 51682 | Savage Combat | 0:6/42,1:6/166 | N | P |
| 2074/2 | 58413 | Savage Combat | 0:6/42,1:6/166 | N | P |
| 2075/1 | 51685 | Prey on the Weak | 0:6/226 | N | V |
| 2075/2 | 51686 | Prey on the Weak | 0:6/226 | N | V |
| 2075/3 | 51687 | Prey on the Weak | 0:6/226 | N | V |
| 2075/4 | 51688 | Prey on the Weak | 0:6/226 | N | V |
| 2075/5 | 51689 | Prey on the Weak | 0:6/226 | N | V |
| 2076/1 | 51690 | Killing Spree | 0:6/226,1:3/0,2:6/263 | N | XM |

### Rogue: Assassination (source tab 182)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 268/1 | 14113 | Improved Poisons | 0:6/107,1:6/108 | N | F |
| 268/2 | 14114 | Improved Poisons | 0:6/107,1:6/108 | N | F |
| 268/3 | 14115 | Improved Poisons | 0:6/107,1:6/108 | N | F |
| 268/4 | 14116 | Improved Poisons | 0:6/107,1:6/108 | N | F |
| 268/5 | 14117 | Improved Poisons | 0:6/107,1:6/108 | N | F |
| 269/1 | 14128 | Lethality | 0:6/108 | N | F |
| 269/2 | 14132 | Lethality | 0:6/108 | N | F |
| 269/3 | 14135 | Lethality | 0:6/108 | N | F |
| 269/4 | 14136 | Lethality | 0:6/108 | N | F |
| 269/5 | 14137 | Lethality | 0:6/108 | N | F |
| 270/1 | 14138 | Malice | 0:6/52 | N | V |
| 270/2 | 14139 | Malice | 0:6/52 | N | V |
| 270/3 | 14140 | Malice | 0:6/52 | N | V |
| 270/4 | 14141 | Malice | 0:6/52 | N | V |
| 270/5 | 14142 | Malice | 0:6/52 | N | V |
| 272/1 | 14144 | Remorseless Attacks | 0:6/42 | N | P |
| 272/2 | 14148 | Remorseless Attacks | 0:6/42 | N | P |
| 273/1 | 14156 | Ruthlessness | 0:6/42 | N | P |
| 273/2 | 14160 | Ruthlessness | 0:6/42 | N | P |
| 273/3 | 14161 | Ruthlessness | 0:6/42 | N | P |
| 274/1 | 14158 | Murder | 0:6/79 | N | V |
| 274/2 | 14159 | Murder | 0:6/79 | N | V |
| 276/1 | 14162 | Improved Eviscerate | 0:6/108 | N | F |
| 276/2 | 14163 | Improved Eviscerate | 0:6/108 | N | F |
| 276/3 | 14164 | Improved Eviscerate | 0:6/108 | N | F |
| 277/1 | 13733 | Puncturing Wounds | 0:6/107,1:6/107 | N | F |
| 277/2 | 13865 | Puncturing Wounds | 0:6/107,1:6/107 | N | F |
| 277/3 | 13866 | Puncturing Wounds | 0:6/107,1:6/107 | N | F |
| 278/1 | 14168 | Improved Expose Armor | 0:6/107 | N | F |
| 278/2 | 14169 | Improved Expose Armor | 0:6/107 | N | F |
| 279/1 | 14174 | Improved Kidney Shot | 0:6/107 | N | F |
| 279/2 | 14175 | Improved Kidney Shot | 0:6/107 | N | F |
| 279/3 | 14176 | Improved Kidney Shot | 0:6/107 | N | F |
| 280/1 | 14177 | Cold Blood | 0:6/107 | N | FP |
| 281/1 | 58426 | Overkill | 0:6/4 | N | X |
| 283/1 | 14186 | Seal Fate | 0:6/42 | N | P |
| 283/2 | 14190 | Seal Fate | 0:6/42 | N | P |
| 283/3 | 14193 | Seal Fate | 0:6/42 | N | P |
| 283/4 | 14194 | Seal Fate | 0:6/42 | N | P |
| 283/5 | 14195 | Seal Fate | 0:6/42 | N | P |
| 382/1 | 14983 | Vigor | 0:6/35 | N | V |
| 682/1 | 16513 | Vile Poisons | 0:6/108,1:6/108,2:6/107 | N | F |
| 682/2 | 16514 | Vile Poisons | 0:6/108,1:6/108,2:6/107 | N | F |
| 682/3 | 16515 | Vile Poisons | 0:6/108,1:6/108,2:6/107 | N | F |
| 1715/1 | 31226 | Master Poisoner | 0:6/231,1:6/246 | N | P |
| 1715/2 | 31227 | Master Poisoner | 0:6/231,1:6/246 | N | P |
| 1715/3 | 58410 | Master Poisoner | 0:6/231,1:6/246 | N | P |
| 1718/1 | 31234 | Find Weakness | 0:6/108,1:6/108 | N | F |
| 1718/2 | 31235 | Find Weakness | 0:6/108,1:6/108 | N | F |
| 1718/3 | 31236 | Find Weakness | 0:6/108,1:6/108 | N | F |
| 1719/1 | 1329 | Mutilate | 0:80/0,1:64/0,2:64/0 | N | PM |
| 1721/1 | 31208 | Fleet Footed | 0:6/232,1:6/232,2:6/31 | N | V |
| 1721/2 | 31209 | Fleet Footed | 0:6/232,1:6/232,2:6/31 | N | V |
| 1723/1 | 31380 | Deadened Nerves | 0:6/87 | N | V |
| 1723/2 | 31382 | Deadened Nerves | 0:6/87 | N | V |
| 1723/3 | 31383 | Deadened Nerves | 0:6/87 | N | V |
| 1762/1 | 31244 | Quick Recovery | 0:6/4,1:6/118 | N | PX |
| 1762/2 | 31245 | Quick Recovery | 0:6/4,1:6/118 | N | PX |
| 2065/1 | 51625 | Deadly Brew | 0:6/4 | N | PX |
| 2065/2 | 51626 | Deadly Brew | 0:6/4 | N | PX |
| 2066/1 | 51627 | Turn the Tables | 0:65/42 | N | P |
| 2066/2 | 51628 | Turn the Tables | 0:65/42 | N | P |
| 2066/3 | 51629 | Turn the Tables | 0:65/42 | N | P |
| 2068/1 | 51632 | Blood Spatter | 0:6/108 | N | F |
| 2068/2 | 51633 | Blood Spatter | 0:6/108 | N | F |
| 2069/1 | 51634 | Focused Attacks | 0:6/42 | N | P |
| 2069/2 | 51635 | Focused Attacks | 0:6/42 | N | P |
| 2069/3 | 51636 | Focused Attacks | 0:6/42 | N | P |
| 2070/1 | 51664 | Cut to the Chase | 0:6/4 | N | PX |
| 2070/2 | 51665 | Cut to the Chase | 0:6/4 | N | PX |
| 2070/3 | 51667 | Cut to the Chase | 0:6/4 | N | PX |
| 2070/4 | 51668 | Cut to the Chase | 0:6/4 | N | PX |
| 2070/5 | 51669 | Cut to the Chase | 0:6/4 | N | PX |
| 2071/1 | 51662 | Hunger For Blood | 0:3/0 | N | XM |

### Rogue: Subtlety (source tab 183)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 241/1 | 13958 | Master of Deception | 0:6/154 | N | V |
| 241/2 | 13970 | Master of Deception | 0:6/154 | N | V |
| 241/3 | 13971 | Master of Deception | 0:6/154 | N | V |
| 244/1 | 13975 | Camouflage | 0:6/107,1:6/107 | N | F |
| 244/2 | 14062 | Camouflage | 0:6/107,1:6/107 | N | F |
| 244/3 | 14063 | Camouflage | 0:6/107,1:6/107 | N | F |
| 245/1 | 13976 | Initiative | 0:6/109 | N | P |
| 245/2 | 13979 | Initiative | 0:6/109 | N | P |
| 245/3 | 13980 | Initiative | 0:6/109 | N | P |
| 246/1 | 13983 | Setup | 0:6/42 | N | P |
| 246/2 | 14070 | Setup | 0:6/42 | N | P |
| 246/3 | 14071 | Setup | 0:6/42 | N | P |
| 247/1 | 13981 | Elusiveness | 0:6/107,1:6/107 | N | F |
| 247/2 | 14066 | Elusiveness | 0:6/107,1:6/107 | N | F |
| 261/1 | 14057 | Opportunity | 0:6/108,1:6/108 | N | F |
| 261/2 | 14072 | Opportunity | 0:6/108,1:6/108 | N | F |
| 262/1 | 14076 | Dirty Tricks | 0:6/107,1:6/108 | N | F |
| 262/2 | 14094 | Dirty Tricks | 0:6/107,1:6/108 | N | F |
| 263/1 | 14079 | Improved Ambush | 0:6/107 | N | F |
| 263/2 | 14080 | Improved Ambush | 0:6/107 | N | F |
| 265/1 | 14082 | Dirty Deeds | 0:6/107,1:6/112,2:6/112 | N | F |
| 265/2 | 14083 | Dirty Deeds | 0:6/107,1:6/112,2:6/112 | N | F |
| 284/1 | 14185 | Preparation | 0:3/0 | N | X |
| 303/1 | 14278 | Ghostly Strike | 0:31/0,1:6/49,2:80/0 | N | M |
| 381/1 | 14183 | Premeditation | 0:80/0,1:6/148 | N | M |
| 681/1 | 16511 | Hemorrhage | 0:121/0,1:31/0,2:6/14 | N | PM |
| 1123/1 | 14171 | Serrated Blades | 0:6/108,1:6/280 | N | F |
| 1123/2 | 14172 | Serrated Blades | 0:6/108,1:6/280 | N | F |
| 1123/3 | 14173 | Serrated Blades | 0:6/108,1:6/280 | N | F |
| 1700/1 | 30892 | Sleight of Hand | 0:6/108,1:6/187,2:6/188 | N | F |
| 1700/2 | 30893 | Sleight of Hand | 0:6/108,1:6/187,2:6/188 | N | F |
| 1701/1 | 30894 | Heightened Senses | 0:6/17,1:6/185,2:6/186 | N | V |
| 1701/2 | 30895 | Heightened Senses | 0:6/17,1:6/185,2:6/186 | N | V |
| 1702/1 | 30902 | Deadliness | 0:6/166 | N | V |
| 1702/2 | 30903 | Deadliness | 0:6/166 | N | V |
| 1702/3 | 30904 | Deadliness | 0:6/166 | N | V |
| 1702/4 | 30905 | Deadliness | 0:6/166 | N | V |
| 1702/5 | 30906 | Deadliness | 0:6/166 | N | V |
| 1711/1 | 31211 | Enveloping Shadows | 0:6/229 | N | V |
| 1711/2 | 31212 | Enveloping Shadows | 0:6/229 | N | V |
| 1711/3 | 31213 | Enveloping Shadows | 0:6/229 | N | V |
| 1712/1 | 31216 | Sinister Calling | 0:6/137,1:6/108 | N | F |
| 1712/2 | 31217 | Sinister Calling | 0:6/137,1:6/108 | N | F |
| 1712/3 | 31218 | Sinister Calling | 0:6/137,1:6/108 | N | F |
| 1712/4 | 31219 | Sinister Calling | 0:6/137,1:6/108 | N | F |
| 1712/5 | 31220 | Sinister Calling | 0:6/137,1:6/108 | N | F |
| 1713/1 | 31221 | Master of Subtlety | 0:6/4 | N | X |
| 1713/2 | 31222 | Master of Subtlety | 0:6/4 | N | X |
| 1713/3 | 31223 | Master of Subtlety | 0:6/4 | N | X |
| 1714/1 | 36554 | Shadowstep | 0:64/0,1:64/0,2:6/31 | N | P |
| 1722/1 | 31228 | Cheat Death | 0:6/69 | N | V |
| 1722/2 | 31229 | Cheat Death | 0:6/69 | N | V |
| 1722/3 | 31230 | Cheat Death | 0:6/69 | N | V |
| 2077/1 | 51692 | Waylay | 0:6/42 | N | P |
| 2077/2 | 51696 | Waylay | 0:6/42 | N | P |
| 2078/1 | 51698 | Honor Among Thieves | 0:35/42 | N | P |
| 2078/2 | 51700 | Honor Among Thieves | 0:35/42 | N | P |
| 2078/3 | 51701 | Honor Among Thieves | 0:35/42 | N | P |
| 2079/1 | 58414 | Filthy Tricks | 0:6/107,1:6/107,2:6/107 | N | F |
| 2079/2 | 58415 | Filthy Tricks | 0:6/107,1:6/107,2:6/107 | N | F |
| 2080/1 | 51708 | Slaughter from the Shadows | 0:6/107,1:6/107,2:6/79 | N | F |
| 2080/2 | 51709 | Slaughter from the Shadows | 0:6/107,1:6/107,2:6/79 | N | F |
| 2080/3 | 51710 | Slaughter from the Shadows | 0:6/107,1:6/107,2:6/79 | N | F |
| 2080/4 | 51711 | Slaughter from the Shadows | 0:6/107,1:6/107,2:6/79 | N | F |
| 2080/5 | 51712 | Slaughter from the Shadows | 0:6/107,1:6/107,2:6/79 | N | F |
| 2081/1 | 51713 | Shadow Dance | 0:6/275,2:6/36 | N | V |
| 2244/1 | 14179 | Relentless Strikes | 0:6/109 | N | P |
| 2244/2 | 58422 | Relentless Strikes | 0:6/109 | N | P |
| 2244/3 | 58423 | Relentless Strikes | 0:6/109 | N | P |
| 2244/4 | 58424 | Relentless Strikes | 0:6/109 | N | P |
| 2244/5 | 58425 | Relentless Strikes | 0:6/109 | N | P |

### Priest: Discipline (source tab 201)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 321/1 | 14531 | Martyrdom | 0:6/42 | N | P |
| 321/2 | 14774 | Martyrdom | 0:6/42 | N | P |
| 322/1 | 10060 | Power Infusion | 0:6/65,1:6/72 | N | V |
| 341/1 | 14520 | Mental Agility | 0:6/108 | N | F |
| 341/2 | 14780 | Mental Agility | 0:6/108 | N | F |
| 341/3 | 14781 | Mental Agility | 0:6/108 | N | F |
| 342/1 | 14522 | Unbreakable Will | 0:6/232,1:6/232,2:6/232 | N | V |
| 342/2 | 14788 | Unbreakable Will | 0:6/232,1:6/232,2:6/232 | N | V |
| 342/3 | 14789 | Unbreakable Will | 0:6/232,1:6/232,2:6/232 | N | V |
| 342/4 | 14790 | Unbreakable Will | 0:6/232,1:6/232,2:6/232 | N | V |
| 342/5 | 14791 | Unbreakable Will | 0:6/232,1:6/232,2:6/232 | N | V |
| 343/1 | 14748 | Improved Power Word: Shield | 0:6/108 | N | F |
| 343/2 | 14768 | Improved Power Word: Shield | 0:6/108 | N | F |
| 343/3 | 14769 | Improved Power Word: Shield | 0:6/108 | N | F |
| 344/1 | 14749 | Improved Power Word: Fortitude | 0:6/108,1:6/137 | N | F |
| 344/2 | 14767 | Improved Power Word: Fortitude | 0:6/108,1:6/137 | N | F |
| 346/1 | 14747 | Improved Inner Fire | 0:6/108,2:6/107 | N | F |
| 346/2 | 14770 | Improved Inner Fire | 0:6/108,2:6/107 | N | F |
| 346/3 | 14771 | Improved Inner Fire | 0:6/108,2:6/107 | N | F |
| 347/1 | 14521 | Meditation | 0:6/134 | N | V |
| 347/2 | 14776 | Meditation | 0:6/134 | N | V |
| 347/3 | 14777 | Meditation | 0:6/134 | N | V |
| 348/1 | 14751 | Inner Focus | 0:6/108,1:6/107 | N | FPM |
| 350/1 | 14750 | Improved Mana Burn | 0:6/107 | N | F |
| 350/2 | 14772 | Improved Mana Burn | 0:6/107 | N | F |
| 351/1 | 63574 | Soul Warding | 0:6/107,1:6/108 | N | F |
| 352/1 | 14523 | Silent Resolve | 0:6/10,1:6/107,2:6/108 | N | F |
| 352/2 | 14784 | Silent Resolve | 0:6/10,1:6/107,2:6/108 | N | F |
| 352/3 | 14785 | Silent Resolve | 0:6/10,1:6/107,2:6/108 | N | F |
| 1201/1 | 18551 | Mental Strength | 0:6/137 | N | V |
| 1201/2 | 18552 | Mental Strength | 0:6/137 | N | V |
| 1201/3 | 18553 | Mental Strength | 0:6/137 | N | V |
| 1201/4 | 18554 | Mental Strength | 0:6/137 | N | V |
| 1201/5 | 18555 | Mental Strength | 0:6/137 | N | V |
| 1202/1 | 52795 | Borrowed Time | 0:6/42,1:6/4 | N | PX |
| 1202/2 | 52797 | Borrowed Time | 0:6/42,1:6/4 | N | PX |
| 1202/3 | 52798 | Borrowed Time | 0:6/42,1:6/4 | N | PX |
| 1202/4 | 52799 | Borrowed Time | 0:6/42,1:6/4 | N | PX |
| 1202/5 | 52800 | Borrowed Time | 0:6/42,1:6/4 | N | PX |
| 1769/1 | 33167 | Absolution | 0:6/108 | N | F |
| 1769/2 | 33171 | Absolution | 0:6/108 | N | F |
| 1769/3 | 33172 | Absolution | 0:6/108 | N | F |
| 1771/1 | 33186 | Focused Power | 0:6/107,1:6/79,2:6/136 | N | F |
| 1771/2 | 33190 | Focused Power | 0:6/107,1:6/79,2:6/136 | N | F |
| 1772/1 | 34908 | Enlightenment | 0:6/137,1:6/65 | N | V |
| 1772/2 | 34909 | Enlightenment | 0:6/137,1:6/65 | N | V |
| 1772/3 | 34910 | Enlightenment | 0:6/137,1:6/65 | N | V |
| 1773/1 | 63504 | Improved Flash Heal | 0:6/4,1:6/108 | N | FX |
| 1773/2 | 63505 | Improved Flash Heal | 0:6/4,1:6/108 | N | FX |
| 1773/3 | 63506 | Improved Flash Heal | 0:6/4,1:6/108 | N | FX |
| 1774/1 | 33206 | Pain Suppression | 0:6/87,1:6/235 | N | V |
| 1858/1 | 45234 | Focused Will | 0:6/42,1:6/57 | N | P |
| 1858/2 | 45243 | Focused Will | 0:6/42,1:6/57 | N | P |
| 1858/3 | 45244 | Focused Will | 0:6/42,1:6/57 | N | P |
| 1894/1 | 47507 | Aspiration | 0:6/108 | N | F |
| 1894/2 | 47508 | Aspiration | 0:6/108 | N | F |
| 1895/1 | 47509 | Divine Aegis | 0:6/4 | N | PXM |
| 1895/2 | 47511 | Divine Aegis | 0:6/4 | N | PXM |
| 1895/3 | 47515 | Divine Aegis | 0:6/4 | N | PXM |
| 1896/1 | 47535 | Rapture | 0:6/4,1:6/4 | N | X |
| 1896/2 | 47536 | Rapture | 0:6/4,1:6/4 | N | X |
| 1896/3 | 47537 | Rapture | 0:6/4,1:6/4 | N | X |
| 1897/1 | 47540 | Penance | 0:3/0 | N | X |
| 1898/1 | 47586 | Twin Disciplines | 0:6/108,1:6/108 | N | F |
| 1898/2 | 47587 | Twin Disciplines | 0:6/108,1:6/108 | N | F |
| 1898/3 | 47588 | Twin Disciplines | 0:6/108,1:6/108 | N | F |
| 1898/4 | 52802 | Twin Disciplines | 0:6/108,1:6/108 | N | F |
| 1898/5 | 52803 | Twin Disciplines | 0:6/108,1:6/108 | N | F |
| 1901/1 | 47516 | Grace | 0:6/42 | N | P |
| 1901/2 | 47517 | Grace | 0:6/42 | N | P |
| 2235/1 | 57470 | Renewed Hope | 0:6/112,1:6/42 | N | P |
| 2235/2 | 57472 | Renewed Hope | 0:6/112,1:6/42 | N | P |
| 2268/1 | 33201 | Reflective Shield | 0:6/4 | N | X |
| 2268/2 | 33202 | Reflective Shield | 0:6/4 | N | X |

### Priest: Holy (source tab 202)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 361/1 | 14892 | Inspiration | 0:6/42 | N | PM |
| 361/2 | 15362 | Inspiration | 0:6/42 | N | PM |
| 361/3 | 15363 | Inspiration | 0:6/42 | N | PM |
| 401/1 | 14889 | Holy Specialization | 0:6/71 | N | M |
| 401/2 | 15008 | Holy Specialization | 0:6/71 | N | M |
| 401/3 | 15009 | Holy Specialization | 0:6/71 | N | M |
| 401/4 | 15010 | Holy Specialization | 0:6/71 | N | M |
| 401/5 | 15011 | Holy Specialization | 0:6/71 | N | M |
| 402/1 | 14901 | Spiritual Guidance | 0:6/174,1:6/175 | N | V |
| 402/2 | 15028 | Spiritual Guidance | 0:6/174,1:6/175 | N | V |
| 402/3 | 15029 | Spiritual Guidance | 0:6/174,1:6/175 | N | V |
| 402/4 | 15030 | Spiritual Guidance | 0:6/174,1:6/175 | N | V |
| 402/5 | 15031 | Spiritual Guidance | 0:6/174,1:6/175 | N | V |
| 403/1 | 14909 | Searing Light | 0:6/108,1:6/108 | N | FM |
| 403/2 | 15017 | Searing Light | 0:6/108,1:6/108 | N | FM |
| 404/1 | 14898 | Spiritual Healing | 0:6/108,1:6/108 | N | FM |
| 404/2 | 15349 | Spiritual Healing | 0:6/108,1:6/108 | N | FM |
| 404/3 | 15354 | Spiritual Healing | 0:6/108,1:6/108 | N | FM |
| 404/4 | 15355 | Spiritual Healing | 0:6/108,1:6/108 | N | FM |
| 404/5 | 15356 | Spiritual Healing | 0:6/108,1:6/108 | N | FM |
| 406/1 | 14908 | Improved Renew | 0:6/108 | N | FM |
| 406/2 | 15020 | Improved Renew | 0:6/108 | N | FM |
| 406/3 | 17191 | Improved Renew | 0:6/108 | N | FM |
| 408/1 | 14912 | Improved Healing | 0:6/108 | N | FM |
| 408/2 | 15013 | Improved Healing | 0:6/108 | N | FM |
| 408/3 | 15014 | Improved Healing | 0:6/108 | N | FM |
| 410/1 | 14913 | Healing Focus | 0:6/108 | N | FM |
| 410/2 | 15012 | Healing Focus | 0:6/108 | N | FM |
| 411/1 | 27900 | Spell Warding | 0:6/87 | N | V |
| 411/2 | 27901 | Spell Warding | 0:6/87 | N | V |
| 411/3 | 27902 | Spell Warding | 0:6/87 | N | V |
| 411/4 | 27903 | Spell Warding | 0:6/87 | N | V |
| 411/5 | 27904 | Spell Warding | 0:6/87 | N | V |
| 413/1 | 14911 | Healing Prayers | 0:6/108 | N | FM |
| 413/2 | 15018 | Healing Prayers | 0:6/108 | N | FM |
| 442/1 | 19236 | Desperate Prayer | 0:10/0 | N | M |
| 1181/1 | 18530 | Divine Fury | 0:6/107 | N | FM |
| 1181/2 | 18531 | Divine Fury | 0:6/107 | N | FM |
| 1181/3 | 18533 | Divine Fury | 0:6/107 | N | FM |
| 1181/4 | 18534 | Divine Fury | 0:6/107 | N | FM |
| 1181/5 | 18535 | Divine Fury | 0:6/107 | N | FM |
| 1561/1 | 20711 | Spirit of Redemption | 0:6/4,1:6/137 | N | X |
| 1635/1 | 27789 | Holy Reach | 0:6/108,1:6/108 | N | F |
| 1635/2 | 27790 | Holy Reach | 0:6/108,1:6/108 | N | F |
| 1636/1 | 27811 | Blessed Recovery | 0:6/42 | N | P |
| 1636/2 | 27815 | Blessed Recovery | 0:6/42 | N | P |
| 1636/3 | 27816 | Blessed Recovery | 0:6/42 | N | P |
| 1637/1 | 724 | Lightwell | 0:28/0 | N | M |
| 1765/1 | 33142 | Blessed Resilience | 0:6/42,1:6/136 | N | P |
| 1765/2 | 33145 | Blessed Resilience | 0:6/42,1:6/136 | N | P |
| 1765/3 | 33146 | Blessed Resilience | 0:6/42,1:6/136 | N | P |
| 1766/1 | 33150 | Surge of Light | 0:6/42 | N | P |
| 1766/2 | 33154 | Surge of Light | 0:6/42 | N | P |
| 1767/1 | 33158 | Empowered Healing | 0:6/107,1:6/107 | N | F |
| 1767/2 | 33159 | Empowered Healing | 0:6/107,1:6/107 | N | F |
| 1767/3 | 33160 | Empowered Healing | 0:6/107,1:6/107 | N | F |
| 1767/4 | 33161 | Empowered Healing | 0:6/107,1:6/107 | N | F |
| 1767/5 | 33162 | Empowered Healing | 0:6/107,1:6/107 | N | F |
| 1768/1 | 34753 | Holy Concentration | 0:6/42 | N | P |
| 1768/2 | 34859 | Holy Concentration | 0:6/42 | N | P |
| 1768/3 | 34860 | Holy Concentration | 0:6/42 | N | P |
| 1815/1 | 34861 | Circle of Healing | 0:10/0 | N | M |
| 1902/1 | 63534 | Empowered Renew | 0:6/108,1:6/4 | N | FX |
| 1902/2 | 63542 | Empowered Renew | 0:6/108,1:6/4 | N | FX |
| 1902/3 | 63543 | Empowered Renew | 0:6/108,1:6/4 | N | FX |
| 1903/1 | 47558 | Test of Faith | 0:6/112,1:3/0 | N | X |
| 1903/2 | 47559 | Test of Faith | 0:6/112,1:3/0 | N | X |
| 1903/3 | 47560 | Test of Faith | 0:6/112,1:3/0 | N | X |
| 1904/1 | 63730 | Serendipity | 0:6/42 | N | P |
| 1904/2 | 63733 | Serendipity | 0:6/42 | N | P |
| 1904/3 | 63737 | Serendipity | 0:6/42 | N | P |
| 1905/1 | 47562 | Divine Providence | 0:6/108,1:6/108,2:6/108 | N | FM |
| 1905/2 | 47564 | Divine Providence | 0:6/108,1:6/108,2:6/108 | N | FM |
| 1905/3 | 47565 | Divine Providence | 0:6/108,1:6/108,2:6/108 | N | FM |
| 1905/4 | 47566 | Divine Providence | 0:6/108,1:6/108,2:6/108 | N | FM |
| 1905/5 | 47567 | Divine Providence | 0:6/108,1:6/108,2:6/108 | N | FM |
| 1911/1 | 47788 | Guardian Spirit | 0:6/118,1:6/69 | N | M |
| 2279/1 | 64127 | Body and Soul | 0:6/42,1:6/4 | N | PX |
| 2279/2 | 64129 | Body and Soul | 0:6/42,1:6/4 | N | PX |

### Priest: Shadow (source tab 203)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 461/1 | 15257 | Shadow Weaving | 0:6/109 | N | P |
| 461/2 | 15331 | Shadow Weaving | 0:6/109 | N | P |
| 461/3 | 15332 | Shadow Weaving | 0:6/109 | N | P |
| 462/1 | 15259 | Darkness | 0:6/108,1:6/108,2:6/108 | N | F |
| 462/2 | 15307 | Darkness | 0:6/108,1:6/108,2:6/108 | N | F |
| 462/3 | 15308 | Darkness | 0:6/108,1:6/108,2:6/108 | N | F |
| 462/4 | 15309 | Darkness | 0:6/108,1:6/108,2:6/108 | N | F |
| 462/5 | 15310 | Darkness | 0:6/108,1:6/108,2:6/108 | N | F |
| 463/1 | 15260 | Shadow Focus | 0:6/107,1:6/108 | N | F |
| 463/2 | 15327 | Shadow Focus | 0:6/107,1:6/108 | N | F |
| 463/3 | 15328 | Shadow Focus | 0:6/107,1:6/108 | N | F |
| 465/1 | 15270 | Spirit Tap | 0:6/42 | N | P |
| 465/2 | 15335 | Spirit Tap | 0:6/42 | N | P |
| 465/3 | 15336 | Spirit Tap | 0:6/42 | N | P |
| 466/1 | 15318 | Shadow Affinity | 0:6/108,1:6/4 | N | FX |
| 466/2 | 15272 | Shadow Affinity | 0:6/108,1:6/4 | N | FX |
| 466/3 | 15320 | Shadow Affinity | 0:6/108,1:6/4 | N | FX |
| 481/1 | 15273 | Improved Mind Blast | 0:6/107,1:3/0 | N | FX |
| 481/2 | 15312 | Improved Mind Blast | 0:6/107,1:3/0 | N | FX |
| 481/3 | 15313 | Improved Mind Blast | 0:6/107,1:3/0 | N | FX |
| 481/4 | 15314 | Improved Mind Blast | 0:6/107,1:3/0 | N | FX |
| 481/5 | 15316 | Improved Mind Blast | 0:6/107,1:3/0 | N | FX |
| 482/1 | 15275 | Improved Shadow Word: Pain | 0:6/108 | N | F |
| 482/2 | 15317 | Improved Shadow Word: Pain | 0:6/108 | N | F |
| 483/1 | 15274 | Veiled Shadows | 0:6/107,1:6/107 | N | F |
| 483/2 | 15311 | Veiled Shadows | 0:6/107,1:6/107 | N | F |
| 484/1 | 15286 | Vampiric Embrace | 0:6/4 | N | PX |
| 501/1 | 15407 | Mind Flay | 0:6/4,1:6/33,2:6/227 | N | PXM |
| 521/1 | 15473 | Shadowform | 0:6/36,1:6/79,2:6/87 | N | V |
| 541/1 | 15487 | Silence | 0:6/27 | N | M |
| 542/1 | 15392 | Improved Psychic Scream | 0:6/107 | N | F |
| 542/2 | 15448 | Improved Psychic Scream | 0:6/107 | N | F |
| 881/1 | 17322 | Shadow Reach | 0:6/108 | N | F |
| 881/2 | 17323 | Shadow Reach | 0:6/108 | N | F |
| 1638/1 | 27839 | Improved Vampiric Embrace | 0:6/108 | N | F |
| 1638/2 | 27840 | Improved Vampiric Embrace | 0:6/108 | N | F |
| 1777/1 | 33213 | Focused Mind | 0:6/108 | N | F |
| 1777/2 | 33214 | Focused Mind | 0:6/108 | N | F |
| 1777/3 | 33215 | Focused Mind | 0:6/108 | N | F |
| 1778/1 | 33221 | Shadow Power | 1:6/108 | N | F |
| 1778/2 | 33222 | Shadow Power | 1:6/108 | N | F |
| 1778/3 | 33223 | Shadow Power | 1:6/108 | N | F |
| 1778/4 | 33224 | Shadow Power | 1:6/108 | N | F |
| 1778/5 | 33225 | Shadow Power | 1:6/108 | N | F |
| 1779/1 | 34914 | Vampiric Touch | 0:6/4,1:6/3,2:6/4 | N | PX |
| 1781/1 | 14910 | Mind Melt | 0:6/107,1:6/107 | N | F |
| 1781/2 | 33371 | Mind Melt | 0:6/107,1:6/107 | N | F |
| 1816/1 | 33191 | Misery | 0:6/42,2:6/108 | N | FP |
| 1816/2 | 33192 | Misery | 0:6/42,2:6/108 | N | FP |
| 1816/3 | 33193 | Misery | 0:6/42,2:6/108 | N | FP |
| 1906/1 | 47569 | Improved Shadowform | 0:6/4,1:6/149 | N | XM |
| 1906/2 | 47570 | Improved Shadowform | 0:6/4,1:6/149 | N | XM |
| 1907/1 | 47573 | Twisted Faith | 0:6/174,1:6/112,2:6/175 | N | V |
| 1907/2 | 47577 | Twisted Faith | 0:6/174,1:6/112,2:6/175 | N | V |
| 1907/3 | 47578 | Twisted Faith | 0:6/174,1:6/112,2:6/175 | N | V |
| 1907/4 | 51166 | Twisted Faith | 0:6/174,1:6/112,2:6/175 | N | V |
| 1907/5 | 51167 | Twisted Faith | 0:6/174,1:6/112,2:6/175 | N | V |
| 1908/1 | 64044 | Psychic Horror | 0:6/12,1:64/0 | N | PM |
| 1909/1 | 47580 | Pain and Suffering | 0:6/42,1:6/4 | N | PX |
| 1909/2 | 47581 | Pain and Suffering | 0:6/42,1:6/4 | N | PX |
| 1909/3 | 47582 | Pain and Suffering | 0:6/42,1:6/4 | N | PX |
| 1910/1 | 47585 | Dispersion | 0:6/87,2:6/60 | N | V |
| 2027/1 | 15337 | Improved Spirit Tap | 0:6/42 | N | P |
| 2027/2 | 15338 | Improved Spirit Tap | 0:6/42 | N | P |
| 2267/1 | 63625 | Improved Devouring Plague | 0:6/108,1:6/4 | N | FX |
| 2267/2 | 63626 | Improved Devouring Plague | 0:6/108,1:6/4 | N | FX |
| 2267/3 | 63627 | Improved Devouring Plague | 0:6/108,1:6/4 | N | FX |

### Shaman: Elemental (source tab 261)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 561/1 | 16038 | Call of Flame | 0:6/108,1:6/108 | N | F |
| 561/2 | 16160 | Call of Flame | 0:6/108,1:6/108 | N | F |
| 561/3 | 16161 | Call of Flame | 0:6/108,1:6/108 | N | F |
| 562/1 | 16041 | Call of Thunder | 0:6/107 | N | F |
| 563/1 | 16035 | Concussion | 0:6/108,1:6/108 | N | F |
| 563/2 | 16105 | Concussion | 0:6/108,1:6/108 | N | F |
| 563/3 | 16106 | Concussion | 0:6/108,1:6/108 | N | F |
| 563/4 | 16107 | Concussion | 0:6/108,1:6/108 | N | F |
| 563/5 | 16108 | Concussion | 0:6/108,1:6/108 | N | F |
| 564/1 | 16039 | Convection | 0:6/108 | N | F |
| 564/2 | 16109 | Convection | 0:6/108 | N | F |
| 564/3 | 16110 | Convection | 0:6/108 | N | F |
| 564/4 | 16111 | Convection | 0:6/108 | N | F |
| 564/5 | 16112 | Convection | 0:6/108 | N | F |
| 565/1 | 16089 | Elemental Fury | 0:6/108 | N | F |
| 565/2 | 60184 | Elemental Fury | 0:6/108 | N | F |
| 565/3 | 60185 | Elemental Fury | 0:6/108 | N | F |
| 565/4 | 60187 | Elemental Fury | 0:6/108 | N | F |
| 565/5 | 60188 | Elemental Fury | 0:6/108 | N | F |
| 567/1 | 16086 | Improved Fire Nova | 0:6/108,1:6/107 | N | F |
| 567/2 | 16544 | Improved Fire Nova | 0:6/108,1:6/107 | N | F |
| 573/1 | 16166 | Elemental Mastery | 0:6/108,1:64/0 | N | FP |
| 574/1 | 16164 | Elemental Focus | 0:6/42 | N | P |
| 575/1 | 16040 | Reverberation | 0:6/107 | N | F |
| 575/2 | 16113 | Reverberation | 0:6/107 | N | F |
| 575/3 | 16114 | Reverberation | 0:6/107 | N | F |
| 575/4 | 16115 | Reverberation | 0:6/107 | N | F |
| 575/5 | 16116 | Reverberation | 0:6/107 | N | F |
| 721/1 | 16578 | Lightning Mastery | 0:6/107 | N | F |
| 721/2 | 16579 | Lightning Mastery | 0:6/107 | N | F |
| 721/3 | 16580 | Lightning Mastery | 0:6/107 | N | F |
| 721/4 | 16581 | Lightning Mastery | 0:6/107 | N | F |
| 721/5 | 16582 | Lightning Mastery | 0:6/107 | N | F |
| 1640/1 | 28996 | Elemental Warding | 0:6/87 | N | V |
| 1640/2 | 28997 | Elemental Warding | 0:6/87 | N | V |
| 1640/3 | 28998 | Elemental Warding | 0:6/87 | N | V |
| 1641/1 | 28999 | Elemental Reach | 0:6/107,1:6/108,2:6/107 | N | F |
| 1641/2 | 29000 | Elemental Reach | 0:6/107,1:6/108,2:6/107 | N | F |
| 1642/1 | 29062 | Eye of the Storm | 0:6/108 | N | F |
| 1642/2 | 29064 | Eye of the Storm | 0:6/108 | N | F |
| 1642/3 | 29065 | Eye of the Storm | 0:6/108 | N | F |
| 1645/1 | 30160 | Elemental Devastation | 0:6/42 | N | P |
| 1645/2 | 29179 | Elemental Devastation | 0:6/42 | N | P |
| 1645/3 | 29180 | Elemental Devastation | 0:6/42 | N | P |
| 1682/1 | 30664 | Unrelenting Storm | 0:6/219 | N | V |
| 1682/2 | 30665 | Unrelenting Storm | 0:6/219 | N | V |
| 1682/3 | 30666 | Unrelenting Storm | 0:6/219 | N | V |
| 1685/1 | 30672 | Elemental Precision | 0:6/199,1:6/10 | N | V |
| 1685/2 | 30673 | Elemental Precision | 0:6/199,1:6/10 | N | V |
| 1685/3 | 30674 | Elemental Precision | 0:6/199,1:6/10 | N | V |
| 1686/1 | 30675 | Lightning Overload | 0:6/4 | N | PX |
| 1686/2 | 30678 | Lightning Overload | 0:6/4 | N | PX |
| 1686/3 | 30679 | Lightning Overload | 0:6/4 | N | PX |
| 1687/1 | 30706 | Totem of Wrath | 0:28/0 | N | V |
| 2049/1 | 51466 | Elemental Oath | 0:65/57 | N | V |
| 2049/2 | 51470 | Elemental Oath | 0:65/57 | N | P |
| 2050/1 | 51474 | Astral Shift | 0:6/69,1:6/42 | N | P |
| 2050/2 | 51478 | Astral Shift | 0:6/69,1:6/42 | N | P |
| 2050/3 | 51479 | Astral Shift | 0:6/69,1:6/42 | N | P |
| 2051/1 | 51480 | Lava Flows | 0:6/4,1:6/108 | N | FX |
| 2051/2 | 51481 | Lava Flows | 0:6/4,1:6/108 | N | FX |
| 2051/3 | 51482 | Lava Flows | 0:6/4,1:6/108 | N | FX |
| 2052/1 | 51483 | Storm, Earth and Fire | 0:6/107,1:6/4,2:6/108 | N | FX |
| 2052/2 | 51485 | Storm, Earth and Fire | 0:6/107,1:6/4,2:6/108 | N | FX |
| 2052/3 | 51486 | Storm, Earth and Fire | 0:6/107,1:6/4,2:6/108 | N | FX |
| 2053/1 | 51490 | Thunderstorm | 0:2/0,1:137/0,2:98/0 | N | V |
| 2252/1 | 62097 | Shamanism | 0:6/107,1:6/107,2:6/107 | N | F |
| 2252/2 | 62098 | Shamanism | 0:6/107,1:6/107,2:6/107 | N | F |
| 2252/3 | 62099 | Shamanism | 0:6/107,1:6/107,2:6/107 | N | F |
| 2252/4 | 62100 | Shamanism | 0:6/107,1:6/107,2:6/107 | N | F |
| 2252/5 | 62101 | Shamanism | 0:6/107,1:6/107,2:6/107 | N | F |
| 2262/1 | 63370 | Booming Echoes | 0:6/107,1:6/108 | N | F |
| 2262/2 | 63372 | Booming Echoes | 0:6/107,1:6/108 | N | F |

### Shaman: Restoration (source tab 262)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 581/1 | 16176 | Ancestral Healing | 0:6/42 | N | P |
| 581/2 | 16235 | Ancestral Healing | 0:6/42 | N | P |
| 581/3 | 16240 | Ancestral Healing | 0:6/42 | N | P |
| 582/1 | 55198 | Tidal Force | 0:6/4 | N | X |
| 583/1 | 16180 | Improved Water Shield | 0:6/4 | N | PX |
| 583/2 | 16196 | Improved Water Shield | 0:6/4 | N | PX |
| 583/3 | 16198 | Improved Water Shield | 0:6/4 | N | PX |
| 586/1 | 16182 | Improved Healing Wave | 0:6/107 | N | F |
| 586/2 | 16226 | Improved Healing Wave | 0:6/107 | N | F |
| 586/3 | 16227 | Improved Healing Wave | 0:6/107 | N | F |
| 586/4 | 16228 | Improved Healing Wave | 0:6/107 | N | F |
| 586/5 | 16229 | Improved Healing Wave | 0:6/107 | N | F |
| 587/1 | 16181 | Healing Focus | 0:6/108 | N | F |
| 587/2 | 16230 | Healing Focus | 0:6/108 | N | F |
| 587/3 | 16232 | Healing Focus | 0:6/108 | N | F |
| 588/1 | 16187 | Restorative Totems | 0:6/108,1:6/4 | N | FX |
| 588/2 | 16205 | Restorative Totems | 0:6/108,1:6/4 | N | FX |
| 588/3 | 16206 | Restorative Totems | 0:6/108,1:6/4 | N | FX |
| 589/1 | 16184 | Improved Reincarnation | 0:6/107,1:6/107 | N | F |
| 589/2 | 16209 | Improved Reincarnation | 0:6/107,1:6/107 | N | F |
| 590/1 | 16190 | Mana Tide Totem | 0:28/0 | N | V |
| 591/1 | 16188 | Nature's Swiftness | 0:6/108 | N | FP |
| 592/1 | 16178 | Purification | 0:6/136 | N | V |
| 592/2 | 16210 | Purification | 0:6/136 | N | V |
| 592/3 | 16211 | Purification | 0:6/136 | N | V |
| 592/4 | 16212 | Purification | 0:6/136 | N | V |
| 592/5 | 16213 | Purification | 0:6/136 | N | V |
| 593/1 | 16179 | Tidal Focus | 0:6/108 | N | F |
| 593/2 | 16214 | Tidal Focus | 0:6/108 | N | F |
| 593/3 | 16215 | Tidal Focus | 0:6/108 | N | F |
| 593/4 | 16216 | Tidal Focus | 0:6/108 | N | F |
| 593/5 | 16217 | Tidal Focus | 0:6/108 | N | F |
| 594/1 | 16194 | Tidal Mastery | 0:6/107 | N | F |
| 594/2 | 16218 | Tidal Mastery | 0:6/107 | N | F |
| 594/3 | 16219 | Tidal Mastery | 0:6/107 | N | F |
| 594/4 | 16220 | Tidal Mastery | 0:6/107 | N | F |
| 594/5 | 16221 | Tidal Mastery | 0:6/107 | N | F |
| 595/1 | 16173 | Totemic Focus | 0:6/108 | N | F |
| 595/2 | 16222 | Totemic Focus | 0:6/108 | N | F |
| 595/3 | 16223 | Totemic Focus | 0:6/108 | N | F |
| 595/4 | 16224 | Totemic Focus | 0:6/108 | N | F |
| 595/5 | 16225 | Totemic Focus | 0:6/108 | N | F |
| 1646/1 | 29187 | Healing Grace | 0:6/108,1:6/107 | N | F |
| 1646/2 | 29189 | Healing Grace | 0:6/108,1:6/107 | N | F |
| 1646/3 | 29191 | Healing Grace | 0:6/108,1:6/107 | N | F |
| 1648/1 | 29206 | Healing Way | 0:6/108 | N | F |
| 1648/2 | 29205 | Healing Way | 0:6/108 | N | F |
| 1648/3 | 29202 | Healing Way | 0:6/108 | N | F |
| 1695/1 | 30864 | Focused Mind | 0:6/234,1:6/234 | N | V |
| 1695/2 | 30865 | Focused Mind | 0:6/234,1:6/234 | N | V |
| 1695/3 | 30866 | Focused Mind | 0:6/234,1:6/234 | N | V |
| 1696/1 | 30867 | Nature's Blessing | 0:6/175 | N | V |
| 1696/2 | 30868 | Nature's Blessing | 0:6/175 | N | V |
| 1696/3 | 30869 | Nature's Blessing | 0:6/175 | N | V |
| 1697/1 | 30872 | Improved Chain Heal | 0:6/108 | N | F |
| 1697/2 | 30873 | Improved Chain Heal | 0:6/108 | N | F |
| 1698/1 | 974 | Earth Shield | 0:6/4,1:6/149 | N | PX |
| 1699/1 | 30881 | Nature's Guardian | 0:6/42 | N | P |
| 1699/2 | 30883 | Nature's Guardian | 0:6/42 | N | P |
| 1699/3 | 30884 | Nature's Guardian | 0:6/42 | N | P |
| 1699/4 | 30885 | Nature's Guardian | 0:6/42 | N | P |
| 1699/5 | 30886 | Nature's Guardian | 0:6/42 | N | P |
| 2059/1 | 51560 | Improved Earth Shield | 0:6/107,1:6/108 | N | F |
| 2059/2 | 51561 | Improved Earth Shield | 0:6/107,1:6/108 | N | F |
| 2060/1 | 51554 | Blessing of the Eternals | 0:6/57,1:6/4 | N | X |
| 2060/2 | 51555 | Blessing of the Eternals | 0:6/57,1:6/4 | N | X |
| 2061/1 | 51556 | Ancestral Awakening | 0:6/4 | N | PX |
| 2061/2 | 51557 | Ancestral Awakening | 0:6/4 | N | PX |
| 2061/3 | 51558 | Ancestral Awakening | 0:6/4 | N | PX |
| 2063/1 | 51562 | Tidal Waves | 0:6/42,1:6/107,2:6/107 | N | FP |
| 2063/2 | 51563 | Tidal Waves | 0:6/42,1:6/107,2:6/107 | N | FP |
| 2063/3 | 51564 | Tidal Waves | 0:6/42,1:6/107,2:6/107 | N | FP |
| 2063/4 | 51565 | Tidal Waves | 0:6/42,1:6/107,2:6/107 | N | FP |
| 2063/5 | 51566 | Tidal Waves | 0:6/42,1:6/107,2:6/107 | N | FP |
| 2064/1 | 61295 | Riptide | 0:10/0,1:6/8 | N | V |
| 2084/1 | 51886 | Cleanse Spirit | 0:38/0,1:38/0,2:38/0 | N | V |

### Shaman: Enhancement (source tab 263)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 601/1 | 16254 | Anticipation | 0:6/49,1:6/234 | N | V |
| 601/2 | 16271 | Anticipation | 0:6/49,1:6/234 | N | V |
| 601/3 | 16272 | Anticipation | 0:6/49,1:6/234 | N | V |
| 602/1 | 16256 | Flurry | 0:6/42 | N | P |
| 602/2 | 16281 | Flurry | 0:6/42 | N | P |
| 602/3 | 16282 | Flurry | 0:6/42 | N | P |
| 602/4 | 16283 | Flurry | 0:6/42 | N | P |
| 602/5 | 16284 | Flurry | 0:6/42 | N | P |
| 605/1 | 16262 | Improved Ghost Wolf | 0:6/107 | N | F |
| 605/2 | 16287 | Improved Ghost Wolf | 0:6/107,1:6/108 | N | F |
| 607/1 | 16261 | Improved Shields | 0:6/108,1:6/108 | N | F |
| 607/2 | 16290 | Improved Shields | 0:6/108,1:6/108 | N | F |
| 607/3 | 51881 | Improved Shields | 0:6/108,1:6/108 | N | F |
| 609/1 | 16258 | Guardian Totems | 0:6/108,1:6/107 | N | F |
| 609/2 | 16293 | Guardian Totems | 0:6/108,1:6/107 | N | F |
| 610/1 | 16259 | Enhancing Totems | 0:6/108,1:6/108 | N | F |
| 610/2 | 16295 | Enhancing Totems | 0:6/108 | N | F |
| 610/3 | 52456 | Enhancing Totems | 0:6/108,1:6/108 | N | F |
| 611/1 | 16266 | Elemental Weapons | 0:6/108,1:6/108,2:6/108 | N | F |
| 611/2 | 29079 | Elemental Weapons | 0:6/108,1:6/108,2:6/108 | N | F |
| 611/3 | 29080 | Elemental Weapons | 0:6/108,1:6/108,2:6/108 | N | F |
| 613/1 | 16255 | Thundering Strikes | 0:6/52,1:6/57 | N | V |
| 613/2 | 16302 | Thundering Strikes | 0:6/52,1:6/57 | N | V |
| 613/3 | 16303 | Thundering Strikes | 0:6/52,1:6/57 | N | V |
| 613/4 | 16304 | Thundering Strikes | 0:6/52,1:6/57 | N | V |
| 613/5 | 16305 | Thundering Strikes | 0:6/52,1:6/57 | N | V |
| 614/1 | 17485 | Ancestral Knowledge | 0:6/137 | N | V |
| 614/2 | 17486 | Ancestral Knowledge | 0:6/137 | N | V |
| 614/3 | 17487 | Ancestral Knowledge | 0:6/137 | N | V |
| 614/4 | 17488 | Ancestral Knowledge | 0:6/137 | N | V |
| 614/5 | 17489 | Ancestral Knowledge | 0:6/137 | N | V |
| 615/1 | 16252 | Toughness | 0:6/137,1:6/232 | N | V |
| 615/2 | 16306 | Toughness | 0:6/137,1:6/232 | N | V |
| 615/3 | 16307 | Toughness | 0:6/137,1:6/232 | N | V |
| 615/4 | 16308 | Toughness | 0:6/137,1:6/232 | N | V |
| 615/5 | 16309 | Toughness | 0:6/137,1:6/232 | N | V |
| 616/1 | 16268 | Spirit Weapons | 0:36/0,1:36/0 | N | PA |
| 617/1 | 43338 | Shamanistic Focus | 0:6/108 | N | FP |
| 901/1 | 17364 | Stormstrike | 0:6/271,1:64/0,2:64/0 | N | PM |
| 1643/1 | 29082 | Weapon Mastery | 0:6/79 | N | M |
| 1643/2 | 29084 | Weapon Mastery | 0:6/79 | N | M |
| 1643/3 | 29086 | Weapon Mastery | 0:6/79 | N | M |
| 1647/1 | 29192 | Improved Windfury Totem | 0:6/107 | N | F |
| 1647/2 | 29193 | Improved Windfury Totem | 0:6/107 | N | F |
| 1689/1 | 30802 | Unleashed Rage | 0:6/240,1:65/166,2:65/167 | N | P |
| 1689/2 | 30808 | Unleashed Rage | 0:6/240,1:65/166,2:65/167 | N | V |
| 1689/3 | 30809 | Unleashed Rage | 0:6/240,1:65/166,2:65/167 | N | V |
| 1690/1 | 30798 | Dual Wield | 0:36/0 | N | PA |
| 1691/1 | 30812 | Mental Quickness | 0:6/108,1:6/237,2:6/238 | N | F |
| 1691/2 | 30813 | Mental Quickness | 0:6/108,1:6/237,2:6/238 | N | F |
| 1691/3 | 30814 | Mental Quickness | 0:6/108,1:6/237,2:6/238 | N | F |
| 1692/1 | 30816 | Dual Wield Specialization | 0:6/54 | N | V |
| 1692/2 | 30818 | Dual Wield Specialization | 0:6/54 | N | V |
| 1692/3 | 30819 | Dual Wield Specialization | 0:6/54 | N | V |
| 1693/1 | 30823 | Shamanistic Rage | 0:6/42,1:6/87 | N | P |
| 2054/1 | 51521 | Improved Stormstrike | 0:6/42 | N | P |
| 2054/2 | 51522 | Improved Stormstrike | 0:6/42 | N | P |
| 2055/1 | 51525 | Static Shock | 0:6/4,1:6/107 | N | FPX |
| 2055/2 | 51526 | Static Shock | 0:6/4,1:6/107 | N | FPX |
| 2055/3 | 51527 | Static Shock | 0:6/4,1:6/107 | N | FPX |
| 2056/1 | 51523 | Earthen Power | 0:6/4,1:6/108 | N | FX |
| 2056/2 | 51524 | Earthen Power | 0:6/4,1:6/108 | N | FX |
| 2057/1 | 51528 | Maelstrom Weapon | 0:6/42 | N | PM |
| 2057/2 | 51529 | Maelstrom Weapon | 0:6/42 | N | PM |
| 2057/3 | 51530 | Maelstrom Weapon | 0:6/42 | N | PM |
| 2057/4 | 51531 | Maelstrom Weapon | 0:6/42 | N | PM |
| 2057/5 | 51532 | Maelstrom Weapon | 0:6/42 | N | PM |
| 2058/1 | 51533 | Feral Spirit | 0:28/0 | N | V |
| 2083/1 | 51883 | Mental Dexterity | 0:6/268 | N | V |
| 2083/2 | 51884 | Mental Dexterity | 0:6/268 | N | V |
| 2083/3 | 51885 | Mental Dexterity | 0:6/268 | N | V |
| 2101/1 | 16043 | Earth's Grasp | 0:6/108,1:6/108,2:6/108 | N | F |
| 2101/2 | 16130 | Earth's Grasp | 0:6/108,1:6/108,2:6/108 | N | F |
| 2249/1 | 60103 | Lava Lash | 0:31/0,1:3/0 | N | XM |
| 2263/1 | 63373 | Frozen Power | 0:6/107,1:6/4 | N | FX |
| 2263/2 | 63374 | Frozen Power | 0:6/107,1:6/4 | N | FX |

### Druid: Feral Combat (source tab 281)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 794/1 | 16929 | Thick Hide | 0:6/142 | N | V |
| 794/2 | 16930 | Thick Hide | 0:6/142 | N | V |
| 794/3 | 16931 | Thick Hide | 0:6/142 | N | V |
| 795/1 | 16858 | Feral Aggression | 0:6/108,1:6/108 | N | F |
| 795/2 | 16859 | Feral Aggression | 0:6/108,1:6/108 | N | F |
| 795/3 | 16860 | Feral Aggression | 0:6/108,1:6/108 | N | F |
| 795/4 | 16861 | Feral Aggression | 0:6/108,1:6/108 | N | F |
| 795/5 | 16862 | Feral Aggression | 0:6/108,1:6/108 | N | F |
| 796/1 | 16934 | Ferocity | 0:6/107,1:6/107 | N | F |
| 796/2 | 16935 | Ferocity | 0:6/107,1:6/107 | N | F |
| 796/3 | 16936 | Ferocity | 0:6/107,1:6/107 | N | F |
| 796/4 | 16937 | Ferocity | 0:6/107,1:6/107 | N | F |
| 796/5 | 16938 | Ferocity | 0:6/107,1:6/107 | N | F |
| 797/1 | 16940 | Brutal Impact | 0:6/107,1:6/107 | N | F |
| 797/2 | 16941 | Brutal Impact | 0:6/107,1:6/107 | N | F |
| 798/1 | 16942 | Sharpened Claws | 0:6/52 | N | M |
| 798/2 | 16943 | Sharpened Claws | 0:6/52 | N | M |
| 798/3 | 16944 | Sharpened Claws | 0:6/52 | N | M |
| 799/1 | 16947 | Feral Instinct | 0:6/154,1:6/108 | N | FM |
| 799/2 | 16948 | Feral Instinct | 0:6/154,1:6/108 | N | FM |
| 799/3 | 16949 | Feral Instinct | 0:6/154,1:6/108 | N | FM |
| 801/1 | 37116 | Primal Fury | 0:36/0,1:36/0 | N | PMA |
| 801/2 | 37117 | Primal Fury | 0:36/0,1:36/0 | N | PMA |
| 802/1 | 16966 | Shredding Attacks | 0:6/107,1:6/107 | N | F |
| 802/2 | 16968 | Shredding Attacks | 0:6/107,1:6/107 | N | F |
| 803/1 | 16972 | Predatory Strikes | 0:6/4,1:6/4,2:6/109 | N | PX |
| 803/2 | 16974 | Predatory Strikes | 0:6/4,1:6/4,2:6/109 | N | PX |
| 803/3 | 16975 | Predatory Strikes | 0:6/4,1:6/4,2:6/109 | N | PX |
| 804/1 | 49377 | Feral Charge | 0:36/0,1:36/0 | N | PA |
| 805/1 | 16998 | Savage Fury | 0:6/108,1:6/108,2:6/108 | N | F |
| 805/2 | 16999 | Savage Fury | 0:6/108,1:6/108,2:6/108 | N | F |
| 807/1 | 17002 | Feral Swiftness | 0:6/31 | N | M |
| 807/2 | 24866 | Feral Swiftness | 0:6/31 | N | M |
| 808/1 | 17003 | Heart of the Wild | 0:6/137,1:3/0 | N | X |
| 808/2 | 17004 | Heart of the Wild | 0:6/137,1:3/0 | N | X |
| 808/3 | 17005 | Heart of the Wild | 0:6/137,1:3/0 | N | X |
| 808/4 | 17006 | Heart of the Wild | 0:6/137,1:3/0 | N | X |
| 808/5 | 24894 | Heart of the Wild | 0:6/137,1:3/0 | N | X |
| 809/1 | 17007 | Leader of the Pack | 0:6/4 | N | X |
| 1162/1 | 61336 | Survival Instincts | 0:6/4 | N | X |
| 1792/1 | 33872 | Nurturing Instinct | 0:6/175 | N | V |
| 1792/2 | 33873 | Nurturing Instinct | 0:6/175 | N | V |
| 1793/1 | 33851 | Primal Tenacity | 0:6/232,1:6/69 | N | V |
| 1793/2 | 33852 | Primal Tenacity | 0:6/232,1:6/69 | N | V |
| 1793/3 | 33957 | Primal Tenacity | 0:6/232,1:6/69 | N | V |
| 1794/1 | 33853 | Survival of the Fittest | 0:6/137,1:6/187,2:3/0 | N | X |
| 1794/2 | 33855 | Survival of the Fittest | 0:6/137,1:6/187,2:3/0 | N | X |
| 1794/3 | 33856 | Survival of the Fittest | 0:6/137,1:6/187,2:3/0 | N | X |
| 1795/1 | 33859 | Predatory Instincts | 0:6/163,1:6/229 | N | M |
| 1795/2 | 33866 | Predatory Instincts | 0:6/163,1:6/229 | N | M |
| 1795/3 | 33867 | Predatory Instincts | 0:6/163,1:6/229 | N | M |
| 1796/1 | 33917 | Mangle | 0:36/0,1:36/0 | N | PA |
| 1798/1 | 34297 | Improved Leader of the Pack | 0:6/107,1:3/0 | N | FX |
| 1798/2 | 34300 | Improved Leader of the Pack | 0:6/107,1:3/0 | N | FX |
| 1914/1 | 48409 | Primal Precision | 0:6/240,1:6/108 | N | F |
| 1914/2 | 48410 | Primal Precision | 0:6/240,1:6/108 | N | F |
| 1918/1 | 48432 | Rend and Tear | 0:6/4,1:6/4 | N | X |
| 1918/2 | 48433 | Rend and Tear | 0:6/4,1:6/4 | N | X |
| 1918/3 | 48434 | Rend and Tear | 0:6/4,1:6/4 | N | X |
| 1918/4 | 51268 | Rend and Tear | 0:6/4,1:6/4 | N | X |
| 1918/5 | 51269 | Rend and Tear | 0:6/4,1:6/4 | N | X |
| 1919/1 | 48483 | Infected Wounds | 0:6/42 | N | P |
| 1919/2 | 48484 | Infected Wounds | 0:6/42 | N | P |
| 1919/3 | 48485 | Infected Wounds | 0:6/42 | N | P |
| 1920/1 | 48532 | Improved Mangle | 0:6/107,1:6/107 | N | F |
| 1920/2 | 48489 | Improved Mangle | 0:6/107,1:6/107 | N | F |
| 1920/3 | 48491 | Improved Mangle | 0:6/107,1:6/107 | N | F |
| 1921/1 | 48492 | King of the Jungle | 0:6/4,1:6/4,2:6/108 | N | FX |
| 1921/2 | 48494 | King of the Jungle | 0:6/4,1:6/4,2:6/108 | N | FX |
| 1921/3 | 48495 | King of the Jungle | 0:6/4,1:6/4,2:6/108 | N | FX |
| 1927/1 | 50334 | Berserk | 0:6/108,1:6/107,2:6/77 | N | F |
| 2241/1 | 57873 | Protector of the Pack | 0:6/166,1:6/87 | N | M |
| 2241/2 | 57876 | Protector of the Pack | 0:6/166,1:6/87 | N | M |
| 2241/3 | 57877 | Protector of the Pack | 0:6/166,1:6/87 | N | M |
| 2242/1 | 57878 | Natural Reaction | 0:6/49,1:6/42 | N | PM |
| 2242/2 | 57880 | Natural Reaction | 0:6/49,1:6/42 | N | PM |
| 2242/3 | 57881 | Natural Reaction | 0:6/49,1:6/42 | N | PM |
| 2266/1 | 63503 | Primal Gore | 0:6/286 | N | V |

### Druid: Restoration (source tab 282)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 821/1 | 17050 | Improved Mark of the Wild | 0:6/108,1:6/137 | N | F |
| 821/2 | 17051 | Improved Mark of the Wild | 0:6/108,1:6/137 | N | F |
| 822/1 | 17056 | Furor | 0:6/4,1:6/107 | N | FX |
| 822/2 | 17058 | Furor | 0:6/4,1:6/107 | N | FX |
| 822/3 | 17059 | Furor | 0:6/4,1:6/107 | N | FX |
| 822/4 | 17060 | Furor | 0:6/4,1:6/107 | N | FX |
| 822/5 | 17061 | Furor | 0:6/4,1:6/107 | N | FX |
| 823/1 | 17063 | Nature's Focus | 0:6/108 | N | F |
| 823/2 | 17065 | Nature's Focus | 0:6/108 | N | F |
| 823/3 | 17066 | Nature's Focus | 0:6/108 | N | F |
| 824/1 | 17069 | Naturalist | 0:6/107,1:6/79 | N | F |
| 824/2 | 17070 | Naturalist | 0:6/107,1:6/79 | N | F |
| 824/3 | 17071 | Naturalist | 0:6/107,1:6/79 | N | F |
| 824/4 | 17072 | Naturalist | 0:6/107,1:6/79 | N | F |
| 824/5 | 17073 | Naturalist | 0:6/107,1:6/79 | N | F |
| 825/1 | 17074 | Nature's Bounty | 0:6/107 | N | F |
| 825/2 | 17075 | Nature's Bounty | 0:6/107 | N | F |
| 825/3 | 17076 | Nature's Bounty | 0:6/107 | N | F |
| 825/4 | 17077 | Nature's Bounty | 0:6/107 | N | F |
| 825/5 | 17078 | Nature's Bounty | 0:6/107 | N | F |
| 826/1 | 16833 | Natural Shapeshifter | 0:6/108 | N | F |
| 826/2 | 16834 | Natural Shapeshifter | 0:6/108 | N | F |
| 826/3 | 16835 | Natural Shapeshifter | 0:6/108 | N | F |
| 827/1 | 16864 | Omen of Clarity | 0:6/42 | N | P |
| 828/1 | 17104 | Gift of Nature | 0:6/108,1:6/108 | N | F |
| 828/2 | 24943 | Gift of Nature | 0:6/108,1:6/108 | N | F |
| 828/3 | 24944 | Gift of Nature | 0:6/108,1:6/108 | N | F |
| 828/4 | 24945 | Gift of Nature | 0:6/108,1:6/108 | N | F |
| 828/5 | 24946 | Gift of Nature | 0:6/108,1:6/108 | N | F |
| 829/1 | 17106 | Intensity | 0:6/134,1:6/42 | N | P |
| 829/2 | 17107 | Intensity | 0:6/134,1:6/42 | N | P |
| 829/3 | 17108 | Intensity | 0:6/134,1:6/42 | N | P |
| 830/1 | 17111 | Improved Rejuvenation | 0:6/108 | N | F |
| 830/2 | 17112 | Improved Rejuvenation | 0:6/108 | N | F |
| 830/3 | 17113 | Improved Rejuvenation | 0:6/108 | N | F |
| 831/1 | 17116 | Nature's Swiftness | 0:6/108 | N | FPM |
| 841/1 | 17118 | Subtlety | 0:6/108,1:6/107 | N | F |
| 841/2 | 17119 | Subtlety | 0:6/108,1:6/107 | N | F |
| 841/3 | 17120 | Subtlety | 0:6/108,1:6/107 | N | F |
| 842/1 | 17123 | Improved Tranquility | 0:6/108,1:6/108 | N | F |
| 842/2 | 17124 | Improved Tranquility | 0:6/108,1:6/108 | N | F |
| 843/1 | 24968 | Tranquil Spirit | 0:6/108 | N | F |
| 843/2 | 24969 | Tranquil Spirit | 0:6/108 | N | F |
| 843/3 | 24970 | Tranquil Spirit | 0:6/108 | N | F |
| 843/4 | 24971 | Tranquil Spirit | 0:6/108 | N | F |
| 843/5 | 24972 | Tranquil Spirit | 0:6/108 | N | F |
| 844/1 | 18562 | Swiftmend | 0:10/0 | N | M |
| 1788/1 | 33879 | Empowered Touch | 0:6/107,1:6/107 | N | F |
| 1788/2 | 33880 | Empowered Touch | 0:6/107,1:6/107 | N | F |
| 1789/1 | 33886 | Empowered Rejuvenation | 0:6/108 | N | F |
| 1789/2 | 33887 | Empowered Rejuvenation | 0:6/108 | N | F |
| 1789/3 | 33888 | Empowered Rejuvenation | 0:6/108 | N | F |
| 1789/4 | 33889 | Empowered Rejuvenation | 0:6/108 | N | F |
| 1789/5 | 33890 | Empowered Rejuvenation | 0:6/108 | N | F |
| 1790/1 | 33881 | Natural Perfection | 0:6/42,1:6/57 | N | P |
| 1790/2 | 33882 | Natural Perfection | 0:6/42,1:6/57 | N | P |
| 1790/3 | 33883 | Natural Perfection | 0:6/42,1:6/57 | N | P |
| 1791/1 | 65139 | Tree of Life | 0:36/0,1:36/0 | N | PA |
| 1797/1 | 34151 | Living Spirit | 0:6/137 | N | V |
| 1797/2 | 34152 | Living Spirit | 0:6/137 | N | V |
| 1797/3 | 34153 | Living Spirit | 0:6/137 | N | V |
| 1915/1 | 48411 | Master Shapeshifter | 0:6/4 | N | X |
| 1915/2 | 48412 | Master Shapeshifter | 0:6/4 | N | X |
| 1916/1 | 51179 | Gift of the Earthmother | 0:6/65,1:6/107 | N | F |
| 1916/2 | 51180 | Gift of the Earthmother | 0:6/65,1:6/107 | N | F |
| 1916/3 | 51181 | Gift of the Earthmother | 0:6/65,1:6/107 | N | F |
| 1916/4 | 51182 | Gift of the Earthmother | 0:6/65,1:6/107 | N | F |
| 1916/5 | 51183 | Gift of the Earthmother | 0:6/65,1:6/107 | N | F |
| 1917/1 | 48438 | Wild Growth | 0:6/8,1:6/4 | N | XM |
| 1922/1 | 48496 | Living Seed | 0:6/4 | N | PXM |
| 1922/2 | 48499 | Living Seed | 0:6/4 | N | PXM |
| 1922/3 | 48500 | Living Seed | 0:6/4 | N | PXM |
| 1929/1 | 48539 | Revitalize | 0:6/112,1:6/107 | N | F |
| 1929/2 | 48544 | Revitalize | 0:6/112,1:6/107 | N | F |
| 1929/3 | 48545 | Revitalize | 0:6/112,1:6/107 | N | F |
| 1930/1 | 48535 | Improved Tree of Life | 0:6/142,1:6/175 | N | M |
| 1930/2 | 48536 | Improved Tree of Life | 0:6/142,1:6/175 | N | M |
| 1930/3 | 48537 | Improved Tree of Life | 0:6/142,1:6/175 | N | M |
| 2264/1 | 63410 | Improved Barkskin | 0:6/107,1:6/107,2:6/107 | N | F |
| 2264/2 | 63411 | Improved Barkskin | 0:6/107,1:6/107,2:6/107 | N | F |

### Druid: Balance (source tab 283)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 762/1 | 16814 | Starlight Wrath | 0:6/107 | N | F |
| 762/2 | 16815 | Starlight Wrath | 0:6/107 | N | F |
| 762/3 | 16816 | Starlight Wrath | 0:6/107 | N | F |
| 762/4 | 16817 | Starlight Wrath | 0:6/107 | N | F |
| 762/5 | 16818 | Starlight Wrath | 0:6/107 | N | F |
| 763/1 | 16821 | Improved Moonfire | 0:6/107,1:6/108,2:6/108 | N | F |
| 763/2 | 16822 | Improved Moonfire | 0:6/107,1:6/108,2:6/108 | N | F |
| 764/1 | 16819 | Nature's Reach | 0:6/108,1:6/108,2:6/108 | N | F |
| 764/2 | 16820 | Nature's Reach | 0:6/108,1:6/108,2:6/108 | N | F |
| 782/1 | 16836 | Brambles | 0:6/4,1:6/108,2:6/107 | N | FX |
| 782/2 | 16839 | Brambles | 0:6/4,1:6/108,2:6/107 | N | FX |
| 782/3 | 16840 | Brambles | 0:6/4,1:6/108,2:6/107 | N | FX |
| 783/1 | 16845 | Moonglow | 0:6/108 | N | F |
| 783/2 | 16846 | Moonglow | 0:6/108 | N | F |
| 783/3 | 16847 | Moonglow | 0:6/108 | N | F |
| 784/1 | 16850 | Celestial Focus | 0:6/108,1:6/65 | N | FP |
| 784/2 | 16923 | Celestial Focus | 0:6/108,1:6/65 | N | FP |
| 784/3 | 16924 | Celestial Focus | 0:6/108,1:6/65 | N | FP |
| 788/1 | 5570 | Insect Swarm | 0:6/3,1:6/54 | N | M |
| 789/1 | 16880 | Nature's Grace | 0:6/42 | N | P |
| 789/2 | 61345 | Nature's Grace | 0:6/42 | N | P |
| 789/3 | 61346 | Nature's Grace | 0:6/42 | N | P |
| 790/1 | 16896 | Moonfury | 0:6/108,1:6/108 | N | F |
| 790/2 | 16897 | Moonfury | 0:6/108,1:6/108 | N | F |
| 790/3 | 16899 | Moonfury | 0:6/108,1:6/108 | N | F |
| 792/1 | 16909 | Vengeance | 0:6/108 | N | F |
| 792/2 | 16910 | Vengeance | 0:6/108 | N | F |
| 792/3 | 16911 | Vengeance | 0:6/108 | N | F |
| 792/4 | 16912 | Vengeance | 0:6/108 | N | F |
| 792/5 | 16913 | Vengeance | 0:6/108 | N | F |
| 793/1 | 24858 | Moonkin Form | 0:6/36,1:6/77,2:64/0 | N | PM |
| 1782/1 | 33589 | Lunar Guidance | 0:6/174,1:6/175 | N | V |
| 1782/2 | 33590 | Lunar Guidance | 0:6/174,1:6/175 | N | V |
| 1782/3 | 33591 | Lunar Guidance | 0:6/174,1:6/175 | N | V |
| 1783/1 | 33592 | Balance of Power | 0:6/199,1:6/87 | N | V |
| 1783/2 | 33596 | Balance of Power | 0:6/199,1:6/87 | N | V |
| 1784/1 | 33597 | Dreamstate | 0:6/219 | N | V |
| 1784/2 | 33599 | Dreamstate | 0:6/219 | N | V |
| 1784/3 | 33956 | Dreamstate | 0:6/219 | N | V |
| 1785/1 | 33600 | Improved Faerie Fire | 0:6/4,1:6/107 | N | FX |
| 1785/2 | 33601 | Improved Faerie Fire | 0:6/4,1:6/107 | N | FX |
| 1785/3 | 33602 | Improved Faerie Fire | 0:6/4,1:6/107 | N | FX |
| 1786/1 | 33603 | Wrath of Cenarius | 0:6/107,1:6/107 | N | F |
| 1786/2 | 33604 | Wrath of Cenarius | 0:6/107,1:6/107 | N | F |
| 1786/3 | 33605 | Wrath of Cenarius | 0:6/107,1:6/107 | N | F |
| 1786/4 | 33606 | Wrath of Cenarius | 0:6/107,1:6/107 | N | F |
| 1786/5 | 33607 | Wrath of Cenarius | 0:6/107,1:6/107 | N | F |
| 1787/1 | 33831 | Force of Nature | 0:28/0,1:6/226 | N | M |
| 1822/1 | 35363 | Nature's Majesty | 0:6/107 | N | F |
| 1822/2 | 35364 | Nature's Majesty | 0:6/107 | N | F |
| 1912/1 | 48384 | Improved Moonkin Form | 0:6/4,1:6/174 | N | XM |
| 1912/2 | 48395 | Improved Moonkin Form | 0:6/4,1:6/174 | N | XM |
| 1912/3 | 48396 | Improved Moonkin Form | 0:6/4,1:6/174 | N | XM |
| 1913/1 | 48389 | Owlkin Frenzy | 0:6/42 | N | PM |
| 1913/2 | 48392 | Owlkin Frenzy | 0:6/42 | N | PM |
| 1913/3 | 48393 | Owlkin Frenzy | 0:6/42 | N | PM |
| 1923/1 | 50516 | Typhoon | 0:3/0,1:64/0 | N | PXM |
| 1924/1 | 48516 | Eclipse | 0:6/4,1:6/4 | N | PX |
| 1924/2 | 48521 | Eclipse | 0:6/4,1:6/4 | N | PX |
| 1924/3 | 48525 | Eclipse | 0:6/4,1:6/4 | N | PX |
| 1925/1 | 48488 | Gale Winds | 0:6/108,1:6/107 | N | F |
| 1925/2 | 48514 | Gale Winds | 0:6/108,1:6/107 | N | F |
| 1926/1 | 48505 | Starfall | 0:6/23 | N | PM |
| 1928/1 | 48506 | Earth and Moon | 0:6/42,1:6/79 | N | P |
| 1928/2 | 48510 | Earth and Moon | 0:6/42,1:6/79 | N | P |
| 1928/3 | 48511 | Earth and Moon | 0:6/42,1:6/79 | N | P |
| 2238/1 | 57810 | Genesis | 0:6/108,1:6/108 | N | F |
| 2238/2 | 57811 | Genesis | 0:6/108,1:6/108 | N | F |
| 2238/3 | 57812 | Genesis | 0:6/108,1:6/108 | N | F |
| 2238/4 | 57813 | Genesis | 0:6/108,1:6/108 | N | F |
| 2238/5 | 57814 | Genesis | 0:6/108,1:6/108 | N | F |
| 2239/1 | 57849 | Improved Insect Swarm | 0:6/4,1:6/4 | N | X |
| 2239/2 | 57850 | Improved Insect Swarm | 0:6/4,1:6/4 | N | X |
| 2239/3 | 57851 | Improved Insect Swarm | 0:6/4,1:6/4 | N | X |
| 2240/1 | 57865 | Nature's Splendor | 0:6/107,1:6/107,2:6/107 | N | F |

### Warlock: Destruction (source tab 301)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 941/1 | 17778 | Cataclysm | 0:6/108 | N | F |
| 941/2 | 17779 | Cataclysm | 0:6/108 | N | F |
| 941/3 | 17780 | Cataclysm | 0:6/108 | N | F |
| 943/1 | 17788 | Bane | 0:6/107,1:6/107 | N | F |
| 943/2 | 17789 | Bane | 0:6/107,1:6/107 | N | F |
| 943/3 | 17790 | Bane | 0:6/107,1:6/107 | N | F |
| 943/4 | 17791 | Bane | 0:6/107,1:6/107 | N | F |
| 943/5 | 17792 | Bane | 0:6/107,1:6/107 | N | F |
| 944/1 | 17793 | Improved Shadow Bolt | 0:6/42,1:6/108 | N | FP |
| 944/2 | 17796 | Improved Shadow Bolt | 0:6/42,1:6/108 | N | FP |
| 944/3 | 17801 | Improved Shadow Bolt | 0:6/42,1:6/108 | N | FP |
| 944/4 | 17802 | Improved Shadow Bolt | 0:6/42,1:6/108 | N | FP |
| 944/5 | 17803 | Improved Shadow Bolt | 0:6/42,1:6/108 | N | FP |
| 961/1 | 17815 | Improved Immolate | 0:6/108,1:6/108 | N | F |
| 961/2 | 17833 | Improved Immolate | 0:6/108,1:6/108 | N | F |
| 961/3 | 17834 | Improved Immolate | 0:6/108,1:6/108,2:6/286 | N | F |
| 963/1 | 17877 | Shadowburn | 0:64/0,1:2/0 | N | P |
| 964/1 | 17917 | Destructive Reach | 0:6/108,1:6/108 | N | F |
| 964/2 | 17918 | Destructive Reach | 0:6/108,1:6/108 | N | F |
| 965/1 | 17927 | Improved Searing Pain | 0:6/107 | N | F |
| 965/2 | 17929 | Improved Searing Pain | 0:6/107 | N | F |
| 965/3 | 17930 | Improved Searing Pain | 0:6/107 | N | F |
| 966/1 | 17954 | Emberstorm | 0:6/108,1:6/108,2:6/107 | N | F |
| 966/2 | 17955 | Emberstorm | 0:6/108,1:6/108,2:6/107 | N | F |
| 966/3 | 17956 | Emberstorm | 0:6/108,1:6/108,2:6/107 | N | F |
| 966/4 | 17957 | Emberstorm | 0:6/108,1:6/108,2:6/107 | N | F |
| 966/5 | 17958 | Emberstorm | 0:6/108,1:6/108,2:6/107 | N | F |
| 967/1 | 17959 | Ruin | 0:6/108 | N | F |
| 967/2 | 59738 | Ruin | 0:6/108 | N | F |
| 967/3 | 59739 | Ruin | 0:6/108 | N | F |
| 967/4 | 59740 | Ruin | 0:6/108 | N | F |
| 967/5 | 59741 | Ruin | 0:6/108 | N | F |
| 968/1 | 17962 | Conflagrate | 0:2/0,1:6/3 | N | V |
| 981/1 | 18130 | Devastation | 0:6/107 | N | F |
| 982/1 | 18119 | Aftermath | 0:6/42,1:6/108 | N | FP |
| 982/2 | 18120 | Aftermath | 0:6/42,1:6/108 | N | FP |
| 983/1 | 18126 | Demonic Power | 0:6/107,1:6/107 | N | F |
| 983/2 | 18127 | Demonic Power | 0:6/107,1:6/107 | N | F |
| 985/1 | 18135 | Intensity | 0:6/108 | N | F |
| 985/2 | 18136 | Intensity | 0:6/108 | N | F |
| 986/1 | 18096 | Pyroclasm | 0:6/42 | N | P |
| 986/2 | 18073 | Pyroclasm | 0:6/42 | N | P |
| 986/3 | 63245 | Pyroclasm | 0:6/42 | N | P |
| 1676/1 | 30283 | Shadowfury | 0:2/0,1:6/12 | N | M |
| 1677/1 | 30288 | Shadow and Flame | 0:6/108 | N | F |
| 1677/2 | 30289 | Shadow and Flame | 0:6/108 | N | F |
| 1677/3 | 30290 | Shadow and Flame | 0:6/108 | N | F |
| 1677/4 | 30291 | Shadow and Flame | 0:6/108 | N | F |
| 1677/5 | 30292 | Shadow and Flame | 0:6/108 | N | F |
| 1678/1 | 30293 | Soul Leech | 0:6/4 | N | PX |
| 1678/2 | 30295 | Soul Leech | 0:6/4 | N | PX |
| 1678/3 | 30296 | Soul Leech | 0:6/4 | N | PX |
| 1679/1 | 30299 | Nether Protection | 0:6/42 | N | P |
| 1679/2 | 30301 | Nether Protection | 0:6/42 | N | P |
| 1679/3 | 30302 | Nether Protection | 0:6/42 | N | P |
| 1817/1 | 34935 | Backlash | 0:6/42,1:6/57 | N | P |
| 1817/2 | 34938 | Backlash | 0:6/42,1:6/57 | N | P |
| 1817/3 | 34939 | Backlash | 0:6/42,1:6/57 | N | P |
| 1887/1 | 63349 | Molten Skin | 0:6/87 | N | V |
| 1887/2 | 63350 | Molten Skin | 0:6/87 | N | V |
| 1887/3 | 63351 | Molten Skin | 0:6/87 | N | V |
| 1888/1 | 47258 | Backdraft | 0:6/42 | N | P |
| 1888/2 | 47259 | Backdraft | 0:6/42 | N | P |
| 1888/3 | 47260 | Backdraft | 0:6/42 | N | P |
| 1889/1 | 54117 | Improved Soul Leech | 0:6/4,1:6/4 | N | X |
| 1889/2 | 54118 | Improved Soul Leech | 0:6/4,1:6/4 | N | X |
| 1890/1 | 47266 | Fire and Brimstone | 0:6/4,1:6/107 | N | FX |
| 1890/2 | 47267 | Fire and Brimstone | 0:6/4,1:6/107 | N | FX |
| 1890/3 | 47268 | Fire and Brimstone | 0:6/4,1:6/107 | N | FX |
| 1890/4 | 47269 | Fire and Brimstone | 0:6/4,1:6/107 | N | FX |
| 1890/5 | 47270 | Fire and Brimstone | 0:6/4,1:6/107 | N | FX |
| 1891/1 | 50796 | Chaos Bolt | 0:2/0 | N | V |
| 2045/1 | 47220 | Empowered Imp | 0:6/108,1:6/107 | N | F |
| 2045/2 | 47221 | Empowered Imp | 0:6/108,1:6/107 | N | F |
| 2045/3 | 47223 | Empowered Imp | 0:6/108,1:6/107 | N | F |

### Warlock: Affliction (source tab 302)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1001/1 | 17783 | Fel Concentration | 0:6/108 | N | F |
| 1001/2 | 17784 | Fel Concentration | 0:6/108 | N | F |
| 1001/3 | 17785 | Fel Concentration | 0:6/108 | N | F |
| 1002/1 | 18094 | Nightfall | 0:6/4 | N | PX |
| 1002/2 | 18095 | Nightfall | 0:6/4 | N | PX |
| 1003/1 | 17810 | Improved Corruption | 0:6/108,1:6/107 | N | F |
| 1003/2 | 17811 | Improved Corruption | 0:6/108,1:6/107 | N | F |
| 1003/3 | 17812 | Improved Corruption | 0:6/108,1:6/107 | N | F |
| 1003/4 | 17813 | Improved Corruption | 0:6/108,1:6/107 | N | F |
| 1003/5 | 17814 | Improved Corruption | 0:6/108,1:6/107 | N | F |
| 1004/1 | 17804 | Soul Siphon | 0:6/4,1:6/112 | N | X |
| 1004/2 | 17805 | Soul Siphon | 0:6/4,1:6/112 | N | X |
| 1005/1 | 18174 | Suppression | 0:6/199,1:6/108 | N | F |
| 1005/2 | 18175 | Suppression | 0:6/199,1:6/108 | N | F |
| 1005/3 | 18176 | Suppression | 0:6/199,1:6/108 | N | F |
| 1006/1 | 18179 | Improved Curse of Weakness | 0:6/108 | N | F |
| 1006/2 | 18180 | Improved Curse of Weakness | 0:6/108 | N | F |
| 1007/1 | 18182 | Improved Life Tap | 0:6/4 | N | X |
| 1007/2 | 18183 | Improved Life Tap | 0:6/4 | N | X |
| 1021/1 | 18218 | Grim Reach | 0:6/108 | N | F |
| 1021/2 | 18219 | Grim Reach | 0:6/108 | N | F |
| 1022/1 | 18220 | Dark Pact | 0:8/0 | N | V |
| 1041/1 | 63108 | Siphon Life | 0:6/4,1:6/108 | N | FPX |
| 1042/1 | 18271 | Shadow Mastery | 0:6/108,1:6/108 | N | F |
| 1042/2 | 18272 | Shadow Mastery | 0:6/108,1:6/108 | N | F |
| 1042/3 | 18273 | Shadow Mastery | 0:6/108,1:6/108 | N | F |
| 1042/4 | 18274 | Shadow Mastery | 0:6/108,1:6/108 | N | F |
| 1042/5 | 18275 | Shadow Mastery | 0:6/108,1:6/108 | N | F |
| 1061/1 | 18288 | Amplify Curse | 1:6/107 | N | F |
| 1081/1 | 18223 | Curse of Exhaustion | 0:6/33 | N | M |
| 1101/1 | 18213 | Improved Drain Soul | 0:6/4,1:6/108,2:3/0 | N | FX |
| 1101/2 | 18372 | Improved Drain Soul | 0:6/4,1:6/108,2:3/0 | N | FX |
| 1284/1 | 18827 | Improved Curse of Agony | 0:6/108 | N | F |
| 1284/2 | 18829 | Improved Curse of Agony | 0:6/108 | N | F |
| 1667/1 | 32477 | Malediction | 0:6/107,1:6/79 | N | F |
| 1667/2 | 32483 | Malediction | 0:6/107,1:6/79 | N | F |
| 1667/3 | 32484 | Malediction | 0:6/107,1:6/79 | N | F |
| 1668/1 | 30054 | Improved Howl of Terror | 0:6/107 | N | F |
| 1668/2 | 30057 | Improved Howl of Terror | 0:6/107 | N | F |
| 1669/1 | 30060 | Contagion | 0:6/108,1:6/108,2:6/107 | N | F |
| 1669/2 | 30061 | Contagion | 0:6/108,1:6/108,2:6/107 | N | F |
| 1669/3 | 30062 | Contagion | 0:6/108,1:6/108,2:6/107 | N | F |
| 1669/4 | 30063 | Contagion | 0:6/108,1:6/108,2:6/107 | N | F |
| 1669/5 | 30064 | Contagion | 0:6/108,1:6/108,2:6/107 | N | F |
| 1670/1 | 30108 | Unstable Affliction | 0:6/3,1:77/0 | N | X |
| 1763/1 | 32385 | Shadow Embrace | 0:6/42 | N | P |
| 1763/2 | 32387 | Shadow Embrace | 0:6/42 | N | P |
| 1763/3 | 32392 | Shadow Embrace | 0:6/42 | N | P |
| 1763/4 | 32393 | Shadow Embrace | 0:6/42 | N | P |
| 1763/5 | 32394 | Shadow Embrace | 0:6/42 | N | P |
| 1764/1 | 32381 | Empowered Corruption | 0:6/107 | N | F |
| 1764/2 | 32382 | Empowered Corruption | 0:6/107 | N | F |
| 1764/3 | 32383 | Empowered Corruption | 0:6/107 | N | F |
| 1873/1 | 54037 | Improved Felhunter | 0:6/107,1:6/108,2:6/108 | N | F |
| 1873/2 | 54038 | Improved Felhunter | 0:6/107,1:6/108,2:6/108 | N | F |
| 1875/1 | 47198 | Death's Embrace | 0:6/112,1:6/112 | N | V |
| 1875/2 | 47199 | Death's Embrace | 0:6/112,1:6/112 | N | V |
| 1875/3 | 47200 | Death's Embrace | 0:6/112,1:6/112 | N | V |
| 1876/1 | 47201 | Everlasting Affliction | 0:6/42,1:6/107 | N | FP |
| 1876/2 | 47202 | Everlasting Affliction | 0:6/42,1:6/107 | N | FP |
| 1876/3 | 47203 | Everlasting Affliction | 0:6/42,1:6/107 | N | FP |
| 1876/4 | 47204 | Everlasting Affliction | 0:6/42,1:6/107 | N | FP |
| 1876/5 | 47205 | Everlasting Affliction | 0:6/42,1:6/107 | N | FP |
| 1878/1 | 47195 | Eradication | 0:6/42 | N | P |
| 1878/2 | 47196 | Eradication | 0:6/42 | N | P |
| 1878/3 | 47197 | Eradication | 0:6/42 | N | P |
| 2041/1 | 48181 | Haunt | 0:2/0,1:6/4,2:6/271 | N | X |
| 2205/1 | 53754 | Improved Fear | 0:6/4 | N | PX |
| 2205/2 | 53759 | Improved Fear | 0:6/4 | N | PX |
| 2245/1 | 58435 | Pandemic | 0:6/286,1:6/108 | N | F |

### Warlock: Demonology (source tab 303)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1221/1 | 18692 | Improved Healthstone | 0:6/4 | N | X |
| 1221/2 | 18693 | Improved Healthstone | 0:6/4 | N | X |
| 1222/1 | 18694 | Improved Imp | 0:6/108 | N | F |
| 1222/2 | 18695 | Improved Imp | 0:6/108 | N | F |
| 1222/3 | 18696 | Improved Imp | 0:6/108 | N | F |
| 1223/1 | 18697 | Demonic Embrace | 0:6/137 | N | V |
| 1223/2 | 18698 | Demonic Embrace | 0:6/137 | N | V |
| 1223/3 | 18699 | Demonic Embrace | 0:6/137 | N | V |
| 1224/1 | 18703 | Improved Health Funnel | 0:6/108,1:6/108 | N | F |
| 1224/2 | 18704 | Improved Health Funnel | 0:6/108,1:6/108 | N | F |
| 1225/1 | 18705 | Demonic Brutality | 0:6/108,1:6/107 | N | F |
| 1225/2 | 18706 | Demonic Brutality | 0:6/108,1:6/107 | N | F |
| 1225/3 | 18707 | Demonic Brutality | 0:6/108,1:6/107 | N | F |
| 1226/1 | 18708 | Fel Domination | 0:6/107,1:6/108 | N | FP |
| 1227/1 | 18709 | Master Summoner | 0:6/107,1:6/108 | N | F |
| 1227/2 | 18710 | Master Summoner | 0:6/107,1:6/108 | N | F |
| 1242/1 | 18731 | Fel Vitality | 0:6/107,1:6/132,2:6/133 | N | F |
| 1242/2 | 18743 | Fel Vitality | 0:6/107,1:6/132,2:6/133 | N | F |
| 1242/3 | 18744 | Fel Vitality | 0:6/107,1:6/132,2:6/133 | N | F |
| 1243/1 | 18754 | Improved Succubus | 0:6/108,1:6/108 | N | F |
| 1243/2 | 18755 | Improved Succubus | 0:6/108,1:6/108 | N | F |
| 1243/3 | 18756 | Improved Succubus | 0:6/108,1:6/108 | N | F |
| 1244/1 | 23785 | Master Demonologist | 0:6/4 | N | X |
| 1244/2 | 23822 | Master Demonologist | 0:6/4 | N | X |
| 1244/3 | 23823 | Master Demonologist | 0:6/4 | N | X |
| 1244/4 | 23824 | Master Demonologist | 0:6/4 | N | X |
| 1244/5 | 23825 | Master Demonologist | 0:6/4 | N | X |
| 1261/1 | 18767 | Master Conjuror | 0:6/108,1:6/108 | N | F |
| 1261/2 | 18768 | Master Conjuror | 0:6/108,1:6/108 | N | F |
| 1262/1 | 18769 | Unholy Power | 0:6/107 | N | F |
| 1262/2 | 18770 | Unholy Power | 0:6/107 | N | F |
| 1262/3 | 18771 | Unholy Power | 0:6/107 | N | F |
| 1262/4 | 18772 | Unholy Power | 0:6/107 | N | F |
| 1262/5 | 18773 | Unholy Power | 0:6/107 | N | F |
| 1263/1 | 35691 | Demonic Knowledge | 0:6/4 | N | X |
| 1263/2 | 35692 | Demonic Knowledge | 0:6/4 | N | X |
| 1263/3 | 35693 | Demonic Knowledge | 0:6/4 | N | X |
| 1281/1 | 30326 | Mana Feed | 0:6/107 | N | F |
| 1282/1 | 19028 | Soul Link | 0:3/0 | N | X |
| 1283/1 | 47245 | Molten Core | 0:6/42,1:6/107 | N | FP |
| 1283/2 | 47246 | Molten Core | 0:6/42,1:6/107 | N | FP |
| 1283/3 | 47247 | Molten Core | 0:6/42,1:6/107 | N | FP |
| 1671/1 | 30143 | Demonic Aegis | 0:6/108 | N | F |
| 1671/2 | 30144 | Demonic Aegis | 0:6/108 | N | F |
| 1671/3 | 30145 | Demonic Aegis | 0:6/108 | N | F |
| 1672/1 | 30146 | Summon Felguard | 0:56/0 | N | V |
| 1673/1 | 30242 | Demonic Tactics | 0:6/107,1:6/57,2:6/52 | N | F |
| 1673/2 | 30245 | Demonic Tactics | 0:6/107,1:6/57,2:6/52 | N | F |
| 1673/3 | 30246 | Demonic Tactics | 0:6/107,1:6/57,2:6/52 | N | F |
| 1673/4 | 30247 | Demonic Tactics | 0:6/107,1:6/57,2:6/52 | N | F |
| 1673/5 | 30248 | Demonic Tactics | 0:6/107,1:6/57,2:6/52 | N | F |
| 1680/1 | 30319 | Demonic Resilience | 0:6/187,1:6/107,2:6/179 | N | F |
| 1680/2 | 30320 | Demonic Resilience | 0:6/187,1:6/107,2:6/179 | N | F |
| 1680/3 | 30321 | Demonic Resilience | 0:6/187,1:6/107,2:6/179 | N | F |
| 1880/1 | 47193 | Demonic Empowerment | 0:77/0 | N | X |
| 1882/1 | 54347 | Improved Demonic Tactics | 0:6/4 | N | X |
| 1882/2 | 54348 | Improved Demonic Tactics | 0:6/4 | N | X |
| 1882/3 | 54349 | Improved Demonic Tactics | 0:6/4 | N | X |
| 1883/1 | 47230 | Fel Synergy | 0:6/4 | N | PX |
| 1883/2 | 47231 | Fel Synergy | 0:6/4 | N | PX |
| 1884/1 | 63117 | Nemesis | 0:6/108 | N | F |
| 1884/2 | 63121 | Nemesis | 0:6/108 | N | F |
| 1884/3 | 63123 | Nemesis | 0:6/108 | N | F |
| 1885/1 | 47236 | Demonic Pact | 0:6/4,1:6/107,2:6/79 | N | FX |
| 1885/2 | 47237 | Demonic Pact | 0:6/4,1:6/107,2:6/79 | N | FX |
| 1885/3 | 47238 | Demonic Pact | 0:6/4,1:6/107,2:6/79 | N | FX |
| 1885/4 | 47239 | Demonic Pact | 0:6/4,1:6/107,2:6/79 | N | FX |
| 1885/5 | 47240 | Demonic Pact | 0:6/4,1:6/107,2:6/79 | N | FX |
| 1886/1 | 59672 | Metamorphosis | 0:36/0,1:36/0,2:36/0 | N | PA |
| 2261/1 | 63156 | Decimation | 0:6/42,1:6/4 | N | PX |
| 2261/2 | 63158 | Decimation | 0:6/42,1:6/4 | N | PX |

### Hunter: Beast Mastery (source tab 361)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1381/1 | 19549 | Improved Aspect of the Monkey | 0:6/107 | N | F |
| 1381/2 | 19550 | Improved Aspect of the Monkey | 0:6/107 | N | F |
| 1381/3 | 19551 | Improved Aspect of the Monkey | 0:6/107 | N | F |
| 1382/1 | 19552 | Improved Aspect of the Hawk | 0:6/107,1:6/107 | N | F |
| 1382/2 | 19553 | Improved Aspect of the Hawk | 0:6/107,1:6/107 | N | F |
| 1382/3 | 19554 | Improved Aspect of the Hawk | 0:6/107,1:6/107 | N | F |
| 1382/4 | 19555 | Improved Aspect of the Hawk | 0:6/107,1:6/107 | N | F |
| 1382/5 | 19556 | Improved Aspect of the Hawk | 0:6/107,1:6/107 | N | F |
| 1384/1 | 19559 | Pathfinding | 0:6/107,1:6/172,2:6/211 | N | F |
| 1384/2 | 19560 | Pathfinding | 0:6/107,1:6/172,2:6/211 | N | F |
| 1385/1 | 19572 | Improved Mend Pet | 0:6/4,1:6/108 | N | FX |
| 1385/2 | 19573 | Improved Mend Pet | 0:6/4,1:6/108 | N | FX |
| 1386/1 | 19574 | Bestial Wrath | 0:6/61,1:6/79,2:6/77 | N | V |
| 1387/1 | 19577 | Intimidation | 0:6/42,1:77/0 | N | PX |
| 1388/1 | 19578 | Spirit Bond | 0:6/4,1:6/4 | N | X |
| 1388/2 | 20895 | Spirit Bond | 0:6/4,1:6/4 | N | X |
| 1389/1 | 19583 | Endurance Training | 0:6/107,1:6/133 | N | F |
| 1389/2 | 19584 | Endurance Training | 0:6/107,1:6/133 | N | F |
| 1389/3 | 19585 | Endurance Training | 0:6/107,1:6/133 | N | F |
| 1389/4 | 19586 | Endurance Training | 0:6/107,1:6/133 | N | F |
| 1389/5 | 19587 | Endurance Training | 0:6/107,1:6/133 | N | F |
| 1390/1 | 19590 | Bestial Discipline | 0:6/107 | N | F |
| 1390/2 | 19592 | Bestial Discipline | 0:6/107 | N | F |
| 1393/1 | 19598 | Ferocity | 0:6/107 | N | F |
| 1393/2 | 19599 | Ferocity | 0:6/107 | N | F |
| 1393/3 | 19600 | Ferocity | 0:6/107 | N | F |
| 1393/4 | 19601 | Ferocity | 0:6/107 | N | F |
| 1393/5 | 19602 | Ferocity | 0:6/107 | N | F |
| 1395/1 | 19609 | Thick Hide | 0:6/107,1:6/142 | N | F |
| 1395/2 | 19610 | Thick Hide | 0:6/107,1:6/142 | N | F |
| 1395/3 | 19612 | Thick Hide | 0:6/107,1:6/142 | N | F |
| 1396/1 | 19616 | Unleashed Fury | 0:6/107 | N | F |
| 1396/2 | 19617 | Unleashed Fury | 0:6/107 | N | F |
| 1396/3 | 19618 | Unleashed Fury | 0:6/107 | N | F |
| 1396/4 | 19619 | Unleashed Fury | 0:6/107 | N | F |
| 1396/5 | 19620 | Unleashed Fury | 0:6/107 | N | F |
| 1397/1 | 19621 | Frenzy | 0:6/107 | N | F |
| 1397/2 | 19622 | Frenzy | 0:6/107 | N | F |
| 1397/3 | 19623 | Frenzy | 0:6/107 | N | F |
| 1397/4 | 19624 | Frenzy | 0:6/107 | N | F |
| 1397/5 | 19625 | Frenzy | 0:6/107 | N | F |
| 1624/1 | 35029 | Focused Fire | 0:3/0,1:6/4 | N | X |
| 1624/2 | 35030 | Focused Fire | 0:3/0,1:6/4 | N | X |
| 1625/1 | 24443 | Improved Revive Pet | 0:6/107,1:6/108,2:6/107 | N | F |
| 1625/2 | 19575 | Improved Revive Pet | 0:6/107,1:6/108,2:6/107 | N | F |
| 1799/1 | 34453 | Animal Handler | 0:6/107,1:6/4 | N | FX |
| 1799/2 | 34454 | Animal Handler | 0:6/107,1:6/4 | N | FX |
| 1800/1 | 34455 | Ferocious Inspiration | 0:6/4,2:6/108 | N | FX |
| 1800/2 | 34459 | Ferocious Inspiration | 0:6/4,2:6/108 | N | FX |
| 1800/3 | 34460 | Ferocious Inspiration | 0:6/4,2:6/108 | N | FX |
| 1801/1 | 34462 | Catlike Reflexes | 0:6/49,1:6/107,2:6/107 | N | F |
| 1801/2 | 34464 | Catlike Reflexes | 0:6/49,1:6/107,2:6/107 | N | F |
| 1801/3 | 34465 | Catlike Reflexes | 0:6/49,1:6/107,2:6/107 | N | F |
| 1802/1 | 34466 | Serpent's Swiftness | 0:6/140,1:6/107 | N | F |
| 1802/2 | 34467 | Serpent's Swiftness | 0:6/140,1:6/107 | N | F |
| 1802/3 | 34468 | Serpent's Swiftness | 0:6/140,1:6/107 | N | F |
| 1802/4 | 34469 | Serpent's Swiftness | 0:6/140,1:6/107 | N | F |
| 1802/5 | 34470 | Serpent's Swiftness | 0:6/140,1:6/107 | N | F |
| 1803/1 | 34692 | The Beast Within | 0:6/79 | N | V |
| 2136/1 | 53252 | Invigoration | 0:6/4 | N | X |
| 2136/2 | 53253 | Invigoration | 0:6/4 | N | X |
| 2137/1 | 53256 | Cobra Strikes | 0:6/42 | N | P |
| 2137/2 | 53259 | Cobra Strikes | 0:6/42 | N | P |
| 2137/3 | 53260 | Cobra Strikes | 0:6/42 | N | P |
| 2138/1 | 53265 | Aspect Mastery | 0:6/107,1:6/107,2:6/108 | N | F |
| 2139/1 | 53270 | Beast Mastery | 0:6/146,1:6/145 | N | V |
| 2140/1 | 53262 | Longevity | 0:6/108 | N | F |
| 2140/2 | 53263 | Longevity | 0:6/108 | N | F |
| 2140/3 | 53264 | Longevity | 0:6/108 | N | F |
| 2227/1 | 56314 | Kindred Spirits | 0:6/4,1:6/4 | N | X |
| 2227/2 | 56315 | Kindred Spirits | 0:6/4,1:6/4 | N | X |
| 2227/3 | 56316 | Kindred Spirits | 0:6/4,1:6/4 | N | X |
| 2227/4 | 56317 | Kindred Spirits | 0:6/4,1:6/4 | N | X |
| 2227/5 | 56318 | Kindred Spirits | 0:6/4,1:6/4 | N | X |

### Hunter: Survival (source tab 362)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1303/1 | 19168 | Lightning Reflexes | 0:6/137 | N | V |
| 1303/2 | 19180 | Lightning Reflexes | 0:6/137 | N | V |
| 1303/3 | 19181 | Lightning Reflexes | 0:6/137 | N | V |
| 1303/4 | 24296 | Lightning Reflexes | 0:6/137 | N | V |
| 1303/5 | 24297 | Lightning Reflexes | 0:6/137 | N | V |
| 1304/1 | 19184 | Entrapment | 0:6/42 | N | P |
| 1304/2 | 19387 | Entrapment | 0:6/42 | N | P |
| 1304/3 | 19388 | Entrapment | 0:6/42 | N | P |
| 1305/1 | 19376 | Trap Mastery | 0:6/108,1:6/108,2:6/107 | N | F |
| 1305/2 | 63457 | Trap Mastery | 0:6/108,1:6/108,2:6/107 | N | F |
| 1305/3 | 63458 | Trap Mastery | 0:6/108,1:6/108,2:6/107 | N | F |
| 1306/1 | 56342 | Lock and Load | 0:6/42,1:6/4,2:6/4 | N | PX |
| 1306/2 | 56343 | Lock and Load | 0:6/42,1:6/4 | N | PX |
| 1306/3 | 56344 | Lock and Load | 0:6/42,1:6/4 | N | PX |
| 1309/1 | 19286 | Survival Tactics | 0:6/107,1:6/107 | N | F |
| 1309/2 | 19287 | Survival Tactics | 0:6/107,1:6/107 | N | FP |
| 1310/1 | 19290 | Surefooted | 0:6/232,1:6/232 | N | V |
| 1310/2 | 19294 | Surefooted | 0:6/232,1:6/232 | N | V |
| 1310/3 | 24283 | Surefooted | 0:6/232,1:6/232 | N | V |
| 1311/1 | 19295 | Deflection | 0:6/47,1:6/234 | N | V |
| 1311/2 | 19297 | Deflection | 0:6/47,1:6/234 | N | V |
| 1311/3 | 19298 | Deflection | 0:6/47,1:6/234 | N | V |
| 1312/1 | 19306 | Counterattack | 0:2/0,1:6/26 | N | M |
| 1321/1 | 19370 | Killer Instinct | 0:6/52 | N | V |
| 1321/2 | 19371 | Killer Instinct | 0:6/52 | N | V |
| 1321/3 | 19373 | Killer Instinct | 0:6/52 | N | V |
| 1322/1 | 3674 | Black Arrow | 0:6/3,1:6/271 | N | M |
| 1325/1 | 19386 | Wyvern Sting | 0:6/12 | N | PM |
| 1621/1 | 19159 | Savage Strikes | 0:6/107 | N | F |
| 1621/2 | 19160 | Savage Strikes | 0:6/107 | N | F |
| 1622/1 | 19255 | Survivalist | 0:6/137 | N | V |
| 1622/2 | 19256 | Survivalist | 0:6/137 | N | V |
| 1622/3 | 19257 | Survivalist | 0:6/137 | N | V |
| 1622/4 | 19258 | Survivalist | 0:6/137 | N | V |
| 1622/5 | 19259 | Survivalist | 0:6/137 | N | V |
| 1623/1 | 52783 | Improved Tracking | 0:6/107 | N | F |
| 1623/2 | 52785 | Improved Tracking | 0:6/107 | N | F |
| 1623/3 | 52786 | Improved Tracking | 0:6/107 | N | F |
| 1623/4 | 52787 | Improved Tracking | 0:6/107 | N | F |
| 1623/5 | 52788 | Improved Tracking | 0:6/107 | N | F |
| 1809/1 | 34491 | Resourcefulness | 0:6/108,1:6/107 | N | F |
| 1809/2 | 34492 | Resourcefulness | 0:6/108,1:6/107 | N | F |
| 1809/3 | 34493 | Resourcefulness | 0:6/108,1:6/107 | N | F |
| 1810/1 | 34494 | Survival Instincts | 0:6/87,1:6/107 | N | F |
| 1810/2 | 34496 | Survival Instincts | 0:6/87,1:6/107 | N | F |
| 1811/1 | 34497 | Thrill of the Hunt | 0:6/4 | N | PX |
| 1811/2 | 34498 | Thrill of the Hunt | 0:6/4 | N | PX |
| 1811/3 | 34499 | Thrill of the Hunt | 0:6/4 | N | PX |
| 1812/1 | 34500 | Expose Weakness | 0:6/42 | N | P |
| 1812/2 | 34502 | Expose Weakness | 0:6/42 | N | P |
| 1812/3 | 34503 | Expose Weakness | 0:6/42 | N | P |
| 1813/1 | 34506 | Master Tactician | 0:6/42 | N | P |
| 1813/2 | 34507 | Master Tactician | 0:6/42 | N | P |
| 1813/3 | 34508 | Master Tactician | 0:6/42 | N | P |
| 1813/4 | 34838 | Master Tactician | 0:6/42 | N | P |
| 1813/5 | 34839 | Master Tactician | 0:6/42 | N | P |
| 1814/1 | 19503 | Scatter Shot | 0:31/0,1:6/5,2:64/0 | N | PM |
| 1820/1 | 19498 | Hawk Eye | 0:6/107 | N | F |
| 1820/2 | 19499 | Hawk Eye | 0:6/107 | N | F |
| 1820/3 | 19500 | Hawk Eye | 0:6/107 | N | F |
| 2141/1 | 53295 | Noxious Stings | 0:6/107,1:6/112 | N | F |
| 2141/2 | 53296 | Noxious Stings | 0:6/107,1:6/112 | N | F |
| 2141/3 | 53297 | Noxious Stings | 0:6/107,1:6/112 | N | F |
| 2142/1 | 53298 | Point of No Escape | 0:6/107,1:6/107 | N | F |
| 2142/2 | 53299 | Point of No Escape | 0:6/107,1:6/107 | N | F |
| 2143/1 | 53302 | Sniper Training | 0:6/23,1:6/107 | N | F |
| 2143/2 | 53303 | Sniper Training | 0:6/23,1:6/107 | N | F |
| 2143/3 | 53304 | Sniper Training | 0:6/23,1:6/107 | N | F |
| 2144/1 | 53290 | Hunting Party | 0:6/4,1:6/137 | N | PX |
| 2144/2 | 53291 | Hunting Party | 0:6/4,1:6/137 | N | PX |
| 2144/3 | 53292 | Hunting Party | 0:6/4,1:6/137 | N | PX |
| 2145/1 | 53301 | Explosive Shot | 0:6/226 | N | M |
| 2228/1 | 56339 | Hunter vs. Wild | 0:6/268,1:6/212 | N | V |
| 2228/2 | 56340 | Hunter vs. Wild | 0:6/268,1:6/212 | N | V |
| 2228/3 | 56341 | Hunter vs. Wild | 0:6/268,1:6/212 | N | V |
| 2229/1 | 56333 | T.N.T. | 0:6/4,1:6/108,2:6/108 | N | FX |
| 2229/2 | 56336 | T.N.T. | 0:6/4,1:6/108,2:6/108 | N | FX |
| 2229/3 | 56337 | T.N.T. | 0:6/4,1:6/108,2:6/108 | N | FX |

### Hunter: Marksmanship (source tab 363)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1341/1 | 19407 | Improved Concussive Shot | 0:6/107 | N | F |
| 1341/2 | 19412 | Improved Concussive Shot | 0:6/107 | N | F |
| 1342/1 | 19416 | Efficiency | 0:6/108 | N | F |
| 1342/2 | 19417 | Efficiency | 0:6/108 | N | F |
| 1342/3 | 19418 | Efficiency | 0:6/108 | N | F |
| 1342/4 | 19419 | Efficiency | 0:6/108 | N | F |
| 1342/5 | 19420 | Efficiency | 0:6/108 | N | F |
| 1343/1 | 19421 | Improved Hunter's Mark | 0:6/108,1:6/108 | N | F |
| 1343/2 | 19422 | Improved Hunter's Mark | 0:6/108,1:6/108 | N | F |
| 1343/3 | 19423 | Improved Hunter's Mark | 0:6/108,1:6/108 | N | F |
| 1344/1 | 19426 | Lethal Shots | 0:6/52 | N | M |
| 1344/2 | 19427 | Lethal Shots | 0:6/52 | N | M |
| 1344/3 | 19429 | Lethal Shots | 0:6/52 | N | M |
| 1344/4 | 19430 | Lethal Shots | 0:6/52 | N | M |
| 1344/5 | 19431 | Lethal Shots | 0:6/52 | N | M |
| 1345/1 | 19434 | Aimed Shot | 0:121/0,1:6/118 | N | M |
| 1346/1 | 19454 | Improved Arcane Shot | 0:6/108 | N | F |
| 1346/2 | 19455 | Improved Arcane Shot | 0:6/108 | N | F |
| 1346/3 | 19456 | Improved Arcane Shot | 0:6/108 | N | F |
| 1347/1 | 19461 | Barrage | 0:6/108,1:6/108 | N | F |
| 1347/2 | 19462 | Barrage | 0:6/108,1:6/108 | N | F |
| 1347/3 | 24691 | Barrage | 0:6/108,1:6/108 | N | F |
| 1348/1 | 19464 | Improved Stings | 0:6/108,1:6/108,2:6/107 | N | F |
| 1348/2 | 19465 | Improved Stings | 0:6/108,1:6/108,2:6/107 | N | F |
| 1348/3 | 19466 | Improved Stings | 0:6/108,1:6/108,2:6/107 | N | F |
| 1349/1 | 19485 | Mortal Shots | 0:6/108,1:6/108 | N | F |
| 1349/2 | 19487 | Mortal Shots | 0:6/108,1:6/108 | N | F |
| 1349/3 | 19488 | Mortal Shots | 0:6/108,1:6/108 | N | F |
| 1349/4 | 19489 | Mortal Shots | 0:6/108,1:6/108 | N | F |
| 1349/5 | 19490 | Mortal Shots | 0:6/108,1:6/108 | N | F |
| 1351/1 | 35100 | Concussive Barrage | 0:6/42 | N | P |
| 1351/2 | 35102 | Concussive Barrage | 0:6/42 | N | P |
| 1353/1 | 23989 | Readiness | 0:3/0 | N | X |
| 1361/1 | 19506 | Trueshot Aura | 0:65/167,1:65/166 | N | V |
| 1362/1 | 19507 | Ranged Weapon Specialization | 0:6/79 | N | M |
| 1362/2 | 19508 | Ranged Weapon Specialization | 0:6/79 | N | M |
| 1362/3 | 19509 | Ranged Weapon Specialization | 0:6/79 | N | M |
| 1804/1 | 34475 | Combat Experience | 0:6/137,1:6/137 | N | V |
| 1804/2 | 34476 | Combat Experience | 0:6/137,1:6/137 | N | V |
| 1806/1 | 34482 | Careful Aim | 0:6/212 | N | V |
| 1806/2 | 34483 | Careful Aim | 0:6/212 | N | V |
| 1806/3 | 34484 | Careful Aim | 0:6/212 | N | V |
| 1807/1 | 34485 | Master Marksman | 0:6/52,1:6/108 | N | F |
| 1807/2 | 34486 | Master Marksman | 0:6/52,1:6/108 | N | F |
| 1807/3 | 34487 | Master Marksman | 0:6/52,1:6/108 | N | F |
| 1807/4 | 34488 | Master Marksman | 0:6/52,1:6/108 | N | F |
| 1807/5 | 34489 | Master Marksman | 0:6/52,1:6/108 | N | F |
| 1808/1 | 34490 | Silencing Shot | 0:31/0,1:6/27 | N | M |
| 1818/1 | 34950 | Go for the Throat | 0:6/42 | N | P |
| 1818/2 | 34954 | Go for the Throat | 0:6/42 | N | P |
| 1819/1 | 34948 | Rapid Killing | 0:6/42,1:6/107 | N | FP |
| 1819/2 | 34949 | Rapid Killing | 0:6/42,1:6/107 | N | FP |
| 1821/1 | 35104 | Improved Barrage | 0:6/107,1:6/108 | N | F |
| 1821/2 | 35110 | Improved Barrage | 0:6/107,1:6/108 | N | F |
| 1821/3 | 35111 | Improved Barrage | 0:6/107,1:6/108 | N | F |
| 2130/1 | 53234 | Piercing Shots | 0:6/42 | N | P |
| 2130/2 | 53237 | Piercing Shots | 0:6/42 | N | P |
| 2130/3 | 53238 | Piercing Shots | 0:6/42 | N | P |
| 2131/1 | 53228 | Rapid Recuperation | 0:6/42,1:6/4 | N | PX |
| 2131/2 | 53232 | Rapid Recuperation | 0:6/42,1:6/4 | N | PX |
| 2132/1 | 53215 | Wild Quiver | 0:6/42,1:6/274 | N | P |
| 2132/2 | 53216 | Wild Quiver | 0:6/42,1:6/274 | N | P |
| 2132/3 | 53217 | Wild Quiver | 0:6/42,1:6/274 | N | P |
| 2133/1 | 53221 | Improved Steady Shot | 0:6/42 | N | P |
| 2133/2 | 53222 | Improved Steady Shot | 0:6/42 | N | P |
| 2133/3 | 53224 | Improved Steady Shot | 0:6/42 | N | P |
| 2134/1 | 53241 | Marked for Death | 0:6/112,1:6/108 | N | F |
| 2134/2 | 53243 | Marked for Death | 0:6/112,1:6/108 | N | F |
| 2134/3 | 53244 | Marked for Death | 0:6/112,1:6/108 | N | F |
| 2134/4 | 53245 | Marked for Death | 0:6/112,1:6/108 | N | F |
| 2134/5 | 53246 | Marked for Death | 0:6/112,1:6/108 | N | F |
| 2135/1 | 53209 | Chimera Shot | 0:77/0,1:121/0,2:31/0 | N | XM |
| 2197/1 | 53620 | Focused Aim | 0:6/108,1:6/54 | N | F |
| 2197/2 | 53621 | Focused Aim | 0:6/108,1:6/54 | N | F |
| 2197/3 | 53622 | Focused Aim | 0:6/108,1:6/54 | N | F |

### Paladin: Retribution (source tab 381)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1401/1 | 20042 | Improved Blessing of Might | 0:6/108 | N | F |
| 1401/2 | 20045 | Improved Blessing of Might | 0:6/108 | N | F |
| 1402/1 | 20049 | Vengeance | 0:6/42 | N | P |
| 1402/2 | 20056 | Vengeance | 0:6/42 | N | P |
| 1402/3 | 20057 | Vengeance | 0:6/42 | N | P |
| 1403/1 | 20060 | Deflection | 0:6/47 | N | V |
| 1403/2 | 20061 | Deflection | 0:6/47 | N | V |
| 1403/3 | 20062 | Deflection | 0:6/47 | N | V |
| 1403/4 | 20063 | Deflection | 0:6/47 | N | V |
| 1403/5 | 20064 | Deflection | 0:6/47 | N | V |
| 1407/1 | 20101 | Benediction | 0:6/108 | N | F |
| 1407/2 | 20102 | Benediction | 0:6/108 | N | F |
| 1407/3 | 20103 | Benediction | 0:6/108 | N | F |
| 1407/4 | 20104 | Benediction | 0:6/108 | N | F |
| 1407/5 | 20105 | Benediction | 0:6/108 | N | F |
| 1410/1 | 20111 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 1410/2 | 20112 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 1410/3 | 20113 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 1411/1 | 20117 | Conviction | 0:6/52,1:6/57 | N | V |
| 1411/2 | 20118 | Conviction | 0:6/52,1:6/57 | N | V |
| 1411/3 | 20119 | Conviction | 0:6/52,1:6/57 | N | V |
| 1411/4 | 20120 | Conviction | 0:6/52,1:6/57 | N | V |
| 1411/5 | 20121 | Conviction | 0:6/52,1:6/57 | N | V |
| 1441/1 | 20066 | Repentance | 0:6/12 | N | M |
| 1464/1 | 20335 | Heart of the Crusader | 0:6/4 | N | X |
| 1464/2 | 20336 | Heart of the Crusader | 0:6/4 | N | X |
| 1464/3 | 20337 | Heart of the Crusader | 0:6/4 | N | X |
| 1481/1 | 20375 | Seal of Command | 0:6/42,2:6/4 | N | PX |
| 1631/1 | 25956 | Improved Judgements | 0:6/107 | N | F |
| 1631/2 | 25957 | Improved Judgements | 0:6/107 | N | F |
| 1632/1 | 9799 | Eye for an Eye | 0:6/4 | N | PX |
| 1632/2 | 25988 | Eye for an Eye | 0:6/4 | N | PX |
| 1633/1 | 9452 | Vindication | 0:6/42 | N | P |
| 1633/2 | 26016 | Vindication | 0:6/42 | N | P |
| 1634/1 | 26022 | Pursuit of Justice | 0:6/31,2:6/234 | N | V |
| 1634/2 | 26023 | Pursuit of Justice | 0:6/31,2:6/234 | N | V |
| 1755/1 | 31866 | Crusade | 0:6/168,1:6/79 | N | V |
| 1755/2 | 31867 | Crusade | 0:6/168,1:6/79 | N | V |
| 1755/3 | 31868 | Crusade | 0:6/168,1:6/79 | N | V |
| 1756/1 | 31869 | Sanctified Retribution | 0:6/107,1:6/108 | N | F |
| 1757/1 | 31871 | Divine Purpose | 0:6/186,1:6/185,2:6/4 | N | X |
| 1757/2 | 31872 | Divine Purpose | 0:6/186,1:6/185,2:6/4 | N | X |
| 1758/1 | 31876 | Judgements of the Wise | 0:6/4 | N | PX |
| 1758/2 | 31877 | Judgements of the Wise | 0:6/4 | N | PX |
| 1758/3 | 31878 | Judgements of the Wise | 0:6/4 | N | PX |
| 1759/1 | 31879 | Fanaticism | 0:6/107,1:6/10 | N | F |
| 1759/2 | 31880 | Fanaticism | 0:6/107,1:6/10 | N | F |
| 1759/3 | 31881 | Fanaticism | 0:6/107,1:6/10 | N | F |
| 1761/1 | 32043 | Sanctity of Battle | 0:6/57,1:6/108,2:6/52 | N | F |
| 1761/2 | 35396 | Sanctity of Battle | 0:6/57,1:6/108,2:6/52 | N | F |
| 1761/3 | 35397 | Sanctity of Battle | 0:6/57,1:6/108,2:6/52 | N | F |
| 1823/1 | 35395 | Crusader Strike | 0:121/0,1:31/0,2:6/4 | N | XM |
| 2147/1 | 53375 | Sanctified Wrath | 0:6/107,1:6/107,2:6/4 | N | FX |
| 2147/2 | 53376 | Sanctified Wrath | 0:6/107,1:6/107,2:6/4 | N | FX |
| 2148/1 | 53379 | Swift Retribution | 0:6/107 | N | F |
| 2148/2 | 53484 | Swift Retribution | 0:6/107 | N | F |
| 2148/3 | 53648 | Swift Retribution | 0:6/107 | N | F |
| 2149/1 | 53380 | Righteous Vengeance | 0:6/4 | N | PX |
| 2149/2 | 53381 | Righteous Vengeance | 0:6/4 | N | PX |
| 2149/3 | 53382 | Righteous Vengeance | 0:6/4 | N | PX |
| 2150/1 | 53385 | Divine Storm | 0:3/0,1:3/0,2:31/0 | N | XM |
| 2176/1 | 53486 | The Art of War | 0:6/108,1:6/42 | N | FP |
| 2176/2 | 53488 | The Art of War | 0:6/108,1:6/42 | N | FP |
| 2179/1 | 53501 | Sheath of Light | 0:6/237,1:6/4,2:6/238 | N | PX |
| 2179/2 | 53502 | Sheath of Light | 0:6/237,1:6/4,2:6/238 | N | PX |
| 2179/3 | 53503 | Sheath of Light | 0:6/237,1:6/4,2:6/238 | N | PX |

### Paladin: Holy (source tab 382)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1432/1 | 20205 | Spiritual Focus | 0:6/108 | N | F |
| 1432/2 | 20206 | Spiritual Focus | 0:6/108 | N | F |
| 1432/3 | 20207 | Spiritual Focus | 0:6/108 | N | F |
| 1432/4 | 20209 | Spiritual Focus | 0:6/108 | N | F |
| 1432/5 | 20208 | Spiritual Focus | 0:6/108 | N | F |
| 1433/1 | 20216 | Divine Favor | 0:6/107 | N | FP |
| 1435/1 | 31821 | Aura Mastery | 0:6/108,1:6/108,2:6/108 | N | F |
| 1443/1 | 20234 | Improved Lay on Hands | 0:6/42,1:6/107 | N | FP |
| 1443/2 | 20235 | Improved Lay on Hands | 0:6/42,1:6/107 | N | FP |
| 1444/1 | 20237 | Healing Light | 0:6/108 | N | F |
| 1444/2 | 20238 | Healing Light | 0:6/108 | N | F |
| 1444/3 | 20239 | Healing Light | 0:6/108 | N | F |
| 1446/1 | 20244 | Improved Blessing of Wisdom | 0:6/108 | N | F |
| 1446/2 | 20245 | Improved Blessing of Wisdom | 0:6/108 | N | F |
| 1449/1 | 20257 | Divine Intellect | 0:6/137 | N | V |
| 1449/2 | 20258 | Divine Intellect | 0:6/137 | N | V |
| 1449/3 | 20259 | Divine Intellect | 0:6/137 | N | V |
| 1449/4 | 20260 | Divine Intellect | 0:6/137 | N | V |
| 1449/5 | 20261 | Divine Intellect | 0:6/137 | N | V |
| 1450/1 | 20254 | Improved Concentration Aura | 0:6/107,1:6/107,2:6/107 | N | F |
| 1450/2 | 20255 | Improved Concentration Aura | 0:6/107,1:6/107,2:6/107 | N | F |
| 1450/3 | 20256 | Improved Concentration Aura | 0:6/107,1:6/107,2:6/107 | N | F |
| 1461/1 | 20210 | Illumination | 0:6/42,1:6/112 | N | P |
| 1461/2 | 20212 | Illumination | 0:6/42,1:6/112 | N | P |
| 1461/3 | 20213 | Illumination | 0:6/42,1:6/112 | N | P |
| 1461/4 | 20214 | Illumination | 0:6/42,1:6/112 | N | P |
| 1461/5 | 20215 | Illumination | 0:6/42,1:6/112 | N | P |
| 1463/1 | 20224 | Seals of the Pure | 0:6/108,1:6/108 | N | F |
| 1463/2 | 20225 | Seals of the Pure | 0:6/108,1:6/108 | N | F |
| 1463/3 | 20330 | Seals of the Pure | 0:6/108,1:6/108 | N | F |
| 1463/4 | 20331 | Seals of the Pure | 0:6/108,1:6/108 | N | F |
| 1463/5 | 20332 | Seals of the Pure | 0:6/108,1:6/108 | N | F |
| 1465/1 | 20359 | Sanctified Light | 0:6/107 | N | F |
| 1465/2 | 20360 | Sanctified Light | 0:6/107 | N | F |
| 1465/3 | 20361 | Sanctified Light | 0:6/107 | N | F |
| 1502/1 | 20473 | Holy Shock | 0:3/0 | N | X |
| 1627/1 | 5923 | Holy Power | 0:6/71 | N | V |
| 1627/2 | 5924 | Holy Power | 0:6/71 | N | V |
| 1627/3 | 5925 | Holy Power | 0:6/71 | N | V |
| 1627/4 | 5926 | Holy Power | 0:6/71 | N | V |
| 1627/5 | 25829 | Holy Power | 0:6/71 | N | V |
| 1628/1 | 9453 | Unyielding Faith | 0:6/232,1:6/232 | N | V |
| 1628/2 | 25836 | Unyielding Faith | 0:6/232,1:6/232 | N | V |
| 1742/1 | 31822 | Pure of Heart | 0:6/246,1:6/246,2:6/246 | N | V |
| 1742/2 | 31823 | Pure of Heart | 0:6/246,1:6/246,2:6/246 | N | V |
| 1743/1 | 31825 | Purifying Power | 0:6/108,1:6/108 | N | F |
| 1743/2 | 31826 | Purifying Power | 0:6/108,1:6/108 | N | F |
| 1744/1 | 31828 | Blessed Life | 0:6/42 | N | P |
| 1744/2 | 31829 | Blessed Life | 0:6/42 | N | P |
| 1744/3 | 31830 | Blessed Life | 0:6/42 | N | P |
| 1745/1 | 31833 | Light's Grace | 0:6/42 | N | P |
| 1745/2 | 31835 | Light's Grace | 0:6/42 | N | P |
| 1745/3 | 31836 | Light's Grace | 0:6/42 | N | P |
| 1746/1 | 31837 | Holy Guidance | 0:6/174,1:6/175 | N | V |
| 1746/2 | 31838 | Holy Guidance | 0:6/174,1:6/175 | N | V |
| 1746/3 | 31839 | Holy Guidance | 0:6/174,1:6/175 | N | V |
| 1746/4 | 31840 | Holy Guidance | 0:6/174,1:6/175 | N | V |
| 1746/5 | 31841 | Holy Guidance | 0:6/174,1:6/175 | N | V |
| 1747/1 | 31842 | Divine Illumination | 0:6/72 | N | V |
| 2190/1 | 53551 | Sacred Cleansing | 0:6/42 | N | P |
| 2190/2 | 53552 | Sacred Cleansing | 0:6/42 | N | P |
| 2190/3 | 53553 | Sacred Cleansing | 0:6/42 | N | P |
| 2191/1 | 53556 | Enlightened Judgements | 0:6/107,1:6/54,2:6/55 | N | F |
| 2191/2 | 53557 | Enlightened Judgements | 0:6/107,1:6/54,2:6/55 | N | F |
| 2192/1 | 53563 | Beacon of Light | 0:6/23 | N | P |
| 2193/1 | 53569 | Infusion of Light | 0:6/42 | N | P |
| 2193/2 | 53576 | Infusion of Light | 0:6/42 | N | P |
| 2198/1 | 53660 | Blessed Hands | 0:6/108,1:6/107,2:6/108 | N | F |
| 2198/2 | 53661 | Blessed Hands | 0:6/108,1:6/107,2:6/108 | N | F |
| 2199/1 | 53671 | Judgements of the Pure | 0:6/42,1:6/108,2:6/108 | N | FP |
| 2199/2 | 53673 | Judgements of the Pure | 0:6/42,1:6/108,2:6/108 | N | FP |
| 2199/3 | 54151 | Judgements of the Pure | 0:6/42,1:6/108,2:6/108 | N | FP |
| 2199/4 | 54154 | Judgements of the Pure | 0:6/42,1:6/108,2:6/108 | N | FP |
| 2199/5 | 54155 | Judgements of the Pure | 0:6/42,1:6/108,2:6/108 | N | FP |

### Paladin: Protection (source tab 383)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1421/1 | 20127 | Redoubt | 0:6/42,1:6/150 | N | PM |
| 1421/2 | 20130 | Redoubt | 0:6/42,1:6/150 | N | PM |
| 1421/3 | 20135 | Redoubt | 0:6/42,1:6/150 | N | PM |
| 1422/1 | 20138 | Improved Devotion Aura | 0:6/108,1:6/107 | N | F |
| 1422/2 | 20139 | Improved Devotion Aura | 0:6/108,1:6/107 | N | F |
| 1422/3 | 20140 | Improved Devotion Aura | 0:6/108,1:6/107 | N | F |
| 1423/1 | 20143 | Toughness | 0:6/142,1:6/232 | N | V |
| 1423/2 | 20144 | Toughness | 0:6/142,1:6/232 | N | V |
| 1423/3 | 20145 | Toughness | 0:6/142,1:6/232 | N | V |
| 1423/4 | 20146 | Toughness | 0:6/142,1:6/232 | N | V |
| 1423/5 | 20147 | Toughness | 0:6/142,1:6/232 | N | V |
| 1425/1 | 20174 | Guardian's Favor | 0:6/107,1:6/107 | N | F |
| 1425/2 | 20175 | Guardian's Favor | 0:6/107,1:6/107 | N | F |
| 1426/1 | 20177 | Reckoning | 0:6/42 | N | P |
| 1426/2 | 20179 | Reckoning | 0:6/42 | N | P |
| 1426/3 | 20181 | Reckoning | 0:6/42 | N | P |
| 1426/4 | 20180 | Reckoning | 0:6/42 | N | P |
| 1426/5 | 20182 | Reckoning | 0:6/42 | N | P |
| 1429/1 | 20196 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 1429/2 | 20197 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 1429/3 | 20198 | One-Handed Weapon Specialization | 0:6/79 | N | M |
| 1430/1 | 20925 | Holy Shield | 0:6/51,1:6/43,2:6/189 | N | PM |
| 1431/1 | 20911 | Blessing of Sanctuary | 0:6/4 | N | PX |
| 1442/1 | 63646 | Divinity | 0:6/118,1:6/136 | N | V |
| 1442/2 | 63647 | Divinity | 0:6/118,1:6/136 | N | V |
| 1442/3 | 63648 | Divinity | 0:6/118,1:6/136 | N | V |
| 1442/4 | 63649 | Divinity | 0:6/118,1:6/136 | N | V |
| 1442/5 | 63650 | Divinity | 0:6/118,1:6/136 | N | V |
| 1501/1 | 20468 | Improved Righteous Fury | 1:6/107 | N | F |
| 1501/2 | 20469 | Improved Righteous Fury | 1:6/107 | N | F |
| 1501/3 | 20470 | Improved Righteous Fury | 1:6/107 | N | F |
| 1521/1 | 20487 | Improved Hammer of Justice | 0:6/107 | N | F |
| 1521/2 | 20488 | Improved Hammer of Justice | 0:6/107 | N | F |
| 1629/1 | 20096 | Anticipation | 0:6/49 | N | V |
| 1629/2 | 20097 | Anticipation | 0:6/49 | N | V |
| 1629/3 | 20098 | Anticipation | 0:6/49 | N | V |
| 1629/4 | 20099 | Anticipation | 0:6/49 | N | V |
| 1629/5 | 20100 | Anticipation | 0:6/49 | N | V |
| 1748/1 | 31844 | Stoicism | 0:6/232,1:6/107 | N | F |
| 1748/2 | 31845 | Stoicism | 0:6/232,1:6/107 | N | F |
| 1748/3 | 53519 | Stoicism | 0:6/232,1:6/107 | N | F |
| 1750/1 | 31848 | Sacred Duty | 0:6/107,2:6/137 | N | F |
| 1750/2 | 31849 | Sacred Duty | 0:6/107,2:6/137 | N | F |
| 1751/1 | 31850 | Ardent Defender | 0:6/69,1:6/4 | N | X |
| 1751/2 | 31851 | Ardent Defender | 0:6/69,1:6/4 | N | X |
| 1751/3 | 31852 | Ardent Defender | 0:6/69,1:6/4 | N | X |
| 1753/1 | 31858 | Combat Expertise | 0:6/240,1:6/137,2:6/290 | N | V |
| 1753/2 | 31859 | Combat Expertise | 0:6/240,1:6/137,2:6/290 | N | V |
| 1753/3 | 31860 | Combat Expertise | 0:6/240,1:6/137,2:6/290 | N | V |
| 1754/1 | 31935 | Avenger's Shield | 0:2/0,1:6/33 | N | M |
| 2185/1 | 20262 | Divine Strength | 0:6/137 | N | V |
| 2185/2 | 20263 | Divine Strength | 0:6/137 | N | V |
| 2185/3 | 20264 | Divine Strength | 0:6/137 | N | V |
| 2185/4 | 20265 | Divine Strength | 0:6/137 | N | V |
| 2185/5 | 20266 | Divine Strength | 0:6/137 | N | V |
| 2194/1 | 53583 | Guarded by the Light | 0:6/107,1:6/87,2:6/42 | N | FP |
| 2194/2 | 53585 | Guarded by the Light | 0:6/107,1:6/87,2:6/42 | N | FP |
| 2195/1 | 53590 | Touched by the Light | 0:6/174,1:6/50,2:6/175 | N | V |
| 2195/2 | 53591 | Touched by the Light | 0:6/174,1:6/50,2:6/175 | N | V |
| 2195/3 | 53592 | Touched by the Light | 0:6/174,1:6/50,2:6/175 | N | V |
| 2196/1 | 53595 | Hammer of the Righteous | 0:2/0 | N | M |
| 2200/1 | 53695 | Judgements of the Just | 0:6/107,1:6/107,2:6/107 | N | FP |
| 2200/2 | 53696 | Judgements of the Just | 0:6/107,1:6/107,2:6/107 | N | FP |
| 2204/1 | 53709 | Shield of the Templar | 1:6/87,2:6/42 | N | P |
| 2204/2 | 53710 | Shield of the Templar | 1:6/87,2:6/42 | N | P |
| 2204/3 | 53711 | Shield of the Templar | 1:6/87,2:6/42 | N | P |
| 2280/1 | 64205 | Divine Sacrifice | 0:35/81 | N | P |
| 2281/1 | 53527 | Divine Guardian | 0:6/231,1:6/108,2:6/108 | N | FP |
| 2281/2 | 53530 | Divine Guardian | 0:6/231,1:6/108,2:6/108 | N | FP |
| 2282/1 | 31785 | Spiritual Attunement | 0:6/4 | N | PX |
| 2282/2 | 33776 | Spiritual Attunement | 0:6/4 | N | PX |

### Death Knight: Blood (source tab 398)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1936/1 | 50365 | Improved Blood Presence | 0:6/4,1:6/107 | N | FPX |
| 1936/2 | 50371 | Improved Blood Presence | 0:6/4,1:6/107 | N | FPX |
| 1938/1 | 48978 | Bladed Armor | 0:6/285,1:3/0 | N | X |
| 1938/2 | 49390 | Bladed Armor | 0:6/285,1:3/0 | N | X |
| 1938/3 | 49391 | Bladed Armor | 0:6/285,1:3/0 | N | X |
| 1938/4 | 49392 | Bladed Armor | 0:6/285,1:3/0 | N | X |
| 1938/5 | 49393 | Bladed Armor | 0:6/285,1:3/0 | N | X |
| 1939/1 | 48979 | Butchery | 0:6/4,1:6/85 | N | PX |
| 1939/2 | 49483 | Butchery | 0:6/4,1:6/85 | N | PX |
| 1941/1 | 48982 | Rune Tap | 0:136/0 | N | V |
| 1942/1 | 48985 | Improved Rune Tap | 0:6/108,1:6/107 | N | F |
| 1942/2 | 49488 | Improved Rune Tap | 0:6/108,1:6/107 | N | F |
| 1942/3 | 49489 | Improved Rune Tap | 0:6/108,1:6/107 | N | F |
| 1943/1 | 48987 | Dark Conviction | 0:6/52,1:6/57 | N | M |
| 1943/2 | 49477 | Dark Conviction | 0:6/52,1:6/57 | N | M |
| 1943/3 | 49478 | Dark Conviction | 0:6/52,1:6/57 | N | M |
| 1943/4 | 49479 | Dark Conviction | 0:6/52,1:6/57 | N | M |
| 1943/5 | 49480 | Dark Conviction | 0:6/52,1:6/57 | N | M |
| 1944/1 | 48988 | Bloody Vengeance | 0:6/42 | N | P |
| 1944/2 | 49503 | Bloody Vengeance | 0:6/42 | N | P |
| 1944/3 | 49504 | Bloody Vengeance | 0:6/42 | N | P |
| 1945/1 | 48997 | Subversion | 0:6/107,1:6/107 | N | F |
| 1945/2 | 49490 | Subversion | 0:6/107,1:6/107 | N | F |
| 1945/3 | 49491 | Subversion | 0:6/107,1:6/107 | N | F |
| 1948/1 | 49004 | Scent of Blood | 0:6/42 | N | P |
| 1948/2 | 49508 | Scent of Blood | 0:6/42,1:6/42 | N | P |
| 1948/3 | 49509 | Scent of Blood | 0:6/42,1:6/42,2:6/42 | N | P |
| 1949/1 | 49005 | Mark of Blood | 0:6/4 | N | PX |
| 1950/1 | 49006 | Veteran of the Third War | 0:6/137,1:6/137,2:6/240 | N | V |
| 1950/2 | 49526 | Veteran of the Third War | 0:6/137,1:6/137,2:6/240 | N | V |
| 1950/3 | 50029 | Veteran of the Third War | 0:6/137,1:6/137,2:6/240 | N | V |
| 1953/1 | 49015 | Vendetta | 0:6/4 | N | PX |
| 1953/2 | 50154 | Vendetta | 0:6/4 | N | PX |
| 1953/3 | 55136 | Vendetta | 0:6/4 | N | PX |
| 1954/1 | 49016 | Hysteria | 0:6/79,1:6/226 | N | M |
| 1955/1 | 49018 | Sudden Doom | 0:6/4 | N | PX |
| 1955/2 | 49529 | Sudden Doom | 0:6/4 | N | PX |
| 1955/3 | 49530 | Sudden Doom | 0:6/4 | N | PX |
| 1957/1 | 55050 | Heart Strike | 0:121/0,1:31/0 | N | M |
| 1958/1 | 49023 | Might of Mograine | 0:6/108 | N | F |
| 1958/2 | 49533 | Might of Mograine | 0:6/108 | N | F |
| 1958/3 | 49534 | Might of Mograine | 0:6/108 | N | F |
| 1959/1 | 49189 | Will of the Necropolis | 0:3/0,1:36/0 | N | PXA |
| 1959/2 | 50149 | Will of the Necropolis | 0:3/0,1:36/0 | N | PXA |
| 1959/3 | 50150 | Will of the Necropolis | 0:3/0,1:36/0 | N | PXA |
| 1960/1 | 49027 | Bloodworms | 0:6/231 | N | P |
| 1960/2 | 49542 | Bloodworms | 0:6/231 | N | P |
| 1960/3 | 49543 | Bloodworms | 0:6/231 | N | P |
| 1961/1 | 49028 | Dancing Rune Weapon | 0:28/0,1:6/4,2:6/4 | N | PXM |
| 2015/1 | 48977 | Bloody Strikes | 0:6/108,1:6/108,2:6/108 | N | F |
| 2015/2 | 49394 | Bloody Strikes | 0:6/108,1:6/108,2:6/108 | N | F |
| 2015/3 | 49395 | Bloody Strikes | 0:6/108,1:6/108,2:6/108 | N | F |
| 2017/1 | 49182 | Blade Barrier | 0:6/42,1:3/0 | N | PX |
| 2017/2 | 49500 | Blade Barrier | 0:6/42,1:3/0 | N | PX |
| 2017/3 | 49501 | Blade Barrier | 0:6/42,1:3/0 | N | PX |
| 2017/4 | 55225 | Blade Barrier | 0:6/42,1:3/0 | N | PX |
| 2017/5 | 55226 | Blade Barrier | 0:6/42,1:3/0 | N | PX |
| 2018/1 | 49145 | Spell Deflection | 0:6/69 | N | P |
| 2018/2 | 49495 | Spell Deflection | 0:6/69 | N | V |
| 2018/3 | 49497 | Spell Deflection | 0:6/69 | N | V |
| 2019/1 | 55233 | Vampiric Blood | 0:6/118,1:6/34 | N | V |
| 2034/1 | 61154 | Blood Gorged | 0:36/0,2:36/0 | N | PA |
| 2034/2 | 61155 | Blood Gorged | 0:36/0,2:36/0 | N | PA |
| 2034/3 | 61156 | Blood Gorged | 0:36/0,2:36/0 | N | PA |
| 2034/4 | 61157 | Blood Gorged | 0:36/0,2:36/0 | N | PA |
| 2034/5 | 61158 | Blood Gorged | 0:36/0,2:36/0 | N | PA |
| 2086/1 | 49467 | Death Rune Mastery | 0:6/226 | N | P |
| 2086/2 | 50033 | Death Rune Mastery | 0:6/226 | N | P |
| 2086/3 | 50034 | Death Rune Mastery | 0:6/226 | N | P |
| 2105/1 | 53137 | Abomination's Might | 0:65/166,1:6/137,2:65/167 | N | V |
| 2105/2 | 53138 | Abomination's Might | 0:65/166,1:6/137,2:65/167 | N | V |
| 2217/1 | 55107 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 2217/2 | 55108 | Two-Handed Weapon Specialization | 0:6/79 | N | M |
| 2259/1 | 62905 | Improved Death Strike | 0:6/108,1:6/107 | N | F |
| 2259/2 | 62908 | Improved Death Strike | 0:6/108,1:6/107 | N | F |

### Death Knight: Frost (source tab 399)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1968/1 | 49042 | Toughness | 0:6/142,1:6/232 | N | V |
| 1968/2 | 49786 | Toughness | 0:6/142,1:6/232 | N | V |
| 1968/3 | 49787 | Toughness | 0:6/142,1:6/232 | N | V |
| 1968/4 | 49788 | Toughness | 0:6/142,1:6/232 | N | V |
| 1968/5 | 49789 | Toughness | 0:6/142,1:6/232 | N | V |
| 1971/1 | 49137 | Endless Winter | 0:6/137,1:6/107 | N | F |
| 1971/2 | 49657 | Endless Winter | 0:6/137,1:6/107 | N | FP |
| 1973/1 | 49140 | Black Ice | 0:6/79 | N | V |
| 1973/2 | 49661 | Black Ice | 0:6/79 | N | V |
| 1973/3 | 49662 | Black Ice | 0:6/79 | N | V |
| 1973/4 | 49663 | Black Ice | 0:6/79 | N | V |
| 1973/5 | 49664 | Black Ice | 0:6/79 | N | V |
| 1975/1 | 49143 | Frost Strike | 0:121/0,1:31/0 | N | M |
| 1979/1 | 51271 | Unbreakable Armor | 0:6/101,1:6/137 | N | V |
| 1980/1 | 49796 | Deathchill | 0:6/107 | N | FP |
| 1981/1 | 49149 | Chill of the Grave | 0:6/231 | N | P |
| 1981/2 | 50115 | Chill of the Grave | 0:6/231 | N | P |
| 1989/1 | 49184 | Howling Blast | 0:3/0,1:2/0 | N | X |
| 1990/1 | 49186 | Frigid Dreadplate | 0:6/184 | N | V |
| 1990/2 | 51108 | Frigid Dreadplate | 0:6/184 | N | P |
| 1990/3 | 51109 | Frigid Dreadplate | 0:6/184 | N | P |
| 1992/1 | 49188 | Rime | 0:6/107,1:6/42 | N | FP |
| 1992/2 | 56822 | Rime | 0:6/107,1:6/42 | N | FP |
| 1992/3 | 59057 | Rime | 0:6/107,1:6/42 | N | FP |
| 1993/1 | 49024 | Merciless Combat | 0:6/112 | N | V |
| 1993/2 | 49538 | Merciless Combat | 0:6/112 | N | V |
| 1997/1 | 49200 | Acclimation | 0:6/42 | N | P |
| 1997/2 | 50151 | Acclimation | 0:6/42 | N | P |
| 1997/3 | 50152 | Acclimation | 0:6/42 | N | P |
| 1998/1 | 49202 | Tundra Stalker | 0:6/112,1:6/240 | N | V |
| 1998/2 | 50127 | Tundra Stalker | 0:6/112,1:6/240 | N | V |
| 1998/3 | 50128 | Tundra Stalker | 0:6/112,1:6/240 | N | V |
| 1998/4 | 50129 | Tundra Stalker | 0:6/112,1:6/240 | N | V |
| 1998/5 | 50130 | Tundra Stalker | 0:6/112,1:6/240 | N | V |
| 1999/1 | 49203 | Hungering Cold | 0:3/0 | N | X |
| 2020/1 | 49455 | Runic Power Mastery | 0:6/35 | N | V |
| 2020/2 | 50147 | Runic Power Mastery | 0:6/35 | N | V |
| 2022/1 | 49226 | Nerves of Cold Steel | 0:6/54,1:6/122 | N | M |
| 2022/2 | 50137 | Nerves of Cold Steel | 0:6/54,1:6/122 | N | M |
| 2022/3 | 50138 | Nerves of Cold Steel | 0:6/54,1:6/122 | N | M |
| 2029/1 | 50384 | Improved Frost Presence | 0:6/4,1:6/107 | N | FX |
| 2029/2 | 50385 | Improved Frost Presence | 0:6/4,1:6/107 | N | FX |
| 2030/1 | 49471 | Glacier Rot | 0:6/4 | N | X |
| 2030/2 | 49790 | Glacier Rot | 0:6/4 | N | X |
| 2030/3 | 49791 | Glacier Rot | 0:6/4 | N | X |
| 2031/1 | 49175 | Improved Icy Touch | 0:6/4,1:6/107,2:6/107 | N | FX |
| 2031/2 | 50031 | Improved Icy Touch | 0:6/4,1:6/107,2:6/107 | N | FX |
| 2031/3 | 51456 | Improved Icy Touch | 0:6/4,1:6/107,2:6/107 | N | FX |
| 2035/1 | 55061 | Icy Reach | 0:6/107 | N | F |
| 2035/2 | 55062 | Icy Reach | 0:6/107 | N | F |
| 2040/1 | 50187 | Guile of Gorefiend | 0:6/108,1:6/107 | N | F |
| 2040/2 | 50190 | Guile of Gorefiend | 0:6/108,1:6/107 | N | F |
| 2040/3 | 50191 | Guile of Gorefiend | 0:6/108,1:6/107 | N | F |
| 2042/1 | 50880 | Icy Talons | 0:6/231,1:3/0 | N | PX |
| 2042/2 | 50884 | Icy Talons | 0:6/231,1:3/0 | N | PX |
| 2042/3 | 50885 | Icy Talons | 0:6/231,1:3/0 | N | PX |
| 2042/4 | 50886 | Icy Talons | 0:6/231,1:3/0 | N | PX |
| 2042/5 | 50887 | Icy Talons | 0:6/231,1:3/0 | N | PX |
| 2044/1 | 51123 | Killing Machine | 0:6/42 | N | P |
| 2044/2 | 51127 | Killing Machine | 0:6/42 | N | P |
| 2044/3 | 51128 | Killing Machine | 0:6/42 | N | P |
| 2044/4 | 51129 | Killing Machine | 0:6/42 | N | P |
| 2044/5 | 51130 | Killing Machine | 0:6/42 | N | P |
| 2048/1 | 51468 | Annihilation | 0:6/4,1:6/107 | N | FX |
| 2048/2 | 51472 | Annihilation | 0:6/4,1:6/107 | N | FX |
| 2048/3 | 51473 | Annihilation | 0:6/4,1:6/107 | N | FX |
| 2210/1 | 54639 | Blood of the North | 0:6/226,1:6/108 | N | FP |
| 2210/2 | 54638 | Blood of the North | 0:6/226,1:6/108 | N | FP |
| 2210/3 | 54637 | Blood of the North | 0:6/226,1:6/108 | N | FP |
| 2215/1 | 49039 | Lichborne | 0:6/77,1:6/77,2:6/77 | N | V |
| 2223/1 | 55610 | Improved Icy Talons | 0:65/138,1:6/192 | N | V |
| 2260/1 | 50040 | Chilblains | 0:6/109 | N | P |
| 2260/2 | 50041 | Chilblains | 0:6/109 | N | P |
| 2260/3 | 50043 | Chilblains | 0:6/109 | N | P |
| 2284/1 | 65661 | Threat of Thassarian | 0:6/4 | N | XM |
| 2284/2 | 66191 | Threat of Thassarian | 0:6/4 | N | XM |
| 2284/3 | 66192 | Threat of Thassarian | 0:6/4,1:3/0 | N | XM |

### Death Knight: Unholy (source tab 400)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 1932/1 | 48962 | Virulence | 0:6/55,1:6/107 | N | F |
| 1932/2 | 49567 | Virulence | 0:6/55,1:6/107 | N | F |
| 1932/3 | 49568 | Virulence | 0:6/55,1:6/107 | N | F |
| 1933/1 | 48963 | Morbidity | 0:6/108,1:6/107 | N | F |
| 1933/2 | 49564 | Morbidity | 0:6/108,1:6/107 | N | F |
| 1933/3 | 49565 | Morbidity | 0:6/108,1:6/107 | N | F |
| 1934/1 | 48965 | Ravenous Dead | 0:6/137,1:6/4 | N | X |
| 1934/2 | 49571 | Ravenous Dead | 0:6/137,1:3/0 | N | X |
| 1934/3 | 49572 | Ravenous Dead | 0:6/137,1:3/0 | N | X |
| 1962/1 | 49032 | Crypt Fever | 0:6/112 | N | V |
| 1962/2 | 49631 | Crypt Fever | 0:6/112 | N | V |
| 1962/3 | 49632 | Crypt Fever | 0:6/112 | N | V |
| 1963/1 | 49036 | Epidemic | 0:6/107 | N | F |
| 1963/2 | 49562 | Epidemic | 0:6/107 | N | F |
| 1984/1 | 52143 | Master of Ghouls | 0:6/107 | N | F |
| 1985/1 | 49158 | Corpse Explosion | 0:3/0,1:3/0 | N | X |
| 1996/1 | 49194 | Unholy Blight | 0:6/4 | N | PX |
| 2000/1 | 49206 | Summon Gargoyle | 0:28/0,1:6/226,2:64/0 | N | P |
| 2001/1 | 49208 | Reaping | 0:6/226 | N | P |
| 2001/2 | 56834 | Reaping | 0:6/226 | N | P |
| 2001/3 | 56835 | Reaping | 0:6/226 | N | P |
| 2003/1 | 49217 | Wandering Plague | 0:6/4 | N | PX |
| 2003/2 | 49654 | Wandering Plague | 0:6/4 | N | PX |
| 2003/3 | 49655 | Wandering Plague | 0:6/4 | N | PX |
| 2004/1 | 49219 | Blood-Caked Blade | 0:6/4 | N | PXM |
| 2004/2 | 49627 | Blood-Caked Blade | 0:6/4 | N | PXM |
| 2004/3 | 49628 | Blood-Caked Blade | 0:6/4 | N | PXM |
| 2005/1 | 49220 | Impurity | 0:3/0 | N | X |
| 2005/2 | 49633 | Impurity | 0:3/0 | N | X |
| 2005/3 | 49635 | Impurity | 0:3/0 | N | X |
| 2005/4 | 49636 | Impurity | 0:3/0 | N | X |
| 2005/5 | 49638 | Impurity | 0:3/0 | N | X |
| 2007/1 | 49222 | Bone Shield | 0:6/87,1:6/79 | N | P |
| 2008/1 | 49013 | Outbreak | 0:6/108,1:6/108 | N | F |
| 2008/2 | 55236 | Outbreak | 0:6/108,1:6/108 | N | F |
| 2008/3 | 55237 | Outbreak | 0:6/108,1:6/108 | N | F |
| 2009/1 | 49224 | Magic Suppression | 0:6/107,1:6/87 | N | FM |
| 2009/2 | 49610 | Magic Suppression | 0:6/107,1:6/87 | N | F |
| 2009/3 | 49611 | Magic Suppression | 0:6/107,1:6/87 | N | FM |
| 2011/1 | 49223 | Dirge | 0:6/231 | N | P |
| 2011/2 | 49599 | Dirge | 0:6/231 | N | P |
| 2013/1 | 50391 | Improved Unholy Presence | 0:6/4 | N | X |
| 2013/2 | 50392 | Improved Unholy Presence | 0:6/4 | N | X |
| 2025/1 | 49588 | Unholy Command | 0:6/107 | N | F |
| 2025/2 | 49589 | Unholy Command | 0:6/107 | N | F |
| 2036/1 | 50117 | Rage of Rivendare | 0:6/112,1:6/240 | N | V |
| 2036/2 | 50118 | Rage of Rivendare | 0:6/112,1:6/240 | N | V |
| 2036/3 | 50119 | Rage of Rivendare | 0:6/112,1:6/240 | N | V |
| 2036/4 | 50120 | Rage of Rivendare | 0:6/112,1:6/240 | N | V |
| 2036/5 | 50121 | Rage of Rivendare | 0:6/112,1:6/240 | N | V |
| 2039/1 | 49146 | On a Pale Horse | 0:36/0,1:36/0 | N | PA |
| 2039/2 | 51267 | On a Pale Horse | 0:36/0,1:36/0 | N | PA |
| 2043/1 | 51099 | Ebon Plaguebringer | 0:6/112,1:6/52,2:6/57 | N | V |
| 2043/2 | 51160 | Ebon Plaguebringer | 0:6/112,1:6/52,2:6/57 | N | V |
| 2043/3 | 51161 | Ebon Plaguebringer | 0:6/112,1:6/52,2:6/57 | N | V |
| 2047/1 | 51459 | Necrosis | 0:6/4 | N | PX |
| 2047/2 | 51462 | Necrosis | 0:6/4 | N | PX |
| 2047/3 | 51463 | Necrosis | 0:6/4 | N | PX |
| 2047/4 | 51464 | Necrosis | 0:6/4 | N | PX |
| 2047/5 | 51465 | Necrosis | 0:6/4 | N | PX |
| 2082/1 | 51745 | Vicious Strikes | 0:6/108,1:6/107 | N | F |
| 2082/2 | 51746 | Vicious Strikes | 0:6/108,1:6/107 | N | F |
| 2085/1 | 63560 | Ghoul Frenzy | 0:6/20,1:6/138 | N | V |
| 2216/1 | 55090 | Scourge Strike | 0:121/0,1:31/0,2:3/0 | N | XM |
| 2218/1 | 55129 | Anticipation | 0:6/49 | N | V |
| 2218/2 | 55130 | Anticipation | 0:6/49 | N | V |
| 2218/3 | 55131 | Anticipation | 0:6/49 | N | V |
| 2218/4 | 55132 | Anticipation | 0:6/49 | N | V |
| 2218/5 | 55133 | Anticipation | 0:6/49 | N | V |
| 2221/1 | 51052 | Anti-Magic Zone | 0:28/0 | N | M |
| 2225/1 | 55620 | Night of the Dead | 0:6/107,1:6/107 | N | F |
| 2225/2 | 55623 | Night of the Dead | 0:6/107,1:6/107 | N | F |
| 2226/1 | 55666 | Desecration | 0:6/42 | N | P |
| 2226/2 | 55667 | Desecration | 0:6/42 | N | P |
| 2285/1 | 66799 | Desolation | 0:6/42 | N | P |
| 2285/2 | 66814 | Desolation | 0:6/42 | N | P |
| 2285/3 | 66815 | Desolation | 0:6/42 | N | P |
| 2285/4 | 66816 | Desolation | 0:6/42 | N | P |
| 2285/5 | 66817 | Desolation | 0:6/42 | N | P |

### Pet: Tenacity (source tab 409)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 2110/1 | 61680 | Culling the Herd | 0:6/231 | N | PM |
| 2110/2 | 61681 | Culling the Herd | 0:6/231 | N | PM |
| 2110/3 | 52858 | Culling the Herd | 0:6/231 | N | PM |
| 2114/1 | 61682 | Cobra Reflexes | 0:6/9 | N | M |
| 2114/2 | 61683 | Cobra Reflexes | 0:6/9 | N | M |
| 2116/1 | 61686 | Great Stamina | 0:6/137 | N | M |
| 2116/2 | 61687 | Great Stamina | 0:6/137 | N | M |
| 2116/3 | 61688 | Great Stamina | 0:6/137 | N | M |
| 2117/1 | 61689 | Natural Armor | 0:6/101 | N | M |
| 2117/2 | 61690 | Natural Armor | 0:6/101 | N | M |
| 2122/1 | 53175 | Pet Barding | 0:6/101,1:6/49 | N | M |
| 2122/2 | 53176 | Pet Barding | 0:6/101,1:6/49 | N | M |
| 2123/1 | 53178 | Guard Dog | 0:6/4 | N | XM |
| 2123/2 | 53179 | Guard Dog | 0:6/4 | N | XM |
| 2126/1 | 53182 | Spiked Collar | 0:6/79 | N | M |
| 2126/2 | 53183 | Spiked Collar | 0:6/79 | N | M |
| 2126/3 | 53184 | Spiked Collar | 0:6/79 | N | M |
| 2160/1 | 19596 | Boar's Speed | 0:6/31 | N | M |
| 2161/1 | 53427 | Great Resistance | 0:6/87 | N | M |
| 2161/2 | 53429 | Great Resistance | 0:6/87 | N | M |
| 2161/3 | 53430 | Great Resistance | 0:6/87 | N | M |
| 2162/1 | 53409 | Lionhearted | 0:6/232,1:6/232 | N | M |
| 2162/2 | 53411 | Lionhearted | 0:6/232,1:6/232 | N | M |
| 2163/1 | 53450 | Grace of the Mantis | 0:6/187 | N | M |
| 2163/2 | 53451 | Grace of the Mantis | 0:6/187 | N | M |
| 2169/1 | 53476 | Intervene | 0:96/0,1:6/111 | N | PM |
| 2170/1 | 53477 | Taunt | 0:114/0,1:6/11 | N | M |
| 2171/1 | 53478 | Last Stand | 0:3/0 | N | XM |
| 2172/1 | 53480 | Roar of Sacrifice | 0:6/197 | N | PM |
| 2173/1 | 53481 | Blood of the Rhino | 0:6/137,1:6/118 | N | M |
| 2173/2 | 53482 | Blood of the Rhino | 0:6/137,1:6/118 | N | M |
| 2237/1 | 61685 | Charge | 0:96/0,1:6/166,2:64/0 | N | PM |
| 2255/1 | 62758 | Wild Hunt | 0:3/0,1:3/0 | N | XM |
| 2255/2 | 62762 | Wild Hunt | 0:3/0,1:3/0 | N | XM |
| 2258/1 | 62764 | Silverback | 0:6/4 | N | XM |
| 2258/2 | 62765 | Silverback | 0:6/4 | N | XM |
| 2277/1 | 63900 | Thunderstomp | 0:2/0 | N | M |

### Pet: Ferocity (source tab 410)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 2106/1 | 61680 | Culling the Herd | 0:6/231 | N | PM |
| 2106/2 | 61681 | Culling the Herd | 0:6/231 | N | PM |
| 2106/3 | 52858 | Culling the Herd | 0:6/231 | N | PM |
| 2107/1 | 61682 | Cobra Reflexes | 0:6/9 | N | M |
| 2107/2 | 61683 | Cobra Reflexes | 0:6/9 | N | M |
| 2109/1 | 61684 | Dash | 0:6/31 | N | M |
| 2111/1 | 61685 | Charge | 0:96/0,1:6/166,2:64/0 | N | PM |
| 2112/1 | 61686 | Great Stamina | 0:6/137 | N | M |
| 2112/2 | 61687 | Great Stamina | 0:6/137 | N | M |
| 2112/3 | 61688 | Great Stamina | 0:6/137 | N | M |
| 2113/1 | 61689 | Natural Armor | 0:6/101 | N | M |
| 2113/2 | 61690 | Natural Armor | 0:6/101 | N | M |
| 2124/1 | 53180 | Improved Cower | 0:6/4 | N | XM |
| 2124/2 | 53181 | Improved Cower | 0:6/4 | N | XM |
| 2125/1 | 53182 | Spiked Collar | 0:6/79 | N | M |
| 2125/2 | 53183 | Spiked Collar | 0:6/79 | N | M |
| 2125/3 | 53184 | Spiked Collar | 0:6/79 | N | M |
| 2128/1 | 53186 | Bloodthirsty | 0:6/42 | N | PM |
| 2128/2 | 53187 | Bloodthirsty | 0:6/42 | N | PM |
| 2129/1 | 53203 | Spider's Bite | 0:6/52 | N | M |
| 2129/2 | 53204 | Spider's Bite | 0:6/52 | N | M |
| 2129/3 | 53205 | Spider's Bite | 0:6/52 | N | M |
| 2151/1 | 19596 | Boar's Speed | 0:6/31 | N | M |
| 2152/1 | 53409 | Lionhearted | 0:6/232,1:6/232 | N | M |
| 2152/2 | 53411 | Lionhearted | 0:6/232,1:6/232 | N | M |
| 2153/1 | 53426 | Lick Your Wounds | 0:6/20 | N | M |
| 2154/1 | 53427 | Great Resistance | 0:6/87 | N | M |
| 2154/2 | 53429 | Great Resistance | 0:6/87 | N | M |
| 2154/3 | 53430 | Great Resistance | 0:6/87 | N | M |
| 2155/1 | 53401 | Rabid | 0:6/42 | N | PM |
| 2156/1 | 55709 | Heart of the Phoenix | 0:77/0 | N | XM |
| 2157/1 | 53434 | Call of the Wild | 0:6/166,1:6/167 | N | M |
| 2203/1 | 23145 | Dive | 0:6/31 | N | M |
| 2219/1 | 52825 | Swoop | 0:96/0,1:6/166,2:64/0 | N | PM |
| 2253/1 | 62758 | Wild Hunt | 0:3/0,1:3/0 | N | XM |
| 2253/2 | 62762 | Wild Hunt | 0:3/0,1:3/0 | N | XM |
| 2254/1 | 62759 | Shark Attack | 0:6/79 | N | M |
| 2254/2 | 62760 | Shark Attack | 0:6/79 | N | M |

### Pet: Cunning (source tab 411)

| Talent/rank | Spell | Source name | Slots effect/aura | Class | Review |
| --- | --- | --- | --- | --- | --- |
| 2118/1 | 61682 | Cobra Reflexes | 0:6/9 | N | M |
| 2118/2 | 61683 | Cobra Reflexes | 0:6/9 | N | M |
| 2119/1 | 61684 | Dash | 0:6/31 | N | M |
| 2120/1 | 61686 | Great Stamina | 0:6/137 | N | M |
| 2120/2 | 61687 | Great Stamina | 0:6/137 | N | M |
| 2120/3 | 61688 | Great Stamina | 0:6/137 | N | M |
| 2121/1 | 61689 | Natural Armor | 0:6/101 | N | M |
| 2121/2 | 61690 | Natural Armor | 0:6/101 | N | M |
| 2127/1 | 53182 | Spiked Collar | 0:6/79 | N | M |
| 2127/2 | 53183 | Spiked Collar | 0:6/79 | N | M |
| 2127/3 | 53184 | Spiked Collar | 0:6/79 | N | M |
| 2165/1 | 19596 | Boar's Speed | 0:6/31 | N | M |
| 2166/1 | 61680 | Culling the Herd | 0:6/231 | N | PM |
| 2166/2 | 61681 | Culling the Herd | 0:6/231 | N | PM |
| 2166/3 | 52858 | Culling the Herd | 0:6/231 | N | PM |
| 2167/1 | 53409 | Lionhearted | 0:6/232,1:6/232 | N | M |
| 2167/2 | 53411 | Lionhearted | 0:6/232,1:6/232 | N | M |
| 2168/1 | 53427 | Great Resistance | 0:6/87 | N | M |
| 2168/2 | 53429 | Great Resistance | 0:6/87 | N | M |
| 2168/3 | 53430 | Great Resistance | 0:6/87 | N | M |
| 2175/1 | 53490 | Bullheaded | 0:6/77,1:64/0 | N | PM |
| 2177/1 | 52234 | Cornered | 0:6/79,1:6/197 | N | M |
| 2177/2 | 53497 | Cornered | 0:6/79,1:6/197 | N | M |
| 2181/1 | 53508 | Wolverine Bite | 0:2/0 | N | M |
| 2182/1 | 53514 | Owl's Focus | 0:6/42 | N | PM |
| 2182/2 | 53516 | Owl's Focus | 0:6/42 | N | PM |
| 2183/1 | 53511 | Feeding Frenzy | 0:6/226 | N | M |
| 2183/2 | 53512 | Feeding Frenzy | 0:6/226 | N | M |
| 2184/1 | 53517 | Roar of Recovery | 0:6/21 | N | M |
| 2201/1 | 23145 | Dive | 0:6/31 | N | M |
| 2206/1 | 54044 | Carrion Feeder | 0:3/0 | N | PXM |
| 2207/1 | 53483 | Mobility | 0:119/107 | N | FM |
| 2207/2 | 53485 | Mobility | 0:119/107 | N | FM |
| 2208/1 | 53554 | Mobility | 0:119/107 | N | FM |
| 2208/2 | 53555 | Mobility | 0:119/107 | N | FM |
| 2256/1 | 62758 | Wild Hunt | 0:3/0,1:3/0 | N | XM |
| 2256/2 | 62762 | Wild Hunt | 0:3/0,1:3/0 | N | XM |
| 2257/1 | 53450 | Grace of the Mantis | 0:6/187 | N | M |
| 2257/2 | 53451 | Grace of the Mantis | 0:6/187 | N | M |
| 2278/1 | 53480 | Roar of Sacrifice | 0:6/197 | N | PM |
