import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';

/// US40 E1. [mechanicId] es el membershipId (H11); la lista sale de `GetBranchMechanicsUseCase`.
class ReassignTaskMechanicUseCase {
  final BayRepository repository;

  const ReassignTaskMechanicUseCase({required this.repository});

  Future<void> execute(String taskId, String mechanicId) {
    return repository.reassignMechanic(taskId, mechanicId);
  }
}
