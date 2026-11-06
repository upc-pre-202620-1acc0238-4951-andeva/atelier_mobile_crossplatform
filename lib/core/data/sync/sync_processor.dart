import 'dart:async';
import 'dart:developer';
import 'dart:math' show min;

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/cross_isolate_lock.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_store.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';

enum SyncOutcome {
  completed,
  noSession,

  /// Otro motor está sincronizando.
  busy,
  unauthorized,

  /// Se acabó el tiempo, cambió el usuario o se perdió el bloqueo. Queda todo consistente.
  interrupted,
}

/// Algoritmo de docs/06-offline-sync.md §3, sin Flutter ni workmanager para poder probarlo.
/// Corre en la UI y en el worker; el bloqueo `sync` evita que los dos envíen a la vez.
class SyncProcessor {
  static const maxAttempts = 8;
  static const lease = Duration(minutes: 2);
  static const _heartbeat = Duration(seconds: 30);

  final PendingOperationDao dao;
  final SessionStore session;
  final CrossIsolateLock lock;
  final OperationHandlerRegistry handlers;
  final SyncScheduler scheduler;
  final String maxAttemptsMessage;
  final Future<String?> Function() ensureFreshToken;
  final DateTime Function() now;

  SyncProcessor({
    required this.dao,
    required this.session,
    required this.lock,
    required this.handlers,
    required this.scheduler,
    required this.maxAttemptsMessage,
    required this.ensureFreshToken,
    this.now = DateTime.now,
  });

  Future<SyncOutcome>? _inFlight;
  bool _rerun = false;

  /// El mismo dueño "renueva" el bloqueo, así que este no excluye dentro de un motor: sin este
  /// vuelo único, dos disparadores (encolar y volver la red) enviarían lo mismo dos veces.
  Future<SyncOutcome> run({Duration? budget}) {
    final current = _inFlight;
    if (current != null) {
      _rerun = true;
      return current;
    }
    return _inFlight = _runUntilSettled(
      budget,
    ).whenComplete(() => _inFlight = null);
  }

  /// Para los disparadores que no esperan el resultado.
  void runDetached() {
    unawaited(
      run().then<void>(
        (_) {},
        onError: (Object e) => log('Sync falló: $e', name: 'SyncProcessor'),
      ),
    );
  }

  static Duration backoff(int attempts) {
    return Duration(minutes: min(1 << min(attempts, 6), 60));
  }

  Future<SyncOutcome> _runUntilSettled(Duration? budget) async {
    while (true) {
      _rerun = false;
      final outcome = await _runOnce(budget);
      if (!_rerun || outcome != SyncOutcome.completed) return outcome;
    }
  }

  Future<SyncOutcome> _runOnce(Duration? budget) async {
    final userId = await session.getUserId();
    if (userId == null) return SyncOutcome.noSession;
    if (!await lock.tryAcquire(CrossIsolateLock.sync, lease)) {
      return SyncOutcome.busy;
    }

    // Una sola operación puede tardar 3 min (intento, refresh y reintento). El lease sigue corto
    // para que, si el sistema mata al motor, el otro no quede bloqueado mucho tiempo.
    final heartbeat = Timer.periodic(_heartbeat, (_) {
      unawaited(lock.tryAcquire(CrossIsolateLock.sync, lease));
    });
    final SyncOutcome outcome;
    try {
      outcome = await _process(userId, budget);
    } finally {
      heartbeat.cancel();
      await lock.release(CrossIsolateLock.sync);
    }

    if (outcome == SyncOutcome.completed) await _scheduleRetry(userId);
    return outcome;
  }

  Future<SyncOutcome> _process(String userId, Duration? budget) async {
    if (await ensureFreshToken() == null) return SyncOutcome.noSession;

    await dao.resetSyncing(userId);
    final start = now();
    final batch = await dao.nextBatch(userId, start.millisecondsSinceEpoch);
    for (final operation in batch) {
      if (budget != null && now().difference(start) > budget) {
        return SyncOutcome.interrupted;
      }
      // Nunca con el token de otro usuario: pudieron cerrar sesión a mitad de la vuelta.
      if (await session.getUserId() != userId) return SyncOutcome.interrupted;
      if (!await lock.tryAcquire(CrossIsolateLock.sync, lease)) {
        return SyncOutcome.interrupted;
      }

      // El lote es una foto: la UI pudo descartarla o una falla en cascada, marcarla.
      final latest = await dao.findById(operation.id);
      if (latest == null || latest.status != 'PENDING') continue;
      final parentId = operation.dependsOn;
      if (parentId != null && await dao.findById(parentId) != null) continue;
      final handler = handlers.find(operation.type);
      if (handler == null) continue; // Sin handler: queda PENDING, no se pierde.

      if (!await dao.markSyncing(operation.id)) continue;
      final OperationResult result;
      try {
        result = await handler.send(operation);
      } catch (e) {
        // También errores de tipo: un payload dañado no debe bloquear la cola para siempre.
        await _retry(operation, Retry(message: e.toString()));
        continue;
      }

      switch (result) {
        case Applied():
          await dao.deleteById(operation.id);
        case Unauthorized():
          await dao.markRetry(
            operation.id,
            attempts: operation.attempts,
            nextAttemptAt: operation.nextAttemptAt,
            httpStatus: 401,
          );
          return SyncOutcome.unauthorized;
        case Retry():
          await _retry(operation, result);
        case Failed():
          await _fail(
            operation.id,
            attempts: operation.attempts + 1,
            httpStatus: result.httpStatus,
            code: result.code,
            message: result.message,
          );
      }
    }
    return SyncOutcome.completed;
  }

  Future<void> _retry(PendingOperationEntity operation, Retry result) async {
    final attempts = operation.attempts + 1;
    if (attempts >= maxAttempts) {
      return _fail(
        operation.id,
        attempts: attempts,
        httpStatus: result.httpStatus,
        code: result.code,
        message: maxAttemptsMessage,
      );
    }
    await dao.markRetry(
      operation.id,
      attempts: attempts,
      nextAttemptAt: now().add(backoff(attempts)).millisecondsSinceEpoch,
      httpStatus: result.httpStatus,
      code: result.code,
      message: result.message,
    );
  }

  /// FAILED en cascada: lo que dependía de esta operación tampoco se podrá enviar.
  Future<void> _fail(
    String id, {
    required int attempts,
    int? httpStatus,
    String? code,
    String? message,
  }) async {
    await dao.markFailed(
      id,
      attempts: attempts,
      httpStatus: httpStatus,
      code: code,
      message: message,
    );
    final pending = await dao.dependentIds(id);
    while (pending.isNotEmpty) {
      final dependent = pending.removeLast();
      await dao.failAsDependent(dependent, code: code, message: message);
      pending.addAll(await dao.dependentIds(dependent));
    }
  }

  Future<void> _scheduleRetry(String userId) async {
    final next = await dao.nextAttemptAfter(
      userId,
      now().millisecondsSinceEpoch,
    );
    if (next == null) return;
    try {
      await scheduler.requestSyncAt(next, now());
    } on Exception catch (e) {
      log('No se pudo programar el reintento: $e', name: 'SyncProcessor');
    }
  }
}
