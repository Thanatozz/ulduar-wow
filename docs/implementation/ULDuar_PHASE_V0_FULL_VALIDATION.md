# ULDuar Phase V.0 — pre-carrier baseline validation

Evidence collected 2026-09-20/21. Validation workspace: `C:/WoWProjecto/validation/V0`.

## 1. Executive result

The selected core and abilities module configured, compiled and linked in a fresh Visual Studio build. All 39 Forge tests passed. The full GoogleTest inventory contains 11,446 cases: 5,959 passed, zero failed and 5,487 skipped, including one disabled ASan-only diagnostic. Both servers started against disposable database copies. The cloned build-12340 client authenticated, entered the world, loaded UlduarAbilities/Protocol2, opened the panel and cast native Frost Armor; its probe captured no Lua errors.

The six DBC round trips and isolated mutation fixture passed. StormLib created, listed and read back a validation MPQ byte-exactly. Read-only inspection of the installed world found no Spell identity/reference conflict in 90000..90023 within the audited fields.

`PHASE_V0_STATUS = COMPLETE`; `PRE_ARTIFACT_VALIDATION_GATE = PASS` for the selected baseline and documented coverage limits. The native precedence experiment succeeded. This is not final artifact-authoring approval: R.1 reservation/maintainer authority remains outstanding.

No final carrier rows were authored. No IDs were reserved. R.1 maintainer/historical ownership authority remains separate from this technical baseline.

## 2. Authorization, isolation and source scope

V.0 explicitly authorized configure/build/tests, live read-only database inspection, isolated database imports, staging DBC/MPQ fixtures and cloned-client tests. The earlier source-only restrictions do not apply to these V.0 operations.

Original project: `C:/WoWProjecto/ulduar-wow`; original build: `C:/WoWProjecto/ulduar-build`; original client: `C:/WoWProjecto/Client`. All generated executable, database, DBC, MPQ and client artifacts are under `validation/V0`, including `baseline`, `build`, `logs`, `database`, `dbc`, `mpq`, `client`, `tests`, `reports`, `hashes` and `configs`.

The core HEAD is `d7ce67dc1800f092bac98aad680ece1c201b89a0`; module HEAD is `5f51c5e012b153b1edae00af2b0e11a9d45ba62d`. Existing dirty/untracked module files and the five modified Spell/Unit files are inputs, not V.0 changes. The pre-validation snapshot records their individual hashes, repository status and 24,891 original-build file metadata records. It also records client executable, archive, addon, server DBC and configuration hashes without database passwords.

The build uses the A.10 selected release: `mod-ulduar-abilities` enabled; citybuilder, editor, density-test and wave-survival disabled. V.0 does not claim validation of those excluded modules. Neither R.1 nor older reports were edited.

## 3. Source consistency and configure

Reviewed the modified Spell.cpp/.h, SpellEffects.cpp, Unit.cpp/.h and abilities module registration/build inputs. No unresolved merge markers or duplicate Ulduar registration definitions were found. Actual compilation/linkage resolved declarations, includes and ODR dependencies for the selected targets. No old TrinityCore/Ascension implementation was added. The three proposed runtime seams remain unimplemented.

Fresh build directory: `validation/V0/build`. CMake 4.4.3; generator Visual Studio 17 2022; x64; MSVC 19.44.35228.0 (toolset directory 14.44.35207); SDK 10.0.26100.0; RelWithDebInfo. Dependencies: Boost 1.81.0, MySQL 8.4 client and OpenSSL 3.5.8. `BUILD_TESTING=ON`, `SCRIPTS=static`, `MODULES=static`, `WITH_WARNINGS=ON`, default PCH enabled. Initial configure succeeded in 28.302 seconds. Exact command and retries are in the build audit.

The pinned GoogleTest configure dependency was downloaded into staging. Windows pthread feature probes were negative and the Windows Threads package was subsequently found; those probes were not configure failures.

## 4. Build, demonstrated defects and warning review

Built `authserver`, `worldserver` and `unit_tests`; abilities linked through `modules.lib`. Outputs and SHA-256 hashes are in the build audit. `_CL_=/MP1` and MSBuild parallelism 2 bounded compiler process concurrency. Tools were configured but extractor/tool targets were not claimed as built.

Initial build took 1,673.787 seconds. Auth/world linked, but tests failed with LNK2038 runtime-library mismatches and duplicate CRT symbols: GoogleTest used MT while the core used MD. Setting `gtest_force_shared_crt=ON` in the isolated configure fixed this; the three-target retry completed successfully in 36.657 seconds. This is a validation configuration requirement, not a gameplay source change.

CTest then exposed an existing multi-configuration registration defect: its command referenced `build/src/test/unit_tests`, while Visual Studio emitted `build/bin/RelWithDebInfo/unit_tests.exe`. The only intentional existing source/build-file edit is `src/test/CMakeLists.txt`, changing the command to `$<TARGET_FILE:unit_tests>`. After configure regeneration, both the Forge-filtered and full CTest runs passed.

| Severity | Evidence | Disposition |
| --- | --- | --- |
| HIGH | Existing NetworkThread socket descriptor narrowing to int, C4244 | Retained as a portability risk; V.0 authentication/world connection succeeded. No unrelated core rewrite. |
| MEDIUM | Other existing numeric narrowing, C4244 | Logged; no demonstrated Ulduar defect. |
| LOW | GCC diagnostic pragmas ignored by MSVC in test mocks, C4068 | Non-blocking for execution. |
| MEDIUM | GCC coverage switches ignored by MSVC, D9002 | No instrumentation/coverage percentage claimed. |
| EXTERNAL | CMake CMP0153/CMP0167 and dependency compatibility deprecations | Retained with complete configure logs. |
| Resolved blocker | MT/MD mismatch during first test link | Isolated shared-CRT configure flag and successful rebuild. |
| Resolved blocker | CTest executable path | Target-file generator expression and successful CTest reruns. |

No abilities-module-specific compiler warning was found in the reviewed warning inventory. All raw warnings and initial failures remain available; they were not hidden by the successful retry. Required C++ and SQL codestyle linters returned zero. The SQL linter internally fetched `origin master`; no checkout, commit or push occurred.

## 5. Test inventory and execution

| Scope | Total | PASS | FAIL | SKIP |
| --- | ---: | ---: | ---: | ---: |
| UlduarForgePhaseA | 21 | 21 | 0 | 0 |
| UlduarForgePhaseA6 | 15 | 15 | 0 | 0 |
| UlduarForgeImpactTargetTest | 3 | 3 | 0 | 0 |
| Full GoogleTest inventory | 11,446 | 5,959 | 0 | 5,487 |

The first broad `Ulduar*` run also selected 22 existing native Ulduar vehicle-scale tests: all 61 selected cases passed. The subsequent precise `UlduarForge*` CTest run passed all 39 module cases. These reruns are not added together as unique tests.

The full suite has 5,486 skipped parameter combinations in SpellProcFullCoverageTest because the tested property is not applicable, plus `FlatMultimapAuraPattern.DISABLED_StaleIteratorAfterCascade_AsanOnly`. No Forge case was skipped. Full CTest wall duration was 4.664 seconds (CTest reported approximately 3.59 seconds; GoogleTest case timing is a different measurement). The JSON companion records every name, suite, status, duration, failure output and skip output.

### Integration coverage and limits

Identity, revision, binding uniqueness, owner/slot rejection, generation changes, no-binding lookup, stale snapshot retention, unsupported/pending carrier rejection and Impact composition/recursion restrictions were exercised by model/contract/catalog tests. The three target tests use in-process AC Player/Creature/SpellInfo fixtures and test primary exclusion plus friendly/hostile secondary legality.

These are not end-to-end bound Forge casts. No live manager-binding API was added to force those paths. No live proof is claimed for Holy Light 635 as a bound Forge cast, invalid binding packet rejection, projectile snapshot retention, logout registry cleanup or live Impact propagation. Those remain `NOT_TESTABLE_WITH_CURRENT_DATA` in this client exercise. The native Frost Armor cast is evidence of the unbound baseline, not a substitute for those tests. No additional Lua test suite or live-stack bot suite was run.

## 6. Database baseline and namespace evidence

Read-only inspection identified MySQL 8.4.11 on 127.0.0.1:3306 with `acore_auth`, `acore_characters` and `acore_world`. The audit records `updates`, `updates_include`, schema/table inventories and module update entries. Existing exports were made using transaction-consistent mysqldump without table locks and stored only under `V0/database`.

The configured original account could not create validation schemas (error 1044). Instead, V.0 initialized a separate MySQL instance at 127.0.0.1:3308 with data under `V0/database/mysql-data`. Existing dumps were imported into `ulduar_v0_20260920_auth`, `_characters` and `_world`. All three imports succeeded. The validation realmlist, test account, character and normal server housekeeping only affected those disposable schemas. Original credentials were read in memory for authorized inspection/export and were not written to reports or copied into staging server configs.

The world audit examined numeric fields in 70 relevant tables, including spell_*, conditions, ranks, trainers, scripts/SmartAI, item/creature spell fields and gameobject data, plus aura-string references. There were 349 numeric hits in the interval; semantic classification found costs, cooldowns/durations and other non-Spell values, not Spell identity/reference conflicts. Examples include spell_dbc effect periods/base points, SmartAI timers and gameobject autoclose durations. Queries completed without errors; aura-string interval screens returned no matches.

The isolated MySQL import log includes two redo-log capacity/checkpointer warnings while loading the dump. Imports and subsequent server/client operations completed; this is an ENVIRONMENT_ONLY staging sizing warning, not silent import failure. No production MySQL setting was changed.

`INSTALLED_WORLD_90000_90023 = EMPTY` for this inspected schema and the documented field interpretation. This is not a claim about arbitrary historical releases or hidden/computed ownership. It neither reserves the interval nor replaces the R.1 maintainer declaration. No experimental migration was needed: existing dump import and server schema loading were exercised; new migration/rollback behavior was not tested.

## 7. Server data, DBC and MPQ tooling

The server used the existing `ulduar-build/bin/RelWithDebInfo/Data` directory read-only. All 20 reviewed DBC inputs, including the six primary tables and visual dependencies, matched their expected hashes.

The existing M2 Editor WDBC parser/serializer round-tripped copied Spell (49,839 rows), SpellRange (64), SpellCastTimes (70), SpellVisual (9,406), SpellIcon (3,226) and SkillLineAbility (10,219). Header dimensions, record sizes, IDs, reference rows, string integrity and semantic equality were checked. All six outputs were also binary-identical. No semantic normalization diff was needed.

The mutation fixture added SpellRange ID 188 and changed a copied row's field 3 to 12.5. Reparse found the new row/value and preserved all unaffected records. This is a private SpellRange fixture, not a Spell carrier or production allocation. It was not installed into the canonical client/server.

StormLib 9.40 Unicode x64 created `V0/mpq/V0-Toolchain-Only.mpq`, packed `DBFilesClient\\TestValidationFile.txt` and the private SpellRange fixture, closed/reopened/listed/read them, and verified member sizes and bytes/SHA-256. Tool sources and DLL were hashed before use. No editor tool source was changed.

## 8. Server startup and diagnostic observations

Fresh auth/world binaries ran with V0 configs, ports 3726/8087 on loopback and the disposable MySQL instance. Automatic database updates/setup were disabled. Worldserver reached its ready line and reported `[UlduarAbilities] Loaded. Definitions: 30. Enabled: true. Mobile: unavailable.` DBC and module startup succeeded.

World initialization reported 1 minute 42 seconds. This excludes external build/configure time and is not a calibrated benchmark. A sampled world working set was about 1.77 GB shortly after startup; later working sets varied. Module initialization and client login were not independently timed.

Two missing TaxiFlightSpeed configuration warnings used the default 32. During world operation, three MoveSpline velocity checks were logged for creature entries 30541, 30544 and 31039. These are retained as existing-world movement diagnostics requiring separate triage; no causal link to the abilities changes or observed baseline failure was established. They do not justify rewriting unrelated core behavior in V.0.

RelWithDebInfo execution was used. ASan was not configured, and the ASan-only disabled case was not executed. No claim of sanitizer cleanliness or exhaustive gameplay correctness is made.

Cleanup limitation: the helper requested `server shutdown 0`, which this core rejected with `Incorrect values` because it requires a positive delay. After its 15-second wait the helper terminated only its owned world/auth processes; the user had already logged out. Their absence was independently confirmed, but graceful server shutdown and exact server exit codes were not established. This ENVIRONMENT_ONLY helper defect does not invalidate the recorded successful startup. The separate validation MySQL instance received mysqladmin shutdown and logged normal shutdown/Shutdown complete; the original MySQL service was not stopped.

## 9. Client, addon and native baseline

A physical client clone contains the 18 selected A.10 archives; backup-enUS is excluded. No hardlinks/junctions expose canonical archives to fixture writes. Original Wow.exe build 12340 is used; locale enUS. The 21 installed UlduarAbilities addon files match their canonical source hashes.

A staging-only `AAA_V0Probe` addon records build/locale, Protocol2 readiness, visible panel/microbutton, errors and native cast events. The user operated the client after requesting manual control; automation of mouse/keyboard stopped at that request. A disposable account authenticated and character `Vobaseline` entered `Ulduar V0 Disposable`.

The saved baseline records confirm `ProtocolVersion=2`, ready=true, addon loaded, panel shown, microbutton shown and zero captured Lua errors. Frost Armor generated `UNIT_SPELLCAST_SUCCEEDED`; the user reported normal behavior. `/logout` saved the evidence. The probe opened the panel through its existing API; a manual microbutton click was not separately tested. This is a bounded successful startup/native-cast observation, not a claim that every existing ability feature was tested.

## 10. Native locale MPQ precedence experiment

The cloned client was closed before archive edits. Byte-identical backups of its unnumbered, -2 and -3 locale patch archives are under `V0/baseline/pre-precedence`. In those clone archives only, the existing Spell 635 enUS name was changed respectively to `V0_UNNUMBERED`, `V0_TWO` and `V0_THREE`. Existing SpellCastTimes row 20 was changed to 1111 ms in the unnumbered archive and 2222 ms in -2. The -3 archive still has no SpellCastTimes member. No Spell row or ID was added.

Each mutated archive was closed/reopened and its fixture member verified byte-exact. This is transport/toolchain test data, not a custom carrier artifact. The canonical client and server DBCs remain untouched. The requested user observation is the probe's Spell 635 name and cast time after a fresh cloned-client launch; no cast of that spell is required.

Round 1 observed `V0_THREE / 2500ms`: the Spell selection was established, but the duration marker had mistakenly retained minimum=2500. This was a FIXTURE_DEFECT, not a demonstrated engine/serializer failure. The second fixture set base and minimum consistently to 1111 in the unnumbered archive and 2222 in -2. After another fresh launch, the user reported `V0_THREE / 2222ms`, Protocol2 ready and zero Lua errors. SavedVariables independently confirm those values, build 12340 and enUS.

`NATIVE_LOCALE_PATCH_PRECEDENCE = PROVEN_BY_EXPERIMENT`; `CLIENT_TABLE_GATE = PASS_RUNTIME_EVIDENCE`. Spell's -3 marker wins over the two alternatives; the -2 CastTimes marker wins when that member is absent from -3. The corrected fixture is specified in `client_precedence_fixture_round2.json`; raw first- and second-round variables were retained. The experiment concerns only the selected enUS build-12340 package; arbitrary patch letters, other locales and other client versions are outside its scope.

The six original inputs are pinned in `ULDuar_V0_EFFECTIVE_CLIENT_TABLES.json`: Spell, SpellRange, SpellVisual, SpellIcon and SkillLineAbility from patch-enUS-3; SpellCastTimes from patch-enUS-2. Original member hashes, row counts and ID fingerprints are retained. Spell and CastTimes have direct instrumented observations; applying the observed archive order to the other four tables is an inference combined with the existing member inventory, not four additional runtime read traces. None of the test-mutated hashes is adopted as a release input.

After the user closed the clone, its three modified MPQs were restored from verified backups and checked against the unchanged canonical archives. Test fixture DBCs/observations remain in staging as evidence. Repeated login/world entry/logout during both experiments also exercised reconnection of the disposable player.

## 11. Preservation and evidence files

Hash comparison of 10,074 protected originals found exactly one change: the CTest registration correction in `src/test/CMakeLists.txt`. No originals were missing; editor tool sources were unchanged; all 24,891 original-build file metadata entries were unchanged. No C++, canonical Lua, original SQL, DBC, MPQ, client or config file changed. Results, pre/post hashes and the exact diff are recorded in `ULDuar_V0_FILES_CHANGED.json`; stage-only client probe/config/fixtures and disposable SQL operations are explicitly separate.

Primary audit companions under `docs/audits`:

- `ULDuar_V0_PRE_VALIDATION_SNAPSHOT.json`
- `ULDuar_V0_BUILD_RESULT.json`
- `ULDuar_V0_TEST_RESULTS.json`
- `ULDuar_V0_DATABASE_BASELINE.json`
- `ULDuar_V0_DBC_ROUNDTRIP.json`
- `ULDuar_V0_MPQ_VALIDATION.json`
- `ULDuar_V0_CLIENT_BASELINE.json`
- `ULDuar_V0_CLIENT_BASELINE.md`
- `ULDuar_V0_SERVER_STARTUP.md`
- `ULDuar_V0_CLIENT_PRECEDENCE_TEST.md`
- `ULDuar_V0_CLIENT_PRECEDENCE_RESULT.json`
- `ULDuar_V0_EFFECTIVE_CLIENT_TABLES.json`
- `ULDuar_V0_CLEANUP.json`
- `ULDuar_V0_FINAL_GATE.json`
- `ULDuar_V0_EVIDENCE_FILE_MANIFEST.json`
- `ULDuar_V0_FILES_CHANGED.json`

Raw logs and GoogleTest output remain under `V0/logs` and `V0/tests`. Database dumps remain private staging files; reports contain identities/hashes/update metadata, not account credentials.

## 12. Gate and exact remaining work

Configure/build/module linkage, relevant tests, server DBC load, DBC serialization, MPQ creation/read and installed interval inspection have successful evidence. Initial link and test-discovery failures were corrected and rerun.

The native precedence observation is recorded, clone archive restoration is verified, and shutdown state is recorded in `ULDuar_V0_CLEANUP.json`. No unresolved BLOCKER_PRE_ARTIFACT was demonstrated in the V.0 baseline. The retained core warnings and world movement diagnostics are documented limitations, not a claim of exhaustive defect freedom. R.1 historical/maintainer authorization remains an external project-governance prerequisite; V.0 does not satisfy or waive it.

No carrier authoring starts automatically. The next safe action after this baseline is closed is to finish R.1 using the V.0 technical evidence and the required historical authority; only then can a separately authorized isolated carrier-artifact phase begin.
