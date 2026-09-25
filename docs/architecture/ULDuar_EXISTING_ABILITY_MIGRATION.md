# Migration of existing Ulduar ability mechanics

Nothing was deleted. The legacy node build (`PlayerAbilityState`, `.ua element/delivery/coverage/...`, the addon
protocol) keeps working unchanged. The engine runs **on top of it**: when a player has engine layers for an
ability, `BuildRuntimeContext` first builds the legacy context and then lets the resolved values it can execute
override it. Players without engine layers use exactly the previous code path.

| Mechanic | Current behavior / implementation | Generalized mapping | Migration risk | Runtime feature needed | Test needed |
| --- | --- | --- | --- | --- | --- |
| Frostbolt base | Definition id 1, spell chain 116, CastTime / Unit / Projectile / Damage+Aura, native SpellInfo | `EngineBridge::BuildCore`: Damage 100 (= native), Element from base element / school, CastTime/Cooldown/GCD/ranges/cost/speed from the ranked SpellInfo | Low; Core is read-only | none | in-game: numbers match native tooltip |
| Impact | Instant secondary on targets near the impact, Coverage -> count, 10 yd + 2/rank | Planned: Targeting.MaxTargets > 1 with Origin PrimaryTarget for Direct definitions. **Not mapped by the bridge yet** (Direct definitions have no Projectile component); legacy Impact keeps working | Medium: Impact vs Shatter differ only by delivery | bridge rule for Direct secondaries | parity of targets/range |
| Split | Root launch, extra projectiles from caster, staggered | Projectile.Targets > 1, Origin Caster (bridge -> Split) | Low | existing executor | stagger unchanged |
| Shatter | Secondary projectiles from impacted target | Projectile.Targets > 1, Origin PrimaryTarget (bridge -> Shatter) | Low | existing executor | visual source from target |
| Nova | All valid targets within radius around target, 5 yd + 1/rank | ADD Area, Origin PrimaryTarget, Area.Radius, Area.Scaling (bridge -> Nova) | Medium: Nova has no target cap; Area.MaxTargets 0 = unlimited keeps parity | existing executor | radius and scaling |
| Chain | Sequential hops from previous target, rebound rank with revisit gap | Projectile.Targets, AcquisitionRange, Origin PreviousTarget (bridge -> Chain); rebound -> future Targeting.SecondaryCanRepeat | Medium: rebound not mapped yet | executor + repeat rule | hop order, no duplicate hits |
| Additional targets / Coverage | Coverage rank -> SecondaryTargetCount / SearchRange | Projectile.Targets / AcquisitionRange | Low | none | - |
| Potency | Secondary effect multiplier 10% + 5%/rank | Projectile.Scaling / Area.Scaling (percent) | Low | none | secondary damage % |
| Element conversion | Node sets element; `Spell::SetSpellSchoolMask` per Spell when supported | Primary.Element SET | Low | none | school in combat log |
| Damage node | +5%/rank primary damage | Primary.Damage PERCENT_ADD | Low | none | - |
| Cooldown node | -0.5 s/rank, max 50%, floor 1 ms | Casting.Cooldown ADD (engine: no floor, 0 = no cooldown) | Legacy floors stay for legacy nodes; engine path uses `CooldownOverrideMs` | done | cooldown 0 and added cooldown in game |
| Cast time node | -0.1 s/rank, max 50%, min 0.5 s | Casting.CastTime ADD/MULTIPLY (engine: 0 = instant) | Core guard widened; legacy callers unchanged | done | instant cast, moving after instant |
| Mobile casting | Node exists, always refused (no safe hook) | Casting.CanCastWhileMoving | High: needs movement hook review | core/movement hook | cast while moving, interruption |
| Rank / state system | CustomRank, Evolution Points, persisted per character | Future: an "EvolutionNodes" layer that translates nodes into modifiers (source kind Talent) | Medium: must preserve spent points and SQL | none | budget parity |
| Arcane Missiles controller | Channel controller + payload spell via aura script | Casting.ChannelTime / ChannelTickInterval (resolved only) | High: channel timing is native | channel executor | tick parity |

## Recommended incremental order

1. Keep legacy nodes as the player-facing system; use the Lab to validate engine runtime parity per mechanic.
2. Translate legacy nodes into an engine layer (source Talent) behind a config switch, compare both
   `AbilityRuntimeContext`s in debug logs, then flip.
3. Remove the legacy 50% floors only when the node translation replaces them.
4. Add executors in this order: conditions adapter (OnHit), echo scheduler, periodic conversion, resource/range,
   moving cast.
