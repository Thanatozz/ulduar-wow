# Ulduar Abilities 1.5 - visual recreation

2026-09-14. IMPLEMENTED, STATICALLY REVIEWED. RUNTIME TEST REQUIRED.

## Reference and scope

Read-only reference: `C:/WoWProjecto/Work/ascension/Interface`.
This is an original composition using Blizzard client resources, not a port of Ascension.

Sources inspected:

- `AddOns/Ascension_CharacterAdvancement/CharacterAdvancement.xml`: navigation/content/sidebar
  separation, ornamental frame and scrollable editing surface.
- `AddOns/Ascension_CharacterAdvancement/Templates/CASpellButton.lua`: icon states, pending
  changes, hover and separation between entry data and presentation.
- `AddOns/Ascension_Collections/Collections.xml` and `CollectionsTabMixin.lua`: shared visual
  shell and connected navigation tabs.
- `SharedXML/Scroll/ScrollFrame.lua/.xml`: scroll range, offset and content/viewport separation.
- `AddOns/Blizzard_AchievementUI/Blizzard_AchievementUI.xml`: existing wood border and background
  texture references. This is evidence of source usage, not an ingame asset/rendering test.

Adopted: consistent panel framing, clear header, left navigation, central editing, right summary,
readable icon states and a fixed confirmation area. Not adopted: Ascension's C_* APIs, custom
atlases, TypeExtensions, global metatable changes, copied artwork or classless progression rules.

## Composition

The window is 1100 x 752 logical UI units, scaled to UIParent with space for bottom tabs.
It retains header dragging, clamping and the existing SavedVariables position format.

- Header: Pearl identity, title/subtitle, Evolution Point budget and Blizzard close button.
- Left: authorized ability catalog, local name search, nine recycled display rows and count.
  Search never sends messages or exposes abilities missing from the server catalog.
- Center: tinted parchment, centered informational Base Element, conversions, Delivery,
  Offense and Propagation. Nodes wrap by available width; section positions and scroll height
  follow the number of rows. Rebound still depends on capabilities and Chain selection.
- Right: Current Build / Draft Build label, scrollable summary and expandable classification.
  Evolution Point spending remains fixed beneath the scroll viewport.
- Footer: status, Refresh, Discard Changes, Confirm and Reset Ability. Reset remains a draft action.
- Bottom: native CharacterFrame tabs controlled by PanelTemplates. Only Abilities is functional.

The selected conversion/delivery has a gold highlight. Ranked modifiers show the draft number,
a highlight when invested, and a separate Pending label when different from committed state.
There are no invented talent dependencies or unlock lines. Disabled nodes keep explanatory hover.

## Source ownership

- `Views/UlduarTemplates.xml`: two original virtual backdrop templates, loaded before factories.
- `Widgets/Theme.lua`: dimensions, texture references, section decoration and centered row layout.
- `Widgets/Node.lua`: icon/rank/hover/selection/pending presentation, preserving existing callbacks.
- `AbilityList.lua`: local search and fixed visible rows over the server-authorized catalog.
- `AbilityTree.lua`: capability-based layout and editor scroll content.
- `AbilityDetails.lua`: measured text layout and independent summary scrollbar.
- `UlduarFrame.lua`, `Widgets/Tabs.lua`: shell, navigation and existing state-action wiring.

This is a bounded visual migration inside the existing addon. The future Ulduar_Shared/Ulduar_UI
provider architecture and UIEditor are not implemented by this skin. Do not duplicate these
helpers when that migration occurs: move them behind the shared facade.

Protocol.lua, DraftBuild.lua, AbilityTooltip.lua, SpellBookIntegration.lua and UlduarMicroButton.lua
are unchanged. Server/core/config/SQL are unchanged. No client patch or dependency installation
is required by the new addon source. Microbutton behavior is not fixed or revalidated by this task.

## Installation and verification

Deploy the entire `UlduarAbilities` source folder to the target client's `Interface/AddOns`.
Include the new `Views` folder and updated TOC; copying only the Lua files is insufficient.
Reload the UI after replacing an already-installed addon. Restart the client if it was newly installed.
The installed client copy was not modified during this task. `/ua resetposition` remains available.

Manual acceptance (all NOT RUN):

1. Enable Lua error reporting; login and open `/ua` with the working module/protocol.
2. Check frame borders/backgrounds, tabs and glyphs at 1024x768, 1280x1024 and widescreen/UI scales.
3. Drag the header, close/reopen, reload; confirm position and clickable regions remain correct.
4. Search with matching/no matching names, clear search, scroll a long eligible catalog and select entries.
5. Check empty/offline catalog; no old rows, selected icons or tooltips should remain exposed.
6. Check physical-base abilities with six conversion choices: row wrapping must not overlap Delivery.
7. Test all supported modifiers and Chain/Rebound; inspect the bottom of the editor using its scrollbar.
8. Inspect long spell names and multi-line summaries, Details expand/collapse and the fixed point budget.
9. Edit multiple ranks with left/right clicks and switch elements/delivery: only Draft changes.
10. Confirm once: one APPLY_BUILD; committed state changes only on the confirmed server snapshot.
11. Close/change ability while dirty: Confirm/Discard/ESC preserve existing behavior, including timeout/conflict.
12. Check external Spellbook/action tooltips remain committed, and normal spell drag/drop remains intact.

Static checks verify XML well-formedness, TOC file existence/order, layout bounds and changed-file scope.
They do not prove texture availability, native Lua execution, mouse clipping or visual fidelity.
No CMake, compiler, server, client, Lua execution, SQL or MPQ operation was run.
