# Periodic property decisions

Status of the periodic properties that are resolved but not executed, with the decision each one needs.
None is implemented in this milestone. "Decision" = what the maintainer must choose; "Proposal" = the
recommended default.

## 1. Properties

| Property | Today | Proposal | Blocker |
| --- | --- | --- | --- |
| `Periodic.FinalTick` | RESOLVED ONLY | one extra tick at expiration (native `SPELL_ATTR…` style "tick on remove"), counted in `TickCount` so total output is **preserved** (the pool is split over N+1 ticks) | executor: easy; carrier: needs `AfterEffectRemove` by expire only (not dispel/death) to deal one tick; both must use the same TickCount formula |
| `Periodic.ScalingPerStackPct` | RESOLVED ONLY | a per-stack **amount** multiplier on top of linear stacking: tick = base × stacks × (1 + pct × (stacks − 1)). Default 0 = today's linear stacking | changes `SyncCarrierAura`'s per-stack amount (native multiplies by stacks); needs a clamp against integer overflow |
| `Periodic.TickScalingPerStackPct` | RESOLVED ONLY | a per-stack **interval** change (faster ticks per stack) with total output preserved per stack. Decision: keep or drop; it overlaps with haste | amplitude change on a running carrier resets the phase (native `CalculatePeriodic`) |
| `Periodic.SnapshotStats` | RESOLVED ONLY | see §2 | |

## 2. Snapshot policy

| Part | Carrier (native tick) | Executor | Decision |
| --- | --- | --- | --- |
| Caster done bonuses (spell power, % done) | snapshot at application/refresh (in the pool) | snapshot | keep snapshot: matches native 3.3.5 DoTs |
| Crit chance | snapshot at application/refresh (`SetCritChance`) | snapshot | keep |
| Haste on interval | snapshot at application (`Periodic.CanHaste`) | snapshot | keep |
| Target taken modifiers | **dynamic per tick** | snapshot at hit | the carrier behavior is the target; the executor is a fallback |
| `SnapshotStats = false` (dynamic caster stats) | would need re-running done bonuses per tick | same | proposal: not supported; reject in validation until a use case exists |

## 3. Native periodic retiming (Corruption duration/rate)

Changing `Periodic.Duration` / `Periodic.TickInterval` on a **native** periodic ability (not a conversion) stays
RESOLVED ONLY. A safe rule:
- duration: `Aura::SetMaxDuration` + `SetDuration` at application, from the aura script, before the first tick;
- interval: `DoEffectCalcPeriodic` on the native aura; the core recomputes the tick cap from MaxDuration;
- total output: **preserved** by default (amount × native ticks / new ticks), opt-in otherwise;
- requires an aura script bound to each retimed spell (per ability SQL), like the carrier.

Not implemented: every retimed native spell needs its own binding and an in-game test.

## 4. Periodic healing family (design)

- A separate `PeriodicHealingCarrier` pool (`SPELL_AURA_PERIODIC_HEAL` rows, same generic shape, SchoolMask 127,
  per-aura school override). It needs its own proposed range and ledger transaction; the tombstoned
  141351..141357 are never reused.
- Base: the core's `damageBeforeTakenMods` for heals (pre-taken healing), rescaled like the damage path.
- Native tick: `HandlePeriodicHealAurasTick` applies healing taken modifiers, crit and overheal per tick.
- The school override must also be read by the heal tick (`SpellHealingBonusDone/Taken` school) — a new
  consumer to add to [PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md) when implemented.

## 5. Element property migration (Primary.Element / Effect.Element → SchoolMask)

Today `Primary.Element` / `Effect.Element` are single-value enums (Original, Physical … Arcane). The runtime
already carries a `SpellSchoolMask`, and carriers accept any non-empty combination.

| Step | Change | Compatibility |
| --- | --- | --- |
| 1 | add `Primary.SchoolMask` / `Effect.SchoolMask` (bitmask, 0 = native) | new properties; old ones unchanged |
| 2 | resolver maps `Element = X` to `SchoolMask = 1 << X` when `SchoolMask` is unset | old Essences resolve identically |
| 3 | conversions that produce combined schools write the mask; single-element conversions keep writing Element | |
| 4 | `Element` becomes an alias (like `Primary.Damage` → `Primary.Scaling`); inspector shows the mask | saved builds keep loading |
| 5 | client descriptor sends the mask; `Element` labels derive from it ("Frostfire" for Frost\|Fire) | client update |

Open question for combined schools: the multi-school decisions in
[PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md) (crit source, done/taken stacking) must be settled
before a combined-school conversion ships.
