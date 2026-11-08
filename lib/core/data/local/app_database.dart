import 'package:atelier_mobile_crossplatform/core/data/local/app_lock_table.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_maintenance_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_table.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_table.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_table.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_table.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/branch_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/branch_table.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/shift_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/shift_table.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_dao.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/local/voucher_dao.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_table.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/local/voucher_table.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/predictive_alert_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/predictive_alert_table.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/telemetry_reading_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/telemetry_reading_table.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_table.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/batch_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/batch_table.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/part_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/part_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/appointment_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/appointment_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_table.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/task_dao.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/task_table.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_dao.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PendingOperations,
    PendingUploads,
    CacheMetadata,
    Attendances,
    Shifts,
    Branches,
    Tasks,
    WorkOrders,
    Bays,
    Customers,
    Vehicles,
    Appointments,
    Parts,
    Batches,
    Vouchers,
    TelemetryReadings,
    VehicleFaults,
    PredictiveAlerts,
    AppLocks,
  ],
  daos: [
    PendingOperationDao,
    PendingUploadDao,
    CacheMetadataDao,
    CacheMaintenanceDao,
    AttendanceDao,
    ShiftDao,
    BranchDao,
    TaskDao,
    VehicleDao,
    BayDao,
    CustomerDao,
    AppointmentDao,
    WorkOrderDao,
    PartDao,
    BatchDao,
    TelemetryReadingDao,
    VehicleFaultDao,
    PredictiveAlertDao,
    VoucherDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'atelier_db',
              native: const DriftNativeOptions(setup: configureConnection),
            ),
      );

  /// La UI y el worker abren el mismo archivo por separado. Corre antes de migrar, y
  /// `busy_timeout` va primero porque cambiar a WAL también necesita el bloqueo.
  static void configureConnection(CommonDatabase database) {
    database.execute('PRAGMA busy_timeout = 5000');
    database.execute('PRAGMA journal_mode = WAL');
  }

  @override
  int get schemaVersion => 1;

  /// Avisa a los `watch()` de este motor que otro motor escribió en el archivo.
  void notifyExternalChanges() {
    notifyUpdates(allTables.map(TableUpdate.onTable).toSet());
  }
}
