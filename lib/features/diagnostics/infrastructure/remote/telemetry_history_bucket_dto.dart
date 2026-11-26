import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// `TelemetryHistoryBucketResponse` (docs/api/iot.md).
class TelemetryHistoryBucketDto {
  final String? bucketTime;
  final String? vehicleId;
  final int? avgSpeedKmh;
  final double? avgEngineTempCelsius;
  final int? avgEngineRpm;
  final double? avgFuelPercentage;
  final double? avgBatteryVoltage;
  final int? sampleCount;

  const TelemetryHistoryBucketDto({
    this.bucketTime,
    this.vehicleId,
    this.avgSpeedKmh,
    this.avgEngineTempCelsius,
    this.avgEngineRpm,
    this.avgFuelPercentage,
    this.avgBatteryVoltage,
    this.sampleCount,
  });

  factory TelemetryHistoryBucketDto.fromJson(Map<String, dynamic> json) {
    double? asDouble(String key) => (json[key] as num?)?.toDouble();
    int? asInt(String key) => (json[key] as num?)?.toInt();
    return TelemetryHistoryBucketDto(
      bucketTime: json['bucketTime'] as String?,
      vehicleId: json['vehicleId'] as String?,
      avgSpeedKmh: asInt('avgSpeedKmh'),
      avgEngineTempCelsius: asDouble('avgEngineTempCelsius'),
      avgEngineRpm: asInt('avgEngineRpm'),
      avgFuelPercentage: asDouble('avgFuelPercentage'),
      avgBatteryVoltage: asDouble('avgBatteryVoltage'),
      sampleCount: asInt('sampleCount'),
    );
  }

  TelemetryHistoryBucket toDomain(String requestedVehicleId) {
    final time = bucketTime;
    return TelemetryHistoryBucket(
      bucketTime: time == null ? null : DateTime.tryParse(time)?.toUtc(),
      vehicleId: vehicleId ?? requestedVehicleId,
      avgSpeedKmh: avgSpeedKmh,
      avgEngineTempCelsius: avgEngineTempCelsius,
      avgEngineRpm: avgEngineRpm,
      avgFuelPercentage: avgFuelPercentage,
      avgBatteryVoltage: avgBatteryVoltage,
      sampleCount: sampleCount ?? 0,
    );
  }
}
