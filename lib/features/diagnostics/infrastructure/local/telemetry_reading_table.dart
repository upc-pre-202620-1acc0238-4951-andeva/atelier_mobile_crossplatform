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
  // Técnico que capturó la lectura (US19): en un terminal compartido no se envía bajo la sesión de otro.
  // Nulo en filas anteriores a la v3: las envía quien esté con sesión.
  TextColumn get userId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
