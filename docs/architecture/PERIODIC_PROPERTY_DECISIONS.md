# Periodic property decisions

Decisions for the periodic properties, settled 2026-09-27 (§1, §2, §5). §3 and §4 remain designs.

## 1. Properties (decided 2026-09-27)

| Property | Decision | Runtime |
| --- | --- | --- |
| `Periodic.FinalTick` | one tick AT expiration only when no regular tick lands there (6 s / 1 s: nothing added; 6 s / 2.5 s: ticks at 2.5, 5.0 and 6.0). The same pool is redistributed over the final TickCount; natural expiry only (not dispel, death, manual removal, immunity purge, logout) | RUNTIME CODED. One formula (`PeriodicTickCount`, `HasFinalTick`, `AdvancePeriodic(…, finalTick)`) for executor and carrier. Carrier: `SyncCarrierAura` rounds MaxDuration up to whole intervals so the native tick cap allows the extra tick, and the carrier script moves the next tick to the remaining duration when it would land after expiration; any removal before expiry cancels it |
| `Periodic.ScalingPerStackPct` | `StackFactor = 1 + (Stacks − 1) × pct / 100`, default **100** (x2 = 2.0; 50%: x2 = 1.5; 150%: x2 = 2.5). Negative values clamp to 0; the factor is capped (`MaxPeriodicStackFactor`) and the per-stack amount to int32. Logical stacks stay independent of the native uint8 count | RUNTIME (executor ticks and carrier per-stack amount) |
| `Periodic.TickScalingPerStackPct` | **DEPRECATED / NO NEW USE.** Reconciliation found it was the property the runtime actually read, with exactly the ScalingPerStackPct formula; it never changed tick speed. Its name is now a deprecated alias of `Periodic.ScalingPerStackPct` (commands and presets keep working with a notice); the retired registry entry is not Lab-editable and has no consumer | - |
| Future `Periodic.TickRatePerStackPct` | "more stacks = faster ticks", if ever wanted, is a new, separately reviewed property; unrelated to haste Essences | not designed |
| `Periodic.SnapshotStats` | `true` is the only supported value; `false` is rejected by validation (`AbilityResolver`) | see §2 |

## 2. Snapshot policy (SnapshotStats = true)

| Part | When | Notes |
| --- | --- | --- |
| Caster spell power / AP, caster % done | snapshot at application/refresh | in the pool (carrier: pre-taken amount of the payload hit) |
| Crit chance | snapshot at application/refresh | carrier: `SetCritChance`, highest over the instance's schools |
| Haste on interval | snapshot at application/refresh | `Periodic.CanHaste` |
| Resolved Ulduar build | snapshot (immutable `ResolvedAbility`) | |
| Target taken modifiers, immunity, resistance, absorb | **dynamic per tick** (carrier) | executor fallback: taken modifiers snapshotted at hit (documented executor semantics) |

`SnapshotStats = false` is UNSUPPORTED and rejected. If a future Essence needs dynamic caster stats per tick,
design a granular `SnapshotPolicy` (per stat group) instead of hidden behavior.

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

## 5. Element -> SchoolMask migration (adopted 2026-09-27)

| Rule | Implementation |
| --- | --- |
| `Primary.SchoolMask` / `Effect.SchoolMask` are the future authorities | new registry properties (Identifier, 0..127) |
| `SchoolMask = 0` means native / original school | default |
| Unset mask + legacy `Element` → the Element's one-bit mask | `Engine::MigratedSchoolMask` (`Element` order = school bit order), `MigratedEffectSchoolMask` (`EffectElement::Native` = 0) |
| A legacy enum value is never read as a bitmask | tested (Frost = 4 → mask 16, never mask 4) |
| Combined conversions write the mask directly | resolved; no direct-hit school adapter yet (inspector: NOT EXECUTED line) |
| VariantHash includes the final mask | a non-zero mask is hashed; an unset mask is skipped so every existing variant keeps its hash |
| Inspector label | `Engine::SchoolMaskName`: "Frost", "Frost\|Fire" |
| Saved builds | unaffected (properties are not persisted; Lab layers hold enum ids in memory) |
| Client protocol v1 | unchanged (`Element` field); SchoolMask belongs to a future negotiated descriptor revision |
