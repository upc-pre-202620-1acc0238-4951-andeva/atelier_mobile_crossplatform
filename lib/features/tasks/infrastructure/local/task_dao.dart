import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_table.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_table.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/task_table.dart';
import 'package:drift/drift.dart';

part 'task_dao.g.dart';

class TaskWithRefs {
  final TaskEntity task;
  final String? plate;
  final String? bayName;

  const TaskWithRefs({
    required this.task,
    this.plate,
    this.bayName,
  });
}

@DriftAccessor(tables: [Tasks, Vehicles, Bays])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.attachedDatabase);

  Future<void> replaceMine(List<TasksCompanion> newTasks) async {
    await transaction(() async {
      final previous = {
        for (final row in await select(tasks).get()) row.id: row,
      };
      await delete(tasks).go();
      for (final row in newTasks) {
        final prev = previous[row.id.value];
        final companion = prev != null ? _keepDetailOf(row, prev) : row;
        await into(tasks).insertOnConflictUpdate(companion);
      }
    });
  }

  /// `AssignedTaskResource` no trae servicio, mecánico ni motivo de pausa: si la recarga no los
  /// manda, se conservan los del detalle; los de pausa o suspensión, solo si no cambió el estado.
  TasksCompanion _keepDetailOf(TasksCompanion current, TaskEntity prev) {
    final sameStatus = current.status.value == prev.status;
    Value<String?> orPrevious(Value<String?> value, String? previous) {
      return value.present && value.value != null ? value : Value(previous);
    }

    return current.copyWith(
      serviceName: orPrevious(current.serviceName, prev.serviceName),
      mechanicId: orPrevious(current.mechanicId, prev.mechanicId),
      holdReason: orPrevious(
        current.holdReason,
        sameStatus ? prev.holdReason : null,
      ),
      missingItemDescription: orPrevious(
        current.missingItemDescription,
        sameStatus ? prev.missingItemDescription : null,
      ),
      pendingSuspensionReason: orPrevious(
        current.pendingSuspensionReason,
        sameStatus ? prev.pendingSuspensionReason : null,
      ),
    );
  }

  Future<int> mergeDetail({
    required String id,
    required String status,
    required String description,
    String? serviceName,
    String? mechanicId,
    String? holdReason,
    String? missingItemDescription,
    String? pendingSuspensionReason,
    int? startedAt,
    required int totalPausedSeconds,
    required int syncedAt,
  }) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: Value(status),
        description: Value(description),
        serviceName: Value(serviceName),
        mechanicId: Value(mechanicId),
        holdReason: Value(holdReason),
        missingItemDescription: Value(missingItemDescription),
        pendingSuspensionReason: Value(pendingSuspensionReason),
        startedAt: Value(startedAt),
        totalPausedSeconds: Value(totalPausedSeconds),
        syncedAt: Value(syncedAt),
      ),
    );
  }

  Future<void> deleteById(String id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<TaskEntity?> findById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<TaskWithRefs>> observeAll() {
    final query = select(tasks).join([
      leftOuterJoin(vehicles, vehicles.id.equalsExp(tasks.vehicleId)),
      leftOuterJoin(bays, bays.id.equalsExp(tasks.bayId)),
    ])
      ..orderBy([
        OrderingTerm(
          expression: const CustomExpression<int>(
            "CASE tasks.status WHEN 'IN_PROGRESS' THEN 0 WHEN 'ON_HOLD' THEN 1 ELSE 2 END",
          ),
        ),
        OrderingTerm.asc(tasks.workOrderNumber),
      ]);

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => TaskWithRefs(
                  task: row.readTable(tasks),
                  plate: row.readTableOrNull(vehicles)?.plate,
                  bayName: row.readTableOrNull(bays)?.name,
                ),
              )
              .toList(),
        );
  }

  Stream<TaskWithRefs?> observeById(String id) {
    final query = select(tasks).join([
      leftOuterJoin(vehicles, vehicles.id.equalsExp(tasks.vehicleId)),
      leftOuterJoin(bays, bays.id.equalsExp(tasks.bayId)),
    ])..where(tasks.id.equals(id));

    return query.watchSingleOrNull().map(
          (row) => row == null
              ? null
              : TaskWithRefs(
                  task: row.readTable(tasks),
                  plate: row.readTableOrNull(vehicles)?.plate,
                  bayName: row.readTableOrNull(bays)?.name,
                ),
        );
  }
}
