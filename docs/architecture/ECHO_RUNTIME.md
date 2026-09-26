# Echo runtime

Code:
- `src/AbilityEchoScheduler.cpp`
- `src/AbilitySpellScript.cpp`
- `src/AbilityPropagationResolver.cpp`
- `src/SecondarySpellExecutor.cpp`
- `src/AbilityTargetResolver.cpp`
- `src/engine/RuntimeMechanics.cpp` (`PlanEchoes`)
- `src/engine/ExecutionModel.cpp` (`HitOutputScale`)

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

- **No recursion.** Only the player's own cast (`IsRootCast`) schedules echoes, so echo hits never plan echoes.
  `Echo.CanEchoTriggerEcho` defaults to false and is not executed.
- **MultiEcho.** It means several echo executions planned once, from the original event: Original, Echo 1,
  Echo 2, Echo 3 (`PlanEchoes`, bounded by `MaxEchoCount` / `MaxEchoChainDepth` and the absolute limits).
- **Channels.** For Arcane Missiles each missile is a payload event, so each missile may echo. An echo replays
  that missile payload, not the channel.

## Safety

- **No stale pointers.** Events hold GUIDs and the shared immutable snapshot only. Targets are re-resolved and
  revalidated when an echo fires: alive, same map/phase, legal, within the spell range + 5, LOS.
- **Secondaries.** The echo's secondaries use the normal propagation validators, and Shatter/Chain use proxies.
- **Launch source.** An echo launched from the caster uses the native SPELL_GO (no visual-only packet naming
  the local player; that crashed the client).
- **Procs.** With `Echo.CanProc` off, echo executions carry `TRIGGERED_DISALLOW_PROC_EVENTS`.
- **Crit.** With `Echo.CanCrit` off, crits are removed from every hit of the lineage.

## Status

RUNTIME CODED, SYNTAX CHECKED, REQUIRES IN-GAME TEST. The previous version was tested in game (it crashed the
client; fixed). The payload replay and echo-lineage propagation are new and untested.
