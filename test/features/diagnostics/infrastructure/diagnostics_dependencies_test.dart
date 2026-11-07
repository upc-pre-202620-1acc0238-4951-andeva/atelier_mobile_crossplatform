import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
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
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/register_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/resolve_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/telemetry_batch_handler.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    setupDependencies();
    getIt.unregister<AppDatabase>();
    getIt.registerLazySingleton<AppDatabase>(
      () => AppDatabase(NativeDatabase.memory()),
      dispose: (database) => database.close(),
    );
  });

  tearDown(() => getIt.reset());

  test('los 24 casos de uso se pueden resolver', () {
    expect(getIt<GetPairedObdAdaptersUseCase>(), isNotNull);
    expect(getIt<RequestBluetoothPermissionUseCase>(), isNotNull);
    expect(getIt<GetObdDevicesUseCase>(), isNotNull);
    expect(getIt<GetActiveInstallationUseCase>(), isNotNull);
    expect(getIt<InstallObdDeviceUseCase>(), isNotNull);
    expect(getIt<UninstallObdDeviceUseCase>(), isNotNull);
    expect(getIt<ConnectObdUseCase>(), isNotNull);
    expect(getIt<DisconnectObdUseCase>(), isNotNull);
    expect(getIt<StartLiveTelemetryUseCase>(), isNotNull);
    expect(getIt<StopLiveTelemetryUseCase>(), isNotNull);
    expect(getIt<ObserveLiveTelemetryUseCase>(), isNotNull);
    expect(getIt<FreezeTelemetryUseCase>(), isNotNull);
    expect(getIt<ScanFaultsUseCase>(), isNotNull);
    expect(getIt<ClearFaultsUseCase>(), isNotNull);
    expect(getIt<RefreshVehicleFaultsUseCase>(), isNotNull);
    expect(getIt<ObserveVehicleFaultsUseCase>(), isNotNull);
    expect(getIt<ObserveDiagnosticsSyncStateUseCase>(), isNotNull);
    expect(getIt<GenerateHealthReportUseCase>(), isNotNull);
    expect(getIt<GetLatestHealthReportUseCase>(), isNotNull);
    expect(getIt<GetHealthReportDetailUseCase>(), isNotNull);
    expect(getIt<DownloadHealthReportPdfUseCase>(), isNotNull);
    expect(getIt<RefreshPredictiveAlertsUseCase>(), isNotNull);
    expect(getIt<ObservePredictiveAlertsUseCase>(), isNotNull);
    expect(getIt<AcknowledgePredictiveAlertUseCase>(), isNotNull);
  });

  // Es lo único que resuelve el worker: si tocara Bluetooth, fallaría en un motor sin esos plugins.
  test('los tres handlers se construyen desde el registro', () {
    final handlers = getIt<OperationHandlerRegistry>();

    expect(
      handlers.find(TelemetryBatchHandler.type),
      isA<TelemetryBatchHandler>(),
    );
    expect(
      handlers.find(RegisterFaultHandler.type),
      isA<RegisterFaultHandler>(),
    );
    expect(handlers.find(ResolveFaultHandler.type), isA<ResolveFaultHandler>());
  });
}
