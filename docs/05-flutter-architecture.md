# Guía de arquitectura y estándares — Atelier Mobile (Flutter)

Adaptación de la guía del curso ([00-easysong-guide.md](00-easysong-guide.md)) a la app de staff de Atelier. Se mantienen **la misma arquitectura, carpetas, nombres y patrones** del profesor; se agregan solo las piezas que esta app necesita (sesión con refresh, permisos RBAC, push, Bluetooth, cámara, ubicación y cola offline).

La funcionalidad es la de `atelier-mobile-android`: mismas historias, mismo backend y mismos casos de uso. Esa app es la **referencia de comportamiento**; esta guía dice cómo se escribe en Flutter.

Regla para decidir: **primero el repo del profesor.** Si él no lo resuelve, la solución más simple en Flutter con el mismo nombre que en Android. La única diferencia de fondo pedida es **Drift** en vez de `sqflite`.

---

## 1. Visión general

**Clean Architecture** + **Feature-First** + conceptos tácticos de **DDD**, con UI en widgets de Flutter y **Material 3**.

```text
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│   (Pages, ViewModels con ChangeNotifier, UiState, Navigator)    │
└───────────────────────────────┬─────────────────────────────────┘
                                │ usa
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                          │
│                 (UseCases con método execute)                   │
└───────────────────────────────┬─────────────────────────────────┘
                                │ orquesta
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                             │
│  (Entidades, Value Objects, Repositorios abstractos, Permission)│
└───────────────────────────────▲─────────────────────────────────┘
                                │ implementa (DIP)
┌───────────────────────────────┴─────────────────────────────────┐
│                     INFRASTRUCTURE LAYER                        │
│  (Api con http, DTOs, Drift, DAOs, SessionManager, workmanager, │
│   OBD por Bluetooth, Supabase, FCM, registros de get_it)        │
└─────────────────────────────────────────────────────────────────┘
```

Regla de dependencia: `domain` no importa Flutter, `http`, Drift, `get_it` ni plugins. Sí puede usar paquetes de Dart puro como `decimal`. Cada **feature** corresponde a un *bounded context* del backend (o a una parte de él).

### Android → Flutter

| Android (`05` original) | Flutter (esta app) | De dónde sale |
| --- | --- | --- |
| Compose `Screen` | `Page` (widget) | Profesor |
| `@HiltViewModel` + `StateFlow` | `ChangeNotifier` + `ListenableBuilder` | Profesor |
| `_uiState.update { it.copy() }` | `_update(_state.copyWith())` | Profesor |
| `operator fun invoke` | `execute` | Profesor |
| Hilt (`@Provides`, `@Binds`) | `get_it` | Profesor |
| Retrofit `Service` + Gson | `Api` con `http` + `fromJson` | Profesor |
| Navigation Compose | `Navigator` + `MaterialPageRoute` | Profesor |
| Room (`@Entity`, `@Dao`) | **Drift** (`Table`, `@DriftAccessor`) | Pedido del proyecto |
| `Flow` de Room | `Stream` de `.watch()` | Drift |
| `suspend` + `Result<T>` | `Future` + excepciones | Profesor |
| OkHttp `Interceptor` + `Authenticator` | `AuthenticatedClient extends http.BaseClient` | §5.3 |
| DataStore | `flutter_secure_storage` + `SharedPreferencesAsync` | §5.3 |
| WorkManager + `@HiltWorker` | `workmanager` | [06](06-offline-sync.md) §3 |
| `BigDecimal` | `Decimal` (paquete `decimal`) | §5.1 |
| `@JvmInline value class` | `extension type` | §5.1 |
| `IOException` | `NetworkException` (propia) | §5.3 |
| `java.time.Clock` | `DateTime Function()` inyectable | §5.1 |
| `strings.xml` | ARB con `flutter gen-l10n` | §4 |
| Coil 3 | `cached_network_image` | §2 |
| CameraX / Photo Picker | `image_picker` | [04](04-mobile-integration.md) §3 |
| `FusedLocationProviderClient` | `geolocator` | [04](04-mobile-integration.md) §7 |
| Sockets Bluetooth nativos | `ObdTransport`: canal de plataforma (SPP) y `universal_ble` (BLE) | [04](04-mobile-integration.md) §4 |

---

## 2. Dependencias

Como en el curso, todo va en `pubspec.yaml`. Las librerías que el profesor no usa se marcan con ➕: cada una tiene un motivo y no hay otra forma razonable de hacerlo con lo que él ya usa.

Las versiones se resolvieron con Flutter 3.47.7 y Dart 3.13.5, y todas tienen licencia permisiva (MIT, BSD o Apache).

```yaml
name: atelier_mobile_crossplatform
description: "App de staff de Atelier para Android e iOS."
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.13.5

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:          # ➕ textos en español (fechas y Material)
    sdk: flutter
  http: ^1.6.0
  get_it: ^9.3.0
  path_provider: ^2.1.6           # ➕ carpetas para fotos pendientes y PDFs
  drift: ^2.35.3                  # ➕ reemplaza a sqflite (pedido del proyecto)
  drift_flutter: ^0.3.1           # ➕ abre la base en Android e iOS
  shared_preferences: ^2.5.6      # ➕ datos de sesión que no son secretos
  flutter_secure_storage: ^11.2.0 # ➕ tokens cifrados
  decimal: ^3.2.6                 # ➕ dinero sin errores de double
  intl: ^0.20.3                   # ➕ fechas y S/ 1,234.50
  uuid: ^4.6.0                    # ➕ ids de cola y de fotos
  workmanager: ^0.10.10           # ➕ cola offline en segundo plano
  connectivity_plus: ^7.3.2       # ➕ deshabilitar acciones "en línea"
  firebase_core: ^5.1.0           # ➕ FCM
  firebase_messaging: ^17.0.1     # ➕ FCM
  flutter_local_notifications: ^22.3.3 # ➕ canales y push en primer plano
  permission_handler: ^13.0.2     # ➕ cámara, notificaciones y Bluetooth
  geolocator: ^14.0.1             # ➕ geocerca
  image_picker: ^1.2.4            # ➕ fotos de evidencia
  flutter_image_compress: ^2.5.1  # ➕ JPEG de 1600 px
  cached_network_image: ^4.0.6    # ➕ fotos con caché, como Coil
  google_sign_in: ^7.2.0          # ➕ Google Sign-In
  universal_ble: ^3.2.0           # ➕ ELM327 por BLE (única opción en iOS)
  flutter_foreground_task: ^11.0.3 # ➕ sesión OBD-II larga en Android
  open_filex: ^5.0.0              # ➕ abrir PDFs
  share_plus: ^13.3.1             # ➕ compartir PDFs

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.17.1           # ➕ genera el código de Drift
  drift_dev: ^2.35.2              # ➕ genera el código de Drift
  mocktail: ^1.0.5                # ➕ mocks en tests
  flutter_launcher_icons: ^0.14.4

flutter:
  uses-material-design: true
  generate: true                  # textos de lib/l10n

  assets:
    - assets/images/

  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/plus_jakarta_sans_regular.ttf
        - asset: assets/fonts/plus_jakarta_sans_medium.ttf
          weight: 500
        - asset: assets/fonts/plus_jakarta_sans_semibold.ttf
          weight: 600
        - asset: assets/fonts/plus_jakarta_sans_bold.ttf
          weight: 700
        - asset: assets/fonts/plus_jakarta_sans_extrabold.ttf
          weight: 800
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/jetbrains_mono_medium.ttf
          weight: 500
    - family: AlbertSans
      fonts:
        - asset: assets/fonts/albert_sans_extrabold.ttf
          weight: 800
```

### Lo que no se usa, a propósito

| No usar | Por qué |
| --- | --- |
| `dio`, `retrofit`, `json_serializable`, `freezed` | El profesor usa `http`, `fromJson` y `copyWith` a mano. Drift es la única generación de código |
| `provider`, `bloc`, `riverpod` | `ChangeNotifier` + `get_it`, como el profesor |
| `go_router` | `Navigator`, como el profesor |
| `flutter_blue_classic` | GPL-3: obligaría a publicar la app bajo esa licencia. SPP va por un canal de plataforma que reutiliza el Kotlin de Android |
| `flutter_blue_plus` | Su licencia actual exige una licencia comercial para uso con fines de lucro. `universal_ble` es BSD y cubre lo mismo |
| Cliente de Supabase | Arrastra dependencias que no hacen falta: la subida es un `POST` con `http`, igual que en Android |
| `timezone` | Lima es UTC−5 fijo y no tiene horario de verano: basta `BusinessTime` |

### `build.yaml`

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            atelier_db: lib/core/data/local/app_database.dart
          schema_dir: drift_schemas/
```

### `analysis_options.yaml`

Igual que el del profesor, sin analizar el código generado:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - android/**
    - ios/**
    - "**/*.g.dart"
```

---

## 3. Estructura de carpetas

```text
lib/
├── main.dart                          # Inicio, tema y AppRoot
│
├── core/
│   ├── config/
│   │   └── app_config.dart            # Valores de --dart-define-from-file
│   ├── data/
│   │   ├── local/
│   │   │   ├── app_database.dart      # Única base Drift (todas las tablas)
│   │   │   ├── app_lock_table.dart    # Tabla app_locks (propia de Flutter)
│   │   │   ├── cross_isolate_lock.dart # Exclusión entre motores (06 §3)
│   │   │   ├── jwt_claims.dart        # Lee `exp` del JWT para token_expires_at
│   │   │   ├── session_manager.dart   # Sesión: tokens cifrados + preferencias
│   │   │   └── session_store.dart     # Interfaz mínima para probar sin plugins
│   │   ├── remote/
│   │   │   ├── api_client.dart        # get/post/put/delete → JSON o ApiException
│   │   │   ├── authenticated_client.dart # "Authorization", "Accept-Language" y un reintento tras 401
│   │   │   ├── connectivity_observer.dart # ChangeNotifier para acciones en línea
│   │   │   ├── pdf_downloader.dart    # PDFs → cacheDir/pdfs (04 §8)
│   │   │   ├── public_endpoints.dart  # Rutas sin token
│   │   │   ├── token_refresher.dart   # Un solo refresh aunque haya varios 401
│   │   │   ├── branch/                # BranchApi: lo usan auth y attendance
│   │   │   ├── employee/              # EmployeeApi: lo usan auth, attendance y workorders
│   │   │   └── session/               # AuthRefreshApi, DeviceTokenApi y sus DTOs
│   │   └── sync/
│   │       ├── pending_operation_table.dart / pending_upload_table.dart / cache_metadata_table.dart
│   │       ├── pending_operation_dao.dart / pending_upload_dao.dart / cache_metadata_dao.dart
│   │       ├── cache_maintenance_dao.dart # Borra las cachés al cerrar sesión (no la cola)
│   │       ├── local_change_notifier.dart # El worker avisa a la UI que escribió (06 §3)
│   │       ├── pending_operation_queue.dart # Punto único para encolar
│   │       ├── operation_handler.dart # Contrato + registro de handlers por `type`
│   │       ├── upload_file_handler.dart # UPLOAD_FILE (núcleo)
│   │       ├── sync_processor.dart    # Algoritmo de 06 §3, sin Flutter (testeable)
│   │       ├── sync_scheduler.dart    # Trabajo único, reintento y periódico
│   │       ├── sync_triggers.dart     # Al abrir, al recuperar red y al volver a primer plano
│   │       └── sync_worker.dart       # callbackDispatcher de workmanager
│   ├── designsystem/                  # Aún no existe: fuera del paso 1 (07)
│   │   ├── component/                 # AtelierTopBar, AtelierButton, StatusChip, MoneyText…
│   │   └── theme/
│   │       └── theme.dart             # MaterialTheme, como el del profesor, con la marca Atelier
│   ├── di/
│   │   └── dependency_injection.dart  # getIt + setupDependencies()
│   ├── domain/
│   │   ├── api_exception.dart         # httpStatus + code + message + details
│   │   ├── business_time.dart         # Día de Lima: "hoy", dedupe_key, rangos
│   │   ├── missing_branch_exception.dart
│   │   ├── money.dart
│   │   ├── network_exception.dart     # Sin red o sin respuesta
│   │   ├── permission.dart
│   │   ├── plan.dart
│   │   └── session.dart
│   ├── media/
│   │   ├── photo_capture.dart         # Foto → pending_uploads → UPLOAD_FILE + ATTACH_*
│   │   ├── storage_paths.dart         # Rutas del bucket con UUID por foto
│   │   └── supabase_uploader.dart     # Comprime, sube y arma la URL pública
│   └── notifications/
│       ├── device_token_registrar.dart # PUT /users/me/device-token
│       ├── notification_channels.dart
│       ├── push_inbox.dart            # Push tocado pendiente de abrir
│       ├── push_messaging_service.dart # FirebaseMessaging: token y mensajes
│       └── push_router.dart           # data.type → PushDestination
│
├── l10n/
│   └── app_es.arb                     # Textos visibles
│
├── navigation/
│   └── app_root.dart                  # Login o app, según la sesión
│
└── features/
    ├── auth/            # IAM: login, Google, OTP, invitación, recuperar contraseña
    ├── main/            # Scaffold + NavigationBar con pestañas según permisos
    ├── attendance/      # HR: marcar ingreso/salida, mi día, historial, descargos, mi turno
    ├── team/            # HR: asistencia de la sede, revisar descargos
    ├── reception/       # CRM: placa/cliente, registrar, afiliar, citas, llegada
    ├── workorders/      # Operations: abrir orden, tareas, propuestas, proforma, fotos
    ├── tasks/           # Operations: mis tareas, cronómetro, pausas, evidencias, repuestos
    ├── bays/            # Operations: tablero de bahías y reasignación
    ├── inventory/       # Inventory: catálogo, lotes, alertas de stock
    ├── diagnostics/     # IoT: escáner ELM327, DTC, telemetría, informes IA, alertas
    ├── cashier/         # Invoicing: comprobante SUNAT, pagos, pase de salida, entrega
    └── reports/         # Invoicing/IoT: flujo de caja y flota en PDF
```

Cada feature repite la estructura del profesor:

```text
features/tasks/
├── application/
│   ├── observe_my_tasks_use_case.dart
│   ├── refresh_my_tasks_use_case.dart
│   ├── start_task_use_case.dart
│   └── pause_task_use_case.dart
├── domain/
│   ├── task.dart
│   ├── task_id.dart
│   ├── task_status.dart
│   ├── pause_reason.dart
│   └── task_repository.dart
├── infrastructure/
│   ├── di/
│   │   └── task_dependencies.dart      # setupTaskDependencies()
│   ├── local/
│   │   ├── task_dao.dart
│   │   └── task_table.dart
│   ├── remote/
│   │   ├── task_api.dart
│   │   ├── assigned_task_dto.dart
│   │   ├── work_order_task_dto.dart
│   │   └── pause_task_request_dto.dart
│   └── task_repository_impl.dart
└── presentation/
    ├── mytasks/
    │   ├── my_tasks_page.dart
    │   ├── my_tasks_ui_state.dart
    │   └── my_tasks_view_model.dart
    └── taskdetail/
        ├── task_detail_page.dart
        ├── task_detail_ui_state.dart
        ├── task_detail_view_model.dart
        └── components/
            ├── task_timer.dart
            └── task_product_list.dart
```

Diferencias con el repo del profesor, porque aquí hay muchos más archivos:

- **`get_it` por feature:** en lugar de un archivo enorme, `core/di/dependency_injection.dart` llama a `setupTaskDependencies()`, `setupAttendanceDependencies()`, etc. Android hace lo mismo con sus módulos.
- **Una subcarpeta por pantalla** en `presentation/` cuando hay más de una.
- **`infrastructure/local/`** agrupa tabla y DAO.

### Mapa feature → historias → API

| Feature | Historias | Archivo de API |
| --- | --- | --- |
| `auth` | US01–US05 | [api/iam.md](api/iam.md) |
| `attendance` | US06–US10 | [api/hr.md](api/hr.md) |
| `team` | US10 (supervisión de descargos), asistencia diaria de la sede | [api/hr.md](api/hr.md) |
| `reception` | US11, US44 | [api/crm.md](api/crm.md) |
| `workorders` | US12–US15, US22, US24, US25, US36, US33 E2, US35 E2 | [api/operations.md](api/operations.md) |
| `tasks` | US23, US26–US30, US33 E1, US35 E1/E3 | [api/operations.md](api/operations.md) |
| `bays` | US40 | [api/operations.md](api/operations.md) |
| `inventory` | US31, US32, US34 | [api/inventory.md](api/inventory.md) |
| `diagnostics` | US16–US21, US43 | [api/iot.md](api/iot.md) |
| `cashier` | US37–US39, US42 | [api/invoicing.md](api/invoicing.md), [api/operations.md](api/operations.md) |
| `reports` | US41, US43 E2 | [api/invoicing.md](api/invoicing.md), [api/iot.md](api/iot.md) |

---

## 4. Convenciones de nomenclatura

Las del profesor. Los archivos van en `snake_case` y los imports son absolutos (`package:atelier_mobile_crossplatform/...`).

| Elemento | Convención | Ejemplo en Atelier |
| :--- | :--- | :--- |
| Entidades de dominio | Sustantivo | `Task` en `task.dart` |
| Value Objects | Sustantivo | `Money`, `TaskId`, `Plate` |
| Repositorio (contrato) | `abstract class [Modelo]Repository` | `TaskRepository` |
| Implementación | `[Modelo]RepositoryImpl` / `InMemory[Modelo]Repository` | `TaskRepositoryImpl` |
| Casos de uso | Verbo + modelo + `UseCase`, método `execute` | `StartTaskUseCase`, `ClockInUseCase` |
| Cliente HTTP | `[Modelo]Api` | `TaskApi`, `AttendanceApi` |
| DTOs | `[Modelo]Dto`, `[Acción]RequestDto`, `[Acción]ResponseDto` | `AssignedTaskDto`, `ClockInRequestDto` |
| Tabla Drift | Plural del nombre de la tabla, en `[modelo]_table.dart` | `Tasks`, `WorkOrders` |
| Fila de Drift | `@DataClassName('[Modelo]Entity')` | `TaskEntity` |
| DAOs | `[Modelo]Dao` | `TaskDao` |
| Registro de `get_it` | `setup[Feature]Dependencies()` | `setupTaskDependencies()` |
| Estado de UI | `[Pantalla]UiState` | `TaskDetailUiState` |
| ViewModels | `[Pantalla]ViewModel` | `TaskDetailViewModel` |
| Pantallas | `[Pantalla]Page` | `TaskDetailPage` |

Reglas extra de este proyecto (las mismas de Android):

- **`@DataClassName` es obligatorio.** Sin él, la tabla `Tasks` genera la clase `Task` y choca con la entidad de dominio.
- **Enums:** `enum` de dominio con el nombre del backend como dato (`TaskStatus.inProgress` → `'IN_PROGRESS'`). El DTO y la tabla guardan el `String`; el repositorio convierte. Un valor desconocido no debe cerrar la app: el backend puede agregar valores.
- **Ids:** `String` UUID envueltos en `extension type` (`TaskId`, `WorkOrderId`).
- **Textos visibles:** español, en `lib/l10n/app_es.arb`. El `message` del backend se muestra tal cual.

---

## 5. Patrones por capa

> El código de §5.1 a §5.4 se compiló y probó con `flutter analyze` y `flutter test` antes de escribir esta guía. Los imports se omiten.

### 5.1. Dominio

```dart
// core/domain/money.dart — Decimal, no double, para no perder céntimos; Drift lo guarda como texto (06 §5)
class Money {
  static const pen = 'PEN';
  static const usd = 'USD';

  final Decimal amount;
  final String currency;

  Money({required this.amount, required this.currency}) {
    if (amount < Decimal.zero) {
      throw ArgumentError('Amount must be greater than or equal to 0');
    }
    if (currency != pen && currency != usd) {
      throw ArgumentError('Currency must be PEN or USD');
    }
  }
}

// features/tasks/domain/task_id.dart — seguridad de tipos sin costo en ejecución
extension type TaskId._(String value) {
  factory TaskId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('TaskId must not be blank');
    }
    return TaskId._(value);
  }
}

// features/tasks/domain/task_status.dart
enum TaskStatus {
  pending('PENDING'),
  assigned('ASSIGNED'),
  inProgress('IN_PROGRESS'),
  onHold('ON_HOLD'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  final String apiName;

  const TaskStatus(this.apiName);

  static TaskStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiName == value);
  }
}

// features/tasks/domain/task.dart
class Task {
  final TaskId id;
  final String workOrderId;
  final int? workOrderNumber;
  final String vehicleId;
  final String description;
  final TaskStatus status;
  final DateTime? startedAt;
  final int totalPausedSeconds;

  const new({
    required this.id,
    required this.workOrderId,
    required this.workOrderNumber,
    required this.vehicleId,
    required this.description,
    required this.status,
    required this.startedAt,
    required this.totalPausedSeconds,
  });
}

// features/tasks/domain/task_repository.dart
abstract class TaskRepository {
  Stream<List<Task>> watchMyTasks();

  Future<void> refreshMyTasks();

  Future<Task> start(TaskId id);
}
```

Permisos como concepto de dominio (la app decide la UI con ellos, nunca con el nombre del rol):

```dart
// core/domain/permission.dart
extension type const Permission(String value) {
  static const tasksRead = Permission('operations:tasks:read');
  static const tasksTrackTime = Permission('operations:tasks:track_time');
  // … resto según docs/02-roles-and-permissions.md
}

// core/domain/session.dart (campos completos: docs/06-offline-sync.md §5)
class Session {
  final String userId;
  final Set<String> permissions;

  const new({required this.userId, required this.permissions});

  bool has(Permission permission) => permissions.contains(permission.value);
}
```

La UI combina **permiso del rol** y **módulo del plan**: `Session` también tendrá `plan`, `canUseTelemetry()` y `canUseAiDiagnostics()`, con las mismas reglas que en Android (un plan `null` no oculta nada; decide el backend).

El reloj se inyecta para poder probarlo, y Lima se calcula sin paquetes:

```dart
// core/domain/business_time.dart
class BusinessTime {
  static const limaOffset = Duration(hours: -5);

  final DateTime Function() now;

  const new({this.now = DateTime.now});

  DateTime limaNow() => now().toUtc().add(limaOffset);

  String today() => limaNow().toIso8601String().substring(0, 10);
}
```

### 5.2. Aplicación

```dart
// features/tasks/application/start_task_use_case.dart
class StartTaskUseCase {
  final TaskRepository repository;

  const new({required this.repository});

  Future<Task> execute(TaskId id) => repository.start(id);
}

// features/tasks/application/observe_my_tasks_use_case.dart
class ObserveMyTasksUseCase {
  final TaskRepository repository;

  const new({required this.repository});

  Stream<List<Task>> execute() => repository.watchMyTasks();
}
```

Android devuelve `Result<T>`; aquí un caso de uso **lanza** `ApiException` o `NetworkException`, como en el repo del profesor. Cuando Android usa un `sealed` para distinguir resultados (`ClockInResult`, `IssueOutcome`, `ArrivalResult`), se usa una `sealed class` de Dart.

`LocationProvider` y `ObdTransport` son contratos de dominio; sus implementaciones con plugins viven en `infrastructure`.

### 5.3. Infraestructura

#### Cliente HTTP y DTOs

Un `Api` por recurso, como `SongApi`, pero sobre un `ApiClient` compartido. Los campos salen de la sección *Modelos* del archivo de API.

```dart
// features/tasks/infrastructure/remote/task_api.dart
class TaskApi {
  final ApiClient client;

  const new({required this.client});

  Future<List<AssignedTaskDto>> getMyTasks() async {
    final List jsons = await client.get('/api/v1/tasks/my');
    return jsons.map((e) => AssignedTaskDto.fromJson(e)).toList();
  }

  Future<AssignedTaskDto> start(String taskId) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/tasks/$taskId/start',
    );
    return AssignedTaskDto.fromJson(json);
  }
}

// features/tasks/infrastructure/remote/assigned_task_dto.dart
class AssignedTaskDto {
  final String taskId;
  final String workOrderId;
  final int? workOrderNumber;
  final String vehicleId;
  final String status;
  final String description;
  final String? startedAt;
  final int? totalPausedSeconds;

  const new({
    required this.taskId,
    required this.workOrderId,
    required this.workOrderNumber,
    required this.vehicleId,
    required this.status,
    required this.description,
    required this.startedAt,
    required this.totalPausedSeconds,
  });

  factory AssignedTaskDto.fromJson(Map<String, dynamic> json) {
    return AssignedTaskDto(
      taskId: json['taskId'],
      workOrderId: json['workOrderId'],
      workOrderNumber: json['workOrderNumber'],
      vehicleId: json['vehicleId'],
      status: json['status'],
      description: json['description'],
      startedAt: json['startedAt'],
      totalPausedSeconds: json['totalPausedSeconds'],
    );
  }
}
```

#### Errores del backend

`ApiClient` es la versión Flutter de `apiCall` de Android. Decodifica UTF-8 siempre (`response.body` dañaría las tildes si el servidor no declara el `charset`) y convierte cualquier error en una excepción de dominio.

```dart
// core/domain/api_exception.dart — en dominio: los casos de uso deciden por HTTP sin importar http
class ApiException implements Exception {
  final int httpStatus;
  final String code;
  final String message;
  final List<String> details;

  const new({
    required this.httpStatus,
    required this.code,
    required this.message,
    this.details = const [],
  });

  @override
  String toString() => message;
}

// core/domain/network_exception.dart — el IOException de Android
class NetworkException implements Exception {
  final String message;

  const new([this.message = 'Sin conexión']);

  @override
  String toString() => message;
}

```

`lib/core/data/remote/api_client.dart` expone `get`, `post`, `put`, `delete` y `getBytes` (PDFs), con `headers` opcional, y devuelve el JSON ya decodificado o `null` en un 204:

- `IOException` (red y TLS), `ClientException` y timeout → `NetworkException`. No basta `SocketException`.
- Un error cuyo cuerpo no sea un objeto JSON, o traiga tipos inesperados (Render o un proxy pueden responder HTML), → `ApiException` con mensaje genérico. Nunca un `TypeError`.
- El timeout de 60 s (Render despierta en frío) es **por intento** y vive en `AuthenticatedClient`. Si envolviera todo el flujo, la UI vería "sin respuesta" mientras el `POST` reintentado tras el refresh todavía puede llegar.

> **Timeout y dinero:** `.timeout` deja de esperar, pero no cancela la petición: el `POST` pudo llegar al backend. Por eso emitir y cobrar siguen las reglas de H28 ([03](03-traceability.md#huecos-abiertos)): tras un `NetworkException`, se relee antes de reintentar. A diferencia de OkHttp, `package:http` no reintenta por su cuenta.

#### Sesión, cabeceras y renovación del token

`AuthenticatedClient` reemplaza a `AuthInterceptor` y `TokenAuthenticator`. Es el único cliente que reciben los `Api`.

`lib/core/data/remote/authenticated_client.dart` envía `Accept-Language: es` y:

- No pone token en las rutas públicas (`PublicEndpoints`) y respeta un `Authorization` explícito: el paso 2 llama a `membership` con el token aún sin guardar.
- Ante un 401 en ruta privada pide a `TokenRefresher` un token nuevo y reintenta **una sola vez**. Un 401 en ruta pública son credenciales, no sesión.

El refresh **rota** el `refreshToken` ([api/README.md](api/README.md) §2): un segundo refresh con el token viejo responde 401 y cerraría la sesión. Android lo evita con `synchronized`. En Flutter hay dos niveles:

1. **Dentro de un motor:** Dart corre en un solo hilo, así que basta compartir el `Future` en curso.
2. **Entre motores:** el worker de `workmanager` corre en otro motor, con su propia memoria. Ahí lo que comparten es el archivo de Drift, y se usa `CrossIsolateLock` ([06](06-offline-sync.md) §3).

`lib/core/data/remote/token_refresher.dart` aplica esos dos niveles:

- `refreshIfStale(tokenViejo)`: si otro ya renovó, devuelve el token actual sin llamar al backend. `ensureFresh()` renueva antes de enviar si el token venció (04 §5).
- Espera el bloqueo hasta cubrir su lease (90 s), no 10 s: con Render en frío el otro motor puede tardar 60 s, y rendirse antes devolvería un 401 sin necesidad.
- Con un 200 guarda la **respuesta completa** (`save(dto)`): el plan y los permisos también se actualizan en cada refresh. Decodifica con `utf8.decode(bodyBytes)`, y un 200 ilegible no cierra la sesión.
- Solo un 401 del refresh cierra la sesión. Sin red, o con un 5xx, la sesión se conserva y se reintenta luego.
- Antes de usar la respuesta comprueba que el token siga siendo el del inicio: si no, se cerró sesión o entró otro usuario durante el `POST`, y se descarta para no resucitar, pisar ni borrar la sesión. El cierre de sesión no espera el bloqueo.

`lib/core/data/local/session_manager.dart` guarda la sesión (claves en [06](06-offline-sync.md) §5). Sus reglas:

- **Orden de `save`:** preferencias → `refresh_token` → `token`. iOS puede matar al worker entre dos escrituras: así el corte deja un refresh válido. Al revés, un token nuevo con el refresh viejo perdería la sesión.
- **`clear` usa una lista de claves y no borra `installed`:** si la borrara, el siguiente arranque ejecutaría `clearIfReinstalled` y cerraría la sesión ya renovada.
- **`reload()`** avisa a los oyentes cuando otro motor cambió la sesión. No guarda nada en memoria.
- **Keychain con `first_unlock`:** el worker debe poder leerlo con el teléfono bloqueado.
- `Session.needsBranchChoice` (H33): sin perfil laboral y sin sede. Al iniciar sesión se escriben sede y marca **antes** de `save`, que es lo que hace visible la sesión: `AppRoot` la ve completa en su primera lectura.

- Se usa `SharedPreferencesAsync`, no `SharedPreferences`: esta última guarda una copia en memoria y un motor no vería lo que escribió el otro.
- `AppRoot` escucha este `ChangeNotifier`: al borrarse la sesión vuelve al login solo (§5.5).
- `SessionStore` es la interfaz mínima que usan `AuthenticatedClient` y `TokenRefresher`, así se prueban sin plugins.

#### Base de datos con Drift

**Tabla.** Reemplaza a `@Entity`. Las columnas pasan a `snake_case` solas y `.named()` se usa solo cuando difieren. Las 19 tablas están en [06](06-offline-sync.md) §5.

```dart
// features/tasks/infrastructure/local/task_table.dart (versión corta)
@DataClassName('TaskEntity')
@TableIndex(name: 'idx_tasks_work_order_id', columns: {#workOrderId})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text()();
  TextColumn get status => text()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

**DAO.** Reemplaza a `@Dao`. Drift ofrece consultas tipadas, así que casi nunca hace falta SQL.

```dart
// features/tasks/infrastructure/local/task_dao.dart
part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.attachedDatabase);

  Stream<List<TaskEntity>> watchAll() => select(tasks).watch();

  Future<List<TaskEntity>> fetchAll() => select(tasks).get();

  Future<void> replaceAll(List<TasksCompanion> entities) {
    return transaction(() async {
      await delete(tasks).go();
      await batch((b) => b.insertAll(tasks, entities));
    });
  }

  Future<TaskEntity> upsert(TasksCompanion entity) {
    return into(tasks).insertReturning(entity, onConflict: DoUpdate((_) => entity));
  }
}
```

| Room | Drift |
| --- | --- |
| `@Query("SELECT …") suspend fun` | `select(tasks)…get()` |
| `@Query("SELECT …") fun …: Flow` | `select(tasks)…watch()` |
| `@Upsert` | `into(tasks).insertOnConflictUpdate(x)` |
| `@Insert(onConflict = IGNORE)` | `into(x).insertReturningOrNull(y, mode: InsertMode.insertOrIgnore)` |
| `@Transaction` | `transaction(() async { … })` |
| `Entity` para insertar | `TasksCompanion.insert(...)` (los campos nulos y con valor por defecto son opcionales) |
| `Room.inMemoryDatabaseBuilder` | `AppDatabase(NativeDatabase.memory())` |
| `exportSchema = true` | `dart run drift_dev make-migrations` |

**Base.** Una sola, en el núcleo; cada feature solo agrega su tabla y su DAO:

```dart
// core/data/local/app_database.dart
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PendingOperations, PendingUploads, CacheMetadata, Attendances, Shifts, Branches,
    Tasks, WorkOrders, Bays, Customers, Vehicles, Appointments, Parts, Batches,
    Vouchers, TelemetryReadings, VehicleFaults, PredictiveAlerts, AppLocks,
  ],
  daos: [PendingOperationDao, TaskDao /* … un DAO por tabla */],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'atelier_db',
              native: const DriftNativeOptions(setup: configureConnection),
            ),
      );

  /// Antes de migrar: la migración es la escritura con más riesgo de bloqueo. `busy_timeout`
  /// primero, porque cambiar a WAL también puede encontrar el archivo ocupado.
  static void configureConnection(CommonDatabase database) {
    database.execute('PRAGMA busy_timeout = 5000');
    database.execute('PRAGMA journal_mode = WAL');
  }

  @override
  int get schemaVersion => 1;

  /// Avisa a los `watch()` de este motor que otro motor escribió en el archivo.
  void notifyExternalChanges() {
    notifyUpdates(allTables.map(TableUpdate.onTable).toSet());
  }
}
```

- `WAL` y `busy_timeout` son obligatorios: la UI y el worker abren el mismo archivo por separado. Van en `configureConnection`, pasado a `driftDatabase(native: DriftNativeOptions(setup: ...))`, y `busy_timeout` primero. En `beforeOpen` correrían **después** de la migración, justo la escritura con más riesgo de bloqueo. No se usa `shareAcrossIsolates`, porque solo funciona dentro del mismo motor.
- El parámetro `executor` permite usar una base en memoria en los tests.
- **Después de cambiar una tabla o un DAO:** `dart run build_runner build --delete-conflicting-outputs`. Los `*.g.dart` **se versionan**, para que `flutter run` funcione recién clonado y los cambios de esquema se vean en la revisión. `build_runner` 2.17 avisa que esa opción ya no existe y la ignora: no es un error.
- **Al cambiar el esquema:** subir `schemaVersion` y ejecutar `dart run drift_dev make-migrations`, que guarda el esquema en `drift_schemas/` y genera los pasos y las pruebas. Los esquemas se versionan.

#### Offline-first (Drift como fuente única de la verdad)

```dart
// features/tasks/infrastructure/task_repository_impl.dart
class TaskRepositoryImpl implements TaskRepository {
  final TaskApi api;
  final TaskDao dao;

  const new({required this.api, required this.dao});

  @override
  Stream<List<Task>> watchMyTasks() {
    return dao.watchAll().map((rows) => rows.map(_toDomain).toList()); // siempre desde Drift
  }

  @override
  Future<void> refreshMyTasks() async {
    try {
      final List<AssignedTaskDto> dtos = await api.getMyTasks();       // 1. red
      await dao.replaceAll(dtos.map(_toCompanion).toList());           // 2. DTO → tabla
    } on NetworkException {
      // Sin red: la UI sigue con la caché local.
    }
    // Un ApiException (401, 403, 5xx) sí sube: no es lo mismo que estar sin red.
  }

  @override
  Future<Task> start(TaskId id) async {
    final AssignedTaskDto dto = await api.start(id.value);
    return _toDomain(await dao.upsert(_toCompanion(dto)));
  }

  TasksCompanion _toCompanion(AssignedTaskDto dto) {
    return TasksCompanion.insert(
      id: dto.taskId,
      workOrderId: dto.workOrderId,
      workOrderNumber: Value(dto.workOrderNumber),
      vehicleId: dto.vehicleId,
      status: dto.status,
      description: dto.description,
      startedAt: Value(
        dto.startedAt == null
            ? null
            : DateTime.parse(dto.startedAt!).millisecondsSinceEpoch,
      ),
      totalPausedSeconds: dto.totalPausedSeconds ?? 0,
      syncedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Task _toDomain(TaskEntity entity) {
    return Task(
      id: TaskId(entity.id),
      workOrderId: entity.workOrderId,
      workOrderNumber: entity.workOrderNumber,
      vehicleId: entity.vehicleId,
      description: entity.description,
      status: TaskStatus.fromApi(entity.status),
      startedAt: entity.startedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(entity.startedAt!, isUtc: true),
      totalPausedSeconds: entity.totalPausedSeconds,
    );
  }
}
```

Las escrituras que deben sobrevivir sin red van a `pending_operations` ([06](06-offline-sync.md)).

#### Inyección con `get_it`

Como el profesor, salvo por dos cambios: un archivo por feature y **ViewModels con `registerFactory`**.

```dart
// core/di/dependency_injection.dart
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<SessionManager>(() => SessionManager());
  // … CrossIsolateLock, TokenRefresher, AuthenticatedClient, ApiClient, cola…

  setupAuthDependencies();
  setupTaskDependencies();
  // … una llamada por feature
}

// features/tasks/infrastructure/di/task_dependencies.dart
void setupTaskDependencies() {
  getIt.registerLazySingleton<TaskDao>(() => getIt<AppDatabase>().taskDao);
  getIt.registerLazySingleton<TaskApi>(
    () => TaskApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(api: getIt<TaskApi>(), dao: getIt<TaskDao>()),
  );
  getIt.registerLazySingleton<StartTaskUseCase>(
    () => StartTaskUseCase(repository: getIt<TaskRepository>()),
  );
  // … un caso de uso por acción

  getIt.registerFactory<MyTasksViewModel>(
    () => MyTasksViewModel(
      observeMyTasksUseCase: getIt<ObserveMyTasksUseCase>(),
      refreshMyTasksUseCase: getIt<RefreshMyTasksUseCase>(),
      startTaskUseCase: getIt<StartTaskUseCase>(),
    ),
  );

  // ViewModel con parámetro, para pantallas de detalle
  getIt.registerFactoryParam<TaskDetailViewModel, TaskId, void>(
    (taskId, _) => TaskDetailViewModel(taskId: taskId /* , casos de uso */),
  );
}
```

`setupDependencies()` también corre en el worker. Allí no se crea nada que no se pida, porque todo es perezoso; lo que dependa de la UI no debe construirse en su constructor.

### 5.4. Presentación

```dart
// features/tasks/presentation/mytasks/my_tasks_ui_state.dart
class MyTasksUiState {
  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;

  const MyTasksUiState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MyTasksUiState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false, // copyWith(errorMessage: null) no borraría el error
  }) {
    return MyTasksUiState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// features/tasks/presentation/mytasks/my_tasks_view_model.dart
class MyTasksViewModel extends ChangeNotifier {
  final ObserveMyTasksUseCase observeMyTasksUseCase;
  final RefreshMyTasksUseCase refreshMyTasksUseCase;
  final StartTaskUseCase startTaskUseCase;

  MyTasksViewModel({
    required this.observeMyTasksUseCase,
    required this.refreshMyTasksUseCase,
    required this.startTaskUseCase,
  }) {
    _subscription = observeMyTasksUseCase.execute().listen((tasks) {
      _update(_state.copyWith(tasks: tasks));
    });
    refresh();
  }

  late final StreamSubscription<void> _subscription;
  bool _disposed = false;

  MyTasksUiState _state = const MyTasksUiState();
  MyTasksUiState get state => _state;

  Future<void> refresh() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      await refreshMyTasksUseCase.execute();
      _update(_state.copyWith(isLoading: false));
    } catch (e) {
      _update(_state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> start(TaskId id) async {
    try {
      await startTaskUseCase.execute(id);
    } catch (e) {
      _update(_state.copyWith(errorMessage: e.toString()));
    }
  }

  void _update(MyTasksUiState state) {
    if (_disposed) return; // Una respuesta puede llegar con la pantalla ya cerrada.
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
```

`e.toString()` da el `message` del backend, porque `ApiException` lo devuelve así.

La página crea su ViewModel y lo libera:

```dart
// features/tasks/presentation/mytasks/my_tasks_page.dart
class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  late final MyTasksViewModel viewModel = getIt<MyTasksViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final state = viewModel.state;
        if (state.tasks.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final Task task = state.tasks[index];
                return ListTile(
                  title: Text(task.description),
                  onTap: () => viewModel.start(task.id),
                );
              },
            ),
          );
        }
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(child: Text(state.errorMessage ?? 'Sin tareas'));
      },
    );
  }
}
```

### 5.5. Navegación

`Navigator` y `MaterialPageRoute`, como el profesor. No hay rutas con nombre: los argumentos son parámetros del constructor y el compilador los valida, igual que las rutas `@Serializable` de Android.

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => TaskDetailPage(taskId: task.id)),
);
```

El profesor cambia de flujo con `pushReplacement` al tocar un botón. Atelier necesita más: si el refresh falla con 401, debe volver al login desde cualquier pantalla. Por eso la raíz observa la sesión (lo mismo que hace `AppNavHost` en Android):

`lib/navigation/app_root.dart` es un `StatefulWidget` que escucha `SessionManager` y relee **solo al recibir el aviso**. Un `Future` creado en `build` volvería al spinner con cualquier reconstrucción. Mientras relee mantiene la pantalla actual, y de dos lecturas seguidas vale la más reciente.

Hasta que se construya la capa de presentación muestra marcadores sin estilo en lugar de `LoginPage`, la pantalla de elegir sede (cuando `needsBranchChoice`) y `MainPage`.

Las pestañas salen de la sesión. Con `IndexedStack`, cada pestaña conserva su estado y su `Navigator`; el `MainPage` del profesor las reconstruye al cambiar, porque ahí el ViewModel es un singleton.

```dart
// features/main/presentation/navigation_item.dart — una opción por pestaña
class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Permission? requires;
  final WidgetBuilder page;

  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.requires,
    required this.page,
  });

  bool isVisibleFor(Session session) {
    return requires == null || session.has(requires!);
  }
}
```

Los push se abren con un `navigatorKey` global, que consume `PushInbox`: `PushRouter` convierte `data.type` + ids en un `PushDestination` y `MainPage` lo traduce a una página.

### 5.6. Sistema de diseño

- `core/designsystem/theme/theme.dart` conserva la forma del `MaterialTheme` del profesor (`light()`, `dark()`), con colores y tipografía de la marca. Los valores están en `core/designsystem/theme/{Color,Type,Shape}.kt` del repo Android, y son los que hay que portar.
- **Tipografía:** Plus Jakarta Sans en la interfaz, JetBrains Mono para datos y Albert Sans solo en el imagotipo, igual que Android. Los `.ttf` se copian de `app/src/main/res/font/`. Los `.woff2` de `docs/branding/satoshi/` no sirven: Flutter no carga ese formato.
- **Íconos:** los de Material (`Icons.*`), como el profesor. Android los escribe con `ImageVector.Builder`, y aquí no hace falta.
- **Componentes:** los mismos que `core/designsystem/component/` de Android (`AtelierButton`, `AtelierTextField`, `AtelierTopBar`, `AtelierChip`, `AtelierBanner`, `AtelierOtpField`, `AtelierLogo`), más `MoneyText` y `PermissionGate`.

---

## 6. Cómo construir un feature (paso a paso)

1. **Dominio:** entidad, value objects, enum de estados y `abstract class` de repositorio.
2. **Infraestructura:** `Api` + DTOs a partir del archivo de API del contexto; `*_table.dart` + `*_dao.dart` si hay caché (registrarlos en `AppDatabase` y correr `build_runner`); `RepositoryImpl` con el patrón offline-first; `setup<Feature>Dependencies()`.
3. **Aplicación:** un `UseCase` por acción, con `execute`.
4. **Presentación:** `UiState`, `ViewModel` (`registerFactory`), `Page` y `components/`; los botones que dependen de permisos leen la `Session`.
5. **Navegación:** `Navigator.push` desde quien la abre; si es pestaña, un `NavigationItem`.
6. **Trazabilidad:** comprobar en [03-traceability.md](03-traceability.md) que cada escenario de la historia tiene su llamada.
7. **Pruebas:** `test/` replica la estructura de `lib/` (§7).

---

## 7. Pruebas

Las mismas que en Android: lógica y estado, sin emulador.

| Qué | Con qué |
| --- | --- |
| DAO y consultas | `AppDatabase(NativeDatabase.memory())` |
| Dos motores sobre el mismo archivo | Dos `AppDatabase(NativeDatabase.createInBackground(file))` |
| `Api` y errores HTTP | `MockClient` de `package:http/testing.dart` |
| Repositorios | `Api` con `MockClient` + Drift en memoria |
| Casos de uso y ViewModels | `mocktail` o repositorios falsos (`InMemory…`) |
| Reloj | `BusinessTime(now: () => DateTime.utc(...))` |

```dart
test('sin red se sigue mostrando la caché', () async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  // … Api con MockClient, TaskRepositoryImpl y MyTasksViewModel
  await Future<void>.delayed(const Duration(milliseconds: 100));
  expect(vm.state.tasks.single.description, 'Frenos');

  online = false;
  await vm.refresh();
  expect(vm.state.tasks.length, 1);
  expect(vm.state.errorMessage, isNull);
});
```

Lo que dependa de un plugin (cámara, GPS, Bluetooth, push, `workmanager`) se prueba en un dispositivo real, y detrás de un contrato de dominio para que el resto sí sea testeable.

---

## 8. Resumen

1. **DIP:** Page → ViewModel → UseCase → `abstract class`; la implementación vive en infraestructura.
2. **`get_it`:** singletons perezosos para servicios y casos de uso; `registerFactory` para ViewModels.
3. **Estado:** `_state` privado, reemplazado con `copyWith`; `notifyListeners()`; `dispose` cancela las suscripciones.
4. **Offline-first:** red → Drift → UI con `watch()`; las escrituras críticas pasan por la cola.
5. **Dos motores:** la UI y el worker solo comparten el archivo de Drift y el almacenamiento: `CrossIsolateLock` y `LocalChangeNotifier` existen por eso.
6. **Seguridad:** la UI se arma con permisos de la sesión; el backend vuelve a validar todo.
7. **Sesión:** `AuthenticatedClient` agrega el token y renueva una sola vez ante 401; si falla, se cierra la sesión y `AppRoot` vuelve al login.
8. **Multiplataforma:** todo lo que dependa de la plataforma va detrás de un contrato. Las diferencias reales entre Android e iOS están en [04-mobile-integration.md](04-mobile-integration.md).
