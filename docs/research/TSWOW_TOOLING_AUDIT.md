# TSWoW tooling audit

Date: 2026-09-27. Evidence: `tswow/tswow` at `00608832b426` (2026-08-02). License: GPL-3.0 for the repository;
`misc/client-extensions` is **MIT** (its own LICENSE; Lua 5.1 under its COPYRIGHT). Not installed or run.

## 1. Core coupling

- `cores/TrinityCore` is the only core submodule (`https://github.com/tswow/TrinityCore.git`, branch
  `tswow`). The repository contains **no AzerothCore fork** and no AzerothCore references; no evidence of a
  usable AzerothCore port was found. Ulduar stays on AzerothCore.
- The runtime scripting (TypeScript → C++ via `tswow-scripts/typescript2cxx`, `tswow-core`) targets the
  TrinityCore fork's hook set.

## 2. Components

| Piece | Path | What it does | Class |
| --- | --- | --- | --- |
| Data DSL (TypeScript) | `tswow-scripts/data/{dbc,sql,luaxml,cell,query,table}`, `tswow-scripts/wotlk/{dbc,sql,luaxml,std}` | typed editing of DBC rows, SQL tables and client Lua/XML, with cross-references | PORTABLE IDEA (schemas differ between TC and AC SQL; DBC layouts are the client's and are the same) |
| ID allocator | `tswow-scripts/util/ids/{Ids.ts,Allocator.ts}` | per-table id ranges keyed by `mod:name`, persisted as `table|fullName|low|high` | PORTABLE IDEA; Ulduar's append-only ledger with evidence and tombstones is stricter and stays authoritative |
| MPQ builder | `misc/mpqbuilder` (C++, StormLib) | builds client patch MPQs from a folder | PORTABLE TOOL candidate for Ulduar's patch pipeline (license GPL-3 for the tool; the MPQ output is data) |
| Lua/XML reader | `misc/mpqbuilder/luaxmlreader.cpp` | reads client Lua/XML | PORTABLE TOOL |
| BLP converter | `misc/blpconverter` | image ↔ BLP | PORTABLE TOOL |
| ADT creator | `misc/adt-creator` (submodule) | creates ADT tiles | PORTABLE TOOL (not needed now) |
| Client extensions | `misc/client-extensions` (MIT) | client DLL: detours (`ClientDetours`), custom packets (`CustomPackets/*`, opcodes 0x102 S→C = stock `CMSG_EMOTE` number, 0x51F C→S = stock `TC9_CMSG_PREPARE_FOR_REDIRECT` number; fragmentation), Lua bridge, MPQ loading, `ClientWardenDisabler` (empty file in this commit) | PORT SELECTIVELY: the custom-packet transport is the most relevant piece for Ulduar's native transport (stage 3); Warden-related code is not ported |
| Module workflow / IDE | `build.js`, VSCodium integration, `tswow-scripts/compile`, `runtime` | project/module build orchestration and live reload | PORTABLE IDEA |
| TypeScript → C++ | `tswow-scripts/typescript2cxx` | transpiles server scripts | TRINITYCORE-COUPLED |
| Server runtime | `tswow-core` | TC hook bindings | TRINITYCORE-COUPLED |

## 3. What Ulduar should reuse

1. **Transport:** evaluate the MIT custom-packet layer as the basis of ULDCP1 native ingress, instead of
   addon-whisper parsing. Server side: an AzerothCore opcode handler in Ulduar code (not TSWoW's). Each client
   address (0x006B0B80 handler registration, 0x006B0B50 `SendPacket`, 0x00401050/0x00401130 packet
   init/finalize) must be verified against the exact SHA-256 before any hook (Windows handoff stage 3).
2. **Data pipeline ideas:** typed DBC/SQL generation from one source, generated IDs checked against the
   Ulduar ledger (never `max(id)+1`), and one command that rebuilds the client MPQ and the server SQL
   together.
3. **mpqbuilder** as a candidate MPQ packer for a reproducible patch build (hash manifest and conflict
   detection are Ulduar additions, see the roadmap).

## 4. Not suitable

- Switching to the TrinityCore fork or its TypeScript server runtime.
- Treating TSWoW's ID allocator as authority over the Ulduar ledger.
- Any Warden/anti-cheat-related client code.
