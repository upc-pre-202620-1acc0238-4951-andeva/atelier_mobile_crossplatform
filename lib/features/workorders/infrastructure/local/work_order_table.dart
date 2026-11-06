import 'package:drift/drift.dart';

@DataClassName('WorkOrderEntity')
@TableIndex(name: 'idx_work_orders_branch_id_status', columns: {#branchId, #status})
class WorkOrders extends Table {
  TextColumn get id => text()();
  IntColumn get internalNumber => integer().nullable()();
  TextColumn get branchId => text()();
  TextColumn get vehicleId => text()();  // placa y modelo: tabla vehicles
  TextColumn get customerId => text()();  // nombre: tabla customers
  TextColumn get currentBayId => text().nullable()();
  TextColumn get bayName => text().nullable()();
  TextColumn get status => text()();  // DRAFT | IN_PROGRESS | COMPLETED | PAID | CANCELED
  TextColumn get diagnosticSummary => text().nullable()();
  IntColumn get mileageIn => integer().nullable()();
  TextColumn get subtotal => text().nullable()();
  TextColumn get taxAmount => text().nullable()();
  TextColumn get totalAmount => text()();
  TextColumn get currency => text()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
