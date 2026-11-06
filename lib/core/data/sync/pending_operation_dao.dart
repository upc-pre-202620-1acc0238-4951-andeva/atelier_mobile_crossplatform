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

  Future<void> markSyncing(String id) => _update(
    id,
    const PendingOperationsCompanion(status: Value('SYNCING')),
  );

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

  /// Acción "Reintentar" de la pantalla de pendientes.
  Future<void> retry(String id, int now) {
    return _update(
      id,
      PendingOperationsCompanion(
        status: const Value('PENDING'),
        attempts: const Value(0),
        nextAttemptAt: Value(now),
      ),
    );
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

  Future<void> _update(String id, PendingOperationsCompanion changes) {
    return (update(
      pendingOperations,
    )..where((t) => t.id.equals(id))).write(changes);
  }
}
