import 'dart:convert';
import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Punto único para encolar lo que se captura sin red.
class PendingOperationQueue {
  final PendingOperationDao dao;
  final SessionManager session;
  final SyncProcessor processor;
  final SyncScheduler scheduler;
  final DateTime Function() now;

  PendingOperationQueue({
    required this.dao,
    required this.session,
    required this.processor,
    required this.scheduler,
    this.now = DateTime.now,
  });

  /// Encola [payload] (el body exacto a enviar, ya con la hora del dispositivo) y dispara el
  /// sync, salvo con [dispatch] en `false` (la siguiente de una cadena lo hará). Devuelve el id de
  /// la operación, o `null` si el hecho ya estaba en cola.
  Future<String?> enqueue({
    required String type,
    required Object payload,
    required String dedupeKey,
    String? dependsOn,
    String? id,
    bool dispatch = true,
  }) async {
    final current = await session.getSession();
    if (current == null) throw StateError('No se puede encolar sin sesión');

    final operationId = id ?? const Uuid().v4();
    final millis = now().millisecondsSinceEpoch;
    final inserted = await dao.enqueue(
      PendingOperationsCompanion.insert(
        id: operationId,
        type: type,
        payload: jsonEncode(payload),
        dedupeKey: dedupeKey,
        userId: current.userId,
        tenantId: current.tenantId,
        nextAttemptAt: millis,
        createdAt: millis,
        dependsOn: Value(dependsOn),
      ),
    );
    if (!inserted) return null;
    if (!dispatch) return operationId;

    processor.runDetached();
    try {
      await scheduler.requestSync();
    } on Exception catch (e) {
      // Ya quedó guardada: un fallo al programar no debe parecer que se perdió.
      log('No se pudo programar el sync: $e', name: 'PendingOperationQueue');
    }
    return operationId;
  }
}
