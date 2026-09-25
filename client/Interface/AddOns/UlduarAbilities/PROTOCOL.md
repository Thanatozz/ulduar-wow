# Ulduar Abilities addon protocol v2

Prefix `ULDAB1`, transport WHISPER, language LANG_ADDON, recipient exactly the requesting player.
Client uses the global 3.3.5a SendAddonMessage API. Server intercepts the private-chat PlayerScript
hook before normal whisper forwarding, then replies directly to that player's session.
Every message includes prefix + TAB + payload and is at most 255 bytes including the prefix/TAB.
Payload fields use ASCII `|`; numeric fields only, except fixed operation/error identifiers.
No icon paths, arbitrary chat strings, SQL, target GUIDs, rank grants or remote character operations.

Header: `2|TYPE|sequence|token` (four fields). Sequence is a positive uint32, monotonic per handshake.
The server token is a nonzero random uint32, handled as a string in Lua. It correlates a session;
authentication comes from the server Player and self-recipient check, not token secrecy.

## Requests

| Payload | Meaning |
| --- | --- |
| `2|HELLO|seq|0` | Negotiate v2 and issue new session token; includes initial snapshot |
| `2|GET|seq|token` | Refresh enabled definitions and this character's cached state |
| `2|APPLY_BUILD|seq|token|abilityId|baseRevision|element|mode|coverage|potency|damage|cooldown|castTime|rebound` | Atomically validate/commit the draft |
| `2|COVERAGE|seq|token|abilityId` | Server reads current Coverage rank and purchases +1 |
| `2|POTENCY|seq|token|abilityId` | Server reads current Potency rank and purchases +1 |
| `2|ELEMENT|seq|token|abilityId|element` | Validated element choice through AbilityManager |
| `2|MODE|seq|token|abilityId|mode` | Validated free propagation selection |
| `2|RESET|seq|token|abilityId` | Existing manager reset, retaining custom rank |

Addon 1.4 sends ONLY APPLY_BUILD for mutations. Per-node operations remain legacy compatibility for
tools using protocol 2; clients using protocol 1 are rejected. They are not used by draft editing. The server has no request that sets available
points, custom rank, costs, radii or multipliers.
Only runtime-enabled definitions with loaded player state can mutate. Costs, prerequisites and
persistence are checked by AbilityManager. Invalid/overflowing/non-numeric fields fail parsing.
Requests are limited to eight per two-second window per GUID, including handshake attempts.
A sequence is consumed before mutation, so repeated requests never spend twice. Logout erases the
protocol session. A new handshake rotates the token; old-session mutations are rejected.

## Replies

All replies repeat sequence and token. HELLO errors use token 0. Successful WELCOME supplies the
new token, followed by BEGIN, then DEF/STATE/RANKS per ability and END. Each tuple below appends fields
to the four-field header; DEF has 14 total fields and STATE has 17.

| TYPE | Additional fields |
| --- | --- |
| WELCOME | none |
| BEGIN | abilityCount |
| DEF | id, baseSpellId, castType, targetingType, deliveryType, temporalType, rangeType, effectFlags, targetRelation, modeMask |
| CAPS | id, nodeMask, classId, skillLineId, specialization label (additive v1 record) |
| BASE | id, baseElement (additive v1 record; required by addon 1.2) |
| REV | id, stateRevision (uint64 decimal string in Lua; required by addon 1.3) |
| RULES | elementCost, coverageCost, potencyCost, maxRank, maxTargets, maxRange, baseTargets, baseSearch, searchStep, baseNova, novaStep, basePotency, potencyStep |
| BALANCE | propagationCap, meleeCap, novaCap, chainStep, damageStepPct, cooldownStepSeconds, cooldownCapPct, castStepSeconds, castCapPct, castFloorSeconds, modifierCost |
| MODIFIERS | id, modifierMask, damageRank, cooldownRank, castTimeRank, reboundRank, baseCooldownMs, baseCastTimeMs |
| STATE | id, customRank, availablePoints, spentPoints, element, mode, coverageRank, potencyRank, targetCount, searchRange, novaRadius, secondaryEffectMultiplier, safetyLimited |
| RANKS | id, comma-separated Blizzard rank spell IDs (multiple chunks allowed) |
| END | none |
| ERROR | code, terminal (0 or 1) |

Enums use AbilityTypes.h numeric values. Elements: Original 0, Physical 1 (unsupported), Holy 2,
Fire 3, Nature 4, Frost 5, Shadow 6, Arcane 7. Modes: None 0, Impact 1, Split 2, Shatter 3, Nova 4,
Chain 5. modeMask sets bit `1 << mode`; None is not shown as a selectable node. All type dimensions
start at 0 in their C++ declaration order. Effect flags are a bitmask, permitting Damage + Healing.
Rank IDs are obtained from GetNextSpellInChain; each comma-separated chunk is bounded to 160 bytes
before its next ID, leaving room for the header. Values in STATE are cached/derived, not a DB SELECT.
Only mutations invoke the manager's existing synchronous save/readback.

Errors: VERSION, UNAVAILABLE, THROTTLED, SESSION, REQUEST, ABILITY are terminal. REJECTED is followed
by a fresh snapshot, including an empty snapshot if a persistence error invalidated the player cache.
The UI retains the error message while committing that snapshot. Terminal errors clear availability;
Refresh establishes another session. An eight-second timeout disables mutations until reconnect.
Timeouts never retry mutations automatically: a save may already have succeeded on the server.

The client accepts only matching sequence/token, its own sender name and WHISPER transport.
APPLY_BUILD errors use nonterminal ERROR plus snapshot (STALE/BUDGET/LIMIT/REJECTED/ABILITY).
The manager validates the complete candidate under one lock, persists one row and increments REV.
Revisions are process-local uint64 generations, renewed on load, manager commits and config reload;
session/handshake boundaries invalidate old drafts. No revision SQL column is required.
The complete concurrency and failure contract is documented in the module's DRAFT_BUILD.md.
It stages all records and atomically commits at END after confirming counts and a STATE for every DEF.
Late/unrelated packets are ignored. UI selection can change while pending; it does not change the
AbilityId already sent. A full GET on open/Refresh reconciles changes made with GM commands.
UI capacity is 128 runtime entries for this protocol version; future large registries need pagination.

CAPS nodeMask bits: 1 element, 2 coverage, 4 potency, 8 controller payload, 16 aura-only propagation.
The new client disables node purchases until capabilities arrive. Older v1 clients ignore CAPS, but
server validation still rejects unsupported purchases. The server sends only runtime definitions
whose ClassId matches the player (0 is unrestricted) and whose chain contains an active known rank.
GetAvailableAbilitiesForPlayer performs this check; EVERY mutation rechecks the same eligibility.
Class/spec sorting is presentation only. Names/icons still come from the client SpellID.
BASE comes from AbilityDefinition, not DBC text or a client inference. Original in STATE resolves to
BASE for presentation. Old v1 clients ignore BASE; addon 1.2 refuses a nonempty snapshot missing BASE,
with an explicit update message. Deploy server and addon together. No new SQL is needed.
All records remain within 255 bytes, including prefix/header. SPELLS_CHANGED requests a debounced GET;
Refresh reconciles GM changes. Snapshot completion remains server-authoritative.

Modifier mask: Damage=1, Cooldown=2, CastTime=4, Coverage=8, Potency=16, Rebound=32.
BALANCE and MODIFIERS are mandatory for addon 1.4. See the module MODIFIERS_BALANCE.md for current rules.

## Developer Ability Lab (addon 1.6)

The Lab window (`/ua lab`, `/ualab`) does not use `ULDAB1`. It reuses the core's addon command channel
(prefix `AzerothCore`, `AddonChannelCommandHandler`): request `h<4-digit counter>ua lab <args>` as a WHISPER to
the player itself; replies `a<counter>` (ack), `m<counter><text>` (one output line), `o<counter>` (ok) or
`f<counter>` (failed). The server runs the exact `.ua lab` chat command, so GM access and
`UlduarAbilities.DebugEditor` are enforced there. Arguments are single tokens limited to letters, digits and
`. _ % + -`. See `docs/architecture/ULDuar_ABILITY_LAB.md`.
