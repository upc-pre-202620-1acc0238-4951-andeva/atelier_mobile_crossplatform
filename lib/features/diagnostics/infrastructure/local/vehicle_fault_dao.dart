import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_table.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_table.dart';
import 'package:drift/drift.dart';

part 'vehicle_fault_dao.g.dart';

/// Caché `vehicle_faults` (06 §4, por vehículo en diagnóstico). Las fallas aún en cola tienen id
/// `local-{id de la operación}` y sobreviven a la recarga desde el backend.
@DriftAccessor(tables: [VehicleFaults, PendingOperations])
class VehicleFaultDao extends DatabaseAccessor<AppDatabase>
    with _$VehicleFaultDaoMixin {
  VehicleFaultDao(super.attachedDatabase);

  Future<void> upsert(VehicleFaultEntity fault) {
    return into(vehicleFaults).insertOnConflictUpdate(fault);
  }

  Future<VehicleFaultEntity?> findById(String id) {
    return (select(vehicleFaults)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteById(String id) {
    return (delete(vehicleFaults)..where((t) => t.id.equals(id))).go();
  }

  /// Recarga del alcance `faults:{vehicleId}` sin tocar las fallas que siguen en cola. Las `local-` cuya
  /// operación ya no existe se descartaron en "Pendientes de sincronizar": si quedaran, seguirían contadas
  /// como pendientes e impedirían volver a registrar ese DTC.
  Future<void> replaceRemote(String vehicleId, List<VehicleFaultEntity> faults) {
    return transaction(() async {
      await (delete(vehicleFaults)..where(
            (t) => t.vehicleId.equals(vehicleId) & t.id.like('local-%').not(),
          ))
          .go();
      await customUpdate(
        "DELETE FROM vehicle_faults WHERE vehicle_id = ? AND id LIKE 'local-%' "
        'AND substr(id, 7) NOT IN (SELECT id FROM pending_operations)',
        variables: [Variable.withString(vehicleId)],
        updates: {vehicleFaults},
        updateKind: UpdateKind.delete,
      );
      await batch((b) => b.insertAllOnConflictUpdate(vehicleFaults, faults));
    });
  }

  /// `REGISTER_FAULT` confirmado: la fila local pasa a tener el id del backend.
  Future<void> replaceLocal(String localId, VehicleFaultEntity fault) {
    return transaction(() async {
      await deleteById(localId);
      await upsert(fault);
    });
  }

  Future<List<VehicleFaultEntity>> findActive(String vehicleId) => _active(vehicleId).get();

  Stream<List<VehicleFaultEntity>> watchActive(String vehicleId) {
    return _active(vehicleId).watch();
  }

  SimpleSelectStatement<$VehicleFaultsTable, VehicleFaultEntity> _active(
    String vehicleId,
  ) {
    return select(vehicleFaults)
      ..where((t) => t.vehicleId.equals(vehicleId) & t.isResolved.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)]);
  }

  Future<void> markResolved(String id, int resolvedAt) {
    return (update(vehicleFaults)..where((t) => t.id.equals(id))).write(
      VehicleFaultsCompanion(
        isResolved: const Value(true),
        resolvedAt: Value(resolvedAt),
      ),
    );
  }

  Stream<int> watchPendingCount(String vehicleId) {
    final count = vehicleFaults.id.count();
    final query = selectOnly(vehicleFaults)
      ..addColumns([count])
      ..where(
        vehicleFaults.vehicleId.equals(vehicleId) &
            vehicleFaults.id.like('local-%'),
      );
    return query.map((row) => row.read(count)!).watchSingle();
  }
}
