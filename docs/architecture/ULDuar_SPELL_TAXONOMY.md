# Ulduar universal spell taxonomy

Status: proposed architecture, 2026-09-14. No runtime implementation or build is implied.
The [gap analysis](ULDuar_GAP_ANALYSIS.md) identifies verified existing behavior and implementation priorities.
The [metadata contract](ULDuar_ABILITY_METADATA.md) defines storage, provenance and conversions.

## Fundamental model

An ability is a stable Ulduar identity backed by a native spell rank chain. A cast is one execution of a versioned
ability. An effect is an independently addressable operation within that execution. An aura, field or summon can
outlive the cast. Triggered payloads are graph edges to other spells, not additional ranks or merged effects.

Keep native effect slots 0, 1 and 2, including empty slots, in the import. Derived effects use stable semantic keys
and parent references; they must not overwrite slot identities. A native effect applying a periodic aura has both an
application operation and a tick payload. Targeting, school and time predicates bind to the payload being modified.

Do not model activation with one exclusive enum: a triggered spell can have a cast-time definition, and a channel
can launch projectiles. Store invocation, cast schedule and attack binding separately. Likewise, delivery is not
geometry: a visually narrow beam can have a single-target hit model with no editable width.

All values are typed. `Unknown`, `NotApplicable`, `Inherited` and an explicit zero are distinct. An unavailable
adapter is `Unsupported`, not a false capability. Preserve unknown native flags and source values for later review.
Tags are namespaced semantic assertions with provenance, not substitutes for numeric fields.

## Dimension dictionary

S = spell/ability, E = effect or payload, A = aura, F = field, U = summon, C = cast/runtime.
Defaults may originate at S; E overrides require a supported execution adapter. Derived S summaries are for search
only. An `exists E` selector must test all its effect predicates on the same E.

| Dimension | Scope | Canonical properties and semantics |
| --- | --- | --- |
| Identity | S/E | Ability ID, native base/ranked spell, rank chain, family, category, source class, source effect |
| Provenance | S/E | Source spell, controller/payload edges, source revision, tags, importer and reviewer versions |
| Activation | S/C | Invocation: manual, triggered, proc, passive; schedule: instant, cast time, channel |
| Attack binding | S/E | Independent spell, next melee swing, melee ability, ranged weapon shot, auto-repeat |
| Targeting | S/E | Unit, self, ground, direction, caster area, target area; implicit target A and B preserved |
| Target anchors | E/C | Caster, explicit unit, source, destination, last hop; position plus map/phase/transport |
| Target relation | E | Enemy, ally, self, party, raid, any; never inferred solely from damage versus healing |
| Target object | E | Unit, corpse, pet, creature, game object, item, destination; live/dead and creature masks |
| Geometry | E/F | Point, circle, cone, line, beam, ring, arc, chain, custom; explicit dimensional capabilities |
| Delivery | E | Direct, projectile, beam, area, persistent area, triggered payload, attached aura |
| Propagation | E | Original, impact, split, shatter, chain, nova, bounce, spread, repeat; strategy and event policy |
| Coverage | E/F | Max targets, target cap, radius, angle, width, length, hop range, spread angle, density, falloff |
| Range | S/E | Minimum/maximum acquisition and effect range; hostile/friendly variants; contact reach policy |
| Temporal | E | Instant, delayed, periodic, channel ticks, persistent ticks; schedule origin and snapshot policy |
| Duration | S/A/F/U | Cast/channel duration, aura duration, field lifetime, summon lifetime; finite/permanent |
| Frequency | E/A/F | Tick interval, pulse interval, channel rate; initial/final tick and refresh phase policies |
| Potency | E | Typed damage, healing, absorb, control strength, displacement strength, resource amount |
| Cost | S/C | Resource components, raw amount, percent basis, normalized amount, per-second cost, multiplier |
| Resources | S/E/C | Mana, rage, energy, health, blood/frost/unholy/death runes, runic power, combo points, custom |
| Resource flow | S/E | Consumption, generation, refund; transaction scope, target binding, resource precision |
| Cooldown | S/C | Own cooldown, category timer, GCD, event-start policy, charges, recharge and shared pool |
| Speed | S/E | Cast rate, projectile velocity, channel rate, tick rate; independent axes, explicit adapters |
| School | S/E | Physical, holy, fire, nature, frost, shadow, arcane bitmask; inherited and effective masks |
| Scaling | E | Flat base, level, SP, AP, weapon, max/missing health, armor, resource, custom coefficients |
| Critical | E | Eligibility, chance, chance modifier, additive bonus, multiplier, special outcome policy |
| Reliability | E/C | Hit, miss, resist, dodge, parry, block, immunity; defense type and resolution order |
| Aura | A/E | Aura type, stacks/max stacks, refresh/replace rules, duration, dispel type, polarity by context |
| Control | E/A | Stun, root, slow, silence, fear, disarm, interrupt, taunt, charm, confuse, sleep, banish |
| Control policy | E/A | Diminishing-return group, break conditions, mechanic immunity, school lockout duration |
| Displacement | E | Knockback, knock-up, pull, charge, leap, teleport, dash; direction, distance, speed, collision |
| Mobility | S/C | Cast/channel while moving, movement interrupt flags, turning limits, facing requirements |
| Threat | E | Flat threat, multiplier, zero-threat, redirect, forced aggro, taunt; logical owner attribution |
| Triggers | E/C | Typed event subscription, subject, phase, payload, proc chance/model, charges and internal cooldown |
| Conditions | S/E/C | Health, distance, movement, facing, stealth, combat, casting, auras, creature and weapon state |
| Restrictions | S/E | Weapon, stance/form, stealth, combat, mounted, movement, target, resource and location rules |
| Mechanic tags | S/E | Bleed, poison, disease, curse, magic, shield, stealth, pet, summon, totem, trap |
| Mechanic tags | S/E | ComboPoint, Rune, Transformation, Stance, Form, WeaponAttack; preserve semantic distinctions |
| Summon | E/U | Creature, guardian, pet, totem, trap, object; duration, ownership, controller, limits, inheritance |
| Visual | S/E/C | Cast, missile, impact, persistent, beam assets; emitter, source/destination and fallback policy |
| Audio | S/E/C | Cast, impact, loop, expiration references; packaged visual-kit restrictions remain explicit |
| Conversion | S/E | Typed transformation graph with preconditions, output fields, affected effects and legality proof |

Further native properties stay representable: reagents, ammo, equipped item class/subclass/inventory masks,
totem categories, spell focus, area restrictions, facing flags, aura-state requirements, pushback, interrupts,
reflection, dispel resistance, range collision reach, target level, chain attenuation and spell-specific scripts.
These belong in typed restriction, reliability, scaling or adapter extensions, not an opaque `misc` gameplay field.

## Geometry and propagation are independent

Original means preserve native topology; current `AbilityPropagationMode::None` maps to Original. Impact selects
neighbors at a successful impact. Split emits siblings at launch. Shatter emits from impact with projectile
delivery. Chain acquires one successor after success. Nova emits radially around its declared anchor. Bounce may
alternate relations or revisit under an explicit gap. Spread copies a declared aura payload; it must not copy
the entire spell. Repeat executes a scheduled payload a finite number of times. Chain geometry alone does not
authorize arbitrary new triggers or repeated resource generation.

Each propagation edge declares its effect bundle: damage only, damage plus slow, healing only, and so on.
Controller, generation and resource-consumption effects are excluded unless explicitly authorized. The original
combo-point generator of an attack is not reproduced for every secondary target.

Separate gameplay target cap from a hard execution safety cap. `Unlimited` means no gameplay cap, never unlimited
server work. Reaching a safety limit emits a diagnostic. Radius, range and density are not target counts.

## Multi-effect selection examples

| Ability archetype | Decomposition | Meaningful generic selector |
| --- | --- | --- |
| Direct damage plus slow | Damage impact E0; ApplyAura(Slow) E1 | Frost damage matches E0, control matches E1 |
| Moonfire-like hybrid | Direct damage; periodic aura application and damage ticks | Periodic damage targets ticks |
| Weapon finisher | Weapon damage plus conditional combo-point consumption | Finisher tag retains resource logic |
| Channel projectile | Channel controller; repeated child projectile impacts | Separate channel and missile speed |
| Ground damage field | Placement; field lifetime; area tick payload | Coverage radius; frequency pulse interval |
| HoT | Ally aura application; periodic healing ticks | Healing duration is aura lifetime |
| Shield | Ally aura; absorb pool and expiration | Absorb potency; no automatic damage coefficient |
| Interrupt | Enemy cast cancellation; school lockout | Interrupt event and lockout duration, not damage |
| Pet summon | Summon controller; pet attacks with owner provenance | Summon selectors do not imply pet-attack bonuses |
| Charge | Movement operation; contact damage/control | Collision and arrival govern contact payload |
| Proc passive | Persistent subscription; triggered effect | Character subject or source-event effect selector |
| Dispel | Eligible aura selection; removal operation | Dispel type/count, not generic enemy damage |

Counterexample: a spell with Fire direct damage and Frost slow is not Periodic Frost Damage. Aggregating school,
effect and temporal flags across independent effects would produce a false match. Search may show both tags;
talent eligibility and runtime selection may not use that lossy aggregate.

## Native evidence and extension boundary

[DBCStructure.h](../../src/server/shared/DataStores/DBCStructure.h) `SpellEntry` preserves three independent
effect arrays, family masks, equipment restrictions and school bitmask. `SpellRangeEntry` has hostile/friendly
minimum and maximum values. `SpellRuneCostEntry` distinguishes rune costs from runic power generation.
[SpellInfo.h](../../src/server/game/Spells/SpellInfo.h) supplies semantic target categories and native extensions.

The existing [AbilityTypes.h](../../modules/mod-ulduar-abilities/src/AbilityTypes.h) is a useful starter taxonomy,
but its `AbilityClassification` represents one cast/target/delivery/time/range and a union of effect flags.
Do not claim a Beam enum implements beam geometry, or a Summon effect flag implements universal pet support.
Ring/arc/custom geometry, generalized charges/recharge, mixed per-effect schools and new conversion routes
are proposals requiring adapters. Native aura proc charges are not ability recharge charges.

Version taxonomy vocabulary independently from balance values. Unknown terms fail publication with a report;
older clients may show a server-generated textual summary but may not reinterpret unknown execution semantics.
