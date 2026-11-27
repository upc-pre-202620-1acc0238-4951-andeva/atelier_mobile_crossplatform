import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_suspension.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// US29: solicitudes de suspensión en espera. No hay endpoint que las liste (H5), así que consulta el detalle de las
/// órdenes en curso. Como el monitor de Android: como mucho [maxOrders] órdenes `IN_PROGRESS` y [maxConcurrency]
/// consultas a la vez. En línea. Una orden que falla se omite: el resultado puede ser parcial.
class FindPendingSuspensionsUseCase {
  static const maxOrders = 15;
  static const maxConcurrency = 3;

  final WorkOrderRepository repository;

  const FindPendingSuspensionsUseCase({required this.repository});

  Future<List<PendingSuspension>> execute(List<WorkOrder> orders) async {
    final inProgress = [
      for (final order in orders)
        if (order.status == WorkOrderStatus.inProgress) order,
    ].take(maxOrders).toList();
    final found = <PendingSuspension>[];
    for (var start = 0; start < inProgress.length; start += maxConcurrency) {
      final end = start + maxConcurrency > inProgress.length ? inProgress.length : start + maxConcurrency;
      final batch = inProgress.sublist(start, end);
      final results = await Future.wait([for (final order in batch) _inspect(order)]);
      for (final list in results) {
        found.addAll(list);
      }
    }
    return found;
  }

  Future<List<PendingSuspension>> _inspect(WorkOrder order) async {
    try {
      final detail = await repository.getDetail(order.id);
      return [
        for (final task in detail.tasksAwaitingSuspensionReview) PendingSuspension(order: order, task: task),
      ];
    } on Exception {
      // Se sigue con las demás órdenes.
      return const [];
    }
  }
}
