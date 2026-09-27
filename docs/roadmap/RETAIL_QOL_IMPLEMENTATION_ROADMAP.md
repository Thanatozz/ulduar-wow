# Retail-QoL implementation roadmap

Date: 2026-09-27. Ordered by evidence (player value vs architectural risk), not by the initial wish list.
Architecture: [../architecture/RETAIL_QOL_TARGET_ARCHITECTURE.md](../architecture/RETAIL_QOL_TARGET_ARCHITECTURE.md).
Feature evidence: [../research/QOL_FEATURE_MATRIX.md](../research/QOL_FEATURE_MATRIX.md).

## Phase 0 — decisions (no code)

1. License of `ulduar-client-patch` (GPL-3 needed before porting GPL-3 client code).
2. Accept AGPL-3 obligations for server modules (mod-transmog, mod-aoe-loot) or not.
3. Account-wide vs character-wide ownership for titles/achievements.

## Immediate (server/addon only, no native risk)

| Feature | Architecture | Dependency | Complexity | Responsibility | Reference |
| --- | --- | --- | --- | --- | --- |
| AoE loot | install mod-aoe-loot as a module | Phase 0.2 | low (module + config) | server | azerothcore/mod-aoe-loot |
| Transmog (server authority) | mod-transmog with `UseCollectionSystem = 1`, gossip UI first | Phase 0.2 | low | server | azerothcore/mod-transmog |
| Sell junk + auto repair | Ulduar QoL addon on stock merchant events | none | low | addon | stock API |
| Camera distance option | stock CVars exposed in the Ulduar options | none | low | addon | stock client |

## Short term

| Feature | Architecture | Dependency | Complexity | Responsibility | Reference |
| --- | --- | --- | --- | --- | --- |
| Native transport (ULDCP1) | custom-packet channel, verified against the exact hash; server opcode handler | Windows stage 3 | high | client + server | TSWoW client-extensions (MIT) |
| Collections framework + UI | CollectionService (appearances, mounts, companions) + Collections window | transmog module; transport or addon messages | medium | server + addon | mod-transmog, mod-account-mounts (idea) |
| Spellbook/Forge hub | Ulduar_UI window with search, categories, favorites, Shift detail; stock SpellBook untouched | Ulduar UI framework | medium | addon | TWW Spellbook (UX patterns only) |
| ALE prototype | ALE_INTEGRATION_STRATEGY §5 | build/start authorization | low | server | azerothcore/mod-ale |

## Medium term

| Feature | Architecture | Dependency | Complexity | Responsibility | Reference |
| --- | --- | --- | --- | --- | --- |
| Nameplate events/API + distance + sorting | native Lua registration and nameplate hook | first authorized hooks | medium | client + addon | awesome_wotlk (re-implement) |
| FOV + clipboard fix | two small hooks | first authorized hooks | low | client | awesome_wotlk (re-implement) |
| Dynamic aura presentation | ULDCP1 aura metadata + native aura binding | transport; native aura audit | high | client | Ulduar models |
| Target/mouseover outline | render hook + mask/edge pass | render hook evidence | medium | client | wxl-unit-outline (technique) |
| Reproducible patch pipeline | manifest → ledger-checked DBC/SQL → MPQ → hash manifest | ledger | medium | tooling | tswow mpqbuilder / data DSL |

## Long term

| Feature | Why late |
| --- | --- |
| Quest-objective / interactable outlines | per-model redraw cost; needs objective mapping |
| Modern asset formats (M2/WMO/ADT/DB2) | renderer, memory and crash risk; offline conversion preferred first |
| Arbitrary beams, extended spell presentation | client renderer work |
| >255 aura protocol (ExtendedAuraSlots) | wire + client change |

## Explicitly not planned

Running WarcraftXL and UlduarClientPatch together; Eluna in addition to ALE; the TSWoW TrinityCore
runtime; awesome_wotlk's patcher/loader; any Retail art copied from third-party repositories.
