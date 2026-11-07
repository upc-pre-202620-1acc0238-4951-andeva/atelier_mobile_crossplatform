import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

/// Registrar que el cliente rechazó la propuesta, con sus notas (US15 E2). En línea.
class RejectProposalUseCase {
  final WorkOrderRepository repository;

  const RejectProposalUseCase({required this.repository});

  Future<Proposal> execute(
    WorkOrderId id,
    String proposalId,
    String customerNotes,
  ) async {
    if (!WorkOrderValidation.isRequiredText(
      customerNotes,
      WorkOrderValidation.notesMax,
    )) {
      throw const InvalidWorkOrderInputException('customerNotes');
    }
    return repository.rejectProposal(id, proposalId, customerNotes);
  }
}
