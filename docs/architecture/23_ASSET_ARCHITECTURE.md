# 23 — Arquitectura de assets

**DESIGN DECISION.** MVP prioriza recursos del cliente Blizzard objetivo y código propio.
La existencia de una textura en AtlasInfo Ascension no prueba que exista en WotLK ni autoriza distribuirla.

## Rutas

```text
Interface/Ulduar/
  UI/
  Icons/
  Atlas/
  Frames/
  Abilities/
  CityBuilder/
  Glue/
```

UI/Frames contienen skins genéricas; Abilities y CityBuilder solo recursos exclusivos de feature.
Atlas almacena spritesheets propios; su metadata pertenece al registro de recursos versionado.
No se crea arte nuevo durante esta tarea.

## Convenciones

Nombres ASCII estables y descriptivos, lower-kebab-case para recursos nuevos;
preservar spelling exacto en metadatos y no depender de tolerancia Windows a mayúsculas.
Namespace atlas: ulduar-ability-node-selected, ulduar-panel-border, etc.
Metadata: path, width/height, UV normalizadas, optional flags, fuente/licencia, categoría y versión.
No guardar UV en cada widget. Registrar fallback para atlas inexistente.

TGA/BLP se evalúan con formatos compatibles con el cliente objetivo.
No usar PNG como supuesto formato runtime universal ni introducir shaders/máscaras custom.
Spritesheets deben contemplar bleeding, padding y escala; BLP con compresión/alpha se prueba visualmente.
La compatibilidad de un encoder/formato específico queda RUNTIME TEST REQUIRED; no se ejecutó conversión.

## Recursos Blizzard prioritarios

- Interface/Icons/INV_Misc_Gem_Pearl_06 para identidad contextual/microbutton.
- Interface/DialogFrame/UI-DialogBox-Background, UI-DialogBox-Border y UI-DialogBox-Header.
- Interface/Buttons/ButtonHilight-Square y familia UI-MicroButton para estados.
- Templates CharacterFrame/OptionsFrame tabs y fuentes GameFontNormal/Highlight.
- Iconos reales de spells mediante GetSpellInfo, sin imágenes enviadas por protocolo.

Validar paths en nuestro cliente, documentar cada uso en manifiesto de assets.
No copiar la tabla AtlasInfo de Ascension ni sus sheets: implementar metadata propia de un subconjunto permitido.

## Mantenimiento

Cambiar recurso sin cambiar identidad de ability. El registry sigue enviando SpellID.
Assets son presentación; nunca desbloquean nodes ni determinan coste.
Una actualización de spritesheet coordina metadata/UV en la misma release.
Rollback conserva versión anterior de ambos, no solo del archivo de imagen.
