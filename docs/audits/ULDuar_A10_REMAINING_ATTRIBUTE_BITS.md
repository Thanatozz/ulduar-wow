# ULDuar A.10 remaining attribute bits

SOURCE_ONLY. Focused review of the 33 A.9 unresolved entries only. Earlier 223 decisions remain unchanged.

All 33 are authored CLEAR (0) for the four exact diagnostic fixtures: SERIALIZATION_DECIDED_RUNTIME_UNVERIFIED.
This is an explicit no-opt-in policy for optional/unknown capabilities, supported by simple native reference rows and
the scoped consumers below. It is not a claim that every flag is understood or that clear yields correct live UX.
No complete Spell row or production data is emitted. Family abbreviations: MD, RPD, MH, RH.

The raw A.8 reference rows 1495, 585, 2050, 635, 31759 and 34232 have all 33 listed bits clear.
This supports a conservative fixture choice; none of those research references gains a carrier contract here.

| Word / bit | Name | Family relevance | Known behavior / reason for CLEAR | Remaining evidence | Serialization blocking? |
| --- | --- | --- | --- | --- | --- |
| 0 / 0x00000800 | SPELL_ATTR0_WEARER_CASTS_PROC_TRIGGER | MD/RPD/MH/RH: No proc-trigger or item-wearer payload. | No active named server consumer; do not opt into unexplained wearer behavior. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 1 / 0x00200000 | SPELL_ATTR1_THREAT_ONLY_ON_MISS | MD/RPD/MH/RH: All; ordinary hit/heal threat. | No active named server consumer; do not request an alternate threat mode. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 1 / 0x04000000 | SPELL_ATTR1_REQUIRE_ALL_TARGETS | MD/RPD/MH/RH: All; one explicit unit. | No active named server consumer; target intent is enforced by frozen seam, not this uncertain flag. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 1 / 0x40000000 | SPELL_ATTR1_COMBO_ON_BLOCK | MD/RPD/MH/RH: All; no combo/reactive action. | Header dodge/combo terminology is not authority for this spell profile. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 2 / 0x00000200 | SPELL_ATTR2_ALWAYS_CAST_AS_UNIT | MD/RPD/MH/RH: All; ordinary player spell. | No extra cast-origin mode requested; explicit unit input is specified elsewhere. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 2 / 0x00004000 | SPELL_ATTR2_ALLOW_WHILE_INVISIBLE | MD/RPD/MH/RH: All; retain ordinary restrictions. | No invisibility exemption requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 2 / 0x00200000 | SPELL_ATTR2_FAIL_ON_ALL_TARGETS_IMMUNE | MD/RPD/MH/RH: No immunity aura in any fixture. | SpellAuraEffects.cpp:4026 applies flag-aura removal when combined with IMMUNITY_PURGES_EFFECT. Both are off here; no immunity-grant payload. | Observe applicable native/world interactions later; no data value missing | No; explicit 0 |
| 2 / 0x00400000 | SPELL_ATTR2_NO_INITIAL_THREAD | MD/RPD/MH/RH: All; normal combat/threat. | Name and examples do not establish meaning; do not opt into special initial behavior. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 3 / 0x80000000 | SPELL_ATTR3_NOT_ON_AOE_IMMUNE | MD/RPD/MH/RH: All; direct point, not AoE. | SpellInfo.cpp:1680 rejects creatures with ImmuneAoE when set. Clear avoids adding an AoE-specific target restriction to a point spell. | Observe applicable native/world interactions later; no data value missing | No; explicit 0 |
| 4 / 0x00000002 | SPELL_ATTR4_CLASS_TRIGGER_ONLY_ON_TARGET | MD/RPD/MH/RH: No triggering aura defined by carrier. | Spell.cpp:8987 checks this bit on triggeredByAura, not a general caster-isolation flag. Clear on carrier; outside aura/proc provenance remains runtime work. | Observe applicable native/world interactions later; no data value missing | No; explicit 0 |
| 4 / 0x00000020 | SPELL_ATTR4_ALLOW_CLIENT_TARGETING | MD/RPD/MH/RH: All; standard enemy/ally unit target. | No active consumer; explicit TargetA/flags define the fixture. Clear does not claim all client targeting is understood. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 4 / 0x00080000 | SPELL_ATTR4_ALLOW_PROC_WHILE_SITTING | MD/RPD/MH/RH: No proc aura; ordinary cast restrictions. | No sitting/proc exception requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 4 / 0x00400000 | SPELL_ATTR4_PROC_SUPPRESS_SWING_ANIM | MD/RPD/MH/RH: No weapon-proc payload. | No special proc-animation suppression requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 4 / 0x40000000 | SPELL_ATTR4_OBSOLETE | MD/RPD/MH/RH: All. | No opt-in to an obsolete/unknown feature. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 4 / 0x80000000 | SPELL_ATTR4_USE_FACING_FROM_SPELL | MD/RPD/MH/RH: All; damage facing1, healing facing0. | No active server consumer; preserve normal facing via the separate reviewed field, without enabling unknown client behavior. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 5 / 0x00000040 | SPELL_ATTR5_IGNORE_AREA_EFFECT_PVP_CHECK | MD/RPD/MH/RH: All; point spell. | Unit.cpp:10895 bypasses an area PvP eligibility check when set. Clear preserves normal rules; no area effect to justify exception. | Observe applicable native/world interactions later; no data value missing | No; explicit 0 |
| 5 / 0x00400000 | SPELL_ATTR5_NOT_ON_TRIVIAL | MD/RPD/MH/RH: All; ordinary legal targets. | No additional trivial-target restriction requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 5 / 0x80000000 | SPELL_ATTR5_ADD_MELEE_HIT_RATING | MD/RPD/MH/RH: Damage uses MAGIC defense; healing positive. | No active named consumer and contradictory header; no melee-rating override requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 6 / 0x00000002 | SPELL_ATTR6_DO_NOT_RESET_COOLDOWN_IN_ARENA | MD/RPD/MH/RH: All; own cooldown0. | No arena-only or cooldown-reset exception requested; native default and later instance debt policy remain. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 6 / 0x00000010 | SPELL_ATTR6_IGNORE_FOR_MOD_TIME_RATE | MD/RPD/MH/RH: All; exact base timing, normal modifiers. | No timing-modifier bypass requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 6 / 0x00000200 | SPELL_ATTR6_ALLOW_ON_CHARMED_TARGETS | MD/RPD/MH/RH: All; ordinary relation/control rules. | No additional charm-target exception requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 6 / 0x00000400 | SPELL_ATTR6_NO_AURA_LOG | MD/RPD/MH/RH: All; no aura payload. | SpellInfo.cpp:1800 is a commented-out condition, not an active consumer. A9 BLOCKED_RUNTIME overstates that evidence. No possessed-friend exception/log override is requested. | Client behavior unverified; only commented server condition found | No; explicit 0 |
| 6 / 0x00020000 | SPELL_ATTR6_ALLOW_EQUIP_WHILE_CASTING | MD/RPD/MH/RH: All; equipment-independent spell. | No special equipment-swap permission requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 6 / 0x00080000 | SPELL_ATTR6_DELAY_COMBAT_TIMER_DURING_CAST | MD/RPD/MH/RH: All; retained A9 timer policy. | No extra combat-timer delay requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 6 / 0x00800000 | SPELL_ATTR6_TAPS_IMMEDIATELY | MD/RPD/MH/RH: Damage especially; native outcomes. | No pre-impact tapping exception requested; later runtime must observe normal tagging behavior. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 6 / 0x10000000 | SPELL_ATTR6_DO_NOT_SELECT_TARGET_WITH_INITIATES_COMBAT | MD/RPD/MH/RH: All; INITIATE_COMBAT remains clear. | No extra target-selection exception. Original target-intent seam remains authoritative. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 7 / 0x00000001 | SPELL_ATTR7_ALLOW_SPELL_REFLECTION | MD/RPD/MH/RH: Damage native MAGIC reflection; heal friendly. | Spell.cpp m_canReflect and Unit spell-hit paths already define native reflection without this opt-in; clear is not a reflection immunity claim. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 7 / 0x00000010 | SPELL_ATTR7_TREAT_AS_RAID_BUFF | MD/RPD/MH/RH: No buff aura. | No raid-buff presentation/behavior requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 7 / 0x00020000 | SPELL_ATTR7_DO_NOT_LOG_PVP_KILL | MD/RPD/MH/RH: Damage especially. | Retain normal event presentation; no kill-log suppression requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 7 / 0x00100000 | SPELL_ATTR7_NO_CLIENT_FAIL_WHILE_STUNNED_FLEEING_CONFUSED | MD/RPD/MH/RH: All; ordinary control restrictions. | No client failure-suppression exception requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 7 / 0x10000000 | SPELL_ATTR7_DO_NOT_COUNT_FOR_PVP_SCOREBOARD | MD/RPD/MH/RH: All; no consolidated buff. | Contradictory name/header; do not enable a scoreboard/buff-consolidation exception. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 7 / 0x20000000 | SPELL_ATTR7_REFLECTION_ONLY_DEFENDS | MD/RPD/MH/RH: Damage native reflection. | No special reflection variant requested. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |
| 7 / 0x80000000 | SPELL_ATTR7_ALWAYS_CAST_LOG | MD/RPD/MH/RH: All; normal cast logging. | Do not force an extra client indicator; runtime must observe normal presentation. | Client presentation/control acceptance; flag meaning remains uncertain | No; explicit 0 |

## Complete-word design summary

Only already-reviewed set bits remain. Hex below is a documentation summary, not a generated DBC or loader manifest.

| Family | Attr0 | Attr1 | Attr2 | Attr3 | Attr4 | Attr5 | Attr6 | Attr7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MeleeDamage | 0 | 0x00080000 | 0x20020000 | 0 | 0x00800000 | 0 | 0x02000000 | 0 |
| RangedProjectileDamage | 0 | 0x00080000 | 0 | 0 | 0x00800000 | 0 | 0 | 0 |
| MeleeHealing | 0 | 0 | 0x00020000 | 0 | 0x00800000 | 0 | 0x02000000 | 0 |
| RangedHealing | 0 | 0 | 0 | 0 | 0x00800000 | 0 | 0 | 0 |

The five set decisions are EXCLUDE_CASTER for damage, CANT_CRIT only MD, DO_NOT_RESET_COMBAT_TIMERS for contact, SUPPRESS_WEAPON_PROCS for all, DOESNT_RESET_SWING_TIMER_IF_INSTANT for contact. Unknown flags are not inherited from a whole native row. Review effective custom attributes/corrections later; these raw words do not suppress native class talents globally.

Do not conflate REQUIRE_ALL_TARGETS/ALLOW_CLIENT_TARGETING with the original target-intent seam, or threat-related names with the scoped Paladin threat seam. No DBC bit implements those code contracts.
