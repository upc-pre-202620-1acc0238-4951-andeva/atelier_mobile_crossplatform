import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Pasa la orden a `IN_PROGRESS`. Un 422 trae el `message` de la transición inválida. En línea.
class StartWorkOrderUseCase {
  final WorkOrderRepository repository;

  const StartWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute(WorkOrderId id) {
    return repository.start(id);
  }
}
