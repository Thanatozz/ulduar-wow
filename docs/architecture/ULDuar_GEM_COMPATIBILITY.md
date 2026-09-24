# Ulduar gem definitions and compatibility

Status: proposed, 2026-09-14. Existing node purchases remain supported through a legacy adapter.
Gems customize one owned ability instance. Talents publish global character rules. Keystones have a separate
character slot and structural rule scope. These three scopes cannot be inferred from the item name or rarity.

## Definition model

| Entity | Contract |
| --- | --- |
| `GemDefinition` | Stable ID/version, localized name/icon, slot scope, tags, release state, allowed rank/variants |
| `GemRequirements` | Typed boolean selector over graph capabilities; binds effect keys and coverage groups |
| `GemExclusions` | Forbidden geometry, effects, conversions, groups or missing execution adapters |
| `GemModifier` | Bound target, operation, abstract/concrete stat, signed value, unit, stage and stacking group |
| `GemRank` | Rank index, point/socket cost, explicit value vector; cumulative versus replacement semantics |
| `GemRarity` | Acquisition/display policy and optional declared budget; never implicit compatibility bypass |
| `GemVariant` | Named alternative requirement/modifier bundle, fixed on acquisition or explicitly changed |
| `ModifierGroup` | Stack key, scope, operation policy, cap, exclusivity and deterministic tie-break |

Rank r is a complete replacement value vector by default, not the sum of ranks 1..r. Each group declares one
policy: sum additive values, multiply factors, maximum, unique, or exclusive. `maximum` ties resolve by stable
definition ID and instance ID; `exclusive` rejects multiple contributors rather than hiding a paid gem.
Quantize once after composing each field. Mixed percent-add and multiply operations use separate groups.

Requirements use the [talent selector grammar](ULDuar_GENERALIZED_TALENTS.md); no arbitrary client expression.
`existsEffect(all(...))` preserves same-effect binding. `allEffects` and `countEffects` are explicit alternatives.
Unknown capability results fail closed with a reason code. Metadata presence alone is insufficient: the required
adapter must support that effect type and the full transformation bundle.

## Capability examples

```text
Chain
  bind E = existsEffect(Targeting.Unit AND (Effect.Damage OR Effect.Healing))
  require E.capability.unit_payload, propagation.chain, bounded_targets
  exclude E.geometry in {Cone, Line} OR E.delivery=PersistentArea unless a conversion adapter supports it
  exclude root-only controller/resource operations from propagated bundle

Projectile Speed
  bind E = existsEffect(Delivery.Projectile AND capability.edit_projectile_velocity)
  require finite positive native/effective velocity and valid travel adapter

Radius
  bind G = existsCoverageGroup(capability.radius)
  require G.editable AND compatible executor
```

Healing chain keeps assist legality; damage chain keeps attack legality. A spell containing both binds an explicit
branch/bundle, never every effect. A beam visual does not satisfy width. Summon count does not satisfy area radius.
Do not add a second chain to an existing native chain unless a composition policy defines its total target budget.

## Compatibility before and after transformations

1. Validate slot ownership, catalog/rank/variant, point budget, revision and mutually exclusive groups.
2. Resolve a structural dependency DAG. Gems may require capabilities introduced by earlier conversions, but
   cannot satisfy their own preconditions or depend on a cycle. Installation order does not set execution order.
3. Bind numeric gem selectors to the graph after structural gem transformations and structural keystone rules.
4. Resolve each modifier and all drawbacks; reject the complete candidate on unsupported or ineffective required
   drawback. Structural keystone changes revalidate already installed gems as one build transaction.
5. Return a server preview with affected effects, final numbers and conflict explanation; commit only the complete
   validated build. Losing a prerequisite never silently deletes a purchased gem or preserves an unpriced bonus.

When a new catalog disables a previously installed gem, preserve ownership and slot history, disable the whole
gem bundle, report the reason and offer a migration/refund policy. Client previews are advisory and never
authorize a transformation. Optional user confirmation is a future UI behavior, not permission to implement now.

## Sidegrades

| Variant | Modifier bundle | Additional compatibility requirement |
| --- | --- | --- |
| Focused Power | +2 Potency / -1 Coverage | Both payload potency and reducible coverage |
| Diffusion | +1 Coverage / -1 Potency | Magnitude above floor; legal geometry |
| Far Reach | +1 Range / +10% CastTime | Positive cast-time axis; no instant cast |
| Economy | +1 abstract Cost / -1 Potency | Nonzero discountable cost and potency |
| Risky Precision | +20% crit bonus damage / -5 percentage points crit chance | Crit-eligible payload, chance >=5% |
| Overcharge | +1 Potency / +10% concrete resource cost | Nonzero spendable resource component |
| Accelerated Decay | +1 Frequency / -1 Duration | Finite periodic schedule with at least one final tick |

Trade-off effectiveness is evaluated against the complete candidate without that gem's atomic bundle. If a penalty
is completely removed by clamping, unsupported axes or an override, the gem is incompatible. If other valid bonuses
offset a penalty numerically, the trace must still show a nonzero marginal penalty; this is a legal build choice.
Reject partially realized required penalties unless a variant explicitly prices that saturation. Damage crit bonus
versus total crit multiplier must be explicit; +20% bonus damage is not +20 percentage points crit chance.

Example: Focused Power on a 4-target, 100-base-magnitude chain yields 3 targets and 121 magnitude under v1.
On a 10-yard circular field it yields 9.091 yards and 121 magnitude. On a plain single-target heal with no
coverage axis it is incompatible; learning a character talent with no matching heal would instead be DORMANT.

## Proposed schema

| Table | Key | Fields |
| --- | --- | --- |
| `ulduar_gem_definition` | version, gem_id | scope, text/icon, rank/rarity/variant refs, release state |
| `ulduar_gem_modifier` | version, gem_id, variant_id, rank, modifier_id | target AST, operation, value, unit, group |
| `ulduar_gem_compatibility` | version, gem_id, variant_id, rule_id | requirement/exclusion AST, reason key |
| `character_ulduar_ability_gems` | guid, ability_instance_id, slot_id | gem_instance_id, variant, rank, revision |

Supporting gem rank, rarity, variant and modifier-group catalogs have versioned composite keys. Inventory ownership
links through gem_instance_id and enforces a unique installed instance; virtual legacy nodes use a separate grant
source instead of fabricating tradable items. Character ability_instance_id references classless spell ownership,
not a native rank that disappears after training. Index compatibility capabilities for browsing, then evaluate the
full AST on the server. Stable IDs in expressions are taxonomy/profile identifiers, not SpellID allowlists.

Persist all slots and point changes atomically with the character build revision. The current single-row ability
upsert is not a sufficient transaction for a multi-slot inventory mutation. Preserve existing EP independently
of future classless spell points and talent points.

## Existing code to retain

[AbilityTypes.h](../../modules/mod-ulduar-abilities/src/AbilityTypes.h) already has `IsPropagationCompatible`,
modifier masks and centralized costs. [AbilityManager.cpp](../../modules/mod-ulduar-abilities/src/AbilityManager.cpp)
`ApplyBuild` checks current ownership/class availability, revision, node support, total points and technical limits.
Generalize these checks into a capability evaluator and whole-build validator. There is no current GemDefinition,
rarity/variant library, signed stat system or installed-gem table; the existing UI edits fixed node ranks.
