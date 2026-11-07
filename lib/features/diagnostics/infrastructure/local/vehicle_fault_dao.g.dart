// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_fault_dao.dart';

// ignore_for_file: type=lint
mixin _$VehicleFaultDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehicleFaultsTable get vehicleFaults => attachedDatabase.vehicleFaults;
  $PendingOperationsTable get pendingOperations =>
      attachedDatabase.pendingOperations;
  VehicleFaultDaoManager get managers => VehicleFaultDaoManager(this);
}

class VehicleFaultDaoManager {
  final _$VehicleFaultDaoMixin _db;
  VehicleFaultDaoManager(this._db);
  $$VehicleFaultsTableTableManager get vehicleFaults =>
      $$VehicleFaultsTableTableManager(_db.attachedDatabase, _db.vehicleFaults);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(
        _db.attachedDatabase,
        _db.pendingOperations,
      );
}
