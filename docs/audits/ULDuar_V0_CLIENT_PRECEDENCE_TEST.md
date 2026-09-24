# V.0 native enUS locale patch experiment

Status: **PROVEN_BY_EXPERIMENT** for the selected package. `CLIENT_TABLE_GATE = PASS_RUNTIME_EVIDENCE`.
Round 1 established the Spell selection. Round 2 supplied the corrected cast-time observation; the first
duration result alone was insufficient.

## Environment and isolation

- Native Wow.exe build 12340, enUS; physical copy at `validation/V0/client`.
- Same 18 selected A.10 archives; backup-enUS excluded. No additional custom test patch name was mounted.
- Original three locale MPQs were hashed, copied into stage backups and verified before modification.
- Only existing Spell 635's enUS display name and existing SpellCastTimes row 20 were changed in the clone.
- No carrier or other Spell row was added. The server retained original data, and no cast of the marked heal was needed.
- The user launched/operated the cloned client manually. `GetSpellInfo(635)` was observed through the stage-only probe.

## Round 1

| Archive | Spell 635 name | CastTimes row 20: base / minimum |
| --- | --- | --- |
| patch-enUS.MPQ | V0_UNNUMBERED | 1111 / 2500 |
| patch-enUS-2.MPQ | V0_TWO | 2222 / 2500 |
| patch-enUS-3.MPQ | V0_THREE | Member absent, unchanged |

User reported `V0_THREE / 2500ms / Protocol2 ready=true / errors=0`.
SavedVariables independently contain that result, build 12340/enUS and successful panel/addon state.

This proves the -3 Spell member wins over the other two marked copies in this package. It does not prove
the CastTimes selection: the diagnostic fixture mistakenly retained minimum=2500. Classification:
**FIXTURE_DEFECT**, not serializer corruption or a demonstrated contradiction of the proposed archive order.

Evidence: `V0/reports/client_precedence_fixture.json` and
`V0/baseline/pre-precedence/AAA_V0Probe.round1.lua`.

## Round 2

The clone was closed. The minimum was corrected to match the diagnostic base: 1111/1111 in the unnumbered
archive and 2222/2222 in -2. The -3 Spell marker and absence of its CastTimes member remain unchanged.
Reopening each modified archive reproduced the fixture bytes exactly.

Evidence: `V0/reports/client_precedence_fixture_round2.json`.
The user observed **V0_THREE / 2222 ms / Protocol2 ready / zero Lua errors**. SavedVariables independently
record the same values with build 12340/enUS. They are preserved in
`V0/baseline/pre-precedence/AAA_V0Probe.round2.lua`; its SHA-256 is in
`ULDuar_V0_CLIENT_PRECEDENCE_RESULT.json`.

## Scope of a successful result

`V0_THREE / 2222ms` establishes -3 over the other marked Spell copies and -2 over the unnumbered
CastTimes copy for these selected archives. Applying that rule to the other four table candidates would
combine runtime ordering evidence with their existing member/hash inventory; it would not be six separate
instrumented table-read observations. No generalization to arbitrary custom patch letters, other locales
or other executable versions is intended.

Original MPQs remain unchanged. After the client was closed, the three cloned fixture archives were
restored from verified backups and compared with canonical archive hashes. Backups and test DBC files
remain staging evidence only. `ULDuar_V0_EFFECTIVE_CLIENT_TABLES.json` pins the six original member hashes
using this evidence; no test-mutated member is a release input. No IDs were reserved and no carrier was created.
