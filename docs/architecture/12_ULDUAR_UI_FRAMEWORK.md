# 12 — Ulduar_UI: fachada y ciclo de vida

**DESIGN DECISION.** Paquete Ulduar_UI, namespace UlduarUI. Su base se especifica en 11.
Es infraestructura de presentación en mundo; no almacena builds autoritativas ni maneja SQL.

## Servicios y dependencias

Core/Version, Registry/Panels, Widgets, Layout, Tooltips, Modals, Preferences y Debug.
Shared suministra utilidades neutrales; Ulduar_UI adapta APIs de FrameXML ya cargadas.
Features registran factories de páginas sin provocar dependencias circulares.

API conceptual de panel registry:
`RegisterPanel(id, factory, metadata)`, `OpenPanel(id, selection)`, `ClosePanel(id)`,
`RegisterNavigationGuard(owner, callback)`.
La metadata declara título, tamaño mínimo, opción LoD y permisos de edición de layout.
No se pasan spell IDs ni comandos SQL al registry genérico.

## Lifecycle

1. Bootstrap establece versión y comprueba proveedor Shared único.
2. Carga templates después de métodos que usa su OnLoad.
3. ADDON_LOADED inicializa preferencias del paquete; no presupone SV antes del evento.
4. Feature registra panel/factory. Crear ventana solo una vez.
5. Open solicita guard; factory construye si hace falta; controller conecta store; Show presenta datos.
6. Close resuelve Draft/operación pendiente; Hide retira suscripciones visuales, mantiene store/protocolo necesarios.
7.  Release de contenido reutilizable cancela callbacks y limpia leases. El marco principal no se destruye ni recrea por
   tab.

Estados de feature: Offline, Connecting, Ready, Editing, Confirming, Conflict, Error.
El framework sabe bloquear/navegar, pero la feature decide qué estados representan sus operaciones.
No mezclar `IsShown`, `ready` y `has pending request` en un único booleano.

## Presentación

Blizzlike WotLK: GameFontNormal/Highlight, bordes dialog/panel, tabs CharacterFrame/OptionsFrame,
UIPanelButtonTemplate/UIPanelCloseButton, GameTooltip y highlights Blizzard.
La selección de recursos se encapsula en skin y atlas propio; no hardcodear visuales de Ascension.

MainFrame expone header arrastrable, Close y content root. No vuelve draggable toda el área de nodos.
Clamp y posición SV se comparten como comportamiento, con ID estable por ventana y /ua resetposition compatible.
Layouts adaptan 4:3, scale y fuente; no cambian gameplay.

## Performance y fallos

Refresh se programa por dirty flags de store/layout, coalescido una vez por actualización cuando haya trabajo.
Tooltips no disparan solicitudes y listas no recorren el registry completo cada frame.
Un error de widget se diagnostica sin publicar estado incompleto ni simular confirmación.
Cuando falta Shared/version compatible, deshabilitar apertura de la feature con mensaje claro; /ua no debe romper el
chat.

**RUNTIME TEST REQUIRED:** bootstrap duplicado, LoD tardío, panel deshabilitado, reload, SV corruptas,
apertura en combate, hijos protegidos, error en factory y destrucción de owner con callbacks pendientes.
