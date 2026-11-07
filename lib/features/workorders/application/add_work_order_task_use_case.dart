import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

/// Agregar una tarea con servicio, mecánico (opcional, H11) y precio sin IGV (US12 E2, US22 E1).
/// Devuelve el detalle con los totales recalculados. En línea.
class AddWorkOrderTaskUseCase {
  final WorkOrderRepository repository;

  const AddWorkOrderTaskUseCase({required this.repository});

  Future<WorkOrderDetail> execute(WorkOrderId id, NewWorkOrderTask task) async {
    if (!WorkOrderValidation.isRequiredText(
      task.description,
      WorkOrderValidation.taskDescriptionMax,
    )) {
      throw const InvalidWorkOrderInputException('description');
    }
    if (!WorkOrderValidation.isOptionalAmount(task.price)) {
      throw const InvalidWorkOrderInputException('price');
    }
    return repository.addTask(id, task);
  }
}
