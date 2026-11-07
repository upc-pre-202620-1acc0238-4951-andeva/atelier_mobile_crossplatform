import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/appointment_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_table.dart';
import 'package:drift/drift.dart';

part 'appointment_dao.g.dart';

/// Una fila de `appointments` con la placa y el nombre del cliente, si ya están en caché.
class AppointmentWithRefs {
  final AppointmentEntity appointment;
  final String? plate;
  final String? customerName;

  const AppointmentWithRefs({
    required this.appointment,
    this.plate,
    this.customerName,
  });
}

/// Caché `appointments` (06 §4, hoy y mañana · 5 min) por sede y día de Lima.
@DriftAccessor(tables: [Appointments, Vehicles, Customers])
class AppointmentDao extends DatabaseAccessor<AppDatabase>
    with _$AppointmentDaoMixin {
  AppointmentDao(super.attachedDatabase);

  Future<void> upsert(AppointmentEntity appointment) {
    return into(appointments)
        .insertOnConflictUpdate(appointment.toCompanion(false));
  }

  /// Recarga completa del alcance `appointments:{branchId}:{fecha}`: [from]–[to] es el día de Lima
  /// en epoch ms.
  Future<void> replaceDay(
    String branchId,
    int from,
    int to,
    List<AppointmentEntity> rows,
  ) {
    return transaction(() async {
      await (delete(appointments)..where(
            (t) =>
                t.branchId.equals(branchId) &
                t.scheduledAt.isBiggerOrEqualValue(from) &
                t.scheduledAt.isSmallerThanValue(to),
          ))
          .go();
      for (final row in rows) {
        await upsert(row);
      }
    });
  }

  Stream<List<AppointmentWithRefs>> watchDay(
    String branchId,
    int from,
    int to,
  ) {
    final query =
        select(appointments).join([
            leftOuterJoin(
              vehicles,
              vehicles.id.equalsExp(appointments.vehicleId),
            ),
            leftOuterJoin(
              customers,
              customers.id.equalsExp(appointments.customerId),
            ),
          ])
          ..where(
            appointments.branchId.equals(branchId) &
                appointments.scheduledAt.isBiggerOrEqualValue(from) &
                appointments.scheduledAt.isSmallerThanValue(to),
          )
          ..orderBy([OrderingTerm.asc(appointments.scheduledAt)]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => AppointmentWithRefs(
              appointment: row.readTable(appointments),
              plate: row.readTableOrNull(vehicles)?.plate,
              customerName: row.readTableOrNull(customers)?.displayName,
            ),
          )
          .toList(),
    );
  }
}
