import 'package:drift/drift.dart';

@DataClassName('AttendanceEntity')
@TableIndex(name: 'idx_attendances_membership_id_clock_in', columns: {#membershipId, #clockIn})
class Attendances extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  TextColumn get membershipId => text()();
  TextColumn get shiftId => text()();
  IntColumn get clockIn => integer()();
  IntColumn get clockOut => integer().nullable()();
  TextColumn get status => text()();  // ON_TIME | LATE | EXCUSED | ABSENT
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get distanceToBranchMeters => real().named('distance_to_branch_m')();
  IntColumn get workedMinutes => integer().nullable()();
  IntColumn get regularMinutes => integer().nullable()();
  IntColumn get overtimeMinutes => integer().nullable()();
  TextColumn get justificationReason => text().nullable()();
  TextColumn get justificationStatus => text().nullable()();  // PENDING | APPROVED | REJECTED
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
