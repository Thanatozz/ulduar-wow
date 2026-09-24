# 29 — Convenciones para futuros agentes

**DESIGN DECISION.** Leer README/ADRs/contrato de subsistema antes de editar y revisar AGENTS vigente.
Las restricciones/autorización del usuario prevalecen sobre ejemplos de comandos en documentos.

## Lua y XML

- Lua compatible con cliente 3.3.5a; comprobar APIs en fuente/cliente real, no copiar nombres Retail.
- Globales de producto explícitos: UlduarShared, UlduarUI, UlduarAbilities, UlduarAtlas, UlduarFramePool.
  El global actual UlduarAbilitiesUI permanece hasta migración explícita.
- Funciones auxiliares locales; templates/nombres exportados prefijados Ulduar.
- No redefinir global Mixin/SetAtlas ni metatables; exception solo con ADR, prueba y rollback.
- Métodos del widget no contienen requests de red ni acceso a state autoritativo mutable.
- Handlers estables se registran una vez; OnAcquire/OnRelease manejan owner/model/suscripciones.
- Evitar referencias a frame reciclado: usar IDs/lease y limpiar closures.
- No hardcodear spell IDs/nombres localizados en UI si el catálogo los proporciona.
- Un framework compartido; no copiar widgets a CityBuilder/Collections.
- XML para jerarquía estable, Lua para datos/instancias/controllers. Ver 14.
- Datos remotos nunca se ejecutan como Lua. Export del editor es texto, no loadstring.

## Servidor y protocolo

Registry central, resolución native de ranks y contexto por cast. No context global mutable ni SchoolMask en SpellInfo.
Config/defaults/costes se anuncian para preview pero se validan otra vez en servidor.
Cambios de schema/enum/wire exigen compatibilidad y documentación; no reutilizar un enum con significado distinto.
No ocultar failures con casts inseguros ni llamar SQL por hover/cast.
Nombres SQL globalmente únicos en toda distribución; no aplicar SQL al auditar UI.

## Assets y licencias

Assets Blizzard existentes primero. No copiar spritesheets/catalogs ni grandes bloques Ascension.
Bibliotecas externas con origen/licencia/versión registrados.
UV y paths en registro único, no por nodo.

## Documentación y revisión

UTF-8 y LF; enlaces relativos entre documentos; nombres ASCII de archivos.
Cada afirmación de runtime lleva evidencia de prueba; cada propuesta etiqueta DESIGN DECISION.
Actualizar source map cuando cambien símbolos relevantes. Especificar versiones/client build evaluados.
Cambiar doc antigua no autoriza tocar código ajeno. Preservar worktree del usuario;
si git ya muestra cambios previos, separarlos de los propios antes de cualquier rollback.

## Checklist de una entrega futura

Dependencias/orden correctos; owner/lifecycle claro; default vanilla conservado; un request por Confirm;
Committed externo; capacidad/draft preview separado; SQL/wire compatibles; pruebas proporcionadas;
rollback de una sola feature; ningún archivo de Ascension modificado.
