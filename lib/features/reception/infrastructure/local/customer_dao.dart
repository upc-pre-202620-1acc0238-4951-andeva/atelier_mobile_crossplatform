import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_table.dart';
import 'package:drift/drift.dart';

part 'customer_dao.g.dart';

/// Caché `customers` (06 §4, clientes vistos o buscados · 7 días).
@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.attachedDatabase);

  Future<void> upsert(CustomerEntity customer) {
    return into(customers).insertOnConflictUpdate(customer.toCompanion(false));
  }

  Future<CustomerEntity?> findById(String id) {
    return (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<CustomerEntity?> watchById(String id) {
    return (select(
      customers,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Búsqueda sin red: documento al inicio o parte del nombre.
  Future<List<CustomerEntity>> search(String query) {
    return (select(customers)
          ..where(
            (t) => t.taxId.like('$query%') | t.displayName.like('%$query%'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
          ..limit(50))
        .get();
  }
}
