# Periodic damage class audit

Date: 2026-09-27. Question: the generic carriers have `DmgClass` MAGIC (`DefenseType` 1 in pending SQL 007).
What goes wrong for Physical or melee/ranged converted periodics, and does Ulduar need a per-instance
outcome class?

## 1. Four separate concepts

| Concept | Meaning | Carrier source |
| --- | --- | --- |
| SchoolMask | what the damage is (Physical, Frost, Frost\|Fire) | per instance (`Aura::SetSchoolMaskOverride`) |
| `SpellInfo::DmgClass` | outcome table: NONE / MAGIC / MELEE / RANGED | carrier row: MAGIC, shared |
| Attack type | weapon slot (BASE / OFF / RANGED) for weapon-based formulas | not used by periodic ticks |
| Weapon vs spell semantics | weapon damage, block, parry, dodge, glancing | never apply to periodic ticks |

Physical school ≠ melee class, and magic school ≠ spell outcome class: native Rend is Physical/MELEE, native
Corruption is Shadow/MAGIC, and there are Physical/MAGIC spells.

## 2. Where DmgClass matters for a periodic tick (AzerothCore source)

| Mechanic | Code | Uses | Effect on a carrier (MAGIC) |
| --- | --- | --- | --- |
| Crit multiplier | `Unit::SpellCriticalDamageBonus` | `spellProto->DmgClass`: MELEE/RANGED ×2, others ×1.5 | a melee payload's converted periodic would crit ×1.5 instead of ×2 — **wrong** |
| Crit chance | module `CarrierCritChance` → `SpellDoneCritChance` / `SpellTakenCritChance` with the **payload** SpellInfo | payload DmgClass | correct per payload |
| Resilience | tick: `ApplyResilience(…, CR_CRIT_TAKEN_SPELL)` | always spell resilience for periodic ticks | same as native DoTs (Rend included): OK |
| Armor | `IsDamageReducedByArmor(schoolMask, …)` | Physical school bit, not DmgClass (bleeds excluded by mechanic) | Physical instance gets armor like native Rend without the bleed mechanic |
| Block / parry / dodge / glancing | melee outcome tables | never used by periodic ticks | OK |
| Magic hit/resist tables | apply-time spell hit | carriers are not cast | OK |
| Dispel "Cloak of Shadows" style removal | `DmgClass == MAGIC` | carrier class | a Physical carrier is removed by Cloak of Shadows — a gameplay detail, noted |

## 3. Decision

- A per-instance outcome class is **not** introduced now: the only wrong result is the crit multiplier, and a
  general `OutcomeClass` override would touch every DmgClass consumer (crit, proc tables, Cloak-type
  removals, spell hit tables) for one case.
- **Implemented (narrow):** a payload whose `DmgClass` is MELEE or RANGED never gets a carrier; it is
  executor-backed with the new backing reason `OUTCOME_CLASS`. The executor deals ticks through
  `CalculateSpellDamageTaken` with the payload SpellInfo, so the crit multiplier follows the payload's class.
  Cost: executor semantics (snapshotted taken modifiers, no periodic procs) for those instances.
- Physical **magic-class** payloads keep carriers (crit ×1.5 is correct for them).
- Most melee payloads are weapon-damage spells without a pre-taken base, which were already executor-backed
  (`NO_PRE_TAKEN_BASE`).

## 4. Future option (only if needed)

`Aura::SetDamageClassOverride` read by `SpellCriticalDamageBonus` and the Cloak-type removal, with its own
consumer audit (like the school and dispel overrides). Trigger: a design that needs native-carrier semantics
(dynamic taken modifiers, periodic procs) for melee/ranged converted periodics.
