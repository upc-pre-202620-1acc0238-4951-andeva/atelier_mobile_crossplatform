# Plan — Portar la capa visual de Android a Flutter

**Fuente de verdad única:** el código de `../../atelier-mobile-android/app/src/main/java/com/andeva/atelier/mobile/` (más `res/` y `DESIGN.md` de ese repo). Lo que se ve y se hace en Android se ve y se hace igual en Flutter: mismos colores, tipografías, espaciados, radios, íconos, textos, orden de secciones, estados vacíos/carga/error, validaciones, diálogos, hojas inferiores, animaciones y navegación. Si Android y un doc de este repo se contradicen en algo visual o de comportamiento de pantalla, **gana Android**.

Este plan levanta la regla 7 de [07-roadmap.md](07-roadmap.md): ahora sí se construyen `core/designsystem` y `presentation`.

## 0. Qué ya existe y qué no se toca

- `domain`, `application` e `infrastructure` de las 12 features ya están hechos (pasos 0–9), **pero Android cambió después en todas sus capas**. Antes de portar la presentación de cada feature, se compara su domain, application e infrastructure (y `core/`) con Android y se porta lo nuevo o cambiado: modelos, campos, casos de uso, DTOs, endpoints, DAOs y reglas de negocio. Se omiten los cambios que solo sirven a historias excluidas. Lo que no cambió no se reescribe. Los ViewModels llaman a los casos de uso existentes vía `get_it`. Si a una pantalla le falta un caso de uso que Android tiene, se agrega siguiendo [05](05-flutter-architecture.md), sin inventar endpoints.
- El estilo de código sigue [05-flutter-architecture.md](05-flutter-architecture.md) §5.4 y AGENTS.md: `ChangeNotifier` + `_state` + `copyWith` + `ListenableBuilder`; `registerFactory` para ViewModels; `Navigator` + `MaterialPageRoute`; sin `provider`/`bloc`/`go_router`. Se copia **qué** se ve y **qué** hace, traducido a Flutter idiomático; no Kotlin línea por línea.
- Textos visibles: idénticos a los de Android, en `lib/l10n/app_es.arb`.

## 1. Historias EXCLUIDAS (no se construyen)

US04, US05, US18, US19, US28, US29, US30, US34, US35, US36, US37, US38, US39, US40, US41, US42, US43.

Regla: **no** se construye la UI de esas historias ni sus puntos de entrada (botones, ítems de menú, pestañas, tarjetas del dashboard, rutas de push). El código de `domain`/`application`/`infrastructure` que ya existe para ellas **se deja como está** (no se borra). Si una pantalla mezcla historias incluidas y excluidas, se construye la pantalla y se omite solo la parte excluida, sin dejar huecos visuales (el layout se cierra como si esa sección no existiera).

| Historia | Qué se omite en la UI (Android → Flutter) |
| --- | --- |
| US04 | Botón/acción "Cerrar sesión" (Perfil, Ajustes, menús) y su diálogo de pendientes |
| US05 | `auth/presentation/forgot/*`, `auth/presentation/reset/*` y el enlace "¿Olvidaste tu contraseña?" del login |
| US18 | `diagnostics/presentation/live/*` (telemetría en vivo, umbrales, congelar muestra) y sus accesos desde el hub |
| US19 | Captura/almacenamiento local y envío en lote de telemetría en el hub de diagnóstico (contadores de lecturas pendientes, botón sincronizar telemetría). **No** afecta la pantalla general "Pendientes de sincronizar" de `main` |
| US28 | `tasks/.../TaskEvidenceSection`, `TaskPhotoCapture` y la acción de subir fotos de desmontaje/montaje |
| US29 | Solicitar suspensión, aprobar/rechazar suspensión y reanudar (en detalle de tarea y detalle de orden) |
| US30 | Cerrar tarea con horas hombre (hoja de cierre y botón del dock) |
| US34 | `inventory/presentation/alerts/*` y la recepción de órdenes de compra (foto de comprobante / `receive`) |
| US35 | Sección de rentabilidad/margen FIFO en el detalle de la orden |
| US36 | Resumen de liquidación (subtotal, IGV, total) de la orden: `QuotationSummarySection` / `OrderCostSheets` en lo que sea liquidación |
| US37 | Emisión de comprobantes (`cashier/presentation/vouchers/*` emisión, `CheckoutSheets` de comprobante) |
| US38 | Registro de pagos (checkout) |
| US39 | Marcar pagada, pase de salida y entrega (`cashier/presentation/checkout/*`) |
| US40 | `bays/presentation/*` (tablero y reasignación de bahías) |
| US41 | Exportación PDF de flujo de caja en `reports` |
| US42 | `cashier/presentation/series/*` (series fiscales) |
| US43 | Descarga/compartir PDF del informe de salud y PDF de flota |

Ante la duda de si algo pertenece a una historia excluida: buscar la historia en [03-traceability.md](03-traceability.md) y en `docs/01-requirements/user-stories.md`. Si sigue en duda, **construirlo** y anotarlo en el reporte final.

Consecuencia: la feature `cashier` casi entera y `bays` quedan sin UI. Si al omitir US37–US39 una pantalla de `cashier` (p. ej. `dailycash`) queda sin historia excluida, se construye.

## 2. Fases

Cada fase termina con `flutter analyze` sin errores y `flutter test` en verde. Después de cada pantalla, abrir el archivo Kotlin y la versión Flutter lado a lado y repasar: textos, orden, colores, tamaños, estados y acciones.

### Fase A — Design system (`lib/core/designsystem/`)

Portar **todo** `core/designsystem/` de Android (34 archivos):

- `theme/`: `Color.kt` (claro **y** oscuro, `values-night`), `Type.kt` (PlusJakartaSans, JetBrainsMono, AlbertSans — ya en `pubspec`), `Shape.kt`, `Theme.kt` → `atelier_theme.dart` con `ThemeData` claro y oscuro + `ThemeExtension` para los tokens que Material no cubre.
- `component/`: un archivo Dart por componente con el mismo nombre (`AtelierButton` → `atelier_button.dart`, etc.), mismas variantes, tamaños, estados (habilitado, deshabilitado, cargando), densidades y animaciones (`Motion.kt`).
- `icon/Icons.kt`: mismo set de íconos. Vectores propios de `res/drawable/` → SVG convertidos a `CustomPainter` o a `IconData`; si hace falta una dependencia (p. ej. `flutter_svg`), agregarla y anotarla en [05](05-flutter-architecture.md) §2.
- `text/UiText.kt` y `core/presentation/` (`DateFormat`, `MoneyFormat`, `DocumentIntents`) → `lib/core/presentation/`.
- Logo e imágenes de `res/drawable` que use la UI → `assets/images/`.

### Fase B — Navegación raíz y `auth`

- `navigation/AppNavHost.kt` + `AppNavHostViewModel.kt` → reemplazar los marcadores de `AppRoot` por la navegación real.
- `auth`: login (sin enlace de recuperar, US05), registro por invitación, verificar correo (OTP), elegir sede. `AuthComponents.kt`.

### Fase C — `main`

`MainNavigationBar`, `MainNavigation`, `MainViewModel`, dashboard admin, asistencia admin, `ModulesSheet` (sin entradas a módulos excluidos), notificaciones, perfil (sin cerrar sesión, US04), pendientes de sincronizar. Pestañas por permiso exactamente como Android.

### Fase D — `attendance`

`AttendanceScreen`, `FloorHubScreen` (dashboard del piso) y su navegación.

### Fase E — `tasks`

`MyTasksScreen`, `TaskDetailScreen` y componentes (`ChronometerTimer`, `PartSheets`, `TaskPartsSection`, `TaskPitActionDock`, `TaskSheets`) **sin** evidencia fotográfica (US28), suspensión (US29) ni cierre (US30).

### Fase F — `reception` + `workorders`

Recepción: búsqueda de vehículo (+ sheets), registrar cliente, afiliación. Órdenes: lista, abrir orden, detalle (+ diálogos y componentes, sin US29/US35/US36/US39), reportar hallazgo, galería de ingreso, panel de propuestas, catálogo de servicios.

### Fase G — `inventory`

Catálogo, detalle de repuesto, órdenes de compra (lista y detalle, sin recepción US34), escáner SKU, proveedores, valorización. Sin alertas (US34).

### Fase H — `diagnostics`

Hub (pestañas dispositivos y alertas, sheets), fallas del vehículo, informe IA (sin PDF, US43). Sin telemetría en vivo (US18) ni captura/lote de telemetría (US19).

### Fase I — `reports`, `team`, `cashier` restante

`ReportsScreen` sin exportación PDF (US41). `team` si tiene UI en Android. `cashier/dailycash` solo si no depende de US37–US39.

### Fase J — Cierre

- Push: `PushRouter` abre las pantallas nuevas; los destinos de historias excluidas no navegan a nada.
- Pruebas de widget mínimas por pantalla principal (renderiza estado cargado, vacío y error) y de ViewModel donde Android tenga lógica no trivial.
- Comandos de [AGENTS.md](../AGENTS.md) en verde: `build_runner` (si cambió Drift), `flutter analyze`, `flutter test`, `flutter build apk --debug --dart-define-from-file=config/dev.json` (si no existe `config/dev.json`, copiar `config/dev.example.json` sin versionarlo).
- Actualizar [07-roadmap.md](07-roadmap.md) con un paso 10 "Presentación" y la lista de lo omitido.
- iOS: sin comprobar.

## 3. Verificación de paridad (segundo agente)

Por cada archivo de UI en Android (`core/designsystem`, `core/presentation`, `features/*/presentation`, `navigation`), marcar en `docs/08-presentation-parity.md`:

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias |
| --- | --- | --- | --- |

Estados: ✅ igual · ⚠️ diferencias (listarlas: textos, colores, orden, acciones, estados faltantes) · ❌ falta · ⛔ excluido (historia USxx).

Comprobar además que **ninguna** historia excluida quedó accesible desde la UI.
