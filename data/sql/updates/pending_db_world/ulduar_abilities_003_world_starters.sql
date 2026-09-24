-- Ulduar Abilities: requested initial catalog (28 abilities), channel and aura payloads.
-- Filename must sort after ulduar_abilities_001_world.sql, which clears this script's bindings.
-- Requires mod-ulduar-abilities. Leaves every other module and Blizzard script binding untouched.
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_ulduar_ability_runtime' AND `spell_id` IN (-116, -5143, -7268, -20185, -133, -635, -3044, -2973, -1752, -2050, -589, -45902, -45477, -45462, -403, -331, -172, -686, -5176, -6807, -5185, -47541, -8921, -1082, -1978, -20271, -585, -2098, -8042, -348);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-116, 'spell_ulduar_ability_runtime'),
(-5143, 'spell_ulduar_ability_runtime'),
(-7268, 'spell_ulduar_ability_runtime'),
(-20185, 'spell_ulduar_ability_runtime'),
(-133, 'spell_ulduar_ability_runtime'),
(-635, 'spell_ulduar_ability_runtime'),
(-3044, 'spell_ulduar_ability_runtime'),
(-2973, 'spell_ulduar_ability_runtime'),
(-1752, 'spell_ulduar_ability_runtime'),
(-2050, 'spell_ulduar_ability_runtime'),
(-589, 'spell_ulduar_ability_runtime'),
(-45902, 'spell_ulduar_ability_runtime'),
(-45477, 'spell_ulduar_ability_runtime'),
(-45462, 'spell_ulduar_ability_runtime'),
(-403, 'spell_ulduar_ability_runtime'),
(-331, 'spell_ulduar_ability_runtime'),
(-172, 'spell_ulduar_ability_runtime'),
(-686, 'spell_ulduar_ability_runtime'),
(-5176, 'spell_ulduar_ability_runtime'),
(-6807, 'spell_ulduar_ability_runtime'),
(-5185, 'spell_ulduar_ability_runtime'),
(-47541, 'spell_ulduar_ability_runtime'),
(-8921, 'spell_ulduar_ability_runtime'),
(-1082, 'spell_ulduar_ability_runtime'),
(-1978, 'spell_ulduar_ability_runtime'),
(-20271, 'spell_ulduar_ability_runtime'),
(-585, 'spell_ulduar_ability_runtime'),
(-2098, 'spell_ulduar_ability_runtime'),
(-8042, 'spell_ulduar_ability_runtime'),
(-348, 'spell_ulduar_ability_runtime');
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'aura_ulduar_ability_runtime' AND `spell_id` IN (-116, -5143, -20185, -133, -589, -172, -8921, -1978, -8042, -348);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-116, 'aura_ulduar_ability_runtime'),
(-5143, 'aura_ulduar_ability_runtime'),
(-20185, 'aura_ulduar_ability_runtime'),
(-133, 'aura_ulduar_ability_runtime'),
(-589, 'aura_ulduar_ability_runtime'),
(-172, 'aura_ulduar_ability_runtime'),
(-8921, 'aura_ulduar_ability_runtime'),
(-1978, 'aura_ulduar_ability_runtime'),
(-8042, 'aura_ulduar_ability_runtime'),
(-348, 'aura_ulduar_ability_runtime');
