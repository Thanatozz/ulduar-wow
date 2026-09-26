# Effect activation

Code:
- `src/engine/EngineTypes.h` (`HitRole`, `ActivationFlag`, `ExecutionContext`, `ActivationAllows`)
- `src/engine/RuntimeMechanics.cpp` (`EffectActivates`, `CanTriggerProc`)
- `src/engine/ExecutionModel.cpp` (`ClassifyHit`)
- `src/AbilityRuntime.h` (`AbilityPropagationContext::Execution()`)

Tests: `UlduarEffectActivation.*` (roles, `FromEcho`, stable bits, `OriginMask` alias),
`UlduarArchitectureTrigger.ActivationMaskAndRecursionGuard`.

## One authority

Whether an effect may activate on a hit is decided by **the effect itself**: its `Effect.ActivationMask`
(alias `Effect.OriginMask`). Propagation, Echo and Periodic code only **describe** the hit; they contain no
effect policy.

The hit description is deliberately small:

| Role | Hits |
| --- | --- |
| Primary | the execution's own hit (the player's cast, or an echo's own hit) |
| Secondary | any Split / Shatter / Chain / Nova hit (no per-mode split until a mechanic needs one) |
| Periodic | a periodic tick |
| Proc | an effect triggered by an effect |

`FromEcho` is a lineage flag on top of the role.

Mask bits (stable values, stored in builds and presets):

| Bit | Value | Kind |
| --- | --- | --- |
| PRIMARY | 1 | role |
| SECONDARY | 2 | role |
| ECHO | 4 | lineage |
| PERIODIC | 8 | role |
| PROC | 16 | role |

Rule: `allowed = mask has the Role bit AND (not FromEcho OR mask has the Echo bit)`. The Echo bit alone
activates nothing.

`Effect.OriginMask` is only a deprecated alias: it resolves to `Effect.ActivationMask` (same property, same
bits). The older origin enum (OriginalCast, TriggeredCast, Echo, PeriodicTick, Proc, Emitter) is retired.
Richer ancestry (original vs triggered cast, emitter, imbue, proc chain) may exist only as internal execution
context, never as a second editable authority.

| Essence | Mask | Frostbolt + Split 3 |
| --- | --- | --- |
| Freeze (-45% move, -25% attack speed) | PRIMARY | primary: damage + Freeze; secondaries 1-3: damage only |
| Chill (-30% move, -15% attack speed) | PRIMARY \| SECONDARY | primary and secondaries |
| Chill that also echoes | PRIMARY \| SECONDARY \| ECHO | also the echo's own hit and its secondaries |

Freeze is **not** incompatible with Split, Nova or Chain. The ability keeps propagating; the Essence simply does
not activate on those hits. Default mask: PRIMARY.

## Removed duplicate authorities

`Projectile.CanApplyEffects`, `Area.CanApplyEffects` and `Projectile.CanProc` stay registered. They are no
longer Lab-editable and no runtime reads them, so they cannot contradict an effect's own mask. The proc guard
(`CanTriggerProc`) asks the same `EffectActivates` rule, returning `SourceNotAllowed`.

Low-level safety guards that remain (they are not gameplay configuration):
- the carrier's native payload capability (`AbilityPayloadCapabilities`);
- `Echo.CanProc` (native proc events of echo executions);
- `Echo.CanEchoPeriodic` (whether an echo re-runs the periodic component).

## Effect magnitude

The effect or Essence definition owns its magnitude, e.g. `-30%` movement speed. `Effect.Scaling` is **not**
a universal crowd-control strength multiplier. Its gameplay application is on hold except for explicitly
quantitative effects with defined semantics. Controls (slow, root, silence, stun, fear, polymorph, disarm,
interrupt, healing reduction) never scale from a generic percentage. Effects expose mechanics:
`Effect.Duration`, `Effect.TriggerChance` (alias `Effect.Chance`), trigger and application rules.

## Runtime status

| Part | State |
| --- | --- |
| Activation rule and hit classification | IMPLEMENTED, UNIT TESTED; the runtime exposes `AbilityPropagationContext::Execution()` |
| Applying Essence effects (Chill/Freeze auras, emitters, imbues) on hits | RESOLVED ONLY: no effect runtime yet; the inspector lists effects as not executed |
| Native payload auras (Frostbolt's own slow) | Part of the native payload: applied on primary, secondary and echo hits (an echo replays the payload), subject to the carrier capability |
