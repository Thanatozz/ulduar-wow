-- Apply manually to the characters database after the module's 001/002 character migrations.
-- Existing builds retain their ranks; the four new modifiers start at zero.
ALTER TABLE `character_ulduar_abilities`
    ADD COLUMN `damage_rank` INT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN `cooldown_reduction_rank` INT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN `cast_time_reduction_rank` INT UNSIGNED NOT NULL DEFAULT 0,
    ADD COLUMN `chain_rebound_rank` INT UNSIGNED NOT NULL DEFAULT 0;
