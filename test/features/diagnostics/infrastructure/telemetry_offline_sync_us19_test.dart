import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/diagnostics_pre_sync_hook.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/telemetry_batch_handler.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import '../support/diagnostics_test_env.dart';

/// US19 — almacenamiento local resiliente y sincronización diferida en la fosa.
void main() {
  late DiagnosticsTestEnv env;

  setUp(() async {
    env = await DiagnosticsTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  TelemetrySample sample(DateTime at) => TelemetrySample(
    timestamp: at,
    engineTempCelsius: 90,
    engineRpm: 800,
  );

  Future<void> insertForeign(String id, String userId, DateTime at) {
    return env.db
        .into(env.db.telemetryReadings)
        .insert(
          TelemetryReadingsCompanion.insert(
            id: id,
            vehicleId: 'v1',
            timestamp: at.millisecondsSinceEpoch,
            engineTempCelsius: 85,
            userId: Value(userId),
          ),
        );
  }

  Future<List<Map<String, dynamic>>> batches() async => [
    for (final op in await env.queued())
      if (op.type == TelemetryBatchHandler.type) env.payloadOf(op),
  ];

  test('E1: sin señal la lectura queda en el teléfono con su dueño y estado pendiente', () async {
    final capturedAt = env.clock.subtract(const Duration(minutes: 5));
    expect(await env.repository.saveReading('v1', sample(capturedAt)), isTrue);

    final row = (await env.db.telemetryReadingDao.findForVehicle('v1')).single;
    expect(row.userId, 'u1');
    expect(row.batchOperationId, isNull);
    expect((await env.repository.watchSyncState('v1').first).pendingReadings, 1);
    expect((await env.repository.watchSyncState('v1').first).isSynced, isFalse);
  });

  test('E2: el pre-sync empaqueta el remanente tras 60 s sin muestras, con la hora original', () async {
    final capturedAt = env.clock.subtract(const Duration(minutes: 5));
    for (var i = 0; i < 3; i++) {
      await env.repository.saveReading('v1', sample(capturedAt.add(Duration(seconds: i * 2))));
    }

    await DiagnosticsPreSyncHook(repository: env.repository).beforeSync('u1');

    final sent = await batches();
    expect(sent, hasLength(1));
    final readings = sent.single['readings'] as List;
    expect(readings, hasLength(3));
    expect(DateTime.parse((readings.first as Map)['timestamp'] as String), capturedAt);
    // Sigue pendiente hasta que el lote salga de la cola.
    expect((await env.repository.watchSyncState('v1').first).pendingReadings, 3);
  });

  test('E2: no parte en micro-lotes un vehículo que sigue transmitiendo', () async {
    await env.repository.saveReading('v1', sample(env.clock.subtract(const Duration(seconds: 4))));

    await DiagnosticsPreSyncHook(repository: env.repository).beforeSync('u1');
    expect(await batches(), isEmpty);

    // Al cerrar sesión se empaqueta todo, sin esperar.
    await DiagnosticsPreSyncHook(repository: env.repository).beforeSync('u1', forceFlushAll: true);
    expect(await batches(), hasLength(1));
  });

  test('terminal compartido: las lecturas de otro técnico no viajan con esta sesión', () async {
    final old = env.clock.subtract(const Duration(minutes: 10));
    await insertForeign('ajena', 'u2', old);
    await env.repository.saveReading('v1', sample(old.add(const Duration(seconds: 2))));
    // Una fila anterior a la v3 (sin dueño) la envía quien tenga sesión.
    await env.db.customStatement(
      'INSERT INTO telemetry_readings (id, vehicle_id, timestamp, engine_temp_celsius) VALUES (?, ?, ?, ?)',
      ['legado', 'v1', old.add(const Duration(seconds: 4)).millisecondsSinceEpoch, 80.0],
    );

    expect(await env.repository.enqueueUnbatchedReadings(onlyFull: false, userId: 'u1'), 1);

    final readings = (await batches()).single['readings'] as List;
    expect(readings, hasLength(2));
    final rows = {for (final r in await env.db.telemetryReadingDao.findForVehicle('v1')) r.id: r};
    expect(rows['ajena']!.batchOperationId, isNull);
    expect(rows['legado']!.batchOperationId, isNotNull);
  });

  test('sin iot:telemetry:ingest (Mecánico Jefe, H22) no se encola un lote que daría 403', () async {
    await env.signIn(permissions: const [Permission.faultsRead, Permission.faultsResolve]);
    await env.repository.saveReading('v1', sample(env.clock.subtract(const Duration(minutes: 5))));

    expect(await env.repository.enqueueUnbatchedReadings(onlyFull: false), 0);
    expect(await batches(), isEmpty);
  });

  test('pedidos simultáneos no duplican lotes', () async {
    final start = env.clock.subtract(const Duration(minutes: 20));
    for (var i = 0; i < 250; i++) {
      await env.repository.saveReading('v1', sample(start.add(Duration(seconds: i * 2))));
    }

    final results = await Future.wait<int>([
      env.repository.enqueueUnbatchedReadings(onlyFull: false),
      env.repository.enqueueUnbatchedReadings(onlyFull: false),
    ]);
    await DiagnosticsPreSyncHook(repository: env.repository).beforeSync('u1');

    expect(results[0] + results[1], 2);
    expect((await batches()).map((b) => (b['readings'] as List).length), [200, 50]);
  });
}
