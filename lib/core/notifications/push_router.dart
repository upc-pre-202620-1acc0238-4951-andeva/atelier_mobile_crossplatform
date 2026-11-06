import 'package:flutter/foundation.dart';

enum PushChannel { tasks, attendance, inventory }

/// Pantalla que abre cada push (docs/04-mobile-integration.md §2). Las features la convierten en
/// su ruta.
sealed class PushDestination {
  const PushDestination();

  List<String> get _ids;

  @override
  bool operator ==(Object other) {
    return other is PushDestination &&
        other.runtimeType == runtimeType &&
        listEquals(other._ids, _ids);
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

class PushRouter {
  /// `data.type` + ids → destino. Un tipo desconocido o sin sus ids devuelve `null` sin fallar: el
  /// backend puede agregar tipos nuevos.
  static PushDestination? route(Map<String, dynamic> data) {
    String? id(String key) {
      final value = data[key];
      return value is String && value.trim().isNotEmpty ? value : null;
    }

    final workOrderId = id('workOrderId');
    final taskId = id('taskId');
    final hasTask = workOrderId != null && taskId != null;
    final attendanceId = id('attendanceId');
    final membershipId = id('membershipId');
    final itemId = id('itemId');
    final shiftId = id('shiftId');

    return switch (data['type']) {
      'TASK_ASSIGNED' || 'TASK_PAUSED' || 'TASK_RESUMED' when hasTask =>
        TaskDetailDestination(workOrderId, taskId),
      'TASK_SUSPENSION_REQUESTED' when hasTask =>
        TaskSuspensionReviewDestination(workOrderId, taskId),
      'TASK_PART_CHARGED' when hasTask =>
        TaskProductsDestination(workOrderId, taskId),
      'WORK_ORDER_COMPLETED' when workOrderId != null =>
        WorkOrderDetailDestination(workOrderId),
      'LOW_STOCK' when itemId != null => LowStockAlertsDestination(itemId),
      'OVERTIME_RECORDED' when attendanceId != null && membershipId != null =>
        CollaboratorAttendanceDestination(attendanceId, membershipId),
      'JUSTIFICATION_REVIEWED' when attendanceId != null =>
        MyAttendanceDestination(attendanceId),
      'SHIFT_REMINDER' when shiftId != null => ClockInDestination(shiftId),
      _ => null,
    };
  }

  static PushChannel channelFor(PushDestination destination) {
    return switch (destination) {
      TaskDetailDestination() ||
      TaskSuspensionReviewDestination() ||
      TaskProductsDestination() ||
      WorkOrderDetailDestination() => PushChannel.tasks,
      LowStockAlertsDestination() => PushChannel.inventory,
      CollaboratorAttendanceDestination() ||
      MyAttendanceDestination() ||
      ClockInDestination() => PushChannel.attendance,
    };
  }
}
