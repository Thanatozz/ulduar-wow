# Multi-school damage policy (Ulduar)

Date: 2026-09-27. Engine model: `src/engine/MultiSchool.*` (mod-ulduar-abilities), tests
`UlduarMultiSchool.*` (`tests/AbilityPeriodicPolicyTest.cpp`).

## 1. Event model

A combined-school event (e.g. `1000 Frost|Fire`) is ONE event:
- one amount, one crit roll, one mitigation step, one periodic pool;
- one multi-bit `SpellSchoolMask` (the combat log keeps the full mask);
- never split into shares (`600 Frost + 400 Fire` is wrong).

## 2. Rules

| Aspect | Ulduar policy | Stock AzerothCore | Where implemented |
| --- | --- | --- | --- |
| Immunity | immune only when **every** school of the event is blocked | same (`IsImmunedToDamage` needs all bits) | NATIVE OK |
| Resistance | most favorable school for the attack: **lowest** applicable resistance | same (`CalcAbsorbResist` uses the lowest) | NATIVE OK |
| Crit chance | **highest** applicable chance among the schools | first school of the mask (`GetFirstSchoolInMask`) | module: `CarrierCritChance` (max over school bits) |
| School % damage done | the single **best** school-specific modifier, once (Fire +10% & Frost +10% → +10%; Fire +20% & Frost +8% → +20%) | product of every overlapping aura | engine model; runtime: see §4 |
| School flat damage done | the single best school-specific contribution, once | sum of every overlapping aura | engine model; runtime: see §4 |
| School % damage taken | the single most favorable result for the attack (the highest multiplier), once | product of every overlapping aura | core: `HandlePeriodicDamageAurasTick` (override instances) |
| General modifiers (not school-specific) | apply normally, once | same | NATIVE OK |
| Absorbs | school-mask overlap | same | NATIVE OK |
| Procs | school-mask overlap unless a proc says otherwise | same | NATIVE OK |
| Combat log | full combined mask | same | NATIVE OK (effective mask) |

"Most favorable" is always from the attack's point of view, consistent with resistance: the event uses its
best school once.

## 3. Interaction order

```
amount = (base + bestSchoolFlatDone) x generalDone x bestSchoolDone      (done side, at hit)
amount = amount x generalTaken x bestSchoolTaken (+ flat taken of that school)   (taken side, per tick)
armor (only if Physical is in the mask) -> crit (highest chance, one roll) -> AoE reduction
-> absorb / resist (lowest resistance) -> resilience -> damage
```

## 4. Runtime scope

- The policy applies only to aura instances with a **school override** (the generic carriers). Native spells
  with a multi-school `SpellInfo` (e.g. native Frostfire Bolt) keep stock AzerothCore behavior: changing them
  would rebalance native classes.
- **Taken side (implemented):** `AuraEffect::HandlePeriodicDamageAurasTick` computes `SpellDamageBonusTaken`
  once per school bit and keeps the best result when the override mask has more than one bit. General taken
  modifiers apply in every candidate alike; `SpellDamageBonusTaken` has no side effects (audited).
- **Crit chance (implemented):** the carrier's snapshotted chance is the max over the instance's schools.
- **Done side (model only):** carrier pools start from the payload hit's pre-taken amount, which the native
  hit computed for its own school. Combined-school conversions of direct hits do not exist yet
  (`Primary.SchoolMask` is resolved-only), so no multi-school done bonus is computed at runtime. When a
  combined conversion ships, its done bonus must use `MultiSchoolBest` (per-school done multiplier and flat
  bonus), not the stock product.
- REQUIRES LOCAL BUILD / REQUIRES IN-GAME TEST for the implemented parts.
