import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry_thresholds.dart';

/// Telemetría en vivo de un vehículo (US18).
class LiveTelemetryUiState {
  final String vehicleId;
  final String? plate;

  /// `iot:telemetry:ingest` y el plan: conectar y muestrear.
  final bool canIngest;

  /// `iot:telemetry:read` y el plan: ver la última lectura del servidor.
  final bool canReadRemote;
  final LiveTelemetry live;
  final TelemetrySnapshot? frozen;
  final TelemetrySample? remoteSample;
  final bool isLoadingRemote;

  /// El servidor ya respondió (con o sin lectura).
  final bool remoteLoaded;
  final DiagnosticsSyncState? sync;
  final bool isOnline;
  final bool isBusy;
  final UiText? error;

  const LiveTelemetryUiState({
    required this.vehicleId,
    this.plate,
    this.canIngest = false,
    this.canReadRemote = false,
    this.live = const LiveTelemetry(),
    this.frozen,
    this.remoteSample,
    this.isLoadingRemote = false,
    this.remoteLoaded = false,
    this.sync,
    this.isOnline = true,
    this.isBusy = false,
    this.error,
  });

  bool get hasAnyPermission => canIngest || canReadRemote;

  /// La sesión muestrea otro vehículo: sus cifras no se muestran aquí.
  bool get isOtherVehicle => live.vehicleId != null && live.vehicleId != vehicleId;

  bool get isStreamingHere =>
      live.vehicleId == vehicleId &&
      (live.state == ObdLinkState.streaming || live.state == ObdLinkState.reconnecting);

  bool get canStart => canIngest && !isBusy && !isOtherVehicle && live.state == ObdLinkState.connected;

  /// Sin enlace: el adaptador se elige en el escáner.
  bool get needsConnection =>
      canIngest && (live.state == ObdLinkState.disconnected || live.state == ObdLinkState.lost);

  TelemetrySample? get liveSample => isOtherVehicle ? null : live.sample;

  bool get canFreeze => canIngest && !isBusy && liveSample != null;

  /// Sin sesión OBD con datos, quien puede leer ve lo último que llegó al servidor.
  bool get showRemote => canReadRemote && !isStreamingHere && liveSample == null;

  TelemetrySample? get displayedSample => showRemote ? remoteSample : liveSample;

  Set<TelemetryWarning> get displayedWarnings {
    if (!showRemote) return isOtherVehicle ? const {} : live.warnings;
    final sample = remoteSample;
    return sample == null ? const {} : TelemetryThresholds.warningsFor(sample);
  }

  LiveTelemetryUiState copyWith({
    String? plate,
    bool? canIngest,
    bool? canReadRemote,
    LiveTelemetry? live,
    TelemetrySnapshot? frozen,
    bool clearFrozen = false,
    TelemetrySample? remoteSample,
    bool clearRemoteSample = false,
    bool? isLoadingRemote,
    bool? remoteLoaded,
    DiagnosticsSyncState? sync,
    bool? isOnline,
    bool? isBusy,
    UiText? error,
    bool clearError = false,
  }) {
    return LiveTelemetryUiState(
      vehicleId: vehicleId,
      plate: plate ?? this.plate,
      canIngest: canIngest ?? this.canIngest,
      canReadRemote: canReadRemote ?? this.canReadRemote,
      live: live ?? this.live,
      frozen: clearFrozen ? null : frozen ?? this.frozen,
      remoteSample: clearRemoteSample ? null : remoteSample ?? this.remoteSample,
      isLoadingRemote: isLoadingRemote ?? this.isLoadingRemote,
      remoteLoaded: remoteLoaded ?? this.remoteLoaded,
      sync: sync ?? this.sync,
      isOnline: isOnline ?? this.isOnline,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : error ?? this.error,
    );
  }
}
