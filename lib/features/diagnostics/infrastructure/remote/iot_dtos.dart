import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

int? _int(Object? value) => (value as num?)?.toInt();

double? _double(Object? value) => (value as num?)?.toDouble();

/// `Obd2DeviceResponse`.
class ObdDeviceDto {
  final String id;
  final String? deviceIdentifier;
  final String? connectionType;
  final String? status;
  final String? hardwareModel;
  final String? firmwareVersion;

  const ObdDeviceDto({
    required this.id,
    this.deviceIdentifier,
    this.connectionType,
    this.status,
    this.hardwareModel,
    this.firmwareVersion,
  });

  factory ObdDeviceDto.fromJson(Map<String, dynamic> json) {
    return ObdDeviceDto(
      id: json['id'] as String,
      deviceIdentifier: json['deviceIdentifier'] as String?,
      connectionType: json['connectionType'] as String?,
      status: json['status'] as String?,
      hardwareModel: json['hardwareModel'] as String?,
      firmwareVersion: json['firmwareVersion'] as String?,
    );
  }
}

/// `DeviceInstallationResponse`.
class DeviceInstallationDto {
  final String id;
  final String? deviceId;
  final String? vehicleId;
  final String? installedAt;
  final String? uninstalledAt;
  final int? initialOdometerKm;
  final int? finalOdometerKm;
  final bool? isActive;

  const DeviceInstallationDto({
    required this.id,
    this.deviceId,
    this.vehicleId,
    this.installedAt,
    this.uninstalledAt,
    this.initialOdometerKm,
    this.finalOdometerKm,
    this.isActive,
  });

  factory DeviceInstallationDto.fromJson(Map<String, dynamic> json) {
    return DeviceInstallationDto(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      installedAt: json['installedAt'] as String?,
      uninstalledAt: json['uninstalledAt'] as String?,
      initialOdometerKm: _int(json['initialOdometerKm']),
      finalOdometerKm: _int(json['finalOdometerKm']),
      isActive: json['isActive'] as bool?,
    );
  }
}

/// `RegisterVehicleFaultRequest`: payload de `REGISTER_FAULT`.
class RegisterFaultRequestDto {
  final String vehicleId;
  final String dtcCode;
  final String severity;
  final String? description;

  const RegisterFaultRequestDto({
    required this.vehicleId,
    required this.dtcCode,
    required this.severity,
    this.description,
  });

  factory RegisterFaultRequestDto.fromJson(Map<String, dynamic> json) {
    return RegisterFaultRequestDto(
      vehicleId: json['vehicleId'] as String,
      dtcCode: json['dtcCode'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'dtcCode': dtcCode,
      'severity': severity,
      'description': ?description,
    };
  }
}

/// `VehicleFaultResponse`.
class VehicleFaultDto {
  final String id;
  final String? vehicleId;
  final String? dtcCode;
  final String? severity;
  final String? description;
  final String? detectedAt;
  final bool? isResolved;
  final String? resolvedAt;

  const VehicleFaultDto({
    required this.id,
    this.vehicleId,
    this.dtcCode,
    this.severity,
    this.description,
    this.detectedAt,
    this.isResolved,
    this.resolvedAt,
  });

  factory VehicleFaultDto.fromJson(Map<String, dynamic> json) {
    return VehicleFaultDto(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String?,
      dtcCode: json['dtcCode'] as String?,
      severity: json['severity'] as String?,
      description: json['description'] as String?,
      detectedAt: json['detectedAt'] as String?,
      isResolved: json['isResolved'] as bool?,
      resolvedAt: json['resolvedAt'] as String?,
    );
  }
}

/// Payload de `RESOLVE_FAULT`: [faultId] puede ser `local-{uuid}` si se borró mientras su registro se
/// enviaba.
class ResolveFaultPayload {
  final String faultId;
  final String vehicleId;
  final String dtcCode;

  const ResolveFaultPayload({
    required this.faultId,
    required this.vehicleId,
    required this.dtcCode,
  });

  factory ResolveFaultPayload.fromJson(Map<String, dynamic> json) {
    return ResolveFaultPayload(
      faultId: json['faultId'] as String,
      vehicleId: json['vehicleId'] as String,
      dtcCode: json['dtcCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'faultId': faultId, 'vehicleId': vehicleId, 'dtcCode': dtcCode};
  }
}

/// `TelemetryBatchRequest`: payload de `TELEMETRY_BATCH` (hasta 200 lecturas). El handler envía el payload
/// tal cual, así que solo hace falta armarlo.
class TelemetryBatchRequestDto {
  final String vehicleId;
  final List<TelemetryReadingItemDto> readings;

  const TelemetryBatchRequestDto({
    required this.vehicleId,
    required this.readings,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'readings': [for (final reading in readings) reading.toJson()],
    };
  }
}

/// `TelemetryReadingItemDto`: `timestamp` y `engineTempCelsius` son obligatorios; lo que falta no se envía.
class TelemetryReadingItemDto {
  final String timestamp;
  final double engineTempCelsius;
  final int? engineRpm;
  final int? speedKmh;
  final double? batteryVoltage;
  final double? fuelPercentage;
  final double? latitude;
  final double? longitude;

  const TelemetryReadingItemDto({
    required this.timestamp,
    required this.engineTempCelsius,
    this.engineRpm,
    this.speedKmh,
    this.batteryVoltage,
    this.fuelPercentage,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'engineTempCelsius': engineTempCelsius,
      'engineRpm': ?engineRpm,
      'speedKmh': ?speedKmh,
      'batteryVoltage': ?batteryVoltage,
      'fuelPercentage': ?fuelPercentage,
      'latitude': ?latitude,
      'longitude': ?longitude,
    };
  }
}

/// `HealthReportCreatedResponse`.
class HealthReportCreatedDto {
  final String reportId;
  final String? vehicleId;
  final int? overallHealthScore;
  final String? executiveSummary;
  final int? totalRisksDetected;
  final String? generatedAt;

  const HealthReportCreatedDto({
    required this.reportId,
    this.vehicleId,
    this.overallHealthScore,
    this.executiveSummary,
    this.totalRisksDetected,
    this.generatedAt,
  });

  factory HealthReportCreatedDto.fromJson(Map<String, dynamic> json) {
    return HealthReportCreatedDto(
      reportId: json['reportId'] as String,
      vehicleId: json['vehicleId'] as String?,
      overallHealthScore: _int(json['overallHealthScore']),
      executiveSummary: json['executiveSummary'] as String?,
      totalRisksDetected: _int(json['totalRisksDetected']),
      generatedAt: json['generatedAt'] as String?,
    );
  }
}

/// `HealthReportDetailResponse`.
class HealthReportDetailDto {
  final String reportId;
  final String? vehicleId;
  final int? daysAnalyzed;
  final String? generatedAt;
  final VehicleHealthReportAiDto? diagnosis;

  const HealthReportDetailDto({
    required this.reportId,
    this.vehicleId,
    this.daysAnalyzed,
    this.generatedAt,
    this.diagnosis,
  });

  factory HealthReportDetailDto.fromJson(Map<String, dynamic> json) {
    final diagnosis = json['diagnosis'] as Map<String, dynamic>?;
    return HealthReportDetailDto(
      reportId: json['reportId'] as String,
      vehicleId: json['vehicleId'] as String?,
      daysAnalyzed: _int(json['daysAnalyzed']),
      generatedAt: json['generatedAt'] as String?,
      diagnosis: diagnosis == null
          ? null
          : VehicleHealthReportAiDto.fromJson(diagnosis),
    );
  }
}

/// `VehicleHealthReportAiDto`.
class VehicleHealthReportAiDto {
  final int? healthScore;
  final String? overallCondition;
  final String? executiveSummary;
  final List<SubsystemEvaluationDto>? subsystemEvaluations;
  final List<PredictiveRiskDto>? predictiveRisks;
  final List<RecommendedServiceActionDto>? recommendedActions;
  final List<DtcTelemetryCorrelationDto>? dtcCorrelations;

  const VehicleHealthReportAiDto({
    this.healthScore,
    this.overallCondition,
    this.executiveSummary,
    this.subsystemEvaluations,
    this.predictiveRisks,
    this.recommendedActions,
    this.dtcCorrelations,
  });

  factory VehicleHealthReportAiDto.fromJson(Map<String, dynamic> json) {
    List<T>? list<T>(String key, T Function(Map<String, dynamic>) parse) {
      return (json[key] as List?)
          ?.map((e) => parse(e as Map<String, dynamic>))
          .toList();
    }

    return VehicleHealthReportAiDto(
      healthScore: _int(json['healthScore']),
      overallCondition: json['overallCondition'] as String?,
      executiveSummary: json['executiveSummary'] as String?,
      subsystemEvaluations: list(
        'subsystemEvaluations',
        SubsystemEvaluationDto.fromJson,
      ),
      predictiveRisks: list('predictiveRisks', PredictiveRiskDto.fromJson),
      recommendedActions: list(
        'recommendedActions',
        RecommendedServiceActionDto.fromJson,
      ),
      dtcCorrelations: list(
        'dtcCorrelations',
        DtcTelemetryCorrelationDto.fromJson,
      ),
    );
  }
}

class SubsystemEvaluationDto {
  final String? subsystemName;
  final String? status;
  final int? score;
  final String? findings;

  const SubsystemEvaluationDto({
    this.subsystemName,
    this.status,
    this.score,
    this.findings,
  });

  factory SubsystemEvaluationDto.fromJson(Map<String, dynamic> json) {
    return SubsystemEvaluationDto(
      subsystemName: json['subsystemName'] as String?,
      status: json['status'] as String?,
      score: _int(json['score']),
      findings: json['findings'] as String?,
    );
  }
}

class PredictiveRiskDto {
  final String? category;
  final double? probability;
  final int? timeHorizonDays;
  final String? consequences;

  const PredictiveRiskDto({
    this.category,
    this.probability,
    this.timeHorizonDays,
    this.consequences,
  });

  factory PredictiveRiskDto.fromJson(Map<String, dynamic> json) {
    return PredictiveRiskDto(
      category: json['category'] as String?,
      probability: _double(json['probability']),
      timeHorizonDays: _int(json['timeHorizonDays']),
      consequences: json['consequences'] as String?,
    );
  }
}

class RecommendedServiceActionDto {
  final String? serviceCode;
  final String? serviceName;
  final String? urgency;
  final Decimal? estimatedCost;
  final String? rationale;

  const RecommendedServiceActionDto({
    this.serviceCode,
    this.serviceName,
    this.urgency,
    this.estimatedCost,
    this.rationale,
  });

  factory RecommendedServiceActionDto.fromJson(Map<String, dynamic> json) {
    return RecommendedServiceActionDto(
      serviceCode: json['serviceCode'] as String?,
      serviceName: json['serviceName'] as String?,
      urgency: json['urgency'] as String?,
      estimatedCost: decimalFromJson(json['estimatedCost']),
      rationale: json['rationale'] as String?,
    );
  }
}

class DtcTelemetryCorrelationDto {
  final String? dtcCode;
  final String? correlatedSensorReading;
  final String? anomalyExplanation;

  const DtcTelemetryCorrelationDto({
    this.dtcCode,
    this.correlatedSensorReading,
    this.anomalyExplanation,
  });

  factory DtcTelemetryCorrelationDto.fromJson(Map<String, dynamic> json) {
    return DtcTelemetryCorrelationDto(
      dtcCode: json['dtcCode'] as String?,
      correlatedSensorReading: json['correlatedSensorReading'] as String?,
      anomalyExplanation: json['anomalyExplanation'] as String?,
    );
  }
}

/// `PredictiveAlertResponse`.
class PredictiveAlertDto {
  final String id;
  final String? vehicleId;
  final String? recommendedServiceId;
  final String? alertType;
  final double? confidenceScore;
  final String? message;
  final String? status;
  final String? createdAt;

  const PredictiveAlertDto({
    required this.id,
    this.vehicleId,
    this.recommendedServiceId,
    this.alertType,
    this.confidenceScore,
    this.message,
    this.status,
    this.createdAt,
  });

  factory PredictiveAlertDto.fromJson(Map<String, dynamic> json) {
    return PredictiveAlertDto(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String?,
      recommendedServiceId: json['recommendedServiceId'] as String?,
      alertType: json['alertType'] as String?,
      confidenceScore: _double(json['confidenceScore']),
      message: json['message'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
