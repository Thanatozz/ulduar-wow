# Primary output and output presentation

Code: `mod-ulduar-abilities`:
- `src/engine/PropertyRegistry.*` (property + aliases)
- `src/AbilityEngineBridge.cpp` (Core and runtime mapping)
- `src/AbilitySpellScript.cpp` (per-hit application)
- `src/AbilityAddonProtocol.cpp` (`OUT` record)
- `src/engine/Presentation.cpp` (secondary lines)

Addon: `client/Interface/AddOns/UlduarAbilities/AbilityTooltip.lua`.

Status labels follow [ULDuar_ABILITY_RUNTIME.md](ULDuar_ABILITY_RUNTIME.md#support-matrix). Nothing here was run in
game from the cloud environment.

## Primary.Scaling

`Primary.Scaling` is the primary numeric output of the ability, in percent of the native value (100 = native).

- **Damage abilities:** it scales damage.
- **Healing abilities:** it scales healing.
- **Abilities that do either** (Death Coil): it scales whichever the hit produces.

There is one property, not separate damage and healing scalings.

| Aspect | Value |
| --- | --- |
| Canonical name | `Primary.Scaling` |
| Deprecated aliases | `Primary.Damage`, `Primary.Healing` (resolve to `Primary.Scaling`; the Lab prints a one-line notice) |
| Type / unit | number, percent; zero = NO PAYLOAD (the hit executes but deals nothing) |
| Scope | ability (Primary component) |
| Resolver | normal arithmetic stages; Potency capability axis; conditional modifiers allowed (per hit) |
| Runtime consumer | bridge: `PrimaryDamageMultiplier` and `PrimaryHealingMultiplier` both x (resolved / Core). Spell script `OnHit`: applied once to every fresh native amount (root, secondary and echo hits) |
| Composition with legacy build | multiplied with the legacy Damage rank (it used to overwrite it) |
| Forge / Lab | editable as `Primary.Scaling` |
| Tooltip | never shown as a property; the tooltip shows the resulting value |
| Support | RUNTIME CODED (damage and healing); REQUIRES IN-GAME TEST |

`Primary.Output` (Damage, Healing, DamageOrHealing, None) is a **structural**, non-editable property.
- The bridge sets it from the native spell.
- Requirements use it: `RequireDamage()` / `RequireHealing()` check the output kind and `Primary.Scaling > 0`.
- Before the rename, those requirements read two separate properties.

Persistence: modifiers store the property enum id, never its name. Lab presets saved at runtime are in memory
only. Old command text keeps working through the aliases, so no data migration is needed.

## Secondary scaling

`Projectile.Scaling`, `Area.Scaling` and `Echo.Scaling` stay separate properties: they are different component
scopes and may diverge. Presentation collapses them (`SecondaryOutputLines`, mirrored in Lua):

```
Secondary Damage: 60%          <- common value of the active components
Area Damage: -30%              <- only components that differ, as a signed difference
```

Healing abilities say "Healing". Inactive components are omitted.

## Three information levels

| Level | Shows | Source |
| --- | --- | --- |
| Normal tooltip | What the ability does, WoW wording: `Deals 700 Frost damage and an additional 600 Frost damage over 6 sec.` / `Heals the target for 1,240.` | `OUT` record |
| Advanced (hold Shift) | Resolved results: Direct / Periodic amount, duration, tick interval, secondary lines | `OUT` record |
| Forge / Ability Lab | Editable mechanics, component scalings, conversion and efficiency, requirements, the full trace | `.ua lab inspect`, Lab window |

Formulas, property names, conversion percentages and tick counts never appear in the normal tooltip.

**`OUT` record.** It is additive, and older addons ignore it. Format:
`id | healing | direct | periodic | durationMs | intervalMs | ticks | projectile% | area% | echo% | element`

- **Nominal values:** native base points (the basis of the 3.3.5 client's own tooltip, before spell power) x
  the resolved primary scaling. The conversion split uses the same `PlanConvertedPeriodic` as the runtime,
  with the unhasted interval.
- **Channel controllers** (Arcane Missiles) carry their output in a payload spell, so they report
  percentages only. The normal damage line is omitted for them (PARTIAL).
- **Inside the Ulduar window,** tooltips show the committed server output, not the unconfirmed draft.
- **Status:** RUNTIME CODED, Lua 5.1 parsed. Tooltip rendering and the Shift refresh (`MODIFIER_STATE_CHANGED`
  re-runs the hovered frame's `OnEnter`) REQUIRE IN-GAME TEST.

## Tooltip accuracy: PARTIAL

The absolute values in `OUT` are **PARTIAL**. They are native base points (+ die average), without level
scaling, spell power or caster done modifiers, × `Primary.Scaling`, then split by the conversion plan.
Percentages (secondary, echo) and timing (duration, interval, ticks) are exact resolved values. The Normal
and Shift levels stay as they are; only the numbers they print are partial.

**Target.** Caster-resolved output: caster stats + coefficient + caster done modifiers + `Primary.Scaling`,
then echo / secondary / periodic composition. Target mitigation and target taken modifiers are excluded,
and so are per-hit conditional modifiers, which depend on the target.

### Core APIs audited (none mutate `SpellInfo`)

| API | Target-free? | Use for the tooltip |
| --- | --- | --- |
| `Unit::SpellDamageBonusDone` / `SpellPctDamageModsDone` | **No.** They return the input unchanged when `victim` is null, and read the victim for creature-type flat/pct bonuses and victim-state talents. Passing the caster as victim would pick up the wrong conditional bonuses | not directly |
| `Unit::SpellHealingBonusDone` / `SpellPctHealingModsDone` | **No**, and unsafe with null: no null guard, and the victim is dereferenced (victim health / aura talents) | never with a null victim |
| `Unit::SpellBaseDamageBonusDone(schoolMask)` / `SpellBaseHealingBonusDone(schoolMask)` | **Yes**: the caster's spell power for the school | spell power term |
| `sSpellMgr->GetSpellBonusData(id)` (`direct_damage`, `dot_damage`, `ap_bonus`) and `Unit::CalculateDefaultCoefficient` | **Yes** | coefficient |
| `Unit::CalculateLevelPenalty(spellInfo)` | **Yes** | low-rank penalty |
| `SpellEffectInfo::CalcValue(caster)` | caster-only, but rolls the die | base with level scaling (use `BasePoints` + level fields + die average instead) |
| `Player::ApplySpellMod(id, SPELLMOD_DAMAGE / SPELLMOD_BONUS_MULTIPLIER, value)` | **Yes**: talents that modify this spell | caster spell mods |
| `GetTotalAuraMultiplierByMiscMask(SPELL_AURA_MOD_DAMAGE_PERCENT_DONE, school)` | **Yes** | generic % done |

**Engine model (module `9a50156`, `OutputEstimate.*`, tests `UlduarOutputEstimate.*`)**; no `OUT2` record or
addon change yet (held until checklist Stage J0 passes). The estimate mirrors the target-free terms of
`SpellDamageBonusDone` / `SpellHealingBonusDone`: level scaling (caster level clamped to [BaseLevel, MaxLevel],
minus max(BaseLevel, SpellLevel)), die average, spell power × coefficient (effect `BonusMultiplier`, overridden by
`spell_bonus_data` direct) × level penalty, generic done multiplier, caster spell mods, then `Primary.Scaling`;
AP bonuses and victim-dependent terms are excluded. `SchoolMaskLabel` names combined schools (Frostfire,
Shadowflame, Spellfire…). The planned `OUT2` record keeps `OUT` unchanged and adds echo chance and scaling as
separate fields (never a guaranteed amount) and the instance school mask.

Original plan: an `OUT` v2 computes, server-side and per player:

```
base = BasePoints + die average (+ level scaling)
base = base + SpellBaseDamageBonusDone(school) x coefficient x level penalty
base = ApplySpellMod(SPELLMOD_DAMAGE) x generic % done
base = base x Primary.Scaling
```

It then feeds the existing conversion plan. It must be refreshed when stats change (throttled on
`UNIT_STAT` / aura changes), and marked as an estimate: it does not include victim-dependent bonuses. Until
then the addon keeps the PARTIAL numbers.
