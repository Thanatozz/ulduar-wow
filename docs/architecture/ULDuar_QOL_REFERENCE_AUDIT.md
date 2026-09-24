# Ulduar QoL reference audit

Date: 2026-09-15. CoA is a QoL/reference donor only.
Pinned CoA revision: `feb155c82c754f7190ffebc9843cab581ccda7b7`.
No CoA classes, progression, world baseline, client executable or custom gameplay are proposed for adoption.

Design aim: retail-like convenience with WotLK/Classic visual identity.
Independent implementation means a Ulduar feature can be built without CoA gameplay; it does not mean the
inspected CoA implementation can be copied without its dependencies.

## Evidence and limits

Revisited [AscensionCompat.cpp][compat], [SpellChargeState.h][charges],
[collection SQL][sql] and [client compatibility documentation][client].
The current repository does not contain every canonical client addon/asset from its sibling workspace.
Do not infer a bag, map, mail or journal UI implementation from server support or promotional names.
The prior [CoA audit](ASCENSION_CLASSLESS_BASE_AUDIT.md) remains valid on gameplay exclusion;
its cosmetic "not relevant" classification is amended for this newly requested QoL scope.

Verified collection service behavior:
loads Appearances.dbc, ItemAppearances.dbc, ItemSet.dbc and VanityCollection.dbc;
loads account appearance/vanity ownership, validates appearance/category requests,
persists character selections, refreshes visible items and sends collection snapshots/deltas.
It batches appearance additions and schedules login resynchronization.
Vanity delivery checks catalog membership, account ownership unless a configured bypass is active,
item storage capacity and optional learned-spell fallback.

This proves server collection plumbing, not complete stock-client UI portability.
Collection handlers use custom opcodes and native-v4 client data.
SpellChargeState is a small standard-library arithmetic type; complete charge behavior also depends on
Player integration, persistence, packet support and UI.
Appearance selection uses a DB transaction for its row set; it is not a Forge entitlement/economy transaction.

## All requested categories

Status: VERIFIED = concrete source evidence; PARTIAL = related mechanism only;
UNVERIFIED = no feature implementation established in inspected published sources.
An unverified row is an audit gap, not a claim that no CoA client ever implements it.

| Category | Evidence / candidate | Status |
| --- | --- | --- |
| Inventory/Bags | Inventory scan collects cosmetics; no unified-bag UI established | PARTIAL |
| Loot | Item acquisition can feed cosmetic collection | PARTIAL |
| Spellbook | Native replacements/progression support; full QoL browser not established | PARTIAL |
| Action Bars | Native temporary/replacement buttons in earlier source audit | PARTIAL |
| Cooldown/Charges | SpellChargeState and Player charge synchronization | VERIFIED |
| Tooltips | Native modifier/aura information pathways | PARTIAL |
| Character Stats | Custom class/resource formulas | VERIFIED gameplay |
| Collections | Account appearance/vanity service and delta sync | VERIFIED |
| Transmog | ApplyLocalAppearance, ownership/category checks, visible item refresh | VERIFIED |
| Mount Journal | Mount/companion vanity categories and delivery | PARTIAL |
| Map | No standalone map QoL implementation established | UNVERIFIED |
| Quest Tracking | No tracker implementation established | UNVERIFIED |
| Vendors | Vanity delivery is not a general vendor QoL system | PARTIAL |
| Mail | No mail QoL implementation established | UNVERIFIED |
| Professions | No independent profession UI established | UNVERIFIED |
| Nameplates | No independent nameplate UI established | UNVERIFIED |
| UI Scaling | Canonical client UI not fully published here | UNVERIFIED |
| Search/Filtering | Collection catalogs support an index; search UI not established | PARTIAL |
| Interaction improvements | Validated cosmetic apply/delivery results | VERIFIED |
| Accessibility/readability | Extra Ulduar concern; no donor implementation established | UNVERIFIED |

Additional fields for the same entries:

| Category | Ulduar decision |
| --- | --- |
| Inventory/Bags | Defer separate addon research |
| Loot | Keep collection-on-acquire concept |
| Spellbook | Build Forge-owned instance view |
| Action Bars | Preserve slot identity; own UI |
| Cooldown/Charges | Small arithmetic reference candidate |
| Tooltips | Own resolved-snapshot tooltips |
| Character Stats | Exclude formulas; own semantic stat view |
| Collections | Independently reimplement |
| Transmog | Independently reimplement later |
| Mount Journal | Own journal; UI still unverified |
| Map | No CoA portability claim |
| Quest Tracking | No CoA portability claim |
| Vendors | Keep safe delivery UX only |
| Mail | No CoA portability claim |
| Professions | No CoA portability claim |
| Nameplates | No CoA portability claim |
| UI Scaling | Ulduar addon setting, not a proven port |
| Search/Filtering | Own semantic/collection filters |
| Interaction improvements | Own request/result feedback |
| Accessibility/readability | Future local UI quality gate |

No rows above silently import a Retail UI. Preserve native frame textures, typography and familiar interactions;
add search, readable status, scalable panels and server-sourced information where useful.

## Candidate dependency matrix

Tables join by ID. "EXE" includes a custom native client/DLL dependency in the donor pathway.
For UNVERIFIED categories above, server/core/client/EXE/DBC/UI dependencies are **unknown**;
independent implementation feasibility is unassessed, donor reuse value unproven and risk HIGH until sourced.

| ID / feature | Server dependency | Core dependency |
| --- | --- | --- |
| Q01 Charge arithmetic | None inside the value type | std::algorithm/cstdint only |
| Q02 Charge display | Authoritative charge snapshots | Player charge save/send/cast integration |
| Q03 Appearance collection | AscensionCollectionService + account ownership | Inventory/equip hooks and DB |
| Q04 Cosmetic application | Ownership/category validation + selections | Visible item refresh/appearance overrides |
| Q05 Mount/companion collection | Vanity catalog and account grants | Native item/spell grant APIs |
| Q06 Collection delta sync | Batched additions and login resync | Player update/login timing |
| Q07 Safe cosmetic delivery | Catalog/owner validation and capacity checks | CanStoreNewItem/StoreNewItem/learnSpell |
| Q08 Action continuity | Earlier audited native replacement service | Player replacement/rank/action support |
| Q09 Searchable collection view | Own read-only server catalog | No new core policy inherently needed |
| Q10 Resolved tooltip/stat view | Ulduar snapshot service | Existing Ulduar resolver |

Additional fields for the same entries:

| ID / feature | Client / EXE dependency |
| --- | --- |
| Q01 Charge arithmetic | None for arithmetic; native integration separate |
| Q02 Charge display | CoA custom packet/UI pathway; native client |
| Q03 Appearance collection | Collection opcodes; native-v4 UI |
| Q04 Cosmetic application | Native-v4 appearance client pathway |
| Q05 Mount/companion collection | Vanity opcodes and native-v4 UI |
| Q06 Collection delta sync | Custom collection packets |
| Q07 Safe cosmetic delivery | Packet or local command interface |
| Q08 Action continuity | Native packets plus client data |
| Q09 Searchable collection view | Own addon; donor UI not verified |
| Q10 Resolved tooltip/stat view | Own addon; donor formulas excluded |

| ID | DBC dependency | UI dependency |
| --- | --- | --- |
| Q01 | None | None inside helper |
| Q02 | Native spell metadata | Charge overlay and timer refresh |
| Q03 | Donor Appearances/ItemAppearances | Collection browser and sync |
| Q04 | Donor appearance categories/models | Selection, preview and apply |
| Q05 | VanityCollection and native spell/item data | Journal, favorites and summon controls |
| Q06 | Catalog identifiers | Snapshot/delta application |
| Q07 | Vanity item-to-spell mappings | Clear error/success feedback |
| Q08 | Matching replacement/rank metadata | Secure native buttons |
| Q09 | Own catalog; no custom DBC inherently | Addon filters/search |
| Q10 | Carrier metadata consistency | Tooltip/stat panel |

Additional fields for the same entries:

| ID | Independent? / value / risk |
| --- | --- |
| Q01 | Yes, narrow candidate / medium / MEDIUM |
| Q02 | Yes by own adapter / high later / HIGH |
| Q03 | Yes as concept / medium / HIGH |
| Q04 | Yes as own cosmetic service / medium / HIGH |
| Q05 | Yes as concept / medium / HIGH |
| Q06 | Yes with own protocol / medium / MEDIUM |
| Q07 | Yes; do not copy fallback policy / medium / MEDIUM |
| Q08 | Yes via own slot adapter / high / HIGH |
| Q09 | Yes; own implementation / high / LOW |
| Q10 | Yes; use existing Ulduar foundation / high / MEDIUM |

Q03/Q04/Q05 are **ideas for independent implementation**, not portable whole services.
Their published implementation uses CoA-specific data/opcodes and native client behavior.
For a stock WotLK client, recreate presentation through an addon and reviewed native appearance mechanisms;
do not assume custom appearance categories or spell cosmetics render automatically.

Q01 directly depends only on standard headers and stores Available, NextRecovery and RecoveryTime.
It recovers charges sequentially using absolute timestamps and caps restored amounts.
Its missing-deadline policy refills the pool; Ulduar must decide whether that is appropriate for corrupted
or migrated state. Clock changes, zero recovery, cap changes and instance/shared cooldown identity require review.
Do not copy the entire CoA charge stack merely because its arithmetic helper is small.

## Candidate order and exclusions

First useful QoL in the Forge slice is clear resolved tooltips, stable action buttons and minimal ownership UI.
These already follow Ulduar requirements; CoA provides reference lessons rather than a new dependency.
Later independent candidates: collection search/filtering, batched collection synchronization,
account cosmetic collection, reviewed transmog, mount/companion journal and charge display when gameplay needs it.

Exclude CoA's 21 custom classes, automatic class/spec talents, class stat/resource policy, custom world baseline,
Manastorm progression and the native-v4 Extensions.dll compatibility patch.
The published DLL patch addresses that client's endpoint behavior; it is not a generic QoL requirement.
Do not import unlock-all vanity policy, arbitrary learned-spell fallback or custom asset datasets as Ulduar grants.

Before any later implementation, inspect exact per-file licenses and attribution, source the missing client UI,
confirm native rendering capability, and define cosmetic ownership independently from combat entitlements.
No experiments, client preparation or source copying were executed during this audit.

[compat]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/modules/mod-ascension-compat/src
[charges]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/src/server/game/Spells/SpellChargeState.h
[sql]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/tree/feb155c82c75/modules/mod-ascension-compat/data/sql
[client]:
  https://github.com/jealous-sound/azerothcore-wotlk-coa/blob/feb155c82c75/apps/client-compat/README.md
