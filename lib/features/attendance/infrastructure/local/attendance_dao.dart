import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_table.dart';
import 'package:drift/drift.dart';

part 'attendance_dao.g.dart';

@DriftAccessor(tables: [Attendances])
class AttendanceDao extends DatabaseAccessor<AppDatabase>
    with _$AttendanceDaoMixin {
  AttendanceDao(super.attachedDatabase);

  Future<void> upsert(AttendanceEntity attendance) {
    // Con `toCompanion(false)` también se escriben los nulos: la entidad los omitiría y quedaría el valor viejo.
    return into(attendances).insertOnConflictUpdate(attendance.toCompanion(false));
  }

  /// Recarga completa del alcance: el backend no soporta deltas (06 §4).
  Future<void> replaceRange(
    String membershipId,
    int fromMillis,
    int toMillis,
    List<AttendanceEntity> rows,
  ) {
    return transaction(() async {
      await (delete(attendances)..where(
            (t) =>
                t.membershipId.equals(membershipId) &
                t.clockIn.isBiggerOrEqualValue(fromMillis) &
                t.clockIn.isSmallerThanValue(toMillis),
          ))
          .go();
      await batch(
        (b) => b.insertAllOnConflictUpdate(
          attendances,
          rows.map((row) => row.toCompanion(false)),
        ),
      );
    });
  }

  /// La jornada más reciente: abierta (aunque haya empezado ayer) o la última cerrada.
  Stream<AttendanceEntity?> watchLatest(String membershipId) {
    return (select(attendances)
          ..where((t) => t.membershipId.equals(membershipId))
          ..orderBy([(t) => OrderingTerm.desc(t.clockIn)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<AttendanceEntity?> findById(String id) {
    return (select(
      attendances,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<AttendanceEntity?> findOpen(String membershipId) {
    return (select(attendances)
          ..where(
            (t) => t.membershipId.equals(membershipId) & t.clockOut.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.clockIn)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<AttendanceEntity>> watchSince(
    String membershipId,
    int fromMillis,
  ) {
    return (select(attendances)
          ..where(
            (t) =>
                t.membershipId.equals(membershipId) &
                t.clockIn.isBiggerOrEqualValue(fromMillis),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.clockIn)]))
        .watch();
  }
}
