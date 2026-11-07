import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Avisa al cliente de la propuesta (US15). Devuelve el correo al que se envió. En línea.
class NotifyProposalUseCase {
  final WorkOrderRepository repository;

  const NotifyProposalUseCase({required this.repository});

  Future<String> execute(WorkOrderId id, String proposalId) {
    return repository.notifyProposal(id, proposalId);
  }
}
