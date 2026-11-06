import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';

export 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';

enum PushChannel { tasks, attendance, inventory }

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
      'TASK_ASSIGNED' ||
      'TASK_PAUSED' ||
      'TASK_RESUMED' when hasTask => TaskDetailDestination(workOrderId, taskId),
      'TASK_SUSPENSION_REQUESTED' when hasTask =>
        TaskSuspensionReviewDestination(workOrderId, taskId),
      'TASK_PART_CHARGED' when hasTask => TaskProductsDestination(
        workOrderId,
        taskId,
      ),
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
