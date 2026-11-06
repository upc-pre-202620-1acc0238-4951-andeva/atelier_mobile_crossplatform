import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Iniciar la tarea o reanudarla tras una pausa propia (US27 E1, E5). En línea.
class StartTaskUseCase {
  final TaskRepository repository;

  const StartTaskUseCase({required this.repository});

  Future<TaskDetail> execute(TaskId id) => repository.start(id);
}
