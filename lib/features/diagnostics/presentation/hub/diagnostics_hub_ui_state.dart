import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

enum DiagnosticsHubTab { scanner, devices, alerts }

enum AlertsScope { tenant, vehicle }

class DeviceInstallationSummary {
  final String installationId;
  final String deviceId;
  final String vehicleId;
  final String plate;
  final String vehicleModel;
  final String? ownerName;

  const DeviceInstallationSummary({
    required this.installationId,
    required this.deviceId,
    required this.vehicleId,
    required this.plate,
    required this.vehicleModel,
    this.ownerName,
  });
}

class RegisterObdDeviceForm {
  final String deviceIdentifier;
  final String connectionType;
  final String hardwareModel;
  final String firmwareVersion;

  const RegisterObdDeviceForm({
    this.deviceIdentifier = '',
    this.connectionType = 'BLUETOOTH_BLE',
    this.hardwareModel = '',
    this.firmwareVersion = '',
  });

  bool get canSubmit => deviceIdentifier.trim().isNotEmpty && connectionType.trim().isNotEmpty;

  RegisterObdDeviceForm copyWith({
    String? deviceIdentifier,
    String? connectionType,
    String? hardwareModel,
    String? firmwareVersion,
  }) {
    return RegisterObdDeviceForm(
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      connectionType: connectionType ?? this.connectionType,
      hardwareModel: hardwareModel ?? this.hardwareModel,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }
}

/// Estado único del hub de diagnóstico OBD-II (pestañas Escáner, Dispositivos y Alertas).
class DiagnosticsHubUiState {
  final DiagnosticsHubTab selectedTab;
  // Plan y permisos
  final bool planIncludesTelemetry;
  final bool planIncludesAi;
  final bool canUseTelemetry;
  final bool canReadTelemetry;
  final bool canUseAiDiagnostics;
  final bool canReadAiReports;
  final bool canReadDevices;
  final bool canRegisterDevices;
  final bool canManageInstallations;
  final bool canReadFaults;
  final bool canResolveFaults;
  final bool canReadAlerts;
  final bool canAcknowledgeAlerts;
  final bool canCreateAppointment;
  final bool canReportFinding;
  // Estado global
  final bool isOnline;
  final int unreadNotificationsCount;
  final int pendingSyncCount;
  final UiText? error;
  final UiText? notice;
  // Vehículos
  final List<VehicleWithOwner> workshopVehicles;
  final bool vehiclesLoading;
  final Map<String, String> vehicleWorkOrderIds;
  final String? selectedVehicleId;
  final bool vehiclePickerOpen;
  final String vehicleSearchQuery;
  // Escáner y vinculación (pestaña 1)
  final DeviceInstallation? activeInstallation;
  final bool isLoadingInstallation;
  final bool installForVehicleSheetOpen;
  final String installOdometerInput;
  final bool installOdometerInvalid;
  final List<ObdAdapter> pairedAdapters;
  final bool bluetoothPermissionRequired;
  final bool bluetoothDisabled;
  final String? selectedAdapterAddress;
  final ObdLinkState linkState;
  final ObdConnectionInfo? connectionInfo;
  final bool isConnecting;
  // Dispositivos (pestaña 2)
  final List<ObdDevice> devices;
  final DeviceStatus? deviceStatusFilter;
  final bool isLoadingDevices;
  final Map<String, DeviceInstallationSummary> deviceInstallations;
  final RegisterObdDeviceForm? registerForm;
  final ObdDevice? editingStatusDevice;
  final ObdDevice? installingDevice;
  final ObdDevice? uninstallingDevice;
  final bool isSavingDeviceAction;
  // Alertas predictivas (pestaña 3)
  final AlertsScope alertsScope;
  final List<PredictiveAlert> tenantAlerts;
  final List<PredictiveAlert> vehicleAlerts;
  final bool isLoadingAlerts;
  final PredictiveAlert? convertingAlert;
  final String convertAlertDateText;
  final String convertAlertTimeText;
  final String convertAlertDurationText;
  final String convertAlertReason;
  final bool isActingOnAlert;

  const DiagnosticsHubUiState({
    this.selectedTab = DiagnosticsHubTab.scanner,
    this.planIncludesTelemetry = true,
    this.planIncludesAi = true,
    this.canUseTelemetry = false,
    this.canReadTelemetry = false,
    this.canUseAiDiagnostics = false,
    this.canReadAiReports = false,
    this.canReadDevices = false,
    this.canRegisterDevices = false,
    this.canManageInstallations = false,
    this.canReadFaults = false,
    this.canResolveFaults = false,
    this.canReadAlerts = false,
    this.canAcknowledgeAlerts = false,
    this.canCreateAppointment = false,
    this.canReportFinding = false,
    this.isOnline = true,
    this.unreadNotificationsCount = 0,
    this.pendingSyncCount = 0,
    this.error,
    this.notice,
    this.workshopVehicles = const [],
    this.vehiclesLoading = false,
    this.vehicleWorkOrderIds = const {},
    this.selectedVehicleId,
    this.vehiclePickerOpen = false,
    this.vehicleSearchQuery = '',
    this.activeInstallation,
    this.isLoadingInstallation = false,
    this.installForVehicleSheetOpen = false,
    this.installOdometerInput = '',
    this.installOdometerInvalid = false,
    this.pairedAdapters = const [],
    this.bluetoothPermissionRequired = false,
    this.bluetoothDisabled = false,
    this.selectedAdapterAddress,
    this.linkState = ObdLinkState.disconnected,
    this.connectionInfo,
    this.isConnecting = false,
    this.devices = const [],
    this.deviceStatusFilter,
    this.isLoadingDevices = false,
    this.deviceInstallations = const {},
    this.registerForm,
    this.editingStatusDevice,
    this.installingDevice,
    this.uninstallingDevice,
    this.isSavingDeviceAction = false,
    this.alertsScope = AlertsScope.tenant,
    this.tenantAlerts = const [],
    this.vehicleAlerts = const [],
    this.isLoadingAlerts = false,
    this.convertingAlert,
    this.convertAlertDateText = '',
    this.convertAlertTimeText = '10:00',
    this.convertAlertDurationText = '60',
    this.convertAlertReason = '',
    this.isActingOnAlert = false,
  });

  List<DiagnosticsHubTab> get availableTabs {
    final hasScannerTelemetry =
        planIncludesTelemetry &&
        (canUseTelemetry || canReadTelemetry || canReadFaults || canResolveFaults);
    final hasScannerAi = planIncludesAi && (canUseAiDiagnostics || canReadAiReports);
    return [
      if (hasScannerTelemetry || hasScannerAi) DiagnosticsHubTab.scanner,
      if (planIncludesTelemetry && (canReadDevices || canRegisterDevices)) DiagnosticsHubTab.devices,
      if (planIncludesTelemetry && canReadAlerts) DiagnosticsHubTab.alerts,
    ];
  }

  bool get canConnectBluetooth => planIncludesTelemetry && (canUseTelemetry || canResolveFaults);

  VehicleWithOwner? get selectedVehicle {
    for (final item in workshopVehicles) {
      if (item.vehicle.id == selectedVehicleId) return item;
    }
    return null;
  }

  String? get selectedVehicleWorkOrderId {
    final id = selectedVehicleId;
    return id == null ? null : vehicleWorkOrderIds[id];
  }

  List<VehicleWithOwner> get filteredVehicles {
    final q = vehicleSearchQuery.trim().toLowerCase();
    if (q.isEmpty) return workshopVehicles;
    return workshopVehicles.where((item) {
      return item.vehicle.plate.toLowerCase().contains(q) ||
          item.vehicle.brand.toLowerCase().contains(q) ||
          item.vehicle.model.toLowerCase().contains(q) ||
          (item.owner?.displayName.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<PredictiveAlert> get visibleAlerts {
    return alertsScope == AlertsScope.tenant ? tenantAlerts : vehicleAlerts;
  }

  bool get isBluetoothConnected =>
      linkState == ObdLinkState.connected ||
      linkState == ObdLinkState.streaming ||
      linkState == ObdLinkState.reconnecting;

  DiagnosticsHubUiState copyWith({
    DiagnosticsHubTab? selectedTab,
    bool? planIncludesTelemetry,
    bool? planIncludesAi,
    bool? canUseTelemetry,
    bool? canReadTelemetry,
    bool? canUseAiDiagnostics,
    bool? canReadAiReports,
    bool? canReadDevices,
    bool? canRegisterDevices,
    bool? canManageInstallations,
    bool? canReadFaults,
    bool? canResolveFaults,
    bool? canReadAlerts,
    bool? canAcknowledgeAlerts,
    bool? canCreateAppointment,
    bool? canReportFinding,
    bool? isOnline,
    int? unreadNotificationsCount,
    int? pendingSyncCount,
    UiText? error,
    bool clearError = false,
    UiText? notice,
    bool clearNotice = false,
    List<VehicleWithOwner>? workshopVehicles,
    bool? vehiclesLoading,
    Map<String, String>? vehicleWorkOrderIds,
    String? selectedVehicleId,
    bool? vehiclePickerOpen,
    String? vehicleSearchQuery,
    DeviceInstallation? activeInstallation,
    bool clearActiveInstallation = false,
    bool? isLoadingInstallation,
    bool? installForVehicleSheetOpen,
    String? installOdometerInput,
    bool? installOdometerInvalid,
    List<ObdAdapter>? pairedAdapters,
    bool? bluetoothPermissionRequired,
    bool? bluetoothDisabled,
    String? selectedAdapterAddress,
    bool clearSelectedAdapter = false,
    ObdLinkState? linkState,
    ObdConnectionInfo? connectionInfo,
    bool clearConnectionInfo = false,
    bool? isConnecting,
    List<ObdDevice>? devices,
    DeviceStatus? deviceStatusFilter,
    bool clearDeviceStatusFilter = false,
    bool? isLoadingDevices,
    Map<String, DeviceInstallationSummary>? deviceInstallations,
    RegisterObdDeviceForm? registerForm,
    bool clearRegisterForm = false,
    ObdDevice? editingStatusDevice,
    bool clearEditingStatusDevice = false,
    ObdDevice? installingDevice,
    bool clearInstallingDevice = false,
    ObdDevice? uninstallingDevice,
    bool clearUninstallingDevice = false,
    bool? isSavingDeviceAction,
    AlertsScope? alertsScope,
    List<PredictiveAlert>? tenantAlerts,
    List<PredictiveAlert>? vehicleAlerts,
    bool? isLoadingAlerts,
    PredictiveAlert? convertingAlert,
    bool clearConvertingAlert = false,
    String? convertAlertDateText,
    String? convertAlertTimeText,
    String? convertAlertDurationText,
    String? convertAlertReason,
    bool? isActingOnAlert,
  }) {
    return DiagnosticsHubUiState(
      selectedTab: selectedTab ?? this.selectedTab,
      planIncludesTelemetry: planIncludesTelemetry ?? this.planIncludesTelemetry,
      planIncludesAi: planIncludesAi ?? this.planIncludesAi,
      canUseTelemetry: canUseTelemetry ?? this.canUseTelemetry,
      canReadTelemetry: canReadTelemetry ?? this.canReadTelemetry,
      canUseAiDiagnostics: canUseAiDiagnostics ?? this.canUseAiDiagnostics,
      canReadAiReports: canReadAiReports ?? this.canReadAiReports,
      canReadDevices: canReadDevices ?? this.canReadDevices,
      canRegisterDevices: canRegisterDevices ?? this.canRegisterDevices,
      canManageInstallations: canManageInstallations ?? this.canManageInstallations,
      canReadFaults: canReadFaults ?? this.canReadFaults,
      canResolveFaults: canResolveFaults ?? this.canResolveFaults,
      canReadAlerts: canReadAlerts ?? this.canReadAlerts,
      canAcknowledgeAlerts: canAcknowledgeAlerts ?? this.canAcknowledgeAlerts,
      canCreateAppointment: canCreateAppointment ?? this.canCreateAppointment,
      canReportFinding: canReportFinding ?? this.canReportFinding,
      isOnline: isOnline ?? this.isOnline,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      error: clearError ? null : (error ?? this.error),
      notice: clearNotice ? null : (notice ?? this.notice),
      workshopVehicles: workshopVehicles ?? this.workshopVehicles,
      vehiclesLoading: vehiclesLoading ?? this.vehiclesLoading,
      vehicleWorkOrderIds: vehicleWorkOrderIds ?? this.vehicleWorkOrderIds,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      vehiclePickerOpen: vehiclePickerOpen ?? this.vehiclePickerOpen,
      vehicleSearchQuery: vehicleSearchQuery ?? this.vehicleSearchQuery,
      activeInstallation: clearActiveInstallation ? null : (activeInstallation ?? this.activeInstallation),
      isLoadingInstallation: isLoadingInstallation ?? this.isLoadingInstallation,
      installForVehicleSheetOpen: installForVehicleSheetOpen ?? this.installForVehicleSheetOpen,
      installOdometerInput: installOdometerInput ?? this.installOdometerInput,
      installOdometerInvalid: installOdometerInvalid ?? this.installOdometerInvalid,
      pairedAdapters: pairedAdapters ?? this.pairedAdapters,
      bluetoothPermissionRequired: bluetoothPermissionRequired ?? this.bluetoothPermissionRequired,
      bluetoothDisabled: bluetoothDisabled ?? this.bluetoothDisabled,
      selectedAdapterAddress: clearSelectedAdapter
          ? null
          : (selectedAdapterAddress ?? this.selectedAdapterAddress),
      linkState: linkState ?? this.linkState,
      connectionInfo: clearConnectionInfo ? null : (connectionInfo ?? this.connectionInfo),
      isConnecting: isConnecting ?? this.isConnecting,
      devices: devices ?? this.devices,
      deviceStatusFilter: clearDeviceStatusFilter ? null : (deviceStatusFilter ?? this.deviceStatusFilter),
      isLoadingDevices: isLoadingDevices ?? this.isLoadingDevices,
      deviceInstallations: deviceInstallations ?? this.deviceInstallations,
      registerForm: clearRegisterForm ? null : (registerForm ?? this.registerForm),
      editingStatusDevice: clearEditingStatusDevice ? null : (editingStatusDevice ?? this.editingStatusDevice),
      installingDevice: clearInstallingDevice ? null : (installingDevice ?? this.installingDevice),
      uninstallingDevice: clearUninstallingDevice ? null : (uninstallingDevice ?? this.uninstallingDevice),
      isSavingDeviceAction: isSavingDeviceAction ?? this.isSavingDeviceAction,
      alertsScope: alertsScope ?? this.alertsScope,
      tenantAlerts: tenantAlerts ?? this.tenantAlerts,
      vehicleAlerts: vehicleAlerts ?? this.vehicleAlerts,
      isLoadingAlerts: isLoadingAlerts ?? this.isLoadingAlerts,
      convertingAlert: clearConvertingAlert ? null : (convertingAlert ?? this.convertingAlert),
      convertAlertDateText: convertAlertDateText ?? this.convertAlertDateText,
      convertAlertTimeText: convertAlertTimeText ?? this.convertAlertTimeText,
      convertAlertDurationText: convertAlertDurationText ?? this.convertAlertDurationText,
      convertAlertReason: convertAlertReason ?? this.convertAlertReason,
      isActingOnAlert: isActingOnAlert ?? this.isActingOnAlert,
    );
  }
}
