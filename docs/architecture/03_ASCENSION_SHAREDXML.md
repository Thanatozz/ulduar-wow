# 03 — SharedXML de Ascension: catálogo técnico

**VERIFIED FROM ASCENSION SOURCE**, A03–A15/A34. Las compatibilidades indicadas son estáticas,
no certificaciones de ejecución. P0 = fundamento; P1 = consumidor inmediato; P2 = después de medir necesidad.
LOAD ORDER se refiere a manifiestos A01/A02: no a un escáner automático de carpetas.

## Mixin

- NAME / PATH: Mixin; SharedXML/Util/Mixin.lua.
- PURPOSE: componer métodos sobre una tabla/frame; variantes safe, load y scripts.
- LOAD ORDER: después de TypeExtensions.xml; antes de consumidores de mixins.
- DEPENDENCIES: Lua, _G y SetScript/HasScript en variantes de frames.
- PUBLIC API: Mixin, MixinSafe, CreateFromMixins, MixinAndLoadScripts.
- WHO USES IT: CA, Collections, pools, tabs, inspect.
- HOW IT BEHAVES: copia métodos; variantes script los enlazan y pueden ejecutar OnLoad por mixin.
  El orden resuelve colisiones; safe no equivale a inmutabilidad.
- VANILLA COMPATIBLE: concepto sí; API no incorporada por declarar Interface 30300.
- ASCENSION CLIENT REQUIRED: no para el concepto puro; consumidores pueden exigir extensiones.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: UlduarShared:Mixin y lifecycle explícito; sí, P0.

## ObjectPool / FramePool

- NAME / PATH: ObjectPoolMixin, FramePoolMixin, TexturePoolMixin, FramePoolCollectionMixin; SharedXML/Pools.lua.
- PURPOSE: reutilizar objetos, frames y regiones sin crecimiento por cada refresh.
- LOAD ORDER: tras Mixin/funciones base; antes de NineSlice y features.
- DEPENDENCIES: CreateFromMixins; CreateFrame para frame pools; parent y template válido.
- PUBLIC API: CreateObjectPool, CreateFramePool, Acquire, Release, ReleaseAll, EnumerateActive,
  DeferredRelease/CompleteDeferredRelease, colecciones por template.
- WHO USES IT: CA botones/gates/ramas, clases, TabSystem, Spellbook shine.
- HOW IT BEHAVES: activos en set, inactivos en stack; Acquire devuelve objeto y isNew.
  Release llama resetter. Default de frame oculta y limpia anchors; no limpia por sí solo todos los datos/callbacks.
  DeferredRelease pospone reset y exige completar el ciclo.
- VANILLA COMPATIBLE: algoritmo sí; revisar firmas de creación de regiones y funciones auxiliares.
- ASCENSION CLIENT REQUIRED: no para pool básico; templates/consumidores pueden requerirlo.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: UlduarFramePool y ObjectPool; sí P0; deferred release no V1.

## AtlasInfo / AtlasUtil / Texture:SetAtlas

- PATH: SharedXML/AtlasInfo.lua y TypeExtensions/Texture.lua.
- PURPOSE: nombre estable → textura, dimensiones, UV y flags de tiling.
- LOAD ORDER: TypeExtensions instala método antes de la tabla; AtlasInfo debe existir antes de llamarlo.
- DEPENDENCIES: GetTextureMetatable para extensión; AtlasUtil:Unpack; métodos de textura/tiling.
- PUBLIC API: AtlasUtil:Unpack/GetAtlasInfo/GetCoords/AtlasExists/GetSize/AddAtlas; Texture:SetAtlas.
- WHO USES IT: NineSlice, tabs, CA, Collections, tooltips y AtlasBrowser.
- HOW IT BEHAVES: selecciona recurso y UV; opcionalmente adapta tamaño, conserva dimensiones cuando no se solicita.
- VANILLA COMPATIBLE: tabla y wrapper propio sí; extensión directa no demostrada.
- ASCENSION CLIENT REQUIRED: **ASCENSION CLIENT DEPENDENCY** GetTextureMetatable y algunas operaciones de textura.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: UlduarAtlasRegistry + UlduarUI:SetAtlas; sí P0,
  solo assets vanilla inicialmente. No distribuir AtlasInfo de Ascension.

## NineSlice

- PATH: SharedXML/NineSliceLayouts.lua, NineSlice.lua.
- PURPOSE: componer corners/edges/center ajustables.
- LOAD ORDER: catálogo layouts → NineSlice; requiere atlas y primitivas disponibles al aplicar.
- DEPENDENCIES: Texture:SetAtlas, layouts, helpers y regiones del contenedor.
- PUBLIC API: NineSliceUtil.ApplyLayout/ApplyLayoutByName/AddLayout; NineSlicePanelMixin:SetLayout.
- WHO USES IT: headers, marcos compartidos, CA.Content y Collections.
- HOW IT BEHAVES: obtiene/crea piezas, distribuye esquinas y bordes, aplica UV/colores/texture kit.
- VANILLA COMPATIBLE: composición de texturas sí; catálogo y métodos custom no directamente.
- ASCENSION CLIENT REQUIRED: implementación leída usa extensión SetAtlas y recursos propios.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: backdrop Blizzard primero; nueve regiones propias P2.

## CallbackRegistry / EventRegistry / EventUtil

- PATH: CallbackRegistryMixin.lua, GlobalCallbackRegistry.lua, Util/EventUtil.lua.
- PURPOSE: observadores y puente de eventos con handles de liberación.
- LOAD ORDER: Mixin/helpers → CallbackRegistry → EventRegistry → EventUtil → consumidores.
- DEPENDENCIES: CreateCounter, GenerateClosure, securecall/secureexecuterange y AttributeDelegate en registry.
- PUBLIC API: RegisterCallback, RegisterCallbackWithHandle, TriggerEvent, UnregisterCallback;
  ContinueAfterAllEvents, ContinueOnAddOnLoaded, CreateCallbackHandleContainer.
- WHO USES IT: DataProvider, TabSystem, CA filtros, herramientas.
- HOW IT BEHAVES: owner identifica suscripción; handles desregistran; EventUtil espera condiciones/eventos.
  El registro usa barreras secure específicas para evitar taint.
- VANILLA COMPATIBLE: patrón sí; no asumir secureexecuterange disponible en nuestro cliente.
- ASCENSION CLIENT REQUIRED: dependencias exactas del registry requieren verificación; no copiar implementación.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: bus Lua propio y bridge Frame:RegisterEvent; sí P0.

## DataProvider

- PATH: SharedXML/DataProvider.lua.
- PURPOSE: colección observable y ordenable, independiente del frame consumidor.
- LOAD ORDER: después de CallbackRegistry y utilidades de tablas.
- DEPENDENCIES: CreateFromMixins, enumeradores de tabla, callbacks.
- PUBLIC API: CreateDataProvider, Insert, Remove, Sort, Find, Enumerate, Flush.
- WHO USES IT: se carga como infraestructura; no se encontraron consumidores de CreateDataProvider/DataProviderMixin
  fuera de su propia definición en la búsqueda de SharedXML/FrameXML/AddOns. CA consulta C_* directamente.
- HOW IT BEHAVES: emite OnInsert/OnRemove/OnSizeChanged/OnSort/OnMove; mantiene colección interna.
- VANILLA COMPATIBLE: sí reimplementado con Lua; dependencia registry actual no portable sin revisar.
- ASCENSION CLIENT REQUIRED: no inherente al modelo.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: vista de colección por ID; P1, solo si las listas lo necesitan.

## TabSystem

- PATH: SharedXML/TabSystem/TabSystem.xml, TabSystemTemplates.xml, TabSystemMixin.lua, TabSystemTabMixin.lua.
- PURPOSE: tabs y selección de paneles.
- LOAD ORDER: XML de templates carga mixin de tab; luego mixin de sistema; consumidores después.
- DEPENDENCIES: CallbackRegistry, FramePool, templates/atlas y funciones auxiliares.
- PUBLIC API: AddTab, RemoveTab, SelectTabID, SetTabLayout, SetTabPoint, SetTabEnabled, GetPanelForTabID.
- WHO USES IT: Collections, CA specs/sidebar, Inspect.
- HOW IT BEHAVES: pool de CheckButtons, tabla de paneles, selected/deselected, layout horizontal/vertical/custom.
  Callbacks distinguen selección; PreClick permite cargar un panel aún ausente.
- VANILLA COMPATIBLE: patrón sí; usar PanelTemplates propios de WotLK como base.
- ASCENSION CLIENT REQUIRED: las skins/mixins leídas dependen de extensiones.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: UlduarUI Tabs; sí P1.

## ScrollList / HybridScrollFrame; ScrollBox

- PATH: SharedXML/Scroll/Scroll.xml, ScrollList.lua/xml, ScrollListItemBase.lua, HybridScrollFrame.lua/xml.
- PURPOSE: renderizar filas visibles con offset en vez de crear un frame por dato.
- LOAD ORDER: HybridScrollFrame.xml → ScrollList.xml → ScrollFrame.xml.
- DEPENDENCIES: templates, EnumUtil, helpers Hybrid y selección/atlas.
- PUBLIC API: SetTemplate, SetGetNumResultsFunction, SetSelectedIndex, RefreshScrollFrame, ScrollToSelection.
- WHO USES IT: CA sidebar/browser, AtlasBrowser, menús.
- HOW IT BEHAVES: Init crea botones reutilizables; Refresh aplica índice offset+i, oculta sobrantes,
  calcula altura total y mueve highlight. Una callback produce cantidad de resultados.
- VANILLA COMPATIBLE: Faux/Hybrid compatible tras validar variante; API concreta es propia.
- ASCENSION CLIENT REQUIRED: helpers extra pueden depender del entorno.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: lista virtual fija sobre FauxScrollFrame; sí P1.
- ScrollBox: no se encontró ScrollBoxMixin implementado en búsqueda de fuentes. No exigir API Retail ScrollBox.

## ScrollableDropDown

- PATH: SharedXML/ScrollableDropDown.lua/xml.
- PURPOSE: selección con popup de altura limitada.
- LOAD ORDER: después de ScrollList y dropdown/templates compartidos.
- DEPENDENCIES: ScrollList, UISpecialFrames, templates y callbacks.
- PUBLIC API: SetOptions, SetMultiSelect, SetSelectedValue/Index, SetMenuHeight, SetSelectionCallback.
- WHO USES IT: Ascension_Poll/PollTemplates.xml y PollQuestionMixin.lua usan el dropdown y SetMenuHeight(200).
- HOW IT BEHAVES: mantiene opciones/selección, lista de resultados; clamp; oculta menú al ocultar owner.
- VANILLA COMPATIBLE: concepto sí; widget exacto necesita adaptación.
- ASCENSION CLIENT REQUIRED: hereda dependencias del framework.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: wrapper dropdown Blizzard; P2.

## TypeExtensions

- PATH: SharedXML/TypeExtensions/TypeExtensions.xml; Region.lua/xml, Frame.lua, Texture.lua, Tooltip.lua.
- PURPOSE: extender globalmente tipos y firmas, aproximando APIs de otras versiones.
- LOAD ORDER: fase muy temprana; Region.xml después de WorldFrame en mundo; orden distinto en Glue.
- DEPENDENCIES: metatables de tipos/frames de prueba y APIs adicionales.
- PUBLIC API: SetShown, ClearAndSetPoint, HookEvent, SetAtlas, InsertLine, entre otras.
- WHO USES IT: prácticamente todos los componentes custom revisados.
- HOW IT BEHAVES: instala métodos sobre tipos compartidos, no solo sobre un widget del addon.
- VANILLA COMPATIBLE: no como drop-in.
- ASCENSION CLIENT REQUIRED: sí para partes como GetTextureMetatable; además riesgo global de taint/colisiones.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: **no** equivalente global; helpers namespaced P0.

## Layout / Frame utilities

- PATH: SharedXML/LayoutFrame.lua; Util/FrameUtil.lua, AnchorUtil.lua, PixelUtil.lua.
- PURPOSE: disposición, snapping a píxeles y ciclo de eventos/updates.
- LOAD ORDER: utilidades antes de templates/consumidores; dependencias cruzadas de helpers.
- DEPENDENCIES: APIs de regiones, math/helpers, mixins; algunos wrappers custom.
- PUBLIC API: BaseLayoutMixin, PixelUtil.SetPoint/SetSize, FrameUtil.RegisterFrameForEvents,
  RegisterUpdateFunction, ReflectStandardScriptHandlers.
- WHO USES IT: marcos compartidos y features, utilidades de desarrollo.
- HOW IT BEHAVES: layout por índices/hijos; reflect enlaza scripts y puede invocar OnLoad/OnShow;
  RegisterUpdateFunction sustituye OnUpdate y limita frecuencia.
- VANILLA COMPATIBLE: patrón sí; sustitución de scripts ajenos no aceptable para Ulduar.
- ASCENSION CLIENT REQUIRED: revisar cada helper antes de adoptar.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: layout local/handles de eventos; P1.

## Texture / Button / Backdrop utilities

- PATH: SharedXML/Util/TextureUtil.lua; ButtonStateBehavior.lua; Backdrop.lua/xml; SharedPanelTemplates.lua/xml.
- PURPOSE: recursos, estados normal/pushed/disabled y decoración reutilizable.
- LOAD ORDER: Atlas/TypeExtensions y constantes preceden consumidores; templates cargados por manifiesto.
- DEPENDENCIES: SetAtlas, helpers y recursos; algunas máscaras usan APIs custom.
- PUBLIC API: TextureUtil.SetClampedTextureRotation/CreateAtlasMarkup;
  ButtonStateBehaviorMixin:OnEnter/OnLeave/OnMouseDown/OnMouseUp/OnDisable;
  BackdropTemplateMixin:ApplyBackdrop/ClearBackdrop y templates de panel.
- WHO USES IT: CA, Collections y tabs.
- HOW IT BEHAVES: traduce estado de widget a texturas, color y bordes.
- VANILLA COMPATIBLE: adoptar comportamiento con templates Blizzard reales, no extensiones de masks.
- ASCENSION CLIENT REQUIRED: partes de textura sí; no para un botón Blizzard básico.
- ULDUAR EQUIVALENT / SHOULD WE IMPLEMENT / PRIORITY: skin propia Blizzlike; P1.

## Conclusión operativa

Una utilidad pequeña es portable solo si también lo son sus dependencias transitivas.
No copiar SharedXML como carpeta, no redefinir los nombres globales de Ascension ni su catálogo de atlas.
Los contratos propios de implementación se fijan en 11–14; este documento describe la referencia.
