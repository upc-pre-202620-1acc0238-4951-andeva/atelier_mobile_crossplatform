import 'package:drift/drift.dart';

@DataClassName('BranchEntity')
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get geofenceRadiusMeters => real().named('geofence_radius_m')();
  BoolColumn get isActive => boolean()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
