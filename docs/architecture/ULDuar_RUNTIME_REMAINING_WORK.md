# Runtime remaining work (2026-09-27)

What is still missing between the resolved ability model and gameplay, in the milestone's priority order.
State words ([ULDuar_ABILITY_RUNTIME.md](ULDuar_ABILITY_RUNTIME.md), "Validation states"): PURE TESTS, SYNTAX
CHECKED, LOCAL BUILD PASS, IN-GAME PASS, IN-GAME FAIL, NOT TESTED, RESOLVED ONLY, CLIENT PATCH REQUIRED; plus
ENGINE MODEL (pure rules + tests, no runtime) and HELD (coded, disabled by `UlduarAbilities.PostJ0Runtime = 0`).

## 0. Gate: periodic isolation (Stage J0)

Runtime expansion waits for an in-game PASS of checklist **Stage J0 — Periodic isolation regression**
([ULDuar_LOCAL_VALIDATION_CHECKLIST.md](ULDuar_LOCAL_VALIDATION_CHECKLIST.md)). Current result: **NOT
RECORDED** (fix in source: ulduar-wow `8dbc1d3`, module `0eef40b`).

Everything coded after the fix that changes combat behavior is HELD behind `UlduarAbilities.PostJ0Runtime`
(default 0, module `698e57b`), so the J0 retest build behaves like the fix on those paths:

| Feature | State | Also needs |
| --- | --- | --- |
| Effect executor: Chill (snare carrier), Freeze (frost root carrier) | HELD; SYNTAX CHECKED + PURE TESTS | ledger append of PROPOSED `PC3-GENERIC-EFFECT-CARRIER-POOL-005`, then SQL 009 |
| Drain Life ChannelAuraTick (catalog id 43) | HELD; SYNTAX CHECKED + PURE TESTS | SQL 010 |
| Echo.TargetRule other than SameTarget, Echo.Range | HELD; SYNTAX CHECKED + PURE TESTS | - |
| Per-event conditions on Periodic.Conversion, ConversionEfficiencyPct, Echo.Chance | HELD; SYNTAX CHECKED + PURE TESTS | - |

After J0 PASS: set `PostJ0Runtime = 1` and run checklist stages P1-P4.

## 1. Effect runtime ([EFFECT_RUNTIME.md](EFFECT_RUNTIME.md))

| Effect kind | State | Next step |
| --- | --- | --- |
| Chill / Freeze | HELD (see §0) | ledger append + SQL 009 + in-game P1 |
| Generic Buff / Debuff (other stats) | RESOLVED ONLY | carrier-family audit per native AuraType ([EFFECT_RUNTIME.md](EFFECT_RUNTIME.md) §5); no new range before that audit and maintainer approval |
| Emitter | RESOLVED ONLY | after the trigger bus has a runtime publisher |
| Imbue | RESOLVED ONLY | subscription on the trigger bus |
| Summon | RESOLVED ONLY | per archetype (ControlledPet, Guardian, Stationary, Totem) |
| Displacement | RESOLVED ONLY (inspector: not executed) | Knockback/Pull via native `Unit::KnockbackFrom` / `GetMotionMaster()->MoveJump` |

`Effect.ActivationMask` is the only activation authority ([EFFECT_ACTIVATION.md](EFFECT_ACTIVATION.md)).

### Trigger bus ([TRIGGER_BUS.md](TRIGGER_BUS.md))

ENGINE MODEL + PURE TESTS (module `357ddf3`): routing, filters, chance/PPM, ICD, charges + consumption rule,
loop/depth guard, echo isolation, per-event budget. No runtime publisher or subscriber yet (after J0).

## 2. Echo

| Property | State |
| --- | --- |
| `Echo.TargetRule`, `Echo.Range` | HELD (SameTarget behavior until J0) |
| Echo periodics (converted) | IN-GAME FAIL 2026-09-27 → FIXED IN SOURCE; J0 retest NOT RECORDED |
| Echo of a native payload DoT | known limitation: no second native DoT ([NATIVE_PERIODIC_VIRTUALIZATION.md](NATIVE_PERIODIC_VIRTUALIZATION.md)) |

## 3. Channels ([CHANNEL_RUNTIME.md](CHANNEL_RUNTIME.md))

| Item | State |
| --- | --- |
| Drain Life ChannelAuraTick | HELD (see §0) |
| Blizzard AreaExecutionRoot | ENGINE MODEL (`SelectAreaRootSources`); not wired |
| ChannelTime / TickInterval retiming | ENGINE MODEL (`PlanChannelRetime`, total output preserved); no per-family adapter |

## 4. Delivery.Kind

Direct ↔ Projectile ↔ Beam changes need a delivery adapter; none exists (`DeliveryChangeSupport` =
UNSUPPORTED). Beam is CLIENT PATCH REQUIRED.

## 5. Conditions

Primary.Scaling per hit: RUNTIME. Periodic.Conversion / ConversionEfficiencyPct per converted hit and
Echo.Chance per root impact: HELD (see §0). Other conditional properties: RESOLVED ONLY (the inspector lists
them).

## 6. Periodic healing

ENGINE MODEL (`PeriodicHealing.*`: output selection, separate key space from damage). Runtime: an
executor-backed HoT needs no IDs; a carrier-backed HoT needs a separate `PeriodicHealingCarrier` range (collision
audit, proposal, maintainer approval, ledger append, SQL). None proposed yet.

## 7. Tooltip OUT v2 ([PRIMARY_OUTPUT.md](PRIMARY_OUTPUT.md))

ENGINE MODEL (`OutputEstimate.*`: target-free estimate mirroring the core's done-side terms, school labels). No
`OUT2` record or addon change yet; `OUT` unchanged.

## 8. Native aura capacity

`MAX_AURAS` stays 255. Carriers fall back to the executor when visible slots are full. ExtendedAuraSlots is
documentation only (CLIENT PATCH REQUIRED).

## 9. Forge

- persistence of committed variants against reserved Forge IDs 90000..90023 (RESERVED, not INTRODUCED);
- the client content manifest (variant name/icon per VariantHash) — CLIENT PATCH REQUIRED;
- validation that rejects unsupported combinations instead of resolving them silently.

## 10. Client (ulduar-client-patch)

Unchanged: capabilities stay 0 until proven end to end. Order: transport → HELLO/WELCOME → VariantCache →
DynamicVariantMetadata → Range → Movement → native aura audit → DynamicAuraPresentation. The development loader
stays DEVELOPMENT ONLY.
