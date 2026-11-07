import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// Umbrales de precaución de US18 E1. La API no trae umbrales por fabricante: son valores generales.
abstract final class TelemetryThresholds {
  static const maxCoolantCelsius = 105.0;
  static const minBatteryVolts = 12.0;
  static const maxBatteryVolts = 15.0;
  static const maxEngineRpm = 6000;

  static Set<TelemetryWarning> warningsFor(TelemetrySample sample) {
    final coolant = sample.engineTempCelsius;
    final volts = sample.batteryVoltage;
    final rpm = sample.engineRpm;
    return {
      if (coolant != null && coolant > maxCoolantCelsius)
        TelemetryWarning.coolantOverheat,
      if (volts != null && volts < minBatteryVolts) TelemetryWarning.lowVoltage,
      if (volts != null && volts > maxBatteryVolts)
        TelemetryWarning.highVoltage,
      if (rpm != null && rpm > maxEngineRpm) TelemetryWarning.highRpm,
    };
  }
}
