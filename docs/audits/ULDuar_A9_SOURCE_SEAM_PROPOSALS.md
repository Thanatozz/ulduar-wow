# ULDuar A.9 source seam proposals

SOURCE_ONLY. Design only against core d7ce67dc1800f092bac98aad680ece1c201b89a0 plus the five hashed local Spell/Unit changes. No implementation or runtime evidence. Line numbers identify this preserved checkout.

## 1. Class-neutral healing threat

`src/server/game/Spells/Spell.cpp:2816`, in `Spell::DoAllEffectOnTarget`, obtains effective gain from `caster->HealBySpell`, computes gain * 0.5, then multiplies by another 0.5 if `caster->IsClass(CLASS_PALADIN)`. It forwards that amount through the healed unit's `ThreatManager::ForwardThreatForAssistingMe`. Native Paladin healing therefore starts with gain * 0.25; other native classes start with gain * 0.5. These are pre-modifier amounts, not final threat.

This class test does not inspect SpellFamily or family masks. Both proposed single-effect Forge heals reach it. SPELLFAMILY_GENERIC does not isolate them. Native Paladin spells must retain their existing behavior.

Smallest proposed core change: an immutable per-Spell threat policy, default `NativeDefault`, with one additional explicitly selected value `ClassNeutralHealing`. Freeze it from a unique, owner/revision/generation/catalog-checked Forge snapshot before launch. In the existing branch, apply the Paladin factor only under NativeDefault; retain the gain * 0.5 computation and the exact existing forwarding call. Do not add a second threat event or change the healer identity. Defer `CustomMultiplier` until a concrete contract requires it.

Potential edit locations in a later authorized source phase:

- `Spell.h`: narrowly typed per-cast policy/accessor, default NativeDefault, immutable after preparation.
- `Spell.cpp:2818`: scope the one Paladin factor to NativeDefault.
- Module snapshot construction in `AbilitySpellScript.cpp:129`: attach policy only for the explicitly approved bound custom healing contract, never from a client parameter or a SpellID alone.

`src/server/game/Combat/ThreatManager.cpp`, `ForwardThreatForAssistingMe` and `CalculateModifiedThreat`, retain combat-engagement splitting, controlled/CC handling, redirects, spell_threat multipliers, ordinary threat spellmods and school modifiers. NO_THREAT/NO_HELPFUL_THREAT are not substitutes. Provenance-aware filtering of unrelated class spellmods is a separate unresolved requirement; preserving this pipeline alone does not implement that policy.

Required later observations: equal effective healing and initial threat across native chassis, native Paladin unchanged, overheal and heal absorbs, encounter multipliers, multiple engaged creatures, redirects, zero gain, failed/unbound Forge casts. None was executed.

## 2. Original target intent

Packet path:

1. `SpellHandler.cpp`, `WorldSession::HandleCastSpellOpcode` (around 376): reads cast counter, SpellID and cast flags. The queue branch can retain the original packet and later re-enter this handler.
2. Around 438: `SpellCastTargets::Read` reads target mask and packed GUID, then resolves object pointers. `HandleClientCastFlags` processes additional cast information. The raw wire mask/GUID should be captured before any correction; a native cast counter is not a Forge lease-generation nonce.
3. Around 544: constructs Spell and calls `prepare(&targets)` after native validation/rank handling.
4. `Spell.cpp:3483`: `InitExplicitTargets(*targets)` copies targets and saves `m_originalTargetGUID` at line 735. It may substitute player selection, creature victim, or friendly self when no object pointer resolved.
5. `Spell.cpp:3485`: existing `AllSpellScript::CanPrepare(this, targets, triggeredByAura)` still receives the ORIGINAL input targets, while `spell->m_targets` contains corrected targets. Input was copied, not overwritten.

A.8's concern is real but is not total loss of the original GUID: the GUID is already retained. `GetOriginalTarget()` resolves it to a pointer later; null cannot distinguish absent intent from an object that disappeared. Preserve GUIDs/flags and explicit outcomes, never an unowned Unit pointer.

Minimal design: at preparation entry retain original target mask alongside the existing original GUID and a classification of resolution/correction. Use the existing CanPrepare seam for the scoped validation where possible; a later module script must receive the same frozen intent and binding, rather than resolving independently into a different lease/revision. Packet origin must be tagged at the handler if origin is needed; server-triggered calls must not masquerade as client intent. No ambient map keyed only by SpellID.

Suggested snapshot facts: original mask, existing original object GUID, whether that object resolved at preparation, final corrected GUID, correction classification (none/selection/self/invalid-or-unresolved input), and trusted origin when known. `hadExplicitUnitTarget` is derived from mask + GUID, not merely a non-null corrected pointer. Never infer the user's UI gesture beyond what the packet actually supplies: a client that already sends self is explicit self at the server boundary.

| Original input | Proposed custom Slice-1 policy |
| --- | --- |
| Explicit self unit GUID for healing | Allow, subject to normal relation/alive/range checks |
| Explicit legal friendly/enemy unit | Require preserved intended GUID and relation |
| No unit object supplied, then selection/self substituted | Reject for the exact explicit-unit custom fixture; reconsider only under a versioned explicit policy |
| Nonempty GUID failed to resolve, then self/selection substituted | Reject; never silently retarget |
| Resolved enemy supplied to friendly heal | Reject original invalid relation; target correction is not permission |

The correction branch runs when the original object pointer is absent; it does not generally convert every resolved hostile target to self. A stale nonempty GUID is the especially important case. Native spells retain their existing fallback behavior. This seam does not solve stale queued packets after carrier reuse: A.7 ACTIVE → DRAINING → QUARANTINED → FREE preconditions remain separate, and an arbitrary timeout is still not proof.

## 3. Single pre-native Potency

### Actual insertion opportunities

`Spell.h:495` uses the cast-local `m_spellValue->EffectBasePoints[i]` for `CalculateSpellDamage`. `Spell.cpp:8670`, `SetSpellValue(SPELLVALUE_BASE_POINT0, amount)`, writes only that Spell's value. `SpellEffectInfo::CalcBaseValue` (`SpellInfo.cpp:523`) subtracts one when DieSides is nonzero. With the proposed transport seed DieSides=1 and no level/combo scaling, native CalcValue adds that one back deterministically.

**Preferred proposal:** after a unique, validated custom binding has produced its immutable AbilityCast snapshot in module `AbilitySpellScript::Load` (around 129–161), resolve and freeze the one semantic base roll/Potency amount, then use existing `Spell::SetSpellValue` once for effect 0, before native effect calculations. This requires future module work and effective script binding; pending custom entries do not currently execute it. No new generic core payload API is needed for this one-effect fixture.

Use bounded nonnegative int32 amounts and the reviewed constant carrier die; do not retain the native source spell's random dice in addition to the semantic roll. A basepoint setter is not final damage: subsequent native calculations remain authoritative for their assigned stages. `LoadScripts` is at `Spell.cpp:3540`, before power calculation and CheckCast and well before effect execution. Resolve once, reject invalid binding, and preserve the frozen amount through delayed impact. Instance replacement during flight must not change that amount.

| Option | Static assessment |
| --- | --- |
| A: replace per-cast raw amount before native effect math | Prefer existing SetSpellValue before CalcValue; shared by damage and healing, no global SpellInfo edit |
| A alternative: OnEffectLaunchTarget + SetEffectValue | Existing and per-target, but occurs after CalcValue/ApplyEffectModifiers; blindly replacing it discards prior effect-stage spellmods and may discard an already-consumed modifier application. Do not reapply modifiers blindly |
| B: Forge branches inside EffectSchoolDMG and EffectHeal | Duplicates policy in two core handlers; unnecessary for this fixture unless later evidence defeats the existing setter |
| C: current Ulduar OnHit adapter | Too late for pre-native Potency; native bonus and taken calculations already occurred |

`Spell::HandleEffects` at 5740 calculates the amount, runs script effect hooks, then calls the handler unless prevented. `EffectSchoolDMG` at `SpellEffects.cpp:324` and `EffectHeal` at 1475 both use LAUNCH_TARGET for their primary amount calculation. `OnEffectLaunchTarget` remains useful for inspection, but it is not the preferred replacement point after discovering the earlier setter.

Do not PreventDefault and issue a replacement cast. Do not call DealDamage/HealBySpell manually. Do not mutate shared SpellInfo. Do not apply another Potency multiplier in `AbilitySpellScript::ScaleSecondaryPayload` (line 217): its current OnHit primary damage scaling must be explicitly identity/bypassed for the new pre-native custom policy. Preserve legacy EP/rank behavior and the separately resolved propagation multiplier. Each future child, if ever allowed, needs its own explicit frozen amount semantics; do not automatically apply the root twice.

Single assignment means one semantic Potency ownership and one native payload event per affected target. It does not assert that the core calls CalcValue only once during all validation and execution phases. Setter and modifier-charge interactions require later observation. Multiple script bindings must not overwrite the same basepoints; effective-data review is part of the gate.

### Coefficient ownership and actual flow

1. Ulduar freezes semantic base roll plus Potency, excluding SP/AP and native caster/taken modifiers.
2. Per-cast SetSpellValue supplies that base to CalcValue. Native reviewed effect modifiers remain at their normal stage; provenance filtering is still a separate requirement.
3. Damage: EffectSchoolDMG → SpellDamageBonusDone → SpellDamageBonusTaken → stored target damage. Healing: EffectHeal → SpellHealingBonusDone → before-taken snapshot → SpellHealingBonusTaken → stored negative damage/heal amount.
4. `DoAllEffectOnLaunchTarget` (Spell.cpp:8533) records crit chance/outcome along with the launch amounts. Delayed delivery uses that cast/target state; this proposal does not resnapshot it at impact.
5. At impact the native path processes hit outcome, immunity and script hit hooks. Damage reaches `Unit::CalculateSpellDamageTaken` (1498): world/script received-damage hooks, Physical armor where applicable, DmgClass critical bonus, resilience, then absorb/resist. Physical armor precedes critical multiplication in this source. Do not replace this with a universal invented order.
6. Native damage application, combat log, threat and proc dispatch remain in the existing event path. Healing critical bonus precedes HealBySpell; HealBySpell (Unit.cpp:8412) performs received-heal hook, heal absorbs, DealHeal/effective gain and log; threat forwarding and proc handling follow in Spell.cpp.

NativeBonusContribution owns the one reviewed coefficient contribution. For the A.8 exact fixture the proposed SP coefficients are MD=0, RPD=.123, MH=.231, RH=.481; AP/DOT are zero. Raw DBC coefficient, spell_bonus_data and effective corrections must agree on the intended value; no implicit cast-time fallback is accepted as a second owner. Ulduar Potency neither includes that contribution nor multiplies the result after it. Taken modifiers, crit, armor/resilience/absorb/resist belong to their existing stages.

Setting GENERIC + zero masks is not provenance filtering. Caster native talent/passive contamination, including school-wide effects, remains unresolved code behavior and cannot be certified away by a DBC row. No existing caster modifier pipeline is globally disabled by this proposal.

Required later observations: fixed base with no bonus, controlled SP/AP additions exactly once, target modifiers, crit, Physical armor, Holy resistance applicability, absorbs, immunity, reflected/delayed hits, failed casts, modifier charges, heal threat and logs/procs with exactly one payload event, stale revisions, and legacy EP unaffected. No test was executed or claimed to pass.
