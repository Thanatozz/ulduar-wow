# R.1 client precedence evidence

Access/review date: 2026-09-20. SOURCE_ONLY. CLIENT_TABLE_GATE=PARTIAL.

Scope is the A.10 selected 18-archive enUS diagnostic package, executable build 12340.
Backup-enUS remains excluded. No executable, extractor or editor was launched.

## Evidence classes

| Class | Source | Applicable version / authority | Result and limitation |
| --- | --- | --- | --- |
| A: native client source or version-specific local documentation | Existing project documents, including `docs/architecture/22_MPQ_PATCH_STRATEGY.md` | No native build-12340 loader implementation established | The project previously required precedence verification; a package inventory does not prove loading order. |
| B: already-cited client research | [WotLK Modding Wiki: Client, File Overriding](https://wotlkdev.github.io/wiki/theory/client) | Community client research; WotLK and English clients; no explicit build 12340 or executable fingerprint | Describes locale numeric patches in ascending suffix order, followed by locale alphabetic patches; English base groups have higher priority. Covers locale and numbered patches and alphabetic A-Z patches. It does not expressly place unnumbered `patch-enUS.MPQ` relative to numbered patches, or establish applicability to this exact executable. |
| C: extractor corroboration | `src/tools/map_extractor/System.cpp`, `LoadLocaleMPQFiles` | AzerothCore extraction tool source in the pinned checkout | Opens locale base, unnumbered locale patch, then numbered patches 2..9. This supplies a tool convention for the missing unnumbered case, not native-client proof. |
| D: editor corroboration | `C:/WoWProjecto/M2 Editor/docs/client-assets.md`, `src/client/config.py` | Local editor policy; documentation explicitly cites source B | Uses enUS base-overrides and unnumbered before numbered before letter patches. Its own caveat allows modified-client/manual ordering. |
| D: counterexample to tool unanimity | `C:/WoWProjecto/references/mod-classless-wildcard/client-patch/lib/clientfs.py` | External tool, reference only | Its locale/base policy is not interchangeable with the selected enUS editor policy. It cannot establish native precedence. |

Source B was inspected only for archive precedence, along with its home/repository provenance links.
No downloaded binary/tool was executed. The external page is not a hash-pinned native disassembly or a
Blizzard statement. Its publication/revision date was not established; the access date above is not a
publication date. The project's citation existed before R.1, so this external consultation stays within
the explicitly permitted research boundary.

## Application to the six selected tables

The A.9 member inventory provides byte-level archive membership, not just guessed names. All six relevant
tables occur only in the inspected locale base/patch containers. The selected base MPQs, including patch-U,
have no member for these six probed names. Thus disputed base-vs-locale priority does not itself select a
different copy here. The remaining native rule needed is local to the four contributing locale archives.

Under the documented numeric-patch rule **and** the secondary tools' unnumbered-before-numbered convention,
Spell, SpellRange, SpellVisual, SpellIcon and SkillLineAbility select patch-enUS-3. SpellCastTimes selects
patch-enUS-2 because patch-enUS-3 has no member for that name. These are unchanged A.10 selections.

This is an explicitly conditional inference. Tool agreement does not fill the native-evidence gap about
unnumbered patches. All six records therefore remain CONDITIONAL in
[the R.1 table revision](ULDuar_R1_EFFECTIVE_CLIENT_TABLES.json). Their hashes and row counts are established;
their status has not been promoted to EFFECTIVE_CLIENT_STATIC.

## Minimum missing input

A version-applicable native loading reference that covers unnumbered `patch-enUS.MPQ` versus numbered
locale patches for the selected build-12340 package would close this specific gap. It may be existing
source/disassembly documentation with provenance; runtime execution is not a prerequisite of this phase.
Do not repeat broad client/modding research or treat editor output as that missing reference.

No new patch, DBC selection override or client configuration was created to force the conditional order.
