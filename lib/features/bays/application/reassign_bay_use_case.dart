import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_errors.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';

/// US40 E1/E2. Una bahía que no está libre falla sin llamar; el backend vuelve a validar (409).
class ReassignBayUseCase {
  final BayRepository repository;

  const ReassignBayUseCase({required this.repository});

  Future<void> execute(String workOrderId, WorkBay target) async {
    if (!target.canReceive) throw const BayUnavailableException();
    await repository.reassignBay(workOrderId, target.id);
  }
}
