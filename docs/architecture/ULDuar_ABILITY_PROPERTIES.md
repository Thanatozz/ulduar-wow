# Ulduar universal property registry

Source of truth: `modules/mod-ulduar-abilities/src/engine/PropertyRegistry.h` (`ULDUAR_ABILITY_PROPERTIES`
X-macro). One row defines the enum id, dotted name, component, value type, unit, zero semantic, technical
bounds, balance limit keys, default, enum size, activation property and Lab editability. The tables below were
generated from that table; regenerate them when it changes.

## Metadata

| Field | Meaning |
| --- | --- |
| Type | `number` (double during arithmetic), `bool`, `enum` (stable `uint32` values). No forced floats |
| Unit | ms and counts are integers and are rounded once, after all clamps |
| Zero | Meaning of exactly 0, see [zero semantics](ULDuar_ZERO_SEMANTICS.md) |
| Technical | Absolute validity range. `(` = exclusive minimum (0 is invalid). Violations of a minimum on an `INVALID` / `INVALID WHILE ACTIVE` property reject the resolution; other violations clamp with a warning |
| Balance | `UlduarAbilities.Limit.*` keys that clamp the value (configurable, shown in the inspector) |
| Default | Value used when a component is added by a modifier and the Core has no value |
| Class | UNBOUNDED / ZERO-SEMANTIC / TECHNICAL-MIN / TECHNICAL-MAX / BALANCE-MIN / BALANCE-MAX / BOTH |

Allowed operations derive from the type: numbers `SET ADD SUBTRACT MULTIPLY PERCENT_ADD CLAMP_MIN CLAMP_MAX`,
booleans `SET ENABLE DISABLE`, enums `SET`. Effect-scope properties (`Effect.*`) apply to one effect by key
or to every effect when the key is 0. Name lookup (`FindProperty`) is for commands, presets and protocol only.

## Properties

179 properties (162 in the first pass; the architecture appendix added `Periodic.ConversionEfficiencyPct`,
nine effect-scope `Effect.*` properties and seven effect-scope `Summon.*` properties). `Summon.*` rows are
effect-scope: they are listed under Effect and only mean something on a `Summon` effect. See
[ULDuar_ABILITY_ARCHITECTURE_APPENDIX.md](ULDuar_ABILITY_ARCHITECTURE_APPENDIX.md).

### Primary

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Primary.Damage` | number | - | - | [0, inf] | - | 0 | TECHNICAL-MIN  |
| `Primary.Healing` | number | - | - | [0, inf] | - | 0 | TECHNICAL-MIN  |
| `Primary.Element` | enum | - | - | - | - | Physical | - |
| `Primary.ElementalDamageScaling` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Primary.ElementalHealingScaling` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Range.Min` | number | yd | NO MINIMUM RANGE | [0, 500] | max MaxCastingRange | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Range.Max` | number | yd | - | [0, 500] | max MaxCastingRange | 30 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Primary.CritChanceModifier` | number | % | - | [-100, 100] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Primary.CritDamageBonus` | number | % | - | [-100, 10000] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Primary.ThreatMultiplier` | number | x | NO THREAT | [0, 1000] | - | 1 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Primary.FlatThreat` | number | - | - | [-inf, inf] | - | 0 | UNBOUNDED |
| `Primary.ProcChance` | number | % | NEVER TRIGGERS | [0, 100] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Primary.CanMiss` | bool | - | - | - | - | true | - |
| `Primary.CanDodge` | bool | - | - | - | - | true | - |
| `Primary.CanParry` | bool | - | - | - | - | true | - |
| `Primary.CanBlock` | bool | - | - | - | - | true | - |
| `Primary.CanResist` | bool | - | - | - | - | true | - |
| `Primary.CanReflect` | bool | - | - | - | - | true | - |

### Casting

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Casting.CastTime` | number | ms | INSTANT | [0, 600000] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Casting.ChannelTime` | number | ms | INACTIVE | [0, 600000] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Casting.ChannelTickInterval` | number | ms | INVALID WHILE ACTIVE | (0, 600000] | min MinChannelTickInterval | 1000 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MIN |
| `Casting.Cooldown` | number | ms | NO COOLDOWN | [0, 8.64e+07] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Casting.GlobalCooldown` | number | ms | NO GLOBAL COOLDOWN | [0, 60000] | - | 1500 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Casting.IgnoreGcd` | bool | - | - | - | - | false | - |
| `Casting.NeedFacing` | bool | - | - | - | - | true | - |
| `Casting.NeedLineOfSight` | bool | - | - | - | - | true | - |
| `Casting.CanCastWhileMoving` | bool | - | - | - | - | false | - |
| `Casting.CanCastWhileFalling` | bool | - | - | - | - | false | - |
| `Casting.CanBeInterrupted` | bool | - | - | - | - | true | - |
| `Casting.PushbackProtection` | number | % | - | [0, 100] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Casting.Charges` | number | - | INACTIVE | [0, 100] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Casting.ChargeRechargeTime` | number | ms | INVALID WHILE ACTIVE | (0, 8.64e+07] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |

### Resource

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Resource.Type` | enum | - | - | - | - | Mana | - |
| `Resource.Cost` | number | - | FREE | [0, inf] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN  |
| `Resource.Gain` | number | - | - | [0, inf] | - | 0 | TECHNICAL-MIN  |
| `Resource.RefundOnFailurePct` | number | % | - | [0, 100] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |

### Targeting

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Targeting.Type` | enum | - | - | - | - | Unit | - |
| `Targeting.Relation` | enum | - | - | - | - | Enemy | - |
| `Targeting.AliveRule` | enum | - | - | - | - | AliveOnly | - |
| `Targeting.RequiresTarget` | bool | - | - | - | - | true | - |
| `Targeting.AcquisitionRadius` | number | yd | - | [0, 200] | max MaxSecondaryTargetRange | 0 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Targeting.AcquisitionAngle` | number | deg | - | [0, 360] | - | 360 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Targeting.MaxTargets` | number | - | INVALID | [1, 256] | max MaxTargets | 1 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Targeting.SelectionPriority` | enum | - | - | - | - | Nearest | - |
| `Targeting.SecondaryIncludesPrimary` | bool | - | - | - | - | false | - |
| `Targeting.SecondaryCanRepeat` | bool | - | - | - | - | false | - |
| `Targeting.SecondaryNeedLineOfSight` | bool | - | - | - | - | true | - |

### Delivery

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Delivery.Kind` | enum | - | - | - | - | Direct | - |

### Projectile

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Projectile.Type` | number | - | - | [0, 4.29497e+09] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Projectile.Scaling` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Projectile.Count` | number | - | INVALID | [1, 128] | max MaxProjectileCount | 1 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.Targets` | number | - | INVALID | [1, 256] | max MaxTargets | 1 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.AcquisitionRange` | number | yd | - | [0, 200] | max MaxSecondaryTargetRange | 10 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.Speed` | number | yd/s | INVALID | (0, 1000] | min MinProjectileSpeed, max MaxProjectileSpeed | 25 | TECHNICAL-MIN TECHNICAL-MAX BOTH |
| `Projectile.Lifetime` | number | ms | UNLIMITED | [0, 600000] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Projectile.MaxDistance` | number | yd | UNLIMITED | [0, 500] | max MaxCastingRange | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.VisualScale` | number | x | INVALID | (0, 20] | min MinProjectileVisualScale, max MaxProjectileVisualScale | 1 | TECHNICAL-MIN TECHNICAL-MAX BOTH |
| `Projectile.HitRadius` | number | yd | - | [0, 50] | min MinProjectileHitRadius, max MaxProjectileHitRadius | 0.5 | TECHNICAL-MIN TECHNICAL-MAX BOTH |
| `Projectile.Homing` | bool | - | - | - | - | true | - |
| `Projectile.CanRetarget` | bool | - | - | - | - | false | - |
| `Projectile.CanPierce` | bool | - | - | - | - | false | - |
| `Projectile.PierceCount` | number | - | - | [0, 128] | max MaxTargets | 0 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.CanBounce` | bool | - | - | - | - | false | - |
| `Projectile.BounceCount` | number | - | - | [0, 128] | max MaxBounceTargets | 0 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.BounceRange` | number | yd | - | [0, 200] | max MaxBounceRange | 10 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.BounceScalingPct` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Projectile.CanProc` | bool | - | - | - | - | true | - |
| `Projectile.CanApplyEffects` | bool | - | - | - | - | true | - |
| `Projectile.ImpactDelay` | number | ms | - | [0, 60000] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Projectile.ImpactRadius` | number | yd | INACTIVE | [0, 200] | max MaxAreaRadius | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Projectile.DestroyOnImpact` | bool | - | - | - | - | true | - |
| `Projectile.Origin` | enum | - | - | - | - | Caster | - |
| `Projectile.SpreadAngle` | number | deg | - | [0, 360] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |

### Area

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Area.Scaling` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Area.Radius` | number | yd | INVALID | (0, 200] | max MaxAreaRadius | 5 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Area.InnerRadius` | number | yd | - | [0, 200] | max MaxAreaRadius | 0 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Area.Shape` | enum | - | - | - | - | Circle | - |
| `Area.Origin` | enum | - | - | - | - | PrimaryTarget | - |
| `Area.ConeAngle` | number | deg | INVALID | (0, 360] | - | 90 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Area.CanApplyEffects` | bool | - | - | - | - | true | - |
| `Area.MaxTargets` | number | - | UNLIMITED | [0, 256] | max MaxTargets | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Area.DamageDiminishCap` | number | - | UNLIMITED | [0, 256] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Area.FalloffDamagePct` | number | % | - | [0, 100] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Area.FalloffHealingPct` | number | % | - | [0, 100] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Area.FalloffStartDistance` | number | yd | - | [0, 200] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Area.PersistentDuration` | number | ms | INACTIVE | [0, 3.6e+06] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Area.PersistentTickInterval` | number | ms | INVALID WHILE ACTIVE | (0, 600000] | min MinPersistentAreaTickInterval | 1000 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MIN |
| `Area.MoveWithCaster` | bool | - | - | - | - | false | - |
| `Area.MoveWithTarget` | bool | - | - | - | - | false | - |
| `Area.SelectionRule` | enum | - | - | - | - | Nearest | - |

### Periodic

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Periodic.Conversion` | number | % | NO CONVERSION | [0, 10000] | max MaxPeriodicConversionPct | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Periodic.ConversionEfficiencyPct` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.Duration` | number | ms | INACTIVE | [0, 3.6e+06] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.TickInterval` | number | ms | INVALID WHILE ACTIVE | (0, 3.6e+06] | min MinPeriodicTickInterval, max MaxPeriodicTickInterval | 3000 | TECHNICAL-MIN TECHNICAL-MAX BOTH |
| `Periodic.InitialTick` | bool | - | - | - | - | false | - |
| `Periodic.FinalTick` | bool | - | - | - | - | false | - |
| `Periodic.CanHaste` | bool | - | - | - | - | false | - |
| `Periodic.CanCrit` | bool | - | - | - | - | false | - |
| `Periodic.CanStack` | bool | - | - | - | - | false | - |
| `Periodic.MaxStacks` | number | - | INVALID | [1, 1000] | - | 1 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.StackBehavior` | enum | - | - | - | - | RefreshDuration | - |
| `Periodic.ScalingPerStackPct` | number | % | - | [0, 10000] | - | 100 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.TickScalingPerStackPct` | number | % | - | [0, 10000] | - | 100 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.CanSpreadOnTick` | bool | - | - | - | - | false | - |
| `Periodic.SpreadQuantity` | number | - | INACTIVE | [0, 64] | max MaxSpreadTargets | 1 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Periodic.SpreadRadius` | number | yd | - | [0, 200] | max MaxSpreadRange | 8 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Periodic.SpreadChance` | number | % | NEVER TRIGGERS | [0, 100] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.SpreadCooldown` | number | ms | NO COOLDOWN | [0, 3.6e+06] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.SpreadStackCount` | number | - | INVALID | [1, 1000] | - | 1 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Periodic.SpreadDurationRule` | enum | - | - | - | - | KeepRemaining | - |
| `Periodic.SnapshotStats` | bool | - | - | - | - | true | - |
| `Periodic.PandemicExtensionPct` | number | % | - | [0, 100] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |

### Echo

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Echo.Chance` | number | % | NEVER TRIGGERS | [0, 100] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Echo.Scaling` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Echo.Delay` | number | ms | - | [0, 60000] | min MinEchoDelay, max MaxEchoDelay | 1000 | TECHNICAL-MIN TECHNICAL-MAX BOTH |
| `Echo.MultiEcho` | bool | - | - | - | - | false | - |
| `Echo.MaxEchoCount` | number | - | - | [0, 32] | max MaxEchoCount | 1 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Echo.CanEchoTriggerEcho` | bool | - | - | - | - | false | - |
| `Echo.MaxChainDepth` | number | - | - | [0, 16] | max MaxEchoChainDepth | 1 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Echo.ChanceDecayMode` | enum | - | - | - | - | Multiplicative | - |
| `Echo.ChanceDecay` | number | x | - | [0, 100] | - | 1 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Echo.ScalingDecayPct` | number | % | - | [0, 100] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Echo.DelayIncrease` | number | ms | - | [0, 60000] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Echo.CanCrit` | bool | - | - | - | - | true | - |
| `Echo.CanProc` | bool | - | - | - | - | false | - |
| `Echo.CanEchoPeriodic` | bool | - | - | - | - | false | - |
| `Echo.TargetRule` | enum | - | - | - | - | SameTarget | - |
| `Echo.Range` | number | yd | - | [0, 200] | max MaxSecondaryTargetRange | 10 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |

### Displacement

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Displacement.Kind` | enum | - | - | - | - | Knockback | - |
| `Displacement.Distance` | number | yd | INACTIVE | [0, 200] | max MaxDisplacementDistance | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Displacement.Speed` | number | yd/s | INVALID WHILE ACTIVE | (0, 500] | max MaxDisplacementSpeed | 20 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Displacement.VerticalForce` | number | yd/s | - | [0, 200] | max MaxVerticalForce | 0 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Displacement.Direction` | enum | - | - | - | - | AwayFromCaster | - |
| `Displacement.CanAffectPlayers` | bool | - | - | - | - | true | - |
| `Displacement.CanAffectBosses` | bool | - | - | - | - | false | - |
| `Displacement.CanInterruptCast` | bool | - | - | - | - | false | - |

### Effect

| Property | Type | Unit | Zero | Technical | Balance | Default | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Effect.Spell` | number | - | - | [0, 4.29497e+09] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.TriggerChance` | number | % | NEVER TRIGGERS | [0, 100] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.Duration` | number | ms | INACTIVE | [0, 3.6e+06] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.InternalCooldown` | number | ms | NO COOLDOWN | [0, 3.6e+06] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.DispelType` | enum | - | - | - | - | None | - |
| `Effect.CanStack` | bool | - | - | - | - | false | - |
| `Effect.Stacks` | number | - | INVALID | [1, 1000] | - | 1 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.MaxStacks` | number | - | INVALID | [1, 1000] | - | 1 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.TriggerEvent` | enum | - | - | - | - | Hit | - |
| `Effect.TriggerSourceFilter` | enum | - | - | - | - | Any | - |
| `Effect.TriggerTargetFilter` | enum | - | - | - | - | Any | - |
| `Effect.CanProcFromProc` | bool | - | - | - | - | false | - |
| `Effect.MaxProcChainDepth` | number | - | - | [0, 16] | max MaxProcChainDepth | 1 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Effect.Charges` | number | - | UNLIMITED | [0, 1000] | - | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.ConsumptionRule` | enum | - | - | - | - | None | - |
| `Effect.Scaling` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.RefreshBehavior` | enum | - | - | - | - | Refresh | - |
| `Effect.ExclusiveGroup` | number | - | - | [0, 4.29497e+09] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.Stat` | number | - | - | [0, 4.29497e+09] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.ValueKind` | enum | - | - | - | - | Flat | - |
| `Effect.Value` | number | - | - | [-inf, inf] | - | 0 | UNBOUNDED |
| `Effect.CanCrit` | bool | - | - | - | - | false | - |
| `Effect.CanHaste` | bool | - | - | - | - | false | - |
| `Effect.ApplyTo` | enum | - | - | - | - | Target | - |
| `Effect.Radius` | number | yd | - | [0, 200] | max MaxAreaRadius | 0 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Effect.Persistent` | bool | - | - | - | - | false | - |
| `Effect.RemoveOnDeath` | bool | - | - | - | - | true | - |
| `Effect.Parent` | number | - | - | [0, 4.29497e+09] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.Element` | enum | - | - | - | - | Native | - |
| `Effect.Coverage` | enum | - | - | - | - | Single | - |
| `Effect.MaxTargets` | number | - | INVALID | [1, 256] | max MaxTargets | 1 | TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Effect.Interval` | number | ms | INACTIVE | [0, 3.6e+06] | min MinPeriodicTickInterval, max MaxPeriodicTickInterval | 0 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BOTH |
| `Effect.ProcsPerMinute` | number | - | - | [0, 60] | - | 0 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.OriginMask` | number | - | - | [0, 63] | - | 63 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Effect.Attachment` | enum | - | - | - | - | None | - |
| `Effect.Control` | enum | - | - | - | - | None | - |
| `Summon.Archetype` | enum | - | - | - | - | Guardian | - |
| `Summon.Count` | number | - | INACTIVE | [0, 64] | max MaxSummonCount | 1 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX BALANCE-MAX |
| `Summon.QuantityPenaltyPct` | number | % | - | [0, 100] | - | 50 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Summon.EntityHealthPct` | number | % | INVALID | (0, 10000] | - | 100 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Summon.EntityMovementPct` | number | % | - | [0, 1000] | - | 100 | TECHNICAL-MIN TECHNICAL-MAX  |
| `Summon.AttackScalingPct` | number | % | NO PAYLOAD | [0, 10000] | - | 100 | ZERO-SEMANTIC TECHNICAL-MIN TECHNICAL-MAX  |
| `Summon.AttackSpeedPct` | number | % | INVALID | (0, 1000] | - | 100 | TECHNICAL-MIN TECHNICAL-MAX  |

## Configurable balance limits

| Key | Direction | Default | Absolute range | Unit |
| --- | --- | --- | --- | --- |
| `UlduarAbilities.Limit.MaxCastingRange` | max | 80 | [0, 500] | yd |
| `UlduarAbilities.Limit.MaxAreaRadius` | max | 40 | [0, 200] | yd |
| `UlduarAbilities.Limit.MaxSecondaryTargetRange` | max | 25 | [0, 200] | yd |
| `UlduarAbilities.Limit.MinProjectileSpeed` | min | 5 | [0.1, 1000] | yd/s |
| `UlduarAbilities.Limit.MaxProjectileSpeed` | max | 100 | [0.1, 1000] | yd/s |
| `UlduarAbilities.Limit.MinProjectileVisualScale` | min | 0.25 | [0.01, 20] | x |
| `UlduarAbilities.Limit.MaxProjectileVisualScale` | max | 4 | [0.01, 20] | x |
| `UlduarAbilities.Limit.MinProjectileHitRadius` | min | 0 | [0, 50] | yd |
| `UlduarAbilities.Limit.MaxProjectileHitRadius` | max | 5 | [0, 50] | yd |
| `UlduarAbilities.Limit.MaxProjectileCount` | max | 12 | [1, 128] | - |
| `UlduarAbilities.Limit.MinPeriodicTickInterval` | min | 500 | [50, 600000] | ms |
| `UlduarAbilities.Limit.MaxPeriodicTickInterval` | max | 30000 | [50, 3.6e+06] | ms |
| `UlduarAbilities.Limit.MinChannelTickInterval` | min | 250 | [50, 600000] | ms |
| `UlduarAbilities.Limit.MinPersistentAreaTickInterval` | min | 500 | [50, 600000] | ms |
| `UlduarAbilities.Limit.MinEchoDelay` | min | 250 | [0, 60000] | ms |
| `UlduarAbilities.Limit.MaxEchoDelay` | max | 3000 | [0, 60000] | ms |
| `UlduarAbilities.Limit.MaxEchoCount` | max | 5 | [0, 32] | - |
| `UlduarAbilities.Limit.MaxEchoChainDepth` | max | 3 | [0, 16] | - |
| `UlduarAbilities.Limit.MaxProcChainDepth` | max | 3 | [0, 16] | - |
| `UlduarAbilities.Limit.MaxTargets` | max | 32 | [1, 256] | - |
| `UlduarAbilities.Limit.MaxSpreadTargets` | max | 8 | [0, 64] | - |
| `UlduarAbilities.Limit.MaxSpreadRange` | max | 20 | [0, 200] | yd |
| `UlduarAbilities.Limit.MaxBounceTargets` | max | 10 | [0, 128] | - |
| `UlduarAbilities.Limit.MaxBounceRange` | max | 25 | [0, 200] | yd |
| `UlduarAbilities.Limit.MaxDisplacementDistance` | max | 40 | [0, 200] | yd |
| `UlduarAbilities.Limit.MaxDisplacementSpeed` | max | 60 | [0.1, 500] | yd/s |
| `UlduarAbilities.Limit.MaxVerticalForce` | max | 30 | [0, 200] | yd/s |
| `UlduarAbilities.Limit.MaxPeriodicConversionPct` | max | 100 | [0, 10000] | % |
| `UlduarAbilities.Limit.MaxSummonCount` | max | 10 | [0, 64] | - |

Balance limits are validated at startup: a non-finite value keeps the default, a value outside the absolute
range is clamped, and min/max pairs (projectile speed, visual scale, hit radius, periodic tick, echo delay)
that cross are corrected. Every correction is logged as a `[UlduarAbilities]` warning.
