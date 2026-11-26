# Verificación de paridad — Android vs Flutter (Paso 10)

Auditoría completa de los 207 archivos de UI en `atelier-mobile-android` (`core/designsystem`, `core/presentation`, `navigation` y `features/*/presentation`) frente a los 208 archivos equivalentes en `atelier_mobile_crossplatform` (rama `feature/presentation`), más revisión de cambios post-paso 9 en capas inferiores y barrido de alcanzabilidad de las historias excluidas según [08-presentation-port-plan.md](08-presentation-port-plan.md).

## Resumen cuantitativo

- **Total archivos UI en Android:** 207
- **Total archivos UI en Flutter:** 208
- **Portados e iguales (`✅ igual`, aplicando las exclusiones acordadas):** 170
- **Con diferencias menores o de plataforma (`⚠️ diferencias`):** 8
- **Faltantes no excluidos (`❌ falta`):** 0
- **Excluidos intencionalmente en UI (`⛔ excluido`):** 29 (`US05`: 6, `US18`: 3, `US28`: 2, `US34`: 2, `US37`: 3, `US37–39`: 6, `US40`: 4, `US42`: 3; además de omisiones parciales de `US04`, `US19`, `US29`, `US30`, `US35`, `US36`, `US41` y `US43` dentro de pantallas compartidas)

## 1. Tabla completa de paridad UI (207 archivos Android)

| Archivo Android | Archivo(s) Flutter | Estado | Diferencias |
| --- | --- | --- | --- |
| `core/designsystem/component/AtelierAdaptiveRow.kt` | `core/designsystem/component/atelier_adaptive_row.dart` | ✅ igual | Equivalente fiel (layout adaptativo por ancho/escala de texto). |
| `core/designsystem/component/AtelierBanner.kt` | `core/designsystem/component/atelier_banner.dart` | ✅ igual | Variantes `Ok`/`Info`/`Wait`/`Bad`, colores y espaciado iguales. |
| `core/designsystem/component/AtelierButton.kt` | `core/designsystem/component/atelier_button.dart` | ✅ igual | Estilos `Filled`/`Tonal`/`Outlined`/`Text`/`Destructive`/`DestructiveFilled`, `AtelierFab`, loading y target mínimo. |
| `core/designsystem/component/AtelierChip.kt` | `core/designsystem/component/atelier_chip.dart` | ✅ igual | Tipos `Ok`/`Info`/`Warn`/`Wait`/`Bad`/`Idle` y tokens iguales. |
| `core/designsystem/component/AtelierChronometer.kt` | `core/designsystem/component/atelier_chronometer.dart` | ✅ igual | Tipografía tabular, beacon y colores por estado iguales. |
| `core/designsystem/component/AtelierDensity.kt` | `core/designsystem/component/atelier_density.dart` | ✅ igual | `AtelierMinTouchTarget` (floor 56 dp, standard 48 dp) igual. |
| `core/designsystem/component/AtelierGroupedCard.kt` | `core/designsystem/component/atelier_grouped_card.dart` | ✅ igual | `AtelierGroupedCard` y `AtelierGroupedRow` iguales. |
| `core/designsystem/component/AtelierKpiCard.kt` | `core/designsystem/component/atelier_kpi_card.dart` | ✅ igual | `AtelierKpiCard` y `AtelierKpiGrid` iguales. |
| `core/designsystem/component/AtelierListRow.kt` | `core/designsystem/component/atelier_list_row.dart` | ✅ igual | Soporte de placa, avatar, divisor, loading/skeleton y trailing iguales. |
| `core/designsystem/component/AtelierLiveBeacon.kt` | `core/designsystem/component/atelier_live_beacon.dart` | ✅ igual | Pulso y modo reduced motion equivalentes. |
| `core/designsystem/component/AtelierLogo.kt` | `core/designsystem/component/atelier_logo.dart` | ✅ igual | `AtelierLogo` y `AtelierWordmark` iguales. |
| `core/designsystem/component/AtelierMainTopBar.kt` | `core/designsystem/component/atelier_main_top_bar.dart` | ✅ igual | Badges de notificaciones/sync, acceso a perfil y logo iguales. |
| `core/designsystem/component/AtelierNavigationBar.kt` | `core/designsystem/component/atelier_navigation_bar.dart` | ✅ igual | Cápsula flotante, botón circular de acción, `FloatingBarInset` iguales. |
| `core/designsystem/component/AtelierOtpField.kt` | `core/designsystem/component/atelier_otp_field.dart` | ✅ igual | 6 celdas, autofill/paste, foco y estado de error iguales. |
| `core/designsystem/component/AtelierPanels.kt` | `core/designsystem/component/atelier_panels.dart` | ✅ igual | `AtelierFichaPanel`, `AtelierReportPanel` y `AtelierSectionHeader` iguales. |
| `core/designsystem/component/AtelierPhotoGrid.kt` | `core/designsystem/component/atelier_photo_grid.dart` | ✅ igual | Grilla de miniaturas y badge de estado iguales. |
| `core/designsystem/component/AtelierPidTile.kt` | `core/designsystem/component/atelier_pid_tile.dart` | ✅ igual | Tile PID y `AtelierMetricBar` iguales. |
| `core/designsystem/component/AtelierPlate.kt` | `core/designsystem/component/atelier_plate.dart` | ✅ igual | Placa peruana `S`/`M`/`L` con franja azul igual. |
| `core/designsystem/component/AtelierPlateField.kt` | `core/designsystem/component/atelier_plate_field.dart` | ✅ igual | Campo de placa en mayúsculas/formato igual. |
| `core/designsystem/component/AtelierSegmentedControl.kt` | `core/designsystem/component/atelier_segmented_control.dart` | ✅ igual | Segmentos, scroll horizontal y selección iguales. |
| `core/designsystem/component/AtelierSelectionCard.kt` | `core/designsystem/component/atelier_selection_card.dart` | ⚠️ diferencias | Diferencia mínima: cuando está seleccionada, Flutter envuelve el `Material` en `Padding(1.5)` para simular el borde en gradiente. |
| `core/designsystem/component/AtelierSheet.kt` | `core/designsystem/component/atelier_sheet.dart` | ✅ igual | `AtelierBottomSheet`, acciones y `AtelierRequiresConnection` iguales. |
| `core/designsystem/component/AtelierSkeleton.kt` | `core/designsystem/component/atelier_skeleton.dart` | ✅ igual | `Bone` y `DelayedLoading` equivalentes a `bone()` y `rememberDelayedLoading()`. |
| `core/designsystem/component/AtelierStates.kt` | `core/designsystem/component/atelier_states.dart` | ✅ igual | `Empty`/`Error`/`Offline`/`NoPermission`/`PlanLocked` + `AtelierRefreshBar` iguales. |
| `core/designsystem/component/AtelierSurface.kt` | `core/designsystem/component/atelier_surface.dart` | ✅ igual | `SurfaceTier` (`Card`/`Elevated`/`Floating`/`Recessed`) iguales. |
| `core/designsystem/component/AtelierTextField.kt` | `core/designsystem/component/atelier_text_field.dart` | ✅ igual | Label, hint, error, íconos, password toggle iguales. |
| `core/designsystem/component/AtelierTopBar.kt` | `core/designsystem/component/atelier_top_bar.dart` | ✅ igual | Título, botón Atrás y actions iguales. |
| `core/designsystem/component/Motion.kt` | `core/designsystem/component/motion.dart` + `atelier_page_transitions.dart` | ✅ igual | `AtelierSprings`, `rememberReducedMotion`, `rememberAtelierHaptics` iguales. |
| `core/designsystem/icon/Icons.kt` | `core/designsystem/icon/atelier_icons.dart` | ✅ igual | Vectores personalizados equivalentes. |
| `core/designsystem/text/UiText.kt` | `core/designsystem/text/ui_text.dart` | ✅ igual | `UiText.dynamic` / `UiText.resource` y `toUiText()` con HTTP/domain errors iguales. |
| `core/designsystem/theme/Color.kt` | `core/designsystem/theme/atelier_colors.dart` | ✅ igual | Tokens claro/oscuro exactos. |
| `core/designsystem/theme/Shape.kt` | `core/designsystem/theme/atelier_shapes.dart` | ✅ igual | Radios (`ControlShape`, `ChipShape`, `CardLargeShape`, `HeroShape`, `PanelShape`) iguales. |
| `core/designsystem/theme/Theme.kt` | `core/designsystem/theme/atelier_theme.dart` | ✅ igual | ThemeExtension y ColorScheme claro/oscuro iguales. |
| `core/designsystem/theme/Type.kt` | `core/designsystem/theme/atelier_typography.dart` | ✅ igual | Escala tipográfica Satoshi / Plus Jakarta Sans + tabular figures iguales. |
| `core/presentation/DateFormat.kt` | `core/presentation/date_format.dart` + `lima_time_format.dart` | ✅ igual | Formatos en zona `America/Lima` iguales. |
| `core/presentation/DocumentIntents.kt` | `core/presentation/document_intents.dart` | ✅ igual | `openPdf` y `sharePdf` vía `open_filex` / `share_plus` equivalentes. |
| `core/presentation/MoneyFormat.kt` | `core/presentation/money_format.dart` | ✅ igual | Formato de moneda y `formatQuantity()` iguales. |
| `navigation/AppNavHost.kt` | `navigation/app_root.dart` + `app_navigator.dart` + `root_navigator.dart` + `presentation_setup.dart` | ✅ igual | Equivalente con exclusiones: `_openPush` ignora en no-op `TaskSuspensionReviewDestination` (US29) y `LowStockAlertsDestination` (US34); sin rutas a US excluidas. |
| `navigation/AppNavHostViewModel.kt` | `navigation/app_nav_host_view_model.dart` | ✅ igual | Observa sesión, registra FCM y abre push destinos permitidos. |
| `features/attendance/presentation/AttendanceScreen.kt` | `features/attendance/presentation/attendance_screen.dart` | ✅ igual | Flutter añade parámetro `embedded: bool` para embeberse en `AdminAttendanceScreen`; UI y acciones iguales. |
| `features/attendance/presentation/AttendanceUiState.kt` | `features/attendance/presentation/attendance_ui_state.dart` | ✅ igual | Campos y reglas iguales. |
| `features/attendance/presentation/AttendanceViewModel.kt` | `features/attendance/presentation/attendance_view_model.dart` | ✅ igual | Geolocalización, reloj, justificación y manejo de errores iguales. |
| `features/attendance/presentation/dashboard/FloorHubScreen.kt` | `features/attendance/presentation/dashboard/floor_hub_screen.dart` | ✅ igual | Mismas tarjetas y acciones salvo exclusiones: omite `stockAlerts` (US34), las órdenes listas abren `workOrderCheckout` (US37–39), omite `Bays` en `FloorShortcutsCard` (US40), subtítulo OBD usa `floorHubQuickObdSubNoLive` (US18). |
| `features/attendance/presentation/dashboard/FloorHubUiState.kt` | `features/attendance/presentation/dashboard/floor_hub_ui_state.dart` | ✅ igual | Omite campos de US34/US40 y los no usados `deviceLocation`/`previewLocation`. |
| `features/attendance/presentation/dashboard/FloorHubViewModel.kt` | `features/attendance/presentation/dashboard/floor_hub_view_model.dart` | ⚠️ diferencias | Omite carga de `stockAlerts` (US34), `bays` (US40) y métodos no usados de location preview. |
| `features/attendance/presentation/navigation/AttendanceNavGraph.kt` | `features/attendance/presentation/navigation/attendance_nav_graph.dart` + `attendance_presentation.dart` | ✅ igual | Rutas `attendanceHome` y `attendanceDetail` iguales. |
| `features/auth/presentation/AuthComponents.kt` | `features/auth/presentation/auth_components.dart` | ✅ igual | Componentes visuales auth iguales. |
| `features/auth/presentation/branch/BranchSelectionScreen.kt` | `features/auth/presentation/branch/branch_selection_screen.dart` | ✅ igual | Selección de sede igual. |
| `features/auth/presentation/branch/BranchSelectionUiState.kt` | `features/auth/presentation/branch/branch_selection_ui_state.dart` | ✅ igual | Campos y helpers iguales. |
| `features/auth/presentation/branch/BranchSelectionViewModel.kt` | `features/auth/presentation/branch/branch_selection_view_model.dart` | ✅ igual | Lógica igual. |
| `features/auth/presentation/forgot/ForgotPasswordScreen.kt` | `features/auth/presentation/forgot/forgot_password_screen.dart` | ✅ igual | Sprint 3 (US05): formulario, confirmación genérica, "Ya tengo el enlace" y "Pedir otro enlace". |
| `features/auth/presentation/forgot/ForgotPasswordUiState.kt` | `features/auth/presentation/forgot/forgot_password_ui_state.dart` | ✅ igual | Sprint 3 (US05). |
| `features/auth/presentation/forgot/ForgotPasswordViewModel.kt` | `features/auth/presentation/forgot/forgot_password_view_model.dart` | ✅ igual | Sprint 3 (US05). |
| `features/auth/presentation/login/LoginScreen.kt` | `features/auth/presentation/login/login_screen.dart` | ✅ igual | Sprint 3: enlace "¿Olvidaste tu contraseña?" (US05) y aviso neutro de pendientes del dispositivo (US04). |
| `features/auth/presentation/login/LoginUiState.kt` | `features/auth/presentation/login/login_ui_state.dart` | ✅ igual | Campos iguales. |
| `features/auth/presentation/login/LoginViewModel.kt` | `features/auth/presentation/login/login_view_model.dart` | ✅ igual | Manejo de sesión/pending ops/errores igual. |
| `features/auth/presentation/navigation/AuthNavGraph.kt` | `features/auth/presentation/auth_nav_graph.dart` + `auth_presentation.dart` | ✅ igual | Sprint 3 (US05): rutas `forgotPassword` / `resetPassword` y consumo de `ResetPasswordDeepLink`. Sin plugin de App Links: el enlace se pega (H1). |
| `features/auth/presentation/register/RegisterScreen.kt` | `features/auth/presentation/register/register_screen.dart` | ✅ igual | Registro con token de invitación igual. |
| `features/auth/presentation/register/RegisterUiState.kt` | `features/auth/presentation/register/register_ui_state.dart` | ✅ igual | Igual. |
| `features/auth/presentation/register/RegisterViewModel.kt` | `features/auth/presentation/register/register_view_model.dart` | ✅ igual | Igual. |
| `features/auth/presentation/reset/ResetPasswordScreen.kt` | `features/auth/presentation/reset/reset_password_screen.dart` | ✅ igual | Sprint 3 (US05): enlace o código, reglas de contraseña, aviso de enlace vencido y confirmación al descartar (`PopScope` en lugar de `BackHandler`). |
| `features/auth/presentation/reset/ResetPasswordUiState.kt` | `features/auth/presentation/reset/reset_password_ui_state.dart` | ✅ igual | Sprint 3 (US05). |
| `features/auth/presentation/reset/ResetPasswordViewModel.kt` | `features/auth/presentation/reset/reset_password_view_model.dart` | ✅ igual | Sprint 3 (US05): 400 y 404 = enlace vencido o inválido. |
| `features/auth/presentation/verifyemail/VerifyEmailScreen.kt` | `features/auth/presentation/verifyemail/verify_email_screen.dart` | ✅ igual | Verificación OTP 6 dígitos y reenvío iguales. |
| `features/auth/presentation/verifyemail/VerifyEmailUiState.kt` | `features/auth/presentation/verifyemail/verify_email_ui_state.dart` | ✅ igual | Igual. |
| `features/auth/presentation/verifyemail/VerifyEmailViewModel.kt` | `features/auth/presentation/verifyemail/verify_email_view_model.dart` | ✅ igual | Igual. |
| `features/bays/presentation/BayActionSheets.kt` | — | ⛔ excluido (US40) | Excluido intencionalmente (gestión de bahías US40). |
| `features/bays/presentation/BaysScreen.kt` | — | ⛔ excluido (US40) | Excluido intencionalmente (US40). |
| `features/bays/presentation/BaysUiState.kt` | — | ⛔ excluido (US40) | Excluido intencionalmente (US40). |
| `features/bays/presentation/BaysViewModel.kt` | — | ⛔ excluido (US40) | Excluido intencionalmente (US40). |
| `features/cashier/presentation/CashierComponents.kt` | — | ⛔ excluido (US37–39) | Excluido intencionalmente (checkout/comprobantes US37–39). |
| `features/cashier/presentation/CashierForms.kt` | — | ⛔ excluido (US37–39) | Excluido intencionalmente (US37–39). |
| `features/cashier/presentation/CashierLabels.kt` | `features/cashier/presentation/cashier_labels.dart` + `cashier_formats.dart` | ✅ igual | Mapeo de errores/labels de caja igual; omite labels de comprobantes (US37). |
| `features/cashier/presentation/checkout/CheckoutSheets.kt` | `features/cashier/presentation/checkout/checkout_sheets.dart` | ✅ igual | Sprint 3: hojas de emitir/anular/NC (US37), registrar cobro (US38) y entregar (US39). |
| `features/cashier/presentation/checkout/WorkOrderCheckoutScreen.kt` | `features/cashier/presentation/checkout/work_order_checkout_screen.dart` | ✅ igual | Sprint 3: riel de 4 etapas, pasos 1 (US37), 2 cobros con historial (US38), 3 pase de salida y 4 entrega (US39). |
| `features/cashier/presentation/checkout/WorkOrderCheckoutUiState.kt` | `features/cashier/presentation/checkout/work_order_checkout_ui_state.dart` | ✅ igual | Sprint 3: `PaymentForm`, `PaymentCheckoutSheet`, `DeliverCheckoutSheet`, `canMarkPaid`. |
| `features/cashier/presentation/checkout/WorkOrderCheckoutViewModel.kt` | `features/cashier/presentation/checkout/work_order_checkout_view_model.dart` | ✅ igual | Sprint 3: cobros sin reintento ciego (H28), marcar pagada, pase de salida y entrega. |
| `features/cashier/presentation/dailycash/DailyCashScreen.kt` | `features/cashier/presentation/dailycash/daily_cash_screen.dart` | ✅ igual | Caja diaria igual salvo omisión de acceso rápido `vouchers-shortcut` (US37). |
| `features/cashier/presentation/dailycash/DailyCashUiState.kt` | `features/cashier/presentation/dailycash/daily_cash_ui_state.dart` | ✅ igual | Igual. |
| `features/cashier/presentation/dailycash/DailyCashViewModel.kt` | `features/cashier/presentation/dailycash/daily_cash_view_model.dart` | ✅ igual | Igual. |
| `features/cashier/presentation/navigation/CashierNavGraph.kt` | `features/cashier/presentation/navigation/cashier_nav_graph.dart` + `cashier_presentation.dart` | ✅ igual | Solo registra `dailyCash`; omite `checkout`, `vouchers` y `fiscalSeries` (US37–39, US42). |
| `features/cashier/presentation/series/FiscalSeriesScreen.kt` | — | ⛔ excluido (US42) | Excluido intencionalmente (series fiscales SUNAT US42). |
| `features/cashier/presentation/series/FiscalSeriesUiState.kt` | — | ⛔ excluido (US42) | Excluido intencionalmente (US42). |
| `features/cashier/presentation/series/FiscalSeriesViewModel.kt` | — | ⛔ excluido (US42) | Excluido intencionalmente (US42). |
| `features/cashier/presentation/vouchers/VouchersScreen.kt` | — | ⛔ excluido (US37) | Excluido intencionalmente (comprobantes/notas de crédito US37). |
| `features/cashier/presentation/vouchers/VouchersUiState.kt` | — | ⛔ excluido (US37) | Excluido intencionalmente (US37). |
| `features/cashier/presentation/vouchers/VouchersViewModel.kt` | — | ⛔ excluido (US37) | Excluido intencionalmente (US37). |
| `features/diagnostics/presentation/DiagnosticsUiFormatters.kt` | `features/diagnostics/presentation/diagnostics_ui_formatters.dart` | ✅ igual | Formatos, chips y errores iguales; omite `shareOrOpenPdf` (US43). |
| `features/diagnostics/presentation/faults/VehicleFaultsScreen.kt` | `features/diagnostics/presentation/faults/vehicle_faults_screen.dart` | ✅ igual | Ficha de vehículo, freeze frame, escaneo modo 03 y borrado modo 04 con confirmación iguales. |
| `features/diagnostics/presentation/faults/VehicleFaultsUiState.kt` | `features/diagnostics/presentation/faults/vehicle_faults_ui_state.dart` | ✅ igual | Campos y propiedades iguales. |
| `features/diagnostics/presentation/faults/VehicleFaultsViewModel.kt` | `features/diagnostics/presentation/faults/vehicle_faults_view_model.dart` | ✅ igual | Permisos, flujo BT, escaneo, borrado y manejo de errores iguales. |
| `features/diagnostics/presentation/hub/DiagnosticsAlertsTab.kt` | `features/diagnostics/presentation/hub/diagnostics_alerts_tab.dart` | ✅ igual | Scope sede/vehículo, tarjetas, confirmar alerta y convertir en cita iguales. |
| `features/diagnostics/presentation/hub/DiagnosticsDevicesTab.kt` | `features/diagnostics/presentation/hub/diagnostics_devices_tab.dart` | ✅ igual | Filtro por estado, detalle instalación y menú de dispositivo iguales. |
| `features/diagnostics/presentation/hub/DiagnosticsHubScreen.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_screen.dart` | ⚠️ diferencias | Omite correctamente fila `Telemetría en vivo` (`onOpenLiveTelemetry`, US18). Diferencia menor: omite el chip de lecturas/fallas pendientes (`vehicleSyncState`) en la tarjeta del vehículo seleccionado en Escáner. |
| `features/diagnostics/presentation/hub/DiagnosticsHubSheets.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_sheets.dart` | ✅ igual | Hojas de picker de vehículo, instalar en vehículo, acciones de escáner, registrar dispositivo, cambiar estado, instalar/desinstalar y convertir alerta a cita iguales. |
| `features/diagnostics/presentation/hub/DiagnosticsHubUiState.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart` | ⚠️ diferencias | Omite `vehicleSyncState` (US18). Nota menor: `availableTabs` sigue evaluando `canUseTelemetry \|\| canReadTelemetry` para mostrar pestaña Escáner aunque no exista acción de telemetría en vivo (un usuario con solo permiso de telemetría vería `diagHubNoPermission` en herramientas). |
| `features/diagnostics/presentation/hub/DiagnosticsHubViewModel.kt` | `features/diagnostics/presentation/hub/diagnostics_hub_view_model.dart` | ⚠️ diferencias | Omite `ObserveDiagnosticsSyncStateUseCase` (coherente con omitir `vehicleSyncState`). Añade `requestBluetooth` delegando en `RequestBluetoothPermissionUseCase` (equivalente al launcher Android). En `_loadDeviceInstallations`, `uninstall` omite pasar `finalOdometerKm` al desinstalar desde tab Dispositivos (`vehicle` ya era null en Android salvo cuando se desinstala desde Escáner, donde sí lo pasa). |
| `features/diagnostics/presentation/live/LiveTelemetryScreen.kt` | — | ⛔ excluido (US18) | Excluido intencionalmente (telemetría en vivo US18). |
| `features/diagnostics/presentation/live/LiveTelemetryUiState.kt` | — | ⛔ excluido (US18) | Excluido intencionalmente (US18). |
| `features/diagnostics/presentation/live/LiveTelemetryViewModel.kt` | — | ⛔ excluido (US18) | Excluido intencionalmente (US18). |
| `features/diagnostics/presentation/navigation/DiagnosticsNavGraph.kt` | `features/diagnostics/presentation/navigation/diagnostics_nav_graph.dart` + `diagnostics_presentation.dart` | ✅ igual | Registra Hub, VehicleFaults y AiHealthReport; omite `LiveTelemetryRoute` (US18). |
| `features/diagnostics/presentation/report/AiHealthReportScreen.kt` | `features/diagnostics/presentation/report/ai_health_report_screen.dart` | ✅ igual | Omite botones Abrir/Compartir PDF (US43); mantiene `HealthScoreArc`, subsistemas, riesgos, acciones, correlaciones DTC y hoja `GenerateReportSheet`. |
| `features/diagnostics/presentation/report/AiHealthReportUiState.kt` | `features/diagnostics/presentation/report/ai_health_report_ui_state.dart` | ✅ igual | Omite `pendingPdfFile`, `pdfActionMode`, `isDownloadingPdf` (US43). |
| `features/diagnostics/presentation/report/AiHealthReportViewModel.kt` | `features/diagnostics/presentation/report/ai_health_report_view_model.dart` | ✅ igual | Omite `DownloadHealthReportPdfUseCase` / `downloadPdf` / `sharePdf` (US43). |
| `features/inventory/presentation/InventoryLabels.kt` | `features/inventory/presentation/inventory_labels.dart` | ✅ igual | Categorías, semáforo stock y estados de OC iguales. |
| `features/inventory/presentation/alerts/StockAlertsScreen.kt` | — | ⛔ excluido (US34) | Excluido intencionalmente (bandeja de alertas de stock US34). |
| `features/inventory/presentation/alerts/StockAlertsViewModel.kt` | — | ⛔ excluido (US34) | Excluido intencionalmente (US34). |
| `features/inventory/presentation/catalog/PartsCatalogScreen.kt` | `features/inventory/presentation/catalog/parts_catalog_screen.dart` | ✅ igual | Buscador, acceso a escáner, chips de categoría, banners, skeletons y `CreatePartSheet` iguales. |
| `features/inventory/presentation/catalog/PartsCatalogUiState.kt` | `features/inventory/presentation/catalog/parts_catalog_ui_state.dart` | ✅ igual | Campos y validaciones iguales. |
| `features/inventory/presentation/catalog/PartsCatalogViewModel.kt` | `features/inventory/presentation/catalog/parts_catalog_view_model.dart` | ✅ igual | Debounce 300 ms, caché + reintento al volver red y alta iguales. |
| `features/inventory/presentation/catalog/components/CategoryFilterChips.kt` | `features/inventory/presentation/catalog/components/category_filter_chips.dart` | ✅ igual | 9 categorías con deselección al retocar igual. |
| `features/inventory/presentation/detail/PartDetailScreen.kt` | `features/inventory/presentation/detail/part_detail_screen.dart` | ✅ igual | `AtelierFichaPanel`, banner stock bajo con botón OC, `StockCalibrationCard`, hechos, acciones de lote y lista FIFO con `AtelierLiveBeacon` iguales. |
| `features/inventory/presentation/detail/PartDetailUiState.kt` | `features/inventory/presentation/detail/part_detail_ui_state.dart` | ✅ igual | Igual. |
| `features/inventory/presentation/detail/PartDetailViewModel.kt` | `features/inventory/presentation/detail/part_detail_view_model.dart` | ✅ igual | Orden FIFO defensivo y hojas Edit/ReceiveDirect/DispatchFifo/Restore iguales. |
| `features/inventory/presentation/navigation/InventoryNavGraph.kt` | `features/inventory/presentation/navigation/inventory_nav_graph.dart` + `inventory_navigation.dart` + `inventory_presentation.dart` | ✅ igual | Omite `StockAlertsRoute` (US34); resto de rutas igual. |
| `features/inventory/presentation/orders/PurchaseOrderDetailScreen.kt` | `features/inventory/presentation/orders/purchase_order_detail_screen.dart` | ✅ igual | Omite FAB `Recibir OC`, `ReceiveSheet` y banner `justReceived` (US34 recepción); mantiene borrador/agregar línea/emitir/anular y vista de recibo si ya existe. |
| `features/inventory/presentation/orders/PurchaseOrderDetailViewModel.kt` | `features/inventory/presentation/orders/purchase_order_detail_ui_state.dart` + `purchase_order_detail_view_model.dart` | ✅ igual | Omite `ReceivePurchaseOrderUseCase` y estado de recepción (US34); el resto del ciclo OC igual. |
| `features/inventory/presentation/orders/PurchaseOrdersScreen.kt` | `features/inventory/presentation/orders/purchase_orders_screen.dart` | ✅ igual | Filtros, alta de borrador y pedido sugerido de stock bajo iguales. |
| `features/inventory/presentation/orders/PurchaseOrdersViewModel.kt` | `features/inventory/presentation/orders/purchase_orders_ui_state.dart` + `purchase_orders_view_model.dart` | ✅ igual | Filtro inicial `ISSUED`, cálculo `suggestedReplenishmentQty` y validaciones iguales. |
| `features/inventory/presentation/scanner/SkuScannerScreen.kt` | `features/inventory/presentation/scanner/sku_scanner_screen.dart` | ✅ igual | Cámara (`mobile_scanner`), `PrecisionReticleOverlay` con `#69B1FF` + pulso animado y búsqueda manual iguales. |
| `features/inventory/presentation/scanner/SkuScannerViewModel.kt` | `features/inventory/presentation/scanner/sku_scanner_ui_state.dart` + `sku_scanner_view_model.dart` | ✅ igual | Normalización SKU, debouncing de lectura y errores iguales. |
| `features/inventory/presentation/suppliers/SuppliersScreen.kt` | `features/inventory/presentation/suppliers/suppliers_screen.dart` | ✅ igual | Buscador, chip Activo/Inactivo y hoja crear/editar iguales. |
| `features/inventory/presentation/suppliers/SuppliersViewModel.kt` | `features/inventory/presentation/suppliers/suppliers_ui_state.dart` + `suppliers_view_model.dart` | ✅ igual | Debounce 250 ms y validaciones iguales. |
| `features/inventory/presentation/valuation/InventoryValuationScreen.kt` | `features/inventory/presentation/valuation/inventory_valuation_screen.dart` | ✅ igual | `AtelierReportPanel`, `InventoryHealthCard` y tarjetas por categoría con `AtelierMetricBar` iguales. |
| `features/inventory/presentation/valuation/InventoryValuationViewModel.kt` | `features/inventory/presentation/valuation/inventory_valuation_ui_state.dart` + `inventory_valuation_view_model.dart` | ✅ igual | Cálculos por categoría y valorización iguales. |
| `features/main/presentation/MainNavigationBar.kt` | `features/main/presentation/main_navigation_bar.dart` + `main_shell.dart` + `main_shell_controller.dart` + `main_shell_presentation.dart` | ✅ igual | Barra flotante y botón circular iguales (omite `Bays` US40; `collectPayment` abre `workOrders`/`orders` por exclusión US37–39, igual que Android). |
| `features/main/presentation/MainUiState.kt` | `features/main/presentation/main_ui_state.dart` | ✅ igual | Igual. |
| `features/main/presentation/MainViewModel.kt` | `features/main/presentation/main_view_model.dart` + `main_presentation.dart` | ✅ igual | Igual. |
| `features/main/presentation/attendance/AdminAttendanceScreen.kt` | `features/main/presentation/attendance/admin_attendance_screen.dart` | ✅ igual | Segmento Hoy / Mi turno / Justificaciones igual. |
| `features/main/presentation/attendance/AdminAttendanceUiState.kt` | `features/main/presentation/attendance/admin_attendance_ui_state.dart` | ✅ igual | Igual. |
| `features/main/presentation/attendance/AdminAttendanceViewModel.kt` | `features/main/presentation/attendance/admin_attendance_view_model.dart` | ✅ igual | Igual (apoya revisión con `justification_review.dart`). |
| `features/main/presentation/dashboard/AdminDashboardScreen.kt` | `features/main/presentation/dashboard/admin_dashboard_screen.dart` | ✅ igual | KPIs, resumen de sede, justificaciones y accesos rápidos iguales (sin exclusiones violadas). |
| `features/main/presentation/dashboard/AdminDashboardUiState.kt` | `features/main/presentation/dashboard/admin_dashboard_ui_state.dart` | ✅ igual | Igual. |
| `features/main/presentation/dashboard/AdminDashboardViewModel.kt` | `features/main/presentation/dashboard/admin_dashboard_view_model.dart` | ✅ igual | Omite recarga de `pendingSuspensions` (US29). |
| `features/main/presentation/more/ModulesSheet.kt` | `features/main/presentation/more/modules_sheet.dart` | ✅ igual | Omite `Bays` (US40), `StockAlerts` (US34), `Vouchers` (US37), `FiscalSeries` (US42); resto de módulos y badges iguales. |
| `features/main/presentation/navigation/MainNavigation.kt` | `features/main/presentation/navigation/main_tab.dart` + `main_labels.dart` + `justification_review.dart` | ✅ igual | Mismas pestañas por permiso sin US40. |
| `features/main/presentation/notifications/NotificationsScreen.kt` | `features/main/presentation/notifications/notifications_screen.dart` | ✅ igual | Lista push y marcar todo leído igual. |
| `features/main/presentation/notifications/NotificationsUiState.kt` | `features/main/presentation/notifications/notifications_ui_state.dart` | ✅ igual | Igual. |
| `features/main/presentation/notifications/NotificationsViewModel.kt` | `features/main/presentation/notifications/notifications_view_model.dart` | ✅ igual | Igual. |
| `features/main/presentation/profile/ProfileScreen.kt` | `features/main/presentation/profile/profile_screen.dart` | ✅ igual | Sprint 3 (US04): sección "Seguridad y sesión" y hoja de confirmación de `Cerrar sesión`. |
| `features/main/presentation/profile/ProfileUiState.kt` | `features/main/presentation/profile/profile_ui_state.dart` | ✅ igual | Sprint 3 (US04): `confirmingSignOut` y `signingOut`. |
| `features/main/presentation/profile/ProfileViewModel.kt` | `features/main/presentation/profile/profile_view_model.dart` | ✅ igual | Sprint 3 (US04): `SignOutUseCase`. |
| `features/main/presentation/sync/PendingOperationsScreen.kt` | `features/main/presentation/sync/pending_operations_screen.dart` | ✅ igual | Cola, reintentar/descartar por fila y "Sincronizar ahora" iguales. |
| `features/main/presentation/sync/PendingOperationsUiState.kt` | `features/main/presentation/sync/pending_operations_ui_state.dart` | ✅ igual | Igual. |
| `features/main/presentation/sync/PendingOperationsViewModel.kt` | `features/main/presentation/sync/pending_operations_view_model.dart` | ✅ igual | Igual. |
| `features/reception/presentation/ReceptionErrors.kt` | `features/reception/presentation/reception_errors.dart` | ✅ igual | Igual. |
| `features/reception/presentation/affiliation/AffiliationScreen.kt` | `features/reception/presentation/affiliation/affiliation_screen.dart` | ✅ igual | Igual. |
| `features/reception/presentation/affiliation/AffiliationUiState.kt` | `features/reception/presentation/affiliation/affiliation_ui_state.dart` | ✅ igual | Igual. |
| `features/reception/presentation/affiliation/AffiliationViewModel.kt` | `features/reception/presentation/affiliation/affiliation_view_model.dart` | ✅ igual | Igual. |
| `features/reception/presentation/navigation/ReceptionNavGraph.kt` | `features/reception/presentation/navigation/reception_nav_graph.dart` + `reception_presentation.dart` | ✅ igual | Igual. |
| `features/reception/presentation/register/RegisterCustomerScreen.kt` | `features/reception/presentation/register/register_customer_screen.dart` | ✅ igual | Igual. |
| `features/reception/presentation/register/RegisterCustomerUiState.kt` | `features/reception/presentation/register/register_customer_ui_state.dart` | ✅ igual | Igual. |
| `features/reception/presentation/register/RegisterCustomerViewModel.kt` | `features/reception/presentation/register/register_customer_view_model.dart` | ✅ igual | Igual. |
| `features/reception/presentation/search/VehicleSearchScreen.kt` | `features/reception/presentation/search/vehicle_search_screen.dart` | ✅ igual | Igual. |
| `features/reception/presentation/search/VehicleSearchSheets.kt` | `features/reception/presentation/search/vehicle_search_sheets.dart` | ✅ igual | Igual. |
| `features/reception/presentation/search/VehicleSearchUiState.kt` | `features/reception/presentation/search/vehicle_search_ui_state.dart` | ✅ igual | Igual. |
| `features/reception/presentation/search/VehicleSearchViewModel.kt` | `features/reception/presentation/search/vehicle_search_view_model.dart` | ✅ igual | Igual. |
| `features/reports/presentation/ReportsScreen.kt` | `features/reports/presentation/reports_screen.dart` | ✅ igual | Omite botones PDF flujo de caja (US41) y tarjeta Salud de Flota / PDF (US43); deja filtro período, KPIs, métodos de pago y métricas OT. |
| `features/reports/presentation/ReportsUiState.kt` | `features/reports/presentation/reports_ui_state.dart` | ✅ igual | Omite estado PDF y flota (US41/US43); `hasAnyAccess => canReadCashFlow`. |
| `features/reports/presentation/ReportsViewModel.kt` | `features/reports/presentation/reports_view_model.dart` | ✅ igual | Omite `DownloadCashFlowPdfUseCase` y `GetFleetHealthUseCase` (US41/US43). |
| `features/reports/presentation/navigation/ReportsNavGraph.kt` | `features/reports/presentation/navigation/reports_nav_graph.dart` + `reports_presentation.dart` | ✅ igual | Ruta `reports` igual. |
| `features/tasks/presentation/TaskErrors.kt` | `features/tasks/presentation/task_errors.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/TaskLabels.kt` | `features/tasks/presentation/task_labels.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/detail/TaskDetailScreen.kt` | `features/tasks/presentation/detail/task_detail_screen.dart` + `task_detail_actions.dart` | ✅ igual | Omite evidencia (US28), acciones de suspensión/reanudación (US29) y completar tarea (US30); mantiene banners informativos de suspensión en solo lectura. |
| `features/tasks/presentation/detail/TaskDetailUiState.kt` | `features/tasks/presentation/detail/task_detail_ui_state.dart` | ✅ igual | Omite estados de US28/29/30. |
| `features/tasks/presentation/detail/TaskDetailViewModel.kt` | `features/tasks/presentation/detail/task_detail_view_model.dart` | ✅ igual | Omite `CompleteTaskUseCase`, `RequestSuspensionUseCase`, `ReviewSuspensionUseCase`, `AttachTaskEvidenceUseCase` (US28–30). |
| `features/tasks/presentation/detail/components/ChronometerTimer.kt` | `features/tasks/presentation/detail/components/chronometer_timer.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/detail/components/PartSheets.kt` | `features/tasks/presentation/detail/components/part_sheets.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/detail/components/TaskEvidenceSection.kt` | — | ⛔ excluido (US28) | Excluido intencionalmente (evidencia fotográfica en tarea US28). |
| `features/tasks/presentation/detail/components/TaskPartsSection.kt` | `features/tasks/presentation/detail/components/task_parts_section.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/detail/components/TaskPhotoCapture.kt` | — | ⛔ excluido (US28) | Excluido intencionalmente (US28). |
| `features/tasks/presentation/detail/components/TaskPitActionDock.kt` | `features/tasks/presentation/detail/components/task_pit_action_dock.dart` | ✅ igual | Solo `showStart` y `showPause`; omite "Terminar tarea" (US30). |
| `features/tasks/presentation/detail/components/TaskSheets.kt` | `features/tasks/presentation/detail/components/task_sheets.dart` | ✅ igual | Mantiene hoja de pausa; omite `CompleteTaskSheet` (US30) y `RequestSuspensionSheet`/`ReviewSuspensionSheet` (US29). |
| `features/tasks/presentation/mytasks/MyTasksScreen.kt` | `features/tasks/presentation/mytasks/my_tasks_screen.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/mytasks/MyTasksUiState.kt` | `features/tasks/presentation/mytasks/my_tasks_ui_state.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/mytasks/MyTasksViewModel.kt` | `features/tasks/presentation/mytasks/my_tasks_view_model.dart` | ✅ igual | Igual. |
| `features/tasks/presentation/navigation/TasksNavGraph.kt` | `features/tasks/presentation/navigation/tasks_nav_graph.dart` + `tasks_presentation.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/WorkOrderErrors.kt` | `features/workorders/presentation/work_order_labels.dart` | ✅ igual | Fusionado con labels; mismos mensajes de error. |
| `features/workorders/presentation/WorkOrderLabels.kt` | `features/workorders/presentation/work_order_labels.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/components/ChoiceChip.kt` | `features/workorders/presentation/components/choice_chip.dart` (+ `pick_row.dart`) | ✅ igual | Igual. |
| `features/workorders/presentation/components/PhotoCapture.kt` | `features/workorders/presentation/components/photo_capture.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/components/ProposalLabels.kt` | `features/workorders/presentation/components/proposal_labels.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/detail/WorkOrderDetailScreen.kt` | `features/workorders/presentation/detail/work_order_detail_screen.dart` (+ `bottom_action_bar.dart`) | ✅ igual | Omite FAB checkout (US37–39), asignación de bahía editable (US40), suspensiones (US29), rentabilidad (US35) y total/desglose de liquidación (US36). |
| `features/workorders/presentation/detail/WorkOrderDetailUiState.kt` | `features/workorders/presentation/detail/work_order_detail_ui_state.dart` | ⚠️ diferencias | Omite estados de US29/35/37–40. Mantiene `breakdown => detail?.cascadeBreakdown()` sin usar en pantalla (`cascade.dart`, US36). |
| `features/workorders/presentation/detail/WorkOrderDetailViewModel.kt` | `features/workorders/presentation/detail/work_order_detail_view_model.dart` | ✅ igual | Omite casos de uso de US29/US35/US40. |
| `features/workorders/presentation/detail/components/OrderCostSheets.kt` | `features/workorders/presentation/detail/components/work_order_detail_dialogs.dart` | ⚠️ diferencias | `ProfitabilitySheet` excluida (US35 ⛔); `PartMovementsSheet` (US33 E2) portada dentro de `work_order_detail_dialogs.dart`. |
| `features/workorders/presentation/detail/components/QuotationSummarySection.kt` | `features/workorders/presentation/detail/components/quotation_summary_section.dart` | ✅ igual | Omite "Reanudar tarea" / chip `suspension_pending` (US29) y tarjeta desglose Subtotal/IGV/Total (US36); mantiene PDF y envío por correo. |
| `features/workorders/presentation/detail/components/WorkOrderDetailDialogs.kt` | `features/workorders/presentation/detail/components/work_order_detail_dialogs.dart` | ⚠️ diferencias | Omite `SuspensionSheet` (US29), `ProfitabilitySheet` (US35), `AssignBaySheet` (US40) y `CascadeBreakdown` (US36). En `PdfPreviewSheet` muestra banner `quotationPdfReady` en lugar de renderizado bitmap nativo con `PdfRenderer`. |
| `features/workorders/presentation/finding/ReportFindingScreen.kt` | `features/workorders/presentation/finding/report_finding_screen.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/finding/ReportFindingUiState.kt` | `features/workorders/presentation/finding/report_finding_ui_state.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/finding/ReportFindingViewModel.kt` | `features/workorders/presentation/finding/report_finding_view_model.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/intake/IntakeGalleryScreen.kt` | `features/workorders/presentation/intake/intake_gallery_screen.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/intake/IntakeGalleryUiState.kt` | `features/workorders/presentation/intake/intake_gallery_ui_state.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/intake/IntakeGalleryViewModel.kt` | `features/workorders/presentation/intake/intake_gallery_view_model.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/list/WorkOrdersScreen.kt` | `features/workorders/presentation/list/work_orders_screen.dart` | ✅ igual | Omite chip `orders_pending_suspension_chip` (US29). |
| `features/workorders/presentation/list/WorkOrdersUiState.kt` | `features/workorders/presentation/list/work_orders_ui_state.dart` | ✅ igual | Igual (sin US29). |
| `features/workorders/presentation/list/WorkOrdersViewModel.kt` | `features/workorders/presentation/list/work_orders_view_model.dart` | ✅ igual | Omite `PendingSuspensionMonitor` (US29). |
| `features/workorders/presentation/navigation/WorkOrderNavGraph.kt` | `features/workorders/presentation/navigation/work_order_nav_graph.dart` + `workorders_presentation.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/open/OpenWorkOrderScreen.kt` | `features/workorders/presentation/open/open_work_order_screen.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/open/OpenWorkOrderUiState.kt` | `features/workorders/presentation/open/open_work_order_ui_state.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/open/OpenWorkOrderViewModel.kt` | `features/workorders/presentation/open/open_work_order_view_model.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/proposals/ProposalsPanelScreen.kt` | `features/workorders/presentation/proposals/proposals_panel_screen.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/proposals/ProposalsPanelUiState.kt` | `features/workorders/presentation/proposals/proposals_panel_ui_state.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/proposals/ProposalsPanelViewModel.kt` | `features/workorders/presentation/proposals/proposals_panel_view_model.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/services/ServicesCatalogScreen.kt` | `features/workorders/presentation/services/services_catalog_screen.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/services/ServicesCatalogUiState.kt` | `features/workorders/presentation/services/services_catalog_ui_state.dart` | ✅ igual | Igual. |
| `features/workorders/presentation/services/ServicesCatalogViewModel.kt` | `features/workorders/presentation/services/services_catalog_view_model.dart` | ✅ igual | Igual. |

## 2. Detalle de diferencias menores (`⚠️ diferencias`)

1. **`AtelierSelectionCard` (`atelier_selection_card.dart`):** al estar seleccionada, Flutter envuelve el `Material` en `Padding(1.5)` para simular el borde en gradiente respecto al `border` nativo en Compose.
2. **`FloorHubViewModel` (`floor_hub_view_model.dart`):** omite carga de `stockAlerts` (`US34`), `bays` (`US40`) y los métodos sin uso de previsualización de ubicación.
3. **`DiagnosticsHubScreen` (`diagnostics_hub_screen.dart`):** omite correctamente la fila `Telemetría en vivo` (`US18`). Como diferencia menor, la tarjeta del vehículo seleccionado en Escáner omite el chip de elementos pendientes de sincronizar (`vehicleSyncState`; las fallas DTC pendientes siguen visibles dentro de `VehicleFaultsScreen`).
4. **`DiagnosticsHubUiState` (`diagnostics_hub_ui_state.dart`):** omite `vehicleSyncState` (`US18`). `availableTabs` conserva la condición de Android `canUseTelemetry || canReadTelemetry` para mostrar la pestaña Escáner; un usuario que tuviera únicamente `TELEMETRY_READ` sin permisos de fallas ni IA vería la pestaña Escáner con aviso `diagHubNoPermission` en la tarjeta de acciones (comportamiento heredado de evaluar la pestaña igual que Android).
5. **`DiagnosticsHubViewModel` (`diagnostics_hub_view_model.dart`):** omite `ObserveDiagnosticsSyncStateUseCase` y delega permisos Bluetooth en `RequestBluetoothPermissionUseCase`. Al desinstalar desde la pestaña Dispositivos pasa `null` en `finalOdometerKm`, igual que Android.
6. **`WorkOrderDetailUiState` (`work_order_detail_ui_state.dart`):** omite estados de `US29`/`US35`/`US37–40`. `cascadeBreakdown()` en `cascade.dart` permanece en presentación para cálculos auxiliares de proforma/subtotales sin mostrar el desglose Subtotal/IGV/Total de `US36`.
7. **`OrderCostSheets.kt` (`work_order_detail_dialogs.dart`):** `ProfitabilitySheet` excluida (`US35 ⛔`); `PartMovementsSheet` (`US33 E2`) queda integrada en `work_order_detail_dialogs.dart`.
8. **`WorkOrderDetailDialogs.kt` (`work_order_detail_dialogs.dart`):** omite `SuspensionSheet` (`US29`), `ProfitabilitySheet` (`US35`), `AssignBaySheet` (`US40`) y `CascadeBreakdown` (`US36`). En `PdfPreviewSheet`, en lugar de renderizar bitmaps nativos con `android.graphics.pdf.PdfRenderer`, muestra el resumen textual con banner `quotationPdfReady` y botones Abrir/Compartir vía `open_filex` y `share_plus`.

## 3. Cambios en capas inferiores (`core/`, `domain/`, `application/`, `infrastructure/`)

Se contrastaron permisos, endpoints, casos de uso, repositorios y DAOs entre Android y Flutter para los 12 módulos y `core/`:

- **Permisos:** paridad exacta en `lib/core/domain/permission.dart` frente a `Permission.kt`.
- **`workorders` (agregado en este cierre):** se portaron `DELETE /api/v1/tasks/{taskId}` (`WorkOrderApi.deleteTask`, `RemoveWorkOrderTaskUseCase`) y `DELETE /api/v1/services/{serviceId}` (`ServiceCatalogApi.deleteService`, `DeleteServiceUseCase`), registrados en `workorders_dependencies.dart`.
- **`core/` y caché Drift:** `AuthenticatedClient` implementa reintento acotado para `GET`/`HEAD` idempotentes (`IdempotentGetRetryInterceptor.kt`) y `WorkOrderRepositoryImpl` limpia de Drift las órdenes cerradas (`PAID`/`CANCELED`, equivalente a `WorkOrderCache.kt`). Sin cambios de esquema Drift respecto al paso 9.
- **Portados en Sprint 3:** `TempCacheCleaner.kt` / `GetDevicePendingOperationCountUseCase.kt` (`US04`) → `core/media/temp_cache_cleaner.dart` y `get_device_pending_operation_count_use_case.dart`; `PreSyncHook.kt` / `DiagnosticsPreSyncHook.kt` (`US19`) → `core/data/sync/pre_sync_hook.dart` y `diagnostics_pre_sync_hook.dart`.
- **Elementos no portados (todos pertenecientes a US excluidas o variantes no usadas en Android UI):** `TenantService.kt` (`US42`), `GetLatestVehicleTelemetryUseCase` / `GetVehicleTelemetryHistoryUseCase` / `ReconnectObdUseCase` (`US18`), `ObservePartBrandsUseCase.kt` (sin campo marca en backend, H35), `PendingSuspensionMonitor.kt` (`US29`), casos de uso de comprobantes/series/checkout/handover (`US37–39`, `US42`) y tablero de bahías (`US40`).

## 4. Verificación de exclusiones (US04, US05, US18, US19, US28–30, US34–43)

Barrido sobre `lib/features/**/presentation/**`, `lib/navigation/**` y `AppRoute`:

- **US04 (Sprint 3, portada):** `ProfileScreen` con "Cerrar sesión" y hoja de confirmación; `LoginScreen` con aviso de pendientes del dispositivo.
- **US05 (Sprint 3, portada):** `LoginScreen` con "¿Olvidaste tu contraseña?"; `ForgotPasswordScreen` y `ResetPasswordScreen` registradas en `AuthNavGraph`.
- **US18:** sin `LiveTelemetryScreen`, sin `AppRoute.liveTelemetry` ni fila de telemetría en vivo. `PendingOperationsScreen` de `main` sí se incluye (paso 3).
- **US19 (Sprint 3, portada):** `user_id` en `telemetry_readings` (Drift v3), empaquetado por dueño con ventana de inactividad de 60 s en el pre-sync, empaquetado forzado al cerrar sesión y aviso de lecturas/fallas pendientes del vehículo en `DiagnosticsHubScreen`.
- **US28 / US29 / US30:** `TaskDetailScreen` omite evidencia fotográfica, solicitud/aprobación de suspensión, reanudación y cierre con horas hombre. `WorkOrdersScreen` y `AdminDashboardViewModel` omiten conteos/chips de suspensiones y `app_root.dart` ignora el push `TaskSuspensionReviewDestination`. Solo permanecen etiquetas de solo lectura cuando una tarea ya viene suspendida desde backend.
- **US34:** sin `StockAlertsScreen`, sin entrada en `FloorHubScreen` ni `ModulesSheet`, `app_root.dart` ignora `LowStockAlertsDestination`, y `PurchaseOrderDetailScreen` omite recepción/foto de OC.
- **US35 / US36:** `WorkOrderDetailScreen` omite `ProfitabilitySheet` y tarjeta desglose Subtotal/IGV/Total en `QuotationSummarySection`.
- **US38 / US39 (Sprint 3, portadas):** pasos 2–4 de `WorkOrderCheckoutScreen`; `FloorHubScreen` abre "Cobrar y entregar" desde las órdenes listas.
- **US37–39 / US42 (estado anterior al Sprint 3):** sin pantallas ni rutas de checkout, comprobantes ni series fiscales en `CashierNavGraph` ni `ModulesSheet`; `DailyCashScreen` omite acceso a comprobantes; `FloorHubScreen` navega a `workOrderDetail`. Nota: `BarPrimaryAction.collectPayment` (permisos `invoicesIssueSunat` o `paymentsCreate`) apunta únicamente a `AppRoute.workOrders` / `MainTab.orders` al igual que Android `MainNavigationBar.kt`, sin alcanzar checkout (`US37–39`).
- **US40:** sin `BaysScreen`, sin pestaña ni atajo de bahías; bahía en detalle OT de solo lectura.
- **US41 / US43:** `ReportsScreen` omite exportación PDF de flujo de caja (`US41`) y bloque Salud de Flota (`US43`); `AiHealthReportScreen` omite acciones Abrir/Compartir PDF (`US43`).

## 5. Estado por plataforma

- **Android:** compilado y verificado mediante `flutter analyze`, `flutter test` y `flutter build apk --debug --dart-define-from-file=config/dev.json`.
- **iOS:** sin comprobar (construcción realizada en Windows; requiere Mac para compilar y validar plataforma).
