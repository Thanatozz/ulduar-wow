# Channel runtime

Code:
- `src/AbilitySpellScript.cpp` (controller and payload `Load`)
- `aura_ulduar_ability_runtime` (controller snapshot)
- `src/engine/ExecutionModel.*` (`ClassifyChannel`, `ChannelAdapterSupport`, `PlanChannelPayloads`,
  `DeliveryChangeSupport`)
- `src/AbilityEngineBridge.cpp` (inspector report)

Tests: `UlduarChannelRuntime.*` (pure rules only).

## Taxonomy

The three axes stay independent:
- **Cast behavior:** Channel is a cast/temporal concept.
- **Delivery:** Projectile, Beam and Area are delivery concepts.
- **Temporal behavior:** channel ticks, periodic auras, persistent-area ticks.

A channel is **not** "cast the spell again every tick".

## Audit of the current runtime

The only runtime-enabled channel is Arcane Missiles: controller 5143 (channel, periodic-trigger aura on the
caster), payload 7268 (the native missile). Blizzard is metadata-only (`RuntimeEnabled = false`).

**Channel controller**
- The controller cast builds the immutable `AbilityCast` (runtime context and engine resolution) in `Load`.
- `OnHit` stores it in the controller aura's `AuraScript` (`Controller`).
- The controller itself never propagates or echoes (`_controller`).
- Channel state, duration, interruption and tick timing remain native.

**Payload event**
- Each triggered payload spell whose parent aura is this player's controller aura (same spell chain, same
  caster) copies the snapshot, sets `RankedSpellId` to the payload rank, and creates a **new
  `AbilityPayloadEvent`** with its own visited set, hop history and secondary counter.
- `EventId` is the tick number.
- Unrelated triggered or proc spells never adopt it: the parent aura must carry the script snapshot.
- Simultaneous casters each have their own aura.

**Delivery adapter**
- The payload is the native missile spell, so the normal Spell pipeline handles hit, crit, mitigation, procs and
  ownership.
- Secondaries and echoes cast the payload rank, never the controller, so the channel never restarts.

**Propagation ownership**
- Propagation history is per payload event: missiles propagate independently.
- Sharing history across a whole channel would need an explicit future property.

**Echo interaction**
- Each payload may echo ([ECHO_RUNTIME.md](ECHO_RUNTIME.md)); the echo replays that payload.
- Missiles, secondaries and echoes already in flight complete after an interrupt; no new ticks start.

**Effect interaction**
- Payload hits are Primary-role hits; their propagation copies are Secondary
  ([EFFECT_ACTIVATION.md](EFFECT_ACTIVATION.md)).

## Adapter matrix

| Pattern | Example | State | Boundary |
| --- | --- | --- | --- |
| Channel projectile emitter | Arcane Missiles | RUNTIME (existing controller/payload design, generic via `PayloadSpellId`, no spell-id branch) | ranks, interrupts and simultaneous casters REQUIRE IN-GAME TEST |
| Channel beam | Drain Life / Mind Flay style | UNSUPPORTED | 3.3.5 draws channel visuals from `UNIT_CHANNEL_SPELL` + `UNIT_FIELD_CHANNEL_OBJECT` (`Spell.cpp` channel setup): the beam is the channel spell's own client visual. A beam for another spell needs a native channel carrier with that visual (client DBC). A server-only beam cannot be fabricated, and no catalog ability is a beam channel |
| Channel area / persistent area | Blizzard | UNSUPPORTED | The pulse comes from a dynamic-object aura (periodic trigger on a DynamicObject), not a caster aura. The payload `Load` only resolves caster auras, so the adapter needs a dynobject-aura lookup plus its script snapshot, and in-game verification. The Area component, not the channel, would own radius and selection |

Other channels (no payload spell and no matching adapter) are reported UNSUPPORTED by the inspector.

## Channel modifiers

`Casting.ChannelTime` and `Casting.ChannelTickInterval` stay **RESOLVED ONLY**. The default Ulduar policy is
**total-output preservation**:

- **Rule.** `PlanChannelPayloads` keeps the native payload total and spreads it over the resolved payload count.
- **Examples.** A 0.5 s interval on a 5 x 1 s channel gives 10 payloads at 50%. A longer channel at the same
  rate gives more payloads, each smaller.
- **Opt-in.** A modifier or Essence that increases payload count or output must say so explicitly.

It is not applied because native payload timing belongs to the channel aura's amplitude. Changing it safely
needs a per-adapter rule: the aura periodic timer, plus payload scaling through the snapshot. Doing it
generically could duplicate or delete native payloads.

Native abilities that cannot follow the generic rule without an adapter:
- Arcane Missiles: the aura amplitude drives the missile count;
- Blizzard: dynamic-object aura;
- any channel whose ticks are not payload spells, e.g. Drain Life leech ticks.

## Delivery.Kind

Changing `Delivery.Kind` (Direct ↔ Projectile ↔ Beam) needs a delivery adapter; none exists.
`DeliveryChangeSupport` reports UNSUPPORTED, and the inspector lists it. A resolvable value is not gameplay
support.
