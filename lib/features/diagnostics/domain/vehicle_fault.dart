import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';

/// Falla electrónica de un vehículo (`VehicleFaultResponse`). Mientras el `REGISTER_FAULT` está en cola
/// el id es `local-{uuid}` ([isPending]); al sincronizarse se reemplaza por el del backend (06 §6).
class VehicleFault {
  static const localPrefix = 'local-';

  final String id;
  final String vehicleId;
  final Dtc? dtc;
  final String dtcCode;
  final FaultSeverity? severity;
  final String description;
  final DateTime? detectedAt;
  final bool isResolved;
  final DateTime? resolvedAt;

  const VehicleFault({
    required this.id,
    required this.vehicleId,
    this.dtc,
    required this.dtcCode,
    this.severity,
    required this.description,
    this.detectedAt,
    required this.isResolved,
    this.resolvedAt,
  });

  bool get isPending => isLocalId(id);

  static bool isLocalId(String id) => id.startsWith(localPrefix);

  VehicleFault resolvedOn(DateTime when) {
    return VehicleFault(
      id: id,
      vehicleId: vehicleId,
      dtc: dtc,
      dtcCode: dtcCode,
      severity: severity,
      description: description,
      detectedAt: detectedAt,
      isResolved: true,
      resolvedAt: when,
    );
  }
}

/// Resultado del escaneo de US17: vacío = sin códigos (E2).
class FaultScanResult {
  final List<VehicleFault> faults;
  final FreezeFrame? freezeFrame;

  const FaultScanResult({required this.faults, this.freezeFrame});

  bool get isClean => faults.isEmpty;
}

/// Resultado del borrado de US20: [cleared] ya no aparecen tras la re-lectura (E1); [persistent]
/// reaparecen y requieren revisar el circuito (E2).
class ClearFaultsResult {
  final List<VehicleFault> cleared;
  final List<VehicleFault> persistent;

  const ClearFaultsResult({required this.cleared, required this.persistent});

  bool get isClean => persistent.isEmpty;
}
