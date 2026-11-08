import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/local/voucher_table.dart';
import 'package:drift/drift.dart';

part 'voucher_dao.g.dart';

/// Caché `vouchers` (06 §4): cabeceras por orden, al abrir el cobro.
@DriftAccessor(tables: [Vouchers])
class VoucherDao extends DatabaseAccessor<AppDatabase> with _$VoucherDaoMixin {
  VoucherDao(super.attachedDatabase);

  Future<void> upsert(VoucherEntity row) {
    return into(vouchers).insertOnConflictUpdate(row.toCompanion(false));
  }

  /// Reemplaza las cabeceras de una orden; las de otras órdenes no se tocan.
  Future<void> replaceWorkOrder(String workOrderId, List<VoucherEntity> rows) {
    return transaction(() async {
      await (delete(
        vouchers,
      )..where((t) => t.workOrderId.equals(workOrderId))).go();
      for (final row in rows) {
        await upsert(row);
      }
    });
  }

  Stream<List<VoucherEntity>> watchByWorkOrder(String workOrderId) {
    return (select(vouchers)
          ..where((t) => t.workOrderId.equals(workOrderId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.serie),
            (t) => OrderingTerm.asc(t.number),
          ]))
        .watch();
  }
}
