# Ulduar item stack multiplier

Module: `modules/mod-ulduar-items` (tracked in this repository, see `.gitignore`).
Config: `modules/mod-ulduar-items/conf/mod_ulduar_items.conf.dist`.
Core files modified: **none**.

## Behaviour

Every non-equippable item with a finite positive stack size gets `Stackable * Ulduar.ItemStackMultiplier`
(default 10): 1 -> 10, 5 -> 50, 20 -> 200, 100 -> 1000.

| Case | Result | Why |
| --- | --- | --- |
| `InventoryType != 0` (weapons, armor, bags, quivers, ammo, thrown, relics) | unchanged | equipment stays as is |
| `stackable = -1` or `2147483647` | unchanged | both mean "no limit" in `ItemTemplate::GetMaxStackSize()` |
| `stackable = 0` or `< -1` in the DB | unchanged by us | `ObjectMgr::LoadItemTemplates` already rewrites them to `1` / `-1` (with an error log) before the module runs |
| Result above `2147483646` | clamped to `2147483646` | never produces the `INT32_MAX` "unlimited" sentinel, never overflows |
| `stackable = 1` with per-instance state | unchanged | see below |

### Stack-1 items that stay at 1

`Item::CanBeMergedPartlyWith()` only compares the entry and free space. Two copies of an item that never
stacked before would be merged and one copy's instance data silently discarded. Several core paths also only
track state when `GetMaxStackSize() == 1`. A stack-1 item keeps its stack size when any of these hold:

| Template property | Per-instance data / core assumption |
| --- | --- |
| a spell with charges other than `0` / `-1` | `Spell::TakeCastItem` only persists charges when `Stackable == 1`; otherwise charges would never run out |
| `Duration != 0` | `ITEM_FIELD_DURATION` expiry timer |
| `LockID != 0` or `ITEM_FLAG_HAS_LOOT` | unlocked flag and stored loot (`item_loot_storage`, keyed by item guid) |
| `ITEM_FLAG_IS_WRAPPER` | wrapped gifts (`character_gifts`, keyed by item guid) |
| `ITEM_FLAG_PETITION` | guild/arena charters (petition keyed by item guid) |
| `ITEM_FLAG_ITEM_PURCHASE_RECORD` | extended-cost refunds are only recorded when `GetMaxStackSize() == 1` (`Player::BuyItemFromVendorSlot`) |
| entry `MAIL_BODY_ITEM_TEMPLATE` | mail letters carry `ITEM_FIELD_ITEM_TEXT_ID` |
| `Bonding` = BoP / quest | the 2 h group-loot trade window is only granted when `GetMaxStackSize() == 1` (`Group.cpp`, `PlayerStorage.cpp`) |

Items that already stacked (`stackable > 1`) are always multiplied: the core already handles them as stacks.

## Implementation

1. `OnAfterConfigLoad(reload=false)` reads `Ulduar.ItemStackMultiplier` and `...BumpClientCache`. On a config
   reload a changed multiplier only logs a warning: the store was already rewritten, so a new value needs a
   restart.
2. `OnBeforeWorldInitialized` runs after `ObjectMgr::LoadItemTemplates()` and every other DB load, and before
   grids are preloaded or any session exists. It walks `ObjectMgr::GetItemTemplateStoreFast()` (a vector of
   non-const `ItemTemplate*`, so no `const_cast`), asks the pure `Ulduar::ItemStacks::ComputeStackable()` and writes
   the new `Stackable`. It logs one summary line (`module.ulduar.items`); per-item lines are `LOG_DEBUG` only.
3. `OnBeforeFinalizePlayerWorldSession` adds the active multiplier to the client cache version. The 3.3.5a client
   caches `SMSG_ITEM_QUERY_SINGLE_RESPONSE` (which carries `Stackable`) in `WDB`; a different version makes it
   drop that cache. The value is stable across restarts and changes whenever the multiplier changes.

### Idempotence

Nothing is written to the world DB and no SQL migration exists. Each process start reads the original
`item_template.stackable` again and multiplies it once, so 20 always becomes 200, never 2000. `item_template`
has no reload command, and the module also guards against the hook running twice.

`ServerMailMgr` validates `mail_server_template_items` counts before the module runs, so it still checks
against the original stack sizes.

## Protocol and subsystem audit

| Area | Width / behaviour | Verdict |
| --- | --- | --- |
| `item_template.stackable`, `ItemTemplate::Stackable` | `int32` | fits |
| `ITEM_FIELD_STACK_COUNT`, `item_instance.count` | `uint32` / `int unsigned` | fits |
| Item query packet | `int32(Stackable)` | client learns new size after cache bump |
| Split, swap, bank, guild bank, trade, vendor buy/sell, auction, mail | `uint32` counts; limits come from `GetMaxStackSize()` | fits |
| Loot (`LootItem::count` is 8 bits) | holds the drop count, bounded by the DB's `tinyint` `MaxCount` (<= 255); bigger stacks only mean fewer loot slots | fits |
| Vendor `BuyCount` bundles, `MaxCount` (unique limit), item limit categories | not scaled | ownership caps are unchanged |
| `CMSG_DESTROYITEM` | client packet `u8 bag, u8 slot, u8 amount, u8 unk1..3` | **see open risk** |

### Open risk: destroying stacks larger than 255

The destroy packet carries the amount in one byte, and that layout belongs to the 3.3.5a client, so the server
cannot widen it to 16 bits. The server treats `amount = 0` as "destroy the whole item" and otherwise destroys
`amount`. The three following bytes are undocumented. They may be the high bytes of a 32-bit amount. Stock
3.3.5a already has 1000-stacks (arrows), so the client handles it somehow, but that is not verified. At worst a
player destroys fewer items than intended; the server never destroys more than the stack.

To check: destroy a 300-stack (whole stack, and after a split) and confirm what disappears. If only part
disappears, capture the packet. If `unk1..3` turn out to be the high bytes, reading `amount` as `uint32` in
`WorldPackets::Item::DestroyItem::Read` is a one-line core change.

## Known side effects

- `ItemTemplate::HasSignature()` requires `GetMaxStackSize() == 1`. Multiplied stack-1 items (e.g. crafted
  companion boxes) no longer record "Made by".
- Clients with the cache bump disabled keep old stack sizes in their split UI until they delete `Cache/`.
