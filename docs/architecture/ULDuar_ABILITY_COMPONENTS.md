# Ulduar ability components

Code: `src/engine/EngineTypes.h`, `AbilityModel.h`. Properties per component:
[property registry](ULDuar_ABILITY_PROPERTIES.md).

## Data model

```
AbilityCore (immutable canonical design)          ResolvedAbility (one player's final result)
├── AbilityId, Revision (ranked spell id)          ├── Valid, Diagnostics, Traces
├── Components (bitset)                            ├── Components (after add/remove)
├── Values: PropertyBag (enum-indexed, typed)      ├── Values (final, rounded)
└── Effects[]: EffectDefinition                    ├── Effects[] (final)
      Key, Kind, Values (Effect.* properties)      ├── Semantics (Instant, NoCooldown, PeriodicActive...)
                                                   └── ConditionalModifiers (evaluated per event)
```

A property only exists while its component exists. A modifier for an absent component is ignored with a
`MissingComponent` warning; components are never created implicitly.

## Components

| Component | Kind | Purpose | Key properties |
| --- | --- | --- | --- |
| Primary | core | payload magnitude, school, ranges, hit table, crit, threat | Damage, Healing, Element, Range.Min/Max, CanMiss..CanReflect, Crit*, Threat* |
| Casting | core | cast/channel timing, cooldown, GCD, interruption, movement, charges | CastTime, ChannelTime, ChannelTickInterval, Cooldown, GlobalCooldown, CanCastWhileMoving, Charges |
| Resource | core | power type, cost, gain, refund | Type, Cost, Gain, RefundOnFailurePct |
| Targeting | core | how targets are chosen (separate from delivery) | Type, Relation, AliveRule, AcquisitionRadius/Angle, MaxTargets, SelectionPriority, secondary rules |
| Delivery | core | selects Direct / Projectile / Beam | Delivery.Kind (requires the matching component) |
| Projectile | optional | travel, multi-target, pierce, bounce, impact, origin | Speed, Count, Targets, AcquisitionRange, Scaling, VisualScale, HitRadius, Pierce*, Bounce*, Impact*, Origin, SpreadAngle |
| Beam | optional | reserved for beam delivery (no properties yet) | - |
| Area | optional | shape, radius, falloff, persistence, movement | Radius, InnerRadius, Shape, Origin, ConeAngle, MaxTargets, Falloff*, Persistent*, MoveWith* |
| Periodic | optional | DoT/HoT, stacking, spreading, snapshotting | Conversion, Duration, TickInterval, Initial/FinalTick, CanHaste/Crit/Stack, MaxStacks, StackBehavior, Spread*, SnapshotStats, PandemicExtensionPct |
| Echo | optional | delayed repeated execution | Chance, Scaling, Delay, MultiEcho, MaxEchoCount, CanEchoTriggerEcho, MaxChainDepth, decay, TargetRule, Range |
| Displacement | optional | knockback / pull / leap / dash primitives | Kind, Distance, Speed, VerticalForce, Direction, CanAffectPlayers/Bosses, CanInterruptCast |

Core components cannot be removed (`RemoveComponent` on them is rejected).

## Effects

`EffectKind` (append-only, values stable): Proc, Aura (legacy "applied status"), Dispel, Displacement, Summon,
Resource, Buff, Debuff, Emitter, Imbue, Damage, Healing. An ability can hold any number of effects (e.g. Proc A
30%, Proc B 100%, a slow). Each has a stable `Key` chosen by the author so modifiers target it independently of
list order. `Effect.Parent` links an effect to the effect that owns/emits it (an Emitter and its payload, a
Summon and its aura); the resolver rejects dangling parents and cycles. An Imbue must set `Effect.Attachment`.
Families, trigger model and composition: [architecture appendix](ULDuar_ABILITY_ARCHITECTURE_APPENDIX.md).

Effect-scope properties (`Effect.*`, plus `Summon.*` on Summon effects) are listed in the
[registry](ULDuar_ABILITY_PROPERTIES.md). `Effect.TriggerEvent`: Cast, Hit, Crit, Tick, Heal, Overheal,
DamageTaken, Kill, Dispel, PeriodicApplied, PeriodicExpired, MeleeHit, RangedHit, SpellHit, Attack, Attacked,
Block, Dodge, Parry, ResourceSpent, ResourceGained, AuraApplied, AuraRemoved, Interval.

Effects of the same key: removal wins over addition. Adding a duplicate key is ignored with a warning.

## Capabilities

`AbilityCore::Capabilities` holds one policy per modification axis (Quantity, TargetCount, Duration, Area,
Spread, Stacking, Persistence, Coverage, Element, Movement, Potency): `Allowed`, `NoIncrease` or `Locked`. The
resolver enforces it for every modifier source (a blocked change keeps the base value, `CapabilityRestricted`
warning); Requirements can test it (`CapabilityAllows`). Crowd-control spells receive `CrowdControlPolicies()`
from the runtime bridge (loss-of-control mechanics; snares excluded).

## Conditions

`ConditionKind`: TargetHealthBelow/AbovePct, CasterHealthBelow/AbovePct, TargetHasAura, TargetLacksAura,
TargetHasElementStatus, TargetMoving, CasterMoving, TargetStunned, TargetCasting, DistanceBelow/Above,
NearbyEnemiesAtLeast, NearbyAlliesAtLeast, TargetCreatureType (each can be negated). A modifier with conditions
is stored unbaked in `ResolvedAbility::ConditionalModifiers` and applied per combat event through
`AbilityResolver::ValueWithContext` with a `CombatContext` supplied by the runtime. Structural operations cannot
be conditional.

## Primitive mechanics (pure, tested)

| Mechanic | Function | Guarantees |
| --- | --- | --- |
| Echo sequence | `PlanEchoes` | One plan per cast, no recursive scheduling; bounded by MaxEchoCount / MaxChainDepth and the absolute limits; failed roll ends the sequence; chance decay flat or multiplicative |
| Proc gating | `CanTriggerProc` | Chance 0 never; execution origin must be in `Effect.OriginMask`; proc-from-proc opt-in; loop detection over ancestry; depth bounded by effect and global limit |
| Proc chance | `EffectProcChance` | `Effect.ProcsPerMinute` (PPM x attack speed / 60 s) takes precedence over `Effect.TriggerChance` |
| Summon quantity | `ResolveSummonPower` | Individual efficiency falls as count exceeds the Core count (`Summon.QuantityPenaltyPct`); exposed as `ResolvedEffect::Summon` |
| Periodic stacking | `ApplyPeriodic` | RefreshDuration, AddDuration, IndependentDuration, ReplaceWeaker, AddStackAndRefresh; optional pandemic carry-over |
| Periodic spread | `SpreadPeriodic` | Spread starts at SpreadStackCount (disease style: 1) and keeps remaining or full duration per rule |
