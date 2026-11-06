import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_validation.dart';
import 'package:decimal/decimal.dart';

/// Cierre técnico con horas hombre en decimal (US30 E1). En línea.
class CompleteTaskUseCase {
  final TaskRepository repository;

  const CompleteTaskUseCase({required this.repository});

  Future<TaskDetail> execute(
    TaskId id,
    Decimal actualLaborHours, {
    String? notes,
  }) {
    if (!TaskValidation.isLaborHours(actualLaborHours)) {
      throw const InvalidTaskInputException('actualLaborHours');
    }
    if (!TaskValidation.isNotes(notes)) {
      throw const InvalidTaskInputException('notes');
    }
    return repository.complete(
      id,
      actualLaborHours,
      notes: notes?.trim().isEmpty ?? true ? null : notes!.trim(),
    );
  }
}
