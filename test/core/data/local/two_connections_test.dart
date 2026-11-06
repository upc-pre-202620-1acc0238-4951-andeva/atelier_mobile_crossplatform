import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/cross_isolate_lock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que no existe en Android: dos conexiones independientes sobre un mismo archivo,
/// como la UI y el worker de workmanager.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory directory;
  late AppDatabase first;
  late AppDatabase second;

  AppDatabase open(File file) => AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: AppDatabase.configureConnection,
    ),
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('atelier_two_');
    final file = File('${directory.path}/atelier_db.sqlite');
    first = open(file);
    await first.customSelect('SELECT 1').get(); // Migra antes de abrir la segunda.
    second = open(file);
  });

  tearDown(() async {
    await first.close();
    await second.close();
    await directory.delete(recursive: true);
  });

  PendingOperationsCompanion operation(String id) {
    return PendingOperationsCompanion.insert(
      id: id,
      type: 'PROBE',
      payload: '{}',
      dedupeKey: id,
      userId: 'u1',
      tenantId: 't1',
      nextAttemptAt: 0,
      createdAt: 0,
    );
  }

  test('la conexión queda en WAL y con busy_timeout', () async {
    final mode = await second.customSelect('PRAGMA journal_mode').getSingle();
    final timeout = await second.customSelect('PRAGMA busy_timeout').getSingle();
    expect(mode.read<String>('journal_mode'), 'wal');
    expect(timeout.read<int>('timeout'), 5000);
  });

  test('dos escritores concurrentes no fallan con database is locked', () async {
    Future<void> write(AppDatabase database, String prefix) async {
      for (var i = 0; i < 200; i++) {
        await database.pendingOperationDao.enqueue(operation('$prefix$i'));
      }
    }

    await Future.wait([write(first, 'a'), write(second, 'b')]);

    final rows = await first.select(first.pendingOperations).get();
    expect(rows, hasLength(400));
  });

  test('de muchos intentos simultáneos gana un solo dueño', () async {
    final a = CrossIsolateLock(database: first);
    final b = CrossIsolateLock(database: second);
    for (var round = 0; round < 50; round++) {
      final results = await Future.wait([
        a.tryAcquire('race', const Duration(minutes: 1)),
        b.tryAcquire('race', const Duration(minutes: 1)),
      ]);
      expect(results.where((won) => won), hasLength(1), reason: 'ronda $round');
      await a.release('race');
      await b.release('race');
    }
  });

  test('el bloqueo se libera, se renueva y vence', () async {
    final a = CrossIsolateLock(database: first);
    final b = CrossIsolateLock(database: second);

    expect(await a.tryAcquire('x', const Duration(minutes: 1)), isTrue);
    expect(await b.tryAcquire('x', const Duration(minutes: 1)), isFalse);
    expect(await a.tryAcquire('x', const Duration(minutes: 1)), isTrue);

    await b.release('x'); // Quien no es dueño no lo libera.
    expect(await b.tryAcquire('x', const Duration(minutes: 1)), isFalse);

    await a.release('x');
    expect(await b.tryAcquire('x', const Duration(milliseconds: 1)), isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(await a.tryAcquire('x', const Duration(minutes: 1)), isTrue);
  });

  test('notifyExternalChanges despierta los watch del otro motor', () async {
    final seen = <int>[];
    final subscription = first.pendingOperationDao
        .watchPendingCount('u1')
        .listen(seen.add);
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(seen.last, 0);

    await second.pendingOperationDao.enqueue(operation('w'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(seen.last, 0, reason: 'sin aviso el otro motor no se entera');

    first.notifyExternalChanges();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(seen.last, 1);
    await subscription.cancel();
  });
}
