# 20 — GlueXML

**VERIFIED FROM ASCENSION SOURCE** A02/A33: Glue tiene su manifiesto independiente, GlueParent/GlueDialog,
realm data, login, selección y creación; incluye SharedXML y herramientas de addons directamente.
AccountLogin.lua contiene flujo para guardar contraseña y funciones custom de última cuenta.
Eso es una decisión de Ascension que **no se adopta**.

## Arquitectura objetivo

**DESIGN DECISION.** Separar GlueBootstrap, GlueTheme, LoginView, RealmView, CharacterSelectView
y CharacterCreateView, manteniendo APIs del cliente objetivo.
Branding y recursos Ulduar se ubican en Interface/Ulduar/Glue.
Shared aporta mixins/tablas/atlas/layout neutros; las utilidades de mundo con GameTooltip/UIParent/addon networking
no se inicializan en Glue. Usar adaptador GlueDialog y GlueTooltip si las APIs del cliente lo permiten.

Login maneja presentación del login nativo; no implementa autenticación paralela.
Realm select muestra datos del mecanismo nativo; no interpretar C_RealmSelect de Ascension como API WotLK disponible.
Character select/create conserva semántica de selección, borrado y creación del cliente.
No enviar builds ni comandos de mundo antes de entrar al personaje.

## Persistencia y auto-login futuro

No asumir que SavedVariables de addon se guardan/cargan en Glue como en mundo.
Las preferencias Glue necesitan mecanismo del cliente objetivo documentado por separado.
Auto-login es FUTURE, no implementado ni requisito de branding.
No guardar contraseñas/token en SV, layouts, CVar de texto ni exportaciones Lua;
un diseño futuro necesita contrato de autenticación seguro independiente.

## Prerrequisitos y rollback

Fuente vanilla exacta, loader verificado y patch mínimo probado; no importar todo GlueXML Ascension.
Entregar branding primero, sin alterar auth/realm mechanics.
Rollback restaura archivo/asset anterior o retira patch; no deja al usuario sin pantalla de login.
Pruebas futuras: login fallido, desconexión, selección/borrado cancelado, realm incompatible, locale,
cuenta sin personajes y parche parcial. **RUNTIME TEST REQUIRED**; nada de esto se ejecutó en la auditoría.
