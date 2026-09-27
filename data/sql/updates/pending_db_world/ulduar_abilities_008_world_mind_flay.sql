-- Ulduar Abilities: Mind Flay channel emitter (CHANNEL_RUNTIME.md, "Mind Flay").
-- Controller chain -15407 (ranks 15407, 17311, 17312, 17313, 17314, 18807, 25387, 48155, 48156): spell + aura
-- scripts. Every rank triggers payload 58381 (SPELL_AURA_PERIODIC_TRIGGER_SPELL_WITH_VALUE); 58381 has no
-- SpellMgr rank chain and is bound by exact id. Without this file the Mind Flay definition stays metadata.
-- Requires mod-ulduar-abilities. Apply after ulduar_abilities_003_world_starters.sql.
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_ulduar_ability_runtime' AND `spell_id` IN (-15407, 58381);
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-15407, 'spell_ulduar_ability_runtime'),
(58381, 'spell_ulduar_ability_runtime');
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'aura_ulduar_ability_runtime' AND `spell_id` = -15407;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-15407, 'aura_ulduar_ability_runtime');
