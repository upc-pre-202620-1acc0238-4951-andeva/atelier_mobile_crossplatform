import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_work_order_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

class ObservePendingProposalsUseCase {
  final WorkOrderRepository repository;

  const ObservePendingProposalsUseCase({required this.repository});

  Stream<List<PendingProposal>> execute(WorkOrderId id) {
    return repository.observePendingProposals(id);
  }
}
