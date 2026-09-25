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

`EffectKind`: Proc, Aura, Dispel, Displacement, Summon, Resource. An ability can hold any number of effects
(e.g. Proc A 30%, Proc B 100%, a slow aura). Each has a stable `Key` chosen by the author so modifiers target it
independently of list order. Effect-scope properties (`Effect.*`): Spell, TriggerChance, Duration,
InternalCooldown, DispelType, CanStack, Stacks, MaxStacks, TriggerEvent (Cast, Hit, Crit, Tick, Heal, Overheal,
DamageTaken, Kill, Dispel, PeriodicApplied, PeriodicExpired), Trigger Source/Target filters, CanProcFromProc,
MaxProcChainDepth, Charges, ConsumptionRule, Scaling, RefreshBehavior, ExclusiveGroup, Stat, ValueKind, Value,
CanCrit, CanHaste, ApplyTo, Radius, Persistent, RemoveOnDeath.

Effects of the same key: removal wins over addition. Adding a duplicate key is ignored with a warning.

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
| Proc gating | `CanTriggerProc` | Chance 0 never; proc-from-proc opt-in; loop detection over ancestry; depth bounded by effect and global limit |
| Periodic stacking | `ApplyPeriodic` | RefreshDuration, AddDuration, IndependentDuration, ReplaceWeaker, AddStackAndRefresh; optional pandemic carry-over |
| Periodic spread | `SpreadPeriodic` | Spread starts at SpreadStackCount (disease style: 1) and keeps remaining or full duration per rule |
