import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/batch_table.dart';
import 'package:drift/drift.dart';

part 'batch_dao.g.dart';

/// Caché `batches` por repuesto (06 §4, 1 h). Solo se llena con `inventory:batches:read`.
@DriftAccessor(tables: [Batches])
class BatchDao extends DatabaseAccessor<AppDatabase> with _$BatchDaoMixin {
  BatchDao(super.attachedDatabase);

  /// Recarga completa del alcance `batches:{itemId}`.
  Future<void> replaceForItem(String itemId, List<BatchEntity> rows) {
    return transaction(() async {
      await (delete(batches)..where((t) => t.itemId.equals(itemId))).go();
      await batch((b) => b.insertAllOnConflictUpdate(batches, rows));
    });
  }

  /// Orden FIFO (el más antiguo primero): el backend los manda del más nuevo al más viejo.
  Future<List<BatchEntity>> findForItem(String itemId) => _forItem(itemId).get();

  Stream<List<BatchEntity>> watchForItem(String itemId) {
    return _forItem(itemId).watch();
  }

  SimpleSelectStatement<$BatchesTable, BatchEntity> _forItem(String itemId) {
    return select(batches)
      ..where((t) => t.itemId.equals(itemId))
      ..orderBy([(t) => OrderingTerm.asc(t.arrivalDate)]);
  }
}
