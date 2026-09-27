# Retail-QoL ecosystem audit (source level)

Date: 2026-09-27. Environment: Linux cloud container. Every project below was **cloned and read at the exact
commit listed**, never installed, built into Ulduar or run against a client. Nothing here was executed on
Windows; statements about client behavior are read from source, not observed. GitHub web/API search was
blocked by the environment proxy, so discovery beyond the named projects was limited to AzerothCore
repositories probed by name (§9).

Decisions that follow from this audit: [CLIENT_EXTENSION_FRAMEWORK_DECISION.md](CLIENT_EXTENSION_FRAMEWORK_DECISION.md),
[ALE_INTEGRATION_STRATEGY.md](ALE_INTEGRATION_STRATEGY.md), [TSWOW_TOOLING_AUDIT.md](TSWOW_TOOLING_AUDIT.md),
[QOL_FEATURE_MATRIX.md](QOL_FEATURE_MATRIX.md),
[../architecture/RETAIL_QOL_TARGET_ARCHITECTURE.md](../architecture/RETAIL_QOL_TARGET_ARCHITECTURE.md),
[../roadmap/RETAIL_QOL_IMPLEMENTATION_ROADMAP.md](../roadmap/RETAIL_QOL_IMPLEMENTATION_ROADMAP.md).

## 1. Provenance and license register

| Project | Commit reviewed (date) | License | Code reuse | Assets |
| --- | --- | --- | --- | --- |
| WarcraftXL/wxl-core | `60033ab125e3` (2026-09-14) | GPL-3.0-or-later | only as GPL-3 (a DLL linking it is GPL-3) | none shipped; reads the user's client |
| WarcraftXL/wxl-unit-outline | `29e5e29fa97e` (2026-07-16) | GPL-3.0 | as GPL-3 | none |
| WarcraftXL/wxl-modern-assets | `eb7c7c66461b` (2026-07-17) | GPL-3.0 | as GPL-3 | none; converts assets the user supplies |
| WarcraftXL/wxl-modern-m2 / -wmo / -adt | `7845be16924a` / `e56fa7c93adb` / `5f2726cc9e7f` | GPL-3.0-or-later | as GPL-3 | none |
| WarcraftXL/wxl-db2 | `30e4f2c8ed88` (2026-08-13) | GPL-3.0-or-later | as GPL-3 | none |
| WarcraftXL/wxl-hub | `884a0da7c797` (2026-08-09) | GPL-3.0-or-later | launcher/store, not a library | logo only |
| FrostAtom/awesome_wotlk | `3cbae1e3f7dc` (2026-06-03) | GPL-3.0 (Microsoft Detours: MIT) | as GPL-3 | none |
| azerothcore/mod-ale | `bd74eae623ca` (2026-09-09) | GPL-3.0 | as GPL-3 (server module) | none |
| azerothcore/mod-eluna | same repository as mod-ale (the name resolves to commit `bd74eae623ca`) | - | - | - |
| ElunaLuaEngine/ElunaAzerothCore | `ca08cb85a10a` (2026-09-09) | GPL-2.0 (AzerothCore fork) + Eluna submodule | full core fork | - |
| ElunaLuaEngine/Eluna | `58d765213888` (2026-07-11) | GPL-3.0 | as GPL-3 | - |
| tswow/tswow | `00608832b426` (2026-08-02) | GPL-3.0; `misc/client-extensions` **MIT** | GPL-3 / MIT subtree | none |
| Grim-Batol/The-War-Within-Spellbook | `114f1966dda6` (2025-07-27) | **no license file** (all rights reserved by default) | ideas only | 12 BLP + 1 OGG that are Retail (The War Within) UI art: Blizzard assets, not redistributable by us |
| Grim-Batol/Paragon-Anniversary | `a3cb1bb5d9b3` (2026-06-06) | AGPL-3.0 | as AGPL-3 | Retail UI BLPs (CovenantRenown, 2x buttons): Blizzard assets |
| azerothcore/mod-transmog | `0d85cbc53d63` (2026-07-26) | AGPL-3.0 | as AGPL-3 (server module) | none |
| azerothcore/mod-aoe-loot | `57279b660a27` (2026-09-25) | AGPL-3.0 | as AGPL-3 | none |
| azerothcore/mod-account-mounts | `0a3b4c4cc084` (2026-09-21) | AGPL-3.0 | as AGPL-3 | none |
| azerothcore/mod-account-achievements | `bfbe3677635f` (2025-02-18) | AGPL-3.0 | as AGPL-3 | none |

Ulduar's own licenses for comparison: `ulduar-wow` GPL-2.0 (AzerothCore; source headers "version 2 or any
later"), `mod-ulduar-abilities` MIT, `ulduar-client-patch` **no license file yet** (decision needed before
any GPL code enters it, §8).

## 2. WarcraftXL (read: core, outline, modern-*, db2, hub)

| Question | Finding (source) |
| --- | --- |
| Client build | 3.3.5a 12340 by design; addresses are absolute constants in `src/offsets/**` |
| Loading | two paths: (a) `wxl-patcher.exe` **rewrites the target PE**: sets large-address-aware, applies byte-patch scripts (e.g. `GlueUnlock.cpp`: bypasses the client's Lua/XML interface signature check, bytes ported from a third-party MIT pack) and adds an import of `WarcraftXL.dll` in a new `.wxl` section, keeping `Wow.exe.orig`; (b) a `d3d9.dll` proxy in the client folder that forwards `Direct3DCreate9(Ex)` and loads the framework |
| Version gating | **none at runtime for the executable**: the patcher accepts any 32-bit PE; extensions are refused only when their compile-time `clientBuild` constant differs from the core's (`Extensions.cpp`), not after hashing the running image |
| Hook library | vendored MinHook; a named hook-point registry (`runtime/HookPoints.cpp`, 708 named addresses: render, M2/WMO/ADT, storage, UI, Lua, addon signature, camera, ...) |
| Event bus | `wxl::events::EventScript`, POD events: model loads, per-frame render, device lost/reset, input, world click, ADT/WMO loads, texture/BLP loads, object update/destroy, target changed, world enter/leave, sound |
| Typed bindings | `wxl::game` (`Native<Fn>(addr)`) over `offsets`; client object/unit/model accessors |
| Lua | can register C functions (`FrameScript_RegisterFunction` 0x00817F90); hooks on addon manifests and the interface signature |
| Network | **no packet/opcode layer**: no hook on NetClient message handlers, no custom packet channel |
| Data/files | `StorageHook`: providers, redirects and transforms over the client's archive reads; M2 arena allocator |
| Extensions | separate DLLs with `wxl.json` manifests, ABI `1.1`, declared hook targets; `wxl-hub` installs them from GitHub releases |
| Unit outline | `wxl-unit-outline`: re-draws the **target and mouseover only** (`kMaxTargets = 2`) M2 batches into a mask render target, then a full-screen edge pass; reaction colors red/yellow/green; players depth-tested, NPCs see-through. Cost grows with every outlined model (a second draw of its batches) |
| Modern assets | in-memory downport of newer M2 (272-274 → 264), WMO (tag-driven walker, background loading, 4-layer materials), split ADT (root/tex/obj), BLP/DDS, M3 bake, WDC1-5 DB2 reader with FileDataID resolver |

Conflict with `UlduarClientPatch.dll`: the Ulduar DLL has **zero** installed hooks today, so there is no
detour overlap yet. The conflicts are architectural: WarcraftXL modifies the executable copy (import +
byte patches + LAA) and replaces `d3d9.dll`, while Ulduar's development loader never writes executable
bytes and validates the exact SHA-256 before and after launch. Both would own "the" native extension layer.

## 3. awesome_wotlk

| Feature | Implementation (source) | Classification |
| --- | --- | --- |
| Loading | `AwesomeWotlkPatch.exe` byte-patches `Wow.exe`/`WowCircle.exe`/`run.exe` in place (no hash check): **replaces the client's own `ScanDllStart` routine** with a stub that loads `AwesomeWotlkLib.dll` and marks the scan finished | CONFLICTS WITH ULDUAR PATCH; neutralizing a client integrity/scan routine is outside Ulduar's rules |
| Startup writes | `DllMain` writes absolute addresses: TOS/EULA accepted flags and a function-pointer "hack" | REJECT (silently accepting agreements; absolute writes without evidence) |
| Auto login | `-login -password -realmlist` on the command line | REJECT (credentials on the command line) |
| FOV | `cameraFov` CVar (1..200 → radians), detour of `Camera::Initialize` 0x00607C20 and live update | PORT IDEA (camera QoL), code only under GPL-3 |
| Nameplate distance | `nameplateDistance` CVar writes the squared distance at 0x00ADAA7C | PORT IDEA |
| Nameplate sorting | per frame: collect visible plates, sort by distance with the target first, reorder frame levels | PORT IDEA |
| `NAME_PLATE_CREATED/UNIT_ADDED/UNIT_REMOVED`, `C_NamePlate.GetNamePlates/GetNamePlateForUnit` | fired from a nameplate update hook | PORT IDEA (Retail-compatible nameplate API is valuable for addons) |
| Clipboard UTF-8 fix | detours of the client clipboard get/set (0x008726F0 / 0x008727E0) | PORT IDEA (small, isolated) |
| `UnitIsControlled/Disarmed/Silenced` | reads unit flags | PORT IDEA |
| `GetInventoryItemTransmog` | returns the **visible item entry** from the player descriptor | NOT USEFUL for collections (not a transmog record; server-side transmog is authoritative) |
| `FlashWindow`, `IsWindowFocused`, `FocusWindow`, `CopyToClipboard` | Win32 wrappers exposed to Lua | PORT IDEA |

Nothing is "already covered by WarcraftXL": WarcraftXL has camera bindings but no FOV CVar, no nameplate API
and no clipboard fix.

## 4. ALE / Eluna

See [ALE_INTEGRATION_STRATEGY.md](ALE_INTEGRATION_STRATEGY.md). Key facts: `azerothcore/mod-eluna` now is
`mod-ale` (same commit); ALE declares itself incompatible with standard Eluna scripts; ElunaAzerothCore is a
**full AzerothCore fork** with `#ifdef ELUNA` in 41 game source files, not a module.

## 5. TSWoW

See [TSWOW_TOOLING_AUDIT.md](TSWOW_TOOLING_AUDIT.md). Key facts: the repository pins **TrinityCore** only
(`cores/TrinityCore` submodule, branch `tswow`); no AzerothCore fork exists in the repository. Its
`misc/client-extensions` subtree is **MIT** and contains a working custom-packet channel for 12340.

## 6. Grim-Batol

- **The War Within Spellbook:** replaces stock FrameXML files (`FrameXML.toc`, `UIParent.lua`,
  `SpellBookFrame.lua/.xml`, `MainMenuBarMicroButtons.lua`) plus Retail BLP art; about 8.8k lines of Lua.
  Requires the client to accept modified FrameXML (interface signature). No license. **REFERENCE ONLY** for
  UX patterns (two-page book, paged content adapter, filter/search, spell categories, shine/animation);
  Ulduar's ADR-002/004 already forbids replacing SpellBook/FrameXML wholesale.
- **Paragon Anniversary:** ALE server scripts + CSMH addon-message bridge + modified FrameXML + Retail art,
  AGPL-3. Endgame progression that overlaps Ulduar's own progression/Forge design. **REFERENCE ONLY**
  (a good example of ALE + client bridge wiring).
- Other organization repositories could not be listed (proxy); not audited.

## 7. AzerothCore modules (server QoL)

| Module | Mechanism | Assessment |
| --- | --- | --- |
| mod-transmog | gossip NPC + `.transmog` commands; `UseCollectionSystem` stores unlocked appearances **per account** (`custom_unlocked_appearances(account_id, item_template_id)`), retroactive unlocks, hidden slots, presets/sets, portable NPC | INTEGRATE as the server authority for appearances; replace its gossip UI with an Ulduar collection addon later |
| mod-aoe-loot | intercepts the loot-open packet, gathers nearby dead creatures (`AOELoot.Range`, clamped 5..100), merges rows into one loot window, preserves rolls/master loot/trade windows | INTEGRATE (pure server, no client change) |
| mod-account-mounts | at login, synchronous `CharacterDatabase.Query` over every character of the account, then `learnSpell` | PORT SELECTIVELY (idea good; blocking login queries should become async or a collection service) |
| mod-account-achievements | shares achievements across the account | DEFER (decide account vs character ownership first, §collections) |

## 8. License and asset risks (summary)

- GPL-3 client code (WarcraftXL, awesome_wotlk): linking it makes the distributed DLL GPL-3. Ulduar's client
  repository has no license yet; choosing GPL-3 for it is required before any such code is copied.
- AGPL-3 server modules (transmog, aoe-loot, Paragon): combining them into worldserver gives AGPL-3
  obligations (source offer to players connecting over the network). Acceptable if the project publishes
  its server source; a decision for the maintainer.
- MIT code (TSWoW client-extensions, Detours): portable with attribution.
- Retail art in repositories (TWW spellbook, Paragon) is Blizzard's; a repository license never grants it.
  Ulduar does not copy those BLPs. UX patterns are re-implemented with 3.3.5 art or original art.
- Byte-patch scripts that bypass client checks (WarcraftXL glue-unlock, awesome_wotlk DLL scan stub) are
  not adopted.

## 9. Discovery limits

Probed by name: `mod-aoe-loot`, `mod-account-mounts`, `mod-account-achievements` (found);
`mod-auto-repair`, `mod-quest-loot-party`, `mod-junk-to-gold` (not found). Retail action bar, bag, map,
quest-tracker and nameplate addon backports were not audited (no search access); they are addon-layer work
and are listed in the feature matrix as "candidate to find", not as evidence.

## 10. Technology conflict matrix

No numeric scores: every cell is a source finding. "12340 compat." means the code targets that build; it does
**not** mean verified against Ulduar's exact executable hash (nothing was run).

| Technology | AzerothCore compat. | 12340 compat. | Core mods | Client DLL/exe mods | MPQ | Addon | Runtime cost | Maintenance | Upstream activity | Hook collision risk | AV false-positive risk | License | Ulduar conflict | Retail-QoL value | Class |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WarcraftXL core | n/a (client) | targets it; no runtime hash gate | none | PE rewrite or `d3d9.dll` proxy; MinHook, 708 hook points | optional (storage transforms) | Lua registration | per-frame render hooks | high (large surface) | very active | high if run with another hook DLL | high (proxy DLL + patched exe) | GPL-3 | loader model, identity policy | high for rendering/assets, none for networking | REFERENCE ONLY |
| wxl-unit-outline | n/a | as core | none | via core | no | no | one extra draw per outlined model + full-screen pass | low | active | via core | via core | GPL-3 | needs core | medium | REFERENCE ONLY (technique) |
| wxl-modern-* / db2 | n/a | as core | none | via core | assets | no | load-time conversion, memory | high | active | via core | via core | GPL-3 | needs core | medium (selected art) | DEFER |
| awesome_wotlk | n/a | targets it; patches any `Wow.exe`/`run.exe` | none | exe byte patches (DLL-scan stub), Detours | no | Lua API/events | small | low | moderate | medium | high (exe patch) | GPL-3 | loader, TOS/EULA writes, credentials | medium (nameplates, FOV) | REFERENCE ONLY (features re-implemented) |
| ALE | module; core hooks already present | n/a | none | none | no | no | global Lua lock on every hook | medium | active | n/a | none | GPL-3 | none (kept off combat) | content speed | DEFER → PROTOTYPE |
| ElunaAzerothCore | core fork | n/a | whole core | none | no | no | similar | high (fork) | active | n/a | none | GPL-2 + GPL-3 | replaces the core | - | REJECT |
| TSWoW runtime | TrinityCore only | n/a | TC fork | - | - | - | - | high | active | - | - | GPL-3 | replaces the core | - | REJECT |
| TSWoW client-extensions | n/a | targets it | none | detours (their own) | optional | Lua bridge | small | low | active | medium | medium (detours) | MIT | none if ported into Ulduar's DLL | high (transport) | PORT SELECTIVELY |
| TSWoW data tools (mpqbuilder, DSL) | n/a | client formats | none | none | yes | no | offline | low | active | none | none | GPL-3 tool | none | high (pipeline) | PORT SELECTIVELY |
| TWW Spellbook | n/a | FrameXML replacement | none | needs signature acceptance | yes | FrameXML | UI only | low | 2025 | n/a | low | none + Blizzard art | FrameXML ADR | high (UX) | REFERENCE ONLY |
| Paragon Anniversary | ALE | FrameXML | none | FrameXML | yes | yes | ALE | medium | 2026 | n/a | low | AGPL-3 + Blizzard art | overlaps progression | low | REFERENCE ONLY |
| mod-transmog | module | n/a | none | none | no | gossip | DB per transmog/unlock | low | active | n/a | none | AGPL-3 | none | high | INTEGRATE |
| mod-aoe-loot | module | n/a | none | none | no | no | grid search per loot | low | active | n/a | none | AGPL-3 | none | high | INTEGRATE |
| mod-account-mounts | module | n/a | none | none | no | no | blocking login queries | low | active | n/a | none | AGPL-3 | none | medium | PORT SELECTIVELY |
