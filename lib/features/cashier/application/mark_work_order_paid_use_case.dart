import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// US39 E2. El backend rechaza si queda saldo: mostrar su `message`.
class MarkWorkOrderPaidUseCase {
  final WorkOrderRepository repository;

  const MarkWorkOrderPaidUseCase({required this.repository});

  Future<WorkOrder> execute(WorkOrderId id) => repository.markAsPaid(id);
}
