# 24 — Orden de carga y dependencias

## Comprobado en Ascension

**VERIFIED FROM ASCENSION SOURCE** A01/A02:
FrameXML.toc y GlueXML.toc incluyen explícitamente SharedXML en distintas posiciones.
No hay SharedXML.toc propio en inventario ni prueba de discovery automático de carpeta.
TypeExtensions precede Mixin; AtlasInfo se define después de instalar métodos pero antes de sus consumidores.
Pools precede NineSlice; layouts precede NineSlice; callback registry precede DataProvider.
WorldFrame precede Region.xml en mundo. Glue usa otro orden y no tiene la misma lista de tipos disponible.
TabSystem.xml incluye templates y luego sistema; Scroll.xml incluye Hybrid → ScrollList → ScrollFrame.
Collections y CA se cargan por TOC/LoD; UIParent contiene loaders.
Glue incluye XML de herramientas de addon directamente; eso no demuestra carga de sus TOC/SV.

Referencias ausentes de los manifiestos impiden certificar la carga de esta extracción como paquete completo.
El orden de un manifiesto es evidencia de intención de carga; el resultado requiere cliente.

## Comprobado en Ulduar

**VERIFIED FROM ULDUAR SOURCE** U10:
TOC actual: Core → Protocol → DraftBuild → AbilityTooltip → Widgets (Node, Connections, ScrollList, Tabs) →
AbilityList → AbilityTree → AbilityDetails → UlduarFrame → UlduarMicroButton → SpellBookIntegration.
Core instala handlers; en ADDON_LOADED del paquete crea ventanas/integraciones.
PLAYER_ENTERING_WORLD invalida request/Draft/sesión y programa handshake.
SPELLS_CHANGED programa GET; timeout de red no reproduce mutaciones.
Ningún SharedXML/FrameXML/GlueXML Ulduar está desplegado por este TOC.

**NOT VERIFIED / RUNTIME TEST REQUIRED:** bootstrap completo del ejecutable 3.3.5a instalado,
orden de parche/loose files, validación de FrameXML y disponibilidad de APIs custom.
No se deriva de la versión 30300 que estén presentes Mixins/ScrollBox/NineSlice modernos.

## Perfil addon recomendado primero

**DESIGN DECISION.**

1. Cliente carga su interfaz base por mecanismo nativo (su detalle no se certifica aquí).
2. Ulduar_Shared TOC: namespace/version → utilidades Lua → atlas/pools/eventos.
3. Ulduar_UI Depends Ulduar_Shared: mixins → templates → servicios de mundo.
4. Feature Depends Ulduar_UI: codec/store/controllers → templates/vistas → bootstrap.
5. ADDON_LOADED por paquete inicializa SV propias; factory abre feature una vez cuando se solicita.

UIEditor LoD depende de UI; no es dependencia de ninguna feature.
UI puede registrar factory por string/callback para feature LoD sin depender del paquete de feature.
No ordenar addons por nombre de carpeta para resolver dependencias.

## Perfil custom futuro

Primitivas neutrales Ulduar se incluyen por el manifiesto del entorno tras sus prerrequisitos.
SharedXML propio con Lua puro puede preceder WorldFrame; creación de GameTooltip/pools con tipos de mundo
debe esperar a FrameXML y Ulduar_UI. No escribir una única flecha SharedXML → todos los widgets como orden universal.
Glue utiliza subconjunto puro y adaptadores Glue; no llama servicios de mundo.

Provider/version marker evita carga doble. Si hay shim Ulduar_Shared, verifica el marker y expone compatibilidad;
no vuelve a ejecutar los scripts ya cargados por manifiesto. Mixed versions fallan de forma explicable.

## Verificación futura

Registrar hitos bootstrap con contador de ejecución y dependencias requeridas, sin spam.
Comprobar ausencia/carga tardía de feature, error en include, template no definido, SV antes de evento,
reload y transición Glue→mundo. Documentar las observaciones como RUNTIME VERIFIED solo con evidencia reproducible.
