# ULDuar Phase A.6 — Neutral Custom Carrier Pool Prototype

Date: 2026-09-16. PHASE_A6_STATUS: COMPLETE within the authorized source-only scope.
Evidence: SOURCE_ONLY and TEST_AUTHORED_NOT_RUN. Deployment and gameplay evidence: RUNTIME_REQUIRED.

## 1. Executive summary

Implemented a versioned shell catalog and deterministic family-pool lease boundary on the existing per-owner
AbilityCarrierRegistry. AbilityCarrierBinding now carries family, catalog version and entry version alongside its
owner, slot, SpellID, generation, instance ID and revision. No second dispatch registry or ownership service exists.

The production catalog contains one existing native exception, Holy Light rank 1 / 635, and four custom specification
identities without SpellIDs. Pending custom definitions cannot bind, including through exact-spell registration.
RuntimeEligible is a reserved state which this prototype deliberately cannot consume. No new carrier was enabled.
The one-active-slot restriction remains. Fifteen pure cases were added to the existing 24 authored tests; all 39
are AUTHORED_NOT_RUN. These counts describe source declarations, not executed or compiled tests.

The permanent direction is HYBRID: neutral custom pools, with narrowly reviewed native exceptions. The canonical
custom spec, six-slot scaling, cooldown/resource authority, envelopes, visuals, manifest and authoring pipeline below
are design contracts, not implemented gameplay. No final custom numeric SpellIDs or balance values were allocated.

This phase performed source reads/edits, SHA-256 inventories and a read-only Python C++ style scan. No compiler,
build system, project executable, test, generator, server, SQL, database, client patcher, live DBC or MPQ was run or
modified. No Git commit was made. Historical artifacts from earlier phases were not resumed or reconfigured.

## 2. Why HYBRID was selected

The [A.5 review](ULDuar_PHASE_A5_SOURCE_REVIEW.md) distinguishes source compatibility from gameplay evidence.
Native-only would force family/scripts, resource, activation or presentation exceptions for three initial profiles.
Custom-only immediately discards the existing narrow Holy Light research boundary without supplying actual data.
HYBRID preserves that boundary while making the future transport surface explicit and reviewable.

| Concern | Native exception | Neutral custom pool |
| --- | --- | --- |
| Initial work | Existing data; individual contract review | Namespace, canonical spec, matched data package |
| Targets/range/timing | Must fit native restrictions exactly | Authored to match semantic family |
| School/projectile | Native school and missile must agree | Holy projectile authored as Holy on both sides |
| Resources | Native cost and class context retained | Mana and explicit cost basis; later cost profiles |
| Coupling | Native family, rank, scripts and talents | Generic/zero masks reduces coupling; generic effects remain |
| Presentation | Fixed native spellbook/visuals/tooltip | Reviewed shell metadata; not dynamic per-player text |
| Multiple instances | Scarce distinct exact-fit native IDs | Bounded interchangeable copies per family/envelope |
| Maintenance | Re-review upstream changes to native rows | Review exporter/package/core compatibility |

No convenience-based promotion of Mongoose Bite, Holy Bolt, NPC/test rows or later Holy Light ranks follows.
The four current profile outcomes from A.5 remain unchanged; the catalog supplies no missing execution adapter.

## 3. Carrier family model

`CarrierFamilyId` is a scoped enum independent of NativeSpellId and AbilityInstanceId. Unknown is a rejection value.
The mapping is explicit in CarrierFamilyForProfile; enum ordinals are not wire protocol or DBC IDs.

| Family | Existing profile reference | Required transport |
| --- | --- | --- |
| MeleeDamage | DamageMelee v1 | Enemy unit, Instant, Direct, Point, Physical, Mana, contact |
| RangedProjectileDamage | DamageRanged v1 | Enemy unit, CastTime, Projectile, Point, Holy, Mana, ranged |
| MeleeHealing | HealingMelee v1 | Friendly unit, Instant, Direct, Point, Holy, Mana, contact |
| RangedHealing | HealingRanged v1 | Friendly unit, CastTime, Direct, Point, Holy, Mana, ranged |

A family is a transport category, not an owned spell, class, rank, gem or archetype. Multiple instances can refer to
the same family while retaining independent IDs and compositions. Contact is a reach policy, not an unconditional
five-yard distance between centers. Purpose, Method and native damage class remain distinct concepts.

## 4. Carrier catalog

Implemented in `modules/mod-ulduar-abilities/src/AbilityCarrierCatalog.h/.cpp`.

| Field | Role |
| --- | --- |
| Family | Typed transport family |
| optional CarrierSpell | Concrete native action identity; absent for every custom placeholder |
| Profile / ProfileVersion | Existing semantic capability requirements; avoids copying AbilityComposition |
| Origin | NativeReviewed or UlduarCustom |
| Status | NativeSourceReviewed, CustomDefinitionPendingData, RuntimeUnsupported, RuntimeEligible |
| ClientMetadata | ReviewedNativeException or RequiresMatchedClientData |
| Version | Entry revision; independent of catalog and instance revisions |
| SpecKey | Stable source specification key, never a SpellID |
| SourceProvenance | Human-readable source-review boundary; not a cryptographic attestation |

Catalog version 1 has five entries. The native entry is `Native_HolyLight_Rank1`, SpellID 635,
RangedHealing/HealingRanged v1, NativeSourceReviewed. The other four entries use the custom names in section 6,
UlduarCustom, CustomDefinitionPendingData and no CarrierSpell. Research candidates are not entries.

Entry capability requirements reference the existing immutable profile. The materialized CarrierContract supplies
the concrete reviewed effect, timing, range, school, resource, attack policy, client constraints and adapter evidence.
ValidateCatalogCarrier checks both boundaries; a label or SpecKey alone does not establish eligibility.

State policy:

| State | Behavior in this prototype |
| --- | --- |
| NativeSourceReviewed | NativeReviewed + ReviewedNativeException; matching catalog/profile and reviewed contract |
| CustomDefinitionPendingData | Always reject; a mistakenly assigned nonzero ID cannot override this |
| RuntimeUnsupported | Always reject |
| RuntimeEligible | Reserved for future effective-data/manifest integration; always reject in A.6 |

NativeSourceReviewed does not mean gameplay evidence exists. The manager still obtains real SpellInfo and runs
ReviewPhaseACarrier for the exact first-rank native definition. All prior readiness, known-spell, class, ownership
and legacy-customization guards remain. A registry constructed directly with test data is a trusted C++ seam,
not a client-facing validation service. No external catalog loader or command accepts arbitrary catalog entries.

CarrierCatalog::Find rejects zero and duplicate concrete spell identities. Each registry owns an immutable catalog
copy, avoiding dangling entry references or later mutation through the constructor argument. Static authoring order
defines allocation priority. No hot reload or cross-session catalog migration is implemented.

## 5. Custom carrier canonical spec

DESIGN ONLY. The following schema is the future authoring authority, independent of SQL columns, DBC row offsets,
C++ aggregate layout and package format. The current C++ placeholders contain references, not serialized full specs.

```text
CanonicalCarrierSpec
  specKey, schemaVersion, specVersion, family, semanticProfileId/version
  purpose, activation, targeting=Unit, targetRelation, delivery, geometry=Point
  school, powerType=Mana, costPolicy/nativeCostBasis
  rangeProfile, castTimeProfile, projectileSpeedProfile
  damageClassPolicy, hitCritDefensePolicy, coefficientPolicy
  spellFamilyPolicy=Generic, familyMasks=[0,0,0]
  effectLayout, attributesPolicy, mechanicPolicy, procEventPolicy
  equipmentPolicy, stancePolicy, reagentToolFocusPolicy
  nativeCooldownPolicy, categoryPolicy, gcdPolicy
  visualProfileKey/version, clientRequirements
  numericDecisions[{field, classification, valueOrUnresolved, sourceReference}]
  provenance, reviewRecord, compatibilityEnvelopeKey/version
```

Every numeric decision uses REQUIRED_FIXED_SEMANTIC, AUTHORED_LATER or REUSE_NATIVE_REFERENCE. Unresolved fields
remain absent, not sentinel production values. Specs do not contain owner, slot, instance, gems or resolved coverage.
The reviewed effect layout has one school-damage or heal payload, no resource/combo/aura/controller side effects.
Magnitude/coefficient, damage class and hit/crit policy require separate explicit review; Physical does not imply
weapon percentage damage, and contact alone does not choose dodge/parry/armor behavior.

Generic family and zero masks are the default. Equipment requirements absent, no form/stance prerequisite, no reagents,
tools or focus, no implicit rank chain, and no native class scripts. Zero stance masks alone are insufficient:
NOT_SHAPESHIFTED must also be absent from a genuinely form-neutral authored shell. Movement, facing, combat entry,
interrupt, silence/pacify, GCD and proc attributes require a reviewed allowlist, not blind copying of a native row.
Clearing every attribute is not a specification either.

No documented collision-safe custom namespace was established by the reviewed architecture/module catalogs.
Therefore this phase assigns no numbers. Future allocation must compare a proposed reserved interval with the
entire target client Spell.dbc, effective server rows/overrides, installed modules, rank/learn/script references and
an append-only release allocation ledger. IDs must not be recycled while supported manifests or saved projections
can reference them. Reserved ranges for Range/CastTime/Visual/Icon records need equivalent collision checks.

## 6. Four ideal Slice-1 custom shells

All four are independent root casts. No next-swing, combo point, Rage, Energy, Rune, weapon/equipment, form/stance,
class-family or controller-child prerequisite is part of their contract. Ordinary native target/cast checks remain.

| Shell spec key | Payload/target | Activation/delivery | School/resource | Range |
| --- | --- | --- | --- | --- |
| UlduarCarrier_MeleeDamage | One SCHOOL_DAMAGE / enemy unit | Instant / Direct | Physical / Mana | Contact reach |
| UlduarCarrier_RangedProjectileDamage | SCHOOL_DAMAGE / enemy | CastTime / Projectile | Holy / Mana | Ranged |
| UlduarCarrier_MeleeHealing | One HEAL / friendly unit | Instant / Direct | Holy / Mana | Contact reach |
| UlduarCarrier_RangedHealing | One HEAL / friendly unit | CastTime / Direct | Holy / Mana | Authored ranged profile |

Damage shells use target A enemy unit, target B none; heal shells use target A friendly unit, target B none.
Unused effects are absent. No trigger child, periodic rider, aura, energize, combo or weapon-percentage effect.
The projectile shell needs native positive speed and a visible compatible missile visual; the other three are direct.
Friendly contact healing needs its own matched native/client contact row, not a 40-yard heal rejected late by Ulduar.

| Numeric/design field | Classification | Decision |
| --- | --- | --- |
| Exactly one payload; unused effects/targets absent | REQUIRED_FIXED_SEMANTIC | One direct damage/heal execution |
| School/power/Generic/zero masks | REQUIRED_FIXED_SEMANTIC | Native metadata encodes listed semantics |
| Contact range/reach flag | REQUIRED_FIXED_SEMANTIC | Contact policy; exact reach/leeway mapping reviewed later |
| Melee cast duration | REQUIRED_FIXED_SEMANTIC | Instant / zero native cast duration |
| Ranged cast duration | AUTHORED_LATER | Positive duration; 2500 ms Holy Light is only a reference |
| Ranged max/min distance | AUTHORED_LATER | No final balance range; native 0..40 is a research reference |
| Direct speed | REQUIRED_FIXED_SEMANTIC | No projectile travel; native Speed=0 |
| Projectile speed | AUTHORED_LATER | Positive and visually synchronized; 24 is only a Holy Bolt reference |
| Mana cost, basis, coefficient and magnitude | AUTHORED_LATER | No final raw/percentage/base-Mana balance choice |
| Own/category cooldown and GCD duration | AUTHORED_LATER | Explicit identities; no accidental native category sharing |
| Native visual and icon references | REUSE_NATIVE_REFERENCE | Candidates only, see section 14 |
| Mechanic/proc masks, DmgClass, mitigation | AUTHORED_LATER | Review combat adapter before data approval |

The fixed semantics do not establish that all four shells can execute through current module definitions. In
particular, custom definition/runtime registration and client data do not exist. There is no generated Spell.dbc row.

## 7. Native exception policy

A native exception requires intentional native side effects, reviewed family/masks, scripts and rank behavior,
acceptable resource behavior and client presentation, exact target/range/activation/delivery, and a documented
reason why no available custom shell provides a materially cleaner contract. Re-review after core/data changes.
Review effective server data and the actual distributed client package before deployment, not just a name/tooltip.

Holy Light 635 retains its bounded SOURCE_COMPATIBLE designation: first rank only; native Paladin gate; single HEAL
to ally; Holy; Mana at 29% native base-Mana cost before native modifiers; 2500 ms base cast; native 0..40 range;
Speed=0; equipment class -1. Native Paladin family/mask, NOT_SHAPESHIFTED restriction, aura/talent effects and ordinary
GCD are retained. Zero form masks do not make it form-neutral. The catalog does not teach the spell or prove a
Forge-only entitlement, and the review function is not an exhaustive fingerprint of every effective field.

Mongoose Bite 1495 remains research-only: Mana/Physical contact semantics in the inspected row do not settle Hunter
family and auto-attack side effects. Holy Bolt 31759/34232 remains research-only: raw Holy/Mana/projectile fields
and Generic family do not prove player-button suitability, ownership, scripts or future native support policy.
No later Holy Light rank is added. No production allowlist or ReviewPhaseACarrier change was made.

## 8. SpellFamily/proc contamination analysis

Recommended default is SPELLFAMILY_GENERIC with all three family-mask words zero. No new native SpellFamily enum
is introduced. `SpellInfo::IsAffected` returns true immediately for a zero requested family; otherwise it compares
family and a nonzero filter mask. Generic/zero flags therefore avoid ordinary class-family matches but are not an
isolation boundary. SpellInfo::IsAffectedBySpellMod also delegates to a script hook which can change that result.
SpellMgr's spell_proc loading validates a bounded set of native family numbers;
inventing a Ulduar number is unjustified.

Relevant inspected paths, relative to repository root:

- `src/server/game/Spells/SpellInfo.cpp`, IsAffected / IsAffectedBySpellMod, around 1334–1371.
- `src/server/game/Spells/SpellMgr.cpp`, CanSpellTriggerProcOnEvent, around 875–939; proc loading around 2089.
- `src/server/game/Entities/Unit/Unit.cpp`, SpellPctDamageModsDone around 8451; hit around 3324/3497/3703;
  native class crit branches around 9304; ProcEventInfo::GetSchoolMask around 315.
- `src/server/game/Spells/SpellEffects.cpp`, native damage bonuses around 655, healing around 1572–1585.
- `src/server/game/Spells/SpellInfo.cpp`, CalcPowerCost around 2812; native aura/spell-mod cost paths remain.

Concrete warning from source: Unit::SpellPctDamageModsDone applies Molten Fury override-class-script cases
4920/4919 before its later IsAffectedOnSpell filter, subject to the preceding attribute check and victim health.
Generic family alone does not eliminate this class-origin interaction. EffectHeal also handles aura 23401,
Nefarian Corrupted Healing, by player/aura/Holy-school conditions, without testing the heal's family.
Native family-specific damage/crit branches are avoided by Generic, but these broader consumers still exist.

The following is the required future contamination checklist; classifications express design intent, not observed
live behavior. A generic filter on an unrelated native class talent is still an accidental class interaction.

| Consumer/filter | Can still affect Generic/zero masks? | Required policy/review |
| --- | --- | --- |
| School bonuses, absorbs, immunity, resistance | Yes | INTENDED_GENERIC_INTERACTION; review school adapter |
| DmgClass hit/crit/defense/armor paths | Yes | INTENDED_GENERIC_INTERACTION only for explicitly chosen defense policy |
| Mechanics/aura-state conditions | Yes | Intended environment/debuff rules; audit class talent origin separately |
| Damage/heal aura multipliers | Yes | Buffs intended; class passives can be ACCIDENTAL_NATIVE_CLASS_INTERACTION |
| Proc flags/type/phase/hit mask | Yes | Intended common event reporting; no proc immunity assumption |
| Attack type, weapon/enchant conditions | Depends on DmgClass/attributes | Reject accidental autoattack/weapon procs |
| Attributes, icon/ID, override scripts | Yes | Audit individually; Molten Fury is ACCIDENTAL_NATIVE_CLASS_INTERACTION |
| Damage/heal events, overheal, threat | Yes | INTENDED_GENERIC_INTERACTION; class-triggered children require review |
| Critical hits / returns on crit | Yes | Crit can be intended; unrelated class refunds/procs are accidental |
| Mana cost / school cost / spellmods | Yes | Native cost authoritative now; review class discount provenance |
| Relation/type/health thresholds | Yes | Generic legality intended; class bonuses may be accidental |
| Generic family / no-family-filter procs | Yes | Explicitly review all-family listeners, including native class auras |
| Native class family plus nonzero masks | Normally excluded | Inspect scripts/exceptions; not complete isolation |
| Encounter overrides: Corrupted Healing | Yes | Candidate INTENDED_GENERIC_INTERACTION; needs release decision |

Future neutral acceptance needs an approved aura/proc interaction inventory and a character entitlement policy that
does not silently grant unrelated native talents. Suppression, if later needed, must be narrow and separately
reviewed. Do not set IGNORE_CASTER_MODIFIERS globally merely to make Generic appear neutral; that also discards
desired combat modifiers. No proc/aura/core behavior was changed here. Ulduar talents remain unimplemented.

## 9. Carrier pool and lease model

The pool is a read-only family-filtered view of the catalog, with availability derived from the existing registry.
`AbilityCarrierRegistry::LeaseCarrier` implements deterministic selection; there is no separate pool singleton,
lease map or count to become stale. Existing AbilityCarrierBinding is the lease representation.

```text
immutable catalog + reviewed candidate CarrierContracts
  -> requested family + current owner's existing bindings
  -> LeaseCarrier (catalog order, skip occupied or pending entries)
  -> RegisterBinding (catalog + instance + ownership + generation checks)
  -> existing immutable cast snapshot and native SpellID dispatch
```

Only candidates with matching catalog IDs are considered. Duplicate candidate IDs reject as ambiguous. No candidate
or no available reviewed member returns POOL_EXHAUSTED, with pending/collision diagnostics when applicable. A
selected invalid contract returns its rejection without searching around that defect. Pending entries are never
selected. No error changes the old binding. No different semantic family or native execution fallback is chosen.

Lease fields: Owner, ActiveSlot, Family, CarrierSpell, Generation, InstanceId, InstanceRevision, CatalogVersion,
CatalogEntryVersion. Generation remains slot-scoped; a successful bind/refresh increases it, release increases it
again and retains the tombstone. Reactivation supplies the current generation explicitly. Revision input history
still prevents same-revision semantic mutation after removal. Overflow and stale generations reject.

One owner cannot lease one SpellID twice or occupy a slot with two instances. Different per-owner registries may
reuse a global carrier ID. One active slot per owner remains enforced even when a synthetic catalog offers two IDs.
Inactive instances consume no lease after explicit RemoveBinding; the registry does not own or retire the instance.
The manager clears the registry on existing load/unload/delete paths. No lifecycle service was added.

Selection and mutation run inside the manager's existing mutex. Direct registry callers must serialize access;
Player/SpellInfo checks retain the existing owner/map-thread assumption. No raw Player/AbilityInstance pointer is
retained. Catalog references are temporary; cast snapshots own immutable resolved definitions and value bindings.

Prototype allocation priority is catalog order, independent of supplied contract order. Changing the available
candidate set can select a different ID on an explicit refresh; there is no automatic background reassignment.
Future gameplay must add the cooldown and queued-packet preconditions below before exposing any lease switching.

## 10. Multi-slot scaling

`SpellHandler.cpp::HandleCastSpellOpcode` reads cast count, SpellID, cast flags and targets. It also queues requests
by spell/category and checks HasActiveSpell. There is no instance ID or lease generation in the native packet.
Therefore simultaneously active instances for one owner need distinct native action identities under this model.
An addon-selected instance cannot disambiguate two identical native spell buttons securely.

For N active slots, each family f needs at least M_f mutually compatible copies, where M_f is the maximum number
of simultaneously selected instances of f. If all N slots may independently choose any of four fixed profiles,
M_f=N and catalog capacity is 4N: N=6 suggests 24 potential IDs. Only six would be leased per owner at once.
This is a capacity estimate, not an allocation or final catalog size. Different players reuse the entire pool.

With client-distinct envelope variants e, the conservative law becomes sum over (f,e) of M_(f,e). If all six slots
may choose any variant, each independently selectable variant may need six copies. Restrictions on legal loadouts
can reduce capacity; genuine reviewed runtime envelopes can merge compatible variants. One ID per exact magnitude
is unnecessary if a correct per-cast magnitude adapter exists; different target/activation/projectile semantics
cannot be merged just because damage values match. Owned inactive instances do not increase global ID demand.

| Native identity concern | Future rule |
| --- | --- |
| Action bar and spellbook | Distinct leased ID per active instance; update projection atomically with loadout |
| Rank chains | Do not implement pool copies as ranks; rank replacement undermines independent identity |
| Own cooldown | Instance debt authoritative, projected onto current carrier |
| Category cooldown | Shared only intentionally; do not reuse native class categories accidentally |
| GCD | Explicit common player recovery group, independent of private instance debt |
| Charges | Future instance state; native proc charges are not an ability recharge model |
| Cast time/range/cost | Require a compatible client envelope; incompatible variants multiply pool size |
| Tooltip/name/icon | Static shell metadata; per-instance presentation requires later authored UI/data policy |
| Accepted delayed casts | Retain their original immutable revision/lease snapshot |
| Queued or late requests | No generation in packet; management generations alone cannot identify old button intent |
| Loadout changes | Later no-active/no-queued-cast gate plus reviewed reuse/quarantine and reconciliation policy |

An arbitrary timeout is not proof that an old native packet cannot arrive. A future swap policy must explicitly
define how in-flight transport, server spell queue and client action-bar replacement are drained or reconciled.
This remains a blocker to exposing multi-slot/loadout gameplay, not a reason to change the packet format here.

## 11. Cooldown identity

Source anchors: Player::_AddSpellCooldown stores by SpellID (`Player.cpp`, around 11239–11258),
HasSpellCooldown reads that map (around 16698), and category recovery expands across category members of the same
native family (around 11170–11206). Thus two Generic carriers sharing a category can still lock each other.
Spell::CheckCast checks spell cooldown and GCD; TriggerGlobalCooldown uses the native recovery category/manager
(`Spell.cpp`, around 5793/5816/9076). Different IDs do not establish independent category recovery automatically.

Future authority: cooldown/charge debt keyed by owner + AbilityInstanceId, with a hybrid native projection. Keep
this as separate future instance runtime state, not mutable fields in the shared resolved cast definition. Cooldown
groups and player GCD have their own identities. The shell is the client/native enforcement surface, not the owner
of persistent ability debt.

Invariant: changing, releasing or reacquiring a carrier MUST NOT reset or duplicate instance cooldown debt.
A future serialized swap preserves the instance's absolute expiry/recharge state, applies remaining debt to the
new carrier before enabling its button, and reconciles the old carrier without unlocking a still-active instance.
Do not blindly clear native cooldowns or transfer them twice. Unrelated existing cooldowns on a candidate carrier
must block/quarantine its use until their provenance is understood; otherwise the new instance may inherit foreign
debt. Shared groups and GCD are not cleared by moving an instance. Reconnect needs later persistence/reconciliation.

None of that authority exists in A.6. The registry never calls Player cooldown APIs, and the existing native cooldown
behavior is unchanged. Current callers must not interpret successful lease bookkeeping as permission to swap a
live ability around its cooldown. No gameplay path exposes these prototype management methods to players.

## 12. Cost/resource identity

Phase A/A.6 cost remains native-authoritative. `Spell::prepare` obtains m_powerCost through CalcPowerCost;
CheckPower checks availability and TakePower performs the native debit. School cost auras and spellmods can affect
the result. Relevant source: Spell.cpp around 3544/3955/5418/7322; SpellInfo.cpp around 2812.
The pool/catalog adds no mana charge and bypasses no check.

Future separation, DESIGN ONLY:

- ResolvedResourceCost: instance/build resolution, resource type, cost basis, amount, modifier order and version.
- NativeCarrierCostEnvelope: what native data and client feedback can represent, including base/percentage basis,
  known native modifiers and allowed instance variation; not an extra payable fee.
- Actual server debit: one cast-commit path, using one authoritative amount after final checks and native failure rules.

Prefer adapting the existing native computation/debit once if a later reviewed core seam can expose the resolved
cost correctly to native checks/procs. Never debit once in native code and again in Ulduar. If client feedback cannot
represent a resolved change faithfully, select a matched cost profile or reject that build; an addon tooltip alone
does not fix native availability checks. The client must not advertise 30 Mana while the server spends 80.
Refund-on-fail, interrupted casts, zero-cost casts, cost-required procs and school modifiers need the same resolved
amount/provenance. No ResourceService, advanced resource model or new cost override is implemented.

## 13. Range/cast-time envelope policy

These classifications separate server feasibility from client presentation. The proprietary client was not run;
exact feedback and local acceptance remain RUNTIME_REQUIRED. A narrower server rule is not implemented merely
because native validation could be extended later.

| Proposed variation | Classification | Current source boundary |
| --- | --- | --- |
| Exact native range/activation | EXACT_MATCH_REQUIRED | Current production contracts retain native checks |
| Client 40 yd, instance 25 yd | SEMANTICALLY_SAFE_BUT_UI_MISMATCH | Future root validator; no primary override today |
| Client 25 yd, server 40 yd | UNSAFE | Client may prevent acquisition/send |
| Ranged friendly heal as contact | REQUIRES_CLIENT_PROFILE | Native reach/target feedback must match |
| Hostile/friendly or Unit/area change | EXACT_MATCH_REQUIRED | Target policy is not a numerical envelope |
| Native 2.5 s, multiplier 0.8 | SEMANTICALLY_SAFE_BUT_UI_MISMATCH | Server scaling exists; client evidence required |
| Native CastTime to Instant | REQUIRES_CLIENT_PROFILE | Multiplier cannot convert activation |
| Slower than multiplier 1 | UNSAFE through current API | No reviewed general slow override; no clamp abuse |
| Projectile delivery/school conversion | REQUIRES_CLIENT_PROFILE | Native speed/visual/school must agree |

`Spell.h::SetCastTimeMultiplier` accepts 0.5..1.0, minimumMs at most 600000, only untriggered non-channel casts
before target selection in NULL/PREPARING state. Spell.cpp applies it to the native calculated cast duration;
the minimum is a clamp and can affect the final value, not authorization for arbitrary new timing semantics.
It does not implement channels, a zero multiplier or a general cast-time setter. Phase A Forge runtime inherits
native timing; this phase adds no modifier or broader override.

`Spell::CheckRange` uses relation-sensitive native range and reach/leeway rules, including the melee range flag.
`SetTriggeredTargetValidator` applies only to directly triggered payloads; it is not a root contact validator.
The existing secondary target resolver rechecks relation, native legality, world/map/phase, distance and LOS.
Changing secondary search radius does not change the carrier's primary acquisition range.

## 14. Visual profile policy

DESIGN ONLY: CarrierVisualProfile has key/version, cast/impact visual references, missile visual/model, speed policy,
sound references, icon and explicit fallback policy. Visual identity is independent of CarrierFamilyId and instance
identity. A.6 uses no per-instance visual selector and creates no assets.

Native reuse candidates from the local DBC research: Holy Light's SpellVisual 2936 is a direct-heal presentation;
Holy Bolt's 7873 has a missile and model reference 224. Those are existing visual references, not custom SpellIDs or
approved standalone assets. Review referenced kits, model, sound, attachment and timing transitively before reuse.
Neither candidate supplies a reviewed contact-heal or Physical contact-damage presentation by implication.

One predictable reviewed visual per shell/envelope is the initial policy. Missing critical projectile presentation
blocks eligibility; fallback to an invisible/direct hit would change the delivery contract. A noncritical icon or
sound fallback must be named and hashed in the manifest. Missile speed participates in native travel scheduling
as well as presentation, so it cannot be treated as a cosmetic-only free choice.

## 15. Client/server manifest requirements

DESIGN ONLY. Integrate into the existing [Forge content manifest](../architecture/ULDuar_ABILITY_FORGE_ARCHITECTURE.md),
not a second release authority. No handshake or client patch was added.

```text
CarrierManifest
  manifestVersion, releaseId, carrierCatalogVersion/hash
  canonicalSpecSchemaVersion, canonicalSpecHashes, exporterVersion
  entries[{specKey/version, family, envelope, copyIndex, allocatedSpellId,
           canonicalSpellRowHash, rangeRefs/hashes, castTimeRefs/hashes,
           visualDependencyRefs/hashes, iconRefs/hashes}]
  serverDefinitionHash, effectiveServerOverrideHash, scriptBindingHash
  clientPackageHash, perFileHashes, nativeClientBuild/inputHashes
  core/moduleRevision, resolverVersion, supportedProtocol/releaseRange
```

Needed data later: Spell.dbc; reviewed SpellRange.dbc and SpellCastTimes.dbc references or new rows if necessary;
SpellVisual.dbc and transitive visual/model/sound dependencies; SpellIcon.dbc/assets; optionally SkillLineAbility for
spellbook presentation. Optional SQL spell_dbc overrides are a server representation, not substitutes for client
rows. Module definitions, SpellInfo loading/corrections and native script binding must agree with the same release.
The current LegacyDefinition runtime adapter must eventually gain reviewed custom definition registration.

Specify canonical byte encoding, ordering, absent-field representation and hash algorithm. Canonical row hashes
must not depend on incidental DBC string-block offsets. Also hash final package files to detect partial distribution.
Review the effective post-correction server fields against the canonical intent. A future mismatch suspends affected
custom casts/commits without deleting instances; a client-reported hash is compatibility information, not anti-cheat
proof. No live package, effective DB state or active client load order was attested in A.6.

## 16. Future data authoring pipeline

1. Author versioned CanonicalCarrierSpec, envelope and visual references with unresolved values explicitly absent.
2. Review all required decisions; validate semantic invariants, resource/target/activation, side effects, dependencies,
   reserved-ID collisions, pool capacity, rank/category independence, native corrections and script associations.
3. A later pure exporter derives the server definition/data representation and client DBC representation from that
   same input. If SQL overrides are selected, generate them from the same canonical source; do not hand-maintain
   three independent C++/SQL/client copies. Export into isolated staging artifacts, never into a live installation.
4. Compare decoded outputs to the canonical spec and effective core interpretation; produce the release manifest.
5. Package matched client/server artifacts with rollback and compatibility metadata under later delivery authorization.
6. Separately authorize build/tests and isolated client/server acceptance before eligibility or distribution changes.

No exporter skeleton, generated DBC, SQL, patch package, asset or generator execution is part of this phase.
The source catalog is an adapter boundary for that future pipeline. Its placeholder fields are not a second complete
authoring schema. Spec changes must version the profile/catalog/manifest coherently rather than silently reinterpret
an existing lease. Exact rollout/ownership/persistence policy remains deferred.

## 17. Integration with existing registry

Seven existing files intentionally changed:

- AbilityCarrierContract.h: family identity and appended lease family/version fields.
- AbilityInstance.h/.cpp: PendingCarrierData, CarrierFamilyMismatch and PoolExhausted diagnostics/names only.
- AbilityCarrierRegistry.h/.cpp: owned immutable catalog, allocation method, catalog-gated exact registration and
  dispatch recheck. Existing maps, revision history, generation tombstones, snapshots and one-slot guard retained.
- AbilityManager.cpp: existing RegisterForgeCarrier sends its one reviewed contract to family-pool selection under
  the same lock. No new management command, native spell grant or public player flow.
- tests/AbilityForgePhaseATest.cpp: explicit synthetic catalog fixtures and fifteen additional pure tests.

Two new source files provide the catalog. Existing source discovery collects module src files; the test file is
already registered in mod-ulduar-abilities.cmake. That registration was inspected, not executed or changed.

RegisterBinding remains callable for trusted exact-spell operations, but cannot bypass catalog validation. A pending
entry with an accidentally assigned ID, unknown/duplicate catalog ID, unsupported status or mismatched family/profile
cannot reach BuildCarrierRuntime. The catalog does not mint a supported CarrierContract from metadata alone.
ResolveCarrier checks family/catalog/entry stamps plus the existing identity/revision/generation invariants. A stale
or invalid Forge match remains Invalid, so the unchanged SpellScript CheckCast seam rejects instead of falling
through to native/legacy execution. An unbound native spell still returns None and uses the existing native path.

The reviewed unchanged dependencies include AbilityManager.h, AbilityInstance resolution, CarrierContract review,
AbilityRuntime/AbilitySpellScript, AbilityTypes/Definitions, AbilityPropagationResolver, AbilityTargetResolver and
SecondarySpellExecutor. Relevant Spell.cpp/.h, SpellInfo.cpp/.h, SpellMgr.cpp, SpellHandler.cpp, SpellEffects.cpp and
Unit.cpp/.h were inspected for the design boundaries above. No core file was edited in A.6.

Impact remains on each resolved AbilityInstance and its captured cast/event; the catalog stores neither current
propagation mode nor coverage counts/radius/multiplier. Existing CarrierContract adapter capability checks can say
that Impact execution is available without storing an instance's Impact values. No WithImpact/Chain/3Targets family
or second propagation engine was created. The A.5 ResolvedCoverage bridge remains design-only, with legacy EP and
ResolvePropagationStats formulas unchanged. There is no second application of coverage or payload scaling.

Acceptance by inspection:

| Requirement | Evidence/boundary |
| --- | --- |
| Independent family and instance identities | CarrierFamilyId, NativeSpellId and AbilityInstanceId remain distinct |
| Catalog separate from ownership | Entry has no owner/instance/slot state |
| Explicit native/custom provenance | Origin, status, metadata policy and source/spec versions |
| Pending cannot bind | Selector skips pending; RegisterBinding independently rejects pending |
| Unique dispatch projection | Existing registry only |
| Owner/slot/generation lease identity | Existing binding extended, not duplicated |
| Same-owner collision protection | Existing collision guards plus allocator occupancy check |
| Cross-owner reuse | No global occupancy map; per-owner registry |
| Explicit exhaustion | POOL_EXHAUSTED and no mutation/fallback |
| Reviewed native exceptions | Sole production ID 635 plus unchanged real-data review |
| Neutral spec defaults | Generic/zero masks with contamination checklist; no immunity claim |
| Coverage separate | Instance snapshot/old adapter retains coverage; catalog only references profile |
| No invented final IDs | Four null optional IDs |
| No persistence/client mutation | Source/doc changes only; preservation inventory below |
| No build/test execution | Only read-only style/source/hash tools used |

## 18. Tests authored but not run

TESTS_AUTHORED_NOT_RUN: 39 total = 24 prior + 15 new. EXECUTED: 0. COMPILED IN THIS PHASE: 0.
All cases below are AUTHORED_NOT_RUN and TEST_AUTHORED_NOT_RUN evidence only. No result is inferred from inspection.
They use pure synthetic instances/contracts/catalogs; no new case constructs Player, SpellInfo or a live cast.
The original three integration-fixture cases are retained unchanged and remain unexecuted.

| New UlduarForgePhaseA6 case | Intended invariant / static scope |
| --- | --- |
| FamilyIdentityIsNotSpellIdentity | Compile-time type separation declarations plus distinct profile mapping |
| PendingCustomSpecificationsCannotLease | Four placeholders have absent IDs; lease fails without mutation |
| NativeExceptionIsCataloguedWithoutPromotingResearchCandidates | 635 catalogued; 1495/31759/34232/later rank absent |
| OwnerCannotLeaseSameCarrierTwice | Collision/exhaustion leaves original lease intact |
| DifferentOwnersReuseGlobalCarrier | Two registries bind the same synthetic global ID independently |
| LeaseRefreshAdvancesGenerationAndStampsCatalog | Refresh increments generation; stamps match; stale refresh rejects |
| EmptyPoolFailsWithoutFallbackOrMutation | Empty catalog returns exhaustion and no slot generation change |
| IncompatibleFamilyCannotLease | Requested family mismatch and direct-registration catalog mismatch reject |
| InactivationReleasesLeaseWithoutDestroyingInstance | Release advances tombstone; instance remains resolvable |
| ReactivationRequiresNewGeneration | Old generation rejects; current tombstone gives new lease generation |
| ImpactChangesSnapshotWithoutChangingShellCatalog | New propagation snapshot retains shell family/version |
| PendingEntryWithAccidentalIdStillCannotBind | Direct registration rejects pending even with a concrete synthetic ID |
| UnsupportedAndFutureEligibleStatesCannotPromoteCustomData | Neither reserved/unsupported state enables custom rows |
| DuplicateCatalogIdentityFailsClosed | Duplicate native IDs reject lookup and registration |
| AllocationUsesCatalogOrderAndKeepsOneActiveSlot | Catalog priority retained; free second ID cannot enable slot 2 |

Ten existing Phase A registry fixtures now inject an explicitly synthetic catalog so their original arbitrary test
IDs do not appear in production. Original test assertions and intent are retained. Synthetic IDs 900001/900003 are
fixture data, never proposed reservations. Existing 24-case quality limitations remain as recorded in A.5.
The Impact case demonstrates use of the same shell; absence of coverage fields is additionally a structural review
fact, not something that merely checking an external catalog copy proves. Type static_asserts are not evaluated here.

Later runtime requirements: real ReviewPhaseACarrier/SpellInfo gates and scripts; manager mutex/readiness/legacy
collisions; actual native dispatch rejection and no-binding parity; spellbook/action bars; real target/cost/range/
activation and GCD/cooldown feedback; in-flight snapshot retention; queued-packet swaps; native proc/aura interaction;
effective manifest/client data. These tests cannot establish any of those behaviors by themselves.

## 19. Preservation

Before editing, a SHA-256 inventory recorded 151 existing files, including untracked module/docs/client files,
the five pre-modified core files, both pending Ulduar SQL files and six native DBC copies. Git status was captured
as additional evidence, not as a substitute for hashing. Final comparison: 7 intentionally changed existing files,
144 byte-identical baseline files, 0 missing/removed files and 3 new files.

Existing files intentionally changed:

- `modules/mod-ulduar-abilities/src/AbilityCarrierContract.h`
  - Before SHA-256: `7fd29f7bcc68659a7e3cb4a497dd94bf8a7ce0075f08a5ef88727e0b78f299d3`
  - After SHA-256: `4a3c9b9eaa6524bf3d12532526df54abdf9bc9057892883fa8e0837cc672a325`
- `modules/mod-ulduar-abilities/src/AbilityCarrierRegistry.cpp`
  - Before SHA-256: `48390148f145eff057514d4e28a556e17225901486d3166caf03a01fdf3bdbc9`
  - After SHA-256: `05d524420b07783f44c2610b9836b46c21f3f6dd336665954654fdf3c721338f`
- `modules/mod-ulduar-abilities/src/AbilityCarrierRegistry.h`
  - Before SHA-256: `808a0a7449432211c2c46a9c256d9a0cd6ff7d7e92a4353190812b957ad655ac`
  - After SHA-256: `9742af858706e91e2e399deca6372882876f4f04c7ba2c0f689ed3d209c14498`
- `modules/mod-ulduar-abilities/src/AbilityInstance.cpp`
  - Before SHA-256: `d34a04dc6edc5349f217b1a33cfa476ba24bddd2e3167b08e898dba89a94f52c`
  - After SHA-256: `e2133f0265a245bd31c5582bcd663bb1b3be5db2bedaace3d6ae7ea29578ff5e`
- `modules/mod-ulduar-abilities/src/AbilityInstance.h`
  - Before SHA-256: `617eda1d852cf7d1c0429f21e706982208abf57bdceca9c1d63be45fac06a830`
  - After SHA-256: `228f0cb12edf38db7f6a5422b3d88c52a965272452587c8414759a0fae255db7`
- `modules/mod-ulduar-abilities/src/AbilityManager.cpp`
  - Before SHA-256: `cb5365435635d03cfb976010a127a3a79a0e9584f168d30372116c7c6e42961b`
  - After SHA-256: `dd936a24fb5b2a47a8972e0f49a559475fcfbb46775bf35e2ed0bb8d53b5cee9`
- `modules/mod-ulduar-abilities/tests/AbilityForgePhaseATest.cpp`
  - Before SHA-256: `931ce13ce05cb0fba72c21d5c9e879d67950b8902a9f50327d2dd6f60e6ca3fa`
  - After SHA-256: `f28d1631d95401f9748b92850d37d1c9ca8b361d874e08468fc3c98f588ec8be`

New files:

- `docs/implementation/ULDuar_PHASE_A6_CUSTOM_CARRIERS.md`
- `modules/mod-ulduar-abilities/src/AbilityCarrierCatalog.cpp`
  - SHA-256: `13f6aae992229b14e22ee6159a346e4d71ddec64c1272dc2d17c01c371cd5b7c`
- `modules/mod-ulduar-abilities/src/AbilityCarrierCatalog.h`
  - SHA-256: `0f463d7621e8c759cc65a995915418093bd960186f6a3221e3b45591c5e8727f`

The report excludes its own final hash to avoid a self-referential checksum. No files were removed. All other
144 baseline files listed below remain byte-identical, including architecture/prior reports, core changes,
existing client files, DBC copies, SQL, definitions, propagation/target/executor code and module build registration.
AbilityManager.cpp now uses LF throughout; its sole behavioral edit is the catalog lease call described above.

Pre-edit root Git status:

```text
 M src/server/game/Entities/Unit/Unit.cpp
 M src/server/game/Entities/Unit/Unit.h
 M src/server/game/Spells/Spell.cpp
 M src/server/game/Spells/Spell.h
 M src/server/game/Spells/SpellEffects.cpp
?? client/
?? data/sql/updates/pending_db_characters/ulduar_abilities_004_characters_modifiers.sql
?? data/sql/updates/pending_db_world/ulduar_abilities_003_world_starters.sql
?? docs/
```

Pre-edit module Git status:

```text
 D conf/my_custom.conf.dist
 D data/sql/db-world/skeleton_module_acore_string.sql
 D src/MP_loader.cpp
 D src/MyPlayer.cpp
?? CMakeLists.txt
?? DRAFT_BUILD.md
?? MODIFIERS_BALANCE.md
?? PROPAGATION.md
?? README.md
?? STARTER_ABILITIES.md
?? UI_CONSOLIDATION.md
?? conf/mod_ulduar_abilities.conf.dist
?? data/sql/db-characters/ulduar_abilities_001_characters.sql
?? data/sql/db-characters/ulduar_abilities_002_characters_propagation.sql
?? data/sql/db-world/ulduar_abilities_001_world.sql
?? mod-ulduar-abilities.cmake
?? src/AbilityAddonProtocol.cpp
?? src/AbilityCarrierContract.cpp
?? src/AbilityCarrierContract.h
?? src/AbilityCarrierRegistry.cpp
?? src/AbilityCarrierRegistry.h
?? src/AbilityCommands.cpp
?? src/AbilityDefinitions.cpp
?? src/AbilityDefinitions.h
?? src/AbilityInstance.cpp
?? src/AbilityInstance.h
?? src/AbilityManager.cpp
?? src/AbilityManager.h
?? src/AbilityPlayerScript.cpp
?? src/AbilityPropagationResolver.cpp
?? src/AbilityPropagationResolver.h
?? src/AbilityRuntime.h
?? src/AbilitySpellScript.cpp
?? src/AbilityTargetResolver.cpp
?? src/AbilityTargetResolver.h
?? src/AbilityTypes.cpp
?? src/AbilityTypes.h
?? src/SecondarySpellExecutor.cpp
?? src/SecondarySpellExecutor.h
?? src/UlduarAbilities.cpp
?? tests/
```

After editing, root Git status is unchanged (the affected documentation/module contents are already untracked).
Module Git status differs only by the two newly untracked catalog source files; the four pre-existing skeleton
removals were preserved and were not caused by A.6. Exact changes inside untracked files are recorded by hashes above.
No reset, clean, commit, SQL changes or client/data writes were performed.

The inspected pure Python C++ codestyle scanner reported no findings for module src. A separate read-only text
inspection checked edited C++/test whitespace and line widths. These are static source checks, not test execution.
SQL lint was not run: no SQL changed and that scanner includes a Git remote fetch. The pinned-commit PR workflow
is inapplicable: this is a local source-only deliverable and the user explicitly prohibited committing.

Full pre-edit SHA-256 inventory (path followed by hash). Paths are repository-relative except the six external
DBC copies. This records untracked content durably; the seven changed entries have their new hashes above.

<details>
<summary>151 pre-edit file hashes</summary>

```text
C:/WoWProjecto/a/Data/dbc/Spell.dbc
d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3
C:/WoWProjecto/a/Data/dbc/SpellCastTimes.dbc
919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec
C:/WoWProjecto/a/Data/dbc/SpellRange.dbc
82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f
C:/WoWProjecto/ulduar-build/bin/RelWithDebInfo/Data/dbc/Spell.dbc
d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3
C:/WoWProjecto/ulduar-build/bin/RelWithDebInfo/Data/dbc/SpellCastTimes.dbc
919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec
C:/WoWProjecto/ulduar-build/bin/RelWithDebInfo/Data/dbc/SpellRange.dbc
82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f
client/Interface/AddOns/UlduarAbilities/ASSETS.md
f84c30c48214631b627a0138af5d2a9c322b5000978e189063131122f8bdea31
client/Interface/AddOns/UlduarAbilities/AbilityDetails.lua
a092c79425626280a950758567833025d7d023419d4957c4b65dbf2397162d20
client/Interface/AddOns/UlduarAbilities/AbilityList.lua
0315871d9b7379ae7d3f9a4814326b0917d0eff5fa737ea0fcb23f81fdd6d046
client/Interface/AddOns/UlduarAbilities/AbilityTooltip.lua
01efc09a64a534dae029c85c82bb8cc102acc1b493feecf357b8a63a8944a579
client/Interface/AddOns/UlduarAbilities/AbilityTree.lua
9727a92b35be84390d896f97e4dbe256127a5553e3db0c293aed34c955987e97
client/Interface/AddOns/UlduarAbilities/Core.lua
244a81ce17b013182fad8259c2ff82db71af76b706f385d5212be6dffe4856a9
client/Interface/AddOns/UlduarAbilities/DESIGN.md
6ece646b85f2cfc933ad6430b968e5397ab2872ff8877f04704948dc2edd031d
client/Interface/AddOns/UlduarAbilities/DraftBuild.lua
509397dbe7704ccdcec231e7cbd8cc882b5f3cfadf73852edeb1fb75f9cad29b
client/Interface/AddOns/UlduarAbilities/PROTOCOL.md
927327e78d023512ac53cb04faf28e6d2db8919ee692f780ea9a901e17bc71ee
client/Interface/AddOns/UlduarAbilities/Protocol.lua
f6c0dbe785499eab93ce28ef84ab590ede236651688cc7806d6a8ef956dbfb36
client/Interface/AddOns/UlduarAbilities/README.md
4c07c299a6c3f7c85ba2a6bc0b7767dcc6afc2e89dde56124115980c946efb7a
client/Interface/AddOns/UlduarAbilities/SpellBookIntegration.lua
8e23f812845dd1c634343132a24b4c3d1d4f06310c374590611b4562e2c5b780
client/Interface/AddOns/UlduarAbilities/UlduarAbilities.toc
e5953ec5a1dc0dbb47b5ae8bd148f568c3e6af0dcacd4a185a0225b6fd860b3c
client/Interface/AddOns/UlduarAbilities/UlduarFrame.lua
ff20abd3c478463a41f1627f77ed729347fb2bc59169cc4298236a65540a8222
client/Interface/AddOns/UlduarAbilities/UlduarMicroButton.lua
b6f23728a4f5d9bd8b125fe9fe6d287a3d7d017abbdb937299c420ad7d001006
client/Interface/AddOns/UlduarAbilities/Views/UlduarTemplates.xml
6035ad41160d01497b21436789de4140cfc4db4c9d7c065af30466c4593f911d
client/Interface/AddOns/UlduarAbilities/Widgets/Connections.lua
32cea50af4aec3e9080f77abc5e4e1f4617e81223639c9c2e50b920105a44542
client/Interface/AddOns/UlduarAbilities/Widgets/Node.lua
442aee74e3ab866750e8360482b199a02aeb3d7ed9feb0dd19669d77dfd5bdc2
client/Interface/AddOns/UlduarAbilities/Widgets/ScrollList.lua
9179f0a44845fe687d0cc409cefe7a79e79daa42607d72aa479749f0f2b38716
client/Interface/AddOns/UlduarAbilities/Widgets/Tabs.lua
a4af3732056826b3a5b876ea9032df64d2b7361e39898366cfa4c7dd4e483131
client/Interface/AddOns/UlduarAbilities/Widgets/Theme.lua
b7cced4e238e6f1d0024d8fcf8a2022f1c20c7c7ad13b7dde4606395993cdb3d
data/sql/updates/pending_db_characters/ulduar_abilities_004_characters_modifiers.sql
d46221e3eb0115a9f174eb200232493b95870b95e8872edce3c54e2cde5f4b33
data/sql/updates/pending_db_world/ulduar_abilities_003_world_starters.sql
a99cb7ee060512decfe73378a65bcf28f1a7fbf4557a089db6b2eeaa2f51f84a
docs/architecture/01_SYSTEM_OVERVIEW.md
c3c6f1dc0bdb680f2543677046bfe74a63c18c647a3023a31eca476528b51835
docs/architecture/02_ASCENSION_ARCHITECTURE_ANALYSIS.md
397639308abb607c4d539f08cd0f4d9ee392f9836808369edad2dc995933c7f3
docs/architecture/03_ASCENSION_SHAREDXML.md
e1ce677f392434d9a3b8652b5a5a3442ffa7dabb53a477b99e693ecfd51ebc2d
docs/architecture/04_ASCENSION_CHARACTER_ADVANCEMENT.md
e3eb1410945b362ebbe79de54425cfb5a742bd56677d736c2eb271240de83706
docs/architecture/05_ASCENSION_FRAMEXML.md
3df3debb5afd7e25f15f490ef78b49caf6b42c5b74798c8ea2b82a42a74dba39
docs/architecture/06_ASCENSION_MICROBUTTONS.md
6d981a6fe4a5f111339d65c9199c9286a94a978b0bc8f5b25c9623dada068402
docs/architecture/07_ASCENSION_SPELLBOOK.md
7c0fe54fd940a3ada5f0c7985b493c52ebdb40d3ef386b83afa2773fb751a168
docs/architecture/08_ASCENSION_TOOLTIPS_AND_MODALS.md
5d9b5473484af9f9e4eb2bc64fce295032e307b4d86dad6b58506992621a2b52
docs/architecture/09_CURRENT_ULDUAR_ARCHITECTURE.md
2734ed17f1745b89393e06ca6e72c1bfeadfc83c5b7535de5db78023380a3dac
docs/architecture/10_TARGET_CLIENT_ARCHITECTURE.md
2fc0da1c7066f6e4e0a146f6b7b3936cec1f62255b7426c71abd4e2d7e42acb7
docs/architecture/11_ULDUAR_SHAREDXML.md
ac7f7cd80aac9f61d2848894a176e31114dfe6dff2aed4ac145211ea36661e76
docs/architecture/12_ULDUAR_UI_FRAMEWORK.md
95bba42fcb6fe1db4ff20ce352a8746d3219c5e139b81cc44add5a69f43718ac
docs/architecture/13_ULDUAR_WIDGET_SYSTEM.md
5f09e407bd45bf0140d6e515ebee92142b128e33fda580220d9341d428045d13
docs/architecture/14_ULDUAR_XML_LUA_RULES.md
4b9ff9c6d5dbf6e0d187e773eb6dd09383907cdb00643776f5bb09a039cdf15f
docs/architecture/15_ULDUAR_ABILITIES_ARCHITECTURE.md
09b6effee57acef0d693f25023eef0efa2e197d2835cbe678315763413f6069a
docs/architecture/16_ULDUAR_PROTOCOL.md
6ed5d510161c498ba5a52c492fd58ff9cb582bcc923341cc84b58fdeb6e80694
docs/architecture/17_ULDUAR_UIEDITOR.md
adc3babc1dc3a61f4b19256ce9cc008e489eb6f5570481641614058f1f424607
docs/architecture/18_ULDUAR_DEVELOPMENT_TOOLS.md
e450207e16d65fc72eca838df6cfb6da7e7ecd7ceff964f561c323b85d565f54
docs/architecture/19_FRAMEXML_STRATEGY.md
4047659a40568386d6d883988a81a18674c6ca26adbcd904dd5b976d0ab0fcb1
docs/architecture/20_GLUEXML_STRATEGY.md
0b89df52ccdffd55c0934e9ad1724537be1b2a14125ca364da89816a31bb0230
docs/architecture/21_LIBRARYXML_STRATEGY.md
9eb362da4bd40cfc44d7530549ad5c80fb20dfcc820f15a22d2a400d66e93463
docs/architecture/22_MPQ_PATCH_STRATEGY.md
873fed84b69a1a25e6463eb2a6f040eb302fca9cff56ef8014b8767d73218306
docs/architecture/23_ASSET_ARCHITECTURE.md
7e459e2d6f203a2099714cacb5c18abde9a2a90138c68d2ab079a9dbd061b0f1
docs/architecture/24_LOAD_ORDER_AND_DEPENDENCIES.md
c7cacb2e529028144345122c8841948604db9c1fdd8097c9a37d2243ff8c2f34
docs/architecture/25_SERVER_CLIENT_BOUNDARIES.md
961e2989b83f943487d77f0fd4e207a03faa55f7a805bf700785974dbc5e9f9e
docs/architecture/26_SECURITY_AND_AUTHORITY.md
36c4975f1a57f17168e38f07bd9c6718f962bc8d39803c7e41076dd0452a3e0c
docs/architecture/27_MIGRATION_PLAN.md
ef4caff9f2e64f805d2aae34665818c2d73a7e3ba99bc4b11ea6c87118f5000c
docs/architecture/28_IMPLEMENTATION_ROADMAP.md
bb894a9edd77326f55adcd524695a9c6e73dbe19a9372c8fd204b0334fe49396
docs/architecture/29_CODING_CONVENTIONS.md
2895ab1eb35414e72d36ef7f3c21046d1606d02aa786b64594caefcbcdf431e3
docs/architecture/30_RUNTIME_TEST_PLAN.md
0b0f914d1e6a3d62330083ac5ea26bd961f9f6611040c307f2c97e9b1cb4fe2d
docs/architecture/ARCHITECTURE_DECISIONS.md
df783a53b5b201546b34556da6c1026953f9bf47f3b3e4b77c48669efffcf129
docs/architecture/ASCENSION_CLASSLESS_BASE_AUDIT.md
4f817197425f0fad310ff75a5a98656b6f629765e93ed3af31e87bfd062f05f4
docs/architecture/ASCENSION_REFERENCE_MAP.md
5c9d39a6d2708fb7e443dc84f76fd56037d0be25778e613776c1d54643d32c6c
docs/architecture/ASTORIA_CLASSLESS_AUDIT.md
9971f98dda6d340bf34e5e6da9d19dbeed3a088c3ab9fe458412e091c631e640
docs/architecture/CLASSLESS_BASE_COMPARISON.md
573c57ba4d283b82a11745f33f00f836fa8c1eb8e825158e47f57cf35ff73b55
docs/architecture/CLASSLESS_PORT_MATRIX.md
61b40ed1556ad37d0ae2ad891092196258e8320b8e220c55710cba6fba0a0481
docs/architecture/CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md
6ab650ce892b6bc5b67f3c24b97fd15e7b48b7b21dbd6069a547ec246e657fee
docs/architecture/CLASSLESS_WILDCARD_PORTABILITY.md
fd420598c0db94eef5aba73111a2105b62f679808e43251e0b66dfbbf87dd9e0
docs/architecture/GLOSSARY.md
666315aee365b1654f160aca05fcc5d522d7ec57f33879ce2d97d2a56102ce43
docs/architecture/README.md
84f4971ea6a964315184fe9bb65c09e5a4ada78c5ea849d5a5bbcf155067e7ab
docs/architecture/ULDuar_ABILITY_FORGE_ARCHITECTURE.md
00c78ff44d9863a5b0b8735d5f340c812d83ee4478afc1d9a9894ac809df8256
docs/architecture/ULDuar_ABILITY_METADATA.md
1a8e1729969cedb0231db98a0cb4ab9802ad2617f124e7077282303a2aa747a3
docs/architecture/ULDuar_ARCHITECTURE_AMENDMENTS.md
2fcaf55d402a38fc86be400d8fdf408a5d4142c0c614871b15c69aa15b12b005
docs/architecture/ULDuar_CLASSLESS_ARCHITECTURE.md
26e71786f21ceb87d68ee8807e7ecb5aee8aabbb080b1d8c88d4e77dd66c21f1
docs/architecture/ULDuar_EXPERIMENT_PLAN.md
c671cdd862cf44a85c42ae6868dca51661f7bf40c424ed3d55c656c6499ce0ce
docs/architecture/ULDuar_GAMEPLAY_ROADMAP_V2.md
5b6402320e42557f81deedc6bf3e354677a834d5179f7661ea89336af7d0a6db
docs/architecture/ULDuar_GAP_ANALYSIS.md
21429404cc974d55959463783b8a7877c19ac81528e792ecd6d20de3f73202e9
docs/architecture/ULDuar_GEM_COMPATIBILITY.md
76f137c5e3504c2d882ad50b33c022a1d3b87a71e7cc985125f12fba3009760a
docs/architecture/ULDuar_GENERALIZED_TALENTS.md
8990dd4aaefdc851832b869352438d2f9efe225258a33e74389b984d4ec56ac9
docs/architecture/ULDuar_GENERIC_STATS.md
114fa22c9c3258d3bc00a6305453e772dfbcf3c840c2f5efa92a395d8a1e6858
docs/architecture/ULDuar_PROGRESSION_ARCHITECTURE.md
1144e286cb1d262f062bc4344b6103aaa07a8f8fd2bfb0da301c26196f6f03c4
docs/architecture/ULDuar_QOL_REFERENCE_AUDIT.md
9ac3e6a658ae98da998e430e57043c726b044ff4834b2a1591d2bd42b8f9deab
docs/architecture/ULDuar_RESOLUTION_PIPELINE.md
c5f2783efab92915107a8d7ca2ec0992af095d5517e1471420768589faed7795
docs/architecture/ULDuar_SPELL_TAXONOMY.md
8eebbf7fa7a2540b94d541ef0b04fddceaef482bab8bba5fad44cac02086dff4
docs/architecture/ULDuar_TALENT_CONVERSION_PIPELINE.md
61bdf57cc30258f7e7f6fa20ae3146fc3732db10c0732d701a5a1aebde5969e2
docs/architecture/ULDuar_UNIVERSAL_TALENT_LIBRARY.md
ab7dc255f807a5c637c11d3e4ebb4a842562830439073965f04236ce20305931
docs/architecture/ULDuar_UPDATED_ROADMAP.md
6b1a7d534d98ef69d8813e34452dae42587c768a7417184d11b9e1c0c9a9b4bb
docs/architecture/ULDuar_VERTICAL_SLICE_V1.md
a2506520105bbda0ce05563519a903193c4c07a3e73d976c4a02be6635040712
docs/implementation/ULDuar_PHASE_A5_SOURCE_REVIEW.md
985a10dad513cf1213771a67a1f7fad32f401d5aed7605c985c60066f764cbad
docs/implementation/ULDuar_PHASE_A_IMPLEMENTATION_REPORT.md
2a5d30772e3cd6b12ed3001041468abc2723dfb770913b8e2744137ddeb6bf85
modules/mod-ulduar-abilities/.editorconfig
bccd67aba0e1e079ca0e27930d37bc131901579ec5b1a8eea8f56c314cbc9d8e
modules/mod-ulduar-abilities/.gitattributes
3971e3c80f86414bd2a68747ec607c6ab0e3320a9253cb4373e5d6f1848c95ef
modules/mod-ulduar-abilities/.github/ISSUE_TEMPLATE/bug_report.yml
1f58dce003f1a84d023698393812d7ac8c59f6aed868dd5fa8f31a0e69a7e5df
modules/mod-ulduar-abilities/.github/ISSUE_TEMPLATE/feature_request.yml
3e00798f4519e17205aee81a3ae084a74f325a52ea09c86a760d1817ce981200
modules/mod-ulduar-abilities/.github/README.md
f3dc498e3688e167348415a7c362844a0b165148370dcc3e348c7ff3d3a10502
modules/mod-ulduar-abilities/.github/README_ES.md
09879f94b7c3862a80e4673304e58d641c3e83a0288726ebae32eaa0b23cec33
modules/mod-ulduar-abilities/.github/workflows/core-build.yml
5115ea7af3ca69c22bfa9b351164f7e35098d799b5611efe3e87e7ccf06d7f58
modules/mod-ulduar-abilities/.github/workflows/core_codestyle.yml
6d9022690423b8fa26072d0b8b6c8d840ec91874b9c11d69da631e7e274a3fbd
modules/mod-ulduar-abilities/.gitignore
f3021a440d7ab92aaab3d645bd2b167f23dcfc6013e91a74035d08f8c83ebf73
modules/mod-ulduar-abilities/CMakeLists.txt
ce63f796487dff22f4db22c598a6d3f13c863eba31cd66b19f466602d1fe9d39
modules/mod-ulduar-abilities/DRAFT_BUILD.md
7168576acc2d373557cb31254985d7f942fda162ad561c478d3d5be02012c109
modules/mod-ulduar-abilities/LICENSE
203a620948410283b0ca6c696133983ebd4050f1f258c5a66bfcb7f943190d5b
modules/mod-ulduar-abilities/MODIFIERS_BALANCE.md
1f51a0c6fcabc63506c5093b02f493e9f607c8645466e4f4be7b1294a4882fe5
modules/mod-ulduar-abilities/PROPAGATION.md
9a23a99297605669958d62c329cf9b88f29c8509af665160a8a454f0a3c9f615
modules/mod-ulduar-abilities/README.md
4874d27cf51faaf43d9e49ccaa5900f9db71343f290bc96b1afeefacb348f63a
modules/mod-ulduar-abilities/STARTER_ABILITIES.md
e13fc5551dc8a45cba4834107632cfe236390eccd9be7170b8dea56434c09e08
modules/mod-ulduar-abilities/UI_CONSOLIDATION.md
95a3554198031d24c5a43cc06235b89dc497538020fa0b5f05feb73d13163436
modules/mod-ulduar-abilities/apps/.gitkeep
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/apps/ci/.gitkeep
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/apps/ci/ci-codestyle.sh
3ca5ad904bac99a01722c731440fd0650de7e516f454795e2b5bf63f60852270
modules/mod-ulduar-abilities/conf/.gitkeep
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/conf/mod_ulduar_abilities.conf.dist
46dbfd9b13fceecd6e46340549998ecf9518c7d9c59584660bc47242e2ce1a99
modules/mod-ulduar-abilities/data/.gitkeep
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/data/sql/db-auth/.gitkeep
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/data/sql/db-characters/.gitkeep
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/data/sql/db-characters/ulduar_abilities_001_characters.sql
dc77850755b9ad19e6d36f2e73f380c979c378b0f52a16c15e047ca0c2296bd7
modules/mod-ulduar-abilities/data/sql/db-characters/ulduar_abilities_002_characters_propagation.sql
eec53b24f1c6a1426dd8c0ae188229f301dbfc01f9775825f530272eb86b1ee9
modules/mod-ulduar-abilities/data/sql/db-world/.gitkeep
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/data/sql/db-world/ulduar_abilities_001_world.sql
154d5cdf351e095723371c35b68747633a31440eb479ea4cd7bed4a2d54599b7
modules/mod-ulduar-abilities/include.sh
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
modules/mod-ulduar-abilities/mod-ulduar-abilities.cmake
8d60c44ae50ce9177eac1ac0bc68ade9f99f0c5615f58c21ed3e2b468c11154e
modules/mod-ulduar-abilities/pull_request_template.md
4ceb825eba26755d9e68fcca9d0e8faf5d3359f0f173a98af33f1a4292e58143
modules/mod-ulduar-abilities/src/AbilityAddonProtocol.cpp
71ba59585d0caa9b87a4847f44677d444b979f699e53c7aa578d9645c06b403d
modules/mod-ulduar-abilities/src/AbilityCarrierContract.cpp
cc754e3a778e961f8502f84fce0f862e1a72b40f565c1f2e823dac8cf80b8660
modules/mod-ulduar-abilities/src/AbilityCarrierContract.h
7fd29f7bcc68659a7e3cb4a497dd94bf8a7ce0075f08a5ef88727e0b78f299d3
modules/mod-ulduar-abilities/src/AbilityCarrierRegistry.cpp
48390148f145eff057514d4e28a556e17225901486d3166caf03a01fdf3bdbc9
modules/mod-ulduar-abilities/src/AbilityCarrierRegistry.h
808a0a7449432211c2c46a9c256d9a0cd6ff7d7e92a4353190812b957ad655ac
modules/mod-ulduar-abilities/src/AbilityCommands.cpp
c2485325ba4e2a68c6cccac223864e34d8bd2f32eda24c48a235fad6a884a78b
modules/mod-ulduar-abilities/src/AbilityDefinitions.cpp
ae73e221b5d7484a99626a9277253c7aa53749807abf6a0ee7633d6ecdcf094f
modules/mod-ulduar-abilities/src/AbilityDefinitions.h
a90b9686950a9ad29451fe33202a96d18a26b72bd5b491b8d0d43364191c8b84
modules/mod-ulduar-abilities/src/AbilityInstance.cpp
d34a04dc6edc5349f217b1a33cfa476ba24bddd2e3167b08e898dba89a94f52c
modules/mod-ulduar-abilities/src/AbilityInstance.h
617eda1d852cf7d1c0429f21e706982208abf57bdceca9c1d63be45fac06a830
modules/mod-ulduar-abilities/src/AbilityManager.cpp
cb5365435635d03cfb976010a127a3a79a0e9584f168d30372116c7c6e42961b
modules/mod-ulduar-abilities/src/AbilityManager.h
0e65bfc5660f1a1008a39c10236d3388d9414a048e5580a0bddd30f7b1060dc5
modules/mod-ulduar-abilities/src/AbilityPlayerScript.cpp
152b247875fd7298b4769e02dfb33f8c0eebcd82cd0b6fdd4692561a9c0e01e4
modules/mod-ulduar-abilities/src/AbilityPropagationResolver.cpp
508883c501a12336fdbdab112254603e338e5e47c549e93b17b5140df1377050
modules/mod-ulduar-abilities/src/AbilityPropagationResolver.h
f0bda28c236b8e7f3f20d09d2e7d2d225ee86fed0072d7016431fba1d3d5de72
modules/mod-ulduar-abilities/src/AbilityRuntime.h
4152f58adb65259dddb9db2abb5b7724fd1a38138ba41e7e9b29aac0b92a0556
modules/mod-ulduar-abilities/src/AbilitySpellScript.cpp
6b4fb064eab8fc75cbd90c173f87fc89165d736e0f207bcf7df47c1e22a30e3a
modules/mod-ulduar-abilities/src/AbilityTargetResolver.cpp
dbf57a46ed9de562ef204d1ee3ff0c49ce6f4db33a97117ac6c87543fba7b223
modules/mod-ulduar-abilities/src/AbilityTargetResolver.h
95415adf15ffeb689ea1b002472d466fb0b24fb55bef721b9f5f298494024ef6
modules/mod-ulduar-abilities/src/AbilityTypes.cpp
bc7e796d072429ce8878f4056a9df30b6d5e4758b6922605152cc416f50424aa
modules/mod-ulduar-abilities/src/AbilityTypes.h
a4630fe50a1228c8f018dd2e17edc1526fa6c29d731c2589e569fd7bd4afb868
modules/mod-ulduar-abilities/src/SecondarySpellExecutor.cpp
1afc454b02de6f359a85155a884521bce8d57d6936af8585ee0f9dc41d2bbeba
modules/mod-ulduar-abilities/src/SecondarySpellExecutor.h
aa8e299515b1058d02a6e021394d0d68d84377d4e17e193a2da861df209fdec1
modules/mod-ulduar-abilities/src/UlduarAbilities.cpp
52cb67732584d639ca45db81de36c1d0e8110032e71d1934c4fecd65c274ff7c
modules/mod-ulduar-abilities/tests/AbilityForgePhaseATest.cpp
931ce13ce05cb0fba72c21d5c9e879d67950b8902a9f50327d2dd6f60e6ca3fa
src/server/game/Entities/Unit/Unit.cpp
f15146db35cf89c01fe31d9d0c74b101f0baf655cf5786ef597d9b3d835e303f
src/server/game/Entities/Unit/Unit.h
f22a88f1b5a0589728b4784aaa68a909c5568d2916c648fe0510573aa34b2d83
src/server/game/Spells/Spell.cpp
8c25be9212263ca2ac335d099e502c428823bc823cff6e243b4fdd03ca2c032f
src/server/game/Spells/Spell.h
ee511de6c8b9f8a0cc2509d04aee5d61f2d7d17335bae75ce9c72eb0bb2b0a9a
src/server/game/Spells/SpellEffects.cpp
a924795551aae276e8224adf87f6a546b53449c7177046677b1f8ed2c98da8a5
```

</details>

## 20. Blockers

- Runtime execution of custom shells is blocked: no reserved IDs, authored rows, effective data review, matching
  client package, custom definition registration or release manifest. Pending and RuntimeEligible states reject.
- No tests or compilation were performed; source inspection/style checks cannot establish C++ linkage or behavior.
- Holy Light retains class/family/forms/native talent context and source-only compatibility. It is not class-neutral.
- Generic family does not isolate native class auras/procs. The concrete broad filters in section 8 need an explicit
  interaction policy before claiming neutral gameplay, followed by separately authorized observation.
- Future multi-slot activation needs instance cooldown/charge authority, a native projection policy, range/time/cost
  envelope decisions, entitlement provenance and queued-cast/lease reuse rules.
  The source selector is not those services.
- Actual client acceptance, package load order and effective server overrides/script associations remain unknown.
- The semantic Coverage bridge, final distribution/balance and future ownership/persistence remain deferred.

These are deployment/next-phase blockers, not missing artifacts from the authorized source-only A.6 deliverable.

## 21. Next safe phase

Recommended next scope: a separately authorized source/data-spec review to settle reserved namespaces, canonical
numeric/envelope decisions, native interaction policy, cooldown/queue preconditions and effective-data review
requirements. A later artifact-authoring phase can stage matched client/server representations and a manifest
without applying them. Build/test/runtime/client distribution each require their own subsequent authorization.
No Phase B/C/D, progression, persistence, UI, talents, Keystones, Free Pick or Wildcard work has begun.

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO SQL WAS EXECUTED.
NO CLIENT PATCH WAS APPLIED.
