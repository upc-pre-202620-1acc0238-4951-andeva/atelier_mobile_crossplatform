// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_dao.dart';

// ignore_for_file: type=lint
mixin _$AppointmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppointmentsTable get appointments => attachedDatabase.appointments;
  $VehiclesTable get vehicles => attachedDatabase.vehicles;
  $CustomersTable get customers => attachedDatabase.customers;
  AppointmentDaoManager get managers => AppointmentDaoManager(this);
}

class AppointmentDaoManager {
  final _$AppointmentDaoMixin _db;
  AppointmentDaoManager(this._db);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db.attachedDatabase, _db.appointments);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db.attachedDatabase, _db.vehicles);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}
