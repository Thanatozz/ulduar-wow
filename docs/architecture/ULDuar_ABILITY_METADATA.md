# Ulduar ability metadata and conversion contract

Status: proposed, 2026-09-14. Companion: [taxonomy](ULDuar_SPELL_TAXONOMY.md).

## Layers and ownership

1. `NativeSpellSnapshot`: immutable import of ranked SpellInfo/DBC plus source-specific script observations.
2. `UlduarAbilityDefinition`: stable identity, native bindings, explicit capability declarations, review status.
3. `UlduarAbilityEffect`: independently typed operations/payloads with native slot and dependency provenance.
4. `ResolvedAbility`: immutable per-character graph after accepted structural changes; contains a trace.
5. `AbilityCastSnapshot`: exact build/catalog revision, ranked spell and event/resource ledger for one cast.

Definitions never mutate shared `SpellInfo`. An adapter translates supported overrides into per-cast core behavior.
Unmodified operations continue through the native implementation. Opaque scripted operations remain available
as native behavior but cannot acquire a transformation merely because their parent spell has a matching tag.

Spell metadata owns identity, invocation, cast schedule, root costs, cooldown groups, common requirements and
presentation defaults. Effect metadata owns operation kind, implicit targets, relation, geometry, delivery,
payload time model, magnitude, coefficients, school override, trigger edges and effect-specific requirements.
Aura/field/summon records own lifetime, stacking, tick phase, ownership and inheritance. A derived spell summary
is a search index, not the authoritative union against which effect selectors execute.

Every field records `value`, `unit`, `sourceKind`, `sourceRef`, `confidence`, `reviewRevision` and inheritance.
Source kinds: native DBC, core correction, native script adapter, authored metadata, gem, keystone, talent, aura.
An authored override includes a reason and affected source revision. `RuntimeEnabled` remains an explicit release
gate. Distinguish `Representable`, `AdapterImplemented`, `ValidatedInRuntime` and `Published` capabilities.

## Keys and examples

`abilityId` is not a SpellID. Native ranks resolve through the rank-chain map. Keep existing ability IDs stable.
`effectKey = native:<slot>:<operation>` or `derived:<definitionId>:<localKey>` survives import ordering changes.
Graph edges bind controller to payload with rank policy: corresponding native rank, explicit mapping, or fixed
payload revision. An unresolved edge blocks transformations depending on it; it does not silently choose rank 1.

```text
ability: moonfire-family
nativeRoot: source binding only
effect native:0:impact -> Damage, Arcane, Instant, Unit/Enemy
effect native:1:apply  -> ApplyAura; aura owner = target, caster identity retained
effect native:1:tick   -> Damage, Arcane, Periodic; parent = native:1:apply
selector exists(effect where kind=Damage and time=Periodic)
modifier potency +15% -> native:1:tick only
```

Core imported slot numbers must be verified for each actual spell; the example is conceptual, not a claim about
the local Moonfire DBC slot numbering. A single native aura effect may expand into several semantic operations.

## Conversion is a typed, first-class transformation

`ConversionDefinition` contains ID/version, source selector, bound effect bundle, read/write sets, required adapter,
preconditions, output template, conservation/balance policy, targeting rewrite, presentation policy, conflicts,
priority and postconditions. Supported operations include replace, split, merge and wrap; each preserves ancestry.
No runtime free-form Lua or SQL is accepted as a conversion expression.

| Conversion | Required changes beyond one enum | Publication gate |
| --- | --- | --- |
| Frost -> Fire | Damage/proc school, mitigation; aura identity policy | School adapter coverage |
| Damage -> Healing | Kind, relation, mitigation/crit/scaling/threat; debuff policy | Healing target adapter |
| Healing -> Absorb | Aura pool/lifetime/stacking, overheal policy, consumption event | Absorb lifecycle adapter |
| Direct -> Projectile | Delivery, travel/impact timing, visual, revalidation | Travel and hit adapter |
| Projectile -> Beam | Hit geometry versus visual beam; duration/ticks if requested | Beam hit-model adapter |
| Unit -> Ground | Destination, placement range/LOS, geometry and targets | Ground targeting adapter |
| SingleTarget -> Area | Bundle, geometry, cap, falloff, ally/enemy checks per target | Area acquisition adapter |
| Instant -> Periodic | Aura/field owner, duration, tick interval, first tick, total budget | Periodic adapter |
| Mana -> Health | Resource basis, rounding, lethal rule, refund/proc provenance | Health cost adapter |

School conversion defaults to modifying selected damage/heal payloads only. Changing a slow into a burn is a
separate authored operation. Mixed schools remain masks, not one dominant school. Full per-effect school
conversion is not supported by today's per-Spell school override; splitting payload execution may be necessary.

For Instant -> Periodic, default `conserveTotalMagnitude`: evaluate a base total once, distribute integral units
across a fixed tick count, put the remainder on the final tick. An explicitly authored per-tick conversion may
increase total output, with its budget shown. Damage -> Healing does not retain enemy-only implicit targets or
damage mitigation. Reuse of native scripts requires an adapter proving their assumptions remain valid.

Structural conversions execute in a bounded dependency DAG. Topological order uses explicit dependencies, then
phase/priority/stable ID. Conflicting writes without a declared compose rule reject the build. A conversion is
applied once, never repeatedly until stable. Cycles, including Fire -> Frost -> Fire, are rejected during candidate
validation. Preserve a before/after graph and explanation for every rejection and every applied conversion.

## Proposed world schema (logical, no SQL)

All published rows are immutable under `(catalog_version, id)`. New balance values publish a new version.
Localized text references are keys into a separate localization catalog. Units and enum IDs use the taxonomy version.

| Table | Primary key | Essential fields / relations |
| --- | --- | --- |
| `ulduar_ability_definition` | version, ability_id | native_root, rank_map, identity, activation, costs, cooldowns |
| `ulduar_ability_effect` | version, ability_id, effect_key | parent_key, slot, kind, target, geometry, time, scaling |
| `ulduar_ability_tags` | version, ability_id, scope_key, tag | provenance, confidence; scope `spell` or effect key |

Definition adds name/icon keys, source class/family/category, release state and required adapter revisions.
Effect adds delivery, school policy, coefficient profile, aura/field/summon profile, trigger graph and restriction
references. `scope_key` is non-null so a spell tag has an enforceable unique key. No comma-separated tags.

Supporting relations: native rank bindings `(version, ability_id, native_spell_id)` unique by native role;
effect edges `(version, ability_id, edge_id)` with source/target keys and cycle validation; typed property/profile
tables for targeting, costs, cooldowns, auras and summons. Validated versioned expression ASTs may be serialized
for predicates/coefficient formulas; common searchable dimensions remain indexed columns. Cross-database foreign
keys to DBC IDs are logical references validated at catalog load, not fictitious database constraints.

`ConversionDefinition` and execution adapter registry are additional catalog entities. Their IDs are referenced by
gem, talent or keystone effects; do not bury conversion behavior in a localized tooltip. Adapter registry includes
supported core revision, native behavior ownership and validation evidence.

## Migration of existing behavior

[AbilityDefinitions.cpp](../../modules/mod-ulduar-abilities/src/AbilityDefinitions.cpp) remains the bootstrap
registry until the importer reproduces every enabled binding. Preserve `PayloadSpellId` for Arcane Missiles and
`SecondarySpellId` for Judgement of Light as explicit edges. Preserve `SupportsElementConversion`, potency gates,
modifier mask and supported propagation as legacy adapter limits until each is proven safe to generalize.

Current `AbilityTag`, `AbilityClassification` and `PlayerAbilityState` remain readable through a legacy adapter.
Map `None` propagation to Original, keep the six other school conversions' current limits, and map existing ranks
to named legacy modifier profiles. Current Potency means secondary multiplier, not all-effect Potency. Do not
silently convert it to universal damage/heal/control bonuses. Current Range bands remain UI labels; actual ranges
come from native range records and runtime reach.

Remove source-class eligibility only when classless ownership and native spell requirements can be evaluated.
Never reinterpret saved `ClassId` as a selector restricting universal talents. Keep origin class as provenance.

Comparison gate: old and new adapters resolve identical legacy build snapshots for every registered ability,
rank, propagation mode and budget. Difference reports must distinguish intentional fixes from regressions.
No saved rank, EP, gem-equivalent node or existing UI entry is removed by this documentation phase.
