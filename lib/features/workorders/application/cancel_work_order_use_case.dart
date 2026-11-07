import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

/// Cancela la orden con motivo (US25). Libera bahía y reservas. En línea.
class CancelWorkOrderUseCase {
  final WorkOrderRepository repository;

  const CancelWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute(WorkOrderId id, String reason) async {
    if (!WorkOrderValidation.isRequiredText(
      reason,
      WorkOrderValidation.reasonMax,
    )) {
      throw const InvalidWorkOrderInputException('reason');
    }
    return repository.cancel(id, reason);
  }
}
