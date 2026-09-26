# Local validation checklist (Ability Engine runtime)

For you to run on your local build after pulling. **None of these tests has been executed.** The cloud
environment had no worldserver, database or client. It only compiled and ran the pure engine unit tests and
syntax-checked the module and core sources. Record results next to each item (PASS / FAIL + notes).

Branches: `claude/practical-pascal-u2fl8o` in `ulduar-wow` and in `mod-ulduar-abilities`.

## 0. Build preparation

- [ ] Pull both branches and place `mod-ulduar-abilities` in `modules/` as you normally do.
- [ ] **Re-run the CMake configure/generate step.** The module collects sources with a glob and no
  `CONFIGURE_DEPENDS`, and new files were added since the original module. A plain rebuild does not see them.
  The engine files are:
  - `src/engine/*.cpp`, including `Capabilities.cpp`, `SummonModel.cpp` and `Presentation.cpp`
  - `src/AbilityEngineBridge.cpp`
  - `src/AbilityLabCommands.cpp`
  - `src/AbilityEchoScheduler.cpp`
  - `src/AbilityPeriodicExecutor.cpp`
  - `tests/AbilityArchitectureTest.cpp`
- [ ] The core changes in `ulduar-wow` are in `Spell.h` / `Spell.cpp`:
  - cast-time multiplier range
  - `SetPowerCostOverride`, `SetRangeDelta`, `SetCanCastWhileMoving`
- [ ] Merge the new keys from `conf/mod_ulduar_abilities.conf.dist` into your `mod_ulduar_abilities.conf`:
  - `UlduarAbilities.DebugEditor`
  - every `UlduarAbilities.Limit.*`, including the new `UlduarAbilities.Limit.MaxSummonCount`
- [ ] Full build: worldserver, then fix any compile or link error before continuing. Note the compiler
  (MSVC version).
- [ ] Unit tests: configure with `BUILD_TESTING=ON`, build `unit_tests` and run
  `unit_tests --gtest_filter=Ulduar*`.
  - Expected: all Ulduar tests pass (56 engine/architecture tests plus the existing Forge Phase A tests).
- [ ] Update the client addon (`client/Interface/AddOns/UlduarAbilities`, version 1.6.0).
- [ ] Start the worldserver and check the log:
  - no `[UlduarAbilities]` limit warnings unless you changed limits;
  - a warning when `DebugEditor = 1`.

Command syntax: `.ua lab set <ability> <Property> <op> <value>`; the op is always required (booleans:
`enable 1` / `disable 0`; enums by name, e.g. `set fire`).

Test setup used below: a mage with Frostbolt, and target dummies or neutral NPCs.

- Useful GM commands: `.cooldown`, `.modify mana`, `.aura <id>`, `.unaura <id>`, `.die`, `.respawn`.
- Turn on `UlduarAbilities.Debug = 1` to get per-cast lines in the `spells` log.
- `.ua lab inspect frostbolt` shows:
  - `RUNTIME:` lines (executed);
  - `RESOLVED ONLY` lines (calculated only);
  - `WARN:` / `ERROR:` diagnostics.

## 1. Legacy / unmodified behavior

- [ ] With no Lab layer and no build, Frostbolt matches stock 3.3.5a: cast time, mana cost, damage range,
  slow, range, no cooldown.
- [ ] Flash Heal, Arcane Missiles and Blizzard behave as stock.
- [ ] Legacy node builds (`.ua` / addon Abilities tab) still work and `.ua lab clear all` does not affect them.
- [ ] A non-catalog spell (for example Fire Blast) is unaffected.

## 2. Damage and healing modifiers

- [ ] `.ua lab set frostbolt Primary.Scaling multiply 2`: hits deal about 2x; crits scale too.
- [ ] `.ua lab set frostbolt Primary.Damage multiply 2` still works and prints a one-line deprecation notice.
- [ ] Paladin: `.ua lab set holylight Primary.Scaling multiply 1.5`: heals about 1.5x (Flash Heal is not
  runtime-enabled).
- [ ] `.ua lab clear frostbolt`: values return to stock.

## 3. Cast time

- [ ] `.ua lab set frostbolt Casting.CastTime subtract 1s`: shorter cast bar, and the server accepts the cast
  at the new time.
- [ ] `.ua lab preset frostbolt instant` (0 ms): no cast bar and immediate launch. The inspector shows `INSTANT`.
- [ ] `.ua lab set frostbolt Casting.CastTime multiply 2`: longer cast, no early completion.
- [ ] Haste (`.aura 12472` Icy Veins) still shortens a modified cast time.
- [ ] Legacy cast-time reduction nodes give the same result as before this branch.

## 4. Cooldown

- [ ] Frostbolt has no native cooldown. `.ua lab set frostbolt Casting.Cooldown set 5s`: a 5 s cooldown
  starts, the action bar shows it, and recasting early is rejected.
- [ ] `.ua lab set frostbolt Casting.Cooldown set 0` (after clear): no cooldown.
- [ ] On a spell with a native cooldown, reduce it and set it to 0; check the cooldown is removed server- and
  client-side.
- [ ] The GCD is unchanged in every case.

## 5. Element conversion

- [ ] `.ua lab set frostbolt Primary.Element set fire`: the damage school is fire in the combat log; fire
  resistance and fire immunity apply.
- [ ] A definition without element support shows `RESOLVED ONLY: Primary.Element`.

## 6. Propagation

- [ ] `.ua lab preset frostbolt split`: extra projectiles from the caster, staggered launch.
- [ ] `shatter`: secondaries from the impacted target at reduced scaling.
- [ ] `chain`: sequential jumps from each previous target; no target is hit twice.
- [ ] `nova`: area around the primary target.
- [ ] For each: the secondary targets are only hostile, alive and in line of sight. There is no cost, GCD or
  cooldown per secondary, and no infinite chaining.

## 7. Conditions

- [ ] `.ua lab preset frostbolt execute`: against a target above 35% health, damage is normal.
- [ ] Below 35% health (`.damage` the target down, or use a low-health mob): damage is about 1.5x.
- [ ] The inspector lists 1 conditional modifier and `Primary.Scaling` unchanged (not baked).

## 8. Echo

Use `.ua lab preset frostbolt echo`, then `.ua lab set frostbolt Echo.Chance set 100` to make it deterministic.

- [ ] Echoes arrive after the delay with decreasing scaling; the maximum count is respected.
- [ ] **Target death:** kill the target before the echo fires. No echo, no error, no crash, no retarget.
- [ ] **Target invalidation:** the target becomes friendly, evades, or you move out of range (spell range + 5)
  or out of line of sight. The echo is skipped.
- [ ] **Caster logout / death** before the echo fires: nothing happens, no crash.
- [ ] **Resource:** mana is charged once per cast, not per echo.
- [ ] **Cooldown:** with `Casting.Cooldown set 5s`, an echo does not restart or extend the cooldown.
- [ ] **GCD:** echoes do not trigger a GCD.
- [ ] **Procs:** with `Echo.CanProc` off (default), echo hits trigger no procs; with
  `.ua lab set frostbolt Echo.CanProc enable 1`, hit procs occur. Note whether cast-type procs occur on echoes
  (open question in the appendix, section 11).
- [ ] **Recursion:** echoes never produce echoes and never propagate (combine with `shatter`: only the root
  hit shatters).
- [ ] **Crit:** with `.ua lab set frostbolt Echo.CanCrit disable 0`, echoes never crit.

## 9. Direct-to-periodic conversion

Use `.ua lab preset frostbolt dot` (60% converted, 12 s, 3 s ticks, can haste, can crit).

- [ ] The direct hit deals about 40% and ticks follow every 3 s.
  - Total periodic is about 60% of the hit at the default 100% efficiency.
- [ ] **Efficiency:** `.ua lab set frostbolt Periodic.ConversionEfficiencyPct set 200`.
  - Direct stays at about 40%; the periodic total becomes about 120% of the hit.
- [ ] **Haste:** with a haste buff active *when the DoT is applied*, the interval is shorter. Removing the
  buff mid-DoT does not change it (snapshot).
- [ ] **Minimum interval:** `.ua lab set frostbolt Periodic.TickInterval set 100`.
  - The inspector shows the balance clamp to 500 ms, and ticks are never faster than 500 ms.
- [ ] **Resist:** give the target frost resistance. Ticks are partially resisted.
- [ ] **Absorb:** `.aura 17` (Power Word: Shield) on the target. Ticks are absorbed.
- [ ] **Immunity (new fix):** `.aura 642` (Divine Shield) on the target mid-DoT, or a frost-immune mob.
  - Ticks deal no damage and show "Immune".
  - After the immunity ends, the remaining ticks deal damage again.
- [ ] **Stacking:** `.ua lab set frostbolt Periodic.CanStack enable 1`,
  `.ua lab set frostbolt Periodic.MaxStacks set 5`,
  `.ua lab set frostbolt Periodic.StackBehavior set addstackandrefresh`. Repeated casts increase the tick size up to 5 stacks.
- [ ] **Refresh:** default `refreshduration`. A recast refreshes the duration without stacking.
- [ ] **Spreading:** `.ua lab preset frostbolt spreaddot` with several mobs within 8 yd. The DoT spreads to up to
  2 unaffected mobs per spread and never to friendly or out-of-sight units.
- [ ] **Logout cleanup:** log out mid-DoT. Ticks stop, and there is no crash on logout or relog.
- [ ] **Target death:** ticks stop; no error.
- [ ] **Known limitation:** no debuff icon appears on the target (appendix section 10). Confirm and note it.

## 10. Resource cost

- [ ] `.ua lab set frostbolt Resource.Cost multiply 0.5`: the mana cost halves. Check the tooltip vs actual
  deduction; the tooltip still shows the native cost.
- [ ] `.ua lab set frostbolt Resource.Cost set 0`: the cast is free, and castable at 0 mana.
- [ ] A cost increase above your current mana fails with "Not enough mana".

## 11. Range

- [ ] Shorter: `.ua lab set frostbolt Range.Max subtract 10`. Casting at 25 yd fails with "Out of range".
- [ ] Normal: stock range still works after `.ua lab clear frostbolt`.
- [ ] Longer: `.ua lab set frostbolt Range.Max add 10`.
  - At 35 yd the client itself may refuse to cast (client limitation; record the exact behavior).
  - If the cast is sent, the server accepts it.
- [ ] Minimum range: a positive `Range.Min` rejects casts that are too close.

## 12. Cast while moving

Use `.ua lab preset frostbolt movingcast`.

- [ ] Starting the cast while standing, then moving: the cast should complete. Record whether the client
  stops its own cast bar.
- [ ] Starting the cast while already moving: record whether the client refuses or the server accepts.
- [ ] Jumping or falling during the cast: record the behavior (falling casts are not supported).
- [ ] After `.ua lab clear frostbolt`, movement interrupts the cast again.
- [ ] Arcane Missiles (channel): movement still interrupts it (moving channels are not supported).

## 13. Multiple players and isolation

- [ ] Player A applies Lab modifiers to Frostbolt; player B (unmodified) casts Frostbolt. B gets stock
  behavior for every section above.
- [ ] Both cast simultaneously on the same target:
  - A's DoT and B's DoT are separate;
  - A's echoes do not use B's values;
  - there is no state leakage after A logs out.
- [ ] A changes a modifier while a projectile is in flight. That projectile keeps the old values (snapshot);
  the next cast uses the new ones.

## 14. Ability Lab access and UI

- [ ] GM account, `DebugEditor = 1`: all `.ua lab` commands work.
- [ ] GM account, `DebugEditor = 0`: every `.ua lab` command answers "Disabled"; nothing changes.
- [ ] Non-GM account: `.ua lab` is not available (command not found or no permission).
- [ ] Chat interface: `set`, `effect`, `addproc`, `component`, `list`, `remove`, `clear`, `preset`, `save`,
  `presets`, `properties <filter>` and `inspect` each print the expected output.
- [ ] Addon: `/ua lab` and `/ualab` open the window. For each action:
  - Inspect, List, Clear, Clear all
  - Apply (property/op/value)
  - Find
  - Presets list and Load
  - Save as (the saved name appears in the dropdown)
  - Component Add/Remove
  - Remove #
- [ ] Addon output colors: `RUNTIME` green, `RESOLVED ONLY` orange, rejections red.
- [ ] The addon with `DebugEditor = 0` or as non-GM shows the server's refusal. There is no Lua error.
- [ ] The addon Abilities tab (player builds) still works while the Lab window is open.
- [ ] `/reload` with the Lab window open: no Lua errors.

## 15. New architecture foundations (engine data only)

These families have **no gameplay runtime**; only check that nothing regressed.

- [ ] `.ua lab properties summon` lists the `Summon.*` properties.
- [ ] `.ua lab properties effect.` lists the new `Effect.*` properties.
- [ ] `.ua lab set frostbolt Periodic.ConversionEfficiencyPct set 150` (after `preset dot`) appears as
  RUNTIME with "150% efficiency" in the report line.
- [ ] Capability derivation for crowd-control spells can only be observed once a CC spell is in the ability
  catalog. Until then, verify that Frostbolt (snare) shows **no** `CapabilityRestricted` warnings with any
  preset.

## 16. Output semantics milestone (Primary.Scaling, periodic plan, echo replay, tooltip)

- [ ] **Periodic exact pool:** `.ua lab preset frostbolt dot`, then
  `.ua lab set frostbolt Periodic.Conversion set 30` and
  `.ua lab set frostbolt Periodic.ConversionEfficiencyPct set 200` (no haste buffs).
  - The direct hit is about 70% of stock.
  - The ticks sum to about 60% of the stock hit.
- [ ] **Tick interval:** `.ua lab set frostbolt Periodic.TickInterval set 1.5s`. More, smaller ticks with the same
  sum; the total never grows with the tick rate.
- [ ] **Initial tick:** `.ua lab set frostbolt Periodic.InitialTick enable 1`. One tick on hit and the rest on the
  interval; the sum stays the same (it was about 6/7 before).
- [ ] **Uneven duration:** set a duration that is not a multiple of the interval. No extra short tick at the end.
- [ ] **Echo replays Split:** `.ua lab preset frostbolt split` + `echo` + `Echo.Chance set 100`, 4+ mobs.
  - Each echo hits the primary target and then splits again.
  - With 60% echo and 60% split scaling, echo split hits are about 36% of a stock hit.
- [ ] **Echo with Shatter/Chain/Nova:** the echo's secondaries start from the echo's own impact (proxies for
  Shatter/Chain), never hit the echo's primary target twice, and do not reuse the original cast's visited
  targets.
- [ ] **Echo + DoT:** with `Echo.CanEchoPeriodic` off, the echo deals only the immediate part and the running
  DoT is untouched. With it on (`enable 1`), the echo applies its own smaller pool.
- [ ] **Echo resources:** the echo hits (including their splits) cost no mana, trigger no GCD or cooldown, and no
  echo produces another echo. With MultiEcho, all echoes originate from the original cast.
- [ ] **Echo proc/crit rules:** `Echo.CanProc` off gives no procs from any echo hit; `Echo.CanCrit` off gives no
  crits on the echo or its splits.
- [ ] **Native aura on echoes:** Frostbolt's own slow is applied by echo hits too (the payload is replayed).
- [ ] **Arcane Missiles with echo:** each missile may echo. The channel never restarts. Missiles propagate
  independently. Interrupting the channel stops new missiles while in-flight copies and echoes finish.
- [ ] **Arcane Missiles ranks:** repeat on a low rank and on the max rank; two mages channelling at once keep
  separate snapshots.
- [ ] **Inspector states:** `.ua lab set frostbolt Delivery.Kind set beam` shows `UNSUPPORTED: Delivery.Kind`.
  A range increase shows `PARTIAL:`. On Arcane Missiles, `Casting.ChannelTickInterval` shows RESOLVED ONLY.
- [ ] **Tooltip, normal:** hover Frostbolt with the `dot` preset. One line like
  `Deals X Frost damage and an additional Y Frost damage over 12 sec.`, with no percentages or property names.
  - Refresh first with `/reload` or reopen the Ulduar window.
- [ ] **Tooltip, Shift:** holding Shift while hovering switches to Direct/Periodic/Duration/Tick Interval lines
  and the collapsed "Secondary Damage" line. Releasing Shift switches back.
- [ ] **Tooltip, healing:** Holy Light says "Heals the target for X."
- [ ] **Old addon:** it ignores the new `OUT` record without errors.

## 17. Stability

- [ ] 30 minutes of mixed Lab presets in a group of mobs:
  - no crash or assert;
  - no growing memory from echo, periodic or propagation state;
  - server log free of new errors.
- [ ] `.reload config` with changed `UlduarAbilities.Limit.*` values: new limits apply to new resolutions
  (inspector).
- [ ] Server shutdown with active DoTs and pending echoes: clean shutdown.
