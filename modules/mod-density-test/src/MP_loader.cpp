/*
 * This file is part of the mod-density-test project.
 */

void AddDensityCommands();
void AddDensityConfigScripts();
void AddDensityCreatureScripts();
void AddDensityGameObjectScripts();
void AddDensityPlayerScripts();

void Addmod_density_testScripts()
{
    AddDensityConfigScripts();
    AddDensityCommands();
    AddDensityCreatureScripts();
    AddDensityGameObjectScripts();
    AddDensityPlayerScripts();
}
