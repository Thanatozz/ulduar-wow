# Periodic damage pipeline audit

Code-level audit of the **converted periodic** path (direct hit → `Periodic.Conversion` → executor ticks).
It is compared with the native periodic aura path (`SPELL_AURA_PERIODIC_DAMAGE`).

Code read:
- `Spell::EffectSchoolDMG` (`SpellEffects.cpp`, launch-target damage);
- `Spell::DoAllEffectOnTarget` (`Spell.cpp`: `OnHit` hook, then `CalculateSpellDamageTaken`, `DealDamageMods`,
  `DealSpellDamage`);
- `Unit::CalculateSpellDamageTaken`, `Unit::isSpellBlocked`, `Unit::DealDamageMods`, `Unit::DealDamage` (`Unit.cpp`);
- `AuraEffect::CalculateAmount` and `AuraEffect::HandlePeriodicDamageAurasTick` (`SpellAuraEffects.cpp`);
- module: `AbilitySpellScript.cpp` (`ScaleSecondaryPayload`, `aura_ulduar_ability_runtime`),
  `AbilityPeriodicExecutor.cpp` (`Plan`, `Apply`, `Tick`, `DealTick`), `engine/ExecutionModel.cpp`.

The formula is unchanged:
```
Converted = Base x Conversion          Immediate = Base - Converted
Pool      = Converted x Efficiency     (once)
Tick      = Pool / TickCount           (InitialTick counts toward TickCount; no partial trailing tick)
```

## 1. Where Base comes from

Order of operations for one hit of an ability with conversion:

1. **`Spell::EffectSchoolDMG`** runs at launch-target.
   - `damage = native base points (+ die)`.
   - `damage = caster->SpellDamageBonusDone(target, info, damage, SPELL_DIRECT_DAMAGE, ...)`:
     spell power/attack power coefficient plus caster done mods.
   - `damage = target->SpellDamageBonusTaken(caster, info, damage, SPELL_DIRECT_DAMAGE, ...)`:
     target taken mods.
   - `m_damage += damage`.
2. **`DoAllEffectOnTarget`** calls the `OnHit` script hook. Our `ScaleSecondaryPayload` reads
   `GetHitDamage()` (= `m_damage`) and applies, once each:
   - `Primary.Scaling` (`PrimaryDamageMultiplier`, including the legacy Damage rank);
   - conditional `Primary.Scaling` modifiers;
   - `HitOutputScale` = echo scaling × secondary scaling (propagation/echo hits only);
   - then conversion: `Plan(GetHitDamage())` and `SetHitDamage(Immediate)`.
3. **`DoAllEffectOnTarget`** then runs `CalculateSpellDamageTaken(m_damage = Immediate, crit)`: crit,
   armor, block, resilience, absorb/resist on the **immediate part only**.

So **Base = native base + coefficient + caster done mods + target taken mods, × Primary.Scaling × echo ×
secondary**. It is taken before crit and mitigation.

## 2. What each tick does

`DealTick(caster, target, spell, school, TickAmount × stackFactor, Periodic.CanCrit)`:

1. `IsImmunedToDamageOrSchool(school)`: immunity is checked per tick. If immune, the tick is dropped and a
   `SendSpellDamageImmune` is sent.
2. Crit roll if `Periodic.CanCrit`: `SpellDoneCritChance` + `SpellTakenCritChance`, rolled per tick.
3. `CalculateSpellDamageTaken(amount, crit)`. It runs:
   - the `ModifySpellDamageTaken` script hook and the victim AI's `OnCalculateSpellDamageReceived`;
   - armor, for physical schools without `SPELL_ATTR4_IGNORE_DAMAGE_TAKEN_MODIFIERS`;
   - melee/ranged damage class: block (physical), melee crit bonus, melee/ranged resilience;
   - magic/none damage class: `SpellCriticalDamageBonus`, spell resilience;
   - `CalcAbsorbResist` (absorb shields, resist).

   It does **not** call `SpellDamageBonusDone` or `SpellDamageBonusTaken`.
4. `DealDamageMods` (evade, flight, dead), `SendSpellNonMeleeDamageLog`, `DealSpellDamage`. The damage type
   is `SPELL_DIRECT_DAMAGE`.

## 3. Classification

| Modifier | Converted periodic | Native DoT (for comparison) |
| --- | --- | --- |
| Native base points | SNAPSHOT ON APPLICATION (in Base) | snapshot (`CalculateAmount`) |
| Spell power / attack power coefficient | SNAPSHOT ON APPLICATION (`SpellDamageBonusDone`, direct coefficient) | snapshot (DOT coefficient) |
| Caster done mods (% done, talents, spell mods) | SNAPSHOT ON APPLICATION (`SpellDamageBonusDone` at launch) | snapshot |
| Target taken mods (% taken, Curse of Elements, …) | SNAPSHOT ON APPLICATION (`SpellDamageBonusTaken` at launch) | DYNAMIC PER TICK |
| `Primary.Scaling` | SNAPSHOT ON APPLICATION, applied once in `OnHit` | via our aura `CalcAmount`, once |
| Echo scaling | SNAPSHOT ON APPLICATION, once (`HitOutputScale`) | once |
| Secondary scaling | SNAPSHOT ON APPLICATION, once (`HitOutputScale`) | once |
| `Periodic.Conversion` | SNAPSHOT ON APPLICATION (`PlanConvertedPeriodic`) | n/a |
| `Periodic.ConversionEfficiency` | SNAPSHOT ON APPLICATION, once per pool; never reapplied on refresh, stack or spread | n/a |
| `Periodic.TickScalingPerStack` | DYNAMIC PER TICK (`stackFactor`) | n/a |
| Per-tick crit | DYNAMIC PER TICK if `Periodic.CanCrit` (the direct hit's crit affects only Immediate) | dynamic per tick |
| Armor | DYNAMIC PER TICK (physical schools) | dynamic per tick |
| Block | DYNAMIC PER TICK for melee/ranged-class physical carriers: **divergence**, see §4 | NOT APPLIED (DoTs are never blocked) |
| Resilience | DYNAMIC PER TICK (melee/ranged or spell rating by damage class) | dynamic per tick (spell) |
| Absorb / resist | DYNAMIC PER TICK (`CalcAbsorbResist`, `SPELL_DIRECT_DAMAGE` type) | dynamic per tick (`DOT` type) |
| Target dynamic taken mods applied after application | NOT APPLIED (Base already contains the launch-time taken mods) | dynamic per tick |
| `ModifySpellDamageTaken` hook / AI hook | DYNAMIC PER TICK (each tick is a separate call on a separate amount) | the periodic hooks instead |
| Immunity | DYNAMIC PER TICK (`IsImmunedToDamageOrSchool`) | dynamic per tick |

### POSSIBLE DOUBLE APPLICATION: none found

- **Taken mods.** They are applied once, at launch, into Base. The tick path never calls
  `SpellDamageBonusTaken`.
- **Done mods / coefficient.** They are applied once, at launch. `DealTick` never calls `SpellDamageBonusDone`.
- **Crit.** The direct crit is rolled by `CalculateSpellDamageTaken` on `m_damage` after `OnHit`, so it
  touches only Immediate. The pool is pre-crit and each tick rolls its own crit.
- **Mitigation.** Armor, resilience and absorb run on Immediate once and on each tick once: disjoint parts of
  the damage, never the same part twice.
- **Script hooks.** `ModifySpellDamageTaken` runs on Immediate and on each tick: again disjoint amounts.
- **Scaling.** `Primary.Scaling`, echo and secondary scaling are applied once per hit, before `Plan`. The
  pool is never rescaled.
- **Efficiency.** It is applied once in `PlanConvertedPeriodic`. On refresh, `Apply` spreads the already
  efficient `plan.Pool` over the regular ticks (`Pool / regularTicks`). Spread copies `TickAmount`.
- **Native payload auras** (Fireball's own DoT). `aura_ulduar_ability_runtime::CalculateAmount` runs after
  `SpellDamageBonusDone`. On a change, the amount is recomputed from scratch with `CalculateAmount`, never
  multiplied onto the current amount, so there is no compounding on refresh.

No code change is required for double application.

## 4. Divergences from a native DoT (executor-backed instances)

Since the carrier milestone these apply only to executor-backed instances (§5). Carrier-backed instances
use the native tick and have none of them.

1. **Block on physical melee/ranged-class ticks.** `CalculateSpellDamageTaken` rolls block for
   melee/ranged damage-class spells with physical school. Each tick subtracts the full shield block value.
   Native DoTs are never blocked. This matters only for converted physical melee/ranged carriers against a
   blocking target facing the caster.
   - The adapter cannot switch block off without mutating `SpellInfo` (`SPELL_ATTR0_NO_ACTIVE_DEFENSE`).
   - Restoring the blocked part after the call would skip absorb for that part.
   - Fix: the carrier aura (`PERIODIC_RUNTIME.md` §Blizzlike carrier) gives native DoT mitigation.
2. **Taken mods are snapshotted, not dynamic.** A Curse of Elements applied after the conversion does not
   raise the ticks. Correction: an earlier version of this audit said the pre-taken amount was available as
   `TargetInfo::damageBeforeTakenMods`. That field is recorded **only for heals**. The carrier milestone adds
   `TargetInfo::damageDoneBeforeTaken` for `SCHOOL_DAMAGE` (§5).
3. **Direct coefficient, not DOT coefficient.** The pool comes from the direct coefficient of the hit. This
   is intended: conversion moves direct output into time.
4. **Damage type `SPELL_DIRECT_DAMAGE`.** Ticks are logged as spell hits (`SMSG_SPELLNONMELEEDAMAGELOG`),
   not periodic logs. **Ticks trigger no procs.** `DealSpellDamage` only calls `DealDamage`. Procs are
   raised by `Spell` (`ProcSkillsAndAuras`) or by the aura tick, and `DealTick` calls neither. So talents
   such as "your periodic damage has a chance to…" never see converted ticks. See `PERIODIC_RUNTIME.md`
   §Periodic proc semantics.
5. **Pushback.** `DealDamage` applies spell pushback for non-DOT damage types, so a converted tick can push
   back (or abort) a player target's cast. A native DoT does not. Not relevant against creatures.
6. **`SPELL_AURA_PERIODIC_LEECH` payload auras.** Our aura `CalculateAmount` does not scale them.
   `Primary.Scaling`, echo and secondary scaling are NOT APPLIED to a native leech aura. No catalog carrier has
   one.

## 5. Carrier-backed path (native periodic carrier)

Code: `AbilityPeriodicCarrier.cpp`, `AbilityPeriodicExecutor.cpp` (`ConvertHit`), `Engine::PlanPeriodicForBacking`.
Design: [PERIODIC_RUNTIME.md](PERIODIC_RUNTIME.md).

**Core change (minimal, additive).**
- `Spell::EffectSchoolDMG` adds the damage after `SpellDamageBonusDone` and before `SpellDamageBonusTaken`
  to `m_damageDoneBeforeTaken`. Without the direct bonus it adds the raw damage.
- `Spell::DoAllEffectOnLaunchTarget` applies the caster-side AoE target cap (>10 targets) and the chain
  damage multiplier to it, but not the target-side `CalculateAOEDamageReduction`. It then stores the result
  in `TargetInfo::damageDoneBeforeTaken`.
- Nothing reads the field except the module; native damage is unchanged.

**Spell script.**
```
nativeHit = GetHitDamage()                        (core's post-taken, pre-crit hit)
preTaken  = damageDoneBeforeTaken x nativeHit / TargetInfo::damage   (other scripts' changes carried)
scaled    = the hit after Primary.Scaling, conditions, echo, secondary
Pool      = preTaken x (scaled / nativeHit) x Conversion x Efficiency
Immediate = scaled x (1 - Conversion)
```

| Modifier | Carrier-backed classification |
| --- | --- |
| Native base, SP/AP coefficient, caster done mods | SNAPSHOT ON APPLICATION (`damageDoneBeforeTaken`); the carrier's own done bonus is overwritten in `DoEffectCalcAmount`, never added |
| `Primary.Scaling`, conditions, echo, secondary | SNAPSHOT ON APPLICATION, once (same factor as the hit) |
| Conversion, Efficiency | SNAPSHOT ON APPLICATION, once; refresh/stack/spread never reapply |
| Target taken mods (`SpellDamageBonusTaken`) | DYNAMIC PER TICK (`DOT`); the direct hit's taken mod stays on Immediate only |
| Crit | chance SNAPSHOT at application/refresh (`SetCritChance`, payload spell's chance, 0 without `Periodic.CanCrit`); roll DYNAMIC PER TICK |
| Armor | DYNAMIC PER TICK (physical carrier) |
| Block | NOT APPLIED (native DoT) |
| Resilience, absorb/resist | DYNAMIC PER TICK (`CalcAbsorbResist(DOT)`) |
| Immunity | DYNAMIC PER TICK (native tick); application refused by `AddAura` if immune |
| Pushback | NOT APPLIED (`DOT`) |
| Procs | native periodic procs per tick (`PROC_FLAG_DONE/TAKEN_PERIODIC`), none added by the module |
| Periodic haste | the engine interval only; the core's haste step never applies (no family, no attribute) |

POSSIBLE DOUBLE APPLICATION: none.
- Taken modifiers are either on Immediate (the hit) or per tick (the pool), never both.
- Done bonuses are in the pool once, because the carrier's `CalculateAmount` result is replaced, not scaled.

## 6. Tests

Pure rules: `UlduarPeriodicConversion.*` and `UlduarPeriodicCarrier.*` (pre-taken pool, efficiency once,
exclusive tick source, aura tick-count sync) cover:
- exact pool with InitialTick;
- uneven durations;
- no efficiency reapplication on refresh or stack.

The core-side classification above is a code reading. Its in-game check is in
`ULDuar_LOCAL_VALIDATION_CHECKLIST.md` §16 (executor) and §18 (carrier).
