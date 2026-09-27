# Retail-QoL target architecture

Date: 2026-09-27. Evidence: [../research/RETAIL_QOL_ECOSYSTEM_AUDIT.md](../research/RETAIL_QOL_ECOSYSTEM_AUDIT.md);
decisions: [../research/CLIENT_EXTENSION_FRAMEWORK_DECISION.md](../research/CLIENT_EXTENSION_FRAMEWORK_DECISION.md),
[../research/ALE_INTEGRATION_STRATEGY.md](../research/ALE_INTEGRATION_STRATEGY.md).

Goal: Retail-like usability on a WotLK 3.3.5a / AzerothCore foundation, Classic/WotLK visual identity by
default, one authority per layer.

## 1. Layers (one authority each)

```text
SERVER CORE          AzerothCore (Ulduar fork, GPL-2.0)
  COMBAT SYSTEMS     C++ modules: mod-ulduar-abilities, density/city systems
  SERVICES           C++ modules: collections (transmog/mounts/titles), AoE loot
  CONTENT SCRIPTING  ALE (only after the prototype passes; never on combat paths)

CLIENT NATIVE        UlduarClientPatch.dll (the only native extension framework)
  transport          ULDCP1 over a verified custom-packet channel (TSWoW MIT design, re-verified)
  presentation       DynamicAuraPresentation, Range, movement, later outline/nameplates/camera
                     (re-implemented; WarcraftXL/awesome_wotlk as evidence only)

UI                   Ulduar_UI shared library (AddOns + minimal FrameXML hooks per ADR-002/004)
  Spell Forge / Spellbook hub, Collections, Transmog, Character, Quest QoL, QoL options

DATA / ASSETS        one reproducible patch pipeline: source manifest -> DBC/SQL generation checked
                     against the ID ledger -> MPQ build -> hash manifest -> rollback
```

## 2. Evaluation of the proposed stack

| Proposed element | Verdict | Why |
| --- | --- | --- |
| AzerothCore + C++ combat modules | KEEP | no alternative core; Ulduar core changes are AzerothCore-specific |
| ALE for rapid content | CONDITIONAL | module, no core patch, `.reload ale`; global lock and sync DB queries limit it to content, not combat |
| Transmog/collections services | ADOPT mod-transmog as appearance authority, unify under one collection service | server-authoritative, account-wide table already exists |
| WarcraftXL **or** UlduarClientPatch as the one native foundation | UlduarClientPatch | exact-hash gate, no executable rewrite, transport priority; WarcraftXL lacks networking and rewrites the PE |
| Ulduar_UI shared library | KEEP (already the plan: 11-14 architecture docs) | Retail UX patterns re-implemented with Classic art |
| Reproducible data pipeline | ADD | no pipeline exists; TSWoW mpqbuilder + ledger-checked generation |

The proposed architecture is better than the current one only in that it adds the missing service layer
(collections, AoE loot) and a data pipeline. The native layer stays as it is.

## 3. Collections framework (one, not per module)

| Concern | Decision |
| --- | --- |
| Authority | server (C++): a `CollectionService` owning appearances (mod-transmog table), mounts, companions, titles, future cosmetics |
| Ownership | **account-wide** for appearances, mounts and companions (Retail-like); titles and achievements: character-wide until a separate decision |
| Protocol | one versioned Ulduar collection message family (over the same transport as ULDCP1 or addon messages until native transport exists) |
| UI | one Collections window in Ulduar_UI (tabs: Appearances, Mounts, Companions, Titles); Classic art |
| Client storage | SavedVariables only for view preferences, never for ownership |

## 4. Native vs addon responsibility

| Need | Addon only | Needs native |
| --- | --- | --- |
| Bag, sell junk, repair, quest tracker, collections UI, spellbook hub | yes | no |
| Nameplate events/API, nameplate distance, FOV, clipboard, outlines, dynamic aura icons, Range/movement | no | yes (each hook with evidence) |
| AoE loot, transmog, account unlocks | no (server) | no |

## 5. Constraints kept

- Never modify the primary `Wow.exe` or MPQs; no interface-signature bypass as an implicit requirement.
- No stealth, evasion or anti-cheat bypass code from any source.
- Capabilities stay 0 until each is proven end to end.
- GPL-3 client code only after the client repository adopts GPL-3; AGPL server modules only after the
  AGPL obligations are accepted; no Retail art.
