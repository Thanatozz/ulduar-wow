# 27 — Migración incremental

**DESIGN DECISION.** No rewrite total. Cada fase mantiene una ruta funcional anterior y una salida comprobable.
No ejecutar builds/client/SQL por leer este plan: requiere autorización vigente.
Archivos de fases futuras son propuestas; no fueron creados durante la auditoría.

## Phase 0 — Documentation

- GOALS: fijar evidencia, contratos, ADRs y pruebas; preservar todo código existente.
- FILES AFFECTED: docs/architecture/*.md exclusivamente.
- RISKS: confundir propuesta con implementación, basarse en documentación histórica.
- RUNTIME TESTS: ninguno ejecutado; registrar preguntas abiertas en 30.
- ROLLBACK: retirar solo documentos nuevos; nunca revertir cambios de código preexistentes.
- EXIT: índice completo, referencias y distinción de niveles de evidencia.

## Phase 1 — Create Ulduar shared UI foundation

- GOALS: namespace/version, Mixin puro, event handles y primer pool básico; un provider addon.
- FILES AFFECTED: futuro client/Interface/AddOns/Ulduar_Shared y Ulduar_UI; dependencias de TOC de feature.
- RISKS: doble inicialización, funciones inexistentes en vanilla, ciclos de dependencia.
- RUNTIME TESTS: login/reload, feature deshabilitada, proveedor ausente/duplicado, callbacks liberados.
- ROLLBACK: quitar dependencia nueva y restaurar feature anterior; sin tocar estado servidor/DB.
- EXIT: un widget demostrable con API neutral; no construir todos los servicios futuros.

## Phase 2 — Migrate UlduarAbilities widgets

- GOALS: migrar Node/ScrollList/Tabs de uno en uno mediante adaptador con API existente.
- FILES AFFECTED: Widgets/*.lua de addon y Ulduar_UI/Widgets; controllers mínimos de enlace.
- RISKS: callback doble, rank/selection antiguo en frame reciclado, cambio accidental de protocolo.
- RUNTIME TESTS: paridad visual, left/right Draft, tooltips internos/externos, scroll y cambio de ability.
- ROLLBACK: feature flag por widget restaurando implementación previa; jamás ambas activas.
- EXIT: mismo comportamiento/requests, UI usa primitivas compartidas.

## Phase 3 — Move static layout to XML

- GOALS: main frame y contenedores estáticos en templates; Lua conserva datos/controllers.
- FILES AFFECTED: nuevo Views/AbilityFrame.xml y TOC; UlduarFrame.lua/constructores estáticos.
- RISKS: handlers no definidos al OnLoad, nombres duplicados, anchors/drag alterados.
- RUNTIME TESTS: tamaños/scale, 4:3, ESC, SV, apertura/cierre y tabs.
- ROLLBACK: volver al constructor anterior y orden TOC anterior; nunca cargar dos main frames.
- EXIT: layout equivalente, sin cambio de balance ni wire.

## Phase 4 — Create pools/mixins/widgets

- GOALS: extender pool básico de fase 1 al árbol/conexiones/listas; lifecycle y cleanup uniformes.
- FILES AFFECTED: Shared/Pools, UI/Widgets/Connections y views dinámicas.
- RISKS: referencias a frames liberados, fugas de callbacks, crecimiento de pools.
- RUNTIME TESTS: cientos de refresh/cambios, conteos estables, hover tras reciclaje, resize y selección.
- ROLLBACK: revertir consumidor por separado; API shared compatible con fase 2.
- EXIT: memoria/frame count estable. Esta fase consolida, no retrasa la primera implementación de pool de fase 1.

## Phase 5 — Migrate tooltip/modal system

- GOALS: composer tipado, Shift details y StaticPopup adapter con Confirm/Discard/ESC.
- FILES AFFECTED: AbilityTooltip/DraftBuild; Presentation/AbilityDescriptionComposer; UI/Tooltips/Modals.
- RISKS: tooltip externo Draft, texto de aura incorrecto, ESC descarta datos, commit duplicado.
- RUNTIME TESTS: cambios dirty, modal sobre modal, error/STALE/timeout, School/DoT/healing y hovered refresh.
- ROLLBACK: preservar tooltip append actual y modal manual como fallback por release, un solo owner activo.
- EXIT: navegación solo tras respuesta confirmada; ninguna descripción afirma mecánica no soportada.

## Phase 6 — Implement Ulduar UI Editor

- GOALS: V1 local, inspección y edición opt-in; comandos /ului.
- FILES AFFECTED: nuevo addon Ulduar_UIEditor; registro opt-in mínimo de frames.
- RISKS: tocar frames protegidos, guardar referencias inválidas, overlays bloqueando input.
- RUNTIME TESTS: V1 de 17/18, reset/SV corruptas/reload/combate.
- ROLLBACK: deshabilitar addon y limpiar solo perfil de editor opcional; defaults UI intactos.
- EXIT: no requiere servidor ni modifica GameObjects. V2/V3 quedan separados.

## Phase 7 — Move microbutton into custom FrameXML

- GOALS: fuente vanilla exacta, definición del botón y layout normal/vehículo coherente.
- FILES AFFECTED: futuros overrides MainMenuBarMicroButtons y VehicleMenuBar/loader; fallback addon.
- RISKS: validación del cliente, taint, doble botón, rows, addons de barras y PerformanceBar.
- RUNTIME TESTS: matriz 06/19 completa en cliente aislado, incluyendo patch experimental mínimo si hace falta.
- ROLLBACK: retirar override y reactivar fallback addon mediante perfil/version marker.
- EXIT: evidencia de carga/función del shell. No distribuir una carpeta FrameXML suelta suponiendo que carga sola.

## Phase 8 — Prepare patch-U.MPQ

- GOALS: formalizar packaging, precedencia comprobada, manifest de release, updater y rollback.
- FILES AFFECTED: futuros manifests/pipeline de cliente; ubicación canónica Shared/Glue/assets aprobados.
- RISKS: orden MPQ distinto al supuesto, archivos parciales, mismatch UI/Shared/addon.
- RUNTIME TESTS: instalación limpia/upgrade/rollback, locale, addon ausente y errores de loader.
- ROLLBACK: restaurar artefacto previo y conjunto de addons compatible; conservar SV reversibles.
- EXIT: procedimiento repetible con hashes, allowlist y versiones. No implica nuevo DBC ni DLL.

## Phase 9 — Expand to CityBuilder/Collections/etc.

- GOALS: añadir una feature real reutilizando framework y contrato servidor propio.
- FILES AFFECTED: nuevos addons de feature y módulos correspondientes, registry de paneles.
- RISKS: duplicar frameworks, dependencia circular del hub, confundir UIEditor con editor de mundo.
- RUNTIME TESTS: aislar features, disponibilidad/permisos, carga LoD, errores independientes.
- ROLLBACK: deshabilitar feature nueva sin afectar Abilities o UI base.
- EXIT: segunda feature usa widgets existentes; cambios de gameplay son tareas independientes.

## Reglas de transición

Congelar protocolo mientras se migra presentación. Cambios de wire usan versión coordinada en otra entrega.
No renombrar addon/SavedVariables hasta disponer de migración y compatibilidad.
No volver a aplicar SQL para resolver un problema de layout.
No marcar una fase completa con pruebas solo estáticas cuando su EXIT exige cliente.
