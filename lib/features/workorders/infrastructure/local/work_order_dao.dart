import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_table.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_table.dart';
import 'package:drift/drift.dart';

part 'work_order_dao.g.dart';

/// Una fila de `work_orders` con la placa y el nombre del cliente, si ya están en caché.
class WorkOrderWithRefs {
  final WorkOrderEntity workOrder;
  final String? plate;
  final String? customerName;

  const WorkOrderWithRefs({
    required this.workOrder,
    this.plate,
    this.customerName,
  });
}

/// Caché `work_orders` (06 §4, órdenes no cerradas de la sede · 5 min).
@DriftAccessor(tables: [WorkOrders, Vehicles, Customers])
class WorkOrderDao extends DatabaseAccessor<AppDatabase>
    with _$WorkOrderDaoMixin {
  WorkOrderDao(super.attachedDatabase);

  Future<WorkOrderEntity?> findById(String id) {
    return (select(
      workOrders,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteById(String id) {
    return (delete(workOrders)..where((t) => t.id.equals(id))).go();
  }

  /// Recarga completa del alcance `work_orders:{branchId}`. La lista no trae subtotal, IGV,
  /// kilometraje ni diagnóstico: se conservan los que ya vinieron con el detalle.
  Future<void> replaceBranch(String branchId, List<WorkOrderEntity> rows) {
    return transaction(() async {
      final previous = {
        for (final row in await (select(
          workOrders,
        )..where((t) => t.branchId.equals(branchId))).get())
          row.id: row,
      };
      await (delete(
        workOrders,
      )..where((t) => t.branchId.equals(branchId))).go();
      for (final row in rows) {
        await _upsert(_keepDetail(row, previous[row.id]));
      }
    });
  }

  /// Cabecera que devolvió una acción o el detalle; lo que no trae se conserva de la fila guardada.
  Future<void> saveHeader(WorkOrderEntity row) {
    return transaction(() async {
      await _upsert(_keepDetail(row, await findById(row.id)));
    });
  }

  Stream<WorkOrderWithRefs?> watchById(String id) {
    return _joined(workOrders.id.equals(id)).map(_toRefs).watchSingleOrNull();
  }

  Stream<List<WorkOrderWithRefs>> watchBranch(String branchId) {
    final query = _joined(workOrders.branchId.equals(branchId))
      ..orderBy([OrderingTerm.desc(workOrders.internalNumber)]);
    return query.map(_toRefs).watch();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _joined(Expression<bool> where) {
    return select(workOrders).join([
      leftOuterJoin(vehicles, vehicles.id.equalsExp(workOrders.vehicleId)),
      leftOuterJoin(customers, customers.id.equalsExp(workOrders.customerId)),
    ])..where(where);
  }

  WorkOrderWithRefs _toRefs(TypedResult row) {
    return WorkOrderWithRefs(
      workOrder: row.readTable(workOrders),
      plate: row.readTableOrNull(vehicles)?.plate,
      customerName: row.readTableOrNull(customers)?.displayName,
    );
  }

  Future<void> _upsert(WorkOrderEntity row) {
    return into(workOrders).insertOnConflictUpdate(row.toCompanion(false));
  }

  WorkOrderEntity _keepDetail(WorkOrderEntity row, WorkOrderEntity? previous) {
    if (previous == null) return row;
    final sameTotal = row.totalAmount == previous.totalAmount;
    return row.copyWith(
      internalNumber: Value(row.internalNumber ?? previous.internalNumber),
      bayName: Value(
        row.bayName ??
            (row.currentBayId == previous.currentBayId
                ? previous.bayName
                : null),
      ),
      diagnosticSummary: Value(
        row.diagnosticSummary ?? previous.diagnosticSummary,
      ),
      mileageIn: Value(row.mileageIn ?? previous.mileageIn),
      // Con otro total, el subtotal y el IGV guardados ya no le corresponden.
      subtotal: Value(row.subtotal ?? (sameTotal ? previous.subtotal : null)),
      taxAmount: Value(
        row.taxAmount ?? (sameTotal ? previous.taxAmount : null),
      ),
    );
  }
}
