# Periodic runtime (direct-to-periodic conversion)

Code:
- `src/engine/ExecutionModel.*` (`PlanConvertedPeriodic`, `PeriodicTickCount`, `AdvancePeriodic`,
  `RefreshTickAmount`)
- `src/engine/PeriodicCarrier.*` (carrier ids, school selection, backing decision, pool per backing, aura sync)
- `src/AbilityPeriodicExecutor.*` (instances, stacking, spread, executor ticks)
- `src/AbilityPeriodicCarrier.*` (`aura_ulduar_periodic_carrier`, native carrier adapter)
- `src/AbilitySpellScript.cpp` (split at hit)
- `src/engine/RuntimeMechanics.cpp` (stacking and spread)
- core: `TargetInfo::damageDoneBeforeTaken` (`Spell.h`, `Spell.cpp`, `SpellEffects.cpp`)

Tests: `UlduarPeriodicConversion.*` (`tests/AbilityRuntimeSemanticsTest.cpp`), `UlduarPeriodicCarrier.*`
(`tests/AbilityCarrierTest.cpp`).

Pending SQL: `ulduar_abilities_005_world_periodic_carriers.sql` (see [Application order](#sql-application-order)).

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

## Ownership

The **engine** (`AbilityPeriodicExecutor` + pure rules) owns:
- Conversion and ConversionEfficiency;
- the pool, the tick count and the hasted/clamped interval;
- stacking (`Periodic.StackBehavior`) and spread (`Periodic.Spread*`);
- echo composition;
- the immutable ability snapshot.

The **tick source** only executes ticks. Each instance has exactly one (`Engine::PeriodicBacking`):

| Backing | Who deals the ticks | When |
| --- | --- | --- |
| Carrier | a native `SPELL_AURA_PERIODIC_DAMAGE` carrier aura | default, whenever a carrier can hold the instance |
| Executor | the module's scheduled ticks (core spell damage path) | only for the reasons below |

`Engine::DecidePeriodicBacking` picks the executor only when:

| Reason | Why no carrier |
| --- | --- |
| `CARRIER_DISABLED` | `UlduarAbilities.Periodic.NativeCarrier = 0` |
| `MULTI_SCHOOL` | multi-school payload (e.g. Frostfire): a carrier has one school, and narrowing it would change resist/immunity |
| `CARRIER_NOT_LOADED` | carrier spell or script binding missing (pending SQL not applied), checked at startup per school |
| `INDEPENDENT_DURATION` | needs several concurrent instances; the core keeps one aura per caster + spell on a target |
| `NO_PRE_TAKEN_BASE` | the core did not record the pre-taken amount (payloads that are not `SPELL_EFFECT_SCHOOL_DAMAGE`, e.g. weapon damage) |
| `CARRIER_SLOT_TAKEN` | another ability of the same caster already holds that school's carrier on this target |

**No double damage.** An existing instance keeps its backing on refresh and stack.
- A carrier-backed instance schedules no executor tick, and `Tick()` refuses one
  (`Engine::ExecutorDealsTicks`).
- An executor-backed instance never creates an aura.
- If a carrier's script binding turns out to be missing at creation, the aura is removed before the executor
  takes the instance.

The executor path is the documented fallback above, gated per instance. It is not a second active damage
path.

## Native carrier (RUNTIME CODED / REQUIRES SQL / REQUIRES IN-GAME TEST)

### Carrier set

One generic carrier per school. There is no carrier per ability or variant. The IDs are reserved in the
canonical ledger (`docs/data/ulduar_id_allocations.json`, transaction `PC1-PERIODIC-CARRIER-RESERVATION-002`,
evidence `docs/audits/ULDuar_PC1_PERIODIC_CARRIER_EVIDENCE.json`).

| Spell | School | Row |
| --- | --- | --- |
| 141344 | Physical | pending SQL 005 (DmgClass melee, like Rend) |
| 141345 | Holy | pending SQL 005 |
| 141346 | Fire | pending SQL 005 |
| 141347 | Nature | pending SQL 005 |
| 141348 | Frost | pending SQL 005 |
| 141349 | Shadow | pending SQL 005 |
| 141350 | Arcane | pending SQL 005 |
| 141351..141357 | Physical..Arcane healing, in the same school order | reserved identity only (future `PeriodicHealingCarrier`) |

Each damage carrier row (`spell_dbc`, server-side) has:
- exactly one effect: `APPLY_AURA` / `SPELL_AURA_PERIODIC_DAMAGE` on the target;
- the carrier's school;
- `SpellFamilyName` 0 and no class mask, no dispel type, no mechanic, no other effect;
- a native school icon as a reference only (presentation belongs to the client patch).

`PeriodicCarrier::ValidateAtStartup` refuses a school whose row has any other shape or lacks the binding.

### Tick amount and interval

| Hook (`aura_ulduar_periodic_carrier`) | Sets |
| --- | --- |
| `DoEffectCalcAmount` | amount per stack. It runs after `AuraEffect::CalculateAmount`'s `SpellDamageBonusDone` step, so the engine amount **replaces** the native coefficient-scaled amount. The core then multiplies it by the stack count |
| `DoEffectCalcPeriodic` | the engine interval (hasted at application with `Periodic.CanHaste`, floored by `MinPeriodicTickInterval`, clamped to the duration). It runs before the core's periodic-haste step, which never applies to a carrier (no family, no `SPELL_ATTR5_SPELL_HASTE_AFFECTS_PERIODIC`) |
| `OnEffectPeriodic` | tells the executor a tick happened (spread). The native handler deals the damage |
| `AfterEffectRemove` | forgets the instance (expire, death, cleanse, cancel) |

The per-stack amount is `llround(TickAmount x stackFactor / stacks)` (`Engine::SyncCarrierAura`). Native aura
amounts are integers, so a tick can be off by at most `stacks` damage from the fractional engine value.

### Pre-taken pool (no double application)

A native tick applies `SpellDamageBonusTaken(DOT)` on every tick. So a carrier pool must start **before**
target taken modifiers.

- **Core field.** A new `TargetInfo::damageDoneBeforeTaken` records each target's `SCHOOL_DAMAGE` amount
  after `SpellDamageBonusDone` and before `SpellDamageBonusTaken`.
  - It gets the same caster-side AoE target cap and chain multiplier as the hit.
  - It does not get the target-side AoE damage reduction.
  - Before this change the core recorded such an amount only for heals (`damageBeforeTakenMods`).
- **Rescaling.** The spell script rescales it by whatever changed the hit between launch and `OnHit`, then by
  the same factor as the hit: `Primary.Scaling`, conditions, echo and secondary scaling.
- **Split.** `Engine::PlanPeriodicForBacking` splits the hit:
  - Immediate from the post-taken hit: the direct part keeps its own taken modifiers, once.
  - Carrier pool from the pre-taken amount × conversion × efficiency (once). The native tick applies the
    target's **current** taken modifiers.
  - Executor pool from the post-taken amount, as before; its ticks never apply taken modifiers.

Each of these is applied exactly once:
- caster done bonuses: at launch;
- `Primary.Scaling`, echo, secondary: at hit;
- Conversion and ConversionEfficiency: at plan;
- target taken modifiers: per tick (carrier) or at hit (executor).

See [the audit](PERIODIC_DAMAGE_PIPELINE_AUDIT.md) §5.

### Crit

`Periodic.CanCrit` on: `AuraEffect::SetCritChance` receives the payload spell's crit chance (the caster's
talents and gear for that spell, the target's crit-taken modifiers), snapshotted at application and refresh
like a native DoT. Off: 0. The native tick rolls it and applies the native periodic crit bonus.

### Stack and duration synchronization

One carrier aura per caster + target + ability instance (the core's aura key is spell + caster).
`Engine::SyncCarrierAura` turns the engine `PeriodicInstance` into:

| Aura field | Value |
| --- | --- |
| MaxDuration, Duration | `RemainingMs` |
| Stack count | `Stacks` (shown natively) |
| Amplitude | the interval, clamped to the remaining time |
| Amount per stack | as above |

The native tick cap is `MaxDuration / Amplitude`, counted since the last (re)application.
- **Fresh application:** `CalculatePeriodic(create)`. The first tick comes one interval later; exactly
  `floor(Remaining / Interval)` ticks.
- **Refresh / stack / AddDuration:** `Sync`. Its `CalculatePeriodic` (not create) restarts the tick count but
  keeps the running tick phase, like a native DoT refresh. Any phase still gives exactly
  `floor(Remaining / Interval)` ticks. The executor reads the aura's remaining duration before
  `ApplyPeriodic`, so pandemic carry-over and AddDuration use the live value.
- **InitialTick:** one extra native `PeriodicTick` 1 ms after the hit (the application tick counts toward
  `TickCount`).

**IndependentDuration** needs several concurrent instances of one ability on one target. The core cannot hold
two auras of the same spell from the same caster. Those instances stay executor-backed: no visible aura,
executor mitigation.

### Spread

A carrier tick first reports to the executor, which applies `Periodic.Spread*` (chance, cooldown, radius,
quantity).
- The spread copy keeps the source's tick amount (efficiency never reapplied), `SpreadStackCount`,
  `SpreadDurationRule` (KeepRemaining uses the aura's live remaining time) and caster ownership.
- It keeps the source's backing (`Engine::SpreadBacking`). A carrier source spreads only to targets whose
  carrier slot is free: a pre-taken amount must land on a carrier again, so the target's own taken modifiers
  apply exactly once. Other targets are skipped.
- An executor source stays executor-backed.

### Native semantics gained

A carrier tick is `AuraEffect::HandlePeriodicDamageAurasTick`, so it gets:
- per-tick immunity;
- `SpellDamageBonusTaken(DOT)` per tick (dynamic taken modifiers);
- armor for the physical carrier;
- crit;
- spell resilience;
- `CalcAbsorbResist(DOT)`;
- the periodic combat log (`SendPeriodicAuraLog`);
- periodic procs: `PROC_FLAG_DONE_PERIODIC` / `PROC_FLAG_TAKEN_PERIODIC`, via `ProcSkillsAndAuras`.

It gets **no block** and **no pushback** (damage type `DOT`).

### Periodic proc semantics

Carrier ticks raise the native periodic proc flags. The module calls no proc hook itself, so procs are never
duplicated.
- The carrier has no class family, so class talents filtered by `SpellFamilyFlags` (e.g. "your Corruption
  ticks…") do not treat it as their spell. A converted Frostbolt is not a Corruption.
- Generic periodic procs (trinkets, "periodic damage" effects, school-filtered procs) do trigger.
- Executor-backed instances still raise no procs (unchanged).

### Echo + periodic

There is no echo-specific rule. An echo with `Echo.CanEchoPeriodic` applies its own (echo-scaled) pool to the
same instance, governed only by `Periodic.StackBehavior`:
- RefreshDuration: the echo's tick amount replaces the running one;
- ReplaceWeaker: the stronger instance is kept;
- AddStackAndRefresh: adds a stack.

`Echo.CanEchoPeriodic` stays off by default. A production Essence that enables it should also select a
compatible stacking policy (typically AddStackAndRefresh or ReplaceWeaker) for its design. The Developer Lab
may create intentionally bad combinations.

### Healing periodic (design only)

Healing conversion stays **RESOLVED ONLY**. The carrier abstraction is kind-aware
(`Engine::CarrierKind::PeriodicHealing`, reserved IDs 141351..141357). A future healing carrier reuses:
- the ownership, timing, stacking, sync and presentation infrastructure;
- a `SPELL_AURA_PERIODIC_HEAL` row;
- a pre-taken heal base (the core already records `damageBeforeTakenMods` for heals).

No healing carrier row is authored.

### Client presentation boundary

- Nothing server-side renames or re-icons an aura. A stock client may show a generic or technical carrier,
  or nothing: the carrier is a server-only `spell_dbc` row the stock client does not know. The effect of an
  unknown spell id in `SMSG_AURA_UPDATE` / `SMSG_PERIODICAURALOG` on a stock client REQUIRES IN-GAME TEST.
- Dynamic icon/name per ability is **CLIENT PATCH REQUIRED** (`ulduar-client-patch`).
- Metadata the patch will need, exposed later through an isolated channel that does not touch periodic
  gameplay:
  - AbilityId;
  - BaseSpellId (the payload rank);
  - VariantHash (resolved build);
  - carrier identity (carrier spell, caster GUID, target GUID, generation);
  - Element.
- The server runtime does not wait for the patch.

## SQL application order

Nothing is applied by this repository's tooling. Apply manually, in this order:

1. `mod-ulduar-abilities/data/sql/db-world/ulduar_abilities_001_world.sql` (clears and rebinds Frostbolt);
2. `data/sql/updates/pending_db_world/ulduar_abilities_003_world_starters.sql`;
3. `data/sql/updates/pending_db_world/ulduar_abilities_005_world_periodic_carriers.sql` (carrier rows +
   `aura_ulduar_periodic_carrier` bindings);
4. `data/sql/updates/pending_db_world/ulduar_abilities_006_world_blizzard.sql` (Blizzard bindings,
   [CHANNEL_RUNTIME.md](CHANNEL_RUNTIME.md)).

The characters migrations (`001`, `002`, `004`) are independent. Without 005, every school logs
`Periodic carrier … is not loaded` and converted periodics run on the executor.

## Known limits

| Item | State |
| --- | --- |
| Native carrier ticks | RUNTIME CODED / REQUIRES SQL / REQUIRES IN-GAME TEST |
| Visible debuff, stacks, duration on the target | server sends them natively; a stock client does not know the carrier spell; dynamic icon/name: CLIENT PATCH REQUIRED |
| Executor-backed instances (reasons above) | RUNTIME; executor semantics (snapshotted taken mods, block, pushback, no procs) as in the [audit](PERIODIC_DAMAGE_PIPELINE_AUDIT.md) §4 |
| IndependentDuration | executor-backed (one aura per caster + spell) |
| Two abilities of one caster with the same school on one target | the second is executor-backed (`CARRIER_SLOT_TAKEN`); more carrier slots would need more ledger IDs |
| Healing conversion (HoT) | RESOLVED ONLY (carrier IDs reserved) |
| Retiming native periodic auras (Corruption duration/rate) | RESOLVED ONLY |
| `Periodic.FinalTick`, `Periodic.ScalingPerStackPct`, `Periodic.SnapshotStats` | RESOLVED ONLY |
