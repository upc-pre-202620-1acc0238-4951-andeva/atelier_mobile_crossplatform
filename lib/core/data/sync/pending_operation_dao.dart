import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_table.dart';
import 'package:drift/drift.dart';

part 'pending_operation_dao.g.dart';

@DriftAccessor(tables: [PendingOperations])
class PendingOperationDao extends DatabaseAccessor<AppDatabase>
    with _$PendingOperationDaoMixin {
  PendingOperationDao(super.attachedDatabase);

  /// Respeta `dedupe_key`: devuelve false si el hecho ya estaba en la cola.
  Future<bool> enqueue(PendingOperationsCompanion operation) async {
    final inserted = await into(pendingOperations).insertReturningOrNull(
      operation,
      mode: InsertMode.insertOrIgnore,
    );
    return inserted != null;
  }

  Future<List<PendingOperationEntity>> nextBatch(String userId, int now) {
    return (select(pendingOperations)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals('PENDING') &
                t.nextAttemptAt.isSmallerOrEqualValue(now),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<PendingOperationEntity?> findById(String id) {
    return (select(
      pendingOperations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<PendingOperationEntity?> findByDedupeKey(String dedupeKey) {
    return (select(
      pendingOperations,
    )..where((t) => t.dedupeKey.equals(dedupeKey))).getSingleOrNull();
  }

  Future<List<PendingOperationEntity>> findForUserByType(
    String userId,
    String type,
  ) {
    return (select(pendingOperations)
          ..where((t) => t.userId.equals(userId) & t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Próximo intento futuro, para reprogramar el worker tras el backoff. Solo futuros: lo que
  /// espera a su padre o no tiene handler ya venció y reprogramaría el worker en bucle.
  Future<int?> nextAttemptAfter(String userId, int now) {
    final next = pendingOperations.nextAttemptAt.min();
    final query = selectOnly(pendingOperations)
      ..addColumns([next])
      ..where(
        pendingOperations.userId.equals(userId) &
            pendingOperations.status.equals('PENDING') &
            pendingOperations.nextAttemptAt.isBiggerThanValue(now),
      );
    return query.map((row) => row.read(next)).getSingle();
  }

  /// `false` si ya no estaba PENDING: la UI, en otra conexión, pudo descartarla tras la última lectura.
  Future<bool> markSyncing(String id) async {
    final updated =
        await (update(pendingOperations)..where(
              (t) => t.id.equals(id) & t.status.equals('PENDING'),
            ))
            .write(const PendingOperationsCompanion(status: Value('SYNCING')));
    return updated > 0;
  }

  Future<void> markRetry(
    String id, {
    required int attempts,
    required int nextAttemptAt,
    int? httpStatus,
    String? code,
    String? message,
  }) {
    return _update(
      id,
      PendingOperationsCompanion(
        status: const Value('PENDING'),
        attempts: Value(attempts),
        nextAttemptAt: Value(nextAttemptAt),
        lastHttpStatus: Value(httpStatus),
        lastErrorCode: Value(code),
        lastErrorMessage: Value(message),
      ),
    );
  }

  Future<void> markFailed(
    String id, {
    required int attempts,
    int? httpStatus,
    String? code,
    String? message,
  }) {
    return _update(
      id,
      PendingOperationsCompanion(
        status: const Value('FAILED'),
        attempts: Value(attempts),
        lastHttpStatus: Value(httpStatus),
        lastErrorCode: Value(code),
        lastErrorMessage: Value(message),
      ),
    );
  }

  /// Las que dependen de una operación fallida no deben esperar para siempre.
  Future<List<String>> dependentIds(String parentId) {
    final query = selectOnly(pendingOperations)
      ..addColumns([pendingOperations.id])
      ..where(
        pendingOperations.dependsOn.equals(parentId) &
            pendingOperations.status.equals('FAILED').not(),
      );
    return query.map((row) => row.read(pendingOperations.id)!).get();
  }

  Future<void> failAsDependent(String id, {String? code, String? message}) {
    return _update(
      id,
      PendingOperationsCompanion(
        status: const Value('FAILED'),
        lastErrorCode: Value(code),
        lastErrorMessage: Value(message),
      ),
    );
  }

  /// Lo que quedó en SYNCING si el motor murió a mitad del envío. Solo con el bloqueo `sync`.
  Future<void> resetSyncing(String userId) {
    return (update(pendingOperations)..where(
          (t) => t.userId.equals(userId) & t.status.equals('SYNCING'),
        ))
        .write(const PendingOperationsCompanion(status: Value('PENDING')));
  }

  /// Acción "Reintentar" con toda su cadena. Una sola sentencia: si el sync volviera a fallar al
  /// padre antes de reactivar al hijo, este quedaría PENDING esperando para siempre.
  Future<void> resetFailed(List<String> ids, int now) {
    return (update(pendingOperations)..where(
          (t) => t.id.isIn(ids) & t.status.equals('FAILED'),
        ))
        .write(
          PendingOperationsCompanion(
            status: const Value('PENDING'),
            attempts: const Value(0),
            nextAttemptAt: Value(now),
            lastHttpStatus: const Value(null),
            lastErrorCode: const Value(null),
            lastErrorMessage: const Value(null),
          ),
        );
  }

  /// Hijos directos en cualquier estado, a diferencia de [dependentIds].
  Future<List<String>> allDependentIds(String parentId) {
    final query = selectOnly(pendingOperations)
      ..addColumns([pendingOperations.id])
      ..where(pendingOperations.dependsOn.equals(parentId));
    return query.map((row) => row.read(pendingOperations.id)!).get();
  }

  /// Acción "Descartar" con toda su cadena. Una sola sentencia: el worker, en otra conexión, podría
  /// empezar a enviar entre comprobar y borrar. `false` si algo se está enviando: no borra nada.
  Future<bool> discardUnlessSyncing(List<String> ids) async {
    if (ids.isEmpty) return false;
    final marks = List.filled(ids.length, '?').join(', ');
    final variables = [for (final id in ids) Variable.withString(id)];
    final deleted = await customUpdate(
      'DELETE FROM pending_operations WHERE id IN ($marks) AND NOT EXISTS ('
      "SELECT 1 FROM pending_operations WHERE id IN ($marks) AND status = 'SYNCING')",
      variables: [...variables, ...variables],
      updates: {pendingOperations},
      updateKind: UpdateKind.delete,
    );
    return deleted > 0;
  }

  Future<void> deleteById(String id) {
    return (delete(pendingOperations)..where((t) => t.id.equals(id))).go();
  }

  /// Solo si el usuario elige descartar al cerrar sesión: la cola de otros nunca se borra.
  Future<void> deleteForUser(String userId) {
    return (delete(
      pendingOperations,
    )..where((t) => t.userId.equals(userId))).go();
  }

  Stream<int> watchPendingCount(String userId) {
    final count = pendingOperations.id.count();
    final query = selectOnly(pendingOperations)
      ..addColumns([count])
      ..where(
        pendingOperations.userId.equals(userId) &
            pendingOperations.status.isIn(['PENDING', 'FAILED']),
      );
    return query.map((row) => row.read(count)!).watchSingle();
  }

  Stream<List<PendingOperationEntity>> watchForUser(String userId) {
    return (select(pendingOperations)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Stream<List<PendingOperationEntity>> watchByTypeAndDedupePrefix(
    String type,
    String dedupePrefix,
  ) {
    return (select(pendingOperations)
          ..where(
            (t) =>
                t.type.equals(type) &
                t.dedupeKey.like('$dedupePrefix%'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> _update(String id, PendingOperationsCompanion changes) {
    return (update(
      pendingOperations,
    )..where((t) => t.id.equals(id))).write(changes);
  }
}
