import 'package:drift/drift.dart';

@DataClassName('AppointmentEntity')
@TableIndex(name: 'idx_appointments_branch_id_scheduled_at', columns: {#branchId, #scheduledAt})
class Appointments extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get customerId => text()();
  TextColumn get vehicleId => text()();
  IntColumn get scheduledAt => integer()();
  IntColumn get estimatedDurationMinutes => integer().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get status => text()();  // PENDING | CONFIRMED | ARRIVED | CANCELED
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
