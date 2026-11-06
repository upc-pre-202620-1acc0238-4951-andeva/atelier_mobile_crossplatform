import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_table.dart';
import 'package:drift/drift.dart';

part 'vehicle_dao.g.dart';

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

  Future<VehicleEntity?> findByPlate(String plate) {
    return (select(vehicles)..where((t) => t.plate.equals(plate)))
        .getSingleOrNull();
  }
}
