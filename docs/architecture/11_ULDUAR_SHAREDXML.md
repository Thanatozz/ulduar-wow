# 11 — Contratos de infraestructura compartida

Todo este documento es **DESIGN DECISION**, no API existente. ADR-001/006.
Implementar primero en AddOns/Ulduar_Shared; ubicación futura SharedXML/Ulduar, según 10/24.
No cargar ambos proveedores. Las APIs aquí son contratos de diseño, no funciones Blizzard.

## Estructura conceptual

Core/ (versión, namespace, capacidades de entorno), Mixins/, Pools/, Atlas/, Widgets/, Layout/,
Tooltips/, Tabs/, Modals/, Scroll/, Events/, Debug/.

Solo las primitivas neutras deben funcionar en Glue y mundo. Los adaptadores de GameTooltip, UIParent, SavedVariables
y modals de gameplay se activan en Ulduar_UI después de cargarse FrameXML.
Una carpeta puede contener código compartido y requerir inicialización tardía; compartir no significa ejecutar temprano.

## Mixin system

- PURPOSE: componer comportamiento de nuestros objetos sin tocar metatables Blizzard.
- PUBLIC API: UlduarShared:Mixin(target, ...); UlduarShared:CreateFromMixins(...);
  UlduarUI:BindScripts(frame, scriptMap) solo para frames propios.
- LIFECYCLE: copiar métodos, Init una vez; OnAcquire y OnRelease por uso. Mixin no llama OnLoad implícitamente.
- DEPENDENCIES: Lua básico; BindScripts requiere frame y métodos comprobados.
- EXAMPLE USE: combinar NodeVisualMixin y TooltipOwnerMixin en ModifierNode.
- WHAT NOT TO DO: reemplazar GetTextureMetatable, inyectar SetAtlas a todas las Texture,
  copiar estados mutables de un mixin como si fueran de cada instancia.
- Colisiones: declarar orden explícito; en dev advertir métodos reemplazados. Cada Init crea tablas de instancia nuevas.

## Object Pool / Frame Pool

- PURPOSE: reutilización acotada de botones, conexiones, filas y futuros objetos UI de CityBuilder.
- PUBLIC API: UlduarFramePool:New(factory, resetter, options); Acquire(owner, model), Release(object),
  ReleaseAll(owner), EnumerateActive(), GetCounts(). ObjectPool comparte contrato con factory de tablas.
- LIFECYCLE: factory → Init una vez → Reset → OnAcquire → Bind(model) → Show.
  Release: invalidar lease/generation → OnRelease → cancelar suscripciones/hover → Reset → Hide → pool inactivo.
  Acquire debe volver a estado base aunque el último owner haya cerrado por error.
- DEPENDENCIES: mixins opcionales, fábrica y resetter; FramePool requiere CreateFrame y template previamente cargado.
- EXAMPLE USE: lista adquiere solo filas visibles; árbol adquiere un node por descriptor activo y edges por conexión.
- WHAT NOT TO DO: Release doble silencioso, mantener PlayerState/Draft por referencia en inactivos,
  crecer indefinidamente o reciclar frame protegido de Blizzard.
- Invariantes: un objeto pertenece a un pool y una lease; Release ajeno retorna error dev.
  Reset restaura anchors, alpha, scale, texturas/UV, texto, checked/disabled y tooltips; limpia datos e ID.
  Scripts base estables no se duplican; callbacks de owner se eliminan.
  Futures/callbacks capturan generación y no actualizan un frame reasignado. No usar deferred release en V1.

## Widget system

- PURPOSE: formas visuales neutras con contrato uniforme.
- PUBLIC API: UlduarUI:CreateWidget(kind, parent, options); widget:Bind(model), SetEnabled(value, reason),
  Refresh(), Release().
- LIFECYCLE: ver 13; crear arte una vez y cambiar modelo sin reconstruir jerarquía.
- DEPENDENCIES: XML de templates, mixins/pools, fuente de skin; no protocolo.
- EXAMPLE USE: AbilityEditor entrega view model a ModifierNode.
- WHAT NOT TO DO: widget que llama ApplyBuild o calcula ownership/costes autoritativos.

## Tab system

- PURPOSE: seleccionar panel con apariencia Blizzard y navegación guardada.
- PUBLIC API: UlduarUI:CreateTabs(owner, descriptors); tabs:Select(id), SetEnabled(id, value, reason),
  GetSelectedId(), Release().
- LIFECYCLE: descriptores → factories lazy → guarda de navegación → cambio de selected → Hide/Show panel.
- DEPENDENCIES: PanelTemplates/template WotLK, eventos, registry de paneles.
- EXAMPLE USE: Abilities/Builds/Codex/Progression; placeholders no cargan backend.
- WHAT NOT TO DO: button normal disfrazado de tab; índices de array como identidad persistente;
  seleccionar visualmente antes de resolver dirty guard.

## Scroll list / Data provider

- PURPOSE: filas visibles sin un frame por registro.
- PUBLIC API: list:SetDataProvider(provider), SetSelection(id), ScrollToId(id), Refresh(), Release().
  Provider: GetCount(), GetId(index), GetItem(id), Subscribe(callback).
- LIFECYCLE: cambio de datos/viewport recalcula offset; rebind solo filas visibles; release sobrantes.
- DEPENDENCIES: FauxScrollFrame WotLK inicialmente; pool, callbacks.
- EXAMPLE USE: lista de abilities disponibles, inspector y catálogo futuro.
-  WHAT NOT TO DO: copiar ScrollBox Retail; pasar índice como AbilityId; OnUpdate que recorre todas las entries cada
  frame.
- Mantener selección por ID al ordenar; eliminar selección si la ability deja de estar disponible.
  Anchors del contenido y edges comparten ScrollChild. Altura variable queda para una fase específica.

## Modal system

- PURPOSE: coordinar decisiones y bloqueo de owner.
- PUBLIC API: UlduarUI.Modals:ConfirmChanges(owner, callbacks), CancelForOwner(owner).
- LIFECYCLE: registrar una definición StaticPopup una vez; cada apertura crea operación/guard token;
  resolver Confirm/Discard/ESC; liberar bloqueo exactamente una vez.
- DEPENDENCIES: StaticPopup de mundo; adaptador GlueDialog separado, nunca fallback implícito.
- EXAMPLE USE: salir del editor dirty espera respuesta de servidor antes de cerrar.
- WHAT NOT TO DO: asumir OnCancel=Discard; cerrar owner antes de confirmación; duplicar petición al presionar Enter.
- Semántica detallada en 08; StaticPopup no equivale por sí mismo a bloqueo total del fondo.

## Tooltip helpers

- PURPOSE: dibujar segmentos de descripción y administrar ownership.
- PUBLIC API: UlduarUI.Tooltips:Show(owner, descriptor, context), Hide(owner), Append(tooltip, descriptor, key).
- LIFECYCLE: render al hover/dirty event; deduplicar por key/generation; liberar al esconder/reutilizar owner.
- DEPENDENCIES: GameTooltip en mundo; composer de feature inyectado; no datos de gameplay propios del helper.
- EXAMPLE USE: descriptor Draft en editor y Committed en actionbar.
- WHAT NOT TO DO: cambiar strings vanilla por búsqueda/reemplazo ni consultar red al mover el mouse.

## Atlas abstraction

- PURPOSE: nombres de recurso estables sin extender tipos globales.
- PUBLIC API: UlduarAtlas:Register(name, metadata), Get(name), Has(name);
  UlduarUI:SetAtlas(texture, name, useSize).
- LIFECYCLE: catálogo versionado registrado una vez; llamadas puras de render.
- DEPENDENCIES: SetTexture, SetTexCoord, SetWidth/Height; flags soportados de forma explícita.
- EXAMPLE USE: ability-node-selected → recurso Blizzard/propio con UV.
- WHAT NOT TO DO: requerir GetTextureMetatable, máscaras custom o buscar archivos por nombre de Ascension.
- Metadata: path, width, height, left/right/top/bottom, optional tile/flip flags y source/license.
  Rechazar nombre duplicado incompatible, UV fuera de rango y tamaños inválidos.
  Ausencia usa fallback de desarrollo y diagnóstico único; no deja textura vieja al reciclar.

## NineSlice abstraction

- PURPOSE: bordes redimensionables cuando un backdrop Blizzard no cubra el diseño.
- PUBLIC API: UlduarUI.NineSlice:Apply(frame, layoutId), SetColor(frame, rgba), Release(frame).
- LIFECYCLE: crea nueve regiones como máximo por frame; actualiza anchors/UV, nunca nueve nuevas por refresh.
- DEPENDENCIES: atlas/layout, tamaños de esquinas; sin Texture:SetAtlas global.
- EXAMPLE USE: panel grande del futuro editor.
- WHAT NOT TO DO: implementar todo NineSlice Retail antes de tener un consumidor.
  MVP usa SetBackdrop/template vanilla; los flags no soportados se rechazan o degradan documentadamente.

## Layout utilities

- PURPOSE: espacio/padding/escala consistentes y posición segura.
- PUBLIC API: Layout:Stack(children, axis, gap), Grid(children, columns, cell), Clamp(frame),
  SavePosition(frame), RestorePosition(frame, record).
- LIFECYCLE: ejecutar por dirty/resize/scale; no mover nodos durante OnClick.
- DEPENDENCIES: APIs locales de frame; adaptador SV en Ulduar_UI.
- EXAMPLE USE: secciones Offense/Propagation por capabilities.
- WHAT NOT TO DO: override de SetPoint de frames ajenos o guardar referencias userdata en SV.
- Posiciones serializables contra UIParent, con point/relativePoint/x/y y schema; validar números finitos.

## Event bus

- PURPOSE: desacoplar servicios/modelos de vistas y destruir suscripciones sin fugas.
- PUBLIC API: Events:Subscribe(event, owner, callback) → handle:Unsubscribe();
  Publish(event, payload); UnsubscribeOwner(owner).
- LIFECYCLE: registro explícito, dispatch por snapshot de listeners, release handles al cerrar/reciclar.
- DEPENDENCIES: Lua; un frame bridge para eventos Blizzard en mundo.
- EXAMPLE USE: SnapshotCommitted → controller recompone vistas.
- WHAT NOT TO DO: `C_*` ficticio; emitir eventos como si fueran confirmación de servidor;
  recursion ilimitada o almacenar callbacks de frames retirados.

## Debug tools

- PURPOSE: diagnosticar pools, suscripciones, carga y frames propios.
- PUBLIC API: Debug:Inspect(frame), PoolStats(), Trace(event, enabled), AssertInvariant(name, condition).
- LIFECYCLE: opt-in dev; buffers acotados, sin handlers permanentes costosos al apagar.
- DEPENDENCIES: solo servicios anteriores; editor separado.
- EXAMPLE USE: detectar una fila que conserva tooltip de otro ID.
- WHAT NOT TO DO: volcar tokens/credenciales, ejecutar Lua remoto o integrar gameplay GM dentro de UI.
