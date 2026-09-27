-- Ulduar Abilities: Drain Life channel aura tick adapter (CHANNEL_RUNTIME.md, "ChannelAuraTick").
-- Chain -689 (ranks 689, 699, 709, 7651, 11699, 11700, 27219, 27220, 47857): one APPLY_AURA
-- SPELL_AURA_PERIODIC_LEECH on the channel target, no payload spell. Spell + aura scripts on the chain; no native
-- script binds these ids. Without this file the Drain Life definition (catalog id 43) stays metadata.
-- Requires mod-ulduar-abilities. Apply after ulduar_abilities_003_world_starters.sql.
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'spell_ulduar_ability_runtime' AND `spell_id` = -689;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-689, 'spell_ulduar_ability_runtime');
DELETE FROM `spell_script_names` WHERE `ScriptName` = 'aura_ulduar_ability_runtime' AND `spell_id` = -689;
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(-689, 'aura_ulduar_ability_runtime');
