# 30 — Plan de pruebas runtime

Todas las pruebas de este documento están **NOT RUN / RUNTIME TEST REQUIRED** en esta auditoría.
No ejecutarlas sin autorización. Registrar cliente build/locale, hash de patch, addon/protocolo, core commit,
config, pasos, resultado esperado/observado y logs/screenshots mínimos.
No usar PASS por haber leído una función.

## Carga y packaging

| ID | Caso | Resultado esperado |
| --- | --- | --- |
| L01 | Cliente vanilla + perfil addon limpio | Shared/UI/feature cargan en orden una vez |
| L02 | Shared faltante/versión incorrecta | Error explicable, UI segura; gameplay no modificado |
| L03 | Addon LoD no cargado; click hub | Factory/loader una vez, panel listo |
| L04 | Feature deshabilitada | Shell no llama global inexistente |
| L05 | Reload, salida a selección y reconexión | Estado de sesión invalidado; no replay de mutation |
| L06 | Shared en patch + shim addon | Un provider, sin duplicar handlers/templates |
| L07 | Patch/locale/loose files de precedencia | Resultado documentado por recurso y manifiesto |
| L08 | Rollback de release | Login y /ua recuperados con SV compatibles |

## UI, estado y presentación

| ID | Caso | Resultado esperado |
| --- | --- | --- |
| U01 | 4:3/wide, distintas UI scales | Ventana y nodos legibles/clickeables, sin clipping |
| U02 | Header drag, cerrar/reload y posición inválida | Posición recordada o reset/clamp seguro |
| U03 | Tabs seleccionadas y placeholders | Una página activa, anchor unido al borde |
| U04 | Scroll/orden/cambio de ability repetidos | Selección por ID, filas/tooltip sin datos viejos |
| U05 | Mage con ranks altos conocidos | Solo catálogo eligible; no exige rank 1 activo |
| U06 | Metadata-only/desaprendida/otra clase | No configurable; servidor también rechaza |
| U07 | 0 EP y EP disponibles | Oculta +0 EP, presupuesto correcto |
| U08 | Element base/convertido/reset Draft | No Original como escuela UI; reset requiere Confirm |
| U09 | 10 left/5 right/element/delivery | Cero mutation hasta Confirm; una APPLY_BUILD |
| U10 | Redistribuir/borrar rank y volver a base | Dirty correcto, sin ranks negativos ni puntos extra |
| U11 | Committed y Draft diferentes | Tooltip editor Preview; actionbar/spellbook committed |
| U12 | Cambios pendientes cerrar/cambiar | Confirm/Discard; ESC conserva Draft y cancela navegación |
| U13 | Modal sobre popup, clicks detrás/Enter doble | Bloqueo del owner, un request, no fuga de input |
| U14 | Pool acquire/release cientos de veces | Conteos estables, callbacks y tooltips liberados |
| U15 | Natural tooltip y Shift | Daño/aura/DoT/heal separados; no cifras inventadas |

## Integraciones

M01: Talent → Ulduar → Achievement; medir espacios y hit rects, no solo screenshot.
M02: click tras login/reload/scale, mantener mouse presionado mientras cambia estado.
M03: abrir/cerrar ventanas native, PerformanceBar y Help sin desplazamiento accidental.
M04: entrada/salida de vehículos/posesión, parent y filas correctos; combate sin taint.
M05: addon externo que reparenta barra: integración desactivada/adaptada sin lucha de anchors.
S01: vanilla SpellBook categorías, páginas, mascotas y distintos ranks.
S02: Pearl abre ability correcta; drag/drop y modified click de SpellButton intactos.
S03: tooltip de action normal, macro/spell no resoluble y tooltip de otro addon: no duplicar ni atribuir ability
errónea.

## Autoridad y protocolo

P01: HELLO/GET/BEGIN/END completos, cantidad y campos correctos.
P02: versión vieja, token antiguo, secuencia fuera de orden, remitente distinto y paquete >255 bytes.
P03: perder/duplicar fragmento/END; staging no se publica parcialmente; timeout y recuperación.
P04: confirmar dos veces; no doble gasto. GET puede repetirse; APPLY incierto no se repite automáticamente.
P05: GM sube/baja rank o config cambia mientras Draft abierto; STALE y estado actualizado.
P06: enviar ID ajeno, enum inválido, ranks extremos, gasto excesivo o Rebound sin Chain; rechazo completo.
P07: DB falla antes/después del write; no ack falso ni overwrite posterior con cache vieja.
P08: logout/login y delete; persistencia y limpieza, incluidos errores de DB.
P09: snapshot con cambios concurrentes de reglas/catálogo; detectar versión incoherente.
P10 futuro push: invalida/actualiza Committed sin ejecutar navegación pendiente de otro request.

## Paridad gameplay que debe conservar una migración UI

G01: Player A Frostbolt convertido y Player B normal simultáneos; daño/credit/school aislados.
G02: Shatter a varias distancias; daño y aura al llegar visual; primary muere/desaparece y snapshot válido.
G03: Chain: origen visual previo, ownership Player, targets no repetidos salvo Rebound legal.
G04: Rebound rank 0,1,3,6,9: gaps, prioridad de nunca golpeados y al menos tres unidades para loop estable.
G05: Split stagger por cantidad; ventana máxima y revalidación si target muere.
G06: Arcane Missiles: evento por payload tick; no channel adicional ni coste/GCD repetido.
G07: Arcane Shot/Serpent Sting: presentación nativa, impacto/sonido y animación sin promesas de mute no soportadas.
G08: caps 40/25/15 yd, Chain +1 yd/rank, Potency 10+5r y modifiers conforme config.
G09: immunity/absorb/resist/procs/reflect/crit/amenaza y daño periódico; slow Frostbolt sin cambio de aura.
G10: phase/map/transport, LOS y PvP, pets/totems/triggered casts ajenos; sin contaminación.
G11: módulo disabled y abilities no registradas se comportan como native.
G12: cooldown/category y cast time con haste, floors y caps; GCD intacto.

No resolver bugs de estas pruebas cambiando UI para ocultarlos. Reportar limitaciones del pipeline por separado.

## UIEditor

E01: inspect muestra todas las propiedades y unavailable si falta API.
E02: solo frames opt-in se mueven; protected/terceros quedan read-only.
E03: grid/snap/resize/clamp con scale, ESC y mouse release.
E04: SV inválidas, reset, export textual y reload; no ejecutar export.
E05: ocultar/liberar frame seleccionado retira overlays y callbacks.
E06: editor deshabilitado no afecta gameplay, layout ni consumo continuo de CPU.

## Formato de resultado

Cada ID: NOT RUN / PASS / FAIL / BLOCKED, entorno, pasos, observación, evidencia, limitación.
Separar STATICALLY VERIFIED de RUNTIME VERIFIED.
Una prueba falla por comportamiento observado, no por ausencia de screenshots; si no se ejecutó, es NOT RUN.
