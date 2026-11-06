import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Recarga `tasks:my` y enriquece placa y bahía si hay permisos (US26).
class RefreshMyTasksUseCase {
  final TaskRepository repository;

  const RefreshMyTasksUseCase({required this.repository});

  Future<void> execute() => repository.refreshMyTasks();
}
