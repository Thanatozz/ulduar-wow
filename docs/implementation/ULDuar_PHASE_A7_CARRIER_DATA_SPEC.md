# ULDuar Phase A.7 — Carrier Namespace and Canonical Data Specification

Date: 2026-09-19. PHASE_A7_STATUS: COMPLETE for source/data-spec review.
NAMESPACE_STATUS: UNRESOLVED / NAMESPACE_UNRESOLVED. No numeric interval is reserved.
Evidence: SOURCE_ONLY. Existing tests: 39 AUTHORED_NOT_RUN; zero tests executed in this phase.

## 1. Executive summary

HYBRID remains the strategy. This review fixes the design contracts and explicit gates needed before custom carrier
artifacts can be authored. It creates no usable carrier, C++ feature, SQL, DBC, generator or client package.
All four canonical records below classify every required field; unknown technical decisions and unauthored balance
values remain visible blockers, not fabricated defaults. A complete design review does not mean data is ready to emit.

Namespace evidence includes two identical extracted/build DBC sets, a differing spell-editor set, existing custom
visual artifacts and server-only SQL Spell rows above the raw DBC maximum. No complete effective client/server
inventory or existing release-aware allocation ledger proves a collision-safe interval. Therefore no ID is assigned.

Slice-1 policy selects one exact native base timing/range/cost profile per family, matched on both sides. Native
modifiers require explicit interaction review. Broader server-only envelopes remain diagnostic-prototype proposals.
Future cooldown debt belongs to the AbilityInstance. Used carrier IDs cannot be reassigned to another identity
during the same transport session under the conservative V1 policy; quarantine is event-based, not time-based.

Holy Light 635 is SOURCE_COMPATIBLE, NATIVE_EXCEPTION, NOT CLASS_NEUTRAL, with role REPLACE_WHEN_CUSTOM_READY.
1495, 31759 and 34232 remain research-only. No allowlist or catalog entry changed.

## 2. A.6 state carried forward

Read alongside the [A.6 report](ULDuar_PHASE_A6_CUSTOM_CARRIERS.md),
[A.5 source review](ULDuar_PHASE_A5_SOURCE_REVIEW.md) and [Phase A report](ULDuar_PHASE_A_IMPLEMENTATION_REPORT.md).
The Forge, ability metadata, taxonomy, resolution pipeline, generic stats and vertical-slice documents remain
unchanged. They establish stable instance identity, explicit source provenance and immutable cast snapshots;
they do not establish that all proposed resource/coverage/client adapters already exist.

Source inspection covered CarrierCatalog, CarrierContract, CarrierRegistry, AbilityInstance and manager registration/
dispatch. Catalog version 1 still contains 635 and four custom placeholders without SpellIDs. PendingData rejects
both allocation and exact registration. RuntimeEligible is reserved and also rejects in current code. Catalog
family/profile/version stamps, ownership, generation and revision guards remain. One active slot remains enforced.

No clear inconsistency between the A.6 code and its documented prototype contract required a C++ correction.
Its lack of cooldown/queue/quarantine authority is an explicitly deferred feature, not a claim of safe live swaps.
RegisterBinding/RemoveBinding are bookkeeping seams, not safe player-facing lifecycle operations. In particular,
RemoveBinding erases a projection, so later requests return None; that cannot implement the future quarantine gate
described in section 13. Do not expose it as a live custom-carrier deactivate/swap operation without that gate.

The 39 tests were counted/reviewed as source only; none were added, compiled or run. Manager-to-native dispatch,
positive targeting, real client restrictions and native aura/proc behavior still require separate evidence.
Current Impact and legacy ResolvePropagationStats remain unchanged; the A.5 Coverage bridge is still design only.

## 3. Namespace inventory

Full observations, fingerprints and audit scope are in
[ULDuar_CUSTOM_ID_NAMESPACE.md](../architecture/ULDuar_CUSTOM_ID_NAMESPACE.md).

| Namespace | Observed USED evidence | RESERVED | UNKNOWN |
| --- | --- | --- | --- |
| Spell | 49,839 raw rows + 4,491 disjoint base SQL IDs | No Ulduar reservation proved | Effective DB/MPQ and releases |
| SpellRange | 64 raw WotLK IDs, max 187 | None proved | Live overrides/client overlays |
| SpellCastTimes | 70 raw WotLK IDs, max 209 | None proved | Live overrides/client overlays |
| SpellVisual | 9,406 base; custom 16680..16684 and 17000 | Local outputs, no shared reservation | Packed dependencies |
| SpellIcon | 3,226 raw IDs, max 4375 | None proved | Effective client package |
| SkillLineAbility | 10,219 raw IDs, max 21980 | None proved | Effective skill-line projection |

Raw Spell IDs reach 80864; base SQL also uses 100001, 100099, 100100, 100101 and 100102. Min/max are not free-space
proofs. Editor visual 17000 is occupied even though no Spell row in that editor copy references it. M2 outputs
16680..16684 have recorded element/model dependencies. All must be reconciled with supported packages.

Search included module/pending SQL, five module directories, script references, addon spell metadata and editor
artifacts. Item/creature/string/visual keys are distinct namespaces; mount/item spell references must join the Spell
occupancy set. Active client MPQ contents, effective DB rows and installed custom content were not observed live.
Old Vanilla/TBC editor inputs and Ascension reference assets cannot certify a WotLK Ulduar interval.

## 4. Reserved-ID policy

Adopt the companion namespace policy: append-only typed allocation events, serialized across module owners, with
allocation date, owner, purpose/spec/envelope/copy, introduced/retired release, compatibility state, provenance and
hashed collision-audit inputs. Never compute max(ID)+1. Correct ledger errors by new events, not rewriting history.
No reuse while supported/rollback releases or retained projections can reference an ID; default is never recycle
introduced IDs. Retirement does not erase occupancy. Native dependency reuse does not allocate or mutate that row.

Only a complete effective-data collision audit can move a symbolic request to numeric RESERVED. This phase records
no production allocation and proposes no supposedly safe high-number block. A later artifact phase is blocked from
emitting carrier rows until that audit and the required spec decisions are resolved.

## 5. Capacity analysis

Let N=6 active slots, F=4 families, E_f the count of client-distinct reviewed envelope variants in family f.
Let M_(f,e) be the maximum simultaneous demand for a variant under the actual allowed loadouts.
For disjoint pools the required capacity is sum(M_(f,e)); if all slots may choose every variant, it is
N * sum(E_f). Copies are global data rows reused across owners, not IDs per owned or inactive AbilityInstance.

| Strategy | Minimum for the stated four fixed profiles | Worst case / limitation |
| --- | --- | --- |
| A: six copies per family | 24 IDs, at most six leased per owner | Cannot represent additional incompatible variants |
| B: family + envelope pools | 24 when each E_f=1 | 6 * sum(E_f); unbounded if variants are unconstrained |
| C: slot-specific | Six only if each slot has a permanently fixed profile | Free family choice needs 6 * sum(E_f) |
| D: compatible mixed pools | 24 for four incompatible fixed profiles | Capacity follows compatible variant demand |

Six is the lower bound for one fixed six-slot loadout; it is not enough to offer every combination of all four
incompatible families. With the current single active slot, four eventual custom rows can cover the four branches,
only one leased per player. Neither four nor 24 is an allocation in this phase.

Envelope combinations form equivalence classes only when every exact dimension agrees and the same reviewed
override policy serves them. For a hypothetical variant set with two ranged cast times, two ranged distances,
three cost profiles for every family, one melee presentation and two ranged presentations, the counts are
E_MD=3, E_MH=3, E_RPD=24, E_RH=24: unrestricted six-slot demand would require 324 IDs. This is a capacity example,
not selected balance or a catalog proposal. Unrestricted numerical/visual variation has no finite worst-case count.

Projectile/non-projectile, target relation and activation differences cannot share a shell. Independent native
cooldowns usually need unique active SpellIDs, already supplied by copies; intentional shared categories/GCD are
separate. Distinct category/cost/timing/visual dependencies may increase envelope counts. Native ranks must not
stand in for independent copies. In a mixed pool, every allowed loadout must have a complete unique-carrier
assignment; a greedy policy needs capacity proof for overlaps, otherwise keep disjoint family/envelope pools.

Quarantined used IDs consume session capacity even while inactive. Arbitrarily many same-session loadout changes
have no finite ID bound under V1 quarantine. Do not promise that 24 supports unlimited swaps: reject exhaustion or
use the later reconnect/reconciliation workflow. Same-owner sharing and silent semantic fallback remain forbidden.

## 6. CanonicalCarrierSpec required fields

The canonical spec is the sole future authoring source for both client and server representations. C++ catalog
entries reference it; SQL/DBC layouts are export targets. Required fields can carry an explicit unresolved status
in a draft, but an artifact-ready record cannot retain unknown required execution/presentation values.

REQUIRED_FOR_V1 means explicit, versioned presence. OPTIONAL_FOR_V1 means omission has a specified harmless meaning.
DEFERRED means no executable V1 encoding. FORBIDDEN_TO_INFER means an explicit reviewed decision is mandatory:
never fill it from family, spell name, class, a guessed default or neighboring ID. It is not permission to omit it.

| Field | Classification | Required rule |
| --- | --- | --- |
| specKey | REQUIRED_FOR_V1 | Stable symbolic identity, not SpellID |
| schemaVersion | REQUIRED_FOR_V1 | Typed schema/serialization contract |
| specVersion | REQUIRED_FOR_V1 | Immutable content revision |
| family | REQUIRED_FOR_V1 | One of four exact semantic transport families |
| semanticProfileId / semanticProfileVersion | REQUIRED_FOR_V1 | Resolve existing profile explicitly |
| purpose | REQUIRED_FOR_V1 | Damage or Healing; cross-check profile |
| activation | REQUIRED_FOR_V1 | Instant or CastTime; no hidden next-swing |
| targeting | REQUIRED_FOR_V1 | Unit |
| targetRelation | REQUIRED_FOR_V1 | Enemy or Friendly; self/dead policy explicit |
| delivery | REQUIRED_FOR_V1 | Direct or Projectile |
| geometry | REQUIRED_FOR_V1 | Point root; coverage separate |
| school | REQUIRED_FOR_V1 | Native/client/server agreement |
| powerType | REQUIRED_FOR_V1 | Mana; no class resource substitution |
| costPolicy | REQUIRED_FOR_V1 | Native-authoritative V1; explicit cost basis |
| rangeProfile | REQUIRED_FOR_V1 | Relation-specific min/max and reach policy |
| castTimeProfile | REQUIRED_FOR_V1 | Native base time and allowed native modifiers |
| projectileSpeedProfile | REQUIRED_FOR_V1 | Positive speed or explicit direct/no-travel |
| damageClassPolicy | FORBIDDEN_TO_INFER | Contact/Physical does not imply native melee defense |
| hitCritDefensePolicy | FORBIDDEN_TO_INFER | Explicit miss/crit/mitigation/reflect/block/dodge/parry policy |
| coefficientPolicy | FORBIDDEN_TO_INFER | Explicit bonus stages and base-point convention |
| spellFamilyPolicy | REQUIRED_FOR_V1 | Generic default with contamination review |
| familyMasks | REQUIRED_FOR_V1 | Three explicit zero words, including effect class masks review |
| effectLayout | REQUIRED_FOR_V1 | One payload, no extra native rider/trigger |
| attributesPolicy | FORBIDDEN_TO_INFER | Reviewed complete bit policy; no blind clone or zero-all |
| mechanicPolicy | REQUIRED_FOR_V1 | No implicit control/mechanic rider |
| procEventPolicy | FORBIDDEN_TO_INFER | Allowed events/listeners, native-origin deny policy |
| equipmentPolicy | REQUIRED_FOR_V1 | No required weapon/equipment for these shells |
| stancePolicy | REQUIRED_FOR_V1 | No masks or attribute-imposed form/stance requirement |
| reagentPolicy | REQUIRED_FOR_V1 | Explicit none for reagents/tools/totems/focus |
| cooldownPolicy | REQUIRED_FOR_V1 | Own debt/projection and authored native base cooldown |
| categoryPolicy | REQUIRED_FOR_V1 | No implicit class category; queue consequences reviewed |
| gcdPolicy | REQUIRED_FOR_V1 | Separate reviewed common recovery model |
| visualProfile | REQUIRED_FOR_V1 | Predictable cast/missile/impact/icon dependency closure |
| clientRequirements | REQUIRED_FOR_V1 | Build/package, targets, restrictions, spellbook/action behavior |
| compatibilityEnvelope | REQUIRED_FOR_V1 | Versioned exact dimensions and permitted variations |
| provenance | REQUIRED_FOR_V1 | Authored vs referenced data and immutable source hashes |
| reviewRecord | REQUIRED_FOR_V1 | Scope, reviewer, input versions, unresolved issues, evidence level |
| nativeRankPolicy | REQUIRED_FOR_V1 | No rank chain for custom pool copies |
| targetFlags / self / deadTarget policy | FORBIDDEN_TO_INFER | Match explicit relation and native client targeting |
| magnitude / native cost amount | FORBIDDEN_TO_INFER | Authored later; absence is not zero |
| optional cosmetic sound fallback | OPTIONAL_FOR_V1 | Silence only if explicitly approved as nonessential |
| localization notes / author comments | OPTIONAL_FOR_V1 | Omission cannot alter semantics |
| SkillLineAbility projection | OPTIONAL_FOR_V1 | Use only if required by reviewed spellbook presentation |
| charges / generalized talents / per-instance cosmetics | DEFERRED | No V1 gameplay/export extension |
| assigned production SpellID | FORBIDDEN_TO_INFER | Separate ledger mapping after collision approval |

Every draft value has status, typed value or explicit absence, unit, sourceKind/sourceRef, confidence and review
revision, consistent with AbilityMetadata. No NaN, infinity, implicit enum ordinals, unknown-bit coercion or
silent unit conversion. Use canonical field ordering and normalized numeric encoding for hashes. Unknown is
distinct from zero, empty set and NOT_APPLICABLE. Conflicting profile/spec values reject authoring.

## 7. Four Slice-1 canonical specs

These are complete design records, not production JSON/YAML. FIXED is a design constraint; AUTHORED_LATER is an
intentional balance/content decision; REUSE_REFERENCE is a candidate requiring dependency review; UNKNOWN is an
unresolved technical choice; NOT_APPLICABLE is an explicit absence. Unknown required fields block later emission.
Schema/spec revision 1 below is a proposed document revision, not an allocated or published content release.

### MeleeDamage

```text
specKey: FIXED UlduarCarrier_MeleeDamage
schemaVersion: FIXED draft schema 1
specVersion: FIXED draft spec 1; unpublished
family: FIXED MeleeDamage
semanticProfileId: FIXED DamageMelee
semanticProfileVersion: FIXED 1 (current source reference)
purpose: FIXED Damage
method: FIXED Melee
activation: FIXED Instant; independent root, no next-swing
targeting: FIXED Unit
targetRelation: FIXED Enemy
delivery: FIXED Direct
geometry: FIXED Point
school: FIXED Physical
powerType: FIXED Mana
costPolicy: FIXED NativeCarrierCost authority for V1; one native debit
costModel: AUTHORED_LATER flat or percentage-of-base-Mana; no inferred formula
costAmount: AUTHORED_LATER explicit amount and rounding; absence is not zero
rangeProfile: FIXED ContactReach semantic policy; native reach mapping UNKNOWN
castTimeProfile: FIXED Instant native base time zero
projectileSpeedProfile: FIXED zero native speed / no projectile travel
damageClassPolicy: UNKNOWN native defense class must be selected explicitly
hitCritDefensePolicy: UNKNOWN reviewed hit/crit/mitigation/proc path required
coefficientPolicy: UNKNOWN reviewed scaling stages/level rules required
magnitude: AUTHORED_LATER base amount/coefficient; no final balance here
spellFamilyPolicy: FIXED Generic; no new native family enum
familyMasks: FIXED zero three-word family masks; effect class masks zero
effectLayout: FIXED one SCHOOL_DAMAGE payload, enemy target A, no B, no extra effects
attributesPolicy: UNKNOWN full bitset; no next-swing/form/equipment/class coupling
mechanicPolicy: FIXED no mechanic/control/periodic/controller rider
procEventPolicy: UNKNOWN exact event masks/listeners; section 14 origin policy mandatory
equipmentPolicy: FIXED no required weapon, item class, subclass or inventory slot
stancePolicy: FIXED no required/excluded forms; no NOT_SHAPESHIFTED restriction
reagentPolicy: FIXED none: reagents, tools, totems, focus and category requirements
cooldownPolicy: AUTHORED_LATER native duration; instance debt/projection invariant fixed
categoryPolicy: UNKNOWN explicit queue/recovery category; no class-category borrowing
gcdPolicy: AUTHORED_LATER common reviewed native recovery policy and duration
visualProfile: UNKNOWN reviewed contact cast/impact/icon presentation required
clientRequirements: UNKNOWN effective package; fixed target/timing/cost/reach agreement required
compatibilityEnvelope: FIXED MeleeDamage_ExactV1 design; numeric bounds AUTHORED_LATER
provenance: FIXED Ulduar-authored A.7 design + existing profile v1; references identified
reviewRecord: FIXED A.7 SOURCE_ONLY design review; effective-data/runtime approval absent
nativeRankPolicy: FIXED no rank chain; copies are independent action IDs
clientTargetFlags: UNKNOWN explicit raw flags matching Unit and relation; no inferred bitset
selfTargetPolicy: FIXED no self fallback; explicit enemy legality
deadTargetPolicy: FIXED living units only; no corpse/resurrection target
assignedSpellId: UNKNOWN absent; NAMESPACE_UNRESOLVED
skillLineAbilityProjection: UNKNOWN conditional presentation need; never entitlement authority
charges: NOT_APPLICABLE V1 has no charge/recharge feature
channelPolicy: NOT_APPLICABLE non-channel root
optionalSoundFallback: UNKNOWN may be silence only after explicit nonessential-cosmetic review
```

### RangedProjectileDamage

```text
specKey: FIXED UlduarCarrier_RangedProjectileDamage
schemaVersion: FIXED draft schema 1
specVersion: FIXED draft spec 1; unpublished
family: FIXED RangedProjectileDamage
semanticProfileId: FIXED DamageRanged
semanticProfileVersion: FIXED 1 (current source reference)
purpose: FIXED Damage
method: FIXED Ranged
activation: FIXED CastTime; independent root, no next-swing
targeting: FIXED Unit
targetRelation: FIXED Enemy
delivery: FIXED Projectile
geometry: FIXED Point
school: FIXED Holy
powerType: FIXED Mana
costPolicy: FIXED NativeCarrierCost authority for V1; one native debit
costModel: AUTHORED_LATER flat or percentage-of-base-Mana; no inferred formula
costAmount: AUTHORED_LATER explicit amount and rounding; absence is not zero
rangeProfile: AUTHORED_LATER exact min/max; no hidden contact or melee dead zone
castTimeProfile: AUTHORED_LATER one positive exact native base time
projectileSpeedProfile: AUTHORED_LATER positive synchronized native speed
damageClassPolicy: UNKNOWN native defense class must be selected explicitly
hitCritDefensePolicy: UNKNOWN reviewed hit/crit/mitigation/proc path required
coefficientPolicy: UNKNOWN reviewed scaling stages/level rules required
magnitude: AUTHORED_LATER base amount/coefficient; no final balance here
spellFamilyPolicy: FIXED Generic; no new native family enum
familyMasks: FIXED zero three-word family masks; effect class masks zero
effectLayout: FIXED one SCHOOL_DAMAGE payload, enemy target A, no B, no extra effects
attributesPolicy: UNKNOWN full bitset; no next-swing/form/equipment/class coupling
mechanicPolicy: FIXED no mechanic/control/periodic/controller rider
procEventPolicy: UNKNOWN exact event masks/listeners; section 14 origin policy mandatory
equipmentPolicy: FIXED no required weapon, item class, subclass or inventory slot
stancePolicy: FIXED no required/excluded forms; no NOT_SHAPESHIFTED restriction
reagentPolicy: FIXED none: reagents, tools, totems, focus and category requirements
cooldownPolicy: AUTHORED_LATER native duration; instance debt/projection invariant fixed
categoryPolicy: UNKNOWN explicit queue/recovery category; no class-category borrowing
gcdPolicy: AUTHORED_LATER common reviewed native recovery policy and duration
visualProfile: REUSE_REFERENCE SpellVisual 7873 candidate; dependency/package review pending
clientRequirements: UNKNOWN effective package; fixed target/timing/cost/reach agreement required
compatibilityEnvelope: FIXED RangedProjectileDamage_ExactV1 design; numeric bounds AUTHORED_LATER
provenance: FIXED Ulduar-authored A.7 design + existing profile v1; references identified
reviewRecord: FIXED A.7 SOURCE_ONLY design review; effective-data/runtime approval absent
nativeRankPolicy: FIXED no rank chain; copies are independent action IDs
clientTargetFlags: UNKNOWN explicit raw flags matching Unit and relation; no inferred bitset
selfTargetPolicy: FIXED no self fallback; explicit enemy legality
deadTargetPolicy: FIXED living units only; no corpse/resurrection target
assignedSpellId: UNKNOWN absent; NAMESPACE_UNRESOLVED
skillLineAbilityProjection: UNKNOWN conditional presentation need; never entitlement authority
charges: NOT_APPLICABLE V1 has no charge/recharge feature
channelPolicy: NOT_APPLICABLE non-channel root
optionalSoundFallback: UNKNOWN may be silence only after explicit nonessential-cosmetic review
```

### MeleeHealing

```text
specKey: FIXED UlduarCarrier_MeleeHealing
schemaVersion: FIXED draft schema 1
specVersion: FIXED draft spec 1; unpublished
family: FIXED MeleeHealing
semanticProfileId: FIXED HealingMelee
semanticProfileVersion: FIXED 1 (current source reference)
purpose: FIXED Healing
method: FIXED Melee
activation: FIXED Instant; independent root, no next-swing
targeting: FIXED Unit
targetRelation: FIXED Friendly
delivery: FIXED Direct
geometry: FIXED Point
school: FIXED Holy
powerType: FIXED Mana
costPolicy: FIXED NativeCarrierCost authority for V1; one native debit
costModel: AUTHORED_LATER flat or percentage-of-base-Mana; no inferred formula
costAmount: AUTHORED_LATER explicit amount and rounding; absence is not zero
rangeProfile: FIXED ContactReach semantic policy; native reach mapping UNKNOWN
castTimeProfile: FIXED Instant native base time zero
projectileSpeedProfile: FIXED zero native speed / no projectile travel
damageClassPolicy: UNKNOWN native defense class must be selected explicitly
hitCritDefensePolicy: UNKNOWN reviewed hit/crit/mitigation/proc path required
coefficientPolicy: UNKNOWN reviewed scaling stages/level rules required
magnitude: AUTHORED_LATER base amount/coefficient; no final balance here
spellFamilyPolicy: FIXED Generic; no new native family enum
familyMasks: FIXED zero three-word family masks; effect class masks zero
effectLayout: FIXED one HEAL payload, ally target A, no B, no extra effects
attributesPolicy: UNKNOWN full bitset; no next-swing/form/equipment/class coupling
mechanicPolicy: FIXED no mechanic/control/periodic/controller rider
procEventPolicy: UNKNOWN exact event masks/listeners; section 14 origin policy mandatory
equipmentPolicy: FIXED no required weapon, item class, subclass or inventory slot
stancePolicy: FIXED no required/excluded forms; no NOT_SHAPESHIFTED restriction
reagentPolicy: FIXED none: reagents, tools, totems, focus and category requirements
cooldownPolicy: AUTHORED_LATER native duration; instance debt/projection invariant fixed
categoryPolicy: UNKNOWN explicit queue/recovery category; no class-category borrowing
gcdPolicy: AUTHORED_LATER common reviewed native recovery policy and duration
visualProfile: UNKNOWN reviewed contact cast/impact/icon presentation required
clientRequirements: UNKNOWN effective package; fixed target/timing/cost/reach agreement required
compatibilityEnvelope: FIXED MeleeHealing_ExactV1 design; numeric bounds AUTHORED_LATER
provenance: FIXED Ulduar-authored A.7 design + existing profile v1; references identified
reviewRecord: FIXED A.7 SOURCE_ONLY design review; effective-data/runtime approval absent
nativeRankPolicy: FIXED no rank chain; copies are independent action IDs
clientTargetFlags: UNKNOWN explicit raw flags matching Unit and relation; no inferred bitset
selfTargetPolicy: FIXED explicit legal self target allowed; no server fallback
deadTargetPolicy: FIXED living units only; no corpse/resurrection target
assignedSpellId: UNKNOWN absent; NAMESPACE_UNRESOLVED
skillLineAbilityProjection: UNKNOWN conditional presentation need; never entitlement authority
charges: NOT_APPLICABLE V1 has no charge/recharge feature
channelPolicy: NOT_APPLICABLE non-channel root
optionalSoundFallback: UNKNOWN may be silence only after explicit nonessential-cosmetic review
```

### RangedHealing

```text
specKey: FIXED UlduarCarrier_RangedHealing
schemaVersion: FIXED draft schema 1
specVersion: FIXED draft spec 1; unpublished
family: FIXED RangedHealing
semanticProfileId: FIXED HealingRanged
semanticProfileVersion: FIXED 1 (current source reference)
purpose: FIXED Healing
method: FIXED Ranged
activation: FIXED CastTime; independent root, no next-swing
targeting: FIXED Unit
targetRelation: FIXED Friendly
delivery: FIXED Direct
geometry: FIXED Point
school: FIXED Holy
powerType: FIXED Mana
costPolicy: FIXED NativeCarrierCost authority for V1; one native debit
costModel: AUTHORED_LATER flat or percentage-of-base-Mana; no inferred formula
costAmount: AUTHORED_LATER explicit amount and rounding; absence is not zero
rangeProfile: AUTHORED_LATER exact min/max; no hidden contact or melee dead zone
castTimeProfile: AUTHORED_LATER one positive exact native base time
projectileSpeedProfile: FIXED zero native speed / no projectile travel
damageClassPolicy: UNKNOWN native defense class must be selected explicitly
hitCritDefensePolicy: UNKNOWN reviewed hit/crit/mitigation/proc path required
coefficientPolicy: UNKNOWN reviewed scaling stages/level rules required
magnitude: AUTHORED_LATER base amount/coefficient; no final balance here
spellFamilyPolicy: FIXED Generic; no new native family enum
familyMasks: FIXED zero three-word family masks; effect class masks zero
effectLayout: FIXED one HEAL payload, ally target A, no B, no extra effects
attributesPolicy: UNKNOWN full bitset; no next-swing/form/equipment/class coupling
mechanicPolicy: FIXED no mechanic/control/periodic/controller rider
procEventPolicy: UNKNOWN exact event masks/listeners; section 14 origin policy mandatory
equipmentPolicy: FIXED no required weapon, item class, subclass or inventory slot
stancePolicy: FIXED no required/excluded forms; no NOT_SHAPESHIFTED restriction
reagentPolicy: FIXED none: reagents, tools, totems, focus and category requirements
cooldownPolicy: AUTHORED_LATER native duration; instance debt/projection invariant fixed
categoryPolicy: UNKNOWN explicit queue/recovery category; no class-category borrowing
gcdPolicy: AUTHORED_LATER common reviewed native recovery policy and duration
visualProfile: REUSE_REFERENCE SpellVisual 2936 candidate; dependency/package review pending
clientRequirements: UNKNOWN effective package; fixed target/timing/cost/reach agreement required
compatibilityEnvelope: FIXED RangedHealing_ExactV1 design; numeric bounds AUTHORED_LATER
provenance: FIXED Ulduar-authored A.7 design + existing profile v1; references identified
reviewRecord: FIXED A.7 SOURCE_ONLY design review; effective-data/runtime approval absent
nativeRankPolicy: FIXED no rank chain; copies are independent action IDs
clientTargetFlags: UNKNOWN explicit raw flags matching Unit and relation; no inferred bitset
selfTargetPolicy: FIXED explicit legal self target allowed; no server fallback
deadTargetPolicy: FIXED living units only; no corpse/resurrection target
assignedSpellId: UNKNOWN absent; NAMESPACE_UNRESOLVED
skillLineAbilityProjection: UNKNOWN conditional presentation need; never entitlement authority
charges: NOT_APPLICABLE V1 has no charge/recharge feature
channelPolicy: NOT_APPLICABLE non-channel root
optionalSoundFallback: UNKNOWN may be silence only after explicit nonessential-cosmetic review
```

All records include the exact profile's Mana/native-cost contract without choosing a flat/percentage amount.
Generic/zero masks means no intended class-family dependency, not immunity to broader effects. Full native bit,
defense and coefficient policies must be settled explicitly before data authoring. Reusing a visual never imports
the source spell's family, costs, scripts, ranks or native acquisition identity. No Impact state enters these specs.

## 8. Compatibility envelopes

CarrierCompatibilityEnvelope identifies an immutable set of semantic/client assumptions, allowed numeric domains,
units, native modifier policy, UI discrepancy policy, adapter version and evidence references. A shell can serve
multiple instances only when each fits that envelope; an instance fit does not let two active slots share one ID.

| Dimension | V1 classification | Future exception boundary |
| --- | --- | --- |
| Target relation / Unit flags / self / dead targets | EXACT_MATCH | A different policy REQUIRES_DISTINCT_CARRIER |
| Activation kind | EXACT_MATCH | Instant/CastTime/Channel conversion UNSUPPORTED now |
| Delivery / geometry | EXACT_MATCH | Direct/projectile/area change REQUIRES_DISTINCT_CARRIER |
| Range min/max and reach | EXACT_MATCH | SERVER_MAY_RESTRICT only in authorized diagnostic prototype |
| Cast-time base | EXACT_MATCH | SERVER_MAY_OVERRIDE_WITH_UI_MISMATCH only as diagnostic prototype |
| Projectile speed | EXACT_MATCH | No reviewed arbitrary root speed override; different speed needs profile |
| School | EXACT_MATCH | Cross-school primary conversion is outside custom V1 |
| Power type | EXACT_MATCH | Non-Mana is UNSUPPORTED in V1 |
| Cost model/base amount | EXACT_MATCH | Native understood modifiers only; custom amounts need profiles |
| GCD model / own cooldown / category | EXACT_MATCH | Instance-debt projection requires later reviewed authority |
| Visual dependency set | EXACT_MATCH | Incompatible missile/presentation REQUIRES_DISTINCT_CARRIER |
| Optional contextual legality | SERVER_MAY_RESTRICT | LOS/immunity/phase/etc remain normal native rejection rules |

SERVER_MAY_RESTRICT does not authorize a Ulduar root range validator that does not exist. Server-only school
override is not client school/visual correctness. A shell's effective native semantics and client metadata must agree;
the allowed variation set is not a bag of unchecked arbitrary runtime values. Envelope changes version the spec,
catalog entry and affected manifest mapping. Compatibility is never inferred from equal numerical SpellIDs.

## 9. Range policy

For custom numerical range, client max greater than resolved max is permitted only in a separately authorized,
explicitly labeled diagnostic prototype with an implemented root validator. The UI mismatch must be displayed and
measured. It is not permitted for production Slice 1. Current A.6 has no general primary-range override.

Production requires matched authored relation-sensitive min/max, native reach flags and reviewed native range
modifiers. Client 40 / server 25 is a potentially conservative server rule but misleading local availability.
Client 25 / server 40 is never an acceptable envelope: the client can block the requested action before the server.
Changing max alone cannot repair minimum range, combat reach or target relation.

| Case | Rule |
| --- | --- |
| Client min less than resolved min | Diagnostic-only restriction; production must match dead-zone feedback |
| Client min greater than resolved min | Reject the envelope; local client can exclude intended legal targets |
| Melee/contact | Match reach flag and core reach/leeway algorithm; do not equate to center distance 5 yd |
| Friendly contact heal | Dedicated matched contact row; no 40-yard native heal masquerading as contact |
| Dead targets | V1 living targets only; a corpse/resurrection policy needs a distinct reviewed profile |
| Self targeting | Healing permits explicit self if native assist checks allow; damage never retargets self |
| Self-cast fallback | Do not add a server fallback from invalid target; native client auto-self behavior needs review |

Source: Spell::CheckRange around Spell.cpp:7219 uses native range/reach, relation and spellmods; a triggered target
validator is not a root override. SpellInfo::CheckTarget/CheckExplicitTarget checks target restrictions beyond
distance. Client auto-self-cast settings may produce an explicit self target; those settings are not evidence of
server permission to substitute a different target. Test that separately in a later authorized client phase.

## 10. Cast-time policy

Choose A for Slice 1: one exact authored base cast time per family, with ordinary reviewed native haste/spellmods.
Instant for contact families; one positive authored value for each ranged family. These positive values remain
AUTHORED_LATER. Exact base data does not forbid native modifiers whose behavior and client feedback are reviewed.

B (maximum base with server reductions) is diagnostic-only until client cast-bar/movement/queue feedback agrees.
C (several exact profiles/envelopes) is the preferred later expansion for genuinely different authored base timing;
it increases E_f and pool demand. D (custom timing with matched UI) is deferred and has no current API promise.

Spell.h::SetCastTimeMultiplier accepts 0.5..1.0, minimumMs <=600000, before target selection for untriggered
non-channel casts in NULL/PREPARING state. Spell.cpp:3578 applies the multiplier/minimum to calculated native time
when multiplier <1. This is not an Instant conversion, arbitrary slow setter or channel-tick authoring API.
No new timing API or Forge modifier was added. Ordinary native speed modifiers and future semantic Speed resolution
must not both apply the same scaling. A new envelope needs a documented single scaling stage.

## 11. Cost policy

V1 remains NativeCarrierCost authoritative. Client and server share power type, base amount/formula and native
modifier behavior. The amount and flat-versus-base-Mana basis for each custom spec must be authored before data.
Client exactness means the same effective formula/context, not one numerical amount for every level and buff.

| Cost variation | Policy |
| --- | --- |
| Same native formula, reviewed native modifiers | Same shell may serve it; no extra Ulduar debit |
| Different custom flat Mana amounts | Distinct matched cost profiles unless a future client-compatible seam is proved |
| Percentage of base Mana | Separate formula from flat cost; define rounding/base source and matching client view |
| Zero-cost root | Explicit zero-cost profile; review cost-required procs and spellmods, do not pretend paid cost |
| Client shows only a cost range | Diagnostic preview only, never sufficient native affordability feedback in V1 |
| Same shell with arbitrary resolved costs | UNSUPPORTED without matched checks/UI/debit/proc integration |

Future ResolvedResourceCost names instance/revision, resource, basis, amount, modifiers/order, rounding and commit
policy. NativeCarrierCostEnvelope describes representability; it is not a second fee. One authoritative debit amount
must reach affordability checks, native commit, relevant proc events and refund rules. Prefer one reviewed native
debit seam, not Native TakePower plus a ResourceService deduction. SpellInfo::CalcPowerCost, Spell::CheckPower and
TakePower are the current path. Percentage-of-base-Mana is not percent of current Mana. A zero-cost effect under a
native cost-reduction aura and a zero-base-cost row can differ for cost-required proc tests; review both explicitly.
If displaying/representing the resolved amount is unproven, reject the build or select an exact profile.

## 12. Cooldown authority design

DESIGN ONLY. Authority is stable owner + AbilityInstanceId, never leased SpellID. Proposed state:

```text
AbilityCooldownState
  ownerGuid, abilityInstanceId, stateRevision, rulesVersion
  ownAbsoluteExpiryUTC, clockDomain/version
  sharedGroupRefs[]                   # separate owner/group authority; not duplicate timers
  chargeModel=NotApplicableForV1
  charges, maxCharges, rechargeSchedule # absent unless a later charge model is explicitly enabled
  lastCommittedCastToken, lastMutationReceipt
  persistedAtUTC, reconciliationStatus
NativeCooldownProjection
  owner, slot, instanceId, leaseGeneration, catalogEntryVersion
  carrierSpell, projectedStateRevision, projectionReceipt
```

Absolute expiry is server time, not a client timestamp or saved monotonic tick. Within one process use a monotonic
deadline derived from authoritative time; persistence/reconnect uses a documented durable UTC/time authority.
Unknown/backward clock anomalies suspend readiness until reconciled; never silently grant a fresh cooldown.
If future charges are introduced, a missing state must not mean full charges. Serial/parallel recharge is then
an explicit rulesVersion decision, not inferred from native proc charges.

Own cooldown commits exactly once per accepted cast token at the reviewed native commit stage; explicit failure/
refund policies update the same state. Shared cooldown groups have their own owner/group expiry authority; do not
store divergent copies in each instance. GCD remains player/recovery-group native authority, separate from own debt.
Projection carries remaining debt onto the current SpellID before it becomes active. Categories can lock other
Generic-family spells (Player.cpp category cooldown path), so category separation must be deliberate.

Loadout swap, release, reassign, retire/reacquire and reconnect never clear or duplicate debt. Releasing the old
carrier retains instance/group state; no blind native ClearCooldown. A candidate with unrelated native cooldown or
independent entitlement is unavailable until provenance is resolved. Reconnect loads/reconciles debt before grants
or enabled action buttons; interrupted projection remains suspended and retries idempotently. No persistence,
cooldown authority or reconciliation implementation was added in A.7.

## 13. Queue/drain/quarantine lease policy

Native CMSG_CAST_SPELL contains count, SpellID, flags and targets, not instance/revision/generation.
SpellHandler.cpp:424 can queue the original packet. PlayerUpdates.cpp:2329–2428 reads the configured queue window,
checks existing request categories/current spells/GCD/cooldown, and later re-enters the packet handler. CancelCast
clears the current server queue, but cannot remove a packet not yet received. The queue window is not a maximum
network delay or proof of quiescence. An addon acknowledgement cannot authenticate old native packet intent.

Design states, separate from A.6's current binding implementation:

| State | Native cast disposition | Occupancy |
| --- | --- | --- |
| ACTIVE | Resolve unique reviewed instance snapshot | Consumes one active lease |
| DRAINING | Reject new roots; finish/cancel already accepted work by explicit policy | ID still reserved |
| QUARANTINED | Reject every new root for this retired session mapping | ID unavailable, no active slot consumed |
| FREE | No former packet can address a different mapping; eligibility still checked before activation | Allocatable |

FREE -> ACTIVE requires owner entitlement, unused compatible ID, no collision, current catalog/package, generation
check, one-slot limit, reconciled cooldown/group/GCD state, and native projection readiness. A staging preparation
may fail without exposing an active lease; ACTIVE is reached only after all required projections are coherent.

ACTIVE -> DRAINING requires an authorized serialized management transition, initially alive/out of combat and no
new activation race. Advance management epoch and close the root gate before withdrawing the projection. Keep a
rejection tombstone; do not erase the mapping while a still-known carrier could fall through to native execution.
Stop/cancel queued work under the owner thread with recorded outcomes, not by an unrelated worker mutating the deque.

DRAINING -> QUARANTINED requires:

- No current generic, melee, autorepeat or channeled cast can emit more roots for that mapping. Channels are outside
  V1; any unexpected channel holds draining until explicitly ended, not treated as safe by the generic queue check.
- No queued carrier/category request or management operation can commit against the old epoch. Clearing the queue
  does not satisfy the pending-network condition below.
- Every accepted delayed projectile and triggered child has finished/cancelled safely, or has a proved detached
  immutable snapshot and independent accounting. V1 conservatively waits for tracked in-flight events to finish.
- All debit, cooldown, refund, threat and event receipts are committed once; instance/group debt is retained.
- Native spellbook/action-bar projection changes are ordered under the same transition; remove only Forge-owned
  grant sources, never independently owned native spells. GCD debt is not removed by these changes.

QUARANTINED -> FREE is forbidden for reassignment to another instance or materially changed semantic revision
within the same transport session in V1. No arbitrary delay, latency estimate, empty deque or UI acknowledgement
qualifies. With untagged packets, the server cannot distinguish an old button intent from the new use of that ID.

The conservative release condition is a new authenticated transport/session epoch after the old session is closed,
all old-session packets/queues/operations are unable to dispatch, in-flight work has drained, and cooldown/entitlement/
catalog projection has been reconciled for the new session. A mere addon reload, zone transfer or disconnect/rebind
that retains the same WorldSession/queue is insufficient. A later proven transport-boundary protocol could relax
this, but none is implemented or claimed here. Cold start also requires explicit persisted-debt reconciliation.

An unchanged-instance/unchanged-semantics refresh is distinguishable as equivalent intent only if its debt and
side-effect ownership remain continuous; treat it as refresh of ACTIVE, not general reuse. A material revision
change after an exposed button needs the same drain/epoch policy. This deliberately limits convenient same-session
reforging until an explicit input-ordering design exists. It does not alter current authored tests or add gameplay.

An inactive instance owns no active carrier, while a previously exposed SpellID can remain quarantined for the
session. New never-exposed IDs may still be used if the permitted slot budget and pool capacity allow. Exhaustion
rejects; it does not share a carrier, clear cooldown debt or bypass quarantine. No multi-slot feature is implemented.

## 14. Native aura/proc contamination policy

Classification is by effect provenance plus consumer semantics, not only the carrier's SpellFamily. Generic with
zero masks excludes ordinary family matching but not no-family filters, school/type multipliers or scripts.
Never globally set IGNORE_CASTER_MODIFIERS or disable all procs to simulate neutrality.

Policy precedence: an unrelated native class talent/passive source is DENY_NATIVE_CLASS_ORIGIN even if its consumer
uses a generic school/crit filter. Known world/item/buff/debuff provenance can be ALLOW_GENERIC for ordinary combat
rules. A reviewed explicit exception needs a versioned allow record. Unknown provenance does not silently become
generic: it is UNKNOWN and blocks approval of the affected interaction. This policy is not yet an enforcement hook.

An ordinary externally applied class-cast buff can be an explicitly allowed world interaction without making its
native class/talent ownership Forge authority. Distinguish that reviewed active buff from silently inheriting an
unrelated native talent/passive as part of the character build; do not ban all buffs merely because their caster
uses a native class. Source provenance and the approved interaction record must resolve that distinction.

| Category | Default | Required scope |
| --- | --- | --- |
| School multipliers | ALLOW_GENERIC | Known normal buffs/debuffs; origin override applies |
| Generic damage multipliers | ALLOW_GENERIC | Reviewed ordinary done/taken stages, once |
| Generic healing multipliers | ALLOW_GENERIC | Reviewed heal/overheal stages, once |
| Crit modifiers | ALLOW_IF_EXPLICIT | Match chosen defense/crit model; deny unrelated class talents |
| Hit modifiers | ALLOW_IF_EXPLICIT | Match magic/melee hit model; no inferred class skill dependency |
| Absorbs | ALLOW_GENERIC | Native school/effect eligibility retained |
| Immunities | ALLOW_GENERIC | Native world protection and effect immunity retained |
| Resistances | ALLOW_GENERIC | Apply chosen native school/defense rules, not invented Holy rules |
| Armor | ALLOW_IF_EXPLICIT | Required review for Physical damage adapter; not inferred from contact |
| Weapon procs | ALLOW_IF_EXPLICIT | Default absent for independent shell; effect/attack-type audit |
| Class-specific passive auras | DENY_NATIVE_CLASS_ORIGIN | Only named intentional native exception can retain them |
| Talent auras | DENY_NATIVE_CLASS_ORIGIN | Ulduar future semantic talents have separate entitlement/provenance |
| Encounter mechanics | REQUIRES_REVIEW | Generally preserve world rules, including school-based overrides |
| Spellmods | REQUIRES_REVIEW | IsAffected, family=0 wildcard and script hooks all reviewed |
| Mana-cost modifiers | ALLOW_IF_EXPLICIT | Native formula/UI/proc agreement and source provenance |
| Proc flags | REQUIRES_REVIEW | Audit listeners, event phase/type/hit mask; not a blanket allow switch |
| Kill/hit/crit triggers | ALLOW_IF_EXPLICIT | Once-only event semantics; children and resource returns reviewed |
| Threat modifiers | ALLOW_GENERIC | Normal world threat; class passive source override applies |
| Override-class scripts | DENY_NATIVE_CLASS_ORIGIN | Explicit encounter exception separately reviewed |
| Any unclassified source/listener | UNKNOWN | Block approval until provenance and effect are reviewed |

ALLOW_IF_EXPLICIT without an allow record is denied for that interaction. REQUIRES_REVIEW/UNKNOWN blocks release
approval where the interaction can occur; do not erase ordinary world buffs to hide missing evidence. The later
entitlement/adapter design must either prevent an unrelated native passive from being granted or suppress its
specific interaction using an explicitly reviewed source-aware boundary. Neither implementation exists here.

Source counterexamples: Unit::SpellPctDamageModsDone applies Molten Fury cases 4920/4919 before the later
IsAffectedOnSpell filter, subject to its preceding attribute/health checks. EffectHeal checks aura 23401 and Holy
school for Corrupted Healing without requiring Priest family. SpellInfo::IsAffected returns true for requested
family zero. SpellMgr::CanSpellTriggerProcOnEvent examines school, type/phase/hit masks and cost requirements.
No-family-filter does not imply no native-class origin. Corrupted Healing is an encounter review candidate;
Molten Fury is denied as unrelated native talent influence on custom neutral carriers.

## 15. Entitlement boundary

Custom carrier eligibility must not derive from native class, talent tree, class skill line or trainer history.
Class can remain character/chassis metadata. Any necessary resource/mechanic availability is an explicit reviewed
capability requirement, not implicit class ownership. The current native Holy Light exception retains its class
gate until replacement; do not bypass it under the new neutral design policy.

Later Ulduar Progression owns AbilityInstance entitlement and lifecycle, Core consumption/receipts, active-slot
assignment and requested carrier projection, generic talent entitlement, gem ownership/socket assignment and
keystone entitlement/activation. Abilities owns semantic resolution/validation and runtime contracts; the native
projection service applies reviewed known-spell/action/mechanic state and reports failures. Neither the carrier
catalog nor spellbook is the ownership authority. Projection failure preserves ownership and suspends activation.

Keep grant-source ledgers separate for native and Forge spell sources. A native trainer grant must not be hijacked
or erased by a Forge projection. Generalized talents compile into semantic rules later, not copied native passive
auras by default. Gems remain local to an instance; native skill lines, rarity and Ability Essence cannot prove
entitlement. No progression, persistence, respec, talents or keystones were implemented.

## 16. Effective server-data review

Approval target is effective interpretation, not just raw DBC rows. Source loading evidence:
DBCStores.cpp loads DBC data/locale strings then LoadFromDB for configured override tables. Spell, SpellRange,
SpellCastTimes, SpellVisual and SkillLineAbility have such DB table mappings. SpellIcon is a client dependency;
SpellInfo retains icon IDs without making local server rows proof of client icon data.
DBCDatabaseLoader.cpp replaces matching indexed records with DB records and grows the index to maximum ID + 1.
Thus DB occupancy and sparse-index capacity matter even when raw DBC IDs appear free; uint32 representability
alone is insufficient evidence for a safe high-number allocation.
World.cpp loads SpellInfo, cooldown overrides, corrections, ranks, spell-specific/aura-state data, skill maps and
custom attributes in sequence. SpellMgr can invoke OnLoadSpellCustomAttr. Effective-data review must capture all
later hooks/configuration affecting the carrier, not stop after SpellInfo construction.

Required per-entry evidence packet:

| Area | Evidence / rejection rule |
| --- | --- |
| Raw input | Canonical spec, allocation ledger receipt, raw Spell row and dependency hashes |
| DB overlay | Effective read-only export and applied versions for all relevant *_dbc tables |
| Native interpretation | SpellInfo field projection after corrections, cooldown overrides and custom attributes |
| Scripts | Direct IDs, negative rank-root bindings, global hooks, script versions and child edges |
| Conditions | Cast/target conditions including referenced conditions and error behavior |
| Procs | spell_proc, generated default entries, listener origins, phase/type/hit/cost filters |
| Bonuses | spell_bonus_data, native coefficients/levels, rounding and any no-coefficient fallback |
| Threat | spell_threat and ordinary damage/heal threat policy |
| Family | Generic/masks/effect class masks; broad filters and override-class scripts |
| Attributes/mechanics | All words, custom attributes, prevention/interrupt/facing/combat/form restrictions |
| Target/range | Explicit/implicit A/B, self/dead policy, relation, min/max/reach, target creature masks |
| Timing/cost | Base cast/speed, native modifiers, Mana model, single-debit and refund behavior |
| Defense | DmgClass, attack type, hit/crit, armor/resistance/absorb/immunity/proc reporting |
| Ranks/learning | No accidental chain/replacement/skill/trainer link; copy identities independent |
| Cooldowns/queue | Recovery/category/GCD, queue category grouping and lease projection policy |
| Visual dependencies | Speed/missile/visual consistency and registered client dependency closure |
| Runtime integration | Contract adapter, script registration, no fallback after invalid or quarantined binding |

Each field gets raw -> overlay -> correction/hook -> effective value with source provenance and an explicit diff
against canonical intent. An unexplained difference rejects the entry. A static predicted effective record is
SOURCE_ONLY, not an observed dump. Live DB and loaded process state were not inspected in this phase.

Future RuntimeEligible requires complete static/data review, matched package/release evidence, reviewed native
interaction/lease/cost policies, implemented adapter boundaries and separately authorized tests/runtime evidence
for the actual client/server combination. Merely changing the enum or populating an ID is insufficient; current
A.6 intentionally cannot consume RuntimeEligible. Do not implement or promote that transition in this phase.

## 17. Client-data review

| Dependency | Required match/review |
| --- | --- |
| Spell.dbc | Exact ID, effects/targets, attributes, power/cost, family, native timing/range and presentation refs |
| SpellRange.dbc | Friendly/hostile min/max and flags; contact/reach feedback |
| SpellCastTimes.dbc | Base time and level terms; client cast bar/movement/interrupt behavior |
| SpellVisual.dbc | Cast/impact/missile kits and referenced visual-effect records |
| SpellIcon.dbc | Icon IDs, filenames, assets and intended spellbook/button representation |
| Missile/models | All transitive model/skin/texture/attachment dependencies and synchronized travel |
| Sounds | Referenced sound entries/files or approved nonessential silence fallback |
| SkillLineAbility if used | Client grouping/visibility without unintended class/trainer/learning coupling |
| Spellbook | Known active root, distinct copies, names/ranks, no hidden rank replacement |
| Action bars | Secure native activation, target/self fallback, feedback, cooldown/GCD and projection updates |

Review the actual effective package after MPQ/locale precedence; loose extracted DBC equality is insufficient.
Canonical semantic hashes normalize string references; package hashes preserve exact distributed bytes.
Missing critical missile/model data blocks the affected carrier. No fallback from projectile to direct delivery.
Client presentation cannot stand in for server target/power checks, and server overrides cannot repair unavailable
client targeting. Actual client behavior remains RUNTIME_REQUIRED. No client data was generated or changed.

## 18. Manifest/version policy

Refine the single Forge content manifest, not a separate release authority. Every release binds the full tuple:

| Version/hash | Meaning / change rule |
| --- | --- |
| Canonical spec schema | Field/encoding meaning; incompatible changes need a new schema |
| Spec version | Immutable authored spec content; any changed intent gets a new revision |
| Semantic profile version | Referenced resolved profile semantics; independent of schema/spec revision |
| Carrier entry version | Concrete ID/envelope/adapters and reviewed effective data for that entry |
| Catalog version/hash | Immutable ordered entry set and allocation priority; member/order change versions it |
| Client package version/hash | Exact artifacts and dependency closure, build/locales/overlay policy |
| Server definition version/hash | Compiled/data adapter representation plus effective override/script projection |
| Resolver version | Semantic resolution/formula implementation; changes require compatibility review |
| Protocol version | Management message grammar/capabilities; no implied change to native cast packets |

Versions need not have the same number. A manifest names compatible exact references/hashes, supported client build,
ledger revision, source/core/module revisions and effective-data review record. Equal version with different content
hash is an integrity failure. An explicit reviewed compatibility mapping may accept a different package/revision
only when relevant semantic and dependency hashes are equivalent; never silently substitute a newer catalog.
The existing addon Protocol 2 grammar is unchanged.

| Mismatch | Disposition |
| --- | --- |
| Native client build/wire incompatibility prevents safe base session | REJECT_LOGIN via core compatibility policy |
| Forge protocol/schema or global resolver incompatibility | DISABLE_FORGE; ALLOW_READ_ONLY safe server summary |
| Global catalog integrity failure or untrusted manifest | DISABLE_FORGE until integrity/review resolves |
| One carrier row/dependency/entry version/effective-data mismatch | DISABLE_AFFECTED_CARRIERS and dependent commits |
| Partial package missing a visual/icon required by an affected carrier | DISABLE_AFFECTED_CARRIERS |
| Unknown required capability or unverifiable critical hash | DISABLE_AFFECTED_CARRIERS, or DISABLE_FORGE if global |
| Nonsemantic notes/optional approved cosmetic difference | WARN_ONLY if manifest explicitly permits it |
| Preview cannot safely load affected client IDs | ALLOW_READ_ONLY text from server; no unsafe icon/spell dereference |

A carrier mismatch alone does not justify rejecting otherwise safe base login. Do not delete ownership, auto-respec,
clear cooldown debt, teach replacement native spells or patch client files during mismatch handling. Read-only means
no casts/commits for disabled content. A client-reported hash is compatibility evidence, not anti-cheat attestation;
server authority still checks casts. No handshake/version enforcement code is added here.

## 19. Holy Light 635 role

SOURCE_COMPATIBLE / NATIVE_EXCEPTION / NOT CLASS_NEUTRAL.
Role: REPLACE_WHEN_CUSTOM_READY for the permanent Forge surface. It remains a bounded source-reviewed Slice
reference until a neutral RangedHealing shell has complete data/adapter/client/runtime approval. Readiness is not
defined as merely having a new DBC row. Existing native player use remains native; replacement must preserve grant
sources, instance identity and cooldown debt, not unlearn a legitimate Paladin spell automatically.

The exact first-rank contract still retains Paladin eligibility/family, native cost, cast/range restrictions and
NOT_SHAPESHIFTED. No later rank is approved. The new neutral entitlement policy does not retroactively declare 635
class-neutral or remove its current gates. No allowlist/catalog change was made.

## 20. Research candidates

| Candidate | Remaining promotion blockers |
| --- | --- |
| 1495 Mongoose Bite | Hunter family/talent coupling; combat/autoattack side effects; client action behavior |
| 31759 Holy Bolt | Player spellbook/button suitability; effective scripts/conditions; native restrictions |
| 34232 Holy Bolt | Independent effective-row/rank/script review; do not inherit approval from equal raw axes |

For all three: native exception rationale versus a cleaner custom shell; grant/entitlement provenance; exact effect/
target/resource/defense/range/activation/visual review; cooldown/queue categories; loaded overrides and allowed aura/
proc interactions; matched package and separately authorized client/server observation. Holy Bolt's Holy/Mana/
projectile fields avoid one conversion mismatch but Generic does not prove neutral behavior. Mongoose's inspected
row has no dodge prerequisite in A.5; do not resurrect an older expansion assumption instead of reviewing data.
No contract or catalog entry was authored for these IDs.

## 21. HeroFreePick boundary

HeroFreePick is permitted only as UI/progression/catalog-reference material. No code, lookup table, custom Ascension
ID, Ability Essence price, local rarity or unlock tree becomes authoritative carrier metadata. Similar names/icons
do not prove equivalent native execution. Transport identities come exclusively from Ulduar's reviewed ledger/spec/
manifest. No external module or reference project was imported, installed, executed or modified.

## 22. Remaining blockers

- NAMESPACE_UNRESOLVED: effective client archives, DB overlays, supported releases and editor allocations need a
  coherent collision audit before any production IDs or emitting artifacts.
- Damage class/defense, coefficient, complete attributes/proc policy, category/GCD choice and visual dependency
  details require authored decisions. Balance values remain AUTHORED_LATER, not zero or borrowed implicitly.
- Native class contamination policy has no new enforcement or entitlement implementation. Generic is insufficient.
- Safe activation/drain/quarantine, cooldown authority and future single-debit resolved costs remain design only.
- Raw/client/effective-server approval and subsequent runtime evidence are separate gates, all still outstanding.
- Full persistent Slice 1 and convenient same-session reforging/loadout behavior are not established by this review.

### Preservation and inspection record

Before edits, SHA-256 and Git status were recorded for 297 existing files across modules, docs, repository
client files, relevant core sources and all 29 discovered loose DBC copies. A separate deterministic digest covered
7617 repository SQL files. Final comparison found all 297 protected files byte-identical, zero missing files,
and the same SQL count/digest. Existing root/module Git statuses are unchanged; these two documents are within the
already-untracked docs tree. No C++, tests, module config, SQL, DBC, client assets or existing reports were edited.

New files only:

- `docs/implementation/ULDuar_PHASE_A7_CARRIER_DATA_SPEC.md`
- `docs/architecture/ULDuar_CUSTOM_ID_NAMESPACE.md`

Removed files: none. Existing pre-task core modifications and module skeleton deletions remain untouched.
Baseline core HEAD: `d7ce67dc1800f092bac98aad680ece1c201b89a0`. No Git commit was made.

SQL inventory digest (SHA-256 of sorted repository-relative path + NUL + per-file SHA-256 + LF):

```text
92696a509f3cfd2abcfc05173c02d78fc30e2a05067988bb6229ae67fbf2662f
```

Selected protected source/report fingerprints (same before and after):

```text
docs/implementation/ULDuar_PHASE_A6_CUSTOM_CARRIERS.md
f68db194bcb404894f1b1d0236b2430d94332e84955aecc68a9a9717cc0310bc
modules/mod-ulduar-abilities/src/AbilityCarrierCatalog.cpp
13f6aae992229b14e22ee6159a346e4d71ddec64c1272dc2d17c01c371cd5b7c
modules/mod-ulduar-abilities/src/AbilityCarrierCatalog.h
0f463d7621e8c759cc65a995915418093bd960186f6a3221e3b45591c5e8727f
modules/mod-ulduar-abilities/src/AbilityCarrierContract.cpp
cc754e3a778e961f8502f84fce0f862e1a72b40f565c1f2e823dac8cf80b8660
modules/mod-ulduar-abilities/src/AbilityCarrierContract.h
4a3c9b9eaa6524bf3d12532526df54abdf9bc9057892883fa8e0837cc672a325
modules/mod-ulduar-abilities/src/AbilityCarrierRegistry.cpp
05d524420b07783f44c2610b9836b46c21f3f6dd336665954654fdf3c721338f
modules/mod-ulduar-abilities/src/AbilityCarrierRegistry.h
9742af858706e91e2e399deca6372882876f4f04c7ba2c0f689ed3d209c14498
modules/mod-ulduar-abilities/src/AbilityInstance.cpp
e2133f0265a245bd31c5582bcd663bb1b3be5db2bedaace3d6ae7ea29578ff5e
modules/mod-ulduar-abilities/src/AbilityInstance.h
228f0cb12edf38db7f6a5422b3d88c52a965272452587c8414759a0fae255db7
modules/mod-ulduar-abilities/src/AbilityManager.cpp
dd936a24fb5b2a47a8972e0f49a559475fcfbb46775bf35e2ed0bb8d53b5cee9
modules/mod-ulduar-abilities/tests/AbilityForgePhaseATest.cpp
f28d1631d95401f9748b92850d37d1c9ca8b361d874e08468fc3c98f588ec8be
```

Static document checks found all 23 required sections and all 37 minimum canonical fields in each of four records;
each record has 51 fields with explicit statuses. Existing test declarations remain 39 AUTHORED_NOT_RUN.
Only source/data reads, hashing and text-format/schema-coverage inspection were used. No project code or authored
test body was executed. C++/SQL linters were not run because neither language changed; SQL tooling with database
or remote side effects is unnecessary for this documentation-only review.


## 23. Exact prerequisites for artifact-authoring phase

1. Approve a target release/build/locale and obtain authorized read-only effective client/server data snapshots.
2. Reconcile all used/reserved/tombstoned IDs and references, including editor visuals and historical packages.
3. Complete the collision audit; reserve typed IDs/copies through the shared append-only ledger with immutable hashes.
4. Replace every required UNKNOWN and AUTHORED_LATER in each selected spec with reviewed values and provenance.
   Resolve defense, coefficients, attributes, proc origins, ranges/reach, cast/cost, category/GCD and visuals.
5. Select the V1 exact envelopes and capacity/copy policy; prove allowed loadouts have unique compatible assignments.
6. Review the native interaction inventory and effective-data acceptance diff/checklists, including all DB/hooks.
7. Approve cooldown/queue/quarantine and entitlement boundaries as deployment prerequisites; artifact preparation
   must remain disabled content until those runtime boundaries and their separately authorized evidence exist.
8. Define canonical serialization/hashing, client/server output schemas, manifest tuple and mismatch behavior.
9. Separately authorize an artifact-only staging directory/output plan and reviewable pure serializer, with no live
   writes, SQL application, client patch application or RuntimeEligible promotion. No such generator exists here.
10. Require a later independent authorization for compilation/tests, effective runtime observation and distribution.

Symbolic specifications can be reviewed while the namespace is unresolved; concrete Spell rows cannot be emitted.
No next phase was begun. Completion here is acceptance of a documented contract review with explicit blockers,
not acceptance of carrier gameplay or permission to proceed to Phase B/C/D.

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO SQL WAS EXECUTED.
NO DBC WAS GENERATED OR MODIFIED.
NO CLIENT PATCH WAS APPLIED.
