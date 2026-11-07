import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/register_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/resolve_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/telemetry_batch_handler.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;

import '../support/diagnostics_test_env.dart';

PendingOperationEntity _op(String id, String type, Map<String, Object?> payload) {
  return PendingOperationEntity(
    id: id,
    type: type,
    payload: jsonEncode(payload),
    dedupeKey: '$type:$id',
    userId: 'u1',
    tenantId: 't1',
    status: 'PENDING',
    attempts: 0,
    nextAttemptAt: 0,
    createdAt: 0,
  );
}

void main() {
  const batchPath = '/api/v1/iot/telemetry/batch';
  const faultsPath = '/api/v1/iot/faults';
  const activePath = '/api/v1/iot/faults/vehicle/v1/active';
  const resolvePath = '/api/v1/iot/faults/f9/resolve';

  late DiagnosticsTestEnv env;
  late TelemetryBatchHandler batch;
  late RegisterFaultHandler register;
  late ResolveFaultHandler resolve;

  final batchOp = _op('b1', TelemetryBatchHandler.type, {
    'vehicleId': 'v1',
    'readings': [
      {
        'timestamp': '2026-10-24T13:00:00.000Z',
        'engineTempCelsius': 88.5,
        'engineRpm': 820,
      },
    ],
  });
  final registerOp = _op('op1', RegisterFaultHandler.type, {
    'vehicleId': 'v1',
    'dtcCode': 'P0304',
    'severity': 'CRITICAL',
    'description': 'Falla de encendido en el cilindro 4',
  });

  setUp(() async {
    env = await DiagnosticsTestEnv.create();
    await env.signIn();
    batch = TelemetryBatchHandler(api: env.api);
    register = RegisterFaultHandler(
      api: env.api,
      dao: env.db.vehicleFaultDao,
      now: () => env.clock,
    );
    resolve = ResolveFaultHandler(
      api: env.api,
      dao: env.db.vehicleFaultDao,
      now: () => env.clock,
    );
  });

  tearDown(() => env.close());

  test('TELEMETRY_BATCH: 202 se aplica, 404 falla con el message, sin red reintenta', () async {
    env.responses['POST $batchPath'] = (_) =>
        jsonResponse({'vehicleId': 'v1', 'ingestedCount': 1}, 202);
    expect(await batch.send(batchOp), isA<Applied>());
    expect(env.requested('POST', batchPath).single.body, contains('"engineTempCelsius":88.5'));

    env.responses['POST $batchPath'] = (_) =>
        apiError(404, 'El vehículo no tiene un escáner instalado');
    expect(
      await batch.send(batchOp),
      isA<Failed>().having(
        (r) => r.message,
        'message',
        'El vehículo no tiene un escáner instalado',
      ),
    );

    env.responses['POST $batchPath'] = offline;
    expect(await batch.send(batchOp), isA<Retry>());
  });

  test('REGISTER_FAULT reemplaza la falla local por la del backend', () async {
    await env.db.vehicleFaultDao.upsert(faultEntity('local-op1', 'P0304'));
    env.responses['POST $faultsPath'] = (_) =>
        jsonResponse(faultJson('f9', 'P0304'), 201);

    expect(await register.send(registerOp), isA<Applied>());

    expect(await env.db.vehicleFaultDao.findById('local-op1'), isNull);
    expect((await env.db.vehicleFaultDao.findById('f9'))!.dtcCode, 'P0304');
  });

  test('REGISTER_FAULT conserva la marca de borrada para su RESOLVE_FAULT', () async {
    await env.db.vehicleFaultDao.upsert(
      faultEntity('local-op1', 'P0304', resolved: true),
    );
    env.responses['POST $faultsPath'] = (_) =>
        jsonResponse(faultJson('f9', 'P0304'), 201);

    await register.send(registerOp);

    expect((await env.db.vehicleFaultDao.findById('f9'))!.isResolved, isTrue);
  });

  test('RESOLVE_FAULT con id real o local', () async {
    env.responses['POST $resolvePath'] = (_) =>
        jsonResponse(faultJson('f9', 'P0304', resolved: true));
    final real = _op('r1', ResolveFaultHandler.type, {
      'faultId': 'f9',
      'vehicleId': 'v1',
      'dtcCode': 'P0304',
    });
    expect(await resolve.send(real), isA<Applied>());
    expect((await env.db.vehicleFaultDao.findById('f9'))!.isResolved, isTrue);

    // Local: el id real se busca entre las activas del vehículo.
    env.requests.clear();
    env.responses['GET $activePath'] = (_) =>
        jsonResponse([faultJson('f9', 'P0304')]);
    final pending = _op('r2', ResolveFaultHandler.type, {
      'faultId': 'local-op1',
      'vehicleId': 'v1',
      'dtcCode': 'P0304',
    });
    expect(await resolve.send(pending), isA<Applied>());
    expect(env.requested('POST', resolvePath), hasLength(1));

    // Si ya no está activa no hay nada que resolver.
    env.requests.clear();
    env.responses['GET $activePath'] = (_) => jsonResponse(<Object>[]);
    expect(await resolve.send(pending), isA<Applied>());
    expect(env.requested('POST', resolvePath), isEmpty);
  });
}
