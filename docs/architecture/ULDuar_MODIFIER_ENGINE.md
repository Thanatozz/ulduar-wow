# Ulduar modifier engine

Code: `src/engine/AbilityModel.h` (`AbilityModifier`), `AbilityResolver.{h,cpp}`, `ModifierLayers.{h,cpp}`.
Consistent with [ULDuar_RESOLUTION_PIPELINE.md](ULDuar_RESOLUTION_PIPELINE.md): immutable structural snapshot,
provenance per contribution, additive percentages summed, multiplicative groups multiplied, single rounding.

## Modifier

```
AbilityModifier
  Source      { Kind: Core|GameMode|Talent|Equipment|Aura|Essence|DeveloperLab, Id, Label }
  Operation   SET ADD SUBTRACT MULTIPLY PERCENT_ADD ENABLE DISABLE CLAMP_MIN CLAMP_MAX
              ADD_COMPONENT REMOVE_COMPONENT ADD_EFFECT REMOVE_EFFECT
  Property    AbilityProperty (value operations)
  Component   (component operations)
  EffectKey   effect-scope target, 0 = every effect
  Value       typed PropertyValue
  NewEffect   (ADD_EFFECT payload)
  Conditions  [] (empty = unconditional; structural ops cannot be conditional)
```

Every modifier is validated on entry (`ValidateModifier`): operation allowed for the property type, enum value
in range, finite number, effect key rules, no removal of core components. Invalid modifiers are dropped with a
warning and never partially applied.

## Resolution order

| Stage | Work |
| --- | --- |
| 1 | Copy the Core (never mutated) |
| 2 | Components and effects: additions, then removals (removal wins); effects ordered by key |
| 3 | SET / ENABLE / DISABLE: one winner by precedence |
| 4 | Flat: sum of ADD and SUBTRACT |
| 5 | Multipliers: `x (1 + sum(PERCENT_ADD)/100)`, then `x product(MULTIPLY)` |
| 6 | Conditional modifiers (same sub-order) per combat event via `ValueWithContext` |
| 7 | Explicit clamps from mechanics (CLAMP_MIN = max of mins, CLAMP_MAX = min of maxes), then configured balance limits |
| 8 | Technical validation: values violating a technical minimum of an INVALID property reject the ability (not repaired by a balance clamp); other technical bounds clamp; cross-property rules (Range.Min <= Range.Max, InnerRadius < Radius, Delivery.Kind has its component, active periodic/channel/persistent/charges/displacement need positive intervals/speeds) |
| 9 | Rounding (ms, counts, ids) and semantic resolution (Instant, NoCooldown, Free, ...), reported as diagnostics |

Example: Damage 100, `ADD 50`, `MULTIPLY 1.20` -> `(100 + 50) x 1.20 = 180`.

## Determinism and precedence

- Arithmetic is commutative within a stage, so modifier/socket order cannot change results.
- SET conflicts: higher source kind wins (DeveloperLab > Essence > Aura > Equipment > Talent > GameMode > Core),
  then higher source id. Equal precedence with different values: larger number / larger enum wins, DISABLE beats
  ENABLE; a `SetConflict` warning is emitted. An individual mechanic that must be order sensitive has to say so
  explicitly in its own data; none does today.
- Contributions are listed in a stable order (operation, precedence) for the inspector.

## Sources and layers

`ModifierLayerStore` holds, per (player GUID, ability id), one list per source kind. The resolved result is
cached as `shared_ptr<ResolvedAbility const>` and invalidated when:

| Event | Mechanism |
| --- | --- |
| Lab/Essence/any layer changed | per-entry stamp (monotonic) |
| Ability rank / canonical design changed | `AbilityCore::Revision` (= ranked spell id) |
| Configuration reload (limits) | global generation (`InvalidateAll` from `AbilityManager::Configure`) |
| Logout / character deletion | `ForgetOwner` |

Talent, equipment and aura layers are representable (source kinds exist) and will call `ReplaceLayer` on their
own change events; they are not wired yet.

## Clamp and trace reporting

Each touched property records base, contributions (source + operation + value + conditional flag), calculated
value, every clamp (explicit / balance with its config key / technical) and final value. The inspector renders
this; balance clamps are never silent.
