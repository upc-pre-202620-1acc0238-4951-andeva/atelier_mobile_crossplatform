import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late PendingOperationDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.pendingOperationDao;
  });
  tearDown(() => database.close());

  PendingOperationsCompanion operation(
    String id, {
    String? dedupeKey,
    String userId = 'u1',
    int nextAttemptAt = 0,
    int createdAt = 0,
  }) {
    return PendingOperationsCompanion.insert(
      id: id,
      type: 'PROBE',
      payload: '{}',
      dedupeKey: dedupeKey ?? id,
      userId: userId,
      tenantId: 't1',
      nextAttemptAt: nextAttemptAt,
      createdAt: createdAt,
    );
  }

  test('enqueue respeta dedupe_key', () async {
    expect(await dao.enqueue(operation('a', dedupeKey: 'k')), isTrue);
    expect(await dao.enqueue(operation('b', dedupeKey: 'k')), isFalse);
    expect(await database.select(database.pendingOperations).get(), hasLength(1));
  });

  test('nextBatch filtra usuario, estado y hora, y ordena por captura', () async {
    await dao.enqueue(operation('late', createdAt: 2));
    await dao.enqueue(operation('early', createdAt: 1));
    await dao.enqueue(operation('other', userId: 'u2'));
    await dao.enqueue(operation('future', nextAttemptAt: 100));
    await dao.enqueue(operation('syncing'));
    await dao.markSyncing('syncing');

    final batch = await dao.nextBatch('u1', 50);
    expect(batch.map((e) => e.id), ['early', 'late']);
  });

  test('los contadores cuentan PENDING y FAILED, solo del usuario', () async {
    await dao.enqueue(operation('pending'));
    await dao.enqueue(operation('failed'));
    await dao.markFailed('failed', attempts: 1, code: 'X', message: 'x');
    await dao.enqueue(operation('syncing'));
    await dao.markSyncing('syncing');
    await dao.enqueue(operation('other', userId: 'u2'));

    expect(await dao.watchPendingCount('u1').first, 2);
  });

  test('resetSyncing solo afecta al usuario indicado', () async {
    await dao.enqueue(operation('mine'));
    await dao.enqueue(operation('other', userId: 'u2'));
    await dao.markSyncing('mine');
    await dao.markSyncing('other');

    await dao.resetSyncing('u1');

    expect((await dao.findById('mine'))!.status, 'PENDING');
    expect((await dao.findById('other'))!.status, 'SYNCING');
  });

  test('dependentIds omite las que ya fallaron', () async {
    await dao.enqueue(operation('parent'));
    await dao.enqueue(
      operation('child').copyWith(dependsOn: const Value('parent')),
    );
    await dao.enqueue(
      operation('failed').copyWith(dependsOn: const Value('parent')),
    );
    await dao.markFailed('failed', attempts: 1);

    expect(await dao.dependentIds('parent'), ['child']);
  });

  test('nextAttemptAfter da el mínimo futuro; lo vencido no cuenta', () async {
    expect(await dao.nextAttemptAfter('u1', 5), isNull);
    await dao.enqueue(operation('past', nextAttemptAt: 1));
    expect(await dao.nextAttemptAfter('u1', 5), isNull);
    await dao.enqueue(operation('a', nextAttemptAt: 30));
    await dao.enqueue(operation('b', nextAttemptAt: 10));
    expect(await dao.nextAttemptAfter('u1', 5), 10);
  });

  test('el contador incluye PENDING y FAILED, no SYNCING', () async {
    await dao.enqueue(operation('a'));
    await dao.enqueue(operation('b'));
    await dao.enqueue(operation('c'));
    await dao.markFailed('b', attempts: 1);
    await dao.markSyncing('c');
    expect(await dao.watchPendingCount('u1').first, 2);
  });

  test('clearCaches borra las cachés y conserva cola, telemetría y locks', () async {
    await dao.enqueue(operation('a'));
    await database.into(database.branches).insert(
      BranchesCompanion.insert(
        id: 'b1',
        name: 'Sede',
        latitude: 0,
        longitude: 0,
        geofenceRadiusMeters: 50,
        isActive: true,
        syncedAt: 0,
      ),
    );
    await database.into(database.telemetryReadings).insert(
      TelemetryReadingsCompanion.insert(
        id: 't1',
        vehicleId: 'v1',
        timestamp: 1,
        engineTempCelsius: 90,
      ),
    );
    await database.into(database.appLocks).insert(
      AppLocksCompanion.insert(name: 'x', owner: 'o', expiresAt: 1),
    );

    await database.cacheMaintenanceDao.clearCaches();

    expect(await database.select(database.branches).get(), isEmpty);
    expect(await database.select(database.pendingOperations).get(), hasLength(1));
    expect(await database.select(database.telemetryReadings).get(), hasLength(1));
    expect(await database.select(database.appLocks).get(), hasLength(1));
  });

  test('markSyncing solo pasa desde PENDING', () async {
    await dao.enqueue(operation('a'));
    await dao.enqueue(operation('b'));
    await dao.markFailed('b', attempts: 1);

    expect(await dao.markSyncing('a'), isTrue);
    expect(await dao.markSyncing('a'), isFalse);
    expect(await dao.markSyncing('b'), isFalse);
    expect(await dao.markSyncing('missing'), isFalse);
    expect((await dao.findById('b'))!.status, 'FAILED');
  });

  test('resetFailed solo reactiva FAILED y limpia el error', () async {
    await dao.enqueue(operation('failed'));
    await dao.enqueue(operation('pending', nextAttemptAt: 7));
    await dao.enqueue(operation('syncing'));
    await dao.enqueue(operation('outside'));
    await dao.markFailed(
      'failed',
      attempts: 8,
      httpStatus: 422,
      code: 'CODE',
      message: 'Falló',
    );
    await dao.markSyncing('syncing');
    await dao.markFailed('outside', attempts: 1);

    await dao.resetFailed(['failed', 'pending', 'syncing'], 100);

    final failed = (await dao.findById('failed'))!;
    expect(failed.status, 'PENDING');
    expect(failed.attempts, 0);
    expect(failed.nextAttemptAt, 100);
    expect(failed.lastHttpStatus, isNull);
    expect(failed.lastErrorCode, isNull);
    expect(failed.lastErrorMessage, isNull);
    expect((await dao.findById('pending'))!.nextAttemptAt, 7);
    expect((await dao.findById('syncing'))!.status, 'SYNCING');
    expect((await dao.findById('outside'))!.status, 'FAILED');
  });

  test('allDependentIds incluye a los hijos FAILED', () async {
    await dao.enqueue(operation('parent'));
    await dao.enqueue(
      operation('failed').copyWith(dependsOn: const Value('parent')),
    );
    await dao.markFailed('failed', attempts: 1);

    expect(await dao.allDependentIds('parent'), ['failed']);
    expect(await dao.dependentIds('parent'), isEmpty);
  });

  test('discardUnlessSyncing borra todo o nada, y avisa al watch', () async {
    await dao.enqueue(operation('a'));
    await dao.enqueue(operation('b'));
    await dao.enqueue(operation('c'));
    final counts = <int>[];
    final subscription = dao.watchPendingCount('u1').listen(counts.add);
    addTearDown(subscription.cancel);
    await expectLater(dao.watchPendingCount('u1').first, completion(3));

    await dao.markSyncing('b');
    expect(await dao.discardUnlessSyncing(['a', 'b']), isFalse);
    expect(await dao.findById('a'), isNotNull);

    expect(await dao.discardUnlessSyncing(['a', 'c']), isTrue);
    expect(await dao.findById('a'), isNull);
    expect(await dao.findById('c'), isNull);
    expect(await dao.findById('b'), isNotNull);

    expect(await dao.discardUnlessSyncing(const []), isFalse);
    expect(await dao.discardUnlessSyncing(['missing']), isFalse);

    await expectLater(
      dao.watchPendingCount('u1').first,
      completion(0),
    );
    await pumpEventQueue();
    expect(counts.last, 0);
  });
}
