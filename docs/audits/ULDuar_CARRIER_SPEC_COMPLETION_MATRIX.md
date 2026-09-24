# ULDuar A.8 carrier spec completion matrix

Date: 2026-09-19. SOURCE_ONLY. 51 fields per family, 204 total. All four: NOT_ARTIFACT_READY.
[Main review](../implementation/ULDuar_PHASE_A8_EFFECTIVE_DATA_REVIEW.md).

The Policy column references the full per-field decision immediately below each table.
The original A.7 status is retained, including nested unknowns described in policy notes.
Machine-readable full text is in [the matrix audit](ULDuar_A8_SPEC_MATRIX.json).
This is documentation, not a consumable carrier catalog or production manifest.

## Evidence and remaining-evidence keys

All evidence is SOURCE_ONLY. Class keys: E=ENGINE_TECHNICAL; U=UX_TECHNICAL; B=BALANCE;
T=CONTENT; R=RUNTIME_EVIDENCE; C=CLIENT_EVIDENCE. Combined keys retain all relevant categories.
These classify every UNKNOWN/AUTHORED_LATER field, and also the remaining A.7 fields.
Ready values describe a field decision, never overall approval or observed execution.

Remaining keys: I=ordinary future integration/effective-data review; V=missing scoped runtime design/adapter;
C=missing target-client/package evidence; N=missing namespace proof; P=unresolved authoring/attribute policy;
B=balance review later (the staging fixture already has an exact provisional value).
Global N/C gates apply to every field even where its local decision is READY_STATIC.

## Source keys

- S1: A.7 section 7 + AbilityInstance.cpp MakeProfile/GetPhaseAProfiles; design identities and semantic constraints.
- S2: AbilityCarrierCatalog.cpp ValidateCatalogCarrier/GetPhaseA6CarrierCatalog; custom entries remain pending.
- S3: A raw Spell/Range/CastTimes reference rows and DBCStructure.h; see reference companion and hashed JSON.
- S4: Unit.cpp SpellHitResult/MagicSpellHitResult, crit functions and CalculateSpellDamageTaken.
- S5: SpellInfo.cpp _InitializeExplicitTargetMask/CheckExplicitTarget and Spell.cpp InitExplicitTargets/CheckRange.
- S6: SpellInfo.cpp CalcPowerCost; Spell.cpp CheckPower/TakePower; no second resource debit exists.
- S7: Spell.cpp TriggerGlobalCooldown; Player.cpp cooldown projection; PlayerUpdates.cpp queued category checks.
- S8: SharedDefines.h SpellAttr0..7 and Spell.cpp/SpellInfo.cpp attribute consumers; main report section 16.
- S9: Unit.cpp bonus done/taken/level penalty; SpellInfo.cpp:339; spell_bonus_data.sql; main section 18.
- S10: Spell.cpp proc dispatch/HealInfo/threat; SpellMgr.cpp proc filtering; A.7 provenance policy.
- S11: A visual/icon/kit/effect/sound rows, external manifests and loose asset inventory; references companion.
- S12: Player.cpp SendInitialSpells/IsActionButtonDataValid; SkillLineAbility/SkillLine rows; client unknown.
- S13: A.7 namespace ledger policy; A.8 hashed occupancy inventory and missing effective-release sources.

## MeleeDamage

| Field | A.7 | Evidence | Policy | Source | Remaining | Readiness |
| --- | --- | --- | --- | --- | --- | --- |
| specKey | FIXED | E | P01 | S1 | I | READY_STATIC |
| schemaVersion | FIXED | E | P02 | S1 | I | READY_STATIC |
| specVersion | FIXED | E | P03 | S1 | I | READY_STATIC |
| family | FIXED | E | P04 | S1 | I | READY_STATIC |
| semanticProfileId | FIXED | E | P05 | S1 | I | READY_STATIC |
| semanticProfileVersion | FIXED | E | P06 | S1 | I | READY_STATIC |
| purpose | FIXED | E | P07 | S1 | I | READY_STATIC |
| method | FIXED | E | P08 | S1 | I | READY_STATIC |
| activation | FIXED | E | P09 | S1 | I | READY_STATIC |
| targeting | FIXED | E | P10 | S1 | I | READY_STATIC |
| targetRelation | FIXED | E | P11 | S1 | I | READY_STATIC |
| delivery | FIXED | E | P12 | S1 | I | READY_STATIC |
| geometry | FIXED | E | P13 | S1 | I | READY_STATIC |
| school | FIXED | E | P14 | S1 | I | READY_STATIC |
| powerType | FIXED | E | P15 | S1 | I | READY_STATIC |
| costPolicy | FIXED | E | P16 | S6 | I | READY_STATIC |
| costModel | AUTHORED_LATER | E+B | P17 | S6 | B | READY_PROVISIONAL_BALANCE |
| costAmount | AUTHORED_LATER | B | P18 | S3 | B | READY_PROVISIONAL_BALANCE |
| rangeProfile | FIXED | E+U+C | P19 | S5 | C | READY_STATIC |
| castTimeProfile | FIXED | E | P20 | S3 | I | READY_STATIC |
| projectileSpeedProfile | FIXED | E | P21 | S3 | I | READY_STATIC |
| damageClassPolicy | UNKNOWN | E | P22 | S4 | I | READY_STATIC |
| hitCritDefensePolicy | UNKNOWN | E+R | P23 | S4 | I | READY_STATIC |
| coefficientPolicy | UNKNOWN | E+B+R | P24 | S9 | V | BLOCKED_RUNTIME |
| magnitude | AUTHORED_LATER | B+R | P25 | S9 | V | BLOCKED_RUNTIME |
| spellFamilyPolicy | FIXED | E | P26 | S10 | I | READY_STATIC |
| familyMasks | FIXED | E | P27 | S10 | I | READY_STATIC |
| effectLayout | FIXED | E | P28 | S3 | I | READY_STATIC |
| attributesPolicy | UNKNOWN | E+C | P29 | S8 | P | BLOCKED_POLICY |
| mechanicPolicy | FIXED | E | P30 | S3 | I | READY_STATIC |
| procEventPolicy | UNKNOWN | E+R | P31 | S10 | V | BLOCKED_RUNTIME |
| equipmentPolicy | FIXED | E | P32 | S8 | I | READY_STATIC |
| stancePolicy | FIXED | E | P33 | S8 | I | READY_STATIC |
| reagentPolicy | FIXED | E | P34 | S3 | I | READY_STATIC |
| cooldownPolicy | AUTHORED_LATER | E+B | P35 | S7 | B | READY_PROVISIONAL_BALANCE |
| categoryPolicy | UNKNOWN | E+U | P36 | S7 | I | READY_STATIC |
| gcdPolicy | AUTHORED_LATER | U+B | P37 | S7 | B | READY_PROVISIONAL_BALANCE |
| visualProfile | UNKNOWN | T+C | P38 | S11 | C | BLOCKED_CLIENT |
| clientRequirements | UNKNOWN | U+C | P39 | S13 | C | BLOCKED_CLIENT |
| compatibilityEnvelope | FIXED | E+U | P40 | S3 | I | READY_STATIC |
| provenance | FIXED | E | P41 | S3 | I | READY_STATIC |
| reviewRecord | FIXED | E | P42 | S2 | I | READY_STATIC |
| nativeRankPolicy | FIXED | E | P43 | S2 | I | READY_STATIC |
| clientTargetFlags | UNKNOWN | E+C | P44 | S5 | C | READY_STATIC |
| selfTargetPolicy | FIXED | E | P45 | S5 | I | READY_STATIC |
| deadTargetPolicy | FIXED | E | P46 | S8 | I | READY_STATIC |
| assignedSpellId | UNKNOWN | E | P47 | S13 | N | BLOCKED_NAMESPACE |
| skillLineAbilityProjection | UNKNOWN | U+C | P48 | S12 | C | BLOCKED_CLIENT |
| charges | NOT_APPLICABLE | E | P49 | S7 | I | READY_STATIC |
| channelPolicy | NOT_APPLICABLE | E | P50 | S8 | I | READY_STATIC |
| optionalSoundFallback | UNKNOWN | T+C | P51 | S11 | C | BLOCKED_CLIENT |

### MeleeDamage policy decisions

- P01 (specKey): UlduarCarrier_MeleeDamage
- P02 (schemaVersion): Draft schema 1 retained; no production schema artifact emitted.
- P03 (specVersion): Draft spec 2 in A.8 documentation; unpublished. This does not mutate the A.6 catalog entry
  version.
- P04 (family): MeleeDamage
- P05 (semanticProfileId): DamageMelee
- P06 (semanticProfileVersion): 1 (current source reference)
- P07 (purpose): Damage
- P08 (method): Melee
- P09 (activation): Instant; independent root, no next-swing
- P10 (targeting): Unit
- P11 (targetRelation): Enemy
- P12 (delivery): Direct
- P13 (geometry): Point
- P14 (school): Physical
- P15 (powerType): Mana
- P16 (costPolicy): NativeCarrierCost and exactly one native debit for the fixture. ResolvedResourceCost is deferred.
- P17 (costModel): PROVISIONAL_SLICE1 percentage of native create-Mana; flat/per-level/per-second components zero. Not
  final class-neutral economy.
- P18 (costAmount): PROVISIONAL_SLICE1 3% of base/create-Mana; native CalcPowerCost modifier order and rounding. No
  second Ulduar deduction.
- P19 (rangeProfile): Range2: hostile/friendly min0,max5,flags1; native combat reach/leeway, not fixed
  center-distance5.
- P20 (castTimeProfile): CastTimes1: exact instant base0.
- P21 (projectileSpeedProfile): Speed0; no missile travel.
- P22 (damageClassPolicy): MAGIC=1. Contact geometry does not select MELEE. BASE_ATTACK is internal bookkeeping, no
  weapon payload.
- P23 (hitCritDefensePolicy): Physical spell hit, armor and normal absorbs/immunities; no melee dodge/parry/block
  path; CANT_CRIT set; facing1.
- P24 (coefficientPolicy): PROVISIONAL_SLICE1 direct SP=0, AP/DOT=0; explicit done/taken policy; level penalty1
  fixture. One future Potency input, no double scaling.
- P25 (magnitude): PROVISIONAL_SLICE1 resolved base 25 fixed. Option-B carrier seed is one unit before required
  replacement; not a native fallback. No per-level/combo scaling.
- P26 (spellFamilyPolicy): SPELLFAMILY_GENERIC=0; no native family enum or class eligibility. This does not isolate
  broad modifiers.
- P27 (familyMasks): Three family mask words zero; all effect class masks zero. Provenance filtering remains separate.
- P28 (effectLayout): One SCHOOL_DAMAGE=2 with TargetA=6 enemy, B=0; two absent effects; no triggers, auras, periodic
  or controller riders.
- P29 (attributesPolicy): Named REQUIRED_SET/CLEAR rules in main section16; remaining word bits/client flags
  unresolved. Never copy a native full bitset or assume all zero.
- P30 (mechanicPolicy): Mechanic0, effect mechanics0, no aura/control/dispel/periodic rider.
- P31 (procEventPolicy): Negative magic cast/hit/damage/kill; no crit in this fixture. Generic listeners reviewed;
  class talents/passives denied by future provenance boundary. Row proc flags/chance/charges0.
- P32 (equipmentPolicy): EquippedItemClass=-1; subclass/inventory masks0; no ammunition/mainhand/offhand requirement.
- P33 (stancePolicy): Stances/StancesNot0; NOT_SHAPESHIFTED clear; no stance/form entitlement. Verify client/resource
  behavior in forms later.
- P34 (reagentPolicy): Reagent IDs/counts, totems/categories, focus and tool requirements absent/zero.
- P35 (cooldownPolicy): PROVISIONAL_SLICE1 own recovery0; future non-GCD debt belongs to AbilityInstance, not lease.
- P36 (categoryPolicy): Spell Category0 and category recovery0 for current one-slot fixture; one shared native queued
  intent. Six independent queue categories are not promised.
- P37 (gcdPolicy): PROVISIONAL_SLICE1 StartRecoveryCategory133,1500 ms base; ordinary spell haste/mods and native1000
  ms floor. Own recovery0 is not GCD0.
- P38 (visualProfile): SpellVisual342 / SpellIcon257 reference candidates; kit/effect/sound graph recorded; effective
  model/texture/animation closure missing.
- P39 (clientRequirements): Matched build12340 package, supported locales, target/cost/timing/reach and native action
  identity. Effective release package unpinned.
- P40 (compatibilityEnvelope): MeleeDamage_ExactV1: use this record numerical baseline; only one envelope. No
  arbitrary cost/range/cast/school/presentation mutation.
- P41 (provenance): Ulduar-authored A.8 design; native per-field references and hashes explicitly recorded. No
  native/Ascension row clone.
- P42 (reviewRecord): A.8 SOURCE_ONLY audit; no tests, effective-data approval or runtime/client evidence. Custom
  pending status unchanged.
- P43 (nativeRankPolicy): No spell_ranks chain, learn-trigger relation or automatic rank promotion. Each leased copy
  is distinct transport.
- P44 (clientTargetFlags): Propose raw Targets=0 as inspected native rows; effect target supplies ENEMY0x80 in
  effective explicit mask. Native packet Unit flag0x2 is separate. No corpse/destination/area flag.
- P45 (selfTargetPolicy): Enemy legality only; EXCLUDE_CASTER set; no self fallback. Missing hostile target selection
  remains subject to native checks.
- P46 (deadTargetPolicy): Living units only; no dead/corpse/resurrection targeting; caster cannot cast while dead.
- P47 (assignedSpellId): Absent. NAMESPACE_UNRESOLVED; no numeric interval or individual ID allocated.
- P48 (skillLineAbilityProjection): Prefer visible known-spell fixture without new skill row; server packet/action
  path permits this hypothesis. General tab/drag behavior unproved; optional new mapping only after evidence.
- P49 (charges): NOT_APPLICABLE; no ability charge/recharge feature and no proc aura charges.
- P50 (channelPolicy): NOT_APPLICABLE; independent non-channel root, no channel attributes/ticks.
- P51 (optionalSoundFallback): UNKNOWN until selected visual cues are reviewed. Silence may replace only explicitly
  nonessential cosmetics; no silent fallback for a critical cue.

## RangedProjectileDamage

| Field | A.7 | Evidence | Policy | Source | Remaining | Readiness |
| --- | --- | --- | --- | --- | --- | --- |
| specKey | FIXED | E | P01 | S1 | I | READY_STATIC |
| schemaVersion | FIXED | E | P02 | S1 | I | READY_STATIC |
| specVersion | FIXED | E | P03 | S1 | I | READY_STATIC |
| family | FIXED | E | P04 | S1 | I | READY_STATIC |
| semanticProfileId | FIXED | E | P05 | S1 | I | READY_STATIC |
| semanticProfileVersion | FIXED | E | P06 | S1 | I | READY_STATIC |
| purpose | FIXED | E | P07 | S1 | I | READY_STATIC |
| method | FIXED | E | P08 | S1 | I | READY_STATIC |
| activation | FIXED | E | P09 | S1 | I | READY_STATIC |
| targeting | FIXED | E | P10 | S1 | I | READY_STATIC |
| targetRelation | FIXED | E | P11 | S1 | I | READY_STATIC |
| delivery | FIXED | E | P12 | S1 | I | READY_STATIC |
| geometry | FIXED | E | P13 | S1 | I | READY_STATIC |
| school | FIXED | E | P14 | S1 | I | READY_STATIC |
| powerType | FIXED | E | P15 | S1 | I | READY_STATIC |
| costPolicy | FIXED | E | P16 | S6 | I | READY_STATIC |
| costModel | AUTHORED_LATER | E+B | P17 | S6 | B | READY_PROVISIONAL_BALANCE |
| costAmount | AUTHORED_LATER | B | P18 | S3 | B | READY_PROVISIONAL_BALANCE |
| rangeProfile | AUTHORED_LATER | U+B | P19 | S5 | B | READY_PROVISIONAL_BALANCE |
| castTimeProfile | AUTHORED_LATER | U+B | P20 | S3 | B | READY_PROVISIONAL_BALANCE |
| projectileSpeedProfile | AUTHORED_LATER | U+T | P21 | S3 | C | READY_PROVISIONAL_BALANCE |
| damageClassPolicy | UNKNOWN | E | P22 | S4 | I | READY_STATIC |
| hitCritDefensePolicy | UNKNOWN | E+R | P23 | S4 | I | READY_STATIC |
| coefficientPolicy | UNKNOWN | E+B+R | P24 | S9 | V | BLOCKED_RUNTIME |
| magnitude | AUTHORED_LATER | B+R | P25 | S9 | V | BLOCKED_RUNTIME |
| spellFamilyPolicy | FIXED | E | P26 | S10 | I | READY_STATIC |
| familyMasks | FIXED | E | P27 | S10 | I | READY_STATIC |
| effectLayout | FIXED | E | P28 | S3 | I | READY_STATIC |
| attributesPolicy | UNKNOWN | E+C | P29 | S8 | P | BLOCKED_POLICY |
| mechanicPolicy | FIXED | E | P30 | S3 | I | READY_STATIC |
| procEventPolicy | UNKNOWN | E+R | P31 | S10 | V | BLOCKED_RUNTIME |
| equipmentPolicy | FIXED | E | P32 | S8 | I | READY_STATIC |
| stancePolicy | FIXED | E | P33 | S8 | I | READY_STATIC |
| reagentPolicy | FIXED | E | P34 | S3 | I | READY_STATIC |
| cooldownPolicy | AUTHORED_LATER | E+B | P35 | S7 | B | READY_PROVISIONAL_BALANCE |
| categoryPolicy | UNKNOWN | E+U | P36 | S7 | I | READY_STATIC |
| gcdPolicy | AUTHORED_LATER | U+B | P37 | S7 | B | READY_PROVISIONAL_BALANCE |
| visualProfile | REUSE_REFERENCE | T+C | P38 | S11 | C | BLOCKED_CLIENT |
| clientRequirements | UNKNOWN | U+C | P39 | S13 | C | BLOCKED_CLIENT |
| compatibilityEnvelope | FIXED | E+U | P40 | S3 | I | READY_STATIC |
| provenance | FIXED | E | P41 | S3 | I | READY_STATIC |
| reviewRecord | FIXED | E | P42 | S2 | I | READY_STATIC |
| nativeRankPolicy | FIXED | E | P43 | S2 | I | READY_STATIC |
| clientTargetFlags | UNKNOWN | E+C | P44 | S5 | C | READY_STATIC |
| selfTargetPolicy | FIXED | E | P45 | S5 | I | READY_STATIC |
| deadTargetPolicy | FIXED | E | P46 | S8 | I | READY_STATIC |
| assignedSpellId | UNKNOWN | E | P47 | S13 | N | BLOCKED_NAMESPACE |
| skillLineAbilityProjection | UNKNOWN | U+C | P48 | S12 | C | BLOCKED_CLIENT |
| charges | NOT_APPLICABLE | E | P49 | S7 | I | READY_STATIC |
| channelPolicy | NOT_APPLICABLE | E | P50 | S8 | I | READY_STATIC |
| optionalSoundFallback | UNKNOWN | T+C | P51 | S11 | C | BLOCKED_CLIENT |

### RangedProjectileDamage policy decisions

- P01 (specKey): UlduarCarrier_RangedProjectileDamage
- P02 (schemaVersion): Draft schema 1 retained; no production schema artifact emitted.
- P03 (specVersion): Draft spec 2 in A.8 documentation; unpublished. This does not mutate the A.6 catalog entry
  version.
- P04 (family): RangedProjectileDamage
- P05 (semanticProfileId): DamageRanged
- P06 (semanticProfileVersion): 1 (current source reference)
- P07 (purpose): Damage
- P08 (method): Ranged
- P09 (activation): CastTime; independent root, no next-swing
- P10 (targeting): Unit
- P11 (targetRelation): Enemy
- P12 (delivery): Projectile
- P13 (geometry): Point
- P14 (school): Holy
- P15 (powerType): Mana
- P16 (costPolicy): NativeCarrierCost and exactly one native debit for the fixture. ResolvedResourceCost is deferred.
- P17 (costModel): PROVISIONAL_SLICE1 percentage of native create-Mana; flat/per-level/per-second components zero. Not
  final class-neutral economy.
- P18 (costAmount): PROVISIONAL_SLICE1 9% of base/create-Mana; native CalcPowerCost modifier order and rounding. No
  second Ulduar deduction.
- P19 (rangeProfile): PROVISIONAL_SLICE1 Range5: hostile/friendly min0,max40,flags0; no ranged-weapon dead zone.
- P20 (castTimeProfile): PROVISIONAL_SLICE1 CastTimes20: base2500 ms, per-level0,min2500. Ordinary reviewed native
  haste.
- P21 (projectileSpeedProfile): PROVISIONAL_SLICE1 Speed24; native missile timing; one exact envelope.
- P22 (damageClassPolicy): MAGIC=1. Contact geometry does not select MELEE. BASE_ATTACK is internal bookkeeping, no
  weapon payload.
- P23 (hitCritDefensePolicy): Holy magic hit/crit, facing1; normal reflect/deflect/absorb/immunity. Partial Holy
  resist branch applies to creatures, not players.
- P24 (coefficientPolicy): PROVISIONAL_SLICE1 direct SP=0.123, AP/DOT=0; explicit done/taken policy; level penalty1
  fixture. One future Potency input, no double scaling.
- P25 (magnitude): PROVISIONAL_SLICE1 resolved base 13..17. Option-B carrier seed is one unit before required
  replacement; not a native fallback. No per-level/combo scaling.
- P26 (spellFamilyPolicy): SPELLFAMILY_GENERIC=0; no native family enum or class eligibility. This does not isolate
  broad modifiers.
- P27 (familyMasks): Three family mask words zero; all effect class masks zero. Provenance filtering remains separate.
- P28 (effectLayout): One SCHOOL_DAMAGE=2 with TargetA=6 enemy, B=0; two absent effects; no triggers, auras, periodic
  or controller riders.
- P29 (attributesPolicy): Named REQUIRED_SET/CLEAR rules in main section16; remaining word bits/client flags
  unresolved. Never copy a native full bitset or assume all zero.
- P30 (mechanicPolicy): Mechanic0, effect mechanics0, no aura/control/dispel/periodic rider.
- P31 (procEventPolicy): Negative magic cast/hit/damage/kill; crit when native result is critical. Generic listeners
  reviewed; class talents/passives denied by future provenance boundary. Row proc flags/chance/charges0.
- P32 (equipmentPolicy): EquippedItemClass=-1; subclass/inventory masks0; no ammunition/mainhand/offhand requirement.
- P33 (stancePolicy): Stances/StancesNot0; NOT_SHAPESHIFTED clear; no stance/form entitlement. Verify client/resource
  behavior in forms later.
- P34 (reagentPolicy): Reagent IDs/counts, totems/categories, focus and tool requirements absent/zero.
- P35 (cooldownPolicy): PROVISIONAL_SLICE1 own recovery0; future non-GCD debt belongs to AbilityInstance, not lease.
- P36 (categoryPolicy): Spell Category0 and category recovery0 for current one-slot fixture; one shared native queued
  intent. Six independent queue categories are not promised.
- P37 (gcdPolicy): PROVISIONAL_SLICE1 StartRecoveryCategory133,1500 ms base; ordinary spell haste/mods and native1000
  ms floor. Own recovery0 is not GCD0.
- P38 (visualProfile): SpellVisual7873 / SpellIcon237 reference candidates; kit/effect/sound graph recorded; effective
  model/texture/animation closure missing.
- P39 (clientRequirements): Matched build12340 package, supported locales, target/cost/timing/reach and native action
  identity. Effective release package unpinned.
- P40 (compatibilityEnvelope): RangedProjectileDamage_ExactV1: use this record numerical baseline; only one envelope.
  No arbitrary cost/range/cast/school/presentation mutation.
- P41 (provenance): Ulduar-authored A.8 design; native per-field references and hashes explicitly recorded. No
  native/Ascension row clone.
- P42 (reviewRecord): A.8 SOURCE_ONLY audit; no tests, effective-data approval or runtime/client evidence. Custom
  pending status unchanged.
- P43 (nativeRankPolicy): No spell_ranks chain, learn-trigger relation or automatic rank promotion. Each leased copy
  is distinct transport.
- P44 (clientTargetFlags): Propose raw Targets=0 as inspected native rows; effect target supplies ENEMY0x80 in
  effective explicit mask. Native packet Unit flag0x2 is separate. No corpse/destination/area flag.
- P45 (selfTargetPolicy): Enemy legality only; EXCLUDE_CASTER set; no self fallback. Missing hostile target selection
  remains subject to native checks.
- P46 (deadTargetPolicy): Living units only; no dead/corpse/resurrection targeting; caster cannot cast while dead.
- P47 (assignedSpellId): Absent. NAMESPACE_UNRESOLVED; no numeric interval or individual ID allocated.
- P48 (skillLineAbilityProjection): Prefer visible known-spell fixture without new skill row; server packet/action
  path permits this hypothesis. General tab/drag behavior unproved; optional new mapping only after evidence.
- P49 (charges): NOT_APPLICABLE; no ability charge/recharge feature and no proc aura charges.
- P50 (channelPolicy): NOT_APPLICABLE; independent non-channel root, no channel attributes/ticks.
- P51 (optionalSoundFallback): UNKNOWN until selected visual cues are reviewed. Silence may replace only explicitly
  nonessential cosmetics; no silent fallback for a critical cue.

## MeleeHealing

| Field | A.7 | Evidence | Policy | Source | Remaining | Readiness |
| --- | --- | --- | --- | --- | --- | --- |
| specKey | FIXED | E | P01 | S1 | I | READY_STATIC |
| schemaVersion | FIXED | E | P02 | S1 | I | READY_STATIC |
| specVersion | FIXED | E | P03 | S1 | I | READY_STATIC |
| family | FIXED | E | P04 | S1 | I | READY_STATIC |
| semanticProfileId | FIXED | E | P05 | S1 | I | READY_STATIC |
| semanticProfileVersion | FIXED | E | P06 | S1 | I | READY_STATIC |
| purpose | FIXED | E | P07 | S1 | I | READY_STATIC |
| method | FIXED | E | P08 | S1 | I | READY_STATIC |
| activation | FIXED | E | P09 | S1 | I | READY_STATIC |
| targeting | FIXED | E | P10 | S1 | I | READY_STATIC |
| targetRelation | FIXED | E | P11 | S1 | I | READY_STATIC |
| delivery | FIXED | E | P12 | S1 | I | READY_STATIC |
| geometry | FIXED | E | P13 | S1 | I | READY_STATIC |
| school | FIXED | E | P14 | S1 | I | READY_STATIC |
| powerType | FIXED | E | P15 | S1 | I | READY_STATIC |
| costPolicy | FIXED | E | P16 | S6 | I | READY_STATIC |
| costModel | AUTHORED_LATER | E+B | P17 | S6 | B | READY_PROVISIONAL_BALANCE |
| costAmount | AUTHORED_LATER | B | P18 | S3 | B | READY_PROVISIONAL_BALANCE |
| rangeProfile | FIXED | E+U+C | P19 | S5 | C | BLOCKED_CLIENT |
| castTimeProfile | FIXED | E | P20 | S3 | I | READY_STATIC |
| projectileSpeedProfile | FIXED | E | P21 | S3 | I | READY_STATIC |
| damageClassPolicy | UNKNOWN | E | P22 | S4 | I | READY_STATIC |
| hitCritDefensePolicy | UNKNOWN | E+R | P23 | S4 | V | BLOCKED_RUNTIME |
| coefficientPolicy | UNKNOWN | E+B+R | P24 | S9 | V | BLOCKED_RUNTIME |
| magnitude | AUTHORED_LATER | B+R | P25 | S9 | V | BLOCKED_RUNTIME |
| spellFamilyPolicy | FIXED | E | P26 | S10 | I | READY_STATIC |
| familyMasks | FIXED | E | P27 | S10 | I | READY_STATIC |
| effectLayout | FIXED | E | P28 | S3 | I | READY_STATIC |
| attributesPolicy | UNKNOWN | E+C | P29 | S8 | P | BLOCKED_POLICY |
| mechanicPolicy | FIXED | E | P30 | S3 | I | READY_STATIC |
| procEventPolicy | UNKNOWN | E+R | P31 | S10 | V | BLOCKED_RUNTIME |
| equipmentPolicy | FIXED | E | P32 | S8 | I | READY_STATIC |
| stancePolicy | FIXED | E | P33 | S8 | I | READY_STATIC |
| reagentPolicy | FIXED | E | P34 | S3 | I | READY_STATIC |
| cooldownPolicy | AUTHORED_LATER | E+B | P35 | S7 | B | READY_PROVISIONAL_BALANCE |
| categoryPolicy | UNKNOWN | E+U | P36 | S7 | I | READY_STATIC |
| gcdPolicy | AUTHORED_LATER | U+B | P37 | S7 | B | READY_PROVISIONAL_BALANCE |
| visualProfile | UNKNOWN | T+C | P38 | S11 | C | BLOCKED_CLIENT |
| clientRequirements | UNKNOWN | U+C | P39 | S13 | C | BLOCKED_CLIENT |
| compatibilityEnvelope | FIXED | E+U | P40 | S3 | I | READY_STATIC |
| provenance | FIXED | E | P41 | S3 | I | READY_STATIC |
| reviewRecord | FIXED | E | P42 | S2 | I | READY_STATIC |
| nativeRankPolicy | FIXED | E | P43 | S2 | I | READY_STATIC |
| clientTargetFlags | UNKNOWN | E+C | P44 | S5 | C | READY_STATIC |
| selfTargetPolicy | FIXED | E+R | P45 | S5 | V | BLOCKED_RUNTIME |
| deadTargetPolicy | FIXED | E | P46 | S8 | I | READY_STATIC |
| assignedSpellId | UNKNOWN | E | P47 | S13 | N | BLOCKED_NAMESPACE |
| skillLineAbilityProjection | UNKNOWN | U+C | P48 | S12 | C | BLOCKED_CLIENT |
| charges | NOT_APPLICABLE | E | P49 | S7 | I | READY_STATIC |
| channelPolicy | NOT_APPLICABLE | E | P50 | S8 | I | READY_STATIC |
| optionalSoundFallback | UNKNOWN | T+C | P51 | S11 | C | BLOCKED_CLIENT |

### MeleeHealing policy decisions

- P01 (specKey): UlduarCarrier_MeleeHealing
- P02 (schemaVersion): Draft schema 1 retained; no production schema artifact emitted.
- P03 (specVersion): Draft spec 2 in A.8 documentation; unpublished. This does not mutate the A.6 catalog entry
  version.
- P04 (family): MeleeHealing
- P05 (semanticProfileId): HealingMelee
- P06 (semanticProfileVersion): 1 (current source reference)
- P07 (purpose): Healing
- P08 (method): Melee
- P09 (activation): Instant; independent root, no next-swing
- P10 (targeting): Unit
- P11 (targetRelation): Friendly
- P12 (delivery): Direct
- P13 (geometry): Point
- P14 (school): Holy
- P15 (powerType): Mana
- P16 (costPolicy): NativeCarrierCost and exactly one native debit for the fixture. ResolvedResourceCost is deferred.
- P17 (costModel): PROVISIONAL_SLICE1 percentage of native create-Mana; flat/per-level/per-second components zero. Not
  final class-neutral economy.
- P18 (costAmount): PROVISIONAL_SLICE1 7% of base/create-Mana; native CalcPowerCost modifier order and rounding. No
  second Ulduar deduction.
- P19 (rangeProfile): Range2: hostile/friendly min0,max5,flags1; native combat reach/leeway, not fixed
  center-distance5.
- P20 (castTimeProfile): CastTimes1: exact instant base0.
- P21 (projectileSpeedProfile): Speed0; no missile travel.
- P22 (damageClassPolicy): MAGIC=1. Contact geometry does not select MELEE. BASE_ATTACK is internal bookkeeping, no
  weapon payload.
- P23 (hitCritDefensePolicy): Positive Holy heal; native Holy spell crit; no hostile avoidance; facing0. Neutral
  threat0.5*effective gain is not current Paladin behavior.
- P24 (coefficientPolicy): PROVISIONAL_SLICE1 direct SP=0.231, AP/DOT=0; explicit done/taken policy; level penalty1
  fixture. One future Potency input, no double scaling.
- P25 (magnitude): PROVISIONAL_SLICE1 resolved base 46..56. Option-B carrier seed is one unit before required
  replacement; not a native fallback. No per-level/combo scaling.
- P26 (spellFamilyPolicy): SPELLFAMILY_GENERIC=0; no native family enum or class eligibility. This does not isolate
  broad modifiers.
- P27 (familyMasks): Three family mask words zero; all effect class masks zero. Provenance filtering remains separate.
- P28 (effectLayout): One HEAL=10 with TargetA=21 ally, B=0; two absent effects; no triggers, auras, periodic or
  controller riders.
- P29 (attributesPolicy): Named REQUIRED_SET/CLEAR rules in main section16; remaining word bits/client flags
  unresolved. Never copy a native full bitset or assume all zero.
- P30 (mechanicPolicy): Mechanic0, effect mechanics0, no aura/control/dispel/periodic rider.
- P31 (procEventPolicy): Positive magic cast/heal/crit-heal with effective/overheal data. Generic listeners reviewed;
  class talents/passives denied by future provenance boundary. Row proc flags/chance/charges0.
- P32 (equipmentPolicy): EquippedItemClass=-1; subclass/inventory masks0; no ammunition/mainhand/offhand requirement.
- P33 (stancePolicy): Stances/StancesNot0; NOT_SHAPESHIFTED clear; no stance/form entitlement. Verify client/resource
  behavior in forms later.
- P34 (reagentPolicy): Reagent IDs/counts, totems/categories, focus and tool requirements absent/zero.
- P35 (cooldownPolicy): PROVISIONAL_SLICE1 own recovery0; future non-GCD debt belongs to AbilityInstance, not lease.
- P36 (categoryPolicy): Spell Category0 and category recovery0 for current one-slot fixture; one shared native queued
  intent. Six independent queue categories are not promised.
- P37 (gcdPolicy): PROVISIONAL_SLICE1 StartRecoveryCategory133,1500 ms base; ordinary spell haste/mods and native1000
  ms floor. Own recovery0 is not GCD0.
- P38 (visualProfile): SpellVisual135 / SpellIcon682 reference candidates; kit/effect/sound graph recorded; effective
  model/texture/animation closure missing.
- P39 (clientRequirements): Matched build12340 package, supported locales, target/cost/timing/reach and native action
  identity. Effective release package unpinned.
- P40 (compatibilityEnvelope): MeleeHealing_ExactV1: use this record numerical baseline; only one envelope. No
  arbitrary cost/range/cast/school/presentation mutation.
- P41 (provenance): Ulduar-authored A.8 design; native per-field references and hashes explicitly recorded. No
  native/Ascension row clone.
- P42 (reviewRecord): A.8 SOURCE_ONLY audit; no tests, effective-data approval or runtime/client evidence. Custom
  pending status unchanged.
- P43 (nativeRankPolicy): No spell_ranks chain, learn-trigger relation or automatic rank promotion. Each leased copy
  is distinct transport.
- P44 (clientTargetFlags): Propose raw Targets=0 as inspected native rows; effect target supplies ALLY0x100 in
  effective explicit mask. Native packet Unit flag0x2 is separate. No corpse/destination/area flag.
- P45 (selfTargetPolicy): Explicit legal self allowed; no fallback desired. Current InitExplicitTargets can fill
  absent ally target with caster; pre-correction Forge intent boundary missing.
- P46 (deadTargetPolicy): Living units only; no dead/corpse/resurrection targeting; caster cannot cast while dead.
- P47 (assignedSpellId): Absent. NAMESPACE_UNRESOLVED; no numeric interval or individual ID allocated.
- P48 (skillLineAbilityProjection): Prefer visible known-spell fixture without new skill row; server packet/action
  path permits this hypothesis. General tab/drag behavior unproved; optional new mapping only after evidence.
- P49 (charges): NOT_APPLICABLE; no ability charge/recharge feature and no proc aura charges.
- P50 (channelPolicy): NOT_APPLICABLE; independent non-channel root, no channel attributes/ticks.
- P51 (optionalSoundFallback): UNKNOWN until selected visual cues are reviewed. Silence may replace only explicitly
  nonessential cosmetics; no silent fallback for a critical cue.

## RangedHealing

| Field | A.7 | Evidence | Policy | Source | Remaining | Readiness |
| --- | --- | --- | --- | --- | --- | --- |
| specKey | FIXED | E | P01 | S1 | I | READY_STATIC |
| schemaVersion | FIXED | E | P02 | S1 | I | READY_STATIC |
| specVersion | FIXED | E | P03 | S1 | I | READY_STATIC |
| family | FIXED | E | P04 | S1 | I | READY_STATIC |
| semanticProfileId | FIXED | E | P05 | S1 | I | READY_STATIC |
| semanticProfileVersion | FIXED | E | P06 | S1 | I | READY_STATIC |
| purpose | FIXED | E | P07 | S1 | I | READY_STATIC |
| method | FIXED | E | P08 | S1 | I | READY_STATIC |
| activation | FIXED | E | P09 | S1 | I | READY_STATIC |
| targeting | FIXED | E | P10 | S1 | I | READY_STATIC |
| targetRelation | FIXED | E | P11 | S1 | I | READY_STATIC |
| delivery | FIXED | E | P12 | S1 | I | READY_STATIC |
| geometry | FIXED | E | P13 | S1 | I | READY_STATIC |
| school | FIXED | E | P14 | S1 | I | READY_STATIC |
| powerType | FIXED | E | P15 | S1 | I | READY_STATIC |
| costPolicy | FIXED | E | P16 | S6 | I | READY_STATIC |
| costModel | AUTHORED_LATER | E+B | P17 | S6 | B | READY_PROVISIONAL_BALANCE |
| costAmount | AUTHORED_LATER | B | P18 | S3 | B | READY_PROVISIONAL_BALANCE |
| rangeProfile | AUTHORED_LATER | U+B | P19 | S5 | B | READY_PROVISIONAL_BALANCE |
| castTimeProfile | AUTHORED_LATER | U+B | P20 | S3 | B | READY_PROVISIONAL_BALANCE |
| projectileSpeedProfile | FIXED | E | P21 | S3 | I | READY_STATIC |
| damageClassPolicy | UNKNOWN | E | P22 | S4 | I | READY_STATIC |
| hitCritDefensePolicy | UNKNOWN | E+R | P23 | S4 | V | BLOCKED_RUNTIME |
| coefficientPolicy | UNKNOWN | E+B+R | P24 | S9 | V | BLOCKED_RUNTIME |
| magnitude | AUTHORED_LATER | B+R | P25 | S9 | V | BLOCKED_RUNTIME |
| spellFamilyPolicy | FIXED | E | P26 | S10 | I | READY_STATIC |
| familyMasks | FIXED | E | P27 | S10 | I | READY_STATIC |
| effectLayout | FIXED | E | P28 | S3 | I | READY_STATIC |
| attributesPolicy | UNKNOWN | E+C | P29 | S8 | P | BLOCKED_POLICY |
| mechanicPolicy | FIXED | E | P30 | S3 | I | READY_STATIC |
| procEventPolicy | UNKNOWN | E+R | P31 | S10 | V | BLOCKED_RUNTIME |
| equipmentPolicy | FIXED | E | P32 | S8 | I | READY_STATIC |
| stancePolicy | FIXED | E | P33 | S8 | I | READY_STATIC |
| reagentPolicy | FIXED | E | P34 | S3 | I | READY_STATIC |
| cooldownPolicy | AUTHORED_LATER | E+B | P35 | S7 | B | READY_PROVISIONAL_BALANCE |
| categoryPolicy | UNKNOWN | E+U | P36 | S7 | I | READY_STATIC |
| gcdPolicy | AUTHORED_LATER | U+B | P37 | S7 | B | READY_PROVISIONAL_BALANCE |
| visualProfile | REUSE_REFERENCE | T+C | P38 | S11 | C | BLOCKED_CLIENT |
| clientRequirements | UNKNOWN | U+C | P39 | S13 | C | BLOCKED_CLIENT |
| compatibilityEnvelope | FIXED | E+U | P40 | S3 | I | READY_STATIC |
| provenance | FIXED | E | P41 | S3 | I | READY_STATIC |
| reviewRecord | FIXED | E | P42 | S2 | I | READY_STATIC |
| nativeRankPolicy | FIXED | E | P43 | S2 | I | READY_STATIC |
| clientTargetFlags | UNKNOWN | E+C | P44 | S5 | C | READY_STATIC |
| selfTargetPolicy | FIXED | E+R | P45 | S5 | V | BLOCKED_RUNTIME |
| deadTargetPolicy | FIXED | E | P46 | S8 | I | READY_STATIC |
| assignedSpellId | UNKNOWN | E | P47 | S13 | N | BLOCKED_NAMESPACE |
| skillLineAbilityProjection | UNKNOWN | U+C | P48 | S12 | C | BLOCKED_CLIENT |
| charges | NOT_APPLICABLE | E | P49 | S7 | I | READY_STATIC |
| channelPolicy | NOT_APPLICABLE | E | P50 | S8 | I | READY_STATIC |
| optionalSoundFallback | UNKNOWN | T+C | P51 | S11 | C | BLOCKED_CLIENT |

### RangedHealing policy decisions

- P01 (specKey): UlduarCarrier_RangedHealing
- P02 (schemaVersion): Draft schema 1 retained; no production schema artifact emitted.
- P03 (specVersion): Draft spec 2 in A.8 documentation; unpublished. This does not mutate the A.6 catalog entry
  version.
- P04 (family): RangedHealing
- P05 (semanticProfileId): HealingRanged
- P06 (semanticProfileVersion): 1 (current source reference)
- P07 (purpose): Healing
- P08 (method): Ranged
- P09 (activation): CastTime; independent root, no next-swing
- P10 (targeting): Unit
- P11 (targetRelation): Friendly
- P12 (delivery): Direct
- P13 (geometry): Point
- P14 (school): Holy
- P15 (powerType): Mana
- P16 (costPolicy): NativeCarrierCost and exactly one native debit for the fixture. ResolvedResourceCost is deferred.
- P17 (costModel): PROVISIONAL_SLICE1 percentage of native create-Mana; flat/per-level/per-second components zero. Not
  final class-neutral economy.
- P18 (costAmount): PROVISIONAL_SLICE1 29% of base/create-Mana; native CalcPowerCost modifier order and rounding. No
  second Ulduar deduction.
- P19 (rangeProfile): PROVISIONAL_SLICE1 Range5: hostile/friendly min0,max40,flags0; no ranged-weapon dead zone.
- P20 (castTimeProfile): PROVISIONAL_SLICE1 CastTimes20: base2500 ms, per-level0,min2500. Ordinary reviewed native
  haste.
- P21 (projectileSpeedProfile): Speed0; no missile travel.
- P22 (damageClassPolicy): MAGIC=1. Contact geometry does not select MELEE. BASE_ATTACK is internal bookkeeping, no
  weapon payload.
- P23 (hitCritDefensePolicy): Positive Holy heal; native Holy spell crit; no hostile avoidance; facing0. Neutral
  threat0.5*effective gain is not current Paladin behavior.
- P24 (coefficientPolicy): PROVISIONAL_SLICE1 direct SP=0.481, AP/DOT=0; explicit done/taken policy; level penalty1
  fixture. One future Potency input, no double scaling.
- P25 (magnitude): PROVISIONAL_SLICE1 resolved base 50..60. Option-B carrier seed is one unit before required
  replacement; not a native fallback. No per-level/combo scaling.
- P26 (spellFamilyPolicy): SPELLFAMILY_GENERIC=0; no native family enum or class eligibility. This does not isolate
  broad modifiers.
- P27 (familyMasks): Three family mask words zero; all effect class masks zero. Provenance filtering remains separate.
- P28 (effectLayout): One HEAL=10 with TargetA=21 ally, B=0; two absent effects; no triggers, auras, periodic or
  controller riders.
- P29 (attributesPolicy): Named REQUIRED_SET/CLEAR rules in main section16; remaining word bits/client flags
  unresolved. Never copy a native full bitset or assume all zero.
- P30 (mechanicPolicy): Mechanic0, effect mechanics0, no aura/control/dispel/periodic rider.
- P31 (procEventPolicy): Positive magic cast/heal/crit-heal with effective/overheal data. Generic listeners reviewed;
  class talents/passives denied by future provenance boundary. Row proc flags/chance/charges0.
- P32 (equipmentPolicy): EquippedItemClass=-1; subclass/inventory masks0; no ammunition/mainhand/offhand requirement.
- P33 (stancePolicy): Stances/StancesNot0; NOT_SHAPESHIFTED clear; no stance/form entitlement. Verify client/resource
  behavior in forms later.
- P34 (reagentPolicy): Reagent IDs/counts, totems/categories, focus and tool requirements absent/zero.
- P35 (cooldownPolicy): PROVISIONAL_SLICE1 own recovery0; future non-GCD debt belongs to AbilityInstance, not lease.
- P36 (categoryPolicy): Spell Category0 and category recovery0 for current one-slot fixture; one shared native queued
  intent. Six independent queue categories are not promised.
- P37 (gcdPolicy): PROVISIONAL_SLICE1 StartRecoveryCategory133,1500 ms base; ordinary spell haste/mods and native1000
  ms floor. Own recovery0 is not GCD0.
- P38 (visualProfile): SpellVisual2936 / SpellIcon70 reference candidates; kit/effect/sound graph recorded; effective
  model/texture/animation closure missing.
- P39 (clientRequirements): Matched build12340 package, supported locales, target/cost/timing/reach and native action
  identity. Effective release package unpinned.
- P40 (compatibilityEnvelope): RangedHealing_ExactV1: use this record numerical baseline; only one envelope. No
  arbitrary cost/range/cast/school/presentation mutation.
- P41 (provenance): Ulduar-authored A.8 design; native per-field references and hashes explicitly recorded. No
  native/Ascension row clone.
- P42 (reviewRecord): A.8 SOURCE_ONLY audit; no tests, effective-data approval or runtime/client evidence. Custom
  pending status unchanged.
- P43 (nativeRankPolicy): No spell_ranks chain, learn-trigger relation or automatic rank promotion. Each leased copy
  is distinct transport.
- P44 (clientTargetFlags): Propose raw Targets=0 as inspected native rows; effect target supplies ALLY0x100 in
  effective explicit mask. Native packet Unit flag0x2 is separate. No corpse/destination/area flag.
- P45 (selfTargetPolicy): Explicit legal self allowed; no fallback desired. Current InitExplicitTargets can fill
  absent ally target with caster; pre-correction Forge intent boundary missing.
- P46 (deadTargetPolicy): Living units only; no dead/corpse/resurrection targeting; caster cannot cast while dead.
- P47 (assignedSpellId): Absent. NAMESPACE_UNRESOLVED; no numeric interval or individual ID allocated.
- P48 (skillLineAbilityProjection): Prefer visible known-spell fixture without new skill row; server packet/action
  path permits this hypothesis. General tab/drag behavior unproved; optional new mapping only after evidence.
- P49 (charges): NOT_APPLICABLE; no ability charge/recharge feature and no proc aura charges.
- P50 (channelPolicy): NOT_APPLICABLE; independent non-channel root, no channel attributes/ticks.
- P51 (optionalSoundFallback): UNKNOWN until selected visual cues are reviewed. Silence may replace only explicitly
  nonessential cosmetics; no silent fallback for a critical cue.

## Additional effective-data gates not separate A.7 fields

Fields such as interrupt flags, PreventionType, level/base/max levels, raw coefficient encoding and native
threat/class/resource paths are covered by the parent policy fields above and sections 10..18 of the main report.
The desired explicit-target healing policy conflicts with a native missing-target correction path; it is not
silently promoted because TargetA=ALLY. Class-dependent healing threat and create-Mana basis remain visible gates.
No record is ARTIFACT_READY even if some fields are READY_STATIC or READY_PROVISIONAL_BALANCE.
