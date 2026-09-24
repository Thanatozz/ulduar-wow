# Classless Wildcard experimental reference audit

Date: 2026-09-15. Decision: **REFERENCE_ONLY**. Evidence: source inspection, not runtime verification.

AzerothCore and the existing Ulduar implementation remain the base. Ability Forge becomes the primary
progression loop. No external module, SQL, client patch, generated data or runtime change was installed.

## Scope and evidence

The exact requested repository was cloned only to
`C:\WoWProjecto\references\mod-classless-wildcard`.
Inspected revision: `5ffe6957cad94492480a8e3b6b351021318af83e`,
dated 2026-09-14, subject "Big patch for issues." References below are pinned to that snapshot.
Requirements describe AzerothCore master and WoW 3.3.5a; they do not establish compatibility with a
particular AC commit. Ulduar HEAD is `d7ce67dc1800f092bac98aad680ece1c201b89a0`, plus existing local work.

The fourteen prior contracts listed in [Amendments](ULDuar_ARCHITECTURE_AMENDMENTS.md) were reviewed first.
Existing semantic definitions, EP customization, cast/event/hit snapshots, delivery, healing and weapon
adapters are preserved. There are 28 enabled ability definitions among 30 definitions in the present module;
metadata-only entries do not become executable through this proposal. Existing ClassId availability gates
require a future scoped adapter; this audit does not remove them.

Evidence labels throughout this set:
**OBSERVED** = inspected source; **INTENT** = upstream documentation;
**INFERENCE** = consequence needing an experiment; **PROPOSED** = future Ulduar design.
Source presence never means a live test passed. Historical PLAN files are not implementation specifications.

## Experimental status and explicit warnings

The author's exact warning includes:
> This is a total server overhaul, and it is experimental.

and:
> do not add it to an existing one you care about.

The [README warning block][readme] says the required client patch must be installed by every player;
it warns that installation changes character data and core tables, asks for world/character backups,
requires the same module version on server and client, and identifies bad tooltips and failed casts
as mismatch outcomes. It says unsupported UI addons may misread class, spellbook, talents, paper doll
or power state, produce Lua errors, or break; only the bundled addon is supported and others are untested.
It also warns that some cross-class builds greatly exceed native power and leaves encounter tuning to the realm.
These are the author's stated scope and warnings, not a claim that every combination is broken.

Configuration additionally marks Death Knight/rune support experimental. It warns that disabling DK inclusion
after grants leaves known DK abilities while rune costs can be skipped. Allocation, checks and regeneration
must therefore agree across initialization and configuration changes.

Documentation/source discrepancies:

| Claim or implication | Inspected implementation |
| --- | --- |
| Hero is a universal new class | Fixed Paladin class 2 chassis |
| All talent trees unlocked by client DBC | Installer no longer writes TalentTab.dbc |
| Installer introduction says EXE unchanged by default | Actual CLI enables creation text and EXE patch by default |
| Dry run writes nothing | ensure_pillow runs before dry-run work and may invoke pip |
| Reversible installation | Character conversion saves class without original-class ledger |
| Generated versions match | Generation IDs are logged/printed, not enforced at login |
| Historical plan upgrades already-owned talent on normal rolls | Current normal talent pool excludes owned talents |
| Missing prerequisites are constrained | DropUnresolvablePrerequisites clears missing dependency IDs |
| No default overrides implied | Base SQL disables six pet-upkeep entries |

Additional fields for the same entries:

| Claim or implication | Consequence |
| --- | --- |
| Hero is a universal new class | Native class/stat assumptions persist |
| All talent trees unlocked by client DBC | Bundled talent browser is essential |
| Installer introduction says EXE unchanged by default | Read executable path |
| Dry run writes nothing | Do not execute even dry run here |
| Reversible installation | Uninstall cannot restore old identity |
| Generated versions match | Operational comparison, not a handshake |
| Historical plan upgrades already-owned talent on normal rolls | Paid stake branch differs |
| Missing prerequisites are constrained | Fail-open catalog behavior |
| No default overrides implied | Inspect SQL, not only README |

`PLAN.md` describes earlier chassis/cross-power hooks and phased implementation. The current source uses
contextual PlayerScript hooks instead. `PLAN-elemental-variants.md` retains staged work and open questions
about base/variant coexistence, talent-rooted variant inclusion and element naming; current generated rows
implement parts of those plans. It acknowledges that variant form-kit pairing can require extra rows.
No comprehensive completed acceptance suite is inferred from either plan. No literal TODO/FIXME list in
the principal inspected server files establishes completeness. Rune support, external-addon compatibility,
unproven cross-class combinations and plan/open-question discrepancies remain explicit limitations.

## Complete server source map

Paths in this table are relative to [src][src]. Mgr = ClasslessMgr, PS = ClasslessPlayerScript.
The database and client dependency columns are part of each subsystem's contract.

| Subsystem / files | Hooks / entry | Database |
| --- | --- | --- |
| Registration: cw_loader.cpp | AddClassless* functions | None directly |
| Model: ClasslessWildcard.h | Config, entries, CharState | Mirrors cw tables |
| Service: ClasslessMgr.h/.cpp | LoadConfig, BuildLibrary, grant/save/roll | World, character, auth read |
| Foundation: ClasslessPlayerScript.cpp | World/Player hooks below | Native save + cw state |
| Native aura fixes: same PS file | AuraScript apply/proc/periodic | spell_script_names |
| Protocol: ClasslessAddon.cpp | Player chat interception | Through Mgr |
| Commands: ClasslessCommands.cpp | CommandScript command table | Through Mgr |
| NPC: ClasslessNpc.cpp | CreatureScript gossip | Creature/vendor SQL + Mgr |
| Authored combat: ClasslessForgedScripts.cpp | Player/Unit/Pet/Creature/Spell hooks | Generated spell/creature rows |
| Loot: ClasslessLoot.cpp | Creature kill and pet kill Player hooks | Generated item templates |
| Vendor lists: ClasslessVendorLists.h | Generated constants | npc_vendor and item_template |

Additional fields for the same entries:

| Subsystem / files | Client | Core assumptions |
| --- | --- | --- |
| Registration: cw_loader.cpp | None | AC module loader |
| Model: ClasslessWildcard.h | CWCL records | SpellID and TalentID keys |
| Service: ClasslessMgr.h/.cpp | Addon sender | Player and SpellMgr |
| Foundation: ClasslessPlayerScript.cpp | Power/pet/talent UI | Contextual class API |
| Native aura fixes: same PS file | Native auras | Native effect layouts |
| Protocol: ClasslessAddon.cpp | ClasslessWildcard.lua | Self addon whispers |
| Commands: ClasslessCommands.cpp | Chat | Session/player permission |
| NPC: ClasslessNpc.cpp | Gossip + addon | NPC IDs and player state |
| Authored combat: ClasslessForgedScripts.cpp | Matching DBC/assets | Fixed native spell IDs |
| Loot: ClasslessLoot.cpp | Matching Item.dbc | Native loot/inventory |
| Vendor lists: ClasslessVendorLists.h | Native vendor | Generated gear catalog |

| Subsystem | Authority in reference | Portability classification | Risk |
| --- | --- | --- | --- |
| Registration and constants | Wiring only | KEEP_CONCEPT | LOW |
| Mgr and native ownership | Entire progression | REIMPLEMENT_FROM_REFERENCE | CRITICAL |
| Hero conversion and stat policy | Native character identity | CONFLICTS_WITH_ULDuar | CRITICAL |
| Contextual mechanics/resource hooks | Native compatibility | REIMPLEMENT_FROM_REFERENCE | HIGH |
| Aura fixes | Selected native family effects | EXPERIMENT_FIRST | HIGH |
| Protocol, commands and gossip | Requests; Mgr authorizes | REIMPLEMENT_FROM_REFERENCE | HIGH |
| Hero authored spells/talents | Fixed-ID combat | CONFLICTS_WITH_ULDuar | HIGH |
| Custom gear/loot/vendors | World economy | NOT_NEEDED | HIGH |
| Missing-button recovery helper | Native action projection | PORT_SMALL_COMPONENT candidate | MEDIUM |

No additional gameplay module is a mandatory dependency in the inspected source.
Playerbot account exemptions are optional; the implementation reads account usernames/prefixes.

Ancillary progression paths also remain native and Mgr-coupled:
SetMode handles initial choice/deadline, Rebirth charges gold and resets native grants before replaying the
chosen mode's schedule, and ApplyArchetype can respec/refund a build before automated native purchases.
Stopping an archetype retains existing grants. Rebirth is not a migration tool for Ulduar instances or EP.
Its reset and replay have the same separate-write concerns as other acquisition operations.
BuyScroll checks native inventory/cost through the manager; it is an economy feature, not Forge infrastructure.
GrantRidingSkill and GrantRuneforging teach configured level-gated native spells on login/level-up;
Runeforging restores its skill line and recipes directly, outside the roll/purchase catalog.
Those grants are native permanent convenience policy, not multi-source mechanic entitlements.
SetStatAllocation validates a budget and applies deltas to five native stats; it is Hero gameplay, not QoL.

World hooks: before config load and startup. Player hooks: create, first login, login, logout,
delete-from-DB, level changed, calculate talent points, can learn talent, learn spell, money changed,
after max-power update, contextual IsClass, HasActivePowerType, before guardian stats and update.
Deletion appends cw cleanup to the core deletion transaction. Logout unloads caches, rather than committing
one final aggregate transaction; individual mutations already issue independent writes.

Forged scripts include cast/logout tracking; Crossdraw, Ricochet Shot/bounce, Quickening, Repertoire,
Wildcard Surge, Makeshift Strike, Reserve Break, Ward Off, Area Control, Healing Spit, Emberfeed and Overflow;
pet initialization/world entry, sentry CreatureScript, and Unit damage/healing/death behavior.
These are authored native effects. Their name "Forged" does not signify player-created AbilityInstances.
Quickening checks/spends several native pools as a fixed spell; it is not a metadata-selected resource service.

Configuration covers enable/exemptions, forced Hero chassis, initial gear/proficiencies, DK inclusion,
library filters, overrides, AE/TE prices and level schedules, form kits, stats, variants, Hero spells,
roll weights/pity/bans/locks/scrolls, rebirth, archetypes, loot and vendor behavior.
These knobs encode a realm-wide replacement policy, not independently composable Ulduar services.

## Hero foundation and remaining restrictions

`ClasslessMgr::EnforceChassis` uses **CLASS_PALADIN = 2**. No new Hero class ID is allocated.
It changes the class byte, sets display power, initializes level stats, taxi nodes and talents, updates
all stats, refills health/mana, teaches proficiencies and calls SaveToDB. Create/login can convert existing
characters. Original class provenance is not stored. Client class strings say Hero while class identity stays 2.

All-race creation SQL adds class-2 creation rows and copies human-Paladin action defaults.
The starter path can strip gear and issue neutral equipment, weapons, ammo, food and bags.
The initial native chassis, its base mana and stats survive; periodic universal stat deltas add AGI to AP/RAP
and INT to spell power. This policy must not replace Ulduar PotencyResolver or generic stat semantics.

The module grants broad weapon, armor, shield and dual-wield proficiency. It removes class restrictions
from world items and quests in SQL. Trainers are not Forge: outside-source class-library learning is
intercepted, removed and sometimes refunded through a same-tick last-money-loss heuristic.
A quest can retain XP/item rewards while its class ability reward is removed.

Talent points use a large protective ceiling and are reset to zero free points; normal Hero talent purchases
are blocked through OnPlayerCanLearnTalent. Native passive ownership is still used internally.
Spellbook skill lines and addon tabs present cross-class known spells; the addon replaces the purchase UI.
Stock packets, power fields, pet bars and native spells remain underneath.

**Can a character have no traditional combat identity?** Semantically yes, while retaining an internal native
chassis for login and standard equipment/stats. Source demonstrates ways to expose several mechanics through
that chassis. It does not prove every resource, pet and form combination safe or that all native checks vanish.
Ulduar needs explicit capabilities and entitlement policies, not the Hero rename or forced class conversion.

Restriction inventory, at the scope of inspected paths:

| Restriction | Evidence / affected path | Proposed treatment |
| --- | --- | --- |
| Creation race/class and stats | playercreateinfo, ChrClasses, CharBaseInfo, EnforceChassis | Keep internal chassis |
| Native known-spell/skill eligibility | Player learning/login + SkillRaceClassInfo | Reviewed carrier allowlist |
| Ulduar ClassId availability | Existing module definitions/resolver | Central instance availability adapter |
| Armor/weapon/relic equipment | Player IsClass equipment contexts, item class masks | Entitlement-scoped policy |
| Raw weapon/class checks | Spell.cpp wand handling and other getClass paths | Audit each reviewed carrier |
| Mana/rage/energy maxima and active flags | Player power hooks | Native resource adapters |
| Rune allocation/ticks/spending | InitRunes, RegenerateAll, Spell rune checks | One lifecycle capability |
| Combo/reactive state | Rogue finisher and Warrior Overpower share core storage | Separate event token or reject mix |
| Forms/stances/stealth | SpellInfo Stances and native aura/cast checks | Explicit mechanic requirements |
| Pet loading/type/talents | Pet::LoadPetFromDB, CanSeeDKPet, Guardian stats | Owned pet type and load policy |
| Quest/taxi class contexts | Player IsClass contexts and quest masks | Preserve quest safety; scoped review |
| Native talent family selectors | Talent.dbc, SpellFamily masks, ApplySpellMod | Compile generalized rules |
| Client power visibility | Native single display power and rune class UI | Separate resource presentation |
| Client spell cost/range rejection | Local Spell.dbc and cast validation | Matched reviewed carrier contract |
| Cast identity | Native cast packet has SpellID, not instance ID | Server-owned carrier-to-instance mapping |
| Action buttons/rank cleanup | character_action load and HasSpell | Projection reconciliation |
| Addon class assumptions | Spellbook, talents, paper doll hooks | Compatibility matrix and capability UI |

Local AC already declares contextual class, active-power and guardian-init hooks used by the reference.
That is API compatibility evidence only. A whole-core enumeration of every raw class check and all possible
spell scripts has not been proved complete; the carrier/mechanic expansion gate requires that inventory for
each newly enabled capability. Never answer every IsClass query true or globally bypass CheckCast.

## Universal resource audit

The reference has native pools, a selected display power, rune UI and combo UI. It does not have a generic
custom resource registry. Health exists in the engine but is not a configurable Energy-to-Health keystone here.
Tables cover the eleven requested dimensions; resource maxima/current values are distinct from ownership.

| Dimension | Mana | Rage |
| --- | --- | --- |
| Source of truth | Native Player mana | Native Player rage |
| Display/UI | Native selected bar + addon | Native selected bar + addon |
| Regeneration | AC RegenerateAll, mana rules | Native decay/regen auras |
| Generation | Native regen/energize | Native damage/hit/reactive paths |
| Spending | Spell native mana cost | Native rage cost, internal tenths |
| Cast validation | Native CheckPower/CheckCast | Native power check |
| Initialization | Paladin base mana/stats | Max raised by hook, default 1000 internal |
| Persistence | Native save/login lifecycle | Native lifecycle; cw stores no amount |
| Class assumptions | Chassis mana/int/spirit | Active-power hook enables pool |
| Spell family assumptions | Native cost/regen modifiers retained | Native modifiers retained |
| Client assumptions | DBC costs can reject locally | Selected native bar cannot show all |

Additional fields for the same entries:

| Dimension | Energy |
| --- | --- |
| Source of truth | Native Player energy |
| Display/UI | Native selected bar + addon |
| Regeneration | AC RegenerateAll |
| Generation | Native regen/energize |
| Spending | Native energy cost |
| Cast validation | Native power check |
| Initialization | Max raised to 100 |
| Persistence | Native lifecycle; cw stores no amount |
| Class assumptions | Active-power hook enables pool |
| Spell family assumptions | Native modifiers retained |
| Client assumptions | Forms may choose native display |

| Dimension | Runic Power | Runes |
| --- | --- | --- |
| Source of truth | Native Player RP | Native six rune slots/cooldowns |
| Display/UI | RU addon payload + native selection limits | RU type/ready flags, no remaining time |
| Regeneration | Native RP decay with DK ability context | AC rune cooldown/grace loop |
| Generation | Native rune-spend/energize effects | Cooldown completion/conversion effects |
| Spending | Native RP spell cost | Native rune cost/type/grace handling |
| Cast validation | Native power check | Native DK-context rune checks |
| Initialization | Active when session rune flag permits | LoadCharacter fixed-session flag; InitRunes |
| Persistence | No cw current-RP column | No cw rune cooldown ledger |
| Class assumptions | DK context for native decay | Allocation and context must agree |
| Spell family assumptions | Native DK modifiers remain | DK aura fixes still native mechanics |
| Client assumptions | Addon knows RP; limited refresh | Custom row required on Paladin chassis |

Additional fields for the same entries:

| Dimension | Combo Points |
| --- | --- |
| Source of truth | Native target-bound combo state |
| Display/UI | CP count for selected target |
| Regeneration | No passive regeneration |
| Generation | Native add-combo effects |
| Spending | Native finisher paths |
| Cast validation | Native target/points checks |
| Initialization | Native state on login/target |
| Persistence | No cw combo persistence ledger |
| Class assumptions | Rogue/Warrior reactive collision |
| Spell family assumptions | Native finisher family effects remain |
| Client assumptions | Packet count lacks target GUID |

OnPlayerHasActivePowerType marks mana/rage/energy active for enabled, non-exempt, in-world players.
RP follows the session rune flag. Other queries fall through to native behavior.
There is no independent module regeneration loop replacing AC. Core RegenerateAll already visits energy/mana;
rage/RP and rune regeneration follow their native schedules and conditions.

The selected bar is persisted as a display choice; the two-second update restores it except in native
Cat/Ghoul/Bear/Dire Bear display forms. Rune state is a session snapshot to avoid changing a class-context
answer after rune allocation. Rune UI appears when an owned spell needs runes or RP. Updates cache a rune
type/ready signature and bucket RP changes; no exact remaining cooldown is transmitted. The update path
skips dead players. Reconnect, resurrection and stale selected targets therefore need explicit UI experiments.

OnPlayerIsClass makes contextual decisions. Reactive Hunter checks look for Counterattack ownership and
Warrior checks look for Overpower; Rogue reactive identity is suppressed. The source documents that
Overpower and rogue finishers share the native combo pool, including expiry clearing points.
Pet context uses creature type; with no current pet the implementation returns true for pet class queries,
despite a nearby comment suggesting neutral fallback. This needs load-order testing, not an assumed crash.

### Proposed UlduarResourceService

ResourceSpec is selected by resolved metadata: resource key, cost expression, unit, generation policy,
regen policy, maximum policy and required mechanic. Native adapters cover Mana, Rage, Energy, RunicPower,
Runes and target-bound ComboPoints. HealthCost is a separate future adapter with explicit survival rules.

Use native values as the single amount authority. Do not mirror and tick a second pool.
Prepare a cast-local cost quote after gems/talents/keystone resolution; validate availability at native commit,
spend once using an ownership token and define interruption/refund semantics per resource.
One adapter owns each spend path, preventing both native and Ulduar subtraction.
Rune readiness and combo target GUID belong in the quote, not just a displayed count.
Keystones may replace a cost resource only when both source and destination adapters support the whole path.
UI selection never determines cost. Serialize resource values from the server with unit and snapshot revision.
Persist entitlements/policies durably; let reviewed native lifecycle own transient amounts unless an explicit
future cooldown-save contract replaces it. Configuration reload must not invalidate allocated rune storage.

Keep the reference's contextual activation, unit conversion and rune snapshot lessons.
Rewrite class-specific stat policy, all-resource free grants and resource selection around semantic metadata.

## Mechanic lifecycle and prerequisite kits

In this table, "native" restoration means ordinary engine persistence; it is not proof of a separate,
transactional module entitlement ledger. All rows require Ulduar reimplementation, except engine utilities
that remain native. No row authorizes a global restriction bypass.

| Mechanic | Grant / lifetime | Removal / other sources |
| --- | --- | --- |
| Forms | Stances analysis grants an allowed form or kit | Companion pruning; one source enum |
| Stances | cw_form_kits and required-form path | Same companion sweep |
| Stealth | Native ability and optional kit | Owned native rank removal |
| Pets | Summon/tame/control native abilities and kits | Dismiss orphan; hunter save-not-in-slot |
| Pet bars | Native control UI after pet load | Dismiss clears active bar |
| Pet spells | Core pet spells plus prerequisite pairs | Not a general pet-spell source ledger |
| Runes | Config/session capability, not earned mechanic | Cannot safely revoke by simple flag |
| Runic Power | Rune session gate and native max | No independent entitlement reference count |
| Combo Points | Native generating abilities | Native target/finisher/expiry rules |
| Dual Wield | Broad permanent proficiency teaching | Normally remains; uninstall bulk removal |
| Weapon Skills | Broad permanent skill/proficiency kit | No per-source lifecycle |
| Armor Skills | Broad permanent proficiencies | No per-source lifecycle |
| Shields | Proficiency + equipment context | Broad grant, not transient |
| Ranged Weapons | Proficiency, DBC relic/class changes | Broad grant, native gear persists |
| Ammo | Starter/vendor ammo and native consumption | Item lifetime, not mechanic reference |

Additional fields for the same entries:

| Mechanic | Restore / remaining class and UI issues |
| --- | --- |
| Forms | Login sync; native stance/aura checks |
| Stances | Native stance bar/class assumptions |
| Stealth | Native stealth aura/cast checks remain |
| Pets | Pet DB, type context, DK visibility ordering |
| Pet bars | Native charm packets; async load experiment |
| Pet spells | Native pet storage/type/talent scripts |
| Runes | Native InitRunes and DK class UI |
| Runic Power | Native amount + RU addon |
| Combo Points | Shared reactive pool; CP lacks GUID |
| Dual Wield | Native equip checks and known spell |
| Weapon Skills | Native skills saved; class overrides |
| Armor Skills | Item masks rewritten in SQL |
| Shields | Native shield restrictions still relevant |
| Ranged Weapons | Ranged slot/wand class checks |
| Ammo | Native ammo validation; tools != reagents |

`GrantRequiredForm` scans native Stances, skips allow-without-form spells, accepts an already known valid
form, otherwise chooses a stable available form. Talent-only unavailable forms do not necessarily reject
the purchase. A form owned at too-low rank can also leave the ability unusable until later.
This is convenience repair, not full build validation.

`cw_form_kits` maps form/parent SpellID to child SpellID. GrantFormKit deduplicates across parent ranks,
skips already owned children and stops nested kit recursion. Some children outside the library are learned
without a cw ownership row. Companion justification deliberately excludes companion-only cycles,
but scans parent ranks beyond just the active rank. Pruning removes companion native chains, not a
source-counted entitlement. One GrantSource enum cannot represent simultaneous quest, item, talent and
Forge ownership. Repeated pet-orphan cleanup compensates for pets returning after mount transitions.

`DismissOrphanedPet` checks the created-by spell; hunter Call Pet and kit relationships receive special
handling. It uses PET_SAVE_NOT_IN_SLOT for hunter pets. Guardian initialization chooses HUNTER_PET for beasts
and SUMMON_PET otherwise. OnLogin sets DK-pet visibility after HandleLogin; local Pet::LoadPetFromDB can
reject DK-context loading without visibility. Establish actual asynchronous ordering in isolation.

### Proposed UlduarMechanicEntitlementService

MechanicRequirement identifies capability, version, parameters and authored policy: Reject, RequireExisting
or GrantWhileSourceActive. Resolve dependencies as a bounded acyclic graph before spending a Core or Gem.
An unavailable form, rune adapter, weapon or pet implementation makes that candidate unsupported.

Entitlement rows are keyed by owner, mechanic key, source type and source instance.
Releasing one source removes only that source. The effective grant remains while another source exists.
Permanent quest/native grants are distinct from transient equipped-instance, talent, item and keystone sources.
Projection is idempotent; it records what the service owns and never removes unrelated known spells.
On source loss, define aura exit, equipment handling, pet dismissal/save, rune pending casts and combo target cleanup.
Login reconciles durable desired grants with native state before enabling casts; logout/death/map/spec changes
have explicit per-mechanic policies. Fail closed for unknown dependencies; do not silently erase prerequisites.

## Native ranks, spellbook and action bars

BuildLibrary uses SkillLineAbility class masks/class skill lines, native spell chains, trainer evidence,
teaching spells and overrides. Root identity comes from GetFirstSpellInChain; rank IDs and required levels
are collected per line. Native name deduplication and quest-related filtering are catalog policy.
Missing/empty trainer sources can disable that configured filter for the session, broadening the pool.

GrantAbility learns rank one and eligible later ranks. UpdateAbilityRanks learns eligible ranks on level changes;
the native engine manages active/inactive lower ranks. Removal traverses the whole chain across specs.
Passive entries are treated separately in presentation; passive native auras still execute.

`RestoreDroppedActionButtons` reads active-spec character_action rows, considers spell actions,
requires HasSpell, does not overwrite an occupied button and sends initial action buttons after repair.
This is a narrow candidate because the function depends on Player, CharacterDatabase and action constants,
rather than Mgr budgets, Hero conversion or world rewrite. It still needs an entitlement/projection guard.
It neither supplies durable desired Forge slot mapping nor solves two instances sharing one carrier.

CoreSpellGrantAdapter should project a reviewed carrier/rank for an owned AbilityInstance, record that
projection, retain independent native sources, and repair action mapping from durable instance slots.
Known spells are execution capability, not evidence of Forge ownership.
Use native rank replacement packets where appropriate, preserving deliberate downranking policy.
Do not silently bind a saved button to a different instance after a catalog revision.

## Free Pick: complete acquisition path

| Concern | Observed source behavior | Ulduar consequence |
| --- | --- | --- |
| Catalog | Native class skill/trainer/talent catalog + generated lines | Reference data, not Forge identity |
| Currency | AE and TE in CharState; configurable level awards | Do not adopt economy |
| Ability price | Server rarity/override cost | Keep server-derived pricing concept |
| Talent price/ranks | Server rank cost, optional rank scaling | Semantic TalentOwnership instead |
| Prerequisites | Talent dependency and row/level; replaced-talent ability accepted | Need complete dependency graph |
| Tiers | Level 10 + row * 5; no native points-in-tree requirement | Authored Ulduar policy |
| Missing prerequisite | Dropped when unresolved in catalog | Reject/quarantine definition |
| Learn | Mode, enabled, ownership, level, funds checked | Resource/mechanic feasibility still required |
| Unlearn | Native chain removal, current-price refund | Refund receipt-paid cost, preserve sources |
| Talent unlearn | Checks dependent talent use | Ability removal can invalidate replaced prerequisite |
| Respec | Removes grants; recalculates budgets from level | Durable receipt and migration policy |
| Client authority | Addon/commands/NPC request; server computes outcome | Preserve authority, rewrite transport |
| Unsupported abilities | Filters/exclusions, not full runtime adapter certification | Explicit capability allowlist |
| Stale requests | No expected build/catalog revision | Reject stale commit |
| Duplicate requests | Owned checks stop some buys; ranks/rerolls can advance again | Idempotency key needed |
| Reconnect | Loads cw state, synchronizes/reconciles native spells | No transaction receipt recovery |
| Persistence | Multiple Execute/REPLACE calls around native changes | No atomic durable purchase boundary |

Purchase methods lack a universal combat/death/movement mutation gate. Different entry points must not
supply inconsistent legality. Addon's authenticated self-whisper receiver is a useful trust boundary,
but authenticated players can still send malformed or repeated requests.

CWCL parses numeric arguments and bounded outgoing records; it sends small ability/talent pages.
HELLO can trigger broad spell correction work. No dedicated per-command request ID, expected revision,
catalog hash or robust operation rate budget was found. The existing Ulduar Protocol 2 protections are
a better starting point, though an in-memory sequence is not a durable purchase receipt.

Two concrete input-validation gaps deserve dedicated later cases: addon MODE narrows a parsed integer to
uint8, while SetMode checks exemption/deadline but does not whitelist the requested enum values.
STATSETALL accepts five uint32 values; SetStatAllocation sums them in uint32 before comparing to budget.
An overflowing sum can evade that comparison. Use checked wide sums and individual bounds in Ulduar.
These source findings do not assert that a live exploit was reproduced.

Money-refund tracking remembers a same-tick negative delta, rather than a trainer transaction identity.
Do not reuse it for Ulduar purchases. Grant/load/delete paths do not make the entire character operation atomic:
SaveState, SaveBans and per-ability/per-talent persistence use separate writes; native saves are another layer.
SaveBans deletes then reinserts. A query failure can resemble absent state. Client success is not a commit receipt.

Useful concepts: searchable catalog, server prices, native rank projection, explicit preview, dependency repair,
and reconnect reconciliation. The module does not provide a Forge-ready entitlement transaction service.

## Wildcard: roll semantics and persistence

Pool = enabled native ability/talent entries, not component definitions. Ability filtering excludes owned
roots/names and bans; variant policy is configurable. Synergy uses origin class masks and persisted pity.
Weights feed server RNG; all-zero weights fall back to uniform choice. Unordered iteration and unrecorded RNG
do not provide a deterministic, replayable offer ledger. No claim about cryptographic unpredictability is made.

A roll immediately grants and saves its result, then sends a reveal message. The client's Keep button advances
the reveal queue; it does not accept a durable pending server offer. Disconnect cannot recover an unaccepted
choice because that transaction model does not exist here.

Talent rolls exclude owned entries and select a rank; current roll filtering does not apply the same dependency
check as BuyTalent. A paid stake reroll can upgrade an existing talent. Rank jumps explicitly remove the previous
native passive before adding the new rank, avoiding one source of doubled effects.

Reroll verifies mode and ownership, charges earned rerolls or native scroll items, removes the old result,
persists bans/pity and rolls a replacement. If replacement generation fails, the caller can still report success;
there is no encompassing rollback. Empty pools first release bans and can then seek the lowest remaining level,
potentially above the character's current level. Higher-level catch-up rolls use the final current player level.
Saving each roll before advancing last-level state creates an inferred crash-replay risk during catch-up.

Starting-hand locks protect owned non-companion/non-talent ability grants below the configured free-reroll level.
SetLock expresses a desired boolean, which is safer than a toggle; a legacy toggle path still exists.
RerollUnlockedAbilities snapshots server-owned unlocked entries and loops ordinary Reroll until failure.
This is repeated immediate mutation, not one atomic rapid-roll batch or a persisted rapid-roll job.
The addon reveal/animation queue is presentation only. No separate generic rapid-roll engine was verified.

For Ulduar, classify the engine **REIMPLEMENT_FROM_REFERENCE**:
component offers identify GemDefinition, Core reward, TalentDefinition or SocketUpgrade.
Persist offer ID, owner, candidate definitions, catalog/pool version, RNG audit reference, expiration,
reroll price receipt, lock state and offer revision. Accept is one durable idempotent transaction.
Semantic build affinities replace origin-class masks. Never consume the previous reward or currency unless
a legal replacement exists and the transaction commits. See [Progression](ULDuar_PROGRESSION_ARCHITECTURE.md).

## Talents: cross-class access is not generalization

Talent.dbc supplies class tabs, rows, columns, dependency IDs and native rank spells. Pet tabs are excluded.
Native TalentID and passive SpellIDs remain authoritative. Grants call learnSpell/addTalent and native
talent synchronization rather than Player::LearnTalent, while normal talent-point UI is disabled.
Some active talents become ability lines; missing prerequisite entries are removed from dependency checks.

SpellFamily masks are not generalized. ApplySpellMod still applies native family selectors.
The addon sends server-computed native cost, cast time, cooldown, duration, range and effect corrections.
Those calculations and selected aura-script fixes improve native cross-class behavior; they do not turn
Improved Fireball into a semantic Fire + Damage + CastTime rule.

Native aura replacements cover Frenzied Regeneration, Judgement of Wisdom, pet hit/expertise scaling,
Blade Barrier and death-rune handling. Replacing SQL script bindings avoids combining old and new
proc predicates; importing a second binding could instead suppress or double effects.
Family-free Ulduar rules still benefit from the lessons: remove old passive ranks, preserve native aura lifecycle,
calculate tooltip fields server-side, and distinguish displayed power from an actually available pool.

Client cost floors anticipate possible native talent reductions so local DBC checks do not reject valid casts.
That is not a general cost resolver and does not include every Ulduar transformation or haste effect.
Text correction only substitutes unambiguous numbers; ambiguous descriptions are left unchanged.
Generalized rules must have exclusive execution ownership so the corresponding native passive does not apply twice.

## Client patch inventory and version contract

Classifications describe why the reference uses each change; they do not prescribe importing it into Ulduar.

| Changed surface | Actual files/behavior | Classification |
| --- | --- | --- |
| Wow.exe | exepatch.py signature-based interface patches | RISKY_BINARY_PATCH |
| Interface checks | Six mandatory sites and optional seventh | RISKY_BINARY_PATCH |
| Base MPQ | New Data patch archive; original archives untouched | USEFUL_FOR_ABILITY_FORGE concept |
| Locale MPQ | New locale overlay and localized glue strings | REQUIRED_FOR_CLASSLESS presentation |
| GlueXML | CharacterCreate.lua, GlueStrings.lua | REQUIRED_FOR_CLASSLESS Hero screen |
| FrameXML | No wholesale replacement found; addon hooks stock frames | NOT_NEEDED as a core replacement |
| ChrClasses.dbc | Hero labels and relic-slot behavior | REQUIRED_FOR_CLASSLESS Hero UI |
| CharBaseInfo.dbc | All races on class 2 | REQUIRED_FOR_CLASSLESS Hero creation |
| SkillRaceClassInfo.dbc | Universal skill access | REQUIRED_FOR_CLASSLESS reference model |
| SkillLineAbility.dbc | Universal class masks / learn policy / generated lines | REQUIRED_FOR_CLASSLESS |
| Spell.dbc | Tool requirements, cost floor, generated spell rows | REQUIRED_FOR_CLASSLESS reference data |
| SkillLine.dbc | Generated Hero skill line | NOT_NEEDED |
| SpellVisual.dbc | Generated visual combinations | USEFUL_FOR_ABILITY_FORGE idea |
| SpellIcon.dbc | Element badge icons for variants | USEFUL_FOR_ABILITY_FORGE idea |
| Item.dbc | Generated gear item metadata | NOT_NEEDED |
| CharStartOutfit.dbc | Hero starter outfit | NOT_NEEDED |
| Talent.dbc | Read for cost-floor analysis; not generalized talents | NOT_NEEDED as authority |
| TalentTab.dbc | Legacy cleanup name; no current installer payload | NOT_NEEDED |
| Class icon textures | Hero/class creation presentation | NOT_NEEDED |
| ClasslessWildcard addon | Character Advancement purchase/search/talents | REQUIRED_FOR_FREE_PICK |
| Roll/reveal/lock UI | Same Lua addon | REQUIRED_FOR_WILDCARD |
| Multi-resource UI | Native fields plus CP/RU messages | USEFUL_FOR_ABILITY_FORGE |
| Spellbook/action bars | Cross-class tab and rank handling | USEFUL_FOR_ABILITY_FORGE |
| Tooltip corrections | SF/SC-style server native modifier records | USEFUL_FOR_ABILITY_FORGE |
| Paper doll/stat allocation | Hero stat effects and custom allocation | CONFLICTING gameplay; not QoL-only |
| Cosmetic frame styling/help | Addon presentation | QOL_ONLY |

The addon changes spellbook, talent and paper-doll behavior through hooks. It is not a portable Forge UI.
Generated elemental/forged SQL and client JSON manifests must describe the same native IDs and effects.

`exepatch.py` recognizes instruction patterns and already-patched variants. Known SHA256 values label
recognized clients; they are not a strict complete-file allowlist gate. A backup is retained before direct
writes. The installer also manages addon files, cache removal and an install JSON record.
Its top-level description is stale about default EXE patching: argparse defaults and install flow win.

The install JSON has version, suffix/locales, installed files, addon/creation-text and EXE-patched state.
Generated spell datasets have generation IDs, logged by server and printed by installer.
No enforced addon/DBC/MPQ/taxonomy/catalog content-hash negotiation was found.

Potential Ulduar Client Patch Builder: keep the concept of deterministic overlays generated from a single
manifest; experiment with MPQ writer/reader and DBC transformation primitives in isolation.
Those helpers live in client-patch/lib/mpq.py, pkware.py, dbc.py and the related transformation modules;
the binary patcher is client-patch/lib/exepatch.py, while install.py is at client-patch root.
Do not port the installer wholesale. The inspected DBC parser validates magic/layout but is not a complete
bounds-hardened hostile-input parser. Python/Pillow bootstrap and EXE modification must be separate,
explicit packaging steps, never side effects of validation or dry run.
A future builder needs input hashes, row ownership, collision checks, output hashes, atomic publication,
rollback manifests and independently tested malformed archive/DBC handling.
No binary patch is required merely to design or store an AbilityInstance.

## SQL inventory

This is a static inventory of all 25 inspected SQL files, including diagnostics, manual reverts and uninstall.
Auto-load paths contain 3 character files and 16 world files. No auth table is created or altered.
Categories: NEW TABLE; ALTER EXISTING TABLE; DELETE/REPLACE EXISTING DATA; BULK WORLD REWRITE;
DBC OVERRIDE; CHARACTER STATE. A table may have several categories.

### New module and backup tables

| Table | Categories and operation | Source SQL family |
| --- | --- | --- |
| cw_char_state | NEW TABLE, CHARACTER STATE; later ALTER and UPDATE | characters base/rerolls/archetype |
| cw_char_abilities | NEW TABLE, CHARACTER STATE; native root ownership | characters base |
| cw_char_talents | NEW TABLE, CHARACTER STATE; native TalentID rank | characters base |
| cw_char_bans | NEW TABLE, CHARACTER STATE; reroll exclusion | characters base |
| cw_ability_override | NEW TABLE; delete/insert default exceptions | world base |
| cw_talent_override | NEW TABLE | world base |
| cw_archetypes | NEW TABLE; delete/insert authored builds | archetypes |
| cw_form_kits | NEW TABLE; delete/insert tagged default pairs | world form kits |
| cw_ability_variants | NEW TABLE; delete/insert generated mappings | spells elemental |
| cw_ability_variants_meta | NEW TABLE; REPLACE generation | spells elemental |
| cw_forged_spells | NEW TABLE, ALTER EXISTING TABLE; generated rows | spells forged |
| cw_forged_meta | NEW TABLE, ALTER EXISTING TABLE; REPLACE generation | spells forged |
| cw_item_class_backup | NEW TABLE; INSERT IGNORE original item masks | world item classes |
| cw_quest_class_backup | NEW TABLE; INSERT IGNORE original quest masks | world class quests |
| cw_vlist | NEW TEMPORARY TABLE; populate/update working vendor list | world vendor lists |

### Existing world tables

| Table | Categories / scope | Source SQL family |
| --- | --- | --- |
| item_template | DELETE/REPLACE custom items; BULK WORLD REWRITE AllowableClass | items*, base, item classes |
| quest_template_addon | BULK WORLD REWRITE nonzero AllowableClasses to zero | class quests |
| playercreateinfo | INSERT IGNORE all-race class-2 rows | hero races |
| playercreateinfo_action | INSERT IGNORE class-2 actions copied from human Paladin | hero races |
| playercreateinfo_item | DELETE/REPLACE legacy cw-kit tagged starter rows | base |
| creature | DELETE/REPLACE module NPC spawns | base |
| creature_template | DELETE/REPLACE/UPDATE module NPCs, pets, vendors | base, forged, vendors |
| creature_template_model | DELETE/REPLACE model bindings for those entries | base, forged, vendors |
| creature_template_spell | DELETE/REPLACE generated pet spell bindings | forged |
| npc_vendor | DELETE/REPLACE module vendors/items | base, vendors |
| conditions | DELETE class-loot/vendor conditions; restore in manual revert | class loot, vendors |
| item_loot_template | BULK reward-bag group/chance UPDATE | class loot |
| spell_script_names | DELETE/REPLACE selected native and generated bindings | spell scripts, forged |
| spell_ranks | DELETE/REPLACE generated rank chains | elemental, forged |
| spell_dbc | DBC OVERRIDE; DELETE/REPLACE generated spells | elemental, forged |
| talent_dbc | DBC OVERRIDE; DELETE/REPLACE Hero talents | forged |
| talenttab_dbc | DBC OVERRIDE; DELETE/REPLACE Hero talent tabs | forged |
| skillline_dbc | DBC OVERRIDE; DELETE/REPLACE Hero skill line | forged |
| skilllineability_dbc | DBC OVERRIDE; DELETE/REPLACE generated skill abilities | elemental, forged |
| skillraceclassinfo_dbc | DBC OVERRIDE; DELETE/REPLACE universal/generated access | skillraceclass, forged |

Quest changes are to **quest_template_addon**, not quest_template.
There is no DML against playercreateinfo_spell or playercreateinfo_spell_custom in the inspected SQL.
The latter is a catalog read dependency. Do not mistake reading a table for rewriting it.
Class-loot edits include condition source groups 10036-10061 and reward entries 51999-52005.
Backup tables cover item/quest class masks, not a full original-world snapshot.

### Manual revert, uninstall and implicit native state

| Table / group | Additional destructive/restorative action |
| --- | --- |
| item_template, quest_template_addon | Manual/uninstall restores saved class masks; custom rows also deleted |
| cw_item_class_backup, cw_quest_class_backup | Manual/uninstall drops backups after restore |
| conditions, item_loot_template | Manual class-loot revert deletes/reinserts predicates and resets loot grouping |
| cw_char_state, cw_char_abilities, cw_char_talents, cw_char_bans | Character uninstall DROP TABLE |
| cw_char_cards | Legacy table DROP on uninstall; not created by current auto SQL |
| character_spell | Character uninstall deletes broad proficiency spell IDs |
| updates | Both DB uninstall scripts delete cw updater bookkeeping |
| charstartoutfit_dbc | Legacy DBC override rows deleted only by world uninstall |
| cw_ability_override, cw_talent_override, cw_archetypes, cw_form_kits | World uninstall DROP TABLE |
| creature, creature_template, creature_template_model, npc_vendor | Module rows deleted by world uninstall |
| skillraceclassinfo_dbc, spell_script_names | Override removal and selected native script restoration |

Generated spell/variant/talent metadata and some creation additions remain after the current uninstall;
do not call it a complete world reset. Removing class overrides lets native login cleanup remove some
cross-class spells, but does not restore the pre-conversion class or every originally owned source.
The diagnostics SQL contains reads, not mutations.

Runtime additionally writes the four cw character tables, and native Player/Pet/inventory APIs can save
characters, character_spell, character_talent, character_skills, character_action, character_inventory,
item_instance and pet-related state. These are indirect engine effects, distinct from direct module SQL DML.
Auth `account`, trainer_spell or legacy npc_trainer, playercreateinfo_spell_custom,
character_action and information_schema are read dependencies. No auth schema mutation was observed.

Almost all world rewrites exist to support the total Hero realm: universal item/quest masks, starter rows,
custom gear/vendors, native talent catalogs, variant SpellIDs and generated DBC entries.
None is imported into Ulduar. Forge initially needs its own future ownership schema and reviewed projections,
not these SQL files.

## EXPERIMENT_RISK_REGISTER

Severity describes the consequence if imported or relied on without validation, not a demonstrated live incident.

| ID | Risk | Rating | Mitigation / required evidence |
| --- | --- | --- | --- |
| R01 | Experimental upstream changes | HIGH | Pin commit, inspect every update and generated diff |
| R02 | Destructive DB/world assumptions | CRITICAL | Fresh sandbox DBs; never import into Ulduar |
| R03 | Client/server mismatch | CRITICAL | Enforced content manifest before custom casts/commits |
| R04 | Native family masks | HIGH | Semantic selectors; reviewed native fallback only |
| R05 | Double talent application | CRITICAL | One executor per effect; rank removal and provenance |
| R06 | Resource ownership/spending conflict | HIGH | Single native amount authority and commit token |
| R07 | Rank/source collision | HIGH | Source ledger plus carrier projection reconciliation |
| R08 | AbilityInstance confused with SpellID | CRITICAL | Stable instance ID, explicit active mapping |
| R09 | Pet ownership/load order | HIGH | Source-aware pet lifecycle; async restore experiment |
| R10 | Form/stance removal | HIGH | Dependency graph, aura exit and source retention |
| R11 | Rune initialization/config reload | CRITICAL | Allocation/check/tick invariant; no live flag reversal |
| R12 | Combo target/reactive collision | HIGH | GUID-bound snapshots; separate Overpower token or reject |
| R13 | Stale action ranks/slots | HIGH | Durable instance slots; safe button restoration |
| R14 | Client binary/MPQ incompatibility | CRITICAL | Separate client; hash gates; no default EXE edits |
| R15 | Addon conflicts | HIGH | Test spellbook, bar, talent and paper-doll integrations |
| R16 | Future AC API changes | HIGH | Pinned compatibility contract and upgrade review |
| R17 | Upstream abandonment | MEDIUM | Small independent adapters; no full-module dependency |
| R18 | License/attribution obligations | HIGH | Verify per-file notices before any future code distribution |
| R19 | Security/client trust | CRITICAL | Authenticated actor, bounded parser, revision, receipt, rate limits |
| R20 | Existing Ulduar character migration | CRITICAL | No conversion; explicit reversible legacy adoption later |
| R21 | Separate writes and crash replay | CRITICAL | Atomic ownership/ledger/outbox; fault-injection plan |
| R22 | Global grant guards across players | HIGH | Inspect map-thread scheduling; per-actor serialized state |
| R23 | Global SpellInfo tool mutation | HIGH | No shared metadata mutation; per-cast reviewed requirements |
| R24 | Fail-open missing catalog/prerequisites | HIGH | Quarantine invalid definitions, reject unsupported builds |
| R25 | Installer dry-run side effects | HIGH | Never run it here; separate dependency bootstrap |
| R26 | Empty reroll/partial bulk operation | HIGH | Reserve legal result and commit atomically |
| R27 | Display/cost mismatch | HIGH | Same resolved snapshot and matched carrier feasibility |
| R28 | Unbounded combinations and recursion | HIGH | Validated graph budgets and immutable execution snapshots |

R22 is a source-derived concurrency concern: Mgr's grant/suppression flags are instance-wide booleans,
while state-map access has a mutex. The mutex alone does not prove those guards safe across map threads.
R23 is directly observed: StripSpellTools clears shared SpellInfo Totem/TotemCategory fields through const_cast;
reagents are not the same fields and are retained. Neither mechanism should be copied.

The repository LICENSE is GPL-2.0 text; file-specific/core notices also need review.
Record Dustin Hendrickson/upstream authorship and exact source commit for any later extraction.
This is a provenance gate, not a legal compatibility determination.

## Conclusion and linked decisions

The valuable reference is lifecycle knowledge: simultaneous native pools, contextual class checks,
prerequisite kits, native passive/rank cleanup, pet restoration, addon corrections and missing action recovery.
No inspected subsystem replaces Ulduar taxonomy, effect graph, potency/coverage, gems, generalized talents,
keystones or deterministic execution.

Continue with [Portability](CLASSLESS_WILDCARD_PORTABILITY.md),
[Forge](ULDuar_ABILITY_FORGE_ARCHITECTURE.md), [Progression](ULDuar_PROGRESSION_ARCHITECTURE.md),
[QoL](ULDuar_QOL_REFERENCE_AUDIT.md), [Experiments](ULDuar_EXPERIMENT_PLAN.md),
[Roadmap](ULDuar_GAMEPLAY_ROADMAP_V2.md), [Slice 1](ULDuar_VERTICAL_SLICE_V1.md)
and [Amendments](ULDuar_ARCHITECTURE_AMENDMENTS.md).

[readme]:
  https://github.com/DustinHendrickson/mod-classless-wildcard/blob/5ffe6957cad9/README.md
[src]:
  https://github.com/DustinHendrickson/mod-classless-wildcard/tree/5ffe6957cad9/src
[sql]:
  https://github.com/DustinHendrickson/mod-classless-wildcard/tree/5ffe6957cad9/data/sql
[client]:
  https://github.com/DustinHendrickson/mod-classless-wildcard/tree/5ffe6957cad9/client-patch

Source anchors: [SQL inventory][sql], [client implementation][client].
Server symbols above resolve within [the pinned source directory][src], especially ClasslessMgr.cpp,
ClasslessPlayerScript.cpp and ClasslessAddon.cpp. This audit records observed code and proposed gates;
the [experiment plan](ULDuar_EXPERIMENT_PLAN.md) contains future tests, none executed in this phase.

## Appendix: every SQL file and mutation target

This per-file index includes direct DDL/DML only. See the preceding inventory for scope and indirect native saves.

### data/sql/db-characters/cw_characters_archetype.sql

| Table | Operations |
| --- | --- |
| cw_char_state | ALTER TABLE |

### data/sql/db-characters/cw_characters_base.sql

| Table | Operations |
| --- | --- |
| cw_char_abilities | CREATE TABLE |
| cw_char_bans | CREATE TABLE |
| cw_char_state | CREATE TABLE |
| cw_char_talents | CREATE TABLE |

### data/sql/db-characters/cw_characters_rerolls.sql

| Table | Operations |
| --- | --- |
| cw_char_state | ALTER TABLE; UPDATE |

### data/sql/db-world/cw_archetypes.sql

| Table | Operations |
| --- | --- |
| cw_archetypes | CREATE TABLE; DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_items_heirlooms.sql

| Table | Operations |
| --- | --- |
| item_template | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_items_pack.sql

| Table | Operations |
| --- | --- |
| item_template | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_items_pack2.sql

| Table | Operations |
| --- | --- |
| item_template | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_items_tiered.sql

| Table | Operations |
| --- | --- |
| item_template | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_spells_elemental.sql

| Table | Operations |
| --- | --- |
| cw_ability_variants | CREATE TABLE; DELETE FROM; INSERT INTO |
| cw_ability_variants_meta | CREATE TABLE; REPLACE INTO |
| skilllineability_dbc | DELETE FROM; INSERT INTO |
| spell_dbc | DELETE FROM; INSERT INTO |
| spell_ranks | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_spells_forged.sql

| Table | Operations |
| --- | --- |
| creature_template | DELETE FROM; INSERT INTO |
| creature_template_model | DELETE FROM; INSERT INTO |
| creature_template_spell | DELETE FROM; INSERT INTO |
| cw_forged_meta | ALTER TABLE; CREATE TABLE; REPLACE INTO |
| cw_forged_spells | ALTER TABLE; CREATE TABLE; DELETE FROM; INSERT INTO |
| skillline_dbc | DELETE FROM; INSERT INTO |
| skilllineability_dbc | DELETE FROM; INSERT INTO |
| skillraceclassinfo_dbc | DELETE FROM; INSERT INTO |
| spell_dbc | DELETE FROM; INSERT INTO |
| spell_ranks | DELETE FROM; INSERT INTO |
| spell_script_names | DELETE FROM; INSERT INTO |
| talent_dbc | DELETE FROM; INSERT INTO |
| talenttab_dbc | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_world_base.sql

| Table | Operations |
| --- | --- |
| creature | DELETE FROM; INSERT INTO |
| creature_template | DELETE FROM; INSERT INTO; UPDATE |
| creature_template_model | DELETE FROM; INSERT INTO |
| cw_ability_override | CREATE TABLE; DELETE FROM; INSERT IGNORE INTO |
| cw_talent_override | CREATE TABLE |
| item_template | DELETE FROM; INSERT INTO |
| npc_vendor | DELETE FROM; INSERT INTO |
| playercreateinfo_item | DELETE FROM |

### data/sql/db-world/cw_world_class_loot.sql

| Table | Operations |
| --- | --- |
| conditions | DELETE FROM |
| item_loot_template | UPDATE |

### data/sql/db-world/cw_world_class_quests.sql

| Table | Operations |
| --- | --- |
| cw_quest_class_backup | CREATE TABLE; INSERT IGNORE INTO |
| quest_template_addon | UPDATE |

### data/sql/db-world/cw_world_form_kits.sql

| Table | Operations |
| --- | --- |
| cw_form_kits | CREATE TABLE; DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_world_hero_races.sql

| Table | Operations |
| --- | --- |
| playercreateinfo | INSERT IGNORE INTO |
| playercreateinfo_action | INSERT IGNORE INTO |

### data/sql/db-world/cw_world_item_classes.sql

| Table | Operations |
| --- | --- |
| cw_item_class_backup | CREATE TABLE; INSERT IGNORE INTO |
| item_template | UPDATE |

### data/sql/db-world/cw_world_skillraceclass.sql

| Table | Operations |
| --- | --- |
| skillraceclassinfo_dbc | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_world_spell_scripts.sql

| Table | Operations |
| --- | --- |
| spell_script_names | DELETE FROM; INSERT INTO |

### data/sql/db-world/cw_world_vendor_lists.sql

| Table | Operations |
| --- | --- |
| conditions | DELETE FROM |
| creature_template | DELETE FROM; INSERT INTO |
| creature_template_model | DELETE FROM; INSERT INTO |
| cw_vlist | CREATE TEMPORARY TABLE; UPDATE |
| npc_vendor | DELETE FROM; INSERT INTO |

### data/sql/diagnostics/cw_check_summons.sql

Read-only diagnostics; no DDL/DML target.

### data/sql/manual/cw_class_loot_revert.sql

| Table | Operations |
| --- | --- |
| conditions | DELETE FROM; INSERT INTO |
| item_loot_template | UPDATE |

### data/sql/manual/cw_class_quests_revert.sql

| Table | Operations |
| --- | --- |
| cw_quest_class_backup | DROP TABLE |
| quest_template_addon | UPDATE |

### data/sql/manual/cw_item_classes_revert.sql

| Table | Operations |
| --- | --- |
| cw_item_class_backup | DROP TABLE |
| item_template | UPDATE |

### data/sql/uninstall/cw_uninstall_characters.sql

| Table | Operations |
| --- | --- |
| character_spell | DELETE FROM |
| cw_char_abilities | DROP TABLE |
| cw_char_bans | DROP TABLE |
| cw_char_cards | DROP TABLE |
| cw_char_state | DROP TABLE |
| cw_char_talents | DROP TABLE |
| updates | DELETE FROM |

### data/sql/uninstall/cw_uninstall_world.sql

| Table | Operations |
| --- | --- |
| charstartoutfit_dbc | DELETE FROM |
| conditions | DELETE FROM |
| creature | DELETE FROM |
| creature_template | DELETE FROM |
| creature_template_model | DELETE FROM |
| cw_ability_override | DROP TABLE |
| cw_archetypes | DROP TABLE |
| cw_form_kits | DROP TABLE |
| cw_item_class_backup | DROP TABLE |
| cw_quest_class_backup | DROP TABLE |
| cw_talent_override | DROP TABLE |
| item_template | DELETE FROM; UPDATE |
| npc_vendor | DELETE FROM |
| quest_template_addon | UPDATE |
| skillraceclassinfo_dbc | DELETE FROM |
| spell_script_names | DELETE FROM; INSERT IGNORE INTO |
| updates | DELETE FROM |
