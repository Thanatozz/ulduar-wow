# 25 — Fronteras servidor/cliente

**DESIGN DECISION** basada en U01–U17; no se cambia protocolo en esta auditoría.

| Objeto / operación | Dueño | Cliente puede |
| --- | --- | --- |
| AbilityDefinition/runtime enable/class/knowledge | Servidor | Mostrar catálogo permitido |
| Native rank chain | SpellMgr/servidor | Mapear IDs recibidos a tooltip/icono |
| CustomRank/EvolutionPoints y presupuesto | AbilityManager | Calcular preview con reglas recibidas |
| PlayerAbilityState/StateRevision | Servidor/cache/DB según campo | Mantener snapshot Committed |
| Draft | Feature cliente | Editar libremente dentro de preview; solicitar commit |
| ApplyBuild | Servidor | Enviar valores deseados y BaseRevision una vez |
| Targets/legality/PvP | Core + módulo | Describir reglas, no seleccionar hits |
| Damage/healing/auras/school/procs | Core + adaptador runtime | Mostrar descriptor estimado si hay datos |
| VisualSource/arrival scheduling | Spell/SecondaryExecutor | Recibir visual nativo; no ejecutar daño |
| Frame/layout/theme | Ulduar_UI + feature | Preferencias locales |
| Microbutton normal/vehicle | Shell FrameXML futuro | Abrir hub |
| Descripción natural | Composer de feature | Redactar datos autoritativos/preview etiquetado |
| UIEditor | Cliente dev | Modificar layouts opt-in |
| Editor .uedit de GameObjects | Servidor GM | Futuro UI envía intención validada separada |
| Assets | Paquete cliente | Renderizar, sin alterar autoridad |
| Login | Cliente/servidor auth nativos | Branding Glue, no auth alternativo |

LogicalCaster no es VisualSource. El Player conserva daño, amenaza, kill credit, procs y escuela por cast.
Un nuevo tooltip no puede corregir una propiedad del pipeline de daño ni demostrar su funcionamiento.

Reglas de elegibilidad deben aplicarse en lista y mutación, no solo esconder abilities client-side.
CatalogStore no puede desbloquear runtime-enabled=false. Registry no implica soporte universal para
healing/periodic/channel.
Capacidades visuales y gameplay distintas: WeaponShot no garantiza proyectil utilizable en cualquier SpellVisual.

Cada feature es dueña de su contrato de red. Transporte compartido futuro solo ofrece envelope/throttle/dispatch,
no absorbe reglas de CityBuilder o Abilities. Glue no participa de esos requests.

Cambiar ownership, estado o semántica de commit exige revisión de 16/26 y matriz 30; cambiar icono no lo exige.
