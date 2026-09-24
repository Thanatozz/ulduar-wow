# 10 — Arquitectura objetivo del cliente

**DESIGN DECISION**, no implementada. ADR-001/002/005/008.

**SharedXML/Ulduar**

- Responsabilidad: Utilidades neutrales, mixins, pools, atlas/layout y bases UI reutilizables
- Prohibido: PlayerAbilityState, SQL, reglas de daño, red de feature

**FrameXML**

- Responsabilidad: Integración mínima con shell vanilla, loader aprobado, microbutton y vehículo
- Prohibido: Árbol de Abilities, estado de builds, Collections completo

**GlueXML**

- Responsabilidad: Login/realm/select/create y branding; adaptador de entorno Glue
- Prohibido: Addon messages gameplay, dependencias UIParent/Player

**LibraryXML**

- Responsabilidad: Dependencias externas reutilizables y licenciadas
- Prohibido: Framework propio disfrazado de biblioteca externa

**AddOns/Ulduar_UI**

- Responsabilidad: Fachada de UI en mundo, navegación, preferencias, servicios de widgets
- Prohibido: Autoridad de gameplay o protocolo específico de Abilities

**AddOns/Ulduar_Abilities**

- Responsabilidad: Datos de feature, Draft, controllers, views y protocolo
- Prohibido: Overrides globales y lógica server duplicada como autoridad

**AddOns/Ulduar_UIEditor**

- Responsabilidad: Herramienta local dev, opt-in sobre frames registrados
- Prohibido: Edición de mundo/SQL o ejecución arbitraria de paquetes remotos

**Otras features**

- Responsabilidad: CityBuilder, Collections, Transmog, MountJournal, etc.
- Prohibido: Copias de pools, atlas y modals

## Dos perfiles de distribución, una implementación

**Perfil MVP compatible con addon:** crear Ulduar_Shared como addon con primitivas propias y Ulduar_UI encima.
La feature actual conserva carpeta `UlduarAbilities` y namespace hasta completar compatibilidad.
Orden por TOC/Dependencies, sin tocar FrameXML. No depender de rutas fuera de AddOns para arrancar esta fase.

**Perfil cliente custom futuro:** las primitivas neutrales se empaquetan en `Interface/SharedXML/Ulduar`,
incluidas explícitamente por manifiestos aprobados. Ulduar_UI continúa como servicio en mundo.
Ulduar_Shared puede quedar como shim de compatibilidad que verifica versión y presencia, sin ejecutar una segunda copia.
El código tiene **una ubicación fuente canónica por fase**; nunca dos implementaciones divergentes.
La mudanza a SharedXML no es requisito previo de migrar un widget.

## Propiedad de nombres y dependencias

`UlduarShared`: primitivas; `UlduarUI`: servicios/widgets; `UlduarAbilities`: dominio cliente;
`UlduarAtlas` y `UlduarFramePool`: APIs especializadas propias.
`Ulduar_UI` es nombre de paquete, no una segunda tabla global.
La transición desde `UlduarAbilitiesUI` requiere un adaptador temporal y versión de SavedVariables;
no renombrar carpetas, addon ID o globales en una entrega incidental.

Features dependen de UI; UI depende de Shared. Shared no depende de features.
Un hub registra páginas mediante factories/callbacks diferidos: no depende de los TOC de todas las features.
UIEditor depende de UI; UI no depende del editor. Ningún loader implica comprar/aprender/confirmar una build.

## Feature packages: responsabilidades concretas

**Ulduar_Abilities**

- UI propia: Lista/editor/build; integra tooltips y Spellbook
- Dependencia/carga: Ulduar_UI; mantener eager inicialmente para hooks/handshake, separar vista LoD después
- Protocolo y datos: Dueño de ULDAB y codec de abilities; servidor mod-ulduar-abilities

**Ulduar_CityBuilder**

- UI propia: Catálogo/preview/selección de construcciones
- Dependencia/carga: Ulduar_UI; panel LoD registrado en hub
- Protocolo y datos: Contrato propio con validación de permisos/ubicación en servidor; no reutilizar APPLY_BUILD

**Ulduar_Collections**

- UI propia: Browser de colecciones desbloqueadas
- Dependencia/carga: Ulduar_UI; LoD
- Protocolo y datos: Datos de colección autoritativos; no inferir unlock de presencia del asset

**Ulduar_Transmog**

- UI propia: Selección/preview de apariencias
- Dependencia/carga: Ulduar_UI; LoD; servicios de datos compartidos explícitos si aparecen
- Protocolo y datos: Contrato propio para aplicar apariencia; no C_Appearance de Ascension

**Ulduar_MountJournal**

- UI propia: Lista/filtros/favoritos y acción permitida
- Dependencia/carga: Ulduar_UI; LoD
- Protocolo y datos: APIs nativas donde baste; servidor para unlocks custom; favoritos locales

**Ulduar_UIEditor**

- UI propia: Inspector/grid/edición de layout
- Dependencia/carga: Ulduar_UI; LoD, dev opt-in
- Protocolo y datos: Sin red de gameplay; SavedVariables locales

Son paquetes de diseño, no features ya implementadas. Un servicio de datos común de Collections/Transmog,
si se necesita, debe estar debajo de ambas; ninguna vista depende de la vista de la otra.
Protocolos de features comparten transporte solo cuando exista un contrato genérico demostrado, sin mezclar namespaces.

## Contrato entre capas

Los widgets reciben view models y callbacks, no sockets ni PlayerState mutable.
Los controllers seleccionan datos Committed/Draft, solicitan confirmación y coordinan navegación.
El protocolo valida estructura y publica snapshots en el store. El servidor vuelve a validar toda operación.
Un fallo de UI deja gameplay y comandos GM independientes.

**RUNTIME TEST REQUIRED:** carga real de SharedXML custom, nombres globales, addon deshabilitado, mixed versions,
LoD tardío y secure frames. No se garantiza precedencia MPQ ni bootstrap del cliente por dibujar este árbol.
