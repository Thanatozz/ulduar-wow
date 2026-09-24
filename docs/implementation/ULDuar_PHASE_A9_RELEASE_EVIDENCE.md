# ULDuar Phase A.9 — Target release and offline package evidence

Date: 2026-09-19 (local review date). Evidence: SOURCE_ONLY. No runtime claims.

## 1. Executive summary

PHASE_A9_STATUS: COMPLETE for the permitted evidence review and design proposals. Release/effective-data completion remains partial; this does not approve artifact authoring.

| Decision | Result |
| --- | --- |
| Target release | PARTIAL; documented local candidate, no authoritative supported-release manifest |
| Client overlay | CLIENT_OVERLAY_PARTIAL; actual archive members read, native loader precedence unproved |
| Effective client dataset | TARGET_DATASET_UNRESOLVED; conditional selection recorded separately |
| Effective world | EFFECTIVE_WORLD_DATA_UNAVAILABLE; no trustworthy offline world export |
| Namespace | NAMESPACE_UNRESOLVED; no numeric interval promoted to a reservation candidate |
| Visual closure | VISUAL_CLOSURE_PARTIAL for all four families |
| Attributes | PARTIAL; remaining client/runtime blockers explicit |
| Defense | DMGCLASS_POLICY_CONFIRMED_STATIC |
| Four custom carriers | NOT_ARTIFACT_READY |

A.9 adds direct read-only inspection of 19 installed client MPQs. Six primary DBC tables selected under the documented editor lookup model match A/B byte-for-byte. SpellCastTimes is supplied by patch-enUS-2, not patch-enUS-3. The missile Holy_Missile_Low.m2 and its inspected texture/skin/sound dependencies actually exist in the archives. Native client selection and full visual interpretation remain separate questions.

The installed addon matches all 21 canonical files. Historical server logs establish a previous use of this core/Data directory, but do not establish current world rows or an approved module set. Pending SQL is not automatically excluded by this checkout's updater. Three future source seams are now specified precisely; the smallest Potency proposal can reuse the existing per-cast SetSpellValue API.

The [release evidence manifest](../audits/ULDuar_A9_RELEASE_MANIFEST.json) is documentation of reviewed inputs, not a production Forge CarrierManifest. Previous reports and all existing source/data are preserved.

## 2. Scope / preservation

The A.8 main report and companions, A.7 contracts/namespace policy, A.6/A.5/A implementation reports, and the requested Forge/metadata/resolution/taxonomy/vertical-slice architecture documents were reviewed as prior contracts. Current local source governs discrepancies. A.9 does not edit those documents.

Allowed operations used: file enumeration, text/source inspection, Git identity/status reads, SHA-256 hashing, WDBC byte decoding, and read-only MPQ member reads held in memory. Independent Python audit snippets only wrote documentation/JSON under docs; they did not import project tooling or execute project tests. Vendor StormLib was opened through a wrapper binding read operations only, using MPQ_OPEN_READ_ONLY=0x100. Incremental patch members would be rejected, not treated as complete rows or repacked. No archive was extracted into replacement data files.

The [initial protected baseline](../audits/ULDuar_A9_PROTECTED_FILE_HASHES.json) covers 10,001 existing files and 18,387,696,266 bytes. It includes pre-existing reports, core/module source, SQL, relevant loose DBCs, client/archive/editor evidence. Thirty later-discovered evidence files have a [separate hash record](../audits/ULDuar_A9_ADDITIONAL_EVIDENCE_HASHES.json); this record explicitly identifies its later capture and does not pretend to be an initial baseline. These include read-only tooling, installed addon files and deployment evidence.

Preservation comparison and the exact new-file list are recorded in [the final audit](../audits/ULDuar_A9_PRESERVATION_RESULT.json). The claim is bounded to these enumerated protected files, not every uninspected file on the machine. Git alone is insufficient: the module implementation is mostly untracked, and five core files were already dirty before this phase.

Final comparison: all 10,031 protected files are byte-identical (18,388,694,566 bytes compared). Twelve new documentation/audit files were created; zero existing files intentionally changed and zero removed. MODIFIED_CPP=0, MODIFIED_LUA=0, MODIFIED_SQL=0, MODIFIED_DBC=0, MODIFIED_MPQ=0, MODIFIED_CLIENT=0, MODIFIED_CONFIG=0. No commit or push. Static document inspection found all 22 required sections, readable JSON and resolved local report links; it was not a project test execution.

## 3. Candidate target release

Use the symbolic documentation name **ULDuar-V1-PREVIEW-CANDIDATE**. `releaseId=null`: no existing authoritative release identifier was found. This name is not a publication or allocation event.

| Field | Observed evidence / remaining qualification |
| --- | --- |
| coreRevision | d7ce67dc1800f092bac98aad680ece1c201b89a0 |
| coreDirtyFingerprint | 4ebe2a2d6c2fd709c9822e0a38fb73733c36bea59cf8b455c02695320f4d3768 |
| moduleRevision | 5f51c5e012b153b1edae00af2b0e11a9d45ba62d; commit alone omits untracked implementation |
| moduleFingerprint | 7401078d905d4eb2879d7e79f01c7b253d8bf657958c8d6e5fbc1141590d5773 |
| clientFolder | C:/WoWProjecto/Client, named in addon installation README and editor client configuration |
| clientBuild | Version-resource evidence 3.3.5a / 12340; executable not launched |
| clientExeHash | aa63a5750d60ef16746c686b3d5e26876d98953eab08b1c026cd0faf78e88cb8 |
| localeSet | enUS observed in local configuration; supported locale set unconfirmed |
| server Data candidate | C:/WoWProjecto/ulduar-build/bin/RelWithDebInfo/Data; explicitly referenced by talent-conversion documentation |
| mpqSet | 19 present client archives, individually hashed; supported membership remains UNKNOWN |
| dbcSet | Conditional per-table member selections; A/B matches do not confer release approval |
| sqlSet | Pinned repository text/model only; installed world revision/content unknown |
| moduleSet | Abilities required; citybuilder, density-test, editor and wave-survival present but supported linkage/enabled status UNKNOWN |
| clientAddonSet | UlduarAbilities canonical source and installed copy identical across 21 files; supported complete addon policy unpinned |
| editorAssetSet | Matching patch-U installation receipt plus historical visual registries/staging; ownership/history unresolved |

Fingerprints use SHA-256 of sorted UTF-8 `absolute path TAB content SHA-256 LF` records, with enumerated scope in the hash inventories. The dirty fingerprint covers exactly Spell.cpp/.h, SpellEffects.cpp and Unit.cpp/.h; the module fingerprint covers inventoried existing module files, including untracked source. They identify bytes, not compatibility.

Evidence sources: `docs/architecture/01_SYSTEM_OVERVIEW.md`, `22_MPQ_PATCH_STRATEGY.md`, `ULDuar_TALENT_CONVERSION_PIPELINE.md`, module README, canonical addon README, editor config/client.json, installation receipt, pre-existing Server.log and safe non-secret worldserver configuration keys. A clarification about intended supported paths was left unanswered during this review; silence is not confirmation. Local-path documentation supports a candidate, not an approved release composition.

## 4. Data classification

Each enumerated artifact has exactly one of the four requested classifications in the manifest. There are 9,477 TARGET_REQUIRED source artifacts, 175 REFERENCE_ONLY evidence/reference artifacts and 379 UNKNOWN artifacts in the 10,031-file combined scope. No TARGET_OPTIONAL has been approved. Source requirement does not mean the corresponding SQL is installed or a compiled module is enabled.

| Artifact group | Classification | Authority |
| --- | --- | --- |
| Named AzerothCore checkout and primary abilities module | TARGET_REQUIRED | Required source inputs; hashes pin local changes |
| Canonical UlduarAbilities addon | TARGET_REQUIRED | Explicit module README designation |
| Repository SQL | TARGET_REQUIRED | Source application model only, never installed occupancy |
| Current client Data/MPQs/executable and build Data/DBC | UNKNOWN | Strong local-candidate evidence; supported release ownership/overlay unconfirmed |
| Installed addon copy | UNKNOWN | Identical bytes, deployment role not independently release-approved |
| Other four local modules | UNKNOWN | Folder presence/historical log is not current linkage/approval |
| Current patch-U and historical F/M/editor staging/backups | UNKNOWN | Installation/authoring evidence, no complete publication/retirement ledger |
| E spell-editor datasets; TrinityCore; Ascension; Work extracts | REFERENCE_ONLY | Semantics/research only; excluded from target occupancy authority |
| Prior reports and audit tooling | REFERENCE_ONLY | Evidence sources, not gameplay package content |

No UNKNOWN source is silently merged into a target namespace. No union of Ascension/editor/custom-reference IDs establishes target occupancy or available IDs. Future release selection must explicitly reclassify and approve optional inputs before absence checks can authorize reservation.

## 5. Client MPQ overlay

See [the archive inventory](../audits/ULDuar_A9_MPQ_OVERLAY_INVENTORY.md) for every path, size, SHA-256, locale, apparent model priority and DBC-presence result. [Machine evidence](../audits/ULDuar_A9_MPQ_MEMBER_INVENTORY.json) retains listfile metadata and exact table hashes/ID sets.

The 19 actual client archives comprise common/common-2, expansion, lichking, patch/patch-2/patch-3/patch-U and eleven enUS archives including locale/speech/base/expansion/lichking/numbered patches and backup-enUS. Relevant exact DBC names occur only in locale-enUS, patch-enUS, patch-enUS-2 and patch-enUS-3. No probed DBC occurs in patch-U. Its hash matches build-d2f8dda3 and the installation receipt; that staging manifest describes sixteen projectile M2/skin files plus listfile metadata.

The local editor configuration names profile base-overrides, locale enUS and no manual order. Source `M2 Editor/src/client/config.py` defines numeric/letter patch ordering and base/locale grouping. This is evidence for editor selection, not client execution. The extractor's locale/patch loading logic is also tool-specific. Project `22_MPQ_PATCH_STRATEGY.md` explicitly leaves native discovery/precedence and locale behavior to later evidence. Filename ranking alone does not close it. backup-enUS is inactive under the editor policy; native-client loading is UNKNOWN.

Result: CLIENT_OVERLAY_PARTIAL. Actual membership is known for the probed paths; native effective order is not proven. No claim of CLIENT_OVERLAY_RESOLVED.

## 6. Effective client DBC evidence

The manifest records tableName, source archive/member, full hash, rows, ID-set fingerprint, evidence and confidence. These are **conditional editor-model selections**, not an approved EffectiveClientTableSet.

| Table | Conditional source | Rows | A/B match |
| --- | --- | --- | --- |
| Spell | patch-enUS-3 | 49,839 | Exact |
| SpellRange | patch-enUS-3 | 64 | Exact |
| SpellCastTimes | patch-enUS-2 | 70 | Exact |
| SpellVisual | patch-enUS-3 | 9,406 | Exact |
| SpellIcon | patch-enUS-3 | 3,226 | Exact |
| SkillLineAbility | patch-enUS-3 | 10,219 | Exact |

A is a/Data/dbc; B is the build Data/dbc; E is the separate WotLK editor dataset. E matches Range/CastTimes/Icon but differs in Spell bytes and SpellVisual rows; no E SkillLineAbility equality is established by this inventory. F and M are historical visual registry outputs, extending visuals/dependencies; they are not effective client tables merely because they exist locally. The selected visual dependency hashes match the native inputs recorded by those historical registries, not their modified output rows.

Auxiliary members inventoried include SkillLine, SpellVisualKit, SpellVisualEffectName, SpellVisualKitModelAttach, SpellVisualPrecastTransitions, SpellMissile, SpellMissileMotion, SoundEntries and AnimationData; additional shake/chain tables were probed. PrecastTransitions comes from locale-enUS. Byte availability does not prove which native client copy wins. TARGET_DATASET_UNRESOLVED remains the gate.

## 7. Offline server-data evidence

Existing-file searches included SQL/dump/compressed-dump/backups, deployment/update manifests, database snapshot/volume evidence, logs and workspace exports. No independent, trustworthy target world-table export or applied-update dump was found outside repository/reference sources. No database service was contacted.

| Artifact | Database / time / revision | Completeness and authority |
| --- | --- | --- |
| Repository base world SQL | Export headers include 2026-06-01; revision pinned by checkout | Source snapshot, not installed target DB |
| Existing RelWithDebInfo/Server.log | Historical world/auth/characters updater log; core d7ce67dc1800, world ACDB335.17-dev | No row contents or complete applied hashes; log run timestamp not established from core build date |
| worldserver.conf selected keys | DataDir ./Data/, SourceDirectory empty, update options present | Intent/config evidence; no proof of current DB state |
| Existing module/pending SQL | Repository/current workspace hashes | Sources only; application state unknown |

The historical log reports world 815 new/2195 archived, auth 13/9 and characters 10/18 updates, and loaded density/abilities configs while reporting several missing configs. These historical statements cannot identify the current effective rows, exact module set or intended V1 set. Reading a log containing a previous startup is not starting a server. Hashes are in the additional evidence record; connection strings and credentials are not copied into reports.

OBSERVED_EFFECTIVE_WORLD_MODEL: unavailable. EFFECTIVE_WORLD_DATA_UNAVAILABLE. Source reconstruction cannot masquerade as an observed export.

## 8. Static expected world model

STATIC_EXPECTED_WORLD_MODEL is a source-only description, not SQL execution or an effective database simulation.

1. `DBUpdater.cpp` reads the configured base directory for an empty database and sorts .sql file paths before applying them. Existing nonempty databases follow update bookkeeping instead; source presence does not establish execution.
2. `UpdateFetcher.cpp` takes included directories from updates_include. Repository base rows specify archived, released, custom and pending locations. Actual installed updates_include may differ.
3. It discovers matching SQL directories from the linked module list. Merely finding a module folder does not prove it is linked. Filenames form the ordered collection; duplicate filename collisions are rejected.
4. The first pass processes ordinary released/archived entries subject to existing applied/hash/state/configuration rules. The second pass processes PENDING, CUSTOM and MODULE entries. **Pending is not categorically excluded in this checkout.** Do not model it as a universally safe staging directory.
5. Installed updates records, hashes, directory state, archived options and historical custom operations determine what is actually present. No such complete offline state was found.

| Data layer | Required later effective evidence |
| --- | --- |
| spell_dbc | Raw store plus ordered SQL overrides, corrections and resulting effective SpellInfo |
| spell_proc | Explicit and generated/default proc behavior, masks, charges and cooldowns |
| spell_bonus_data | Actual coefficient authority and fallback behavior |
| spell_threat | Multipliers and flat/AP terms, alongside native threat code |
| spell_script_names | Exact bindings, negative rank-root expansion and linked script registration |
| conditions | Target/cast restrictions and references affecting candidate IDs |
| Other relationships | Ranks/learn/skill/item/trainer/creature/SmartAI references and custom module queries |

A.8 preserved all 7,617 repository SQL files, with 3,369 relevant keyword-selected files and 123 additional base/support tables. Its conventional base spell_dbc extraction contains 4,491 ID-leading rows. These are lexical source evidence, not a replay. Dynamic SQL, UPDATE/DELETE predicates, archived history and installed modifications remain unresolved. The seven previously identified spell_dbc update files remain source inputs, not proof of seven applied updates.

## 9. Historical allocation reconciliation

A.8's row/reference inventory was revisited alongside current editor registries, patch manifests/receipts, module SQL/source and Work/client files. No complete publication/allocation history was found. Inactivity and an absent current DBC member do not retire an ID.

| Namespace / ID | Owner / evidence file | Status evidence | Release relevance |
| --- | --- | --- | --- |
| SpellVisual 16680; EffectName 7088 | M2 Editor/output/phase9-frost-registry/registry.json | Authored Frost registry rows | HISTORICAL_UNKNOWN |
| SpellVisual 16680..16684; EffectName 7088..7092 | M2 Editor/output/arcane-shot-elements-registry/registry.json | Authored Frost/Fire/Nature/Holy/Shadow rows; repeated IDs show overlapping experiments | HISTORICAL_UNKNOWN |
| SpellVisual 17000 | WoW Spell Editor/DBC_335_wotlk/SpellVisual.dbc | Extra editor row in E; no Ulduar release ownership | REFERENCE_ONLY |
| Spell IDs in base spell_dbc and source references | Pinned core SQL/scripts; A.8 typed inventory | Defined/referenced in source, not automatically custom Ulduar allocation | CURRENT_TARGET source model only; installed relevance unknown |
| Synthetic test IDs | Module test source | Authored fixtures, not published carriers | SAFE_TO_IGNORE_WITH_EVIDENCE as production row definitions only; do not erase literal audit evidence |
| patch-U projectile assets | Actual client MPQ + build-d2f8dda3 manifest/receipt | Present M2/skin assets; no inspected DBC definition | HISTORICAL_UNKNOWN for supported release, not Spell ID allocation |
| Mount/transmog/model packs and Work extracts | Existing reference/staging paths in A.8 external inventory | A model/display/item number is not a Spell namespace allocation | REFERENCE_ONLY where separately sourced; unknown editor publication history retained |
| Citybuilder, density, editor, wave-survival | Current local module source/SQL | No complete installed custom-spell allocation ledger | HISTORICAL_UNKNOWN; module deployment/effective DB unresolved |
| Abilities pending SQL / old experiments | Root pending files and module source | Legacy bindings/ranks/prototype IDs, no usable custom carrier definitions | CURRENT_TARGET source evidence; applied/release history unresolved |

The detailed A.8 typed item/trainer and lexical spell-reference entries remain linked evidence, not discarded. Their mixed-reference union is deliberately not an occupancy authority here. HeroFreePick/Ascension cannot fill gaps in Ulduar history.

## 10. Namespace result

NAMESPACE_UNRESOLVED. Required source inputs are pinned, but no complete approved target client/data set or observed effective world state is available. Therefore an absence claim would still rely on UNKNOWN membership and incomplete history. No numeric CANDIDATE_INTERVAL is nominated from such a union. No reservation or production ledger entry was written.

| Namespace | Conditional native table evidence | Current need / unresolved evidence |
| --- | --- | --- |
| Spell | 49,839 rows, IDs 1..80864 | New rows eventually required; SQL/custom/history/target approval incomplete |
| SpellRange | 64 rows, 1..187 | Reuse 2/5 proposed; contact client behavior pending |
| SpellCastTimes | 70 rows, 1..209 | Reuse 1/20 proposed; exact envelope |
| SpellVisual | 9,406 rows, 1..16679 | Reuse 342/7873/135/2936 conditional on closure; historical 16680..16684 retained separately |
| SpellIcon | 3,226 rows, 1..4375 | Reuse 257/237/682/70 after package/icon presentation review |
| SkillLineAbility | 10,219 rows, 69..21980 | New rows not yet justified; client General-tab behavior blocked |

`Player.h:235–237` masks action values to 24 bits and defines the exclusive maximum 0x01000000. Any future SpellID must fit that bound, but fitting is not evidence of availability. `DBCFileLoader::AutoProduceData` sizes an index array through the maximum index; huge sparse IDs incur memory costs. No max(ID)+1 or high-number-is-free policy is used.

Retain the A.7 append-only, owner/spec/release/provenance-aware ledger and no reuse while any supported release can reference an ID. For one exact envelope per family, six concurrent instances of any family require six copies per family: 24 logical pool entries across four families, not 24 automatically free IDs. Additional envelope variants and quarantined leases can increase capacity; no finite pool authorizes arbitrary live reuse. Existing Range/CastTime/Visual/Icon references are reuse proposals, not new allocations.

## 11. Visual dependency closure

See [the visual report](../audits/ULDuar_A9_VISUAL_DEPENDENCIES.md) and [raw graph/hashes](../audits/ULDuar_A9_VISUAL_GRAPH.json). All reads came from actual installed archives under a conditional lookup model, not only similarly named loose files.

| Family | Visual → kit/effect evidence | Result |
| --- | --- | --- |
| MeleeDamage | 342; kits 506/11065; effect 416 fanofknives_impact | VISUAL_CLOSURE_PARTIAL |
| RangedProjectileDamage | 7873; kits 184/119/121; effects 135/129 and missile 224 | VISUAL_CLOSURE_PARTIAL |
| MeleeHealing | 135; kits 99/270/232; effects 130/135/249 | VISUAL_CLOSURE_PARTIAL |
| RangedHealing | 2936; kits 99/270/154; effects 130/135/244 | VISUAL_CLOSURE_PARTIAL |

Corresponding .m2 models, inspected embedded texture references, numbered skin members and selected SoundEntries files are present and hashed. Exact DBC .mdx names were absent; .m2 alternatives were probed explicitly, without claiming native extension-resolution proof. Character animation/procedure interpretation, nested model/particle/animation dependencies, native overlay selection and approved package ownership remain unresolved. Melee kit 506 includes character procedure 8.

The projectile's HasMissile path now reaches actual Holy_Missile_Low.m2 bytes and inspected dependencies; its critical existence gap has narrowed. This is not full rendering or missile closure. Source SpellMissileID and visual motion ID are zero; those zeros do not warrant inventing auxiliary rows. KitModelAttach has no matching selected-kit rows. Auxiliary transition/animation/sound tables are present, with applicability limits recorded. No projectile carrier is artifact-ready on this evidence.

## 12. Attribute completion

The [attribute inventory](../audits/ULDuar_A9_ATTRIBUTE_INVENTORY.json) lists every one of the 256 word-0..7 bits, source comments/line references, design classification, per-family differences and selected server consumers. It is not a set of serialized attribute words. Current classification totals: 136 REQUIRED_CLEAR, 5 REQUIRED_SET entries with family exceptions, 75 NOT_APPLICABLE, 7 PLATFORM_NORMAL, 28 BLOCKED_CLIENT and 5 BLOCKED_RUNTIME. Required choices are design decisions, not observed client behavior.

| Priority decision | A.9 classification / reason |
| --- | --- |
| DO_NOT_SHEATH | REQUIRED_CLEAR for all; use normal spell sheathing presentation, no weapon-animation exception |
| TRACK_TARGET_IN_CAST_PLAYER_ONLY | REQUIRED_CLEAR; manual/native facing requirement remains separate from client auto-turn |
| COMBAT_FEEDBACK_WHEN_USABLE | REQUIRED_CLEAR; ordinary actionable carrier, not reactive initially-disabled presentation |
| USE_FACING_FROM_SPELL | BLOCKED_CLIENT; header says unknown and no semantic server consumer was found. Proposed off is not full approval |
| DO_NOT_RESET_COMBAT_TIMERS | REQUIRED_SET contact; REQUIRED_CLEAR ranged, choosing ordinary native cast-time swing behavior |
| DOESNT_RESET_SWING_TIMER_IF_INSTANT | REQUIRED_SET contact; REQUIRED_CLEAR ranged |
| NO_PUSHBACK | REQUIRED_CLEAR; ordinary ranged spell pushback, no interval for instant contact |
| EXCLUDE_CASTER | REQUIRED_SET damage; REQUIRED_CLEAR healing |
| CANT_CRIT | REQUIRED_SET MeleeDamage; REQUIRED_CLEAR other three |
| SUPPRESS_WEAPON_PROCS | REQUIRED_SET all; does not block every school/generic item spell proc |
| IS_ABILITY / next-swing / ranged-slot / combo requirements | REQUIRED_CLEAR; MAGIC spell defense and Mana action |
| PASSIVE / hidden / NOT_IN_SPELLBOOK / hidden range / hidden cast-bar text | REQUIRED_CLEAR; actual tab membership still BLOCKED_CLIENT |
| immunity/LOS/phase/modifier bypasses, NO_THREAT, broad caster/target proc suppression | REQUIRED_CLEAR; preserve ordinary world interactions |
| channel/aura/pet/energize-only flags | NOT_APPLICABLE where specifically identified; fixture bit 0 |

Some enum names are misleading. ONLY_IN_SPELLBOOK_UNTIL_LEARNED is consumed by non-active-power energize handling in this core; it does not prove how to put a spell in General. FORCE_DISPLAY_CASTBAR's header describes triggering-aura crit inheritance; do not infer UI behavior from that name. Remaining flags with unclear client semantics remain blocked rather than copying a native reference's unknown bitset.

Separate reviewed fields remain: equipment class -1/masks0; stance masks0; reagents/totems/focus0; no channel; instant interrupt flags0 and ranged0xF; PreventionType1 (silence); damage facing1/healing0. These do not replace required target-intent, client range/cast and modifier provenance review. ATTRIBUTE_POLICY_STATUS: PARTIAL.

## 13. DmgClass / defense confirmation

DMGCLASS_POLICY_CONFIRMED_STATIC for the proposed diagnostic semantics, not for runtime eligibility. Method=Melee means contact acquisition; this fixture deliberately uses spell defense, not weapon-skill combat.

| Interaction | MeleeDamage | RangedProjectileDamage | Both heals |
| --- | --- | --- | --- |
| DmgClass / school | MAGIC / Physical | MAGIC / Holy | MAGIC / Holy, positive effect |
| Hit / miss | Native magic-class hit calculation | Native magic-class hit calculation | Native positive-on-friendly no-miss path, after its initial immunity check |
| Reflect / deflect | Native applicability retained; no exemption flags | Native applicability retained; delayed outcome remains native | Positive friendly path; do not impose harmful spell reflection rules |
| Dodge / parry / block | No MELEE/RANGED defense branch | No MELEE/RANGED defense branch | Not weapon outcomes |
| Crit | CANT_CRIT explicitly set | Native spell crit | Native heal crit |
| Armor | Physical school can enter armor reduction despite MAGIC DmgClass | No Physical armor route | Not damage mitigation |
| Resist / absorb / immunity | Native school/effect handling; no bypass | Holy resistance applicability, absorb and immunity remain native | Heal absorb and applicable healing immunity/world rules |
| Threat / procs | Native negative magic-class event path, reviewed weapon-proc suppression | Same, with projectile/crit outcomes | Positive heal event path; Paladin threat seam still required |

Source anchors: Unit.cpp SpellHitResult overload using Spell at 3703, MagicSpellHitResult at 3497, CalculateSpellDamageTaken at 1498, CalcAbsorbResist at 2334 and crit functions around 9166; Spell.cpp launch/impact/proc handling; SpellEffects.cpp native payload handlers. MAGIC does not mean school is non-Physical, guaranteed hit or immunity bypass. Native Holy resistance is not a universal claim of zero resistance; the existing conditional creature handling remains. Encounter/script modifiers and misleading attribute names require effective review.

## 14. Healing threat source blocker

Both custom heals reach `Spell::DoAllEffectOnTarget`. After HealBySpell returns effective gain, Spell.cpp:2817 starts threat at gain * 0.5; line 2818 halves it again for native Paladin class. Family GENERIC does not prevent that check.

Proposal: frozen per-cast NativeDefault/ClassNeutralHealing policy. Skip only the Paladin-specific extra factor for an explicitly approved bound Forge heal, preserve the ordinary 0.5 coefficient and existing ThreatManager forwarding/modifier/redirect path. Native Paladin spells remain unchanged. No global class-check deletion and no DBC threat flag workaround. Exact locations, constraints and later observations are in [the source seam proposal](../audits/ULDuar_A9_SOURCE_SEAM_PROPOSALS.md).

## 15. Original target-intent source blocker

`Spell::InitExplicitTargets` already preserves the original object GUID before selection/self fallback. The original mask and correction outcome are not equivalently available to later module logic; GetOriginalTarget's pointer alone cannot distinguish missing from stale intent.

Capture original wire mask/GUID before correction, retain resolution/correction facts on the same cast, and use the existing CanPrepare hook, which receives original input after correction of the Spell's copy. Explicit self for healing is allowed; missing target or unresolved supplied GUID must not silently become self under the proposed exact-unit Slice-1 policy. Source origin must be trusted, not inferred from corrected self. Preserve native fallback for unbound spells. No queue-generation or lease safety is solved by this capture.

The packet → targets.Read → Spell → prepare → correction path and minimal future state are detailed in the seam companion. No Spell.cpp change was made.

## 16. Pre-native Potency seam

POTENCY_SEAM_PROPOSAL: use existing `Spell::SetSpellValue(SPELLVALUE_BASE_POINT0, resolvedBase)` after freezing a valid custom Forge snapshot, before native effect calculations. This changes cast-local SpellValue rather than shared SpellInfo. With carrier DieSides=1, CalcBaseValue/CalcValue cancel the transport +1 convention; the semantic roll is frozen once.

The alternative OnEffectLaunchTarget/SetEffectValue hook is after CalcValue and would discard already-applied effect spellmods if used blindly. Two branches in EffectSchoolDMG/EffectHeal duplicate policy. Current Ulduar OnHit scaling is too late and must not multiply Potency again for this new policy. Prefer the earlier existing setter, with explicit script binding, snapshot ownership and amount bounds. Keep the one native effect/event path and all later native mitigation, heal absorb, logs, threat and procs.

This is a source-change proposal, not currently implemented custom carrier behavior. The module's pending custom entries still cannot bind. See the companion for exact source anchors and legacy/secondary constraints.

## 17. Coefficient ownership

Ulduar owns ResolvedAbilityPotency as semantic base amount, including its one base roll, excluding SP/AP. NativeBonusContribution owns the reviewed coefficient contribution once. TargetTakenModifiers, crit and mitigation retain their existing native stages.

Actual source flow differs from a universal base → bonus → crit → all mitigation diagram: damage/heal bonus-done and taken amounts are assembled at launch; crit outcome is stored per target. At damage impact, Physical armor can precede critical bonus, followed by resilience and absorb/resist. Healing critical bonus precedes HealBySpell, its received-heal hook and heal absorb; effective gain then drives threat. No new ordering is implemented here.

The proposed exact diagnostic coefficients remain MD0, RPD0.123, MH0.231, RH0.481 SP, with AP/DOT0. DBC coefficients, actual spell_bonus_data and core corrections must agree with that ownership. Do not add a coefficient to Ulduar base and again in native bonus functions. Do not multiply Potency in OnHit after native bonuses. Provenance-aware talent/passive filtering remains required source behavior; GENERIC/zero masks cannot establish it.

## 18. Mana baseline decision

KEEP_NATIVE_BASE_MANA_FOR_DIAGNOSTIC_SLICE. This is explicitly a temporary diagnostic choice, not class-neutral production balance. It proves Forge composition/transport without prematurely adding ResourceService or a second debit. Client and server must use the same exact native cost fields and ordinary applicable modifiers.

| Family | Range / cast / speed | Native base-Mana % | Semantic base roll | SP coefficient |
| --- | --- | --- | --- | --- |
| MeleeDamage | Contact Range2 / 0 ms / 0 | 3 | 25 | 0 |
| RangedProjectileDamage | Range5 0..40 / 2500 ms / 24 | 9 | 13..17 | .123 |
| MeleeHealing | Contact Range2 / 0 ms / 0 | 7 | 46..56 | .231 |
| RangedHealing | Range5 0..40 / 2500 ms / 0 | 29 | 50..60 | .481 |

These are A.8's exact PROVISIONAL_SLICE1 fixtures, not final balance or usable rows. Flat/per-level/per-second cost0; shared spell GCD category133, base1500 ms with reviewed native haste/floor; own/category cooldown0 and category0. BaseLevel/SpellLevel1, MaxLevel0 and no level/combo amount scaling. Physical contact is reach semantics, not five yards of fixed center distance.

Percentage-of-base-Mana produces different absolute costs on different native chassis. Diagnostic observations must label that limitation. Before a production class-neutral economy, choose a matched flat-cost profile or a specified Ulduar baseline; this phase neither implements one nor creates arbitrary new envelopes. Per-instance cost deviations cannot be hidden under an unchanged client shell. One native debit remains authoritative.

## 19. Spellbook / icon policy

SPELLBOOK_POLICY_STATIC_CONFIDENCE: MEDIUM overall; actual custom-spell tab/drag behavior remains BLOCKED_CLIENT.

Read-only archive inspection found SpellBookFrame.lua and ActionButton.lua in the conditional patch-enUS-2 selection. SpellBookFrame uses GetNumSpellTabs/GetSpellTabInfo, GetSpellName/GetSpellTexture and PickupSpell; these client APIs, not this Lua alone, determine population and indexes. Source/hash/excerpts are in the visual graph inventory. Lua was read, never executed.

Server Player known-spell updates and action-button validation establish server representation, not the client's General tab. A server-granted visible known spell without a native class SkillLineAbility is still a client evidence gap. Clear hidden/passive flags and use exact known native icon references, but do not claim a visible General-tab entry or drag/drop behavior from those flags alone. No custom SkillLine or SkillLineAbility row is authored. Entitlement remains AbilityInstance/Ulduar progression, not native class/trainer history.

Holy Light 635 remains SOURCE_COMPATIBLE, NATIVE_EXCEPTION, NOT CLASS_NEUTRAL, REPLACE_WHEN_CUSTOM_READY. It is not evidence that a new generic spell will populate the same UI. No later ranks are approved. Mongoose Bite 1495 and Holy Bolts 31759/34232 remain research-only; no contracts/catalog promotion.

HeroFreePick remains solely future Character Advancement/category/pending-build/progression/optional Free Pick presentation reference. No code, assets, custom Ascension IDs, essence or rarity metadata were imported or used to resolve transport.

## 20. Artifact-readiness recheck

| Gate | MD | RPD | MH | RH |
| --- | --- | --- | --- | --- |
| Safe ID assignable in subsequent reservation phase | No | No | No | No |
| Complete approved attribute words | No | No | No | No |
| DmgClass/defense design decided | Yes, source-only | Yes, source-only | Yes, source-only | Yes, source-only |
| Exact diagnostic numeric envelope | Yes, provisional fixture | Yes, provisional fixture | Yes, provisional fixture | Yes, provisional fixture |
| Critical effective-package visual closure | Partial | Partial; missile assets located | Partial | Partial |
| Required source seams understood | Design documented | Design documented | Design documented | Design documented |
| No unresolved serialization/data choice | No | No | No | No |
| Result | NOT_ARTIFACT_READY | NOT_ARTIFACT_READY | NOT_ARTIFACT_READY | NOT_ARTIFACT_READY |

Understanding a future seam does not implement it. ARTIFACT_READY would only authorize a later isolated artifact-authoring proposal, never RuntimeEligible. Neither status is promoted here.

## 21. Remaining blockers

1. Supported release owner/membership, actual native archive precedence and effective table selection are not pinned. No approved optional sets or supported release history were found.
2. No trustworthy offline effective world export, installed updates_include/updates hashes, complete linked module evidence or editor publication/retirement history. Repository SQL cannot substitute.
3. Namespace absence/collision proof is incomplete. No ledger/reservation is justified; high/sparse IDs are not a workaround.
4. Full visual interpretation/dependencies, exact attribute words, client contact-heal range/target feedback and custom spellbook behavior remain blocked.
5. Healing threat, original intent and Potency are design proposals. Provenance-aware native talent suppression, cooldown debt, lease drain/quarantine and manifest enforcement remain distinct source requirements. Data fields cannot solve them.
6. There is no new runtime evidence for any carrier, bonus/defense/threat behavior or client presentation. Tests remain authored only; none were run in A.9.

## 22. Exact next safe phase

Remain in read-only evidence work until the release inputs are approved and existing offline evidence can establish effective state. The next bounded task is to reconcile an explicitly selected supported client archive set and locale, identify authoritative native overlay evidence, obtain an already-existing trustworthy world/update export if available, and reconcile published/editor history against it. Review the remaining flagged attributes and complete the visual dependency parser/source evidence against that selected package.

Only after that review proves a namespace and completes serialization choices should a separate reservation/artifact-authoring proposal identify exact isolated outputs. No reservation, generator, live export command or source implementation is authorized by this report. Later source work must explicitly scope the three seams and the remaining provenance/cooldown/lease/manifest contracts. No next phase was begun automatically.

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
