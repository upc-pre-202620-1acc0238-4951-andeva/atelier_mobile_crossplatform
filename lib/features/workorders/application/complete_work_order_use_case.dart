import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Da la orden por terminada. El backend avisa con `WORK_ORDER_COMPLETED`. En línea.
class CompleteWorkOrderUseCase {
  final WorkOrderRepository repository;

  const CompleteWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute(WorkOrderId id) {
    return repository.complete(id);
  }
}
