# Mapa de referencias y alcance de evidencia

Raíz A: `C:/WoWProjecto/Work/Interface` (solo lectura).
Raíz U: `C:/WoWProjecto/ulduar-wow`.
Las rutas siguientes son relativas a su raíz. Los símbolos son anclas de búsqueda más estables que números de línea.
No se copió código ni assets. Fechas de lectura: 2026-09-08 y 2026-09-09.

## Ascension: referencias leídas

**A01**

- Ruta / símbolos: FrameXML/FrameXML.toc
- Evidencia / profundidad: Manifiesto completo; orden explícito, referencias faltantes

**A02**

- Ruta / símbolos: GlueXML/GlueXML.toc
- Evidencia / profundidad: Manifiesto completo; entorno Glue e inclusiones directas de herramientas

**A03**

- Ruta / símbolos: SharedXML/Util/Mixin.lua
- Evidencia / profundidad: Mixin, MixinSafe, MixinAndLoadScripts; copia de métodos y script binding

**A04**

- Ruta / símbolos: SharedXML/Pools.lua
- Evidencia / profundidad: ObjectPoolMixin, FramePoolMixin, FramePoolCollectionMixin; Acquire/Release/reset

**A05**

- Ruta / símbolos: SharedXML/AtlasInfo.lua; SharedXML/TypeExtensions/Texture.lua; SharedXML/Util/TextureUtil.lua
- Evidencia / profundidad: Tabla de atlas, SetAtlas, AtlasUtil; extensión global y wrapper

**A06**

- Ruta / símbolos: SharedXML/NineSlice.lua; NineSliceLayouts.lua
- Evidencia / profundidad: ApplyLayout, ApplyLayoutByName, NineSlicePanelMixin y catálogo

**A07**

- Ruta / símbolos: SharedXML/CallbackRegistryMixin.lua; GlobalCallbackRegistry.lua; Util/EventUtil.lua
- Evidencia / profundidad: Callbacks, handles, ciclo de suscripción y barreras secure

**A08**

- Ruta / símbolos: SharedXML/DataProvider.lua
- Evidencia / profundidad: Colección, ordenación, mutación y notificaciones

**A09**

- Ruta / símbolos: SharedXML/TabSystem/TabSystem.xml, TabSystemMixin.lua, TabSystemTabMixin.lua, TabSystemTemplates.xml
- Evidencia / profundidad: AddTab, SelectTab, UpdateTabLayout, paneles y pool

**A10**

- Ruta / símbolos: SharedXML/Scroll/Scroll.xml, ScrollList.lua, ScrollListItemBase.lua, HybridScrollFrame.lua
- Evidencia / profundidad: Lista basada en HybridScrollFrame y callbacks de datos

**A11**

- Ruta / símbolos: SharedXML/ScrollableDropDown.lua/xml; AddOns/Ascension_Poll/PollTemplates.xml y PollQuestionMixin.lua
- Evidencia / profundidad: Opciones, selección múltiple y consumidor Poll

**A12**

- Ruta / símbolos: SharedXML/LayoutFrame.lua; Util/FrameUtil.lua, PixelUtil.lua, AnchorUtil.lua
- Evidencia / profundidad: Layout y utilidades; muestreo de contratos

**A13**

- Ruta / símbolos: SharedXML/TypeExtensions/TypeExtensions.xml; Frame.lua, Region.lua, Texture.lua, Tooltip.lua
- Evidencia / profundidad: Acceso a metatables y extensiones globales

**A14**

- Ruta / símbolos: SharedXML/Util/CustomFunctionChecks.lua; FrameXML/Util/GlobalOverwrites.lua
- Evidencia / profundidad: Fallbacks DLL; wrappers sobre APIs preexistentes C_CharacterAdvancement

**A15**

- Ruta / símbolos: SharedXML/Util/C_TrinityCore.lua; FrameXML/Util/C_PopupQueue.lua
- Evidencia / profundidad: Ambos implementados en Lua; chat auxiliar y cola de popups

**A16**

- Ruta / símbolos: AddOns/Ascension_CharacterAdvancement/Ascension_CharacterAdvancement.toc
- Evidencia / profundidad: LoD, dependencia Collections, orden templates/browser/main

**A17**

- Ruta / símbolos: AddOns/Ascension_CharacterAdvancement/CharacterAdvancement.lua/xml
- Evidencia / profundidad: OnLoad/Show/Hide, FullUpdate, SetSpells, SetTalents, pending build; lectura dirigida

**A18**

- Ruta / símbolos: AddOns/Ascension_CharacterAdvancement/Templates/CharacterAdvancementTemplates.xml
- Evidencia / profundidad: Jerarquía y scripts/mixins de templates

**A19**

- Ruta / símbolos: AddOns/Ascension_CharacterAdvancement/Templates/CASpellButton.lua
- Evidencia / profundidad: SetEntry, estados, hover, clicks, drag, refresh

**A20**

- Ruta / símbolos: AddOns/Ascension_CharacterAdvancement/Templates/CAConnectedNodes.lua; CABranchTexture.lua
- Evidencia / profundidad: Rejilla de conexiones y reciclaje de segmentos

**A21**

- Ruta / símbolos: AddOns/Ascension_CharacterAdvancement/Templates/CAGate.lua; CASpecTab.lua; CAClassButton.lua
- Evidencia / profundidad: Requisitos, puntos por clase/spec, navegación

**A22**

-  Ruta / símbolos: FrameXML/CharacterAdvancement/CharacterAdvancementBaseTemplates.lua/xml; CAGateBaseMixin.lua;
  FrameXML/Util/CharacterAdvancementUtil.lua; CharacterAdvancementCostUtil.lua; FrameXML/Data/CharacterAdvancement.lua
- Evidencia / profundidad: Base y utilidades fuera del addon; muestreo/consumidores

**A23**

- Ruta / símbolos: AddOns/Ascension_Collections/Collections.lua/xml, CollectionsTabMixin.lua y TOC
- Evidencia / profundidad: Hub, carga diferida por tab, drag y cierre

**A24**

- Ruta / símbolos: FrameXML/UIParent.lua
- Evidencia / profundidad: UIParentLoadAddOn, CharacterAdvancement_LoadUI y otros loaders

**A25**

- Ruta / símbolos: FrameXML/MainMenuBarMicroButtons.lua/xml; MainMenuBar.lua/xml; VehicleMenuBar.lua
- Evidencia / profundidad: Templates, orden, estados, anchors y dos filas en vehículos

**A26**

-  Ruta / símbolos: FrameXML/SpellBookFrame.lua/xml; Ascension_Spellbook/Ascension_Spellbook.lua/xml;
  Ascension_ProfessionBook.lua; Util/SpellBookUtil.lua
- Evidencia / profundidad: Libro vanilla presente y override posterior; libro custom secure

**A27**

- Ruta / símbolos: FrameXML/GameTooltip.lua, GameTooltipMods.lua; SharedXML/TypeExtensions/Tooltip.lua
- Evidencia / profundidad: OnTooltipSetSpell, mod formatters, inserción de líneas y extensiones

**A28**

- Ruta / símbolos: FrameXML/StaticPopup.lua/xml; Util/C_PopupQueue.lua
- Evidencia / profundidad: Popup de pending changes y wrapper de cola

**A29**

-  Ruta / símbolos: AddOns/Ascension_UIDevelopmentTools/Ascension_UIDevelopmentTools.toc; Console/DevConsole.lua/xml y
  DevConsoleCommands.lua; EventTrace/EventTrace.lua/xml y EventTraceMixin.lua; AtlasBrowser/AtlasBrowser.lua;
  TableInspector/TableInspector.lua/xml
- Evidencia / profundidad: LoD, SV, browser, trace e inspección; lectura dirigida

**A30**

-  Ruta / símbolos: AddOns/Ascension_AppearanceUI/AppearanceWardrobeMixin.lua y TOC;
  Ascension_InspectUI/InspectFrame.lua y TOC; Ascension_VanityCollection/VanityCollection.lua y TOC
- Evidencia / profundidad: Muestreo: APIs appearance, inspect async, hub y layout

**A31**

- Ruta / símbolos: AddOns/AscensionUI/AscensionUI.toc
- Evidencia / profundidad: SV global/personaje, dependencia Collections; coexistencia de utilidades históricas

**A32**

- Ruta / símbolos: LibraryXML/*.toc; LibraryXML/AceEvent-3.0.toc; FrameXML/LibStub.lua
- Evidencia / profundidad: Inventario y manifiesto ejemplo; bootstrap externo no demostrado

**A33**

- Ruta / símbolos: GlueXML/AccountLogin.lua; CharacterSelect.lua
- Evidencia / profundidad: Muestreo: credenciales, selección y servicios custom

**A34**

- Ruta / símbolos: SharedXML/Backdrop.lua/xml; ButtonStateBehavior.lua; SharedPanelTemplates.lua/xml
- Evidencia / profundidad: Decoración y estados; muestreo de contratos

## Ulduar: referencias leídas

En U01–U09, prefijo `modules/mod-ulduar-abilities/src/`.
En U10–U16, prefijo `client/Interface/AddOns/UlduarAbilities/`.

**U01**

- Archivos / símbolos: AbilityTypes.h/.cpp; AbilityRuntime.h
- Evidencia: Dimensiones, estado, reglas y contexto

**U02**

- Archivos / símbolos: AbilityDefinitions.cpp/.h
- Evidencia: RegisterDefaultAbilities, starters, metadata/runtime

**U03**

- Archivos / símbolos: AbilityManager.cpp/.h
- Evidencia: Registro, ranks, disponibilidad, Load/Persist/Commit/ApplyBuild

**U04**

- Archivos / símbolos: AbilityAddonProtocol.cpp
- Evidencia: Handshake, mensajes, límites y Snapshot

**U05**

- Archivos / símbolos: AbilitySpellScript.cpp
- Evidencia: Adaptadores de daño/aura/channel, hooks

**U06**

- Archivos / símbolos: AbilityPropagationResolver.cpp/.h
- Evidencia: RootLaunch, impacto, Split, Chain/history

**U07**

- Archivos / símbolos: AbilityTargetResolver.cpp/.h
- Evidencia: Relaciones, filtros y origen de búsqueda

**U08**

- Archivos / símbolos: SecondarySpellExecutor.cpp/.h
- Evidencia: Contexto Spell*, proxy, travel time, prepare

**U09**

- Archivos / símbolos: UlduarAbilities.cpp; AbilityPlayerScript.cpp; AbilityCommands.cpp
- Evidencia: Registro, config, login/logout/delete y GM

**U10**

- Archivos / símbolos: UlduarAbilities.toc; Core.lua
- Evidencia: Orden 30300, eventos, namespace y sesión

**U11**

- Archivos / símbolos: Protocol.lua
- Evidencia: Staging de snapshot, reglas y confirmación

**U12**

- Archivos / símbolos: DraftBuild.lua
- Evidencia: Draft, Confirm, guardas y modal manual

**U13**

- Archivos / símbolos: UlduarFrame.lua; Widgets/Tabs.lua
- Evidencia: Layout, posición, navegación

**U14**

-  Archivos / símbolos: AbilityList.lua; AbilityTree.lua; AbilityDetails.lua; Widgets/Node.lua, Connections.lua,
  ScrollList.lua
- Evidencia: Presentación y nodos

**U15**

- Archivos / símbolos: AbilityTooltip.lua; SpellBookIntegration.lua
- Evidencia: Descriptor, hooks y marcador Pearl

**U16**

- Archivos / símbolos: UlduarMicroButton.lua
- Evidencia: Inyección limitada y restauración de anchors

**U17**

- Archivos / símbolos: src/server/game/Spells/Spell.h/.cpp, SpellEffects.cpp; Entities/Unit/Unit.h/.cpp
- Evidencia: Diff preexistente; school, visuales y hooks por instancia

**U18**

-  Archivos / símbolos: modules/CMakeLists.txt; src/cmake/macros/AutoCollect.cmake;
  modules/mod-ulduar-abilities/CMakeLists.txt
- Evidencia: Convención de fuentes y registro; no se ejecutó CMake

**U19**

-  Archivos / símbolos: modules/mod-ulduar-editor/README.md, src/UlduarEditor.cpp, src/MP_loader.cpp;
  modules/mod-citybuilder/src/MyPlayer.cpp, MP_loader.cpp; modules/mod-density-test/src
- Evidencia: Editor de mundo, residual de templates y módulo de diagnóstico

## Límites e incertidumbres

La búsqueda de implementaciones Lua de `C_CharacterAdvancement` encontró wrappers en GlobalOverwrites,
no una implementación completa de sus operaciones principales. `GetTextureMetatable` se consume sin definición
Lua encontrada en las cinco capas. Esto es dependencia del entorno custom; no identifica por sí solo la DLL exacta.
`C_TrinityCore` y `C_PopupQueue` sí tienen implementación Lua: el prefijo C_ no prueba código nativo.

No se encontró una implementación `ScrollBoxMixin` en las capas buscadas. El sistema observado es ScrollList/Hybrid.
No concluir que un binario o paquete ausente no pueda aportar otros sistemas.

Faltan, entre otras referencias de manifiesto: SharedXML/Logging.lua, SharedXML/HDPatch.xml,
PTRXML/PTR.xml y DevelopmentXML/DevelopmentXML.xml. Los esquemas XML referencian una XSD de Ascension:
es metadato de autoría, no prueba de que el parser vanilla acepte todas sus extensiones.

La presencia de TOCs en LibraryXML no demuestra su descubrimiento automático por un cliente vanilla.
No se dispone en el árbol cliente versionado de Ulduar de un manifiesto FrameXML/GlueXML propio ni de un
registro runtime de su carga. No se inspeccionó ni ejecutó Wow.exe para resolverlo.
