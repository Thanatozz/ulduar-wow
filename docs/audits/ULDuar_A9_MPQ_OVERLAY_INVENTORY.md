# ULDuar A.9 MPQ overlay inventory

SOURCE_ONLY. CLIENT_OVERLAY_PARTIAL. All actual client archives remain UNKNOWN supported-release membership.
Hashes describe inspected bytes. Priority is the local editor model, not a proven native client load order.
Only read-only StormLib open/read/info/close APIs were bound; no extraction or archive writer was used.

## Archive inventory

| Archive relative to Client/Data | Bytes | SHA-256 | Locale | DBC candidates | Model rank | Classification |
| --- | --- | --- | --- | --- | --- | --- |
| common-2.MPQ | 1810430636 | 9c605d95443172bdfd7c6936bc636684761241657935c22da25f955083809f43 | base | NO | 6 | UNKNOWN |
| common.MPQ | 2881154862 | d850ffa5efd6a1ba845899a7d9f9ad27f6eea7ac606e95033506c72c86ee0236 | base | NO | 7 | UNKNOWN |
| enUS/backup-enUS.MPQ | 167245856 | 9f52f932db31c407a1fb043aed715ed29c20e9a6e7446db9e2fa9408c960f6a5 | enUS | NO | None | UNKNOWN |
| enUS/base-enUS.MPQ | 29176975 | c02b13b4b85eb59b8a3557442e69b376fa5d491092ebaa2beeac979ddbd4514e | enUS | NO | 17 | UNKNOWN |
| enUS/expansion-locale-enUS.MPQ | 17389181 | c9f27ce716b7195776929e8e3a7faeeaa15522215be47611c101dd5b1d8845c1 | enUS | NO | 14 | UNKNOWN |
| enUS/expansion-speech-enUS.MPQ | 241033297 | b9d9d13fc46251248ac9a36893ef6e275de43aadff5b89871dfeca7165d92cf5 | enUS | NO | 13 | UNKNOWN |
| enUS/lichking-locale-enUS.MPQ | 12354378 | 89b1eba015927e321683a3867be1b8a76e593c438527eb42f4934d03484f1b04 | enUS | NO | 12 | UNKNOWN |
| enUS/lichking-speech-enUS.MPQ | 354008839 | 8fc28d2f26d4b00db1884577cfa82769c234a8177b3827b5fae59dc006e6705f | enUS | NO | 11 | UNKNOWN |
| enUS/locale-enUS.MPQ | 204291376 | 45f02a3bf3964b169f397cea58113cdce5fa7bdf58d4b63f68e46255bb3bd3ea | enUS | YES | 16 | UNKNOWN |
| enUS/patch-enUS-2.MPQ | 225570171 | ab9af8457f0d7b99a562f26b7d1651bbf68ebc37ddb249d01ac860ccc8746ff4 | enUS | YES | 9 | UNKNOWN |
| enUS/patch-enUS-3.MPQ | 100373935 | d61a60297af9044d926754d997cd5aa630500cd003d41983a9ccb5b324d61299 | enUS | YES | 8 | UNKNOWN |
| enUS/patch-enUS.MPQ | 296616080 | c1c06b0d0c34c331b21df7cdd25cc422a650efbd477e42b80849ba30b2e5fc99 | enUS | YES | 10 | UNKNOWN |
| enUS/speech-enUS.MPQ | 438430439 | bfd2c4bf07213736bae28e1c8f49bf60783e12545ac555016d6f22441f7c793d | enUS | NO | 15 | UNKNOWN |
| expansion.MPQ | 1921219911 | 34a19723d773997b31ec72a16361af8bdd8cc38d108274b9b8a96521ec2c4f4a | base | NO | 5 | UNKNOWN |
| lichking.MPQ | 2553948549 | 8456e92d47f2bc71efba30fcabd4fea8c5ef0d93feef320ba51ffeeacf78de9d | base | NO | 4 | UNKNOWN |
| patch-2.MPQ | 1401729059 | c8b78bb75bcf5773e9ae99e11bdfcabc2a37aed3da947367d8af808d4d3c23c6 | base | NO | 2 | UNKNOWN |
| patch-3.MPQ | 605089137 | 56dbbfc8f9ce7182ca88538d75284e738020138a7ca4217d72d8168865510dd3 | base | NO | 1 | UNKNOWN |
| patch-U.MPQ | 22742 | 45e72ae9152f94290be0b3632c12a983a67a91edbd505b7540b74e5ac87b2497 | base | NO | 0 | UNKNOWN |
| patch.MPQ | 4004713057 | 92b4a94a6c7a23c0b9fd88c47823e41792879a7ee1f70c2349a255153ca25d54 | base | NO | 3 | UNKNOWN |

Rank 0 is inspected first in the conditional model. backup-enUS.MPQ is excluded by the editor filename policy; its native-client status is not inferred. The four locale containers with relevant DBCs are locale-enUS, patch-enUS, patch-enUS-2 and patch-enUS-3. The other fifteen have none of the 19 exact names probed; this is not a claim that they contain no data.

## Conditional table selection

| Table | Archive | Rows | SHA-256 | ID-set SHA-256 |
| --- | --- | --- | --- | --- |
| Spell | patch-enUS-3.MPQ | 49839 | d5cce1a83550dcfa9eb2f0251dbb11fd24c272534b2b1a9b230924a44d817ab3 | a32ff4fb626b70f388f591bfb9dfcef4da6fab321559ec219fc2798b4fa903b0 | None 
| SpellRange | patch-enUS-3.MPQ | 64 | 82d261be5e42d90f62a13642a3fd8f421fe1b0056ad8ed7dea73cdf4f8c8cb7f | 0c1f6477b9226a94565d334fa72357345d652e206cdfc8ef42763260c134bae1 | None 
| SpellCastTimes | patch-enUS-2.MPQ | 70 | 919ca9b65cb144a3a9cf0ce10d2a25fcc7cdccf33c752ed376e086ff62f8ccec | f2599871cd8c6ce71f1db09afc5193264e80283199a0fa3f8590b2c51058874d | None 
| SpellVisual | patch-enUS-3.MPQ | 9406 | 966db0c9944068475b31d2584d5db88456d1ab26d0ca0658d75d048f1e00a601 | 1d9eedd64fbf50d586e1062944d1c34e7235af58b78e0ad2cdb220bcfc798d8b | None 
| SpellIcon | patch-enUS-3.MPQ | 3226 | 2b12326641dba1554878b3f53c993e1211e50b3839ccdbeca378a23e7b3248db | 3bfe1c5011bcc2da2cbbac1d18b857cf673d57d630b9c275e014ed80d68ba9f8 | None 
| SkillLineAbility | patch-enUS-3.MPQ | 10219 | 4154b833d6a26b9b9ce53851d56cb594f0813c0936a72ec89f933cc69abe42c3 | 1e1973df5dd8e7d8ab2fe1171b2bfad041ae7abb68b5598efa86b2f61768f544 | None 
| SkillLine | patch-enUS-3.MPQ | 150 | 276824940b7a38e1639e974571e5cb1ad0a1ecbaf3d7d14ebf02ab0294edcadb | 0181a5d868db069795d7a4533eca9ec610e7c753f049e26516c1a1657364977b | None 
| SpellVisualKit | patch-enUS-3.MPQ | 8663 | 3fd35945ed732ccc88ff9bdce91be05abb94bcd030a9cb84ce08e932dc5d24a1 | 241dd6ff5bb1cf99d01187c1f0808ea8b7c0a437c29af7e26d99bd13ad7d6b72 | None 
| SpellVisualEffectName | patch-enUS-3.MPQ | 3965 | 0556356171ea424666e0b42961bc5d6997a1c6c08242b2eee799bf75ba3559e8 | f6ed5e6369e294d526b444fea4e4086bf11addd0ec7f0acdcae00b435b0dc331 | None 
| SpellVisualKitModelAttach | patch-enUS-3.MPQ | 591 | 01bdac91ce21525ffa4c527b9a0d227bd0a97d93f4a9f223c0b637c1ede17a6b | 40abefc45808638ff20c173dcdec93852fd61e96351c4452931f2a2aa106107e | None 
| SpellVisualPrecastTransitions | locale-enUS.MPQ | 3 | 3f81455326df9c6568ce34bb8afe81b9d66694e5b763e0909380a9f184dd98ee | 4636993d3e1da4e9d6b8f87b79e8f7c6d018580d52661950eabc3845c5897a4d | None 
| SpellMissile | patch-enUS-3.MPQ | 105 | a049e09d4027e7b0c7992aca3a0b002d522a25b4fed11de9ef88ab22b9511495 | d7afea5077fe01eb4a2db17726152eb4567b1e528819407f1763d158738dcd0b | None 
| SpellMissileMotion | patch-enUS-3.MPQ | 204 | f24c81f36de34eab396eaf4771828c88c2a3fd0ff7d2a1c90682bec14cd20e64 | 224b56458f82ce4ded0aa1de99e4a8bcf7bcd05ef887d1e05afa0681357b2b41 | None 
| SoundEntries | patch-enUS-3.MPQ | 12941 | 6ed8ea6fcb90fa35d0ad8f709b8c7a27b37fa917cb64215128a49afe6c4e95a5 | da1020d0ac46baad7476990185b1df1a5538df0e45b2e7c3ed90b4acb7e87cbb | None 
| AnimationData | patch-enUS-3.MPQ | 506 | 5c694f178114b6e55e50ac9fa1045a69ff859ddf6dbd934e0334a4cda0172a3f | 1acc02cda14fe314094ce45707d7e7c6454b881672c612ee95c16cc47ba15078 | None 

These entries are not EffectiveClientTableSet approval. SpellCastTimes comes from patch-enUS-2; SpellVisualPrecastTransitions from locale-enUS. All six primary selected tables equal A and B by full-byte hash. E differs for Spell and SpellVisual; F/M extend visual dependencies, not these selected members. Full comparisons remain in A.8 inventories.

## Evidence and limits

The local editor configuration selects base-overrides, enUS, with no manual order. Its Python source defines the model; it was read, not imported or executed. The extractor source also defines a tool-specific archive order. Neither is native client loader source. The project MPQ strategy explicitly leaves client discovery/precedence to future evidence. Hash/member matches improve pinning but do not close that gap.

See [member inventory](ULDuar_A9_MPQ_MEMBER_INVENTORY.json), [release manifest](ULDuar_A9_RELEASE_MANIFEST.json) and [main report](../implementation/ULDuar_PHASE_A9_RELEASE_EVIDENCE.md).
