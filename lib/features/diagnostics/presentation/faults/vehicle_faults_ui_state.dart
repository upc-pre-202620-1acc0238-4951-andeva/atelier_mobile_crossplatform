import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Estado único de la pantalla de fallas DTC de un vehículo.
class VehicleFaultsUiState {
  final String vehicleId;
  final String? plate;
  final Vehicle? vehicle;
  final List<VehicleFault> faults;
  final FreezeFrame? freezeFrame;
  final ClearFaultsResult? lastClearResult;
  final DiagnosticsSyncState syncState;
  final ObdLinkState linkState;
  final bool canReadFaults;
  final bool canScanFaults;
  final bool canResolveFaults;
  final bool planIncludesTelemetry;
  final bool isOnline;
  final bool isRefreshing;
  final bool isLoaded;
  final bool isScanning;
  final bool isClearing;
  final bool confirmClearOpen;
  final UiText? error;
  final UiText? notice;

  const VehicleFaultsUiState({
    this.vehicleId = '',
    this.plate,
    this.vehicle,
    this.faults = const [],
    this.freezeFrame,
    this.lastClearResult,
    this.syncState = const DiagnosticsSyncState(pendingReadings: 0, pendingFaults: 0),
    this.linkState = ObdLinkState.disconnected,
    this.canReadFaults = false,
    this.canScanFaults = false,
    this.canResolveFaults = false,
    this.planIncludesTelemetry = true,
    this.isOnline = true,
    this.isRefreshing = false,
    this.isLoaded = false,
    this.isScanning = false,
    this.isClearing = false,
    this.confirmClearOpen = false,
    this.error,
    this.notice,
  });

  String get displayPlate => vehicle?.plate ?? plate ?? '';

  bool get isBluetoothConnected =>
      linkState == ObdLinkState.connected ||
      linkState == ObdLinkState.streaming ||
      linkState == ObdLinkState.reconnecting;

  VehicleFaultsUiState copyWith({
    Vehicle? vehicle,
    List<VehicleFault>? faults,
    FreezeFrame? freezeFrame,
    bool clearFreezeFrame = false,
    ClearFaultsResult? lastClearResult,
    bool clearLastClearResult = false,
    DiagnosticsSyncState? syncState,
    ObdLinkState? linkState,
    bool? canReadFaults,
    bool? canScanFaults,
    bool? canResolveFaults,
    bool? planIncludesTelemetry,
    bool? isOnline,
    bool? isRefreshing,
    bool? isLoaded,
    bool? isScanning,
    bool? isClearing,
    bool? confirmClearOpen,
    UiText? error,
    bool clearError = false,
    UiText? notice,
    bool clearNotice = false,
  }) {
    return VehicleFaultsUiState(
      vehicleId: vehicleId,
      plate: plate,
      vehicle: vehicle ?? this.vehicle,
      faults: faults ?? this.faults,
      freezeFrame: clearFreezeFrame ? null : (freezeFrame ?? this.freezeFrame),
      lastClearResult: clearLastClearResult ? null : (lastClearResult ?? this.lastClearResult),
      syncState: syncState ?? this.syncState,
      linkState: linkState ?? this.linkState,
      canReadFaults: canReadFaults ?? this.canReadFaults,
      canScanFaults: canScanFaults ?? this.canScanFaults,
      canResolveFaults: canResolveFaults ?? this.canResolveFaults,
      planIncludesTelemetry: planIncludesTelemetry ?? this.planIncludesTelemetry,
      isOnline: isOnline ?? this.isOnline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoaded: isLoaded ?? this.isLoaded,
      isScanning: isScanning ?? this.isScanning,
      isClearing: isClearing ?? this.isClearing,
      confirmClearOpen: confirmClearOpen ?? this.confirmClearOpen,
      error: clearError ? null : (error ?? this.error),
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}
