import 'package:drift/drift.dart';

@DataClassName('VehicleEntity')
@TableIndex(name: 'idx_vehicles_plate', columns: {#plate}, unique: true)
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get plate => text()();
  TextColumn get vin => text().nullable()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  IntColumn get year => integer().nullable()();
  TextColumn get engineType => text().nullable()();
  TextColumn get currentOwnerId => text().nullable()();
  IntColumn get currentMileage => integer().nullable()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
