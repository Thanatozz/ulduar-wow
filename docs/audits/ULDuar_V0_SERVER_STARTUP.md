# V.0 server startup evidence

Fresh binaries: `C:/WoWProjecto/validation/V0/build/bin/RelWithDebInfo`.
Configs: `validation/V0/configs`; database copies on loopback port 3308.
Auth port 3726; world port 8087. Automatic update/setup settings were disabled.
The original server data directory was loaded without modification.

`SERVER_STARTUP = PASS`.

Worldserver reached:

```text
WORLD: World Initialized In 1 Minutes 42 Seconds
AzerothCore rev. d7ce67dc1800+ ... (Win64, RelWithDebInfo, Static) (worldserver-daemon) ready...
[UlduarAbilities] Loaded. Definitions: 30. Enabled: true. Mobile: unavailable.
```

The exact unabridged output is in `V0/logs/worldserver-console.log`. Auth console logging was empty during the observation; auth success is established by its listening socket and the user's actual test-account login/world entry, not an invented auth-ready log line.

The test account and player existed only in disposable schemas. Production tables were not migrated or used for server writes. Importing the three pre-existing database dumps succeeded; no new migration was authored.

## Diagnostics retained

- Two missing TaxiFlightSpeed config messages; default 32 retained.
- Three MoveSplineInitArgs velocity checks for existing creature entries 30541, 30544, 31039 during operation. MEDIUM existing-world diagnostics; causality to Ulduar is unestablished. No observed client/module startup regression.
- No duplicate Ulduar registration, missing ability definition or module crash was found in the reviewed startup log.
- World initialization: 102 seconds reported by the server. Working-set sample after startup approximately 1.77 GB; subsequent samples vary and are not performance benchmarks.
- RelWithDebInfo used; ASan and a separate Debug rebuild not run. Module-only initialization/client login timings not independently measured.

This is baseline startup/native-operation evidence. Live bound-Forge invalid binding, logout registry cleanup, delayed snapshot and Impact paths were not exercised. Pure/in-process test results are recorded separately.

Final shutdown ownership is recorded in `ULDuar_V0_CLEANUP.json`. The helper's `server shutdown 0` command
was rejected because this core requires a positive delay. After its timeout it terminated its owned world
and auth processes; they are no longer running. The immediate polls in `server_processes.json` retained
null exit codes, so no clean exit code or graceful server shutdown is claimed. The user had already logged
out. Isolated MySQL was shut down normally with mysqladmin; its log confirms completion. Original MySQL
was not stopped. This is a documented validation-helper limitation, not a startup failure.
