# Periodic runtime (direct-to-periodic conversion)

Code:
- `src/engine/ExecutionModel.*` (`PlanConvertedPeriodic`, `PeriodicTickCount`, `AdvancePeriodic`)
- `src/AbilityPeriodicExecutor.*`
- `src/AbilitySpellScript.cpp` (split at hit)
- `src/engine/RuntimeMechanics.cpp` (stacking and spread)

Tests: `tests/AbilityRuntimeSemanticsTest.cpp` (UlduarPeriodicConversion.*).

## Model

Periodic conversion is **not** secondary scaling. A direct ability converts part of its primary output of one
hit into a periodic pool:

```
BaseOutput      = the hit's resolved output (native amount x Primary.Scaling x echo x secondary scaling)
ConvertedOutput = BaseOutput x Periodic.Conversion          (clamped to 0..100% of the base)
ImmediateOutput = BaseOutput - ConvertedOutput               (stays on the hit)
PeriodicPool    = ConvertedOutput x Periodic.ConversionEfficiencyPct   (applied ONCE to the whole pool)
TickOutput      = PeriodicPool / TickCount
TickCount       = floor(Duration / Interval) + (InitialTick ? 1 : 0),  Interval clamped to Duration
```

**Worked example:** Base 1000, 30%, 200%, 6 s, 1 s → Immediate 700, Pool 600, 6 ticks of 100 (nominal total
1300).

**Tick rate and duration only redistribute:**
- A 0.5 s interval gives 12 ticks of 50.
- A 12 s duration gives 12 ticks of 50.

Neither multiplies damage. A per-tick scaling mechanic would be a separate, explicit property; none exists.

## Runtime behavior (RUNTIME CODED, REQUIRES IN-GAME TEST)

- **Plan.** `AbilityPeriodicExecutor::Plan` builds the plan per hit. The interval is hasted at application if
  `Periodic.CanHaste` (snapshot) and never falls below `MinPeriodicTickInterval`. The spell script keeps
  `Immediate` on the hit and hands `Pool` to `Apply`.
- **Tick chain.** An optional application tick at +1 ms does not consume time. Regular ticks follow at every
  full interval. `AdvancePeriodic` stops before a partial trailing interval, so exactly `TickCount` ticks deal
  exactly the pool. Two defects are fixed:
  - With `InitialTick`, the old chain dealt only 6/7 of the pool.
  - A duration that was not a multiple of the interval dealt an extra partial tick.
- **Ticks keep native combat behavior.** Each tick goes through:
  - crit (only if `Periodic.CanCrit`, rolled per tick);
  - `CalculateSpellDamageTaken` (armor, block, resilience, crit bonus);
  - `DealDamageMods`, absorb/resist (`CalcAbsorbResist`), `DealSpellDamage`;
  - a school/damage immunity check per tick.

  The pool is nominal output, not guaranteed health loss.
- **Stacking.** Stacking and refresh follow `Periodic.StackBehavior` (`ApplyPeriodic`).
  - A refresh gets no application tick, so its pool is divided by the regular ticks only.
  - The interval re-snapshots haste.
  - Efficiency is never re-applied: every application brings its own pool share, and stacks multiply ticks
    by `Periodic.TickScalingPerStackPct`.
- **Spread** on tick: `SpreadPeriodic` (unchanged).
- **Echo executions.** They convert their own echo-scaled root (echo root 600 → 420 immediate + 360 pool). Only
  with `Echo.CanEchoPeriodic` do they apply the pool; otherwise the echo deals only the immediate part and
  cannot weaken or refresh a running periodic.

## Known limits

| Item | State |
| --- | --- |
| Visible debuff / stack count on the target | UNSUPPORTED: no carrier aura yet. Ticks appear as the spell's damage in the log (design: [architecture appendix](ULDuar_ABILITY_ARCHITECTURE_APPENDIX.md), section 12) |
| Ticks count as periodic damage for procs/talents | NO: dealt as direct spell damage |
| Healing conversion (HoT) | RESOLVED ONLY |
| Retiming native periodic auras (Corruption duration/rate) | RESOLVED ONLY |
| `Periodic.FinalTick`, `Periodic.ScalingPerStackPct`, `Periodic.SnapshotStats` | RESOLVED ONLY |
