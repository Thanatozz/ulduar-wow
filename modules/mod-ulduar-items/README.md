# mod-ulduar-items

Ulduar WoW item tuning.

- **Item stack multiplier**: `Ulduar.ItemStackMultiplier` (default 10) multiplies the stack size of
  non-equippable items in memory at startup. No DB writes, so restarts never compound it.

Full design, exclusion rules and protocol audit: `docs/implementation/ULDuar_ITEM_STACK_MULTIPLIER.md`.

Configuration: copy `conf/mod_ulduar_items.conf.dist` to `<config dir>/modules/mod_ulduar_items.conf`
(CMake install does this).
