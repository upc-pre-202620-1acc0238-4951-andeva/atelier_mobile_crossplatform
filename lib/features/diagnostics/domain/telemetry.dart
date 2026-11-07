import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';

/// Una muestra en vivo del modo 01 (US18). Solo se guarda y se envía si trae [engineTempCelsius], porque
/// es obligatorio en `TelemetryReadingItemDto` (H23). [intakePressureKpa] solo se muestra: el lote no
/// tiene ese campo.
class TelemetrySample {
  final DateTime timestamp;
  final double? engineTempCelsius;
  final int? engineRpm;
  final int? speedKmh;
  final double? batteryVoltage;
  final double? fuelPercentage;
  final int? intakePressureKpa;

  const TelemetrySample({
    required this.timestamp,
    this.engineTempCelsius,
    this.engineRpm,
    this.speedKmh,
    this.batteryVoltage,
    this.fuelPercentage,
    this.intakePressureKpa,
  });

  bool get canBeSent => engineTempCelsius != null;
}

/// Lectura que rebasa un umbral de `TelemetryThresholds` (US18 E1).
enum TelemetryWarning { coolantOverheat, lowVoltage, highVoltage, highRpm }

/// Estado de la sesión en vivo: enlace, vehículo, última muestra y sus avisos.
class LiveTelemetry {
  final ObdLinkState state;
  final String? vehicleId;
  final TelemetrySample? sample;
  final Set<TelemetryWarning> warnings;

  const LiveTelemetry({
    this.state = ObdLinkState.disconnected,
    this.vehicleId,
    this.sample,
    this.warnings = const {},
  });

  LiveTelemetry copyWith({
    ObdLinkState? state,
    TelemetrySample? sample,
    Set<TelemetryWarning>? warnings,
  }) {
    return LiveTelemetry(
      state: state ?? this.state,
      vehicleId: vehicleId,
      sample: sample ?? this.sample,
      warnings: warnings ?? this.warnings,
    );
  }
}

/// Muestra congelada (US18 E2). Ya está en `telemetry_readings` y viaja en el lote; no hay endpoint para
/// adjuntarla a la orden (H19).
class TelemetrySnapshot {
  final String vehicleId;
  final TelemetrySample sample;
  final Set<TelemetryWarning> warnings;

  const TelemetrySnapshot({
    required this.vehicleId,
    required this.sample,
    required this.warnings,
  });
}

/// Lo capturado que aún no llega al backend (US19 E1).
class DiagnosticsSyncState {
  final int pendingReadings;
  final int pendingFaults;

  const DiagnosticsSyncState({
    required this.pendingReadings,
    required this.pendingFaults,
  });

  bool get isSynced => pendingReadings == 0 && pendingFaults == 0;
}
