# Ulduar abstract stats and deterministic resolvers

Status: proposed v1 resolver contract. Numbers below are initial design constants, not tuned balance claims.
Current formulas remain in a separate `legacy-v1` profile; see [gap analysis](ULDuar_GAP_ANALYSIS.md).

## Common resolver contract

Input: immutable structurally resolved effect graph, bound selector results, signed stat points, versioned resolver
profile and engine capabilities. Output: concrete field deltas, effective values, clamp information, reasons and
trace. No resolver branches on individual SpellIDs. A profile is chosen by metadata/geometry, not by spell name.

Points are signed integers in v1. Profile percentages are rational numbers; accumulate with checked fixed-point
arithmetic. Distances use 1/1000 yard, time uses integer milliseconds, chances use basis points. Round distances
and magnitude half away from zero, durations to nearest millisecond, costs upward to a spendable resource unit.
Round once at the destination field after stacking; do not round each contributor independently.

For positive baseline continuous quantity `x`, default point scale is `F(p) = (11/10)^p`.
Thus +1 gives 10% more and -1 gives division by 1.1; signed points cancel exactly before rounding.
Checked rational exponentiation must reject values exceeding the declared point bound before evaluation.
Defaults: point input [-20,20], geometry dimensions [0.001,100] yards, target counts [1,64], intervals >=100ms.
These are proposed normal gameplay profile limits; a separately versioned technical budget may be stricter.
Legacy profiles retain current limits and behavior until intentionally migrated.

Default favorable directions: positive Potency/Coverage/Range/Duration/Frequency/Reliability increase their
named measure; positive Speed increases rate; positive Cost and Cooldown reduce expense/time. Concrete `+Cost%`
means a penalty and must not be confused with positive abstract Cost points. Tooltips display the resolved change.

## CoverageResolver

Resolve a declared `coverageGroup`, not every effect that shares a spell. The group owns exactly one coverage
profile and may share geometry across damage and debuff effects. Applying radius twice to that shared field
is forbidden. Baseline is the output of structural conversions before abstract numeric modifiers.

Algorithm:

1. Bind selected coverage group(s) and total all Coverage points per modifier stacking rules.
2. Read the group's explicit profile. When absent, choose by this precedence: Chain/Bounce, Split, radial field,
   Circle/Nova, Cone, Line, Beam, Ring/Arc, Custom. Structural authoring must resolve competing geometries first.
3. Compute the primary axis below; secondary axes change only when the profile explicitly says so.
4. Enforce gameplay bounds, native target legality and independent execution budgets. Return every clamped delta.
5. If a required trade-off has no effective penalty at a bound, reject the whole hybrid gem. Do not award its bonus.

| Profile | Result for points p | Meaning of -1 |
| --- | --- | --- |
| Chain/Bounce | `totalTargetBudget = clamp(baseTotal+p,1,cap)` | One fewer target/hop execution |
| Split | `projectileTargetSlots = clamp(baseSlots+p,1,cap)` | One fewer projectile/target slot |
| Circle/Impact/Nova | `radius = baseRadius*F(p)` | Radius divided by 1.1 |
| Persistent area | `fieldRadius = baseRadius*F(p)` | Smaller field; lifetime unchanged |
| Cone | `angle = baseAngle*F(p)` | Narrower angle; reach fixed |
| Line | `width = baseWidth*F(p)` | Narrower line; length fixed |
| Beam with width | `width = baseWidth*F(p)` | Narrower collision beam |
| Ring | `outerRadius = innerRadius + baseThickness*F(p)` | Thinner ring; inner radius fixed |
| Arc | `arcAngle = baseAngle*F(p)` | Shorter arc; radius and thickness fixed |
| Custom | Named adapter-owned monotonic axis | Defined in profile or unsupported |
| Point/single unit | No editable coverage axis | Incompatible with coverage trade-off |

Count definitions include the primary target by default. Legacy secondary counts get an explicit translation:
`baseTotal = 1 + SecondaryTargetCount`. A revisiting chain's target budget counts executions; `uniqueTargetCap`
is a separate field. Do not increase both merely because they are represented as integers.

Cone angles clamp to (0,360] degrees; custom cone-reach and line-length profiles are legal alternatives but must
be named and shown in the preview. A pencil beam has no width capability merely because its visual is a beam.
Native unlimited-target AoEs use radius, not a fabricated target cap. A propagation chain keeps hop range fixed
under default Coverage; abstract Range may adjust an explicitly selected hop-range axis.

Spread and density require explicit profiles: aura spread may use a recipient count; projectile spread may use
an angle. Density is spawns per unit area and can alter total spawn count, so any density profile must declare a
finite spawn budget and rounding. Falloff is an ordered distance/hop multiplier curve with an explicit conservation
policy. Coverage never silently changes falloff, potency, duration, density and cap together.

Worked examples: base chain 4 total targets -> 3 at -1; split 3 slots -> 2; circle radius 10 -> 9.091 yards;
cone 60 degrees -> 54.545 degrees; line/beam width 2 -> 1.818 yards; nova/field radius 5 -> 4.545 yards.
Chain at 1 total target cannot pay a -1 Coverage drawback. Two effects sharing one 10-yard field still resolve
to 9.091 yards, not 8.264. Distances in examples show three decimals after the single final rounding.

## PotencyResolver

Multiply selected payload magnitude by F(p), preserving coefficient provenance. Damage, healing and absorb use
their own pipeline domains. Periodic potency is per tick with unchanged schedule, so total scales identically.
Control duration belongs to Duration; a Slow potency profile changes slow percentage with a mechanic/PvP cap.
Binary stun, silence or interrupt has no generic magnitude axis. Displacement potency may adjust distance only
if a collision-safe adapter is present. Resource magnitude must be an explicit resource-generation profile.

One generic Potency gem defaults to damage/heal/absorb payloads in its declared bundle. It does not increase the
slow, summon count and combo points in the same spell. Shared scaling is evaluated once before the payload is
distributed, or independently per tick under an explicit native policy; never both.

Legacy Potency is `(10 + 5*rank)%` secondary effect multiplier by default. Legacy Damage is +5% per rank to primary
damage and its propagated damage. Preserve both as distinct profiles; a new universal potency gem may use F(p).

## SpeedResolver and Frequency

Speed chooses one declared axis: cast rate first for cast-time spells, otherwise channel rate for channels,
otherwise projectile velocity. An ambiguous hybrid must declare its axis. Cast duration becomes `base/F(p)`;
projectile velocity becomes `base*F(p)`. Instant spells do not gain fictitious negative cast times.

Channel-rate profile conserves pulse count, reducing duration and interval together; it owns both fields as one
atomic modifier. Frequency independently reduces tick/pulse interval with duration fixed, increasing tick count.
Speed(channel-rate) and Frequency targeting that same schedule conflict unless a named composition is authored.
Frequency does not automatically increase periodic cost rates, proc chances or per-tick magnitude.

Default new periodic scheduler: no immediate tick; ticks at positive multiples of interval <= duration; no partial
last tick. Require at least one tick after resolution. Native adapters retain original cadence and refresh phase.
Example: duration 6000ms, interval 2000ms -> three ticks; +1 Frequency yields interval 1818ms -> three ticks.
The preview must show actual tick count rather than promise a 10% total-output increase at a discrete boundary.

## CostResolver

Cost is a vector of components, not one scalar. Each contains resource ID, raw/percent/per-second components,
percent basis (base/max/current), debit timing and minimum policy. Positive Cost points divide the selected
expense by F(p), after expressing its native formula; resource conversion occurs structurally before this step.
The result is rounded upward. Do not discount a resource refund as if it were a debit.

Mana normalization uses declared base mana, not current pool. Rage/runic power use native internal units;
combo points bind to their target/finisher rule; runes use a discrete rune-cost adapter. Rune substitution and
combo-point discounts are unsupported by the generic continuous profile. A free spell has no Cost drawback axis.
Health costs default to nonlethal with a specified health floor; lethal variants require explicit authoring.
Retain both native base cost and actual paid cost in the root cost ledger so refund talents can choose correctly.

## DurationResolver and remaining axes

Duration selects aura, field, summon or channel lifetime explicitly; it multiplies only that finite lifetime by
F(p). Permanent auras cannot be lengthened. Stun/root/fear durations honor mechanic caps and core diminishing
returns at execution. A duration change does not increase slow percentage. Native tick intervals remain fixed
unless a schedule profile declares otherwise. Reapplication defines reset/extend/replace and stack behavior.

Range adjusts max acquisition or hop range by F(p), with min range fixed and max >= min. Melee reach remains a
dynamic caster/target calculation unless a melee-range adapter exists. Cooldown divides selected own/category/GCD
timer by F(p) with independent floors; recharge uses a separate charge-pool adapter. No generic reduction resets
category siblings by accident. Reliability defaults to +100 basis points per point to hit chance where a hit
roll exists; explicit variants choose crit, dispel success or resistance reduction. It never overrides immunity
or changes hit, crit, dodge and block simultaneously.

## Acceptance cases for later implementation

Require deterministic traces for rank changes, same modifiers in different insertion orders, negative points,
zero/permanent fields, saturated penalties, overflow, shared geometry, mixed effects, converted resources,
multiple schools, weapon attacks and native tick refresh. Verify client previews against server-produced values.
These are design acceptance criteria; no test code, compiler or runtime tests were run in this phase.
