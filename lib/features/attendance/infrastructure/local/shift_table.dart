import 'package:drift/drift.dart';

@DataClassName('ShiftEntity')
class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get startTime => text()();  // "08:00:00" hora de Lima
  TextColumn get endTime => text()();
  IntColumn get gracePeriodMinutes => integer()();
  TextColumn get workDays => text()();  // "MONDAY,TUESDAY,…"
  TextColumn get restDays => text()();
  BoolColumn get isActive => boolean()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
