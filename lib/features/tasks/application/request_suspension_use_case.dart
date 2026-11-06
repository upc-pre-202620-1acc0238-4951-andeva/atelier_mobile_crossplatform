import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_validation.dart';

/// Pedir la suspensión por una pieza defectuosa o faltante (US29 E1). En línea.
class RequestSuspensionUseCase {
  final TaskRepository repository;

  const RequestSuspensionUseCase({required this.repository});

  Future<TaskDetail> execute(
    TaskId id,
    String missingItemDescription, {
    String? inventoryItemId,
  }) {
    if (!TaskValidation.isMissingItem(missingItemDescription)) {
      throw const InvalidTaskInputException('missingItemDescription');
    }
    return repository.requestSuspension(
      id,
      missingItemDescription.trim(),
      inventoryItemId: inventoryItemId,
    );
  }
}
