# Documentación de Atelier Mobile (Flutter)

Documentación para construir la app multiplataforma (Android e iOS) de staff. Es la misma app que `atelier-mobile-android`, con el estilo Flutter del curso y **Drift** como base local. Está escrita en Markdown simple (sin LaTeX ni HTML) para que la lean igual una persona y un asistente de IA.

## Orden de lectura

| # | Archivo | Qué responde |
| --- | --- | --- |
| 0 | [00-easysong-guide.md](00-easysong-guide.md) | **Cómo lo hace el profesor:** análisis de `easysong-mobile-flutter`, el estándar del curso |
| 1 | [01-requirements/user-stories.md](01-requirements/user-stories.md) | **Qué** hay que construir: épicas EP01–EP09 e historias US01–US44 con sus criterios Gherkin |
| 2 | [02-roles-and-permissions.md](02-roles-and-permissions.md) | **Quién** puede hacer cada cosa: 8 roles, catálogo de permisos, matriz y qué pantalla habilita cada permiso |
| 3 | [03-traceability.md](03-traceability.md) | **Con qué endpoint** se cumple cada escenario, con qué permiso, y qué falta en el backend |
| 4 | [api/README.md](api/README.md) | **Cómo** hablar con el backend: sesión, errores, cabeceras, fechas, dinero, archivos y enums |
| 5 | `api/<contexto>.md` | Referencia de cada endpoint: permiso, parámetros, body, respuesta y modelos |
| 6 | [04-mobile-integration.md](04-mobile-integration.md) | Configuración, push FCM, fotos en Supabase, OBD-II, offline, permisos de Android e iOS, cuentas de prueba |
| 7 | [05-flutter-architecture.md](05-flutter-architecture.md) | **Cómo** se programa: librerías, carpetas, nombres y patrones (estilo del curso + Drift) |
| 8 | [06-offline-sync.md](06-offline-sync.md) | **Sin red**: tablas Drift, cola de operaciones, idempotencia por endpoint, flujos offline y convivencia entre la UI y el worker |
| 9 | [07-roadmap.md](07-roadmap.md) | **En qué paso va** la construcción: orden de features, estado, rama y qué reutilizar del núcleo |
| — | [android-roadmap-reference.md](android-roadmap-reference.md) | Detalle de cada caso de uso y pantalla de la app Android, como referencia para portarlos |
| — | [01-requirements/technical-stories.md](01-requirements/technical-stories.md) | Historias técnicas TS01–TS24 del backend (contexto) |
| — | [branding/](branding/) | Marca: logos, paleta y sistema de diseño |

## Fuentes y cómo se generaron

| Documento | Fuente |
| --- | --- |
| Guía de EasySong | Código del repo `easysong-mobile-flutter` (commit `efb6b2f`) |
| Historias, roles, `api/*.md` y branding | Copiados de `atelier-mobile-android/docs` |
| Trazabilidad | Copiada de Android, con los huecos H40–H43 agregados para iOS |
| Integración | Reescrita para Flutter; contrato y servicios de Android |
| Arquitectura | Reescrita siguiendo la guía de EasySong, con los mismos alcances que la de Android. El código se compiló y probó antes de publicarlo |
| Offline | Decisiones de Android. Tablas Drift generadas desde las Entities de Android y compiladas |
| Roadmap | Mismo orden que Android; casos de uso tomados del código de `features/*/application` |

Si el backend cambia, **el código del backend manda**. Si un archivo copiado cambia en Android, hay que traer el cambio también aquí: no se sincronizan solos.

| Documento | Copiado de `atelier-mobile-android` en |
| --- | --- |
| `03-traceability.md`, `android-roadmap-reference.md` | `d2a86ff` (2026-11-02) |

## Estado del backend

Referencia: `atelier-platform` hasta la versión 1.2.0 (formato de error único, `membershipId` en la sesión, desglose `subtotal`/`taxAmount` en la orden, huecos G1–G10 cerrados e idempotencia R3 y R4). Todos los escenarios de US01–US44 tienen respaldo en el backend o se resuelven en la app; ver [03-traceability.md → Huecos cerrados](03-traceability.md#huecos-cerrados).
