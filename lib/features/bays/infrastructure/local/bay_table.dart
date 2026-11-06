import 'package:drift/drift.dart';

@DataClassName('BayEntity')
@TableIndex(name: 'idx_bays_branch_id', columns: {#branchId})
class Bays extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get name => text()();
  TextColumn get bayType => text()();  // LIFT | PAINT_BOOTH | WASHING | ALIGNMENT
  TextColumn get status => text()();  // AVAILABLE | OCCUPIED | MAINTENANCE
  TextColumn get currentWorkOrderId => text().nullable()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
