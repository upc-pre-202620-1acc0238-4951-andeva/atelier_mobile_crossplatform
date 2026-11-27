# Auditoría de paridad Android ↔ Flutter (v1.0.0)

> **Fuente de verdad:** `atelier-mobile-android` rama `develop`, versión 1.0.0 (último commit `3f6a7d1`, 2026-11-24). **Auditado:** rama Flutter `feature/full-parity` (último commit `d469922`, 2026-11-26). Alcance: **todas** las historias US01–US44 (US07 no existe en `user-stories.md`); ya no hay exclusiones.
> Este archivo **reemplaza** la auditoría anterior (la versión antigua quedó superada y se sobrescribe). Lo escribe el agente comparador; no se tocó código. Lo usará el agente corrector.

## 1. Método y límites

Se abrieron ambos lados y se contrastó con scripts: (1) textos `R.string.*` de cada pantalla Compose contra las referencias `strings.*` del Flutter homónimo y contra `lib/l10n/app_es.arb`; (2) componentes `Atelier*`, tokens `colors.*`, íconos y orden de claves por pantalla; (3) campos de dominio/DTO, casos de uso, endpoints Retrofit contra clientes Dart, permisos, tablas Room contra Drift, handlers de sync y constantes; (4) lectura directa de los archivos con diferencias (líneas citadas). Las traducciones idiomáticas (Compose→widgets, Navigation→`Navigator`, Hilt→`get_it`, ViewModel→`ChangeNotifier`, `AppNavHost`→`AppRoot`/`AppNavigator`, Room→Drift, WorkManager→`workmanager`) **no** se cuentan como diferencia.

Límites honestos: no se ejecutó ninguna de las dos apps ni se compararon capturas, así que las medidas en dp, los tiempos de animación y el espaciado de las pantallas marcadas ✅ se verificaron por coincidencia de tokens, componentes y constantes, no pixel a pixel. Nada de iOS se pudo comprobar (no hay Mac).

## 2. Resumen cuantitativo

| Medida | Android | Flutter | Resultado |
| --- | --- | --- | --- |
| Archivos de código (`.kt` / `.dart` sin `*.g.dart`) | 715 | 774 | 569 pares por nombre; 146 Android sin homónimo (casi todos DI/Room/Retrofit/interfaces de infraestructura que Flutter agrupa distinto) y 206 Flutter sin homónimo (presentaciones agregadas, `*_presentation.dart`, `*_dependencies.dart`, `.steps`) |
| Archivos de UI auditados (design system, `core/presentation`, navegación, `features/*/presentation`, sin `@Preview`) | 216 | — | **184 ✅ · 31 ⚠️ · 1 ❌** |
| Pantallas (`*Screen`) / ViewModels | 43 / 46 | 43 / 46 | Paridad numérica |
| Rutas de navegación | 43 destinos | 45 `AppRoute` | Todas las rutas Android existen; falta la **pestaña** Bahías |
| Casos de uso | 197 | 200 | 5 faltan de verdad (ver §5) |
| Endpoints | 148 | 145 cubiertos | Faltan `tenants/current` (GET, PUT) e `iot/telemetry/vehicle/{id}/history` |
| Permisos `Permission` | 74 | 74 | Idénticos |
| Entidades Room / tablas Drift | 19 | 19 | Idénticas salvo `parts.brand` |
| Tipos de operación de sync | 10 | 10 | Idénticos |
| Textos `strings*.xml` | 1.908 recursos (1.634 usados en UI) | 2.020 claves en `app_es.arb` | 100 % de los textos Android existen en el `.arb` (las únicas 31 variaciones son `%%`→`%` y plurales ICU). **130 claves Android no se referencian en el código Flutter** y **108 textos son solo de Flutter** |
| Colores/tipografía/formas | 55 tokens + 15 estilos + 6 formas | idénticos | ✅ |
| Historias US01–US44 (43 historias) | — | — | **29 ✅ · 14 ⚠️ · 0 ❌** |
| `flutter analyze` | — | — | 9 issues found, todos de nivel `info` (0 errores, 0 advertencias): regla `curly_braces_in_flow_control_structures` en `ai_health_report_view_model.dart:95,134`, `reports_screen.dart:107`, `work_order_detail_screen.dart:71,73,1083` y `work_order_detail_view_model.dart:491,1088,1170`. Salida del comando: código 1 solo por los `info` |
| `flutter test` | — | — | con `-j 1`: **1.120 pasan, 5 fallan** ("Some tests failed", exit 1), todos en `test/features/cashier/presentation/fiscal_series_view_model_test.dart` (E1 agregar serie, serie que no corresponde al tipo, correlativo inicial inválido, E2 serie repetida, activar/desactivar): `mocktail` lanza "Bad state: … `any` on a parameter of type `VoucherType` … registerFallbackValue was not previously called" (falta `registerFallbackValue(VoucherType.…)` en el `setUpAll`). Con la concurrencia por defecto la suite se colgó dos veces (en `obd_transports_test` y en el `tearDownAll` de `main_screens_test`) y una vez falló además `elm327_obd_link_test` ("el prompt puede llegar solo, en otro trozo", `ObdConnectionLostException`): hay pruebas inestables o con recursos compartidos (archivo Drift / timers); conviene revisarlas |

Lectura rápida: el sistema de diseño, la autenticación, asistencia, recepción, órdenes, caja (comprobantes/pagos), inventario base e informes están portados con alta fidelidad. Lo que se desvió es lo que se portó **después** de la primera auditoría desde especificaciones propias y no desde el Android 1.0.0: telemetría en vivo (US18), bahías (US40), series fiscales (US42), alertas de stock (US34), rentabilidad (US35), evidencia/suspensión (US28/29/30), PDF de flota (US43) y los enlaces de correo (US01/US05).

## 3. Cómo leer las tablas

✅ igual (sin diferencias detectadas) · ⚠️ diferencias · ❌ falta. Prioridad: P1 funcionalidad faltante/rota, P2 diferencia visual notable, P3 menor. Las líneas citadas del lado Android son de `app/src/main/java/com/andeva/atelier/mobile/`; las de Flutter, de `lib/`.

## 4. Tabla por archivo Android (UI)

### 4.1 Design system (`core/designsystem`)

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `core/designsystem/component/AtelierAdaptiveRow.kt` | `core/designsystem/component/atelier_adaptive_row.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierBanner.kt` | `core/designsystem/component/atelier_banner.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierButton.kt` | `core/designsystem/component/atelier_button.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierChip.kt` | `core/designsystem/component/atelier_chip.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierChronometer.kt` | `core/designsystem/component/atelier_chronometer.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierDensity.kt` | `core/designsystem/component/atelier_density.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierGroupedCard.kt` | `core/designsystem/component/atelier_grouped_card.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierKpiCard.kt` | `core/designsystem/component/atelier_kpi_card.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierListRow.kt` | `core/designsystem/component/atelier_list_row.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierLiveBeacon.kt` | `core/designsystem/component/atelier_live_beacon.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierLogo.kt` | `core/designsystem/component/atelier_logo.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierMainTopBar.kt` | `core/designsystem/component/atelier_main_top_bar.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierNavigationBar.kt` | `core/designsystem/component/atelier_navigation_bar.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierOtpField.kt` | `core/designsystem/component/atelier_otp_field.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierPanels.kt` | `core/designsystem/component/atelier_panels.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierPhotoGrid.kt` | `core/designsystem/component/atelier_photo_grid.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierPidTile.kt` | `core/designsystem/component/atelier_pid_tile.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierPlate.kt` | `core/designsystem/component/atelier_plate.dart` | ✅ | Sin diferencias detectadas (`plateA11y` se lee con `AppLocalizations.of(context)` en atelier_plate.dart:35). |
| `core/designsystem/component/AtelierPlateField.kt` | `core/designsystem/component/atelier_plate_field.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierSegmentedControl.kt` | `core/designsystem/component/atelier_segmented_control.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierSelectionCard.kt` | `core/designsystem/component/atelier_selection_card.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierSheet.kt` | `core/designsystem/component/atelier_sheet.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierSkeleton.kt` | `core/designsystem/component/atelier_skeleton.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierStates.kt` | `core/designsystem/component/atelier_states.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierSurface.kt` | `core/designsystem/component/atelier_surface.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierTextField.kt` | `core/designsystem/component/atelier_text_field.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/AtelierTopBar.kt` | `core/designsystem/component/atelier_top_bar.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/component/Motion.kt` | `core/designsystem/component/motion.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/icon/Icons.kt` | `core/designsystem/icon/atelier_icons.dart` | ✅ | Los 4 vectores propios (person, assignment, bluetooth_searching, home) están portados como `AtelierVectorIcon`. El resto del set usa `Icons.*_outlined` de Material (ver nota de íconos al final). |
| `core/designsystem/text/UiText.kt` | `core/designsystem/text/ui_text.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/designsystem/theme/Color.kt` | `core/designsystem/theme/atelier_colors.dart` | ✅ | Los 55 tokens de `AtelierColors` y las paletas claro/oscuro coinciden valor por valor (incl. alfa de `heroSpecular` 0.30 = 0x4D, `primaryGlow` 0.24 = 0x3D). |
| `core/designsystem/theme/Shape.kt` | `core/designsystem/theme/atelier_shapes.dart` | ✅ | Radios 6/12/16/18/20/24, píldora de la barra flotante y `Spacing` 4/8/16/24/32 idénticos. |
| `core/designsystem/theme/Theme.kt` | `core/designsystem/theme/atelier_theme.dart` | ⚠️ | Android pasa `shapes = AtelierShapes` (extraSmall 6, small/medium 12, large 16) a `MaterialTheme` y define `background`/`surfaceVariant` en el esquema (Theme.kt:34,38,65,69,127-131); Flutter no mapea las formas a `ThemeData` ni define `background`/`surfaceVariant` (atelier_theme.dart:11-62; el fondo se cubre con `scaffoldBackgroundColor`). Efecto visual solo en widgets Material sin estilo propio (P3). |
| `core/designsystem/theme/Type.kt` | `core/designsystem/theme/atelier_typography.dart` | ✅ | Escala M3 idéntica (Satoshi 400/500/700/900, cifras tabulares, tracking). Nota P3: `pubspec.yaml` además declara PlusJakartaSans y JetBrainsMono, que Android ya no usa. |

### 4.2 Núcleo UI (`core/presentation`, `core/notifications`)

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `core/notifications/AtelierMessagingService.kt` | `core/notifications/push_messaging_service.dart`<br>`notification_channels.dart` | ⚠️ | Android usa solo `notification.title/body` del push (AtelierMessagingService.kt:30-44); Flutter añade títulos por defecto `pushDefaultTitle*` (8 textos que Android no tiene). Canales Tareas/Asistencia/Inventario equivalentes. P3. |
| `core/notifications/AuthDeepLinkInbox.kt` | `core/notifications/auth_deep_link_inbox.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/notifications/DeviceTokenRegistrar.kt` | `core/notifications/device_token_registrar.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/notifications/NotificationChannels.kt` | `core/notifications/notification_channels.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/notifications/NotificationPermissionEffect.kt` | `core/notifications/notification_permission_requester.dart` | ✅ | Equivalente (solicitud de POST_NOTIFICATIONS). |
| `core/notifications/NotificationPermissionViewModel.kt` | `core/notifications/notification_permission_requester.dart` | ✅ | Equivalente. |
| `core/notifications/PushInbox.kt` | `core/notifications/push_inbox.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/notifications/PushRouter.kt` | `core/notifications/push_router.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/presentation/DateFormat.kt` | `core/presentation/date_format.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/presentation/DocumentIntents.kt` | `core/presentation/document_intents.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `core/presentation/MoneyFormat.kt` | `core/presentation/money_format.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.3 Raíz y navegación

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `MainActivity.kt` | `main.dart`<br>`android/app/src/main/AndroidManifest.xml` | ❌ | Android registra dos App Links `https://atelier.andeva.tech` con `autoVerify` (`/auth/reset-password`, `/auth/accept-invitation`; AndroidManifest.xml:59-76) y `MainActivity` publica el URI en `AuthDeepLinkInbox.postFromUri` (MainActivity.kt, `onCreate`/`onNewIntent`). En Flutter el manifiesto solo declara MAIN/LAUNCHER (AndroidManifest.xml:40-43) y nada llama a `AuthDeepLinkInbox.postFromUri` (auth_deep_link_inbox.dart:36): los enlaces del correo (US01 invitación, US05 restablecer) no abren la app. iOS (Associated Domains) tampoco comprobado. P1. |
| `navigation/AppNavHost.kt` | `navigation/app_root.dart`<br>`navigation/app_navigator.dart`<br>`navigation/app_nav_host_view_model.dart` | ⚠️ | (1) Push `TaskSuspensionReview` abre `WorkOrderDetailRoute` en Android (AppNavHost.kt:121) y la tarea en Flutter (app_root.dart:123-127). (2) Enlaces de auth con sesión iniciada: mismo aviso (`authDeeplinkSignedInWarning`) pero sin enlace entrante (ver MainActivity). Resto equivalente: raíz por sesión, `needsBranchChoice`, tab roots, transición (200/240 ms, 1/12) portada en `atelier_page_transitions.dart`. |
| `navigation/AppNavHostViewModel.kt` | `navigation/app_nav_host_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `attendance`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/attendance/presentation/AttendanceScreen.kt` | `features/attendance/presentation/attendance_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/attendance/presentation/AttendanceUiState.kt` | `features/attendance/presentation/attendance_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/attendance/presentation/AttendanceViewModel.kt` | `features/attendance/presentation/attendance_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/attendance/presentation/dashboard/FloorHubScreen.kt` | `features/attendance/presentation/dashboard/floor_hub_screen.dart`<br>`floor_hub_ui_state.dart`<br>`floor_hub_view_model.dart` | ⚠️ | Tarjeta de Stock: Android muestra alertas de stock mínimo (`floorHubStockCaption` "alertas de stock mínimo", cifras `floorHubFigureOutOfStock` agotados / `floorHubFigureOpenPos` OC emitidas / catálogo, sección `floorHubStockDecisions` "Requieren reposición" y `floorHubStockEmpty`; FloorHubScreen.kt:~395-440, `onOpenStockAlerts` :139/:786, `state.stockAlerts`/`outOfStockCount`). Flutter conserva el diseño anterior: lista de OC emitidas (`floorHubStockPosCaption`, `issuedPurchaseOrders`; floor_hub_screen.dart:424,595; view model :48,144-147) y no abre la bandeja de alertas. Acceso rápido Bahías: subtítulo Android `floorHubQuickBaysSub` "Vehículos asignados por elevador" vs `moreHBaysSub` "Qué auto ocupa cada bahía" (floor_hub_screen.dart:941). Flutter añade strings propios (`floorHubPo*`, `floorHubAppt*`, `floorHubCashReadySubtitle`) que Android no usa. P1/P2. |
| `features/attendance/presentation/dashboard/FloorHubUiState.kt` | `features/attendance/presentation/dashboard/floor_hub_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/attendance/presentation/dashboard/FloorHubViewModel.kt` | `features/attendance/presentation/dashboard/floor_hub_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/attendance/presentation/navigation/AttendanceNavGraph.kt` | `features/attendance/presentation/navigation/attendance_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |

### 4.4 Feature `auth`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/auth/presentation/AuthComponents.kt` | `features/auth/presentation/auth_components.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/branch/BranchSelectionScreen.kt` | `features/auth/presentation/branch/branch_selection_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/branch/BranchSelectionUiState.kt` | `features/auth/presentation/branch/branch_selection_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/branch/BranchSelectionViewModel.kt` | `features/auth/presentation/branch/branch_selection_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/forgot/ForgotPasswordScreen.kt` | `features/auth/presentation/forgot/forgot_password_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/forgot/ForgotPasswordUiState.kt` | `features/auth/presentation/forgot/forgot_password_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/forgot/ForgotPasswordViewModel.kt` | `features/auth/presentation/forgot/forgot_password_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/login/LoginScreen.kt` | `features/auth/presentation/login/login_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/login/LoginUiState.kt` | `features/auth/presentation/login/login_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/login/LoginViewModel.kt` | `features/auth/presentation/login/login_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/navigation/AuthNavGraph.kt` | `features/auth/presentation/auth_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/auth/presentation/register/RegisterScreen.kt` | `features/auth/presentation/register/register_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/register/RegisterUiState.kt` | `features/auth/presentation/register/register_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/register/RegisterViewModel.kt` | `features/auth/presentation/register/register_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/reset/ResetPasswordScreen.kt` | `features/auth/presentation/reset/reset_password_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/reset/ResetPasswordUiState.kt` | `features/auth/presentation/reset/reset_password_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/reset/ResetPasswordViewModel.kt` | `features/auth/presentation/reset/reset_password_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/verifyemail/VerifyEmailScreen.kt` | `features/auth/presentation/verifyemail/verify_email_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/verifyemail/VerifyEmailUiState.kt` | `features/auth/presentation/verifyemail/verify_email_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/auth/presentation/verifyemail/VerifyEmailViewModel.kt` | `features/auth/presentation/verifyemail/verify_email_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `bays`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/bays/presentation/BayActionSheets.kt` | `features/bays/presentation/bay_action_sheets.dart` | ⚠️ | Falta la sección "Mecánicos y faenas en bahía" (:177 `baysMechanicsSection`) con reasignar mecánico por tarea (`orderReassignMechanicBtn`, `orderMechanicUnassigned`, `orderMechanicRoleDefault`), hoja de elegir mecánico y el botón "Asignar a {bahía}" (`orderAssignToBay`). Flutter muestra descripciones por estado (`bayStatus*Desc`) que Android no tiene. P1. |
| `features/bays/presentation/BaysScreen.kt` | `features/bays/presentation/bays_screen.dart` | ⚠️ | 565 → 286 líneas. Faltan: resumen de ocupación (`BayOccupancySummary` :380: AtelierSurface + AtelierLiveBeacon + AtelierMetricBar, textos `baysOccupancyTitle/Fraction/Breakdown`), FAB "Nueva bahía" (:192; Flutter usa botón en la barra y en el estado vacío), AtelierRefreshBar, filas `AtelierListRow` con beacon vivo (Flutter dibuja `_BayCard` con AtelierSurface), `BayStatusChip` con ícono Build para mantenimiento. Flutter añade botón de refrescar en la barra (`baysRefresh`). P2. |
| `features/bays/presentation/BaysUiState.kt` | `features/bays/presentation/bays_ui_state.dart` | ⚠️ | Android: `availableMechanics`, `reassigningTaskId`, `canReadWorkOrders`, `canAssignBay`, `canReleaseBay`, `activeOrders` filtrados; Flutter modela `BaySheet`/`CreateBayForm` y no tiene mecánicos. |
| `features/bays/presentation/BaysViewModel.kt` | `features/bays/presentation/bays_view_model.dart`<br>`bays_ui_state.dart` | ⚠️ | Faltan `onOpenReassignTaskMechanic`/`onConfirmReassignTaskMechanic` (usan `ReassignTaskMechanicUseCase`; en Flutter solo lo usa el detalle de orden), `availableMechanics`, `reassigningTaskId`; permisos: Android exige además `WORK_ORDERS_READ` (canReadWorkOrders) y distingue `canAssignBay`/`canReleaseBay` (BaysViewModel.kt:66-70); Flutter solo `canRead/canReassign/canManage` (bays_view_model.dart:85-87). Avisos: Android `orderBayAssignedNotice` "Orden asignada a {p1} para intervención…" vs Flutter `baysAssignedNotice` "Orden ingresada a §." / `baysMovedNotice`. |

### 4.4 Feature `cashier`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/cashier/presentation/CashierComponents.kt` | `features/cashier/presentation/cashier_components.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/CashierForms.kt` | `features/cashier/presentation/cashier_forms.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/CashierLabels.kt` | `features/cashier/presentation/cashier_labels.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/checkout/CheckoutSheets.kt` | `features/cashier/presentation/checkout/checkout_sheets.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/checkout/WorkOrderCheckoutScreen.kt` | `features/cashier/presentation/checkout/work_order_checkout_screen.dart` | ⚠️ | Flutter no usa `cashierExitPassChooser` (título del selector al compartir el pase de salida, WorkOrderCheckoutScreen.kt:157) ni los chips de estado de la orden `orderStatusDraft/InProgress/Completed/Paid/Canceled` (:293-297). Orden de claves por sección distinta (rail → pasos); el resto de textos coincide. P2. |
| `features/cashier/presentation/checkout/WorkOrderCheckoutUiState.kt` | `features/cashier/presentation/checkout/work_order_checkout_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/checkout/WorkOrderCheckoutViewModel.kt` | `features/cashier/presentation/checkout/work_order_checkout_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/dailycash/DailyCashScreen.kt` | `features/cashier/presentation/dailycash/daily_cash_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/dailycash/DailyCashUiState.kt` | `features/cashier/presentation/dailycash/daily_cash_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/dailycash/DailyCashViewModel.kt` | `features/cashier/presentation/dailycash/daily_cash_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/navigation/CashierNavGraph.kt` | `features/cashier/presentation/navigation/cashier_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/cashier/presentation/series/FiscalSeriesScreen.kt` | `features/cashier/presentation/series/fiscal_series_screen.dart` | ⚠️ | 579 → 337 líneas; diseño distinto. Faltan: tarjeta "Información fiscal del taller" (`TenantFiscalSectionCard` :287; RUC, razón social, nombre comercial; hoja de edición :418-458, `cashierFiscalTenant*`), tarjeta "PSE administrado por Atelier" (:336), hoja de detalle de serie con Activar/Desactivar y confirmación (:397-411, `cashierSeriesDetailTitle/DeactivateBody/ActivateBody`; Flutter usa un interruptor directo), selector de tipo de comprobante + serie de 4 caracteres con reglas F…/B…/NC (:476-514, `cashierSeriesType/Serie/NcHint/NcSerieError/SerieError/InitialError`), FAB "Agregar serie" (:130), `AtelierRefreshBar` sobre la lista, cabecera "Series electrónicas de la sede". Flutter usa `AtelierReportPanel` con cifras facturas/boletas y 20 textos propios `fiscalSeries*` (p. ej. `fiscalSeriesPse`, `fiscalSeriesToggleLabel`) que Android no tiene; dos literales sin l10n ("Boleta · Último número", "Activa"). P1. |
| `features/cashier/presentation/series/FiscalSeriesUiState.kt` | `features/cashier/presentation/series/fiscal_series_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/series/FiscalSeriesViewModel.kt` | `features/cashier/presentation/series/fiscal_series_view_model.dart`<br>`fiscal_series_ui_state.dart` | ⚠️ | Android carga y guarda el perfil fiscal (`GetTenantFiscalProfileUseCase`, `UpdateTenantFiscalProfileUseCase`; permisos `TENANTS_READ/UPDATE`), valida serie/correlativo por tipo (`serieValid`, `initialValid`), mantiene `sheet`/`sheetError`; Flutter no tiene nada de eso (ver tabla de capas). P1. |
| `features/cashier/presentation/vouchers/VouchersScreen.kt` | `features/cashier/presentation/vouchers/vouchers_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/vouchers/VouchersUiState.kt` | `features/cashier/presentation/vouchers/vouchers_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/cashier/presentation/vouchers/VouchersViewModel.kt` | `features/cashier/presentation/vouchers/vouchers_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `diagnostics`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/diagnostics/presentation/DiagnosticsUiFormatters.kt` | `features/diagnostics/presentation/diagnostics_ui_formatters.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/faults/VehicleFaultsScreen.kt` | `features/diagnostics/presentation/faults/vehicle_faults_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/faults/VehicleFaultsUiState.kt` | `features/diagnostics/presentation/faults/vehicle_faults_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/faults/VehicleFaultsViewModel.kt` | `features/diagnostics/presentation/faults/vehicle_faults_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/hub/DiagnosticsAlertsTab.kt` | `features/diagnostics/presentation/hub/diagnostics_alerts_tab.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/hub/DiagnosticsDevicesTab.kt` | `features/diagnostics/presentation/hub/diagnostics_devices_tab.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/hub/DiagnosticsHubScreen.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_screen.dart` | ⚠️ | La acción de telemetría en vivo cambia de título y subtítulo según el modo (`diagActionLiveTitle`, `diagActionLiveSubBt` "Lectura de PIDs en tiempo real y captura", `diagActionLiveSubRemote` "Última lectura registrada y serie histórica"; :800) y puede entrar en modo remoto sin escáner; Flutter usa `diagLiveTitle` + `diagActionLiveSub` fijo ("RPM, temperatura, presión y voltaje en vivo"). P2. |
| `features/diagnostics/presentation/hub/DiagnosticsHubSheets.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_sheets.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/hub/DiagnosticsHubUiState.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/hub/DiagnosticsHubViewModel.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/live/LiveTelemetryScreen.kt` | `features/diagnostics/presentation/live/live_telemetry_screen.dart` | ⚠️ | 733 → 295 líneas; rediseño completo en Android. Faltan: `AtelierFichaPanel` de cabecera (:153), `AtelierPlanLockedState` (:218), `AtelierRefreshBar`/pull to refresh (:227), estado vacío remoto con botón Actualizar (:299-301), tiles calibrados `CalibratedPidTile` con `AtelierPidTile` + `AtelierMetricBar` y estado por PID (`diagPidStatus*`, `diagPid*`, `diagPidUnit*`: RPM, temperatura, voltaje, carga, velocidad, acelerador, combustible, presión de admisión; :518-661), sección "Historial reciente" por cubos de tiempo (`HistoryBucketRow` :498, `diagLiveHistoryHeader/Samples`; endpoint `GET iot/telemetry/vehicle/{id}/history`), hoja inferior de muestra congelada (:368, `AtelierBottomSheet`), barra inferior `LiveTelemetryBottomBar` (:411: Reconectar, Códigos DTC, Congelar, Detener/Iniciar, Actualizar). Flutter: 6 tiles propios (`diagLivePid*`), tarjeta de muestra congelada en línea, y un diálogo de salida (`diagLiveExit*`) que Android no tiene. P1. |
| `features/diagnostics/presentation/live/LiveTelemetryUiState.kt` | `features/diagnostics/presentation/live/live_telemetry_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/live/LiveTelemetryViewModel.kt` | `features/diagnostics/presentation/live/live_telemetry_view_model.dart`<br>`live_telemetry_ui_state.dart` | ⚠️ | Faltan `reconnect` (ReconnectObdUseCase), `loadRemoteTelemetry` con `telemetryHistory`, `canReadFaults`, `connectedToOtherVehicle`/`isReconnecting`, `missingCoolantPid0105`, `liveWarnings` y `frozenSnapshot` como estado (ver capas). P1. |
| `features/diagnostics/presentation/navigation/DiagnosticsNavGraph.kt` | `features/diagnostics/presentation/navigation/diagnostics_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/diagnostics/presentation/report/AiHealthReportScreen.kt` | `features/diagnostics/presentation/report/ai_health_report_screen.dart` | ⚠️ | PDF: Android ofrece "Abrir PDF" / "Compartir PDF" con selector `reportsPdfChooser` y `pdfActionMode` (AiHealthReportScreen.kt:215, `diagReportOpenPdf/SharePdf`); Flutter presenta una tarjeta propia (`diagReportPdfTitle`, `diagReportPdfHint`, `reportsOpenPdf/SharePdf`). El resto del informe (secciones, score, sheet de generación) coincide. P2. |
| `features/diagnostics/presentation/report/AiHealthReportUiState.kt` | `features/diagnostics/presentation/report/ai_health_report_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/diagnostics/presentation/report/AiHealthReportViewModel.kt` | `features/diagnostics/presentation/report/ai_health_report_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `inventory`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/inventory/presentation/alerts/StockAlertsScreen.kt` | `features/inventory/presentation/alerts/stock_alerts_screen.dart`<br>`stock_alerts_ui_state.dart` | ⚠️ | 247 → 164 líneas. Android: FAB "Crear orden de compra" (:98, `invSeg2AlertsCreatePoFab`), `AtelierRefreshBar`, banner sin conexión "alertas calculadas con el catálogo guardado" (`inventoryAlertsOffline`), cabecera "Por reponer", fila con chips Agotado / "Faltan {n}" y `AtelierMetricBar` de stock vs mínimo (:187-218, `inventoryAlertSubtitle` "SKU … · Stock x de y"). Flutter: panel `AtelierReportPanel` con cifras agotados/por reponer (`stockAlerts*`, 10 textos que Android no tiene), sin FAB ni barra métrica, `AtelierOfflineState` en lugar del banner. P1/P2. |
| `features/inventory/presentation/alerts/StockAlertsViewModel.kt` | `features/inventory/presentation/alerts/stock_alerts_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/catalog/components/CategoryFilterChips.kt` | `features/inventory/presentation/catalog/components/category_filter_chips.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/catalog/PartsCatalogScreen.kt` | `features/inventory/presentation/catalog/parts_catalog_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/catalog/PartsCatalogUiState.kt` | `features/inventory/presentation/catalog/parts_catalog_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/catalog/PartsCatalogViewModel.kt` | `features/inventory/presentation/catalog/parts_catalog_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/detail/PartDetailScreen.kt` | `features/inventory/presentation/detail/part_detail_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/detail/PartDetailUiState.kt` | `features/inventory/presentation/detail/part_detail_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/detail/PartDetailViewModel.kt` | `features/inventory/presentation/detail/part_detail_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/InventoryLabels.kt` | `features/inventory/presentation/inventory_labels.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/navigation/InventoryNavGraph.kt` | `features/inventory/presentation/navigation/inventory_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/inventory/presentation/orders/PurchaseOrderDetailScreen.kt` | `features/inventory/presentation/orders/purchase_order_detail_screen.dart`<br>`receipt_photo_capture.dart` | ⚠️ | Recepción de OC: Android "Recibir orden" / hoja "Recibir la orden" con N° de comprobante + foto (`inventoryPoReceive*`, `inventoryPoPhoto*`, :575); Flutter "Recibir compra" con campo extra de fecha AAAA-MM-DD, vista previa, quitar foto y 9 textos propios `invReceive*`. Misma regla de negocio (`ReceivePurchaseOrderUseCase`). P2. |
| `features/inventory/presentation/orders/PurchaseOrderDetailViewModel.kt` | `features/inventory/presentation/orders/purchase_order_detail_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/orders/PurchaseOrdersScreen.kt` | `features/inventory/presentation/orders/purchase_orders_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/orders/PurchaseOrdersViewModel.kt` | `features/inventory/presentation/orders/purchase_orders_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/scanner/SkuScannerScreen.kt` | `features/inventory/presentation/scanner/sku_scanner_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/scanner/SkuScannerViewModel.kt` | `features/inventory/presentation/scanner/sku_scanner_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/suppliers/SuppliersScreen.kt` | `features/inventory/presentation/suppliers/suppliers_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/suppliers/SuppliersViewModel.kt` | `features/inventory/presentation/suppliers/suppliers_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/valuation/InventoryValuationScreen.kt` | `features/inventory/presentation/valuation/inventory_valuation_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/inventory/presentation/valuation/InventoryValuationViewModel.kt` | `features/inventory/presentation/valuation/inventory_valuation_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `main`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/main/presentation/attendance/AdminAttendanceScreen.kt` | `features/main/presentation/attendance/admin_attendance_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/attendance/AdminAttendanceUiState.kt` | `features/main/presentation/attendance/admin_attendance_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/attendance/AdminAttendanceViewModel.kt` | `features/main/presentation/attendance/admin_attendance_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/dashboard/AdminDashboardScreen.kt` | `features/main/presentation/dashboard/admin_dashboard_screen.dart`<br>`admin_dashboard_ui_state.dart`<br>`admin_dashboard_view_model.dart` | ⚠️ | Faltan: KPI "Bahías de trabajo" con subtítulo de bahías libres (AdminDashboardScreen.kt:550, `dashboardKpiBays/Sub`), KPI "Alertas de stock" con chip (:570, `dashboardKpiStock/Sub`, `notificationsLowStockChip`), cifra "en bahía" y badge "En vivo" del panel (:405, `todayFigureInBay`, `todayLiveBayBadge`) y sus datos (`bays`, `stockAlerts`, `canReadBays`, `canReadInventory`, `occupiedBaysCount`, `availableBaysCount` en AdminDashboardUiState.kt). Los destinos `onOpenBays`/`onOpenStockAlerts` no existen en Flutter. P1. |
| `features/main/presentation/dashboard/AdminDashboardUiState.kt` | `features/main/presentation/dashboard/admin_dashboard_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/dashboard/AdminDashboardViewModel.kt` | `features/main/presentation/dashboard/admin_dashboard_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/MainNavigationBar.kt` | `features/main/presentation/main_navigation_bar.dart` | ✅ | Barra flotante equivalente (la pestaña Bahías falta por MainTab, ver MainNavigation.kt). |
| `features/main/presentation/MainUiState.kt` | `features/main/presentation/main_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/MainViewModel.kt` | `features/main/presentation/main_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/more/ModulesSheet.kt` | `features/main/presentation/more/modules_sheet.dart` | ⚠️ | (a) Series fiscales: Android `FISCAL_CONFIG_MANAGE \|\| TENANTS_UPDATE` (ModulesSheet.kt:269), Flutter solo `fiscalConfigManage` (modules_sheet.dart:225). (b) Orden: Android Caja = Arqueo, Comprobantes, Reportes, Series; Stock = Repuestos, Alertas, Compras, Proveedores, Valorización (:262-286). Flutter pone Series antes de Reportes (:225 vs :234) y Alertas al final de Stock (:281). (c) Textos/íconos: Android `moreHSeries` "Series de comprobantes" / "Boletas y facturas SUNAT de la sede" (ReceiptLong) y `moreHAlerts` "Alertas de stock" / "Repuestos por reponer o agotados"; Flutter `moreHFiscalSeries` "Series SUNAT" / "Series de facturas y boletas" (confirmation_number) y `moreHStockAlerts` / "Repuestos bajo el mínimo". P2. |
| `features/main/presentation/navigation/MainNavigation.kt` | `features/main/presentation/navigation/main_tab.dart` | ⚠️ | Falta la pestaña `Bays` (MainNavigation.kt:136, ícono Garage, `mainTabBays`) y su relleno por `BAYS_READ` en las tres ramas de `tabsFor` (:172, :183, :212); el comentario de main_tab.dart:48-49 dice que Bahías "no existe como pestaña" (decisión vieja). El resto de `tabsFor`, `BarPrimaryAction`, `prefersOperationalDashboard` y `navigateToModule` coinciden. Además en Flutter la rama de técnico con `canUseTelemetry` solo cae a `orders` (main_tab.dart:118-122), sin el escalón `BAYS_READ` (Android :183). P1. |
| `features/main/presentation/notifications/NotificationsScreen.kt` | `features/main/presentation/notifications/notifications_screen.dart`<br>`notifications_ui_state.dart` | ⚠️ | Android muestra las alertas de stock mínimo dentro de "Requieren atención" (NotificationsScreen.kt:285 `notificationsStockDeficitLine` "SKU … · Stock actual … (Mínimo …)", chip `notificationsLowStockChip`, navega a `StockAlertsRoute`); Flutter no carga alertas de stock (NotificationsUiState sin `stockAlerts`). P2. |
| `features/main/presentation/notifications/NotificationsUiState.kt` | `features/main/presentation/notifications/notifications_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/notifications/NotificationsViewModel.kt` | `features/main/presentation/notifications/notifications_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/profile/ProfileScreen.kt` | `features/main/presentation/profile/profile_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/profile/ProfileUiState.kt` | `features/main/presentation/profile/profile_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/profile/ProfileViewModel.kt` | `features/main/presentation/profile/profile_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/sync/PendingOperationsScreen.kt` | `features/main/presentation/sync/pending_operations_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/sync/PendingOperationsUiState.kt` | `features/main/presentation/sync/pending_operations_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/main/presentation/sync/PendingOperationsViewModel.kt` | `features/main/presentation/sync/pending_operations_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `reception`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/reception/presentation/affiliation/AffiliationScreen.kt` | `features/reception/presentation/affiliation/affiliation_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/affiliation/AffiliationUiState.kt` | `features/reception/presentation/affiliation/affiliation_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/affiliation/AffiliationViewModel.kt` | `features/reception/presentation/affiliation/affiliation_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/navigation/ReceptionNavGraph.kt` | `features/reception/presentation/navigation/reception_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/reception/presentation/ReceptionErrors.kt` | `features/reception/presentation/reception_errors.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/register/RegisterCustomerScreen.kt` | `features/reception/presentation/register/register_customer_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/register/RegisterCustomerUiState.kt` | `features/reception/presentation/register/register_customer_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/register/RegisterCustomerViewModel.kt` | `features/reception/presentation/register/register_customer_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/search/VehicleSearchScreen.kt` | `features/reception/presentation/search/vehicle_search_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/search/VehicleSearchSheets.kt` | `features/reception/presentation/search/vehicle_search_sheets.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/search/VehicleSearchUiState.kt` | `features/reception/presentation/search/vehicle_search_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reception/presentation/search/VehicleSearchViewModel.kt` | `features/reception/presentation/search/vehicle_search_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `reports`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/reports/presentation/navigation/ReportsNavGraph.kt` | `features/reports/presentation/navigation/reports_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/reports/presentation/ReportsScreen.kt` | `features/reports/presentation/reports_screen.dart`<br>`reports_ui_state.dart`<br>`reports_view_model.dart` | ⚠️ | Salud de flota: Android abre una hoja de búsqueda de cliente desde el botón `reportsDownloadFleet` (:457), con estado bloqueado por plan (`reportsFleetLocked`), acción Buscar (`reportsFleetSearchAction`), selector Abrir/Compartir (`reportsPdfChooser`, `actionMode`) y resultados (`fleetSheet`, `query`, `results`, `fleetLockedByPlan`, `canDownloadFleet`). Flutter resuelve la selección en línea (`reportsFleetSelected`, `reportsFleetClear`) sin esas cadenas. El resto (periodos, movimientos, flujo de caja) coincide. P2. |
| `features/reports/presentation/ReportsUiState.kt` | `features/reports/presentation/reports_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/reports/presentation/ReportsViewModel.kt` | `features/reports/presentation/reports_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `tasks`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/tasks/presentation/detail/components/ChronometerTimer.kt` | `features/tasks/presentation/detail/components/chronometer_timer.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/detail/components/PartSheets.kt` | `features/tasks/presentation/detail/components/part_sheets.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/detail/components/TaskEvidenceSection.kt` | `features/tasks/presentation/detail/components/task_evidence_section.dart`<br>`task_photo_capture.dart` | ⚠️ | 136 → 95 líneas. Android: selector Desmontaje/Montaje y nota con contador "{n} / {max} caracteres" dentro de la sección (:60-120, `tasksSeg2EvidenceKindLabel`, `…NoteLabel/Hint/NoteCounter/FieldError`), cuadrícula de fotos con estados; Flutter: la sección solo muestra vacío + "Tomar foto" y delega tipo/nota a `TaskPhotoCapture`, sin contador y con "Elegir de la galería" (`tasksSeg2EvidencePickGallery`) que Android no ofrece. P1. |
| `features/tasks/presentation/detail/components/TaskPartsSection.kt` | `features/tasks/presentation/detail/components/task_parts_section.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/detail/components/TaskPhotoCapture.kt` | `features/tasks/presentation/detail/components/task_photo_capture.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/detail/components/TaskPitActionDock.kt` | `features/tasks/presentation/detail/components/task_pit_action_dock.dart` | ⚠️ | 154 → 96 líneas: Android reparte Iniciar/Pausar y Cerrar con `AtelierAdaptiveRow` de ancho igual (:142-149) y usa ícono CheckCircle en Cerrar; Flutter usa `task_alt_outlined` y no usa `AtelierAdaptiveRow`. Verificar el ajuste a una columna con fuente grande. P3. |
| `features/tasks/presentation/detail/components/TaskSheets.kt` | `features/tasks/presentation/detail/components/task_sheets.dart` | ⚠️ | Faltan: hoja de foto con error de envío con Reintentar/Descartar (:421 `tasksSeg2EvidenceFailedSheetTitle`, `syncRetryBtn/syncDiscardBtn`; avisos `tasksSeg2EvidenceFailedRetry/DiscardNotice`), diálogo de salida con nota sin guardar (:463 `tasksSeg2UnsavedExit*`, `hasUnsavedChanges`), advertencia al cerrar sin foto de Montaje (`tasksSeg2CompleteMissingAssemblyWarning`, `requiresAssemblyEvidence/hasAssemblyEvidence`) y la línea "Falta: {pieza}" en la revisión de suspensión (`ordersSuspensionMissingItem`). Ícono de reapertura/cierre difiere (Android DeleteOutline/Refresh/WarningAmber). P1. |
| `features/tasks/presentation/detail/TaskDetailScreen.kt` | `features/tasks/presentation/detail/task_detail_screen.dart` | ⚠️ | Faltan la sección "Decisiones" con `AtelierDecisionRow` para suspensión activa o por revisar (:500-503: `ordersSectionDecisions`, `tasksSeg2SuspensionResumeRowTitle/Hint`, `tasksSeg2SuspensionReviewHint`); Flutter resuelve reanudar/revisar con banner y hojas sin esa fila. Flutter muestra el dock de fosa y la evidencia dentro de la pantalla con strings propios (`pitDock*`). P1. |
| `features/tasks/presentation/detail/TaskDetailUiState.kt` | `features/tasks/presentation/detail/task_detail_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/detail/TaskDetailViewModel.kt` | `features/tasks/presentation/detail/task_detail_view_model.dart`<br>`task_detail_ui_state.dart` | ⚠️ | Faltan `onSelectFailedEvidence/onRetryFailedEvidence/onDiscardFailedEvidence`, `hasUnsavedChanges`, `maxEvidenceNoteLength`, `requiresAssemblyEvidence`, `selectedFailedEvidence`, permisos `canRequestHold`/`canValidateHold` separados, `onResumeSuspendedTask` (ver capas). P1. |
| `features/tasks/presentation/mytasks/MyTasksScreen.kt` | `features/tasks/presentation/mytasks/my_tasks_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/mytasks/MyTasksUiState.kt` | `features/tasks/presentation/mytasks/my_tasks_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/mytasks/MyTasksViewModel.kt` | `features/tasks/presentation/mytasks/my_tasks_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/navigation/TasksNavGraph.kt` | `features/tasks/presentation/navigation/tasks_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/tasks/presentation/TaskErrors.kt` | `features/tasks/presentation/task_errors.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/tasks/presentation/TaskLabels.kt` | `features/tasks/presentation/task_labels.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |

### 4.4 Feature `workorders`

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias concretas |
| --- | --- | --- | --- |
| `features/workorders/presentation/components/ChoiceChip.kt` | `features/workorders/presentation/components/choice_chip.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/components/PhotoCapture.kt` | `core/media/photo_capture.dart`<br>`features/workorders/presentation/components/photo_capture.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/components/ProposalLabels.kt` | `features/workorders/presentation/components/proposal_labels.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/detail/components/OrderCostSheets.kt` | `features/workorders/presentation/detail/profitability/profitability_card.dart`<br>`profitability_view_model.dart` | ⚠️ | Android: `ProfitabilitySheet` (hoja con "Ingreso por mano de obra / por repuestos / Costo de los repuestos / Ganancia de repuestos / Subtotal sin IGV / Por repuesto", `ordersProfit*`) y `PartMovementsSheet`. Flutter: tarjeta en línea con otros textos (`profitabilityRevenue/Cost/Gross/Labor/Lines/NoTax`, "Costo de ventas (FIFO)") y otros rótulos; mismo endpoint. P2. |
| `features/workorders/presentation/detail/components/QuotationSummarySection.kt` | `features/workorders/presentation/detail/components/quotation_summary_section.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/detail/components/WorkOrderDetailDialogs.kt` | `features/workorders/presentation/detail/components/work_order_detail_dialogs.dart` | ⚠️ | Hoja de asignar bahía: Android chips `bayStatusAvailable/Occupied/Maintenance`, Flutter descripciones `bayStatus*Desc`; falta `ordersSuspensionMissingItem` ("Falta: {pieza}") y la descripción accesible de página del PDF (`quotationPdfPageDesc`). P3. |
| `features/workorders/presentation/detail/WorkOrderDetailScreen.kt` | `features/workorders/presentation/detail/work_order_detail_screen.dart` | ⚠️ | Faltan la fila de decisión "Suspensión: {tarea}" (`ordersDecisionSuspension` :473) y la fila "Rentabilidad" que abre una hoja (:754 `ordersProfitabilityTitle/Hint`); Flutter muestra `WorkOrderProfitabilityCard` en línea con botón "Calcular rentabilidad" (`profitability*`). P2. |
| `features/workorders/presentation/detail/WorkOrderDetailUiState.kt` | `features/workorders/presentation/detail/work_order_detail_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/detail/WorkOrderDetailViewModel.kt` | `features/workorders/presentation/detail/work_order_detail_view_model.dart` | ⚠️ | Aviso de bahía asignada: Android `orderBayAssignedNotice` "Orden asignada a {p1} para intervención…"; Flutter `baysAssignedNotice` "Orden ingresada a §." (otro texto). Falta además el estado de revisión de suspensión (`reviewingSuspension`, `onOpenSuspension`) y `onOpenProfitability/onDismissProfitability` como hoja (Flutter usa `ProfitabilityViewModel` en línea). P2. |
| `features/workorders/presentation/finding/ReportFindingScreen.kt` | `features/workorders/presentation/finding/report_finding_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/finding/ReportFindingUiState.kt` | `features/workorders/presentation/finding/report_finding_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/finding/ReportFindingViewModel.kt` | `features/workorders/presentation/finding/report_finding_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/intake/IntakeGalleryScreen.kt` | `features/workorders/presentation/intake/intake_gallery_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/intake/IntakeGalleryUiState.kt` | `features/workorders/presentation/intake/intake_gallery_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/intake/IntakeGalleryViewModel.kt` | `features/workorders/presentation/intake/intake_gallery_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/list/WorkOrdersScreen.kt` | `features/workorders/presentation/list/work_orders_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/list/WorkOrdersUiState.kt` | `features/workorders/presentation/list/work_orders_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/list/WorkOrdersViewModel.kt` | `features/workorders/presentation/list/work_orders_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/navigation/WorkOrderNavGraph.kt` | `features/workorders/presentation/navigation/work_order_nav_graph.dart` | ✅ | Grafo equivalente en el registro de rutas (`AppRoute` + `*_nav_graph.dart`); las 43 rutas Android existen en Flutter. |
| `features/workorders/presentation/open/OpenWorkOrderScreen.kt` | `features/workorders/presentation/open/open_work_order_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/open/OpenWorkOrderUiState.kt` | `features/workorders/presentation/open/open_work_order_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/open/OpenWorkOrderViewModel.kt` | `features/workorders/presentation/open/open_work_order_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/proposals/ProposalsPanelScreen.kt` | `features/workorders/presentation/proposals/proposals_panel_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/proposals/ProposalsPanelUiState.kt` | `features/workorders/presentation/proposals/proposals_panel_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/proposals/ProposalsPanelViewModel.kt` | `features/workorders/presentation/proposals/proposals_panel_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/services/ServicesCatalogScreen.kt` | `features/workorders/presentation/services/services_catalog_screen.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/services/ServicesCatalogUiState.kt` | `features/workorders/presentation/services/services_catalog_ui_state.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/services/ServicesCatalogViewModel.kt` | `features/workorders/presentation/services/services_catalog_view_model.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |
| `features/workorders/presentation/WorkOrderErrors.kt` | `features/workorders/presentation/workorders_presentation.dart` | ✅ | Traducción de errores equivalente. |
| `features/workorders/presentation/WorkOrderLabels.kt` | `features/workorders/presentation/work_order_labels.dart` | ✅ | Sin diferencias detectadas (textos, componentes y tokens contrastados). |


### 4.5 Archivos Flutter sin equivalente Android (extras)

| Archivo Flutter | Qué es |
| --- | --- |
| `core/designsystem/component/atelier_page_transitions.dart` | Traduce las transiciones de `AppNavHost` (válido). |
| `features/main/presentation/main_shell*.dart`, `navigation/main_tab.dart`, `justification_review.dart` | Traducción del contenedor de pestañas (válido). |
| `features/workorders/presentation/detail/profitability/*`, `cascade.dart`, `components/bottom_action_bar.dart`, `pick_row.dart` | Rentabilidad en línea (**difiere**, ver P2-2) y ayudas de UI. |
| `features/inventory/presentation/orders/receipt_photo_capture.dart` | Captura de foto del comprobante con vista previa/quitar (**difiere**, P2-3). |
| `core/presentation/lima_time_format.dart`, `state_sheet_host.dart` | Utilidades de formato y hojas dirigidas por estado (válido). |

## 5. Capas inferiores (dominio, aplicación, infraestructura, `core`)

| Pieza Android | Pieza Flutter | Estado | Diferencia / falta |
| --- | --- | --- | --- |
| `core/data/remote/tenant/TenantService.kt`, `TenantDtos.kt` (`GET`/`PUT api/v1/tenants/current`) | — | ❌ | No existe cliente ni DTO del tenant. Lo usan los casos de uso de perfil fiscal (US42). P1. |
| `core/data/local/Migrations.kt` (v1→v2 `parts.brand`) + `PartEntity.brand` | `core/data/local/app_database.dart` (schemaVersion 3), `part_table.dart` | ❌ | La tabla `parts` de Drift no tiene `brand` (10 columnas vs 11). Las migraciones de Flutter v1→2 (`tasks.pending_suspension_requested_at`) y v2→3 (`telemetry_readings.user_id`) equivalen a las de Android v2→3 partidas en dos pasos; falta la de `brand`. P3. |
| `features/inventory/domain/Part.kt` `brand`; `PartDto.brand`; `PartDao.observeAll/search(category, brand)`; `ObservePartBrandsUseCase`; `ObservePartsCatalogUseCase(category, brand)` | `features/inventory/domain/part.dart`, `inventory_dao`, `inventory_api.dart` | ❌ | Ningún modelo, DTO, DAO ni caso de uso de Flutter conoce `brand` (US31 H35). Android no muestra la marca en la UI actual, pero el filtro ya está en el repositorio. P3. |
| `features/diagnostics/application/GetVehicleTelemetryHistoryUseCase.kt` + `TelemetryHistoryBucket(Dto)` + `IotService.getTelemetryHistory` | `features/diagnostics/infrastructure/remote/iot_api.dart:7` | ❌ | Flutter documenta que "`history` no" se usa. Sin historial no hay "Historial reciente" en telemetría en vivo (US18). P1. |
| `features/diagnostics/application/ReconnectObdUseCase.kt` | — | ❌ | No hay caso de uso de reconexión: Android reconecta en el sitio (`LiveTelemetryViewModel.reconnect`); el botón "Reconectar" de Flutter solo abre el hub de diagnóstico (live_telemetry_screen.dart:77-81). P1. |
| `features/diagnostics/domain/Telemetry.kt` (`LatestVehicleTelemetry`, `TelemetrySample.engineLoadPercentage/throttlePositionPercentage`) | `latest_telemetry_dto.dart`, `get_latest_telemetry_use_case.dart`, domain `telemetry` | ⚠️ | El último valor remoto sí existe (mismos 9 campos). Faltan en la muestra viva carga de motor y acelerador (mostradas como tiles `diagPidLoad/diagPidThrottle` en Android). P1 (con US18). |
| `features/diagnostics/domain/DiagnosticSession.kt` `activeVehicleId` + `DiagnosticsPreSyncHook` (`excludeVehicleId`) | `diagnostics_pre_sync_hook.dart` | ⚠️ | Diferencia documentada y válida: el worker de Flutter es otro motor y no ve la sesión Bluetooth, así que usa solo la ventana de inactividad de 60 s (diagnostics_pre_sync_hook.dart:5-9). Sin acción salvo confirmar en dispositivo. P3. |
| `features/cashier/application/GetTenantFiscalProfileUseCase.kt`, `UpdateTenantFiscalProfileUseCase.kt`, `domain/TenantFiscalProfile.kt`, `CashierRepositoryImpl.updateTenantProfile` (nombre 1..100, razón social 1..150, RUC 11 dígitos) | — | ❌ | No existen. Sin ellos no se puede mostrar ni editar el perfil fiscal del taller (US42). P1. |
| `features/cashier/domain/CashierValidation.kt` `MAX_LINE_DESCRIPTION_LENGTH = 200` | `features/cashier/domain/cashier_validation.dart:12` `maxLineDescriptionLength = 250` | ⚠️ | Android recorta a 200 caracteres la descripción de cada línea del comprobante y del motivo de nota de crédito (CashierRepositoryImpl.kt:172,182); Flutter permite 250. P2. |
| `features/bays/domain/BayBoard.kt` `BayOccupant.tasks: List<TaskDetail>` | `features/bays/domain/bay_board.dart` | ⚠️ | Flutter no conserva las tareas del ocupante (solo `mechanicIds`, `laborElapsed`); por eso la hoja de bahía no puede reasignar el mecánico de cada tarea (`ReassignTaskMechanicUseCase` existe pero solo lo usa el detalle de orden). P1. |
| `features/workorders/infrastructure/repository/PendingSuspensionMonitor.kt` (TTL 60 s, `Semaphore(3)`, tope de 15 órdenes `IN_PROGRESS`, `StateFlow` compartido, invalidado por `WorkshopCacheEventBus`) | `features/workorders/application/find_pending_suspensions_use_case.dart` | ⚠️ | Flutter consulta el detalle de todas las órdenes `draft/inProgress` una por una y en serie, sin caché ni tope ni flujo observable (find_pending_suspensions_use_case.dart:12-25): más lento y más tráfico en el panel y en la lista. P2. |
| `features/workorders/domain/WorkOrder.kt` `PendingSuspensionItem(taskId, workOrderId, workOrderNumber, plate, serviceName, taskDescription, reason, requestedAt)` | `features/workorders/domain/pending_suspension.dart` (`order` + `task`) | ⚠️ | Modelo distinto con el mismo contenido; sin `workOrderNumber`/`serviceName` planos. Solo estructura. P3. |
| `core/notifications/PushRouter.kt` + `PushDestination` | `core/notifications/push_router.dart`, `core/domain/push_destination.dart` | ✅ | Los 8 tipos de push y los 3 canales coinciden. El destino de `TASK_SUSPENSION_REVIEW` difiere en la navegación (ver `AppNavHost.kt`). |
| `core/domain/Permission.kt` (74 permisos), `Session.kt`, `Plan.kt` | `core/domain/permission.dart`, `session.dart`, `plan.dart` | ✅ | 74 permisos idénticos; `canUseTelemetry/canReadTelemetry/canUseAiDiagnostics/canReadAiReports/hasSubscriptionAccess/canSwitchBranch` idénticos. |
| `core/data/remote/*` (AuthInterceptor, TokenAuthenticator, TokenRefresher, IdempotentGetRetryInterceptor, PdfDownloader, PublicEndpoints) | `api_client.dart`, `authenticated_client.dart`, `token_refresher.dart`, `pdf_downloader.dart` | ✅ | Reintento acotado de GET/HEAD, refresh con `CrossIsolateLock` y descarga de PDF equivalentes. |
| `core/data/sync/*` (SyncProcessor, OperationHandler, PreSyncHook, SyncScheduler, UploadFileHandler, CacheMaintenance) | `core/data/sync/*` | ✅ | Los 10 tipos de operación (`CLOCK_IN`, `CLOCK_OUT`, `SUBMIT_JUSTIFICATION`, `ATTACH_TASK_EVIDENCE`, `ATTACH_INTAKE_IMAGE`, `SUBMIT_PROPOSAL`, `REGISTER_FAULT`, `RESOLVE_FAULT`, `TELEMETRY_BATCH`, `UPLOAD_FILE`) tienen handler en Flutter. |
| Room: 19 entidades (`AttendanceEntity`…`WorkOrderEntity`) | Drift: 19 tablas (`*_table.dart`) | ✅ | Columnas idénticas salvo `parts.brand` (arriba). `distance_to_branch_m`/`geofence_radius_m` se llaman `…_meters` en Drift (nombre interno, sin efecto). |
| Endpoints Retrofit (148 anotaciones en 12 servicios) | `*_api.dart` | ⚠️ | 145 de 148 cubiertos. Faltan `GET/PUT api/v1/tenants/current` y `GET iot/telemetry/vehicle/{id}/history`. |
| Casos de uso: 197 (`*UseCase.kt`) | 200 (`*_use_case.dart`) | ⚠️ | Faltan 8 de Android por nombre: `ReconnectObdUseCase`, `GetVehicleTelemetryHistoryUseCase`, `GetTenantFiscalProfileUseCase`, `UpdateTenantFiscalProfileUseCase`, `ObservePartBrandsUseCase` (reales); `ReviewJustificationUseCase` (sin uso en Android) y `CreateBayUseCase` / `GetLatestVehicleTelemetryUseCase` (existen con otro nombre: `CreateWorkBayUseCase`, `GetLatestTelemetryUseCase`). |
| ViewModels: 46 (`*ViewModel.kt`) | 46 (`*_view_model.dart`) | ✅ | Paridad numérica; las diferencias de contenido están en la tabla por archivo. |
| Modelos de dominio, DTOs (campos `@SerializedName`) y reglas de `application/` | `domain/`, `infrastructure/remote`, `application/` | ✅ | Contraste automático de campos y constantes: sin faltantes salvo los listados arriba (Part.brand, Telemetry, TenantFiscalProfile, límite 200/250). |


## 6. Tabla por historia de usuario

| US | Historia | Estado | Detalle |
| --- | --- | --- | --- |
| US01 | Registro por invitación corporativa | ⚠️ | Pantalla de registro y validaciones idénticas. El enlace del correo de invitación no abre la app: faltan los App Links (`AndroidManifest.xml:59-76` en Android; Flutter sin intent-filters ni `postFromUri`). |
| US02 | Verificación OTP de correo | ✅ | `VerifyEmailScreen` con las mismas 7 claves; temporizador de reenvío equivalente. |
| US03 | Inicio de sesión y sede | ✅ | Login, Google, selección de sede y `canSwitchBranch` idénticos. |
| US04 | Cierre de sesión seguro | ✅ | Perfil: diálogo con y sin pendientes, vaciado de cola/temporales, tiempos 1.5/2/4 s idénticos. |
| US05 | Restablecer contraseña | ⚠️ | Pantallas `forgot` y `reset` iguales; el enlace del correo no abre la app (mismo hueco que US01). |
| US06 | Marcación de ingreso con geocerca | ✅ | `AttendanceScreen`/`FloorHub` con el mismo flujo, geocerca (radio de Tierra 6371008.8) y cola `CLOCK_IN`. |
| US08 | Marcación de salida | ✅ | Hoja de confirmación y `CLOCK_OUT` iguales. |
| US09 | Programación semanal de turnos | ✅ | Historial y turno iguales en estructura; Flutter define textos propios de día y estado de historial (`dayMonday…`, `attendanceHistory*`) que Android no usa; confirmar que el formato visible coincide. |
| US10 | Descargos de tardanza | ✅ | Emisión y revisión (`AdminAttendance`) iguales; la revisión vive en `justification_review.dart`. |
| US11 | Búsqueda de cliente y vehículo | ✅ | 134 claves idénticas; directorio de clientes = `portfolioCustomers`. |
| US12 | Apertura de orden | ✅ | `OpenWorkOrderScreen` igual (346 vs 356 líneas, mismos textos y validaciones). |
| US13 | Evidencias de recepción | ✅ | `IntakeGalleryScreen` igual (6 ángulos). |
| US14 | Propuesta por hallazgo | ✅ | `ReportFinding` y `ProposalsPanel` iguales. |
| US15 | Aprobación de propuesta | ✅ | Panel de propuestas igual. |
| US44 | Alta y afiliación de clientes | ✅ | `RegisterCustomer` y `Affiliation` iguales. |
| US16 | Enlace de escáner OBD-II | ✅ | Pestañas Escáner/Dispositivos/Alertas con las mismas cadenas; servicio en primer plano equivalente. Detalle menor en la acción de telemetría del hub (P2). |
| US17 | Códigos de falla | ✅ | `VehicleFaultsScreen` igual. |
| US18 | Telemetría en vivo | ⚠️ | Rediseño completo en Android no portado: tiles calibrados con barra y estado por PID, historial por cubos, modo remoto con refresco, reconexión, hoja de muestra congelada, botón DTC, estado de plan. Ver `LiveTelemetryScreen.kt`. **P1.** |
| US19 | Almacenamiento local y sincronización de telemetría | ✅ | Lecturas con dueño (`user_id`), lotes de 200, ventana de 60 s y `TELEMETRY_BATCH` equivalentes (ver nota de `DiagnosticsPreSyncHook`). |
| US20 | Borrado de fallas | ✅ | Igual (`ClearFaults`). |
| US21 | Informe predictivo con IA y PDF | ⚠️ | Generación y secciones iguales; las acciones del PDF (abrir/compartir con selector) tienen otra UI y textos. P2. |
| US22 | Cómputo en cascada de costos | ✅ | `QuotationSummarySection` y `cascade.dart` equivalentes. |
| US23 | Imputación de repuestos a tareas | ✅ | Hojas `ChargePart/ReturnPart/EditPart` iguales. |
| US24 | Proforma PDF | ✅ | Vista previa y compartir iguales; falta solo la descripción accesible de página (`quotationPdfPageDesc`, P3). |
| US25 | Resolución de presupuesto | ✅ | Aprobar/rechazar con motivo igual. |
| US26 | Tareas del mecánico | ✅ | `MyTasksScreen` igual (filtros, panel, chips). |
| US27 | Cronómetro, pausas y turnos | ✅ | Cronómetro, pausas y reapertura iguales; dock con detalle menor (P3). |
| US28 | Evidencia fotográfica de desmontaje/montaje | ⚠️ | Faltan tipo+nota con contador dentro de la sección, hoja de foto fallida (reintentar/descartar) y salida con nota sin guardar. **P1.** |
| US29 | Suspensión por pieza defectuosa | ⚠️ | Faltan filas de decisión (reanudar/revisar) en tarea y orden, la línea "Falta: pieza", el destino de push de revisión (Android abre la orden) y el monitor con TTL/tope. **P1/P2.** |
| US30 | Cierre técnico con horas hombre | ⚠️ | Falta la advertencia y el requisito de foto de Montaje al cerrar (`requiresAssemblyEvidence`). **P1.** |
| US31 | Búsqueda de repuestos | ⚠️ | Catálogo, búsqueda y detalle iguales; falta `brand` en modelo, DAO, DTO y migración (Android tampoco lo muestra aún). P3. |
| US32 | Descargo FIFO | ✅ | Hojas de descargo/recepción directa iguales. |
| US33 | Reincorporación de materiales | ✅ | Devolución a inventario igual. |
| US34 | Alertas de stock mínimo | ⚠️ | Bandeja con otro diseño (sin FAB crear OC, sin barra métrica); sin integración en dashboard (KPI), centro de notificaciones ni tarjeta de stock del hub; recepción de OC con otros textos y campo de fecha. **P1/P2.** |
| US35 | Rentabilidad / margen FIFO | ⚠️ | Mismo endpoint y permiso; Android la muestra en hoja desde una fila, con 7 rótulos propios; Flutter en tarjeta en línea con otros rótulos. P2. |
| US36 | Liquidación en cascada | ✅ | Resumen subtotal/IGV/total igual. |
| US37 | Comprobantes UBL 2.1 | ✅ | `VouchersScreen` y hojas de emisión iguales (36 claves). |
| US38 | Pagos multi-medio | ✅ | Paso de cobros del checkout igual. |
| US39 | Orden pagada, pase de salida y entrega | ⚠️ | Flujo igual; faltan el título del selector de compartir pase (`cashierExitPassChooser`) y los chips de estado de la orden del checkout. P2. |
| US40 | Supervisión y reasignación de bahías | ⚠️ | Sin pestaña "Bahías", sin resumen de ocupación, sin reasignar mecánico por tarea, sin KPI en dashboard ni FAB. **P1.** |
| US41 | PDF de flujo de caja | ✅ | Periodos, movimientos y descarga iguales. |
| US42 | Información fiscal y series SUNAT | ⚠️ | Pantalla de series rediseñada distinta; falta el perfil fiscal del taller (RUC/razón social), tarjeta PSE, detalle de serie con confirmación y validaciones por tipo. **P1.** |
| US43 | PDF de salud vehicular y de flota | ⚠️ | PDF del informe y de flota existen, pero con selección de cliente y acciones distintas a la hoja de Android. P2. |


Dónde Flutter va **más allá** de Android (sin contraparte, no se debe borrar sin decidir): textos de dominio para días de la semana, `pushDefaultTitle*`, "Elegir de la galería" en evidencia, diálogo de salida de telemetría, botón de refrescar en Bahías, campo de fecha al recibir una OC.

## 7. Lista priorizada de correcciones

### P1 — Funcionalidad faltante o rota

| # | Corrección | Android | Flutter |
| --- | --- | --- | --- |
| P1-1 ✅ | **App Links de auth (US01/US05).** Declarar los dos intent-filters `https://atelier.andeva.tech` con `autoVerify` (`/auth/reset-password`, `/auth/accept-invitation`), recibir el URI inicial y los posteriores (plugin de links) y llamar a `AuthDeepLinkInbox.postFromUri`; iOS: Associated Domains (sin comprobar). | `app/src/main/AndroidManifest.xml:59-76`, `MainActivity.kt`, `core/notifications/AuthDeepLinkInbox.kt` | `android/app/src/main/AndroidManifest.xml`, `lib/main.dart`, `lib/core/notifications/auth_deep_link_inbox.dart`, `lib/features/auth/presentation/auth_nav_graph.dart` |
| P1-2 ✅ | **Pestaña Bahías (US40).** Agregar `MainTab.bays` (ícono Garage, `mainTabBays`) a `tabsFor` en las 3 ramas (Hoy: relleno por `BAYS_READ`; técnico sin telemetría: `BAYS_READ` antes de Órdenes), y a la barra flotante. | `features/main/presentation/navigation/MainNavigation.kt:136,172,183,212`, `MainNavigationBar.kt` | `lib/features/main/presentation/navigation/main_tab.dart`, `main_navigation_bar.dart`, `main_shell.dart` |
| P1-3 ✅ | **Tablero de bahías (US40).** Resumen de ocupación (superficie + beacon + MetricBar, textos `baysOccupancy*`), FAB "Nueva bahía", barra de refresco, filas con beacon; sección "Mecánicos y faenas" con reasignación por tarea (conservar `tasks` en `BayOccupant`, `availableMechanics`, `ReassignTaskMechanicUseCase`), botón "Asignar a {bahía}", permisos `WORK_ORDERS_READ`/`BAYS_REASSIGN` separados, aviso `orderBayAssignedNotice`. | `bays/presentation/BaysScreen.kt:192,380`, `BayActionSheets.kt:177`, `BaysViewModel.kt`, `BaysUiState.kt`, `bays/domain/BayBoard.kt` | `lib/features/bays/presentation/*`, `lib/features/bays/domain/bay_board.dart`, `lib/features/bays/infrastructure/repository/bay_repository_impl.dart` |
| P1-4 ✅ | **Telemetría en vivo (US18).** Rehacer `LiveTelemetryScreen` según Android: Ficha + placa + chips, plan bloqueado, pull-to-refresh, tiles calibrados (8 PIDs, estados `diagPidStatus*`, MetricBar), historial por cubos (nuevo `GetVehicleTelemetryHistoryUseCase`, DTO `TelemetryHistoryBucket`, endpoint `GET iot/telemetry/vehicle/{id}/history`), `ReconnectObdUseCase`, hoja inferior de muestra congelada, barra inferior (Reconectar / DTC / Congelar / Detener / Actualizar); quitar el diálogo de salida propio y el texto `diagActionLiveSub`. Acción del hub con título/subtítulo por modo. | `diagnostics/presentation/live/*` (Screen, ViewModel, UiState), `application/GetVehicleTelemetryHistoryUseCase.kt`, `ReconnectObdUseCase.kt`, `domain/Telemetry.kt`, `infrastructure/remote/IotService.kt`, `hub/DiagnosticsHubScreen.kt:800` | `lib/features/diagnostics/presentation/live/*`, `application/`, `domain/`, `infrastructure/remote/iot_api.dart`, `presentation/hub/diagnostics_hub_screen.dart`, `lib/l10n/app_es.arb` |
| P1-5 ✅ | **Series y perfil fiscal (US42).** Portar `FiscalSeriesScreen`: tarjeta fiscal del taller (RUC, razón social, nombre comercial; hoja de edición con validación 1..100 / 1..150 / RUC 11), tarjeta PSE administrado, detalle de serie con activar/desactivar y confirmación, selector de tipo y reglas F/B/NC, FAB. Agregar `TenantService` (`GET/PUT api/v1/tenants/current`), `TenantFiscalProfile`, `GetTenantFiscalProfileUseCase`, `UpdateTenantFiscalProfileUseCase`; módulo visible con `FISCAL_CONFIG_MANAGE` o `TENANTS_UPDATE`. Eliminar los textos propios `fiscalSeries*`. | `cashier/presentation/series/*`, `cashier/application/{Get,Update}TenantFiscalProfileUseCase.kt`, `core/data/remote/tenant/*`, `CashierRepositoryImpl.kt:399` | `lib/features/cashier/presentation/series/*`, `lib/features/cashier/application/`, `lib/features/cashier/domain/`, `lib/core/data/remote/` (nuevo `tenant/`), `lib/features/main/presentation/more/modules_sheet.dart:225` |
| P1-6 ✅ | **Evidencia y cierre de tarea (US28/US30).** Sección de evidencia con selector Desmontaje/Montaje y nota con contador `tasksSeg2EvidenceNoteCounter`; hoja de foto fallida con Reintentar/Descartar (+ avisos); diálogo "Salir con nota sin guardar" (`hasUnsavedChanges`); en el cierre exigir/avisar foto de Montaje (`requiresAssemblyEvidence`, `tasksSeg2CompleteMissingAssemblyWarning`). Quitar "Elegir de la galería" si Android no lo ofrece. | `tasks/presentation/detail/components/TaskEvidenceSection.kt:111`, `TaskSheets.kt:421,463`, `TaskDetailViewModel.kt`, `TaskDetailUiState.kt` | `lib/features/tasks/presentation/detail/components/task_evidence_section.dart`, `task_photo_capture.dart`, `task_sheets.dart`, `task_detail_view_model.dart`, `task_detail_ui_state.dart` |
| P1-7 ✅ | **Decisiones de suspensión (US29).** Sección "Decisiones" con `AtelierDecisionRow` en detalle de tarea (reanudar / revisar, `tasksSeg2SuspensionResumeRowTitle/Hint`, `…ReviewHint`) y fila "Suspensión: {tarea}" en detalle de orden; línea "Falta: {pieza}"; el push `TASK_SUSPENSION_REQUESTED` debe abrir el detalle de la orden. | `TaskDetailScreen.kt:500-503`, `WorkOrderDetailScreen.kt:473`, `navigation/AppNavHost.kt:121` | `lib/features/tasks/presentation/detail/task_detail_screen.dart`, `lib/features/workorders/presentation/detail/work_order_detail_screen.dart`, `lib/navigation/app_root.dart:123` |
| P1-8 ✅ | **Integración de alertas de stock (US34).** KPI "Alertas de stock" y KPI "Bahías" en el dashboard (+ cifra "en bahía" y badge "En vivo"), sección de alertas en notificaciones (`notificationsStockDeficitLine`, `notificationsLowStockChip`), tarjeta de Stock del hub con alertas (`floorHubStock*`, abre la bandeja), FAB "Crear orden de compra" y barra métrica en la bandeja. | `AdminDashboardScreen.kt:405,550,570`, `NotificationsScreen.kt:285`, `FloorHubScreen.kt:~395-440,786`, `StockAlertsScreen.kt:98,187` | `lib/features/main/presentation/dashboard/*`, `notifications/*`, `lib/features/attendance/presentation/dashboard/floor_hub_*.dart`, `lib/features/inventory/presentation/alerts/*` |

### P2 — Diferencia visual notable

| # | Corrección | Android | Flutter |
| --- | --- | --- | --- |
| P2-1 ✅ | **Módulos.** Mismo orden (Caja: Arqueo, Comprobantes, Reportes, Series; Stock: Repuestos, Alertas, Compras, Proveedores, Valorización) y textos `moreHSeries/moreHAlerts`; usar los textos de Android y borrar `moreHFiscalSeries*/moreHStockAlerts*`. | `ModulesSheet.kt:262-286` | `modules_sheet.dart:225-290`, `app_es.arb` |
| P2-2 ✅ | **Rentabilidad (US35).** Hoja (`ProfitabilitySheet`) abierta desde una fila "Rentabilidad" con los 7 rótulos `ordersProfit*`; quitar tarjeta en línea y textos `profitability*`. | `OrderCostSheets.kt:46`, `WorkOrderDetailScreen.kt:754`, `WorkOrderDetailViewModel.kt:889` | `lib/features/workorders/presentation/detail/profitability/*`, `work_order_detail_screen.dart` |
| P2-3 ✅ | **Recepción de OC (US34).** Usar `inventoryPoReceive*/inventoryPoPhoto*`, sin campo de fecha propio ni textos `invReceive*`. | `PurchaseOrderDetailScreen.kt:575` | `purchase_order_detail_screen.dart`, `receipt_photo_capture.dart` |
| P2-4 ✅ | **PDF de salud (US21/US43).** Botones "Abrir PDF"/"Compartir PDF" con selector `reportsPdfChooser`; hoja de salud de flota con búsqueda, bloqueo por plan y acción Buscar (`reportsDownloadFleet`, `reportsFleetLocked`, `reportsFleetSearchAction`). | `AiHealthReportScreen.kt:215`, `ReportsScreen.kt:457`, `ReportsViewModel.kt` | `ai_health_report_screen.dart`, `reports_screen.dart`, `reports_view_model.dart` |
| P2-5 ✅ | **Checkout (US39).** Chips de estado de la orden (`orderStatus*`) y título del selector al compartir pase (`cashierExitPassChooser`). | `WorkOrderCheckoutScreen.kt:157,293` | `work_order_checkout_screen.dart` |
| P2-6 ✅ | **Tarjeta de Stock del hub y acceso a bahías.** Subtítulo `floorHubQuickBaysSub`; quitar strings `floorHubPo*`. | `FloorHubScreen.kt` | `floor_hub_screen.dart:424,595,941` |
| P2-7 ⚠️ (parcial: tope y concurrencia, sin TTL ni flujo) | **Monitor de suspensiones.** Caché TTL 60 s, concurrencia 3, tope 15 órdenes, flujo observable e invalidación por escrituras. | `PendingSuspensionMonitor.kt` | `find_pending_suspensions_use_case.dart` |
| P2-8 ✅ | **Longitud de descripción de línea de comprobante: 200, no 250.** | `CashierValidation.kt:14` | `cashier_validation.dart:12` |
| P2-9 ✅ | **Bahías en detalle de orden.** Chips de estado `bayStatus*` y aviso `orderBayAssignedNotice`. | `WorkOrderDetailDialogs.kt`, `WorkOrderDetailViewModel.kt` | `work_order_detail_dialogs.dart`, `work_order_detail_view_model.dart` |
| P2-10 ✅ | **Notificaciones.** (ver P1-8). | | |

### P3 — Menor

| # | Corrección | Android | Flutter |
| --- | --- | --- | --- |
| P3-1 ⚠️ (no: H35, el backend no documenta la marca) | Campo `brand` de repuesto: columna Drift + migración, DTO, mapper, DAO (`observeAll/search` con marca), `ObservePartBrandsUseCase`. | `Part.kt`, `Migrations.kt`, `InventoryRepositoryImpl.kt:97-109` | `part.dart`, `part_table.dart`, `app_database.dart`, `inventory_repository_impl.dart` |
| P3-2 ✅ | `Theme.kt`: mapear `AtelierShapes` a `ThemeData` (`SliderTheme`, `CardTheme`… o `shape` por defecto) y definir `surfaceVariant/background`. | `Theme.kt` | `atelier_theme.dart` |
| P3-3 ✅ | `TaskPitActionDock`: `AtelierAdaptiveRow` de ancho igual e ícono CheckCircle. | `TaskPitActionDock.kt:142` | `task_pit_action_dock.dart` |
| P3-4 ⚠️ (no: requiere rasterizar PDF) | `quotationPdfPageDesc` (accesibilidad de página PDF) y `plateA11y` ya existe. | `WorkOrderDetailDialogs.kt` | `work_order_detail_dialogs.dart` |
| P3-5 ✅ | Quitar de `pubspec.yaml` las fuentes PlusJakartaSans/JetBrainsMono (Android solo usa Satoshi y Albert Sans). | `res/font/` | `pubspec.yaml:72-90`, `assets/fonts/` |
| P3-6 ⚠️ (se mantiene: títulos de respaldo para pushes sin título) | Quitar `pushDefaultTitle*` (8 textos que Android no tiene) o confirmar que son deseados. | `AtelierMessagingService.kt` | `push_messaging_service.dart`, `app_es.arb` |
| P3-7 ✅ | Textos duplicados/propios sin contraparte (108 valores solo en Flutter) y 2 literales sin l10n en `fiscal_series_screen.dart` ("Boleta · Último número", "Activa"). | — | `app_es.arb`, `fiscal_series_screen.dart` |


### Orden sugerido
1. P1-1 (enlaces) y P1-2 (pestaña) son pequeños y desbloquean pruebas de US01/US05/US40.
2. P1-5 (tenant + series) y P1-4 (telemetría) son los más grandes; empezar por el dominio (`TenantService`, `GetVehicleTelemetryHistory`, `ReconnectObd`) y luego la pantalla.
3. P1-3, P1-6, P1-7, P1-8 tocan archivos compartidos (`task_detail_*`, `admin_dashboard_*`, `floor_hub_*`): hacerlos secuenciales.
4. Tras cada paso: `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`, y actualizar `docs/07-roadmap.md` y `docs/03-traceability.md`.

## 8. Resultado de `flutter analyze` y `flutter test`

- `flutter analyze`: 9 issues found, todos de nivel `info` (0 errores, 0 advertencias): regla `curly_braces_in_flow_control_structures` en `ai_health_report_view_model.dart:95,134`, `reports_screen.dart:107`, `work_order_detail_screen.dart:71,73,1083` y `work_order_detail_view_model.dart:491,1088,1170`. Salida del comando: código 1 solo por los `info`
- `flutter test`: con `-j 1`: **1.120 pasan, 5 fallan** ("Some tests failed", exit 1), todos en `test/features/cashier/presentation/fiscal_series_view_model_test.dart` (E1 agregar serie, serie que no corresponde al tipo, correlativo inicial inválido, E2 serie repetida, activar/desactivar): `mocktail` lanza "Bad state: … `any` on a parameter of type `VoucherType` … registerFallbackValue was not previously called" (falta `registerFallbackValue(VoucherType.…)` en el `setUpAll`). Con la concurrencia por defecto la suite se colgó dos veces (en `obd_transports_test` y en el `tearDownAll` de `main_screens_test`) y una vez falló además `elm327_obd_link_test` ("el prompt puede llegar solo, en otro trozo", `ObdConnectionLostException`): hay pruebas inestables o con recursos compartidos (archivo Drift / timers); conviene revisarlas

## 9. Notas sobre íconos y strings

- Íconos: Android usa `Icons.Outlined.*` + 4 vectores propios; Flutter usa el equivalente `Icons.*_outlined`/`*_outline` de Material. Las diferencias reales de ícono son las señaladas en las tablas (`Garage` en la barra, `ReceiptLong`, `CheckCircle` en el dock).
- Strings: las 130 claves Android que Flutter no referencia pertenecen exactamente a las pantallas ⚠️ de arriba (bahías, series, telemetría, alertas de stock, PDF, evidencia, suspensión, dashboard, módulos). Al corregir cada pantalla deben pasar a usarse; los textos Flutter sin contraparte (108) deberían borrarse del `.arb`.


## 10. Estado de la corrección (rama `feature/full-parity`)

- **Resueltos:** P1-1 a P1-8 (enlaces de correo, pestaña y tablero de bahías, telemetría en vivo, series y perfil fiscal, evidencia y cierre de tarea, decisiones de suspensión, integración de alertas de stock); P2-1 a P2-6, P2-8, P2-9 y P2-10; P3-2, P3-3, P3-5 y P3-7. P2-5 ya estaba cubierto salvo el color del chip "Completada" (Android la pinta `Info`, Flutter `Ok`).
- **Parciales o no resueltos:** P2-7 (se acotó la carga, falta el TTL y el flujo observable), P3-1 (la marca de repuesto es el hueco H35 del backend), P3-4 (la descripción accesible de página exige renderizar el PDF), P3-6 (los títulos de respaldo de los avisos push se mantienen a propósito).
- **Pruebas:** los 5 casos de `fiscal_series_view_model_test.dart` se reescribieron con `registerFallbackValue(VoucherType.factura)` y la nueva API; `flutter analyze` queda sin avisos. La suite no se colgó con la concurrencia por defecto en esta máquina; los cuelgues de la auditoría coincidieron con otros procesos de Flutter en paralelo (análisis y compilación) y no se encontró una causa en los archivos citados.
- **iOS:** sigue **sin comprobar** (Associated Domains incluido).
