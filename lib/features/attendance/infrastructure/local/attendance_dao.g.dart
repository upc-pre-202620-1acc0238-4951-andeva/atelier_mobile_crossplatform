// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_dao.dart';

// ignore_for_file: type=lint
mixin _$AttendanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $AttendancesTable get attendances => attachedDatabase.attendances;
  AttendanceDaoManager get managers => AttendanceDaoManager(this);
}

class AttendanceDaoManager {
  final _$AttendanceDaoMixin _db;
  AttendanceDaoManager(this._db);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db.attachedDatabase, _db.attendances);
}
