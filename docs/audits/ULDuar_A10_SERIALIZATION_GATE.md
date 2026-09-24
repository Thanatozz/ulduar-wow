# ULDuar A.10 serialization gate

SOURCE_ONLY. All four: STATIC_SERIALIZATION_READY=YES, RUNTIME_READY=NO, CLIENT_VALIDATED=NO.
Overall: CARRIER_SPEC_READY_NAMESPACE_BLOCKED. No executable or gameplay artifact is emitted.

## Meaning of the decision

The diagnostic specification has sufficiently explicit semantic, numeric and raw attribute choices to serialize
after a safe SpellID is assigned. This does not authorize emitting a row now, loading it, granting it, or marking
it RuntimeEligible. Namespace reservation and selected-release reconciliation are still required. An unimplemented
source seam is a runtime gate, not an unknowable serialization field.

| Field | MeleeDamage | RangedProjectileDamage | MeleeHealing | RangedHealing |
| --- | --- | --- | --- | --- |
| Purpose / method | Damage / contact | Damage / ranged | Healing / contact | Healing / ranged |
| Activation | Instant | CastTime | Instant | CastTime |
| Delivery / geometry | Direct / Point | Projectile / Point | Direct / Point | Direct / Point |
| Effect 0 / TargetA / TargetB | SCHOOL_DAMAGE 2 / enemy 6 / 0 | SCHOOL_DAMAGE 2 / enemy 6 / 0 | HEAL 10 / ally 21 / 0 | HEAL 10 / ally 21 / 0 |
| Other effects | 0 | 0 | 0 | 0 |
| DmgClass / school mask | MAGIC 1 / Physical 1 | MAGIC 1 / Holy 2 | MAGIC 1 / Holy 2 | MAGIC 1 / Holy 2 |
| Range reference | 2 contact reach | 5, 0..40 | 2 contact reach | 5, 0..40 |
| CastTimes reference / base ms | 1 / 0 | 20 / 2500 | 1 / 0 | 20 / 2500 |
| Projectile speed | 0 | 24 | 0 | 0 |
| Power / native base-Mana % | Mana 0 / 3 | Mana 0 / 9 | Mana 0 / 7 | Mana 0 / 29 |
| Semantic base roll | 25 | 13..17 | 46..56 | 50..60 |
| Reviewed SP / AP / DOT coefficient | 0 / 0 / 0 | .123 / 0 / 0 | .231 / 0 / 0 | .481 / 0 / 0 |
| SpellVisual / SpellIcon | 342 / 257 | 7873 / 237 | 135 / 682 | 2936 / 70 |
| FacingCasterFlags | 1 | 1 | 0 | 0 |
| InterruptFlags | 0 | 0xF | 0 | 0xF |
| CANT_CRIT | Set | Clear | Clear | Clear |

Common frozen choices: generic family with zero family masks; no native class/weapon/form/stance/reagent/tool
entitlement; equipment class -1/masks0; no focus/totems; no channel; PreventionType1 (silence); SpellLevel/BaseLevel1,
MaxLevel0; zero level/combo scaling; flat/per-level/per-second cost0; GCD category133/base1500 ms, ordinary reviewed
native haste/floor; own recovery0, category0 and category recovery0. SkillLineAbility is omitted from this fixture.
Range2 uses native reach semantics, not a fixed center-to-center five-yard guarantee.

The carrier transport amount remains a one-unit seed (raw basepoints0/die1) replaced per cast by the frozen semantic
base; do not also retain the source spell's random dice. The semantic base roll belongs to the snapshot. The setter
and native coefficient application are future implementation, not behavior produced by an isolated DBC row.
String offsets/row encoding are later artifact-writer mechanics; the diagnostic spec keys can provide explicit enUS
names without claiming a production localized tooltip. No ID is inferred from a spec key.

See [the focused bit review](ULDuar_A10_REMAINING_ATTRIBUTE_BITS.md) for all eight explicit attribute words and the
33 newly decided clear bits. A.9's other 223 bit decisions were retained.

## Visual serialization versus rendering

| Family / visual | SERIALIZATION_REQUIRED evidence | Decision | RUNTIME_RENDERING_REQUIRED |
| --- | --- | --- | --- |
| MeleeDamage / 342 | Existing visual, kits506/11065, effect416, sound/animation rows, actual M2/skin/texture/sound hashes | ARTIFACT_SERIALIZABLE | Character procedure8, attachment/animation, native MDX-to-M2 resolution and complete nested model behavior |
| RangedProjectileDamage / 7873 | Existing visual, kits184/119/121, effects129/135, missile224; actual Holy_Missile_Low.m2 and inspected dependencies | ARTIFACT_SERIALIZABLE | Native missile launch/path/impact/timing, nested model behavior and effective package selection |
| MeleeHealing / 135 | Existing visual, kits99/270/232, effects130/135/249 and hashed assets | ARTIFACT_SERIALIZABLE | Contact-friendly presentation, cast animation, attachments and client target feedback |
| RangedHealing / 2936 | Existing visual, kits99/270/154, effects130/135/244 and hashed assets | ARTIFACT_SERIALIZABLE | Cast/impact animation, target presentation and complete rendering behavior |

All referenced kits/effect-name/sound/animation rows in the A.9 bounded graphs exist. Models were found under explicit
.m2 alternative probes for .mdx DBC paths. This is enough to write an isolated reference to the unchanged existing
visual row, not proof of client extension mapping, complete nested asset closure or rendering. No native visual,
kit, model or texture is changed by the design. The referenced IDs are known even while native effective selection
is CONDITIONAL. Changing to an unrelated visual/package later invalidates this decision.

The projectile has an actual missile model chain; this is not a placeholder with a missing missile ID. Source
SpellMissileID/motion0 remain zero. Do not invent optional dependency rows. Full visual closure remains PARTIAL;
RUNTIME_UNVERIFIED remains true for all four. Serialization readiness deliberately answers a different question.

## Three frozen source contracts

All are FROZEN_DESIGN_PROPOSAL, not implemented:

- Healing threat: from a bound Forge snapshot, NativeDefault preserves native behavior; ClassNeutralHealing skips
  only the Paladin-specific extra factor in Spell.cpp:2818. Preserve effective-gain * .5 and existing forwarding,
  redirects, modifiers and world interactions. Native Paladin casts remain unchanged.
- Target intent: preserve original wire mask/object GUID, resolution result and substitution outcome before native
  correction loses that distinction. Reuse existing original GUID/CanPrepare where applicable. Exact-unit Forge
  accepts explicit valid self healing, rejects missing/invalid intent corrected to self; unbound spells stay native.
- Potency: after valid immutable Forge snapshot resolution, use Spell::SetSpellValue(SPELLVALUE_BASE_POINT0,
  resolvedBase), before native amount processing. Freeze one roll, preserve native bonus/crit/mitigation/event flow,
  no second event, no shared SpellInfo mutation, no second Potency multiplier in OnHit. Legacy propagation stays scoped.

Exact source locations, lifetime/queue caveats and coefficient ownership are retained from
[the A.9 proposal](ULDuar_A9_SOURCE_SEAM_PROPOSALS.md). Freeze the contract, not an unreviewed implementation patch.
GENERIC/zero masks still do not isolate native talents. Provenance filtering, cooldown ownership, lease quarantine
and manifest admission remain runtime implementation gates; no data flag is claimed to implement them.

## Mana and spellbook gates

KEEP_NATIVE_BASE_MANA_FOR_DIAGNOSTIC_SLICE is frozen. Absolute Mana cost can differ by native chassis; only diagnostic
transport evidence accepts this. Production economy must later normalize/replace it. No ResourceService work in Phase A.

SPELLBOOK_ARTIFACT_GATE=NON_BLOCKING_RUNTIME_GATE. A serialized known SpellID can be represented by native server
spell/action identity once assigned and loaded; this is not evidence that an arbitrary unreserved ID is currently
known or usable. General-tab population, drag/drop, icon/tooltip and friendly contact feedback remain client
acceptance requirements (static confidence MEDIUM). No static evidence proves a new SkillLineAbility row necessary,
so none is added or assigned. Granting spells or configuring action bars is not performed here.

The next prerequisite is RELEASE / NAMESPACE RESERVATION, not another semantic carrier-design phase.
