# Ulduar isolated experiment plan

Date: 2026-09-15. **PLANNED ONLY. NO EXPERIMENTS EXECUTED.**
No build, CMake, SQL, client patcher, upstream test runner, dry run or server/client launch belongs to this phase.

## Purpose and isolation

Future experiment root:
`C:\WoWProjecto\experiments\classless-wildcard`.

A later explicitly authorized experiment uses a clean pinned AzerothCore checkout plus the pinned
mod-classless-wildcard reference, fresh disposable databases, separate build/install/data/config/log directories
and a separate test client copied from an authorized baseline.
Keep the read-only reference clone at `C:\WoWProjecto\references\mod-classless-wildcard`.

Never reuse Ulduar world/auth/character databases, DB credentials, client, build directory or server configuration.
Do not point a test server at Ulduar account schemas even for convenience.
Prefer a separate DB instance/port and credentials restricted to experiment schemas.
Use different auth/world ports, realm ID/name, data paths and client realmlist.
Verify resolved absolute paths and process/config/database identities before any later start.

Proposed directory responsibilities, not directories created now:

| Relative path | Content |
| --- | --- |
| source/ac | Clean pinned AC and experiment-only module |
| build, install | Experiment-only build products |
| config, data, logs | Isolated server settings and extracted data |
| database | Fresh-schema identities and disposable snapshots |
| client-baseline | Untouched test-client input with hashes |
| client-candidate | Patched experiment client only |
| evidence | Manifests, logs, screenshots, request traces and findings |

Do not deploy CoA alongside Wildcard in this experiment; that would obscure cause and effect.
A later Ulduar Forge integration sandbox is a separate experiment with copies of synthetic fixtures,
not live saved characters.

## Future preparation gates

1. Record AC/module commit hashes, compiler/dependency versions and per-file license provenance.
2. Establish clean-client build/hash/locale and original backup outside the patcher's output.
3. Inspect every SQL scope from the audit and capture empty disposable-schema baseline.
4. Validate ports, account schema isolation, configs and paths before starting any process.
5. Review installer bootstrap and binary patch behavior before invoking it, including dry-run side effects.
6. Capture generated SQL/client manifest generation IDs and all resulting file hashes.
7. Use a baseline run without the module to distinguish existing AC/client behavior.
8. Enable the experimental module only in that isolated installation and record exact configuration.
9. Preserve evidence before discarding/resetting disposable state.

No commands are provided for running these gates now; this is a reviewable later plan.
A failed isolation check stops that future experiment, not an invitation to borrow Ulduar paths.

## Functional checklist

Every row is NOT RUN. For each, record setup, action, expected/native baseline, actual outcome,
server/client logs, DB before/after and reproduction identity.

| ID | Case | Required observation |
| --- | --- | --- |
| E01 | Character creation / Level 1 | Race/class-2 chassis, starter state, no accidental old profile |
| E02 | Login / first login | Stable class, stats, grants and UI; second login does not duplicate |
| E03 | Mana | Regen/5-second rule, cost, insufficient power, UI and relog lifecycle |
| E04 | Rage | Damage generation, cap, decay, spending and selected/nonselected bar |
| E05 | Energy | Regen, cap, cost, form display and insufficient power |
| E06 | Runes | Allocation before use, six slots, cooldown/grace/conversion, insufficient rune |
| E07 | Runic Power | Generation/spend/decay, units, UI and config lifecycle |
| E08 | Combo Points | Target A/B switch, finishers, target death, Overpower expiry collision |
| E09 | Pet | Summon/tame/load/dismiss; no-pet class context and DK visibility ordering |
| E10 | Pet bars/spells | Commands, autocast, pet type/talent/scaling, async relog restore |
| E11 | Forms | Required-form grants, level restriction, aura exit and independent sources |
| E12 | Stances | Grants/bar/cast checks; removal while active |
| E13 | Stealth | Activation/breaking, native restrictions, relog and loss of entitlement |
| E14 | Dual Wield/weapon skills | Equip/unequip, offhand validity, skill state and revoke |
| E15 | Armor/shields/ranged/ammo | Equip class masks, shield use, wand checks and native ammo cost |
| E16 | Cross-class spell | Costs/target/equipment/LOS/phase/immune behavior |
| E17 | Cross-class talent | Real family effect, rank swap, passive count and tooltip |
| E18 | Spell rank upgrade | Level threshold, downrank policy, book/action continuity |
| E19 | Free Pick | Server cost, prerequisites, duplicate buy and insufficient funds |
| E20 | Unlearn | Refund, dependent talent/form/pet and independent source preservation |
| E21 | Respec | Full state/budget consistency; repeat and disconnect mid-operation |
| E22 | Wildcard roll | Pool eligibility, level/catch-up, weights, no duplicate native line |
| E23 | Reroll | Scroll/currency, empty pool, bans/pity and no replacement failure |
| E24 | Lock / bulk / rapid requests | Desired state, stale lock, batch partial failure and reveal queue |
| E25 | Reconnect | Same grants, currency, bans and ranks; no new roll from reconnect |
| E26 | Restart server | Memory/DB agreement; catch-up rewards not replayed |
| E27 | Action bar | Restore missing button; preserve occupied/user-edited button/spec |
| E28 | Spellbook | All class tabs, passive/active distinction, ranks and other addons |
| E29 | Tooltip | Actual cost/cast/range/effects; ambiguous text and locale cases |
| E30 | Resource UI | Display switch, nonselected pools, rune ready states and CP target |
| E31 | Quest interactions | Class access, spell reward interception, item/XP/gold unchanged |
| E32 | Gear/stat changes | Creation gear, masks, universal stat deltas and equipment scripts |
| E33 | Death/resurrection | Ownership stable; resources/pets/forms/UI correct afterward |

## Failure, security and consistency checklist

| ID | Scenario | Evidence / acceptance concern |
| --- | --- | --- |
| F01 | Malformed/truncated/oversized addon messages | Bounded handling, no crash or mutation |
| F02 | Forged actor/receiver or cross-owner ID | Session identity enforced |
| F03 | Duplicate buy/rank/reroll request | Observe current behavior; Ulduar requires durable idempotency |
| F04 | Stale catalog/config/state | No silent unsupported grants in Ulduar design |
| F05 | Rapid HELLO/catalog/preview traffic | Bounded CPU/memory/network and operation budget |
| F06 | DB query/execute failure | Distinguish unavailable DB from absent profile |
| F07 | Crash between debit, grant, state save and native save | Identify partial commits/replay points |
| F08 | Crash after roll but before last-level update | Catch-up reward duplication/loss |
| F09 | Concurrent players on separate map threads | Grant guards/state pointer safety, race tooling later |
| F10 | Player logout/delete with delayed events | Lifetime safety and native event cancellation |
| F11 | Rune config reload and next login | No null rune storage or bypassed cost |
| F12 | Talent script binding duplication | Exactly one intended effect/proc predicate |
| F13 | Companion cycles and multiple sources | No self-sustaining kit, no unrelated grant deletion |
| F14 | Empty/zero-weight/overflowing roll pools | Defined failure; no currency or ability loss |
| F15 | MPQ/DBC malformed inputs and unknown EXE | Refuse invalid layout/hash; no original overwrite |
| F16 | Module uninstall/revert | Compare entire disposable baseline, document residuals |
| F17 | Addon conflict matrix | Stock-only, bundled-only and selected UI addons by version |
| F18 | Mismatched client/server generation | Reproduce mismatch; design Ulduar compatibility gate |
| F19 | Native global SpellInfo mutation | Check exempt/non-Hero behavior for cross-player effects |
| F20 | Forge same carrier / two instances | Reject ambiguous mapping; prove stable active identity |

Use fault injection only in disposable fixtures. Never expose live account data, credentials or character dumps.
A observed defect is recorded with exact commit/config and narrow reproduction; source-derived suspicions are
not marked confirmed until reproduced. Upstream success does not waive Ulduar semantic acceptance.

## Separate Forge integration acceptance

The Ulduar sandbox later proves all four Slice 1 purpose/method profiles, one Core consumption,
stable instance ID, one compatible Impact Gem, native safe casts and reconnect/restart persistence.
See the complete [Slice 1 acceptance contract](ULDuar_VERTICAL_SLICE_V1.md).
Include crash-after-ownership-before-projection, duplicate commit, stale revision, cross-owner socketing,
carrier collision and existing legacy EP preservation on synthetic migration fixtures.

## Evidence and exit criteria

Each experiment yields a manifest, case outcomes, logs and unresolved limitations.
Resource cases record server values, native cost units and client display separately.
A prototype is accepted only for capabilities actually exercised; do not infer all-class support from one cast.
Stop runtime work on crashes, DB cross-contamination, unsafe cost bypass or ambiguous cast ownership;
preserve evidence, restore only disposable snapshots and narrow the capability set.

Passing the reference experiment does not authorize installation into Ulduar.
Any later extraction is independently reviewed against the portability matrix and tested in the Ulduar sandbox.
No cleanup, install, database or client mutation was carried out as part of writing this plan.
