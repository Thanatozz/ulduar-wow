# Periodic target architecture (contract)

Date: 2026-09-27. Status: **TARGET DESIGN, largely implemented** (see §0). The seven per-school carriers are
HISTORICAL / SUPERSEDED. Current runtime: [PERIODIC_RUNTIME.md](PERIODIC_RUNTIME.md).

## 0. Implementation status

| Section | State |
| --- | --- |
| §2 instance key | RUNTIME CODED (`PeriodicInstanceKey`; `PeriodicEffectKey` is always 0 until an ability owns two periodic effects) |
| §3 generic pool | RUNTIME CODED; IDs RESERVED (ledger revision `PC2-GENERIC-PERIODIC-CARRIER-POOL-004`); pending SQL 007 |
| §4 per-instance school | RUNTIME CODED (core override, [PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md)) |
| §5 dual element | DECIDED: one event, one multi-bit mask ([MULTI_SCHOOL_DAMAGE_POLICY.md](MULTI_SCHOOL_DAMAGE_POLICY.md)); crit = highest school chance (module), taken % = best school once (core `6a98c36`); LOCAL BUILD PASS, NOT TESTED in game |
| §6 echo lineages | IN-GAME FAIL (2026-09-27: native payload aura shared with the Root) → FIXED IN SOURCE, retest pending; converted carriers per lineage by the ownership registry |
| §7 IndependentDuration | RUNTIME CODED (one carrier per application) |
| §8 presentation groups | ENGINE MODEL + TESTS; no producer to the client yet |
| §9 dispel | RUNTIME CODED: carriers take the payload's dispel type per aura (core `Aura::SetDispelTypeOverride`, `0efcbff`) and grouped LIFO dispel runs through the core `OnGroupedDispel` hook + module resolver ([DISPEL_PRIORITY_AUDIT.md](DISPEL_PRIORITY_AUDIT.md), [DISPEL_TYPE_OVERRIDE_AUDIT.md](DISPEL_TYPE_OVERRIDE_AUDIT.md)); LOCAL BUILD PASS, NOT TESTED in game. SUPERSEDED: "carriers undispellable" |
| §10 aura slots | capacity check + diagnostics RUNTIME CODED; ExtendedAuraSlots documentation only |

LOCAL BUILD PASS for the whole milestone (maintainer, 2026-09-27). Items without an explicit in-game result are NOT TESTED in game; status vocabulary: [ULDuar_ABILITY_RUNTIME.md](ULDuar_ABILITY_RUNTIME.md) "Validation states".

Shared with the client patch: `ulduar-client-patch/docs/AURA_PRESENTATION.md` and
`AURA_PROTOCOL_V2_DESIGN.md` carry the presentation half of this contract.

## 1. Authority

Gameplay is server authoritative. The server owns:
- conversion, efficiency, pool, ticks, interval;
- stacking, spread, echo composition, school, dispel;
- carrier allocation.

The client only presents, and a carrier SpellID never carries meaning for the client.

## 2. Periodic instance

One server object per logical periodic application. The names are the contract's, not final code names.

| Field | Meaning |
| --- | --- |
| CasterGuid, TargetGuid | ownership; different casters never share an instance |
| AbilityId | the ability (not the ranked spell) |
| PeriodicEffectKey | which periodic effect of the ability (one ability may own several) |
| Lineage | Root, or Echo with EchoGeneration 1..N |
| ApplicationId | unique per application; only IndependentDuration creates more than one per lineage |
| CarrierSpellId | the allocated technical carrier (execution identity only) |
| SchoolMask | effective school of **this instance** (may be multi-bit) |
| TickAmount / pool state, interval | engine plan (unchanged formulas) |
| Expiration / remaining, max duration | lifetime |
| LogicalStacks | wide integer (not the stock `uint8` aura stack count) |
| Snapshot references | immutable ability snapshot, caster crit/haste snapshots |

Instance key = (CasterGuid, TargetGuid, AbilityId, PeriodicEffectKey, Lineage, EchoGeneration,
ApplicationId). `Periodic.StackBehavior` decides whether a new application refreshes an existing key or
creates a new ApplicationId.

## 3. Generic carrier pool

- A carrier is only a native aura/tick execution identity. Its SpellID encodes **no** school, ability,
  variant, icon or display name.
- The target pool is about 2048 identical generic `SPELL_AURA_PERIODIC_DAMAGE` carriers.
- The server allocates a free carrier per instance on the target and releases it when the aura ends.
- The core key "one aura per caster + spell per target" then no longer limits:
  - several abilities of one school;
  - Root/Echo lineages;
  - IndependentDuration.
- If the pool or the native aura slots are exhausted, the executor fallback remains the safety path. It is
  never silent merging.

### ID status

| Range | Status | Notes |
| --- | --- | --- |
| 141344..141350 | **RETIRED_TOMBSTONE** (ledger revision `PC1-PERIODIC-CARRIER-RETIREMENT-003`) | HISTORICAL per-school carriers; SQL 005 SUPERSEDED; never reused |
| 141351..141357 | **RETIRED_TOMBSTONE** | HISTORICAL healing reservation; never reused |
| 310272..312319 (2048) | **RESERVED** (ledger revision `PC2-GENERIC-PERIODIC-CARRIER-POOL-004`, 2026-09-27; not INTRODUCED) | see §3.1 and [the ledger doc](ULDuar_ID_ALLOCATION_LEDGER.md) |

### 3.1 Candidate collision screen (2026-09-27)

- **141358 onward was not assumed free.** An untyped decimal screen over six repositories (10,790 files:
  ulduar-wow, the four modules, ulduar-client-patch) finds 115,843 distinct 6-digit literals. No 2048-wide
  aligned block at or above 142336 is free of all literals.
- **Typed review** of the lowest-hit blocks:
  - 310272..312319 has no Spell.dbc row or EffectTriggerSpell reference (pinned Spell table
    `d5cce1a8…`), no base `spell_dbc` row and no ledger entry.
  - Its SQL hits are only `item_template.BuyPrice/SellPrice`, `waypoint_data.id` and
    `creature_addon.path_id`.
  - Its other hits are firework-show millisecond timestamps (`firework_show_*.h`) and file sizes in audit
    JSON.
  - 381952..383999 is the runner-up with the same profile.
- **Sparse index:** the server SpellStore index grows to 312320 entries (about 2.4 MiB of pointers at 8
  bytes). A client patch adding rows grows the client index similarly.
- **Before reservation:**
  - screen the ulduar-client-patch MPQ/DBC outputs and any external environment;
  - get a maintainer decision.
- Reserving is an append-only ledger transaction and is not performed here.

## 4. Per-instance school mask

The instance owns the effective `SpellSchoolMask`. Shared `SpellInfo` is never mutated per player.

**Native periodic consumers that read the carrier's `SpellInfo` school today**
(`AuraEffect::HandlePeriodicDamageAurasTick`, `SpellAuraEffects.cpp`):

| Consumer | Call | School source today |
| --- | --- | --- |
| Immunity | `target->IsImmunedToDamage(caster, GetSpellInfo())` | `spellInfo->GetSchoolMask()` (no override passed) |
| Taken modifiers | `SpellDamageBonusTaken(caster, GetSpellInfo(), dmg, DOT, stack)` | defaults to SpellInfo (the function accepts a `schoolMask` parameter) |
| Armor | `IsDamageReducedByArmor(GetSpellInfo()->GetSchoolMask(), …)` | SpellInfo |
| Crit bonus | `SpellCriticalDamageBonus(caster, m_spellInfo, dmg, target)` | SpellInfo |
| Absorb / resist | `DamageInfo(…, GetSpellInfo()->GetSchoolMask(), DOT, …)` → `CalcAbsorbResist` | SpellInfo |
| Damage / threat | `DealDamage(…, DOT, GetSpellInfo()->GetSchoolMask(), …)` | SpellInfo |
| Periodic log | `SendPeriodicAuraLog`: `data << aura->GetSpellInfo()->GetSchoolMask()` | SpellInfo |
| Procs | `ProcSkillsAndAuras(…, &dmgInfo)`: the DamageInfo school above | SpellInfo |
| Crit chance | `AuraEffect::CalcPeriodicCritChance`: `GetSpellInfo()->GetSchoolMask()` (the module overrides the chance with `SetCritChance`) | SpellInfo |
| Aura scripts | any `GetSpellInfo()->GetSchoolMask()` in scripts bound to the carrier (none today) | SpellInfo |

**Core change (made, 2026-09-27):** `Aura::SetSchoolMaskOverride` / `GetEffectiveSchoolMask`
(`effectiveSchool = override ? override : spellInfo->GetSchoolMask()`), read by the call sites above,
`SendPeriodicAuraLog` and school-immunity purges. The "SpellInfo" column is the pre-change state; per-site
status is in [PERIODIC_SCHOOL_MASK_AUDIT.md](PERIODIC_SCHOOL_MASK_AUDIT.md).

## 5. Dual element (combined school)

Only combined-school damage is supported: `1000 Frost|Fire` is one hit, one amount, one crit, one mitigation
event and one periodic pool, with no per-element split. What AzerothCore does with a multi-bit mask today:

| Mechanic | Behavior with mask Frost\|Fire | Source |
| --- | --- | --- |
| Immunity | immune only if the immunities cover **all** bits (`(immuneMask & schoolMask) == schoolMask`) | `Unit::IsImmunedToDamage(…)` 9943-10004, `IsImmunedToSchool` 10006 |
| Resistance | the **lowest** resistance among the bits | `Unit::GetResistance(SpellSchoolMask)` 16305 |
| Penetration | sum of `SPELL_AURA_MOD_TARGET_RESISTANCE` auras whose misc mask overlaps any bit | `GetEffectiveResistChance` 2299 |
| Absorb | any absorb aura whose misc mask overlaps any bit | `CalcAbsorbResist` (absorb loop, `GetMiscValue() & schoolMask`) |
| % damage done | product of every `MOD_DAMAGE_PERCENT_DONE` aura whose misc overlaps (a Fire +10% and a Frost +10% both apply: ×1.21) | `SpellPctDamageModsDone` 8451 |
| Spell power | player base spell power + sum of per-school `MOD_DAMAGE_DONE` auras overlapping any bit | `SpellBaseDamageBonusDone` 9104 |
| % damage taken | product of `MOD_DAMAGE_PERCENT_TAKEN` by misc mask (overlap) | `SpellDamageBonusTaken` 8963 |
| Crit chance | the **first** school bit only (`GetFirstSchoolInMask`: Fire before Frost) | `SpellDoneCritChance` 9173 |
| Armor | applies if the Physical bit is set; with `SPELL_ATTR0_CU_SCHOOLMASK_NORMAL_WITH_MAGIC`, the lower of armor and magic resist | `IsDamageReducedByArmor` 2203, `CalcAbsorbResist` |
| School-filtered procs | procs whose school filter overlaps any bit | proc system (school mask of DamageInfo) |

These are existing semantics, not new ones. Before enabling multi-bit carriers, confirm them as intended
gameplay:
- the first-bit crit chance;
- multiplicative stacking of per-school done modifiers.

Direct hits already support a multi-bit override (`Spell::SetSpellSchoolMask`, element conversion).
Periodic carriers need §4 first.

## 6. Echo periodics (supersedes "echo merges into root")

- Root and each Echo generation are **separate logical instances** (Lineage + EchoGeneration in the key).
  Each has its own carrier, amount, duration, stacks, refresh and procs. A weaker Echo can never replace
  or weaken the Root.
- A recast reuses its own lineage per `Periodic.StackBehavior`:
  - new Root → Root lineage;
  - new Echo 1 → Echo 1 lineage;
  - and so on.
- Lineages are bounded by `MaxEchoCount`. There is no permanent lineage per historical cast.
- Echoes still never create echoes.

**Implemented (RUNTIME CODED):** the executor keys by `PeriodicInstanceKey`, including lineage and echo
generation. The former interim rule (echo pool refreshes or stacks the Root instance) is HISTORICAL.

## 7. IndependentDuration

- Each independent application gets a unique ApplicationId, its own carrier from the pool, and its own
  expiration, amount and snapshot.
- Implemented (RUNTIME CODED) on native pool carriers. The former executor-only rule
  (`INDEPENDENT_DURATION`) is removed.
- On pool or aura-slot exhaustion it falls back to the executor. It never silently merges.

## 8. Presentation groups (presentation only)

Server instances stay independent. A client may collapse several into one visible logical aura.

- **Group key:** TargetGuid + CasterGuid + AbilityId + PeriodicEffectKey + PresentationSignature. Different
  casters never share a group. CarrierSpellId, EchoGeneration and ApplicationId identify **members**, never
  the group.
- **Displayed duration:** the member with the earliest expiration. When it expires, the next earliest
  shows its own real remaining time; durations are never reset. A refresh may change which member expires
  first.
- **Stack count:** the sum of members' logical stacks (Root×3 + Echo1×2 + Echo2×1 = ×6). The server's
  logical count is wide; stock `uint8` is not the authority.
- **Group order:** the newest meaningful application first (C, B, A). A periodic tick never reorders. A
  meaningful reapplication or refresh moves the group to the front.
- **Member order within a group:** earliest expiration first. The two orderings are independent.
- **Local player priority:** the local player's groups are shown before equivalent foreign groups. This is
  client presentation only; gameplay is unaffected.

## 9. Dispel

`DispelType` (Magic, Curse, Poison, Disease, …) decides *what* may be removed. `DispelStrength` decides
*how much* of the selected Ulduar group is removed.

| Strength | Removes from the selected group |
| --- | --- |
| WEAK | 1 logical stack |
| HALF | max(1, floor(totalStacks / 2)) logical stacks |
| FULL | the whole group |

Cast time and cooldown per strength are ability balance data, not part of the algorithm.

- **Group selection:** the newest eligible group first (LIFO), walking backwards past groups the
  DispelType cannot remove.
- **Member removal inside the group:** earliest expiration first. Selection order and removal order are
  distinct.

### 9.1 Stock AzerothCore behavior (audited)

- **`Spell::EffectDispel`** (`SpellEffects.cpp` 2604-2670):
  - builds a list of dispellable visible, non-passive auras with charges/stacks
    (`Unit::GetDispellableAuraList`, 5914);
  - picks one **uniformly at random** per dispel count (`urand(0, size - 1)`);
  - rolls `Aura::CalcDispelChance` (`SpellAuras.cpp` 1133: caster `SPELLMOD_RESIST_DISPEL_CHANCE` +
    target `SPELL_AURA_MOD_DISPEL_RESIST`);
  - drops 0% auras from the list;
  - removes via `RemoveAurasDueToSpellByDispel` (`Unit.cpp` 5235): `OnDispel` hook, stack/charge
    reduction, `AfterDispel` hook.
- **Unstable Affliction** (`spell_warl_unstable_affliction`, `spell_warlock.cpp` 1024-1047): `AfterDispel`
  casts the backlash (damage + silence) on the dispeller.
- **Vampiric Touch** (`spell_pri_vampiric_touch`, `spell_priest.cpp` 851-900): `AfterDispel` casts its
  dispel damage spell on the aura's owner.
- **Conclusion:** stock protection mechanics **only punish after selection**. They do not change selection
  priority. The only selection-side influence is the success chance (dispel-resist modifiers), not
  ordering.
- **Ulduar rule:** punishment/protection is a semantic effect property (data), never a spell-ID branch.
  Deterministic LIFO selection replaces stock random selection only for Ulduar groups.

## 10. Native aura slot capacity

- The stock contract is `MAX_AURAS = 255` (slots 0..254, 255 is the sentinel), with a `uint8` wire slot
  (`SpellAuraDefines.h`; `SMSG_AURA_UPDATE` 0x496 / `_ALL` 0x495, audited in the client
  `AURA_PRESENTATION.md`).
- The carrier pool size and aura-slot capacity are **separate** limits. **Not changed.**
- Future **ExtendedAuraSlots** milestone, investigation only:
  - a `uint16` slot/index;
  - `AuraApplication` slot storage and the update writers;
  - both packets and the client packet parser;
  - native client aura storage and UnitBuff/UnitDebuff mapping;
  - frame and nameplate UI;
  - the invalid sentinel and addon API boundaries.

  Never just raise `MAX_AURAS`.

## 11. Implementation order (server)

1. ~~Per-aura school override in the core (§4).~~ Done (RUNTIME CODED).
2. ~~Carrier pool: allocator, release, startup validation, pending SQL.~~ Done; ledger appended
   (`PC2-GENERIC-PERIODIC-CARRIER-POOL-004`, ulduar-wow `1446137`).
3. ~~Instance key extension, echo lineages, native IndependentDuration.~~ Done (RUNTIME CODED).
4. Presentation metadata producer (client protocol revision, after client native aura evidence).
5. ~~Dispel: decide carrier dispellability, then wire strengths and LIFO group selection.~~ Done (RUNTIME
   CODED, see §9 status).

No SQL is applied. The server is not built or started by these steps without explicit authorization.
