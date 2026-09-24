# 07 — Spellbook: aprender sin reemplazarlo

**VERIFIED FROM ASCENSION SOURCE**, A26.
La extracción conserva SpellBookFrame.lua/xml y carga posteriormente
FrameXML/Ascension_Spellbook/Ascension_Spellbook.xml.
No se encontró un addon ordinario independiente Ascension_Spellbook con TOC en la lista inspeccionada:
el sistema es parte de FrameXML.

## Modelo observado

XML declara páginas, botones, tabs y panel de profesiones; Lua implementa SpellbookMixin, SpellButtonMixin,
SpellbookPageMixin y variantes de profesiones.
SpellButtonMixin:OnLoad inicializa SecureActionButton, atributo type=spellbook, clicks izquierdo/derecho y drag.
SetSpell resuelve slot/bookType/SpellID mediante C_Spell, ranks, entrenamiento y estados.
OnShow registra cursor/action/cooldown/shapeshift; OnHide desregistra y limpia.
OnDragStart hace PickupSpell y oculta highlight; los métodos de click contemplan modified clicks.
OnEnter usa GameTooltip:SetSpell más líneas de entrenamiento o ausencia en action bar.

SpellbookMixin atiende SPELLS_CHANGED, tabs, búsqueda, páginas y mascotas.
Hay pool de autocast shine; no todo frame es reconstruido al cambiar página.
Ascension_ProfessionBook añade botones secure y utilidades de profesión.
C_Spell mezcla funciones Lua y entorno custom: no confundirlo con el C_Spell Retail ni asumir equivalencia WotLK.

## Lecciones utilizables

- Separar catálogo/resolución de slot de la representación de una entrada.
- Reutilizar filas y limpiar estado al cambiar categoría/página.
- Respetar las rutas secure de cast y drag/drop.
- Refrescar información cuando cambian spells/cooldown, no consultar servidor por hover.
- Mantener tooltip como consumidor de ID normalizado.

**DO NOT COPY NOW:** ToggleSpellBook override, nuevas categorías de juego, entrenamiento integrado,
custom spellbook attributes y assets. Alteran una superficie muy sensible de interacción vanilla.

## Contrato Ulduar

**DESIGN DECISION.** Vanilla SpellBook + botón contextual Pearl + tooltip committed.
Conservar U15 como adaptador de integración, separado del AbilityEditor.
El servidor envía ranks/registry elegible; no mapear spell por nombre localizado.
El botón de 16–18 px se asocia a entrada/slot actual y se oculta al reciclarla o si deja de ser editable.
El click abre hub, tab Abilities e ID adecuado con guarda de Draft.
No cambiar OnClick/OnDragStart/atributos secure del SpellButton vanilla.

Instalar hooks una vez; obtener ID desde APIs de slot/link disponibles en cliente objetivo.
No inventar SetSpellBookItem de Retail. GameTooltip:SetSpell(slot, bookType) sí está usado en ambas fuentes.
Cambios estructurales en combate se posponen; tooltip lee cache local.
SpellButton_UpdateButton utiliza objetos con nombre/ID que no siempre coinciden con el sufijo visual;
preservar la resolución explícita del adaptador actual.

**RUNTIME TEST REQUIRED:** páginas, ranks inactivos, profesiones, mascotas, drag a actionbar,
modified clicks, combate, cambio de spell aprendido y addon de spellbook externo.
Si no se puede asociar una entrada con certeza, omitir el marcador; /ua continúa disponible.
