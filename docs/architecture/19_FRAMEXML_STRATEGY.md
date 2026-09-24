# 19 — Estrategia FrameXML

**DESIGN DECISION**, ADR-002/004. Cambios profundos solo donde el shell es dueño real del comportamiento.
La referencia Ascension está en 05/06; no constituye la base de archivos a distribuir.

## Permitido en arquitectura objetivo

- Loader explícito de primitivas Ulduar cuando exista paquete cliente.
- Declaración del UlduarMicroButton con template, icono Pearl, tooltip, click y estado.
- Adaptación conjunta del layout normal/vehículo y listas de botones.
- Hook/fachada de apertura de hub, tolerante a addon ausente y carga LoD.
- Diagnóstico de versión/capacidades del shell, sin llamadas a gameplay.

## No pertenece aquí

Registro de abilities, Draft, ApplyBuild, cálculos de puntos, árboles visuales de feature,
CityBuilder/Collections completos, SQL, preferencias de builds ni copia global de pools por feature.
No reemplazar CharacterFrame, SpellBook, GameTooltip o actionbars completos para añadir un botón.

## Fuente y carga

Primero adquirir y versionar la fuente exacta del FrameXML vanilla de nuestro cliente objetivo con procedencia/hash.
La extracción Ascension no puede servir de base vanilla ni probar la compatibilidad de sus atributos XML.
Si el cliente impone validación de archivos/manifiestos, investigarla y documentarla antes de asumir que un MPQ
basta. No recomendar un bypass binario ni DLL como requisito implícito.

La modificación conceptual afecta MainMenuBarMicroButtons.xml/.lua y el código de layout de vehículo necesario;
el loader puede requerir edición de manifiesto. Contar archivos no sustituye coherencia.
No sobrescribir un archivo entero copiándolo de Ascension.

## Contrato de integración

La declaración FrameXML adquiere ownership del botón; un capability/version marker desactiva la inyección addon.
Ambos usan la misma identidad global UlduarMicroButton, jamás dos botones.
Click llama UlduarUI cuando esté listo o solicita carga de paquete conocido; error controlado si falta.
Guardar mismo orden Talents → Ulduar → Achievements en fila normal. Vehículos usan layout explícito revisado.
No forzar custom layouts de terceros: detectar owner externo y desactivar/adaptar de forma declarada.

Rollback: retirar patch restaura shell original; siguiente perfil de addon reanuda fallback seguro.
No permitir instalación mitad-old/mitad-new sin diagnóstico de incompatibilidad.

**RUNTIME TEST REQUIRED:** cliente exacto, validación de FrameXML, preload, secure taint, vehículos,
PerformanceBar/Help, addons de barras, reload y loader de feature ausente.
