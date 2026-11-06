import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_table.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_table.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/branch_table.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/shift_table.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_table.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/local/voucher_table.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/predictive_alert_table.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_table.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/batch_table.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/part_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/appointment_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_table.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/task_table.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_table.dart';
import 'package:drift/drift.dart';

part 'cache_maintenance_dao.g.dart';

/// Al cerrar sesión se borran las cachés (son datos del taller). No se tocan la cola,
/// `telemetry_readings` (captura pendiente de envío) ni `app_locks`.
@DriftAccessor(
  tables: [
    CacheMetadata,
    Branches,
    Shifts,
    Attendances,
    Tasks,
    WorkOrders,
    Bays,
    Customers,
    Vehicles,
    Appointments,
    Parts,
    Batches,
    Vouchers,
    VehicleFaults,
    PredictiveAlerts,
  ],
)
class CacheMaintenanceDao extends DatabaseAccessor<AppDatabase>
    with _$CacheMaintenanceDaoMixin {
  CacheMaintenanceDao(super.attachedDatabase);

  Future<void> clearCaches() {
    return transaction(() async {
      for (final table in <TableInfo>[
        cacheMetadata,
        branches,
        shifts,
        attendances,
        tasks,
        workOrders,
        bays,
        customers,
        vehicles,
        appointments,
        parts,
        batches,
        vouchers,
        vehicleFaults,
        predictiveAlerts,
      ]) {
        await delete(table).go();
      }
    });
  }
}
