# 02 — Arquitectura extraída de Ascension

**VERIFIED FROM ASCENSION SOURCE** A01–A34; véase mapa para rutas y alcance de lectura.
Esto es una interfaz 30300 profundamente extendida, no una biblioteca portable de addons vanilla.

## Capas y arranque

FrameXML.toc incluye SharedXML, utilidades y datos de dominio, XML de marcos vanilla, overrides y herramientas.
GlueXML.toc incluye su propio conjunto de utilidades, templates y pantallas; vuelve a incluir primitivas compartidas.
No demuestra que Glue y mundo compartan una misma instancia de tablas Lua ni sus SavedVariables.

LibraryXML contiene TOCs individuales de bibliotecas, por ejemplo AceEvent-3.0.toc incluye su XML.
No hay un LibraryXML.toc global en la extracción inspeccionada. No se encontró bootstrap Lua suficiente para
afirmar que vanilla descubre allí paquetes como descubre AddOns. Esta dependencia queda **INFERRED / RUNTIME TEST
REQUIRED**.

UIParentLoadAddOn delega en LoadAddOn y maneja fallo. CharacterAdvancement_LoadUI selecciona variantes según modo/clase.
Collections crea tabs con nombres de panel que pueden no existir aún; el PreClick invoca el loader de la feature.
Así evita requerir todas las features al cargar el hub.

## Addons examinados

**Ascension_CharacterAdvancement**

-  Dependencias y carga declaradas: LoD; Dependencies Collections; templates → browser → main XML; sin SV declaradas en
  su TOC
- Datos, eventos y presentación: C_CharacterAdvancement; eventos pending/learn/result; pools y mixins

**Ascension_Collections**

- Dependencias y carga declaradas: LoD; CollectionsTabMixin.lua → Collections.xml; sin SV declaradas
- Datos, eventos y presentación: Hub y factories LoD, clase/game mode, drag, Show/Hide y tabs

**Ascension_UIDevelopmentTools**

- Dependencias y carga declaradas: LoD, DefaultState disabled; SV DevConsoleHistory/DevConsoleAliases
- Datos, eventos y presentación: Console, EventTrace, AtlasBrowser, TableInspector; XML y mixins

**Ascension_AppearanceUI**

- Dependencias y carga declaradas: LoD; depende Collections; templates y mixins por categoría/modelo
- Datos, eventos y presentación: C_Appearance, separación wardrobe/collection/model; assets específicos

**Ascension_VanityCollection**

- Dependencias y carga declaradas: LoD; depende Collections; Lua/XML y VanityStore auxiliar
- Datos, eventos y presentación: Colección/tienda; fade controller y datos propios, no un mount journal portable

**Ascension_InspectUI**

- Dependencias y carga declaradas: LoD; paneles Lua/XML y side panels
- Datos, eventos y presentación: _NotifyInspect y resultado MYSTIC_ENCHANT_INSPECT_RESULT; tabs condicionales

**AscensionUI**

- Dependencias y carga declaradas: Depende Collections; SV global y por personaje; librerías embebidas
- Datos, eventos y presentación: Utilidades históricas, CASpecList, skill tree, gossip/prestige y death recap

No inferir que LoD implica que nunca se carga al login: otra dependencia, loader o inclusión directa puede cargarlo.
GlueXML incluye directamente XML de UIDevelopmentTools; esa ruta no ejecuta necesariamente su TOC ni inicializa SV
igual.

También se localizaron variantes CharacterAdvancementSeason9, CoATalents, TalentUI, BuildCreator y SkillCards.
Su presencia demuestra especialización por modo; no se auditó exhaustivamente todo su gameplay.
Profesiones tienen adaptador dentro de FrameXML/Ascension_Spellbook, además de APIs y paneles tradicionales.
No se identificó un subsistema universal independiente llamado Codex/Compendium que debamos imitar por su nombre.

## Cómo llegan datos a UI

CA recibe entradas por GetSpellsByClass/GetTalentsByClass y consulta elegibilidad, ranks y pending state con C_*.
Los eventos de resultado refrescan widgets; no hay SQL ni valores de daño autoritativos calculados por el addon CA.
La implementación de esas operaciones principales no está en Lua en las capas buscadas.
**ASCENSION CLIENT DEPENDENCY:** motor/API y probablemente integración servidor propia; protocolo exacto no visible.

No todos los C_* son nativos. C_TrinityCore.lua implementa chat auxiliar ASCENSION_LUA sobre SendAddonMessage;
C_PopupQueue.lua implementa una cola en Lua. No usar esta observación para afirmar que CA utiliza ese chat:
no se trazó tal vínculo. GlobalOverwrites conserva referencias a funciones C_CharacterAdvancement ya existentes
y cambia consultas según previewCharacterAdvancementChanges; es wrapper, no backend completo.

## Compatibilidad: qué adoptar

**Mixins y pools con reset explícito**

- Clasificación: SAFE TO ADAPT CONCEPTUALLY
- Aplicación Ulduar: Implementación propia namespaced

**Templates + controladores de estado**

- Clasificación: SAFE TO ADAPT CONCEPTUALLY
- Aplicación Ulduar: XML estático y view models

**Atlas por nombre y metadatos**

- Clasificación: SAFE TO ADAPT CONCEPTUALLY
- Aplicación Ulduar: SetTexture/SetTexCoord mediante fachada

**Callbacks y datos observables**

- Clasificación: SAFE TO ADAPT CONCEPTUALLY
- Aplicación Ulduar: Handles y unsubscribe, sin copiar barreras secure

**Tab con carga diferida de panel**

- Clasificación: SAFE TO ADAPT CONCEPTUALLY
- Aplicación Ulduar: Registry de paneles con dependencia unidireccional

**Metatables globales, SetAtlas añadido a todos los Texture**

- Clasificación: RISKY / ASCENSION-SPECIFIC
- Aplicación Ulduar: No adoptar

**C_CharacterAdvancement, C_Appearance, servicios custom de realm**

- Clasificación: ASCENSION-SPECIFIC
- Aplicación Ulduar: Adaptadores Ulduar sobre protocolo propio

**Sustituir SpellBook, inspect o todas las descripciones**

- Clasificación: DO NOT COPY NOW
- Aplicación Ulduar: Mantener integración contextual

**Declarar microbutton en FrameXML propio**

- Clasificación: POTENTIALLY GOOD
- Aplicación Ulduar: Tras disponer de patch compatible y rollback

**Credenciales guardadas por login custom**

- Clasificación: DO NOT COPY
- Aplicación Ulduar: No almacenar contraseñas en SV ni UI layouts

El estilo puede inspirar composición y ciclo de vida sin copiar texturas, nombres de assets, código ni branding.
La procedencia/licencia de una librería se verifica de forma independiente; estar en la extracción no concede permiso.
