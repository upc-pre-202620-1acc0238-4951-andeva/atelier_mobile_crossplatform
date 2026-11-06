import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Supervisor: retirar un repuesto improcedente (US23 E2, US33 E1). En línea.
class RemovePartFromTaskUseCase {
  final TaskRepository repository;

  const RemovePartFromTaskUseCase({required this.repository});

  Future<void> execute(TaskId id, String productId) =>
      repository.removePart(id, productId);
}
