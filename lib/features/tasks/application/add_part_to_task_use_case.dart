import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_validation.dart';

/// Imputar un repuesto con el precio de catálogo (US23 E1/E3, US35 E1). En línea.
class AddPartToTaskUseCase {
  final TaskRepository repository;

  const AddPartToTaskUseCase({required this.repository});

  Future<TaskProduct> execute(TaskId id, String productId, double quantity) {
    if (!TaskValidation.isQuantity(quantity)) {
      throw const InvalidTaskInputException('quantity');
    }
    return repository.addPart(id, productId, quantity);
  }
}
