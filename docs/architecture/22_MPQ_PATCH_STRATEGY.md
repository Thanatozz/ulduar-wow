# 22 — Patch de cliente y distribución

**DESIGN DECISION.** Nombre candidato: Data/patch-U.MPQ.
**RUNTIME TEST REQUIRED:** que ese nombre sea descubierto, su precedencia frente a otros patches/locales,
prioridad por locale y aceptación de FrameXML/GlueXML por el cliente exacto.
No afirmar que una letra alta garantiza ganar. Esta auditoría no creó, abrió para modificar ni reconstruyó MPQ.

## Contenido futuro

| Dentro del patch | Addon normal |
| --- | --- |
| SharedXML/Ulduar en perfil custom | Ulduar_UI: servicios en mundo/preferencias |
| Overrides mínimos FrameXML | Ulduar_Abilities: feature, Draft, protocolo y vistas |
| Overrides GlueXML autorizados | Ulduar_UIEditor: herramienta dev opt-in |
| Interface/Ulduar assets | CityBuilder/Collections futuros como features |
| Manifiestos de bootstrap que realmente se necesiten | Dependencias externas MVP declaradas por TOC |

La columna addon no implica que todos esos paquetes existan hoy.
No introducir DBC/spells/proxies por aprovechar este patch: cualquier cambio de gameplay requiere tarea y versionado
aparte.

## Fuente, release y actualización

Mantener fuentes canónicas de cliente en repositorio; separar vanilla baseline, overrides propios y assets.
Manifiesto de release: client build objetivo, locale, UI schema, Shared/UI/feature versions, protocolo soportado,
lista de rutas internas, hash de fuente y hash del artefacto.
La ruta canónica de Shared migra una vez; el paquete fallback nunca lleva una implementación distinta.

Empaquetar solo allowlist: excluir SV, credenciales, backups, herramientas ajenas, referencias Ascension y work dirs.
Distribuir el artefacto con cliente cerrado, instalación atómica por launcher futuro y verificación del conjunto.
No sobrescribir archivos de usuario de addons terceros. Un feature addon tiene release coordinada con
shell/capabilities.

## Precedencia: experimento requerido

En entorno manual de prueba, un recurso inocuo con versiones distinguibles en cada capa permite observar qué carga.
Registrar exe build, locale, lista de patches, loose files permitidos y resultado.
Separar prueba de assets de prueba de FrameXML: cargar una textura no demuestra cargar scripts protegidos.
No incluir ese experimento en producción ni asumir que la extracción refleja orden MPQ original.

## Rollback

Conservar artefacto anterior y manifiesto. Quitar/restaurar solo rutas propias.
Restaurar conjunto compatible de shell + Shared + addons; no dejar shim esperando provider ausente.
Schema SV migrable de forma aditiva; feature mantiene compatibilidad durante una ventana explícita.
Entrada a mundo, login y /ua deben poder recuperarse incluso si el addon de feature falla.

Fase 7 puede validar un pequeño artefacto experimental para microbutton; fase 8 formaliza pipeline y release.
No es necesario tener empaquetado final para diseñar el cambio, pero no desplegar FrameXML suelto sin prueba real.
