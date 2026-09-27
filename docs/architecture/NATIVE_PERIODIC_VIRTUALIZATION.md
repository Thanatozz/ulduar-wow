# Native periodic virtualization (DESIGN ONLY)

Date: 2026-09-27. Status: **design only, nothing implemented.** Prerequisite: checklist Stage J0 PASS.

## 1. Problem

AzerothCore keeps **one aura per spell + caster + target** (`Unit::_TryStackingOrRefreshingExistingAura`,
`Aura::TryRefreshStackOrCreate`). Ulduar instance semantics need several periodic instances of one ability on
one target: Root, Echo1..EchoN, and IndependentDuration applications.

Converted periodics already have them (generic carrier pool + `PeriodicInstanceKey` + `PeriodicRegistry`). A
**native** periodic payload aura (Immolate's `PERIODIC_DAMAGE`, Corruption, Serpent Sting) does not:

- since `8dbc1d3` / `0eef40b` an Echo or secondary copy keeps an existing Root native aura untouched
  (`Spell::SetTriggeredKeepExistingAuras`): no removal, no refresh, no weakening;
- the Echo therefore gets **no second native DoT**. This is the intended, documented limitation.

Nuance to keep in mind: the keep-existing rule only applies when the caster's aura already exists. If the Root
native DoT has expired (or was dispelled) when an Echo copy lands, the Echo copy creates the native aura; a later
Root recast then refreshes that aura natively. One native aura has no lineage of its own.

## 2. What native periodics carry that a carrier does not

| Native aura property | Used by | Lost if the periodic becomes a generic carrier |
| --- | --- | --- |
| `SpellFamilyName` + `SpellFamilyFlags` | Conflagrate (consumes Immolate), Fire and Brimstone, Chimera Shot (refreshes Serpent Sting), Everlasting Affliction, Glyphs | yes: carriers have family 0 by design |
| Native coefficient / `dot_damage` bonus data | spell power scaling of ticks | replaced by the Ulduar snapshot pool |
| Other aura effects of the same spell (e.g. a snare or a stat debuff in effect 2) | gameplay | only the periodic part moves |
| Native name / icon / tooltip | stock client | carrier is a technical id (client patch presents it) |
| Mechanic / dispel type | dispels, immunities | carrier takes the dispel type per aura; mechanic must be copied per instance |

## 3. Options

### A. Convert the native periodic portion into an Ulduar periodic instance

The periodic effect of the payload is suppressed (`PreventHitAura` / effect mask) and its amount becomes a
carrier instance for every lineage, Root included.

- \+ uniform: every lineage is a real instance (Root, Echo, IndependentDuration), same ownership registry.
- \- breaks every family-flag interaction in §2 for the Root too (Conflagrate cannot find Immolate).
- \- needs per-spell rules for multi-effect periodics (keep effect 2, move effect 1).
- \- changes the Root's behavior for players who never use echoes.

Verdict: acceptable only as an **explicit opt-in** (it is what `Periodic.Conversion` on a direct-damage spell
already does). Not a default for native DoTs.

### B. Shadow the native periodic for non-Root lineages

The Root keeps its native aura unchanged (all class interactions keep working). For Echo lineages (and later
IndependentDuration applications) the native periodic effect is **mirrored** into a converted carrier instance
keyed by that lineage:

- per-tick amount = the native aura's per-tick amount computed for the echo copy (`AuraEffect::CalculateAmount`
  with the echo's scaling), duration/interval from the native effect, school/dispel from the payload;
- the echo copy's native periodic effect stays prevented (the existing keep-existing rule), so no native aura is
  created or touched by the echo, whether or not the Root aura exists;
- carrier removal is exact (registry), like every converted instance.

- \+ Root behavior is exactly native; echoes get their own DoT.
- \+ reuses the carrier pool, key, registry, dispel grouping, presentation groups.
- \- the shadow is not a native Immolate: Conflagrate / Chimera Shot see only the Root aura (acceptable: those
  mechanics are Root-owned).
- \- amount parity needs care (snapshot timing, `SPELLMOD_DOT`, pandemic-free refresh rules).
- bounded: only the periodic effect of payload auras is mirrored; non-periodic aura effects are not.

### C. Keep the native aura Root-only (current)

- \+ zero risk, already implemented and under J0 retest.
- \- echoes of native-DoT abilities deal only their direct part.

## 4. Recommendation

1. **Now:** C (current behavior). Do not implement A or B before J0 PASS.
2. **Next bounded step after J0 and the effect runtime:** B for Echo lineages only, behind a property
   (e.g. `Echo.ShadowNativePeriodic`, default off), with its own checklist stage and debug trace
   (`SHADOW_CREATE`). It needs:
   - the always-prevent rule for the echo copy's native periodic effect (today it is prevented only when the Root
     aura exists; see §1 nuance);
   - a pure test set mirroring `AbilityPeriodicIsolationTest` (Root native + Echo shadow never cross-remove);
   - no new IDs (the generic periodic pool is reused).
3. **A** stays an explicit per-ability opt-in through the existing conversion properties.

No code, SQL or IDs are part of this document.
