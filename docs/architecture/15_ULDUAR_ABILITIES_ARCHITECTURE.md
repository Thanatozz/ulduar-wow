# 15 — Ulduar_Abilities objetivo

**DESIGN DECISION.** Migrar la feature actual UlduarAbilities sin reescribir su runtime ni cambiar su wire
incidentalmente. El nombre con underscore es paquete objetivo; su adopción requiere migración explícita.

## Estructura propuesta

```text
Ulduar_Abilities/
  Ulduar_Abilities.toc
  Bootstrap.lua
  Data/CatalogStore.lua
  Data/RulesStore.lua
  State/CommittedStore.lua
  State/DraftStore.lua
  State/BuildPreview.lua
  Protocol/Transport.lua
  Protocol/Codec.lua
  Protocol/SnapshotAssembler.lua
  Controllers/AbilityController.lua
  Controllers/NavigationController.lua
  Presentation/AbilityViewModel.lua
  Presentation/AbilityDescriptionComposer.lua
  Presentation/ModifierDescriptors.lua
  Views/AbilityFrame.xml
  Views/AbilityFrame.lua
  Views/AbilityList.lua
  Views/AbilityEditor.lua
  Views/CurrentBuild.lua
  Integration/Spellbook.lua
  Integration/ActionTooltips.lua
  Integration/Hub.lua
```

Esto es distribución de responsabilidades, no obligación de crear veinte archivos vacíos.
Las primitivas de botón/tab/pool no vuelven a implementarse aquí.

## Modelo de datos y autoridad

CatalogStore: registry disponible para este Player, rank mapping, taxonomía, BaseElement y capacidades.
RulesStore: costes, curvas y caps anunciados con versión.
CommittedStore: snapshots confirmados indexados AbilityId, revisión y sesión.
DraftStore: copia base + vista mutable local + dirty + conflicto, una ability activa.
BuildPreview: cálculo determinista con reglas recibidas, nunca concede puntos ni daño al gameplay.
No serializar Committed como fuente de verdad en SavedVariables ni reusarlo tras nuevo token sin refrescar.

Controllers envían intención al store. Bind de widgets recibe view model inmutable por convención/copia;
no permitir que un widget escriba sobre Committed.
Reset produce Draft Original/None/ranks cero; Confirm aplica build completa. Cancel/Discard no toca DB.

## Flujo de edición

```text
Snapshot completo -> Committed -> BeginDraft
  -> intent (left/right/element/delivery/reset)
  -> DraftStore + BuildPreview
  -> editor/tooltips/budget muestran Preview
  -> Confirm -> APPLY_BUILD(baseRevision, desired fields)
  -> servidor valida/persiste/publica revision
  -> snapshot confirmado -> Committed + Draft
```

Un error no ejecuta navegación pendiente. STALE descarta la base obsoleta como candidato a commit:
mostrar conflicto y estado actual, sin mezclar automáticamente puntos nuevos con selección vieja.
No reenviar mutation tras timeout; GET/re-handshake y reconciliación explícita.

## Vistas

- Main frame: header movible y clamp, punto SV validado, ESC mediante navigation guard.
- Left: solo catálogo elegible conocido; icon/name native; rank y +EP únicamente si EP>0.
- Editor: nombre, Base Element centrado, conversiones excepto base, delivery, secciones de modifiers.
- Current Build: contexto claramente Draft Preview si dirty; acceso a committed para comparación.
- Details: cast/target/delivery/temporal/range/effects; letra Blizzard moderada.
- Connections: descriptors entre nodos, estado derivado; no determinan requisitos de gameplay.
- Tabs Abilities funcional; Builds/Codex/Progression placeholders hasta backend propio.
- Confirm/Discard: servicio modal y botón de commit único; bloqueo mientras hay request pendiente.
- Spellbook/hotbar: integración separada, committed; microbutton pertenece al shell/Hub.

## Descripción natural tipada

Composer recibe AbilityDefinition/State/rules/effective stats, más un contexto `draft` o `committed`.
Salida propuesta: title, primarySegments, propagationSegments, advancedSegments, caveats.
No modifica DBC ni parsea y sustituye palabras localizadas.

Ejemplos semánticos, sin inventar cifras de daño:
- Frostbolt Fire/Shatter: daño de Fire; después del impacto salen proyectiles hacia hasta N enemigos en R yd.
  El slow conserva su comportamiento original.
- Chain: hasta N saltos; R yd por hop; indicar Rebound/gap solo si habilitado.
- Nova: todos los objetivos legales en radio, sin convertirla en target-count.
- Periodic: efecto por tick/duración/total se presenta solo si el descriptor conoce esos datos.
- Healing o mixed: separar segmentos Healing/Damage; no deducir TargetRelation de EffectFlags.
- Physical: escuela base física se representa, pero el enum no habilita conversión física funcional.

Si hay datos exactos de rango de daño ajustado por rank/stats disponibles de servidor, etiquetar estimación
y sus supuestos. Resistencias, absorciones/crit situacionales no se convierten en promesas del tooltip.
Hasta ampliar ese DTO, conservar descripción vanilla más sección Ulduar clara. Shift revela clasificación/ranks/caps.

## Runtime servidor que se conserva

Registry → resolver native rank/controller/payload → snapshot AbilityCast → PayloadEvent por hit/tick →
TargetResolver → SecondaryExecutor Spell del Player.
No comunicar VisualSource al addon para que calcule damage. La UI no corrige los proyectiles del core.
ChannelTicks no se modela como un único evento por channel completo. Secondary presenta Potency según payload;
no usar la migración de widgets para alterar esos cálculos.

Referencias actuales: U01–U16; pruebas de paridad en 30. Healing overhaul, persistent area completa,
GCD reduction y nuevos nodos no quedan autorizados por este diseño.
