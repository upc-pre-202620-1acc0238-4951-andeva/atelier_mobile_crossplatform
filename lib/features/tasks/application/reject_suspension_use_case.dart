import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Supervisor: desestimar la suspensión (US29 E2). En línea.
class RejectSuspensionUseCase {
  final TaskRepository repository;

  const RejectSuspensionUseCase({required this.repository});

  Future<TaskDetail> execute(TaskId id) => repository.rejectSuspension(id);
}
