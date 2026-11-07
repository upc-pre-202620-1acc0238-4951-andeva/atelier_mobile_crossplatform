import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/register_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/resolve_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/telemetry_batch_handler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/diagnostics_test_env.dart';

Dtc _dtc(String code) => Dtc.of(code)!;

final _start = DateTime.utc(2026, 10, 24, 13);

TelemetrySample _sample(int second, {double? temp = 88}) {
  return TelemetrySample(
    timestamp: _start.add(Duration(seconds: second)),
    engineTempCelsius: temp,
    engineRpm: 820,
    speedKmh: 0,
    batteryVoltage: 13.9,
    fuelPercentage: 61,
    intakePressureKpa: 35,
  );
}

void main() {
  const devicesPath = '/api/v1/iot/devices';
  const installPath = '/api/v1/iot/installations/install';

  late DiagnosticsTestEnv env;

  setUp(() async {
    env = await DiagnosticsTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  test('instalación activa, sin instalación y dispositivos', () async {
    expect(await env.repository.getActiveInstallation('v1'), isNull);

    env.responses['GET /api/v1/iot/installations/vehicle/v1/active'] = (_) =>
        jsonResponse(installationJson());
    expect((await env.repository.getActiveInstallation('v1'))?.id, 'i1');

    env.responses['GET $devicesPath'] = (_) => jsonResponse([
      {
        'id': 'd1',
        'deviceIdentifier': 'AA:BB:CC:11:22:33',
        'connectionType': 'BLUETOOTH_BLE',
        'status': 'ACTIVE',
      },
    ]);
    final device = (await env.repository.getDevices(
      status: DeviceStatus.active,
    )).single;
    expect(device.matches('aa:bb:cc:11:22:33'), isTrue);
    expect(
      env.requested('GET', devicesPath).single.url.queryParameters['status'],
      'ACTIVE',
    );
  });

  test('instalar envía el odómetro y el 409 llega con el message', () async {
    env.responses['POST $installPath'] = (_) =>
        jsonResponse(installationJson(), 201);
    final installation = await env.repository.installDevice(
      deviceId: 'd1',
      vehicleId: 'v1',
      currentOdometerKm: 45000,
    );
    expect(installation.isActive, isTrue);
    expect(
      env.requested('POST', installPath).single.body,
      contains('"currentOdometerKm":45000'),
    );

    env.responses['POST $installPath'] = (_) =>
        apiError(409, 'El vehículo ya tiene un escáner');
    await expectLater(
      env.repository.installDevice(deviceId: 'd1', vehicleId: 'v1'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'El vehículo ya tiene un escáner',
        ),
      ),
    );
  });

  test('solo se guardan las muestras con temperatura y sin repetir el instante', () async {
    expect(
      await env.repository.saveReading('v1', _sample(0), latitude: -12.04, longitude: -77.04),
      isTrue,
    );
    expect(await env.repository.saveReading('v1', _sample(0)), isFalse);
    expect(await env.repository.saveReading('v1', _sample(2, temp: null)), isFalse);

    final rows = await env.db.telemetryReadingDao.findForVehicle('v1');
    expect(rows.single.latitude, -12.04);
  });

  test('las lecturas salen en lotes de 200 sin repetirse', () async {
    for (var i = 0; i < 450; i++) {
      await env.repository.saveReading('v1', _sample(i * 2));
    }

    expect(await env.repository.enqueueUnbatchedReadings(onlyFull: true), 2);
    expect(await env.repository.enqueueUnbatchedReadings(onlyFull: true), 0);
    expect(await env.repository.enqueueUnbatchedReadings(onlyFull: false), 1);
    expect(await env.repository.enqueueUnbatchedReadings(onlyFull: false), 0);

    final batches = (await env.queued())
        .where((op) => op.type == TelemetryBatchHandler.type)
        .map(env.payloadOf)
        .toList();
    expect(batches.map((b) => (b['readings'] as List).length), [200, 200, 50]);
    final first = (batches.first['readings'] as List).first as Map<String, dynamic>;
    expect(DateTime.parse(first['timestamp'] as String), _start);
    expect((first['timestamp'] as String).endsWith('Z'), isTrue);
    expect(first.containsKey('latitude'), isFalse); // Los opcionales sin dato no se envían.
    expect(first.containsKey('intakePressureKpa'), isFalse);
    expect(
      (await env.repository.watchSyncState('v1').first).pendingReadings,
      450,
    );
  });

  test('un lote ya en cola se reutiliza si se cortó antes de marcar las filas', () async {
    await env.repository.saveReading('v1', _sample(0));
    await env.repository.enqueueUnbatchedReadings(onlyFull: false);
    final operationId = (await env.queued()).single.id;
    // Simula morir entre encolar y assignBatch: la fila vuelve a estar sin lote.
    await env.db.customStatement('UPDATE telemetry_readings SET batch_operation_id = NULL');

    expect(await env.repository.enqueueUnbatchedReadings(onlyFull: false), 1);

    expect((await env.queued()).single.id, operationId);
    final row = (await env.db.telemetryReadingDao.findForVehicle('v1')).single;
    expect(row.batchOperationId, operationId);
  });

  test('las lecturas confirmadas se purgan a los 7 días', () async {
    await env.repository.saveReading(
      'v1',
      TelemetrySample(timestamp: DateTime.utc(2026, 10, 10), engineTempCelsius: 80),
    );
    await env.repository.saveReading('v1', _sample(0));
    await env.repository.enqueueUnbatchedReadings(onlyFull: false);

    await env.repository.purgeConfirmedReadings();
    expect(await env.db.telemetryReadingDao.findForVehicle('v1'), hasLength(2)); // El lote sigue en cola.

    await env.db.pendingOperationDao.deleteForUser('u1'); // El backend lo confirmó.
    await env.repository.purgeConfirmedReadings();
    final rows = await env.db.telemetryReadingDao.findForVehicle('v1');
    expect(rows.map((r) => r.timestamp), [_sample(0).timestamp.millisecondsSinceEpoch]);
    expect((await env.repository.watchSyncState('v1').first).pendingReadings, 0);
  });

  test('los códigos nuevos quedan locales con su REGISTER_FAULT y los activos no se repiten', () async {
    await env.db.vehicleFaultDao.upsert(faultEntity('f1', 'P0133'));

    final faults = await env.repository.registerDetectedFaults(
      'v1',
      [_dtc('P0133'), _dtc('P0304')],
      's1',
    );

    expect(faults[0].id, 'f1');
    expect(faults[1].isPending, isTrue);
    expect(faults[1].severity, FaultSeverity.critical);
    final operation = (await env.queued()).single;
    expect(operation.type, RegisterFaultHandler.type);
    expect(operation.dedupeKey, 'FAULT:v1:P0304:s1');
    expect(faults[1].id, 'local-${operation.id}');
    expect(env.payloadOf(operation)['severity'], 'CRITICAL');
    expect((await env.repository.watchSyncState('v1').first).pendingFaults, 1);

    // Volver a escanear en la misma sesión devuelve la misma falla.
    final again = await env.repository.registerDetectedFaults('v1', [_dtc('P0304')], 's1');
    expect(again.single.id, faults[1].id);
    expect(await env.queued(), hasLength(1));
  });

  test('un código ya en cola pero sin fila activa recupera esa operación por su dedupe_key', () async {
    final local = (await env.repository.registerDetectedFaults('v1', [_dtc('P0304')], 's1')).single;
    await env.db.vehicleFaultDao.markResolved(local.id, 5); // Ya no aparece entre las activas.

    final found = (await env.repository.registerDetectedFaults('v1', [_dtc('P0304')], 's1')).single;

    expect(found.id, local.id);
    expect(await env.queued(), hasLength(1));
    expect(await env.db.vehicleFaultDao.findById(local.id), isNotNull);
  });

  test('al borrar se resuelven las reales, se descartan las locales y se reportan las persistentes', () async {
    await env.db.vehicleFaultDao.upsert(faultEntity('f1', 'P0133'));
    await env.db.vehicleFaultDao.upsert(faultEntity('f2', 'P0420'));
    final local = (await env.repository.registerDetectedFaults('v1', [_dtc('P0304')], 's1')).single;

    final result = await env.repository.applyClearedFaults('v1', [_dtc('P0420')], 's1');

    expect(result.cleared.map((f) => f.id).toSet(), {'f1', local.id});
    expect(result.persistent.map((f) => f.id), ['f2']);
    expect(result.isClean, isFalse);
    final operation = (await env.queued()).single;
    expect(operation.type, ResolveFaultHandler.type);
    expect(operation.dedupeKey, 'RESOLVE_FAULT:f1');
    expect(await env.db.vehicleFaultDao.findById(local.id), isNull);
    final active = await env.repository.watchActiveFaults('v1').first;
    expect(active.map((f) => f.id), ['f2']);
  });

  test('una falla local que se está enviando se resuelve después de su registro', () async {
    final local = (await env.repository.registerDetectedFaults('v1', [_dtc('P0304')], 's1')).single;
    final registerId = (await env.queued()).single.id;
    await env.db.pendingOperationDao.markSyncing(registerId);

    await env.repository.applyClearedFaults('v1', const [], 's1');

    final operations = await env.queued();
    final resolve = operations.singleWhere((op) => op.type == ResolveFaultHandler.type);
    expect(resolve.dependsOn, registerId);
    expect(env.payloadOf(resolve)['faultId'], local.id);
    expect((await env.db.vehicleFaultDao.findById(local.id))!.isResolved, isTrue);
    expect(operations.where((op) => op.id == registerId), hasLength(1));
  });

  test('recargar las fallas conserva las locales y las que se están resolviendo', () async {
    final local = (await env.repository.registerDetectedFaults('v1', [_dtc('P0304')], 's1')).single;
    await env.db.vehicleFaultDao.upsert(faultEntity('f1', 'P0133'));
    await env.repository.applyClearedFaults('v1', [_dtc('P0304')], 's1'); // f1 se resuelve en cola.
    env.responses['GET /api/v1/iot/faults/vehicle/v1/active'] = (_) => jsonResponse([
      faultJson('f1', 'P0133'),
      faultJson('f3', 'P0171'),
    ]);

    await env.repository.refreshActiveFaults('v1');

    final active = await env.repository.watchActiveFaults('v1').first;
    expect(active.map((f) => f.id).toSet(), {local.id, 'f3'});
  });

  test('recargar quita la falla local cuya operación se descartó', () async {
    final local = (await env.repository.registerDetectedFaults('v1', [_dtc('P0304')], 's1')).single;
    final operationId = (await env.queued()).single.id;
    await env.db.pendingOperationDao.discardUnlessSyncing([operationId]);
    env.responses['GET /api/v1/iot/faults/vehicle/v1/active'] = (_) =>
        jsonResponse(<Object>[]);

    await env.repository.refreshActiveFaults('v1');

    expect(await env.db.vehicleFaultDao.findById(local.id), isNull);
    expect((await env.repository.watchSyncState('v1').first).pendingFaults, 0);
  });

  test('sin permiso no se piden fallas ni alertas', () async {
    await env.signIn(permissions: const []);

    await env.repository.refreshActiveFaults('v1');
    await env.repository.refreshPredictiveAlerts('v1');

    expect(env.requests, isEmpty);
  });

  test('alertas predictivas en caché y marcar como revisada', () async {
    env.responses['GET /api/v1/iot/alerts/vehicle/v1'] = (_) =>
        jsonResponse([alertJson('a1'), alertJson('a2')]);
    await env.repository.refreshPredictiveAlerts('v1');
    expect(await env.repository.watchPredictiveAlerts('v1').first, hasLength(2));

    env.responses['PATCH /api/v1/iot/alerts/a1/acknowledge'] = (_) =>
        jsonResponse(alertJson('a1', status: 'ACKNOWLEDGED'));
    final alert = await env.repository.acknowledgePredictiveAlert('a1');

    expect(alert.recommendedServiceId, 's1');
    final cached = await env.repository.watchPredictiveAlerts('v1').first;
    expect(
      cached.firstWhere((a) => a.id == 'a1').status,
      PredictiveAlertStatus.acknowledged,
    );
  });
}
