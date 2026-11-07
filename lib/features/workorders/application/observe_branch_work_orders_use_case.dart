import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

class ObserveBranchWorkOrdersUseCase {
  final WorkOrderRepository repository;

  const ObserveBranchWorkOrdersUseCase({required this.repository});

  Stream<List<WorkOrder>> execute() {
    return repository.observeBranchWorkOrders();
  }
}
