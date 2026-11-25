import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/acknowledge_predictive_alert_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/connect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/convert_alert_to_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/disconnect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_active_installation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_paired_obd_adapters_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_tenant_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/install_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/refresh_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/register_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/request_bluetooth_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/uninstall_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/update_obd_device_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_validation.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/enrich_reception_references_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_workshop_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:flutter/foundation.dart';

/// Instante UTC de una fecha `yyyy-MM-dd` y hora `HH:mm[:ss]` de Lima; `null` si alguna no es válida.
@visibleForTesting
DateTime? parseLimaInstant(String dateText, String timeText) {
  final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateText.trim());
  final time = RegExp(r'^(\d{2}):(\d{2})(?::(\d{2}))?$').firstMatch(timeText.trim());
  if (date == null || time == null) return null;
  final year = int.parse(date.group(1)!);
  final month = int.parse(date.group(2)!);
  final day = int.parse(date.group(3)!);
  final hour = int.parse(time.group(1)!);
  final minute = int.parse(time.group(2)!);
  final second = int.parse(time.group(3) ?? '0');
  if (hour > 23 || minute > 59 || second > 59) return null;
  final probe = DateTime.utc(year, month, day);
  if (probe.year != year || probe.month != month || probe.day != day) return null;
  return DateTime.utc(year, month, day, hour, minute, second).subtract(BusinessTime.limaOffset);
}

class DiagnosticsHubViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObservePendingOperationCountUseCase observePendingCount;
  final ConnectivityObserver connectivity;
  final ObservePushHistoryUseCase observePushHistory;
  final ObserveWorkshopVehiclesUseCase observeWorkshopVehicles;
  final EnrichReceptionReferencesUseCase enrichReferences;
  final ObserveMyTasksUseCase observeMyTasks;
  final RefreshMyTasksUseCase refreshMyTasks;
  final ObserveBranchWorkOrdersUseCase observeBranchWorkOrders;
  final RefreshBranchWorkOrdersUseCase refreshBranchWorkOrders;
  final GetActiveInstallationUseCase getActiveInstallation;
  final InstallObdDeviceUseCase installObdDevice;
  final UninstallObdDeviceUseCase uninstallObdDevice;
  final GetObdDevicesUseCase getObdDevices;
  final RegisterObdDeviceUseCase registerObdDevice;
  final UpdateObdDeviceStatusUseCase updateObdDeviceStatus;
  final GetPairedObdAdaptersUseCase getPairedObdAdapters;
  final RequestBluetoothPermissionUseCase requestBluetoothPermission;
  final ConnectObdUseCase connectObd;
  final DisconnectObdUseCase disconnectObd;
  final ObserveLiveTelemetryUseCase observeLiveTelemetry;
  final ObserveDiagnosticsSyncStateUseCase? observeSyncState;
  final GetTenantPredictiveAlertsUseCase getTenantPredictiveAlerts;
  final RefreshPredictiveAlertsUseCase refreshPredictiveAlerts;
  final ObservePredictiveAlertsUseCase observePredictiveAlerts;
  final AcknowledgePredictiveAlertUseCase acknowledgePredictiveAlert;
  final ConvertAlertToAppointmentUseCase convertAlertToAppointment;
  final String? initialVehicleId;
  final DateTime Function() now;

  DiagnosticsHubViewModel({
    required this.observeSession,
    required this.observePendingCount,
    required this.connectivity,
    required this.observePushHistory,
    required this.observeWorkshopVehicles,
    required this.enrichReferences,
    required this.observeMyTasks,
    required this.refreshMyTasks,
    required this.observeBranchWorkOrders,
    required this.refreshBranchWorkOrders,
    required this.getActiveInstallation,
    required this.installObdDevice,
    required this.uninstallObdDevice,
    required this.getObdDevices,
    required this.registerObdDevice,
    required this.updateObdDeviceStatus,
    required this.getPairedObdAdapters,
    required this.requestBluetoothPermission,
    required this.connectObd,
    required this.disconnectObd,
    required this.observeLiveTelemetry,
    this.observeSyncState,
    required this.getTenantPredictiveAlerts,
    required this.refreshPredictiveAlerts,
    required this.observePredictiveAlerts,
    required this.acknowledgePredictiveAlert,
    required this.convertAlertToAppointment,
    this.initialVehicleId,
    this.now = DateTime.now,
  }) : _state = DiagnosticsHubUiState(
         selectedVehicleId: initialVehicleId,
         isOnline: connectivity.isOnline,
       ),
       _selectedVehicleId = initialVehicleId {
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _subscriptions.add(
      observeWorkshopVehicles.execute().listen((vehicles) {
        _vehicles = vehicles;
        _hasVehicles = true;
        _recomputeVehicles();
      }),
    );
    _subscriptions.add(
      observeMyTasks.execute().listen((tasks) {
        _tasks = tasks;
        _hasTasks = true;
        _recomputeVehicles();
      }),
    );
    _subscriptions.add(
      observeBranchWorkOrders.execute().listen((orders) {
        _workOrders = orders;
        _hasWorkOrders = true;
        _recomputeVehicles();
      }),
    );
    _subscriptions.add(
      observeLiveTelemetry.execute().listen(
        (live) {
          final chosen = _state.selectedVehicleId ?? live.vehicleId;
          _setSelectedVehicle(chosen);
          _update(_state.copyWith(linkState: live.state, selectedVehicleId: chosen));
        },
      ),
    );
    _subscriptions.add(
      observePendingCount.execute().listen((count) => _update(_state.copyWith(pendingSyncCount: count))),
    );
    _subscriptions.add(
      observePushHistory.execute().listen(
        (records) => _update(
          _state.copyWith(unreadNotificationsCount: records.where((r) => !r.read).length),
        ),
      ),
    );
    connectivity.addListener(_onConnectivity);
    _watchVehicleAlerts(initialVehicleId);
    _watchSyncState(initialVehicleId);
    loadPairedAdapters();
  }

  DiagnosticsHubUiState _state;
  DiagnosticsHubUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  StreamSubscription<List<PredictiveAlert>>? _vehicleAlertsSubscription;
  StreamSubscription<DiagnosticsSyncState>? _syncSubscription;
  String? _selectedVehicleId;
  List<VehicleWithOwner> _vehicles = const [];
  List<Task> _tasks = const [];
  List<WorkOrder> _workOrders = const [];
  bool _hasVehicles = false;
  bool _hasTasks = false;
  bool _hasWorkOrders = false;
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity.isOnline));

  void _update(DiagnosticsHubUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  void _setSelectedVehicle(String? vehicleId) {
    if (vehicleId == _selectedVehicleId) return;
    _selectedVehicleId = vehicleId;
    _watchVehicleAlerts(vehicleId);
    _watchSyncState(vehicleId);
  }

  /// US18: lecturas y fallas del vehículo elegido que aún no llegan al backend.
  void _watchSyncState(String? vehicleId) {
    _syncSubscription?.cancel();
    _syncSubscription = null;
    final observe = observeSyncState;
    _update(_state.copyWith(clearVehicleSyncState: true));
    if (observe == null || vehicleId == null || vehicleId.isEmpty) return;
    _syncSubscription = observe
        .execute(vehicleId)
        .listen((sync) => _update(_state.copyWith(vehicleSyncState: sync)));
  }

  void _watchVehicleAlerts(String? vehicleId) {
    _vehicleAlertsSubscription?.cancel();
    _vehicleAlertsSubscription = null;
    if (vehicleId == null || vehicleId.isEmpty) {
      _update(_state.copyWith(vehicleAlerts: const []));
      return;
    }
    _vehicleAlertsSubscription = observePredictiveAlerts
        .execute(vehicleId)
        .listen((alerts) => _update(_state.copyWith(vehicleAlerts: alerts)));
  }

  void _onSession(Session? session) {
    final planTelemetry = session?.plan?.iotTelemetryEnabled ?? true;
    final planAi = session?.plan?.aiDiagnosticsEnabled ?? true;
    bool has(Permission permission) => session?.has(permission) ?? false;
    var next = _state.copyWith(
      planIncludesTelemetry: planTelemetry,
      planIncludesAi: planAi,
      canUseTelemetry: session?.canUseTelemetry() ?? false,
      canReadTelemetry: session?.canReadTelemetry() ?? false,
      canReadRemoteTelemetry: has(Permission.telemetryRead) && (session?.canReadTelemetry() ?? false),
      canUseAiDiagnostics: session?.canUseAiDiagnostics() ?? false,
      canReadAiReports: session?.canReadAiReports() ?? false,
      canReadDevices: has(Permission.devicesRead),
      canRegisterDevices: has(Permission.devicesRegister),
      canManageInstallations: has(Permission.installationsManage),
      canReadFaults: has(Permission.faultsRead),
      canResolveFaults: has(Permission.faultsResolve) && planTelemetry,
      canReadAlerts: has(Permission.predictiveAlertsRead),
      canAcknowledgeAlerts: has(Permission.predictiveAlertsAcknowledge),
      canCreateAppointment: has(Permission.appointmentsCreate),
      canReportFinding: has(Permission.proposalsCreate),
    );
    final tabs = next.availableTabs;
    if (tabs.isNotEmpty && !tabs.contains(next.selectedTab)) {
      next = next.copyWith(selectedTab: tabs.first);
    }
    _update(next);
    if (session != null && (planTelemetry || planAi)) {
      if (has(Permission.tasksRead) || has(Permission.workOrdersRead)) {
        _update(_state.copyWith(vehiclesLoading: _state.workshopVehicles.isEmpty));
      }
      if (has(Permission.tasksRead)) unawaited(_refreshReference(refreshMyTasks.execute));
      if (has(Permission.workOrdersRead)) unawaited(_refreshReference(refreshBranchWorkOrders.execute));
    }
    if (session != null && planTelemetry) {
      if (has(Permission.devicesRead)) unawaited(loadDevices(_state.deviceStatusFilter));
      if (has(Permission.predictiveAlertsRead)) unawaited(_loadTenantAlerts());
    }
  }

  Future<void> _refreshReference(Future<void> Function() refresh) async {
    try {
      await refresh();
    } on Object {
      // Sin red se sigue con la caché.
    }
    _update(_state.copyWith(vehiclesLoading: false));
  }

  void _recomputeVehicles() {
    // Como `combine` de Android: espera a que las tres fuentes hayan emitido.
    if (!_hasVehicles || !_hasTasks || !_hasWorkOrders) return;
    final woByVehicle = <String, String>{};
    for (final order in _workOrders) {
      woByVehicle[order.vehicleId] = order.id.value;
    }
    for (final task in _tasks) {
      woByVehicle.putIfAbsent(task.vehicleId, () => task.workOrderId);
    }
    final priorityIds = <String>{
      for (final task in _tasks)
        if (task.vehicleId.isNotEmpty) task.vehicleId,
      for (final order in _workOrders)
        if (order.vehicleId.isNotEmpty) order.vehicleId,
    };
    final cachedIds = _vehicles.map((v) => v.vehicle.id).toSet();
    final missing = <String>{
      ...priorityIds,
      ?_selectedVehicleId,
    }.where((id) => id.isNotEmpty && !cachedIds.contains(id)).toList();
    if (missing.isNotEmpty) {
      unawaited(_enrich(missing));
    }
    // Primero los vehículos con tareas u órdenes; el orden relativo se conserva.
    final ordered = [
      ..._vehicles.where((v) => priorityIds.contains(v.vehicle.id)),
      ..._vehicles.where((v) => !priorityIds.contains(v.vehicle.id)),
    ];
    final current = _state.selectedVehicleId;
    final chosen = (current != null && ordered.any((v) => v.vehicle.id == current))
        ? current
        : (initialVehicleId ?? (ordered.isEmpty ? null : ordered.first.vehicle.id));
    _setSelectedVehicle(chosen);
    _update(
      _state.copyWith(
        workshopVehicles: ordered,
        vehicleWorkOrderIds: woByVehicle,
        selectedVehicleId: chosen,
      ),
    );
    if (_state.planIncludesTelemetry) {
      unawaited(_loadDeviceInstallations(ordered));
      if (chosen != null) unawaited(_loadActiveInstallation(chosen));
    }
  }

  Future<void> _enrich(List<String> vehicleIds) async {
    try {
      await enrichReferences.execute(vehicleIds, const []);
    } on Object {
      // Nunca falla la pantalla por enriquecer referencias.
    }
  }

  void selectTab(DiagnosticsHubTab tab) {
    if (!_state.availableTabs.contains(tab)) return;
    _update(_state.copyWith(selectedTab: tab, clearError: true));
    switch (tab) {
      case DiagnosticsHubTab.scanner:
        loadPairedAdapters();
        final vehicleId = _state.selectedVehicleId;
        if (vehicleId != null) unawaited(_loadActiveInstallation(vehicleId));
      case DiagnosticsHubTab.devices:
        unawaited(loadDevices(_state.deviceStatusFilter));
      case DiagnosticsHubTab.alerts:
        unawaited(refreshAlerts());
    }
  }

  void clearNotices() => _update(_state.copyWith(clearError: true, clearNotice: true));

  // region Vehículo e instalación en Escáner

  void openVehiclePicker() => _update(_state.copyWith(vehiclePickerOpen: true, vehicleSearchQuery: ''));

  void dismissVehiclePicker() => _update(_state.copyWith(vehiclePickerOpen: false));

  void onVehicleSearchQueryChange(String query) => _update(_state.copyWith(vehicleSearchQuery: query));

  void selectVehicle(String vehicleId) {
    _setSelectedVehicle(vehicleId);
    _update(_state.copyWith(selectedVehicleId: vehicleId, vehiclePickerOpen: false, clearError: true));
    unawaited(_loadActiveInstallation(vehicleId));
    if (_state.canReadAlerts) {
      unawaited(_refreshVehicleAlertsQuietly(vehicleId));
    }
  }

  Future<void> _refreshVehicleAlertsQuietly(String vehicleId) async {
    try {
      await refreshPredictiveAlerts.execute(vehicleId);
    } on Object {
      // Es solo una actualización en segundo plano.
    }
  }

  Future<void> _loadActiveInstallation(String vehicleId) async {
    if (!_state.canReadDevices || !_state.planIncludesTelemetry || !_state.isOnline) return;
    _update(_state.copyWith(isLoadingInstallation: true));
    try {
      final installation = await getActiveInstallation.execute(vehicleId);
      _update(
        _state.copyWith(
          isLoadingInstallation: false,
          activeInstallation: installation,
          clearActiveInstallation: installation == null,
        ),
      );
    } on Object {
      _update(_state.copyWith(isLoadingInstallation: false));
    }
  }

  void openInstallForSelectedVehicle() {
    final state = _state;
    if (!state.canManageInstallations || !state.isOnline || state.selectedVehicleId == null) return;
    if (state.devices.isEmpty) unawaited(loadDevices(DeviceStatus.active));
    final odometer = state.selectedVehicle?.vehicle.currentMileage?.toString() ?? '';
    _update(
      _state.copyWith(
        installForVehicleSheetOpen: true,
        installOdometerInput: odometer,
        installOdometerInvalid: false,
        clearError: true,
      ),
    );
  }

  void dismissInstallForSelectedVehicle() {
    if (_state.isSavingDeviceAction) return;
    _update(_state.copyWith(installForVehicleSheetOpen: false));
  }

  void onInstallOdometerChange(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    _update(_state.copyWith(installOdometerInput: digits, installOdometerInvalid: false));
  }

  Future<void> confirmInstallOnSelectedVehicle(ObdDevice device) async {
    final state = _state;
    final vehicleId = state.selectedVehicleId;
    if (vehicleId == null || state.isSavingDeviceAction || !state.isOnline) return;
    final odometerText = state.installOdometerInput.trim();
    final odometerKm = odometerText.isEmpty ? null : int.tryParse(odometerText);
    if ((odometerText.isNotEmpty && odometerKm == null) || !DiagnosticsValidation.isOdometer(odometerKm)) {
      _update(_state.copyWith(installOdometerInvalid: true));
      return;
    }
    _update(_state.copyWith(isSavingDeviceAction: true, clearError: true));
    try {
      final installation = await installObdDevice.execute(
        deviceId: device.id,
        vehicleId: vehicleId,
        currentOdometerKm: odometerKm,
      );
      final vehicle = _state.selectedVehicle;
      final summary = vehicle == null ? null : _summaryOf(installation.id, device.id, vehicle);
      _update(
        _state.copyWith(
          isSavingDeviceAction: false,
          installForVehicleSheetOpen: false,
          activeInstallation: installation,
          deviceInstallations: summary == null
              ? _state.deviceInstallations
              : {..._state.deviceInstallations, device.id: summary},
          notice: UiText.resource((s) => s.obdInstallSuccess(vehicle?.vehicle.plate ?? '')),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isSavingDeviceAction: false, error: toDiagnosticsUiText(e)));
    }
  }

  DeviceInstallationSummary _summaryOf(String installationId, String deviceId, VehicleWithOwner item) {
    return DeviceInstallationSummary(
      installationId: installationId,
      deviceId: deviceId,
      vehicleId: item.vehicle.id,
      plate: item.vehicle.plate,
      vehicleModel: '${item.vehicle.brand} ${item.vehicle.model}'.trim(),
      ownerName: item.owner?.displayName,
    );
  }

  Future<void> uninstallFromSelectedVehicle() async {
    final state = _state;
    final installation = state.activeInstallation;
    if (installation == null) return;
    if (!state.canManageInstallations || !state.isOnline || state.isSavingDeviceAction) return;
    _update(_state.copyWith(isSavingDeviceAction: true, clearError: true));
    try {
      await uninstallObdDevice.execute(
        installation.id,
        finalOdometerKm: state.selectedVehicle?.vehicle.currentMileage,
      );
      _update(
        _state.copyWith(
          isSavingDeviceAction: false,
          clearActiveInstallation: true,
          deviceInstallations: {..._state.deviceInstallations}..remove(installation.deviceId),
          notice: UiText.resource((s) => s.obdUninstallSuccess),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isSavingDeviceAction: false, error: toDiagnosticsUiText(e)));
    }
  }

  // endregion

  // region Bluetooth ELM327

  Future<void> loadPairedAdapters() async {
    try {
      final adapters = await getPairedObdAdapters.execute();
      final state = _state;
      final selected = state.selectedAdapterAddress;
      final chosen = (selected != null && adapters.any((a) => a.address == selected))
          ? selected
          : _firstOrNull(adapters.where((a) => state.devices.any((d) => d.matches(a.address))))?.address ??
                _firstOrNull(adapters)?.address;
      _update(
        _state.copyWith(
          pairedAdapters: adapters,
          selectedAdapterAddress: chosen,
          clearSelectedAdapter: chosen == null,
          bluetoothPermissionRequired: false,
          bluetoothDisabled: false,
        ),
      );
    } on Object catch (e) {
      _update(
        _state.copyWith(
          pairedAdapters: const [],
          bluetoothPermissionRequired: e is BluetoothPermissionDeniedException,
          bluetoothDisabled: e is BluetoothDisabledException,
        ),
      );
    }
  }

  /// Pide el permiso de Bluetooth y, concedido, recarga los adaptadores emparejados.
  Future<void> requestBluetooth() async {
    bool granted;
    try {
      granted = await requestBluetoothPermission.execute();
    } on Object {
      granted = false;
    }
    await onBluetoothPermissionResult(granted);
  }

  Future<void> onBluetoothPermissionResult(bool granted) async {
    if (granted) {
      await loadPairedAdapters();
    } else {
      _update(_state.copyWith(bluetoothPermissionRequired: true));
    }
  }

  void selectAdapter(String address) {
    _update(_state.copyWith(selectedAdapterAddress: address, clearError: true));
  }

  Future<void> connectSelectedAdapter() async {
    final state = _state;
    final address = state.selectedAdapterAddress;
    if (address == null || !state.canConnectBluetooth || state.isConnecting) return;
    final adapter = _firstOrNull(state.pairedAdapters.where((a) => a.address == address));
    if (adapter == null) return;
    _update(_state.copyWith(isConnecting: true, clearError: true, clearNotice: true));
    try {
      final info = await connectObd.execute(adapter);
      _update(_state.copyWith(isConnecting: false, connectionInfo: info));
    } on Object catch (e) {
      _update(
        _state.copyWith(isConnecting: false, clearConnectionInfo: true, error: toDiagnosticsUiText(e)),
      );
    }
  }

  Future<void> disconnectAdapter() async {
    try {
      await disconnectObd.execute();
    } on Object {
      // Se deja el enlace como esté; el estado real llega por la sesión.
    }
    _update(_state.copyWith(clearConnectionInfo: true));
  }

  // endregion

  // region Dispositivos OBD-II (pestaña 2)

  Future<void> loadDevices([DeviceStatus? filter, bool keepFilter = true]) async {
    if (!_state.canReadDevices || !_state.planIncludesTelemetry) return;
    final effective = keepFilter && filter == null ? _state.deviceStatusFilter : filter;
    _update(
      _state.copyWith(
        isLoadingDevices: true,
        deviceStatusFilter: effective,
        clearDeviceStatusFilter: effective == null,
        clearError: true,
      ),
    );
    try {
      final list = await getObdDevices.execute(status: effective);
      _update(_state.copyWith(isLoadingDevices: false, devices: list));
      unawaited(_loadDeviceInstallations(_state.workshopVehicles));
    } on Object catch (e) {
      _update(_state.copyWith(isLoadingDevices: false, error: toDiagnosticsUiText(e)));
    }
  }

  /// Aplica el filtro de estado tal cual (incluido "Todos" = `null`) y recarga.
  Future<void> filterDevices(DeviceStatus? filter) => loadDevices(filter, false);

  Future<void> _loadDeviceInstallations(List<VehicleWithOwner> vehicles) async {
    if (vehicles.isEmpty || !_state.canReadDevices || !_state.isOnline) return;
    final entries = await Future.wait(
      vehicles.map((item) async {
        try {
          final active = await getActiveInstallation.execute(item.vehicle.id);
          if (active != null && active.isActive) {
            return MapEntry(active.deviceId, _summaryOf(active.id, active.deviceId, item));
          }
        } on Object {
          // Un vehículo sin respuesta no bloquea al resto.
        }
        return null;
      }),
    );
    _update(
      _state.copyWith(
        deviceInstallations: {
          for (final entry in entries)
            if (entry != null) entry.key: entry.value,
        },
      ),
    );
  }

  void onOpenRegisterDevice() {
    if (!_state.canRegisterDevices || !_state.isOnline) return;
    _update(_state.copyWith(registerForm: const RegisterObdDeviceForm(), clearError: true, clearNotice: true));
  }

  void onDismissRegisterDevice() {
    if (_state.isSavingDeviceAction) return;
    _update(_state.copyWith(clearRegisterForm: true, clearError: true));
  }

  void onIdentifierChange(String value) => _editRegisterForm((f) => f.copyWith(deviceIdentifier: value));

  void onConnectionTypeChange(String value) => _editRegisterForm((f) => f.copyWith(connectionType: value));

  void onHardwareModelChange(String value) => _editRegisterForm((f) => f.copyWith(hardwareModel: value));

  void onFirmwareVersionChange(String value) => _editRegisterForm((f) => f.copyWith(firmwareVersion: value));

  void _editRegisterForm(RegisterObdDeviceForm Function(RegisterObdDeviceForm) transform) {
    final form = _state.registerForm;
    if (form == null || _state.isSavingDeviceAction) return;
    _update(_state.copyWith(registerForm: transform(form), clearError: true));
  }

  Future<void> onConfirmRegisterDevice() async {
    final state = _state;
    final form = state.registerForm;
    if (form == null) return;
    if (!state.canRegisterDevices || !form.canSubmit || state.isSavingDeviceAction || !state.isOnline) return;
    _update(_state.copyWith(isSavingDeviceAction: true, clearError: true));
    try {
      final created = await registerObdDevice.execute(
        deviceIdentifier: form.deviceIdentifier,
        connectionType: form.connectionType,
        hardwareModel: _blankToNull(form.hardwareModel),
        firmwareVersion: _blankToNull(form.firmwareVersion),
      );
      _update(
        _state.copyWith(
          isSavingDeviceAction: false,
          clearRegisterForm: true,
          devices: [created, ..._state.devices],
          notice: UiText.resource((s) => s.obdRegisteredNotice(created.deviceIdentifier)),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isSavingDeviceAction: false, error: toDiagnosticsUiText(e)));
    }
  }

  void onOpenStatusSheet(ObdDevice device) {
    if (!_state.canRegisterDevices || !_state.isOnline) return;
    _update(_state.copyWith(editingStatusDevice: device, clearError: true, clearNotice: true));
  }

  void onDismissStatusSheet() {
    if (_state.isSavingDeviceAction) return;
    _update(_state.copyWith(clearEditingStatusDevice: true));
  }

  Future<void> onUpdateDeviceStatus(DeviceStatus status) async {
    final device = _state.editingStatusDevice;
    if (device == null || _state.isSavingDeviceAction) return;
    _update(_state.copyWith(isSavingDeviceAction: true, clearError: true));
    try {
      final updated = await updateObdDeviceStatus.execute(device.id, status);
      _update(
        _state.copyWith(
          isSavingDeviceAction: false,
          clearEditingStatusDevice: true,
          devices: _state.devices.map((d) => d.id == updated.id ? updated : d).toList(),
          notice: UiText.resource((s) => s.obdStatusUpdatedNotice(updated.deviceIdentifier)),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isSavingDeviceAction: false, error: toDiagnosticsUiText(e)));
    }
  }

  void onOpenInstallDevice(ObdDevice device) {
    if (!_state.canManageInstallations || !_state.isOnline) return;
    _update(_state.copyWith(installingDevice: device, clearError: true, clearNotice: true));
  }

  void onDismissInstallDevice() {
    if (_state.isSavingDeviceAction) return;
    _update(_state.copyWith(clearInstallingDevice: true));
  }

  Future<void> onConfirmInstallDevice(VehicleWithOwner vehicle) async {
    final device = _state.installingDevice;
    if (device == null || _state.isSavingDeviceAction) return;
    _update(_state.copyWith(isSavingDeviceAction: true, clearError: true));
    try {
      final installation = await installObdDevice.execute(
        deviceId: device.id,
        vehicleId: vehicle.vehicle.id,
        currentOdometerKm: vehicle.vehicle.currentMileage,
      );
      final summary = _summaryOf(installation.id, device.id, vehicle);
      _update(
        _state.copyWith(
          isSavingDeviceAction: false,
          clearInstallingDevice: true,
          deviceInstallations: {..._state.deviceInstallations, device.id: summary},
          activeInstallation: _state.selectedVehicleId == vehicle.vehicle.id
              ? installation
              : _state.activeInstallation,
          notice: UiText.resource((s) => s.obdInstallSuccess(vehicle.vehicle.plate)),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isSavingDeviceAction: false, error: toDiagnosticsUiText(e)));
    }
  }

  void onOpenUninstallDevice(ObdDevice device) {
    if (!_state.canManageInstallations || !_state.isOnline) return;
    _update(_state.copyWith(uninstallingDevice: device, clearError: true, clearNotice: true));
  }

  void onDismissUninstallDevice() {
    if (_state.isSavingDeviceAction) return;
    _update(_state.copyWith(clearUninstallingDevice: true));
  }

  Future<void> onConfirmUninstallDevice() async {
    final device = _state.uninstallingDevice;
    if (device == null) return;
    final summary = _state.deviceInstallations[device.id];
    if (summary == null || _state.isSavingDeviceAction) return;
    _update(_state.copyWith(isSavingDeviceAction: true, clearError: true));
    try {
      await uninstallObdDevice.execute(summary.installationId);
      final isSelected = _state.selectedVehicleId == summary.vehicleId;
      _update(
        _state.copyWith(
          isSavingDeviceAction: false,
          clearUninstallingDevice: true,
          deviceInstallations: {..._state.deviceInstallations}..remove(device.id),
          clearActiveInstallation: isSelected,
          notice: UiText.resource((s) => s.obdUninstallSuccess),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isSavingDeviceAction: false, error: toDiagnosticsUiText(e)));
    }
  }

  // endregion

  // region Alertas predictivas (pestaña 3)

  Future<void> setAlertsScope(AlertsScope scope) {
    _update(_state.copyWith(alertsScope: scope, clearError: true));
    return refreshAlerts();
  }

  Future<void> refreshAlerts() async {
    if (!_state.canReadAlerts) return;
    switch (_state.alertsScope) {
      case AlertsScope.tenant:
        await _loadTenantAlerts();
      case AlertsScope.vehicle:
        final vehicleId = _state.selectedVehicleId;
        if (vehicleId == null) return;
        _update(_state.copyWith(isLoadingAlerts: true, clearError: true));
        try {
          await refreshPredictiveAlerts.execute(vehicleId);
          _update(_state.copyWith(isLoadingAlerts: false));
        } on Object catch (e) {
          _update(_state.copyWith(isLoadingAlerts: false, error: toDiagnosticsUiText(e)));
        }
    }
  }

  Future<void> _loadTenantAlerts() async {
    if (!_state.canReadAlerts) return;
    _update(_state.copyWith(isLoadingAlerts: true, clearError: true));
    try {
      final list = await getTenantPredictiveAlerts.execute();
      _update(_state.copyWith(isLoadingAlerts: false, tenantAlerts: list));
      final cachedIds = _state.workshopVehicles.map((v) => v.vehicle.id).toSet();
      final missing = list
          .map((a) => a.vehicleId)
          .where((id) => id.isNotEmpty && !cachedIds.contains(id))
          .toSet()
          .toList();
      if (missing.isNotEmpty) await _enrich(missing);
    } on Object catch (e) {
      _update(_state.copyWith(isLoadingAlerts: false, error: toDiagnosticsUiText(e)));
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    final state = _state;
    if (!state.canAcknowledgeAlerts || !state.isOnline || state.isActingOnAlert) return;
    _update(_state.copyWith(isActingOnAlert: true, clearError: true, clearNotice: true));
    try {
      final updated = await acknowledgePredictiveAlert.execute(alertId);
      final merged = PredictiveAlert(
        id: updated.id,
        vehicleId: updated.vehicleId,
        alertType: updated.alertType,
        confidenceScore: updated.confidenceScore,
        message: updated.message,
        status: updated.status ?? PredictiveAlertStatus.acknowledged,
        recommendedServiceId: updated.recommendedServiceId,
        createdAt: updated.createdAt,
      );
      _update(
        _state.copyWith(
          isActingOnAlert: false,
          tenantAlerts: _state.tenantAlerts.map((a) => a.id == updated.id ? merged : a).toList(),
          notice: UiText.resource((s) => s.diagAlertsAckDone),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isActingOnAlert: false, error: toDiagnosticsUiText(e)));
    }
  }

  void openConvertAlertSheet(PredictiveAlert alert) {
    if (!_state.canCreateAppointment || !_state.isOnline) return;
    _update(
      _state.copyWith(
        convertingAlert: alert,
        convertAlertDateText: _limaDayFromToday(1),
        convertAlertTimeText: '10:00',
        convertAlertDurationText: '60',
        convertAlertReason: alert.message,
        clearError: true,
        clearNotice: true,
      ),
    );
  }

  String _limaDayFromToday(int days) => BusinessTime.addDays(BusinessTime.limaDate(now()), days);

  void dismissConvertAlertSheet() {
    if (_state.isActingOnAlert) return;
    _update(_state.copyWith(clearConvertingAlert: true, clearError: true));
  }

  void onConvertAlertQuickDate(int daysFromToday) {
    _update(_state.copyWith(convertAlertDateText: _limaDayFromToday(daysFromToday), clearError: true));
  }

  void onConvertAlertDateChange(String value) {
    _update(_state.copyWith(convertAlertDateText: _take(value, 10), clearError: true));
  }

  void onConvertAlertTimeChange(String value) {
    _update(_state.copyWith(convertAlertTimeText: _take(value, 5), clearError: true));
  }

  void onConvertAlertDurationChange(String value) {
    _update(
      _state.copyWith(convertAlertDurationText: _take(value.replaceAll(RegExp(r'\D'), ''), 3), clearError: true),
    );
  }

  void onConvertAlertReasonChange(String value) {
    _update(_state.copyWith(convertAlertReason: _take(value, 500), clearError: true));
  }

  Future<void> confirmConvertAlertToAppointment() async {
    final state = _state;
    final alert = state.convertingAlert;
    if (alert == null) return;
    if (!state.canCreateAppointment || !state.isOnline || state.isActingOnAlert) return;

    final scheduledAt = parseLimaInstant(state.convertAlertDateText, state.convertAlertTimeText);
    if (scheduledAt == null || !scheduledAt.isAfter(now())) {
      _update(_state.copyWith(error: UiText.resource((s) => s.diagAlertsConvertInvalidDatetime)));
      return;
    }
    final duration = int.tryParse(state.convertAlertDurationText.trim());
    if (duration == null || duration < 15) {
      _update(_state.copyWith(error: UiText.resource((s) => s.diagAlertsConvertInvalidDuration)));
      return;
    }
    final reasonText = state.convertAlertReason.trim();
    final reason = reasonText.isEmpty ? alert.message : reasonText;

    _update(_state.copyWith(isActingOnAlert: true, clearError: true));
    try {
      final appointment = await convertAlertToAppointment.execute(
        alert.id,
        scheduledAt: scheduledAt,
        estimatedDurationMinutes: duration,
        reason: reason,
      );
      final dateText = formatLimaDateTime(appointment.scheduledAt ?? scheduledAt);
      _update(
        _state.copyWith(
          isActingOnAlert: false,
          clearConvertingAlert: true,
          notice: UiText.resource(
            (s) => s.diagAlertsConvertOk(dateText.isEmpty ? appointment.appointmentId : dateText),
          ),
        ),
      );
      unawaited(refreshAlerts());
    } on Object catch (e) {
      _update(_state.copyWith(isActingOnAlert: false, error: toDiagnosticsUiText(e)));
    }
  }

  // endregion

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    _vehicleAlertsSubscription?.cancel();
    _syncSubscription?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

String _take(String value, int max) => value.length <= max ? value : value.substring(0, max);

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

T? _firstOrNull<T>(Iterable<T> items) => items.isEmpty ? null : items.first;
