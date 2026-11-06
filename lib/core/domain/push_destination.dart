/// Pantalla que abre cada push (docs/04-mobile-integration.md §2). Las features la convierten en
/// su ruta.
sealed class PushDestination {
  const PushDestination();

  List<String> get _ids;

  @override
  bool operator ==(Object other) {
    if (other is! PushDestination || other.runtimeType != runtimeType) {
      return false;
    }
    // Mismo tipo: misma cantidad de ids.
    for (var i = 0; i < _ids.length; i++) {
      if (other._ids[i] != _ids[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(_ids));
}

final class TaskDetailDestination extends PushDestination {
  final String workOrderId;
  final String taskId;

  const TaskDetailDestination(this.workOrderId, this.taskId);

  @override
  List<String> get _ids => [workOrderId, taskId];
}

final class TaskSuspensionReviewDestination extends PushDestination {
  final String workOrderId;
  final String taskId;

  const TaskSuspensionReviewDestination(this.workOrderId, this.taskId);

  @override
  List<String> get _ids => [workOrderId, taskId];
}

final class TaskProductsDestination extends PushDestination {
  final String workOrderId;
  final String taskId;

  const TaskProductsDestination(this.workOrderId, this.taskId);

  @override
  List<String> get _ids => [workOrderId, taskId];
}

final class WorkOrderDetailDestination extends PushDestination {
  final String workOrderId;

  const WorkOrderDetailDestination(this.workOrderId);

  @override
  List<String> get _ids => [workOrderId];
}

final class LowStockAlertsDestination extends PushDestination {
  final String itemId;

  const LowStockAlertsDestination(this.itemId);

  @override
  List<String> get _ids => [itemId];
}

final class CollaboratorAttendanceDestination extends PushDestination {
  final String attendanceId;
  final String membershipId;

  const CollaboratorAttendanceDestination(this.attendanceId, this.membershipId);

  @override
  List<String> get _ids => [attendanceId, membershipId];
}

final class MyAttendanceDestination extends PushDestination {
  final String attendanceId;

  const MyAttendanceDestination(this.attendanceId);

  @override
  List<String> get _ids => [attendanceId];
}

final class ClockInDestination extends PushDestination {
  final String shiftId;

  const ClockInDestination(this.shiftId);

  @override
  List<String> get _ids => [shiftId];
}
