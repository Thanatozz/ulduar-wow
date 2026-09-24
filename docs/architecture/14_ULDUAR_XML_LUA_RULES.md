# 14 — Reglas XML y Lua

**DESIGN DECISION, ADR-005.** Mover estructura estable, conservar contenido dinámico.

| XML | Lua |
| --- | --- |
| Jerarquía estática y templates virtuales | Creación de instancias necesarias y pools |
| Anchors iniciales, tamaños base, decoración | Layout según capabilities/viewport |
| Texturas, fontstrings y subframes con identidad | Datos del servidor, state y Draft |
| Scripts pequeños que delegan a métodos | Controllers, protocolo, eventos y validación de estructura |
| Tabs y nodos base | Lista de tabs/nodos y selección |
| Close/header/content | Confirm, navegación, error y reconciliación |

## Orden y nombres

El script que define los métodos debe cargarse antes de crear el frame que los usa en OnLoad.
Un template puede ser declarado antes de su factory, pero no instanciado antes de sus handlers.
No asumir atributo XML `mixin=` moderno: usar OnLoad que aplica helper Ulduar propio, verificado para 30300.
No reutilizar XSD Ascension como garantía de parser.

Prefijar nombres de templates `Ulduar...`; names globales solo donde son necesarios
(por ejemplo UISpecialFrames o referencias XML), respetando alias temporal de addon actual.
Dinámicos usan referencias privadas; no llenar _G con SpellIDs como nombres de frames.
Las strings visibles se localizan desde Lua/tabla de locale propia; no concatenar coste autoritativo en XML.

## Migración segura

Extraer primero un panel estático con mismos nombres/callbacks/medidas.
Comparar estados antes/después sin cambiar protocolo ni balance en esa entrega.
Retirar el constructor Lua correspondiente al activar XML para no duplicar frames.
Mantener adaptador hacia controles existentes hasta mover controller.
No introducir un framework XML paralelo por cada feature.

## Antipatrones y revisión

Evitar miles de CreateFrame/SetPoint mezclados con ApplyBuild.
Evitar XML con una fila/nodo por cada spell/rank disponible.
No llamar scripts globales de gameplay desde handlers de widgets.
No usar handlers Lua inline extensos ni loadstring remoto.
Antes de aprobar: comprobar templates existentes, orden de includes, unicidad de globales,
alcance de callbacks, cleanup y combate. El diff XML estático no valida taint en runtime.
