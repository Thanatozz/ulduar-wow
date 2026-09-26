-- Ulduar Abilities: Blizzard channel area emitter (CHANNEL_RUNTIME.md, "Area emitter").
-- Controller chain -10 (ranks 10, 6141, 8427, 10185, 10186, 10187, 27085, 42939, 42940): spell + aura scripts.
-- Payload pulses have no SpellMgr rank chain, so each payload id the controller ranks trigger is bound exactly:
-- 42208-42213, 42198, 42937, 42938. The runtime infers the same set from the controllers' trigger effects.
-- Without this file only the Blizzard definition stays metadata. Apply after ulduar_abilities_003_world_starters.sql.
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_ulduar_ability_runtime' AND `spell_id` IN (-10, 42208, 42209, 42210, 42211, 42212, 42213, 42198, 42937, 42938);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-10, 'spell_ulduar_ability_runtime'),
(42208, 'spell_ulduar_ability_runtime'),
(42209, 'spell_ulduar_ability_runtime'),
(42210, 'spell_ulduar_ability_runtime'),
(42211, 'spell_ulduar_ability_runtime'),
(42212, 'spell_ulduar_ability_runtime'),
(42213, 'spell_ulduar_ability_runtime'),
(42198, 'spell_ulduar_ability_runtime'),
(42937, 'spell_ulduar_ability_runtime'),
(42938, 'spell_ulduar_ability_runtime');
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'aura_ulduar_ability_runtime' AND `spell_id` = -10;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-10, 'aura_ulduar_ability_runtime');
