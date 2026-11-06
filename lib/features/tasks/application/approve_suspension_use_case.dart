import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Supervisor: aprobar la suspensión de la tarea (US29 E1). En línea.
class ApproveSuspensionUseCase {
  final TaskRepository repository;

  const ApproveSuspensionUseCase({required this.repository});

  Future<TaskDetail> execute(TaskId id) => repository.approveSuspension(id);
}
