import 'package:drift/drift.dart';

@DataClassName('TelemetryReadingEntity')
@TableIndex(name: 'idx_telemetry_readings_vehicle_id_timestamp', columns: {#vehicleId, #timestamp}, unique: true)
class TelemetryReadings extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  IntColumn get timestamp => integer()();  // momento de la lectura (UTC)
  RealColumn get engineTempCelsius => real()();  // obligatorio en el backend
  IntColumn get engineRpm => integer().nullable()();
  IntColumn get speedKmh => integer().nullable()();
  RealColumn get batteryVoltage => real().nullable()();
  RealColumn get fuelPercentage => real().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get batchOperationId => text().nullable()();  // id del TELEMETRY_BATCH que la lleva

  @override
  Set<Column<Object>> get primaryKey => {id};
}
