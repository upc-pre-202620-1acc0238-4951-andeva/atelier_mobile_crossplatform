import 'package:drift/drift.dart';

@DataClassName('PredictiveAlertEntity')
@TableIndex(name: 'idx_predictive_alerts_vehicle_id_created_at', columns: {#vehicleId, #createdAt})
class PredictiveAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  TextColumn get alertType => text()();  // ENGINE_OVERHEATING_RISK | BATTERY_FAILURE_RISK | …
  RealColumn get confidenceScore => real()();
  TextColumn get message => text()();
  TextColumn get status => text()();  // DISPATCHED | ACKNOWLEDGED | RESOLVED | DISMISSED
  IntColumn get createdAt => integer()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
