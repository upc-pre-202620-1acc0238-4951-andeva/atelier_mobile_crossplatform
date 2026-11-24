import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_table.dart';
import 'package:drift/drift.dart';

part 'vehicle_dao.g.dart';

/// Vehículo en caché unido a su titular actual si también está en `customers`.
class VehicleWithOwnerRow {
  final VehicleEntity vehicle;
  final CustomerEntity? owner;

  const VehicleWithOwnerRow({required this.vehicle, this.owner});
}

@DriftAccessor(tables: [Vehicles])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.attachedDatabase);

  Future<void> saveFromServer(VehiclesCompanion vehicle) async {
    await transaction(() async {
      await (delete(vehicles)
            ..where(
              (t) =>
                  t.plate.equals(vehicle.plate.value) &
                  t.id.equals(vehicle.id.value).not(),
            ))
          .go();
      await into(vehicles).insertOnConflictUpdate(vehicle);
    });
  }

  Future<VehicleEntity?> findById(String id) {
    return (select(vehicles)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<VehicleEntity?> watchById(String id) {
    return (select(vehicles)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Padrón de vehículos vistos con su titular, los más recientes primero. Une `customers` por
  /// `attachedDatabase`, así este DAO no depende de ella en el código generado.
  Stream<List<VehicleWithOwnerRow>> watchAllWithOwners() {
    final owners = attachedDatabase.customers;
    final query = select(vehicles).join([
      leftOuterJoin(owners, owners.id.equalsExp(vehicles.currentOwnerId)),
    ])
      ..orderBy([
        OrderingTerm.desc(vehicles.syncedAt),
        OrderingTerm.asc(vehicles.plate),
      ]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => VehicleWithOwnerRow(
              vehicle: row.readTable(vehicles),
              owner: row.readTableOrNull(owners),
            ),
          )
          .toList(),
    );
  }

  Future<VehicleEntity?> findByPlate(String plate) {
    return (select(vehicles)..where((t) => t.plate.equals(plate)))
        .getSingleOrNull();
  }
}
