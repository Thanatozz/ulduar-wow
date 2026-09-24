# ULDuar Phase A.10 — Release closure and namespace gate

Date: 2026-09-20. SOURCE_ONLY. Final bounded evidence review before reservation/artifact authoring.

## 1. Executive decision

PHASE_A10_STATUS: COMPLETE for the requested read-only decisions and reports.
RELEASE_GATE: PARTIAL. No deployment/runtime approval.

**CARRIER_SPEC_READY_NAMESPACE_BLOCKED.** The four diagnostic specifications are statically serializable under
A.10's revised definition. All four remain RUNTIME_READY=NO and CLIENT_VALIDATED=NO. No carrier row was emitted.

| Gate | Result |
| --- | --- |
| TARGET_RELEASE_STATUS | PARTIAL |
| V1_SUPPORTED_LOCALE | enUS |
| CLIENT_ARCHIVE_MEMBERSHIP | RESOLVED for the explicitly selected diagnostic candidate |
| EFFECTIVE_CLIENT_TABLES | CONDITIONAL |
| EFFECTIVE_WORLD_DATA | UNAVAILABLE; NO_OFFLINE_EFFECTIVE_WORLD_SNAPSHOT |
| NAMESPACE_MODEL | CANONICAL_RELEASE_MANIFEST |
| NAMESPACE_STATUS | NAMESPACE_CANDIDATE_ONLY |
| ATTRIBUTE_SERIALIZATION | READY; actual behavior remains unverified |
| Four visual references | ARTIFACT_SERIALIZABLE / RUNTIME_UNVERIFIED |
| SPELLBOOK_ARTIFACT_GATE | NON_BLOCKING_RUNTIME_GATE |
| Three source designs | FROZEN_DESIGN_PROPOSAL; not implemented |

Candidate Spell block **90000..90023** is a documented negative-screen candidate, not a reservation. It covers the
future six copies per family, not unrestricted lease churn. It cannot be used to generate rows or grant spells yet.

## 2. Scope and preservation

Read A.9 and all of its Markdown/JSON companions, A.8/A.7/A.6 reports and the custom-ID policy. The new decisions
supersede only the gates explicitly changed by the A.10 request; previous reports remain unchanged.

Fresh hashes were captured before report authoring for 10,043 protected existing files, including all A.9 scope
and previous reports. There was no A.9-to-A.10 drift in that inherited scope, and the inspected A.8 source/data
hashes still match. Newly consulted local reference files have a separate supplemental hash inventory.
Final byte comparisons and exact new files are in [the preservation audit](../audits/ULDuar_A10_PRESERVATION_RESULT.json).
This is an enumerated scope, not a claim about every unrelated file on the machine.

Final comparison: all 10,051 protected files are byte-identical, totaling 18,400,917,575 bytes. Eleven new
documentation/audit files were created; zero existing files changed and zero removed. MODIFIED_CPP=0,
MODIFIED_LUA=0, MODIFIED_SQL=0, MODIFIED_DBC=0, MODIFIED_MPQ=0, MODIFIED_CLIENT=0, MODIFIED_CONFIG=0.
Static document inspection confirmed readable JSON, all 33 focused attribute entries and resolved local links.
No project test was executed by these documentation checks.

Only read-only source/data inspection and documentation/JSON audit writes were used. No build system, project
test, compiler, generated project binary, server, client, patcher or database was run. SQL was text input only.
No previous report, C++, Lua, config, SQL, DBC, MPQ or client file was intentionally changed. No commit/push.

## 3. Explicit candidate release membership

[The membership manifest](../audits/ULDuar_A10_RELEASE_MEMBERSHIP.json) selects exact components and records
evidence for every IN_RELEASE decision. This is a prospective diagnostic package selection, not a claim that the
current local executable/server/DB already obeys it. The symbolic name remains ULDuar-V1-PREVIEW-CANDIDATE;
releaseId is null. No historical release identity is manufactured.

Core d7ce67dc1800f092bac98aad680ece1c201b89a0 plus the five hashed local Spell/Unit changes and the current abilities
module source are selected. The module's commit 5f51c5e012b153b1edae00af2b0e11a9d45ba62d alone is insufficient:
its untracked implementation is included in the preserved module fingerprint. The manifest carries both fingerprints.

| Component | Membership | Concrete evidence / selection scope |
| --- | --- | --- |
| C:/WoWProjecto/Client/Wow.exe | IN_RELEASE | User's candidate; build12340 version resource, pinned A.9 hash, canonical addon installation location |
| Base/expansion/lichking/locale/numbered MPQs | IN_RELEASE | Actual named-client archive/member/hash inventory; extractor lists and dependency graph support package selection, not native priority |
| patch-U | IN_RELEASE | Actual installed hash matches installation receipt and build-d2f8dda3 manifest; asset-only membership |
| backup-enUS and other backup/staging packages | OUT_OF_RELEASE | Project MPQ strategy explicitly excludes backups/work dirs from release allowlists |
| B: build RelWithDebInfo/Data/dbc | IN_RELEASE | Primary local data corpus explicitly named in talent-conversion architecture; six tables match the inspected candidate members |
| UlduarAbilities addon | IN_RELEASE | Module README names canonical addon; addon README names installed client path; 21 files byte-identical |
| Abilities module | IN_RELEASE | Primary module specified by task; A.6/A.9 one-slot source contracts |
| Citybuilder/editor/density-test/wave-survival | OUT_OF_RELEASE | Explicit selection of the bounded abilities diagnostic slice; no assumption of required membership from directory presence or historical logs |
| Repository base/archive/released SQL source closure | IN_RELEASE | Exact hashed source inputs and updater model, not an assertion of installed rows |
| Current two pending abilities SQL files | IN_RELEASE | World starter bindings and character modifiers are explicitly selected by filename/hash; future pending files are not implicitly included |
| Custom SQL | OUT_OF_RELEASE | No existing custom SQL payload selected; unknown installed custom state remains deployment evidence |
| F/M generated visual DBC outputs | OUT_OF_RELEASE | Historical editor outputs are absent from selected patch-U DBC membership; retain historical tombstones |
| Old UlduarAbilities addon | OUT_OF_RELEASE | Canonical source/install locations are explicit; old source is historical evidence, not a release payload |
| Ascension/TrinityCore/E/Work/other datasets | REFERENCE_ONLY | User's exclusions; no imported IDs or occupancy authority |

Excluding four auxiliary modules is a candidate-release decision, not a statement that they are disabled in an
existing binary. Future deployment must verify the linked module set and reject a mismatch. No config or module
directory was changed. Source SQL inclusion likewise does not assert current DB application.

## 4. Initial locale

V1_SUPPORTED_LOCALE=enUS for this first Forge diagnostic slice. Evidence: actual Client/WTF/Config.wtf locale,
editor client configuration, enUS archive set, client build12340, and A.10's explicit permission to standardize the
initial scope on this evidence. Supporting every WotLK locale is not a prerequisite for this slice.

This is a documented support boundary only. No other locale files were deleted or altered. Supporting another
locale later requires its own package/string/dependency review and manifest version, not implicit inclusion now.

## 5. Exact archive selection

Eighteen of the nineteen A.9 archives are IN_RELEASE; backup-enUS is BACKUP/OUT_OF_RELEASE. The manifest records
full paths, sizes and SHA-256 hashes. Names below enumerate membership, not load priority.

| Archive relative to Client/Data | Archive classification |
| --- | --- |
| common.MPQ | IN_RELEASE |
| common-2.MPQ | IN_RELEASE |
| expansion.MPQ | IN_RELEASE |
| lichking.MPQ | IN_RELEASE |
| patch.MPQ | IN_RELEASE |
| patch-2.MPQ | IN_RELEASE |
| patch-3.MPQ | IN_RELEASE |
| patch-U.MPQ | IN_RELEASE |
| enUS/base-enUS.MPQ | IN_RELEASE |
| enUS/locale-enUS.MPQ | IN_RELEASE |
| enUS/speech-enUS.MPQ | IN_RELEASE |
| enUS/expansion-locale-enUS.MPQ | IN_RELEASE |
| enUS/expansion-speech-enUS.MPQ | IN_RELEASE |
| enUS/lichking-locale-enUS.MPQ | IN_RELEASE |
| enUS/lichking-speech-enUS.MPQ | IN_RELEASE |
| enUS/patch-enUS.MPQ | IN_RELEASE |
| enUS/patch-enUS-2.MPQ | IN_RELEASE |
| enUS/patch-enUS-3.MPQ | IN_RELEASE |
| enUS/backup-enUS.MPQ | BACKUP; OUT_OF_RELEASE |

patch-U's selected hash is 45e72ae9152f94290be0b3632c12a983a67a91edbd505b7540b74e5ac87b2497. It contains the inspected
projectile assets, not any of the six primary DBC members. Selecting this exact package does not select the F/M
registry DBCs or all old editor outputs. backup-enUS exclusion is release policy; native handling of an extra file
still present in the local directory is not established by that policy. A later deployment must enforce membership.

## 6. Native precedence — bounded local evidence

| Provenance | Evidence | Conclusion |
| --- | --- | --- |
| NATIVE_CLIENT_EVIDENCE | No authoritative loader trace/source for this exact executable found in reviewed local material | Insufficient to promote effective selection |
| EDITOR_TOOL_POLICY | M2 Editor config.py and docs/client-assets.md choose enUS base-overrides and numeric/letter ordering | Explicit editor behavior only; documentation acknowledges non-patch order uncertainty |
| EXTRACTION_TOOL_POLICY | AzerothCore map_extractor/System.cpp lists archives and opens locale plus numbered patches | Extractor implementation, not proof of native client execution |
| REFERENCE_TOOL_POLICY | Local wildcard clientfs.py claims a client view but orders locale group above base unconditionally | Conflicts with M2 editor's enUS group policy; not imported or executed |
| INFERENCE | For these six tables, relevant copies are in locale archives and tools agree on numbered locale ordering | Supports the conditional selection; agreement is not authoritative native proof |

M2 documentation cites an external WotLK reverse-engineering page. That citation was not fetched or promoted into
reviewed evidence: this phase used existing local sources only. No client loader binary was executed or patched.
The project MPQ strategy itself explicitly requires precedence evidence. No source found justifies replacing that
gap with filename sorting. The focused search covered project/reference documentation and existing extractor/editor
source; it is finished for this phase.

## 7. Effective client tables

[The table audit](../audits/ULDuar_A10_EFFECTIVE_CLIENT_TABLES.json) records archive, exact member, full SHA-256,
row count and ID fingerprint for each row below. Every entry remains CONDITIONAL / SOURCE_ONLY.

| Table | Conditional selected archive | Member | Rows |
| --- | --- | --- | --- |
| Spell | patch-enUS-3.MPQ | DBFilesClient/Spell.dbc | 49839 |
| SpellRange | patch-enUS-3.MPQ | DBFilesClient/SpellRange.dbc | 64 |
| SpellCastTimes | patch-enUS-2.MPQ | DBFilesClient/SpellCastTimes.dbc | 70 |
| SpellVisual | patch-enUS-3.MPQ | DBFilesClient/SpellVisual.dbc | 9406 |
| SpellIcon | patch-enUS-3.MPQ | DBFilesClient/SpellIcon.dbc | 3226 |
| SkillLineAbility | patch-enUS-3.MPQ | DBFilesClient/SkillLineAbility.dbc | 10219 |

All six match A/B full-byte hashes. CastTimes is absent from patch-enUS-3 in the actual member audit, hence its
different candidate source. No DBC was extracted to a production location. EFFECTIVE_CLIENT_STATIC is not claimed.

## 8. Final offline-world search

NO_OFFLINE_EFFECTIVE_WORLD_SNAPSHOT. [The bounded search inventory](../audits/ULDuar_A10_BOUNDED_SEARCH.json)
records 20,691 filename matches across existing SQL/dump/snapshot/deployment patterns under C:/WoWProjecto, with
source/reference trees distinguished and dependency/cache/Git internals excluded. No candidate independent effective
world/update export was found. An initial unfiltered post-processing attempt was stopped at its budget; the final
filename-filtered pass completed. No database was contacted and no service was started.

Repository dumps, migration source and the previously inspected historical Server.log are not an observed current
world export. The log lacks complete row contents and applied-update hashes. This conclusion is bounded to the
searched evidence; it does not claim no backup could exist outside scope or inside an unidentified archive.

Stop repeating this search. Under the selected namespace model, a trustworthy export/admission comparison is an
explicit requirement when adopting an existing environment for deployment, not a demand to query a live database
now or to invent another architecture phase.

## 9. Namespace model decision

NAMESPACE_MODEL=CANONICAL_RELEASE_MANIFEST (MODEL B), with fail-closed deployment admission. MODEL A ties allocation
to the current installed world and would remain blocked on the missing export; it also does not establish safety
for other supported releases. MODEL B can authorize future reservations against a closed canonical package and its
history without pretending an arbitrary local world has been inspected.

Safety is preserved by explicit conditions: all selected source/data/modules and supported/rollback history must
be collision-reviewed; one append-only ledger owns allocations; deployment must reject unknown/conflicting effective
rows, references, update state, modules and client packages before Forge projection. A canonical manifest cannot
silently overwrite an unknown installed ID. None of that enforcement is claimed implemented.

This is an explicit A.10 refinement of the earlier policy's mandatory installed-export allocation prerequisite.
Previous reports are not rewritten. The detailed comparison and admission contract are in
[the namespace proposal](../audits/ULDuar_A10_NAMESPACE_CANDIDATES.md).

## 10. Historical publication reconciliation

| Known artifact/allocation | Classification | Release/tombstone decision |
| --- | --- | --- |
| F SpellVisual16680 / EffectName7088 | UNKNOWN_HISTORY | Experiment authoring proved, never-published not proved; retain typed tombstone |
| M SpellVisual16680..16684 / EffectName7088..7092 | UNKNOWN_HISTORY | Same; OUT_OF_RELEASE DBCs, conservative historical exclusion |
| E SpellVisual17000 | REFERENCE_ONLY | Separate editor dataset; not canonical Ulduar occupancy, no reuse assumption |
| patch-U projectile assets | UNKNOWN_HISTORY for publication | Local installed bytes/receipt proved; IN_RELEASE exact asset package, no implied DBC allocation |
| Editor registry/staging manifests | UNKNOWN_HISTORY | Experiment provenance alone does not prove EXPERIMENT_ONLY across publication history |
| Old ability/addon experiments | UNKNOWN_HISTORY | Native presentation references found; no global carrier allocation ledger discovered |
| Ascension IDs/assets | REFERENCE_ONLY | Excluded from Ulduar allocation authority |

No artifact is classified PUBLISHED_ULDUAR without publication evidence, or retired because absent from today's
selection. No EXPERIMENT_ONLY claim is manufactured from a work-folder name. Tombstones here are design exclusions,
not production ledger writes. Visual IDs do not consume numerically equal Spell IDs. The remaining historical input
is specific: supported/rollback release manifests or a maintainer-backed publication/allocation statement, with
conservative typed exclusion of any unresolved Ulduar uses.

## 11. Candidate namespace

NAMESPACE_CANDIDATE_ONLY: propose Spell IDs 90000..90023, capacity24, documentation only.
[Machine evidence](../audits/ULDuar_A10_NAMESPACE_CANDIDATE_EVIDENCE.json) stores exact input hashes, typed set
fingerprints, empty intersections, historical exclusions, 24-bit check and sparse-index impact.

The block is absent from all 50,656 distinct inspected locale Spell rows, 4,491 base spell_dbc IDs, and additional
conservative SQL/binding/reference screens. Checking all inspected versions makes this negative raw-Spell screen
independent of which numbered locale archive wins. It does not establish the effective dependent tables or complete
SQL semantics. Timers/faction IDs/unrelated table keys containing 90000 are not automatically SpellID collisions.
Unresolved computed/positional references still prevent a final reservation certificate.

90023 fits the 24-bit action identity. Compared with native max80864, a max-index client model adds 9159 positions;
the server source model already reaches100102, so its maximum does not increase. Pointer-array examples and limits
are documented; no extremely high-ID shortcut is used. Six copies per family require24 IDs only for the retained
single exact envelope. Extra envelopes or quarantined leases require a later capacity decision, not automatic reuse.

Final reservation requires the exact interval's typed canonical closure plus historical/ledger review. No SpellID
is owned, reserved, mapped to a family copy, or emitted by this report.

## 12. Focused attribute finalization

ATTRIBUTE_SERIALIZATION=READY. [The focused audit](../audits/ULDuar_A10_REMAINING_ATTRIBUTE_BITS.md) contains exactly
the 33 formerly blocked bits: bit/name, family relevance, source behavior, remaining observation and serialization
gate. All 33 are now explicitly CLEAR for the simple diagnostic fixtures, classified
SERIALIZATION_DECIDED_RUNTIME_UNVERIFIED. The earlier 223 decisions are retained, not broadly re-audited.

This is a deliberate no-opt-in policy, not a claim that an unknown flag has no behavior. All 33 are also clear in
the reviewed raw native references 1495, 585, 2050, 635, 31759 and 34232; those references inform the choice without gaining
carrier approval. The five server-labeled cases were inspected in context. NO_AURA_LOG's supposed consumer is a
commented-out condition; A.9's BLOCKED_RUNTIME classification overstated that evidence. The immunity-aura, AoE
target and PvP bypass flags are not needed for this one-effect explicit-unit fixture. Trigger-only-on-target belongs
to the triggering aura, not generic carrier isolation.

Explicit words are in the companion. All unknown optional bits are off; only the retained five family-specific
set decisions remain. Client facing, usability, combat feedback and proc/world interactions still require later
acceptance. Choosing raw values makes serialization possible; it does not make execution safe.

## 13. Visual serialization gate

| Family | Visual ID | Visual serialization | Runtime closure |
| --- | --- | --- | --- |
| MeleeDamage | 342 | ARTIFACT_SERIALIZABLE | RUNTIME_UNVERIFIED |
| RangedProjectileDamage | 7873 | ARTIFACT_SERIALIZABLE | RUNTIME_UNVERIFIED |
| MeleeHealing | 135 | ARTIFACT_SERIALIZABLE | RUNTIME_UNVERIFIED |
| RangedHealing | 2936 | ARTIFACT_SERIALIZABLE | RUNTIME_UNVERIFIED |

Existing visual/kit/effect-name/sound/animation rows and actual hashed M2/skin/texture/sound assets support writing
references to these unchanged rows in an isolated fixture. The projectile's actual missile model is located.
No referenced row required by the bounded graph is missing. Exact native .mdx-to-.m2 behavior, nested model closure,
character procedure8, attachment/animation, projectile timing and package selection remain rendering/release gates.

A.9 VISUAL_CLOSURE_PARTIAL remains true. It no longer means NOT_SERIALIZABLE under the deliberately narrower A.10
question. No visual row, model, texture, archive or dependency ID was created/modified. See
[the serialization gate](../audits/ULDuar_A10_SERIALIZATION_GATE.md) for family evidence and boundaries.

## 14. Three frozen source designs

All three are FROZEN_DESIGN_PROPOSAL, not implemented behavior. A.9's exact source locations/data flow remain the
implementation reference; no new architecture is introduced.

| Design | Frozen contract |
| --- | --- |
| Healing threat | Bound snapshot selects NativeDefault or ClassNeutralHealing; the latter skips only the native Paladin extra reduction, retaining normal effective-heal threat and world modifiers/redirects |
| Target intent | Capture original wire mask/object GUID, resolution result and native substitution outcome; exact-unit Forge uses original intent, unbound native spells keep native corrections |
| Potency | After valid frozen snapshot resolution, SetSpellValue(SPELLVALUE_BASE_POINT0,resolvedBase) before native amount processing; no second OnHit Potency multiplication, event or global SpellInfo mutation |

The existing original GUID/CanPrepare seam and cast-local SpellValue are reused in the design. Preservation of
normal modifiers does not implement provenance-aware native talent suppression. Cooldown debt, lease quarantine
and manifest enforcement also remain runtime gates. A DBC field is not a substitute for any of these code behaviors.

## 15. Frozen payload, timing and Mana fixture

| Family | Semantic amount | SP | Range | Cast ms | Speed | Base-Mana % |
| --- | --- | --- | --- | --- | --- | --- |
| MeleeDamage | 25 | 0 | Contact / Range2 | 0 | 0 | 3 |
| RangedProjectileDamage | 13..17 | .123 | 0..40 / Range5 | 2500 | 24 | 9 |
| MeleeHealing | 46..56 | .231 | Contact / Range2 | 0 | 0 | 7 |
| RangedHealing | 50..60 | .481 | 0..40 / Range5 | 2500 | 0 | 29 |

HYBRID strategy, four families, one exact envelope each, future six copies per family remain unchanged. MD remains
MAGIC/Physical/contact with CANT_CRIT; ranged damage MAGIC/Holy; healing MAGIC positive. GCD category133/base1500ms,
own cooldown0. AP/DOT coefficients0. Native caster/taken/crit/mitigation stages retain A.9 ownership.

KEEP_NATIVE_BASE_MANA_FOR_DIAGNOSTIC_SLICE is frozen. Absolute costs may differ by native chassis, acceptable only
for diagnostic transport evidence. Production Forge economy must later normalize/replace this baseline. No
ResourceService work, balancing, additional debit or new resource envelope is introduced in Phase A.

Holy Light635 remains REPLACE_WHEN_CUSTOM_READY, SOURCE_COMPATIBLE native exception, not class-neutral. No later
ranks or research candidates are promoted. HeroFreePick remains UI/progression reference only; no imports.

## 16. Spellbook gate

SPELLBOOK_ARTIFACT_GATE=NON_BLOCKING_RUNTIME_GATE. Static confidence remains MEDIUM. An assigned, loaded and known
native SpellID can have server action identity; no current unknown or unreserved carrier is thereby usable. Exact
General-tab population, drag/drop, icon/tooltip and friendly contact feedback remain client acceptance criteria.

FrameXML calls into native spellbook APIs; it does not prove a new generic spell's tab behavior. This does not prevent
staging a serialized row after namespace approval. No static evidence requires a new SkillLineAbility for that
isolated fixture, so none is created. Progression entitlement remains outside native class/trainer authority.

## 17. Serialization and runtime decisions

| Carrier | STATIC_SERIALIZATION_READY | RUNTIME_READY | CLIENT_VALIDATED |
| --- | --- | --- | --- |
| MeleeDamage | YES | NO | NO |
| RangedProjectileDamage | YES | NO | NO |
| MeleeHealing | YES | NO | NO |
| RangedHealing | YES | NO | NO |

Numeric envelopes, effect/target/relation, DmgClass, attribute values, visual/dependency IDs, cost/GCD and source
seam contracts are known sufficiently for the defined isolated fixture. The companion records the field mapping.
The missing carrier identity remains a namespace assignment; no usable row can be emitted now. Serialization
readiness is a specification decision, not a promise that the current runtime can safely execute the row.

## 18. Release gate and minimum remaining inputs

RELEASE_GATE=PARTIAL, not PASS_STATIC: membership and locale are selected, but native effective client selection
is still conditional and the candidate namespace lacks a complete reservation certificate/history closure.

Only two narrow evidence packages remain before reservation/artifact authorization:

1. **Release selection proof:** authoritative native loader/precedence evidence for the selected build/package,
   or a separately approved effective table package with justified selection. Existing tool policy alone is insufficient.
2. **Namespace reservation proof:** finish typed canonical source/update/reference checking for 90000..90023 and
   reconcile supported/rollback history plus the allocator/ledger authority. Unknown historical Spell uses must be
   excluded/tombstoned, not declared retired. Then reserve in a separately authorized step.

An existing-world export/admission comparison is a **deployment/adoption** prerequisite under MODEL B. Its absence
does not require another local search before canonical allocation. Runtime source seams, native aura/proc provenance,
cooldown/leases, manifest enforcement and client acceptance remain later implementation/acceptance gates; they are
not additional unknown values in these four diagnostic specifications.

NEXT_SAFE_PHASE: **RELEASE / NAMESPACE RESERVATION**, limited to those exact inputs and a reviewable reservation
decision. After approval, a separately authorized isolated artifact-authoring task can consume the frozen specs.
Do not schedule another broad carrier-design audit. No next phase, allocation or artifact authoring was begun.

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO LIVE DATABASE WAS CONNECTED OR QUERIED.
NO SQL WAS EXECUTED OR MODIFIED.
NO DBC WAS GENERATED OR MODIFIED.
NO MPQ WAS GENERATED OR MODIFIED.
NO CLIENT PATCH WAS APPLIED.
NO PRODUCTION ID WAS RESERVED OR ALLOCATED.
