import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// `VehicleLatestTelemetryResponse` (docs/api/iot.md). No trae presión de admisión.
class LatestTelemetryDto {
  final String vehicleId;
  final String timestamp;
  final double? latitude;
  final double? longitude;
  final int? speedKmh;
  final double? engineTempCelsius;
  final int? engineRpm;
  final double? batteryVoltage;
  final double? fuelPercentage;

  const LatestTelemetryDto({
    required this.vehicleId,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.speedKmh,
    this.engineTempCelsius,
    this.engineRpm,
    this.batteryVoltage,
    this.fuelPercentage,
  });

  factory LatestTelemetryDto.fromJson(Map<String, dynamic> json) {
    double? asDouble(String key) => (json[key] as num?)?.toDouble();
    return LatestTelemetryDto(
      vehicleId: json['vehicleId'] as String,
      timestamp: json['timestamp'] as String,
      latitude: asDouble('latitude'),
      longitude: asDouble('longitude'),
      speedKmh: (json['speedKmh'] as num?)?.toInt(),
      engineTempCelsius: asDouble('engineTempCelsius'),
      engineRpm: (json['engineRpm'] as num?)?.toInt(),
      batteryVoltage: asDouble('batteryVoltage'),
      fuelPercentage: asDouble('fuelPercentage'),
    );
  }

  TelemetrySample toDomain() {
    return TelemetrySample(
      timestamp: DateTime.parse(timestamp).toUtc(),
      engineTempCelsius: engineTempCelsius,
      engineRpm: engineRpm,
      speedKmh: speedKmh,
      batteryVoltage: batteryVoltage,
      fuelPercentage: fuelPercentage,
    );
  }
}
