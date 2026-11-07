import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_dtos.dart';

/// Instantes del backend en ISO-8601 UTC (docs/api/README.md §6); Drift los guarda como epoch ms.
DateTime? _instant(String? raw) => DateTime.tryParse(raw ?? '')?.toUtc();

DateTime _fromMillis(int millis) {
  return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}

extension VehicleFaultDtoMapper on VehicleFaultDto {
  VehicleFaultEntity toEntity(String fallbackVehicleId, int syncedAt) {
    return VehicleFaultEntity(
      id: id,
      vehicleId: vehicleId ?? fallbackVehicleId,
      dtcCode: dtcCode ?? '',
      severity: severity ?? '',
      description: description ?? '',
      detectedAt: _instant(detectedAt)?.millisecondsSinceEpoch ?? syncedAt,
      isResolved: isResolved == true,
      resolvedAt: _instant(resolvedAt)?.millisecondsSinceEpoch,
      syncedAt: syncedAt,
    );
  }
}

extension VehicleFaultEntityMapper on VehicleFaultEntity {
  VehicleFault toDomain() {
    final resolved = resolvedAt;
    return VehicleFault(
      id: id,
      vehicleId: vehicleId,
      dtc: Dtc.of(dtcCode),
      dtcCode: dtcCode,
      severity: FaultSeverity.fromString(severity),
      description: description,
      detectedAt: _fromMillis(detectedAt),
      isResolved: isResolved,
      resolvedAt: resolved == null ? null : _fromMillis(resolved),
    );
  }
}

extension TelemetryReadingEntityMapper on TelemetryReadingEntity {
  TelemetryReadingItemDto toItemDto() {
    return TelemetryReadingItemDto(
      timestamp: _fromMillis(timestamp).toIso8601String(),
      engineTempCelsius: engineTempCelsius,
      engineRpm: engineRpm,
      speedKmh: speedKmh,
      batteryVoltage: batteryVoltage,
      fuelPercentage: fuelPercentage,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

extension PredictiveAlertDtoMapper on PredictiveAlertDto {
  PredictiveAlertEntity toEntity(String fallbackVehicleId, int syncedAt) {
    return PredictiveAlertEntity(
      id: id,
      vehicleId: vehicleId ?? fallbackVehicleId,
      alertType: alertType ?? '',
      confidenceScore: confidenceScore ?? 0,
      message: message ?? '',
      status: status ?? '',
      createdAt: _instant(createdAt)?.millisecondsSinceEpoch ?? syncedAt,
      syncedAt: syncedAt,
    );
  }

  PredictiveAlert toDomain(String fallbackVehicleId) {
    return PredictiveAlert(
      id: id,
      vehicleId: vehicleId ?? fallbackVehicleId,
      alertType: PredictiveAlertType.fromString(alertType),
      confidenceScore: confidenceScore ?? 0,
      message: message ?? '',
      status: PredictiveAlertStatus.fromString(status),
      recommendedServiceId: recommendedServiceId,
      createdAt: _instant(createdAt),
    );
  }
}

extension PredictiveAlertEntityMapper on PredictiveAlertEntity {
  PredictiveAlert toDomain() {
    return PredictiveAlert(
      id: id,
      vehicleId: vehicleId,
      alertType: PredictiveAlertType.fromString(alertType),
      confidenceScore: confidenceScore,
      message: message,
      status: PredictiveAlertStatus.fromString(status),
      createdAt: _fromMillis(createdAt),
    );
  }
}

extension ObdDeviceDtoMapper on ObdDeviceDto {
  ObdDevice toDomain() {
    return ObdDevice(
      id: id,
      deviceIdentifier: deviceIdentifier ?? '',
      connectionType: connectionType,
      status: DeviceStatus.fromString(status),
      hardwareModel: hardwareModel,
      firmwareVersion: firmwareVersion,
    );
  }
}

extension DeviceInstallationDtoMapper on DeviceInstallationDto {
  DeviceInstallation toDomain() {
    return DeviceInstallation(
      id: id,
      deviceId: deviceId ?? '',
      vehicleId: vehicleId ?? '',
      installedAt: _instant(installedAt),
      uninstalledAt: _instant(uninstalledAt),
      initialOdometerKm: initialOdometerKm,
      finalOdometerKm: finalOdometerKm,
      isActive: isActive == true,
    );
  }
}

extension HealthReportCreatedDtoMapper on HealthReportCreatedDto {
  HealthReport toDomain(String fallbackVehicleId) {
    return HealthReport(
      reportId: reportId,
      vehicleId: vehicleId ?? fallbackVehicleId,
      overallHealthScore: overallHealthScore,
      executiveSummary: executiveSummary,
      totalRisksDetected: totalRisksDetected,
      generatedAt: _instant(generatedAt),
    );
  }
}

extension HealthReportDetailDtoMapper on HealthReportDetailDto {
  HealthReportDetail toDomain() {
    final ai = diagnosis;
    return HealthReportDetail(
      reportId: reportId,
      vehicleId: vehicleId ?? '',
      daysAnalyzed: daysAnalyzed,
      generatedAt: _instant(generatedAt),
      diagnosis: ai == null
          ? null
          : HealthDiagnosis(
              healthScore: ai.healthScore,
              overallCondition: ai.overallCondition,
              executiveSummary: ai.executiveSummary,
              subsystemEvaluations: [
                for (final e in ai.subsystemEvaluations ?? const <SubsystemEvaluationDto>[])
                  SubsystemEvaluation(
                    subsystemName: e.subsystemName,
                    status: e.status,
                    score: e.score,
                    findings: e.findings,
                  ),
              ],
              predictiveRisks: [
                for (final r in ai.predictiveRisks ?? const <PredictiveRiskDto>[])
                  PredictiveRisk(
                    category: r.category,
                    probability: r.probability,
                    timeHorizonDays: r.timeHorizonDays,
                    consequences: r.consequences,
                  ),
              ],
              recommendedActions: [
                for (final a in ai.recommendedActions ?? const <RecommendedServiceActionDto>[])
                  RecommendedServiceAction(
                    serviceCode: a.serviceCode,
                    serviceName: a.serviceName,
                    urgency: a.urgency,
                    estimatedCost: a.estimatedCost,
                    rationale: a.rationale,
                  ),
              ],
              dtcCorrelations: [
                for (final c in ai.dtcCorrelations ?? const <DtcTelemetryCorrelationDto>[])
                  DtcCorrelation(
                    dtcCode: c.dtcCode,
                    correlatedSensorReading: c.correlatedSensorReading,
                    anomalyExplanation: c.anomalyExplanation,
                  ),
              ],
            ),
    );
  }
}
