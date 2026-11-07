import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/part_table.dart';
import 'package:drift/drift.dart';

part 'part_dao.g.dart';

/// Caché `parts` (06 §4, catálogo · 1 h). Montos y cantidades se guardan como texto decimal: el stock
/// se compara con `CAST` para no comparar texto (`"10" <= "9"`).
@DriftAccessor(tables: [Parts])
class PartDao extends DatabaseAccessor<AppDatabase> with _$PartDaoMixin {
  PartDao(super.attachedDatabase);

  Future<void> upsertAll(List<PartEntity> rows) {
    return batch((b) => b.insertAllOnConflictUpdate(parts, rows));
  }

  /// Recarga completa del alcance `parts:catalog`: solo cuando llegaron todas las páginas.
  Future<void> replaceAll(List<PartEntity> rows) {
    return transaction(() async {
      await delete(parts).go();
      await upsertAll(rows);
    });
  }

  Future<PartEntity?> findById(String id) {
    return (select(parts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<PartEntity?> watchById(String id) {
    return (select(parts)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// El índice de `sku` no es único y `getSingleOrNull` lanza con dos filas.
  Future<PartEntity?> findBySku(String sku) {
    return (select(parts)
          ..where((t) => t.sku.equals(sku))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<PartEntity>> watchAll({String? category}) {
    final query = select(parts)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (category != null) query.where((t) => t.category.equals(category));
    return query.watch();
  }

  /// Búsqueda sin red, como la del backend: nombre o SKU, sin distinguir mayúsculas.
  /// shortcut: `%` y `_` actúan como comodines y `LIKE` solo ignora mayúsculas en ASCII; solo da
  /// resultados de más. Escapar si alguien lo reporta.
  Future<List<PartEntity>> search(String text, {String? category}) {
    final pattern = '%$text%';
    final query = select(parts)
      ..where((t) => t.name.like(pattern) | t.sku.like(pattern))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
      ..limit(100);
    if (category != null) query.where((t) => t.category.equals(category));
    return query.get();
  }

  /// La misma regla de `GET /inventory/alerts` (H13): stock en el mínimo o debajo.
  Future<List<PartEntity>> findLowStock() => _lowStock().get();

  Stream<List<PartEntity>> watchLowStock() => _lowStock().watch();

  SimpleSelectStatement<$PartsTable, PartEntity> _lowStock() {
    return select(parts)
      ..where(
        (t) => t.totalStock.cast<double>().isSmallerOrEqual(
          t.minimumStock.cast<double>(),
        ),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
  }
}
