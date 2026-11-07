import 'dart:io';
import 'dart:ui';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/acknowledge_predictive_alert_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/clear_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/connect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/disconnect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/download_health_report_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/freeze_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/generate_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_active_installation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_health_report_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_paired_obd_adapters_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/install_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/refresh_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/refresh_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/request_bluetooth_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/scan_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/start_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/stop_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/uninstall_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/bluetooth_permission_gateway.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/ble_obd_transport.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/bluetooth_obd_adapter_provider.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/elm327_obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/obd_foreground_controller.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/obd_session_service_controller.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/permission_handler_bluetooth_gateway.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/spp_obd_transport.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/diagnostics_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/health_report_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/predictive_alert_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/telemetry_reading_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/session/live_diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/register_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/resolve_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/telemetry_batch_handler.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:universal_ble/universal_ble.dart';

/// Corre en ambos motores (UI y worker), pero todo es perezoso: el worker solo construye los tres handlers,
/// sin tocar Bluetooth.
void setupDiagnosticsDependencies() {
  getIt.registerLazySingleton<TelemetryReadingDao>(
    () => getIt<AppDatabase>().telemetryReadingDao,
  );
  getIt.registerLazySingleton<VehicleFaultDao>(
    () => getIt<AppDatabase>().vehicleFaultDao,
  );
  getIt.registerLazySingleton<PredictiveAlertDao>(
    () => getIt<AppDatabase>().predictiveAlertDao,
  );

  getIt.registerLazySingleton<IotApi>(() => IotApi(client: getIt<ApiClient>()));

  final handlers = getIt<OperationHandlerRegistry>();
  handlers.register(
    TelemetryBatchHandler.type,
    () => TelemetryBatchHandler(api: getIt<IotApi>()),
  );
  handlers.register(
    RegisterFaultHandler.type,
    () => RegisterFaultHandler(
      api: getIt<IotApi>(),
      dao: getIt<VehicleFaultDao>(),
    ),
  );
  handlers.register(
    ResolveFaultHandler.type,
    () => ResolveFaultHandler(
      api: getIt<IotApi>(),
      dao: getIt<VehicleFaultDao>(),
    ),
  );

  getIt.registerLazySingleton<DiagnosticsRepository>(
    () => DiagnosticsRepositoryImpl(
      api: getIt<IotApi>(),
      readingDao: getIt<TelemetryReadingDao>(),
      faultDao: getIt<VehicleFaultDao>(),
      alertDao: getIt<PredictiveAlertDao>(),
      pendingOperationDao: getIt<PendingOperationDao>(),
      queue: getIt<PendingOperationQueue>(),
      session: getIt<SessionManager>(),
    ),
  );
  getIt.registerLazySingleton<HealthReportRepository>(
    () => HealthReportRepositoryImpl(
      api: getIt<IotApi>(),
      pdfDownloader: getIt<PdfDownloader>(),
    ),
  );

  getIt.registerLazySingleton<ObdLink>(
    () => Elm327ObdLink(
      transportFor: (kind) => switch (kind) {
        ObdAdapterKind.classic => const SppObdTransport(),
        ObdAdapterKind.ble => BleObdTransport(),
      },
    ),
  );
  getIt.registerLazySingleton<ObdAdapterProvider>(
    () => BluetoothObdAdapterProvider(
      bonded: Platform.isIOS ? null : const SppObdTransport().bondedAdapters,
      scan: scanBleAdapters,
      canScan: UniversalBle.hasPermissions,
    ),
  );
  getIt.registerLazySingleton<BluetoothPermissionGateway>(
    () => const PermissionHandlerBluetoothGateway(),
  );
  getIt.registerLazySingleton<ObdForegroundController>(() {
    final strings = lookupAppLocalizations(const Locale('es'));
    return ObdSessionServiceController(
      channelName: strings.notificationChannelDiagnostics,
      notificationTitle: strings.diagnosticsSessionNotificationTitle,
    );
  });
  getIt.registerLazySingleton<DiagnosticSession>(
    () => LiveDiagnosticSession(
      link: getIt<ObdLink>(),
      repository: getIt<DiagnosticsRepository>(),
      locationProvider: getIt<LocationProvider>(),
      foreground: getIt<ObdForegroundController>(),
    ),
  );

  getIt.registerLazySingleton<GetPairedObdAdaptersUseCase>(
    () => GetPairedObdAdaptersUseCase(provider: getIt<ObdAdapterProvider>()),
  );
  getIt.registerLazySingleton<RequestBluetoothPermissionUseCase>(
    () => RequestBluetoothPermissionUseCase(
      gateway: getIt<BluetoothPermissionGateway>(),
    ),
  );
  getIt.registerLazySingleton<GetObdDevicesUseCase>(
    () => GetObdDevicesUseCase(repository: getIt<DiagnosticsRepository>()),
  );
  getIt.registerLazySingleton<GetActiveInstallationUseCase>(
    () => GetActiveInstallationUseCase(
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<InstallObdDeviceUseCase>(
    () => InstallObdDeviceUseCase(repository: getIt<DiagnosticsRepository>()),
  );
  getIt.registerLazySingleton<UninstallObdDeviceUseCase>(
    () => UninstallObdDeviceUseCase(repository: getIt<DiagnosticsRepository>()),
  );
  getIt.registerLazySingleton<ConnectObdUseCase>(
    () => ConnectObdUseCase(session: getIt<DiagnosticSession>()),
  );
  getIt.registerLazySingleton<DisconnectObdUseCase>(
    () => DisconnectObdUseCase(session: getIt<DiagnosticSession>()),
  );
  getIt.registerLazySingleton<StartLiveTelemetryUseCase>(
    () => StartLiveTelemetryUseCase(session: getIt<DiagnosticSession>()),
  );
  getIt.registerLazySingleton<StopLiveTelemetryUseCase>(
    () => StopLiveTelemetryUseCase(session: getIt<DiagnosticSession>()),
  );
  getIt.registerLazySingleton<ObserveLiveTelemetryUseCase>(
    () => ObserveLiveTelemetryUseCase(session: getIt<DiagnosticSession>()),
  );
  getIt.registerLazySingleton<FreezeTelemetryUseCase>(
    () => FreezeTelemetryUseCase(session: getIt<DiagnosticSession>()),
  );
  getIt.registerLazySingleton<ScanFaultsUseCase>(
    () => ScanFaultsUseCase(
      session: getIt<DiagnosticSession>(),
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<ClearFaultsUseCase>(
    () => ClearFaultsUseCase(
      session: getIt<DiagnosticSession>(),
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<RefreshVehicleFaultsUseCase>(
    () => RefreshVehicleFaultsUseCase(
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObserveVehicleFaultsUseCase>(
    () => ObserveVehicleFaultsUseCase(
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObserveDiagnosticsSyncStateUseCase>(
    () => ObserveDiagnosticsSyncStateUseCase(
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<GenerateHealthReportUseCase>(
    () => GenerateHealthReportUseCase(
      repository: getIt<HealthReportRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetLatestHealthReportUseCase>(
    () => GetLatestHealthReportUseCase(
      repository: getIt<HealthReportRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetHealthReportDetailUseCase>(
    () => GetHealthReportDetailUseCase(
      repository: getIt<HealthReportRepository>(),
    ),
  );
  getIt.registerLazySingleton<DownloadHealthReportPdfUseCase>(
    () => DownloadHealthReportPdfUseCase(
      repository: getIt<HealthReportRepository>(),
    ),
  );
  getIt.registerLazySingleton<RefreshPredictiveAlertsUseCase>(
    () => RefreshPredictiveAlertsUseCase(
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObservePredictiveAlertsUseCase>(
    () => ObservePredictiveAlertsUseCase(
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
  getIt.registerLazySingleton<AcknowledgePredictiveAlertUseCase>(
    () => AcknowledgePredictiveAlertUseCase(
      repository: getIt<DiagnosticsRepository>(),
    ),
  );
}
