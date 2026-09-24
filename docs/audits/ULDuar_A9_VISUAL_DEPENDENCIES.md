# ULDuar A.9 visual dependencies

SOURCE_ONLY. All four families remain VISUAL_CLOSURE_PARTIAL. Selection is conditional on the editor-model order described in [the overlay audit](ULDuar_A9_MPQ_OVERLAY_INVENTORY.md).
DBC rows, referenced model/texture/skin/sound bytes and full hashes are in [the graph inventory](ULDuar_A9_VISUAL_GRAPH.json). No binary member was written to disk.

The DBC paths use .mdx; those exact members are absent. Explicit .m2 alternative probes found the corresponding assets. This documents both results without assuming client normalization. MD20 headers, texture-array bounds, texture strings and numbered skin members were inspected in memory. This bounded reader does not prove all nested particle, child-model or external animation dependencies. AnimationData rows exist for referenced animations; character-model animation availability remains client evidence.

## MeleeDamage

Visual 342; kits 506, 11065; effects 416.
Status: VISUAL_CLOSURE_PARTIAL.

| Member | Found | Archive | SHA-256 |
| --- | --- | --- | --- |
| spells\fanofknives_impact.mdx | False | not found | - |
| spells\fanofknives_impact.m2 | True | common-2.MPQ | a13d7e7daf0ca1f9f3ee716948ad934ad822878abf674bd4a96672a25493b06c |
| SPELLS\ALPHACLOUD.BLP | True | patch.MPQ | de3a4fefb4263085fbdd3fe3e4abb0bb6216b242d9c2fdd5ff3ec9b428175794 |
| SPELLS\FIRE_ANIM02_GREY1.BLP | True | patch-2.MPQ | 12ab9f62c88bc1c8b525e64ac103131da54135fc02acb9aead290a27cb3dd676 |
| SPELLS\BLOODRED_ALPHASPLAT01.BLP | True | common.MPQ | 660fdada1346d36b21e749ab805424766e7fa2efb886e76cbaba9b35f507c22c |
| spells\fanofknives_impact00.skin | True | common-2.MPQ | 9072ee77b5418d95da7f7aab3c7c05f57e5f5771b8792f133c18014d98b612bc |
| Sound\Spells\WarriorSwings\SwingWeaponSpecialWarriorA.wav | True | common.MPQ | 7403c9bf256ef5a3619eb0772c355b883e1724867da9186895b39a62078102ac |
| Sound\Spells\WarriorSwings\SwingWeaponSpecialWarriorC.wav | True | common.MPQ | 6210e82b02ca22f02d49f6740295e525d2273892a80c253b66b8d9423f47a7ff |
| Sound\Spells\WarriorSwings\SwingWeaponSpecialWarriorB.wav | True | common.MPQ | a052bd034ffd7fb2583f49d4d9be32852028fbcb0076b5acd06651a3377ff5c0 |
| Sound\Spells\WarriorSwings\SwingWeaponSpecialWarriorD.wav | True | common.MPQ | 920833d46ded981d31b58ffed313fee5301c0b8fbc5a193774e87180ba82770c |
| Sound\Spells\WarriorSwings\SwingWeaponSpecialWarriorE.wav | True | common.MPQ | 46549a9c5ba51c51d29cb968be847ba5abdf9ab308797ca69fad2f0ad6242f13 |
| Sound\Spells\Warrior_Revenge1.wav | True | common.MPQ | ca0c588c225207d7d1c8adf75abdce3a412c81e0afc8d48fddcee236e0d9cb31 |
| Sound\Spells\Warrior_Revenge2.wav | True | common.MPQ | 803bf054fd3cfae89927360851b58f5d707d71a817ce232482d1e5a7fda3607d |
| Sound\Spells\Warrior_Revenge3.wav | True | common.MPQ | 9d1ca1fa5cc82d889cfff82d96848fec03d970224f884d909482b0430ffa4c6b |
| Sound\Spells\Warrior_Revenge4.wav | True | common.MPQ | aa3cd47557dbcfd50ca7851d4176044e54502e739c9f6795826497beea80ba74 |

Remaining: Native client overlay not proven; Supported release membership not approved; Full model child/animation/particle dependency parser not part of this bounded audit; Character procedure fields [8, 4294967295, 4294967295, 4294967295] require client interpretation.

## RangedProjectileDamage

Visual 7873; kits 119, 121, 184; effects 129, 135, 224.
Status: VISUAL_CLOSURE_PARTIAL.

| Member | Found | Archive | SHA-256 |
| --- | --- | --- | --- |
| Spells\Holy_ImpactDD_Low_Chest.mdx | False | not found | - |
| Spells\Holy_ImpactDD_Low_Chest.m2 | True | common-2.MPQ | d5dd3611de87eed70074c3bdf0f619ee6b9a96e179e3ab4b3518a68d449d2054 |
| Spells\GlowStar_Yellow.blp | True | common.MPQ | 37b59beb820abfd5a7427051ba776a4f875952a2c39ddd8b8179ad2e55998ecc |
| Spells\RibbonBlur1beA_Gold.blp | True | common.MPQ | e49b64fada7d5ae3d78183a8caca7fd85ea21692c58e9e68bc239dbfacf1482f |
| Spells\StarFlashYellowA.blp | True | common.MPQ | 131172299b200f86a61f03d5c935128bc6a6d5bbc15f3bef79483b64c7886683 |
| Spells\StarFlashYellow.blp | True | patch.MPQ | d924ccefba180fdf7dab267aac8ed584370c5aeab1558fb77010c940c9c5dec9 |
| Spells\Dust1_A.blp | True | common.MPQ | 6ab3d96809b40e4f3d0463518cf29606335735db51203bdd0136791c89a77063 |
| Spells\Holy_ImpactDD_Low_Chest00.skin | True | common-2.MPQ | 9072ee77b5418d95da7f7aab3c7c05f57e5f5771b8792f133c18014d98b612bc |
| Spells\Holy_Precast_Low_Hand.mdx | False | not found | - |
| Spells\Holy_Precast_Low_Hand.m2 | True | common-2.MPQ | 6f57961014b445aae655160696ca687fa5c4c8d31fe13c4933b454f8a5dd46f2 |
| Spells\Yellow_Glow3a.blp | True | common.MPQ | 535fac82aed7e8e59d68f7e0bd6a5ab2656741bf4c9b7ca881bc8bc6869b464e |
| Spells\GenericGlow2c.blp | True | patch.MPQ | 0b4bf9380465eff93ff99d713b67c1d90372bf98f419935da41f6c9622fc519a |
| Spells\GenericGlow2b.blp | True | patch.MPQ | c7b300c18ca1cca804fed3d744ce62ac318ce6fb24d113b4fc9c8747ba4674e1 |
| Spells\Holy_Precast_Low_Hand00.skin | True | common-2.MPQ | 233ea99e2902728f2bed84df486116323fbf11b4aaedcef31f73c4750c37ab4e |
| Spells\Holy_Missile_Low.mdx | False | not found | - |
| Spells\Holy_Missile_Low.m2 | True | common-2.MPQ | 5cf71e29c1bd5488ee01a310dbe0c0df4cf44cd13be45b85c72ea22a4b0ae772 |
| SPELLS\STARFLASHYELLOWA.BLP | True | common.MPQ | 131172299b200f86a61f03d5c935128bc6a6d5bbc15f3bef79483b64c7886683 |
| SPELLS\RIBBONBLUR1BEA_GOLD.BLP | True | common.MPQ | e49b64fada7d5ae3d78183a8caca7fd85ea21692c58e9e68bc239dbfacf1482f |
| Spells\Holy_Missile_Low00.skin | True | common-2.MPQ | 9072ee77b5418d95da7f7aab3c7c05f57e5f5771b8792f133c18014d98b612bc |
| Sound\Spells\PreCastHolyMagicLow.wav | True | common.MPQ | 33b1572b80fd3958be4c3577ca63c95ed7d087b976ce34ad4234f0a16967a4b9 |
| Sound\Spells\DirectDamage\HolyImpactDDLow.wav | True | common.MPQ | beb8cbb779b4dc4563692bc1e8d39616dc0b8afbe59a3bf23dd67ae2f5d1f423 |
| Sound\Spells\Cast\HolyCast.wav | True | common.MPQ | c7db5ac6818f48886105cdac972c16bfceb013991415d117fbff55109c53d0e1 |
| Sound\Spells\Missile\HolyMissileLoop.wav | True | common.MPQ | 45891ced62422cd5ca7ed56b0073425b2a85f0999fd2165e96f768597c8f0550 |

Remaining: Native client overlay not proven; Supported release membership not approved; Full model child/animation/particle dependency parser not part of this bounded audit.

## MeleeHealing

Visual 135; kits 99, 232, 270; effects 130, 135, 249.
Status: VISUAL_CLOSURE_PARTIAL.

| Member | Found | Archive | SHA-256 |
| --- | --- | --- | --- |
| Spells\Holy_Precast_Med_Hand.mdx | False | not found | - |
| Spells\Holy_Precast_Med_Hand.m2 | True | common-2.MPQ | 3001a24bb669487eeec2bd1e2a63d953bb61e7988cfcffd47ce2c88c7f969a57 |
| Spells\Yellow_Glow3a.blp | True | common.MPQ | 535fac82aed7e8e59d68f7e0bd6a5ab2656741bf4c9b7ca881bc8bc6869b464e |
| World\Generic\Gnome\ActiveDoodads\GnomeMachine\Yellow_Star_Dim.blp | True | patch.MPQ | 73dac8e31e897381d872e070c659787dfa36b0ca98ef7e74d96f10491c4a7d7a |
| Spells\GenericGlow2c.blp | True | patch.MPQ | 0b4bf9380465eff93ff99d713b67c1d90372bf98f419935da41f6c9622fc519a |
| Spells\GenericGlow2b.blp | True | patch.MPQ | c7b300c18ca1cca804fed3d744ce62ac318ce6fb24d113b4fc9c8747ba4674e1 |
| Spells\Holy_Precast_Med_Hand00.skin | True | common-2.MPQ | 39a083c52f016202cd203626a686d3127069a5e4a3c47f6d501a08e012f98a6b |
| Spells\Holy_Precast_Low_Hand.mdx | False | not found | - |
| Spells\Holy_Precast_Low_Hand.m2 | True | common-2.MPQ | 6f57961014b445aae655160696ca687fa5c4c8d31fe13c4933b454f8a5dd46f2 |
| Spells\Holy_Precast_Low_Hand00.skin | True | common-2.MPQ | 233ea99e2902728f2bed84df486116323fbf11b4aaedcef31f73c4750c37ab4e |
| Spells\Heal_Low_Base.mdx | False | not found | - |
| Spells\Heal_Low_Base.m2 | True | common-2.MPQ | 0daec2f15bcfe69fd916495fee825750d469874dbcb0dd8a1fcc01a8cc4176ff |
| SPELLS\RIBBONBLUR1BD_GOLD_SIDE.BLP | True | common.MPQ | 48a0b8cbd5e407d0a382d89263e78a3a82721b04fb61ddcfb6a30237412449bb |
| SPELLS\STAR5A.BLP | True | common.MPQ | af8b9a0098956c5acf1829f343ad2823d6dd841783d0ccd8685e91c6288f56f6 |
| WORLD\GENERIC\GNOME\ACTIVEDOODADS\GNOMEMACHINE\YELLOW_STAR_DIM.BLP | True | patch.MPQ | 73dac8e31e897381d872e070c659787dfa36b0ca98ef7e74d96f10491c4a7d7a |
| Spells\Heal_Low_Base00.skin | True | common-2.MPQ | 9072ee77b5418d95da7f7aab3c7c05f57e5f5771b8792f133c18014d98b612bc |
| Sound\Spells\PreCastHolyMagicLow.wav | True | common.MPQ | 33b1572b80fd3958be4c3577ca63c95ed7d087b976ce34ad4234f0a16967a4b9 |
| Sound\Spells\Heal_Low_Base.wav | True | common.MPQ | 3e5116d4bf914f90c94c1bdd9503c30e81e1b0ec9e154e4af71acce38d690862 |

Remaining: Native client overlay not proven; Supported release membership not approved; Full model child/animation/particle dependency parser not part of this bounded audit.

## RangedHealing

Visual 2936; kits 99, 154, 270; effects 130, 135, 244.
Status: VISUAL_CLOSURE_PARTIAL.

| Member | Found | Archive | SHA-256 |
| --- | --- | --- | --- |
| Spells\Holy_Precast_Med_Hand.mdx | False | not found | - |
| Spells\Holy_Precast_Med_Hand.m2 | True | common-2.MPQ | 3001a24bb669487eeec2bd1e2a63d953bb61e7988cfcffd47ce2c88c7f969a57 |
| Spells\Yellow_Glow3a.blp | True | common.MPQ | 535fac82aed7e8e59d68f7e0bd6a5ab2656741bf4c9b7ca881bc8bc6869b464e |
| World\Generic\Gnome\ActiveDoodads\GnomeMachine\Yellow_Star_Dim.blp | True | patch.MPQ | 73dac8e31e897381d872e070c659787dfa36b0ca98ef7e74d96f10491c4a7d7a |
| Spells\GenericGlow2c.blp | True | patch.MPQ | 0b4bf9380465eff93ff99d713b67c1d90372bf98f419935da41f6c9622fc519a |
| Spells\GenericGlow2b.blp | True | patch.MPQ | c7b300c18ca1cca804fed3d744ce62ac318ce6fb24d113b4fc9c8747ba4674e1 |
| Spells\Holy_Precast_Med_Hand00.skin | True | common-2.MPQ | 39a083c52f016202cd203626a686d3127069a5e4a3c47f6d501a08e012f98a6b |
| Spells\Holy_Precast_Low_Hand.mdx | False | not found | - |
| Spells\Holy_Precast_Low_Hand.m2 | True | common-2.MPQ | 6f57961014b445aae655160696ca687fa5c4c8d31fe13c4933b454f8a5dd46f2 |
| Spells\Holy_Precast_Low_Hand00.skin | True | common-2.MPQ | 233ea99e2902728f2bed84df486116323fbf11b4aaedcef31f73c4750c37ab4e |
| Spells\HolyLight_Low_Head.mdx | False | not found | - |
| Spells\HolyLight_Low_Head.m2 | True | common-2.MPQ | 36677fc43b9c35a9d0710fe66ce2f15234e66cf5abe54964d75a8f3024e8dffc |
| Spells\GenericGlow64.blp | True | patch.MPQ | c598742dc8332bb37f016d9d68fdd0ad872ec91dce85c1ddb1580d76f6926843 |
| Spells\star5a.blp | True | common.MPQ | af8b9a0098956c5acf1829f343ad2823d6dd841783d0ccd8685e91c6288f56f6 |
| Spells\StarFlashYellow.blp | True | patch.MPQ | d924ccefba180fdf7dab267aac8ed584370c5aeab1558fb77010c940c9c5dec9 |
| Spells\Clouds8x8Fade.blp | True | patch.MPQ | b3b24ef2b458683abd0377190ee140dcbdab0a6b99d8f835c1df007a795537cc |
| Spells\HolyLight_Low_Head00.skin | True | common-2.MPQ | 984b2811054df7cff9ed5d94554d58eb4b956138ee3addd5a9b4c8e49c1ec140 |
| Sound\Spells\PreCastHolyMagicLow.wav | True | common.MPQ | 33b1572b80fd3958be4c3577ca63c95ed7d087b976ce34ad4234f0a16967a4b9 |
| Sound\Spells\HolyLight_Low_Head.wav | True | common.MPQ | 1b623b18cb755661af16dda6fb71e5f946f71c55eb289899ab5927f87ac93253 |

Remaining: Native client overlay not proven; Supported release membership not approved; Full model child/animation/particle dependency parser not part of this bounded audit.

## Missile and auxiliary tables

RangedProjectileDamage visual 7873 has HasMissile=1 and effect-name/model 224. The actual Holy_Missile_Low.m2, its numbered skin and referenced textures are present in the inspected package; sound 3012 is also traced. This resolves a critical existence question, not the whole missile pipeline. SpellMissileID and visual motion ID are zero in the source reference; do not invent a SpellMissile or SpellMissileMotion row to make a graph look complete. SpellMissile/Motion tables were nevertheless inventoried. SpellVisualKitModelAttach has no matching kit rows for these four graphs. PrecastTransitions has three raw rows in the base locale table; applicability/client transitions still need review. No referenced shake ID was observed in selected kits. Melee visual kit 506 has character procedure 8, which remains a client interpretation dependency.

Present files do not prove correct rendering, target attachment, character animation or delayed impact. No family can claim static complete closure for an unpinned effective package.
