# Dispel type override audit

Date: 2026-09-27. Core change: `Aura::SetDispelTypeOverride` / `ClearDispelTypeOverride` /
`HasDispelTypeOverride` / `GetEffectiveDispelType` / `GetEffectiveDispelMask` (`SpellAuras.h/.cpp`), same
pattern as `SetSchoolMaskOverride`. Without an override every consumer sees the SpellInfo dispel type, so
native auras behave exactly as before. The generic periodic carriers (SpellInfo `Dispel` = 0) receive the
payload spell's dispel type per instance (`PeriodicCarrier::Start`); no pool is split by dispel type and no
ability id is hard-coded.

Related core change for the same consumers: `Aura::SetDispelGroupId` (grouped dispel, §3) and
`Unit::IsImmunedToDispelType` (dispel-type immunity alone).

## 1. Consumers of SpellInfo dispel metadata

Classification: **PATCHED** (reads the effective value), **NATIVE OK** (correct without change),
**NOT APPLICABLE** (never sees an overridden aura instance), **UNRESOLVED** (kept native on purpose; a
gameplay decision is pending).

| Consumer | Where | Reads | Class | Notes |
| --- | --- | --- | --- | --- |
| Dispellable aura list | `Unit::GetDispellableAuraList` (`Unit.cpp`) | `GetDispelMask()`, `Dispel == DISPEL_MAGIC` (friend/foe rule) | **PATCHED** | effective mask and type; feeds every consumer below |
| Dispel effect | `Spell::EffectDispel` (`SpellEffects.cpp`) | via the list | **PATCHED** (indirect) + grouped slot (§3) | resistance roll per attempt unchanged for native auras |
| "Nothing to dispel" cast check | `Spell::CheckCast` (`Spell.cpp`, dispel effects) | via the list | **PATCHED** (indirect) | a carrier with a Magic override makes Dispel Magic castable |
| Spell steal | `Spell::EffectStealBeneficialBuff` | `GetDispelMask()` | **PATCHED** | carriers are negative auras, so still never stolen (`!IsPositive()` gate unchanged) |
| Cloak of Shadows style removal | `SpellEffects.cpp` (spell 35729 branch) | `spell->GetDispelMask()` | **PATCHED** | carriers were already removed by `DmgClass == MAGIC`; now also consistent by dispel mask |
| Cast while controlled (immunity-granting spells) | `Spell::CheckCast` loop over caster auras | `GetDispelMask()`, `GetSchoolMask()` | **PATCHED** (dispel and school) | only matters for CC auras; carriers are not CC |
| Dispel immunity purge | `SpellInfo::ApplyAllSpellImmunitiesTo` (`IMMUNITY_PURGES_EFFECT`) | `Dispel == dispelImmunity` | **PATCHED** | effective type |
| School immunity purge (same function) | `SpellInfo::ApplyAllSpellImmunitiesTo` | `auraSpellInfo->GetSchoolMask()` | **PATCHED** | school-mask consumer missed by the previous audit: a 127 carrier overlapped every purge |
| Aura target validation | `Aura::UpdateTargetMap` | `IsImmunedToSpell(spellInfo, caster)` | **PATCHED** | effective school + `IsImmunedToDispelType(effective)` when overridden (also a missed school consumer) |
| Apply-time immunity | `Unit::IsImmunedToSpell` (`spellInfo->Dispel`) | SpellInfo | **NOT APPLICABLE** for carriers | `PeriodicCarrier::Start` checks `IsImmunedToDispelType(instance type)` itself |
| Debuff resistance on spell hit | `Unit::MagicSpellHitResult`, `Spell::DoSpellHitOnUnit` (`SPELL_AURA_MOD_DEBUFF_RESISTANCE`) | `m_spellInfo->Dispel` of the cast | **NOT APPLICABLE** | carriers are added with `AddAura`, not cast |
| Duration by dispel type | `Unit::ModSpellDuration` (`SPELL_AURA_MOD_AURA_DURATION_BY_DISPEL*`) | SpellInfo | **UNRESOLVED** | carrier duration is the engine's; "poison duration -x%" talents do not shorten converted periodics. Decision: apply to the engine duration or not |
| Diseases by caster | `Unit::GetDiseasesByCaster` (Obliterate, Scourge Strike, ...) | `Dispel == DISPEL_DISEASE` | **UNRESOLVED** (kept native) | counting (and Obliterate consuming) converted disease periodics is a class-balance decision |
| Poison checks | `SpellEffects.cpp` deadly-poison scan, `spell_rogue.cpp` Envenom | `Dispel == DISPEL_POISON` | **UNRESOLVED** (kept native) | same: a converted poison periodic is not a rogue poison |
| Dispel immunity aura vs cast spell | `SpellInfo::CanSpellCastOverrideAuraEffect`, `CanSpellProvideImmunityAgainstAura` | SpellInfo of a spell being cast | **NOT APPLICABLE** | about new casts, never an existing aura instance |
| Creature template immunities | `Creature` immunities (`DispelType` bitset) | feed `IMMUNITY_DISPEL` | **NATIVE OK** | reached through `IsImmunedToDispelType` |
| Arena spectator | `ArenaSpectator::SendCommand_Aura` callers | `Dispel` | **PATCHED** | presentation only |
| Dispel scripts | `OnDispel` / `AfterDispel` (`RemoveAurasDueToSpellByDispel`) | aura instance | **NATIVE OK** | unchanged for native auras; grouped carriers never go through it (§3) |
| `.spellinfo` command | `cs_spellinfo.cpp` | SpellInfo | **NOT APPLICABLE** | shows the row, not an instance |
| `SpellInfo::GetDispelMask(DispelType)` | helper | - | **NATIVE OK** | used by the override |

`RemoveAurasWithDispelType` does not exist in this AzerothCore tree; dispel-type removal goes through the list
above or the immunity purge.

## 2. Status

RUNTIME CODED, syntax-checked with `-Wall -Wextra`. REQUIRES LOCAL BUILD / REQUIRES IN-GAME TEST. No native
aura changes behavior (no override set).

## 3. Grouped dispel

- `Spell::EffectDispel` removes auras with a non-zero `GetDispelGroupId()` from the native random list. All
  eligible groups together form **one** extra candidate slot. When the random pick selects that slot,
  `ScriptMgr::OnGroupedDispel` (new `AllSpellScript` hook) resolves it: the resolving script selects the
  group and members, rolls the dispel chance once, removes the stacks itself and fills
  `GroupedDispelResult` for the combat log.
- Native auras keep the native random selection, charges, resistance and `OnDispel`/`AfterDispel`.
- A resisted grouped attempt is logged in `SMSG_DISPEL_FAILED` (spell id of the displayed member) and uses a
  dispel, like a native failure. A group with 100% dispel resistance is dropped without using a dispel
  (2.4.3 rule).
- Grouped carriers never pass through `RemoveAurasDueToSpellByDispel`, so a group of N carriers cannot run
  N reactions. The module's resolver has one reaction point per group
  ([DISPEL_PRIORITY_AUDIT.md](DISPEL_PRIORITY_AUDIT.md) §4).
