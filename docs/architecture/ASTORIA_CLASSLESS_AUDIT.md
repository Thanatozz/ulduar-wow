# Astoria classless source audit

Audit date: 2026-09-14. Read-only source inspection; nothing installed, imported, compiled or executed.
No Astoria checkout was located by the workspace path/name inventory. Public sources were read over HTTPS.
The packaged MPQ was not extracted; asset completeness and rendered UI behavior are unverified.

## Revisions and primary evidence

- Classless system: `9eb3ec311e50f73d1694b88d708790f437ff2a87`.
- AstoriaCore: `84008476c0da2ac51c92a3a6fc89025e90586ef5`.
- Ulduar checkout: `d7ce67dc1800f092bac98aad680ece1c201b89a0` plus existing local modifications.

The target checkout has AzerothCore upstream and module hooks. The request's “current TrinityCore” is interpreted
as the current Ulduar core, with Trinity lineage; no switch of core is proposed. AstoriaCore's Player APIs and
Lua bindings are references, not proof of binary/source compatibility with this checkout.

Source references used below:

| Ref | Pinned source | Evidence inspected |
| --- | --- | --- |
| A1 | [Server.lua][server] | Entire file: SendVars, DB functions, learning, reset and event registration |
| A2 | [Client.lua][client] | Catalog registration, class list, points, rank/requirement UI, mutation calls |
| A3 | [spells.data][spells] | Class/spec catalog and ordered native spell rank/level arrays |
| A4 | [talents.data][talents] | Native talent rank arrays; class/spec presentation data |
| A5 | [req.data][req] and [locks.data][locks] | Explicit prerequisite and mutual-exclusion source data |
| A6 | [A_encryption.lua][secret] | randomString and checkSecret |
| A7 | [character_classless.sql][sql] | Guid row with spells/tpells/talents/stats text columns and resets |
| A8 | [Levelup.lua][level] | Level event grants skills 414, 413 and 293 at 10, 20 and 40 |
| A9 | [PlayerMethods.h][methods] | Eluna LearnSpell/LearnTalent bridges around lines 3685/3705 |
| A10 | [Player.cpp][player] | LearnSpell around 3555; native LearnTalent around 25283 |
| A11 | [README][readme] | Installation requirements for Eluna, AIO, Lua scripts, SQL and client patch |

## Answers to the fifteen audit questions

1. **Spells across classes:** A2 registers A3 with `AIO.AddAddon`, then `FillSpells` reads class/spec arrays and
   renders spell buttons. Browsing is driven by selected catalog class, not the player's original class. However,
   `class_list` contains Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock and Warrior: nine classes,
   with no Death Knight. An unused/display `classes` array mentions MONK/DEMONHUNTER; that does not add WotLK data.
   This source snapshot is not a verified all-ten-class catalog. [Client source][client]
2. **Talents across classes:** A4 supplies arrays of native talent rank spells, names/icons through client spell
   data, and class/spec backgrounds. The UI lets the player select those catalog groups. It does not implement
   Ulduar semantic selectors or generalized effects. [Talent catalog][talents], [client][client]
3. **Native restrictions:** A1 `LearnTalent` calls `player:LearnSpell` for supplied rank SpellIDs, not Eluna
   `LearnTalent(TalentID, rank)`. A9 exposes both methods; A10 native LearnTalent still checks class mask. The Lua
   path bypasses that native talent-tree entry point. This is not evidence that native family-specific behavior
   inside the learned spells becomes universal. [Server][server], [Eluna bridge][methods], [core Player][player]
4. **Learned spell persistence:** A1 caches guid-indexed arrays, serializes them to `character_classless.spells`
   and `tpells`, then uses LearnSpell/RemoveSpell and SaveToDB for native state. `tpells` accounts for spell
   selections charged to talent points by the client. There are two representations to reconcile. [Server][server]
5. **Talent persistence:** Native rank SpellID arrays are stored in `character_classless.talents`, as comma-delimited
   text; selected passives are also learned through the core. There is no normalized universal definition/rank
   ownership table or durable revision. [Server][server], [schema][sql]
6. **Talent ranks:** A2 determines rank by membership in ordered rank arrays and stages the next rank. The server
   learns the submitted list and removes previous entries absent from it. It does not independently prove that
   the submitted list is a legal rank progression or has the right total cost. [Client][client], [server][server]
7. **Prerequisites:** Client `FillSpells` checks required levels, available AP/TP, `db.req`, `db.rreq` and `db.locks`.
   These are explicit source-data relationships rather than a server Talent.dbc eligibility calculation.
   Equivalent validation is absent from the inspected learning handlers. [Client][client], [requirements][req]
8. **UI population:** AIO sends executable client Lua/data; local CLDB stores catalogs and selected arrays.
   `GetSpellInfo` provides icons/names, and native tooltip text is parsed for presentation. Source class/spec
   lists and backgrounds are baked into the data. `ToggleTalentFrame` is overridden to open CLMainFrame.
   The MPQ supplies additional client assets; exact contents are unverified. [Client][client], [installation][readme]
9. **Server authority:** Server owns the authenticated player object, actual LearnSpell/RemoveSpell operations,
   DB writes, and reset money checks/debit. It does not own the AP/TP calculation or catalog/rank/prerequisite
   validation in these handlers. Client-side AP is `floor(level*0.45)` less selections; TP is `max(level-9,0)`
   less talent/talent-cost-spell selections. [Server][server], [Client GetPoints][client]
10. **Eluna dependency:** Player events, GUID/level/spell/skill/money methods, GetPlayersInWorld, CharDBQuery,
    and saving all require the Lua engine API. Ulduar C++ PlayerScript and database APIs can replace them.
    [Server][server], [level grants][level], [Eluna methods][methods]
11. **AIO dependency:** `AddHandlers`, `Handle`, `AddOnInit`, `AddAddon`, `IsServer` and `Msg` provide registration,
    initialization, client distribution and calls. This audit did not inspect the separate AIO implementation,
    so transport limits/serialization protections are not assumed. [Server][server], [client][client]
12. **AstoriaCore-specific dependency:** The Lua system uses core binding methods plus native spell semantics and
    packaged UI assets. A9 has TRINITY/AZEROTHCORE conditional bridges; that supports a portability hypothesis,
    not a drop-in guarantee. Full cross-class cast restrictions, resource visibility and skill/form behavior require
    target-core tests. No broad Astoria patch set is required merely to create the Ulduar catalog. [Bridge][methods]
13. **Portable parts:** Catalog structure, ordered rank provenance, staged UI state, spell/talent point separation,
    search/browse concepts and login synchronization are reusable design material. Re-audit actual catalog coverage,
    levels, dependency edges and data provenance before importing them. [Catalog][spells], [client][client]
14. **Rewrite in C++:** Ownership, budget calculation, learn/unlearn validation, revisions, atomic persistence,
    grant reconciliation, prerequisites, compatibility state and runtime rules belong in Ulduar services. Use
    native spell grant adapters only after semantic validation; generalized talents need Ulduar rule execution.
    This is an architectural recommendation based on the omissions visible in [Server.lua][server].
15. **Security assumptions not to copy:** The client receives the `serverSecret` in SendVars, and checkSecret only
    compares equality. This cannot authorize gameplay choices. Learning accepts caller-supplied arrays without
    server catalog, point, classless prerequisite or rank validation. A modified authorized client can submit
    choices outside the UI's rules; native core spell validity checks do not substitute for a purchase budget.
    [Server][server], [secret check][secret]

## Validation and persistence findings

These are source-level findings, not exploit tests or claims about every deployed Astoria version.

- Learning handlers lack explicit input type/count/duplicate limits and canonical catalog resolution. Validate
  bounded IDs and reject unknown/rank-skipping requests before any grant or DB write. A shared token is not a
  trusted client or a price validation mechanism. [Server][server], [secret helper][secret]
- DBWrite concatenates values into SQL and returns true unconditionally. Serialized user-supplied arrays have
  no explicit type validation in the handler. Treat this as an unsafe construction surface; whether a malicious
  value reaches SQL also depends on Eluna/AIO coercion, which was not tested. Use typed parameters and confirmed
  transaction results. [Server DBWrite][server]
- Multiple custom row updates, native spell changes and SaveToDB are separate operations. Crash consistency and
  replay protection are not established. Logout writes cached arrays again. Introduce one durable build
  transaction, request deduplication and reconciliation of native spell state. [Server][server]
- WipeAll has a server money check, but performs several removals/writes without a transaction. Removing a spell
  based only on membership in this subsystem's list can conflict with other grant sources. A2 also places
  prerequisites in client code, making server-side whole-build validation necessary. [Server][server], [client][client]
- `DBRead` replaces stats with zeros instead of loading its stored string; the schema's stats field does not prove
  a working stat allocation subsystem. Avoid copying apparent capabilities based on column names. [Server][server]

## KEEP / PORT / REWRITE / IGNORE

KEEP means preserve a concept in the design; PORT means extract after validation; neither authorizes copying
unreviewed source, data, assets or behavior into runtime in this phase.

| Subsystem | Decision | Ulduar disposition |
| --- | --- | --- |
| Class-independent browsing concept | KEEP | All ten classes as source material; player-facing categories |
| Native rank arrays/catalog | PORT | Import as provenance; compare against complete local DBC corpus |
| Catalog source prerequisites | PORT | Evidence only; re-author generic requirements with rationale |
| Staged selection/confirmation | KEEP | Existing Ulduar draft model already supplies much of this |
| Class/spec tree presentation | IGNORE | No authoritative class/tab/tier gates or final layout adoption |
| Universal spell grants | REWRITE | C++ catalog, budgets, reference-counted grants and native adapters |
| Universal talent grants | REWRITE | Ulduar definitions/ranks/selectors; no blind native LearnSpell list |
| Character persistence | REWRITE | Normalized versioned ownership and transaction ledger |
| Server/client synchronization | KEEP | Snapshot/revision semantics using existing authenticated transport |
| AIO distribution/transport integration | IGNORE | No new dependency required for current C++/addon stack |
| Eluna event wiring | REWRITE | PlayerScript/core adapters; no dependency introduced |
| Secret-equality validation | IGNORE | Authenticated session plus server rules, limits and replay defense |
| Reset pricing idea | KEEP | Versioned server policy, atomic debit/refund and complete grant checks |
| Level-based weapon/armor skill grants | REWRITE | Generic mechanic grants, controlled native prerequisites |
| MPQ visuals/assets | IGNORE | Uninspected package; assess only if later needed and attributable |
| AstoriaCore base and unrelated changes | IGNORE | Retain current Ulduar core and all Abilities functionality |

## Portability conclusion

A selective port is reasonable: Astoria saves research on classless catalog/rank presentation and Lua UI flow.
The existing Ulduar protocol/draft/runtime foundation already covers parts of that work. A wholesale subsystem
port would import incomplete catalog coverage, native talent spell semantics and insufficient learning validation.
The recommended implementation is native C++ services using audited data concepts, not replacement of the core.
Treat compatibility with an actual separate TrinityCore checkout as an additional adapter project; it was not
validated here. Preserve upstream attribution for any subsequently reused implementation or data.

[server]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/Server.lua
[client]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/Client.lua
[spells]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/data/spells.data
[talents]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/data/talents.data
[req]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/data/req.data
[locks]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/data/locks.data
[secret]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/A_encryption.lua
[sql]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/SQL/character_classless.sql
[level]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/LUA/ClassLess/Levelup.lua
[methods]: https://github.com/AstoriaCore/AstoriaCore/blob/84008476c0da/src/server/game/LuaEngine/PlayerMethods.h
[player]: https://github.com/AstoriaCore/AstoriaCore/blob/84008476c0da/src/server/game/Entities/Player/Player.cpp
[readme]: https://github.com/AstoriaCore/Astoria-ClasslessSystem/blob/9eb3ec311e50/README.md
