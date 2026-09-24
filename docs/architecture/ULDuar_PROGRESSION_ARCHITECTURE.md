# Ulduar progression architecture

Date: 2026-09-15. Proposed contracts only; no SQL or implementation.
Primary acquisition creates and evolves AbilityInstances through Ability Forge.
See [Forge architecture](ULDuar_ABILITY_FORGE_ARCHITECTURE.md) and
[Amendments](ULDuar_ARCHITECTURE_AMENDMENTS.md).

## Progression objects and policy

Ability Slot is an active loadout location. Ability Core is a creation entitlement.
Gem Socket is a location within one instance. Buying/unlocking one does not grant the other two.

Initial policy: one active slot, one Core entitlement, one socket on the created ability.
Later policies may unlock more slots, sockets two and three, and a special fourth socket.
Store unlock conditions in versioned authored policy; no final level schedule or balance costs are set here.
Owned inactive instances remain stored independently of active slot count.
A slot has an instance reference and projection generation; a socket has a stable socket identity and gem reference.

| Ownership type | Durable identity | Mutable state / invariant |
| --- | --- | --- |
| NativeSpellEntitlement | Owner, native chain, source | Projection only while effective source exists |
| AbilityCoreEntitlement | Owner, entitlement ID, reward receipt | Available or consumed once by creation |
| AbilityInstance | Globally unique server instance ID | Owner immutable; composition revision increases |
| GemOwnership | Owner, gem unit/unlock ID | Explicit consumable/equippable policy |
| TalentOwnership | Owner, semantic definition, source | Owned rank differs from active loadout rank |
| MechanicEntitlement | Owner, mechanic, source identity | Effective union of active sources |
| KeystoneOwnership | Owner, semantic definition, source | Active structural choice is separately validated |

Slice 1 uses one non-consumable equippable gem unit, installed in at most one socket at a time.
Removing it returns it to collection; replacing moves ownership atomically.
Future stackable consumables/unlocks require a new explicit policy, not overloading the same counter.

## Conceptual storage boundaries

Future names below describe responsibilities, not migration files to execute:

- Character progression profile: schema/content versions, onboarding state, build revision.
- Source grants: unique source identity, target entitlement, lifetime, provenance and migration status.
- Core entitlements: issuance/consumption receipts.
- Instances: stable identity, base composition, template/version, instance revision and lifecycle.
- Slots/loadouts: owner, slot identity, instance reference and projection generation.
- Socket installations: instance/socket, gem ownership unit, install receipt.
- Gem collection, semantic talent ownership and keystone ownership.
- Budgets/reward ledger: earned, spent and refunded amounts with immutable operation references.
- Operation receipts: owner, request ID, operation type, result identity and committed revisions.
- Projection outbox: durable desired native grants/button/mechanic effects with idempotent effect keys.
- Optional draft offers: offer/revision, choices, RNG provenance, expiration and accepted receipt.
- Archetype discoveries: pattern/version and original discovering instance reference.

Database constraints prevent double Core consumption, duplicate request commits, multiply installed gem units,
cross-owner slot/socket references and multiple active instances mapped to the same native carrier.
References to retired definitions remain recoverable; missing catalog rows suspend use instead of deleting saves.
Every custom row created in future migrations must have a rollback/export strategy.
No world rewrite, class conversion or native ownership overwrite follows from these conceptual tables.

## Transaction protocol

One command envelope contains protocol, authenticated actor context, request ID, expected build revision,
expected instance revision where applicable, catalog hash, operation and bounded arguments.
The actor comes from the server session, not a trusted ownerGuid supplied by the client.
Check finite enum ranges and integer bounds; reject invalid IDs, oversized payloads and unknown versions.
Rate-limit each command family and expensive preview/catalog operations per authenticated player.

Serialize mutations per character. Within one durable DB transaction:
recheck ownership/budget/requirements; write ledger debits/credits; apply desired build; increment revisions;
record result receipt and outbox work. An operation either commits all authoritative ownership changes or none.
Do not hold a database lock while waiting on client or native world execution.
Define duplicate request behavior: same ID and payload returns receipt; same ID with different payload rejects.

Native Player APIs cannot participate in the custom ownership SQL transaction reliably.
Therefore the outbox projects only committed state. A native failure leaves ownership committed but activation
pending, and a retry is safe. Reconciliation compares desired state with owned projections and independent sources.
Do not claim SQL and native Player memory become atomically durable together.

Creation result includes instance ID and pending/ready projection state. The UI shows the authoritative
status and never manufactures a successful native button from preview alone.
A stale preview is rejected with fresh revisions; time elapsed is not approval or success.

## Lifecycle and consistency

| Event | Required behavior |
| --- | --- |
| New Forge profile | Issue exactly one onboarding Core through a unique reward receipt |
| Forge creation retry | Return original instance; no duplicate Core debit |
| Socket installation | Move gem, validate whole build, revise instance, preserve instance ID |
| Socket removal | Recompute baseline plus remaining rules; return non-consumable gem |
| Slot replacement | Validate uniqueness/eligibility; project after durable change |
| Talent/keystone change | Revalidate every affected active instance and mechanic |
| Login | Load profile, receipts/desired grants; reconcile before enabling custom casts |
| Logout | No loss of committed grants; native transient state follows reviewed policy |
| Death/resurrection | Preserve ownership; apply explicit aura/pet/resource lifecycle |
| Level unlock | Idempotent reward key by policy event; no repeated catch-up grant |
| Server crash | Replay pending outbox; never repeat reward/price transaction |
| Catalog revision | Validate/migrate explicitly; suspend unsupported definitions |
| Character deletion | Include custom cleanup in native deletion transaction |
| Spec/loadout change | Release only inactive sources; restore active slot mapping |
| Database read error | Mark unavailable; never treat failure as a brand-new character |

Receipts record paid values; refunds do not use today's catalog price.
Respec is a desired-build transaction with a dependency diff and explicit economic policy.
A native carrier losing a rank does not refund a Core or delete its owning instance.
Power costs during combat are owned by the native resource commit adapter, not by the acquisition budget ledger.

## Source-counted grants and mechanics

Source identity includes type and stable granting object: instance, talent rank, keystone, quest reward,
equipment item, tutorial or administrator action. Do not store one mutable GrantSource enum per spell.
Permanent and temporary grants coexist. Revoke only the source being removed.
Unknown legacy native ownership is conservatively preserved until audited migration identifies its provenance.

MechanicRequirement resolves to an entitlement plan or a clear rejection before an acquisition commits.
Use a bounded acyclic dependency graph; record edges for diagnostics and reverse dependency checks.
Form or pet children cannot keep one another alive through a cycle.
Changing a gem can add/remove requirements without changing instance identity.
Equipment-dependent eligibility is checked at cast time as well as build time; it is not permanent ownership.

Rune capability allocation and active-power checks cannot diverge. Pet summon ownership, stored pet identity,
pet bar/spells and active guardian are separate objects.
Combo points bind to target GUID; reactive Overpower eligibility needs a distinct token or explicit incompatibility.
See resource/mechanic source evidence in the [audit](CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md).

## Optional Free Pick

Retain a server-authoritative catalog/preview/commit interface for components and reviewed exceptions.
Possible purchases: Core entitlements, Gem units/unlocks, semantic Talents, SocketUpgrade and active-slot unlock.
An optional NativeSpellEntitlement shop is a later reviewed mode, not the launch acquisition foundation.

Reuse common transaction/ownership machinery; a Free Pick provider supplies price and eligibility policy only.
It cannot call learnSpell as ownership, bypass Forge validation or mutate character-wide semantic rules directly.
Do not import AE/TE economy, all-native catalogs or native talent rank tables.
Search may expose semantic purpose, activation, delivery, school, resource and compatible owned components.
Origin class remains provenance/filter metadata, never an availability gate.

## Optional Wildcard Component Draft

Reference rolls immediately grant native SpellIDs. Ulduar needs persisted offers and explicit acceptance.

1. Server constructs a legal component pool from the catalog and authored semantic affinity policy.
2. It validates nonempty pool and budget before reserving an offer/reroll operation.
3. Persist candidate definition IDs, quantity/rank, weights/pool version, RNG audit reference and offer revision.
4. Client reveals choices; all hidden/revealed information follows explicit anti-reroll/reconnect policy.
5. Accept references offer and choice, then atomically issues reward and closes the offer with a receipt.
6. Reconnect returns the same pending offer or prior receipt, never a fresh chance.
7. Reroll atomically replaces the offer and debits price; exhausted pools consume nothing.
8. Locks are desired states attached to the offer revision. Bulk/rapid operations have a bounded server policy.

No deterministic RNG seed is accepted from the client. Server auditability need not reveal future rolls.
Use sufficiently wide checked weight sums and stable candidate ordering.
Pity, duplicate protection and affinity are versioned rules; classMask is not semantic affinity.
Component duplicates follow type policy: an extra gem unit can be valid, a unique unlock may convert to a
documented alternate reward, and an unsupported/max-rank talent is excluded.
Drafting a component does not automatically install it or mutate a live ability.
No final rarity prices, cadence or pity constants are set here.

## Migration and compatibility

The existing EP/customization system remains authoritative for existing saves.
Do not infer Core entitlements from known native spells or silently convert all old abilities to instances.
A later explicit migration can create LegacyAbilityView or attach a stable instance to a reviewed legacy record,
record provenance, preserve spent EP and retain a recoverable export.
Unknown grants, native talent auras, action bars and per-spec data are migration blockers until mapped.

Old ownership assumptions are amended rather than deleting old documents.
The first new-character Forge slice and existing legacy characters can coexist behind explicit profile mode.
No new profile flag or migration is implemented in this audit.
