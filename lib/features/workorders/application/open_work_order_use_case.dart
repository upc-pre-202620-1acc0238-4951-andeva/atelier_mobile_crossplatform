import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

/// Abrir la orden con kilometraje y síntomas en la sede de la sesión (US12 E1). 409 = el vehículo ya
/// tiene una orden abierta. Para una cita que llegó no se usa: el backend ya la crea (H10). En línea.
class OpenWorkOrderUseCase {
  final WorkOrderRepository repository;

  const OpenWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute(NewWorkOrder workOrder) async {
    if (!WorkOrderValidation.isMileage(workOrder.mileageIn)) {
      throw const InvalidWorkOrderInputException('mileageIn');
    }
    if (!WorkOrderValidation.isOptionalText(
      workOrder.diagnosticSummary,
      WorkOrderValidation.diagnosticMax,
    )) {
      throw const InvalidWorkOrderInputException('diagnosticSummary');
    }
    return repository.open(workOrder);
  }
}
