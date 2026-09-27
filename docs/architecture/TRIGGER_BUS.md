# Trigger bus

Code: `src/engine/TriggerBus.*` (mod-ulduar-abilities). Tests: `UlduarTriggerBus.*`
(`tests/AbilityTriggerBusTest.cpp`). **State: ENGINE MODEL + PURE TESTS.** No runtime publisher or subscriber
yet; wiring waits for checklist Stage J0 PASS and the effect runtime.

One central bus for every triggered effect (Imbue, Emitter, procs). There are no per-kind proc systems.

## Events

Cast, Hit, Crit, Tick, Heal, Overheal, DamageTaken, Kill, Dispel, PeriodicApplied, PeriodicExpired, AuraApplied,
AuraRemoved (plus the other `TriggerEvent` values of the model). Outgoing events are offered to the **caster's**
subscriptions; incoming ones (DamageTaken, Attacked, Block, Dodge, Parry) to the **target's**.

Event data (`TriggerEventData`): event id, parent id, root id, caster and target as raw GUIDs (never `Unit*`: a
delayed activation re-resolves them and fails closed), AbilityId, EffectKey, lineage, EchoGeneration, school
mask, amount, crit, periodic flag, `ExecutionContext` (role + FromEcho), ancestry (list of
(AbilityId, EffectKey)), attack speed for PPM.

## Per-subscription rules (in order)

1. event type = `Effect.TriggerEvent`, and the subscription owner is the event's subject;
2. `Effect.TriggerSourceFilter` / `TriggerTargetFilter` (relation supplied by the runtime);
3. `Effect.ActivationMask` against the event's context (the only activation authority; echo events need the
   Echo bit);
4. `TriggerChance` = 0 and no PPM → never;
5. proc-from-proc only with `Effect.CanProcFromProc`; the same (AbilityId, EffectKey) twice in one ancestry is a
   loop; depth ≥ min(`Effect.MaxProcChainDepth`, global `MaxProcChainDepth`) is refused;
6. internal cooldown (`Effect.InternalCooldown`, per subscription: per player and per effect);
7. charges (`Effect.Charges`, 0 = unlimited);
8. at most 32 activations per event (`MaxActivationsPerEvent`);
9. roll: `Effect.ProcsPerMinute` > 0 wins over `TriggerChance`: chance = PPM × attack speed / 60 s (WotLK rule;
   events without an attack speed never proc from PPM). A family with another natural frequency (periodic
   ticks, spell casts) must pass its own normalizing "speed" (e.g. tick interval); this is decided per publisher.

`ConsumptionRule`: None (charges never spent), OnTrigger (one charge per activation), OnHit (one charge per
qualifying Hit event, whether or not the roll succeeds). A spent subscription ends.

An activation returns a **child event template**: parent/root ids, ancestry + this effect, role Proc, same
lineage. `MayScheduleEcho` is always false: echoes are planned only by the player's own cast.

## Tests present

Routing and subject, unit filters, activation mask and echo lineage, chance and PPM, ICD, charges OnTrigger and
OnHit, proc chain safety (loop, not-from-proc, root id), depth + per-ability keys, agreement with
`CanTriggerProc` for one ability, event ids and budget, owner removal.

Still to add with the runtime publisher: ChanceZeroNeverProcs / Chance100AlwaysProcs as named tests,
DifferentPlayersHaveIndependentICD, DifferentEffectsHaveIndependentICD, PeriodicTriggerPreservesAncestry (the
current tests cover the rules; these names map them to the milestone list).
