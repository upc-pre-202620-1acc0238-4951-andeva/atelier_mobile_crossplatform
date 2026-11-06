import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Observa una faena específica con sus referencias (placa y bahía).
class ObserveTaskUseCase {
  final TaskRepository repository;

  const ObserveTaskUseCase({required this.repository});

  Stream<Task?> execute(TaskId id) => repository.observeTask(id);
}
