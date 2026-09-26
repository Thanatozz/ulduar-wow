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

  The pool is nominal output, not guaranteed health loss. The exact snapshot/dynamic split of every modifier
  is in [PERIODIC_DAMAGE_PIPELINE_AUDIT.md](PERIODIC_DAMAGE_PIPELINE_AUDIT.md). No modifier is applied
  twice.
- **Stacking.** Stacking and refresh follow `Periodic.StackBehavior` (`ApplyPeriodic`).
  - A refresh gets no application tick, so its pool is divided by the regular ticks only.
  - The interval re-snapshots haste.
  - Efficiency is never re-applied: every application brings its own pool share, and stacks multiply ticks
    by `Periodic.TickScalingPerStackPct`.
- **Spread** on tick: `SpreadPeriodic` (unchanged).
- **Echo executions.** They convert their own echo-scaled root (echo root 600 → 420 immediate + 360 pool). Only
  with `Echo.CanEchoPeriodic` do they apply the pool; otherwise the echo deals only the immediate part and
  cannot weaken or refresh a running periodic.
  - An echo pool lands on the same caster+target+ability instance as the original, per
    `Periodic.StackBehavior`. With the default RefreshDuration, the echo's smaller tick amount replaces the
    running one. That weakening is why `Echo.CanEchoPeriodic` is off by default.
  - The instance keeps the lineage (`FromEcho`) of the application that created it.

## Blizzlike carrier (design; implementation deferred)

Today the executor owns the whole periodic: amount, stacks, timing and damage. Nothing is visible on the
target. The Blizzlike target is **one visible aura per caster + target + ability instance**, showing icon,
duration, remaining time and stacks. The executor keeps the amount and stack state; the aura is the carrier.

### Core APIs (audited)

| Need | API | Note |
| --- | --- | --- |
| Put a periodic aura on the target | `Unit::AddAura` / `CastSpell` of a carrier spell with `SPELL_AURA_PERIODIC_DAMAGE` | caster = the player, so `GetCasterGUID` isolates casters natively |
| Exact per-tick amount | `DoEffectCalcAmount` script hook | runs **after** `SpellDamageBonusDone` in `AuraEffect::CalculateAmount`, so setting the amount there replaces the done bonus (no double coefficient); `amount *= stacks` follows |
| Interval | `DoEffectCalcPeriodic` hook (`AuraEffectCalcPeriodicFn`: `isPeriodic`, `amplitude`), `AuraEffect::SetPeriodicTimer`, `ResetPeriodic` | the executor's hasted, clamped interval |
| Duration and remaining time | `Aura::SetMaxDuration`, `Aura::SetDuration` | sent to the client in the aura update |
| Stacks | `Aura::SetStackAmount` | shown natively as the stack count |
| Tick damage | native `HandlePeriodicDamageAurasTick` | immunity, `SpellDamageBonusTaken(DOT)` per tick, armor, crit, spell resilience, `CalcAbsorbResist(DOT)`, **no block**, no pushback |
| Periodic log and procs | same handler: `SendPeriodicAuraLog`, `ProcSkillsAndAuras(PROC_FLAG_DONE_PERIODIC / TAKEN_PERIODIC)` | converted ticks become periodic damage for procs |

### Avoiding double application with a native tick

A native tick applies `SpellDamageBonusTaken` per tick. The carrier must therefore receive a **pre-taken**
pool; otherwise taken mods would be applied twice (once in Base at launch, once per tick).

- Base for a carrier = the hit's amount **before** target taken mods:
  - `TargetInfo::damageBeforeTakenMods`, scaled by the same `Primary.Scaling` × echo × secondary factor;
  - or `SpellDamageBonusDone` alone, recomputed caster-side.
- The done bonus is not reapplied: the amount is set in `DoEffectCalcAmount`, after `SpellDamageBonusDone`.
- Crit: the native tick rolls `AuraEffect::GetCritChance()`. The core snapshots it with
  `CalcPeriodicCritChance`. `Periodic.CanCrit` maps to `AuraEffect::SetCritChance` (0 when off, the caster's
  spell crit when on) right after application.

Result: taken mods become dynamic per tick, exactly like a native DoT; block and pushback disappear
(divergences 1, 2 and 5 of the audit).

### Minimum reusable carrier

No DBC entry per ability variant. The candidates:

1. **One carrier per school** (7 spells: physical, holy, fire, nature, frost, shadow, arcane). Generic icon and
   name, e.g. "Burning" / "Frostbite". This is the minimum for a visible aura with the right school and damage
   color.
2. **One carrier per ability family** for its own icon. This needs one client DBC row each.
3. **Reuse the payload spell** (Frostbolt's aura). Rejected: it would also apply the native slow and the
   native effect set.

The carrier needs no per-variant data: amount, interval, duration and stacks are all set by script.

### Support split

| Part | State |
| --- | --- |
| Pool, tick count, stacking, spread, immunity, mitigation (executor) | SERVER-COMPLETE (runtime today) |
| Native periodic mitigation, dynamic taken mods, periodic procs, periodic combat log | SERVER-COMPLETE once a carrier spell exists **server-side** (`spell_dbc`), REQUIRES IN-GAME TEST |
| Visible icon, duration, remaining time and stack count on the target frame | CLIENT-REQUIRES-CARRIER: the client draws only spells present in its own `Spell.dbc`. A server-only `spell_dbc` carrier is unknown to the client, so it gets no icon, and the effect of an unknown id in `SMSG_AURA_UPDATE` is untested |
| Ability-specific icon, name and tooltip per ability | CLIENT-PATCH-REQUIRED (one `Spell.dbc` row per family; option 2) |

A reused **existing** client spell of the matching school, with a harmless periodic-damage effect, would be
visible without a client patch, but it shows that spell's own name and icon. Choosing one is a content
decision; the carrier id must be a config value, not a hardcoded spell branch.

### Periodic proc semantics

Today converted ticks trigger **no procs** (see the audit, divergence 4). Two ways to fix it:

- **Through the carrier (preferred).** The native tick raises `PROC_FLAG_DONE_PERIODIC` /
  `PROC_FLAG_TAKEN_PERIODIC` with the carrier spell. Generic periodic procs (trinkets, "periodic damage"
  effects) work. Class talents filtered by `SpellFamilyFlags` do not match a generic carrier; that is
  intended, a converted Frostbolt is not a Corruption.
- **Without a carrier.** `DealTick` could call `Unit::ProcSkillsAndAuras(caster, target, PROC_FLAG_DONE_PERIODIC,
  PROC_FLAG_TAKEN_PERIODIC, ...)` with the payload spell after `DealSpellDamage`. The payload spell's own
  family flags would then match talents written for the direct spell, so a Frostbolt tick could trigger
  "on Frostbolt hit" talents. That is a gameplay decision, so it is not done.

Both keep the no-double-application rule: the proc call never deals damage itself.

## Known limits

| Item | State |
| --- | --- |
| Visible debuff / stack count on the target | CLIENT-REQUIRES-CARRIER: no carrier aura yet (design above). Ticks appear as the spell's damage in the log |
| Ticks count as periodic damage for procs/talents | NO: dealt as direct spell damage, and no proc is raised at all (design above) |
| Block on melee/ranged-class physical ticks; taken mods snapshotted | Divergences from a native DoT, fixed by the carrier ([audit](PERIODIC_DAMAGE_PIPELINE_AUDIT.md) §4) |
| Healing conversion (HoT) | RESOLVED ONLY |
| Retiming native periodic auras (Corruption duration/rate) | RESOLVED ONLY |
| `Periodic.FinalTick`, `Periodic.ScalingPerStackPct`, `Periodic.SnapshotStats` | RESOLVED ONLY |
