# Architecture Decisions

Fecha de diseño: 2026-09-08; revisión documental: 2026-09-09. **DESIGN DECISION** en todos los ADR.
Status de diseño no equivale a implementación. Las condiciones de runtime/packaging son obligatorias antes de activar.
Fuente de contexto: documentos 02–09 y mapa Axx/Uxx.

## ADR-001 — Shared UI architecture

- ID: ADR-001.
- TITLE: una infraestructura propia compartida con provider único.
- STATUS: ADOPTED FOR TARGET DESIGN; NOT IMPLEMENTED.
- CONTEXT: widgets actuales son locales de Abilities; futuras features necesitan primitives comunes.
- DECISION: Ulduar_Shared + Ulduar_UI como addons primero; subconjunto neutral a SharedXML/Ulduar después.
- ALTERNATIVES: copiar SharedXML Ascension; framework distinto por feature; rewrite completo.
- CONSEQUENCES: nombres/versiones/contratos estables; exige lifecycle y migración de consumidores.
- MIGRATION IMPACT: fases 1–4; no cambiar protocolo ni comportamiento del servidor al extraer widgets.

## ADR-002 — AddOn vs FrameXML

- ID: ADR-002.
- TITLE: features en AddOns; shell mínimo en FrameXML.
- STATUS: ADOPTED FOR TARGET DESIGN; CUSTOM PROFILE REQUIRES RUNTIME TEST.
- CONTEXT: la referencia mezcla servicios de dominio y overrides; Ulduar hoy opera addon-only.
-  DECISION: Abilities/UIEditor/otras features permanecen addons; FrameXML solo bootstrap e integración profunda
  necesaria.
- ALTERNATIVES: todo en FrameXML; toda integración dinámica indefinidamente.
- CONSEQUENCES: menor superficie de fork y rollback independiente de features.
- MIGRATION IMPACT: fases 7–8 para shell, anteriores no necesitan custom client.

## ADR-003 — Protocol remains addon messages

- ID: ADR-003.
- TITLE: continuar con transporte addon C++ ↔ Lua.
- STATUS: ADOPTED; BASE TRANSPORT EXISTS.
- CONTEXT: ULDAB1/v2 ya soporta estado y ApplyBuild; C_CharacterAdvancement no está disponible en Ulduar.
- DECISION: evolucionar negociación/snapshot/push sobre addon messages; no networking custom Wow.exe inicialmente.
- ALTERNATIVES: APIs nativas custom, chat GM .ua, compresión inmediata.
- CONSEQUENCES: límites 255 bytes, correlación y framing explícito; transparencia de autoridad servidor.
- MIGRATION IMPACT: conservar wire durante migración UI; cambios incompatibles requieren versión coordinada.

## ADR-004 — Microbutton moves to FrameXML

- ID: ADR-004.
- TITLE: shell propietario de microbutton y layout normal/vehículo.
- STATUS: ACCEPTED TARGET, ACTIVATION CONDITIONAL ON CLIENT PATCH TESTS.
- CONTEXT: inserción por anchor no controla vehicle relayout, arte ni terceros.
- DECISION: declarar botón y descriptor/layout coherentes en FrameXML Ulduar; fallback addon hasta que exista patch.
- ALTERNATIVES: cadena manual completa; offsets de icono; reemplazar actionbar.
- CONSEQUENCES: orden normal Talent→Ulduar→Achievement estable en shell propio; mantener política para barra externa.
- MIGRATION IMPACT: fuente vanilla exacta, lista vehículo, version marker y desactivar inyección duplicada.

## ADR-005 — XML/Lua separation

- ID: ADR-005.
- TITLE: estructura estática en XML, datos y comportamiento en Lua.
- STATUS: ADOPTED FOR TARGET DESIGN.
- CONTEXT: constructor Lua actual mezcla decoración, geometría y handlers.
- DECISION: templates/main hierarchy en XML; instancias/capabilities/state/controllers en Lua.
- ALTERNATIVES: constructor monolítico; XML con todas las abilities/ranks.
- CONSEQUENCES: orden de carga y nombres requieren disciplina; contenido sigue dinámico.
- MIGRATION IMPACT: fase 3 por panel, conservando callbacks/nombres durante transición.

## ADR-006 — No global metatable patching

- ID: ADR-006.
- TITLE: mixins/helpers locales en vez de extensiones globales.
- STATUS: ADOPTED FOR TARGET DESIGN.
- CONTEXT: Ascension usa GetTextureMetatable y wrappers globales; compatibilidad vanilla no demostrada.
- DECISION: UlduarUI:SetAtlas y composición sobre frames propios; sin modificar tipos compartidos.
- ALTERNATIVES: portar TypeExtensions; añadir métodos globales para simular Retail.
- CONSEQUENCES: llamadas más explícitas, menor riesgo de colisiones/taint.
- MIGRATION IMPACT: diseñar APIs antes de migrar widgets; excepciones exigen ADR específico, evidencia y rollback.

## ADR-007 — Ulduar UI Editor

- ID: ADR-007.
- TITLE: herramienta dev local y opt-in, independiente del editor de mundo.
- STATUS: ADOPTED V1 SCOPE; NOT IMPLEMENTED.
- CONTEXT: mod-ulduar-editor actual edita GameObjects; no cubre layout de frames.
- DECISION: addon separado, registro de frames, V1 mover/resize/inspect/grid/SV/reset/export texto.
- ALTERNATIVES: replicar ForgeUI; editar todos los frames globales; mezclar .uedit con Lua layouts.
- CONSEQUENCES: limitado a nuestros frames; no permisos de mundo ni red.
- MIGRATION IMPACT: fase 6 después de widgets estables; V2/V3 entregas independientes.

## ADR-008 — MPQ packaging

- ID: ADR-008.
- TITLE: release de patch Ulduar verificable y reversible.
- STATUS: PROPOSED PACKAGING; PRECEDENCE/LOADING NOT VERIFIED.
- CONTEXT: carpetas extraídas no prueban orden de carga del exe instalado.
- DECISION: artefacto candidato patch-U.MPQ con allowlist/manifiestos/hash y versiones; validar nombre y precedencia.
- ALTERNATIVES: archivos sueltos sin control; copiar patch Ascension; DLL como requisito inicial.
- CONSEQUENCES: pipeline/release y pruebas de cliente necesarias; no incluir features/DB incidentalmente.
- MIGRATION IMPACT: fase 7 prototipo aislado; fase 8 packaging formal y rollback compatible.

## ADR-009 — Server authoritative ability state

- ID: ADR-009.
- TITLE: Committed servidor, Draft cliente, commit lógico completo.
- STATUS: ADOPTED; MAIN MODEL EXISTS.
- CONTEXT: edición local necesita redistribución y protección ante GM/rank changes.
- DECISION: presupuesto/legality/knowledge/capabilities en servidor; APPLY_BUILD con revisión; snapshot confirmado.
- ALTERNATIVES: request por punto; cliente decide coste; persistir Draft como build activa.
- CONSEQUENCES: necesita conflicto/timeout visible y no replay; cliente solo preview.
- MIGRATION IMPACT: preservar U03/U04/U12; versionar nuevos campos y no perder compatibilidad.

## ADR-010 — StaticPopup adapter

- ID: ADR-010.
- TITLE: confirmación Blizzard con operación diferida explícita.
- STATUS: ADOPTED TARGET; VANILLA CALLBACK/ESC TEST REQUIRED.
- CONTEXT: modal manual actual tiene bloqueo/guardas complejos; Ascension ofrece popup con extensión propia.
- DECISION: wrapper propio sobre StaticPopup vanilla, Confirm/Discard, ESC cancela navegación; owner lock separado.
- ALTERNATIVES: copiar OnButton aliases Ascension; modal manual permanente; Discard en todo OnCancel.
- CONSEQUENCES: probar motivo de cancelación y respuesta async; popup solo no bloquea editor.
- MIGRATION IMPACT: fase 5; retirar modal anterior únicamente tras paridad de dirty/ESC/timeout.

## ADR-011 — Preserve vanilla SpellBook

- ID: ADR-011.
- TITLE: integración contextual de abilities sin sustituir el libro.
- STATUS: ADOPTED; BASE INTEGRATION EXISTS.
- CONTEXT: Ascension_Spellbook es override de FrameXML con APIs custom y comportamiento secure propio.
- DECISION: marcador pequeño por entrada eligible y tooltip committed; conservar cast y drag/drop vanilla.
- ALTERNATIVES: reemplazar ToggleSpellBook/book; nueva pestaña grande; botones ocultos según clase solo en cliente.
- CONSEQUENCES: limitaciones de terceros/combate aceptables con fallback /ua.
- MIGRATION IMPACT: preservar SpellBookIntegration, separar adaptador, probar resolución de slot/rank.
