# 09 — Arquitectura actual de Ulduar

**VERIFIED FROM ULDUAR SOURCE**, foto 2026-09-08. Referencias U01–U19 del mapa.
El árbol cliente contiene el addon UlduarAbilities; no una implementación Ulduar de SharedXML, GlueXML o UIEditor.
No confundir una carpeta objetivo documentada con un componente ya cargado.

## Inventario y decisiones

**AbilityDefinitions.cpp/.h**

- Comportamiento actual: Registro central, starters y metadata deshabilitada
- Clasificación y destino: KEEP; ampliar por capacidades y adaptadores comprobados

**AbilityTypes.h/.cpp**

- Comportamiento actual: Taxonomía, costes, estado, curvas y capacidades
- Clasificación y destino: KEEP; separar DTO/reglas si crece, sin duplicar autoridad

**AbilityRuntime.h**

- Comportamiento actual: AbilityCast inmutable compartido; PayloadEvent mutable por evento; AbilityHit
- Clasificación y destino: KEEP; conservar aislamiento y GUIDs

**AbilityManager.cpp/.h**

- Comportamiento actual: Cache GUID/AbilityId, rank chain, DB y validación atómica
- Clasificación y destino: KEEP; REFACTOR acceso DB/versiones cuando se justifique

**AbilityPlayerScript.cpp**

- Comportamiento actual: Login carga, logout descarga, delete limpia fila
- Clasificación y destino: KEEP

**AbilityCommands.cpp**

- Comportamiento actual: Comandos GM .ua
- Clasificación y destino: KEEP; no usar para tráfico del addon

**AbilityAddonProtocol.cpp**

- Comportamiento actual: Transporte de snapshots y ApplyBuild
- Clasificación y destino: KEEP contrato; REFACTOR esquema y push explícito

**AbilitySpellScript.cpp**

- Comportamiento actual: Adaptadores root/channel/aura y modificadores
- Clasificación y destino: KEEP; aislar nuevos tipos, no mezclar UI

**AbilityPropagationResolver.cpp/.h**

- Comportamiento actual: Selección de modos, scheduling, historia Chain
- Clasificación y destino: KEEP; límites y pruebas de rendimiento

**AbilityTargetResolver.cpp/.h**

- Comportamiento actual: Filtros legales y relación separada del efecto
- Clasificación y destino: KEEP

**SecondarySpellExecutor.cpp/.h**

- Comportamiento actual: Spell del Player; contexto exacto por Spell*; proxies y tiempo de vuelo
- Clasificación y destino: KEEP con RUNTIME TEST REQUIRED

**UlduarAbilities.cpp**

- Comportamiento actual: Registro y lectura de config; validación DB al startup
- Clasificación y destino: KEEP

**Core.lua**

- Comportamiento actual: Namespace UlduarAbilitiesUI, eventos, Refresh global y navegación
- Clasificación y destino: REFACTOR en bootstrap, store y controllers

**Protocol.lua**

- Comportamiento actual: Recepción, staging, reglas, mensajes y sesión
- Clasificación y destino: KEEP wire; MOVE internamente a Protocol/

**DraftBuild.lua**

- Comportamiento actual: Copia editable y presupuesto local; también modal
- Clasificación y destino: KEEP estado; MOVE modal a servicio compartido

**UlduarFrame.lua**

- Comportamiento actual: CreateFrame estático, drag header, clamp/SV
- Clasificación y destino: MOVE jerarquía estática a XML gradualmente

**AbilityList/Tree/Details.lua**

- Comportamiento actual: Lista, configurador por capacidades, resumen
- Clasificación y destino: REFACTOR a views con modelos de presentación

**Widgets/Node, Connections, ScrollList, Tabs.lua**

- Comportamiento actual: Widgets propios solo de Abilities; tabs Blizzard
- Clasificación y destino: MOVE primitivas neutras a Ulduar_UI

**AbilityTooltip.lua**

- Comportamiento actual: Descriptor y texto añadido a tooltip vanilla
- Clasificación y destino: KEEP separación committed/draft; REFACTOR composer

**SpellBookIntegration.lua**

- Comportamiento actual: Pearl 16x16 por entrada editable
- Clasificación y destino: KEEP; no reemplazar SpellButton

**UlduarMicroButton.lua**

- Comportamiento actual: Inyección en cadena native, hook UpdateMicroButtons
- Clasificación y destino: REPLACE por shell FrameXML cuando exista patch probado

**UlduarAbilities.toc**

- Comportamiento actual: 30300, 1.4.0, carga eager, SavedVariables
- Clasificación y destino: KEEP durante migración de nombres

**README/PROTOCOL/ASSETS del addon y docs del módulo**

- Comportamiento actual: Documentación de iteraciones anteriores
- Clasificación y destino: DEPRECATE como decisión objetivo cuando contradiga estos documentos

## Registro, disponibilidad y estado

`FindAbilityBySpell` usa `SpellMgr::GetFirstSpellInChain`; disponibilidad itera `GetNextSpellInChain`
y `Player::HasActiveSpell`. Requiere RuntimeEnabled, clase compatible (ClassId=0 permite cualquier clase)
y spell aprendido. El máximo rank aprendido informa tiempos/cooldowns de preview.
No hay ClassMask general todavía: existe **ClassId**. No traducir esta diferencia a una migración obligatoria.

Frostbolt y Arcane Missiles están runtime-enabled; Flash Heal y Blizzard son metadata-only.
Existen más starters: afirmar que solo Frostbolt está activo sería una descripción obsoleta.
El registro no certifica cobertura mecánica completa para todos los tipos.

El manager cachea configuraciones por GUID, no consulta DB por cada cast. Login utiliza LEFT JOIN con fila sentinel
para distinguir personaje sin datos de consulta fallida. Las mutaciones validan una copia completa, hacen upsert
de una fila y verifican por lectura antes de publicar cache/revisión. Logout no vuelve a escribir un snapshot viejo.
Delete está integrado, condicionado a DB disponible; fallos de DB requieren reconciliación operativa.
La columna heredada `secondary_damage_rank` guarda PotencyRank. La revisión es uint64 en memoria, no columna persistida.

## Draft y protocolo

Committed se publica al finalizar snapshot; Draft conserva base/revisión y vista editable.
Element, delivery y ranks cambian localmente. Confirm envía una build completa.
Los tooltips externos usan Committed. La UI interna usa Preview. Reset también se prepara en Draft.

Prefix ULDAB1, versión de payload 2, whisper a sí mismo. El servidor obtiene Player de la sesión,
no de un GUID enviado por el cliente. Hay token, secuencia, throttling y límites de longitud.
La versión actual no tiene push general para premios/GM: una UI puede quedar vieja hasta GET; la revisión impide
sobrescribir silenciosamente el estado. Véase 16 para wire y deuda.

## Gameplay y core preexistente

**Spells/Spell.h**

- Función observada: Opcionales por instancia: school, target validator, visual source, travel, ammo, cast time
- Riesgo / preservación: KEEP aislamiento; futuras adiciones pequeñas/generalizables

**Spells/Spell.cpp**

- Función observada: Pipeline que consume school custom y serializa visual/travel; caster lógico intacto
- Riesgo / preservación: RUNTIME TEST REQUIRED procs, reflect, log, arrival y defaults

**Spells/SpellEffects.cpp**

- Función observada: Propaga school hacia cálculos de efectos de daño
- Riesgo / preservación: Auditar cada efecto; no asumir cobertura de todos los spells

**Entities/Unit/Unit.h**

- Función observada: Firmas con school override opcional
- Riesgo / preservación: Default conserva ruta anterior; contrato compartido sensible

**Entities/Unit/Unit.cpp**

- Función observada: Cálculos de daño/inmunidad/modificadores aceptan override
- Riesgo / preservación: No sustituye todos los usos de SpellInfo en auras/procs

No se modifica `SpellInfo::SchoolMask` compartido en la ruta revisada. Healing conserva rutas escolares originales
en varios puntos: conversión total de healing no está implementada por tener el enum.
El caster de ejecución sigue siendo Player. Los proxies WorldTrigger sirven de fuente visual, no lanzan gameplay.
El tiempo de viaje usa distancia y velocidad nativa; el mismo delay se comunica al cliente. La política de presentación
no puede garantizar silenciar todos los kits sonoros de GO. Transporte móvil, muerte/despawn y carga masiva son pruebas
pendientes.

SecondarySpellExecutor tiene un mailbox global protegido por mutex, indexado por identidad exacta Spell* y con
ScopedHandoff limitado a prepare. Es infraestructura de entrega de contexto, **no** un global current ability/school.
TakeContext consume la entrada; la vida de Spell pasa al evento del core. Conservar esta distinción al refactorizar:
eliminar el mapa sin sustituir su contrato de asociación puede romper nested casts y payloads de channel.

La selección de secundarios descarta triggers, targets muertos, mapas/fases incompatibles, errores de target legality,
LOS/visibilidad y objetivos no permitidos por relación. Enemy además limita neutrales a combate con ese Player y evita
flag PvP incidental. Any usa ataque o asistencia native: no hereda automáticamente todos los filtros adicionales de
Enemy.
Esa diferencia merece pruebas cuando se habiliten abilities Any, no una afirmación de equivalencia entre relaciones.

## Otros módulos y deuda concreta

- `mod-ulduar-editor`: editor **de GameObjects en mundo** mediante .uedit y permisos GM; no es editor de frames Lua.
-  `mod-citybuilder` : loader reservado; fuente de ejemplo todavía presente. No documentar CityBuilder como feature
  completa.
- `mod-density-test`: managers/scripts de diagnóstico de densidad, separado del producto UI.
- Dos fuentes físicas, citybuilder/src/MyPlayer.cpp y ulduar-editor/src/MyPlayer.cpp, definen AddMyPlayerScripts.
  El loader citybuilder está vacío, pero un objeto compilado puede seguir aportar el símbolo duplicado.
  **INFERRED:** riesgo de linker según selección real de fuentes. No se compiló ni corrigió durante esta auditoría.
- Código cliente y SQL pending eran untracked al inicio; el módulo tiene su propio estado Git.
  Antes de empaquetar, registrar fuentes/manifiestos deliberadamente; no confiar solo en diff del repositorio raíz.
-  Refresh global, modal con guardas ESC, reglas de preview paralelas y cambios de wire sin nueva versión en cada
  iteración
  son costes de mantenimiento. Migrarlos con pruebas de compatibilidad, no mediante rewrite.
- ApplyBuild/Commit mantiene el mutex del manager durante persistencia síncrona y readback; el handler de protocolo
  también mantiene su mutex durante Snapshot/ApplyBuild. **INFERRED:** una DB lenta puede bloquear operaciones de otros
  personajes que usan estos locks. Medir antes de diseñar colas/asíncrono; preservar orden y resultado incierto al
  migrar.
