import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Registra que el cliente aprobó la proforma (US25). En línea.
class ApproveQuotationUseCase {
  final WorkOrderRepository repository;

  const ApproveQuotationUseCase({required this.repository});

  Future<WorkOrder> execute(WorkOrderId id) {
    return repository.approveQuotation(id);
  }
}
