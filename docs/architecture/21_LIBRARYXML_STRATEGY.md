# 21 — LibraryXML y dependencias externas

**VERIFIED FROM ASCENSION SOURCE**, A32. Hay 42 TOCs individuales y bibliotecas Ace/CallbackHandler,
LibDeflate, LibSerialize, LibWindow, LibSharedMedia y otras. FrameXML.toc carga LibStub.lua desde FrameXML.
No se encontró un LibraryXML.toc global; los manifiestos individuales no explican por sí solos cómo el cliente
custom los descubre. **INFERRED / RUNTIME TEST REQUIRED** para ese bootstrap.

## Decisión

**DESIGN DECISION.** LibraryXML contiene solo librerías externas reutilizables con procedencia, versión y licencia.
Las implementaciones propias Ulduar de mixins, pools, widgets y eventos pertenecen a Shared, no aquí.
No adoptar Ace completo por disponibilidad; empezar sin dependencias si nuestros contratos pequeños lo permiten.

Durante perfil addon, una dependencia necesaria se distribuye como addon declarado o embedding controlado
con orden TOC real. No apuntar a LibraryXML esperando discovery automático en 3.3.5a.
En perfil custom, un manifest explícito incluye solo las bibliotecas seleccionadas y el bootstrap requerido.

## Registro de dependencia

Antes de incorporar: nombre/versión, origen, licencia, modificaciones locales, entorno Lua/API,
consumidores, tamaño, orden de carga y política de actualización.
Evitar instancias incompatibles; si usa LibStub, respetar versionado y no redefinirlo globalmente.
No redistribuir una librería desde Ascension sin verificar su fuente/licencia de forma independiente.
No incluir compresión/serialización cuando wire delimitado de tamaños acotados resuelve el problema actual.

Rollback de UI no debe exigir borrar datos de usuario creados por otra librería.
Pruebas: biblioteca faltante, versión duplicada, addon deshabilitado y carga en Glue si se declara compatible.
