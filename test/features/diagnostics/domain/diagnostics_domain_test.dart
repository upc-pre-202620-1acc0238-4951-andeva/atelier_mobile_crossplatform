import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_validation.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc_catalog.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry_thresholds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Dtc dtc(String code) => Dtc.of(code)!;

  test('el DTC se normaliza y valida con el formato del backend', () {
    expect(Dtc.of(' p0301 ')?.code, 'P0301');
    expect(Dtc.of('X1234'), isNull);
    expect(Dtc.of('P030'), isNull);
    expect(Dtc.isValid('u0100'), isTrue);
  });

  test('catálogo de DTC con severidad por código y por familia', () {
    FaultSeverity severity(String code) =>
        DtcCatalog.describe(dtc(code)).severity;

    expect(severity('P0217'), FaultSeverity.critical);
    expect(severity('P0304'), FaultSeverity.critical);
    expect(
      DtcCatalog.describe(dtc('P0304')).description,
      endsWith('cilindro 4'),
    );
    expect(
      DtcCatalog.describe(dtc('P0310')).description,
      endsWith('cilindro 10'),
    );
    expect(severity('P0456'), FaultSeverity.low);
    expect(severity('B1234'), FaultSeverity.low);
    expect(severity('C0035'), FaultSeverity.medium);
    expect(
      DtcCatalog.describe(dtc('U0401')).description,
      'Falla de red de comunicación U0401',
    );
  });

  test('umbrales de la telemetría en vivo', () {
    TelemetrySample sample({double? temp, int? rpm, double? volts}) {
      return TelemetrySample(
        timestamp: DateTime.utc(2026),
        engineTempCelsius: temp,
        engineRpm: rpm,
        speedKmh: 0,
        batteryVoltage: volts,
      );
    }

    expect(
      TelemetryThresholds.warningsFor(
        sample(temp: 110, rpm: 6500, volts: 11.5),
      ),
      {
        TelemetryWarning.coolantOverheat,
        TelemetryWarning.highRpm,
        TelemetryWarning.lowVoltage,
      },
    );
    expect(
      TelemetryThresholds.warningsFor(sample(temp: 90, rpm: 800, volts: 13.9)),
      isEmpty,
    );
    expect(TelemetryThresholds.warningsFor(sample(volts: 15.5)), {
      TelemetryWarning.highVoltage,
    });
    expect(sample().canBeSent, isFalse);
  });

  test('validaciones y sugerencia de dispositivo por MAC', () {
    expect(DiagnosticsValidation.isDaysToAnalyze(7), isTrue);
    expect(DiagnosticsValidation.isDaysToAnalyze(90), isTrue);
    expect(DiagnosticsValidation.isDaysToAnalyze(6), isFalse);
    expect(DiagnosticsValidation.isDaysToAnalyze(91), isFalse);
    expect(DiagnosticsValidation.isOdometer(-1), isFalse);
    expect(DiagnosticsValidation.isOdometer(null), isTrue);

    const device = ObdDevice(
      id: 'd1',
      deviceIdentifier: 'aa:bb:cc:11:22:33',
      connectionType: 'BLUETOOTH_BLE',
      status: DeviceStatus.active,
    );
    expect(device.matches('AA:BB:CC:11:22:33'), isTrue);
    expect(device.matches('AA:BB:CC:11:22:34'), isFalse);
  });
}
