# 05 — FrameXML de Ascension

**VERIFIED FROM ASCENSION SOURCE**, A01/A13/A14/A22/A24–A28.
FrameXML no contiene solamente marcos vanilla: es también bootstrap, datos de dominio, servicios y overrides.

## Secuencia relevante leída

1. Referencias Logging/HDPatch/PTR; algunas faltan en la extracción.
2. Constantes, TypeExtensions, Mixin, utilidades, serialización/compresión y GlobalOverwrites.
3. AtlasInfo, enums, callbacks, DataProvider, fuentes/localización.
4. Datos/utilidades de CA, game mode, objetos, spellbook, appearance y otros servicios C_*.
5. Pools/NineSlice y helpers; BasicControls, WorldFrame, Region.xml y UIParent.xml.
6. LibStub, objetos y GameTooltip; templates de tabs/scroll/paneles.
7. Dropdowns/UIPanelTemplates, secure templates, StaticPopup, MainMenuBar, microbuttons.
8. SpellBookFrame/CharacterFrame y otros marcos base; después overrides custom.
9. Ascension_Spellbook, compatibilidad de addons y FrameXMLPost.

Es resumen parcial del manifiesto, no lista para copiar. El orden de funciones definidas puede preceder
su dependencia si la dependencia se usa solo al ejecutar después; no confundir load-time y call-time.

## Qué cambia realmente

- TypeExtensions instala métodos sobre tipos compartidos. `SetShown` visto en un addon no prueba API vanilla.
- GlobalOverwrites cambia funciones existentes, incluso consultas de CA según preview.
- UIParent decide qué addon LoD abrir para cada modo.
- CharacterFrame y Spellbook custom reemplazan/integran marcos del shell.
- GameTooltip contiene lógica extra y formatters; los addons no son los únicos dueños de tooltips.
- MainMenuBarMicroButtons.xml declara botones custom con scripts; VehicleMenuBar los conoce.
- XML referencia esquema propio; archivos pueden usar templates/funciones que no existen en Ulduar.

**ASCENSION CLIENT DEPENDENCY:** getters de metatable, ciertos eventos/tipos/funciones, servicios nativos ausentes
de la extracción y assets de cliente custom. SharedXML no elimina esas dependencias.

## Coste de este enfoque y selección Ulduar

**INFERRED.** Tener bootstrap y shell bajo control facilita integración exacta, a costa de mantener un fork de UI,
compatibilidad con addons y pruebas de carga. No se deduce de ello que Ulduar necesite reemplazar todo FrameXML.

**DESIGN DECISION.** Autorizar como objetivo solamente loader mínimo y microbutton/vehículos propios.
Las features y el protocolo siguen como addons. Mantener fuentes vanilla objetivo identificadas por versión/hash,
y parches de tamaño revisable. No importar GlobalOverwrites, CustomFunctionChecks ni bases CA de Ascension.
El hecho de que una función exista en esta extracción nunca basta para escribirla en Ulduar.
