import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

/// Registrar que el cliente aprobó la propuesta (US15 E1): el backend crea la tarea y recalcula el
/// presupuesto. Devuelve el detalle recargado. En línea.
class ApproveProposalUseCase {
  final WorkOrderRepository repository;

  const ApproveProposalUseCase({required this.repository});

  Future<WorkOrderDetail> execute(
    WorkOrderId id,
    String proposalId,
    ProposalApproval approval,
  ) async {
    if (!WorkOrderValidation.isAmount(approval.finalPrice)) {
      throw const InvalidWorkOrderInputException('finalPrice');
    }
    if (!WorkOrderValidation.isAmount(approval.laborHours)) {
      throw const InvalidWorkOrderInputException('laborHours');
    }
    if (!WorkOrderValidation.isOptionalText(
      approval.notes,
      WorkOrderValidation.notesMax,
    )) {
      throw const InvalidWorkOrderInputException('notes');
    }
    return repository.approveProposal(id, proposalId, approval);
  }
}
