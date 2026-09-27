# In-game bug report template

Copy this block for each bug found on the local server. Keep one report per behavior.

```
Feature:
Commit:                 (ulduar-wow / mod-ulduar-abilities / ulduar-client-patch hashes)
Server build:           (Debug/Release, date)
Config:                 (UlduarAbilities.* keys changed from the .dist defaults; Debug = 1?)
Ability:
Lab modifiers:          (output of .ua lab list <ability>)
Steps:
  1.
  2.
Expected:
Actual:
Relevant log:           ([UlduarPeriodic] / [UlduarAbilities] lines around the event)
Carrier status before:  (.list auras on the target, .ua lab carriers)
Carrier status after:
Reproducibility:        (always / N of M / once)
Regression test added:  (test name, or "none: needs in-game only")
Fix commit:
Retest:                 (PASS / FAIL, date, commit)
```

Status words used in the docs: PURE TESTS, SYNTAX CHECKED, LOCAL BUILD PASS, IN-GAME PASS, IN-GAME FAIL,
NOT TESTED (see `docs/architecture/ULDuar_ABILITY_RUNTIME.md`, "Validation states").
