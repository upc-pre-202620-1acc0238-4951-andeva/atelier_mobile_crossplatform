import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';

/// Diagnóstico OBD-II (US16–US20). Instalación del escáner: en línea. Lecturas y fallas: se capturan sin
/// red y salen por la cola (`TELEMETRY_BATCH`, `REGISTER_FAULT`, `RESOLVE_FAULT`, 06 §3). Las fallas
/// activas y las alertas predictivas se leen offline-first.
abstract class DiagnosticsRepository {
  Future<List<ObdDevice>> getDevices({DeviceStatus? status});

  /// `null`: el vehículo no tiene escáner instalado (404).
  Future<DeviceInstallation?> getActiveInstallation(String vehicleId);

  Future<DeviceInstallation> installDevice({
    required String deviceId,
    required String vehicleId,
    int? currentOdometerKm,
  });

  Future<DeviceInstallation> uninstallDevice(
    String installationId, {
    int? finalOdometerKm,
  });

  /// Guarda la muestra si se puede enviar ([TelemetrySample.canBeSent]); devuelve si se guardó.
  Future<bool> saveReading(
    String vehicleId,
    TelemetrySample sample, {
    double? latitude,
    double? longitude,
  });

  /// Arma `TELEMETRY_BATCH` de hasta 200 lecturas sin lote. Con [onlyFull] solo los lotes completos
  /// (durante el muestreo); sin él, también el resto (al iniciar y al cerrar). Devuelve cuántos encoló.
  Future<int> enqueueUnbatchedReadings({required bool onlyFull});

  /// Borra las lecturas ya confirmadas con más de 7 días (06 §6).
  Future<void> purgeConfirmedReadings();

  Stream<DiagnosticsSyncState> watchSyncState(String vehicleId);

  /// `GET /iot/faults/vehicle/{id}/active` → caché; conserva las fallas aún en cola.
  Future<void> refreshActiveFaults(String vehicleId);

  Stream<List<VehicleFault>> watchActiveFaults(String vehicleId);

  /// Registra los códigos leídos (US17 E1, US20 E2): los ya activos se devuelven tal cual; los nuevos
  /// quedan como `local-{uuid}` con su `REGISTER_FAULT` en cola.
  Future<List<VehicleFault>> registerDetectedFaults(
    String vehicleId,
    List<Dtc> dtcs,
    String sessionId,
  );

  /// Tras el modo 04 y la re-lectura (US20): las fallas activas que ya no aparecen se resuelven; las que
  /// siguen en [remaining] quedan como persistentes.
  Future<ClearFaultsResult> applyClearedFaults(
    String vehicleId,
    List<Dtc> remaining,
    String sessionId,
  );

  Future<void> refreshPredictiveAlerts(String vehicleId);

  Stream<List<PredictiveAlert>> watchPredictiveAlerts(String vehicleId);

  Future<PredictiveAlert> acknowledgePredictiveAlert(String id);
}
