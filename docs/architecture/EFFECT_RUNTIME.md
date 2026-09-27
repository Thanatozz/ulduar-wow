# Effect runtime

Code (mod-ulduar-abilities):
- `src/engine/EffectRuntime.*` — classification, planning, refresh rules, carrier amounts (pure);
- `src/AbilityEffectExecutor.*` — instances, carrier pools, `aura_ulduar_effect_carrier`, diagnostics;
- hooks: `AbilitySpellScript` (payload hits), `AbilityPeriodicExecutor` (converted periodic ticks),
  `aura_ulduar_ability_runtime::OnLeechTick` (Drain Life ticks).

Tests: `UlduarEffectRuntime.*` (`tests/AbilityEffectRuntimeTest.cpp`).

**State: HELD.** SYNTAX CHECKED + PURE TESTS; disabled by `UlduarAbilities.PostJ0Runtime = 0` until checklist
Stage J0 passes; carrier range PROPOSED only (`PC3-GENERIC-EFFECT-CARRIER-POOL-005`, not appended; SQL 009 DO
NOT APPLY). NOT TESTED in game.

## 1. Activation

`Effect.ActivationMask` is the only authority (`Engine::PlanEffectApplication` → `EffectActivates`). A hit
carries `HitRole` (Primary, Secondary, Periodic, Proc) and `FromEcho`; an effect activates when its role bit is
set and, for echo executions, the Echo bit too. The Echo bit alone activates nothing. A refused effect never
touches the hit: damage and healing are applied before and independently of effect activation.

| Hit | Role | Source |
| --- | --- | --- |
| payload hit at depth 0 | Primary | spell script `OnHit` |
| propagation copy (Split, Chain, Nova, Shatter) | Secondary | spell script `OnHit` |
| converted periodic tick (carrier or executor) | Periodic | `AbilityPeriodicExecutor` |
| Drain Life leech tick | Periodic | `aura_ulduar_ability_runtime` |
| trigger-bus activation | Proc | not wired (see [TRIGGER_BUS.md](TRIGGER_BUS.md)) |

## 2. Instance identity

An effect instance is keyed by `PeriodicInstanceKey` fields: caster GUID, target GUID, AbilityId, **EffectKey**,
lineage (Root/Echo), EchoGeneration, ApplicationId. It lives in its own `PeriodicRegistry` (key ↔ generation ↔
(target, caster, carrier)), separate from the periodic registry. Never keyed by AbilityId, SpellId or
presentation group alone.

Consequences:
- Primary, Secondary, Periodic and Proc activations of one effect in one lineage refresh **one** instance;
- Root and each Echo generation are separate instances with separate carriers;
- two casters, two abilities, or two effect keys never share an instance.

## 3. Families (first subset)

| Family | Shape (Debuff) | Native aura | Row | Notes |
| --- | --- | --- | --- | --- |
| Chill (Snare) | `Effect.Stat` = MovementSpeedPct (1), `ValueKind` Percent, `Value` < 0 | `SPELL_AURA_MOD_DECREASE_SPEED`, EffectMechanic snare | School 127 + per-aura school override | magnitude per stack; total clamped to -100%; the core applies only the strongest snare on a unit (native rule) |
| Freeze | `Effect.Control` = Root, `Effect.Element` = Frost | `SPELL_AURA_MOD_ROOT`, EffectMechanic root | SchoolMask Frost (16) | `SpellInfo::LoadAuraState` derives `AURA_STATE_FROZEN` from frost + MOD_ROOT; no damage break (`AuraInterruptFlags` 0) |

Chill never implies Freeze. Any other Buff/Debuff shape is `NO_CARRIER_FAMILY`: counted and reported by the
inspector, never faked with another aura.

Per instance: magnitude, duration, stacks, DispelType (`Aura::SetDispelTypeOverride`, core numbering, Enrage = 9),
school (Chill only). Removal: `aura_ulduar_effect_carrier::AfterRemove` → `OnCarrierRemoved(caster, target,
carrier, generation)` removes exactly the owner of that carrier with that generation (expire, dispel, death,
immunity, manual removal); logout forgets the caster's instances.

## 4. Stacking

Current engine contract (`Engine::ApplyEffect`, `Effect.RefreshBehavior`):

| RefreshBehavior | Existing instance |
| --- | --- |
| Refresh | duration reset, magnitude replaced, +stacks up to MaxStacks |
| Extend | duration added |
| Ignore | unchanged |
| Replace | fresh instance values |

Gap versus the requested generic contract (RefreshDuration, ReplaceWeaker, AddStackAndRefresh,
IndependentDuration): "Refresh" currently merges RefreshDuration and AddStackAndRefresh (stacks grow only when
MaxStacks > 1), and **ReplaceWeaker** and **IndependentDuration** do not exist for effects. Design for the next
step (not implemented, gate):

| Mode | Rule | Key |
| --- | --- | --- |
| RefreshDuration | duration reset, magnitude replaced, stacks unchanged | ApplicationId 0 |
| AddStackAndRefresh | +1 stack up to MaxStacks, duration reset | ApplicationId 0 |
| ReplaceWeaker | replace only when the new magnitude is at least as strong (for snares: more negative); otherwise unchanged | ApplicationId 0 |
| IndependentDuration | a new instance per application | fresh ApplicationId |

Each mode applies **within one lineage**; lineages never merge (same rule as periodics). This is a separate
`Effect.StackBehavior` rather than a reuse of `Periodic.StackBehavior`, because snare strength compares
magnitudes, not tick amounts.

## 5. Carrier family audit (before any further allocation)

A native aura's `AuraType` and `MiscValue` come from the static `SpellInfo` row and cannot be changed per aura;
amount, duration, stacks, school and dispel type can. So one family is needed per distinct
(AuraType, MiscValue, positivity) that the effect runtime must represent:

- Snare: `MOD_DECREASE_SPEED` (misc 0), negative → 1 family (proposed);
- Root/Freeze: `MOD_ROOT`, frost school required for the frozen state → 1 family (proposed);
- a generic non-frost Root would need a second root family (not proposed: no consumer yet);
- stat buffs/debuffs: `MOD_STAT` (misc = stat index), `MOD_DAMAGE_PERCENT_DONE` (misc = school mask),
  `MOD_RESISTANCE`, haste, crit… each a separate family and positive/negative variants. **None proposed** until an
  ability needs them; the list above is the audit input for that decision.

## 6. Diagnostics

`UlduarAbilities.Debug = 1` → `[UlduarEffect]` lines: `EFFECT_CREATE`, `EFFECT_REFRESH`, `EFFECT_EXPIRE`,
`EFFECT_DISPEL`, `EFFECT_REMOVE reason=…`, `EFFECT_INVARIANT reason=…`, plus `SKIP reason=…` for planned but
not applied effects. Fields: ability, caster, target, effect key, lineage, echo generation, ApplicationId,
generation, family, carrier, stacks, remaining ms, amount per stack, remove mode. `.ua lab effects`: family load
state, counters, ownership consistency.

## 7. Required regression tests (next step)

Present: `ChillIsSnareAndNeverFreeze`, `FreezeNeedsRootAndFrost`, `ActivationMaskIsTheOnlyAuthority`,
`UnsupportedShapesAreReportedNotFaked`, `RefreshBehaviors`, `SnareTotalNeverExceedsHundredPercent`,
`CoreDispelTypeNumbering`, `CarrierRangesAreDisjointFromPeriodicPools`, `RootAndEchoEffectInstancesAreIsolated`,
`RolesOfOneLineageShareTheInstance`.

To add with the stacking contract and generic Buff: BuffPrimaryApplies, DebuffPrimaryApplies,
EffectActivationRejectDoesNotRejectDamage, SecondaryEffectAppliesWhenEnabled, EffectExpirationRemovesExactOwner,
WeakDispelRemovesCorrectEffectMember, DifferentCastersNeverCrossRemove, IndependentDurationCreatesIndependentEffect,
ReplaceWeakerDoesNotCrossLineages.
