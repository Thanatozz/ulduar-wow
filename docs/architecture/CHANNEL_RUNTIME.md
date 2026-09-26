# Channel runtime

Code:
- `src/AbilitySpellScript.cpp` (controller and payload `Load`, `ControllerScript`)
- `aura_ulduar_ability_runtime` (controller snapshot)
- `src/engine/PayloadMatching.*` (`MatchControllerPayload`, `InferControllerPayloads`,
  `PayloadHitIsExecutionRoot`)
- `src/AbilityManager.cpp` (inferred payload index, per-definition binding check)
- `src/engine/ExecutionModel.*` (`ClassifyChannel`, `ChannelAdapterSupport`, `PlanChannelPayloads`,
  `DeliveryChangeSupport`)
- `src/AbilityEngineBridge.cpp` (inspector report)

Tests: `UlduarChannelRuntime.*`, `UlduarChannelPayload.*` (pure rules only).

## Taxonomy

The three axes stay independent:
- **Cast behavior:** Channel is a cast/temporal concept.
- **Delivery:** Projectile, Beam and Area are delivery concepts.
- **Temporal behavior:** channel ticks, periodic auras, persistent-area ticks.

A channel is **not** "cast the spell again every tick".

## Audit of the current runtime

Runtime-enabled channels:
- **Arcane Missiles** (RUNTIME): controller 5143 (channel, periodic-trigger aura on the caster), payload 7268
  (the native missile).
- **Blizzard** (RUNTIME CODED / REQUIRES SQL / REQUIRES IN-GAME TEST): controller 10, area payload 42208.
  Without its pending SQL, only this definition stays metadata (`DisableWhenUnbound`).

**Channel controller**
- The controller cast builds the immutable `AbilityCast` (runtime context and engine resolution) in `Load`.
- `OnHit` stores it in the controller aura's `AuraScript` (`Controller`).
- The controller itself never propagates or echoes (`_controller`).
- Channel state, duration, interruption and tick timing remain native.

**Payload event**
- Each triggered payload that matches this player's controller (see
  [Controller -> payload matching](#controller---payload-matching)):
  - copies the snapshot;
  - sets `RankedSpellId` to the payload rank;
  - creates a **new `AbilityPayloadEvent`** with its own visited set, hop history and secondary counter.
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
| Channel projectile emitter | Arcane Missiles | RUNTIME (generic matcher, no spell-id branch; presentation path unchanged) | ranks, interrupts and simultaneous casters REQUIRE IN-GAME TEST |
| Channel area emitter | Blizzard | RUNTIME CODED / REQUIRES SQL (`ulduar_abilities_006_world_blizzard.sql`) / REQUIRES IN-GAME TEST; inspector PARTIAL | per-hit parts only; no propagation or echo from an area pulse (see [Area emitter](#area-emitter-blizzard)) |
| Channel emitter with beam visual | Mind Flay | ARCHITECTURE-SUPPORTED (matcher unit tested); not in the catalog, no bindings | [Beam audit](#beam-audit-drain-life-mind-flay); the beam visual stays native to the controller |
| Channel aura tick | Drain Life | UNSUPPORTED, separate `ChannelAuraTick` adapter required | no payload spell; its ticks are the channel aura's `PERIODIC_LEECH` |
| Arbitrary channel beam | "Frostbolt as a beam" | UNSUPPORTED | the beam is the channel spell's own client visual: client carrier or patch |

Other channels (no payload spell and no matching adapter) are reported UNSUPPORTED by the inspector.

## Controller -> payload matching

`Engine::MatchControllerPayload` accepts a triggered spell as the controller's payload only when all of these
hold:

1. It was triggered by an aura (`Spell::GetTriggeredByAuraSpellInfo`). Casts and procs are rejected
   (`NOT_AURA_TRIGGERED`).
2. The parent aura spell belongs to the ability's native controller rank chain (`NOT_CONTROLLER` otherwise).
3. One of the parent's `PERIODIC_TRIGGER_SPELL` (23) or `PERIODIC_TRIGGER_SPELL_WITH_VALUE` (227) effects
   names exactly this payload id (`NOT_TRIGGERED_BY_PARENT` otherwise).
4. The parent aura is on the caster and cast by the caster (`player->GetAura(parent, player)`). Another
   caster's controller is `FOREIGN_AURA`.
5. That aura carries the immutable controller snapshot (`NO_SNAPSHOT` otherwise).

The payload needs **no SpellMgr rank chain**. The payload ids are inferred at startup from the controller
ranks' trigger effects (`InferControllerPayloads`, `AbilityManager::ControllerPayloads`), so no gameplay
branch lists them:
- Arcane Missiles: 5143..42846 → the 7268 chain (rank 4 → 8419, rank 5 → 8418, as in the native data);
- Blizzard: 10, 6141, 8427, 10185, 10186, 10187, 27085, 42939, 42940 → 42208-42213, 42198, 42937, 42938;
- Mind Flay: every rank → 58381.

Safety:
- No global state: a one-time startup index plus per-spell `Aura` lookups.
- No stored pointers: the snapshot is a `shared_ptr` on the caster's own aura script.
- Simultaneous casters stay isolated: rule 4.

**Arcane Missiles regression.** The matcher accepts exactly the missile ranks the old chain rule accepted
(each rank's aura triggers its own missile rank). The payload event, propagation history, echo, snapshot,
presentation and channel handling are unchanged.

**Startup bindings.** `CheckDatabase` checks every controller and every inferred payload for its
`spell_ulduar_ability_runtime` binding, and every aura spell for `aura_ulduar_ability_runtime`. A binding is
accepted by rank chain (negative first rank) or by exact id.
- A missing binding on a normal definition still disables the module (fail closed, unchanged).
- On a `DisableWhenUnbound` definition (Blizzard) it disables only that definition.

## Area emitter (Blizzard)

Read from the client `Spell.dbc` (3.3.5a) and the core:

| Spell | Effect 0 | Effect 1 |
| --- | --- | --- |
| 10 Blizzard (controller, rank 1) | `PERSISTENT_AREA_AURA` (27), aura `DUMMY`, target `DEST_DYNOBJ_ENEMY`, radius index 14 | `APPLY_AURA` `PERIODIC_TRIGGER_SPELL` (23) on the **caster** (`UNIT_CASTER`), 1000 ms, triggers 42208 |
| 42208 Blizzard (payload, rank 1) | `SCHOOL_DAMAGE`, targets `DEST_CHANNEL_TARGET` + `UNIT_DEST_AREA_ENEMY`, radius index 14 | - |

**Ownership.** The DynamicObject only carries the ground visual and a dummy aura. The controller's caster aura
owns timing and interrupts; the payload owns radius and selection (`UNIT_DEST_AREA_ENEMY`, radius 14), i.e.
the Area component. So no DynamicObject lookup is needed.

**Payload semantics (as coded).**
- Each pulse is a new `Spell`, hence its own `AbilityPayloadEvent`.
- Every enemy hit by the pulse gets the per-hit parts:
  - `Primary.Scaling`;
  - conditions;
  - element conversion;
  - periodic conversion (carrier or executor, per target);
  - effect activation, when effects run.
- **No root from an arbitrary victim.** The payload targets an area (`SpellEffectInfo::IsTargetingArea`), so
  `Engine::PayloadHitIsExecutionRoot` is false. The pulse never starts Split/Shatter/Chain/Nova at launch or
  impact, and never schedules an echo, until an explicit Area-root rule is designed.
- `Area.Radius` and channel tick changes stay RESOLVED ONLY: the radius is the payload's
  `EffectRadiusIndex`, and a radius adapter would be per spell.

**SQL.** `ulduar_abilities_006_world_blizzard.sql` binds `spell_ulduar_ability_runtime` and
`aura_ulduar_ability_runtime` to -10, and `spell_ulduar_ability_runtime` to each exact payload id (no chain).
Created, not applied.

**State:** RUNTIME CODED / REQUIRES SQL / REQUIRES IN-GAME TEST.

## Beam audit (Drain Life, Mind Flay)

| Spell | Structure | Beam visual |
| --- | --- | --- |
| 689 Drain Life (rank 1) | One effect: `APPLY_AURA` `PERIODIC_LEECH` (53) on the channel target, 1000 ms. **No payload spell**: the ticks are aura ticks | channel spell visual 12655, drawn from `UNIT_CHANNEL_SPELL` + `UNIT_FIELD_CHANNEL_OBJECT` |
| 15407 Mind Flay (rank 1) | Dummy + `MOD_DECREASE_SPEED` on the target; effect 2 `PERIODIC_TRIGGER_SPELL_WITH_VALUE` (227) on the **caster**, 1000 ms, triggers 58381 with the per-tick value | channel spell visual 12637; the payload 58381 has no visual (0) |

**Findings**
- **The beam is the channel spell's own visual.** The client draws it from the channel fields. No server
  packet can attach a beam to a different spell. Beam presentation is outside this runtime.
- **Mind Flay: architecture-supported.** It has the emitter shape: a caster aura (type 227, with value)
  triggers 58381 on the channel target each second, shared by all ranks.
  - The generalized matcher accepts it (unit tested with rank data), and the payload is a single-target
    execution root.
  - It is **not in the catalog** and has no bindings. Enabling it would need a definition (controller
    15407, `PayloadSpellId` 58381), bindings for -15407 (spell + aura) and 58381, and an in-game test.
  - The slow stays a native aura on the target.
- **Drain Life: separate adapter.** It has no payload spell: its damage and heal are the channel aura's
  `PERIODIC_LEECH` ticks on the target.
  - The payload-emitter adapter does not apply and is not forced onto it.
  - A future `ChannelAuraTick` adapter would scale the leech aura's amount through the controller snapshot
    (the controller aura is on the target, cast by the caster) and needs its own leech rules.
  - Not implemented.
- **An arbitrary beam** (e.g. "Frostbolt as a beam") needs a native channel carrier whose client visual is
  the wanted beam: a client `Spell.dbc` row (CLIENT-PATCH-REQUIRED), or reusing an existing channel spell and
  showing its name and icon on the cast bar (CLIENT-REQUIRES-CARRIER). It is not faked.

**State:** Mind Flay ARCHITECTURE-SUPPORTED (not enabled); Drain Life and arbitrary beams UNSUPPORTED.

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
