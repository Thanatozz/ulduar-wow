# 06 — Microbuttons: ownership de layout

**VERIFIED FROM ASCENSION SOURCE**, A25.
Los scripts de estado y los de layout son responsabilidades diferentes.

## Declaración y orden real

MainMenuBarMicroButton es un template virtual de 27x40; las texturas normal/pushed/highlight/disabled son 27x58
ancladas abajo. OnEnter usa tooltip/newbie/minLevel; Enable/Disable cambia alpha.
LoadMicroButtonTextures usa UI-MicroButton-<name>-Up/Down/Disabled y UI-MicroButton-Hilight.

En el layout normal leído:
Character → Spellbook → Talent → Achievement → QuestLog → Socials → LFD →
PathToAscension → Challenges → MainMenu → Help.

PVPMicroButton existe pero está hidden y no es el ancla del LFD en esta variante.
DraftModeMicroButton es un hijo especial de Talent con visibilidad según modo/picks; no equivale a otro hueco
horizontal del listado. No copiar el orden de Ascension como si fuera el de nuestro cliente vanilla.

Los botones consecutivos usan BOTTOMLEFT al BOTTOMRIGHT del previo con offset X=-3.
MainMenuBar tiene ancho declarado 1024, no un ancho calculado automáticamente por añadir cualquier botón.
Su arte y barras requieren revisión cuando cambie el ancho ocupado.

## Estados, clicks y PerformanceBar

UpdateMicroButtons comprueba ventanas abiertas, niveles/modes y aplica estados de botones.
Talent observa Collections/avances; otros tienen sus propios handlers de click.
La barra Performance se ancla a MainMenuMicroButton: cambia offsets entre normal y pushed
(10,-16 frente a 9,-18 en el código). No desplazarla de forma independiente para compensar el layout.

**No hay evidencia de que UpdateMicroButtons sea un registry genérico de layout.**
Hookear esta función no garantiza integrar anchoring, ancho, vehículos y visibilidad.

## Vehículos: segunda autoridad de layout

VehicleMenuBar.lua tiene lista local MicroButtons con botones custom de Ascension.
VehicleMenuBar_MoveMicroButtons reparienta el conjunto y cambia anclas de Character y Socials.
Normal: Character en MainMenuBarArtFrame, BOTTOMLEFT 552,2 y Socials después de Quest.
Vehículos de skins revisadas: Character se ancla a VehicleMenuBar y Socials inicia segunda fila bajo Character.
Los offsets son propios de cada skin; no son una API para insertar una ability.

Esto explica por qué una inyección que solo conoce Talent/Achievement es incompleta.
**INFERRED:** competir con relayout de Blizzard/addons puede ocasionar desplazamientos o un botón fuera de su padre.
No se ejecutó el cliente para atribuir cada bug de Ulduar a una única causa.

## Ulduar actual

U16 inserta Pearl solo si Achievement tiene un único anchor native hacia Talent y ambos padres son MainMenuBarArtFrame.
Guarda/restaura puntos; abandona layouts ajenos; hook UpdateMicroButtons programa layout en OnUpdate.
No bloquea el estado PUSHED durante clicks. Es una mitigación limitada, no integración definitiva.
Al ocultarse un frame su OnUpdate deja de ayudar a relayout: reaparición tras cambio de padre requiere pruebas.

## Estrategias y decisión

**A: addon-only**

- Ventaja: Sin patch; rollback quitando addon
- Coste / límite: Hook tras layout, detección de ownership, vehículos y addons externos; no controla shell completo

**B: FrameXML propio**

- Ventaja: Declara espacio real, scripts y lista de vehículos de forma coherente
- Coste / límite: Requiere patch versionado, fuente vanilla exacta y matriz de taint/compatibilidad

**DESIGN DECISION (ADR-004).** B es la arquitectura definitiva cuando exista cliente custom probado.
A continúa como fallback transitorio, sin prometer orden exacto en barras propiedad de otros addons.

Objetivo normal: Talent → Ulduar → Achievement, manteniendo resto del orden vanilla de la versión seleccionada.
Un descriptor de layout propio enumera botones para normal/vehículo y espaciado, aplicado por el shell;
no una cadena dinámica reescrita cada frame por la feature.
El microbutton llama una fachada lazy de UlduarUI; no referencia DraftBuild ni protocolo.
Si la feature está deshabilitada, tooltip informativo y operación segura, sin error Lua.
Un solo owner por instalación: activar hook addon y declaración FrameXML simultáneamente está prohibido.

## Criterios runtime

Login/reload, scale, 4:3/wide, combate, vehículo/posesión, salida de vehículo, ventana activa, click mantenido,
PerformanceBar/Help, addon deshabilitado y terceros que reparentan la barra.
Verificar centros/espacios y área clickable, no solo apariencia del Pearl.
Icono Ulduar: Interface/Icons/INV_Misc_Gem_Pearl_06; no assets de microbuttons Ascension.
