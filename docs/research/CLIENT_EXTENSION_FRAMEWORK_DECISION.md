# Client extension framework decision

Date: 2026-09-27. Evidence: [RETAIL_QOL_ECOSYSTEM_AUDIT.md](RETAIL_QOL_ECOSYSTEM_AUDIT.md) §2, §3, §5 (exact
commits there). Scope: which code owns the native layer inside the 3.3.5a 12340 client.

## 1. Options

- **A.** Keep `ulduar-client-patch` (UlduarClientPatch.dll) as the one native framework; use WarcraftXL,
  awesome_wotlk and TSWoW client-extensions as evidence, references and sources of isolated, licensed ports.
- **B.** Adopt `wxl-core` as the foundation; Ulduar features become WarcraftXL extensions.
- **C.** Run both DLLs.

## 2. Comparison

| Criterion | A: Ulduar patch | B: WarcraftXL core | C: both |
| --- | --- | --- | --- |
| Executable identity | exact SHA-256 + version words + machine + PE magic, checked by the loader and again inside the DLL | none at runtime; patcher accepts any PE32; extension check is a compile-time constant | two policies |
| Executable modification | none (child-process load of an unmodified disposable copy) | PE rewrite of a copy: LAA flag, new import section, byte patches (interface-signature bypass) — or a `d3d9.dll` proxy | both |
| Native evidence quality | explicit: zero hooks until each address has review evidence against the exact hash | 708 named addresses maintained by the project; broad, community-reviewed, not evidence-linked per build hash | - |
| Hook engine | none yet (by rule) | MinHook with a named registry | two engines patching one process: order undefined |
| Network / custom protocol | ULDCP1 v1 portable parser, session, cache; native ingress not proven | **absent** (no packet/opcode layer) | - |
| Rendering, assets, DB2, outline, ImGui | absent | strong (outline, modern M2/WMO/ADT, DB2, storage transforms, ImGui) | - |
| Build reproducibility | CMake, portable tests run on Linux (393 + 137 + 15 checks) | CMake Win32; extensions auto-discovered; releases from CI | - |
| License | no license yet (maintainer choice) | GPL-3.0(-or-later): Ulduar client code linked to it becomes GPL-3 | GPL-3 for the combined distribution |
| False-positive / AV risk | remote-thread `LoadLibraryW` in the development loader only (development-only by rule) | proxy `d3d9.dll` + patched executable: the patterns security software flags most | highest |
| Deployment | disposable copy + development loader (production loader is a future milestone) | patcher + DLLs next to `Wow.exe`, hub launcher/store | two installers |
| Protocol ownership | Ulduar | none (would stay Ulduar code inside an extension) | Ulduar |
| Upstream change risk | none | active (daily commits, ABI 1.1 on branch `v1.1`) | double |

## 3. Decision

**A, with selective ports.** Rationale:

1. Ulduar's highest client priority is a trusted **transport** (HELLO/WELCOME, then Range/movement/aura).
   WarcraftXL provides nothing there; TSWoW's MIT `client-extensions` does (custom packets through the
   client's own message handler registration, fragmentation, Lua bridge) and is the better source.
2. WarcraftXL's loading model (executable rewrite or `d3d9` proxy, interface-signature byte patch, no
   runtime hash gate) contradicts Ulduar rules that are already proven in practice (exact-hash gate,
   unmodified executable, no bypass as an implicit requirement: ADR-002/004, `19_FRAMEXML_STRATEGY.md`).
3. Ulduar's DLL has no hooks yet, so adopting a hook engine is still open. When the first hook is authorized,
   MinHook (BSD-2) is the default candidate; it can be vendored without GPL implications.
4. **C is rejected by default**: two detour engines, two loaders and two identity policies in one process
   without any proof of hook-order or shutdown safety.

B stays possible later. Re-evaluate when **all** hold: WarcraftXL verifies the running executable (hash) at
runtime, supports loading without a PE rewrite or proxy DLL, Ulduar accepts GPL-3 for the client, and the
features Ulduar needs from it (outline, modern assets) are worth more than the migration.

## 4. What Ulduar takes from each project

| Source | Take | How |
| --- | --- | --- |
| TSWoW `misc/client-extensions` (MIT) | custom opcode transport design (handler registration detour at 0x006B0B80, `SendPacket` 0x006B0B50, opcodes 0x102 S→C / 0x51F C→S, fragmentation) | Windows stage 3 evidence against the exact hash, then port with MIT attribution; server side is Ulduar/AzerothCore code |
| WarcraftXL (GPL-3) | offsets and hook-point names as **reverse-engineering evidence** to cross-check Ulduar's own findings; unit-outline technique (mask RT + edge pass) | re-implement independently, or port only after the client repository adopts GPL-3 |
| awesome_wotlk (GPL-3) | nameplate event/API shape, nameplate distance, FOV CVar, clipboard fix | re-implement against evidence; never its loader or startup writes |

## 5. Migration design if B is ever chosen (no rewrite now)

Keep (portable, tested, framework-independent):
- `Session` (ULDCP1 handshake, nonce, generation), `ClientWire.h` (shared with the server module);
- `VariantCache` (atomic snapshots, tombstones, leases);
- presentation models (`Presentation.h`, `PresentationGroups.h`), capability mask semantics;
- `BuildIdentity` (exact-hash policy) — as a precondition WarcraftXL would have to satisfy.

Replace only:
- loader (development loader → WarcraftXL loading, if it gains a hash gate);
- hook infrastructure (future MinHook usage → WarcraftXL registry);
- offsets/bindings (Ulduar evidence files → `wxl::offsets`, each still tied to review evidence);
- event dispatch (host lifecycle seams → `EventScript` events).

The seam already exists: `NativeHost` / `NativeIngress` isolate every native call behind interfaces, and all
tests run without a game process. Capabilities stay 0 until proven end to end under either foundation.
