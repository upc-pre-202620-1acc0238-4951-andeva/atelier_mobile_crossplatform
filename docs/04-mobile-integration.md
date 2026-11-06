# Guía de integración móvil

Todo lo que la app Flutter necesita de servicios externos además de la API REST: configuración, push, fotos, OBD-II, trabajo sin conexión, permisos de Android e iOS y cuentas de prueba.

Los servicios y el contrato con el backend son los mismos que en `atelier-mobile-android`. Cada sección indica qué cambia en iOS, porque ahí están las verdaderas diferencias.

> **Desarrollo en Windows:** se puede compilar y probar Android, pero **no iOS**. Compilar para iOS requiere una Mac con Xcode, y push y distribución requieren una cuenta de pago de Apple Developer. Lo específico de iOS en esta guía se comprobó contra la documentación de cada plugin; no se ha ejecutado en un iPhone.

---

## 1. Configuración del proyecto

Ningún secreto va al repositorio. Los valores van en un JSON ignorado por git, y Flutter los inyecta al compilar:

```json
// config/dev.json (NO versionar; plantilla en config/dev.example.json, sin este comentario)
{
  "API_BASE_URL": "https://<servicio>.onrender.com",
  "GOOGLE_WEB_CLIENT_ID": "<id>.apps.googleusercontent.com",
  "GOOGLE_IOS_CLIENT_ID": "<id-ios>.apps.googleusercontent.com",
  "SUPABASE_URL": "https://<proyecto>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon key pública del proyecto>",
  "SUPABASE_BUCKET": "atelier"
}
```

```bash
flutter run --dart-define-from-file=config/dev.json
```

```dart
// core/config/app_config.dart
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080', // emulador Android; el simulador de iOS usa localhost
  );
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const supabaseBucket = String.fromEnvironment(
    'SUPABASE_BUCKET',
    defaultValue: 'atelier',
  );
}
```

`API_BASE_URL` **no** termina en `/`: las rutas de los `Api` empiezan con `/api/v1`. Es distinto de Android, donde Retrofit exige la barra final.

| Valor | De dónde sale | Para qué |
| --- | --- | --- |
| `API_BASE_URL` | URL del servicio web en Render | `ApiClient` |
| `GOOGLE_WEB_CLIENT_ID` | Google Cloud Console → Credenciales → cliente OAuth **Web** (el mismo que el backend acepta en `GOOGLE_CLIENT_ID`) | `serverClientId` de `google_sign_in` |
| Cliente OAuth **Android** | Google Cloud Console → cliente Android con el package `com.andeva.atelier.mobile` y el SHA-1 de la llave debug/release | Necesario para que Google entregue el `idToken`. No se configura en el backend: el `aud` es el **Web client ID** |
| `GOOGLE_IOS_CLIENT_ID` | Google Cloud Console → cliente **iOS** con el bundle id | `clientId` de `google_sign_in` en iOS, más el *URL scheme* invertido en `Info.plist` |
| `android/app/google-services.json` | Firebase Console → proyecto `atelier-platform-ee4f5` → app Android | FCM. **No se versiona** |
| `ios/Runner/GoogleService-Info.plist` | El mismo proyecto → app iOS (hay que registrarla) | FCM. **No se versiona** |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | Supabase → Project Settings → API | Subida directa de fotos |
| `SUPABASE_BUCKET` | Bucket `atelier` (mismo que `SUPABASE_STORAGE_BUCKET` del backend) | Ruta de las fotos |

> `--dart-define` queda dentro del binario: sirve para valores públicos como estos, no para secretos de servidor. Es lo mismo que pasa con `BuildConfig` en Android.

### Identificador de la app

El proyecto se creó con `com.example`. El paso 0 lo cambia a **`com.andeva.atelier.mobile`** en Android y en iOS, el mismo de la app Android, para reutilizar la app de Firebase y el cliente OAuth ya previstos. Consecuencia: en un mismo teléfono Android no pueden estar instaladas a la vez la app nativa y la de Flutter.

| Plataforma | Valor |
| --- | --- |
| Android | `applicationId` y `namespace` = `com.andeva.atelier.mobile`, `minSdk = 26` |
| iOS | `PRODUCT_BUNDLE_IDENTIFIER` = `com.andeva.atelier.mobile`, `IPHONEOS_DEPLOYMENT_TARGET = 15.0` |

### Android: `android/app/build.gradle.kts`

Con la plantilla de Flutter el proyecto **no compila**: `permission_handler` exige `compileSdk 37`, y el AGP 9.1.0 de la plantilla no lo admite. Esta combinación, la misma de la app nativa, sí generó el APK de prueba con todos los plugins:

| Archivo | Cambio |
| --- | --- |
| `android/settings.gradle.kts` | `com.android.application` → `9.4.1`, y `id("com.google.gms.google-services") version "4.4.4" apply false` para que el plugin esté disponible |
| `android/gradle/wrapper/gradle-wrapper.properties` | `gradle-9.6.0-all.zip` |
| `android/app/build.gradle.kts` | Lo que sigue |

`flutter_local_notifications` necesita *core library desugaring*, y `google-services` se aplica solo si existe el archivo, como en la app nativa:

```kotlin
android {
    compileSdk = 37
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
    defaultConfig {
        minSdk = 26
        targetSdk = 37 // igual que la app nativa
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
```

La parte de `google-services` no se probó: falta el archivo real. La primera compilación es lenta (unos 10 min) y Gradle descarga solo lo que falte del SDK, como CMake 3.22.1. No ejecutar dos compilaciones a la vez: en la prueba, eso corrompió la caché de Kotlin.

> **Aviso de Flutter:** `firebase_core`, `flutter_image_compress_common` y `workmanager_android` aplican el Kotlin Gradle Plugin, y versiones futuras de Flutter dejarán de compilarlos así. Hoy funciona; al subir Flutter, actualizar primero estos plugins.

### `.gitignore`

```gitignore
config/dev.json
config/prod.json
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
*.local.md
```

---

## 2. Notificaciones push (FCM)

1. Al iniciar sesión: pedir permiso, obtener el token con `FirebaseMessaging.instance.getToken()` y enviarlo con `PUT /api/v1/users/me/device-token { "fcmToken": "…" }`.
2. En `FirebaseMessaging.instance.onTokenRefresh`: reenviarlo si hay sesión.
3. Al cerrar sesión: `PUT /api/v1/users/me/device-token { "fcmToken": null }` y luego `POST /api/v1/auth/sign-out`.

> `firebase_messaging` 17 marca `getToken()` y `onTokenRefresh` como obsoletos en favor de `register()` y `onRegistered`, que entregan un **Firebase Installation ID**, no un token de registro. Se siguen usando los primeros, igual que la app nativa, porque es lo que hoy recibe el backend. Esos dos usos llevan `// ignore: deprecated_member_use` con el motivo, para que `flutter analyze` siga en verde. Migrar exige comprobar antes que `atelier-platform` pueda enviar a un FID.

El backend envía mensajes con `notification` (título y cuerpo en español) y `data`. La app enruta según `data.type`:

| `data.type` | Quién lo recibe | `data` extra | Pantalla a abrir |
| --- | --- | --- | --- |
| `TASK_ASSIGNED` | El mecánico asignado | `workOrderId`, `taskId` | Detalle de la tarea |
| `TASK_PAUSED` | Quienes tienen `operations:tasks:hold_validate` | `workOrderId`, `taskId` | Detalle de la tarea (supervisión) |
| `TASK_SUSPENSION_REQUESTED` | Quienes tienen `operations:tasks:hold_validate` | `workOrderId`, `taskId` | Aprobar / rechazar suspensión |
| `TASK_PART_CHARGED` | Quienes tienen `inventory:batches:restore` | `workOrderId`, `taskId` | Productos de la tarea (revisar imputación) |
| `TASK_RESUMED` | Supervisores (`operations:tasks:hold_validate`) tras una pausa; el mecánico cuando se levanta su suspensión | `workOrderId`, `taskId` | Detalle de la tarea |
| `WORK_ORDER_COMPLETED` | Quienes tienen `operations:vehicle_handover:execute` (asesor) | `workOrderId` | Detalle de la orden (control de calidad y cobro) |
| `LOW_STOCK` | Quienes tienen `inventory:alerts:read` | `itemId`, `currentStock`, `minimumStock` | Alertas de stock (se repite en cada descargo bajo el mínimo, H14 de [03](03-traceability.md#huecos-abiertos)) |
| `OVERTIME_RECORDED` | Quienes tienen `hr:payroll:manage` | `attendanceId`, `membershipId`, `overtimeMinutes` | Asistencia del colaborador |
| `JUSTIFICATION_REVIEWED` | El colaborador que envió el descargo | `attendanceId`, `verdict` (`APPROVED`/`REJECTED`) | Mi asistencia |
| `SHIFT_REMINDER` | Colaboradores con turno que empieza en 15 min | `shiftId`, `startTime` | Marcar ingreso |

Cómo se reciben en Flutter:

| Estado de la app | API | Qué hace |
| --- | --- | --- |
| Abierta | `FirebaseMessaging.onMessage` | El sistema **no** muestra nada: se dibuja con `flutter_local_notifications` |
| En segundo plano y se toca | `FirebaseMessaging.onMessageOpenedApp` | `PushRouter` → `PushInbox` |
| Cerrada y se toca | `FirebaseMessaging.instance.getInitialMessage()` | Lo mismo, al arrancar |
| En segundo plano, sin tocar | Ninguna: `onBackgroundMessage` **no se registra** | Correría en otro motor sin nada que hacer; el sistema ya muestra la notificación |

Reglas:

- Crear un canal de Android por grupo: **Tareas**, **Asistencia**, **Inventario**.
- Android 13+ e iOS piden permiso en tiempo de ejecución (tras el login, con explicación previa).
- El push es un aviso: la pantalla siempre recarga los datos desde la API.
- Un `data.type` desconocido se ignora sin fallar (el backend puede agregar tipos nuevos).
- Sin `google-services.json`, `Firebase.initializeApp` falla: se registra en el log, la app abre igual y no se envía token. **Recibir un push real está sin comprobar:** falta el archivo.
- **Solo iOS:** requiere la llave APNs en Firebase, la capacidad *Push Notifications* y el modo de fondo `remote-notification`. Ver H43 en [03](03-traceability.md#huecos-abiertos).

---

## 3. Fotos y evidencias (Supabase Storage)

El backend no recibe archivos: la app sube la foto a Supabase y envía la URL.

```text
image_picker (cámara o galería) → flutter_image_compress (JPEG, lado mayor 1600 px, calidad 80)
  → POST {SUPABASE_URL}/storage/v1/object/{bucket}/{ruta}     (Authorization: Bearer {SUPABASE_ANON_KEY})
  → URL pública: {SUPABASE_URL}/storage/v1/object/public/{bucket}/{ruta}
  → POST /api/v1/work-orders/{id}/intake-images  |  /tasks/{id}/evidence-images  |  /work-orders/{id}/proposals
```

| Uso | Ruta sugerida en el bucket |
| --- | --- |
| Recepción (US13) | `{tenantId}/work-orders/{workOrderId}/intake/{uuid}.jpg` |
| Desmontaje / montaje (US28) | `{tenantId}/work-orders/{workOrderId}/tasks/{taskId}/{uuid}.jpg` |
| Propuesta adicional (US14) | `{tenantId}/work-orders/{workOrderId}/proposals/{uuid}.jpg` |
| Comprobante de compra recibida (US34 E2) | `{tenantId}/purchase-orders/{purchaseOrderId}/receipt/{uuid}.jpg`. Se sube **en línea** justo antes de `PUT /inventory/purchase-orders/{id}/receive`, no por la cola |

- `minWidth` y `minHeight` de `flutter_image_compress` fijan el lado **menor**: con 1600 en ambos, una foto de 4000×3000 saldría de 2133×1600. `compressionMinSide` calcula el valor que deja el lado mayor en 1600 y se pasa el mismo en los dos, así no importa si el plugin mide la foto antes o después de la rotación EXIF. Comprobado en un emulador Android con JPEG reales: 4000×3000 sale 1600×1200, 3000×4000 sale 1200×1600, una foto con rotación EXIF sale 1200×1600 y una de 800×600 no se agranda. En iOS, **sin comprobar**.
- El backend valida que la URL sea `https`, del host de Supabase configurado y que contenga `/storage/v1/object/` y `/atelier/`. Cualquier otra URL → 400.
- El bucket debe permitir `INSERT` con la anon key (política de Storage) y lectura pública.
- Subida con `x-upsert: true` y un `http.Client` simple, **sin** `AuthenticatedClient`: a Supabase no se le envía el JWT del backend.
- Si no hay red, la foto se copia a `getApplicationSupportDirectory()/pending/` y se sube después ([06](06-offline-sync.md) §6). No se guarda la ruta temporal que da `image_picker`: el sistema puede borrarla.
- **Rutas absolutas:** en iOS la carpeta de la app cambia al actualizarla. En `pending_uploads` se guarda la ruta **relativa** a esa carpeta y se resuelve al usarla.
- Las fotos se muestran con `CachedNetworkImage` a partir de la URL pública.

---

## 4. OBD-II (ELM327 por Bluetooth)

La lectura del vehículo ocurre **en la app**; el backend solo recibe los resultados.

### Lo que cambia con iOS

Un ELM327 "clásico" habla **Bluetooth clásico SPP**, y **iOS no da acceso a SPP** sin el programa de certificación MFi de Apple. Por eso:

| Adaptador | Android | iOS |
| --- | --- | --- |
| ELM327 Bluetooth clásico (el de la app nativa) | ✅ SPP | ❌ No se puede usar |
| ELM327 **BLE** (Bluetooth 4.0) | ✅ BLE | ✅ BLE |

```dart
// features/diagnostics/domain/obd_transport.dart
/// El protocolo ELM327 (comandos AT y modos OBD-II) es el mismo sobre SPP o BLE.
abstract class ObdTransport {
  Stream<String> get incoming;

  Future<void> connect(String address);

  Future<void> send(String command);

  Future<void> disconnect();
}
```

| Implementación | Plataforma | Cómo |
| --- | --- | --- |
| `SppObdTransport` | Android | `MethodChannel` + `EventChannel` hacia Kotlin en `android/app/src/main/kotlin/`, que reutiliza `BluetoothSppTransport.kt` de la app nativa. No se usa `flutter_blue_classic` porque es GPL-3 |
| `BleObdTransport` | Android e iOS | `universal_ble`. El servicio y las características cambian según el fabricante (suelen ser `FFE0`/`FFE1` o `FFF0`/`FFF1`/`FFF2`): hay que descubrirlas al conectar y escribir en trozos del tamaño del MTU |

El resto se porta tal cual de la app nativa: `Elm327ObdLink`, `DtcCatalog` y `LiveDiagnosticSession` no dependen del transporte. **No se ha probado con un adaptador BLE**: es el primer riesgo del paso 8. Ver H40 y H41 en [03](03-traceability.md#huecos-abiertos).

### Comandos y endpoints

| Paso | Comandos ELM327 / OBD-II | Endpoint |
| --- | --- | --- |
| Conectar. En SPP, socket con UUID `00001101-0000-1000-8000-00805F9B34FB` | `ATZ`, `ATE0`, `ATL0`, `ATS0`, `ATH0`, `ATSP0`; luego `0100` (si no contesta, la ECU no responde: US16 E2), `ATDPN` (protocolo) y `0902` (VIN, opcional) | `GET /iot/installations/vehicle/{vehicleId}/active` (o `POST /iot/installations/install`) |
| Leer DTC (US17) | Modo `03` → decodificar a `P0xxx` / `Cxxxx` / `Bxxxx` / `Uxxxx` (`NO DATA` = sin códigos); cuadro congelado con modo `02` (`0202`, `020500`, `020C00`, `020D00`), solo se muestra | `POST /iot/faults` por código (`severity`: `LOW`, `MEDIUM` o `CRITICAL`, de `DtcCatalog`: H20 de [03](03-traceability.md#huecos-abiertos)) |
| Telemetría en vivo (US18) | Modo `01`: `010C` RPM, `010D` velocidad, `0105` temperatura refrigerante, `012F` combustible, `010B` presión de admisión (solo se muestra: el lote no tiene ese campo), `ATRV` voltaje | Se encola localmente |
| Enviar lote (US19) | — | `POST /iot/telemetry/batch { vehicleId, readings[] }` |
| Borrar fallas (US20) | Modo `04` y luego `03` para comprobar | `POST /iot/faults/{id}/resolve` por cada DTC que ya no aparece |
| Informe IA (US21) | — | `POST /iot/health-reports/generate?vehicleId=` |

Cada lectura del lote:

```json
{ "timestamp": "2026-10-20T15:04:05Z", "engineRpm": 820, "speedKmh": 0,
  "engineTempCelsius": 88.5, "batteryVoltage": 13.9, "fuelPercentage": 61.0,
  "latitude": -12.0464, "longitude": -77.0428 }
```

- `engineTempCelsius` y `timestamp` son obligatorios; el resto es opcional.
- Lecturas repetidas (mismo vehículo y mismo `timestamp`) se ignoran, así que reintentar un lote es seguro.
- Agrupar en lotes de hasta ~200 lecturas; muestreo sugerido 1 lectura cada 2 s en vivo.
- El informe IA necesita telemetría suficiente en el período (`daysToAnalyze` 7–90); si no, 422 `ERR_INSUFFICIENT_TELEMETRY`.
- Solo el rol con `iot:telemetry:ingest` (por defecto, el mecánico) puede subir telemetría y DTC.
- **Sesión larga en Android:** *foreground service* de tipo `connectedDevice` con `flutter_foreground_task`, para que el sistema no corte la conexión.
- **Sesión larga en iOS:** modo de fondo `bluetooth-central`. iOS mantiene la conexión BLE, pero puede despertar la app con menos frecuencia, así que el muestreo no está garantizado con la pantalla apagada.

---

## 5. Trabajo sin conexión (offline-first)

Patrón del curso: el repositorio intenta la red, guarda en Drift y **la UI siempre lee de Drift**. Las escrituras que no pueden fallar se encolan. El diseño completo está en [06-offline-sync.md](06-offline-sync.md); esta sección es el resumen.

| Dato | Lectura offline (caché Drift) | Escritura offline (cola) |
| --- | --- | --- |
| Mis tareas, detalle de orden, catálogo de repuestos, turno, sedes | Sí | — |
| Lecturas de telemetría y DTC | — | Sí (`POST /iot/telemetry/batch`, `POST /iot/faults`) |
| Fotos de evidencia | — | Sí (subida a Supabase + registro de la URL) |
| Marcación de salida | — | Sí, enviando `clockOutTime` capturado en el dispositivo |
| Marcación de ingreso | — | Sí, enviando `clockInTime` capturado en el dispositivo junto con las coordenadas. El backend lo acepta hasta 12 h después (más tarde → 400: avisar al colaborador para que envíe un descargo) |
| Iniciar / pausar / cerrar tarea, imputar repuestos, cobrar | — | No: requieren respuesta inmediata del backend (stock, reglas de turno) |

Reglas de la cola:

- Una tabla `pending_operations` (tipo, payload JSON, intentos, creado en) y `SyncProcessor`, que corre en primer plano y en `workmanager`.
- Cada operación debe ser **idempotente** o tolerar duplicados (la telemetría ya lo es).
- Antes de enviar, renovar el token si expiró.
- **iOS no garantiza el segundo plano** (H42 en [03](03-traceability.md#huecos-abiertos)): la cola siempre intenta enviar también al abrir la app y al recuperar red.

---

## 6. Permisos

### Android: `android/app/src/main/AndroidManifest.xml`

Los mismos que la app nativa:

| Permiso | Para qué | Cuándo pedirlo |
| --- | --- | --- |
| `INTERNET`, `ACCESS_NETWORK_STATE` | API, Supabase, estado de red | Manifiesto (normales) |
| `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | Geocerca de asistencia (US06–US08) | Al tocar "Marcar ingreso" |
| `CAMERA` | Fotos de recepción y evidencias | Al abrir la cámara |
| `POST_NOTIFICATIONS` (API 33+) | Push | Tras el primer login |
| `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN` (API 31+, `neverForLocation`) | Escáner ELM327 | Al abrir el diagnóstico |
| `BLUETOOTH`, `BLUETOOTH_ADMIN` (`maxSdkVersion="30"`) | Escáner en Android 11 o menor | Manifiesto |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_CONNECTED_DEVICE` | Sesión OBD-II en vivo | Manifiesto |

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE" />

<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.bluetooth" android:required="false" />
<uses-feature android:name="android.hardware.location.gps" android:required="false" />
```

El `INTERNET` que Flutter genera solo en `debug` y `profile` no basta: debe estar en `main`, o la versión `release` no tendrá red.

### iOS: `ios/Runner/Info.plist`

iOS no tiene manifiesto de permisos, pero exige un texto por cada uno: **sin el texto, la app se cierra al pedirlo**.

| Clave | Texto sugerido |
| --- | --- |
| `NSLocationWhenInUseUsageDescription` | Validamos que marques tu asistencia dentro del taller. |
| `NSCameraUsageDescription` | Tomamos fotos de recepción y evidencias de trabajo. |
| `NSPhotoLibraryUsageDescription` | Adjuntamos fotos de tu galería a la orden de trabajo. |
| `NSBluetoothAlwaysUsageDescription` | Conectamos con el escáner OBD-II del vehículo. |

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
    <string>remote-notification</string>
    <string>bluetooth-central</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>atelier.sync</string>
</array>
```

El proyecto iOS usa Swift Package Manager y no tiene `Podfile`. Con SPM, `permission_handler` activa cada permiso leyendo su clave en `Info.plist`, y las notificaciones vienen activas por defecto: no hay macros que declarar. Si se compila desde Xcode.app y no con `flutter build ios`, hay que ejecutar una vez en la Mac `launchctl setenv PERMISSION_HANDLER_INFO_PLIST <ruta absoluta a ios/Runner/Info.plist>`; si no encuentra el archivo, todos los permisos quedan en `denied`. **Sin comprobar:** falta compilar en una Mac.

`AppDelegate.swift` registra los plugins del motor del worker (`setPluginRegistrantCallback`) y la tarea `atelier.sync` (`registerPeriodicTask`). Ese identificador debe coincidir con `SyncScheduler.taskName`, con `periodicName` y con `BGTaskSchedulerPermittedIdentifiers`. **Sin comprobar:** falta compilar en una Mac.

---

## 7. Geocerca y asistencia

- Pedir una ubicación **fresca** con `Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high))`; no usar la última conocida.
- Si la precisión (`position.accuracy`) es peor que 50 m, pedir al usuario que salga a cielo abierto antes de marcar.
- La sede y el turno salen de `GET /hr/employees/membership/{membershipId}` (`branchId`, `assignedShiftId`); la geocerca, de `GET /branches/{id}` (`latitude`, `longitude`, `geofenceRadiusMeters`). La app puede mostrar la distancia antes de enviar, pero **la validación real la hace el backend** (422 si está fuera).
- Detectar ubicación simulada con `position.isMocked` y advertir; el backend no lo verifica. En iOS este dato es menos fiable: solo sirve de aviso.

---

## 8. Descarga de PDFs

```text
ApiClient.getBytes (con Authorization) → getTemporaryDirectory()/pdfs/{nombre}.pdf
  → OpenFilex.open(ruta, type: 'application/pdf')
```

Para compartir (WhatsApp, correo) usar `SharePlus.instance.share(ShareParams(files: [XFile(ruta)]))`. El nombre del archivo viene en `Content-Disposition`.

---

## 9. Cuentas de prueba

No se versionan credenciales. Para el entorno local:

1. Registrar un taller con `POST /auth/sign-up` usando un alias de correo propio (por ejemplo `tu.correo+dueno@gmail.com`) y verificar el OTP que llega al correo.
2. Como dueño, invitar a un colaborador por rol con `POST /invitations/tenant/{tenantId}` usando alias distintos (`+mecanico`, `+jefe`, `+asesor`, `+recepcion`, `+almacen`, `+caja`).
3. Aceptar cada invitación desde la app (`POST /invitations/accept`).
4. Guardar los correos y contraseñas en un archivo local ignorado por git (por ejemplo `test-accounts.local.md`), nunca en el repo.

Un taller recién registrado tiene prueba gratuita con las cuotas del plan elegido (si se elige un plan sin IA, los informes IA responden 403).
