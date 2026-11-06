import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_validation.dart';

/// Supervisor: corregir la cantidad de un repuesto imputado (US22 E2). En línea.
class UpdateTaskPartQuantityUseCase {
  final TaskRepository repository;

  const UpdateTaskPartQuantityUseCase({required this.repository});

  Future<TaskDetail> execute(
    TaskId id,
    String productId,
    double quantity,
  ) {
    if (!TaskValidation.isQuantity(quantity)) {
      throw const InvalidTaskInputException('quantity');
    }
    return repository.updatePartQuantity(id, productId, quantity);
  }
}
