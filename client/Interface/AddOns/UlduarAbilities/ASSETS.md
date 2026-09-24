# Blizzard resources and local inspection

Addon 1.5 uses `Interface\Tooltips\UI-Tooltip-Background` with an opaque tint for the
Confirm/Discard modal, plus the existing `UI-DialogBox-Border` and `UIPanelButtonTemplate`.
No external texture is added. Modifier icons resolve native spell IDs through GetSpellInfo.

No Blizzard art or FrameXML source is redistributed inside this addon. It references client resources
and virtual templates. Prior asset inspection used the local `Data/enUS/locale-enUS.MPQ`.
This revision reuses those references and the requested Pearl icon; no MPQ extraction was run again.

The actual client FrameXML.toc says Interface 30300. Read-only extraction inspected:

* patch-enUS-3.MPQ: MainMenuBarMicroButtons.xml, UIPanelTemplates.lua/xml, OptionsFrameTemplates.xml,
  InterfaceOptionsFrame.lua, QuestLogFrame.lua, UIParent.lua/xml, FrameXML.toc.
* patch-enUS-2.MPQ: MainMenuBarMicroButtons.lua, CharacterFrame.xml, SpellBookFrame.lua/xml,
  QuestLogFrame.xml, TalentFrameTemplates.xml, Blizzard_TalentUI.lua.
* patch-enUS.MPQ: CharacterFrame.lua, CharacterFrameTemplates.xml, InterfaceOptionsFrame.xml,
  MainMenuBar.xml, TalentFrameBase.lua, Blizzard_TalentUI.xml.

There is no loose TalentFrame.lua/xml here: the actual talent window is Blizzard_TalentUI with
TalentFrameBase/TalentFrameTemplates. These local files, not a Retail API reference, informed this UI.
Extraction used the read-only [mpyq library](https://github.com/eagleflo/mpyq) by Aku Kotkavuo from a
temporary tools directory; it is neither shipped nor a runtime dependency. MPQs were never modified.

## Explicit textures

All paths below start with `Interface\`. The client resolves the `.blp` extension.

| Path | Use |
| --- | --- |
| `DialogFrame\UI-DialogBox-Background` | Window and inset panel background |
| `DialogFrame\UI-DialogBox-Border` | Original dialog surround |
| `DialogFrame\UI-DialogBox-Header` | Title ornament |
| `Tooltips\UI-Tooltip-Border` | Inset borders |
| `Tooltips\UI-Tooltip-Background` | Thin, subdued gold connectors |
| `Buttons\UI-Quickslot2` | Spell-node border |
| `Buttons\UI-Quickslot-Depress` | Pressed node |
| `Buttons\ButtonHilight-Square` | Node hover |
| `Buttons\CheckButtonHilight` | Selected element/mode |
| `TalentFrame\TalentFrame-RankBorder` | Coverage/Potency rank ornament |
| `QuestFrame\UI-QuestTitleHighlight` | List selection/hover and point pulse |
| `Buttons\UI-MicroButton-Spellbook-Up` | Ulduar microbutton normal state |
| `Buttons\UI-MicroButton-Spellbook-Down` | Ulduar microbutton pushed state |
| `Buttons\UI-MicroButton-Spellbook-Disabled` | Ulduar microbutton disabled texture |
| `Buttons\UI-MicroButton-Hilight` | Ulduar microbutton highlight |
| `Icons\INV_Misc_QuestionMark` | Fallback while spell presentation is unavailable |
| `Icons\INV_Misc_Gem_Pearl_06` | Microbutton identity and 16px Spellbook configuration marker |

## Templates and inherited textures

`MainMenuBarMicroButton`: original 28x58 size, top hit inset 18, enable/disable alpha behavior.
`LoadMicroButtonTextures` supplies the four explicit microbutton textures listed above.

`UIPanelButtonTemplate`: `Buttons\UI-Panel-Button-Up`, `-Down`, `-Disabled`, `-Highlight`.
`UIPanelCloseButton`: `Buttons\UI-Panel-MinimizeButton-Up`, `-Down`, `-Highlight`.
`CharacterFrameTabButtonTemplate`: `PaperDollInfoFrame\UI-Character-ActiveTab`,
`PaperDollInfoFrame\UI-Character-InActiveTab`, `PaperDollInfoFrame\UI-Character-Tab-Highlight`.
`FauxScrollFrameTemplate` -> `UIPanelScrollFrameTemplate` / scrollbar template:
`Buttons\UI-ScrollBar-Knob`; `Buttons\UI-ScrollBar-ScrollUpButton-Up`, `-Down`, `-Disabled`,
`-Highlight`; `Buttons\UI-ScrollBar-ScrollDownButton-Up`, `-Down`, `-Disabled`, `-Highlight`.
The existing manual Confirm/Discard modal remains in use; StaticPopup migration is a future architecture phase.
Tooltips use the existing GameTooltip and its original configured backdrop.

Fonts: GameFontNormal, GameFontNormalSmall, GameFontNormalLarge, GameFontHighlight,
GameFontHighlightSmall and template-provided GameFontDisable. No bundled font.
PanelTemplates drives tab selection/resizing; SetButtonPulse uses Blizzard's bounded highlight pulse.

## Spell icons

The ability list, selected ability and Spellbook tooltip use GetSpellInfo(baseSpellId), not server icon
paths. Decorative nodes also resolve their icons using GetSpellInfo:

* Base: definition's native element (physical falls back to its spell icon); no Original purchase node.
* Conversions: Frost 116; Fire 133; Nature 403; Arcane 30451; Shadow 686; Holy 2061, excluding Base.
* Impact 30451; Split 2643; Shatter 30455; Nova 1449; Chain 421.
* Coverage 1449; Potency 12042. Spellbook uses the Pearl path above.

These are existing client spell illustrations, not new spells or new assets. Their textures follow
the client's DBC. Presentation/placement and complete widget rendering remain RUNTIME TEST REQUIRED.

## September 2026 design recreation

The reference source was read-only: `C:/WoWProjecto/Work/ascension/Interface`.
No Ascension code, textures or atlases are distributed. See DESIGN.md for specific reference files.

Additional stock client references:

| Path under Interface | Use |
| --- | --- |
| `AchievementFrame\\UI-Achievement-WoodBorder` | Outer window ornament, through our virtual XML template |
| `AchievementFrame\\UI-Achievement-AchievementBackground` | Tinted editor and placeholder background |

These resources are referenced in the inspected Blizzard_AchievementUI sources; texture rendering
in the target Ulduar client remains RUNTIME TEST REQUIRED. The addon does not load AchievementUI
or inherit its frames: it only names textures, with an opaque backing color underneath.

`InputBoxTemplate` supplies the search field's Blizzard input art. `UIPanelScrollFrameTemplate`
supplies the editor/details scrollbars. No Retail mixins, native SetAtlas, custom metatables,
external fonts or new binary assets are required. Section rules/shading use simple texture colors.

`Views/UlduarTemplates.xml` owns the two feature-specific virtual frame templates.
`Widgets/Theme.lua` owns presentation dimensions, art references and layout helpers. It is a
small skin for this addon, not an additional implementation of the future Ulduar_UI framework.
