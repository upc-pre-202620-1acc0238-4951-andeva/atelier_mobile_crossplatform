import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';

/// Orden que ocupa una bahía (US40 E3). [internalNumber] y [plate] salen de las cachés y pueden
/// faltar; [mechanicIds] (membershipId, H11) y [laborElapsed] llegan con el detalle de la orden.
class BayOccupant {
  final String workOrderId;
  final int? internalNumber;
  final String? plate;
  final List<String> mechanicIds;
  final Duration? laborElapsed;

  const BayOccupant({
    required this.workOrderId,
    this.internalNumber,
    this.plate,
    this.mechanicIds = const [],
    this.laborElapsed,
  });
}

class BayBoardItem {
  final WorkBay bay;
  final BayOccupant? occupant;

  const BayBoardItem({required this.bay, this.occupant});
}

/// Tiempo de mano de obra de las tareas `IN_PROGRESS`, sin sus pausas; `null` si ninguna corre.
/// `ON_HOLD` queda fuera: la pausa en curso aún no está en `totalPausedSeconds`.
Duration? laborElapsed(List<TaskDetail> tasks, DateTime now) {
  final running = tasks.where(
    (task) => task.status == TaskStatus.inProgress && task.startedAt != null,
  );
  if (running.isEmpty) return null;
  return running.fold<Duration>(
    Duration.zero,
    (total, task) =>
        total +
        now.difference(task.startedAt!) -
        Duration(seconds: task.totalPausedSeconds),
  );
}
