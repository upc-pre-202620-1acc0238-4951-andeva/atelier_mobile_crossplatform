# Roadmap de construcción — Atelier Mobile (Flutter)

Orden de construcción de la app, paso a paso. **Cada paso se hace en su propia sesión** y en su propia rama. Al cerrar un paso se actualiza este archivo: es lo único que una sesión nueva necesita para saber dónde va el proyecto.

Es el mismo orden que siguió `atelier-mobile-android`. Esa app ya tiene resueltos los flujos y los huecos del backend, así que aquí se **porta** su comportamiento; no se vuelve a diseñar.

## Cómo empezar una sesión

```text
Lee docs/07-roadmap.md y haz el paso N. Primero un plan, luego implementa.
```

Reglas para todas las sesiones:

1. **Fuente de verdad:** `docs/` (00–06 y `api/`). `atelier-documentation.md` y `atelier-ecosystem-details.md` son solo contexto general y están desactualizados.
2. **Estilo:** [05-flutter-architecture.md](05-flutter-architecture.md), que sigue el repo del profesor. El código Android es la referencia de **qué** hace cada caso de uso, no de **cómo** se escribe: no traducir Kotlin línea por línea.
3. **Referencia Android:** cada paso indica su carpeta en `../../atelier-mobile-android/app/src/main/java/com/andeva/atelier/mobile/`. El detalle de cada pieza está en [android-roadmap-reference.md](android-roadmap-reference.md).
4. **Antes de empezar:** el paso anterior debe estar commiteado y el árbol limpio (`git status`). La rama nueva sale de `develop` (o de la rama del paso anterior si aún no se mergeó).
5. **Una sesión por rama:** no trabajar dos sesiones a la vez sobre los mismos archivos.
6. **Reutilizar el núcleo** (`core/`, paso 1). No crear otro cliente HTTP, otra cola ni otro manejo de sesión.
7. **Capas de cada paso:** `domain`, `application` e `infrastructure`. `presentation` y `core/designsystem` no se construyen salvo que el usuario lo pida (decisión tomada en el paso 1): hasta entonces, `AppRoot` muestra marcadores sin estilo. Las pantallas que cada paso enumera abajo describen el alcance funcional que esa capa cubrirá.
8. **Al terminar:** los comandos de abajo en verde, docs actualizados si cambió algo y este archivo marcado.

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

iOS no se puede compilar desde Windows. Los cambios de `ios/` quedan marcados como **sin comprobar** hasta probarlos en una Mac ([04](04-mobile-integration.md)).

## Estado

| # | Paso | Estado | Rama |
| --- | --- | --- | --- |
| 0 | Configuración general (`pubspec`, identificador, plataformas) | ✅ Android · iOS sin comprobar | `feature/foundations` |
| 1 | Núcleo `core/` | ✅ Android en emulador · iOS y teléfono físico sin comprobar | `feature/core` |
| 2 | `auth` — sesión y acceso | ✅ Sin `presentation` · backend real, Google e iOS sin comprobar | `feature/auth` |
| 3 | `main` — contenedor con pestañas por permiso | ✅ Sin `presentation` · push real e iOS sin comprobar | `feature/main` |
| 4 | `attendance` — asistencia y turnos | ✅ Sin `presentation` · Android en emulador · backend real, teléfono físico e iOS sin comprobar | `feature/attendance` |
| 5 | `tasks` — tareas del mecánico | ⬜ Pendiente | |
| 6 | `reception` + `workorders` — recepción y órdenes | ⬜ Pendiente | |
| 7 | `inventory` — catálogo, lotes y alertas | ⬜ Pendiente | |
| 8 | `diagnostics` — OBD-II, DTC e informe IA | ⬜ Pendiente | |
| 9 | `bays`, `cashier`, `reports`, `team` | ⬜ Pendiente | |

Leyenda: ⬜ pendiente · 🔄 en curso · ✅ hecho.

Tamaño de referencia en Android: 459 archivos Kotlin en `core`, `navigation` y `features`.

---

## Paso 0 — Configuración general

Deja el proyecto compilando con todas las dependencias, sin funcionalidad.

- `pubspec.yaml`, `build.yaml` y `analysis_options.yaml` de [05](05-flutter-architecture.md) §2, y `l10n.yaml` + `lib/l10n/app_es.arb`.
- Identificador `com.andeva.atelier.mobile`, `minSdk = 26`, `compileSdk = 37`, AGP 9.4.1, Gradle 9.6.0, iOS 15.0, desugaring y `google-services` opcional ([04](04-mobile-integration.md) §1). Sin estos cambios no compila.
- Permisos de Android e iOS ([04](04-mobile-integration.md) §6).
- `config/dev.example.json`, `AppConfig` y `.gitignore` ([04](04-mobile-integration.md) §1).
- Fuentes `.ttf` en `assets/fonts/` (de `app/src/main/res/font/` de Android) e íconos con `flutter_launcher_icons`, solo `android` e `ios`, desde `docs/branding/atelier-workshop-icon.png`.
- `README.md` del proyecto (el del repo Android como base) y borrar el `.iml`, que `.gitignore` ya ignora.

**Listo cuando:** `flutter build apk --debug` funciona y la app abre en un emulador.

## Paso 1 — Núcleo `core/`

Base que usan todas las features. Detalle en [05](05-flutter-architecture.md) §3 y §5 y en [06](06-offline-sync.md) §3–§5. **Android:** `core/`, `navigation/`.

| Pieza | Dónde | Para qué la usa una feature |
| --- | --- | --- |
| `Session`, `Permission`, `Plan` | `core/domain` | Habilitar UI por permiso y plan (`session.has(...)`, `canUseTelemetry()`) |
| `ApiException`, `NetworkException` | `core/domain` | Mostrar el `message` del backend; distinguir "sin red" |
| `BusinessTime`, `Money`, `MissingBranchException` | `core/domain` | Día de Lima, dinero y acciones que necesitan sede |
| `ApiClient`, `AuthenticatedClient`, `TokenRefresher`, `PublicEndpoints` | `core/data/remote` | Llamar a la API con sesión y un solo refresh |
| `SessionManager`, `JwtClaims` | `core/data/local` | Guardar la respuesta de sign-in (`save(dto)`), sede/turno (`updateAssignment`), `clear()` |
| `AppDatabase` + 19 tablas | `core/data/local`, `features/*/infrastructure/local` | Cada feature agrega **su DAO** (las tablas ya existen) |
| `CrossIsolateLock`, `LocalChangeNotifier` | `core/data` | Convivencia de la UI y el worker |
| `PendingOperationQueue`, `OperationHandler`, `SyncProcessor`, `SyncScheduler`, `callbackDispatcher` | `core/data/sync` | Encolar capturas sin red y registrar su handler ([06](06-offline-sync.md) §3) |
| `CacheMaintenanceDao` | `core/data/sync` | Borrar cachés al cerrar sesión |
| `SupabaseUploader`, `StoragePaths`, `PhotoCapture` | `core/media` | Comprimir y subir fotos; URL pública determinista |
| `PushRouter`, `PushInbox`, `DeviceTokenRegistrar`, `NotificationChannels` | `core/notifications` | Abrir la pantalla correcta al tocar un push |
| `ConnectivityObserver`, `PdfDownloader` | `core/data/remote` | Deshabilitar acciones "en línea"; descargar PDFs |
| `SyncTriggers` | `core/data/sync` | Enviar la cola al abrir, al recuperar red y al volver a primer plano |
| `AppRoot` | `navigation/` | Login o app según la sesión (marcadores sin estilo) |

`MaterialTheme` y los componentes de `core/designsystem` quedan fuera de este paso (regla 7). Se dejaron para el paso que los use: `Session.needsBranchChoice` (paso 2), `watchSession` y las consultas de la pantalla de pendientes (paso 3) y los DAO de cada feature.

**Primero se prueba lo que no existe en Android:** dos conexiones sobre el mismo archivo, `CrossIsolateLock` y el refresh desde dos motores. Es el mayor riesgo técnico del proyecto.

**Listo cuando:** pasan las pruebas de [06](06-offline-sync.md) §8 y, en un dispositivo real, una operación encolada se envía con la app cerrada.

---

## Paso 2 — `auth`

- **Historias:** US01–US05 ([01](01-requirements/user-stories.md), EP01) · **API:** [api/iam.md](api/iam.md) · **Trazabilidad:** [03](03-traceability.md) EP01 · **Android:** `features/auth`
- **Casos de uso:** `SignIn`, `GoogleSignIn`, `VerifyEmail`, `ResendVerification`, `ValidateInvitation`, `AcceptInvitation`, `ForgotPassword`, `ResetPassword`, `GetPendingOperationCount`, `SignOut`, `GetSelectableBranches`, `SelectBranch`, `SkipBranchChoice`.
- **Pantallas:** A5 login, A3 registro por invitación, A4 código, A5b elegir sede, A6 recuperar contraseña. Las cuatro primeras existen en Android; **A6 hay que hacerla**.
- **Tras el login:** `GET /hr/employees/membership/{membershipId}` con el token recibido → `SessionManager.save(dto)` + `updateAssignment(branchId, shiftId)` → `DeviceTokenRegistrar.registerCurrentToken()` → pedir permiso de notificaciones. La sede se pide **antes** de guardar, porque al guardar `AppRoot` cambia de pantalla; sin perfil laboral (404) se entra sin sede.
- **Cierre de sesión:** avisar si hay operaciones pendientes ([06](06-offline-sync.md) §3; la cola se conserva) → `DeviceTokenRegistrar.clear()` → `POST /auth/sign-out` → `CacheMaintenanceDao.clearCaches()` → `SessionManager.clear()`.
- **Errores clave:** 401 credenciales · `code = EMAIL_NOT_VERIFIED` (403) → pantalla OTP · invitación: 404 inexistente/revocada, 409 ya aceptada o membresía activa, 410 vencida.
- **Decisiones ya tomadas en Android:** aceptar la invitación devuelve la sesión, así que A3 no pasa por A4 · el enlace de invitación se pega a mano (H1) · el alta de taller (`POST /auth/sign-up`) queda fuera · solo elige sede quien entra sin perfil laboral (H33).
- **Sin red:** todo es en línea.

**Hecho en el paso 2.** Núcleo extendido: `Session.needsBranchChoice`, `SessionManager.setBranchChoicePending` / `selectBranch` / `dismissBranchChoice`, `BranchApi` (lo reutiliza `attendance`) y `NotificationPermissionRequester`. Caso de uso añadido a la lista: `RequestNotificationPermissionUseCase`.

Diferencias con Android, a propósito:

- `ApiClient` lanza donde Android devuelve `Result`: los fallos de red del token FCM y de `sign-out` se capturan para que nunca impidan entrar o salir.
- Al salir, `refreshToken` se lee **después** del `PUT` del token FCM, porque ese `PUT` puede rotarlo.
- Sede y marca se escriben **antes** de `save`, y tras entrar se dispara la cola (`runDetached`).
- `GoogleSignInUseCase.execute()` pide el `idToken` y entra: no necesita una Activity. Devuelve el resultado de Google (`GoogleSignInOutcome`); los errores del backend suben como excepción.

Para quien haga la presentación (no está escrito, porque solo es de UI):

- `code == emailNotVerifiedCode` (`auth/domain/auth_errors.dart`) → A4. Al verificar, volver al login con el correo precargado y un aviso.
- A3: 404 y 410 → pantalla de invitación vencida o inexistente; `InvalidInvitationException` → igual. Exige además una mayúscula y confirmar la contraseña, como Android. Muestra el rol: `validate` no devuelve la fecha de vencimiento.
- A4: reenvío bloqueado 60 s; "Vence en 15:00" solo tras un reenvío hecho en esa pantalla.
- Permiso de notificaciones: explicar primero y llamar a `RequestNotificationPermissionUseCase` ([04](04-mobile-integration.md) §2).
- Sin comprobar: login contra el backend real (`integration_probe/auth_probe_main.dart`, necesita una cuenta de prueba), Google real (cliente OAuth con el SHA-1) e iOS.

## Paso 3 — `main`

- **Android:** `features/main`. **Casos de uso:** `ObserveSession`, `ObservePendingOperationCount`, `ObservePendingOperations`, `RetryPendingOperation`, `DiscardPendingOperation`, `ObservePushDestination`, `ConsumePushDestination`.
- **Incluye:** `MainPage` con `NavigationBar` e `IndexedStack`, pestañas según `NavigationItem` y permisos ([05](05-flutter-architecture.md) §5.5), aviso si `plan.accessGranted == false`, ícono con el contador de pendientes y pantalla "Pendientes de sincronizar" con *Reintentar* / *Descartar* ([06](06-offline-sync.md) §3). Android todavía no tiene esta última pantalla.
- **Pestañas, como en Android:** con `operations:tasks:track_time` → Inicio · Tareas · (Órdenes si `work_orders:create`) · OBD-II (si `canUseTelemetry()`) · Perfil; sin él → Inicio · Órdenes · Recepción · Stock · Ajustes.
- **Consume** `PushInbox` para abrir el destino del push.

**Hecho en el paso 3.** Los siete casos de uso, sin endpoints: todo es local. Núcleo extendido: `SessionManager.watchSession`, `PendingOperationDao.resetFailed` / `allDependentIds` / `discardUnlessSyncing`, `markSyncing` condicionado y `core/domain/push_destination.dart`. `LocalChangeNotifier.listenInUi` ahora recibe `sync`.

Diferencias con Android, a propósito:

- *Reintentar* y *Descartar* escriben en una sola sentencia, y `markSyncing` solo pasa desde `PENDING`: el worker es otra conexión ([06](06-offline-sync.md) §3).
- La UI sincroniza cuando el worker avisa que terminó. Lo reintentado o encolado mientras él envía no estaba en su lote, `requestSync` lo ignora por `keep` y `nextAttemptAfter` solo ve intentos futuros.
- `SessionRepository` y `PushDestinationRepository` no existen en Android: los casos de uso dependen solo del dominio de su feature, como en `auth`.
- El contador no incluye `SYNCING` ([06](06-offline-sync.md) §3); Android cuenta todos los estados. La lista sí los muestra.

Para quien haga la presentación (no está escrito, porque solo es de UI):

- `MainPage`, `NavigationBar` + `IndexedStack`, `NavigationItem`, perfil y "Pendientes de sincronizar". Los textos de cada `type` de la cola también son de esa capa.
- **Regla de pestañas**, igual que `MainTab.tabsFor` de Android. Con `tasksTrackTime`: Inicio · Tareas (si `tasksRead`) · Órdenes (si `workOrdersCreate`) · OBD-II (si `canUseTelemetry()`) · Perfil. Sin él: Inicio · Órdenes (si `workOrdersRead`) · Recepción (si `vehiclesCreate`) · Stock (si `partsRead`) · Ajustes. `NavigationItem.requires` de [05](05-flutter-architecture.md) §5.5 admite un solo permiso y no alcanza para expresarla: hay que ajustarlo.
- Aviso de plan: `session.hasSubscriptionAccess() == false`. Contador en la última pestaña, como Android.
- `DiscardPendingOperationUseCase` devuelve `false` si algo de la cadena se está enviando: es un aviso, no un error. Tras matarse el worker, una fila puede seguir `SYNCING` hasta la siguiente vuelta del sync.
- Push: `ObservePushDestinationUseCase` repite el valor al suscribirse y emite `null` al consumir. Consumirlo solo en `MainPage`, que no existe mientras `needsBranchChoice`, y traducirlo a la página cuando exista su feature.
- Sin comprobar: push real (falta `google-services.json`) e iOS.

## Paso 4 — `attendance`

- **Historias:** US06, US08, US09, US10 · **API:** [api/hr.md](api/hr.md) · [04](04-mobile-integration.md) §7 · **Android:** `features/attendance`
- **Casos de uso:** `RefreshAttendance`, `ObserveTodayAttendance`, `ObserveAttendanceHistory`, `ObserveWeeklySchedule`, `ClockIn`, `ClockOut`, `SubmitJustification`.
- **Primera feature con cola offline:** `CLOCK_IN`, `CLOCK_OUT`, `SUBMIT_JUSTIFICATION` (handlers + `dedupe_key` de [06](06-offline-sync.md) §3 y §6).
- **Cachés:** `branches`, `shifts`, `attendances`.
- **Ubicación:** `LocationProvider` (contrato en dominio, implementación con `geolocator`), ubicación fresca, precisión ≤ 50 m, detectar ubicación simulada.
- **Sin red en iOS:** la marcación queda en cola hasta que se abra la app (H42). Que se note en la pantalla.

**Hecho en el paso 4.** Los siete casos de uso, `AttendanceApi`, `AttendanceDao`, `ShiftDao`, `BranchDao`, `AttendanceCache`, `GeolocatorLocationProvider` y los handlers `CLOCK_IN`, `CLOCK_OUT` y `SUBMIT_JUSTIFICATION`, registrados en `setupAttendanceDependencies()`. Sin cambio de esquema. Núcleo extendido: `BranchDto.latitude` / `longitude`, `BusinessTime.addDays`, `PendingOperationDao.findForUserByType` y `SessionManager.switchOn`, que ahora también usa `PendingOperationRepositoryImpl`. `SyncProcessor` falla en cascada lo encolado sobre un padre que ya está `FAILED` ([06](06-offline-sync.md) §3).

Diferencias con Android, a propósito:

- **La geocerca y la ubicación simulada avisan, no bloquean.** Android bloquea desde el commit `c20f1d2`, pero estos documentos dicen que decide el backend ([06](06-offline-sync.md) §6). Quien marca fuera recibe 422 con la distancia, o `FAILED` con ese `message` si iba en cola. Contrapartida: el backend no detecta la ubicación simulada. Sí se bloquea sin fix o con precisión peor que 50 m.
- `CLOCK_OUT` verifica su 400 o 404 con `history` del día capturado y del anterior: Android solo mira el capturado, y una salida ya aplicada de una jornada nocturna queda `FAILED`. Si la verificación falla con 5xx, 408 o 429 se reintenta; Android solo reintenta sin red.
- La salida también espera al ingreso en cola de un día anterior, salvo que esté `FAILED`.
- `watchToday` calcula el día en cada emisión: Android lo fija al suscribirse y queda viejo tras la medianoche.
- Solo el 404 de `status-today` es "sin jornada" (H2).

Para quien haga la presentación (no está escrito, porque solo es de UI):

- `ClockInResult`: `outcome` dice qué pasó, `geofence` trae la distancia para el aviso (es `null` si la sede no está en caché) e `isMockLocation` avisa de la ubicación simulada.
- `Recorded` confirma. `Queued`: "Marcación guardada · se enviará al recuperar señal"; en iOS, que se enviará al abrir la app (H42). `AlreadyQueued` lleva a "Pendientes de sincronizar".
- `TodayAttendance` decide el botón: `NotClockedIn` → ingreso; `ClockedIn` → salida; `ClockInQueued` y `ClockOutQueued` muestran la hora capturada; `Completed` → resumen.
- El permiso de ubicación se pide dentro de `LocationProvider`, al marcar. Mostrar cada excepción de `attendance_errors.dart`, y el `message` del backend en `ApiException`.
- "Revisa la hora de tu teléfono" si el backend rechaza la hora capturada, y descargo si pasaron más de 12 h. `Attendance.syncedAt` da el "Actualizado hace N min".
- Mostrar *Marcar ingreso*, *Marcar salida* e historial según `attendanceClockIn`, `attendanceClockOut` y `attendanceReadOwn`.

Comprobado y sin comprobar:

- **Comprobado en emulador** con worker y GPS reales ([06](06-offline-sync.md) §8). La prueba destapó dos errores que las pruebas unitarias no veían, ya corregidos: el diálogo de Google de cada marcación ([04](04-mobile-integration.md) §7) y un `upsert` que no borraba los campos que el backend enviaba en `null`.
- Sin comprobar: backend real (si `history` filtra por la fecha de `clockIn` y si guarda `clockOutTime` tal cual), teléfono físico (GPS bajo techo con `LocationManager`), ubicación simulada (`adb emu geo fix` no cuenta como tal), iOS (`isMocked` y el diálogo de permiso) y los push `SHIFT_REMINDER` y `JUSTIFICATION_REVIEWED`.
- Riesgos que se heredan de Android: un `history` en vuelo puede borrar con `replaceRange` una marcación recién guardada (se corrige en el siguiente refresh y marcar otra vez da 409), y tratar todo 422 de descargo como "ya aplicada" ([06](06-offline-sync.md) §3) podría perder el motivo si la causa fue otra regla.

## Paso 5 — `tasks`

- **Historias:** US26–US30, US23 E1–E3, US33 E1, US35 E1/E3 · **API:** [api/operations.md](api/operations.md), [api/crm.md](api/crm.md) (placa), [api/inventory.md](api/inventory.md) (buscar repuesto) · **Android:** `features/tasks`
- **Casos de uso:** `ObserveMyTasks`, `RefreshMyTasks`, `ObserveTask`, `GetTaskDetail`, `StartTask`, `PauseTask`, `RequestSuspension`, `ApproveSuspension`, `RejectSuspension`, `ResumeSuspendedTask`, `SuggestLaborHours`, `CompleteTask`, `AttachTaskEvidence`, `ObservePendingEvidence`, `SearchParts`, `AddPartToTask`, `UpdateTaskPartQuantity`, `RemovePartFromTask`.
- **En línea:** iniciar, pausar, suspender, reanudar, cerrar e imputar repuestos.
- **Offline:** fotos de desmontaje y montaje (`UPLOAD_FILE` + `ATTACH_TASK_EVIDENCE`).
- **Caché:** `tasks` (+ `vehicles` y `bays` para placa y bahía). **Push:** `TASK_ASSIGNED`, `TASK_PAUSED`, `TASK_RESUMED`, `TASK_SUSPENSION_REQUESTED`, `TASK_PART_CHARGED`.
- **Cuidado (H37, H38, H9):** corregir la cantidad de un repuesto no tiene efecto real y *Devolver* deja la línea visible, por errores del backend.

## Paso 6 — `reception` + `workorders`

- **Historias:** US11, US44, US12–US15, US22, US24, US25, US36, US33 E2, US35 E2 · **API:** [api/crm.md](api/crm.md), [api/operations.md](api/operations.md) · **Android:** `features/reception`, `features/workorders`
- **`reception`:** `FindVehicleByPlate`, `SearchCustomers`, `GetCustomerVehicles`, `ObserveCustomer`, `ObserveVehicle`, `RegisterIndividualCustomer`, `RegisterCompanyCustomer`, `RegisterVehicle`, `LookupAffiliation`, `AffiliateCustomer`, `RefreshAppointments`, `ObserveAppointments`, `MarkAppointmentArrived`.
- **`workorders`:** `RefreshBranchWorkOrders`, `ObserveBranchWorkOrders`, `ObserveWorkOrder`, `GetWorkOrderDetail`, `OpenWorkOrder`, `UpdateWorkOrder`, `FindDraftWorkOrderForVehicle`, `StartWorkOrder`, `CompleteWorkOrder`, `CancelWorkOrder`, `AddWorkOrderTask`, `UpdateWorkOrderTask`, `GetServiceCatalog`, `GetBranchMechanics`, `AttachIntakePhoto`, `ObservePendingIntakePhotos`, `SubmitProposal`, `ObservePendingProposals`, `NotifyProposal`, `ApproveProposal`, `RejectProposal`, `DownloadQuotationPdf`, `SendQuotation`, `ApproveQuotation`, `RejectQuotation`, `GetPartMovements`, `GetProfitability`.
- **Offline:** fotos de recepción (`ATTACH_INTAKE_IMAGE`) y propuestas (`SUBMIT_PROPOSAL`). El resto es en línea.
- **Propuestas:** `severity` solo `LOW`, `MEDIUM` o `CRITICAL`; la petición rechaza `HIGH` con 400 ([api/README.md](api/README.md) §8).
- **Decisiones ya tomadas en Android:** suspensiones en el detalle de la orden (H5) · la llegada de una cita crea la orden después, con kilometraje 0 (H10) · nombres de servicios y mecánicos (H11) · el combustible va al inicio del diagnóstico (H34).
- **Cachés:** `customers`, `vehicles`, `appointments`, `work_orders`. **PDF:** proforma ([04](04-mobile-integration.md) §8).

## Paso 7 — `inventory`

- **Historias:** US31, US32, US34 · **API:** [api/inventory.md](api/inventory.md) · **Android:** `features/inventory`
- **Casos de uso:** `RefreshPartsCatalog`, `ObservePartsCatalog`, `SearchPartsCatalog`, `FindPartBySku`, `ObservePart`, `GetPartDetail`, `RefreshPartBatches`, `ObservePartBatches`, `GetStockAlerts`, `ObserveStockAlerts`, `GetInventoryValuation`, `GetPurchaseOrders`, `GetPurchaseOrder`, `ReceivePurchaseOrder`, `ObservePartBrands`.
- **Cachés:** `parts`, `batches` (solo con `inventory:batches:read`). **Push:** `LOW_STOCK`.
- **Backend:** el catálogo se pagina en memoria, los lotes llegan del más nuevo al más viejo y con agotados, las alertas se calculan al consultar y `receive` responde 400 a todo (H12–H15).
- **Lector de código de barras:** sin implementar en Android. Elegir el plugin en este paso.

## Paso 8 — `diagnostics`

- **Historias:** US16–US21, US43 E1 · **API:** [api/iot.md](api/iot.md) · [04](04-mobile-integration.md) §4 · **Android:** `features/diagnostics`
- **Casos de uso:** `GetPairedObdAdapters`, `GetObdDevices`, `GetActiveInstallation`, `InstallObdDevice`, `UninstallObdDevice`, `ConnectObd`, `DisconnectObd`, `StartLiveTelemetry`, `StopLiveTelemetry`, `ObserveLiveTelemetry`, `FreezeTelemetry`, `ScanFaults`, `ClearFaults`, `RefreshVehicleFaults`, `ObserveVehicleFaults`, `ObserveDiagnosticsSyncState`, `GenerateHealthReport`, `GetLatestHealthReport`, `GetHealthReportDetail`, `DownloadHealthReportPdf`, `RefreshPredictiveAlerts`, `ObservePredictiveAlerts`, `AcknowledgePredictiveAlert`.
- **Offline:** `telemetry_readings` → `TELEMETRY_BATCH`, `REGISTER_FAULT`, `RESOLVE_FAULT` ([06](06-offline-sync.md) §6).
- **En línea:** instalar o retirar el escáner, informe IA, alertas predictivas.
- **Visible solo si** `session.canUseTelemetry()` / `canUseAiDiagnostics()`.
- **Empezar por `ObdTransport`:** SPP por canal de plataforma, luego BLE. **Requiere un ELM327 BLE para probar**; sin él, no se puede afirmar que funcione en iOS (H40, H41).
- **Sesión larga:** `flutter_foreground_task` en Android y `bluetooth-central` en iOS.

## Paso 9 — `bays`, `cashier`, `reports`, `team`

- **`bays`** (US40): `RefreshBayBoard`, `ObserveBayBoard`, `PollBayBoard`, `ReassignBay`, `ReassignTaskMechanic`. Tablero con refresco cada 30 s mientras la pantalla está visible (H24, H25).
- **`cashier`** (US37–US39, US42): `PrepareVoucher`, `IssueVoucher`, `GetWorkOrderVouchers`, `ObserveWorkOrderVouchers`, `RegisterPayment`, `GetVoucherPayments`, `GetDailyCashSummary`, `MarkWorkOrderPaid`, `DownloadExitPass`, `DeliverVehicle`, `GetBranchSeries`, `ConfigureSeries`, `SetSeriesActive`. Todo en línea. `voucherType` viaja como código SUNAT (`"01"`, `"03"`, `"07"`). **Dinero y documentos fiscales: portar H26–H29 sin simplificar**, en especial H28 (no duplicar comprobantes ni cobros tras un timeout).
- **`reports`** (US41, US43 E2): `GetCashFlowSummary`, `DownloadCashFlowPdf`, `DownloadFleetHealthPdf`. Todo en línea (H30, H31).
- **`team`** (US10): `GetBranchDailyAttendance`, `GetPendingJustifications`, `GetCollaboratorAttendance`, `ApproveJustification`, `RejectJustification`. Todo en línea (H32).

---

## Pendientes y riesgos conocidos

| Tema | Detalle | Afecta |
| --- | --- | --- |
| Dos motores | Comprobado en emulador con `workmanager` real ([06](06-offline-sync.md) §8); falta un teléfono físico, por el ahorro de batería de cada fabricante | Paso 1 |
| iOS sin comprobar | Desde Windows no se compila iOS. `Info.plist`, los permisos con Swift Package Manager, `AppDelegate`, Keychain en segundo plano y `BGTaskScheduler` necesitan una Mac | Todos |
| Cuenta de Apple Developer | Sin ella no hay push en iOS ni instalación estable en iPhones (H43) | Pasos 1, 2 |
| Adaptador ELM327 BLE | Sin uno no se puede probar el escáner en iOS (H40) | Paso 8 |
| Segundo plano en iOS | Solo es una mejora: lo capturado puede no salir hasta abrir la app (H42) | Pasos 1, 4, 5, 6, 8 |
| Configuración local | Faltan `google-services.json` y `GoogleService-Info.plist` | Pasos 2, 5, 6 |
| Identificador compartido | Con `com.andeva.atelier.mobile`, la app nativa y esta no conviven en un mismo Android ([04](04-mobile-integration.md) §1) | Pruebas |
| Huecos del backend | H9, H26–H31, H34–H39 siguen abiertos y se heredan tal cual ([03](03-traceability.md#huecos-abiertos)) | Pasos 5–9 |
