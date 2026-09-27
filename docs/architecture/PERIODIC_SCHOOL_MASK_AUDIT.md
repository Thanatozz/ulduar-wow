# Periodic school mask audit

Date: 2026-09-27. Core: AzerothCore (this fork). Scope: native `SPELL_AURA_PERIODIC_DAMAGE` ticks of Ulduar
generic carriers, whose effective school belongs to the periodic instance, not to the carrier's shared
`SpellInfo`. Related: [PERIODIC_TARGET_ARCHITECTURE.md](PERIODIC_TARGET_ARCHITECTURE.md),
[PERIODIC_DAMAGE_PIPELINE_AUDIT.md](PERIODIC_DAMAGE_PIPELINE_AUDIT.md).

## 1. Core change (PATCHED)

- `Aura::SetSchoolMaskOverride`, `GetSchoolMaskOverride` and `GetEffectiveSchoolMask` (`SpellAuras.h/.cpp`)
  add a per-aura override. `NONE` (the default for every native aura) returns `SpellInfo::GetSchoolMask()`,
  so native behavior is unchanged.
- The module sets the override on each generic carrier aura to the instance's `SchoolMask`, right after
  creation.
- Shared `SpellInfo` is never mutated.

## 2. Consumers

Status legend:
- **PATCHED:** now reads the effective school.
- **NATIVE ALREADY OK:** needs no change.
- **SUPPORTED:** covered by module code.
- **UNRESOLVED:** open.

| Path | Code | Status |
| --- | --- | --- |
| Tick immunity | `HandlePeriodicDamageAurasTick`: `IsImmunedToDamage(caster, spellInfo, schoolMask)` | PATCHED |
| Taken modifiers (% and flat) | `SpellDamageBonusTaken(…, DOT, stack, schoolMask)` | PATCHED |
| Done modifiers | `SpellDamageBonusDone(…, schoolMask)`: only for DynamicObject auras. Carriers are unit auras; their amount is set by the module (done bonuses already in the pre-taken pool) | PATCHED (dynobj path) / SUPPORTED |
| Armor | `IsDamageReducedByArmor(schoolMask, …)`: armor only if the Physical bit is set | PATCHED |
| Crit bonus | `SpellCriticalDamageBonus(…, schoolMask)`: crit-damage mods by misc mask | PATCHED |
| Crit chance | `CalcPeriodicCritChance`: done and taken crit chance use the effective school. The module then sets the chance explicitly with `SetCritChance` (payload spell chance) | PATCHED / SUPPORTED |
| AoE damage reduction | `CalculateAOEDamageReduction(…, schoolMask, …)`: only for area auras (not carriers) | PATCHED |
| Resistance, penetration, absorb | `DamageInfo(…, schoolMask, DOT)` → `CalcAbsorbResist` (`GetEffectiveResistChance`, `MOD_TARGET_RESISTANCE`, absorb masks) | PATCHED |
| Resilience | `ApplyResilience(…, CR_CRIT_TAKEN_SPELL)`: school independent | NATIVE ALREADY OK |
| Damage and threat | `DealDamage(…, DOT, schoolMask, …)` | PATCHED |
| Periodic combat log | `SendPeriodicAuraLog`: `aura->GetBase()->GetEffectiveSchoolMask()` | PATCHED |
| Procs (`ProcEventInfo`) | `ProcSkillsAndAuras(…, &dmgInfo)`: the event school is the DamageInfo school above | PATCHED (via DamageInfo) |
| School-filtered procs | `SpellMgr` 900: `eventInfo.GetSchoolMask() & procEntry.SchoolMask` (overlap) | NATIVE ALREADY OK |
| Apply-time immunity | `Unit::AddAura` → `IsImmunedToSpell(carrier SpellInfo)`: the generic carrier row uses SchoolMask 127, refused only by full immunity. The module pre-checks `IsImmunedToSpell(carrier, mask, caster, instanceSchool)` | SUPPORTED |
| Immunity-driven aura removal | `HandleAuraModSchoolImmunity` with `SPELL_ATTR1_IMMUNITY_PURGES_EFFECT` removes harmful auras whose school **overlaps** the immunity. With SpellInfo school 127, any purging immunity would have stripped every carrier; the loop now uses `GetEffectiveSchoolMask()` (e.g. a fire-only purge removes a Fire or Frost\|Fire carrier, not a Frost one) | PATCHED |
| Aura scripts on the carrier | `aura_ulduar_periodic_carrier` reads no school | NATIVE ALREADY OK |
| Crit multiplier by DmgClass | `SpellCriticalDamageBonus` uses the carrier's DmgClass (MAGIC for the pool), so physical instances get the spell crit multiplier, not melee ×2 (Rend-like) | UNRESOLVED (policy) |
| Other periodic types (heal, leech, funnel) | still read SpellInfo; not used by damage carriers | NATIVE ALREADY OK (out of scope) |

## 3. Multi-school behavior: current AzerothCore vs possible Ulduar policy

Dual element is **one** event: one amount, one crit, one mitigation, one pool, a multi-bit
`SpellSchoolMask`. No element shares. The override lets the native tick see the full mask. The semantics
below are **unchanged** stock AzerothCore, verified from source; nothing opinionated was implemented.

| Mechanic | Current AzerothCore (mask Frost\|Fire) | Source | Possible Ulduar policy (undecided) |
| --- | --- | --- | --- |
| Crit chance | **first school bit only** (`GetFirstSchoolInMask`: Fire before Frost) | `SpellDoneCritChance` (`PLAYER_SPELL_CRIT_PERCENTAGE1 + first school`) | max or average of the schools' crit chances |
| Crit bonus | crit-damage mods whose misc mask overlaps any bit | `SpellCriticalDamageBonus` | keep |
| Immunity | immune only if the immunities cover **all** bits | `IsImmunedToDamage` / `IsImmunedToSchool` / `HasSchoolImmunityForMask` | keep (it matches "combined school") |
| Resistance | the **lowest** resistance among the bits | `Unit::GetResistance(SpellSchoolMask)` | keep |
| Penetration | sum of `MOD_TARGET_RESISTANCE` auras overlapping any bit | `GetEffectiveResistChance` | keep |
| Absorb | any absorb aura whose mask overlaps any bit | `CalcAbsorbResist` | keep |
| % done | **product** of every overlapping `MOD_DAMAGE_PERCENT_DONE` (Fire +10% and Frost +10% → ×1.21) | `SpellPctDamageModsDone` | max per aura family, or keep |
| Flat spell power | base spell power + every overlapping per-school `MOD_DAMAGE_DONE` | `SpellBaseDamageBonusDone` | max per school, or keep |
| % taken | product of overlapping `MOD_DAMAGE_PERCENT_TAKEN` | `SpellDamageBonusTaken` | keep, or max |
| Procs | school filters match on overlap | `SpellMgr::CanSpellTriggerProcOnEvent` (line 900) | keep |
| Combat log | the full mask is sent; the stock client colours by its own rule | `SendPeriodicAuraLog`, spell logs | client patch presentation |

**Decisions required (maintainer):** crit chance source, and done/taken stacking across schools. Until then
the stock behavior applies to multi-school instances, identical to multi-school direct hits
(`Spell::SetSpellSchoolMask`).

## 4. What still reads carrier SpellInfo on purpose

Attributes (`SPELL_ATTR*`), DmgClass, effect index and aura type still come from the shared carrier row;
they are technical, not gameplay identity. The DmgClass crit multiplier is the one open policy item above.
