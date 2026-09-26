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
| Channel beam | Drain Life / Mind Flay style | UNSUPPORTED | See [Beam audit](#beam-audit-drain-life-mind-flay). The beam is the channel spell's own client visual. A beam for an arbitrary ability needs a client carrier or patch. No catalog ability is a beam channel |
| Channel area / persistent area | Blizzard | UNSUPPORTED (boundary documented, design below) | The pulse is a **caster** aura, not a DynamicObject aura (see [Area audit](#area-audit-blizzard)). Blocked by rank matching and the unbound SQL, not by ownership |

Other channels (no payload spell and no matching adapter) are reported UNSUPPORTED by the inspector.

## Area audit (Blizzard)

Read from the client `Spell.dbc` (3.3.5a) and the core:

| Spell | Effect 0 | Effect 1 |
| --- | --- | --- |
| 10 Blizzard (controller, rank 1) | `PERSISTENT_AREA_AURA` (27), aura `DUMMY`, target `DEST_DYNOBJ_ENEMY`, radius index 14 | `APPLY_AURA` `PERIODIC_TRIGGER_SPELL` (23) on the **caster** (`UNIT_CASTER`), 1000 ms, triggers 42208 |
| 42208 Blizzard (payload, rank 1) | `SCHOOL_DAMAGE`, targets `DEST_CHANNEL_TARGET` + `UNIT_DEST_AREA_ENEMY`, radius index 14 | - |

**Findings**
- **Ownership.** The DynamicObject only carries the ground visual and a dummy aura. Timing is the controller's
  caster aura, exactly as for Arcane Missiles (5143 → 7268). No DynamicObject lookup is needed.
  - The existing snapshot path applies: the controller `OnHit` stores the immutable `AbilityCast` in its own
    caster aura (`aura_ulduar_ability_runtime::Controller`, a `shared_ptr`).
  - The triggered payload finds it through `GetTriggeredByAuraSpellInfo()` + `player->GetAura(parent, player)`.
  - No global state, no raw pointer across delays.
  - Casters are isolated: each has its own caster aura.
  - Each pulse is a new `Spell`, so it gets a new `AbilityPayloadEvent`.
- **Radius and selection.** They belong to the payload spell (`UNIT_DEST_AREA_ENEMY`, radius 14 around the
  channel destination), i.e. the Area component. The controller owns timing and interrupts (native channel).
- **Blocker 1: payload ranks are not a spell chain.**
  - The controller ranks 10, 6141, 8427, 10185, 10186, 10187, 27085, 42939, 42940 trigger 42208-42213,
    42198, 42937, 42938.
  - AzerothCore `spell_ranks` has no chain for 42208, so the current rule (`GetFirstSpellInChain(payload) ==
    PayloadSpellId`) matches rank 1 only.
  - Needed: a rank-agnostic match. The payload is eligible when its parent aura's chain root is the ability
    spell **and** the parent's `EffectTriggerSpell` is this payload id. The same rule would cover Arcane
    Missiles; it is not switched there, to avoid touching a working path.
- **Blocker 2: SQL binding.** It needs `spell_ulduar_ability_runtime` on -10 and on every payload id (no
  chain, so explicit ids), plus `aura_ulduar_ability_runtime` on -10. That is a pending world SQL change that
  cannot be applied or verified here.
- **Area hits have no single impact target.** The payload has no unit target (`PrimaryTarget` empty), so
  `AfterImpact` never propagates or echoes from a pulse. Per-hit parts still apply to every target:
  `Primary.Scaling`, conditions, conversion, element and crit rules. That is the safe default. Echo or
  propagation per pulse would need an explicit rule: which hit is the pulse's root.
- **Area modifiers.** `Area.Radius` and tick changes stay RESOLVED ONLY. The radius is the payload's
  `EffectRadiusIndex`, and native spell radius mods need a per-spell radius adapter.

**State: UNSUPPORTED (not enabled).** The mechanism is proven by the Arcane Missiles path. Enabling it needs
the rank-agnostic match, the SQL bindings and an in-game test. "Provably safe" is not met while none of the
three can be verified here.

## Beam audit (Drain Life, Mind Flay)

| Spell | Structure | Beam visual |
| --- | --- | --- |
| 689 Drain Life (rank 1) | One effect: `APPLY_AURA` `PERIODIC_LEECH` (53) on the channel target, 1000 ms. **No payload spell**: the ticks are aura ticks | channel spell visual 12655, drawn from `UNIT_CHANNEL_SPELL` + `UNIT_FIELD_CHANNEL_OBJECT` |
| 15407 Mind Flay (rank 1) | Dummy + `MOD_DECREASE_SPEED` on the target; effect 2 `PERIODIC_TRIGGER_SPELL_WITH_VALUE` (227) on the **caster**, 1000 ms, triggers 58381 with the per-tick value | channel spell visual 12637; the payload 58381 has no visual (0) |

**Findings**
- **The beam is the channel spell's own visual.** The client draws it from the channel fields. No server
  packet can attach a beam to a different spell.
- **Mind Flay has the emitter shape.** It is a caster aura that triggers a payload on the channel target, like
  Arcane Missiles. Its payload 58381 is shared by all ranks and takes its amount from the trigger value.
  - A Mind Flay adapter would reuse the emitter path with the rank-agnostic match above.
  - `Primary.Scaling` would apply on the payload hit.
  - The slow is a native aura on the target.
- **Drain Life has no payload.** Its damage and heal are the leech aura's ticks. `aura_ulduar_ability_runtime`
  does not scale `PERIODIC_LEECH` (see [PERIODIC_DAMAGE_PIPELINE_AUDIT.md](PERIODIC_DAMAGE_PIPELINE_AUDIT.md) §4).
  A Drain Life adapter would scale the aura amount; the payload-event model does not apply.
- **An arbitrary beam** (e.g. "Frostbolt as a beam") needs a native channel carrier whose client visual is
  the wanted beam. That means a client `Spell.dbc` row (CLIENT-PATCH-REQUIRED), or reusing an existing
  channel spell and showing its name and icon on the cast bar (CLIENT-REQUIRES-CARRIER). It is not faked.

**State: UNSUPPORTED.**

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
- Arcane Missiles, Blizzard, Mind Flay: the caster aura's amplitude drives the payload count;
- any channel whose ticks are not payload spells, e.g. Drain Life leech ticks.

## Delivery.Kind

Changing `Delivery.Kind` (Direct ↔ Projectile ↔ Beam) needs a delivery adapter; none exists.
`DeliveryChangeSupport` reports UNSUPPORTED, and the inspector lists it. A resolvable value is not gameplay
support.
