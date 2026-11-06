import 'package:drift/drift.dart';

@DataClassName('AppLockEntity')
class AppLocks extends Table {
  TextColumn get name => text()();
  TextColumn get owner => text()();
  IntColumn get expiresAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}
