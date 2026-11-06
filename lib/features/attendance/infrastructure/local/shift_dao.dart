import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/shift_table.dart';
import 'package:drift/drift.dart';

part 'shift_dao.g.dart';

@DriftAccessor(tables: [Shifts])
class ShiftDao extends DatabaseAccessor<AppDatabase> with _$ShiftDaoMixin {
  ShiftDao(super.attachedDatabase);

  Future<void> upsert(ShiftEntity shift) {
    return into(shifts).insertOnConflictUpdate(shift.toCompanion(false));
  }

  Stream<ShiftEntity?> watchById(String id) {
    return (select(
      shifts,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }
}
