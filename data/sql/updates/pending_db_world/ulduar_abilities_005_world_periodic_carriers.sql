-- Ulduar Abilities: native periodic damage carriers (PERIODIC_RUNTIME.md, "Native carrier").
-- Spell 141344..141350 = ledger transaction PC1-PERIODIC-CARRIER-RESERVATION-002 (docs/data/ulduar_id_allocations.json).
-- Server-side rows only: one generic SPELL_AURA_PERIODIC_DAMAGE aura per school, no class family, no dispel type,
-- no other effect. Amount, interval, duration and stacks are set at runtime by aura_ulduar_periodic_carrier.
-- Icons reuse native icon ids (reference, not allocation); client presentation belongs to ulduar-client-patch.
-- Requires mod-ulduar-abilities. Apply after ulduar_abilities_003_world_starters.sql.
DELETE FROM `spell_dbc` WHERE `ID` BETWEEN 141344 AND 141350;
INSERT INTO `spell_dbc` (`ID`, `CastingTimeIndex`, `DurationIndex`, `RangeIndex`, `Effect_1`, `ImplicitTargetA_1`, `EffectAura_1`, `EffectAuraPeriod_1`, `SpellIconID`, `Name_Lang_enUS`, `Name_Lang_Mask`, `DefenseType`, `SchoolMask`) VALUES
(141344, 1, 9, 1, 6, 6, 3, 1000, 245, 'Ulduar Periodic Carrier (Physical)', 16712190, 2, 1),
(141345, 1, 9, 1, 6, 6, 3, 1000, 156, 'Ulduar Periodic Carrier (Holy)', 16712190, 1, 2),
(141346, 1, 9, 1, 6, 6, 3, 1000, 31, 'Ulduar Periodic Carrier (Fire)', 16712190, 1, 4),
(141347, 1, 9, 1, 6, 6, 3, 1000, 1771, 'Ulduar Periodic Carrier (Nature)', 16712190, 1, 8),
(141348, 1, 9, 1, 6, 6, 3, 1000, 188, 'Ulduar Periodic Carrier (Frost)', 16712190, 1, 16),
(141349, 1, 9, 1, 6, 6, 3, 1000, 313, 'Ulduar Periodic Carrier (Shadow)', 16712190, 1, 32),
(141350, 1, 9, 1, 6, 6, 3, 1000, 225, 'Ulduar Periodic Carrier (Arcane)', 16712190, 1, 64);
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'aura_ulduar_periodic_carrier' AND `spell_id` BETWEEN 141344 AND 141350;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(141344, 'aura_ulduar_periodic_carrier'),
(141345, 'aura_ulduar_periodic_carrier'),
(141346, 'aura_ulduar_periodic_carrier'),
(141347, 'aura_ulduar_periodic_carrier'),
(141348, 'aura_ulduar_periodic_carrier'),
(141349, 'aura_ulduar_periodic_carrier'),
(141350, 'aura_ulduar_periodic_carrier');
