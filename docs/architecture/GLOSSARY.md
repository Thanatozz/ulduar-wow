# Glosario

| Término | Significado en Ulduar |
| --- | --- |
| AbilityDefinition | Metadata central servidor: identidad, root spell, tipos y capacidades |
| AbilityId | ID lógico de feature; no equivale necesariamente a SpellID |
| BaseSpellId | Primer spell registrado de la cadena native |
| Native rank chain | Ranks Blizzard resueltos por SpellMgr |
| CustomRank | Progresión Ulduar independiente del rank nativo |
| Evolution Points | Presupuesto de nodos derivado/validado por servidor |
| BaseElement | Escuela informativa base de la definición |
| Original | Valor backend que conserva/resuelve al elemento base; no una escuela extra UI |
| EffectiveElement | Elemento que se describe/aplica según estado y capacidad real |
| EffectFlags | Efectos combinables Damage/Healing/Aura/etc.; no relación de targets |
| TargetRelation | Enemy/Friendly/Self/Any separado de efectos |
| DeliveryType | Dimensión gameplay de entrega, distinta del modo de propagación |
| PresentationType | Forma visual (Projectile/WeaponShot/etc.), sin cambiar ownership |
| PropagationMode | None/Impact/Split/Shatter/Nova/Chain |
| Coverage | Rank que amplía cantidad/rango/radio según modo y caps |
| Potency | Multiplicador genérico del efecto secundario, no solo damage |
| Rebound | Revisitas Chain sujetas a historial/gap por payload |
| Modifier capability | Nodo soportado por definición/rank/adaptador, validado en servidor |
| LogicalCaster | Player dueño de gameplay/credit/procs |
| VisualSource | Fuente de presentación; no caster lógico |
| AbilityCast | Snapshot de configuración del cast root |
| PayloadEvent | Impacto/tick que tiene historia propia de propagación |
| Committed | Estado confirmado y activo del servidor |
| Draft | Copia editable local no aplicada |
| StateRevision | Generación de estado; hoy en memoria/sesión servidor |
| APPLY_BUILD | Solicitud de reemplazo lógico completo validado con revisión |
| Snapshot | Conjunto de registros ensamblado y publicado completo |
| SharedXML | Capa de infraestructura incluida explícitamente por manifiesto, no autocarga por carpeta |
| FrameXML | Interfaz en mundo y shell base del cliente |
| GlueXML | Entorno de login/realm/selección, distinto del mundo |
| LibraryXML | Ubicación objetivo para librerías externas, bootstrap explícito |
| Ulduar_Shared | Provider addon transitorio de primitives propias |
| Ulduar_UI | Paquete de servicios/widgets; namespace UlduarUI |
| Ulduar_Abilities | Nombre objetivo de feature; hoy carpeta UlduarAbilities |
| Ulduar_UIEditor | Editor de layout local opt-in; no mod-ulduar-editor de GameObjects |
| Mixin | Composición de métodos sobre instancia, sin estado mutable compartido accidental |
| Pool / lease | Reutilización de objeto y período de ownership que invalida callbacks viejos |
| Atlas | Nombre → textura, tamaño y UV, sin API custom obligatoria |
| NineSlice | Composición de nueve piezas para borde ajustable |
| LoD | LoadOnDemand; otra dependencia/loader puede solicitar su carga |
| Taint | Contaminación de rutas protegidas del cliente; requiere pruebas de interacción |
| StaticPopup | Sistema de dialog Blizzard; no garantiza bloqueo total de todo el owner |
| Source of truth | Contrato documentado objetivo más evidencia explícita del estado actual |
| VERIFIED FROM SOURCE | Comprobación estática, no prueba de runtime |
| RUNTIME TEST REQUIRED | Comportamiento pendiente de ejecutar en entorno autorizado |
| ASCENSION CLIENT DEPENDENCY | Extensión consumida por la referencia, no disponible por suposición en vanilla |
