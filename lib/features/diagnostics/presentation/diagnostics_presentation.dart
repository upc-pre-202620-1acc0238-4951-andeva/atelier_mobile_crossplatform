import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/acknowledge_predictive_alert_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/clear_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/connect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/convert_alert_to_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/disconnect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/generate_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_active_installation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_health_report_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_paired_obd_adapters_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_tenant_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/install_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/refresh_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/refresh_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/register_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/request_bluetooth_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/scan_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/uninstall_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/update_obd_device_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/faults/vehicle_faults_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/navigation/diagnostics_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/report/ai_health_report_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/enrich_reception_references_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_workshop_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Pantallas y ViewModels de `diagnostics` (hub, fallas DTC e informe IA). Telemetría en vivo (US18) y
/// exportación PDF (US43) quedan fuera de esta capa.
void setupDiagnosticsPresentation() {
  registerDiagnosticsRoutes();

  getIt.registerFactoryParam<DiagnosticsHubViewModel, String?, void>(
    (initialVehicleId, _) => DiagnosticsHubViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observePendingCount: getIt<ObservePendingOperationCountUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      observePushHistory: getIt<ObservePushHistoryUseCase>(),
      observeWorkshopVehicles: getIt<ObserveWorkshopVehiclesUseCase>(),
      enrichReferences: getIt<EnrichReceptionReferencesUseCase>(),
      observeMyTasks: getIt<ObserveMyTasksUseCase>(),
      refreshMyTasks: getIt<RefreshMyTasksUseCase>(),
      observeBranchWorkOrders: getIt<ObserveBranchWorkOrdersUseCase>(),
      refreshBranchWorkOrders: getIt<RefreshBranchWorkOrdersUseCase>(),
      getActiveInstallation: getIt<GetActiveInstallationUseCase>(),
      installObdDevice: getIt<InstallObdDeviceUseCase>(),
      uninstallObdDevice: getIt<UninstallObdDeviceUseCase>(),
      getObdDevices: getIt<GetObdDevicesUseCase>(),
      registerObdDevice: getIt<RegisterObdDeviceUseCase>(),
      updateObdDeviceStatus: getIt<UpdateObdDeviceStatusUseCase>(),
      getPairedObdAdapters: getIt<GetPairedObdAdaptersUseCase>(),
      requestBluetoothPermission: getIt<RequestBluetoothPermissionUseCase>(),
      connectObd: getIt<ConnectObdUseCase>(),
      disconnectObd: getIt<DisconnectObdUseCase>(),
      observeLiveTelemetry: getIt<ObserveLiveTelemetryUseCase>(),
      getTenantPredictiveAlerts: getIt<GetTenantPredictiveAlertsUseCase>(),
      refreshPredictiveAlerts: getIt<RefreshPredictiveAlertsUseCase>(),
      observePredictiveAlerts: getIt<ObservePredictiveAlertsUseCase>(),
      acknowledgePredictiveAlert: getIt<AcknowledgePredictiveAlertUseCase>(),
      convertAlertToAppointment: getIt<ConvertAlertToAppointmentUseCase>(),
      initialVehicleId: initialVehicleId,
    ),
  );
  getIt.registerFactoryParam<VehicleFaultsViewModel, VehicleArgs, void>(
    (args, _) => VehicleFaultsViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeVehicle: getIt<ObserveVehicleUseCase>(),
      observeVehicleFaults: getIt<ObserveVehicleFaultsUseCase>(),
      observeSyncState: getIt<ObserveDiagnosticsSyncStateUseCase>(),
      observeLiveTelemetry: getIt<ObserveLiveTelemetryUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      refreshVehicleFaults: getIt<RefreshVehicleFaultsUseCase>(),
      scanFaultsUseCase: getIt<ScanFaultsUseCase>(),
      clearFaultsUseCase: getIt<ClearFaultsUseCase>(),
      vehicleId: args.vehicleId,
      plate: args.plate,
    ),
  );
  getIt.registerFactoryParam<AiHealthReportViewModel, VehicleArgs, void>(
    (args, _) => AiHealthReportViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeVehicle: getIt<ObserveVehicleUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      getLatestHealthReport: getIt<GetLatestHealthReportUseCase>(),
      getHealthReportDetail: getIt<GetHealthReportDetailUseCase>(),
      generateHealthReport: getIt<GenerateHealthReportUseCase>(),
      vehicleId: args.vehicleId,
      plate: args.plate,
    ),
  );
}
