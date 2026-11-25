import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';

/// Tarea de una orden activa con una solicitud de suspensión esperando al supervisor (US29, H5).
class PendingSuspension {
  final WorkOrder order;
  final TaskDetail task;

  const PendingSuspension({required this.order, required this.task});
}
