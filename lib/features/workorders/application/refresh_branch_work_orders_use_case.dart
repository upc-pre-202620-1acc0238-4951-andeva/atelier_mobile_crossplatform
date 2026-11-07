import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Recarga las órdenes de la sede. Sin red lanza `NetworkException` y la caché sigue visible.
class RefreshBranchWorkOrdersUseCase {
  final WorkOrderRepository repository;

  const RefreshBranchWorkOrdersUseCase({required this.repository});

  Future<void> execute() {
    return repository.refreshBranchWorkOrders();
  }
}
