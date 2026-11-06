import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/cross_isolate_lock.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:mocktail/mocktail.dart';

import '../../support/fake_session_store.dart';

class _MockScheduler extends Mock implements SyncScheduler {}

class _Handler implements OperationHandler {
  final Future<OperationResult> Function(PendingOperationEntity operation) onSend;
  final sent = <String>[];

  _Handler(this.onSend);

  @override
  Future<OperationResult> send(PendingOperationEntity operation) {
    sent.add(operation.id);
    return onSend(operation);
  }
}

ApiException _api(int status) =>
    ApiException(httpStatus: status, code: 'CODE', message: 'Mensaje $status');

void main() {
  late AppDatabase database;
  late PendingOperationDao dao;
  late CrossIsolateLock lock;
  late FakeSessionStore session;
  late OperationHandlerRegistry registry;
  late _MockScheduler scheduler;
  late SyncProcessor processor;
  final clock = DateTime.utc(2026, 11, 5);
  final nowMillis = clock.millisecondsSinceEpoch;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.pendingOperationDao;
    lock = CrossIsolateLock(database: database);
    session = FakeSessionStore();
    registry = OperationHandlerRegistry();
    scheduler = _MockScheduler();
    when(
      () => scheduler.requestSyncAt(any(), any()),
    ).thenAnswer((_) async {});
    processor = SyncProcessor(
      dao: dao,
      session: session,
      lock: lock,
      handlers: registry,
      scheduler: scheduler,
      maxAttemptsMessage: 'No se pudo sincronizar',
      ensureFreshToken: session.getAuthToken,
      now: () => clock,
    );
  });
  tearDown(() => database.close());

  Future<void> enqueue(
    String id, {
    String type = 'PROBE',
    String? dependsOn,
    String userId = 'u1',
    int attempts = 0,
    int createdAt = 0,
  }) {
    return dao.enqueue(
      PendingOperationsCompanion.insert(
        id: id,
        type: type,
        payload: '{}',
        dedupeKey: id,
        userId: userId,
        tenantId: 't1',
        attempts: Value(attempts),
        nextAttemptAt: 0,
        createdAt: createdAt,
        dependsOn: Value(dependsOn),
      ),
    );
  }

  _Handler handle(Future<OperationResult> Function(PendingOperationEntity) f) {
    final handler = _Handler(f);
    registry.register('PROBE', () => handler);
    return handler;
  }

  _Handler respond(Future<void> Function() call, {int? alreadyApplied}) {
    return handle(
      (_) => OperationResult.from(
        call,
        alreadyApplied: alreadyApplied == null
            ? null
            : (e) => e.httpStatus == alreadyApplied,
      ),
    );
  }

  test('2xx borra la operación', () async {
    respond(() async {});
    await enqueue('a');
    expect(await processor.run(), SyncOutcome.completed);
    expect(await dao.findById('a'), isNull);
  });

  test('409 "ya aplicada" se considera éxito', () async {
    respond(() async => throw _api(409), alreadyApplied: 409);
    await enqueue('a');
    await processor.run();
    expect(await dao.findById('a'), isNull);
  });

  test('422 de regla de negocio queda FAILED con el message', () async {
    respond(() async => throw _api(422));
    await enqueue('a');
    await processor.run();
    final row = (await dao.findById('a'))!;
    expect(row.status, 'FAILED');
    expect(row.lastHttpStatus, 422);
    expect(row.lastErrorCode, 'CODE');
    expect(row.lastErrorMessage, 'Mensaje 422');
  });

  test('5xx, 408, 429 y sin red reintentan con backoff', () async {
    for (final error in <Exception>[
      _api(500),
      _api(408),
      _api(429),
      const NetworkException(),
    ]) {
      respond(() async => throw error);
      await enqueue('a');
      await processor.run();
      final row = (await dao.findById('a'))!;
      expect(row.status, 'PENDING');
      expect(row.attempts, 1);
      expect(row.nextAttemptAt, nowMillis + const Duration(minutes: 2).inMilliseconds);
      await dao.deleteById('a');
    }
  });

  test('backoff de min(2^intentos, 60) minutos', () {
    expect(SyncProcessor.backoff(1), const Duration(minutes: 2));
    expect(SyncProcessor.backoff(5), const Duration(minutes: 32));
    expect(SyncProcessor.backoff(6), const Duration(minutes: 60));
    expect(SyncProcessor.backoff(7), const Duration(minutes: 60));
  });

  test('tras un reintento programa el worker para cuando toque', () async {
    respond(() async => throw _api(500));
    await enqueue('a');
    await processor.run();
    verify(
      () => scheduler.requestSyncAt(
        nowMillis + const Duration(minutes: 2).inMilliseconds,
        clock,
      ),
    ).called(1);
  });

  test('sin intentos futuros no reprograma: evita el bucle del worker', () async {
    await enqueue('sin-handler', type: 'DESCONOCIDO');
    await processor.run();
    verifyNever(() => scheduler.requestSyncAt(any(), any()));
  });

  test('al octavo intento queda FAILED con el mensaje genérico', () async {
    respond(() async => throw _api(500));
    await enqueue('a', attempts: 7);
    await processor.run();
    final row = (await dao.findById('a'))!;
    expect(row.status, 'FAILED');
    expect(row.attempts, 8);
    expect(row.lastErrorMessage, 'No se pudo sincronizar');
  });

  test('espera a la operación de la que depende y la envía después', () async {
    final handler = respond(() async {});
    await enqueue('parent', createdAt: 1);
    await enqueue('child', dependsOn: 'parent', createdAt: 2);
    await processor.run();
    expect(handler.sent, ['parent', 'child']);
    expect(await database.select(database.pendingOperations).get(), isEmpty);
  });

  test('no envía la dependiente si el padre sigue pendiente', () async {
    final handler = handle(
      (op) async => op.id == 'parent'
          ? const Retry(httpStatus: 500)
          : const Applied(),
    );
    await enqueue('parent', createdAt: 1);
    await enqueue('child', dependsOn: 'parent', createdAt: 2);
    await processor.run();
    expect(handler.sent, ['parent']);
    expect((await dao.findById('child'))!.status, 'PENDING');
  });

  test('FAILED en cascada a toda la cadena de dependientes', () async {
    respond(() async => throw _api(422));
    await enqueue('a', createdAt: 1);
    await enqueue('b', dependsOn: 'a', createdAt: 2);
    await enqueue('c', dependsOn: 'b', createdAt: 3);
    await processor.run();
    for (final id in ['a', 'b', 'c']) {
      final row = (await dao.findById(id))!;
      expect(row.status, 'FAILED', reason: id);
      expect(row.lastErrorMessage, 'Mensaje 422', reason: id);
    }
  });

  test('lo encolado sobre un padre ya FAILED falla con su mensaje', () async {
    final handler = respond(() async => throw _api(422));
    await enqueue('a', createdAt: 1);
    await processor.run();

    await enqueue('b', dependsOn: 'a', createdAt: 2);
    await enqueue('c', dependsOn: 'b', createdAt: 3);
    await processor.run();

    expect(handler.sent, ['a']);
    for (final id in ['b', 'c']) {
      final row = (await dao.findById(id))!;
      expect(row.status, 'FAILED', reason: id);
      expect(row.lastErrorMessage, 'Mensaje 422', reason: id);
    }
  });

  test('401 deja la operación pendiente y detiene la vuelta', () async {
    final handler = respond(() async => throw _api(401));
    await enqueue('a', createdAt: 1);
    await enqueue('b', createdAt: 2);
    expect(await processor.run(), SyncOutcome.unauthorized);
    expect(handler.sent, ['a']);
    final row = (await dao.findById('a'))!;
    expect(row.status, 'PENDING');
    expect(row.attempts, 0);
    expect(row.lastHttpStatus, 401);
  });

  test('solo envía la cola del usuario actual; sin handler queda PENDING', () async {
    final handler = respond(() async {});
    await enqueue('mine');
    await enqueue('other', userId: 'u2');
    await enqueue('unknown', type: 'DESCONOCIDO');
    await processor.run();
    expect(handler.sent, ['mine']);
    expect((await dao.findById('other'))!.status, 'PENDING');
    expect((await dao.findById('unknown'))!.status, 'PENDING');
  });

  test('una excepción o un payload dañado se reintentan', () async {
    handle((_) async => throw StateError('payload dañado'));
    await enqueue('a');
    expect(await processor.run(), SyncOutcome.completed);
    final row = (await dao.findById('a'))!;
    expect(row.status, 'PENDING');
    expect(row.attempts, 1);
  });

  test('sin sesión no hace nada y conserva la cola', () async {
    final handler = respond(() async {});
    await enqueue('a');
    session.userId = null;
    expect(await processor.run(), SyncOutcome.noSession);
    expect(handler.sent, isEmpty);
    expect(await dao.findById('a'), isNotNull);
  });

  test('sin token renovable no envía nada', () async {
    final handler = respond(() async {});
    await enqueue('a');
    session.token = null;
    expect(await processor.run(), SyncOutcome.noSession);
    expect(handler.sent, isEmpty);
  });

  test('si otro motor tiene el bloqueo termina sin tocar nada', () async {
    final handler = respond(() async {});
    await enqueue('a');
    await dao.markSyncing('a');
    final other = CrossIsolateLock(database: database);
    await other.tryAcquire(CrossIsolateLock.sync, SyncProcessor.lease);

    expect(await processor.run(), SyncOutcome.busy);

    expect(handler.sent, isEmpty);
    expect((await dao.findById('a'))!.status, 'SYNCING');
    expect(
      await other.tryAcquire(CrossIsolateLock.sync, SyncProcessor.lease),
      isTrue,
      reason: 'no liberó un bloqueo ajeno',
    );
  });

  test('devuelve a PENDING lo que quedó en SYNCING y libera el bloqueo', () async {
    final handler = respond(() async {});
    await enqueue('a');
    await dao.markSyncing('a');
    await processor.run();
    expect(handler.sent, ['a']);
    final other = CrossIsolateLock(database: database);
    expect(
      await other.tryAcquire(CrossIsolateLock.sync, SyncProcessor.lease),
      isTrue,
    );
  });

  test('dos disparadores en el mismo motor no envían dos veces', () async {
    final gate = Completer<OperationResult>();
    final handler = handle((_) => gate.future);
    await enqueue('a');

    final first = processor.run();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final second = processor.run();
    gate.complete(const Applied());
    await Future.wait([first, second]);

    expect(handler.sent, ['a']);
  });

  test('lo encolado durante una vuelta sale en la vuelta siguiente', () async {
    final gate = Completer<void>();
    var calls = 0;
    final handler = handle((_) async {
      if (calls++ == 0) await gate.future;
      return const Applied();
    });
    await enqueue('a', createdAt: 1);

    final running = processor.run();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await enqueue('b', createdAt: 2);
    final again = processor.run();
    gate.complete();
    await Future.wait([running, again]);

    expect(handler.sent, ['a', 'b']);
  });

  test('si cierran sesión a mitad de la vuelta no sigue enviando', () async {
    final handler = handle((_) async {
      session.userId = 'u2';
      return const Applied();
    });
    await enqueue('a', createdAt: 1);
    await enqueue('b', createdAt: 2);

    expect(await processor.run(), SyncOutcome.interrupted);

    expect(handler.sent, ['a']);
    expect((await dao.findById('b'))!.status, 'PENDING');
  });

  test('no envía lo que la UI descartó después de armar el lote', () async {
    final handler = handle((op) async {
      if (op.id == 'a') await dao.deleteById('b');
      return const Applied();
    });
    await enqueue('a', createdAt: 1);
    await enqueue('b', createdAt: 2);
    await processor.run();
    expect(handler.sent, ['a']);
  });

  test('al agotar el tiempo se detiene y lo demás sigue PENDING', () async {
    var current = clock;
    final limited = SyncProcessor(
      dao: dao,
      session: session,
      lock: lock,
      handlers: registry,
      scheduler: scheduler,
      maxAttemptsMessage: 'x',
      ensureFreshToken: session.getAuthToken,
      now: () => current,
    );
    final handler = handle((_) async {
      current = current.add(const Duration(seconds: 30));
      return const Applied();
    });
    await enqueue('a', createdAt: 1);
    await enqueue('b', createdAt: 2);

    final outcome = await limited.run(budget: const Duration(seconds: 25));

    expect(outcome, SyncOutcome.interrupted);
    expect(handler.sent, ['a']);
    expect((await dao.findById('b'))!.status, 'PENDING');
  });

  test('no envía lo que la UI descartó justo antes de marcarlo', () async {
    final racing = _DiscardingDao(database);
    final raced = SyncProcessor(
      dao: racing,
      session: session,
      lock: lock,
      handlers: registry,
      scheduler: scheduler,
      maxAttemptsMessage: 'No se pudo sincronizar',
      ensureFreshToken: session.getAuthToken,
      now: () => clock,
    );
    final handler = handle((_) async => const Applied());
    await enqueue('a');

    expect(await raced.run(), SyncOutcome.completed);

    expect(handler.sent, isEmpty);
    expect(await dao.findById('a'), isNull);
  });
}

/// La UI, en otra conexión, descarta entre la última lectura y el marcado.
class _DiscardingDao extends PendingOperationDao {
  _DiscardingDao(super.attachedDatabase);

  @override
  Future<bool> markSyncing(String id) async {
    await deleteById(id);
    return super.markSyncing(id);
  }
}
