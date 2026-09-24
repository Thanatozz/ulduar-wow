# Ulduar Ability Forge architecture

Date: 2026-09-15. Status: proposed design; no runtime implementation.
This amends prior ownership and launch assumptions explicitly in
[Architecture Amendments](ULDuar_ARCHITECTURE_AMENDMENTS.md).

## Primary gameplay contract

A new Forge character begins with zero authored combat AbilityInstances and one AbilityCoreEntitlement.
Native movement, interaction, racial/utility/proficiency state and internal login chassis are not authored
combat abilities. Their exact starter policy is reviewed separately; existing characters are not stripped.

Tutorial sequence: choose Purpose (Damage or Healing), Method (Melee or Ranged), then an available
activation/style preset. The server previews and commits a persistent AbilityInstance.
Gems alter that individual instance. Generalized talents contribute character-wide semantic rules.
A keystone changes fundamental character rules. Optional acquisition modes deliver components through
Progression; none owns semantic execution.

Activation and style are different axes:
Instant, CastTime and Channel describe execution. Quick, Balanced and Powerful are authored parameter presets.
A "Powerful" ability still has one activation. Unsupported combinations are unavailable with a reason.
Slice 1 supports the four purpose/method combinations through reviewed profiles, with bounded activation
choices. Channel is deferred; see [Slice 1](ULDuar_VERTICAL_SLICE_V1.md).

## Identity and ownership

| Object | Identity / purpose | Does not mean |
| --- | --- | --- |
| NativeSpellEntitlement | Owner + reviewed native spell/chain + source | An owned Forge instance |
| AbilityCoreEntitlement | Durable right to create an instance | An active slot or SpellID |
| AbilityInstance | Stable server ID, owner and mutable versioned composition | Native spell identity |
| GemOwnership | Owned gem item/unit or unlock, with explicit grant source | Already installed gem |
| TalentOwnership | Semantic definition/rank and source | Native passive rank by default |
| MechanicEntitlement | Capability with one or more durable grant sources | All mechanics for everyone |
| KeystoneOwnership | Owned structural rule, distinct from active choice | Ordinary local gem modifier |

A Core entitlement is consumed exactly once when creation commits. The created instance survives resocketing,
element conversion, progression, native carrier changes and discovery. Deleting/retiring an instance is a
separate future operation with an explicit refund policy, never an accidental side effect of unlearning a carrier.
Several owned instances may share a template or archetype. Uniqueness by owner plus template/root SpellID
is therefore invalid. Ownership is character-scoped initially; account collections are a later policy.

Conceptual record, not SQL or a promised C++ layout:

```text
AbilityInstance
  instanceId: server-assigned stable identifier
  ownerGuid
  templateId, templateVersion
  instanceRevision, createdByReceipt
  purpose: Damage | Healing
  method: Melee | Ranged
  activation: Instant | CastTime | Channel
  targetPolicy: UnitEnemy | UnitAlly | other reviewed policy
  delivery, geometry
  baseSchool, resourceSpec
  baseParameters: potency, coverage, range, speed, cost
  sockets: ordered socket identities and installed gem ownership references
  learnedProgression: instance progression independent of native ranks
  lifecycle: Active | Stored | Suspended | Retired
```

The illustrative three-gem example is not a fixed-size storage requirement.
Socket counts come from progression policy. Final resolved values are derived cache data with a resolution hash,
not player-editable authoritative columns. Keep the base composition so removing a gem recomputes from baseline.

## Service authority and dependency direction

| Service / owner | Owns |
| --- | --- |
| Ability Forge / progression | Drafts, creation, instance ownership, receipts |
| Ulduar Abilities | Taxonomy, metadata, effect graph, execution, conversions |
| Ability Gems / abilities | Local structural transforms and compatibility rules |
| Generalized talents / abilities | Character semantic rule compilation |
| Keystone rules / abilities | Structural character transformations |
| Classless foundation | Native resources, mechanic and carrier adapters |
| Free Pick / Wild Draft | Optional reward request/offer policy |
| QoL | Optional presentation and cosmetic services |

Additional fields for the same entries:

| Service / owner | Consumes |
| --- | --- |
| Ability Forge / progression | Semantic validation and projection plan |
| Ulduar Abilities | Immutable build snapshot |
| Ability Gems / abilities | Installed ownership references |
| Generalized talents / abilities | Progression's active talent snapshot |
| Keystone rules / abilities | Progression's active keystone snapshot |
| Classless foundation | Validated desired capability plan |
| Free Pick / Wild Draft | Progression transaction interface |
| QoL | Read-only snapshots or separate cosmetic commands |

Recommended physical layout eventually separates abilities, progression, classless compatibility and QoL.
Keep classless initially small; it is justified by Player/Pet/spellbook/resource lifecycle dependencies,
not by a wish to create another progression owner. Existing mod-ulduar-abilities stays in place.

Dependency direction:
progression uses abilities' pure validation/resolution contracts and classless projection interfaces;
classless uses those public contracts and AzerothCore; abilities' runtime consumes an injected immutable
active-build provider without including progression implementation or querying its tables.
QoL consumes public views. Optional mode providers call progression. Put shared DTOs/interfaces in a minimal
contract boundary; implementation registration occurs at composition/bootstrap.
No abilities-to-progression concrete dependency, no circular singleton calls, no duplicate authoritative caches.

Do not create these directories or move existing files in this phase.

## Draft, validation and commit

1. Client obtains an authenticated catalog/build snapshot with content hash and revision.
2. Client sends purpose/method/preset and owned components, not resolved damage or arbitrary effect bytecode.
3. Server resolves a candidate using the same semantic pipeline used at cast time.
4. Validate Core entitlement, slots, socket budget, gem ownership, mechanic graph and carrier feasibility.
5. Return a preview bound to draft ID, expected revisions, chosen definition versions and expiry.
6. Commit revalidates all mutable conditions under per-character serialization.
7. Atomically consume entitlement, create instance, assign slot, add receipt and projection outbox.
8. Apply native projection idempotently, then expose a usable button and final resolved tooltip.
9. A repeated commit returns its original receipt. A stale draft consumes nothing and returns current state.

Native projection failure does not lose the owned instance or consume another Core.
Mark the slot pending/suspended, persist retry reason and reconcile before allowing casts.
Do not report a usable ability until projection succeeds. Definitions whose carrier cannot support their
semantics are rejected before commit; temporary runtime/API failure is a separate recoverable case.

## Effect graph and deterministic resolution

Retain the prior taxonomy's independent purpose, activation, target, delivery, geometry, school,
resource, mechanics and effect identity. Method is the player's broad interaction choice;
it does not replace those runtime axes or infer a native class.

Use the existing resolution ordering as the baseline and explicitly insert instance composition:

```text
Versioned template + instance base structure
  -> local gem transforms in authored deterministic order
  -> character semantic talent rules
  -> keystone structural policy at its declared resolution stage
  -> compatibility and mechanic/resource/carrier feasibility
  -> PotencyResolver + CoverageResolver and parameter derivation
  -> immutable resolved definition and tooltip
  -> native cast validation / cost commit
  -> immutable cast, event and hit snapshots
  -> current native combat safety and delivery adapters
```

The keystone compiler declares stages and conflict precedence; it is not a blanket "last writer wins".
Reject conflicting exclusive transforms, graph cycles, unbounded children, unsupported payloads and unknown units.
Use stable rule IDs and explicit priorities for ties; hash canonical ordered input.
Preserve existing EP-derived parameters through a versioned LegacyCustomization adapter.
Do not reinterpret legacy EP as a Core, Gem currency or refundable acquisition payment.

Gems modify base semantic structure or parameters, not shared SpellInfo.
A delayed hit uses the cast's captured instance revision even if its gem changes before impact.
New casts use the new committed revision. Mid-combat mutation is initially disallowed to simplify this boundary.
Damage, healing and weapon payloads retain their distinct native adapters and hit/crit/immune/proc validation.
Taxonomy generality does not imply that every combination is executable.

## Native execution and presentation contract

This is a launch-blocking design boundary, not an implementation detail to hide until later.
The ordinary native cast request identifies SpellID. It does not carry AbilityInstanceId.
An addon cannot authorize combat by sending a claimed instance ID or insecure scripted cast.

Maintain a server-owned mapping:
owner + active slot + carrier generation -> instance ID, instance revision, reviewed native carrier/rank.
A native cast resolves through the unique active carrier mapping, verifies ownership and snapshots the instance.
A non-carrier spell continues its existing native/legacy path. Never reinterpret all known native spells as Forge.

Slice 1 has one active slot and one mapped carrier, selected from reviewed purpose/method profiles.
The button uses normal secure native spell activation; Forge management messages do not cast the spell.
The stock spellbook can list the carrier while the Ulduar view shows the custom instance name and properties.
This does not promise that the stock Spell.dbc name/icon changes without client data support.

Later, simultaneous slots need distinct native carrier IDs per player or a proven secure dispatch mechanism.
Two active instances cannot ambiguously share one carrier. Prefer a finite reviewed carrier pool rather than
allocating a global DBC spell for every owned instance. Changing an inactive instance does not consume a
permanent global SpellID. Pool exhaustion fails activation with a clear reason.
Server cost, target policy, range, cast/channel behavior, weapon requirements and visual behavior must all
fit the carrier's native/client constraints. Client DBC validation can reject a cast before the server sees it.

NativeSpellEntitlement and instance projection retain separate sources. A legacy real spell cannot be hijacked
by mapping a Forge instance onto the same active native action identity without an explicit collision policy.
Rank updates preserve slot-to-instance identity, and native replacement packets/buttons are only projection.
A future asset/DBC patch may add reviewed carriers, but is not the ownership architecture.

## Archetype discovery

An archetype is a versioned semantic predicate, optional visual suggestion and collection/discovery entry.
It never replaces or renames ownership to a native SpellID automatically.

| Reference archetype | Candidate semantic pattern, requiring authored review |
| --- | --- |
| Smite-like | Damage, Holy, ranged unit target, CastTime |
| Frostbolt-like | Damage, Frost, Projectile, CastTime, Chill |
| Fireball-like | Damage, Fire, Projectile, CastTime; periodic rider optional |
| Healing Touch-like | Healing, Nature, unit ally, slower CastTime |
| Healing Wave-like | Healing, Nature, unit ally, authored potency/cast profile |
| Chain Heal-like | Healing, Nature, Chain, ally target and falloff |
| Cleave-like | Damage, Melee, bounded secondary nearby targets |
| Arcane Missiles-like | Damage, Arcane, Channel, repeated projectile events |

Healing Touch and Healing Wave can overlap semantically; discovery needs additional authored distinctions
or intentionally allows both. Names are not evidence of distinct runtime mechanics.
Record discovery once per owner/archetype/version policy from committed resolved instances.
Reforging away from a pattern retains discovery unless the collection explicitly represents currently active builds.

Spell.dbc, rank chains, effects, schools, targeting and visuals can seed candidate patterns offline.
Native scripts, family masks and triggered children require manual review; text/name matching is insufficient.
Keep provenance/confidence, quarantine unknowns and never auto-enable imported archetypes or assets.
The reference's cw_archetypes are automated native acquisition builds, not this discovery model.

## Client/server content manifest

One release manifest carries:
protocol versions; taxonomy/effect schema versions; template, gem, talent, keystone, mechanic and archetype
catalog hashes; rule compiler/resolver version; carrier bindings; addon/UI hash; asset/DBC/MPQ hashes;
native client build/input hashes; server core/module revision and migration compatibility range.

Generate server and client views from one reviewed canonical catalog. Hash canonical bytes.
A release ID names the immutable set; per-file hashes detect partial packages.
Handshake negotiates protocol and required capabilities and verifies relevant release identifiers.
A client-reported hash is compatibility information, not an anti-cheat attestation.
The server still validates every command and cast.

On mismatch, block affected Forge commits and custom carrier casts while retaining safe login/diagnostic access.
Do not delete ownership, auto-respec, patch files from an addon or silently downgrade semantic definitions.
Prepare a verified package outside the live client, then explicitly publish after a later approved delivery phase.
Existing Ulduar Protocol 2 remains supported through an explicit version bridge; do not silently change its grammar.
No manifest implementation or client package is created now.

## Preservation and current limitations

Existing Ulduar files and saves remain unchanged. Legacy characters require an explicit later migration design,
including unknown native grant sources and EP ownership. The zero-ability tutorial applies to new Forge profiles.
The existing enabled catalog, runtime adapters and delivery proofs are reusable foundations, not proof that
four Forge profiles, persistent instance ownership or carrier dispatch already work.
The external source remains reference-only; see [Audit](CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md).
