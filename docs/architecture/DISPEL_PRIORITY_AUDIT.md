# Dispel priority audit (native vs desired)

Scope: how a dispel chooses what to remove, what AzerothCore does today, what the Ulduar model wants, and what
blocks the gap. Engine model: `src/engine/AuraGrouping.*` (mod-ulduar-abilities), tests `UlduarDispel.*`.

## 1. Native behavior (audited, 2026-09-27)

Source: `Spell::EffectDispel` (`SpellEffects.cpp`), `Unit::GetDispellableAuraList`,
`Unit::RemoveAurasDueToSpellByDispel` (`Unit.cpp`).

| Step | Native rule |
| --- | --- |
| Eligibility | visible, non-passive auras whose `SpellInfo::GetDispelMask()` overlaps the dispel's mask (the dispel type comes from **SpellInfo**, never from the aura instance) |
| Friend/foe | a Magic aura is eligible only if its positivity is the opposite of the target's relation to the dispeller |
| Exclusions | Unholy Blight blocks disease dispels; Banish only by `SPELL_ATTR0_NO_IMMUNITIES` (Mass Dispel) |
| List weight | one list entry per aura, weighted by charges (`SPELL_ATTR7_DISPEL_REMOVES_CHARGES`) or stack amount |
| Selection | `urand` over the list: **uniform random**, no recency, no priority |
| Resistance | `Aura::CalcDispelChance` per attempt; 0% entries are dropped, a failed roll is logged (`SMSG_DISPEL_FAILED`) and still consumes a dispel count |
| Removal | `RemoveAurasDueToSpellByDispel`: `OnDispel` → `ModStackAmount(-n)` or `ModCharges(-n)` → `AfterDispel` |
| Count | `damage` of the dispel effect = number of successful removals (stacks/charges) |

### Native dispel callbacks

| Script | Hook | Reaction |
| --- | --- | --- |
| Unstable Affliction (`spell_warl_unstable_affliction`) | `AfterDispel` | damage + silence on the dispeller, computed from the aura's amount |
| Vampiric Touch (`spell_pri_vampiric_touch`) | `AfterDispel` | damage on the dispeller |

Both run **once per removal call on one aura**. Native has no concept of a group, so "one reaction per group vs
one per member" does not exist natively. A group dispel that removes several member auras would call these
hooks once per member aura it touches.

## 2. Carrier dispellability (DECIDED 2026-09-27: per-aura override)

Pool carriers have no SpellInfo dispel type, so natively they could never be dispelled. Chosen architecture:
option A, a per-aura dispel type override (`Aura::SetDispelTypeOverride`, mirroring the school override). The
carrier receives the payload spell's dispel type per instance (a converted Frostbolt is Magic, a converted
Serpent Sting is Poison, a physical payload without a dispel type stays undispellable). No carrier pool is
split by dispel type. Consumer audit: [DISPEL_TYPE_OVERRIDE_AUDIT.md](DISPEL_TYPE_OVERRIDE_AUDIT.md).

## 3. Ulduar model (engine model + tests; wired for carriers, §4)

| Concept | Rule |
| --- | --- |
| DispelType | Magic / Curse / Disease / Poison: *what* can be dispelled |
| DispelStrength | Weak (1 logical stack), Half (max(1, n/2)), Full (the whole group): *how much* |
| DispelPriority | `Normal` / `Protected`: a semantic property; higher priority is selected first. It is **not** a native field |
| Group selection | among eligible presentation groups: highest priority, then **newest** `LastMeaningfulApplication` (LIFO) |
| Member selection | inside the group, **earliest-expiring** member first, removing logical stacks until the strength is spent |
| Reaction | one reaction per dispelled **group** (`DispelPlan::TriggersReaction`), not per member |

`LastMeaningfulApplication`: the time of the last application that changed the group's gameplay state (a new
instance, an added stack, a stronger replacement). A pure refresh with identical amount/duration does not
count, so reapplying cannot push a group to the front of the dispel order.

## 4. Wiring (RUNTIME CODED, 2026-09-27)

| Desired | Implementation | State |
| --- | --- | --- |
| Ulduar groups never use stock random selection | core: grouped auras (`Aura::SetDispelGroupId`) leave the native list; all groups together are one candidate slot; `ScriptMgr::OnGroupedDispel` resolves it | RUNTIME CODED |
| Group order: priority, then newest meaningful application | module: `AbilityPeriodicExecutor::ResolveGroupedDispel` → `BuildAuraGroups` + `SelectDispelGroup` | RUNTIME CODED (`DispelPriority` is Normal for every group until a property exists) |
| Earliest-expiring member first | `PlanDispel` (members by remaining duration) | RUNTIME CODED |
| Strength | native dispel spells have no strength: **Weak** (1 logical stack) per successful attempt; Half/Full exist in the model for future Ulduar dispels | RUNTIME CODED (Weak) |
| One reaction per group | grouped carriers never run `OnDispel`/`AfterDispel`; the resolver has one reaction point per group (no reaction property yet) | RUNTIME CODED |
| Dispel resistance / failure | one `CalcDispelChance` roll per group (displayed member); failure logged in `SMSG_DISPEL_FAILED`; 100% resistance drops the slot without spending a dispel | RUNTIME CODED |
| Native unrelated auras | unchanged (random, charges, UA/VT reactions) | NATIVE |
| Meaningful application | a new instance, an added stack or a changed tick amount stamps the group; a pure refresh does not | RUNTIME CODED |

Fairness between native auras and Ulduar groups: each attempt picks uniformly among native entries plus ONE
grouped slot, so a target with many Ulduar carriers is not more likely to lose them than a single native
debuff. All RUNTIME CODED items: REQUIRES LOCAL BUILD / REQUIRES IN-GAME TEST.
