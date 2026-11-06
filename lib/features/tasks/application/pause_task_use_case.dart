import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Pausar por refrigerio o fin de turno (US27 E2, E3). En línea.
class PauseTaskUseCase {
  final TaskRepository repository;

  const PauseTaskUseCase({required this.repository});

  Future<TaskDetail> execute(TaskId id, PauseReason reason) =>
      repository.pause(id, reason);
}
