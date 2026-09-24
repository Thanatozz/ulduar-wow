# ULDuar Phase A.5 source review

Date: 2026-09-16. Project: `C:\WoWProjecto\ulduar-wow`.
Module: `modules/mod-ulduar-abilities`.

## 1. Executive summary

PHASE_A5_STATUS: COMPLETE for the requested static review and design research, not execution acceptance.
Evidence: SOURCE_ONLY; tests: TEST_AUTHORED_NOT_RUN; execution acceptance: RUNTIME_REQUIRED.

No definite Phase A runtime-code defect requiring a source correction was established. No runtime source, test,
allowlist, SQL or client file was changed. The review identifies incomplete test coverage, a misleading forms statement
in the previous report and carrier-contract limits which must remain explicit.

| Profile | Source conclusion | Reason |
| --- | --- | --- |
| Damage+Melee | SOURCE_PARTIAL | Mongoose Bite merits review; native family/auto-attack coupling remains |
| Damage+Ranged | SOURCE_PARTIAL | Holy Bolt candidates exist; no current reviewed Ulduar binding |
| Healing+Melee | SOURCE_REJECTED | Current cast-time/contact adapters cannot express the complete profile |
| Healing+Ranged | SOURCE_COMPATIBLE | Holy Light 635, first rank only, with native restrictions retained |

Recommendation: HYBRID, with a small neutral custom pool as the long-term default for exact Forge profiles.
Existing carriers are exceptions only where their native restrictions and family behavior are intentionally acceptable.
This does not enable any new carrier. All three previously unsupported production contracts remain unsupported.

## 2. Scope and explicit NO-BUILD statement

This report follows the replacement instruction titled "Static Carrier Research + Phase A Source Validation".
No build, configuration, compiler, project executable, test, server, SQL or client patch was run after that instruction.
Only source/data reads, process shutdown, static inspection and this Markdown deliverable belong to this phase.

Historical boundary: the earlier, superseded A.5 request explicitly authorized building. Before the replacement,
CMake configuration and the modules build ran, and the unit_tests build was started. Its retained log ends with
MSVC D8040 (child-process creation/communication error); this is not a test outcome. No test executable was launched.
On receiving the replacement, no active task compiler/build root remained; three orphan reusable MSBuild workers
were stopped. No build was resumed. The build directory/cache/logs were preserved, not reset or deleted.
Thus "no compilation/build" below applies to this source-only phase, not retroactively to the entire conversation.

Inspected documents: the Phase A implementation report; Ability Forge, Vertical Slice V1, Roadmap V2,
Architecture Amendments, Spell Taxonomy, Ability Metadata, Generic Stats and Resolution Pipeline.
The later Forge identity amendment takes precedence over the taxonomy's older rank-chain-centered wording.

Inspected source: all 11 requested Phase A C++/test files, module test registration, existing AbilityTypes,
AbilityDefinitions, AbilityPropagationResolver, AbilityTargetResolver and SecondarySpellExecutor; modified
Spell.cpp/.h, SpellEffects.cpp, Unit.cpp/.h; SpellInfo, SpellMgr, SpellInfoCorrections, SpellHandler, DBC structures,
SharedDefines and existing AC test fixtures. Repository agent/C++/review instructions were also read.

No architecture document was rewritten. No Phase B/C/D, ownership, persistence, UI, talent, keystone or external
gameplay implementation was started. Reading repository SQL text was data/source inspection, not SQL execution.

## 3. Phase A static review

Finding severity is distinct from evidence level. NONE means no defect found by inspection, not proof of correctness.

| Area | Severity | Source finding |
| --- | --- | --- |
| Identity | NONE | Explicit strong IDs; instance identity never substitutes for native SpellID |
| Composition/revision | NONE | Copy-resolve-commit editing; old revision and overflow rejected |
| Generation | NONE | Slot comparison and tombstones prevent same-session remove/re-add reuse |
| Owner | NONE | Registry owner check and manager Player GUID check precede publication |
| Carrier ambiguity | NONE | Duplicate rejected; lookup exposes None/Unique/Invalid/Ambiguous |
| Independent native ownership | NONE | Unknown/independent sources rejected; no automatic Forge enrollment |
| EP/custom rank | NONE | Registration and new-root lookup reject existing legacy customization |
| Snapshot lifetime | NONE | Registry creates shared const resolved object; cast copies runtime values |
| Pointer lifetime | NONE | New registry retains GUIDs, not Player/Unit/AbilityInstance pointers |
| Shared SpellInfo | NONE | No new shared mutation; native review reads const SpellInfo |
| Invalid dispatch | NONE | CheckCast rejection retained; no Load=false fallback on rejected root |
| Unbound dispatch | NONE | Source branch still calls the original BuildRuntimeContext |
| Cleanup | NONE | Load/unload/delete erase projection under existing manager mutex |
| Thread safety | MEDIUM | Caller must remain on owning player/map thread; no concurrency test exists |
| Unsupported contracts | NONE | Unknown/rejected contracts and absent adapters fail closed |
| Impact isolation | NONE | Modifier lives on instance; resolver does not modify shared definitions |
| Impact recursion | NONE | Non-root Impact returns before propagation; one root reservation |
| Dispatch test coverage | MEDIUM | No test executes the real manager-to-SpellScript root dispatch seam |
| Negative target tests | MEDIUM | Wrong-relation rejection alone does not prove successful selection |
| Previous report forms wording | LOW | Zero stance masks do not remove NOT_SHAPESHIFTED attribute |

No BLOCKER/HIGH implementation defect was demonstrated. Release blockers remain in section 16.

Source anchors, relative to module `src/`:

- `AbilityInstance.cpp:84`: validates identity, exact profile/version/composition and at most one Impact v1 reference.
- `AbilityInstance.cpp:131`: rejected edits leave the original instance intact; successful edits advance revision.
- `AbilityCarrierRegistry.cpp:13`: expected slot generation, ownership policy, composition history and collisions.
- `AbilityCarrierRegistry.cpp:77`: removal advances the generation without deleting its tombstone.
- `AbilityCarrierRegistry.cpp:103`: unique result always receives a snapshot; ambiguous result clears it.
- `AbilityManager.cpp:404` and `:456`: native eligibility and legacy-collision checks on bind/new-root lookup.
- `AbilityManager.cpp:152`, `:271`, `:279`: load/logout/delete cleanup; existing database code is unchanged.
- `AbilitySpellScript.cpp:82` and `:186`: secondary handoff, root selection and rejected-carrier CheckCast hook.
- `AbilityRuntime.h:26`: the cast's existing InstanceId is the MAP instance, not an AbilityInstanceId.

Optional dereferences were traced through successful resolution/Unique branches. They depend on internal constructors
and private registry maps preserving these invariants; they are not arbitrary client DTOs. No current null path was
found. Mutable event counters remain on the existing map execution path; only cast/composition snapshots are const.
The manager mutex protects its maps, not arbitrary off-thread Player operations. Future callers must honor that rule.

Important limits: registry generations/revision history reset on session destruction; no persistent replay protection
is claimed. ForgeProjectionOnly is a trusted server assertion, not an ownership proof derived from HasActiveSpell.
No existing command/addon endpoint supplies it. A future ownership caller needs separate source-of-grant authority.
Mid-combat management restrictions belong at that future caller; this pure editing model does not authorize management.

No-binding equivalence has SOURCE_ONLY evidence from branch tracing. The 24 tests cannot demonstrate exact legacy
combat equivalence, loaded SQL script associations or rejection of a bound spell whose script was never attached.
Those remain RUNTIME_REQUIRED; no global casting hook or alternate engine was added to disguise the gap.

## 4. Test review — AUTHORED_NOT_RUN

24 AUTHORED / 0 EXECUTED. Every case below is TEST_AUTHORED_NOT_RUN.
The hypothetical future evidence column describes the scope the test could establish after a separately authorized
execution; it does not elevate this review's evidence level.

Legend: U = synthetic pure/service logic; P = actual propagation early-return function without a live caster;
F = actual legality function with AC Player/Creature mocks and synthetic SpellInfo. None uses a real client.

| Test | Intended invariant | Static quality | Future scope | Remaining requirement |
| --- | --- | --- | --- | --- |
| T01 | Distinct instance ID | Direct type assertions | U | Persistent ID allocation |
| T02 | Four profiles | Partial field coverage | U | School/delivery and real carriers |
| T03 | Separate instances | Direct ID comparison | U | Same-profile active lifecycle |
| T04 | Revision advances | Direct stale/edit checks | U | Authorized edit/cast ordering |
| T05 | Local Impact | Direct two-instance check | U | Actual secondary count/magnitude |
| T06 | Reject target mismatch | Direct synthetic contract | U | Client/native target checks |
| T07 | Reject activation mismatch | Direct synthetic contract | U | Native cast timing |
| T08 | Reject resource mismatch | Rage substitution only | U | Real costs and other policies |
| T09 | Empty lookup is None | Direct registry check | U | Unbound native cast |
| T10 | One binding is Unique | Identity/revision/generation | U | Manager/SpellScript path |
| T11 | Reject duplicate carrier | Original binding retained | U | Ambiguous/corrupt-state path |
| T12 | Reject stale generation | Includes remove/re-add | U | Session/reconnect boundary |
| T13 | Native stays outside Forge | Lookup only, no cast | U | Legacy/native behavior parity |
| T14 | Snapshot retains revision | Replaces registry snapshot | U | Delayed native hit/event queue |
| T15 | No recursive Impact | Real early return | P | Proc/trigger descendant scenarios |
| T16 | Unknown is not supported | Explicit support states | U | Real carrier review/data changes |
| T17 | No native hijack | Tests caller ownership enum | U | Actual grant-source authority |
| T18 | Same revision is immutable | Includes after unbind | U | Concurrent management policy |
| T19 | Reject invalid composition | Several bounds only | U | Unknown versions/kinds/zero IDs |
| T20 | One slot and owner | Direct failure diagnostics | U | Player lifecycle/cleanup |
| T21 | Adapter/range/delivery | Multiple independent errors | U | Native adapter execution |
| T22 | Exclude primary | Negative legality predicate | F | Search with eligible alternatives |
| T23 | Friendly heals only | Rejects hostile fixture | F | Friendly success, LOS and hit |
| T24 | Hostile damage only | Rejects friendly fixture | F | Hostile success and PvP rules |

Exact test names in `tests/AbilityForgePhaseATest.cpp`:

```text
T01 InstanceIdentityCannotBeUsedAsSpellOrDefinition
T02 FourProfilesHaveIndependentActivationMethodAndPurpose
T03 SameTemplateCreatesSeparateInstances
T04 ModifierEditPreservesIdentityAndAdvancesRevision
T05 ImpactIsLocalAndRemovalRecomputesBaseline
T06 RejectsIncompatibleTargetRelation
T07 RejectsIncompatibleActivation
T08 RejectsResourceSubstitution
T09 EmptyRegistryReturnsNone
T10 OneValidBindingResolvesUnique
T11 DuplicateCarrierCannotReplaceAnInstance
T12 StaleGenerationAndRemoveReaddAreProtected
T13 UnboundNativeSpellStaysOutsideForge
T14 CastAndDelayedEventKeepOriginalRevision
T15 ImpactSecondaryCannotTriggerAnotherImpact
T16 UnknownAndUnsupportedCarriersCannotBind
T17 NativeOwnershipCannotBeHijacked
T18 SameRevisionCannotHideACompositionEdit
T19 InvalidProfilesModifiersAndRevisionOverflowFailClosed
T20 AdditionalSlotAndCrossOwnerAreRejected
T21 MissingAdaptersRangeAndDeliveryAreRejected
T22 PrimaryCannotBeItsOwnSecondary
T23 HealingImpactRejectsHostileSecondary
T24 DamageImpactRejectsFriendlySecondary
```

T01-T21 use suite UlduarForgePhaseA. T22-T24 use UlduarForgeImpactTargetTest.
T02 checks count, activation, relation, Mana and baseline propagation; it does not assert every profile axis.
T05 checks one secondary and a positive radius, not exactly 10 yards/0.10 or a resulting native heal/damage.
T14 manually assembles AbilityCast/AbilityPayloadEvent; no Spell is prepared and no projectile is scheduled.
T15 exercises the real non-root branch but its assertion cannot prove all indirect proc chains are bounded.
T22-T24 use synthetic spells and mock world/factions. Earlier legality guards can also produce false; stronger
future cases need positive controls and explicit preconditions before checking the intended rejection branch.
The existing fixture avoids database-backed player creation; that does not turn it into a real-world integration run.

Missing future cases: actual Holy Light ReviewPhaseACarrier with loaded metadata; stale/disabled/invalid root dispatch;
manager logout/delete; preserved legacy rank/EP/element/cast timing; real friendly/enemy acquisition and healing;
same-revision carrier changes and generation overflow. No tests were weakened, added or executed in this review.

## 5. Carrier requirements and method

All profiles require a reviewed explicit unit relation, Mana, point geometry, normal native cost/CheckCast and no
unreviewed extra gameplay effects. Melee requires dynamic contact/reach, not merely a nominal five-yard tooltip.
Damage+Melee is Physical/Instant/Direct; Damage+Ranged is Holy/CastTime/Projectile;
Healing+Melee is Holy/Instant/Direct; Healing+Ranged is Holy/CastTime/Direct.

Local WDBC data were inspected read-only against `src/server/shared/DataStores/DBCStructure.h:1641` and related structs.
Spell.dbc contains 49,839 rows, 234 fields, 936-byte records. Numeric effects/targets were matched to SharedDefines.
SpellRange and SpellCastTimes resolve indexed references; SpellVisual was inspected for missile evidence.
Rank/script SQL files were read as repository text, never connected to a database or executed.

Both extracted locations have matching Spell, SpellRange and SpellCastTimes hashes:

```text
C:\WoWProjecto\a\Data\dbc
C:\WoWProjecto\ulduar-build\bin\RelWithDebInfo\Data\dbc
Spell.dbc          d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3
SpellRange.dbc     82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f
SpellCastTimes.dbc 919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec
```

A mechanical first-stage search found 354 Physical/Mana/instant/contact damage candidates and 19 Holy/Mana/cast-time
projectile candidates, before full restriction/script review. It found zero direct Holy/Mana/instant heals with
explicit ally target A=21 and positive friendly max range <=5. That last predicate is not proof that every possible
target topology or scripted heal was exhausted. Discovery is never automatic allowlisting.

Actual client MPQ precedence, installed world DB overrides/conditions and runtime-loaded script mappings are UNKNOWN.
Read-only public AC documentation is supplemental; local source/data are authoritative for this checkout.
The [spell_proc documentation](https://www.azerothcore.org/wiki/spell_proc) confirms distinct school and family filters;
the [rank documentation](https://www.azerothcore.org/wiki/spell_ranks) separates server chains from displayed rank text.

## 6. Damage+Melee research

SOURCE_PARTIAL overall; no allowlist change. Mongoose Bite is a substantially closer native candidate than Raptor
Strike, but preserving its Hunter-family behavior and client auto-attack behavior is a deliberate gameplay decision.

| Candidate | Native behavior | Verdict |
| --- | --- | --- |
| 1495 Mongoose Bite R1 | Physical school damage, melee defense, Mana 3%, contact | SOURCE_PARTIAL |
| 2973 Raptor Strike R1 | Next-swing weapon damage, Mana 4% | SOURCE_REJECTED |
| 35395 Crusader Strike | Weapon effects plus aura, Mana 5%, Paladin family | SOURCE_REJECTED |
| 17364 Stormstrike | Aura and two triggered children, Mana 8% | SOURCE_REJECTED |
| 1752 Sinister Strike R1 | Energy 45 and combo generation | SOURCE_REJECTED |
| 78 Heroic Strike R1 | Rage 150 internal units, next-swing | SOURCE_REJECTED |
| 2816 Bark of Doom | Generic Physical damage; zero native cost and no visual | SOURCE_PARTIAL |
| 96 Dismember | Weapon-percent damage plus aura | SOURCE_REJECTED |

Mongoose Bite: no required/excluded stance masks or aura-state requirement in the inspected row; no equipment-class
requirement, no next-swing bits and no combo effect. This source must not be confused with earlier expansion versions
requiring a dodge. Attributes include NOT_SHAPESHIFTED and INITIATE_COMBAT; DmgClass=MELEE can engage native weapon proc
behavior despite no equipped-item requirement. Family=Hunter, mask0=2. Repository rank chain root is 1495;
later ranks 14269/14270/14271/36916/53339 are separate unreviewed contracts. No current Ulduar definition selects 1495.
No direct binding was found in inspected base spell_script_names, but family masks/native talents still apply.

Crusader Strike is not a clean one-effect transport shell: normalized damage, weapon-percent damage and aura E2 remain.
Stormstrike E1/E2 trigger 32175/32176 and it has a native correction in SpellInfoCorrections.cpp:938.
Silently stripping their extra effects/family behavior would exceed Phase A. Energy/Rage conversion is rejected.
Bark of Doom avoids a class family but still needs native casting, coefficients/procs, presentation and source-grant
review; free cost is not a usable Cost trade-off and visual zero is not acceptable feedback by assumption.

Exact raw candidate cards appear below; Target A/B arrays and effect slot order are preserved.

Raw fields: range arrays are hostile-min, friendly-min, hostile-max, friendly-max; speed is yards/second.
Equipment is class/subclass mask/inventory mask. Attributes are Attr0 through Attr7, without decoding away flags.
Effects: 2=school damage, 3=dummy, 6=aura, 10=heal, 31=weapon percent, 58=weapon damage,
64=trigger spell, 80=combo points, 121=normalized weapon damage. Targets: 6=enemy, 21=ally, 25=any.
Cost is raw plus percentage; all card values are native data, not semantic overrides.

**1495 ? Mongoose Bite**

```text
Root/rank: 1495/1; DBC rank text: Rank 1
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=3; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=2; schoolMask=1; family=9; familyFlags=[2, 0, 0]
Attributes=['0x50000', '0x200', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[342, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**2973 ? Raptor Strike**

```text
Root/rank: 2973/1; DBC rank text: Rank 1
Effects=[58, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=4; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=2; schoolMask=1; family=9; familyFlags=[2, 0, 65536]
Attributes=['0x50404', '0x0', '0x0', '0x400', '0x0', '0x0', '0x0', '0x0']
Equipment=[2, 173555, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[39, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**35395 ? Crusader Strike**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[121, 31, 6]; TargetA=[6, 6, 6]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=5; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=2; schoolMask=1; family=10; familyFlags=[0, 32768, 0]
Attributes=['0x50000', '0x10000200', '0x0', '0x0', '0x0', '0x0', '0x400', '0x0']
Equipment=[2, 173555, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[8316, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**17364 ? Stormstrike**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[6, 64, 64]; TargetA=[6, 6, 6]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=8; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=2; schoolMask=1; family=11; familyFlags=[0, 16777232, 0]
Attributes=['0x50000', '0x200', '0x0', '0x4000002', '0x0', '0x0', '0x0', '0x0']
Equipment=[2, 173555, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 32175, 32176]; Visual=[7660, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**1752 ? Sinister Strike**

```text
Root/rank: 1752/1; DBC rank text: Rank 1
Effects=[121, 80, 0]; TargetA=[6, 6, 0]; TargetB=[0, 0, 0]
PowerType=3; rawCost=45; percentCost=0; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=2; schoolMask=1; family=8; familyFlags=[8388610, 0, 0]
Attributes=['0x50010', '0x8000200', '0x0', '0x400', '0x0', '0x0', '0x0', '0x0']
Equipment=[2, 173555, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[253, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**78 ? Heroic Strike**

```text
Root/rank: 78/1; DBC rank text: Rank 1
Effects=[58, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=1; rawCost=150; percentCost=0; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=2; schoolMask=1; family=4; familyFlags=[64, 0, 0]
Attributes=['0x50014', '0x8000000', '0x0', '0x400', '0x0', '0x0', '0x0', '0x0']
Equipment=[2, 173555, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[39, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**2816 ? Bark of Doom**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=0; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=2; schoolMask=1; family=0; familyFlags=[0, 0, 0]
Attributes=['0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[0, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**96 ? Dismember**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[31, 6, 0]; TargetA=[6, 6, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=0; rangeEntry=2
Range=[0.0, 0.0, 5.0, 5.0]; rangeFlags=1; castMs=0; speed=0.0
DmgClass=0; schoolMask=1; family=0; familyFlags=[0, 0, 0]
Attributes=['0x50410', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[372, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```


## 7. Damage+Ranged research

SOURCE_PARTIAL overall. Server semantic school override is SERVER_SEMANTIC_OVERRIDE_PARTIAL.
Client metadata/visual conversion is UNSUPPORTED by that setter. No new carrier is enabled.

| Candidate | Native fit/problem | Verdict |
| --- | --- | --- |
| 585 Smite R1 | Holy/Mana/cast time; speed zero | SOURCE_REJECTED for Projectile |
| 403 Lightning Bolt R1 | Nature/Mana/projectile | SOURCE_REJECTED for exact Holy |
| 686 Shadow Bolt R1 | Shadow/Mana/projectile | SOURCE_REJECTED for exact Holy |
| 5176 Wrath R1 | Nature/Mana/projectile and form masks | SOURCE_REJECTED for exact Holy |
| 31759 Holy Bolt | Holy/Mana 90/2.5 s/40 yd/24 speed, generic family | SOURCE_PARTIAL |
| 34232 Holy Bolt | Same requested axes as 31759 | SOURCE_PARTIAL |
| 34346 Holy Bolt | 2.0 s variant, creature-level scaling attribute | SOURCE_PARTIAL |
| 142 New Magic Missile (Test) | Holy/Mana 10/2.0 s/40 yd/15 speed | SOURCE_PARTIAL, test-row provenance |

Holy Bolt 31759/34232 use SpellVisual 7873: HasMissile=1, MissileModel=224, cast/impact kits 119/121.
This is stronger source evidence than a name or Speed alone. It does not demonstrate asset availability or rendering.
Their row has a single SCHOOL_DAMAGE effect and no family masks, form masks, reagent or equipment-class requirement.
NOT_SHAPESHIFTED remains. No rank-chain or direct native SpellScript binding was found in the inspected base text;
absence from those files does not attest the installed DB. None has current Ulduar catalog/runtime registration.
Holy Bolt therefore avoids school conversion as a research direction, but does not acquire execution support here.

School source trace (paths relative to project):

| Path | Captured school use | Boundary |
| --- | --- | --- |
| Spell.h:622 | Sets per-Spell mask before target selection | Shared SpellInfo remains native |
| SpellEffects.cpp:655 | Damage done and taken receive override | Native effect/family scripts still run |
| Spell.cpp:2414 | Hit uses Spell overload | Native damage class remains |
| Unit.cpp:3703 | Immunity/reflect/magic hit take effective mask | Melee dispatch still uses SpellInfo |
| Spell.cpp:8591 | Crit chance receives effective mask | Family-specific crit branches remain |
| Spell.cpp:2841 | Damage record and mitigation carry mask | Native SpellID/attributes retained |
| Unit.cpp:2334 | Absorb/resist consumes DamageInfo school | Live immunity/mitigation still applies |
| Unit.cpp:315 | ProcEventInfo reports per-cast override | Family identity is independently filtered |
| SpellMgr.cpp:900 | School proc filtering uses event mask | :906 checks native family/masks |
| SecondarySpellExecutor.cpp | Event shares captured runtime | No live instance composition lookup |

`Unit.cpp:8655` and `:9304` still branch on native SpellFamilyName/masks for damage/crit behavior.
`SpellInfo.cpp:1353` applies native spell modifiers through family masks. Not every SpellInfo-only call has a Spell
argument: the legacy SpellInfo hit overload and other effects retain source-school behavior. Healing paths, auras and
triggered child identities are not universally converted by the damage override. `SpellEffects.cpp:1580` is an explicit
native-school consumer in healing. A complete override claim would be false even when the direct damage route uses it.

The actual normal launch includes the Spell object in hit/proc calculations; the old SpellInfo-only overload should
not be falsely cited as proof that every primary hit ignores the override. The correct conclusion is bounded damage
support with remaining native family/effect semantics. Existing legacy conversion is preserved, not rewritten.

Client: the cast still names the original SpellID. An override does not replace Spell.dbc, its name/school tooltip,
family, cast/missile visuals or spellbook identity. Server damage reporting may carry the effective mask while client
names/effects remain native. A Nature-looking projectile is not proven Holy presentation. RUNTIME_REQUIRED.

Raw fields: range arrays are hostile-min, friendly-min, hostile-max, friendly-max; speed is yards/second.
Equipment is class/subclass mask/inventory mask. Attributes are Attr0 through Attr7, without decoding away flags.
Effects: 2=school damage, 3=dummy, 6=aura, 10=heal, 31=weapon percent, 58=weapon damage,
64=trigger spell, 80=combo points, 121=normalized weapon damage. Targets: 6=enemy, 21=ally, 25=any.
Cost is raw plus percentage; all card values are native data, not semantic overrides.

**585 ? Smite**

```text
Root/rank: 585/1; DBC rank text: Rank 1
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=9; rangeEntry=4
Range=[0.0, 0.0, 30.0, 30.0]; rangeFlags=0; castMs=1500; speed=0.0
DmgClass=1; schoolMask=2; family=6; familyFlags=[128, 0, 0]
Attributes=['0x10000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 134217728, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[128, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**403 ? Lightning Bolt**

```text
Root/rank: 403/1; DBC rank text: Rank 1
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=6; rangeEntry=4
Range=[0.0, 0.0, 30.0, 30.0]; rangeFlags=0; castMs=1500; speed=20.0
DmgClass=1; schoolMask=8; family=11; familyFlags=[1, 0, 0]
Attributes=['0x10000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[173, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**686 ? Shadow Bolt**

```text
Root/rank: 686/1; DBC rank text: Rank 1
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=10; rangeEntry=4
Range=[0.0, 0.0, 30.0, 30.0]; rangeFlags=0; castMs=1700; speed=20.0
DmgClass=1; schoolMask=32; family=5; familyFlags=[1, 0, 0]
Attributes=['0x10000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[64, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**5176 ? Wrath**

```text
Root/rank: 5176/1; DBC rank text: Rank 1
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=8; rangeEntry=4
Range=[0.0, 0.0, 30.0, 30.0]; rangeFlags=0; castMs=1500; speed=20.0
DmgClass=1; schoolMask=8; family=7; familyFlags=[1, 0, 0]
Attributes=['0x10000', '0x0', '0x80000', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[1073741824, 0, 2, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[3860, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**31759 ? Holy Bolt**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=90; percentCost=0; rangeEntry=5
Range=[0.0, 0.0, 40.0, 40.0]; rangeFlags=0; castMs=2500; speed=24.0
DmgClass=1; schoolMask=2; family=0; familyFlags=[0, 0, 0]
Attributes=['0x10000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[7873, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**34232 ? Holy Bolt**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=90; percentCost=0; rangeEntry=5
Range=[0.0, 0.0, 40.0, 40.0]; rangeFlags=0; castMs=2500; speed=24.0
DmgClass=1; schoolMask=2; family=0; familyFlags=[0, 0, 0]
Attributes=['0x10000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[7873, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**34346 ? Holy Bolt**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=90; percentCost=0; rangeEntry=5
Range=[0.0, 0.0, 40.0, 40.0]; rangeFlags=0; castMs=2000; speed=24.0
DmgClass=1; schoolMask=2; family=0; familyFlags=[0, 0, 0]
Attributes=['0x90000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[7873, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**142 ? New Magic Missile (Test)**

```text
Root/rank: no chain entry in inspected base export; DBC rank text: (none)
Effects=[2, 0, 0]; TargetA=[6, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=10; percentCost=0; rangeEntry=5
Range=[0.0, 0.0, 40.0, 40.0]; rangeFlags=0; castMs=2000; speed=15.0
DmgClass=1; schoolMask=2; family=0; familyFlags=[0, 0, 0]
Attributes=['0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[4, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```


## 8. Healing+Melee research

SOURCE_REJECTED for the complete profile in the CURRENT implementation.
SERVER CAN RESTRICT TO CONTACT is a possible future narrow adapter, not CLIENT ALSO REPRESENTS CONTACT CORRECTLY.

`Spell.h:656` accepts cast-time multipliers only in [0.5,1.0], and only normal non-channeled casts before selection.
`Spell.cpp:3577` applies that multiplier with a minimum. Setting multiplier zero would be ignored; Holy Light cannot
become an authored instant heal through this API. Triggered-cast or GM cast-time bypass is not a normal
carrier solution.

`SetTriggeredTargetValidator` accepts only directly triggered payloads. Current AbilityTargetResolver rechecks
secondaries, not the primary root's contact distance. Native `Spell::CheckRange` uses the SpellInfo range/reach flags.
A future binding-specific OnCheckCast could enforce live friendly contact/reach while retaining native cost, target
and LOS checks. It would need acquisition/completion timing and self-target semantics specified. No hook was added.

A ranged native client could still offer an apparently usable button/target at 40 yards while the server rejects it.
That is UX_MISMATCH, not full compatibility. Server tightening cannot repair client range feedback or cast-bar metadata.
Turning a 2.5-second spell into Instant also raises movement, GCD, animation and synchronization questions; none are
answered by a secondary radius check. The current combination is UNSUPPORTED, not SERVER_ONLY_COMPATIBLE.

| Candidate | Source issue | Verdict |
| --- | --- | --- |
| 635 Holy Light R1 | 2.5 s, 40 yd, Mana 29% | SOURCE_REJECTED for contact Instant |
| 19750 Flash of Light R1 | 1.5 s, 40 yd, Mana 7% | SOURCE_REJECTED for contact Instant |
| 2050 Lesser Heal R1 | 1.5 s, 40 yd, Mana 16%, native form masks | SOURCE_REJECTED |
| 20473 Holy Shock R1 | Instant but mixed-target dummy controller, 20/40 yd, Mana 18% | SOURCE_REJECTED |
| 25914 Holy Shock heal | Triggered child, 100 yd, zero native cost, Paladin family | SOURCE_REJECTED as root |

Holy Shock is bound to `spell_pal_holy_shock` in base spell_script_names; the native script selects damage/heal payload.
Using its heal child directly would lose the controller's native Mana policy and is not an equivalent carrier.
A dedicated custom friendly contact/Instant row avoids these metadata mismatches if later authored and verified.

Raw fields: range arrays are hostile-min, friendly-min, hostile-max, friendly-max; speed is yards/second.
Equipment is class/subclass mask/inventory mask. Attributes are Attr0 through Attr7, without decoding away flags.
Effects: 2=school damage, 3=dummy, 6=aura, 10=heal, 31=weapon percent, 58=weapon damage,
64=trigger spell, 80=combo points, 121=normalized weapon damage. Targets: 6=enemy, 21=ally, 25=any.
Cost is raw plus percentage; all card values are native data, not semantic overrides.

**635 ? Holy Light**

```text
Root/rank: 635/1; DBC rank text: Rank 1
Effects=[10, 0, 0]; TargetA=[21, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=29; rangeEntry=5
Range=[0.0, 0.0, 40.0, 40.0]; rangeFlags=0; castMs=2500; speed=0.0
DmgClass=1; schoolMask=2; family=10; familyFlags=[2147483648, 0, 0]
Attributes=['0x10000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[2936, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**19750 ? Flash of Light**

```text
Root/rank: 19750/1; DBC rank text: Rank 1
Effects=[10, 0, 0]; TargetA=[21, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=7; rangeEntry=5
Range=[0.0, 0.0, 40.0, 40.0]; rangeFlags=0; castMs=1500; speed=0.0
DmgClass=1; schoolMask=2; family=10; familyFlags=[1073741824, 0, 0]
Attributes=['0x10000', '0x0', '0x0', '0x0', '0x0', '0x0', '0x2000000', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[6623, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**2050 ? Lesser Heal**

```text
Root/rank: 2050/1; DBC rank text: Rank 1
Effects=[10, 0, 0]; TargetA=[21, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=16; rangeEntry=5
Range=[0.0, 0.0, 40.0, 40.0]; rangeFlags=0; castMs=1500; speed=0.0
DmgClass=1; schoolMask=2; family=6; familyFlags=[262144, 0, 0]
Attributes=['0x10000', '0x0', '0x80000', '0x0', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[2147483648, 0, 134217728, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[285, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```

**20473 ? Holy Shock**

```text
Root/rank: 20473/1; DBC rank text: Rank 1
Effects=[3, 0, 0]; TargetA=[25, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=18; rangeEntry=161
Range=[0.0, 0.0, 20.0, 40.0]; rangeFlags=0; castMs=0; speed=0.0
DmgClass=0; schoolMask=2; family=10; familyFlags=[2097152, 0, 0]
Attributes=['0x50000', '0x0', '0x0', '0x30000', '0x0', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[0, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: spell_pal_holy_shock
```

**25914 ? Holy Shock**

```text
Root/rank: 25914/1; DBC rank text: Rank 1
Effects=[10, 0, 0]; TargetA=[21, 0, 0]; TargetB=[0, 0, 0]
PowerType=0; rawCost=0; percentCost=0; rangeEntry=6
Range=[0.0, 0.0, 100.0, 100.0]; rangeFlags=0; castMs=0; speed=0.0
DmgClass=1; schoolMask=2; family=10; familyFlags=[0, 65536, 0]
Attributes=['0x50000', '0x0', '0x0', '0x200', '0x1', '0x0', '0x0', '0x0']
Equipment=[-1, 0, 0]; stance/exclude words=[0, 0, 0, 0]
Caster/target aura requirements=[0, 0, 0, 0, 0, 0, 0, 0]; explicitTargetMask=0
TriggeredSpells=[0, 0, 0]; Visual=[135, 0]; Reagents=[0, 0, 0, 0, 0, 0, 0, 0]
Direct script binding in inspected base export: none found
```


## 9. Healing+Ranged source review

Holy Light 635 remains SOURCE_COMPATIBLE only within its first-rank, normal native-caster contract.
Existing module definition: ID 9, command `holylight`, native root 635, Paladin class gate retained.
Repository spell_ranks identifies first rank 635; no later rank is approved here.

Exact data: effects [HEAL,0,0]; targets A=[ALLY,0,0], B=[0,0,0]; Holy school mask 2; Mana power 0;
raw/per-level/per-second costs zero and native percentage cost 29%; 0..40 yd hostile/friendly range;
2500 ms base cast; Speed=0; DmgClass=MAGIC; equipment class=-1 with masks zero; reagent/totem requirements absent
in inspected row; no required/excluded stance masks or aura requirements; family Paladin 10, mask0=0x80000000.
SpellVisual 2936 has no missile, and cast/impact kits 270/154. Native haste, bonus healing, crit, cost modifiers,
cooldowns/GCD and assist-target restrictions still apply. The primary heal uses the native EffectHeal route.

Correction to the prior report: Attributes=0x10000 is SPELL_ATTR0_NOT_SHAPESHIFTED. Zero Stances/StancesNot does not
mean unrestricted use in forms. `SpellInfo::CheckShapeshift` enforces the attribute. The current native Paladin gate
does not require a form; that bounded use is source-compatible, not universally form-neutral.

No direct spell-specific binding for 635 was found in inspected base spell_script_names. Native Paladin family/talent
behavior and surrounding aura procs still affect it; "no direct script binding" must not mean "no native coupling".
The Ulduar catalog supports friendly healing/Impact, and existing OnHit scales the secondary heal and its pre-taken
amount. No native school override is needed. Actual loaded scripts/DB overrides remain UNKNOWN.

`ReviewPhaseACarrier` checks the named definition, first rank/root, reviewed effects, timing/range/resource/school
and adapters. Its Supported and ClientConstraints fields encode source/data review, not measured client acceptance.
It is a bounded allowlist, not an exhaustive fingerprint of every native restriction. New effective-data restrictions
must be reviewed before a future release; no broader support is inferred from this label.

## 10. Native vs custom carrier analysis

| Criterion | Native Blizzard carrier | Custom Ulduar carrier |
| --- | --- | --- |
| Implementation complexity | Simple only when exact fit | Initial catalog/package tooling |
| Client data work | None for unchanged native metadata | Matched client data package required |
| Server work | Review native scripts and restrictions | Review simple rows and adapters |
| Target correctness | Fixed native target semantics | Authored exact target A/B |
| Range correctness | Native reach/range may mismatch | Authored range with reviewed reach |
| Activation correctness | Native cast/queue behavior | Exact Instant/CastTime choice |
| Projectile correctness | Native speed/visual must agree | Authored speed and missile visual |
| Resource correctness | Native costs/coupling retained | Authored Mana cost basis |
| SpellFamily contamination | Often class family/masks | Generic family, zero masks planned |
| Talent contamination | Native modifiers can apply | Avoid class masks; generic effects remain |
| Script contamination | ID/family/SQL hooks need audit | No inherited class script binding |
| Visual flexibility | Fixed without client edits | Reviewed asset references |
| Tooltip flexibility | Native name/values remain | Static shell text still not dynamic instance |
| Cooldown independence | Native rank/category sharing | Distinct IDs/categories by policy |
| Multiple instances | Suitable IDs quickly scarce | Bounded pool can reserve distinct leases |
| Future modifiers | Native constraints accumulate | Explicit families of compatible shells |
| Upgrade maintenance | Native fixes may change behavior | Maintain package plus adapter review |
| Debuggability | Native vs semantic effects overlap | Explicit shell ID/lease/instance trace |
| Risk | Hidden coupling and collisions | Distribution/version mismatch and authoring |

RECOMMENDED_CARRIER_STRATEGY: HYBRID. Native exact matches can support a bounded prototype, but forcing arbitrary
Blizzard spell semantics creates growing exceptions. Prefer neutral custom families for the permanent multi-slot
Forge surface, especially contact healing. A custom pool reduces semantic exceptions; it does not eliminate combat
engine rules, generic auras, procs, class chassis restrictions, client packaging or ownership collision policies.

Design-only shell families: UlduarCarrier_MeleeDamage, UlduarCarrier_RangedProjectileDamage,
UlduarCarrier_MeleeHealing, UlduarCarrier_RangedHealing. No numerical IDs are allocated in this report.
Reserve a checked, versioned ID namespace later; reject collisions with client data, DB overrides and native scripts.
Use one simple damage/heal payload; explicit school, Mana/cost, target policy, activation, range and visual;
generic SpellFamily with reviewed zero masks; no implicit rank chain, class scripts, extra resource effect or proc aura.
Melee defense/weapon policy is an authored decision, not inferred solely from Physical school or short range.

Future data dependencies (none created):

- Spell.dbc: shell ID, effects/targets, school, power/cost, requirements, family/flags, cast/range/visual references.
- SpellRange.dbc: reuse exact reviewed ranges/reach flags; new rows only when necessary for contact feedback.
- SpellCastTimes.dbc: reuse exact Instant/cast entries when possible; do not imply per-instance arbitrary timing.
- SpellVisual.dbc: reuse existing complete missile/impact kits first; new visual records/assets only if justified.
- SpellIcon.dbc: reuse icon entries where appropriate; assets and references must agree in the packaged client.
- SkillLineAbility: conditional need for spellbook grouping/learning presentation; not ownership authority.
- Server SpellInfo loading and module registration: same shell metadata, capability contract and native cast hooks.
- Optional spell_dbc overrides: server-only data cannot create the missing client row; no SQL proposed/executed here.
- Client distribution: versioned DBC/asset package and compatibility policy before publishing custom shell buttons.

Per-cast amount overrides exist through SpellValue/SetSpellValue and current OnHit multipliers. A future adapter must
choose the correct magnitude stage so native coefficients/crit/taken modifiers apply once. Editing a base point is
not equivalent to overriding final damage. No such new adapter was implemented.

## 11. Multi-slot carrier strategy

Native CMSG_CAST_SPELL carries cast count, SpellID, flags and targets, not AbilityInstanceId or carrier generation
(`SpellHandler.cpp:376`). The server checks known active spells. Addon management messages cannot replace secure
native activation or supply trusted instance identity.

| Option | Assessment |
| --- | --- |
| A: one generic carrier per slot | Six IDs cannot express arbitrary client metadata for four profiles |
| B: pool per semantic profile | Good exact metadata; must allow six copies of the same profile |
| C: leased compatible pool | Recommended with stable slot/profile assignment and explicit generations |
| D: custom secure dispatch | No proven stock-client alternative; addon current-selection is ambiguous |

Recommend B+C: a finite profile-family pool, leased uniquely per owner and active slot. For six arbitrary simultaneous
choices, four fixed profiles with six compatible carrier copies each imply up to 24 catalog rows, not one new global
SpellID per owned instance. A deterministic family-by-slot reservation is the simplest lease policy initially.
The same catalog pool may be reused by different owners; two active instances for one owner cannot share a carrier.
Inactive owned instances consume no lease. Pool exhaustion rejects activation explicitly.

Native own cooldowns and action buttons follow SpellID; categories/GCD can be shared only intentionally.
Do not exploit native ranks as six independent buttons: rank-chain replacement and cooldown interactions undermine
that assumption. Future per-instance cooldown/resource state remains attached to instance identity and is projected
to its lease; releasing/reacquiring a different ID must not reset cooldown debt. Native proc charges are not an
implementation of generic ability recharge charges.

An outstanding native packet carries no generation. Reassigning the same SpellID to another instance cannot prove
whether a late request referred to the old or new button. Later management must require no active/queued cast,
serialize loadout changes, update spellbook/action bars and define a safe reuse/quarantine policy. Generation checks
protect server management requests; they do not retroactively add a generation to native packets.

An in-flight cast retains its old snapshot independently of a lease. Future loadout authority must distinguish
already accepted casts from new requests, preserve cooldowns and prevent stale action-bar aliasing. Tooltip/name
text remains shell metadata unless a separate instance-aware view is authored; custom DBC alone does not personalize
each character's same carrier ID. No additional slots, leases, cooldown authority or UI were implemented here.

## 12. Client constraint inventory

These are source expectations from shared metadata, server checks and documented attribute semantics. The proprietary
3.3.5 client implementation was not audited/executed. Exact local feedback and rejection timing remain RUNTIME_REQUIRED.
CLIENT_AND_SERVER means both sides are expected consumers, not observed matching enforcement in a live client.

| Constraint | Classification | Source boundary |
| --- | --- | --- |
| Unit relation/target selection | CLIENT_AND_SERVER | DBC targets; CheckTarget/CheckExplicitTarget |
| Range/reach | CLIENT_AND_SERVER | Native range feedback; server CheckRange/reach |
| Cast time and movement | CLIENT_AND_SERVER | Cast metadata/bar; server schedule/interruption |
| Mana power/cost | CLIENT_AND_SERVER | Client display/availability; server computes/debits |
| Reagents/tools/focus | CLIENT_AND_SERVER | Shared requirements; native CheckCast |
| Equipment requirements | CLIENT_AND_SERVER | Item class/masks; native equipment checks |
| Forms/stances | CLIENT_AND_SERVER | Masks plus NOT_SHAPESHIFTED; CheckShapeshift |
| SpellID knowledge/spellbook | CLIENT_AND_SERVER | Client lookup; server HasActiveSpell |
| Action bar identity | CLIENT_AND_SERVER | Native action ID and saved server action state |
| GCD/own/category cooldown | CLIENT_AND_SERVER | Client feedback and server enforcement |
| Missile visual/color | CLIENT_PRESENTATION_ONLY | Client assets; server chooses spell/visual source |
| Projectile impact timing | CLIENT_AND_SERVER | Native speed/travel vs visual synchronization |
| Tooltip text/icon | CLIENT_PRESENTATION_ONLY | Static metadata does not equal resolved instance |
| Instance ownership/revision | SERVER_ONLY | Registry and future server authority |
| Impact secondary eligibility | SERVER_ONLY | Existing target resolver and hit recheck |
| Effective MPQ load order | UNKNOWN | Extracted DBC hashes do not attest loaded client |
| Client handling of NPC/test rows | UNKNOWN | Cannot infer button acceptance from DBC presence |

Future client checklist for each candidate: spellbook appearance, secure button activation, friendly/hostile target
selection and cursor, in/out-of-range feedback, power/cost feedback, cast bar/movement, missile and impact visuals,
damage/heal feedback, GCD/own cooldown, error text, tooltip discrepancies and action-bar behavior after reload/login.
For contact healing, test self/ally at contact and just beyond it; for Holy Bolt, match visible arrival to damage;
for Mongoose, inspect auto-attack side effects; for Holy Light, verify first-rank identity and cost.

Future server plan, NOT executed: use an isolated pre-provisioned test environment with automatic DB updates disabled,
an existing disposable test character and known script/data versions. A worldserver normally writes character state,
so it cannot be called a no-DB-change test merely because the Forge registry is in memory. Obtain separate runtime
authorization and a storage-isolation policy before launch. Prefer existing integration fixtures first.
If a debug binding is later necessary, require a test-only build/path, default disabled, one explicit test owner,
no acquisition/persistence operation, verified Forge-only provenance and explicit cleanup. Do not grant a trained
native spell Forge-only status just to make the experiment run. No diagnostic hook was added in this phase.

## 13. Impact/Coverage bridge

SOURCE_ONLY design. Preserve current Phase A prototype: one secondary, 10 yd, multiplier 0.10 through existing
ResolvePropagationStats. Preserve every legacy rank/EP formula and runtime scaling stage.
There is no currently implemented general CoverageResolver; the older slice document overstates that foundation.

Proposed smallest boundary, not compiled code or a persistent schema:

```text
ResolvedCoverage
  coverageGroupId, profileId/version, resolverVersion, provenance
  optional MaxTargets       # TOTAL executions including primary; checked integer
  optional Radius           # quantized distance, not acquisition range
  optional Angle, Width, Length, HopRange
  distributionPolicyId     # separate from geometry scaling
  SecondaryMultiplier      # final distribution factor; not another Coverage point value
  safetyLimits, clampReasons
```

Use typed units and absence, not zero, for non-applicable fields. Optional MaxTargets alone must not encode unlimited:
native unlimited-area policy needs an explicit tag and an independent finite work budget. Phase A point+Impact can
use total MaxTargets=2, Radius=10 yd and distribution factor 0.10. Bare point baseline has MaxTargets=1 and no radius.

Two separate input adapters converge on ONE resolved runtime representation:

1. LegacyCustomizationAdapter reads current legacy EP/ranks and calls existing ResolvePropagationStats unchanged.
   It translates secondary count N to total N+1 with checked arithmetic and preserves radius/multiplier exactly.
2. Instance composition installs Impact structurally, selecting the secondary topology. Semantic Coverage modifiers
   then go to CoverageResolver with a named geometry profile; gems never translate themselves into legacy ranks.
3. A narrow runtime adapter converts total count back to secondary count once and assigns radius/final distribution
   once. Existing propagation/target/execution machinery consumes the result without recomputing legacy ranks.

Generic Stats specifies Circle/Impact Coverage as a radius axis. Installing Impact adds the topology; adding Coverage
does not silently add another target or potency multiplier. Chain counts, cone angles, line widths and custom shapes
are chosen by typed profile adapters with required fields. Unknown geometry/capabilities reject resolution rather
than a giant per-SpellID switch. Do not hardcode unused dimensions into the current engine.

Distribution and total-output conservation must be explicit policy decisions: current primary 1.0 plus secondary 0.10
is not a conserved single-target budget. Coverage must not apply potency/falloff a second time. Keep current OnHit
secondary scaling exactly once until a separately reviewed magnitude-stage migration exists. Capture final coverage
with the same immutable instance revision/cast snapshot. No bridge code or general compiler was added.

## 14. Source defects found/fixed

SOURCE_DEFECTS_FIXED: 0. No clear Phase A code defect met the source-only correction gate.

Recorded review issues: MEDIUM test coverage and caller-thread assumptions; LOW report forms wording.
This report corrects the latter interpretation without editing existing architecture or widening carrier support.
No broad native-school rewrite, instant-heal bypass, arbitrary NPC allowlisting or test weakening was performed.

## 15. Preservation report

Before this source-only review, a fresh SHA-256 inventory recorded 150 existing files: module including all Phase A
files/tests, client, docs, the five pre-modified core files, two pending Ulduar SQL files and six native DBC copies.
Git status was also recorded; untracked contents were hashed instead of treated as absent.

Root pre-existing modifications: Unit.cpp/.h, Spell.cpp/.h and SpellEffects.cpp. Existing untracked roots:
client/, docs/, `pending_db_characters/ulduar_abilities_004_characters_modifiers.sql` and
`pending_db_world/ulduar_abilities_003_world_starters.sql` under data/sql/updates.
The module already had four skeleton deletions: conf/my_custom.conf.dist,
data/sql/db-world/skeleton_module_acore_string.sql, src/MP_loader.cpp and src/MyPlayer.cpp.
Its implementation files, config, SQL, module documentation, tests and CMake registration were already untracked.
These pre-existing statuses were preserved.

Existing files intentionally changed: none.
New repository files: only `docs/implementation/ULDuar_PHASE_A5_SOURCE_REVIEW.md`.
Removed files: none.
Unrelated existing files: all 150 baseline files remain byte-identical; zero changed and zero missing.
Static formatting inspection and the read-only C++ codestyle scanner found no module source formatting issues.
No project executable was used for these checks. SQL lint was not run: SQL is unchanged and that script also
fetches Git remote state, outside the needed source-only inspection.

Historical build artifacts from the superseded authorized phase remain outside the source repository in ulduar-build,
including its BUILD_TESTING cache setting and logs. This review did not undo them through a prohibited reconfigure.
No Git commit, reset, clean, source deletion or reference-repository modification was performed.

## 16. Remaining blockers

- The 24 tests are authored only; native/legacy parity and actual dispatch are RUNTIME_REQUIRED.
- Three Forge profiles still lack approved executable contracts. New data candidates are not installed adapters.
- Holy Light is first-rank, native Paladin/family/restriction compatible, not class-neutral or runtime-established.
- Current cast-time API cannot author Instant from the inspected heals; primary contact adapter is absent.
- Per-cast school conversion does not neutralize native family/scripts/client metadata.
- Exact client package, live world overrides/script associations and NPC-row action-button acceptance are UNKNOWN.
- Multi-slot reuse needs cooldown continuity and a policy for queued native packets with no generation field.
- Coverage distribution/conservation is a future design decision; current prototype does not implement generic stats.

## 17. Recommended next phase

Review and accept a carrier design decision first: HYBRID with neutral profile-by-slot shell pools, and bounded native
exceptions only where their retained behavior is intentional. Research Mongoose Bite and Holy Bolt further without
promoting them merely because raw fields fit. Prepare a separately authorized Custom Carrier Prototype if exact
contact healing and neutral multi-slot semantics remain requirements.

Before implementation/runtime work, specify native side-effect policy, effective data/manifest evidence, ownership
provenance, loaded script binding, cooldown/lease reuse and the missing dispatch regression cases. Author supplemental
tests under separate scope if needed. Do not proceed to progression/persistence on a claim of runtime acceptance.

No next phase was begun. For THIS replacement source-only phase:

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO SQL WAS EXECUTED.
NO CLIENT PATCH WAS APPLIED.
