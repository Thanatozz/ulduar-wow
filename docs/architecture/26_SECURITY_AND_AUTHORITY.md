# 26 — Autoridad, revisiones y fallo seguro

**VERIFIED FROM ULDUAR SOURCE**, U03/U04/U11/U12.
El receptor servidor valida sesión/canal, parsea números, comprueba elegibilidad y valida presupuesto bajo mutex.
El addon no es una frontera de seguridad: un cliente modificado puede fabricar solicitudes.

## Invariantes normativos

**DESIGN DECISION.**

- Actor siempre el Player autenticado de la sesión, no un GUID aceptado del payload.
- Ability registrada, runtime habilitado, clase/unlocks permitidos y spell aprendido.
- Revision pertenece a sesión/generación actual y coincide con la base.
- Presupuesto total Rank-1; suma de costes en ancho suficiente sin overflow.
- Enums cerrados, ranks no negativos, caps técnicos y requisitos de modos/modifiers.
- Draft no altera DB ni gameplay. Una build inválida no publica cambios parciales.
- Persistencia fallida o resultado incierto no se presenta como éxito ni se repite automáticamente.
- Cambios GM/config/rank invalidan revisiones; push futuro no permite sobrescribir Draft sin conflicto.

## Riesgos observados y mitigación de diseño

**Replay tras reconnect**

- Estado actual: Token + revisión en memoria; cliente limpia estado al entrar al mundo
- Contrato futuro: Session generation explícita y pruebas de token anterior

**Timeout después de write**

- Estado actual: No retry de mutation; cache puede invalidarse
- Contrato futuro: GET/reconcilia, no asumir rollback

**Snapshot incompleto**

- Estado actual: Staging hasta END
- Contrato futuro: Campos obligatorios por versión, TTL/buffer/count y snapshotId

**Respuesta demasiado larga**

- Estado actual: Send omite >255 bytes
- Contrato futuro: Validar antes de BEGIN o chunk con límites

**Datos cross-player por chat**

- Estado actual: Self whisper/sesión comprobados
- Contrato futuro: Mantener actor server y filtro de respuestas

**Protocolo v2 con extensiones**

- Estado actual: Versionado existente, ampliaciones adicionales
- Contrato futuro: Negociación estricta antes de depender de campos nuevos

**Recursos custom inyectados**

- Estado actual: Icono desde SpellID
- Contrato futuro: No recibir rutas ejecutables/Lua por protocolo

**Pools con datos viejos**

- Estado actual: Framework objetivo aún no implementado
- Contrato futuro: Reset/lease/unsubscribe obligatorio

**Proxies visuales**

- Estado actual: Separados del Player lógico
- Contrato futuro: Revalidar al llegar; no ejecutar gameplay con caster proxy

Token de addon no es un secreto que convierta al cliente en confiable.
No considerar preview de coste o booleanos SupportsNode como validación final.

## Persistencia

Un upsert de una fila validada ofrece commit lógico por ability; lectura posterior verifica valores.
No garantiza rollback DB cuando se pierde la conexión después del write.
StateRevision no está persistida actualmente: el diseño admite revision session-scoped si token/generation
evitan reutilización tras reinicio. Persistir revision requeriría migración explícita, no cambio de UI.

No se aplicó SQL durante esta auditoría. Los campos nuevos requieren esquema ya compatible en entorno de pruebas;
la documentación no autoriza ejecutarlos.

## Herramientas y privacidad

UIEditor no es bypass de GM ni acceso a mundo. Exporta texto de layout, no código remoto ejecutado.
No guardar tokens, contraseñas o datos de otros jugadores en dumps/SV.
Licencias/procedencia de recursos y librerías se revisan antes de incorporar; no confundir referencia local con permiso
de copia.

Pruebas de falsificación, límites, stale y falla DB se describen en 30 para ejecución autorizada posterior.
