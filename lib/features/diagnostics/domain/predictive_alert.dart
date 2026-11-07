enum PredictiveAlertType {
  engineOverheatingRisk('ENGINE_OVERHEATING_RISK'),
  batteryFailureRisk('BATTERY_FAILURE_RISK'),
  catalyticSystemDegradation('CATALYTIC_SYSTEM_DEGRADATION'),
  cylinderMisfireHazard('CYLINDER_MISFIRE_HAZARD'),
  brakeWear('BRAKE_WEAR'),
  oilLifeDepletion('OIL_LIFE_DEPLETION'),
  emissionsFailure('EMISSIONS_FAILURE');

  final String value;

  const PredictiveAlertType(this.value);

  static PredictiveAlertType? fromString(String? value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

enum PredictiveAlertStatus {
  dispatched('DISPATCHED'),
  acknowledged('ACKNOWLEDGED'),
  resolved('RESOLVED'),
  dismissed('DISMISSED');

  final String value;

  const PredictiveAlertStatus(this.value);

  static PredictiveAlertStatus? fromString(String? value) {
    for (final status in values) {
      if (status.value == value) return status;
    }
    return null;
  }
}

/// Alerta predictiva de un vehículo (`PredictiveAlertResponse`). No hay push de alertas al staff: se
/// recarga al abrir (06 §1). `recommendedServiceId` no se guarda en la caché: desde Drift llega `null`.
class PredictiveAlert {
  final String id;
  final String vehicleId;
  final PredictiveAlertType? alertType;
  final double confidenceScore;
  final String message;
  final PredictiveAlertStatus? status;
  final String? recommendedServiceId;
  final DateTime? createdAt;

  const PredictiveAlert({
    required this.id,
    required this.vehicleId,
    this.alertType,
    required this.confidenceScore,
    required this.message,
    this.status,
    this.recommendedServiceId,
    this.createdAt,
  });
}
