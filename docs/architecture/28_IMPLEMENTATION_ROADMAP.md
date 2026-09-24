# 28 — Roadmap y puertas de aceptación

**DESIGN DECISION.** Orden de ejecución en 27; aquí se fijan entregables evaluables.

**M0 documentación**

- Entregable mínimo: 34 documentos y mapa de referencias
- Puerta de aceptación: Solo Markdown, incertidumbres visibles
- Fuera de alcance: Cualquier implementación

**M1 fundamento**

- Entregable mínimo: Provider Shared único + Ulduar_UI + widget ejemplo
- Puerta de aceptación: Bootstrap y lifecycle probados en 30300
- Fuera de alcance: MPQ/Glue/Framework Retail

**M2 Abilities adaptada**

- Entregable mínimo: Widgets reutilizados y layout estático XML
- Puerta de aceptación: Paridad de requests/Draft/gameplay
- Fuera de alcance: Rebalance o nuevo runtime

**M3 ciclo de UI**

- Entregable mínimo: Pools, composer y modal
- Puerta de aceptación: Sin fugas, external committed, ESC correcto
- Fuera de alcance: Reemplazar SpellBook

**M4 herramientas**

- Entregable mínimo: UIEditor V1 / inspector
- Puerta de aceptación: No afecta frames ajenos ni servidor
- Fuera de alcance: Forge/console universal

**M5 shell**

- Entregable mínimo: Microbutton FrameXML + vehículos
- Puerta de aceptación: Layout/click/padres/taint verificados
- Fuera de alcance: Reemplazo global de actionbars

**M6 distribución**

- Entregable mínimo: Patch compatible y rollback
- Puerta de aceptación: Instalación reproducible y versiones alineadas
- Fuera de alcance: DLL/client networking custom

**M7 expansión**

- Entregable mínimo: Segunda feature usando framework
- Puerta de aceptación: Sin copia de widgets ni nueva autoridad cliente
- Fuera de alcance: Todas las features a la vez

## Primera implementación recomendada

Una entrega pequeña de Phase 1: namespace/versión, helper Mixin explícito, event handles,
pool con reset y un IconButton de prueba usado por la feature detrás de un adaptador.
Mantener TOC/nombre/SV/protocolo/gameplay actuales hasta probar carga y paridad.
No empezar por portar toda SharedXML ni por reescribir Abilities a veinte archivos.

## Deuda previa que debe vigilarse

- Registro de fuentes untracked/nested module para futuras releases.
- Símbolos de templates residuales en otros módulos: revisión independiente antes de build solicitado.
- Campos obligatorios y versionado del wire ampliado.
- Rutas de fallo de persistencia y snapshots concurrentes.
- Audio secundario, transport snapshots y visuales: pruebas de runtime aparte; UI framework no los arregla.
- Documentación histórica del módulo: mantener enlaces a este diseño en tarea futura si se autoriza editarla.

## Criterio de evaluación

Cada PR/entrega describe problema, cambio, pruebas realizadas y límites. RUNTIME TEST REQUIRED no es PASS.
Revisar después de cada fase si se mantiene beneficio real; no construir abstracciones sin consumidor.
Las fases pueden dividirse en entregas más pequeñas, pero no saltar condiciones de loading/rollback.
