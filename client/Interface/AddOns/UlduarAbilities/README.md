# Ulduar Abilities - official 3.3.5a addon

IMPLEMENTED, STATIC REVIEW ONLY. RUNTIME TEST REQUIRED for every visual and gameplay integration.
Addon 1.5 recreates the window using the local Ascension interface as a design reference.
See [DESIGN.md](DESIGN.md) for the visual changes, source references and manual acceptance checklist.
Draft Build and one APPLY_BUILD confirmation remain unchanged; see the module\'s DRAFT_BUILD.md.
Interface 30300. No addon libraries, saved gameplay state, external textures, modified FrameXML,
MPQ patches, native client changes or Retail APIs are required.

## Locations and installation

Source: `ulduar-wow/client/Interface/AddOns/UlduarAbilities/`.
Installed copy for this workspace: `C:/WoWProjecto/Client/Interface/AddOns/UlduarAbilities/`.
Edit the source copy and copy the entire directory into your client's `Interface/AddOns` after changes.
Restart the client if the addon was installed while it was running; otherwise use `/reload`.

This UI-only revision requires no server rebuild or CMake regeneration. It uses the existing
`AbilityAddonProtocol.cpp` contract; deploy it against the already working Ulduar Abilities server.
No SQL change is needed; the existing module tables/bindings must already be installed and the module
enabled. The server must permit its normal addon channel (`AddonChannel` configuration).
The addon requires no GM privileges. It never sends `.ua` chat commands or offers a custom-rank grant.

## Window

`/ua` and `UlduarMicroButton` toggle `UlduarFrame`. This standalone window uses Blizzard dialog art,
close button, ESC support and CharacterFrame tabs managed by PanelTemplates. Only the header drags.
It scales its 1100x752 layout to the available UIParent width/height, including room for tabs and bars.
SetClampedToScreen keeps it accessible. UlduarAbilitiesDB.framePosition saves point/relativePoint/x/y;
invalid values reset to CENTER. `/ua resetposition` resets the saved position manually.
It is deliberately not registered as a center UIPanel, whose layout would overwrite user positioning.
Test 1024x768, 1280x1024 and widescreen with UI Scale enabled; no rendered screenshot has been verified.

The microbutton inherits the exact 28x58 MainMenuBarMicroButton dimensions/hit rectangle and loads
Blizzard Spellbook up/down/disabled/highlight textures with the Pearl icon inset like the character
portrait. Its order is Talent -> Ulduar -> Achievement, using the native -3px anchor overlap.
Only Achievement is reanchored; following buttons retain their native predecessor chain.
Layout is centralized and reversible. Custom non-native layouts are left to their owner, and the
Ulduar button hides there; `/ua` remains the fallback. The tooltip says `Ulduar Abilities`.
Opening is deferred by the user until out of combat; no protected actions or secure button rewrites occur.

Abilities has a searchable, scrollable server-provided list, Element and Delivery nodes,
capability-driven Damage/Cooldown/CastTime/Coverage/Potency/Rebound rank
nodes, a scrollable current-build summary, expandable Details, points indicator and reset preview.
Six-second point pulses use Blizzard SetButtonPulse and are stopped on hide, without duplicate entries.
Gameplay state updates only when an entire server snapshot ends. Node clicks edit a separate draft:
left +1, right -1, element/delivery selection and Reset all remain local. Confirm submits one complete
APPLY_BUILD with the opening revision. Discard Changes restores committed state without a request.
Closing/switching abilities offers Confirm/Discard (ESC returns to editing).
Pending requests disable editing and leaving.
Coverage and Potency display draft rank, with no invented max 5. RULES supplies preview costs/formulas;
STATE remains authoritative. Invalid budget/safety previews disable Confirm. Timeouts never retry.
Safety-clamped values are indicated. The centered Base Element is informational, never a reset button.
Conversions exclude the base school. Original remains a backend value only, displayed as Base.
Elements can be redistributed freely in the draft. Details omit Base Element when it equals Current.
Delivery is free and limited by server capabilities. Reset stages Original/None/0/0; Confirm applies it.

Builds, Codex and Progression contain only `Coming later`. No save/import/search/progression backend
or fake unlock data is implemented.

## Spellbook integration

IMPLEMENTED; RUNTIME TEST REQUIRED, especially taint/combat/page behavior.
16x16 Pearl buttons are siblings of SpellButton1..12, inside each entry's text column beside its rank,
at TOPLEFT relative to the spell icon TOPRIGHT (+88, -22). The original spell click area is untouched.
A secure post-hook observes SpellButton_UpdateButton and maps XML names separately from their
interleaved page IDs. The actual Blizzard
rank ID is extracted from GetSpellLink(bookSlot, BOOKTYPE_SPELL); SpellBook_GetSpellID returns a SLOT
in this client, not the spell ID. RANKS messages map the server's SpellMgr chain to the ability.
Clicking a marker opens Abilities and selects that AbilityId. Pet spells and unsupported spells
receive no marker. Updates are deferred during combat; normal cast/drag/modified-click scripts are
never replaced. All-ranks display, changed pages, newly learned ranks and combat need ingame testing.

## Server authority and scope

See [PROTOCOL.md](PROTOCOL.md). Requests are self-whisper addon packets processed through the existing
PlayerScript private-chat hook. Only the authenticated sender's state can change. Rank grants remain
GM/debug functionality. Module-disabled/schema-unavailable sessions reject requests. Metadata-only
definitions are never sent. New roots use the manager's existing runtime snapshots and persistence.
Out-of-band GM mutations are shown after Refresh/reopening; unsolicited state push is not implemented.
Healing runtime, new abilities, builds, account progression and client patches are outside this UI phase.

## Manual validation (not performed)

1. Enable the addon on pure Blizzard UI. Check `/ua`, microbutton states/tooltip, close/ESC, four tabs,
   readability, list scroll and clipping at 4:3/widescreen resolutions and different UI scales.
2. Give Frostbolt custom ranks with the existing GM command, then Refresh. Spend on Element, Delivery,
   Coverage and Potency; verify points and values change only following STATE/END.
3. Check insufficient points, locked element conversion, reset confirmation/cancel, logout/login,
   reconnect, disabled module, missing addon channel, delayed responses and rapid clicks.
4. Verify a non-GM can configure only their own character. Duplicate sequence packets must not spend
   twice. Unknown abilities, metadata IDs, invalid enum values and another whisper recipient must fail.
5. Check the Spellbook marker on each Frostbolt rank, all-ranks toggle and page change; normal clicks,
   casts, dragging and modifier clicks must remain vanilla. Check Lua/taint errors through combat.
6. Cast the configured Frostbolt and compare another player's ordinary Frostbolt. Gameplay and visuals
   inherited from earlier module work still require their own regression tests.

Checks in this revision: read-only local FrameXML and Ascension Lua/XML inspection, source review,
protocol-field/TOC review and git whitespace checks. No parser, linter, build or runtime test was run.

BUILD: NOT RUN. CMAKE: NOT RUN. RUNTIME: NOT TESTED. SQL: NOT APPLIED.

## Initial catalog update

The registry retains the requested starter abilities, but each snapshot now contains only abilities
matching the character's class AND an active known Blizzard rank. Metadata-only entries remain hidden.
Availability is rechecked server-side before every addon mutation. GM commands retain their debug role.
The list hides +0 EP. CAPS hides unavailable purchases without changing costs.
See the module's STARTER_ABILITIES.md for partial adapters (Eviscerate, Death Coil, Judgement of Light)
and the pending world SQL migration. Direct healing and periodic scaling retain native schools where
conversion is unavailable. This catalog update remains NOT COMPILED / NOT RUNTIME TESTED.

## Dynamic tooltips

AbilityTooltipDescriptor combines DEF/BASE/STATE data with local RULES-based previews inside UlduarFrame.
List, base icon, nodes and summary expose the build. Secure tooltip hooks append a separate Ulduar
section to native Spellbook/ActionBar tooltips (OnTooltipSetSpell plus SetSpell/SetAction fallbacks).
They preserve native text, distinguish Base/Current and describe each propagation mode with effective
counts/ranges. Potency uses Secondary Damage, Secondary Healing or Secondary Effect by effect flags.
External Spellbook/ActionBar tooltips keep committed state. Draft tooltips are explicitly labelled.
A cleared-tooltip guard prevents duplicate sections. Macro/third-party custom tooltip coverage is
PARTIAL and needs client testing. Already visible tooltips refresh on the next native tooltip refresh.

See the module's UI_CONSOLIDATION.md for the read-only Ascension references, visual packet limits,
Split scheduling, files changed and manual test checklist. Existing healing/channel adapters were
not extended in this UI revision. No new abilities or SQL files were created.

Addon 1.4 requires protocol 2, BALANCE/MODIFIERS metadata and the character modifier migration.
See modules/mod-ulduar-abilities/MODIFIERS_BALANCE.md in the core repository for balance and runtime limitations.
