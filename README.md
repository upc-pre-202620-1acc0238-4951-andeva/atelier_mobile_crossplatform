# Atelier Mobile (Flutter)

App Android e iOS para el **personal del taller** (dueño, administrador, mecánico jefe, asesor, recepcionista, mecánico, almacén y caja) del ecosistema Atelier. Es la misma app que `atelier-mobile-android` y consume el backend `atelier-platform` (Spring Boot, Render).

- **Stack:** Flutter, Material 3, `get_it`, `http`, Drift, `workmanager`, Firebase Messaging, `image_picker`, `geolocator` y Bluetooth (ELM327).
- **Arquitectura:** Clean Architecture + Feature-First + DDD, con el proyecto Flutter del curso como estándar ([docs/05-flutter-architecture.md](docs/05-flutter-architecture.md)).

## Documentación

Empieza por [docs/README.md](docs/README.md). Ahí está el orden de lectura y para qué sirve cada archivo. El avance está en [docs/07-roadmap.md](docs/07-roadmap.md).

## Configuración local

1. Copiar `config/dev.example.json` a `config/dev.json` y completar los valores ([docs/04-mobile-integration.md §1](docs/04-mobile-integration.md#1-configuración-del-proyecto)).
2. Descargar de Firebase `google-services.json` (va en `android/app/`) y `GoogleService-Info.plist` (va en `ios/Runner/`).
3. Ninguno de esos archivos se versiona (ver `.gitignore`).

## Comandos

```bash
flutter run --dart-define-from-file=config/dev.json
```

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

iOS solo se compila en una Mac con Xcode.
