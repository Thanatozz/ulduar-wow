# 08 — Tooltips y modals

**VERIFIED FROM ASCENSION SOURCE** A27/A28. **VERIFIED FROM ULDUAR SOURCE** U12/U15.

## Cuatro niveles distintos de tooltip en Ascension

**Hooks de eventos/métodos**

- Evidencia: GameTooltip.lua registra OnTooltipSetSpell y hooks de hyperlink/auras
- Portabilidad: Patrón adaptable, APIs exactas verificadas por cliente

**FrameXML override**

- Evidencia: GameTooltip_OnSetSpell y loops de ModTooltipSetSpell
- Portabilidad: No trasladar todo el pipeline

**Datos custom**

- Evidencia: C_Spell, GetSpellDescription, información de CA/enchants
- Portabilidad: ASCENSION CLIENT DEPENDENCY en operaciones no resueltas

**Extensión del tipo**

- Evidencia: TypeExtensions/Tooltip.lua: InsertLine/InsertLines/SetSpellByID
- Portabilidad: Modificación global, no usar en Ulduar

GameTooltipMods declara formatters de item y spell, incluye EmbedSpell y renombrados de modo.
Esto muestra reemplazos/inserciones de líneas, pero no demuestra que todas las descripciones se reescriban
mediante una API nativa única ni revela su cálculo en servidor.

Ulduar actual añade resumen derivado a tooltip vanilla; no produce todavía una descripción natural completa.
AbilityTooltipDescriptor separa elemento base/actual, propagation y stats; conservarlo como DTO de entrada.

## Composer Ulduar objetivo

**DESIGN DECISION.** AbilityDescriptionComposer retorna líneas/segmentos semánticos:
encabezado, descripción primaria, propagación, advertencias de preview y detalles avanzados.
La vista decide dónde dibujar; el composer no escribe directamente GameTooltip ni modifica globales.

- Externo (Spellbook/hotbar): Committed únicamente.
- Interno (editor): Draft explícitamente etiquetado Preview; resumen cambia sin request.
- Elemento efectivo: Original se resuelve a BaseElement, nunca se imprime como escuela nueva.
- Descripción natural mediante plantillas por tipo de payload, no reemplazo de cadenas Frost → Fire.
- Daño estimado requiere datos fiables de payload/rank/modifiers; si faltan, conservar texto vanilla y añadir
  descripción custom sin fingir cifras exactas. Resistencia/crit del enemigo no se conocen de forma general.
- Frostbolt convertido conserva su slow original; no describirlo como aura de Fire.
- DoT: distinguir daño por tick, duración y total; no inferir cambio de duración/tick rate.
- Healing: texto y cantidad separados de daño; mixed effects producen segmentos distintos.
- Physical: describir elemento base físico sin habilitar conversión física no soportada.
- Shift: muestra taxonomía, costes/ranks, revision y límites efectivos; sin Shift prioriza descripción jugable.
- Guardas de deduplicación por tooltip/ID/revision/contexto; invalidar al cambiar contenido o limpiar tooltip.

El tooltip no decide si la build es legal ni dispara GET por hover.

## Popup de Ascension y dependencia oculta

StaticPopupDialogs.CLOSE_CHARACTER_ADVANCEMENT_UNSAVED_PENDING_CHANGES ofrece APPLY/DISCARD/GO_BACK,
CanApplyPendingBuild, CancelPendingBuild y retorno a Collections.
El StaticPopup de esta extracción acepta aliases OnButton1/2/3 y funciones de visibilidad adicionales.
Su callback de botón 2 recibe reason="clicked"; **no asumir que la implementación exacta vanilla elegida
trata ESC con la misma semántica**. Copiar OnCancel=Discard sin distinguir salida sería peligroso.

C_PopupQueue es una cola Lua de frames/achievements con OnUpdate mientras hay trabajo.
No es una respuesta de servidor ni una prueba de modal blocking.

## Decisión Ulduar: StaticPopup con adaptador de feature

**DESIGN DECISION, ADR-010.** Migrar del modal manual a StaticPopupDialogs con key única ULDuar de forma incremental.
Usar el template Blizzard disponible y callbacks vanilla comprobados; no depender de aliases custom.
StaticPopup aporta apariencia/stack, pero por sí solo no bloquea todos los controles del owner:
controller debe adquirir bloqueo de edición/navegación y liberarlo al resolver/cancelar.

Texto: Unconfirmed Changes / Apply this build or discard your changes?
Botones visibles: **Confirm**, **Discard**. No tercer botón. Terminología de acciones siempre Confirm.

| Entrada | Efecto |
| --- | --- |
| Solicitar cerrar/cambiar con dirty | Guardar operación diferida única y abrir popup; no ocultar aún editor |
| Confirm | Bloquear doble click; enviar una build; operación se ejecuta solo tras snapshot exitoso |
| Discard por botón | Draft=Committed; ejecutar operación diferida; cero request de mutación |
| ESC | Cancelar la operación de navegación/cierre; conservar Draft y volver al editor |
| STALE/rechazo/timeout | No ejecutar operación diferida ni suponer éxito; mostrar estado real/error |
| Owner destruido/reload | Cancelar operación y handles; nunca reproducir un commit pendiente |

El adaptador debe diferenciar explícitamente botón Discard de escape/cierre programático.
Si no se verifica esa diferenciación en cliente objetivo, mantener modal actual hasta resolverla; no perder Draft.
Pruebas: ESC repetido, otro StaticPopup encima, muerte/combate, timeout, cambio de ability y clicks detrás del popup.
