# Ability Engine architecture appendix

Summons, buffs, debuffs, auras/emitters, triggers, imbues, dynamic presentation, semantic naming, stable
variant identity and client limits.

This appendix extends the existing engine. It does not replace it. Existing references:

- [components](ULDuar_ABILITY_COMPONENTS.md)
- [property registry](ULDuar_ABILITY_PROPERTIES.md)
- [modifier engine](ULDuar_MODIFIER_ENGINE.md)
- [zero semantics](ULDuar_ZERO_SEMANTICS.md)
- [Essence contract](ULDuar_ESSENCE_MODIFIER_CONTRACT.md)
- [runtime](ULDuar_ABILITY_RUNTIME.md)
- [Lab](ULDuar_ABILITY_LAB.md)

The local test plan is [ULDuar_LOCAL_VALIDATION_CHECKLIST.md](ULDuar_LOCAL_VALIDATION_CHECKLIST.md).

## 0. Status vocabulary and how this was validated

| Label | Meaning |
| --- | --- |
| IMPLEMENTED | Code exists in the engine or module |
| UNIT TESTED | Covered by `tests/AbilityEngineTest.cpp` / `tests/AbilityArchitectureTest.cpp`, which were compiled and passed in the cloud environment (standalone g++ 13 + gtest, 56/56) |
| SYNTAX CHECKED | `g++ -fsyntax-only` against the AzerothCore headers; not linked, not run |
| STATICALLY AUDITED | Read and reasoned about from the code; nothing was executed |
| CALCULATED ONLY | The engine resolves, validates and shows the value; no gameplay runtime executes it |
| RUNTIME CODED | Gameplay code exists but has never run |
| REQUIRES LOCAL BUILD | Needs your worldserver build (CMake re-configure + compile + link) |
| REQUIRES IN-GAME TEST | Needs a running server and a 3.3.5a client |
| REQUIRES CLIENT SUPPORT | The unmodified 3.3.5a client blocks or misrepresents it; a client change is needed |

No worldserver was built or started for this work, and no client was used. Nothing below is claimed to work
in game.

## 1. Summary of the audit

The first pass (162 properties, Components, Effects, Conditions, Requirements, Modifier Engine) is sound for
these families. Its key strengths:

- **Effect-scope properties.** `Effect.*` properties resolve per effect key.
- **One modifier path.** Lab and Essences share it.
- **Deterministic resolution.**
- **Explicit zero semantics.**

It needed extensions in five places, and one latent bug was fixed:

| Gap found | Why it mattered | Resolution (all IMPLEMENTED + UNIT TESTED, pure engine) |
| --- | --- | --- |
| No enforced design restrictions | Requirements only gate Essence socketing. Lab layers or several stacked Essences could still produce a 40-target, stacking, permanent Polymorph | **Capabilities**: a per-Core policy per modification axis (`Allowed` / `NoIncrease` / `Locked`), enforced by the resolver for every modifier source, and exposed to Requirements (`CapabilityAllows`) |
| No composition | An Emitter could not own its payload; a Summon could not own an aura | **`Effect.Parent`**: effects form a validated tree (no dangling parent, no cycles) |
| Effect kinds too coarse | `Aura` meant "applied status"; no Emitter, Imbue or inline payload | `EffectKind` extended (append-only): Buff, Debuff, Emitter, Imbue, Damage, Healing |
| Trigger events too few | No weapon/spell hit split, no avoidance, resource or aura events, no emitter interval | `TriggerEvent` extended (append-only) + `ExecutionOrigin` + `Effect.OriginMask` + PPM |
| Conversion and efficiency conflated | "50% converted at 200% efficiency" could not be expressed (and conversion is balance-capped at 100%) | `Periodic.ConversionEfficiencyPct` |
| **Bug:** effect-scope Requirements read the ability bag | "requires an Imbue on the main hand" always evaluated a default value | Effect-scope property requirements now scan the effects, optionally filtered by effect kind |

The registry grew from **162 to 179** properties. Everything else in this appendix is classification and design;
new runtime families were not implemented.

## 2. Model extensions (what exists now)

```
AbilityCore
├── Components, Values (ability scope)
├── Capabilities[axis] = Allowed | NoIncrease | Locked        NEW
└── Effects[]: Key, Kind, Values (effect scope)
      Kind: Proc Aura Dispel Displacement Summon Resource
            Buff Debuff Emitter Imbue Damage Healing          NEW (appended)
      Effect.Parent -> another effect key (tree)              NEW
```

- **Composition.** An effect with `Effect.Parent = k` is emitted/owned by effect `k`. `Parent = 0` means the
  ability owns it. The resolver rejects a parent that does not exist, self-references and cycles
  (`InvalidComposition`, the ability is invalid, so the cast keeps native behavior).
- **Capabilities.** Axes: Quantity, TargetCount, Duration, Area, Spread, Stacking, Persistence, Coverage, Element,
  Movement, Potency. Each numeric/boolean property maps to at most one axis (`Capabilities.cpp`).
  - `NoIncrease` allows only a decrease. Enumerations may not change at all under `NoIncrease` or `Locked`.
  - `Effect.RemoveOnDeath` is an inverted axis: turning it off makes the effect more persistent.
  - `ADD_COMPONENT Area` counts as widening the Area axis.
  - A blocked change keeps the base value and leaves a `CapabilityRestricted` warning in the inspector.
  - Conditional modifiers (stage 6) are subject to the same check.
- **Crowd-control policy.** `CrowdControlPolicies()`:
  - Locked: Spread, Stacking, Persistence, Coverage.
  - NoIncrease: Duration, TargetCount, Area, Quantity.

  The runtime bridge assigns it to any ranked spell with a loss-of-control mechanic: charm, disorient, fear,
  root, sleep, stun, freeze, knockout, polymorph, banish, shackle, horror, sapped, silence. It is derived from
  mechanics, not from a spell-id list. Snares are **excluded**, so Frostbolt keeps full modifiability. The
  bridge part is RUNTIME CODED / SYNTAX CHECKED / REQUIRES LOCAL BUILD.
- **Zero vs balance minimum.** A balance minimum no longer lifts a meaningful zero into an active value. This
  change was needed for `Effect.Interval = 0` ("no periodic activation") and affects no pre-existing property.

## 3. Summons

### 3.1 Archetypes

`Summon.Archetype`:

| Archetype | WotLK examples | Notes |
| --- | --- | --- |
| ControlledPet | Hunter pets, Warlock demons (Imp, Voidwalker, Succubus, Felhunter, Felguard), Water Elemental (glyphed), DK Ghoul (talented) | Persistent, controllable, owner stat scaling |
| Guardian | Shadowfiend, Gargoyle, Treants, Doomguard, Infernal, Army of the Dead ghouls, Water Elemental (base) | Temporary, AI-driven |
| Stationary | Future custom summons (turrets, wards) | Does not move; not bound to totem slots |
| Totem | Shaman totems | One per element slot in the core |

The archetype column is a design classification. The native AzerothCore class behind each spell (pet, guardian,
minion, totem) must be confirmed per spell when the summon runtime maps them.

"Swarm" is not an archetype. A swarm is a Guardian summon with `Summon.Count > 1`, which keeps quantity a
single generic axis.

### 3.2 Entity vs attack

The summon effect carries **entity** properties:

- lifetime: `Effect.Duration`
- `Summon.Count`
- `Summon.EntityHealthPct`
- `Summon.EntityMovementPct`

It also carries **attack** multipliers: `Summon.AttackScalingPct`, `Summon.AttackSpeedPct` and
`Effect.Element` (the attack element override; `Native` keeps the creature's own spell schools).

A DoT cast *by* the summon is a separate ability or effect with its own `Effect.Duration`. So "+50% summon
duration" (`Effect.Duration` on the Summon effect) never touches it (UNIT TESTED,
`EntityAndAttackAreSeparateFromEffectDuration`). When a summon's own spells need individual modification, they
are child effects (`Effect.Parent = summon key`) or referenced abilities with their own Core.

### 3.3 Property classification

| Concept | Classification | Representation |
| --- | --- | --- |
| summon.count | MISSING PROPERTY -> added | `Summon.Count` (0 = inactive, balance max `MaxSummonCount` = 10) |
| summon.duration | EXISTING (generalized) | `Effect.Duration` of the Summon effect |
| entity health | MISSING PROPERTY -> added | `Summon.EntityHealthPct` (strictly > 0) |
| entity armor / resistances | MISSING, deferred | Needs pet stat hooks first; add as `Summon.Entity*Pct` when a runtime exists |
| entity movement speed | MISSING PROPERTY -> added | `Summon.EntityMovementPct` (0 = cannot move) |
| damage / healing | MISSING PROPERTY -> added | `Summon.AttackScalingPct` (applies to all outgoing damage/healing of the entity) |
| attack speed | MISSING PROPERTY -> added | `Summon.AttackSpeedPct` |
| cast speed | NOT REQUIRED yet | Covered by AttackSpeed until a caster summon needs the split |
| attack range / aggro range | NOT REQUIRED yet | AI parameters; add with the summon runtime if a design needs them |
| threat | EXISTING (generalization pending) | `Primary.ThreatMultiplier` exists at ability scope; a summon-scope multiplier only when the runtime exists |
| element | EXISTING (generalized) | `Effect.Element` (attack element); entity visual theme = PRESENTATION ONLY |
| spawn radius / pattern | NOT REQUIRED yet | Placement policy of the runtime |
| target count | EXISTING (generalized) | `Effect.MaxTargets` on the summon's child damage effect |
| ability potency | EXISTING | `Summon.AttackScalingPct` / child `Effect.Scaling` |
| inherit AP / SP / crit / haste / health / other | MISSING, deferred, REQUIRES CORE HOOK | AzerothCore computes pet/guardian scaling inside `Guardian::UpdateStats` families, partly per creature entry. Needs a scaling hook before properties make sense |
| controllable / follows caster / stationary | CAPABILITY / derived | From `Summon.Archetype`; not separate booleans |

### 3.4 Capabilities for summons

Summon restrictions use the generic axes. There is no summon-specific compatibility engine:

Recommended default policies (data for the Cores; no Core sets them yet):

- **Totem.** `Movement` is Locked.
  - Quantity above 1 conflicts with the core's one-totem-per-element-slot model, so it stays Locked until a
    multi-totem runtime exists. This deliberately differs from the conceptual example (the brief listed totems
    as quantity-modifiable).
- **Shadowfiend.** Default (all Allowed).
- **Army of the Dead.** Quantity is Allowed. Its entity count comes from a channel's periodic trigger, not a
  count field, so the runtime maps `Summon.Count` onto whichever native mechanism spawns the entities (effect
  base points vs. tick count). The model stays the same.

UNIT TESTED: `CapabilityRejectsMovementOnTotems` (movement change reverted with a diagnostic; quantity still
accepted; a movement Essence is incompatible, a quantity Essence compatible).

### 3.5 Quantity vs individual efficiency

`SummonModel.h`, computed by the resolver into `ResolvedEffect::Summon` (IMPLEMENTED, UNIT TESTED):

```
individual = 1 - penalty x (count - base) / count        (only when count > base)
total      = count x individual / base
```

`penalty` is `Summon.QuantityPenaltyPct` (default 50%). It is **data on the effect**, so an Essence can soften
it without a per-spell formula.

| Base -> count | Individual | Total vs base |
| --- | --- | --- |
| 1 -> 2 | 75% | 150% |
| 3 -> 4 | 87.5% | ~117% |
| 8 -> 9 | ~94.4% | 106.25% |

These are not final balance numbers. The shape makes one extra entity worth much more to a solitary summon.
Fewer entities than the base never raises individual power; that direction needs its own design decision.

### 3.6 Runtime status

Summon runtime: **CALCULATED ONLY.** Nothing spawns differently yet. Runtime work needed:

- Map Count to native summon effects or tick counts.
- Apply IndividualMultiplier and AttackScaling to the entity's outgoing damage (UnitScript damage hooks
  filtered by owner GUID).
- Scale entity health, movement and attack speed on summon.
- Choose the owner stat inheritance policy.

## 4. Buffs

| Concept | Classification | Representation |
| --- | --- | --- |
| buff family | SHOULD BE EFFECT -> added | `EffectKind::Buff` (legacy `Aura` still accepted) |
| duration | EXISTING | `Effect.Duration` |
| potency | EXISTING | `Effect.Scaling` (%) / `Effect.Value` + `Effect.ValueKind` + `Effect.Stat` |
| stat affected | EXISTING BUT NEEDS GENERALIZATION | `Effect.Stat` is a raw identifier; it should become a typed stat enum when the buff runtime is built |
| coverage (self/single/party/raid/area) | MISSING PROPERTY -> added | `Effect.Coverage` (Single, Party, Raid, Area) + `Effect.ApplyTo` (relation) |
| target count | MISSING PROPERTY -> added | `Effect.MaxTargets` |
| radius | EXISTING | `Effect.Radius` |
| stack count / max stacks | EXISTING | `Effect.Stacks`, `Effect.MaxStacks`, `Effect.CanStack` |
| refresh behavior | EXISTING | `Effect.RefreshBehavior` |
| dispel type | EXISTING | `Effect.DispelType` |
| dispel resistance | MISSING, deferred | Add `Effect.DispelResistPct` with the buff runtime |
| persist through death | EXISTING (generalized) | `Effect.RemoveOnDeath = false`; Persistence axis (inverted) |
| persist through combat end | NOT REQUIRED yet | Buffs persist through combat by default in WotLK; add a flag only if a design needs removal on combat end |
| persist through zoning | NOT REQUIRED | Native aura behavior; not a modifier axis |
| application / removal conditions | SHOULD BE CONDITION | Existing `Condition` list; removal conditions need a runtime listener |

**Coverage transformation** (Icy Veins example, UNIT TESTED as `CoverageTradesAgainstDuration`): one Essence
carries several modifiers: `Effect.Coverage = Party`, `Effect.ApplyTo = Allies` and `Effect.Duration x 0.5`.
The trade-off is part of the Essence data, not engine code. A design that forbids it locks the Coverage axis,
and the Essence's `RequireCapability(Coverage)` then rejects it. Party/raid coverage transformation is
calculated only today.

**Persistence** (UNIT TESTED as `PersistThroughDeathIsAnExplicitProperty`): `RemoveOnDeath` is explicit data,
never inferred from spell flags. The Persistence axis can forbid it.

## 5. Debuffs and crowd control

| Concept | Classification | Representation |
| --- | --- | --- |
| debuff family | SHOULD BE EFFECT -> added | `EffectKind::Debuff` |
| duration / potency / radius / stacks / refresh / dispel type | EXISTING | Same `Effect.*` as buffs |
| target count / coverage | added | `Effect.MaxTargets`, `Effect.Coverage` |
| spread (debuff that spreads) | EXISTING for Periodic, NEEDS GENERALIZATION for non-periodic debuffs | `Periodic.CanSpreadOnTick` etc. cover DoTs. A spreading non-periodic debuff should reuse the same spread semantics on an Emitter child rather than new properties |
| movement slow, attack/cast speed reduction, damage/healing taken, armor/resistance reduction, vulnerability | EXISTING BUT NEEDS GENERALIZATION | `Effect.Stat` + `ValueKind` + `Value`; requires the typed stat enum (section 4) |
| crowd control class | MISSING PROPERTY -> added | `Effect.Control` (None, Stun, Root, Silence, Incapacitate, Fear, Charm, Sleep, Disarm) |
| CC restrictions (CanSpread, CanStack, CanIncreaseTargetCount, CanIncreaseDuration, CanBecomeAreaEffect, CanPersist) | SHOULD BE CAPABILITY -> added | Axes Spread, Stacking, TargetCount, Duration, Area, Persistence with `CrowdControlPolicies()` |

UNIT TESTED (`CrowdControlCannotBecomeMassPermanentStackingControl`): x100 duration, 40 targets, stacking,
persistence, Area coverage and `ADD_COMPONENT Area` are all reverted. Shortening the control still works. A
Spread Essence's requirement fails on the CC design.

Debuff runtime: **CALCULATED ONLY**, except the existing native auras of the spells themselves.

## 6. Auras as emitters

An Aura is a **persistent emitter**, not a synonym for Buff:

```
Emitter (EffectKind::Emitter)
  activation: Effect.Interval > 0 (periodic)  and/or  Effect.TriggerEvent (reactive)
  area:       Effect.Radius, Effect.MaxTargets, Effect.Coverage, Effect.ApplyTo
  lifetime:   Effect.Duration (0 = inactive), Effect.Charges / Effect.ConsumptionRule
  payload:    child effects with Effect.Parent = emitter key
              (Damage, Healing, Buff, Debuff, Resource, Dispel, Summon, Proc)
```

| Aura type | Representation |
| --- | --- |
| Damage aura every X s in radius | Emitter(Interval, Radius) -> Damage(Element) |
| Healing aura | Emitter(Interval, ApplyTo Allies) -> Healing |
| Buff aura (maintain) | Emitter(Interval, ApplyTo Allies) -> Buff(Duration slightly > Interval, RefreshBehavior Refresh) |
| Debuff aura | Emitter(Interval, ApplyTo Enemies) -> Debuff |
| Resource aura | Emitter(Interval) -> Resource |
| Retribution-style | Emitter(TriggerEvent Attacked / DamageTaken, SourceFilter Enemy) -> Damage (payload target = trigger source) |
| Lightning Shield | Emitter(TriggerEvent Attacked, Charges 3, Consumption OnTrigger) -> Damage(Nature) |
| Water Shield | Emitter(TriggerEvent Attacked, Charges) -> Resource (+ optional Healing) |
| Frost shield | Emitter(TriggerEvent Attacked) -> Debuff(Stat movement) on the attacker |
| Fire shield | Emitter(TriggerEvent DamageTaken) -> Damage(Fire) on the attacker |
| Melee aura 5 -> 10 yd | `Effect.Radius` modifier; potency trade-off via `Effect.Scaling` in the same Essence; `Effect.Radius` is on the Area axis |

**Zero semantics.** `Effect.Interval = 0` means "no periodic activation" (reactive only, class B). An active
interval respects the balance minimum `MinPeriodicTickInterval`. `Periodic.TickInterval = 0` on an active
periodic stays **technically invalid** (unchanged, existing test `ActivePeriodicWithZeroTickIsRejected`). New
tests: `EmitterTriggerPayloadComposition`, `ActiveEmitterIntervalRespectsBalanceMinimum`.

Emitter runtime: **CALCULATED ONLY.**

## 7. Triggers and proc control

**Audit result.** The existing Effect model already *is* Trigger + Condition + Payload:

| Part | Representation |
| --- | --- |
| trigger | `Effect.TriggerEvent`, source/target filters |
| chance | `Effect.TriggerChance`, now also `Effect.ProcsPerMinute` |
| internal cooldown | `Effect.InternalCooldown` |
| charges | `Effect.Charges` + `ConsumptionRule` |
| payload | `Effect.Spell`, or child effects via `Effect.Parent` |
| conditions | Modifier `Condition` list |

No second trigger engine is needed. Auras, imbues and buff-granted procs all use this one.

| Requested event | Representation |
| --- | --- |
| OnMeleeHit / OnRangedHit / OnSpellHit | NEW `MeleeHit`, `RangedHit`, `SpellHit` |
| OnAttack (you attack) / attacked | NEW `Attack`, `Attacked` |
| OnDamage | EXISTING `Hit` |
| OnPeriodicTick | EXISTING `Tick` (owning ability); NEW `Interval` (emitter's own clock) |
| OnCrit / OnHeal / OnDamageTaken / OnKill | EXISTING `Crit`, `Heal`, `DamageTaken`, `Kill` |
| OnSpellCast | EXISTING `Cast` |
| OnBlock / OnDodge / OnParry | NEW `Block`, `Dodge`, `Parry` |
| OnResourceSpent / Gained | NEW `ResourceSpent`, `ResourceGained` (runtime needs a power-change hook; to be audited) |
| OnAuraApplied / Removed | NEW `AuraApplied`, `AuraRemoved` |

**Proc control** (existing guard kept):

| Rule | Status |
| --- | --- |
| chance, internal cooldown, charges, target count | properties exist |
| PPM | NEW `Effect.ProcsPerMinute` + `EffectProcChance(effect, attackSpeedMs)` (PPM x speed / 60 s, WotLK rule) |
| proc from proc / self-retrigger / max depth | existing `CanTriggerProc` (NotFromProc, Loop, DepthExceeded) |
| per-origin eligibility | NEW `ExecutionOrigin` (OriginalCast, TriggeredCast, Echo, PeriodicTick, Proc, Emitter) in the proc ancestry, checked against `Effect.OriginMask` (`OriginNotAllowed`) |

UNIT TESTED: `OriginMaskAndRecursionGuard`.

The previous `ProcAncestry::IsEcho` flag was never read by `CanTriggerProc`. It is replaced by `Origin`.

**Runtime status: CALCULATED ONLY (guard functions only).**

- Engine-defined procs have no trigger bus yet.
- Echoes currently control procs through the native `TRIGGERED_DISALLOW_PROC_EVENTS` flag (section 11), not
  through `OriginMask`.
- Mapping the events to AzerothCore proc flags and hit masks (melee/ranged/spell classes, `PROC_EX_BLOCK`,
  dodge, parry) is the first task of the trigger runtime milestone.

## 8. Imbues and attached effects

`EffectKind::Imbue` + `Effect.Attachment`: Character, MainHand, OffHand, Ranged, AnyWeapon, Pet.

- An Imbue with `Attachment = None` is an `InvalidComposition` error.
- An Imbue reuses `TriggerEvent`, chance/PPM, internal cooldown, charges, origin mask and child payload effects.
  Poisons, weapon imbues, stones and character procs are the same kind with different attachment/trigger/payload
  data.
- **Character imbue** (`Attachment = Character`, e.g. `SpellHit`, 20%, child Arcane Damage) is independent of
  weapons by definition.
- **Weapon imbue** (MainHand / OffHand / Ranged / AnyWeapon) triggers only from hits made with that attack type.
- Future modifiers act on existing properties:
  - proc chance / PPM
  - payload `Effect.Scaling`
  - payload `Effect.Element`
  - payload `Effect.MaxTargets`
  - single target -> splash (`Effect.Coverage = Area` + `Effect.Radius` on the payload)
- **Requirements:** `RequireEffectProperty(EffectKind::Imbue, PropertyEquals, Effect.Attachment, MainHand)`.
  UNIT TESTED (`AttachmentIsValidatedAndRequirable`), which also covers the effect-scope requirement fix.
- **Runtime options to decide in the imbue milestone:**
  - Native temporary item enchantment: visible on the item, handled by the client, but tied to the fixed
    enchant/proc tables.
  - Server-side proc listener on the character, filtered by attack type: fully dynamic, but no item tooltip or
    glow without an addon.

Runtime: **CALCULATED ONLY.**

**Aura vs Imbue.** An Emitter is a persistent activity container attached to an entity. An Imbue is a trigger
attached to a character or equipment location. Both use the same trigger fields, conditions, payload children,
proc guard, requirements and modifiers.

## 9. Composition examples

All of these are representable today as data. Runtime: calculated only.

```
Summon(1)  -> Emitter(2, Parent 1, Interval 2 s, Radius 8) -> Damage(3, Parent 2)
Summon(1)  -> Emitter(2, Parent 1, Interval 3 s, ApplyTo Allies) -> Healing(3, Parent 2)
Buff(1)    -> Proc(2, Parent 1, TriggerEvent Hit, 10%) -> Debuff(3, Parent 2)
Imbue(1, Attachment AnyWeapon, TriggerEvent Crit) -> Proc(2, Parent 1) + ability Periodic component
Emitter(1, TriggerEvent DamageTaken, Charges 1) -> Summon(2, Parent 1, Archetype Guardian)
```

## 10. Direct-to-periodic conversion audit

The runtime was added in the previous milestone. Its status is RUNTIME CODED, never run in game.

| Concept | Status |
| --- | --- |
| conversion share | `Periodic.Conversion`: direct keeps `(1 - share)` of the hit |
| converted efficiency | **Was missing.** Now `Periodic.ConversionEfficiencyPct`: periodic total = hit x share x efficiency. Default 100% keeps the previous behavior. Example: 100 direct, 50%, 200% -> 50 direct + 100 periodic (UNIT TESTED as arithmetic; runtime RUNTIME CODED, REQUIRES IN-GAME TEST) |
| duration / interval | existing; interval hasted at application, floored by `MinPeriodicTickInterval` |
| stacking / max stacks / refresh | `ApplyPeriodic` (5 stack behaviors) + `Periodic.TickScalingPerStackPct` (per-stack tick efficiency, a stacking penalty independent from conversion efficiency) |
| spread / spread radius | `SpreadPeriodic` + `FindSpreadTargets` |

Findings:

1. **Immunity was not checked (fixed).** Converted ticks are not a native aura, so the core's aura immunity
   never ran for them. `DealTick` now skips immune targets (`IsImmunedToDamageOrSchool`) and sends the immune
   notice. RUNTIME CODED, SYNTAX CHECKED, REQUIRES IN-GAME TEST.
2. **No visible debuff.** There is no aura on the target, hence no icon, no stack count and no dispel. Ticks
   appear in the combat log as damage lines of the original spell id, sent as non-periodic spell damage.
   Section 12 has the fix design.
3. **Ticks are dealt as direct damage** (`SPELL_DIRECT_DAMAGE`). Talents and procs keyed to periodic damage do
   not see them. Decide in the periodic presentation milestone.
4. **Unused property.** `Periodic.ScalingPerStackPct` is not read anywhere; only `TickScalingPerStackPct` is.
   Either give it a distinct meaning (total damage per stack) or retire it. It was not changed blindly.
5. **Efficiency 0 edge case.** With efficiency 0 the executor refuses the conversion (`total <= 0`) and the
   direct hit stays whole. Document or change deliberately with the periodic milestone.

## 11. Echo runtime audit

STATICALLY AUDITED from `AbilityEchoScheduler.cpp`, `SecondarySpellExecutor.cpp` and `AbilitySpellScript.cpp`.

**Classification:** an Echo is a **triggered execution**, not a true recast. It is a new `Spell` of the same
ranked spell, cast with `TRIGGERED_FULL_MASK`, the caster as original caster and the same immutable cast
snapshot. This matches the intended semantics ("the spell happens again", without paying for it again).

| Aspect | Current behavior |
| --- | --- |
| resource cost | Not charged (triggered; the cost override is root-only) |
| GCD | Not triggered |
| cooldown | Not started; the engine cooldown override runs only for root, untriggered casts |
| cast time | None (triggered, delivered after `Echo.Delay`); the cast-time multiplier is root-only |
| OnCast procs | Not intended. With `Echo.CanProc = false` (default), `TRIGGERED_DISALLOW_PROC_EVENTS` suppresses all proc events. Whether AzerothCore fires cast-type procs for triggered casts when proc events are allowed: REQUIRES IN-GAME TEST |
| OnHit procs | Only when `Echo.CanProc = true` |
| crit | `Echo.CanCrit` (crit forced off otherwise) |
| periodic conversion | Only when `Echo.CanEchoPeriodic` |
| spell charges | Not applicable: `Casting.Charges` is not executed by the runtime at all (calculated only) |
| target invalidation / death | The target is revalidated when the echo fires (alive, legal, in range = spell max range + 5). Failure skips the echo silently; no retarget (only `SameTarget` runs) |
| caster gone | Echo events live on the caster's event list and die with the caster |
| recursion | None: the complete plan is made once at the root impact (`PlanEchoes`), echo impacts return before propagation or echo planning. Preserved |
| propagation | Echoes do not propagate (no Split/Shatter/Chain/Nova from an echo) |

## 12. Stacked periodic presentation

Target model: **one visible aura with an internal stack count** ("Burning Frostbolt x5"), not one aura per
application. The engine already keeps one `PeriodicInstance {Stacks, RemainingMs, TickAmount}` per (caster,
target, ability) except for `IndependentDuration`. The missing part is a **carrier aura**:

- a server-side spell id per periodic *presentation*, not per variant;
- applied to the target with `SetStackAmount(stacks)` and `SetDuration(remaining)`;
- ticks keep coming from the executor.

The client can only show an icon and name for a spell id it knows. That means either:

- reuse existing client spell ids as carriers (name/icon fixed), or
- ship a client patch with a small set of carrier spells.

Tracked in `ULDuar_CUSTOM_ID_NAMESPACE.md` terms: a few ids, never one per Essence combination. REQUIRES CLIENT
SUPPORT for custom names/icons.

Stacking efficiency (`TickScalingPerStackPct`) and conversion efficiency (`ConversionEfficiencyPct`) are
independent properties, as required.

## 13. Snapshot vs dynamic periodic state

Current behavior of converted ticks (STATICALLY AUDITED):

| Input | Current | Decision needed? |
| --- | --- | --- |
| haste (interval) | SNAPSHOT at application (`UNIT_MOD_CAST_SPEED`), only if `Periodic.CanHaste` | Keep snapshot (WotLK DoTs snapshot haste) |
| caster damage bonuses (spell power, % done) | SNAPSHOT: the total comes from the hit's done damage | Keep, but see the next row |
| target "damage taken" modifiers | SNAPSHOT (included in the hit's damage) | **Yes.** WotLK periodic auras apply taken-modifiers per tick |
| crit | DYNAMIC per tick (`SpellDoneCritChance`/`SpellTakenCritChance`), if `Periodic.CanCrit` | Keep |
| armor / block / resilience / absorb / resist | DYNAMIC per tick (`CalculateSpellDamageTaken`, `DealDamageMods`) | Keep |
| immunity | DYNAMIC per tick (fixed in this milestone) | Keep |
| element / school | SNAPSHOT (school at application) | Keep |
| potency (engine modifiers) | SNAPSHOT (resolved ability captured at application; refreshes adopt the new resolution) | Keep |
| conditional modifiers | Evaluated once, at the direct hit | **Yes**, per tick or at application |

`Periodic.SnapshotStats` exists as a property but the runtime ignores it. When the policy is decided, that
property becomes the switch.

## 14. Dynamic player-facing presentation

Pipeline:

```
Core -> Components/Effects -> Modifiers/Essences -> ResolvedAbility -> Presentation Resolver -> player tooltip
                                                                   \-> Lab inspector (technical, unchanged)
```

The player tooltip reads **only the resolved ability** (final values, components, effects, semantics). The
modifier history (`Traces`, `Contributions`, `Clamps`) is Lab-only. Three Essences giving +30%, -10% and x1.2
range show as a single "42 yd range".

Semantic sufficiency audit (does the resolved model carry what the templates need?):

| Template | Data available | Gap |
| --- | --- | --- |
| Direct damage "Hurls {projectile}... {damage} {element}" | `Primary.Damage` (relative %), `Primary.Element`, `Delivery.Kind`, projectile component | Absolute numbers need the runtime (spell power); the tooltip shows `%` of native or asks the server |
| Slow "{amount}% for {duration}" | `Effect.Stat/Value/Duration` | Typed stat enum (section 4) |
| Shatter "{targetCount} additional enemies within {range} yd" | `Projectile.Targets`, `AcquisitionRange`, `Origin` | none |
| Summon "{count} {summonName} for {duration}" | `Summon.Count`, `Effect.Duration`, `ResolvedEffect::Summon.IndividualMultiplier` | summon name = client spell/creature name (addon) |
| Quantity "Each deals 75%..." | `IndividualMultiplier` | none |
| Buff "Increases {effect} by {amount} for {duration}", party | `Effect.*` + `Effect.Coverage` | Typed stat enum |
| Aura "Every {interval}, affects {targets} within {radius} yd" | `Effect.Interval/MaxTargets/Radius/ApplyTo` + children | none |
| Cost / range / cast line | `Resource.Cost`, `Range.Max`, `Casting.CastTime` (+ `Instant` semantic) | Percentage-cost spells store % of base mana: convert with the player's base mana |

The text/localization generator is future work. The **model** is sufficient apart from the typed stat enum.

## 15. Semantic display names

`Presentation.h`: `DetectTransformations(core, resolved)` lists qualitative changes with a severity, and
`DominantTransformation(...)` returns **at most one**, the most severe, if it reaches
`MajorTransformationSeverity` (50). Names are never concatenated. IMPLEMENTED, UNIT TESTED.

| Transformation | Severity | Future name example |
| --- | --- | --- |
| DirectToPeriodic (conversion >= 50%) | 80 | Lingering X |
| SummonQuantity (>= +50% of base) | 75 | Swarming X |
| CoverageExpansion | 75 | (party/raid variant) |
| DeliveryChange | 70 | |
| Propagation (more projectile targets) | 65 | Shattering X / Chaining X |
| AreaConversion | 65 | |
| InstantCast | 60 | Fast X |
| NoCooldown | 55 | Quick X |
| Echo | 55 | Echoing X |
| DirectToPeriodic (< 50%), SummonQuantity (small), ElementChange | 40-45 | tooltip only |

The vocabulary (the actual words, localization, element-specific names) is **not designed yet**.
`AbilityIdentity::DisplayName` stays the base name until a `SemanticNameResolver` maps a
`TransformationKind` to text. The severities are data in one function and easy to tune.

## 16. Stable variant identity

`AbilityIdentity` (IMPLEMENTED, UNIT TESTED):

| Field | Source | Stability |
| --- | --- | --- |
| `AbilityId` | engine ability id | never changes |
| `BaseSpellId` | `Core.Revision` (ranked spell id, e.g. 116) | never changes with modifiers |
| `BaseName` | Core name | never changes |
| `VariantHash` | FNV-1a over the resolved components, capabilities, values, effects and conditional modifiers | equal results give equal hashes, **independent of modifier/socket order** (conditional modifiers are hashed commutatively) |
| `IsBaseVariant` | hash equals the unmodified resolution | |
| `DisplayName` | base name (future: dominant transformation) | presentation only |

No DBC spell is created per variant. The hash is process-independent (deterministic), but it changes when the
Core revision or the registry changes. Treat it as a cache/correlation key, not a persistent id.

## 17. Combat log, Details, death recap

| Need | Classification |
| --- | --- |
| Correct attribution of damage to the caster and the base spell | SERVER COMPLETE today: every packet uses the ranked spell id |
| Own client showing a variant name in the tooltip | ADDON POSSIBILITY: the UlduarAbilities addon already post-hooks spell tooltips (`AbilityTooltip.lua`) |
| Other players seeing "Fast Frostbolt" | ADDON POSSIBILITY. The server can broadcast `{caster GUID, base spell id, variant hash, dominant TransformationKind}` over the addon channel to party/raid, and an addon maps it to a name |
| Combat log lines / Details / death recap showing variant names | CLIENT MODIFICATION REQUIRED for the native log (the client resolves names from its own Spell.dbc). Details integration: UNKNOWN / REQUIRES TEST (depends on whether Details can relabel a spell per source) |
| Distinguishing converted ticks from the direct hit in the log | Needs the carrier aura (section 12); today both use the same spell id |

Nothing in the combat log is replaced in this milestone.

## 18. Client-side limitations

| Feature | Server | Client |
| --- | --- | --- |
| Longer range | SERVER COMPLETE (range delta in `CheckRange`) | CLIENT SUPPORT REQUIRED beyond the client's DBC range for targeted casts |
| Cast while moving (non-channeled) | SERVER COMPLETE (RUNTIME CODED) | CLIENT SUPPORT REQUIRED (the client may stop its own cast bar) |
| Moving channels | not implemented | CLIENT SUPPORT REQUIRED |
| Projectile speed / size | calculated only | CLIENT SUPPORT REQUIRED for speed visuals; size needs visual kits |
| Dynamic tooltips | model ready | ADDON (own client) |
| Dynamic spell names | model ready | ADDON for UI, CLIENT SUPPORT REQUIRED for combat log/spellbook |
| Stacked converted DoT icon | design ready | CLIENT SUPPORT REQUIRED for custom icon/name (or reuse existing spell ids) |
| Summon visual/element transformations | not in scope | CLIENT SUPPORT REQUIRED for new models/effects |
| Party/raid coverage of a self buff | calculated only | Server-side aura application works on any unit; no client change expected (REQUIRES IN-GAME TEST) |

No server hacks were added to fake client behavior.

## 19. Property registry gap analysis

The 162 first-pass properties against the new families, per group:

| Group (count) | Summon | Buff | Debuff | Aura/Emitter | Trigger | Imbue | Presentation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Primary (18) | Threat via Primary.* (ability scope) | - | - | - | ProcChance | - | Damage/Healing/Element/Range read directly |
| Casting (14) | cast time/cooldown of the summon spell | same | same | - | - | - | Cast line, "Instant", cooldown |
| Resource (4) | cost | cost | cost | - | Gain (Resource payload) | - | Cost line |
| Targeting (11) | - | Relation | Relation | AcquisitionRadius for pulses | Source/target filters are on Effect | - | - |
| Delivery (1) | - | - | - | - | - | - | projectile/beam wording |
| Projectile (25) | - | - | - | - | - | splash via Coverage instead | Shatter/Chain templates |
| Area (17) | - | - | area debuffs | persistent area overlaps Emitter; keep Area for ground AoE (Blizzard), Emitter for entity-attached | - | - | radius wording |
| Periodic (21) | - | HoT | DoT, spread | - | Tick event | DoT payload | stacks |
| Echo (16) | - | - | - | - | origin Echo | - | "Echoing" |
| Displacement (8) | - | - | knockback payloads | - | - | - | - |
| Effect (27) | Duration = lifetime | all buff fields | all debuff fields | charges, trigger, radius | trigger, chance, ICD, charges, proc-from-proc, depth | trigger fields | durations/stacks |

New properties (17), each justified by a family that could not be expressed otherwise:

| Property | Scope | Family | Classification |
| --- | --- | --- | --- |
| `Periodic.ConversionEfficiencyPct` | ability | DoT conversion | MISSING PROPERTY |
| `Effect.Parent` | effect | composition (Aura, Summon, Imbue) | MISSING (structural link) |
| `Effect.Element` | effect | summon attacks, emitter/imbue payloads | EXISTING concept generalized to effects |
| `Effect.Coverage` | effect | Buff/Debuff/Aura | MISSING PROPERTY |
| `Effect.MaxTargets` | effect | Buff/Debuff/Aura/summon attacks | MISSING PROPERTY |
| `Effect.Interval` | effect | Emitter | MISSING PROPERTY |
| `Effect.ProcsPerMinute` | effect | Imbue/Trigger | MISSING PROPERTY |
| `Effect.OriginMask` | effect | Trigger | MISSING PROPERTY (origin eligibility) |
| `Effect.Attachment` | effect | Imbue | MISSING PROPERTY |
| `Effect.Control` | effect | CC | MISSING PROPERTY (classification that drives capabilities) |
| `Summon.Archetype` | effect | Summon | MISSING PROPERTY |
| `Summon.Count` | effect | Summon | MISSING PROPERTY |
| `Summon.QuantityPenaltyPct` | effect | Summon | MISSING PROPERTY (data-driven balance curve) |
| `Summon.EntityHealthPct` | effect | Summon | MISSING PROPERTY |
| `Summon.EntityMovementPct` | effect | Summon | MISSING PROPERTY |
| `Summon.AttackScalingPct` | effect | Summon | MISSING PROPERTY |
| `Summon.AttackSpeedPct` | effect | Summon | MISSING PROPERTY |

Deliberately **not** added:

| Concept | Why | Classification |
| --- | --- | --- |
| CanModifyX flags | They are capabilities, not properties | SHOULD BE CAPABILITY |
| controllable / follows caster / stationary | Derived from `Summon.Archetype` | SHOULD BE CAPABILITY / derived |
| entity armor, resistances, owner stat inheritance | No runtime hook yet | MISSING, deferred |
| attack/aggro range, cast speed, spawn radius/pattern | No design yet needs them | NOT REQUIRED |
| dispel resistance, persist through combat end | Deferred to the buff runtime | MISSING, deferred |
| application/removal conditions | Existing conditions | SHOULD BE CONDITION |
| entity visual theme, display names | | PRESENTATION ONLY |

Needs generalization, not implemented:

- `Effect.Stat` should become a typed stat enum.
- Spreading for non-periodic debuffs.
- `Periodic.ScalingPerStackPct` needs a meaning or removal.
- `Periodic.SnapshotStats` is not honored.

## 20. Component / Effect gap analysis

| Concept | Verdict |
| --- | --- |
| Summon | EFFECT (`EffectKind::Summon` + `Summon.*`), not a component. It can then be a payload of a trigger or emitter |
| Buff / Debuff | EFFECT kinds |
| AuraEmitter | EFFECT (`Emitter`) with child effects, not a component. Ground AoE keeps the existing `Area` component (`PersistentDuration`); an entity-attached pulse is an Emitter |
| Trigger | Not a separate object: effect-scope trigger fields + conditions (no second engine) |
| Imbue | EFFECT (`Imbue`) + `Effect.Attachment` |
| Resource / reactive / periodic / area payloads | EFFECT children: `Resource`, `Damage`, `Healing`, `Buff`, `Debuff`, `Dispel`, `Summon`, `Proc`; activation from the parent emitter/trigger |
| Attached effects | Imbue (character/weapon/pet) |
| Reactive Fire Shield | `Emitter(TriggerEvent DamageTaken) -> Damage(Element Fire)`. No FireShield component |

No new Component was needed. The existing optional components remain delivery/execution shapes (Projectile,
Beam, Area, Periodic, Echo, Displacement). The new families are effects.

## 21. Requirements / compatibility gap analysis

ALL / ANY / NONE is sufficient once it can see capabilities and effect-scope values:

| Essence | Requirement (all UNIT TESTED shapes) |
| --- | --- |
| Quantity | `ALL(HasEffectKind Summon, CapabilityAllows Quantity)` |
| Party coverage | `ALL(HasEffectKind Buff, CapabilityAllows Coverage)` |
| Persistent | `ALL(HasEffectKind Buff, CapabilityAllows Persistence)` |
| Weapon proc | `EffectProperty(Imbue, Effect.Attachment == MainHand)` (or ANY over the weapon slots) |
| Spread | `ALL(ANY(HasComponent Periodic, HasEffectKind Debuff), CapabilityAllows Spread)` |

Remaining gaps, which are not blocking:

- Requirements see the resolved values, not the Core's. A "solitary summon only" Essence would need a
  base-value requirement (`PropertyTrace::Base` has the data).
- There is no "effect count" requirement.
- Axis policies are ability-wide. Per-effect policies may be needed when one ability mixes a CC effect with a
  modifiable damage effect: the CC policy currently restricts the damage effect's duration too.

## 22. Recommended implementation order

1. **Local validation of the current runtime** ([checklist](ULDuar_LOCAL_VALIDATION_CHECKLIST.md)), including
   the two runtime changes of this milestone (conversion efficiency, tick immunity) and the CC capability
   derivation.
2. **Periodic presentation and policy:** carrier aura with stack count, periodic damage type, snapshot policy
   (target taken-modifiers, conditional modifiers), `Periodic.SnapshotStats`, `ScalingPerStackPct`.
3. **Typed stat enum** for `Effect.Stat` (unblocks buff/debuff runtime and tooltips).
4. **Buff/Debuff runtime:** application, coverage (party/raid/area), persistence, dispel.
5. **Trigger bus + Emitter runtime:** map TriggerEvents to proc flags/hit masks and power/aura hooks; interval
   emitters; charges; `OriginMask` wired into echo/periodic/proc executions.
6. **Summon runtime:** count mapping, individual multiplier, entity/attack scaling, archetypes, totem slots,
   stat inheritance hook.
7. **Imbue runtime:** decide temporary enchantment vs server listener.
8. **Presentation:** tooltip generator (addon), SemanticNameResolver vocabulary, party/raid variant broadcast.
9. Production Essence system, then the production Spell Forge.
