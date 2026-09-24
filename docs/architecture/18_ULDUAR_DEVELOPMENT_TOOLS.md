# 18 — Herramientas de desarrollo

**VERIFIED FROM ASCENSION SOURCE**, A29.
UIDevelopmentTools declara LoD, DefaultState disabled y SV para historial/aliases de consola.
Su TOC carga Console, EventTrace, AtlasBrowser y TableInspector; GlueXML además incluye sus XML directamente.
AtlasBrowser agrupa AtlasInfo por textura, inicializa una vez y filtra por nombre/atlas en ScrollList.
TableInspector y EventTrace separan templates de fila y controller; es una referencia de composición,
no autorización para copiar ejecución arbitraria de consola ni datos internos.

TableInspector:SearchObject intenta resolver una tabla por nombre y, como alternativa, usa loadstring/pcall para
evaluar una expresión. DevConsole:OnLoad reemplaza print/message globales para capturar salida; en Glue registra
eventos mediante C_Hook. EventTrace engancha EventRegistry.TriggerEvent y conserva entradas con argumentos/tiempo.
Son comportamientos comprobados en la referencia, **DO NOT COPY** para el inspector V1 de Ulduar.
Adoptar filas/filtrado y controles opt-in; evitar evaluación de expresiones y captura global permanente.

## Comandos Ulduar propuestos

**DESIGN DECISION.**

| Comando | Resultado |
| --- | --- |
| /ului inspect | Seleccionar frame y mostrar propiedades; solo lectura por defecto |
| /ului edit | Activar overlays y edición de frames opt-in |
| /ului frames | Lista filtrable de frames propios registrados, no scan continuo de _G |
| /ului reset [id] | Restaurar layout local del ID o selección; sin SQL |

Inspector muestra: name, parent, width/height, todos los anchors (point/relative/relativePoint/x/y),
strata, level, scale/effectiveScale, alpha, IsShown/IsVisible y mouse enabled.
Propiedad no accesible se imprime como unavailable; no llamar métodos inexistentes por analogía con Retail.

Datos se actualizan por selección/resize o frecuencia limitada mientras inspector esté visible.
Cerrar libera mouse/keyboard capture, handlers y overlays. Console dev completa no forma parte de V1.

## Diagnóstico adicional

Panel opcional de pools (activos/inactivos/creados), suscripciones vivas, versión de proveedor Shared,
catálogo/reglas/revision y estados de transporte. Mostrar token solo redactado.
Event trace opt-in con buffer circular acotado y filtro; no loggear todo CHAT_MSG_ADDON por defecto.
Si una fuente remota devuelve texto, tratar como datos: nunca ejecutarlo.

**RUNTIME TEST REQUIRED:** herramienta ausente no cambia gameplay ni UI normal;
editor deshabilitado no conserva OnUpdate pesado; cerrar bajo modal no deja bloqueo de input.
