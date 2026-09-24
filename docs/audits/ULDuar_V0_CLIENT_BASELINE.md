# V.0 client/addon baseline

`ADDON_BASELINE = PASS`; `CLIENT_SERVER_BASELINE = PASS` for the bounded scenario below.

Original client files were copied physically to `C:/WoWProjecto/validation/V0/client`; 18 selected archives,
enUS, Wow.exe build 12340. The canonical installation was not patched.

The user authenticated to **Ulduar V0 Disposable**, entered the world as `Vobaseline`, observed the abilities panel opening and successfully cast Frost Armor. The staging probe recorded:

| Observation | Result |
| --- | --- |
| Client build / locale | 12340 / enUS |
| Addon loaded | Yes |
| Protocol version / readiness | 2 / true |
| Microbutton exists / shown | true / 1 |
| Panel shown | 1 |
| Captured Lua errors | 0 |
| Native cast event | UNIT_SPELLCAST_SUCCEEDED: Frost Armor |
| Logout | Saved probe variables |

Baseline variables and SHA-256 are preserved in `ULDuar_V0_CLIENT_BASELINE.json` and
`validation/V0/baseline/pre-precedence/AAA_V0Probe.baseline.lua`. The 21 original installed-addon files match
canonical addon sources. The additional probe is stage-only; it invokes the existing panel-open API and
does not implement a new Forge UI. A manual microbutton click was not separately observed.

The user's request to control the client manually was honored. Remaining client experiment observations
were requested from the user; mouse/keyboard automation did not resume.

Successful native casting is not evidence that pending custom carriers or live Forge binding paths work.
No final custom spell was taught, created or cast. Zero errors is scoped to the captured session, not an
exhaustive addon regression test. Repeated client entry for the precedence experiment also supplies a
reconnect observation, recorded separately from the initial baseline.
