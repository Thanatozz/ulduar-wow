# ULDuar A.8 native reference rows

Date: 2026-09-19. SOURCE_ONLY. Raw references are not carrier approvals.
Read with [the main review](../implementation/ULDuar_PHASE_A8_EFFECTIVE_DATA_REVIEW.md).

## Input and decoding

Primary reference A is C:/WoWProjecto/a/Data/dbc; B is its matching build-directory copy.
Spell SHA-256:

    d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3

WDBC bytes were read without an editor or project executable. Record layout was cross-checked against
DBCStructure.h and the local 3.3.5a editor bindings. Bonus coefficients are words 229..231, not 231..233.
SpellMissileID is word 227. The raw word arrays and dependent records are retained in
[the audit JSON](ULDuar_A8_DATA_INVENTORY.json). SQL rows below are repository text, not installed data.

## Raw selected spell rows

Power 0=Mana. DmgClass 1=MAGIC, 2=MELEE; school masks 1=Physical, 2=Holy.
Basepoints plus the native die roll are not final damage/healing. Range 2 is reach, not fixed center distance.
Every row below retains its own native scripts, class/level restrictions and provenance unless explicitly discarded.

### Spell 1495 - Mongoose Bite

| Field | Observed raw value |
| --- | --- |
| Rank text | Rank 1 |
| Effects / A / B | [2, 0, 0] / [6, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 0 / 3 |
| Cast index / row | 1 / [1, 0, 0, 0] |
| Range / min H,F / max H,F | 2 / [0.0, 0.0, 5.0, 5.0] |
| Speed / DmgClass / school | 0.0 / 2 / 1 |
| Family / masks | 9 / [2, 0, 0] |
| Basepoints / die sides | [24, 0, 0] / [1, 0, 0] |
| Effect bonus multipliers | [1.0, 0.0, 0.0] |
| Max / base / spell level | [0, 16, 16] |
| Target flags / facing | 0x0 / 1 |
| GCD category / duration | 133 / 1500 |
| Category / own / category recovery | 65 / 0 / 5000 |
| Visual / icon | [342, 0] / 257 |
| Interrupt / prevention / equipment class | 0x0 / 2 / -1 |
| Attribute words 0..7 | 0x50000, 0x200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 2816 - Bark of Doom

| Field | Observed raw value |
| --- | --- |
| Rank text | (empty; not proof of independent rank root) |
| Effects / A / B | [2, 0, 0] / [6, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 0 / 0 |
| Cast index / row | 1 / [1, 0, 0, 0] |
| Range / min H,F / max H,F | 2 / [0.0, 0.0, 5.0, 5.0] |
| Speed / DmgClass / school | 0.0 / 2 / 1 |
| Family / masks | 0 / [0, 0, 0] |
| Basepoints / die sides | [99, 0, 0] / [1, 0, 0] |
| Effect bonus multipliers | [1.0, 0.0, 0.0] |
| Max / base / spell level | [0, 0, 0] |
| Target flags / facing | 0x0 / 0 |
| GCD category / duration | 0 / 0 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [0, 0] / 1 |
| Interrupt / prevention / equipment class | 0x0 / 2 / -1 |
| Attribute words 0..7 | 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 585 - Smite

| Field | Observed raw value |
| --- | --- |
| Rank text | Rank 1 |
| Effects / A / B | [2, 0, 0] / [6, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 0 / 9 |
| Cast index / row | 16 / [16, 1500, 0, 1500] |
| Range / min H,F / max H,F | 4 / [0.0, 0.0, 30.0, 30.0] |
| Speed / DmgClass / school | 0.0 / 1 / 2 |
| Family / masks | 6 / [128, 0, 0] |
| Basepoints / die sides | [12, 0, 0] / [5, 0, 0] |
| Effect bonus multipliers | [0.123, 0.0, 0.0] |
| Max / base / spell level | [6, 1, 1] |
| Target flags / facing | 0x0 / 1 |
| GCD category / duration | 133 / 1500 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [128, 0] / 237 |
| Interrupt / prevention / equipment class | 0xf / 1 / -1 |
| Attribute words 0..7 | 0x10000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 31759 - Holy Bolt

| Field | Observed raw value |
| --- | --- |
| Rank text | (empty; not proof of independent rank root) |
| Effects / A / B | [2, 0, 0] / [6, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 90 / 0 |
| Cast index / row | 20 / [20, 2500, 0, 2500] |
| Range / min H,F / max H,F | 5 / [0.0, 0.0, 40.0, 40.0] |
| Speed / DmgClass / school | 24.0 / 1 / 2 |
| Family / masks | 0 / [0, 0, 0] |
| Basepoints / die sides | [403, 0, 0] / [143, 0, 0] |
| Effect bonus multipliers | [1.0, 0.0, 0.0] |
| Max / base / spell level | [0, 70, 70] |
| Target flags / facing | 0x0 / 1 |
| GCD category / duration | 0 / 0 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [7873, 0] / 70 |
| Interrupt / prevention / equipment class | 0xf / 1 / -1 |
| Attribute words 0..7 | 0x10000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 34232 - Holy Bolt

| Field | Observed raw value |
| --- | --- |
| Rank text | (empty; not proof of independent rank root) |
| Effects / A / B | [2, 0, 0] / [6, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 90 / 0 |
| Cast index / row | 20 / [20, 2500, 0, 2500] |
| Range / min H,F / max H,F | 5 / [0.0, 0.0, 40.0, 40.0] |
| Speed / DmgClass / school | 24.0 / 1 / 2 |
| Family / masks | 0 / [0, 0, 0] |
| Basepoints / die sides | [63, 0, 0] / [23, 0, 0] |
| Effect bonus multipliers | [1.0, 0.0, 0.0] |
| Max / base / spell level | [0, 20, 20] |
| Target flags / facing | 0x0 / 1 |
| GCD category / duration | 0 / 0 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [7873, 0] / 70 |
| Interrupt / prevention / equipment class | 0xf / 1 / -1 |
| Attribute words 0..7 | 0x10000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 142 - New Magic Missile (Test)

| Field | Observed raw value |
| --- | --- |
| Rank text | (empty; not proof of independent rank root) |
| Effects / A / B | [2, 0, 0] / [6, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 10 / 0 |
| Cast index / row | 5 / [5, 2000, 0, 2000] |
| Range / min H,F / max H,F | 5 / [0.0, 0.0, 40.0, 40.0] |
| Speed / DmgClass / school | 15.0 / 1 / 2 |
| Family / masks | 0 / [0, 0, 0] |
| Basepoints / die sides | [0, 0, 0] / [6, 0, 0] |
| Effect bonus multipliers | [1.0, 0.0, 0.0] |
| Max / base / spell level | [0, 0, 0] |
| Target flags / facing | 0x0 / 0 |
| GCD category / duration | 0 / 0 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [4, 0] / 1 |
| Interrupt / prevention / equipment class | 0x0 / 1 / -1 |
| Attribute words 0..7 | 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 635 - Holy Light

| Field | Observed raw value |
| --- | --- |
| Rank text | Rank 1 |
| Effects / A / B | [10, 0, 0] / [21, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 0 / 29 |
| Cast index / row | 20 / [20, 2500, 0, 2500] |
| Range / min H,F / max H,F | 5 / [0.0, 0.0, 40.0, 40.0] |
| Speed / DmgClass / school | 0.0 / 1 / 2 |
| Family / masks | 10 / [2147483648, 0, 0] |
| Basepoints / die sides | [49, 0, 0] / [11, 0, 0] |
| Effect bonus multipliers | [0.481, 0.0, 0.0] |
| Max / base / spell level | [5, 1, 1] |
| Target flags / facing | 0x0 / 0 |
| GCD category / duration | 133 / 1500 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [2936, 0] / 70 |
| Interrupt / prevention / equipment class | 0xf / 1 / -1 |
| Attribute words 0..7 | 0x10000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 19750 - Flash of Light

| Field | Observed raw value |
| --- | --- |
| Rank text | Rank 1 |
| Effects / A / B | [10, 0, 0] / [21, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 0 / 7 |
| Cast index / row | 16 / [16, 1500, 0, 1500] |
| Range / min H,F / max H,F | 5 / [0.0, 0.0, 40.0, 40.0] |
| Speed / DmgClass / school | 0.0 / 1 / 2 |
| Family / masks | 10 / [1073741824, 0, 0] |
| Basepoints / die sides | [80, 0, 0] / [13, 0, 0] |
| Effect bonus multipliers | [1.009, 0.0, 0.0] |
| Max / base / spell level | [25, 20, 20] |
| Target flags / facing | 0x0 / 0 |
| GCD category / duration | 133 / 1500 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [6623, 0] / 242 |
| Interrupt / prevention / equipment class | 0xf / 1 / -1 |
| Attribute words 0..7 | 0x10000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2000000, 0x0 |

### Spell 2050 - Lesser Heal

| Field | Observed raw value |
| --- | --- |
| Rank text | Rank 1 |
| Effects / A / B | [10, 0, 0] / [21, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 0 / 16 |
| Cast index / row | 16 / [16, 1500, 0, 1500] |
| Range / min H,F / max H,F | 5 / [0.0, 0.0, 40.0, 40.0] |
| Speed / DmgClass / school | 0.0 / 1 / 2 |
| Family / masks | 6 / [262144, 0, 0] |
| Basepoints / die sides | [45, 0, 0] / [11, 0, 0] |
| Effect bonus multipliers | [0.231, 0.0, 0.0] |
| Max / base / spell level | [3, 1, 1] |
| Target flags / facing | 0x0 / 0 |
| GCD category / duration | 133 / 1500 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [285, 0] / 682 |
| Interrupt / prevention / equipment class | 0xf / 1 / -1 |
| Attribute words 0..7 | 0x10000, 0x0, 0x80000, 0x0, 0x0, 0x0, 0x0, 0x0 |

### Spell 25914 - Holy Shock

| Field | Observed raw value |
| --- | --- |
| Rank text | Rank 1 |
| Effects / A / B | [10, 0, 0] / [21, 0, 0] / [0, 0, 0] |
| Power / flat / base-Mana % | 0 / 0 / 0 |
| Cast index / row | 1 / [1, 0, 0, 0] |
| Range / min H,F / max H,F | 6 / [0.0, 0.0, 100.0, 100.0] |
| Speed / DmgClass / school | 0.0 / 1 / 2 |
| Family / masks | 10 / [0, 65536, 0] |
| Basepoints / die sides | [480, 0, 0] / [39, 0, 0] |
| Effect bonus multipliers | [0.807, 1.0, 0.0] |
| Max / base / spell level | [47, 40, 40] |
| Target flags / facing | 0x0 / 0 |
| GCD category / duration | 133 / 0 |
| Category / own / category recovery | 0 / 0 / 0 |
| Visual / icon | [135, 0] / 156 |
| Interrupt / prevention / equipment class | 0x0 / 1 / -1 |
| Attribute words 0..7 | 0x50000, 0x0, 0x0, 0x200, 0x1, 0x0, 0x0, 0x0 |

## Individual-field mining decisions

Each row states the field being borrowed. All other fields remain outside that borrowing decision.

| Profile / source | Field and value | Why useful / expressly not inherited |
| --- | --- | --- |
| MD / 1495 | Range2, instant, Mana3%, GCD133/1500 | Contact fixture; exclude Hunter/AP/autoattack/melee coupling |
| MD / 1495 | Basepoints24, die1 | Small 25-unit reference; not level16/ranks or weapon animation approval |
| MD / 2816 | Family0, Physical SCHOOL_DAMAGE | Independent direct layout; not zero cost/GCD or hidden NPC behavior |
| MD / 585 | DmgClass1 | Spell hit model reference; not Holy school, Priest family or its crit policy |
| RPD / 31759 | Range5, Cast20, speed24 | Native Holy projectile shell dimensions; not level70 payload/cost |
| RPD / 34232 | Visual7873, enemyA6, facing1 | Same projectile at another magnitude; not proof of player suitability |
| RPD / 585 | Mana9%, base12/die5, coeff0.123 | Conservative low-rank fixture; not speed0, range30 or Priest masks |
| RPD / 142 | Holy projectile15, cast2000 | Alternative transport evidence; not selected speed or test provenance |
| MH / 25914 | Instant, HEAL10/ally21, MAGIC1 | Native instant healing shape; not child-trigger flags/range100/cost0 |
| MH / 1495 | Range2 reach flag1 | Contact acquisition reference only; not hostile relation/facing/class |
| MH / 635 | Holy healing/crit path | Friendly execution reference; not Paladin threat/family/29% cost |
| MH / 2050 | Base45/die11, coeff0.231 | Modest fixture payload; not Priest training/rank/level penalty |
| MH / 19750 | Mana7% | Recognizable cost reference; not 1500 ms cast or Paladin modifiers |
| RH / 635 | Range5, Cast20, HEAL10, speed0 | Main acquisition reference; not family/masks/form restriction |
| RH / 635 | Base49/die11, coeff0.481, Mana29% | Comparison fixture only; class-neutral economy remains unresolved |
| RH / 19750 | HEAL/ally, cast1500 | Alternative timing evidence; not an additional V1 envelope |
| RH / 2050 | Ally21, MAGIC1, range40 | Cross-class structural reference; not Priest class eligibility |

MD=MeleeDamage; RPD=RangedProjectileDamage; MH=MeleeHealing; RH=RangedHealing.
1495/31759/34232 remain research candidates. No catalog entry, contract or rank approval is created.

## Effective-data cautions

Base spell_bonus_data includes 1495: SP0/AP0.2; 585:0.123; 635:0.481; 2050:0.231;
19750:1.0; 25914:0.8057. The last differs from its raw DBC coefficient approximately 0.807.
This illustrates why raw rows alone are insufficient. Native rank lookup can also supply bonus entries.
An absent explicit proc or script row does not isolate a spell from listeners on other spells or broad school auras.
The pending Ulduar starter SQL binds native roots, including 635, through negative rank-root spell_script_names IDs.
It is source evidence of intended binding, not proof that the live world has that binding.

## Visual graph

The following edges come from A. No visual is approved: all retain VISUAL_DEPENDENCY_UNKNOWN.
Kits reference animations/character procedures as well as effect names and sounds.
The raw rows permit checking fields not summarized here. No dependency is imported from Ascension.

### SpellVisual 342

HasMissile=0, missile effect-name=0, motion=0.
Source SpellMissileID=0 for the corresponding reference spell; no extra missile row is inferred.

| Kit | Start animation / animation | Sound | Character procedures |
| --- | --- | --- |
| 506 | [4294967295, 57] | 3091 | [8, 4294967295, 4294967295, 4294967295] |
| 11065 | [4294967295, 4294967295] | 13339 | [4294967295, 4294967295, 4294967295, 4294967295] |

4294967295 is the raw no-entry sentinel in these signed/sentinel fields.

| Effect-name ID | Model path |
| --- | --- |
| 416 | spells\fanofknives_impact.mdx |

| Sound ID | Directory and candidate files |
| --- | --- |
| 3091 | Sound\Spells\WarriorSwings / SwingWeaponSpecialWarrior{A,C,B,D,E}.wav |
| 13339 | Sound\Spells / Warrior_Revenge1.wav, Warrior_Revenge2.wav, Warrior_Revenge3.wav, Warrior_Revenge4.wav |

### SpellVisual 7873

HasMissile=1, missile effect-name=224, motion=0.
Source SpellMissileID=0 for the corresponding reference spell; no extra missile row is inferred.

| Kit | Start animation / animation | Sound | Character procedures |
| --- | --- | --- |
| 119 | [4294967295, 53] | 2562 | [4294967295, 4294967295, 4294967295, 4294967295] |
| 121 | [4294967295, 9] | 1270 | [4294967295, 4294967295, 4294967295, 4294967295] |
| 184 | [4294967295, 51] | 740 | [4294967295, 4294967295, 4294967295, 4294967295] |

4294967295 is the raw no-entry sentinel in these signed/sentinel fields.

| Effect-name ID | Model path |
| --- | --- |
| 129 | Spells\Holy_ImpactDD_Low_Chest.mdx |
| 135 | Spells\Holy_Precast_Low_Hand.mdx |
| 224 | Spells\Holy_Missile_Low.mdx |

| Sound ID | Directory and candidate files |
| --- | --- |
| 740 | Sound\Spells / PreCastHolyMagicLow.wav |
| 1270 | Sound\Spells\DirectDamage / HolyImpactDDLow.wav |
| 2562 | Sound\Spells\Cast / HolyCast.wav |
| 3012 | Sound\Spells\Missile / HolyMissileLoop.wav |

### SpellVisual 135

HasMissile=0, missile effect-name=0, motion=0.
Source SpellMissileID=0 for the corresponding reference spell; no extra missile row is inferred.

| Kit | Start animation / animation | Sound | Character procedures |
| --- | --- | --- |
| 99 | [4294967295, 52] | 740 | [4294967295, 4294967295, 4294967295, 4294967295] |
| 232 | [4294967295, 4294967295] | 1432 | [4294967295, 4294967295, 4294967295, 4294967295] |
| 270 | [4294967295, 54] | 0 | [4294967295, 4294967295, 4294967295, 4294967295] |

4294967295 is the raw no-entry sentinel in these signed/sentinel fields.

| Effect-name ID | Model path |
| --- | --- |
| 130 | Spells\Holy_Precast_Med_Hand.mdx |
| 135 | Spells\Holy_Precast_Low_Hand.mdx |
| 249 | Spells\Heal_Low_Base.mdx |

| Sound ID | Directory and candidate files |
| --- | --- |
| 740 | Sound\Spells / PreCastHolyMagicLow.wav |
| 1432 | Sound\Spells / Heal_Low_Base.wav |

### SpellVisual 2936

HasMissile=0, missile effect-name=0, motion=0.
Source SpellMissileID=0 for the corresponding reference spell; no extra missile row is inferred.

| Kit | Start animation / animation | Sound | Character procedures |
| --- | --- | --- |
| 99 | [4294967295, 52] | 740 | [4294967295, 4294967295, 4294967295, 4294967295] |
| 154 | [4294967295, 4294967295] | 1430 | [4294967295, 4294967295, 4294967295, 4294967295] |
| 270 | [4294967295, 54] | 0 | [4294967295, 4294967295, 4294967295, 4294967295] |

4294967295 is the raw no-entry sentinel in these signed/sentinel fields.

| Effect-name ID | Model path |
| --- | --- |
| 130 | Spells\Holy_Precast_Med_Hand.mdx |
| 135 | Spells\Holy_Precast_Low_Hand.mdx |
| 244 | Spells\HolyLight_Low_Head.mdx |

| Sound ID | Directory and candidate files |
| --- | --- |
| 740 | Sound\Spells / PreCastHolyMagicLow.wav |
| 1430 | Sound\Spells / HolyLight_Low_Head.wav |

## Remaining closure

VisualKitModelAttach rows were checked for the selected kits; no attachment row was found for these candidates.
Referenced kit shake IDs are zero. Additional AnimationData/CameraShakes/SpellChainEffects tables were inventoried.
Animation IDs and character procedures still need model/client interpretation; row presence is not visual behavior.
Loose model/skin and embedded-texture-string candidates are listed and hashed in the JSON audit.
The search found 21 relevant loose model/skin files and 15 texture basename candidates outside Ascension.
String extraction is not a complete M2 graph parser. A filename hit does not prove the correct package path, skin,
texture variant, sound variant, fallback or load order. Sounds were decoded to filenames, not played.
The final effective MPQ asset graph and all supported locales remain CLIENT_EVIDENCE requirements.
