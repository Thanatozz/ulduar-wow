# Ulduar Developer Ability Lab

Code: `src/AbilityLabCommands.cpp`, `src/engine/ModifierLayers.cpp`, `src/engine/AbilityInspector.cpp`.

The Lab is the testing interface of the modifier engine. It has **no special powers**: it only writes
`AbilityModifier`s into the `DeveloperLab` layer of the GM's own character, the same representation Essences
use. It never rewrites the canonical ability, other players, SpellInfo or the database.

## Access

- GM permission (`RBAC_PERM_COMMAND_GM`) **and** `UlduarAbilities.DebugEditor = 1`.
- Production: `UlduarAbilities.DebugEditor = 0` (default). The server logs a warning at startup when it is on.
- Layers are session-only: they are dropped on logout/character deletion.

## Commands

Adapted to the existing `.ua` command tree (`.ua lab ...`); the specification's names map as follows.

| Specification | Command | Effect |
| --- | --- | --- |
| `.ua editor` (set) | `.ua lab set <ability> <Property> <op> <value>` | Add one modifier. Ops: `set add subtract multiply percent_add enable disable clamp_min clamp_max` or `= + - x % on off min max`. Times accept `2.5s` or ms |
| - | `.ua lab component <ability> <add\|remove> <component>` | Structural modifier |
| - | `.ua lab addproc <ability> <key> <spellId> <chance>` | ADD_EFFECT (Proc) |
| - | `.ua lab effect <ability> <key> <Effect.Property> <op> <value>` | Effect-scope modifier |
| `.ua modifier list` | `.ua lab list <ability>` | Numbered developer modifiers |
| - | `.ua lab remove <ability> <index>` | Remove one |
| `.ua modifier clear` / RESET | `.ua lab clear [ability\|all]` | Drop the layer |
| `.ua preset load` | `.ua lab preset <ability> <name>` | Append a preset's modifiers |
| `.ua preset save` | `.ua lab save <name> <ability>` | Save the current layer (server memory, this run) |
| - | `.ua lab presets` | Built-in and saved presets |
| - | `.ua lab properties [filter]` | Registry listing with types and zero semantics |
| `.ua inspect` / `.ua resolved` | `.ua lab inspect <ability>` | Inspector + runtime capability report |

Every mutating command prints the inspector afterwards, including `RUNTIME:` lines (values the current
runtime executes) and `RESOLVED ONLY (not executed yet):` lines.

## Built-in presets

| Name | Modifiers |
| --- | --- |
| instant | Casting.CastTime SET 0 |
| nocooldown | Casting.Cooldown SET 0 |
| movingcast | Casting.CanCastWhileMoving ENABLE (non-channeled casts) |
| chain | Projectile.Targets +4, AcquisitionRange +18, Scaling x0.60, Origin PreviousTarget |
| split | Projectile.Targets +2, Origin Caster, SpreadAngle 30 |
| shatter | Projectile.Targets +2, Origin PrimaryTarget, Scaling x0.50 |
| nova | ADD Area, Origin PrimaryTarget, Radius 8, Scaling 50 |
| dot | ADD Periodic, Conversion 60, Duration 12 s, Tick 3 s, CanHaste, CanCrit |
| spreaddot | dot + CanSpreadOnTick, SpreadQuantity 2, SpreadRadius 8, SpreadStackCount 1 |
| echo | ADD Echo, Chance 50, MultiEcho, MaxEchoCount 3, multiplicative decay x0.5 |

Preset names describe engine primitives, not spells: `chain` on Frostbolt and `chain` on Shadow Bolt are the
same data.

## Example session

```
.ua lab set frostbolt Casting.CastTime subtract 2.5s     -> CastTime 0 sec, Semantic INSTANT, RUNTIME: Casting.CastTime
.ua lab set frostbolt Casting.Cooldown set 0             -> NO COOLDOWN
.ua lab preset frostbolt chain                           -> RUNTIME: Secondary targets via Chain
.ua lab set frostbolt Range.Max add 60                   -> Balance maximum 80 yd; RUNTIME: Range.Min/Max (server check)
.ua lab save frostbolt_chain_test frostbolt
.ua lab clear frostbolt
```

## Addon UI

`/ua lab` (or `/ualab`) opens the Ability Lab window of the `UlduarAbilities` addon
(`client/Interface/AddOns/UlduarAbilities/AbilityLab.lua`, `LabProtocol.lua`). It is a form over the chat
commands above: ability, property/operation/value, presets (load, list, save), components (add/remove),
list/remove-by-index/clear, and an output pane that shows the server's inspector with `RUNTIME:` lines in green,
`RESOLVED ONLY` in orange and rejections in red.

Transport: the core's addon command channel (`AddonChannelCommandHandler`, prefix `AzerothCore`). The addon
sends `h<counter>ua lab <args>` as a WHISPER to itself; the server runs exactly that `.ua lab` command with the
normal RBAC checks and returns `a` (ack), `m<counter><line>` per output line, then `o` (ok) or `f` (failed).
No module protocol code was added and the UI has no extra authority: without GM access or with
`UlduarAbilities.DebugEditor = 0` the server answers with the same refusal the chat command gives. Arguments
are restricted client-side to single tokens (letters, digits, `. _ % + -`), so a request cannot carry a second
command or chat escape codes. One request is in flight at a time, with an 8 second timeout.

## Not done yet

- Persistent developer presets.
- Inspecting another player's resolution.
- Multi-word ability names (the chat command takes one token).
