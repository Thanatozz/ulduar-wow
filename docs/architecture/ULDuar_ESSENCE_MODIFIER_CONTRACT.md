# Ulduar Essence modifier contract

Code: `src/engine/EssenceModel.{h,cpp}`. Status: data model and contract implemented and unit-tested; no Essence
gameplay (items, sockets, UI, persistence) yet.

## Rule

An Essence contributes **only** `AbilityModifier`s. It never touches `SpellInfo`, spell scripts or ability
definitions, and there is no second modifier system: `EssenceModifiers(essence)` stamps the source
(`Essence`, id, name) and the result goes into the `Essence` layer of `ModifierLayerStore`, resolved by the
same resolver, validation, limits and runtime bridge as the Developer Lab. A test asserts that a Lab preset and
an Essence carrying the same modifiers resolve to identical values.

## EssenceDefinition

| Field | Notes |
| --- | --- |
| Id, Name, Family | identity and grouping |
| Size | Lesser / Normal / Greater |
| Quality | Common / Uncommon / Rare / Epic (independent of size) |
| UniqueRules | `Unique` (legendary/orange presentation, one per character) and `UniqueGroup` (one per group per ability); a classification, not a size or quality |
| Requirements | requirement tree (below) |
| Modifiers | `std::vector<AbilityModifier>` |
| Removable, RemovalCost | removal metadata |
| IconPath, Description | UI metadata only |

Example, Greater Essence of Propagation:
`Projectile.Targets ADD 2`, `Projectile.AcquisitionRange ADD 4`, `Projectile.Scaling MULTIPLY 0.85`,
requirements `ALL(Projectile component, deals damage, NONE(channel))`.

## Requirements engine

`EvaluateRequirement(requirement, resolved)` over the resolved structure. Leaves: HasComponent, HasEffectKind,
DeliveryIs, TargetRelationIs, ElementIs, PropertyAtLeast/AtMost/Above/Below, DealsDamage, Heals, IsChannel.
Groups: ALL, ANY, NONE, nestable. The result lists human-readable reasons for every failed leaf, for UI and
inspector. No spell ids or ability names are ever compared.

Evaluate compatibility against the ability resolved **without** the candidate Essence (so an Essence cannot
satisfy its own requirement), with the other equipped layers applied.

## Ordering

Essence socket order is irrelevant: arithmetic is commutative and SET conflicts are decided by source
precedence and source id (see [modifier engine](ULDuar_MODIFIER_ENGINE.md)). An Essence that must be order
sensitive has to declare it explicitly; the current model has no such mechanic.

## What an Essence gets at runtime

Exactly what the Lab gets: the rows marked RUNTIME in
[ULDuar_ABILITY_RUNTIME.md](ULDuar_ABILITY_RUNTIME.md). Anything the Lab can legally set is expressible by an
Essence, provided the Essence exists and passes its requirements.
