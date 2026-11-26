import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Telemetría en vivo de un vehículo (US18).
class LiveTelemetryUiState {
  final String vehicleId;
  final String? plate;
  final Vehicle? vehicle;

  /// `iot:telemetry:ingest` y el plan: conectar y muestrear.
  final bool canUseTelemetry;

  /// `iot:telemetry:read` y el plan: ver la última lectura del servidor y su historial.
  final bool canReadTelemetry;
  final bool canReadFaults;

  /// El plan incluye el módulo de telemetría; si no, solo se dice qué plan lo incluye.
  final bool planIncludesTelemetry;
  final bool isOnline;
  final ObdLinkState linkState;
  final TelemetrySample? liveSample;
  final Set<TelemetryWarning> liveWarnings;
  final TelemetrySample? remoteTelemetry;
  final List<TelemetryHistoryBucket> telemetryHistory;
  final bool isLoadingRemote;
  final TelemetrySnapshot? frozenSnapshot;
  final DiagnosticsSyncState syncState;

  /// La sesión del escáner está sobre otro vehículo: sus cifras no se muestran aquí.
  final bool connectedToOtherVehicle;
  final bool isReconnecting;

  /// Arranque o parada del muestreo en curso.
  final bool isBusy;
  final UiText? error;

  const LiveTelemetryUiState({
    required this.vehicleId,
    this.plate,
    this.vehicle,
    this.canUseTelemetry = false,
    this.canReadTelemetry = false,
    this.canReadFaults = false,
    this.planIncludesTelemetry = true,
    this.isOnline = true,
    this.linkState = ObdLinkState.disconnected,
    this.liveSample,
    this.liveWarnings = const {},
    this.remoteTelemetry,
    this.telemetryHistory = const [],
    this.isLoadingRemote = false,
    this.frozenSnapshot,
    this.syncState = const DiagnosticsSyncState(pendingReadings: 0, pendingFaults: 0),
    this.connectedToOtherVehicle = false,
    this.isReconnecting = false,
    this.isBusy = false,
    this.error,
  });

  bool get isBluetoothSessionActive =>
      linkState == ObdLinkState.connected ||
      linkState == ObdLinkState.streaming ||
      linkState == ObdLinkState.reconnecting ||
      linkState == ObdLinkState.lost;

  bool get isStreaming => linkState == ObdLinkState.streaming || linkState == ObdLinkState.reconnecting;

  /// Sin sesión del escáner, quien puede leer ve lo último que llegó al servidor.
  bool get isRemoteMode => !isBluetoothSessionActive && canReadTelemetry;

  /// H23: sin temperatura del refrigerante la lectura se muestra pero no se guarda ni se envía.
  bool get missingCoolantPid0105 => isBluetoothSessionActive && liveSample != null && !liveSample!.canBeSent;

  String get displayPlate => vehicle?.plate ?? plate ?? '';

  LiveTelemetryUiState copyWith({
    String? plate,
    Vehicle? vehicle,
    bool? canUseTelemetry,
    bool? canReadTelemetry,
    bool? canReadFaults,
    bool? planIncludesTelemetry,
    bool? isOnline,
    ObdLinkState? linkState,
    TelemetrySample? liveSample,
    bool clearLiveSample = false,
    Set<TelemetryWarning>? liveWarnings,
    TelemetrySample? remoteTelemetry,
    List<TelemetryHistoryBucket>? telemetryHistory,
    bool? isLoadingRemote,
    TelemetrySnapshot? frozenSnapshot,
    bool clearFrozenSnapshot = false,
    DiagnosticsSyncState? syncState,
    bool? connectedToOtherVehicle,
    bool? isReconnecting,
    bool? isBusy,
    UiText? error,
    bool clearError = false,
  }) {
    return LiveTelemetryUiState(
      vehicleId: vehicleId,
      plate: plate ?? this.plate,
      vehicle: vehicle ?? this.vehicle,
      canUseTelemetry: canUseTelemetry ?? this.canUseTelemetry,
      canReadTelemetry: canReadTelemetry ?? this.canReadTelemetry,
      canReadFaults: canReadFaults ?? this.canReadFaults,
      planIncludesTelemetry: planIncludesTelemetry ?? this.planIncludesTelemetry,
      isOnline: isOnline ?? this.isOnline,
      linkState: linkState ?? this.linkState,
      liveSample: clearLiveSample ? null : liveSample ?? this.liveSample,
      liveWarnings: liveWarnings ?? this.liveWarnings,
      remoteTelemetry: remoteTelemetry ?? this.remoteTelemetry,
      telemetryHistory: telemetryHistory ?? this.telemetryHistory,
      isLoadingRemote: isLoadingRemote ?? this.isLoadingRemote,
      frozenSnapshot: clearFrozenSnapshot ? null : frozenSnapshot ?? this.frozenSnapshot,
      syncState: syncState ?? this.syncState,
      connectedToOtherVehicle: connectedToOtherVehicle ?? this.connectedToOtherVehicle,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : error ?? this.error,
    );
  }
}
