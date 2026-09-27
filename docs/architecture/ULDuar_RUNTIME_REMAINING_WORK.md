# Runtime remaining work (2026-09-27)

What is still missing between the resolved ability model and gameplay, in the milestone's priority order.
State words: RUNTIME, RUNTIME CODED (needs build/SQL/in-game test), ENGINE MODEL (pure rules + tests, not
wired), RESOLVED ONLY, DESIGN, CLIENT PATCH REQUIRED.

## 1. Effect runtime

| Effect kind | State | Next step |
| --- | --- | --- |
| Buff / Debuff | RESOLVED ONLY | an effect executor applying a native aura carrier per effect instance (same pool/identity pattern as periodics: generic aura rows + per-instance override of value/duration), activated by `Effect.ActivationMask` |
| Emitter | RESOLVED ONLY | a persistent container (aura on the owner) that activates child effects every `Effect.Interval` or on a trigger |
| Imbue | RESOLVED ONLY | an aura on the character/weapon listening on the trigger bus |
| Summon | RESOLVED ONLY | per archetype (ControlledPet, Guardian, Stationary, Totem); native summon spells as carriers |
| Displacement | RESOLVED ONLY (inspector: not executed) | Knockback/Pull via native `Unit::KnockbackFrom` / `GetMotionMaster()->MoveJump`; Leap/Dash need movement validation |
| Chill / Freeze | RESOLVED ONLY | Chill = snare debuff (native `MOD_DECREASE_SPEED` carrier), Freeze = root + frozen state (`AURA_STATE_FROZEN`) so Shatter-style conditions work; both need the Buff/Debuff executor |

### Activation contract

`Effect.ActivationMask` is the only activation authority ([EFFECT_ACTIVATION.md](EFFECT_ACTIVATION.md)). The
effect executor must read it and nothing else (no per-kind activation flags).

### Trigger bus (design)

One per-player event bus fed by the existing hooks: Cast, Hit, Crit, Tick (carrier `OnEffectPeriodic` and
executor), Heal, Kill, Dispel, PeriodicApplied/Expired, DamageTaken. Subscribers are Imbues/Emitters with
`Effect.TriggerEvent`, `TriggerChance`, `InternalCooldown`, `ProcsPerMinute`, source/target filters and
`MaxProcChainDepth`. Events carry the payload event id so a triggered effect cannot re-trigger itself beyond the
chain depth. Not implemented.

## 2. Echo

| Property | State | Rule to implement |
| --- | --- | --- |
| `Echo.TargetRule` | only SameTarget executed (inspector reports others as not executed) | NearestOther / Random within `Echo.Range` from the root target, excluding the root; deterministic selection per event |
| `Echo.Range` | RESOLVED ONLY | radius for the TargetRule search; clamp to the payload's max range |
| Echo periodics | RUNTIME CODED: separate lineage per echo generation ([ECHO_RUNTIME.md](ECHO_RUNTIME.md)) | in-game test |

## 3. Delivery.Kind

Direct ↔ Projectile ↔ Beam changes need a delivery adapter; none exists (`DeliveryChangeSupport` =
UNSUPPORTED). Projectile needs a native missile carrier per element; Beam is CLIENT PATCH REQUIRED
([CHANNEL_RUNTIME.md](CHANNEL_RUNTIME.md)).

## 4. Conditions beyond primary output

Conditional modifiers are evaluated per combat event only for `Primary.Scaling` (and the properties that read
it at hit). Periodic, echo and effect properties are resolved unconditionally. Next: evaluate conditionals for
`Periodic.Conversion`/`ConversionEfficiencyPct` at plan time and for `Echo.Chance` at scheduling time, with the
same `CombatContext`.

## 5. Tooltip OUT v2 (design)

Extends the plan in [PRIMARY_OUTPUT.md](PRIMARY_OUTPUT.md) ("OUT v2"):
- values from `BasePoints` + die average + level scaling + the player's spell power coefficient, target-free;
- periodic lines per presentation group: total over duration, tick count, interval;
- the instance school mask as a label (combined schools named, e.g. "Frostfire");
- echo lines as chance × scaling, never as a guaranteed amount;
- versioned record (`OUT2`), `OUT` kept for older addons.

## 6. Native aura capacity

`MAX_AURAS` stays 255 (uint8 wire slot). Carriers fall back to the executor when the target's visible slots
are full, counted in diagnostics. **ExtendedAuraSlots** (more visible auras) is documentation only: it needs a
new wire format and a client change (CLIENT PATCH REQUIRED), and is not planned for this milestone.

## 7. Forge

Remaining Forge work ([ULDuar_ABILITY_FORGE_ARCHITECTURE.md](ULDuar_ABILITY_FORGE_ARCHITECTURE.md)):
- persistence of committed variants against reserved Forge IDs 90000..90023 (ledger RESERVED, not INTRODUCED);
- the client content manifest (variant name/icon per VariantHash) — CLIENT PATCH REQUIRED;
- validation that rejects unsupported combinations listed above instead of resolving them silently;
- the Lab's "intentionally bad combinations" stay Lab-only.

## 8. Client (ulduar-client-patch)

- Capabilities stay 0 until proven end to end; transport, Range, movement and aura work happen only on Windows
  against the exact 3.3.5.12340 build (see the client's Windows handoff procedure).
- The development loader stays DEVELOPMENT ONLY. A production loader is a separate future milestone (signed,
  documented install, no evasion behavior).
