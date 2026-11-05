# AGENTS.md — Guía para asistentes de IA

Este repositorio es la app Flutter (Android e iOS) de staff de Atelier: la misma app que `atelier-mobile-android`, con el estilo del curso y Drift. Antes de escribir código, lee:

0. `docs/07-roadmap.md` — en qué paso va la construcción, qué hace cada paso y qué reutilizar del núcleo `core/`. Al terminar un paso, márcalo ahí.
1. `docs/05-flutter-architecture.md` — arquitectura, librerías, carpetas y nombres. **Síguela al pie de la letra.** `docs/00-easysong-guide.md` es el repo del profesor, del que sale ese estilo.
2. `docs/03-traceability.md` — qué endpoint y permiso cubre cada escenario de la historia que estás implementando.
3. `docs/api/<contexto>.md` — campos exactos de request y response (los DTOs salen de la sección *Modelos*).
4. `docs/api/README.md` — sesión, refresh token, formato de error, fechas (UTC → America/Lima), dinero e IGV.
5. `docs/06-offline-sync.md` — tablas Drift, cola `pending_operations`, qué acciones funcionan sin red y convivencia entre la UI y el worker. No encoles acciones marcadas como "en línea".
6. `docs/04-mobile-integration.md` — servicios externos y diferencias entre Android e iOS.

El comportamiento ya está resuelto en `../../atelier-mobile-android`: porta **qué** hace, no **cómo** está escrito en Kotlin.

## Reglas

- Clean Architecture + Feature-First + DDD. `domain` no importa Flutter, `http`, Drift, `get_it` ni plugins.
- Un `UseCase` por acción con método `execute`. Lanza `ApiException` o `NetworkException`; no devuelve `Result`.
- ViewModel: `ChangeNotifier` con `_state` privado y getter `state`; se muta con `copyWith` y `notifyListeners()`. `dispose` cancela las suscripciones. La vista usa `ListenableBuilder`.
- `get_it`: `registerLazySingleton` para servicios y casos de uso, con el contrato como tipo; `registerFactory` para ViewModels. Un `setup<Feature>Dependencies()` por feature.
- Sin `provider`, `bloc`, `riverpod`, `go_router`, `dio`, `retrofit`, `freezed` ni `json_serializable`. Navegación con `Navigator` y `MaterialPageRoute`. DTOs con `fromJson` a mano.
- Drift es la única generación de código. Tablas con `@DataClassName('[Modelo]Entity')`. Tras cambiar una tabla o un DAO, corre `build_runner` y versiona los `*.g.dart`. Tras cambiar el esquema, sube `schemaVersion` y corre `make-migrations`.
- Repositorios offline-first: red → Drift → UI con `watch()`. Escrituras que deben sobrevivir sin red → cola `pending_operations` + `SyncProcessor`.
- La UI y el worker corren en motores distintos y no comparten memoria. Refresh y sincronización van siempre bajo `CrossIsolateLock`. Nada de estado en variables globales que el worker necesite.
- La UI se habilita por **permiso** (`session.has(Permission.x)`), nunca por nombre de rol.
- Mostrar al usuario el `message` del error del backend; decidir el flujo por el código HTTP.
- Lo que dependa de la plataforma va detrás de un contrato. Si solo funciona en Android o en iOS, dilo y documéntalo en `docs/04-mobile-integration.md`.
- No afirmes que algo funciona en iOS si no se ejecutó en una Mac: márcalo como sin comprobar.
- No inventar endpoints ni campos: si no está en `docs/api/`, no existe. Si una historia lo necesita, márcalo como hueco en `docs/03-traceability.md`.
- No versionar secretos: `config/dev.json`, `google-services.json`, `GoogleService-Info.plist`, llaves de firma y cuentas de prueba quedan fuera de git.
- Textos visibles en español, en `lib/l10n/app_es.arb`.

## Comandos

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter build apk --debug --dart-define-from-file=config/dev.json
```
