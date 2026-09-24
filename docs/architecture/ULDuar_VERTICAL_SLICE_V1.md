# Ulduar first playable vertical slice

Date: 2026-09-15. Design only. No gameplay or experiment was run.
Goal: prove persistent player-created ability identity and one visible gem transformation on the existing AC base.

## Exact player loop

1. A newly created Forge profile enters with zero authored combat abilities.
2. Tutorial presents one available Ability Core entitlement and one active ability slot.
3. Forge asks Damage or Healing.
4. Forge asks Melee or Ranged.
5. It previews the supported profile, target, activation, cost and basic effect.
6. Commit consumes the Core exactly once and creates one persistent AbilityInstance.
7. Native projection makes it usable through a normal secure spellbook/action button.
8. The player casts it on a valid training target.
9. Tutorial issues one compatible non-consumable Impact Gem through an idempotent reward receipt.
10. Installing the gem in the instance's one socket adds one bounded secondary impact target.
11. The player sees a second damage/healing result when an eligible nearby target exists.
12. Logout/login restores the same instance ID, revision, slot, socket, gem ownership and native projection.
13. Removing the gem returns it to collection and restores baseline single-target behavior.
14. Reinstalling it produces the same resolved behavior for the same definition and inputs.

The tutorial reward applies once per Forge profile. Existing legacy characters and EP are unchanged.
Management operations initially require an alive, out-of-combat player with no cast in progress.
The interface shows pending projection until the server confirms that the native ability is usable.

## Minimal supported profile matrix

All four Purpose/Method branches are part of the proposed slice acceptance, not claims of current readiness.
Each needs one reviewed native carrier contract before implementation acceptance.

| Profile | Target | Activation / delivery | School |
| --- | --- | --- | --- |
| Damage + Melee | Enemy unit in melee reach | Instant / Direct | Physical |
| Damage + Ranged | Enemy unit | CastTime / Projectile | Holy |
| Healing + Melee | Friendly unit in contact range | Instant / Direct | Holy |
| Healing + Ranged | Friendly unit | CastTime / Direct | Holy |

Additional fields for the same entries:

| Profile | Native adapter |
| --- | --- |
| Damage + Melee | Reviewed weapon/direct damage |
| Damage + Ranged | Reviewed damage + projectile |
| Healing + Melee | Reviewed heal with contact-range validation |
| Healing + Ranged | Reviewed native healing |

Use one reviewed native resource policy per profile; the initial common policy is Mana.
The melee damage carrier must support the chosen cost without an unscoped native power bypass.
Do not turn a Rage-only carrier into Mana merely by changing its tooltip.
A compatible existing carrier is preferred; a missing carrier is a Phase A/B feasibility blocker.

One Balanced preset per profile is enough. Its activation follows the profile.
Quick/Powerful choices and free activation selection are deferred, not implemented as confusing extra enum values.
No final damage, cost, range, timing or level-unlock balance is selected in this architecture phase.

This matrix deliberately limits initial schools and transformations. The broader seven-school taxonomy remains
valid, but Fire, Frost, Nature, Shadow and Arcane conversion are not required to prove this first loop.

## One visible gem

Impact Gem changes the reviewed instance from a single primary unit effect to:
one primary unit plus at most one eligible nearby secondary unit, with bounded impact radius.
Damage selects legal enemies; healing selects legal allies.
The primary is excluded from secondary selection. No recursively generated impacts.
Keep the current CoverageResolver's authored distribution policy and total budget constraints.
The exact coefficients/radius are versioned fixtures to choose in implementation, not invented launch balance.

Each selected unit passes native legality, phase, line-of-sight, immunity and payload-specific checks.
Use stable target ordering and captured cast/event/hit state.
A second valid target makes the change visible in combat/heal results; absence of a secondary is a valid cast.
The tooltip explains the maximum secondary count and resolved distribution.
Gem removal recomputes from base composition, not by subtracting a previous floating-point modifier.

The current module has impact/delivery and healing/weapon foundations, but that is not proof of all four
carrier/gem combinations. Healing-in-contact and root/secondary target constraints require explicit adapter review.
If a profile cannot preserve native safety, the slice is not accepted until that profile is supported;
do not silently ship a broken option or claim a narrower slice met this matrix.

## Minimal data and runtime path

Only one initial Core definition, four semantic profiles, one gem definition, one active slot and one socket
are required. An instance chooses one profile; it does not acquire all four.
Reforging an existing instance's purpose/method is outside Slice 1; stable identity during socket changes proves
the initial mutation model. Later structural changes must retain the same identity contract.

Persistent objects: onboarding receipt, Core entitlement/consumption, instance/revision, active slot,
gem unit, socket installation, build revision, operation receipt and native projection outbox.
No native-purchase shop, talent tree, archetype reward or loadout economy is necessary.

Cast path:
secure native button -> native SpellID -> unique server carrier mapping -> owned instance/revision ->
resolved immutable definition -> native checks and single cost commit -> existing Ulduar execution adapters.

The spellbook/action bar uses a reviewed native carrier. The Ulduar panel/tooltip presents the custom ability.
A stock spellbook name/icon may remain the carrier's native presentation; arbitrary dynamic native spell names
are not promised. The action remains bound to the same owned instance across gem changes and reconnect.

No two active instances share a carrier in this slice because there is only one active slot.
Carrier ID collisions with independently owned legacy/native spells must still be rejected.
No addon combat command replaces secure native spell activation.

## Acceptance evidence to collect later

| Acceptance | Evidence required |
| --- | --- |
| Zero authored abilities and one Core | Server ownership snapshot before tutorial |
| Four supported creation branches | Separate fresh profile per branch; accepted cast and native safety checks |
| Exactly one persistent instance | Receipt, ownership rows and stable instance ID |
| Duplicate/retried creation | Same receipt/instance; no second consumption |
| Native button works | Client action and server resolved instance match |
| Baseline behavior | Single legal primary damage/heal result |
| Gem installation | Same instance ID; new revision; one installed gem unit |
| Visible transformation | Legal secondary result, bounded count, matching tooltip |
| Friendly/enemy safety | Wrong relationship/phase/LOS never produces illegal effect |
| Removal/reinstallation | Baseline/restored resolution hashes and outcomes |
| Logout/reconnect/restart | Same ownership and recoverable pending projections |
| Crash between commit and projection | No duplicate grant; outbox repairs safely |
| Stale/cross-owner/invalid request | Reject with no ownership/budget mutation |
| Existing Ulduar preservation | Prior EP/customization and native actions remain intact |

These are future acceptance cases, not tests executed in this documentation phase.
Training targets must include a hostile pair and a wounded friendly pair for meaningful healing/secondary checks.
Compare deterministic resolution with identical inputs; native combat RNG still has its own recorded outcome.

## Explicitly unsupported in Slice 1

- Channel, periodic damage/healing, arbitrary triggered effects and arbitrary effect graph authoring.
- Chain, Split, Nova, Cone and additional propagation gems beyond the single reviewed Impact behavior.
- Element conversion, chill/slow riders and the full school palette.
- Multiple active slots, additional sockets, gem stacking and trading.
- Multiple selectable resource types, Rage/Energy/RP/Runes/ComboPoints and Health-cost keystones.
- Forms, stances, stealth, pets, pet bars, dual wield and ammo-dependent custom profiles.
- Generalized talent purchases, keystone activation, archetype discovery rewards.
- Free Pick, native catalog buying, Wildcard, rerolls and native talent trees.
- Full respec/loadouts, legacy character migration and world/gear/quest rewrites.
- Dynamic client Spell.dbc generation per instance, client EXE changes and wholesale UI replacement.

Existing native game systems can remain present; "unsupported" means not promised as Forge-configurable mechanics.

## Dependencies and stop conditions

Requires Phase A semantic/profile/carrier contracts; minimal Phase B Mana, range/target and grant adapter;
Phase C ownership/receipts/outbox; minimal socket/gem ownership from Phase E moved into Phase D.
Reject incomplete native carrier contracts before spending the Core.
No external module installation is needed to implement this loop later.
See [Roadmap](ULDuar_GAMEPLAY_ROADMAP_V2.md) and [Experiment Plan](ULDuar_EXPERIMENT_PLAN.md).
