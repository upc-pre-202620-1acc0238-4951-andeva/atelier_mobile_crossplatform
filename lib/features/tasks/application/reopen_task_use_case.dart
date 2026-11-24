import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Reabre una tarea cerrada para retrabajo de calidad (`POST /tasks/{taskId}/reopen`). Exige
/// `operations:work_orders:update` en la sesión. En línea.
class ReopenTaskUseCase {
  final TaskRepository repository;

  const ReopenTaskUseCase({required this.repository});

  Future<TaskDetail> execute(TaskId id, {String? reason}) {
    final trimmed = reason?.trim();
    return repository.reopen(
      id,
      reason: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }
}
