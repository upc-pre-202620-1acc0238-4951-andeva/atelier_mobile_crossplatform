import 'package:atelier_mobile_crossplatform/features/diagnostics/application/convert_alert_to_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_tenant_predictive_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/register_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/update_obd_device_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements DiagnosticsRepository {}

Matcher _invalid(String field) {
  return throwsA(
    isA<InvalidDiagnosticsInputException>().having(
      (e) => e.field,
      'field',
      field,
    ),
  );
}

void main() {
  late _MockRepository repository;
  const device = ObdDevice(id: 'd1', deviceIdentifier: 'AA:BB');

  setUpAll(() {
    registerFallbackValue(DeviceStatus.active);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() => repository = _MockRepository());

  group('RegisterObdDeviceUseCase', () {
    late RegisterObdDeviceUseCase useCase;

    setUp(() => useCase = RegisterObdDeviceUseCase(repository: repository));

    test(
      'exige identificador y solo admite BLUETOOTH_BLE (H18), sin llamar',
      () async {
        await expectLater(
          useCase.execute(deviceIdentifier: '  '),
          _invalid('deviceIdentifier'),
        );
        await expectLater(
          useCase.execute(
            deviceIdentifier: 'AA:BB',
            connectionType: 'BLUETOOTH_CLASSIC',
          ),
          _invalid('connectionType'),
        );
        verifyZeroInteractions(repository);
      },
    );

    test('recorta el identificador y usa BLUETOOTH_BLE por defecto', () async {
      when(
        () => repository.registerDevice(
          deviceIdentifier: any(named: 'deviceIdentifier'),
          connectionType: any(named: 'connectionType'),
          hardwareModel: any(named: 'hardwareModel'),
          firmwareVersion: any(named: 'firmwareVersion'),
        ),
      ).thenAnswer((_) async => device);

      final registered = await useCase.execute(
        deviceIdentifier: ' AA:BB ',
        hardwareModel: 'ELM327 v2.1',
      );

      expect(registered, device);
      verify(
        () => repository.registerDevice(
          deviceIdentifier: 'AA:BB',
          connectionType: 'BLUETOOTH_BLE',
          hardwareModel: 'ELM327 v2.1',
        ),
      ).called(1);
    });
  });

  test('UpdateObdDeviceStatus pasa el estado al repositorio', () async {
    when(() => repository.updateDeviceStatus(any(), any()))
        .thenAnswer((_) async => device);

    await UpdateObdDeviceStatusUseCase(repository: repository)
        .execute('d1', DeviceStatus.lost);

    verify(() => repository.updateDeviceStatus('d1', DeviceStatus.lost))
        .called(1);
  });

  test('GetTenantPredictiveAlerts devuelve las alertas del taller', () async {
    when(() => repository.getTenantPredictiveAlerts())
        .thenAnswer((_) async => const []);

    expect(
      await GetTenantPredictiveAlertsUseCase(repository: repository).execute(),
      isEmpty,
    );
    verify(() => repository.getTenantPredictiveAlerts()).called(1);
  });

  test('ConvertAlertToAppointment pasa fecha, duración y motivo', () async {
    final when_ = DateTime.utc(2026, 12, 1, 15);
    when(
      () => repository.convertAlertToAppointment(
        any(),
        scheduledAt: any(named: 'scheduledAt'),
        estimatedDurationMinutes: any(named: 'estimatedDurationMinutes'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer(
      (_) async => const ConvertedAppointment(
        appointmentId: 'a1',
        vehicleId: 'v1',
        customerId: 'c1',
      ),
    );

    final appointment =
        await ConvertAlertToAppointmentUseCase(repository: repository).execute(
          'al1',
          scheduledAt: when_,
          estimatedDurationMinutes: 60,
          reason: 'Revisar el refrigerante',
        );

    expect(appointment.appointmentId, 'a1');
    verify(
      () => repository.convertAlertToAppointment(
        'al1',
        scheduledAt: when_,
        estimatedDurationMinutes: 60,
        reason: 'Revisar el refrigerante',
      ),
    ).called(1);
  });
}
