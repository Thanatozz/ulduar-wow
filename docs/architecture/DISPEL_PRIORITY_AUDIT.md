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

## 2. Consequence for the generic carriers (UNRESOLVED)

Pool carriers have **no dispel type** (SpellInfo `Dispel` = 0). By the table above they are **never
dispellable natively**: no Cleanse, Dispel Magic or Remove Curse removes a converted periodic. They still end
by expiry, death, cancel, immunity purge (overlap with the effective school mask) and removal effects that do not
read the dispel mask.

Options (decision required; none implemented):

| Option | Change | Cost |
| --- | --- | --- |
| A. Per-aura dispel override | `Aura::SetDispelTypeOverride` (like the school override), read by `GetDispellableAuraList`, spell steal, `RemoveAurasWithDispelType`, dispel immunity and `GetDispelMask` callers | core change across every dispel consumer; needs its own consumer audit |
| B. Carrier sub-pools per dispel type | 5 dispel types × pool size | multiplies the ledger range (not recommended) |
| C. Undispellable by policy | document converted periodics as undispellable | simplest; a gameplay decision |

`Effect.DispelType` exists as a property and is resolved, but no runtime reads it for carriers.

## 3. Desired Ulduar model (engine model + tests only)

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

## 4. Gap

| Desired | Native | State |
| --- | --- | --- |
| LIFO by group | uniform random | NOT WIRED (needs a core selection hook in `EffectDispel`) |
| Strength Weak/Half/Full | `damage` count | NOT WIRED |
| Priority | none | NOT WIRED |
| One reaction per group | one per aura | NOT WIRED |
| Carriers dispellable | never (no dispel type) | UNRESOLVED (§2) |

No native behavior is changed in this milestone.
