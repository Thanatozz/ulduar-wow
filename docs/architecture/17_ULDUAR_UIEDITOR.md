# 17 — Ulduar_UIEditor

**DESIGN DECISION, ADR-007.** Herramienta local para frames propios. No replica ForgeUI ni contiene backend de mundo.
`mod-ulduar-editor` actual manipula GameObjects mediante .uedit: es otro producto y otro permiso.

## V1: alcance obligatorio

Selección de frame registrado, mover, resize, grid, snap, nombre/coords, inspector, SavedVariables, reset
y exportación de layout Lua como texto para copiar. No escribir archivos ni ejecutar export automáticamente.

Registro propuesto: `UlduarUIEditor:RegisterEditable(id, frame, capabilities, defaults)`.
ID estable de diseño, independiente de nombre global o lease de pool.
Solo flags move/resize/scale expresamente autorizados; los widgets reciclados normalmente no son editables
individualmente.
El editor opera sobre el contenedor estable o descriptor de layout, no sobre una fila temporal.

Lifecycle: activar modo → seleccionar → capturar layout inicial → preview durante drag →
validar/clamp → guardar override local → salir retirando overlays y mouse capture.
Cuando el owner se oculta o se recicla, cancelar captura y selección. No retener frame en SV.

## Almacenamiento y export

SavedVariables propias `UlduarUIEditorDB` con schemaVersion, profileId, layouts[id] y resolución/escala de referencia.
Anchor exportado usa ID/nombre permitido de relativeFrame; si no tiene identidad exportable, rechazar y explicar.
Guardar point/relativePoint/x/y/width/height y campos explícitos; números finitos y límites razonables.
No persistir function, userdata, tokens de protocolo ni builds gameplay.

Export genera instrucciones Lua de layout simples en EditBox seleccionable.
Escapar nombres y validar valores; export es texto para revisión, no loadstring.
Reset(id) restaura defaults capturados/versionados; ResetAll solo layouts del editor.
Un cambio de schema conserva copia anterior y migra o vuelve a defaults por entrada inválida.

## V2

Jerarquía de frames registrados, undo/redo por comandos de layout, anchors visuales, snap entre frames,
strata/level, scale y alpha con caps. Undo debe guardar datos previos, no closures con referencias obsoletas.
Evitar ciclos de anchor y jerarquía. Historial acotado por perfil/sesión.

## V3 FUTURE

Texture picker, font picker y template browser. Solo especificación de dirección:
no implementar ni importar catálogos Ascension ahora.

## Restricciones

Fuera de combate para editar; frames protected/forbidden o propiedad Blizzard/terceros se inspeccionan solo si seguro,
nunca se mueven. No reemplazar metatables para interceptar todos los SetPoint.
No registrar eventos globales de mouse permanentemente cuando está desactivado.
Overlays y grid en estrato controlado no deben bloquear clicks al salir del editor.

**RUNTIME TEST REQUIRED:** drag/resize con scale, 4:3, selección de frame oculto, frame pooled liberado,
ESC durante drag, perfil inválido, reload y coexistencia con modal.
