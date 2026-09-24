# Ulduar classless layer

Status: proposed module boundary, 2026-09-14. No module, protocol handler, schema migration or runtime code created.

## Responsibilities and dependencies

| System | Authoritative question | Owner |
| --- | --- | --- |
| CLASSLESS | Which abilities/talents do I know? | `mod-ulduar-classless` |
| ABILITIES | How is an individual ability rebuilt and executed? | `mod-ulduar-abilities` |
| GEMS | How is that ability customized? | Abilities definitions/slots; inventory grant service |
| TALENTS | Which global rules affect my build? | Classless ownership; shared rule compiler/executor |
| KEYSTONE | Which fundamental character rule changes apply? | Character build service; structural rule compiler |

`mod-ulduar-classless` owns universal acquisition, source-class-independent eligibility, point budgets,
learning/unlearning, persistence, generic prerequisites and API/protocol. It consumes immutable metadata/capability
queries from Abilities and publishes an `OwnedBuildSnapshot` to the rule compiler. Abilities owns transformations,
gem compatibility and execution. Avoid mutual singleton calls: a narrow shared contract module contains IDs,
immutable DTOs, selectors and event interfaces; dependency injection supplies the services at startup.

The current checkout is AzerothCore-based (remote and hook types verified), with Trinity lineage. Define a
`CoreSpellGrantAdapter` and `CoreRuntimeAdapter` around the actual APIs. This is not a request to switch to either
AstoriaCore or a different TrinityCore tree. Existing scripts and per-spell execution remain in place.

## Native gates and new ownership

Native `Player::LearnTalent` in
[Player.cpp](../../src/server/game/Entities/Player/Player.cpp), around line 14258, checks TalentTab class masks,
dependencies and original tier spend. Ulduar talent acquisition does not call it. Talent.dbc is source data only.
Native talents can continue on a legacy character mode, but the same source behavior cannot be applied through
both native auras and generalized rules on an enabled Ulduar build.

Universal spell acquisition grants reviewed native spells through `CoreSpellGrantAdapter`. Original class alone
does not determine eligibility. Preserve meaningful weapon, stance/form, stealth, combo-point, rune and target
requirements. Explicitly grant mechanic prerequisites where intended; never globally disable CheckCast because
a spell originates from another class. Native skill auto-learning, passive activation, spellbook display,
resource bars, pet control and class-filtered scripts each need compatibility verification.

Current `AbilityManager::IsAbilityAvailableForPlayer` checks definition.ClassId plus an active known native rank.
Replace its class gate through an ownership-provider adapter only after classless learning works; retain native
rank resolution and runtime release gates. Runtime BuildRuntimeContext currently does not use the same class
availability method, so centralizing authorization also removes a UI/runtime policy inconsistency.

## Point and prerequisite policy

Use distinct ledgers for spell acquisition points, talent points and existing per-ability EP. Earned totals come
from server progression grants; never trust a client total or assume Astoria's level formulas are final balance.
Refund policy is versioned and explicit about currency, respec fees, combat restrictions and rank downgrades.
Keep ability customization `CustomRank` separate from native spell rank and universal talent rank.

Optional prerequisites are generic: owned definition/rank, named mechanic unlock or spend in a Ulduar category.
Prerequisite graphs must be acyclic. On unlearn/downgrade, reject a build leaving invalid dependents or accept a
complete explicit cascade preview with correct refunds. DORMANT compatibility is never a prerequisite failure.
If a dependency merely expresses “has matching current spell,” replace it with a selector, not an ownership gate.

Native grants are reference-counted by source: classless purchase, talent-granted ability, quest, baseline,
equipment, temporary aura or legacy grant. Unlearning one source removes the native spell only when no valid
source remains. Rank upgrades track the native active/inactive chain. Do not delete unrelated trainer/quest spells.

## Commit algorithm and protocol

Logical request: session epoch, request ID, expected build revision, catalog version, complete bounded change set.
Character GUID comes from authenticated session. Names, display tags, client matching results and costs are ignored
as authority. A server preview compiles the candidate with the exact same validator used by commit.

1. Parse bounded request; check version, session, request identity, rate limit and character lifecycle state.
2. Serialize mutations for that character. Reject stale revisions. Load trusted ownership, inventory and ledgers.
3. Resolve canonical definitions/ranks, references, grant sources and generic prerequisites. Check all point and
   item budgets, support states, gem requirements, keystone conflicts and structural conversion DAG.
4. Compile the entire candidate graph and talent rules; compute grant/revoke diff and compatibility states.
5. Commit ownership, costs/refunds, installed gems, ledger, durable revision and request receipt in one character
   database transaction. Persist a native-reconciliation outbox in that transaction where native SaveToDB cannot
   participate. Do not treat several standalone writes as an atomic transaction.
6. Reconcile native spell state on the map/player thread. Until successful, prevent use of newly granted/revoked
   build state. Publish one immutable build revision and acknowledge applied state after reconciliation succeeds.
7. On failure after durable commit, return/recover a pending operation with the same ID; never charge again.
   Login/restart drains pending reconciliation before enabling the build. An identical retry returns its receipt;
   the same ID with a different payload rejects. DB timeout is ambiguous, not permission to repeat the debit.

Use transactional native persistence directly if the core adapter can prove it shares the same transaction.
Otherwise the outbox must be the documented integration, including safe behavior while native state is pending.
Do not acknowledge “learned” after merely storing custom rows. Existing single-row `Persist` readback is useful
for current nodes but does not supply this multi-table/native-state atomicity.

Transport reuses authenticated addon self-whispers and bounded serialization from the existing protocol, in a
separate namespace. Tokens are session correlation; they are not secrets that make client choices trusted.
Keep replay results across reconnects through durable receipts. Details and chunk bounds are in the
[library UI contract](ULDuar_UNIVERSAL_TALENT_LIBRARY.md).

## Proposed character schema

| Table | Primary key | Essential fields |
| --- | --- | --- |
| `character_ulduar_spells` | guid, ability_instance_id | ability_id, native_rank, acquired_version, revision |
| `character_ulduar_ability_gems` | guid, ability_instance_id, slot_id | owned gem ref, variant/rank, revision |
| `character_ulduar_talents` | guid, loadout_id, talent_id | rank, acquired_version, grant source, revision |

`character_ulduar_spells` has unique `(guid, ability_id)` in v1: one customized instance per ability per character.
Multiple independent copies are an explicit future feature, not accidental duplicate native SpellIDs.
Supporting tables: `character_ulduar_build` (guid/loadout/revision/catalog/keystone), `character_ulduar_grants`
(guid/ability/grant_source/entitlement), point ledger (guid/currency/grant_or_spend_id/amount), request receipts
(guid/request_id/payload_hash/result/revision), and reconciliation outbox (operation_id/desired_revision/status).
Catalog references across world/character DBs are verified in application logic; character-owned relations use
composite keys including guid to prevent cross-character installation or refunds.

Keep current `character_ulduar_abilities` during transition. Its `custom_rank`, EP and node ranks are not replaced
by classless acquisition rows. Introduce a legacy customization profile or versioned migrated record only after
old/new resolution parity is demonstrated. Native `character_spell` remains a projection of all valid grant sources,
not the sole authority for Ulduar purchase history. Character deletion must cover online and offline paths.

## Incremental adoption

First introduce immutable metadata and selectors without changing eligibility. Then add classless ownership behind
a character-mode gate, enable a small cross-class acquisition cohort, and reconcile known native spell grants.
Introduce generalized talents with generic numeric rules before stateful proc or movement mechanics. Extend the
existing client with a library view and authoritative state previews. Later migrate legacy node rows to gem
definitions while preserving numeric behavior and EP. No stage requires installing AstoriaCore, Eluna or AIO.

Future validation must include crash between commit/reconciliation, duplicated requests, stale client drafts,
logout/map transfer, granted active talents, skill auto-grants, native spell rank changes, mixed grant sources,
DB unavailability and reconnecting to a new catalog version. No live operations were performed for this design.
