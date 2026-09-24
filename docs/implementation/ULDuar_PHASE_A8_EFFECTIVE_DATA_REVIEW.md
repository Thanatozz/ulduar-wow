# ULDuar Phase A.8 - Effective data and carrier specification review

Date: 2026-09-19. Evidence: SOURCE_ONLY. Phase status: COMPLETE (review and design deliverables only).
Target release: PARTIAL. Namespace: NAMESPACE_UNRESOLVED. All four carriers: NOT_ARTIFACT_READY.

## 1. Executive summary

The local evidence supports a concrete four-envelope design, but cannot prove an unoccupied production namespace.
The release has no authoritative effective-world-data export, supported-release manifest or resolved client overlay
inventory. Loose DBCs, source SQL and historical editor outputs are different evidence sets, not one installed release.
No numeric reservation or usable carrier is produced here.

Four source findings materially affect the design:

- Physical school with MAGIC defense uses spell hit and armor, but starts with zero native spell critical chance.
  Slice 1 should explicitly disable crit for this contact-damage prototype, pending a generic crit design.
- Healing threat in Spell.cpp additionally depends on the caster being Paladin, even for a Generic spell family.
  Generic family and zero masks therefore do not provide class-neutral healing behavior.
- Native bonus-done calculations use the DBC effect bonus coefficient, overridden by spell_bonus_data.
  Cast-time-derived fallback exists in other bonus paths; it is incorrect to assume one universal coefficient rule.
- Spell::InitExplicitTargets can supply the caster for a missing ally target. The A.7 explicit-target/no-fallback
  policy needs a reviewed boundary before that correction; DBC target flags alone do not enforce it.

The recommendation is one exact client envelope per family, native combat execution, and a future single resolved
payload input before native bonus/mitigation. Artifact authoring remains blocked by namespace and client dependencies.
Holy Light 635 remains SOURCE_COMPATIBLE, NATIVE_EXCEPTION, NOT CLASS_NEUTRAL, REPLACE_WHEN_CUSTOM_READY.
1495, 31759 and 34232 remain research references; catalog, contracts and allowlists are unchanged.

Companion evidence:

- [Namespace inventory](../audits/ULDuar_CARRIER_NAMESPACE_INVENTORY.md)
- [Reference rows](../audits/ULDuar_CARRIER_REFERENCE_ROWS.md)
- [All four field-completion matrices](../audits/ULDuar_CARRIER_SPEC_COMPLETION_MATRIX.md)
- [DBC, SQL and source audit](../audits/ULDuar_A8_DATA_INVENTORY.json)
- [External container/metadata hashes](../audits/ULDuar_A8_EXTERNAL_INVENTORY.json)
- [Protected-file baseline](../audits/ULDuar_A8_PROTECTED_FILE_HASHES.json)

## 2. Scope / NO-BUILD statement

This is a source/data-spec review. PowerShell, Git read-only queries and standalone Python byte/text parsing were
used. Python did not import or execute project code. Its only writes were audit JSON and Markdown under docs/.
No production generator, database connection, SQL execution, editor, client, server, compiler or build system ran.
No C++/Lua test or project executable ran. Existing authored tests remain AUTHORED_NOT_RUN.

The mandatory architectural documents, A/A.5/A.6/A.7 reports, namespace policy and carrier source informed this
review. Relevant engine paths were inspected directly. Earlier report assertions do not substitute for current code.
No PR/commit is created. The code-review guide's C++/SQL linters do not apply to changed C++/SQL lines: there are none.
This task's explicit no-runtime constraint also precludes the usual in-game review workflow.

Preservation results and exact output files are recorded in the namespace companion. Pre-existing dirty core files,
untracked module code and deleted module skeleton files were preserved, not restored or committed.
Final preservation: 9,992 protected existing files byte-identical; 0 existing files changed or removed;
9 new documentation/audit files only. The matrix contains 204 field rows and this report has all 24 sections.

## 3. Target release snapshot

```text
TargetReleaseSnapshot
  coreRevision: d7ce67dc1800f092bac98aad680ece1c201b89a0
  serverSourceRevision: coreRevision + existing dirty Unit/Spell/SpellEffects files
  moduleRevision: 5f51c5e012b153b1edae00af2b0e11a9d45ba62d + untracked Ulduar implementation
  clientBuild: Client/Wow.exe version resource 3,3,5,12340; historical registry also cites 12340
  locale: Client/WTF/Config.wtf sets enUS; supported release locale set UNKNOWN
  dbcSource: A and B byte-identical relevant tables; release authority UNKNOWN
  clientExtractSource: registry cites Client/Data/enUS/patch-enUS-3.MPQ
  sqlSourceSet: repository base/updates/pending/module files; installed set UNKNOWN
  moduleSourceSet: five local modules; enabled/deployed set UNKNOWN
  editorArtifactSet: historical M2 editor registries and patch staging; supported set UNKNOWN
  evidenceLevel: SOURCE_ONLY
```

TARGET denotes the expressly requested source checkout, including its hashed local modifications. The module Git
commit alone does not identify its current implementation. No branch head or folder name proves deployed contents.
The current config says DataDir="./Data" and DBC.Locale=255 (automatic selection), not a pinned release locale.
Historical registry hashes match A's Spell and Visual inputs and identify an enUS archive; this improves provenance
without proving that later patch-U or other overlays leave those inputs effective and unchanged.
The client version resource was read as metadata, without launching it. Its hash is in the external inventory.
The build and local locale are therefore observed; release ownership and supported packages remain unresolved.

| Set | Classification | Meaning |
| --- | --- | --- |
| Requested core/module source and repository SQL | TARGET | Review target; installation not attested |
| A: a/Data/dbc | UNKNOWN | Strong reference provenance; authority unpinned |
| B: ulduar-build/bin/RelWithDebInfo/Data/dbc | UNKNOWN | Config-compatible data copy; no runtime claim |
| E: WoW Spell Editor/DBC_335_wotlk | REFERENCE_ONLY | Editor input differs from A |
| Vanilla/TBC editor tables | REFERENCE_ONLY | Wrong build for target occupancy |
| F/M visual outputs and staged patches | UNKNOWN | Historical custom occupancy; release status unknown |
| Client/Data MPQs | UNKNOWN | Present and hashed; effective overlay contents unknown |
| Ascension/TrinityCore/reference trees | REFERENCE_ONLY | Never transport allocation authority |

No set is called LEGACY merely because it is old: retirement/support evidence is missing.
TARGET_DATASET_UNRESOLVED remains the effective-data conclusion.

## 4. Data-source inventory

Discovery covered C:/WoWProjecto loose DBCs, project source/module/client/SQL trees, editor output and patch staging.
The machine-readable inventory contains complete discovered row-ID sets, hashes, sizes, header layouts and sparse
counts for the selected DBC tables. SQL is inventoried as source text, with explicitly limited literal-ID extraction.
Reference-only and historical sources are kept separate from the tentative WotLK footprint.

Additional dependencies include SpellVisualKit, SpellVisualEffectName, SpellMissile/Motion, visual attachments,
SoundEntries, SkillLine and precast/area tables. Container hashes do not decode models, texture references or sounds.
Packed tables, live-only editor content, dynamic SQL references and supported historical packages remain unknown.

Five source modules are present: mod-ulduar-abilities, mod-ulduar-editor, mod-ulduar-wave-survival,
mod-density-test and mod-citybuilder. Presence is not proof of load configuration or entitlement ownership.

## 5. Dataset classification and hashes

The namespace companion gives per-file metadata and hash groups. Important differences are preserved explicitly:

- A/B Spell: 49,839 rows, IDs 1..80864; identical full-file SHA-256.
- E Spell: same ID set, different bytes. Localized string offsets/flags differ widely; Spell 5 also differs in
  effect value multipliers. Equal occupancy is not equal effective semantics.
- A/B Visual: 9,406 rows. F includes 16680; M includes 16680..16684; E includes 17000.
- Range, CastTimes and Icon references in A/B/E match byte-for-byte. SkillLineAbility exists in A/B.

The 29 six-table files from A.7 expand to 68 files when the initially identified visual/audio/skill dependencies
are included. Additional dependency and asset evidence, where present, is listed separately in the audit inventory.
Neither file dates nor maximum IDs establish authority or available allocation space.

## 6. Effective namespace approximation

Spell row evidence begins with 49,839 A rows plus 4,491 repository base spell_dbc rows. These sets are disjoint:
54,330 observed IDs before other reference classes. Base SQL includes 100001 and 100099..100102 above A's maximum.
This is an occupancy lower bound, not the loaded SpellInfo set. Current updates, pending SQL, scripts, modules,
items/creatures and client metadata can add constraints; applied-update and out-of-repository data remain unknown.

Categories are typed: ROW_DEFINED, SQL_OVERRIDE, SCRIPT_BOUND, REFERENCED, EDITOR_RESERVED,
HISTORICAL_PUBLISHED and UNKNOWN. A script binding or item spell field constrains reuse but does not create a row.
An editor visual ID is not a Spell ID. Historical creation does not prove publication; no publication status is
invented. Lexical source references may include synthetic/test constants and are conservative candidates for review.

DBCStores loads mapped SQL overlays after file records. World initialization then constructs SpellInfo and applies
cooldown overrides, corrections, ranks, specific/aura-state classification, skill mapping and custom attributes.
Scripts, conditions, proc rows, bonus rows and threat rows further constrain behavior. Approval must inspect this
effective interpretation, not just compare a generated Spell.dbc row with its design record.

## 7. Namespace decision

NAMESPACE_UNRESOLVED. No interval is proposed, reserved or allocated.

Sparse gaps exist, but cannot satisfy all required exclusion classes. Missing evidence includes effective SQL,
client overlay tables, supported historical releases and reconciled editor allocations. A broad lexical scan cannot
prove the absence of dynamic or packed definitions. max(ID)+1 is expressly rejected.

The A.7 append-only, owner/spec/release-aware ledger policy remains mandatory. Allocation must cite a complete
collision audit and immutable dataset hashes. Never reuse an introduced ID while any supported release can refer
to it. Native dependency reuse is a reference declaration, not an allocation.

In addition to uint32 packet fields, Player.h limits action-button values to below 0x01000000 (24 bits).
DBCDatabaseLoader sizes sparse indices using the highest ID plus one. Both action representation and allocation
memory/overflow limits must be reviewed; a number fitting the cast packet does not prove carrier suitability.

## 8. Capacity policy

V1 permits one exact range/cast/cost/GCD/cooldown/presentation envelope per family. Contact families are instant;
the ranged projectile and ranged heal have one exact positive cast time each. Custom numeric variation belongs in
semantic payload resolution, not arbitrary mutation of client-visible timing, cost, school or range.

For six simultaneously active instances of any family distribution, provision conceptually six distinct copies
per family: 4 x 6 = 24 Spell IDs. This is capacity planning, not an allocated block. Current gameplay remains one slot.
Only four definitions are needed to describe the envelopes; transport copies must still have unique Spell IDs.
Six shared IDs cannot represent arbitrary simultaneous mixes when each ID has immutable family metadata.

If family f gains E_f incompatible envelopes, unrestricted six-slot support costs 6 * sum(E_f) copies.
Slot-specific copies also cost 24 for these four profiles; they do not solve packet ambiguity or presentation.
Compatible exact-envelope leases are preferred over new variants. Quarantined IDs remain unavailable: 24 bounds
simultaneously active capacity, not unlimited same-session swaps. V1 must reject swaps that exhaust safe leases.

A.7's ACTIVE -> DRAINING -> QUARANTINED -> FREE preconditions remain. No reuse for another instance/material
revision in the same native transport session. Drain casts, queues, children and projectiles; retain reject
tombstones and cooldown debt. An arbitrary delay or addon acknowledgement is not proof that old packets cannot land.

## 9. Technical versus balance decisions

The completion matrix classifies every A.7 field, including nested unknowns in otherwise FIXED fields.

| Decision | Class | Result |
| --- | --- | --- |
| Defense, target/effect shape, family, power type | ENGINE_TECHNICAL | Explicit policies below |
| Cost amount, payload magnitude, initial coefficients | BALANCE | PROVISIONAL_SLICE1 values |
| Range, base timing, missile speed, GCD | UX_TECHNICAL + BALANCE | One exact envelope |
| Visual/icon identity and dependencies | CONTENT + CLIENT_EVIDENCE | Candidates, closure missing |
| Full attribute words, queue/proc provenance | ENGINE_TECHNICAL + RUNTIME_EVIDENCE | Partial; gates retained |
| Skill-line/tab, local target/cost feedback | CLIENT_EVIDENCE | Not proved by server source |
| Assigned ID and effective package | ENGINE_TECHNICAL | Namespace/release blockers |

No placeholder is labelled final balance. Technical policy readiness does not imply runtime behavior was observed.

## 10. MeleeDamage technical profile

Recommend spell-like Physical contact damage, not native weapon/melee resolution, for the first isolated prototype.
Use MAGIC=1, Physical school mask=1, SCHOOL_DAMAGE=2, enemy A=6, B=0, one independent instant effect.
No weapon percentage, next-swing, combo, equipment or form dependency. Use native contact Range 2 as a reference.

| Dimension | Recommended MAGIC Physical | Native MELEE alternative |
| --- | --- | --- |
| Hit | MagicSpellHitResult; spell hit rules | MeleeSpellHitResult; melee hit/avoidance |
| Crit | Explicitly disabled in Slice 1 | Native melee crit/stat dependencies |
| Mitigation | Physical armor, absorbs, immunities | Armor plus native block path |
| Dodge/parry/block | Not the melee avoidance path | Eligible subject to native flags/position |
| Attack type | BASE_ATTACK bookkeeping | BASE_ATTACK, possibly offhand requirements |
| Events | Negative magic-class spell event | Melee spell and potential weapon events |
| Weapon | No weapon payload or requirement | Additional coupling must be reviewed |

Unit.cpp:9166 starts MAGIC Physical crit at zero; later target/spell modifiers can change chance. Set CANT_CRIT
explicitly for this provisional profile to avoid accidental aura-granted crit. This is a deliberate prototype
limitation, not a claim that generic Forge Critical Chance already applies. A future semantic crit adapter must
revisit this before promising parity with the other profiles. Method describes contact acquisition, not defense.

Armor is applied before the damage-class switch in CalculateSpellDamageTaken. MAGIC does not bypass Physical
armor. Keep ordinary immunity/absorb/reflect/deflect behavior; do not add ALWAYS_HIT or immunity-bypass flags.
Require the caster to face the enemy (FacingCasterFlags=1, independent of defense class). BASE_ATTACK here does
not authorize weapon damage or weapon procs. The alternative is feasible design-wise but imports melee stat and
avoidance semantics that Forge has not established as a property of contact geometry.

Individual references: 1495 for contact/instant/Mana/GCD, 2816 for a Generic direct Physical effect,
585 for MAGIC spell hit/normal spell activation. None is cloned or promoted.

## 11. RangedProjectileDamage technical profile

Holy mask=2, Mana, MAGIC=1, SCHOOL_DAMAGE=2, enemy A=6, B=0. Propose Range 5 (0..40), CastTimes 20
(2500 ms), Speed=24 from 31759/34232. Require forward facing=1; retain normal cast interrupts and movement rules.
Use visual 7873 as candidate: missile effect-name 224, cast kit 119, impact kit 121, precast kit 184.

Native magic hit, Holy crit, reflect/deflect, immunity and absorb paths remain. No Physical armor for pure Holy.
Unit::CalcAbsorbResist excludes pure Holy against players from its ordinary partial-resistance branch, but allows
that branch against creatures. Effective resistance can include level difference. Immunity and absorb are separate.
No per-cast Nature-to-Holy conversion is needed; client and server author Holy.
Specify a coefficient directly instead of inheriting the NPC Holy Bolt's 1.0 raw multiplier or assuming cast/3.5.
Smite supplies a conservative initial damage/coefficient reference, not its direct delivery or Priest family.

## 12. MeleeHealing technical profile

Holy, Mana, MAGIC=1, HEAL=10, ally A=21, B=0, instant, native contact Range 2, Speed=0.
Explicit self-target allowed; no server fallback from an invalid enemy/dead target. Living assist targets only.
FacingCasterFlags=0. Contact does not require a melee attack class, dodge, parry, block or weapon metadata.

This is the desired policy. Current Spell::InitExplicitTargets (Spell.cpp:735) may choose player selection and then
self when an object target is absent. An explicitly provided illegal object is a different case. A later Forge
boundary must distinguish original packet intent from the corrected target if strict no-fallback is retained.
That boundary is not implemented or established by A.6; both healing profiles retain BLOCKED_RUNTIME here.

Native positive-spell handling bypasses ordinary hostile hit rolls after its initial immunity check.
Heal crit uses Holy spell crit and the native healing critical bonus path. Healing modifiers, heal absorbs and
effective-overheal reporting remain part of normal execution. Range 2's reach flags are a server reference;
friendly contact feedback and automatic self-target behavior remain BLOCKED_CLIENT.

Desired neutral threat is 0.5 * effective gain before reviewed threat modifiers. Current Spell.cpp:2817 also
halves that for a Paladin caster. This violates the desired class-neutral baseline independently of family masks.
Do not declare it solved by data. A later separately authorized source design must address the scoped threat path;
no change is made here. References: 25914 instant HEAL structure, 635 ally/crit behavior, 1495 contact range only.

## 13. RangedHealing technical profile

Use Holy, Mana, MAGIC=1, HEAL=10, ally A=21, B=0, Range 5, CastTimes 20, Speed=0, facing=0.
Holy Light 635 remains an individual-field reference, not the identity of the custom spell.

| Field group | Decision |
| --- | --- |
| 40-yard range, 2500 ms cast, ally HEAL, Holy, no missile | KEEP AS REFERENCE |
| Crit/heal path, ordinary GCD, interrupt flags 0xF | KEEP AS REFERENCE; effective review still required |
| Family 10, family masks, trainer/class eligibility | REPLACE WITH GENERIC / Ulduar entitlement |
| NOT_SHAPESHIFTED | REQUIRED_CLEAR; do not inherit |
| 29% base-Mana formula and amount | BALANCE LATER; proposed initial comparison below |
| Rank/level scaling, 0.481 coefficient and heal range | BALANCE LATER; explicit prototype choices |
| Visual 2936 and icon 70 | Reference candidates; dependency/UI evidence required |
| Paladin threat reduction | Unwanted code coupling; BLOCKED_RUNTIME |

No later Holy Light rank is approved. Cost neutrality also requires a defined Ulduar resource baseline: the current
native percentage formula uses the character's create-Mana, which may vary with native class. Percentage equality
alone is not class-independent absolute cost. The proposed isolated fixtures below explicitly retain that limitation.

## 14. V1 provisional numerical baseline

Every numeric gameplay value in this section is PROVISIONAL_SLICE1, not final balance or an emitted artifact.
These values make the proposed staging fixtures concrete once technical gates are satisfied.

| Profile | Range | Cast ms | Speed | Mana base % | Base payload | SP coefficient |
| --- | --- | --- | --- | --- | --- | --- |
| MeleeDamage | Contact / Range 2 | 0 | 0 | 3 | 25 fixed | 0 |
| RangedProjectileDamage | 0..40 / Range 5 | 2500 | 24 | 9 | 13..17 | 0.123 |
| MeleeHealing | Contact / Range 2 | 0 | 0 | 7 | 46..56 | 0.231 |
| RangedHealing | 0..40 / Range 5 | 2500 | 0 | 29 | 50..60 | 0.481 |

Mana percentages are references from 1495, 585, 19750 and 635 respectively; flat Mana=0, per-level/per-second=0.
Use the existing CalcPowerCost order/rounding and exactly one native debit. This is an explicitly native-cost
fixture, not final class-neutral resource authority. Future class-neutral Mana economy must define its base pool
or adopt a matched flat-cost profile; arbitrary per-instance cost changes cannot share these exact envelopes.

Payload references: 1495 raw basepoints24/die1; 585 base12/die5; 2050 base45/die11; 635 base49/die11.
Those describe the native base roll before scaling, modifiers and mitigation. Healing contact borrows the low-rank
Lesser Heal payload, not Holy Shock's high-level amount. Mongoose's AP coefficient 0.2 is explicitly discarded.
The native coefficient references for 585/2050/635 appear in both raw data and base spell_bonus_data.

Common proposal: own recovery=0, category recovery=0, category=0; StartRecoveryCategory=133, time=1500 ms.
AP/DOT coefficients=0; no periodic effect; no per-level dice scaling. For the isolated fixed fixture, author
SpellLevel=1, BaseLevel=1, MaxLevel=0 and effect points-per-level/combo scaling=0. CalculateLevelPenalty then returns
1 by source, avoiding hidden low-rank scaling. These are fixture values; character level remains relevant to hit
and combat. Native source levels/rank chains are not copied.

Exact raw field encoding must still be checked against effective corrections and all unused fields before authoring.
No numerical balance omission remains for this fixture; technical/client/namespace blockers do remain.

## 15. GCD / cooldown policy

Choose normal shared spell GCD: category 133, 1500 ms base, ordinary reviewed haste/spellmods and native 1000 ms
floor. MAGIC and IS_ABILITY clear preserve the spell-GCD haste branch in Spell.cpp:9113.
Zero own recovery means no own cooldown, not GCD-less casting. No class cooldown category or event-started cooldown.

Spell Category=0, Recovery=0 and CategoryRecovery=0 are proposed for the one-slot fixture. Category also keys
GetCastRequest in PlayerUpdates.cpp, so zero is not proof of six independent queues. V1 accepts one shared native
queued intent, not six independent queued actions. Multi-slot queue policy must be reviewed before expansion;
do not allocate unrelated category IDs merely to evade that review.

Future non-GCD debt remains owner+AbilityInstance based, with shared groups separate and native SpellID projection.
Lease/reconnect/loadout changes must preserve expiry, charge state and idempotent commit receipts. GCD remains
player-level authority. Neither cooldown service nor persistence is implemented in this phase.

## 16. Attributes policy

The following named decisions are explicit requirements, not a whole-row copy or permission to zero unknown bits.
Full words and effective custom attributes are still BLOCKED_POLICY until the remaining platform/client bits are
reviewed against the chosen package. The companion matrix keeps attributesPolicy unresolved for artifact authoring.

| Attribute word / relevant flags | Four-family policy |
| --- | --- |
| 0: ON_NEXT_SWING and ON_NEXT_SWING_NO_DAMAGE | REQUIRED_CLEAR |
| 0: IS_ABILITY, USES_RANGED_SLOT, IS_TRADESKILL | REQUIRED_CLEAR |
| 0: PASSIVE, DO_NOT_DISPLAY, DO_NOT_LOG, SERVER_ONLY | REQUIRED_CLEAR |
| 0: NOT_SHAPESHIFTED, ONLY_STEALTHED, HELD_ITEM_ONLY | REQUIRED_CLEAR |
| 0: ALLOW_CAST_WHILE_DEAD, ONLY_INDOORS/OUTDOORS | REQUIRED_CLEAR |
| 0: NOT_IN_COMBAT_ONLY_PEACEFUL, COOLDOWN_ON_EVENT | REQUIRED_CLEAR |
| 0: NO_IMMUNITIES, NO_ACTIVE_DEFENSE, SCALES_WITH_CREATURE_LEVEL | REQUIRED_CLEAR |
| 0: CANCELS_AUTO_ATTACK_COMBAT | REQUIRED_CLEAR; independent spell does not command stop |
| 0: DO_NOT_SHEATH, TRACK_TARGET_IN_CAST_PLAYER_ONLY | UNKNOWN client animation/facing feedback |
| 0: ALLOW_WHILE_MOUNTED/SITTING | REQUIRED_CLEAR |
| 1: IS_CHANNELED, IS_SELF_CHANNELED, TRACK_TARGET_IN_CHANNEL | REQUIRED_CLEAR |
| 1: USE_ALL_MANA, FINISHING_MOVE_DAMAGE/DURATION | REQUIRED_CLEAR |
| 1: INITIATE_COMBAT, NO_THREAT, ONLY_PEACEFUL_TARGETS | REQUIRED_CLEAR |
| 1: NO_REFLECTION, NO_REDIRECTION | REQUIRED_CLEAR; ordinary world interaction |
| 1: EXCLUDE_CASTER | REQUIRED_SET damage; REQUIRED_CLEAR healing |
| 1: CAST_WHEN_LEARNED, DISCOUNT_POWER_ON_MISS | REQUIRED_CLEAR |
| 2: ALLOW_DEAD_TARGET, AUTO_REPEAT, USE_SHAPESHIFT_BAR | REQUIRED_CLEAR |
| 2: IGNORE_LINE_OF_SIGHT, NO_SCHOOL_IMMUNITIES | REQUIRED_CLEAR |
| 2: INITIATE_COMBAT_POST_CAST, NOT_AN_ACTION | REQUIRED_CLEAR |
| 2: CANT_CRIT | REQUIRED_SET MeleeDamage; REQUIRED_CLEAR other three |
| 2: DO_NOT_RESET_COMBAT_TIMERS | REQUIRED_SET contact; ranged UNKNOWN |
| 2: ACTIVE_THREAT, PROC_COOLDOWN_ON_FAILURE | REQUIRED_CLEAR; no triggered-proc chain grant |
| 3: REQUIRES_OFF_HAND_WEAPON / MAIN_HAND_WEAPON | REQUIRED_CLEAR |
| 3: ALWAYS_HIT, NORMAL_RANGED_ATTACK | REQUIRED_CLEAR |
| 3: SUPPRESS_CASTER_PROCS, SUPPRESS_TARGET_PROCS | REQUIRED_CLEAR |
| 3: IGNORE_CASTER_MODIFIERS / CASTER_AND_TARGET_RESTRICTIONS | REQUIRED_CLEAR |
| 3: NOT_A_PROC, CAN_PROC_FROM_PROCS, INSTANT_TARGET_PROCS | REQUIRED_CLEAR |
| 4: SUPPRESS_WEAPON_PROCS | REQUIRED_SET; not a general spell-item proc ban |
| 4: IGNORE_DAMAGE_TAKEN_MODIFIERS, NO_CAST_LOG | REQUIRED_CLEAR |
| 4: AUTO_RANGED_COMBAT, IGNORE_COMBAT_TIMERS | REQUIRED_CLEAR |
| 4: COMBAT_FEEDBACK_WHEN_USABLE, USE_FACING_FROM_SPELL | UNKNOWN client-dependent bits |
| 5: NO_PARTIAL_RESISTS, IGNORE_CASTER_REQUIREMENETS | REQUIRED_CLEAR |
| 5: ALWAYS_LINE_OF_SIGHT, ALWAYS_AOE_LINE_OF_SIGHT | REQUIRED_CLEAR LOS exceptions |
| 6: NOT_AN_ATTACK, IGNORE_CASTER_DAMAGE_MODIFIERS | REQUIRED_CLEAR; no restriction/modifier bypass |
| 6: AURA_IS_WEAPON_PROC, AI_PRIMARY_RANGED_ATTACK | REQUIRED_CLEAR |
| 6: DOESNT_RESET_SWING_TIMER_IF_INSTANT | REQUIRED_SET contact; ranged clear |
| 7: NO_ATTACK_MISS/DODGE/PARRY, ATTACK_ON_CHARGE_TO_UNIT | REQUIRED_CLEAR |
| 7: RESET_SWING_TIMER_AT_SPELL_START | REQUIRED_CLEAR |
| Remaining cosmetic/unknown bits in words 0..7 | UNKNOWN; must be reviewed, never blindly copied |

INHERIT_PLATFORM_DEFAULT applies to normal root legality and native interrupt processing, not to an unspecified
raw bitset. Separate fields: stance masks=0; equipment class=-1 and masks=0; reagents/totems/focus=0;
channel interrupt flags=0, no channel; instant interrupt flags=0, ranged interrupt flags=0xF as native references.
PreventionType=1 (silence) is proposed for all spell-like profiles; do not copy Mongoose's pacify type=2.
Movement interrupt, pushback, facing and silence feedback require later client/runtime evidence.

## 17. Proc / event policy

Damage exposes accepted cast, negative magic-class spell hit, effective damage and kill where native semantics
produce them. Ranged Holy damage may expose critical hit; MeleeDamage explicitly cannot crit in this fixture.
Healing exposes cast, positive magic-class spell hit/heal, critical heal, attempted/effective healing and overheal.
Overheal is data on the heal event, not an invented separate native proc bit or guaranteed listener invocation.
Miss, immune, reflected, absorbed and zero-effective outcomes retain their correct event/result masks.

Reviewed generic items, encounters and world buffs/debuffs may observe these events. Weapon-swing-only item procs
do not become spell procs just because contact is called Melee. No blanket caster/target proc suppression is allowed.
Native row ProcFlags=0, ProcChance=0, ProcCharges=0 for these non-aura shells means no resident proc aura;
it does not suppress cast/hit events sent to other listeners. Do not copy a proc aura's trigger metadata.

A.7 provenance policy remains: ALLOW_GENERIC world mechanics; ALLOW_IF_EXPLICIT reviewed item/buff origins;
DENY_NATIVE_CLASS_ORIGIN unrelated class talents/passives; REQUIRES_REVIEW broad spellmods/override scripts and
cost/crit/hit modifiers; UNKNOWN origin cannot silently gain eligibility. Active class-cast world buffs require
explicit interaction review rather than a blanket ban on every class-origin spell.

Generic family with zero masks is not isolation. Broad school filters, override-class scripts and direct class
checks can still apply. No provenance filter/suppression is implemented. Runtime-neutrality remains unproved.

## 18. Coefficient / payload policy

SpellInfo.cpp:339 copies EffectBonusMultiplier (DBC words 229..231). SpellDamageBonusDone and
SpellHealingBonusDone begin with this coefficient; spell_bonus_data can override it and add AP contributions.
Bonus-taken paths can calculate cast-time-derived defaults when no explicit bonus entry exists, including the
healing factor 1.88. GetCastingTimeForBonus clamps ordinary direct spell time to 1500..7000 ms and handles
area/multiple-effect penalties. CalculateLevelPenalty separately applies rank/level rules. Do not conflate them.

An explicit future effective coefficient record must cover both done and taken paths. Merely setting the DBC
coefficient to zero does not prove that all flat victim modifiers disappear. No broad IGNORE_CASTER_MODIFIERS
flag should be used to hide this problem: it would remove intended world interactions too.

| Payload option | Assessment |
| --- | --- |
| A: meaningful native base | Best reference fixture; native logs/crit/threat; risks two scaling owners later |
| B: minimal payload replaced before native execution | Recommended future architecture; requires a reviewed seam |
| C: zero plus separate custom execution | Reject for this slice: duplicates native timing/event/combat obligations |

Recommendation B retains one native SCHOOL_DAMAGE/HEAL effect and one native execution path. A later adapter
supplies ResolvedAbilityPotency exactly once before bonuses, crit and mitigation, replacing the transport baseline.
It must not execute a second damage/heal after the native effect. Native logs, threat, immunities, absorbs and proc
reporting remain owned by that one path. A minimal native fallback must never execute when a Forge binding fails.

CarrierBasePayload is an inert transport seed (proposed raw basepoints=0, die=1, hence one unit before replacement).
ResolvedAbilityPotency is the single rolled base amount from section 14 and future semantic modifiers.
NativeBonusContribution is the explicitly reviewed SP/AP and world-aura contribution, not a second Ulduar Potency
multiplier. Coefficients above are provisional native contributions, with AP=0 and no hidden rank scaling.

The one-unit shell seed and section 14's semantic payload are deliberately different quantities. The latter may
be used as a meaningful native reference fixture (option A) only in a later explicitly identified diagnostic
artifact, not mislabeled as the final option-B carrier. Current A.6 preserves native primary magnitude and has no
general custom Potency adapter. Option B therefore adds BLOCKED_RUNTIME requirements, not an implemented feature.

For V1, no arbitrary payload value can become a truthful native tooltip automatically. Exact fixture values and
later resolved names/icons/tooltips need a presentation contract; addon work is outside this phase.

## 19. Visual dependency review

The reference companion records decoded rows and edges, including kits, effect-name paths and sounds.

| Profile | Candidate visual | Static dependency summary |
| --- | --- | --- |
| MeleeDamage | 342 from 1495 | Kits 506/11065; effect 416; melee animation/proc detail needs review |
| RangedProjectileDamage | 7873 | Kits 184/119/121; effects 135/129/224; missile sound 3012 |
| MeleeHealing | 135 from 25914 | Kits 99/270/232; effects 130/135/249; no missile |
| RangedHealing | 2936 | Kits 99/270/154; effects 130/135/244; no missile |

SpellMissileID=0 in these source spells; a visible missile can instead be carried by SpellVisual's missile model
and native Spell.Speed. Do not invent a required nonzero SpellMissile row. Candidate motion IDs are zero.
Kit sound and animation IDs, attachment/area rows and character-procedure fields must also be reviewed.
Visual 342's kit 506 has a character procedure and melee animation; this is not yet a neutral presentation approval.

The loose table graph can be traced, but the target package's model-to-texture/skin and sound asset closure is not
established. MDX paths in DBCs may resolve to M2 assets through client conventions; a matching basename is not proof.
All four candidates remain VISUAL_DEPENDENCY_UNKNOWN. Hashing MPQs alone does not prove these dependencies load.
Reuse local WotLK references only. No Ascension asset/code/ID is copied or used as transport metadata.

## 20. Icon / spellbook presentation policy

Prefer static per-profile native icons for the isolated one-slot fixture, with explicit carrier names/tooltips.
Candidates: MD Icon257; RPD Icon237; MH Icon682; RH Icon70. These are existing SpellIcon references, not new IDs.
Do not claim each icon names a player AbilityInstance. Stock bars identify the SpellID; same-family copies with
different payload/name cannot be distinguished fully by one static family icon. That blocks production six-slot UX
until a reviewed naming/tooltip/projection design exists. Future addon rendering is a design option, not implemented.

Player::SendInitialSpells sends active known spells without requiring a SkillLineAbility lookup for each packet
entry. IsActionButtonDataValid requires a known SpellInfo/known spell and a representable action ID. This supports
server transport projection without proving how the native client chooses spellbook tabs or visibility.

| Alternative | Decision |
| --- | --- |
| Teach visible, no new SkillLineAbility | Preferred first fixture hypothesis; tab/drag UX BLOCKED_CLIENT |
| Show under General | Desired neutral presentation; exact existing skill mapping requires client evidence |
| Hide normal spellbook | Defer; can break stock discovery/action placement |
| Addon-managed presentation | Future only; cannot erase native local cast restrictions |
| New custom skill line | Not required by inspected server send/action path; extra namespace/client work deferred |

SkillLineAbility allocation is OPTIONAL/UNKNOWN, never assumed mandatory or unnecessary on client evidence alone.
No trainer/native talent/class skill-line history grants Forge entitlement. Ulduar Progression must own instance,
carrier projection, generic talent, gem and keystone entitlements later. Native class is not that authority.
HeroFreePick remains conceptual category/build-review/UI reference only; no AP/rarity/mastery metadata defines a shell.

## 21. Spec completion matrix

The [matrix companion](../audits/ULDuar_CARRIER_SPEC_COMPLETION_MATRIX.md) covers all 51 fields of each A.7
record (204 field rows), retains each original status, and provides evidence, proposed policy, source, remaining
evidence and artifact-readiness classification. READY_STATIC applies to an individual design decision, not a
whole carrier or an executed test. Global namespace/package gates still apply to every record.

## 22. Artifact-readiness result per carrier

| Carrier | Result | Principal gates |
| --- | --- | --- |
| MeleeDamage | NOT_ARTIFACT_READY | ID, attributes, visual closure, payload/crit integration |
| RangedProjectileDamage | NOT_ARTIFACT_READY | ID, attributes, visual closure, payload adapter |
| MeleeHealing | NOT_ARTIFACT_READY | ID, attributes, contact client evidence, class-neutral threat |
| RangedHealing | NOT_ARTIFACT_READY | ID, attributes, visual closure, class-neutral threat |

Numerical fixture proposals and MAGIC defense choices are explicit. They do not clear missing IDs, required raw
attribute decisions or critical visual dependencies. ARTIFACT_READY would mean only isolated future staging
authoring, not runtime eligibility; none meets even that narrower gate yet.

## 23. Remaining blockers

1. Authoritative target release, supported locales, effective client overlays and supported historical packages.
2. Authorized offline effective-world-data export and applied update/module manifest; no live query is authorized.
3. Collision proof plus append-only reservation process; no ID is assumed free.
4. Complete attributes and visual/model/texture/sound/animation closure for the exact package.
5. Client evidence for friendly contact, spellbook/tab/action projection, costs, facing and timing.
6. Scoped class-neutral threat, resource baseline and aura/proc/crit policies; Generic family is insufficient.
7. One pre-native Potency input, explicit done/taken coefficient ownership and no native fallback on invalid binding.
8. Effective-data review of corrections, scripts, conditions, ranks, procs, bonuses, threat and entitlements.
9. Queue/drain/quarantine and future cooldown projection before any multi-slot lease reuse.
10. Explicit target intent before native missing-target correction; source currently permits ally self fallback.

These are recorded missing prerequisites, not failures of executed tests. No test was executed.

## 24. Exact next safe phase

Recommend a separately authorized offline evidence-completion phase: designate the intended release and obtain
its existing exports/manifests, inspect effective client tables/assets read-only, reconcile historical allocations,
and finish the raw attribute/neutrality decision record. No production data emission is justified yet.

Only after namespace disjointness, package closure, exact required fields and review ownership are established may
a later authorized phase reserve IDs and author isolated staging artifacts. Runtime/client execution requires its
own later authorization. This phase does not automatically begin either activity.

NO COMPILATION WAS PERFORMED.
NO BUILD SYSTEM WAS RUN.
NO TESTS WERE EXECUTED.
NO SERVER WAS STARTED.
NO DATABASE WAS QUERIED OR MODIFIED.
NO SQL WAS EXECUTED OR MODIFIED.
NO DBC WAS GENERATED OR MODIFIED.
NO MPQ WAS GENERATED OR MODIFIED.
NO CLIENT PATCH WAS APPLIED.
NO PRODUCTION ID WAS ALLOCATED.
