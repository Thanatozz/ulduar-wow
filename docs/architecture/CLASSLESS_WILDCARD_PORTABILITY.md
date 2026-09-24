# Classless Wildcard portability

Date: 2026-09-15. Source: `5ffe6957cad94492480a8e3b6b351021318af83e`.
Decision: **REFERENCE_ONLY**. Nothing has been ported.
The narrow PORT entry below identifies a possible later extraction; it does not change today's decision.

Read the [source audit](CLASSLESS_WILDCARD_EXPERIMENT_AUDIT.md) for exact behavior and risks.
Paths below are relative to the pinned external repository.
The two tables join by ID and together provide all portability/dependency fields.

## Classification vocabulary

| Audit classification | Matrix recommendation | Meaning |
| --- | --- | --- |
| KEEP_CONCEPT | REFERENCE | Preserve lesson, not external authority |
| PORT_SMALL_COMPONENT | PORT | Named narrow helper only, after adapter proof |
| REIMPLEMENT_FROM_REFERENCE | REIMPLEMENT | Useful pattern with unsuitable ownership/dependencies |
| EXPERIMENT_FIRST | EXPERIMENT | No portability promise before isolation |
| NOT_NEEDED | IGNORE | Outside current Forge needs |
| CONFLICTS_WITH_ULDuar | IGNORE | Would replace or undermine protected authority |

## Source and dependency matrix

Abbreviations: M = src/ClasslessMgr.cpp; P = src/ClasslessPlayerScript.cpp;
A = src/ClasslessAddon.cpp; L = client-addon/ClasslessWildcard/ClasslessWildcard.lua;
F = src/ClasslessForgedScripts.cpp; CP = client-patch.
"No other module" means no mandatory dependency found, not independence from AzerothCore.

| ID / feature | Source files | SQL | Client files |
| --- | --- | --- | --- |
| P01 Hero identity | M, P, ClasslessWildcard.h | hero races, items, quests | CP glue/DBC |
| P02 Resource pools | P, M display choice | cw_char_state display | L resource UI |
| P03 Rune lifecycle | P, M LoadCharacter | State/config, no rune ledger | L RU row |
| P04 Combo/reactives | P | None direct | L CP |
| P05 Prerequisite kits | M GrantRequiredForm/GrantFormKit | cw_form_kits, cw abilities | L/native bars |
| P06 Pet compatibility | P, M DismissOrphanedPet | Native pet state | Native pet bar |
| P07 Proficiencies | M, P | Broad item/skill overrides | CP skill/class DBC |
| P08 Root/rank projection | M GrantAbility/UpdateAbilityRanks | cw abilities + spell_ranks | L/native book |
| P09 Missing button repair | M RestoreDroppedActionButtons | character_action read | Native packets |
| P10 Native catalog | M BuildLibrary | Trainer/override/DBC data | L browser |
| P11 Acquisition state | M, ClasslessWildcard.h | Four cw character tables | A, L |
| P12 Free Pick | M Buy*/Unlearn*/Respec | State + native grants | A, L, NPC |
| P13 Wildcard engine | M Roll*/Reroll*/SetLock | State/bans/items | A, L reveal |
| P14 Native talents | M GrantTalent*, P | talent_dbc, native talents | L trees |
| P15 Native aura fixes | P | spell_script_names | Native effects |
| P16 Tooltip correction | A SendSpellCorrections | Native spell data | L correction hooks |
| P17 Addon request transport | A | Through Mgr | L |
| P18 Command/NPC shell | Commands.cpp, Npc.cpp under src | NPC/vendor rows | Gossip/chat/L |
| P19 Hero spells/variants | F, generators, M | Generated spells/talents | CP forged/elemental |
| P20 Hero archetype builds | M, gen_archetypes.py | cw_archetypes | L |
| P21 Gear/loot/vendors | Loot.cpp, VendorLists.h under src | items*, vendors, loot | CP Item.dbc |
| P22 Global tool removal | M StripSpellTools | None direct | CP dbc.py |
| P23 MPQ/DBC primitives | CP/lib mpq.py, pkware.py, dbc.py | None | Archive/DBC format |
| P24 Full installer/EXE | CP install.py, lib/exepatch.py | None | Wow.exe, MPQ, addon |
| P25 Version stamps | Generators, M, CP | *_meta generation tables | JSON/install manifest |
| P26 Delete lifecycle | P OnPlayerDeleteFromDB | Four cw deletes | None |

Additional fields for the same entries:

| ID / feature | Core / other module dependency |
| --- | --- |
| P01 Hero identity | Player stats/class; no other |
| P02 Resource pools | Player power/hooks; no other |
| P03 Rune lifecycle | InitRunes/Spell/regen; no other |
| P04 Combo/reactives | Player combo/Unit events; no other |
| P05 Prerequisite kits | SpellInfo/Player; no other |
| P06 Pet compatibility | Pet/Guardian/classes; no other |
| P07 Proficiencies | Equip/skills; no other |
| P08 Root/rank projection | SpellMgr/Player; no other |
| P09 Missing button repair | Player/CharacterDB; no other |
| P10 Native catalog | DBC stores/SpellMgr; no other |
| P11 Acquisition state | Player/DB/cache; no other |
| P12 Free Pick | Full Mgr; no other |
| P13 Wildcard engine | Full Mgr/RNG; no other |
| P14 Native talents | Talent store/auras; no other |
| P15 Native aura fixes | Effect layouts/families; no other |
| P16 Tooltip correction | ApplySpellMod; no other |
| P17 Addon request transport | Chat/session hooks; no other |
| P18 Command/NPC shell | Command/CreatureScript; no other |
| P19 Hero spells/variants | Fixed spell effects; no other |
| P20 Hero archetype builds | Native buying/leveling; no other |
| P21 Gear/loot/vendors | Item/loot engine; no other |
| P22 Global tool removal | Shared SpellInfo mutation; no other |
| P23 MPQ/DBC primitives | Python; Pillow for some tooling |
| P24 Full installer/EXE | Client signatures/Python/Pillow |
| P25 Version stamps | Build/content convention |
| P26 Delete lifecycle | Core character delete transaction |

For P18/P21 full filenames are ClasslessCommands.cpp, ClasslessNpc.cpp, ClasslessLoot.cpp
and ClasslessVendorLists.h. All eleven server source/header files are mapped in the audit.

| ID | Can isolate? / useful to Ulduar? | Forge conflict |
| --- | --- | --- |
| P01 | No useful identity conversion | Rewrites existing class/stats |
| P02 | Hooks concept; rewrite service | Class policy and free all-pool grants |
| P03 | Test lifecycle first | Config flag is not earned entitlement |
| P04 | Event lesson only | Shared reactive/combo target state |
| P05 | Useful parent-child lifecycle | One source enum and native-ID dependency |
| P06 | Useful edge cases | Native pet type/load policy |
| P07 | Narrow APIs useful, broad policy no | Free proficiencies/world mask rewrite |
| P08 | Rank traversal concept | Native known-spell authority |
| P09 | Yes, one isolated function | Needs instance projection guard |
| P10 | Offline reference discovery | Class catalog cannot own creation |
| P11 | No complete transaction service | No source ledger/revisions/receipts |
| P12 | Browser/price ideas only | Optional mode, native purchase economy |
| P13 | No decoupled component engine | SpellID pools and immediate grants |
| P14 | Native effect lifecycle lessons | Family masks and native passives |
| P15 | Named fixes only after proof | Binding/effect ownership collisions |
| P16 | Server snapshot principle useful | Native family math/string patching |
| P17 | Authenticated self-whisper idea | Missing durable idempotency/version |
| P18 | Presentation only | Hardcoded native acquisition routes |
| P19 | Examples of engine limitations | Replaces semantic conversion/graph |
| P20 | Level policy concept only | Native build template != discovery |
| P21 | No launch value | World economy/stat changes |
| P22 | Do not isolate as policy | Global mutation breaks scoped safety |
| P23 | Possible packaging utility | Input validation and provenance unresolved |
| P24 | No wholesale extraction | Side effects and binary client coupling |
| P25 | Shared generation concept | Logs are not enforced compatibility |
| P26 | Transaction participation pattern | Custom tables differ |

Additional fields for the same entries:

| ID | Classification / recommendation |
| --- | --- |
| P01 | CONFLICTS_WITH_ULDuar / IGNORE |
| P02 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P03 | EXPERIMENT_FIRST / EXPERIMENT |
| P04 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P05 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P06 | EXPERIMENT_FIRST / EXPERIMENT |
| P07 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P08 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P09 | PORT_SMALL_COMPONENT / PORT |
| P10 | KEEP_CONCEPT / REFERENCE |
| P11 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P12 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P13 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P14 | KEEP_CONCEPT / REFERENCE |
| P15 | EXPERIMENT_FIRST / EXPERIMENT |
| P16 | REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT |
| P17 | KEEP_CONCEPT / REFERENCE |
| P18 | NOT_NEEDED / IGNORE |
| P19 | CONFLICTS_WITH_ULDuar / IGNORE |
| P20 | NOT_NEEDED / IGNORE |
| P21 | NOT_NEEDED / IGNORE |
| P22 | CONFLICTS_WITH_ULDuar / IGNORE |
| P23 | EXPERIMENT_FIRST / EXPERIMENT |
| P24 | NOT_NEEDED / IGNORE |
| P25 | KEEP_CONCEPT / REFERENCE |
| P26 | KEEP_CONCEPT / REFERENCE |

## Narrow extraction evidence

Ancillary systems inherit the same dependency analysis:
Rebirth/mode switching (Mgr, cw state, native money/grants, addon/NPC) is
REIMPLEMENT_FROM_REFERENCE / REIMPLEMENT only if an optional Ulduar mode-switch policy is later wanted.
Hero stat allocation (Mgr, cw state, native stat modifiers and addon paper doll) is
CONFLICTS_WITH_ULDuar / IGNORE. Automatic riding/runeforging (Mgr, native skills/spells and skill DBC overrides)
is KEEP_CONCEPT / REFERENCE for explicit convenience grants, not a required Forge subsystem.
All lack mandatory other-module dependencies; none is a narrow ready-to-port service.

P09 is specifically ClasslessMgr.cpp:3040, RestoreDroppedActionButtons, about forty lines.
It reads active-spec saved actions, selects spell buttons, skips occupied buttons, requires HasSpell,
uses addActionButton and sends SendInitialActionButtons after changes.
There is no use of Mgr's catalog, cfg, CharState, grants, currencies or Hero conversion inside the helper.
Dependencies are Player, CharacterDatabase, action constants and logging.
This is evidence for a small component, not for porting Mgr or its whole rank/spellbook subsystem.

Before any later extraction: scope restored actions to legitimate native grants/instance projections,
respect player edits, check rank/carrier generation and native slot bounds, handle DB failure distinctly,
and exercise reconnect/spec change. Preserve source attribution and review file licensing.
Ulduar's durable slot projection remains its own implementation.

P23 is not PORT_SMALL_COMPONENT: parser/writer validation, compression/asset handling and installer
dependencies need experiments. A narrow-looking Python file is not sufficient evidence of safe portability.

## Reassessment of the eight classless work packages

"Reuse" is qualitative coverage, not a fabricated percentage or estimate of engineering hours.
It measures usable implementation after Ulduar constraints, separately from conceptual value.

### 1. Entitlement catalog and source-counted grants

Current requirement: seven ownership types, stable instances and independently removable sources.
External: native root -> one GrantSource plus native talents and companion pairs.
Reuse: **low code coverage; useful lifecycle examples**. Portability: reimplement.
Dependencies: Mgr, cw state, native Player grants, form kits.
Copy concept: source provenance and post-removal reconciliation.
Implement: durable multi-source ledger, instance identity, reverse dependencies and projection ownership.
No longer required: treating every native spell as the primary purchasable ability.

### 2. Budgets, prerequisites and server build validation

Current requirement: validate Core/gem/slot/talent/mechanic rules before commit.
External: server AE/TE cost, level, native talent dependency and catalog filters.
Reuse: **low; partial validation patterns**. Portability: reimplement.
Dependencies: native catalog, prices, Mgr state; no complete carrier feasibility.
Copy concept: server computes cost and rejects unavailable entries.
Implement: whole semantic graph/capability validation, exact refund policy and mutation gates.
No longer required: native rarity economy or class-tree acquisition constraints for launch.

### 3. Durable transactions, revisions, receipts and reconciliation

Current requirement: all ownership/ledger/receipt/outbox mutations atomic and replay-safe.
External: independent SQL writes and native learning; deletion joins native transaction.
Reuse: **negligible direct transaction coverage**. Portability: reimplement.
Dependencies: CharacterDB, native saves, in-memory global guards.
Copy concept: login reconciliation and deletion-transaction participation.
Implement: idempotency, actor serialization, DB error semantics, receipts and outbox.
No longer required: nothing; Forge makes this more central.

### 4. Native grant/rank/spellbook adapter

Current requirement: execution projection for instances and preservation of legacy grants.
External: native chains, level upgrades, book repair, action recovery.
Reuse: **moderate conceptual coverage; one narrow helper candidate**. Portability: mixed P08/P09.
Dependencies: Player/SpellMgr, character_action, client book behavior.
Copy concept: safe rank handling and restoration after learning.
Implement: carrier uniqueness, slot-to-instance mapping, source retention and generation checks.
No longer required: native known spell as primary ownership key.

### 5. Free Pick/respec

Current requirement: optional component shop and validated loadout changes.
External: complete native purchase UI/economy but non-atomic ownership persistence.
Reuse: **low after Forge redesign**. Portability: reimplement optional provider.
Dependencies: Mgr/catalog/native spells and addon.
Copy concept: search/preview/server price/refund UX.
Implement: common progression transactions and component policy.
No longer required: full native Free Pick at launch; resocketing is not native unlearn/refund.

### 6. Wildcard/Wild Draft

Current requirement: optional component offers with durable acceptance.
External: immediate native grants, pity, weights, bans, locks and rerolls.
Reuse: **low code coverage; useful failure cases**. Portability: reimplement.
Dependencies: native pools/ownership, items/currencies, Mgr, reveal addon.
Copy concept: semantic affinity adaptation, desired-state locks, duplicate protection.
Implement: persisted offers, legal replacement reservation, acceptance receipts and reconnect.
No longer required: native-spell rolls or origin-class synergy as the main game.

### 7. Mechanics/resources/forms/pets

Current requirement: capability-driven native compatibility, introduced as needed.
External: contextual power/class hooks, rune snapshot, kits, pet repair, broad proficiencies.
Reuse: **moderate reference coverage, low drop-in code**. Portability: reimplement/experiment.
Dependencies: core hooks, native fields/scripts, client resource and pet UI.
Copy concept: initialization order, single native pools and lifecycle edge cases.
Implement: ResourceService, MechanicEntitlementService and scoped native adapters.
No longer required: enabling all advanced mechanics before the first Forge loop.

### 8. Universal acquisition/library UI

Current requirement: Forge creation, owned instance list, gem socketing and semantic preview.
External: native class browser, talent trees, rolls, resources and tooltip corrections.
Reuse: **low UI code coverage; useful interaction lessons**. Portability: reimplement.
Dependencies: CWCL grammar, native SpellID links, generated assets, frame hooks.
Copy concept: server-resolved display and discoverability.
Implement: versioned Forge UI on existing Ulduar transport and secure native action projection.
No longer required: native class tabs as the mandatory onboarding screen.

## Protected systems and practical next step

Keep existing Ulduar effect execution, native safety, custom school handling, EP, healing/weapon adapters,
cast timing, delivery and current addon contracts. Extend through explicit contracts rather than replacing files.
Start Phase A from [Roadmap V2](ULDuar_GAMEPLAY_ROADMAP_V2.md); no upstream merge, fork adoption,
server installation or client patch is justified by this audit.

[upstream]:
  https://github.com/DustinHendrickson/mod-classless-wildcard/tree/5ffe6957cad9
[helper]:
  https://github.com/DustinHendrickson/mod-classless-wildcard/blob/5ffe6957cad9/src/ClasslessMgr.cpp#L3040

Evidence: [pinned upstream][upstream], [narrow action recovery helper][helper].
