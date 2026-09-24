# Arquitectura Ulduar: índice y contrato de trabajo

Auditoría de fuentes del 8–9 de septiembre de 2026. Esta carpeta es la **source of truth del diseño objetivo**.
El código sigue siendo la evidencia del comportamiento actual: una decisión aquí no significa implementación.
No se compiló ni ejecutó servidor, cliente, SQL, CMake o addons de referencia.

## Cómo leer y resolver discrepancias

1. Leer [01 — visión del sistema](01_SYSTEM_OVERVIEW.md).
2. Comparar el estado real en [09 — Ulduar actual](09_CURRENT_ULDUAR_ARCHITECTURE.md).
3. Consultar las decisiones y condiciones de adopción en [ADRs](ARCHITECTURE_DECISIONS.md).
4. Implementar solamente una fase autorizada de [27 — migración](27_MIGRATION_PLAN.md).
5. Registrar pruebas con [30 — plan runtime](30_RUNTIME_TEST_PLAN.md).

Los documentos del módulo anteriores describen etapas sucesivas; no son prueba de que un comportamiento visual
funcione. Si contradicen esta auditoría, comprobar el símbolo citado y actualizar la evidencia antes de programar.
Los cambios de código existentes al iniciar esta tarea se conservaron. Su presencia en git no es un cambio de esta
auditoría.

## Niveles de evidencia

- **VERIFIED FROM ASCENSION SOURCE**: declaración, llamada o flujo leído en la extracción; no prueba ejecución.
- **VERIFIED FROM ULDUAR SOURCE**: comportamiento trazado estáticamente en el checkout local.
- **INFERRED**: interpretación razonada, con límite de evidencia señalado.
- **DESIGN DECISION**: contrato propuesto/adoptado para implementación futura.
- **RUNTIME TEST REQUIRED**: depende del cliente, base de datos, red, render o ejecución.
- **ASCENSION CLIENT DEPENDENCY**: utiliza una extensión del entorno de Ascension que Ulduar no debe presuponer.

Los identificadores Axx/Uxx remiten a [ASCENSION_REFERENCE_MAP](ASCENSION_REFERENCE_MAP.md).
Las rutas de Ascension son referencias de lectura; nunca dependencias de distribución.

## Índice completo

**[01_SYSTEM_OVERVIEW](01_SYSTEM_OVERVIEW.md)**

- Propósito: Alcance, evidencia y mapa cliente/servidor

**[02_ASCENSION_ARCHITECTURE_ANALYSIS](02_ASCENSION_ARCHITECTURE_ANALYSIS.md)**

- Propósito: Carga, addons, servicios y lecciones de compatibilidad

**[03_ASCENSION_SHAREDXML](03_ASCENSION_SHAREDXML.md)**

- Propósito: Inventario técnico de infraestructura compartida

**[04_ASCENSION_CHARACTER_ADVANCEMENT](04_ASCENSION_CHARACTER_ADVANCEMENT.md)**

- Propósito: Ciclo de vida, datos, nodos, conexiones y pending build

**[05_ASCENSION_FRAMEXML](05_ASCENSION_FRAMEXML.md)**

- Propósito: Overrides y dependencias del entorno

**[06_ASCENSION_MICROBUTTONS](06_ASCENSION_MICROBUTTONS.md)**

- Propósito: Orden, anchors, vehículos y estrategia Ulduar

**[07_ASCENSION_SPELLBOOK](07_ASCENSION_SPELLBOOK.md)**

- Propósito: Libro custom y conservación del libro vanilla

**[08_ASCENSION_TOOLTIPS_AND_MODALS](08_ASCENSION_TOOLTIPS_AND_MODALS.md)**

- Propósito: Descripciones, hooks y confirmación

**[09_CURRENT_ULDUAR_ARCHITECTURE](09_CURRENT_ULDUAR_ARCHITECTURE.md)**

- Propósito: Inventario actual y KEEP/REFACTOR/MOVE/REPLACE/DEPRECATE

**[10_TARGET_CLIENT_ARCHITECTURE](10_TARGET_CLIENT_ARCHITECTURE.md)**

- Propósito: Capas, nombres y dependencias objetivo

**[11_ULDUAR_SHAREDXML](11_ULDUAR_SHAREDXML.md)**

- Propósito: Contratos de primitivas compartidas

**[12_ULDUAR_UI_FRAMEWORK](12_ULDUAR_UI_FRAMEWORK.md)**

- Propósito: Ciclo de vida, navegación y servicios UI

**[13_ULDUAR_WIDGET_SYSTEM](13_ULDUAR_WIDGET_SYSTEM.md)**

- Propósito: Widgets, pools y estados

**[14_ULDUAR_XML_LUA_RULES](14_ULDUAR_XML_LUA_RULES.md)**

- Propósito: Distribución de responsabilidades XML/Lua

**[15_ULDUAR_ABILITIES_ARCHITECTURE](15_ULDUAR_ABILITIES_ARCHITECTURE.md)**

- Propósito: Diseño de la feature y composer de descripciones

**[16_ULDUAR_PROTOCOL](16_ULDUAR_PROTOCOL.md)**

- Propósito: Wire actual, evolución, snapshots y errores

**[17_ULDUAR_UIEDITOR](17_ULDUAR_UIEDITOR.md)**

- Propósito: Editor de layout V1/V2/V3

**[18_ULDUAR_DEVELOPMENT_TOOLS](18_ULDUAR_DEVELOPMENT_TOOLS.md)**

- Propósito: Inspector, comandos y diagnósticos

**[19_FRAMEXML_STRATEGY](19_FRAMEXML_STRATEGY.md)**

- Propósito: Cambios mínimos del shell del cliente

**[20_GLUEXML_STRATEGY](20_GLUEXML_STRATEGY.md)**

- Propósito: Login y selección de personajes

**[21_LIBRARYXML_STRATEGY](21_LIBRARYXML_STRATEGY.md)**

- Propósito: Librerías externas y licencias

**[22_MPQ_PATCH_STRATEGY](22_MPQ_PATCH_STRATEGY.md)**

- Propósito: Empaquetado, precedencia y rollback

**[23_ASSET_ARCHITECTURE](23_ASSET_ARCHITECTURE.md)**

- Propósito: Recursos y atlas propios

**[24_LOAD_ORDER_AND_DEPENDENCIES](24_LOAD_ORDER_AND_DEPENDENCIES.md)**

- Propósito: Orden comprobado y perfiles de carga futuros

**[25_SERVER_CLIENT_BOUNDARIES](25_SERVER_CLIENT_BOUNDARIES.md)**

- Propósito: Ownership de datos y operaciones

**[26_SECURITY_AND_AUTHORITY](26_SECURITY_AND_AUTHORITY.md)**

- Propósito: Validación y límites de confianza

**[27_MIGRATION_PLAN](27_MIGRATION_PLAN.md)**

- Propósito: Fases con pruebas y rollback

**[28_IMPLEMENTATION_ROADMAP](28_IMPLEMENTATION_ROADMAP.md)**

- Propósito: Entregables y criterios de avance

**[29_CODING_CONVENTIONS](29_CODING_CONVENTIONS.md)**

- Propósito: Reglas para futuros agentes

**[30_RUNTIME_TEST_PLAN](30_RUNTIME_TEST_PLAN.md)**

- Propósito: Matriz de pruebas manuales

**[ASCENSION_REFERENCE_MAP](ASCENSION_REFERENCE_MAP.md)**

- Propósito: Rutas/símbolos y límites de inspección

**[ARCHITECTURE_DECISIONS](ARCHITECTURE_DECISIONS.md)**

- Propósito: Decisiones ADR y alternativas

**[GLOSSARY](GLOSSARY.md)**

- Propósito: Vocabulario común

## Rutas de lectura por tarea

- Antes de UI: 09, 10, 11, 12, 13, 14, 15, ADR-001/005/006 y 30.
- Antes de FrameXML: 05, 06, 19, 22, 24, ADR-002/004/008 y 30.
- Antes de protocolo: 09, 16, 25, 26, ADR-003/009 y 30.
- Antes del editor: 17, 18, 29 y ADR-007. No confundir UIEditor con el editor de GameObjects del servidor.
- Para estudiar Ascension: 02–08 y el mapa de referencias. No adoptar APIs por tener prefijo C_.

## FUTURE AGENT INSTRUCTIONS

Antes de implementar la arquitectura definitiva DEBE leerse, en este orden:

1. README.md.
2. [09_CURRENT_ULDUAR_ARCHITECTURE.md](09_CURRENT_ULDUAR_ARCHITECTURE.md).
3. [10_TARGET_CLIENT_ARCHITECTURE.md](10_TARGET_CLIENT_ARCHITECTURE.md).
4. [11_ULDUAR_SHAREDXML.md](11_ULDUAR_SHAREDXML.md).
5. [12_ULDUAR_UI_FRAMEWORK.md](12_ULDUAR_UI_FRAMEWORK.md).
6. [15_ULDUAR_ABILITIES_ARCHITECTURE.md](15_ULDUAR_ABILITIES_ARCHITECTURE.md).
7. [19_FRAMEXML_STRATEGY.md](19_FRAMEXML_STRATEGY.md).
8. [ARCHITECTURE_DECISIONS.md](ARCHITECTURE_DECISIONS.md).
9. [27_MIGRATION_PLAN.md](27_MIGRATION_PLAN.md).
10. [30_RUNTIME_TEST_PLAN.md](30_RUNTIME_TEST_PLAN.md).

Después leer los contratos específicos afectados, inspeccionar el código actual y registrar diferencias respecto de esta
foto. No ejecutar builds, SQL ni cliente por inferir permiso de esta documentación. La autorización vigente del usuario
prevalece. No copiar Ascension, no duplicar frameworks, no migrar todo en una sola entrega.
