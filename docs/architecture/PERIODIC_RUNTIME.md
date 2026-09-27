# Periodic runtime (direct-to-periodic conversion)

> **Scope (2026-09-27, generic pool).** This document describes the current implementation: a **generic
> carrier pool** (Spell 310272..312319, RESERVED in the ledger, pending SQL 007), a per-aura school mask
> set by the core override, separate Root/Echo lineages and carrier-backed IndependentDuration. The seven
> per-school carriers 141344..141357 are **HISTORICAL / SUPERSEDED** (RETIRED_TOMBSTONE in the ledger; SQL 005
> superseded). Target-architecture items not yet implemented are tracked in
> [PERIODIC_TARGET_ARCHITECTURE.md](PERIODIC_TARGET_ARCHITECTURE.md) §10.

Code:
- `src/engine/ExecutionModel.*` (`PlanConvertedPeriodic`, `PeriodicTickCount`, `AdvancePeriodic`,
  `RefreshTickAmount`)
- `src/engine/PeriodicCarrier.*` (pool range, school validation, backing decision, pool per backing, aura sync)
- `src/engine/PeriodicIdentity.*` (`PeriodicInstanceKey`, `CarrierPool` allocator, aura-slot capacity)
- `src/engine/AuraGrouping.*` (presentation groups and dispel planning; engine model, not wired to native dispel)
- `src/AbilityPeriodicExecutor.*` (instances, stacking, spread, executor ticks)
- `src/AbilityPeriodicCarrier.*` (`aura_ulduar_periodic_carrier`, native carrier adapter)
- `src/AbilitySpellScript.cpp` (split at hit)
- `src/engine/RuntimeMechanics.cpp` (stacking and spread)
- core: `TargetInfo::damageDoneBeforeTaken` (`Spell.h`, `Spell.cpp`, `SpellEffects.cpp`)
- core: `Aura::SetSchoolMaskOverride` / `GetEffectiveSchoolMask` ([PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md))

Tests: `UlduarPeriodicConversion.*` (`tests/AbilityRuntimeSemanticsTest.cpp`), `UlduarPeriodicCarrier.*`
(`tests/AbilityCarrierTest.cpp`), `UlduarPeriodicIdentity.*`, `UlduarCarrierPool.*`, `UlduarAuraGroups.*`,
`UlduarDispel.*` (`tests/AbilityPeriodicTargetTest.cpp`).

Pending SQL: `ulduar_abilities_007_world_generic_periodic_carriers.sql` (see [Application order](#sql-application-order)).

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
| `CARRIER_NOT_LOADED` | a pool row or its script binding is missing (pending SQL 007 not applied); checked at startup for all 2048 rows |
| `INVALID_SCHOOL` | empty or out-of-range school mask |
| `NO_PRE_TAKEN_BASE` | the core did not record the pre-taken amount (payloads that are not `SPELL_EFFECT_SCHOOL_DAMAGE`, e.g. weapon damage) |
| `AURA_SLOTS_FULL` | the target has no free visible aura slot (`MAX_AURAS` = 255, unchanged) |
| `POOL_EXHAUSTED` | all 2048 carriers of this (target, caster) scope are in use |

Removed reasons: `MULTI_SCHOOL` (a carrier now takes the instance's full mask), `INDEPENDENT_DURATION` (each
independent application gets its own carrier) and `CARRIER_SLOT_TAKEN` (the pool gives each instance its own
carrier).

**No double damage.** An existing instance keeps its backing on refresh and stack.
- A carrier-backed instance schedules no executor tick, and `Tick()` refuses one
  (`Engine::ExecutorDealsTicks`).
- An executor-backed instance never creates an aura.
- If a carrier's script binding turns out to be missing at creation, the aura is removed before the executor
  takes the instance.

The executor path is the documented fallback above, gated per instance. It is not a second active damage
path.

## Native carrier (RUNTIME CODED / REQUIRES SQL / REQUIRES IN-GAME TEST)

### Carrier pool

- **IDs.** Spell 310272..312319 (2048). **RESERVED** by ledger revision `PC2-GENERIC-PERIODIC-CARRIER-POOL-004`
  (`docs/audits/ULDuar_PC2_GENERIC_CARRIER_POOL_PROPOSAL.json`, evidence
  `ULDuar_PC2_GENERIC_CARRIER_POOL_EVIDENCE.json`), reservation date 2026-09-27. Not INTRODUCED until a release ships
  the rows.
- **No meaning in an ID.** Every row is identical: one `APPLY_AURA` / `SPELL_AURA_PERIODIC_DAMAGE` effect on
  the target, SchoolMask 127, DmgClass magic, `SpellFamilyName` 0, no class mask, no dispel type, no mechanic,
  no other effect, a native icon reference. An ID encodes no school, element, ability, variant, echo
  generation, icon or name.
- **Instance school.** `PeriodicCarrier::Start` sets `Aura::SetSchoolMaskOverride(instance school)` before the
  first amount calculation. A combined-school instance (e.g. Frostfire) keeps its full multi-bit mask; it is one
  event, never split. Stock multi-school semantics apply ([PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md)).
  A target immune to the full mask gets no periodic part, like a native DoT; the carrier ID is released and
  the hit keeps its immediate part (no executor fallback).
- **Allocation** (`Engine::CarrierPool`, per (target, caster) scope):
  - the lowest free ID of that scope; the same ID is reused across targets and across casters, since the
    core's aura key is spell + caster on one target;
  - an ID whose native aura still exists (orphan after a lost instance) is marked held and skipped; an active
    carrier is never stolen;
  - released when the aura ends (expire, dispel, death, cancel, target destruction, caster logout: the core
    removes the aura, `AfterEffectRemove` → `OnCarrierRemoved`);
  - exhaustion or a full aura bar falls back to the executor, counted in diagnostics.
- **Diagnostics.** `AbilityPeriodicExecutor::GetDiagnostics()`: carriers in use, peak, pool-exhausted count,
  aura-slots-full count, executor and carrier instances.
- **Startup validation.** `PeriodicCarrier::ValidateAtStartup` requires all 2048 rows with the generic shape and
  the binding; otherwise the pool is not used at all (`CARRIER_NOT_LOADED`).
- **ExtendedAuraSlots** (more than 255 visible auras) is documentation only: it needs a wire and client change
  and is not implemented. `MAX_AURAS` is unchanged.

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

One carrier aura per periodic instance; each instance holds its own pool ID (the core's aura key is spell + caster).
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

**IndependentDuration** gets one carrier per application (`PeriodicInstanceKey::ApplicationId`), so several
concurrent instances of one ability on one target are native auras with independent durations. Other stack
behaviors share one instance per lineage.

### Spread

A carrier tick first reports to the executor, which applies `Periodic.Spread*` (chance, cooldown, radius,
quantity).
- The spread copy keeps the source's tick amount (efficiency never reapplied), `SpreadStackCount`,
  `SpreadDurationRule` (KeepRemaining uses the aura's live remaining time) and caster ownership.
- It keeps the source's lineage, school and backing (`Engine::SpreadBacking`). A carrier source spreads only
  to targets where a pool carrier and an aura slot are available: a pre-taken amount must land on a carrier
  again, so the target's own taken modifiers apply exactly once. Other targets are skipped.
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

Root and Echo are **separate instances** (`PeriodicLineage`, `EchoGeneration` in the key). An echo never
refreshes, replaces or stacks onto the Root instance.
- An echo with `Echo.CanEchoPeriodic` applies its own (echo-scaled) pool to its own lineage instance (echo
  generation ≥ 1), with its own carrier.
- `Periodic.StackBehavior` applies **within one lineage** (a second echo of the same generation refreshes,
  replaces the weaker or stacks on that echo instance).
- Without `Echo.CanEchoPeriodic` an echo keeps only its immediate part; no carrier is allocated.

`Echo.CanEchoPeriodic` stays off by default. Root and echo instances of one ability share a presentation
group ([PERIODIC_TARGET_ARCHITECTURE.md](PERIODIC_TARGET_ARCHITECTURE.md) §6), which is an engine model; a
stock client shows each carrier aura separately.

### Healing periodic (design only)

Healing conversion stays **RESOLVED ONLY**. A future `PeriodicHealingCarrier` family is a **separate** pool
(its own proposed range and `SPELL_AURA_PERIODIC_HEAL` rows); it is not the damage pool and does not reuse
141351..141357 (tombstoned). It reuses the allocator, identity, sync and presentation infrastructure and the
core's pre-taken heal base (`damageBeforeTakenMods`). No range is proposed and no row is authored.

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
  - carrier identity (carrier spell, caster GUID, target GUID, lineage, echo generation, application);
  - effective school mask (the carrier spell's 127 is not the instance school);
  - Element.
- The server runtime does not wait for the patch.

## SQL application order

Nothing is applied by this repository's tooling. Apply manually, in this order:

1. `mod-ulduar-abilities/data/sql/db-world/ulduar_abilities_001_world.sql` (clears and rebinds Frostbolt);
2. `data/sql/updates/pending_db_world/ulduar_abilities_003_world_starters.sql`;
3. `data/sql/updates/pending_db_world/ulduar_abilities_007_world_generic_periodic_carriers.sql` (pool rows +
   `aura_ulduar_periodic_carrier` bindings; removes 005's rows);
4. `data/sql/updates/pending_db_world/ulduar_abilities_006_world_blizzard.sql` (Blizzard bindings,
   [CHANNEL_RUNTIME.md](CHANNEL_RUNTIME.md));
5. `data/sql/updates/pending_db_world/ulduar_abilities_008_world_mind_flay.sql` (Mind Flay bindings).

**Do not apply** `ulduar_abilities_005_world_periodic_carriers.sql` (SUPERSEDED). 006 and 008 do not depend on
007, so an auto-updater's alphabetical order (…005, 006, 007, 008) is also safe: 007 deletes 005's rows. The
characters migrations (`001`, `002`, `004`) are independent. Without 007 the startup log reports the pool as
not loaded and converted periodics run on the executor.

## Known limits

| Item | State |
| --- | --- |
| Native carrier ticks (generic pool, per-instance school) | RUNTIME CODED / REQUIRES SQL 007 / REQUIRES LOCAL BUILD / REQUIRES IN-GAME TEST |
| Pool IDs 310272..312319 | RESERVED (ledger `PC2-GENERIC-PERIODIC-CARRIER-POOL-004`); not INTRODUCED |
| Visible debuff, stacks, duration on the target | server sends them natively; a stock client does not know the carrier spell; dynamic icon/name: CLIENT PATCH REQUIRED |
| Executor-backed instances (reasons above) | RUNTIME; executor semantics (snapshotted taken mods, block, pushback, no procs) as in the [audit](PERIODIC_DAMAGE_PIPELINE_AUDIT.md) §4 |
| Multi-school crit chance / done-taken stacking | stock AzerothCore semantics; Ulduar policy is an open decision ([PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md)) |
| Presentation groups, dispel strengths / priority | ENGINE MODEL + TESTS; native dispel still picks one aura at random ([DISPEL_PRIORITY_AUDIT.md](DISPEL_PRIORITY_AUDIT.md)) |
| Healing conversion (HoT) | RESOLVED ONLY (separate future family) |
| Retiming native periodic auras (Corruption duration/rate) | RESOLVED ONLY ([PERIODIC_PROPERTY_DECISIONS.md](PERIODIC_PROPERTY_DECISIONS.md)) |
| `Periodic.FinalTick`, `Periodic.ScalingPerStackPct`, `Periodic.TickScalingPerStackPct`, `Periodic.SnapshotStats` | RESOLVED ONLY; decisions in [PERIODIC_PROPERTY_DECISIONS.md](PERIODIC_PROPERTY_DECISIONS.md) |
