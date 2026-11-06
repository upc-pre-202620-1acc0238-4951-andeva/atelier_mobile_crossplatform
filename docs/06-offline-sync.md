# Offline y sincronización — modelo local y cola de operaciones

Diseño completo de la persistencia local (**Drift**) y de la sincronización de la app de staff. Las decisiones son las de `atelier-mobile-android`; cambia la implementación, y hay un problema nuevo que Android no tiene (§3, *Dos motores*). Parte del modelo propuesto en el informe (`atelier-report/docs/backend-documentation/atelier-database-schema.md`, sección 9, *Modelo de Datos Local Móvil*) y lo ajusta al backend real después de la versión **1.0.3**.

> Regla de oro: **la app nunca decide reglas de negocio sin red.** Lo que el backend valida con su propio reloj o con stock en vivo se hace solo en línea. Sin red se puede **leer** (caché) y **capturar** hechos que ocurrieron en un momento conocido (marcaciones, lecturas OBD-II, fotos), que se envían después.

---

## 1. Resultado de la revisión del modelo del informe

El informe define 26 tablas locales. Contrastadas con el código actual:

| Tabla del informe | Decisión | Motivo |
| --- | --- | --- |
| `pending_sync_events` | ✅ **Se mantiene** como `pending_operations` (única cola) | Se agregan dueño (`user_id`, `tenant_id`), clave de deduplicación y próximo intento |
| `local_cache_metadata` | ✅ Se mantiene como `cache_metadata` | Sin `version_hash`: el backend no emite ETag ni acepta `since`; la sincronización es **recarga completa por alcance** |
| `auth_session` | 🔁 **Pasa a `SessionManager`** (tokens en `flutter_secure_storage`, el resto en `SharedPreferencesAsync`) | Es un registro único con tokens. Campos ajustados a la respuesta real |
| `local_permissions_cache` | ❌ Se elimina | Los permisos del usuario llegan en la sesión; `GET /permissions` es solo para dueño y administrador |
| `local_customers_cache` | ✅ Se mantiene (`customers`) | Campos ajustados a `CustomerResource` |
| `local_vehicles_cache` | ✅ Se mantiene (`vehicles`) | `brand` y `model` separados; se agregan `year` y `current_mileage` |
| `local_appointments_cache` | ✅ Se mantiene (`appointments`) | El backend devuelve `customerId`/`vehicleId`, no nombres ni placa: se resuelven con las cachés de clientes y vehículos |
| `offline_reception_mutations` | ❌ Se elimina (llegada **en línea**) | `POST /appointments/{id}/arrive` no tiene body y crea la orden de trabajo; repetirlo no es idempotente |
| `local_bays_cache` | ✅ Se mantiene (`bays`) | Enum en mayúsculas (`LIFT`, `AVAILABLE`…) |
| `local_work_orders_cache` | ✅ Se mantiene (`work_orders`) | Sin placa ni cliente embebidos (se resuelven por id); se agregan `subtotal` y `tax_amount` |
| `local_tasks_cache` | ✅ Se mantiene (`tasks`) | Campos de `AssignedTaskResource` + detalle; sin `actual_hours` ni `paused_at` (el backend no los expone) |
| `offline_pit_mutations` | ❌ Se elimina (tareas **en línea**) | Iniciar, pausar y cerrar usan la hora del servidor; la pausa por fin de turno se valida contra el turno en ese instante |
| `offline_pending_evidences` | 🔁 Se mantiene como `pending_uploads` | Subida directa a **Supabase**, sin URL prefirmada; tres destinos (recepción, tarea, propuesta) |
| `local_inventory_cache` | ✅ Se mantiene (`parts`) | Se agrega `unit_of_measure` |
| `local_batches_cache` | ✅ Se mantiene (`batches`) | Se llena solo si el usuario tiene `inventory:batches:read` (dueño, admin, almacén); para el resto queda vacía |
| `local_suppliers_cache` | ❌ Se elimina | Requiere `inventory:suppliers:manage`; ninguna historia móvil lo necesita sin red |
| `offline_inventory_reservations` | ❌ Se elimina (imputación **en línea**) | El backend valida stock (409), que la tarea sea propia y descarga FIFO en ese momento |
| `local_attendance_cache` | ✅ Se mantiene (`attendances`) | Se agregan `worked_minutes`, `regular_minutes`, `overtime_minutes` y el estado del descargo |
| `local_shift_cache` | ✅ Se mantiene (`shifts`) | Se agregan `work_days`, `rest_days`, `is_active` |
| `offline_attendance_mutations` | 🔁 Se integra en `pending_operations` (`CLOCK_IN`, `CLOCK_OUT`) | El backend acepta `clockInTime` (≤ 12 h) y `clockOutTime` desde 1.0.3 |
| `local_voucher_status_cache` | ✅ Se mantiene (`vouchers`) | Ahora existen `paidAmount`, `pendingBalance` y `paymentStatus` |
| `offline_payment_collections` | ❌ Se elimina (cobro **en línea**) | Exige comprobante emitido y referencia de operación, rechaza montos mayores al saldo y marca la orden como pagada; sin idempotencia un reintento duplicaría dinero |
| `local_subscription_cache` | 🔁 **Pasa a la sesión** (`plan` en `SessionManager`) | `GET /billing/subscriptions/me` es solo para dueño y administrador; desde ahora la respuesta de sesión trae `plan` (tier, estado y flags de IoT e IA) para todos los roles |
| `local_plan_features_cache` | ❌ Se elimina | Se cubre con `plan.iotTelemetryEnabled` y `plan.aiDiagnosticsEnabled` de la sesión |
| `local_telemetry_buffer` | ✅ Se mantiene (`telemetry_readings`) | Nombres de `TelemetryReadingItemDto`; `engine_temp_celsius` pasa a **obligatorio**; ruta `POST /iot/telemetry/batch` |
| `local_vehicle_faults_cache` | ✅ Se mantiene (`vehicle_faults`) | Se agregan `is_resolved` y `resolved_at`; ruta `/iot/faults/vehicle/{id}/active` |
| `local_predictive_alerts_cache` | ✅ Se mantiene (`predictive_alerts`) | Sin push de alertas al staff: se refresca por consulta; estados incluyen `DISMISSED` |

### Rutas del informe que cambiaron

| En el informe | En el backend actual |
| --- | --- |
| `POST /api/v1/iam/auth/refresh-token` | `POST /api/v1/auth/refresh` |
| `GET /api/v1/iam/permissions` | Permisos dentro de la respuesta de sesión |
| `GET /api/v1/crm/customers?since=…` | `GET /api/v1/customers?search=&type=&status=` (sin `since`) |
| `GET /api/v1/crm/vehicles/by-plate/{plate}` | `GET /api/v1/vehicles/by-plate/{plate}` |
| `GET /api/v1/crm/appointments?branchId&date` | `GET /api/v1/appointments?branchId=&date=` |
| `GET /api/v1/mro/work-bays?branchId` | `GET /api/v1/work-bays?branchId=` |
| `GET /api/v1/mro/work-orders?status=in_progress` | `GET /api/v1/work-orders?branchId=` (filtrar estado en la app) |
| `GET /api/v1/mro/tasks/assigned` | `GET /api/v1/tasks/my` |
| `POST /api/v1/mro/tasks/{id}/actions` | `POST /tasks/{id}/start`, `/pause`, `/hold`, `/complete` (en línea) |
| `POST …/evidences/presigned-url` + `POST …/evidences` | Subida a Supabase + `POST /tasks/{id}/evidence-images` |
| `POST /api/v1/inventory/items/{id}/allocate` | `POST /api/v1/tasks/{taskId}/products` (en línea) |
| `GET /api/v1/hr/attendance/my-record` | `GET /api/v1/hr/attendances/employee/{membershipId}/history?startDate=&endDate=` y `/status-today` |
| `POST /api/v1/hr/attendance/clock-in` / `clock-out` | `POST /api/v1/hr/attendances/clock-in` / `clock-out` |
| `POST /api/v1/invoicing/payments/offline-sync` | No existe (cobro en línea: `POST /api/v1/invoicing/payments`) |
| `GET /api/v1/billing/subscriptions/tenant-quota` | `plan` en la respuesta de `sign-in` / `refresh` (y `GET /api/v1/billing/subscriptions/me` para dueño y admin) |
| `POST /api/v1/iot/telemetry/ingest/batch` | `POST /api/v1/iot/telemetry/batch` |
| `GET /api/v1/iot/faults/vehicle/{vehicleId}` | `GET /api/v1/iot/faults/vehicle/{vehicleId}/active` |

---

## 2. Qué funciona sin red

| Acción | Sin red | Cómo |
| --- | --- | --- |
| Ver mis tareas, detalle de orden, bahías, catálogo de repuestos, turno, sede, citas del día, clientes y vehículos ya vistos | ✅ Lectura | Cachés Drift (§4). Del detalle de orden, sin red solo la cabecera (`work_orders`) y las fotos y propuestas en cola: tareas, propuestas e imágenes ya enviadas no tienen tabla y requieren red |
| Marcar ingreso / salida (US06–US08) | ✅ Captura y envío diferido | `CLOCK_IN` / `CLOCK_OUT` en la cola, con hora y GPS del dispositivo |
| Leer DTC y telemetría OBD-II (US16–US19) | ✅ Captura y envío diferido | `telemetry_readings` + `REGISTER_FAULT` |
| Fotos de recepción, desmontaje/montaje y propuestas (US13, US14, US28) | ✅ Captura y envío diferido | `pending_uploads` + `ATTACH_*` |
| Enviar descargo de tardanza (US10) | ✅ Envío diferido | `SUBMIT_JUSTIFICATION` |
| Iniciar, pausar, suspender o cerrar tarea (US27, US29, US30) | ❌ En línea | El backend usa su hora y valida el turno |
| Imputar o retirar repuestos (US23, US33) | ❌ En línea | Stock FIFO y reglas de la tarea en vivo |
| Recibir una orden de compra con su comprobante (US34 E2) | ❌ En línea | Crea lotes y cambia el stock; el backend no es idempotente (H15) |
| Abrir orden, llegada de cita, registrar cliente/vehículo (US11, US12, US44) | ❌ En línea | Generan ids y correlativos del servidor |
| Proforma, aprobar propuestas, emitir comprobante, cobrar, pase de salida (US15, US24, US37–US39) | ❌ En línea | Documentos fiscales y dinero |
| Informe de salud con IA (US21) | ❌ En línea | Inferencia en el servidor y cuota mensual |

En las acciones en línea la UI deshabilita el botón sin conexión y muestra "Requiere conexión". No se encolan.

---

## 3. Cola de operaciones (`pending_operations`)

Una sola tabla para todo lo que se captura sin red. Reemplaza `pending_sync_events` y las colas por contexto del informe.

| Columna | Tipo SQLite | Nulo | Descripción |
| --- | --- | --- | --- |
| `id` | TEXT (UUID) PK | no | Identificador local de la operación |
| `type` | TEXT | no | Tipo (tabla de abajo) |
| `payload` | TEXT (JSON) | no | Body exacto a enviar, ya con la hora del dispositivo |
| `dedupe_key` | TEXT | no | Evita encolar dos veces el mismo hecho (p. ej. `CLOCK_IN:{membershipId}:{fecha}`) |
| `user_id` | TEXT | no | Usuario que la capturó |
| `tenant_id` | TEXT | no | Taller de la sesión |
| `status` | TEXT | no | `PENDING`, `SYNCING`, `FAILED` (las exitosas se borran) |
| `attempts` | INTEGER | no | Reintentos realizados |
| `next_attempt_at` | INTEGER (epoch ms) | no | Cuándo puede volver a intentarse (backoff) |
| `last_http_status` | INTEGER | sí | Último código HTTP |
| `last_error_code` | TEXT | sí | `code` del error del backend |
| `last_error_message` | TEXT | sí | `message` del backend, para mostrarlo |
| `created_at` | INTEGER (epoch ms) | no | Momento de la captura en el dispositivo |
| `depends_on` | TEXT | sí | `id` de otra operación que debe completarse antes (p. ej. la subida de la foto) |

Índices: `UNIQUE(dedupe_key)`, `(status, next_attempt_at)`, `(user_id)`.

### Tipos de operación

| `type` | Endpoint | Payload | Idempotencia al reintentar |
| --- | --- | --- | --- |
| `CLOCK_IN` | `POST /hr/attendances/clock-in` | `{ branchId, shiftId, latitude, longitude, clockInTime }` | 409 = ya existe una jornada abierta → **se considera aplicada** |
| `CLOCK_OUT` | `POST /hr/attendances/clock-out` | `{ attendanceId?, clockOutTime }` | 400 ("salida ya registrada" o reloj desajustado) y 404 ("sin jornada abierta" o salida sin ingreso) son ambiguos: se verifican con `history` del día. Si la jornada ya tiene salida → aplicada; si no → FAILED con el `message`. Sin red para verificar → se reintenta |
| `SUBMIT_JUSTIFICATION` | `POST /hr/attendances/{attendanceId}/justification` | `{ attendanceId, reason }` (el id va en la ruta; el body es `{ reason }`) | 422 "ya justificada" → aplicada |
| `UPLOAD_FILE` | `POST {SUPABASE_URL}/storage/v1/object/atelier/{ruta}` | archivo de `pending_uploads` | Misma ruta = mismo objeto (usar `x-upsert: true`) |
| `ATTACH_INTAKE_IMAGE` | `POST /work-orders/{id}/intake-images` | `{ imageUrl, description }` | ✅ Misma `imageUrl` en la orden → devuelve la imagen ya guardada (R4) |
| `ATTACH_TASK_EVIDENCE` | `POST /tasks/{id}/evidence-images` | `{ imageUrl, description }` | ✅ Misma `imageUrl` en la tarea → devuelve la evidencia ya guardada (R4) |
| `SUBMIT_PROPOSAL` | `POST /work-orders/{id}/proposals` | `{ mechanicId, description, severity, imageUrl, suggestedServiceId? }` | ✅ Misma `imageUrl` en la orden → devuelve la propuesta ya registrada (R4) |
| `TELEMETRY_BATCH` | `POST /iot/telemetry/batch` | `{ vehicleId, readings[] }` (hasta 200) | ✅ El backend ignora lecturas repetidas (mismo vehículo y `timestamp`) |
| `REGISTER_FAULT` | `POST /iot/faults` | `{ vehicleId, dtcCode, severity, description }` | ✅ Si el vehículo ya tiene ese DTC activo, devuelve esa falla (R3) |
| `RESOLVE_FAULT` | `POST /iot/faults/{id}/resolve` | `{}` | ✅ Resolver dos veces devuelve 200 |

`ATTACH_*` y `SUBMIT_PROPOSAL` dependen (`depends_on`) de su `UPLOAD_FILE`: el worker no los envía hasta que la subida termine. La URL pública es determinista (`{SUPABASE_URL}/storage/v1/object/public/{bucket}/{storage_path}`, `SupabaseUploader.publicUrlFor`), así que el payload de `ATTACH_*` se arma con la URL final **al capturar** y no hay que reescribirlo después. Si `UPLOAD_FILE` queda `FAILED`, sus dependientes pasan a `FAILED` con el mismo mensaje.

### Cómo registra cada feature su tipo

El núcleo no conoce endpoints de features. Cada feature implementa `OperationHandler` (`core/data/sync/operation_handler.dart`) y lo registra en `get_it`. Android usa `@IntoMap`; aquí es un registro explícito:

```dart
// features/attendance/infrastructure/di/attendance_dependencies.dart
getIt<OperationHandlerRegistry>().register(
  'CLOCK_IN',
  () => ClockInHandler(api: getIt<AttendanceApi>()),
);

// features/attendance/infrastructure/sync/clock_in_handler.dart
class ClockInHandler implements OperationHandler {
  final AttendanceApi api;

  const new({required this.api});

  @override
  Future<OperationResult> send(PendingOperationEntity operation) {
    final body = ClockInRequestDto.fromJson(jsonDecode(operation.payload));
    return OperationResult.from(
      () => api.clockIn(body),
      alreadyApplied: (e) => e.httpStatus == 409, // 409 = ya existe la jornada → aplicada
    );
  }
}
```

`OperationResult.from` aplica la tabla de respuestas del algoritmo (2xx → `Applied`, 401 → `Unauthorized`, 5xx/408/429/`NetworkException` → `Retry`, otro 4xx → `Failed`). Cada handler solo indica qué errores cuentan como "ya aplicada". Para encolar se usa `PendingOperationQueue.enqueue(type, payload, dedupeKey, dependsOn)`, que completa `user_id`/`tenant_id` desde la sesión y dispara el sync. Un `type` sin handler registrado queda `PENDING` (no se pierde).

La cola no decide por sí sola: `enqueue` usa `InsertMode.insertOrIgnore` y devuelve `false` si el `dedupe_key` ya existe.

```dart
// core/data/sync/pending_operation_dao.dart
part 'pending_operation_dao.g.dart';

@DriftAccessor(tables: [PendingOperations])
class PendingOperationDao extends DatabaseAccessor<AppDatabase>
    with _$PendingOperationDaoMixin {
  PendingOperationDao(super.attachedDatabase);

  /// Respeta `dedupe_key`: devuelve false si el hecho ya estaba en la cola.
  Future<bool> enqueue(PendingOperationsCompanion operation) async {
    final inserted = await into(pendingOperations).insertReturningOrNull(
      operation,
      mode: InsertMode.insertOrIgnore,
    );
    return inserted != null;
  }

  Future<List<PendingOperationEntity>> nextBatch(String userId, int now) {
    return (select(pendingOperations)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals('PENDING') &
                t.nextAttemptAt.isSmallerOrEqualValue(now),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<int> watchPendingCount(String userId) {
    final count = pendingOperations.id.count();
    final query = selectOnly(pendingOperations)
      ..addColumns([count])
      ..where(
        pendingOperations.userId.equals(userId) &
            pendingOperations.status.isIn(['PENDING', 'FAILED']),
      );
    return query.map((row) => row.read(count)!).watchSingle();
  }
}
```

### Dos motores: lo que Android no tiene

En Android, el `SyncWorker` y la UI viven en el mismo proceso y comparten memoria: un solo `AppDatabase`, un solo `TokenRefresher`, y Room avisa a todos. En Flutter, `workmanager` arranca **otro motor de Flutter**, con otro `getIt` y otras instancias.

`shareAcrossIsolates` de Drift no lo resuelve: solo funciona dentro de un mismo motor. Por eso la UI y el worker abren el archivo por separado, y aparecen cuatro problemas:

| Problema | Qué pasaría | Solución |
| --- | --- | --- |
| **Dos escritores en el archivo** | `database is locked` | `busy_timeout = 5000` y `journal_mode = WAL` al abrir la conexión, antes de migrar ([05](05-flutter-architecture.md) §5.3) |
| **Dos refresh a la vez** | El segundo usa un `refreshToken` ya rotado, recibe 401 y **cierra la sesión** | `CrossIsolateLock` alrededor del refresh ([05](05-flutter-architecture.md) §5.3) |
| **Dos sincronizaciones a la vez** | Una devolvería a `PENDING` lo que la otra está enviando, y se duplicarían envíos | `CrossIsolateLock.sync`: quien no lo consigue termina sin hacer nada |
| **Los `watch()` no se enteran** | La UI abierta no ve lo que escribió el worker | `LocalChangeNotifier`: el worker avisa a la UI, que llama a `notifyExternalChanges()`. Además, se llama al volver a primer plano |

El bloqueo vive en una tabla propia (`app_locks`, §5). Es una sola sentencia SQL, así que dos conexiones no pueden ganar a la vez, y tiene **vencimiento** porque iOS puede matar al worker sin aviso y sin que se libere:

```dart
// core/data/local/cross_isolate_lock.dart
class CrossIsolateLock {
  static const tokenRefresh = 'token_refresh';
  static const sync = 'sync';

  final AppDatabase database;
  final String owner;

  CrossIsolateLock({required this.database}) : owner = const Uuid().v4();

  /// Una sola sentencia atómica: dos conexiones no pueden ganar a la vez.
  Future<bool> tryAcquire(String name, Duration lease) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.customStatement(
      'INSERT INTO app_locks (name, owner, expires_at) VALUES (?, ?, ?) '
      'ON CONFLICT (name) DO UPDATE SET owner = excluded.owner, '
      'expires_at = excluded.expires_at '
      'WHERE app_locks.expires_at < ? OR app_locks.owner = excluded.owner',
      [name, owner, now + lease.inMilliseconds, now],
    );
    final row = await (database.select(
      database.appLocks,
    )..where((t) => t.name.equals(name))).getSingleOrNull(); // Otro pudo liberarlo entre las dos.
    return row?.owner == owner;
  }

  Future<void> release(String name) async {
    await (database.delete(
      database.appLocks,
    )..where((t) => t.name.equals(name) & t.owner.equals(owner))).go();
  }
}
```

Volver a llamar a `tryAcquire` con el mismo dueño **renueva** el vencimiento: `SyncProcessor` lo hace antes de cada operación y cada 30 s mientras envía. Por eso el lease sigue en 2 min aunque una operación pueda tardar 3 (intento, refresh y reintento): si el sistema mata al motor, el otro no queda bloqueado mucho tiempo.

Como el mismo dueño renueva, el bloqueo **no excluye dentro de un motor**. Dos disparadores en la UI (encolar y volver la red) ganarían los dos, y el segundo devolvería a `PENDING` lo que el primero envía. Por eso `SyncProcessor.run()` es de un solo vuelo: comparte el `Future` en curso y, si llegó otra petición, da una vuelta más.

El aviso a la UI usa `IsolateNameServer`, que es de todo el proceso y sí cruza motores. Si la app está cerrada no hay nadie escuchando, y no pasa nada:

```dart
// core/data/sync/local_change_notifier.dart
class LocalChangeNotifier {
  static const _portName = 'atelier_ui_port';

  /// Se llama en `main()`, en el motor de la UI.
  static void listenInUi(AppDatabase database, SessionManager session) {
    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);
    port.listen((_) => refresh(database, session));
  }

  /// Lo que otro motor pudo cambiar: filas y sesión. También se llama al volver a primer plano.
  static void refresh(AppDatabase database, SessionManager session) {
    database.notifyExternalChanges();
    session.reload();
  }

  /// Se llama en el worker al terminar, también si falló.
  static void notifyUi() {
    IsolateNameServer.lookupPortByName(_portName)?.send(null);
  }
}
```

Avisar solo a Drift no basta: si el worker borra la sesión (refresh 401), `AppRoot` debe enterarse para volver al login.

### Algoritmo de `SyncProcessor`

`SyncProcessor` no conoce Flutter ni `workmanager`, así se puede probar con Drift en memoria. Corre en dos lugares:

```text
Primer plano (motor de la UI): al abrir, al encolar, al recuperar red, al volver a la app.
Segundo plano (workmanager):   con red, cuando el sistema lo permita.

1. Si no hay sesión → terminar (las operaciones quedan PENDING).
2. tryAcquire(sync, 2 min). Si no se consigue, otro motor está sincronizando → terminar.
3. Renovar el token si venció (ensureFresh). Devolver a PENDING lo que quedó en SYNCING (solo quien tiene el bloqueo puede hacerlo).
4. Tomar operaciones PENDING del usuario actual con next_attempt_at <= ahora, ordenadas por created_at.
   Saltar las que tienen depends_on sin completar.
5. Por cada una: comprobar que el usuario no cambió (si cambió, terminar) → renovar el bloqueo →
   releer la fila (la UI pudo descartarla) → marcar SYNCING → llamar al endpoint → según la respuesta:
     2xx                         → borrar la operación (y su archivo local si era la última que lo usa)
     409/400/404/422 "ya aplicada" (tabla de tipos) → borrar
     401                         → AuthenticatedClient renueva; si falla, PENDING y detener
     otro 4xx (regla de negocio) → FAILED con code y message (no se reintenta solo)
     5xx, timeout, sin red       → PENDING, attempts+1, next_attempt_at = ahora + min(2^attempts, 60) min
     error inesperado del handler → igual que 5xx: un payload dañado no debe bloquear la cola
6. Si attempts llega a 8 → FAILED ("No se pudo sincronizar").
7. Al terminar: liberar el bloqueo, refrescar las cachés afectadas, reprogramar el worker para el próximo
   intento FUTURO (nextAttemptAfter; contar los ya vencidos lo reprogramaría en bucle) y avisar a la UI.
```

### Worker y disparadores

```dart
// core/data/sync/sync_worker.dart
/// Punto de entrada del worker: otro motor, otro `getIt`, otra conexión a Drift.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    setupDependencies();
    return runSyncTask();
  });
}

/// Corre la cola una vez y deja el motor limpio. Requiere `setupDependencies()`.
Future<bool> runSyncTask() async {
  try {
    // iOS corta a los ~30 s sin avisar (H42): se procesa lo que alcance en menos de eso.
    await getIt<SyncProcessor>().run(
      budget: Platform.isIOS ? const Duration(seconds: 25) : null,
    );
    return true;
  } on Exception catch (e) {
    debugPrint('Sync falló: $e');
    return false;
  } finally {
    LocalChangeNotifier.notifyUi();
    await getIt<AppDatabase>().close(); // Si no, el motor deja el archivo abierto.
    await getIt.reset();
  }
}
```

`main()` llama a `Workmanager().initialize(callbackDispatcher)` antes de programar nada. `SyncScheduler` (`lib/core/data/sync/sync_scheduler.dart`) ofrece `requestSync` (trabajo único con red), `requestSyncAt` (reintento con `initialDelay`, con su propio nombre para no bloquear un envío inmediato) y `schedulePeriodic` (15 min).

> **iOS, sin comprobar:** `workmanager_apple` 0.9.11 usa el `uniqueName` del periódico como id de `BGTaskScheduler`. Por eso `periodicName` es `atelier.sync`, el mismo `taskName` permitido en `Info.plist`; con otro nombre fallaría.

| Disparador | Android | iOS |
| --- | --- | --- |
| Al abrir, al encolar, al recuperar red y al volver a primer plano (`SyncTriggers`, con `ConnectivityObserver` y `AppLifecycleListener`) | ✅ `SyncProcessor` directo en la UI | ✅ Igual |
| Trabajo único con restricción de red | ✅ WorkManager | ⚠️ `BGTaskScheduler`: iOS decide cuándo, y lo corta a los ~30 s |
| Periódico cada 15 min | ✅ WorkManager | ⚠️ Solo una pista: puede tardar horas o no ocurrir |
| Reintento tras el backoff | ✅ `requestSyncAt` | ⚠️ Hay que programarlo a mano, sin garantía |

**Regla:** la app nunca debe depender del segundo plano para funcionar. Es una mejora; lo seguro es enviar con la app abierta. Por lo mismo, `SyncProcessor` debe procesar poco en cada vuelta y dejar todo consistente en cualquier momento: iOS no avisa antes de cortar (H42 de [03](03-traceability.md#huecos-abiertos)).

### Reglas de producto

- **Mostrar siempre lo pendiente.** Un ícono en la barra superior con el número de operaciones `PENDING`/`FAILED` y una pantalla "Pendientes de sincronizar" con el `message` del backend y las acciones *Reintentar* y *Descartar*.
- **Cambio de usuario.** La cola es por `user_id`: al cerrar sesión con operaciones pendientes, avisar ("Tienes 3 marcaciones sin enviar"). Si se confirma, se conservan y se envían cuando ese mismo usuario vuelva a entrar. Nunca se envían con el token de otro usuario.
- **Sesión vencida sin red.** Si el refresh token (30 días) vence con operaciones pendientes, tras entrar, se envían. El login no muestra un aviso: sin sesión ya no se sabe de quién son y `GetPendingOperationCountUseCase` devuelve 0, igual que en Android.
- **Hora del dispositivo.** Se guarda en UTC (`Instant`) al capturar. Si el reloj del teléfono está desajustado más de 2 min hacia el futuro, el backend rechaza la marcación (400): mostrar "Revisa la hora de tu teléfono".
- **Marcaciones viejas.** Una marcación de ingreso con más de 12 h no se acepta (400): el colaborador debe enviar un descargo.

---

## 4. Cachés de lectura

Estrategia única: **red → Drift → UI** (patrón offline-first del curso). Cada repositorio intenta la red, reemplaza las filas de su **alcance** y la UI observa Drift con `Stream` (`.watch()`). Como el backend no soporta deltas, se recarga el alcance completo; `cache_metadata` guarda cuándo.

### `cache_metadata`

| Columna | Tipo | Descripción |
| --- | --- | --- |
| `scope` | TEXT PK | Alcance cacheado, p. ej. `tasks:my`, `bays:{branchId}`, `appointments:{branchId}:{fecha}` |
| `last_synced_at` | INTEGER (epoch ms) | Última recarga exitosa |
| `record_count` | INTEGER | Filas del alcance |

La UI muestra "Actualizado hace N min" cuando la caché tiene más de 5 min y no hay red.

### Tablas y vigencia

| Tabla | Fuente | Alcance y vigencia | Quién la usa |
| --- | --- | --- | --- |
| `branches` | `GET /branches` | Todo el taller · 24 h | Todos (geocerca) |
| `shifts` | `GET /hr/work-shifts/{id}` (mi turno) o `GET /hr/work-shifts` | Mi turno · 24 h | Todos |
| `attendances` | `GET /hr/attendances/employee/{membershipId}/history?startDate=&endDate=` + `/status-today` | Últimos 30 días · al abrir Asistencia | Todos |
| `tasks` | `GET /tasks/my` (+ `GET /tasks/{id}` al abrir) | Mis tareas abiertas · al abrir y tras cada acción | Mecánico, jefe |
| `work_orders` | `GET /work-orders?branchId=` y `GET /work-orders/{id}` | Órdenes no cerradas de la sede · 5 min | Asesor, jefe, admin |
| `bays` | `GET /work-bays?branchId=` | Sede · 30 s con pantalla visible | Jefe, admin |
| `parts` | `GET /inventory/items?page=&size=100`, página por página hasta recibir menos de 100 (el backend pagina en memoria y no da el total) | Catálogo · 1 h | Mecánico, almacén |
| `batches` | `GET /inventory/items/{id}/batches` (todos los lotes, también agotados; la app los ordena FIFO por `arrival_date`) | Por repuesto consultado · 1 h | Almacén, admin |
| `customers` | `GET /customers?search=` y `GET /customers/{id}` | Clientes vistos o buscados · 7 días | Recepción, asesor |
| `vehicles` | `GET /vehicles/by-plate/{plate}`, `GET /vehicles/{id}` | Vehículos vistos · 7 días | Recepción, mecánico |
| `appointments` | `GET /appointments?branchId=&date=` | Hoy y mañana · 5 min | Recepción, asesor |
| `vouchers` | `GET /invoicing/vouchers/work-order/{workOrderId}` | Por orden consultada · al abrir | Caja, asesor |
| `vehicle_faults` | `GET /iot/faults/vehicle/{id}/active` | Por vehículo en diagnóstico · al abrir | Mecánico |
| `predictive_alerts` | `GET /iot/alerts/vehicle/{id}` | Por vehículo · al abrir | Mecánico, jefe |

Al cerrar sesión se borran **todas** las cachés (son datos del taller) y se conserva solo la cola del usuario si eligió guardarla.

---

## 5. Esquema Drift

Convención, la misma de Android: tablas y columnas en `snake_case`, ids como `String` (UUID), instantes como entero (epoch ms UTC), fechas `LocalDate` como `String` ISO, dinero como `String` decimal (evita errores de `double`; se convierte a `Decimal` en el dominio). Todos los enums se guardan como el `String` del backend.

Dart usa `camelCase` y Drift lo convierte solo a `snake_case`; `.named()` aparece solo cuando el nombre de la columna no coincide. No se usa `DateTimeColumn`: guardar epoch ms deja el mismo esquema que Android.

> Tablas generadas automáticamente desde las Entities de Android, y compiladas con `build_runner`. El esquema queda igual, con una sola diferencia: `app_locks`.

```dart
// core/data/sync/pending_operation_table.dart
import 'package:drift/drift.dart';

@DataClassName('PendingOperationEntity')
@TableIndex(name: 'idx_pending_operations_dedupe_key', columns: {#dedupeKey}, unique: true)
@TableIndex(name: 'idx_pending_operations_status_next_attempt_at', columns: {#status, #nextAttemptAt})
@TableIndex(name: 'idx_pending_operations_user_id', columns: {#userId})
class PendingOperations extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get payload => text()();
  TextColumn get dedupeKey => text()();
  TextColumn get userId => text()();
  TextColumn get tenantId => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAt => integer()();
  IntColumn get lastHttpStatus => integer().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastErrorMessage => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get dependsOn => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// core/data/sync/pending_upload_table.dart
import 'package:drift/drift.dart';

@DataClassName('PendingUploadEntity')
class PendingUploads extends Table {
  TextColumn get id => text()();
  TextColumn get localFilePath => text()();  // pending/{id}.jpg, relativa a la carpeta de soporte de la app
  TextColumn get storagePath => text()();  // {tenantId}/work-orders/{woId}/tasks/{taskId}/{id}.jpg
  TextColumn get target => text()();  // INTAKE | TASK_EVIDENCE | PROPOSAL
  TextColumn get publicUrl => text().nullable()();  // se llena al subir
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// core/data/sync/cache_metadata_table.dart
import 'package:drift/drift.dart';

@DataClassName('CacheMetadataEntity')
class CacheMetadata extends Table {
  TextColumn get scope => text()();
  IntColumn get lastSyncedAt => integer()();
  IntColumn get recordCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {scope};
}
```

```dart
// features/attendance/infrastructure/local/attendance_table.dart
import 'package:drift/drift.dart';

@DataClassName('AttendanceEntity')
@TableIndex(name: 'idx_attendances_membership_id_clock_in', columns: {#membershipId, #clockIn})
class Attendances extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get membershipId => text()();
  TextColumn get shiftId => text()();
  IntColumn get clockIn => integer()();
  IntColumn get clockOut => integer().nullable()();
  TextColumn get status => text()();  // ON_TIME | LATE | EXCUSED | ABSENT
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get distanceToBranchMeters => real().named('distance_to_branch_m')();
  IntColumn get workedMinutes => integer().nullable()();
  IntColumn get regularMinutes => integer().nullable()();
  IntColumn get overtimeMinutes => integer().nullable()();
  TextColumn get justificationReason => text().nullable()();
  TextColumn get justificationStatus => text().nullable()();  // PENDING | APPROVED | REJECTED
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/attendance/infrastructure/local/shift_table.dart
import 'package:drift/drift.dart';

@DataClassName('ShiftEntity')
class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get startTime => text()();  // "08:00:00" hora de Lima
  TextColumn get endTime => text()();
  IntColumn get gracePeriodMinutes => integer()();
  TextColumn get workDays => text()();  // "MONDAY,TUESDAY,…"
  TextColumn get restDays => text()();
  BoolColumn get isActive => boolean()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/attendance/infrastructure/local/branch_table.dart
import 'package:drift/drift.dart';

@DataClassName('BranchEntity')
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get geofenceRadiusMeters => real().named('geofence_radius_m')();
  BoolColumn get isActive => boolean()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/tasks/infrastructure/local/task_table.dart
import 'package:drift/drift.dart';

@DataClassName('TaskEntity')
@TableIndex(name: 'idx_tasks_work_order_id', columns: {#workOrderId})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text()();
  IntColumn get workOrderNumber => integer().nullable()();
  TextColumn get workOrderStatus => text().nullable()();
  TextColumn get vehicleId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get bayId => text().nullable()();
  TextColumn get serviceName => text().nullable()();  // del detalle
  TextColumn get mechanicId => text().nullable()();
  TextColumn get status => text()();  // ASSIGNED | IN_PROGRESS | ON_HOLD | COMPLETED | …
  TextColumn get description => text()();
  TextColumn get estimatedHours => text().nullable()();
  TextColumn get holdReason => text().nullable()();  // BREAK | END_OF_SHIFT | DEFECTIVE_PART | …
  TextColumn get missingItemDescription => text().nullable()();
  TextColumn get pendingSuspensionReason => text().nullable()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get totalPausedSeconds => integer()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/workorders/infrastructure/local/work_order_table.dart
import 'package:drift/drift.dart';

@DataClassName('WorkOrderEntity')
@TableIndex(name: 'idx_work_orders_branch_id_status', columns: {#branchId, #status})
class WorkOrders extends Table {
  TextColumn get id => text()();
  IntColumn get internalNumber => integer().nullable()();
  TextColumn get branchId => text()();
  TextColumn get vehicleId => text()();  // placa y modelo: tabla vehicles
  TextColumn get customerId => text()();  // nombre: tabla customers
  TextColumn get currentBayId => text().nullable()();
  TextColumn get bayName => text().nullable()();
  TextColumn get status => text()();  // DRAFT | IN_PROGRESS | COMPLETED | PAID | CANCELED
  TextColumn get diagnosticSummary => text().nullable()();
  IntColumn get mileageIn => integer().nullable()();
  TextColumn get subtotal => text().nullable()();
  TextColumn get taxAmount => text().nullable()();
  TextColumn get totalAmount => text()();
  TextColumn get currency => text()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/bays/infrastructure/local/bay_table.dart
import 'package:drift/drift.dart';

@DataClassName('BayEntity')
@TableIndex(name: 'idx_bays_branch_id', columns: {#branchId})
class Bays extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get name => text()();
  TextColumn get bayType => text()();  // LIFT | PAINT_BOOTH | WASHING | ALIGNMENT
  TextColumn get status => text()();  // AVAILABLE | OCCUPIED | MAINTENANCE
  TextColumn get currentWorkOrderId => text().nullable()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/reception/infrastructure/local/customer_table.dart
import 'package:drift/drift.dart';

@DataClassName('CustomerEntity')
@TableIndex(name: 'idx_customers_tax_id', columns: {#taxId})
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();  // INDIVIDUAL | COMPANY
  TextColumn get displayName => text()();
  TextColumn get taxId => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get status => text()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/reception/infrastructure/local/vehicle_table.dart
import 'package:drift/drift.dart';

@DataClassName('VehicleEntity')
@TableIndex(name: 'idx_vehicles_plate', columns: {#plate}, unique: true)
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get plate => text()();
  TextColumn get vin => text().nullable()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  IntColumn get year => integer().nullable()();
  TextColumn get engineType => text().nullable()();
  TextColumn get currentOwnerId => text().nullable()();
  IntColumn get currentMileage => integer().nullable()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/reception/infrastructure/local/appointment_table.dart
import 'package:drift/drift.dart';

@DataClassName('AppointmentEntity')
@TableIndex(name: 'idx_appointments_branch_id_scheduled_at', columns: {#branchId, #scheduledAt})
class Appointments extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get customerId => text()();
  TextColumn get vehicleId => text()();
  IntColumn get scheduledAt => integer()();
  IntColumn get estimatedDurationMinutes => integer().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get status => text()();  // PENDING | CONFIRMED | ARRIVED | CANCELED
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/inventory/infrastructure/local/part_table.dart
import 'package:drift/drift.dart';

@DataClassName('PartEntity')
@TableIndex(name: 'idx_parts_sku', columns: {#sku})
@TableIndex(name: 'idx_parts_category', columns: {#category})
class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get category => text()();
  TextColumn get basePrice => text()();
  TextColumn get totalStock => text()();
  TextColumn get minimumStock => text()();
  TextColumn get unitOfMeasure => text()();
  TextColumn get status => text()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/inventory/infrastructure/local/batch_table.dart
import 'package:drift/drift.dart';

@DataClassName('BatchEntity')
@TableIndex(name: 'idx_batches_item_id', columns: {#itemId})
class Batches extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get batchNumber => text()();
  TextColumn get remainingQty => text()();
  TextColumn get unitCost => text()();
  IntColumn get arrivalDate => integer()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/cashier/infrastructure/local/voucher_table.dart
import 'package:drift/drift.dart';

@DataClassName('VoucherEntity')
@TableIndex(name: 'idx_vouchers_work_order_id', columns: {#workOrderId})
class Vouchers extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text().nullable()();
  TextColumn get voucherType => text()();  // 01 FACTURA | 03 BOLETA | 07 NOTA_CREDITO
  TextColumn get serie => text()();
  IntColumn get number => integer()();
  TextColumn get totalAmount => text()();
  TextColumn get paidAmount => text()();
  TextColumn get pendingBalance => text()();
  TextColumn get paymentStatus => text()();  // PENDING | PARTIAL | PAID
  TextColumn get status => text()();  // DRAFT | ISSUED | ACCEPTED_SUNAT | REJECTED_SUNAT | VOIDED
  TextColumn get pdfUrl => text().nullable()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/diagnostics/infrastructure/local/telemetry_reading_table.dart
import 'package:drift/drift.dart';

@DataClassName('TelemetryReadingEntity')
@TableIndex(name: 'idx_telemetry_readings_vehicle_id_timestamp', columns: {#vehicleId, #timestamp}, unique: true)
class TelemetryReadings extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  IntColumn get timestamp => integer()();  // momento de la lectura (UTC)
  RealColumn get engineTempCelsius => real()();  // obligatorio en el backend
  IntColumn get engineRpm => integer().nullable()();
  IntColumn get speedKmh => integer().nullable()();
  RealColumn get batteryVoltage => real().nullable()();
  RealColumn get fuelPercentage => real().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get batchOperationId => text().nullable()();  // id del TELEMETRY_BATCH que la lleva

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/diagnostics/infrastructure/local/vehicle_fault_table.dart
import 'package:drift/drift.dart';

@DataClassName('VehicleFaultEntity')
@TableIndex(name: 'idx_vehicle_faults_vehicle_id_dtc_code', columns: {#vehicleId, #dtcCode})
class VehicleFaults extends Table {
  TextColumn get id => text()();  // id del backend, o "local-{uuid}" si aún no se envió
  TextColumn get vehicleId => text()();
  TextColumn get dtcCode => text()();
  TextColumn get severity => text()();  // LOW | MEDIUM | CRITICAL
  TextColumn get description => text()();
  IntColumn get detectedAt => integer()();
  BoolColumn get isResolved => boolean()();
  IntColumn get resolvedAt => integer().nullable()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

```dart
// features/diagnostics/infrastructure/local/predictive_alert_table.dart
import 'package:drift/drift.dart';

@DataClassName('PredictiveAlertEntity')
@TableIndex(name: 'idx_predictive_alerts_vehicle_id_created_at', columns: {#vehicleId, #createdAt})
class PredictiveAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  TextColumn get alertType => text()();  // ENGINE_OVERHEATING_RISK | BATTERY_FAILURE_RISK | …
  RealColumn get confidenceScore => real()();
  TextColumn get message => text()();
  TextColumn get status => text()();  // DISPATCHED | ACKNOWLEDGED | RESOLVED | DISMISSED
  IntColumn get createdAt => integer()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

Tabla propia de Flutter (§3, *Dos motores*). **No se borra** al cerrar sesión:

```dart
// core/data/local/app_lock_table.dart
import 'package:drift/drift.dart';

@DataClassName('AppLockEntity')
class AppLocks extends Table {
  TextColumn get name => text()();
  TextColumn get owner => text()();
  IntColumn get expiresAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
```

La base completa está en [05](05-flutter-architecture.md) §5.3. `make-migrations` reemplaza a `exportSchema = true`: versiona el esquema para escribir migraciones cuando cambie el backend.

### Sesión (`SessionManager`)

Reemplaza `auth_session` del informe. `token` y `refresh_token` van en `flutter_secure_storage`; el resto, en `SharedPreferencesAsync` (sin caché en memoria, porque hay dos motores). Claves:

| Clave | Origen | Nota |
| --- | --- | --- |
| `token`, `refresh_token` | `AuthenticatedUserResource` | El refresh rota en cada renovación |
| `token_expires_at` | claim `exp` del JWT | Para renovar antes de vencer |
| `user_id`, `email`, `full_name` | sesión | |
| `tenant_id`, `tenant_name` | `activeTenant` | |
| `membership_id` | sesión | Lo piden los endpoints propios de HR |
| `permissions` | sesión (`List<String>`, convertida a `Set`) | Incluye `ROLE_*` |
| `branch_id`, `shift_id` | `GET /hr/employees/membership/{membershipId}` | Sede y turno asignados |
| `selected_branch_id`, `branch_choice_pending` | Elección de sede (H33) | Sede elegida a mano y marca para ofrecerla. La sede asignada siempre las reemplaza |
| `plan_tier`, `plan_status`, `plan_access_granted`, `iot_telemetry_enabled`, `ai_diagnostics_enabled` | `plan` de la sesión | Ocultar diagnóstico OBD-II e informe IA si el plan no los incluye; aviso si `accessGranted` es falso. Se actualiza en cada `refresh` |

No se guarda avatar (el backend no lo tiene) ni el radio de geocerca (está en `branches`).

---

## 6. Flujos offline por historia

### US06–US08 — Marcación sin cobertura

```text
Tocar "Marcar ingreso"
 → Geolocator: ubicación fresca (alta precisión). Sin fix → bloquear y pedir activar la ubicación
 → Calcular distancia con branches; si está fuera, avisar (el backend decide igual)
 → Con red: POST /hr/attendances/clock-in directo
 → Sin red: encolar CLOCK_IN { branchId, shiftId, latitude, longitude, clockInTime = ahora }
            dedupe_key = CLOCK_IN:{membershipId}:{fecha Lima}
            UI: "Marcación guardada · se enviará al recuperar señal"
 → Al sincronizar: 201 → refrescar attendances; 422 fuera de geocerca → FAILED con la distancia; 409 → ya marcada
```

La salida igual, con `CLOCK_OUT { clockOutTime }`. Si el ingreso de ese día aún está en cola, la salida se encola con `depends_on` = id del ingreso.

### US13, US14, US28 — Fotos sin señal

```text
image_picker → comprimir (JPEG 1600 px, 80 %) → guardar en getApplicationSupportDirectory()/pending/{uuid}.jpg
 → pending_uploads { storage_path = {tenantId}/work-orders/{woId}/{intake|tasks/{taskId}|proposals}/{uuid}.jpg }
 → pending_operations UPLOAD_FILE { uploadId } + ATTACH_… { imageUrl = publicUrlFor(storage_path) } (depends_on = UPLOAD_FILE)
 → La galería de la tarea muestra la foto local con un ícono de "pendiente"
 → Al subir: la foto ya está en Supabase → se borran la fila de pending_uploads y el archivo local; luego se envía ATTACH_…
```

- **El sync se dispara después de encolar las dos** (`dispatch: false` en la primera). Si `UPLOAD_FILE` fallara antes de existir `ATTACH_…`, la cascada no la vería y quedaría esperando para siempre a un padre en `FAILED`.
- **Primero se borra la fila:** un corte entre ambos borrados deja un archivo huérfano. Al revés, el reintento no encontraría el archivo y fallaría una foto que sí se subió.
- Un 401 de Supabase es de la anon key, no de la sesión: la operación pasa a `FAILED` y la cola sigue.

La propuesta adicional (US14) puede **capturarse** sin red, pero su envío y la notificación al cliente ocurren al sincronizar.

### US16–US19 — OBD-II en foso

```text
Lecturas en vivo → telemetry_readings (una fila por muestra, unique vehicle_id + timestamp)
 → Cada 200 lecturas o al cerrar la sesión de diagnóstico: crear TELEMETRY_BATCH con esas filas
 → DTC leídos (modo 03) → vehicle_faults con id "local-{uuid}" + REGISTER_FAULT
      dedupe_key = FAULT:{vehicleId}:{dtcCode}:{sessionId}   (un mismo código no se encola dos veces por sesión)
 → Al confirmar REGISTER_FAULT: reemplazar la fila local por la del backend (id real)
 → Borrado de fallas (modo 04) sin red: RESOLVE_FAULT solo para fallas con id real; las locales se descartan
```

Las lecturas confirmadas se borran a los 7 días (la app no es el histórico; el backend sí).

---

## 7. Requisitos del backend para que la cola sea segura

| # | Cambio | Para qué | Estado |
| --- | --- | --- | --- |
| R1 | `clockInTime` en el ingreso | Marcación de ingreso sin red (US06) | ✅ 1.0.3 |
| R2 | Ignorar lecturas de telemetría repetidas | Reintentos de lotes | ✅ Ya existía |
| R3 | `POST /iot/faults`: si el vehículo ya tiene una falla **activa** con el mismo DTC, devolver esa en vez de crear otra | Reintentar `REGISTER_FAULT` o volver a escanear sin duplicar fallas | ✅ 1.1.0 |
| R4 | `intake-images`, `evidence-images` y `proposals`: si ya existe un registro con la misma `imageUrl` en esa orden o tarea, devolverlo | Reintentar `ATTACH_*` sin fotos ni propuestas duplicadas | ✅ 1.1.0 |

Con R3 y R4, todas las operaciones de la cola se pueden reintentar sin duplicar registros. La ruta de cada foto debe llevar un UUID generado al capturarla (§3): dos fotos distintas nunca comparten URL, y el reintento de la misma siempre la repite.

> R3 y R4 se publicaron en `atelier-platform` 1.1.0 (commit `cdcdc6f`) y siguen en 1.2.0. El reintento devuelve el registro ya guardado y no emite un segundo evento ni push.

---

## 8. Checklist para implementar

1. `AppDatabase` con las tablas del §5, `WAL`, `busy_timeout` y `build.yaml`. `make-migrations` para guardar el esquema inicial.
2. `SessionManager` con las claves del §5, `clearIfReinstalled()` al arrancar y `first_unlock` en el Keychain.
3. `PendingOperationDao` con `enqueue` (respeta `dedupe_key`), `nextBatch(userId, now)`, `markFailed`, `delete`, y un `Stream<int>` de pendientes para la UI.
4. `CrossIsolateLock` en `TokenRefresher` y en `SyncProcessor`.
5. `SyncProcessor` con el algoritmo del §3, `callbackDispatcher` y un `SyncScheduler` que lo dispare (al encolar, al haber red, en primer plano y cada 15 min). `LocalChangeNotifier` en `main()`.
6. `ConnectivityObserver` (`ChangeNotifier`) para deshabilitar las acciones en línea.
7. Repositorios offline-first por feature (§4) y casos de uso que encolan (§6).
8. Pantalla "Pendientes de sincronizar" e ícono con contador.
9. Limpieza al cerrar sesión (cachés) y aviso si hay operaciones pendientes.
10. Tests: DAO en memoria (`NativeDatabase.memory()`), dos conexiones al mismo archivo (bloqueo y escritura concurrente), `SyncProcessor` con `MockClient` y respuestas simuladas (2xx, 409 "ya aplicada", 422, 5xx, timeout).
11. En un dispositivo real: cerrar la app con operaciones en cola y comprobar que se envían, que la sesión no se cierra cuando el worker renueva el token y que la UI abierta ve lo que escribió el worker.

**Cómo repetir el punto 11 sin tocar el backend real.** `tool/sync_mock_server.dart` simula el refresh con rotación y registra cada petición; `integration_probe/sync_probe_main.dart` es una app mínima con el mismo núcleo y un worker real. El emulador no llega al equipo por `10.0.2.2` si el firewall de Windows lo bloquea, por eso se usa `adb reverse`:

```bash
dart run tool/sync_mock_server.dart 8099
```

```bash
adb reverse tcp:8099 tcp:8099
```

```bash
flutter run -t integration_probe/sync_probe_main.dart --dart-define=API_BASE_URL=http://localhost:8099
```

Resultado en el emulador `Medium_Phone` (Android), paso 1:

| Escenario | Evidencia en el registro del servidor |
| --- | --- |
| Con el proceso muerto, el sistema arranca otro motor y la operación llega | `authorized=true` desde `engine=worker`, con el proceso de la UI confirmado muerto |
| El worker renueva y la UI sigue con sesión | Un 401, una rotación y reintento correcto; la UI abierta ve `pendientes=0` y el refresh nuevo |
| Refresh simultáneo con solapamiento real (refresh de 8 s, 4 peticiones de la UI en 401 durante esos 8 s) | Una sola rotación y ningún reuso; la sesión se conserva |

Falta repetirlo en un teléfono físico: el emulador no reproduce el ahorro de batería de cada fabricante.
