import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Mis tareas abiertas desde Room (en curso → en pausa → asignadas), con placa y bahía si están en caché (US26 E1).
class ObserveMyTasksUseCase {
  final TaskRepository repository;

  const ObserveMyTasksUseCase({required this.repository});

  Stream<List<Task>> execute() => repository.observeMyTasks();
}
