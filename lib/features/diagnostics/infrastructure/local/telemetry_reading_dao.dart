import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_table.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/telemetry_reading_table.dart';
import 'package:drift/drift.dart';

part 'telemetry_reading_dao.g.dart';

/// `telemetry_readings` no es caché sino captura (06 §6): cada fila espera su `TELEMETRY_BATCH`. Una lectura
/// está confirmada cuando su lote ya salió de `pending_operations`.
@DriftAccessor(tables: [TelemetryReadings, PendingOperations])
class TelemetryReadingDao extends DatabaseAccessor<AppDatabase>
    with _$TelemetryReadingDaoMixin {
  TelemetryReadingDao(super.attachedDatabase);

  /// Única por vehículo + `timestamp`: la misma muestra no se guarda dos veces. Devuelve si se guardó.
  Future<bool> insertReading(TelemetryReadingsCompanion reading) async {
    final inserted = await into(telemetryReadings).insertReturningOrNull(
      reading,
      mode: InsertMode.insertOrIgnore,
    );
    return inserted != null;
  }

  Future<List<String>> vehiclesWithUnbatched() {
    final query = selectOnly(telemetryReadings, distinct: true)
      ..addColumns([telemetryReadings.vehicleId])
      ..where(telemetryReadings.batchOperationId.isNull());
    return query.map((row) => row.read(telemetryReadings.vehicleId)!).get();
  }

  Future<List<TelemetryReadingEntity>> unbatched(String vehicleId, int limit) {
    return (select(telemetryReadings)
          ..where(
            (t) => t.vehicleId.equals(vehicleId) & t.batchOperationId.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)])
          ..limit(limit))
        .get();
  }

  Future<void> assignBatch(List<String> ids, String operationId) {
    return (update(telemetryReadings)..where((t) => t.id.isIn(ids))).write(
      TelemetryReadingsCompanion(batchOperationId: Value(operationId)),
    );
  }

  /// Lecturas del vehículo que aún no llegan al backend: sin lote o con el lote todavía en cola (US19 E1).
  Stream<int> watchPendingCount(String vehicleId) {
    return customSelect(
      'SELECT COUNT(*) AS pending FROM telemetry_readings WHERE vehicle_id = ? '
      'AND (batch_operation_id IS NULL '
      'OR batch_operation_id IN (SELECT id FROM pending_operations))',
      variables: [Variable.withString(vehicleId)],
      readsFrom: {telemetryReadings, pendingOperations},
    ).map((row) => row.read<int>('pending')).watchSingle();
  }

  /// Confirmadas (su lote ya no está en cola) y anteriores a [before]: el histórico lo tiene el backend.
  Future<int> purgeConfirmed(int before) {
    return customUpdate(
      'DELETE FROM telemetry_readings WHERE batch_operation_id IS NOT NULL '
      'AND batch_operation_id NOT IN (SELECT id FROM pending_operations) '
      'AND timestamp < ?',
      variables: [Variable.withInt(before)],
      updates: {telemetryReadings},
      updateKind: UpdateKind.delete,
    );
  }

  Future<List<TelemetryReadingEntity>> findForVehicle(String vehicleId) {
    return (select(telemetryReadings)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }
}
