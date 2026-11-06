import 'package:drift/drift.dart';

@DataClassName('TaskEntity')
@TableIndex(name: 'idx_tasks_work_order_id', columns: {#workOrderId})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text()();
  IntColumn get workOrderNumber => integer().nullable()();
  TextColumn get workOrderStatus => text().nullable()();
  TextColumn get vehicleId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get bayId => text().nullable()();
  TextColumn get serviceName => text().nullable()();  // del detalle
  TextColumn get mechanicId => text().nullable()();
  TextColumn get status => text()();  // ASSIGNED | IN_PROGRESS | ON_HOLD | COMPLETED | …
  TextColumn get description => text()();
  TextColumn get estimatedHours => text().nullable()();
  TextColumn get holdReason => text().nullable()();  // BREAK | END_OF_SHIFT | DEFECTIVE_PART | …
  TextColumn get missingItemDescription => text().nullable()();
  TextColumn get pendingSuspensionReason => text().nullable()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get totalPausedSeconds => integer()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
