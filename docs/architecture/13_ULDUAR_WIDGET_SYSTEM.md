# 13 — Widgets y composición

**DESIGN DECISION.** Implementaciones propias sobre templates WotLK. API base/lifecycle en 11.
Las capacidades de una habilidad producen **descriptores**, no posiciones especiales para Frostbolt.

**MainFrame**

- Responsabilidad y modelo: Título, header, content, close, tamaño mínimo
- XML: Jerarquía decorativa y drag handle
- Lua / reciclaje: Factory única, posición/clamp

**Panel**

- Responsabilidad y modelo: Fondo/inset y bounds de contenido
- XML: Template simple
- Lua / reciclaje: Bind visibilidad/size

**Button**

- Responsabilidad y modelo: Acción estándar con razón disabled
- XML: UIPanelButtonTemplate o derivado
- Lua / reciclaje: Callback de owner; limpiar al release

**IconButton**

- Responsabilidad y modelo: Icono, border y highlight
- XML: Template propio sobre base Blizzard
- Lua / reciclaje: Atlas/texture y tooltip de modelo

**AbilityNode**

- Responsabilidad y modelo: Identidad, icono, disponibilidad
- XML: Capas/icon/rank/selection
- Lua / reciclaje: Bind AbilityId y view model

**ModifierNode**

- Responsabilidad y modelo: Rank Draft, coste y pending
- XML: Rank overlay y highlight
- Lua / reciclaje: Left/right intent; no SendAddonMessage

**Tab**

- Responsabilidad y modelo: Panel seleccionado, texto y highlight
- XML: CharacterFrame/OptionsFrame tab
- Lua / reciclaje: PanelTemplates y navigation guard

**ScrollList**

- Responsabilidad y modelo: Ventana de filas visibles
- XML: FauxScrollFrame y ScrollChild
- Lua / reciclaje: Offset, pool, selección por ID

**Tooltip**

- Responsabilidad y modelo: Ownership y líneas
- XML: GameTooltip existente
- Lua / reciclaje: Composer neutral, deduplicación

**Modal**

- Responsabilidad y modelo: Confirm/Discard/ESC
- XML: StaticPopup Blizzard
- Lua / reciclaje: Operación diferida y owner lock

**Header**

- Responsabilidad y modelo: Jerarquía de sección
- XML: FontString/arte opcional
- Lua / reciclaje: Texto/localización

**Divider**

- Responsabilidad y modelo: Separación discreta
- XML: Textura Blizzard
- Lua / reciclaje: Resize sin recreación

**StatusText**

- Responsabilidad y modelo: Ready/Pending/Error
- XML: FontString
- Lua / reciclaje: Estado del controller

**Connection**

- Responsabilidad y modelo: Relación visual entre nodos
- XML: Segmento reutilizable
- Lua / reciclaje: Geometría/ruta y estados por descriptor

## Datos de nodo y estados

Modelo mínimo: id, label, icon/atlas, rankCommitted, rankDraft, maxRank opcional, enabled, selected,
pending, reason, tooltipDescriptor y callbacks de intención.
No inventar máximo cinco: maxRank ausente no se convierte en 5; los límites vienen de reglas/capabilities.

Estados visuales independientes:
disabled no es rank cero; selected no equivale a committed; pending puede ser aumento o retirada.
Rank mostrado es Draft en editor y committed fuera. Un highlight pequeño y texto Preview evita confundir gameplay.
Base Element es informativo, ligeramente destacado; nunca un botón gratuito de respec.

Los nodos modificadores se agrupan por descriptor de sección (Offense/Propagation), orden y requisitos visibles.
Rebound solo visible cuando Draft mode Chain; la capa estado decide qué sucede al cambiar a otro modo:
no ocultar gasto inválido silenciosamente.

## Pool contract por consumidor

- Ability list: filas visibles + pequeño margen fijo; selección y tooltip se limpian al reutilizar.
- Modifier nodes: adquirir por capabilities visibles; identidad lógica separada de frame.
- Connections: referencia IDs, no punteros a nodos inactivos; recalcular después de layout.
- Tabs: pocos elementos; pooling opcional si panel registry dinámico; identidad no cambia al reordenar.
- CityBuilder futuro: objetos de UI (filas/palette) solamente, nunca GameObjects del servidor.

Init instala scripts base una vez. OnAcquire no añade el mismo HookScript repetidamente.
OnRelease cancela animaciones/pulses, desregistra callbacks y oculta tooltip propio.
No reciclar un frame seleccionado por UIEditor sin avisar al inspector; sus overlays deben seguir lease válida.

## Límites visuales

Reutilizar assets ya disponibles antes de crear sprites. Conexiones simples ortogonales; un motor de pathfinding
general no es requisito del MVP. Ningún widget requiere SetAtlas nativo, NineSlice Retail, máscaras o ScrollBox.
La estética se comprueba mediante screenshots ingame y pruebas de mouse, no solo revisión XML.
