# 16 — Protocolo actual y objetivo

**VERIFIED FROM ULDUAR SOURCE** U04/U10/U11/U12. No hay networking custom C_* en esta feature.
El canal actual es addon message WHISPER al propio personaje. C++ usa LANG_ADDON y construye respuesta al mismo Player.
El prefijo visible Lua es `ULDAB1`; en C++ la cadena chat incluye `ULDAB1\t`.
El número del prefijo no sustituye `ProtocolVersion=2`.

## Wire actual v2

Cabecera del cuerpo: `2|TYPE|sequence|token`. El conjunto prefix + tab + cuerpo no puede exceder 255 bytes.
Los números se parsean completos; no se aceptan sufijos como parte de un entero.
Requests: HELLO, GET y APPLY_BUILD. Persisten operaciones heredadas por nodo en servidor; la UI oficial usa build
completa.

`APPLY_BUILD` añade, en orden:
AbilityId, BaseRevision, Element, PropagationMode, CoverageRank, PotencyRank,
DamageRank, CooldownReductionRank, CastTimeReductionRank, ChainReboundRank.
Son 14 campos contando cabecera; no incluye Player GUID, puntos, CustomRank ni mobile.
La revisión se conserva como texto decimal en Lua para no perder precisión uint64.

| Respuesta | Campos totales | Función |
| --- | --- | --- |
| WELCOME | 4 | Asigna token a la sesión; luego snapshot |
| BEGIN | 5 | Número de abilities a recibir |
| RULES | 17 | Costes, límites técnicos y curvas base |
| BALANCE | 15 | Caps gameplay, daño/CD/cast time, coste de nuevos modifiers |
| DEF | 14 | ID/baseSpell/taxonomía/relación/modos |
| CAPS | 9 | Capabilities históricas, clase, skill, spec |
| BASE | 6 | AbilityId y elemento base |
| MODIFIERS | 12 | ID/mask, cuatro ranks nuevos, base cooldown/cast time ms |
| REV | 6 | ID y revisión |
| STATE | 17 | ID/rank/puntos/spent/element/mode/coverage/potency/targets/search/radius/multiplier/limited |
| RANKS | 6 | ID y fragmento de IDs nativos separados por coma |
| END | 4 | Final de snapshot; cliente publica staging completo |
| ERROR | 6 | Código y flag terminal |

Confirmar campos exactos contra `Snapshot` y `UA.Receive` antes de cambiar serializers.
RANKS se fragmenta con límite de cadena de 160 caracteres; es chunking específico, no framing genérico.
Los iconos/nombres se resuelven por SpellID cliente; no se transportan texturas.

## Sesión, autoridad y atomicidad actuales

HELLO intercambia token; GET obtiene estado; APPLY valida disponibilidad y revisión antes de mutar.
Solo se permite un request pendiente en el addon. Timeout de 8 segundos invalida conexión local y no repite mutaciones.
El servidor aplica throttling (8 requests por ventana de 2 segundos) y descarta canal/remitente ajeno al propio Player.
Token y secuencia correlacionan respuestas; **no son cifrado ni autenticación criptográfica**.

El manager valida presupuesto total, valores/capacidades, modo, clase y spell aprendido; construye `next`.
Persiste una fila y verifica lectura antes de publicar cache y revisión. Es atomicidad lógica de una build,
no una transacción distribuida entre cliente/cache/DB. Si el write pudo ocurrir y falla la verificación,
se invalida cache; no afirmar rollback SQL. Errores recuperables envían ERROR + snapshot; terminales cortan
sesión/request.

## Deuda comprobada

- Push espontáneo general no existe; `UA.Receive` exige request pendiente. No enviar STATE aislado como supuesto push.
- RULES/STATE y MODIFIERS/BALANCE evolucionaron mediante registros adicionales. Un cliente antiguo v2 puede ignorar
  datos que ya son obligatorios. Una ampliación incompatible debe negociar nueva versión, no confiar en comentarios v1.
- `Send` retorna sin emitir si una respuesta supera 255 bytes. Nuevos campos largos pueden crear snapshots incompletos.
- Snapshot copia estados por ability y obtiene config aparte. No prometer consistencia multi-ability bajo cambios
  concurrentes de config sin un snapshot/generación común.
- Revision vive en memoria. El token/session reset debe impedir que una ventana previa a reconectar haga commit.

## Contrato objetivo

**DESIGN DECISION.** Mantener addon messages. Negociar versión de wire, feature flags y versión de catálogo/reglas.
Separar requestId de stateRevision y snapshotId; definir campos obligatorios por versión.
BEGIN anuncia snapshotId, rulesRevision y cantidad; registros se agrupan bajo ese ID; END verifica completitud.
Nunca publicar medio catálogo ni reemplazar Committed al recibir el primer STATE.

Push futuro: mensaje explícito INVALIDATE o SNAPSHOT_PUSH con sesión válida y revision superior.
El cliente marca Draft conflictivo sin mezclarlo silenciosamente; solicita GET, conserva una vista informativa del
borrador si procede y exige nueva confirmación. Un STATE con requestId ajeno no puede ejecutar navegación pendiente.

Framing futuro solo al necesitarlo: índice/total, tamaño máximo, TTL y máximo de fragmentos por sesión.
Limitar buffer y rechazar duplicados incompatibles. Serializar enteros y enums, nunca `loadstring`.
No comprimir todavía. Reintentar GET es distinto de repetir APPLY: ante resultado incierto, refrescar estado.

Errores normativos: VERSION, SESSION, MALFORMED, THROTTLED, ABILITY, UNAVAILABLE, STALE, BUDGET, LIMIT, STORAGE.
Los códigos concretos actuales pueden diferir; su normalización requiere versión coordinada, no un cambio unilateral.
El servidor no enviará detalles SQL/credenciales en errores de usuario.

**RUNTIME TEST REQUIRED:** pérdida de END, partes duplicadas, timeout tras persistir, reload entre send/receive,
dos confirms, GM cambia rank, cambio de mapa/sesión y cliente antiguo. Véase 26 y 30.
