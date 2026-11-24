// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldPendingOperationsData = <v1.PendingOperationsData>[];
    final expectedNewPendingOperationsData = <v2.PendingOperationsData>[];

    final oldPendingUploadsData = <v1.PendingUploadsData>[];
    final expectedNewPendingUploadsData = <v2.PendingUploadsData>[];

    final oldCacheMetadataData = <v1.CacheMetadataData>[];
    final expectedNewCacheMetadataData = <v2.CacheMetadataData>[];

    final oldAttendancesData = <v1.AttendancesData>[];
    final expectedNewAttendancesData = <v2.AttendancesData>[];

    final oldShiftsData = <v1.ShiftsData>[];
    final expectedNewShiftsData = <v2.ShiftsData>[];

    final oldBranchesData = <v1.BranchesData>[];
    final expectedNewBranchesData = <v2.BranchesData>[];

    final oldTasksData = <v1.TasksData>[];
    final expectedNewTasksData = <v2.TasksData>[];

    final oldWorkOrdersData = <v1.WorkOrdersData>[];
    final expectedNewWorkOrdersData = <v2.WorkOrdersData>[];

    final oldBaysData = <v1.BaysData>[];
    final expectedNewBaysData = <v2.BaysData>[];

    final oldCustomersData = <v1.CustomersData>[];
    final expectedNewCustomersData = <v2.CustomersData>[];

    final oldVehiclesData = <v1.VehiclesData>[];
    final expectedNewVehiclesData = <v2.VehiclesData>[];

    final oldAppointmentsData = <v1.AppointmentsData>[];
    final expectedNewAppointmentsData = <v2.AppointmentsData>[];

    final oldPartsData = <v1.PartsData>[];
    final expectedNewPartsData = <v2.PartsData>[];

    final oldBatchesData = <v1.BatchesData>[];
    final expectedNewBatchesData = <v2.BatchesData>[];

    final oldVouchersData = <v1.VouchersData>[];
    final expectedNewVouchersData = <v2.VouchersData>[];

    final oldTelemetryReadingsData = <v1.TelemetryReadingsData>[];
    final expectedNewTelemetryReadingsData = <v2.TelemetryReadingsData>[];

    final oldVehicleFaultsData = <v1.VehicleFaultsData>[];
    final expectedNewVehicleFaultsData = <v2.VehicleFaultsData>[];

    final oldPredictiveAlertsData = <v1.PredictiveAlertsData>[];
    final expectedNewPredictiveAlertsData = <v2.PredictiveAlertsData>[];

    final oldAppLocksData = <v1.AppLocksData>[];
    final expectedNewAppLocksData = <v2.AppLocksData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.pendingOperations, oldPendingOperationsData);
        batch.insertAll(oldDb.pendingUploads, oldPendingUploadsData);
        batch.insertAll(oldDb.cacheMetadata, oldCacheMetadataData);
        batch.insertAll(oldDb.attendances, oldAttendancesData);
        batch.insertAll(oldDb.shifts, oldShiftsData);
        batch.insertAll(oldDb.branches, oldBranchesData);
        batch.insertAll(oldDb.tasks, oldTasksData);
        batch.insertAll(oldDb.workOrders, oldWorkOrdersData);
        batch.insertAll(oldDb.bays, oldBaysData);
        batch.insertAll(oldDb.customers, oldCustomersData);
        batch.insertAll(oldDb.vehicles, oldVehiclesData);
        batch.insertAll(oldDb.appointments, oldAppointmentsData);
        batch.insertAll(oldDb.parts, oldPartsData);
        batch.insertAll(oldDb.batches, oldBatchesData);
        batch.insertAll(oldDb.vouchers, oldVouchersData);
        batch.insertAll(oldDb.telemetryReadings, oldTelemetryReadingsData);
        batch.insertAll(oldDb.vehicleFaults, oldVehicleFaultsData);
        batch.insertAll(oldDb.predictiveAlerts, oldPredictiveAlertsData);
        batch.insertAll(oldDb.appLocks, oldAppLocksData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewPendingOperationsData,
          await newDb.select(newDb.pendingOperations).get(),
        );
        expect(
          expectedNewPendingUploadsData,
          await newDb.select(newDb.pendingUploads).get(),
        );
        expect(
          expectedNewCacheMetadataData,
          await newDb.select(newDb.cacheMetadata).get(),
        );
        expect(
          expectedNewAttendancesData,
          await newDb.select(newDb.attendances).get(),
        );
        expect(expectedNewShiftsData, await newDb.select(newDb.shifts).get());
        expect(
          expectedNewBranchesData,
          await newDb.select(newDb.branches).get(),
        );
        expect(expectedNewTasksData, await newDb.select(newDb.tasks).get());
        expect(
          expectedNewWorkOrdersData,
          await newDb.select(newDb.workOrders).get(),
        );
        expect(expectedNewBaysData, await newDb.select(newDb.bays).get());
        expect(
          expectedNewCustomersData,
          await newDb.select(newDb.customers).get(),
        );
        expect(
          expectedNewVehiclesData,
          await newDb.select(newDb.vehicles).get(),
        );
        expect(
          expectedNewAppointmentsData,
          await newDb.select(newDb.appointments).get(),
        );
        expect(expectedNewPartsData, await newDb.select(newDb.parts).get());
        expect(expectedNewBatchesData, await newDb.select(newDb.batches).get());
        expect(
          expectedNewVouchersData,
          await newDb.select(newDb.vouchers).get(),
        );
        expect(
          expectedNewTelemetryReadingsData,
          await newDb.select(newDb.telemetryReadings).get(),
        );
        expect(
          expectedNewVehicleFaultsData,
          await newDb.select(newDb.vehicleFaults).get(),
        );
        expect(
          expectedNewPredictiveAlertsData,
          await newDb.select(newDb.predictiveAlerts).get(),
        );
        expect(
          expectedNewAppLocksData,
          await newDb.select(newDb.appLocks).get(),
        );
      },
    );
  });
}
