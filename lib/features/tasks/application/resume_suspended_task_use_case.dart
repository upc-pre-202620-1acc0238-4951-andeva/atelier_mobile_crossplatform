import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Supervisor: levantar la suspensión cuando llega el repuesto (US29 E3). En línea.
class ResumeSuspendedTaskUseCase {
  final TaskRepository repository;

  const ResumeSuspendedTaskUseCase({required this.repository});

  Future<TaskDetail> execute(TaskId id) => repository.resume(id);
}
