# Ulduar zero semantics and validation

Code: `ZeroSemantic` in `src/engine/PropertyRegistry.h`, stages 7-9 in `AbilityResolver.cpp`.

## Three different concepts

| Concept | Where | Example |
| --- | --- | --- |
| Value semantics | registry `Zero` column | Cast time 0 = instant |
| Configurable balance limits | `UlduarAbilities.Limit.*` | Max casting range 80 yd |
| Absolute technical safety | registry technical range + limit absolute range | Max targets never above 256 |

No property has a hidden balance floor. The legacy node system's `MinCastTimeSeconds 0.5`,
`MaxCastTimeReductionPct 50` and `MaxCooldownReductionPct 50` belong to the legacy rank rules only (see
[migration](ULDuar_EXISTING_ABILITY_MIGRATION.md)); the engine does not use them, and the core's 0.5 cast-time
guard was removed.

## Validation classes

| Class | Meaning | Engine behavior |
| --- | --- | --- |
| A. Valid transformation | Zero changes behavior qualitatively | Info diagnostic (`Transformation`), semantic flag set |
| B. Disabled component | Zero means the phase/component does not execute | Info (`ComponentInactive`) |
| C. Invalid technical state | Impossible runtime state | Error (`InvalidTechnical`), `Valid = false`, the cast keeps legacy/native behavior |
| D. Explicitly unbounded / special | Represented by the schema | Info (`NoLimit`) |

## Zero table

| Property | Zero means | Class |
| --- | --- | --- |
| Casting.CastTime | instant cast | A |
| Casting.Cooldown | no cooldown | A |
| Casting.GlobalCooldown | no GCD (also `IgnoreGcd`) | A |
| Resource.Cost | free | A |
| Range.Min | no minimum-range dead zone | A |
| Primary.ProcChance, Effect.TriggerChance, Periodic.SpreadChance, Echo.Chance | never triggers (100 = guaranteed) | A |
| Primary.ThreatMultiplier | produces no threat | A |
| Periodic.Conversion | no conversion | A |
| Projectile.Scaling, Area.Scaling, Echo.Scaling, Effect.Scaling, elemental scaling | executes with no payload | A |
| Casting.ChannelTime | channel phase does not execute | B |
| Casting.Charges | charges disabled | B |
| Periodic.Duration | periodic inactive | B |
| Area.PersistentDuration | not persistent | B |
| Displacement.Distance | displacement inactive | B |
| Effect.Duration | effect has no active duration | B |
| Projectile.ImpactRadius | no impact area | B |
| Periodic.SpreadQuantity | no spread | B |
| Projectile.Speed | stalled projectile | C (never becomes Direct implicitly; changing delivery is an explicit `SET Delivery.Kind`) |
| Projectile.VisualScale, Area.Radius, Area.ConeAngle | impossible geometry | C |
| Projectile.Count, Projectile.Targets, Targeting.MaxTargets, MaxStacks, Stacks, SpreadStackCount | no execution slot | C |
| Periodic.TickInterval | only while Duration > 0 | C while active |
| Casting.ChannelTickInterval | only while ChannelTime > 0 | C while active |
| Area.PersistentTickInterval | only while PersistentDuration > 0 | C while active |
| Casting.ChargeRechargeTime | only while Charges > 0 | C while active |
| Displacement.Speed | only while Distance > 0 | C while active |
| Projectile.Lifetime, Projectile.MaxDistance, Area.MaxTargets, Area.DamageDiminishCap, Effect.Charges | no limit | D |

## Zero and balance minimums

A balance minimum never lifts a value of exactly zero whose zero has a meaning (anything but `Ordinary`): the
zero is a qualitative choice, not a small number. First needed by `Effect.Interval = 0` (an Emitter without
periodic activation, class B); an active interval (> 0) is still raised to `MinPeriodicTickInterval`. An active
`Periodic.TickInterval = 0` remains technically invalid (class C). Other appendix zeros: `Summon.Count = 0`
(inactive), `Summon.AttackScalingPct = 0` (no payload), `Summon.EntityHealthPct = 0` and
`Summon.AttackSpeedPct = 0` (invalid), `Summon.EntityMovementPct = 0` (cannot move),
`Periodic.ConversionEfficiencyPct = 0` (no payload).

## Negative results

Arithmetic may go below zero (`Cooldown 8 s ADD -10 s = -2 s`). A property whose technical minimum is
inclusive and not `INVALID` is clamped to it with a `TechnicalClamp` warning and the zero semantic applies
(cooldown 0 = no cooldown). The trace shows both the calculated -2 s and the technical minimum.

## Balance limits in the trace

```
Periodic.TickInterval             Range.Max
  Base              1 sec           Base              40 yd
  DeveloperLab      x0.40           Essence           +60 yd
  Calculated        0.40 sec        Calculated        100 yd
  Balance minimum   0.50 sec        Balance maximum   80 yd
  Final             0.50 sec        Final             80 yd
```

A technically invalid value is rejected before balance limits: `Projectile.Speed 0` is an error, not
"clamped to MinProjectileSpeed".
