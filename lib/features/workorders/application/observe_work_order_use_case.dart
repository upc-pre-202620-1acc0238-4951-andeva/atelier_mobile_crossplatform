import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

class ObserveWorkOrderUseCase {
  final WorkOrderRepository repository;

  const ObserveWorkOrderUseCase({required this.repository});

  Stream<WorkOrder?> execute(WorkOrderId id) {
    return repository.observeWorkOrder(id);
  }
}
