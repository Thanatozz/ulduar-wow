# Echo runtime

Code:
- `src/AbilityEchoScheduler.cpp`
- `src/AbilitySpellScript.cpp`
- `src/AbilityPropagationResolver.cpp`
- `src/SecondarySpellExecutor.cpp`
- `src/AbilityTargetResolver.cpp`
- `src/engine/RuntimeMechanics.cpp` (`PlanEchoes`)
- `src/engine/ExecutionModel.*` (`HitOutputScale`, `IsExecutionRoot`, `SchedulesEchoes`)

Tests: `UlduarEchoComposition.*`, `UlduarEngineEcho.*`.

## What an echo is

An echo **replays the complete configured ability payload** from the same immutable cast snapshot. It is a
triggered execution of the same ranked spell (`TRIGGERED_FULL_MASK`), not a player cast. It never charges:
- resource cost;
- GCD;
- cooldown;
- cast time;
- reagents or ammunition (`SetTriggeredIgnoreAmmo`).

Each echo is its **own execution**: a new `AbilityPayloadEvent` with its own visited and propagation history,
the same target (`Echo.TargetRule` SameTarget), and the echo scaling of its generation. At impact it runs the
components again from its own root:
- Split starts at launch; Shatter, Nova and Chain start at impact;
- periodic conversion;
- the native payload aura;
- (future) eligible effects.

Composition per hit (`HitOutputScale`), applied to each fresh native calculation already scaled by
`Primary.Scaling`:

```
echo execution -> x Echo.Scaling (of that generation)
secondary hit  -> x secondary scaling (Projectile.Scaling or Area.Scaling)
```

**Example:** Frostbolt 1000, Split 3, secondary 60%, echo 60%.

| Execution | Hits |
| --- | --- |
| Original | primary 1000, split A/B/C 600 |
| Echo | primary 600, echo split A/B/C 360 (= 1000 x 0.6 x 0.6) |

The echo re-evaluates the component graph from its own root; it never copies an already-scaled secondary hit.
With periodic conversion 30% / 200%, the echo root 600 becomes 420 immediate and a 360 pool, but only when
`Echo.CanEchoPeriodic` is set (see [PERIODIC_RUNTIME.md](PERIODIC_RUNTIME.md)).

## Recursion and MultiEcho

- **Execution roots.** `IsExecutionRoot`: the player's cast and each echo's own hit start propagation.
  There is no "terminal echo" rule: an older rule where echo impacts returned before propagation and only
  the root shattered is obsolete.
- **No recursion.** Only the player's own cast schedules echoes (`SchedulesEchoes`), so echo hits never plan
  echoes.
  `Echo.CanEchoTriggerEcho` defaults to false and is not executed.
- **MultiEcho.** It means several echo executions planned once, from the original event: Original, Echo 1,
  Echo 2, Echo 3 (`PlanEchoes`, bounded by `MaxEchoCount` / `MaxEchoChainDepth` and the absolute limits).
- **Channels.** For Arcane Missiles each missile is a payload event, so each missile may echo. An echo replays
  that missile payload, not the channel.
- **Area pulses.** A Blizzard pulse targets an area, so it has no single execution root
  (`Engine::PayloadHitIsExecutionRoot`): it never schedules an echo.

## Echo periodics

- **Current (RUNTIME CODED, 2026-09-27):** Root and each Echo generation are separate periodic instances
  (`PeriodicInstanceKey` lineage + echo generation), each with its own pool carrier, amount, duration, stacks,
  refresh and procs, so an echo never refreshes, replaces or weakens the Root. `Periodic.StackBehavior`
  applies within one lineage ([PERIODIC_TARGET_ARCHITECTURE.md](PERIODIC_TARGET_ARCHITECTURE.md) §6).
- **Native payload auras (fixed 2026-09-27):** an echo copy never touches a native aura the caster already
  has on the target (`Spell::SetTriggeredKeepExistingAuras`). Before the fix an echo of a payload with a
  native periodic aura removed the Root's DoT (via `PreventHitAura`, CanEchoPeriodic off) or replaced it
  (CanEchoPeriodic on). Native payload auras stay one per caster and target; only converted periodics have
  an Echo instance of their own ([PERIODIC_RUNTIME.md](PERIODIC_RUNTIME.md), "Native payload auras").
- **Snapshot:** a delayed echo uses the original cast's immutable snapshot (`AbilityPayloadEvent::Cast`), even
  if the Root was recast or the build changed before the echo fires; its own key never matches the recast
  Root.
- **HISTORICAL / SUPERSEDED:** "an echo applies its pool to the Root instance". A test or checklist step that
  expects an echo to overwrite or stack onto the Root is stale.

## Safety

- **No stale pointers.** Events hold GUIDs and the shared immutable snapshot only. Targets are re-resolved and
  revalidated when an echo fires: alive, same map/phase, legal, within the spell range + 5, LOS.
- **Secondaries.** The echo's secondaries use the normal propagation validators, and Shatter/Chain use proxies.
- **Launch source.** An echo launched from the caster uses the native SPELL_GO (no visual-only packet naming
  the local player; that crashed the client).
- **Procs.** With `Echo.CanProc` off, echo executions carry `TRIGGERED_DISALLOW_PROC_EVENTS`.
- **Crit.** With `Echo.CanCrit` off, crits are removed from every hit of the lineage.

## Status

LOCAL BUILD PASS and IN-GAME tested by the maintainer (2026-09-27): echoes fire and replay the payload.
IN-GAME FAIL: Root/Echo periodic isolation (Root DoT removed or replaced by an echo) — FIXED IN SOURCE,
IN-GAME RETEST PENDING (checklist stage "Periodic isolation regression").
