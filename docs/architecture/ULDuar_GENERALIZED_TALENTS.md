# Ulduar generalized talents

Status: proposed semantics plus source audit, 2026-09-14. This is not a published, balanced talent catalog.
The [conversion pipeline](ULDuar_TALENT_CONVERSION_PIPELINE.md) contains the exhaustive source-rank audit ledger.

## Intent, eligibility and support

A talent defines a global character rule, originating from any class. Source class, TalentTab and native tier are
provenance only. Do not call native `Player::LearnTalent` to establish Ulduar ownership. Do not retain a native
family mask as a hidden class gate. A universal talent's selector describes mechanics and is evaluated against
the player's effective abilities after structural transformations.

Generalization preserves the operation, its subject, event, conditions, coefficient basis, side effects and
restrictions that make the mechanic meaningful. A family-filtered damage increase may broaden to a school;
a finisher, shield counterattack or mana-refund proc must retain its mechanic. Original names and tooltips are
evidence, not an automatic find/replace source. The school of the talent's passive aura is often unrelated to
the school of the abilities it affects.

Each source talent/rank gets exactly one current classification and an explanation. Review status and runtime
support are separate fields; classification is not a substitute for human review.

| Classification | Meaning and release handling |
| --- | --- |
| FULL_GENERIC | Semantic operation is expressible by generic selectors/modifiers; publish only with executor support |
| MECHANIC_GENERIC | Requires a preserved mechanic contract/tag, such as Bleed, Pet, Shield, Rune or Stealth |
| NEEDS_ENGINE_SUPPORT | Generalization is possible but one or more required Ulduar adapters/services are missing |
| LEGACY_SPECIAL | Reviewed adapter for irreducible scripts; report reason and replacement plan |
| INVALID_OR_REDUNDANT | Preserve source/reason; duplicates alias a canonical definition; never drop silently |

Current audit entries use NEEDS_ENGINE_SUPPORT for all imported ranks because the universal rule registry,
ownership and executor are absent. This is an implementation-blocker classification, not a claim that every
talent's semantics have been solved. The ledger records native operations, review routes and LOW semantic
confidence. The independent `candidateSemanticClass` remains unassigned until enough evidence exists.
The examples below identify likely destinations, not final adjudications of the complete talent population.

## Model

| Entity | Required data |
| --- | --- |
| `UlduarTalentDefinition` | ID/version, text/icon keys, category/tags, classification, support, source mappings |
| `UlduarTalentRank` | Rank, point cost, replacement value vector, semantic override when rank changes behavior |
| `UlduarTalentSelector` | Typed predicate AST, subject scope, effect binding, snapshot stage |
| `UlduarTalentTrigger` | Event, phase, chance/PPM policy, internal cooldown, charge and recursion policy |
| `UlduarTalentCondition` | Typed actor/target/event predicates, evaluation time, resource/health/facing bases |
| `UlduarTalentModifier` | Property operation, domain/unit, stacking group, effect target and coefficient policy |
| `UlduarTalentEffect` | Modify, grant ability, apply/remove aura, trigger payload, resource delta, cooldown operation |
| `UlduarTalentPrerequisite` | Optional generic rank/category spend/mechanic unlock; acyclic, with explicit rationale |

Native rank r maps to a complete value vector; do not sum native auras of every rank. Some higher ranks change
proc behavior or unlock an ability. Keep those changes explicit. Many original talents can alias one generalized
definition only after proving their operation, basis, trigger and balance policy equivalent. Alias sources cannot
be purchased repeatedly to stack identical generalized talent ranks.

## Selector and condition grammar

```text
Selector := all(Selector...) | any(Selector...) | not(Selector)
          | existsEffect(binding, Predicate) | allEffects(binding, Predicate)
          | character(Predicate) | ownedSummon(Predicate) | eventEffect(Predicate)
Predicate := property comparison typedLiteral | hasTag(tag) | hasCapability(capability)
comparison := eq | in | hasAnyBits | hasAllBits | lt | le | gt | ge
```

Schema-check property scope, units and enum vocabulary. Bound effect variables are available to modifier targets.
Empty `allEffects` is false for eligibility, avoiding vacuous activation. Multi-school selectors specify any/all
mask semantics. Family/source class/SpellID are debug/import fields unavailable in published generic predicates.
A reviewed LEGACY_SPECIAL adapter can reference source IDs internally with an explicit exception record.

Subjects include character itself, owned ability, selected payload, summon and event. Character-wide armor or
health talents use `character(...)`; they do not require an arbitrary matching learned spell. Summon ownership
selectors distinguish the summon ability from the attacks of currently controlled pets.

Conditions include caster/target current, max or percent health; distance and position; moving/stationary;
behind/in front; stealth; combat; target casting; caster/target aura tags and stacks; creature type; weapon state;
form/stance; resource available, paid or gained. Every predicate declares cast-start, hit, tick or event evaluation.
Transient conditions failing do not remove ownership or mark an otherwise compatible talent unsupported.

## Trigger contract

Supported vocabulary to implement:

| Event family | Names |
| --- | --- |
| Cast | OnCastStart, OnCastFinish, OnCast |
| Result | OnHit, OnMiss, OnCrit, OnKill, OnDamage, OnHeal, OnOverheal |
| Lifecycle | OnTick, OnAuraApply, OnAuraRemove, OnDispel, OnInterrupt |
| Resource | OnResourceSpend, OnResourceGain |
| Defensive | OnDamageTaken, OnDodge, OnParry, OnBlock |

`OnCastStart` follows accepted preparation; cancellation has no finish. `OnCastFinish` is successful completion
of cast/channel; `OnCast` means successful launch and happens once per root, not once per target. Native AfterCast
must be mapped and verified rather than assumed to have every meaning. OnHit requires a landed effect; OnDamage
uses post-mitigation applied damage, OnHeal effective restored health, OnOverheal discarded healing. Absorbed
damage and raw heal amount are separate event fields. OnKill is once per death, with logical credit owner.
OnAuraRemove includes expiration, dispel, replacement and death reason; OnDispel requires successful removal.
OnInterrupt distinguishes successful interruption and school lockout from merely casting an interrupt ability.
Resource events carry actual debits/credits, root cost identity and conversion provenance.

Events include rootCastId, eventId, parentId, effectKey, source ability revision, logical actor, recipient,
amounts, school, outcome, resource ledger ref, timestamp/tick ordinal, generatedByRule and trigger depth.
Fixed-chance versus PPM has an explicit eligible event rate basis. Roll once per rule/event/subject unless
multi-target policy says otherwise. Keep proc cooldown scopes distinct: character, ability, target or summon.

## Semantic conversions and source examples

| Source intent | Candidate selector/operation | Likely destination; required review |
| --- | --- | --- |
| Fireball damage bonus | Fire + Damage payload potency | FULL_GENERIC; preserve direct/periodic intent |
| Frostbolt critical chance | Frost + damaging + crit-capable payload | FULL_GENERIC; do not grant crit to all DoTs |
| Renew magnitude | Periodic Healing payload | FULL_GENERIC; verify whether tick or total bonus |
| Blizzard radius | Ground + PersistentArea coverage group | NEEDS_ENGINE_SUPPORT: field radius adapter |
| Corruption tick modifier | Periodic Damage with appropriate tick property | FULL_GENERIC or schedule adapter |
| Projectile speed | Projectile delivery velocity | NEEDS_ENGINE_SUPPORT: editable velocity |
| Pet damage / durability | Owned Pet/Summon and scaling policy | MECHANIC_GENERIC: ownership and pet stats |
| Stealth cost/mobility | Stealth mechanic plus resource/movement condition | MECHANIC_GENERIC; retain combat breaks |
| Bleed after crit | Weapon damage critical event -> Bleed periodic payload | MECHANIC_GENERIC; derived damage ledger |
| Shield counterattack | Shield/WeaponAttack event -> cooldown/next-use effect | MECHANIC_GENERIC; consume-once state |
| Rune interaction | Rune resource and rune-state transitions | MECHANIC_GENERIC; discrete resource adapter |
| Granted active ability | Global talent effect grants a classless ability | NEEDS_ENGINE_SUPPORT: ownership refcounts |

Specific inspected scripts demonstrate why school replacement is insufficient:

- [Mage Ignite](../../src/server/scripts/Spells/spell_mage.cpp), `spell_mage_ignite`: derives periodic damage from
  the proc's damage, divides it by tick count and uses a delayed periodic merge helper; excludes a family-flag
  case. Generalization must choose the eligible crit events and retain a defined merge rule. Native proc-table
  filtering must also be examined before publishing the selector.
- [Master of Elements](../../src/server/scripts/Spells/spell_mage.cpp), `spell_mage_master_of_elements`: refunds
  base mana cost, not actual cost paid, and resolves an explosion to its controller cost. Proposed rule retains
  `refundBasis=nativeBaseCost` with controller provenance; resource-neutralization needs an explicit design decision.
- [Sword and Board](../../src/server/scripts/Spells/spell_warrior.cpp), `spell_warr_sword_and_board`: resets native
  category 1209. Candidate semantics need a ShieldAttack category and next-use proc contract, not Physical Damage.
- [Savage Defense payload](../../src/server/scripts/Spells/spell_druid.cpp), `spell_dru_savage_defense`: calculates
  absorption from AP and consumes its pool on an absorb callback. This is an illustrative mechanic payload;
  it must not be invented as a separate Talent.dbc row when importing talents.

Native scripts, DBC proc flags, `spell_proc`, `spell_bonus_data`, `spell_threat` and condition data jointly define
intent. A script without an inline school check is not evidence that its native proc accepted every school.

## Unsupported-category report and disposition

| Category | Why current Ulduar cannot publish it generically | Required abstraction / disposition |
| --- | --- | --- |
| Global numeric rules | No character talent rule registry or effect selector executor | First shared modifier engine |
| Family-mask modifiers | Native ADD_FLAT/PCT targets family bits and SpellModOp | Source-set review |
| Stateful procs | Propagation events lack universal combat coverage | Event ledger, ICD, charges, state |
| Passive character stats | Current model is per ability | Character-subject rules and reversible stat ownership |
| Aura/DoT/HoT lifecycle | Current hooks scale select periodic amounts only | Duration/refresh/tick/stack adapters |
| Absorb/control/interrupt | Flag-level taxonomy lacks execution contracts | Pool, DR, dispel and lockout adapters |
| Pet/summon/totem/trap | No generalized owner/inheritance/control interface | Mechanic registry and subject domains |
| Weapons/forms/stealth | Native restrictions and scripts remain specific | Preserve mechanic gates; classless grants |
| Rune/combo/custom resources | Root/secondary protection lacks resource rules | Typed resource ledger/adapters |
| Movement and geometry | Mobile disabled; ground/cone/line/beam abstractions absent | Target/movement adapters |
| Grant/replace talent spells | Native learning side effects; multiple grant sources | Classless reference counting |
| Opaque script/quest interactions | Semantic reach unknown | Manual review; LEGACY_SPECIAL only after adjudication |
| Duplicate/obsolete talents | Source names/IDs alone cannot prove equivalence/uselessness | Reviewed alias/tombstone |

Every unresolved rank stays visible in the conversion ledger. No row is labeled INVALID_OR_REDUNDANT merely for
having no current matching ability. No unsupported record is sold as a dormant supported talent.
