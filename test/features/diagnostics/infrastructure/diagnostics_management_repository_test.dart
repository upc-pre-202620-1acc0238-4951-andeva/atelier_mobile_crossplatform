import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/register_fault_handler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/diagnostics_test_env.dart';

const _devicesPath = '/api/v1/iot/devices';
const _installPath = '/api/v1/iot/installations/install';
const _tenantAlertsPath = '/api/v1/iot/alerts/tenant';

Map<String, dynamic> _body(DiagnosticsTestEnv env, String method, String path) {
  return jsonDecode(env.requested(method, path).single.body)
      as Map<String, dynamic>;
}

Map<String, Object?> _deviceJson({String status = 'ACTIVE'}) => {
  'id': 'd1',
  'deviceIdentifier': 'AA:BB',
  'connectionType': 'BLUETOOTH_BLE',
  'status': status,
  'hardwareModel': 'ELM327',
};

Dtc _dtc(String code) => Dtc.of(code)!;

void main() {
  late DiagnosticsTestEnv env;

  setUp(() async {
    env = await DiagnosticsTestEnv.create();
    await env.signIn();
  });
  tearDown(() => env.close());

  group('escáneres', () {
    test('registerDevice recorta y omite los opcionales vacíos', () async {
      env.responses['POST $_devicesPath'] = (_) =>
          jsonResponse(_deviceJson(), 201);

      final device = await env.repository.registerDevice(
        deviceIdentifier: ' AA:BB ',
        connectionType: 'BLUETOOTH_BLE',
        hardwareModel: ' ELM327 ',
        firmwareVersion: ' ',
      );

      expect(_body(env, 'POST', _devicesPath), {
        'deviceIdentifier': 'AA:BB',
        'connectionType': 'BLUETOOTH_BLE',
        'hardwareModel': 'ELM327',
      });
      expect(device.id, 'd1');
      expect(device.status, DeviceStatus.active);
    });

    test('updateDeviceStatus manda el estado por PATCH', () async {
      env.responses['PATCH $_devicesPath/d1/status'] = (_) =>
          jsonResponse(_deviceJson(status: 'LOST'));

      final device = await env.repository.updateDeviceStatus(
        'd1',
        DeviceStatus.lost,
      );

      expect(_body(env, 'PATCH', '$_devicesPath/d1/status'), {'status': 'LOST'});
      expect(device.status, DeviceStatus.lost);
    });

    test('sin kilometraje instala y retira con 0, como Android', () async {
      env.responses['POST $_installPath'] = (_) =>
          jsonResponse(installationJson(), 201);
      env.responses['POST /api/v1/iot/installations/i1/uninstall'] = (_) =>
          jsonResponse(installationJson());

      await env.repository.installDevice(deviceId: 'd1', vehicleId: 'v1');
      await env.repository.uninstallDevice('i1');

      expect(_body(env, 'POST', _installPath)['currentOdometerKm'], 0);
      expect(
        _body(
          env,
          'POST',
          '/api/v1/iot/installations/i1/uninstall',
        )['finalOdometerKm'],
        0,
      );
    });
  });

  group('alertas del taller', () {
    test('getTenantPredictiveAlerts las devuelve y las guarda por vehículo', () async {
      env.responses['GET $_tenantAlertsPath'] = (_) => jsonResponse([
        alertJson('a1'),
        {...alertJson('a2'), 'vehicleId': null},
      ]);

      final alerts = await env.repository.getTenantPredictiveAlerts();

      expect(alerts.map((a) => a.id), ['a1', 'a2']);
      expect(alerts.last.vehicleId, '');
      final cached = await env.repository.watchPredictiveAlerts('v1').first;
      expect(cached.map((a) => a.id), ['a1']);
    });

    test('convertAlertToAppointment manda la sede de la sesión y lo acordado', () async {
      await env.session.updateAssignment('b1', null);
      env.responses['POST /api/v1/iot/alerts/a1/convert-to-appointment'] =
          (_) => jsonResponse({
            'appointmentId': 'ap1',
            'vehicleId': 'v1',
            'customerId': 'c1',
            'scheduledAt': '2026-12-01T15:00:00Z',
            'status': 'SCHEDULED',
            'notes': 'Preventivo',
          });

      final appointment = await env.repository.convertAlertToAppointment(
        'a1',
        scheduledAt: DateTime.utc(2026, 12, 1, 15),
        estimatedDurationMinutes: 90,
        reason: ' Revisar refrigerante ',
      );

      expect(
        _body(env, 'POST', '/api/v1/iot/alerts/a1/convert-to-appointment'),
        {
          'branchId': 'b1',
          'scheduledAt': '2026-12-01T15:00:00.000Z',
          'estimatedDurationMinutes': 90,
          'reason': 'Revisar refrigerante',
        },
      );
      expect(appointment.appointmentId, 'ap1');
      expect(appointment.scheduledAt, DateTime.utc(2026, 12, 1, 15));
      expect(appointment.status, 'SCHEDULED');
    });

    test('sin datos opcionales manda un cuerpo vacío', () async {
      env.responses['POST /api/v1/iot/alerts/a1/convert-to-appointment'] =
          (_) => jsonResponse({'appointmentId': 'ap1'});

      final appointment = await env.repository.convertAlertToAppointment('a1');

      expect(
        _body(env, 'POST', '/api/v1/iot/alerts/a1/convert-to-appointment'),
        isEmpty,
      );
      expect(appointment.vehicleId, '');
      expect(appointment.scheduledAt, isNull);
    });
  });

  group('H22: sin iot:telemetry:ingest', () {
    setUp(() async {
      await env.signIn(
        permissions: const [Permission.faultsRead, Permission.faultsResolve],
      );
    });

    test('los códigos leídos no se guardan ni se encolan, y no cambian los ya activos', () async {
      await env.db.vehicleFaultDao.upsert(faultEntity('f1', 'P0133'));

      final faults = await env.repository.registerDetectedFaults(
        'v1',
        [_dtc('P0133'), _dtc('P0304')],
        's1',
      );

      expect(faults[0].id, 'f1');
      expect(faults[1].id, '${VehicleFault.scanPrefix}P0304');
      expect(faults[1].isPending, isFalse);
      expect(faults[1].severity, FaultSeverity.critical);
      expect(faults[1].isResolved, isFalse);
      expect(await env.queued(), isEmpty);
      expect(await env.db.vehicleFaultDao.findById(faults[1].id), isNull);
    });

    test('borrar sigue resolviendo en el backend las fallas remotas', () async {
      await env.db.vehicleFaultDao.upsert(faultEntity('f1', 'P0133'));

      final result = await env.repository.applyClearedFaults('v1', const [], 's1');

      expect(result.cleared.single.id, 'f1');
      expect((await env.queued()).single.dedupeKey, 'RESOLVE_FAULT:f1');
    });
  });

  test('con iot:telemetry:ingest los códigos nuevos se encolan', () async {
    final faults = await env.repository.registerDetectedFaults(
      'v1',
      [_dtc('P0304')],
      's1',
    );

    expect(faults.single.isPending, isTrue);
    expect(await env.queued(), hasLength(1));
  });

  test('descartar un REGISTER_FAULT borra la falla local', () async {
    final local = (await env.repository.registerDetectedFaults('v1', [
      _dtc('P0304'),
    ], 's1')).single;
    final operation = (await env.queued()).single;
    final handler = RegisterFaultHandler(api: env.api, dao: env.db.vehicleFaultDao);

    await handler.onDiscard(operation);

    expect(await env.db.vehicleFaultDao.findById(local.id), isNull);
  });

  test('onDiscard sin la fila local no falla', () async {
    final handler = RegisterFaultHandler(api: env.api, dao: env.db.vehicleFaultDao);
    final ghost = PendingOperationEntity(
      id: 'nope',
      type: RegisterFaultHandler.type,
      payload: '{}',
      dedupeKey: 'k',
      userId: 'u1',
      tenantId: 't1',
      status: 'PENDING',
      attempts: 0,
      nextAttemptAt: 0,
      createdAt: 0,
    );

    await handler.onDiscard(ghost);
  });
}
