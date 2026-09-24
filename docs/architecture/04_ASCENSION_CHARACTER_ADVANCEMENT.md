# 04 — CharacterAdvancement en profundidad

**VERIFIED FROM ASCENSION SOURCE** A16–A24. Backend nativo no disponible: resultados de learn/apply
y contenido de paquetes son **ASCENSION CLIENT DEPENDENCY**, no una especificación de red Ulduar.

## Nacimiento y ownership

TOC LoD depende de Ascension_Collections y carga templates, browser y finalmente CharacterAdvancement.xml.
El XML incluye CharacterAdvancement.lua y declara la jerarquía con templates; OnLoad compone mixins.
La base visual también usa FrameXML/CharacterAdvancement: el addon no es autosuficiente.
UIParent tiene CharacterAdvancement_LoadUI y selecciona variante por modo/clase.
Collections añade tab por nombre de panel y PreClick llama loader; no se crea un segundo controller al cambiar tab.

CharacterAdvancementMixin:OnLoad asigna título/icono, registra eventos de resultados permanentes y
crea pools para categorías, spells, talentos, spells compactos, iconos de clase y contadores.
Añade CAConnectedNodesMixin y gates al contenedor de talentos; prepara navegación, specs, filtros y callbacks.
El CloseButton cierra Collections. CA forma parte de ese hub, no una ventana completamente independiente.

## Ciclo de vida

**OnLoad**

- Qué hace: Pools, mixins, handlers y referencias a subframes
- Lección: Inicialización una vez, no en cada refresh

**OnShow**

- Qué hace: Oculta popup antiguo, registra eventos visibles, configura búsquedas; init/full/refresh
- Lección: Separar construcción de actualización

**OnShow en BuildCreator**

- Qué hace: Sustituye fuente de resultados y registra callback con handle
- Lección: Un controller puede consumir proveedor distinto explícitamente

**OnHide**

- Qué hace: Desregistra eventos visibles y callback editor, limpia swap/auxiliares
- Lección: Liberar referencias al salir

**OnHide con pending**

- Qué hace: Muestra popup de cambios pendientes
- Lección: No copiar cierre posterior a Hide sin adaptar navegación

**FullUpdate**

- Qué hace: ReleaseAll de pools, reconstruye modelo de layout, repuebla
- Lección: Pool evita acumular instancias

**Refresh**

- Qué hace: Actualiza monedas, estados, botones y gates existentes
- Lección: Refresh ligero distinto de reconstrucción

Eventos incluyen CHARACTER_ADVANCEMENT_PENDING_BUILD_UPDATED, LEARN_RESULT, UNLEARN_RESULT,
UPDATE_ENTRIES_RESULT, PLAYER_LEVEL_UP, combate y filtros/tags.
Algunos resultados marcan `needsFullUpdateOnShow` cuando no está visible.
No todas las suscripciones se eliminan al ocultar: eventos de resultado instalados en OnLoad siguen siendo relevantes.

## Datos, categorías y specs

GetSpellsByClass/GetTalentsByClass devuelven entradas con ID, spells/ranks, Row/Column, ConnectedNodes y requisitos.
SetSpells adquiere botones, llama SetEntry y calcula posiciones/altura.
SetTalents construye NodeMap/FilledNodes/ConnectedNodes; cada hijo referencia sus padres.
El controller calcula geometría y orden; CASpellButton representa una entrada y consulta elegibilidad.

CAClassButton:SetClass asigna clase/icono/nombre y color; usa un pool para contadores de inversión por spec.
Su click elige clase y eventualmente la spec con más inversión.
CASpecTab deriva de TabSystemTabMixin; calcula contadores y centra texto según lo que muestre.
No trasladar ClassInfo/AE/TE a Ulduar: nuestros IDs/costes nacen del registry y estado enviado.

## Nodos y requisitos

CASpellButtonBaseMixin:SetEntry interpreta rank aprendido o pending, AE/class investment y permisos de aprender/quitar.
El resultado controla icono, texto, bordes y enabled/disabled. Los derivados reutilizan base para talento,
spell compacto, mastery y primary stat; no hay una clase de botón nueva para cada SpellID.

OnEnter compone tooltip con información y motivos; OnLeave lo oculta.
Refresh vuelve a producir hover si el mouse sigue sobre el botón.
OnDragStart llama C_CharacterAdvancement.PickupSpell cuando corresponde; no es el mismo contrato que vanilla
PickupSpell.
Clicks en pending utilizan AddByEntryID/RemoveByEntryID; otros caminos usan aprender/desaprender/confirmación.
No concluir que todo click sea solo local: depende de modo y API llamada.

CAGate separa Condition (required/left/isMet), Info y frames.
CATalentGatesInfoMixin usa GatePool; refresh devuelve contadores y vuelve a vincular TAB/CLASS/GLOBAL_TE/GLOBAL_AE.
El texto de requisito deriva de cantidades consultadas; el dibujo no concede elegibilidad.

## Conexiones

CAConnectedNodesMixin mantiene ConnectedNodes, NodeMap y FilledNodes por contenedor.
GetConnectionOrder busca ruta ortogonal en rejilla, evitando celdas ocupadas.
DrawConnectedNodes adquiere segmentos CATalentBranchTemplate y configura dirección, endpoints/flechas y posición.
Si no encuentra ruta, registra error: no es un motor general de grafos ni justifica copiar sus constantes.

CABranchMixin:Reset oculta segmentos/flechas, restaura anchors y borra node/nodeID.
OnShow/OnHide registran/desregistran pending update.
Refresh evalúa known/pending/can-add del nodo destino y cambia atlas normal/disabled.
La separación útil es **edge model → router → segmentos visuales reciclables**; reglas de compra no viven en el router.

## Scroll, hover y tabs

El área principal mantiene ScrollChild con altura calculada según contenido; UpdateContentScrollLayout y
ScrollToLocate coordinan viewport y localización. Sidebar utiliza ScrollList/HybridScrollFrame con función de cantidad.
Las conexiones se desplazan dentro del mismo contenido: no flotan ancladas a UIParent.

TabSystem gestiona panel activo; CA configura tabs de clase/spec/browser.
Collections ajusta tamaño al panel y contiene excepciones por assets/tamaño. No adoptar esos offsets históricos:
Ulduar debe ofrecer contrato uniforme de tamaño y layout.

## Pending build y servidor

RefreshSaveChangesButton consulta IsPending y CanApplyPendingBuild, ilumina botón o muestra razón.
Undo llama CancelPendingBuild; Save delega a CharacterAdvancementUtil.ConfirmApplyPendingBuild.
GlobalOverwrites altera algunas consultas según previewCharacterAdvancementChanges.
**DO NOT COPY:** sustituir globalmente getters para hacer preview. En Ulduar el consumidor elige explícitamente
Committed o Draft y nunca cambia descripciones activas de terceros por una CVar global.

## Equivalente conceptual Ulduar

| Ascension | Ulduar objetivo |
| --- | --- |
| C_CharacterAdvancement entries | CatalogStore desde DEF/capabilities y snapshots |
| Pending API | DraftStore local con BaseRevision |
| CanApply/Apply | PreviewBudget local + ApplyBuild autoritativo C++ |
| CASpellButton | AbilityNode/ModifierNode con view model |
| Gates | RequirementDescriptor enviado/validado por servidor |
| NodeMap + LinePool | ConnectionModel + pool de regiones |
| Collections hub | UlduarUI panel registry y feature UlduarAbilities |
| Custom learn events | Eventos del store tras respuesta completa |
| Atlas global | UlduarUI:SetAtlas sobre recursos permitidos |

No incorporar masteries, monedas Ascension, classless unlocks ni su catálogo de spells.
La arquitectura objetivo puede expresarlos en el futuro sin crear dependencia sobre esas APIs.
