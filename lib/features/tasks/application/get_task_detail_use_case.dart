import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Consulta en línea el detalle completo de la tarea (`GET /tasks/{id}`).
class GetTaskDetailUseCase {
  final TaskRepository repository;

  const GetTaskDetailUseCase({required this.repository});

  Future<TaskDetail> execute(TaskId id) => repository.getDetail(id);
}
