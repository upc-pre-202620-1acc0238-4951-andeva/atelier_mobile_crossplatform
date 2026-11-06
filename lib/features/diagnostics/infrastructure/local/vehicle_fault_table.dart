import 'package:drift/drift.dart';

@DataClassName('VehicleFaultEntity')
@TableIndex(name: 'idx_vehicle_faults_vehicle_id_dtc_code', columns: {#vehicleId, #dtcCode})
class VehicleFaults extends Table {
  TextColumn get id => text()();  // id del backend, o "local-{uuid}" si aún no se envió
  TextColumn get vehicleId => text()();
  TextColumn get dtcCode => text()();
  TextColumn get severity => text()();  // LOW | MEDIUM | CRITICAL
  TextColumn get description => text()();
  IntColumn get detectedAt => integer()();
  BoolColumn get isResolved => boolean()();
  IntColumn get resolvedAt => integer().nullable()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
