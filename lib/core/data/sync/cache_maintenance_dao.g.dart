// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_maintenance_dao.dart';

// ignore_for_file: type=lint
mixin _$CacheMaintenanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $CacheMetadataTable get cacheMetadata => attachedDatabase.cacheMetadata;
  $BranchesTable get branches => attachedDatabase.branches;
  $ShiftsTable get shifts => attachedDatabase.shifts;
  $AttendancesTable get attendances => attachedDatabase.attendances;
  $TasksTable get tasks => attachedDatabase.tasks;
  $WorkOrdersTable get workOrders => attachedDatabase.workOrders;
  $BaysTable get bays => attachedDatabase.bays;
  $CustomersTable get customers => attachedDatabase.customers;
  $VehiclesTable get vehicles => attachedDatabase.vehicles;
  $AppointmentsTable get appointments => attachedDatabase.appointments;
  $PartsTable get parts => attachedDatabase.parts;
  $BatchesTable get batches => attachedDatabase.batches;
  $VouchersTable get vouchers => attachedDatabase.vouchers;
  $VehicleFaultsTable get vehicleFaults => attachedDatabase.vehicleFaults;
  $PredictiveAlertsTable get predictiveAlerts =>
      attachedDatabase.predictiveAlerts;
  CacheMaintenanceDaoManager get managers => CacheMaintenanceDaoManager(this);
}

class CacheMaintenanceDaoManager {
  final _$CacheMaintenanceDaoMixin _db;
  CacheMaintenanceDaoManager(this._db);
  $$CacheMetadataTableTableManager get cacheMetadata =>
      $$CacheMetadataTableTableManager(_db.attachedDatabase, _db.cacheMetadata);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db.attachedDatabase, _db.branches);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db.attachedDatabase, _db.shifts);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db.attachedDatabase, _db.attendances);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$WorkOrdersTableTableManager get workOrders =>
      $$WorkOrdersTableTableManager(_db.attachedDatabase, _db.workOrders);
  $$BaysTableTableManager get bays =>
      $$BaysTableTableManager(_db.attachedDatabase, _db.bays);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db.attachedDatabase, _db.vehicles);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db.attachedDatabase, _db.appointments);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db.attachedDatabase, _db.parts);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db.attachedDatabase, _db.batches);
  $$VouchersTableTableManager get vouchers =>
      $$VouchersTableTableManager(_db.attachedDatabase, _db.vouchers);
  $$VehicleFaultsTableTableManager get vehicleFaults =>
      $$VehicleFaultsTableTableManager(_db.attachedDatabase, _db.vehicleFaults);
  $$PredictiveAlertsTableTableManager get predictiveAlerts =>
      $$PredictiveAlertsTableTableManager(
        _db.attachedDatabase,
        _db.predictiveAlerts,
      );
}
