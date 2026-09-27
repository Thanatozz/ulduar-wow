# Local validation checklist (Windows, stages A–O)

Authoritative checklist for your local Windows build, rewritten 2026-09-27 for the generic periodic carrier
pool. **None of these checks has been executed.** The cloud environment had no worldserver, database or
client; it only ran the pure engine unit tests (98 passing), syntax checks and codestyle. Record PASS / FAIL +
notes next to each item. Stop at the first failing stage and report it.

Branches: `claude/practical-pascal-u2fl8o` in `ulduar-wow`, `mod-ulduar-abilities` and `ulduar-client-patch`.

Rules for this checklist:
- Never modify `C:/WoWProjecto/Client/Wow.exe`, `C:/WoWProjecto/Client/Data` or the primary client's MPQs.
- Never apply `ulduar_abilities_005_world_periodic_carriers.sql` (SUPERSEDED).
- Echo periodics are separate lineages: a check that expects an echo to refresh, replace or stack onto the
  Root DoT is stale and must be marked FAIL-STALE, not fixed by changing expectations.

Command syntax: `.ua lab set <ability> <Property> <op> <value>`; the op is always required (booleans:
`enable 1` / `disable 0`; enums by name). Useful GM commands: `.cooldown`, `.modify mana`, `.aura <id>`,
`.unaura <id>`, `.die`, `.respawn`, `.ua lab inspect <ability>`, `.ua lab carriers`. Set
`UlduarAbilities.Debug = 1` for per-cast `Periodic: … Backing: … Reason: …` lines in the `spells` log.

## Stage A — Sync and build preparation

- [ ] Pull all three branches; place `mod-ulduar-abilities` in `modules/`.
- [ ] **Re-run CMake configure/generate** (the module globs sources without `CONFIGURE_DEPENDS`). New files
  since the last checklist: `src/engine/PeriodicIdentity.cpp`, `src/engine/AuraGrouping.cpp`,
  `tests/AbilityPeriodicTargetTest.cpp`.
- [ ] Core changes to expect in the build: `SpellAuras.h/.cpp` (`SetSchoolMaskOverride`,
  `GetEffectiveSchoolMask`), `SpellAuraEffects.cpp`, `Unit.cpp` (`SendPeriodicAuraLog`), plus the earlier
  `TargetInfo::damageDoneBeforeTaken` in `Spell.h/.cpp`, `SpellEffects.cpp`.
- [ ] Merge new keys from `conf/mod_ulduar_abilities.conf.dist` into your config.

## Stage B — Build and unit tests

- [ ] Full worldserver build (note the MSVC version); fix compile/link errors before continuing.
- [ ] `BUILD_TESTING=ON`, build `unit_tests`, run `unit_tests --gtest_filter=Ulduar*`: all pass, including
  `UlduarPeriodicIdentity.*`, `UlduarCarrierPool.*`, `UlduarAuraGroups.*`, `UlduarDispel.*`,
  `UlduarPeriodicCarrier.*` and the Forge Phase A tests.
- [ ] Client patch portable tests (see `ulduar-client-patch/docs/WINDOWS_HANDOFF.md`, stage 1).

## Stage C — Ledger and SQL (world DB backup first)

- [ ] **Precondition:** `docs/data/ulduar_id_allocations.json` is at revision
  `PC2-GENERIC-PERIODIC-CARRIER-POOL-004` or later (pool 310272..312319 RESERVED; appended 2026-09-27).
- [ ] Apply in this order ([PERIODIC_RUNTIME.md](PERIODIC_RUNTIME.md#sql-application-order)):
  1. `modules/mod-ulduar-abilities/data/sql/db-world/ulduar_abilities_001_world.sql`
  2. `data/sql/updates/pending_db_world/ulduar_abilities_003_world_starters.sql`
  3. `data/sql/updates/pending_db_world/ulduar_abilities_007_world_generic_periodic_carriers.sql`
  4. `data/sql/updates/pending_db_world/ulduar_abilities_006_world_blizzard.sql`
  5. `data/sql/updates/pending_db_world/ulduar_abilities_008_world_mind_flay.sql`
- [ ] Characters migrations as before (`001`, `002`, `004`).
- [ ] Verify: `SELECT COUNT(*) FROM spell_dbc WHERE ID BETWEEN 310272 AND 312319` = 2048;
  `SELECT COUNT(*) FROM spell_dbc WHERE ID BETWEEN 141344 AND 141357` = 0; bindings for
  `aura_ulduar_periodic_carrier` = 2048.

## Stage D — Startup

- [ ] No `[UlduarAbilities]` error. The carrier pool validates (no "pool not loaded" warning).
- [ ] Blizzard and Mind Flay are **not** reported as disabled.
- [ ] `.ua lab carriers` → `Carrier pool: ready. In use: 0 …`.
- [ ] Negative check (optional, on a copy DB): without SQL 007, the log reports the pool as not loaded and
  converted periodics run on the executor; without 008 only Mind Flay is disabled.

## Stage E — Legacy behavior

- [ ] With no Lab layer, Frostbolt, Flash Heal, Arcane Missiles, Blizzard and Mind Flay match stock 3.3.5a.
- [ ] Legacy node builds (`.ua` / addon Abilities tab) still work; `.ua lab clear all` does not affect them.
- [ ] A non-catalog spell (Fire Blast) is unaffected.

## Stage F — Direct modifiers

- [ ] `Primary.Scaling multiply 2` ≈ 2× hits (crits too); `Primary.Damage` alias prints a deprecation notice.
- [ ] Holy Light `Primary.Scaling multiply 1.5` ≈ 1.5× heals.
- [ ] Cast time: subtract, `preset instant`, multiply 2; haste still applies.
- [ ] Cooldown: `set 5s` starts a cooldown; `set 0` removes it; GCD unchanged.
- [ ] Element: `Primary.Element set fire` → fire school in the log, fire resistance/immunity apply.
- [ ] Resource cost halves / zero / above current mana fails.
- [ ] Range shorter rejects; longer: record client behavior; `Range.Min` rejects close casts.
- [ ] Cast while moving (`preset movingcast`): record client behavior; channels still interrupt.

## Stage G — Propagation and conditions

- [ ] `split`, `shatter`, `chain`, `nova`: hostile, alive, LOS targets only; no cost/GCD/cooldown per secondary;
  no infinite chaining.
- [ ] `preset execute`: normal above 35% HP, ≈ 1.5× below; inspector shows 1 conditional modifier (not baked).

## Stage H — Echo

`.ua lab preset frostbolt echo`, `.ua lab set frostbolt Echo.Chance set 100`.

- [ ] Echoes arrive after the delay with decreasing scaling; max count respected; echoes never echo.
- [ ] Target death / invalidation / caster logout before the echo: skipped, no crash, no retarget.
- [ ] Mana once per cast; no GCD/cooldown from echoes.
- [ ] `Echo.CanProc` off: no procs; `Echo.CanCrit` off: no crits on the echo or its secondaries.
- [ ] Full payload replay with `split`/`shatter`: echo secondaries from the echo's impact at echo × secondary
  scaling (60% × 60% = 36%).
- [ ] Frostbolt's native slow is applied by echo hits.

## Stage I — Periodic conversion on the generic pool

`.ua lab preset frostbolt dot`, `Debug = 1`, cast on a dummy.

- [ ] Log: `Backing: CARRIER Reason: CARRIER`. The target has an aura with an id in 310272..312319 (the
  lowest free one, normally 310272). Record what a stock client shows (nothing / unknown aura).
- [ ] **Instance school:** `SMSG_PERIODICAURALOG` / combat log shows **Frost** ticks, not a 127 mask. With
  `Primary.Element set fire`, the next application ticks as Fire.
- [ ] Exact pool: conversion 30%, efficiency 200%, 6 s / 1 s → ticks sum ≈ 60% of a stock hit; with
  `Periodic.InitialTick enable 1`, one more tick, same sum. Tick interval 1.5 s: more, smaller ticks, same sum.
- [ ] Dynamic taken modifiers: Curse of the Elements after the hit → remaining ticks grow; before the hit →
  direct and ticks grow once, never twice.
- [ ] Absorb: Power Word: Shield absorbs ticks.
- [ ] Immunity: a frost-immune target (or Ice Block) shows immune ticks; Divine Shield purges the carrier
  (school overlap) and `.ua lab carriers` shows the ID released.
- [ ] Fire school conversion on a fire-immune mob: no carrier is created (full-mask immunity), the direct part
  still lands.
- [ ] No block, no pushback on ticks; generic periodic procs fire once; no class talent treats the carrier as
  its spell.
- [ ] Haste snapshot at application; `Periodic.TickInterval set 100` clamps to 500 ms.

## Stage J — Pool, identity and lineages

- [ ] **Two abilities, same school, one caster, one target:** Frostbolt (`preset dot`) + Fireball (`preset dot`,
  `Primary.Element set frost`): two carriers with different pool IDs, both `CARRIER`, both ticking Frost.
- [ ] **Reuse across targets and casters:** two dummies each get 310272; a second mage on the same dummy also
  gets 310272 (the core keys by spell + caster).
- [ ] **IndependentDuration:** `Periodic.StackBehavior set independentduration`, three casts: three carrier
  auras with independent timers.
- [ ] **Stacking within a lineage:** `addstackandrefresh`, `CanStack enable 1`, `MaxStacks set 5`: the aura's
  stack count follows the engine; refresh keeps the tick rhythm.
- [ ] **Echo lineage:** `Echo.CanEchoPeriodic enable 1` + echo preset: the echo creates its **own** carrier
  (separate pool ID); the Root DoT's amount, duration and stacks are unchanged. Without `CanEchoPeriodic`,
  the echo deals only its immediate part and allocates no carrier.
- [ ] **Spread** (`preset spreaddot`): the spread copy lands on its own carrier with the source's tick amount
  and school; never on friendly/out-of-LOS units.
- [ ] **Release:** after expiry, death, `.unaura`, dispel-like removal and caster logout, `.ua lab carriers`
  returns to 0 in use. Relog mid-DoT: no crash; the orphan aura is not stolen by a new cast (new cast gets
  the next ID).
- [ ] **Executor fallbacks:** `UlduarAbilities.Periodic.NativeCarrier = 0` → `EXECUTOR / CARRIER_DISABLED`;
  a conversion on a payload that is not `SCHOOL_DAMAGE` (if one is available) → `NO_PRE_TAKEN_BASE`. Never
  both damage paths (tick count matches one source).
- [ ] **Aura slots:** (optional) fill a target's visible auras; the next conversion falls back with
  `AURA_SLOTS_FULL` and the counter increments.

## Stage K — Multi-school

- [ ] A combined-school conversion (Frostfire via the Lab, if available): one tick event with the combined
  mask; resistance = lowest of the two; immunity requires both schools. Record the crit chance source (first
  school) for the open decision in [PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md).

## Stage L — Dispel (native)

- [ ] A second player carrying your converted DoT casts Cleanse / Dispel Magic on themselves: the carrier is
  **not** removed (carriers have no dispel type). Record it; this is the documented open decision in
  [DISPEL_PRIORITY_AUDIT.md](DISPEL_PRIORITY_AUDIT.md) §2, not a bug to patch here.
- [ ] Native DoTs (Corruption, Unstable Affliction) dispel as stock, including UA's backlash.

## Stage M — Channels

- [ ] **Arcane Missiles:** low and max rank; each missile converts, propagates and may echo; the channel never
  restarts; interrupt stops new missiles; two mages keep separate snapshots.
- [ ] **Blizzard:** each pulse hits every enemy with scaling/conditions/element/conversion; no
  Split/Shatter/Chain/Nova/Echo from a pulse; interrupt stops pulses; ranks 1, 7 (27085 → 42198), 9.
- [ ] **Mind Flay:** ranks 1 and 9; each tick (58381) is scaled by `Primary.Scaling`; the slow and beam stay
  native; `split` makes each tick split; echo replays a tick, never the channel; interrupt stops ticks.
- [ ] Inspector: Arcane Missiles `Casting.ChannelTickInterval` → RESOLVED ONLY; Drain Life is not in the
  catalog.

## Stage N — Client, addon and tooltip

- [ ] Addon: `/ua lab` window actions (Inspect, List, Clear, Apply, Find, Presets, Save as, Components,
  Remove #); `DebugEditor = 0` and non-GM get the server's refusal without Lua errors.
- [ ] Tooltip normal line (`Deals X Frost damage and an additional Y Frost damage over 12 sec.`), Shift level,
  healing wording; an old addon ignores the `OUT` record.
- [ ] Stock client with a carrier on the target: record aura frame behavior (unknown spell id) — input for the
  client patch.
- [ ] Client patch: follow `ulduar-client-patch/docs/WINDOWS_HANDOFF.md`. The development loader runs only on
  a **copy** of the client; capabilities stay 0 until each is proven end to end.

## Stage O — Isolation and stability

- [ ] Player A with Lab modifiers, player B stock: B is stock everywhere; simultaneous DoTs on one target stay
  separate; no leakage after A logs out; in-flight projectiles keep their snapshot.
- [ ] 30 minutes of mixed presets in a mob group: no crash/assert; `.ua lab carriers` in-use returns to 0 when
  combat ends; memory stable; no new log errors.
- [ ] `.reload config` with changed limits applies to new resolutions.
- [ ] Shutdown with active DoTs and pending echoes: clean.
