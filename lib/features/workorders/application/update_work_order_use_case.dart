import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

/// Corregir kilometraje o diagnóstico (US12 E1). Es el paso que completa la orden que el backend crea
/// al llegar una cita con kilometraje 0 (H10). Lo que va en `null` no cambia. En línea.
class UpdateWorkOrderUseCase {
  final WorkOrderRepository repository;

  const UpdateWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute(
    WorkOrderId id, {
    int? mileageIn,
    String? diagnosticSummary,
  }) async {
    if (mileageIn != null && !WorkOrderValidation.isMileage(mileageIn)) {
      throw const InvalidWorkOrderInputException('mileageIn');
    }
    if (!WorkOrderValidation.isOptionalText(
      diagnosticSummary,
      WorkOrderValidation.diagnosticMax,
    )) {
      throw const InvalidWorkOrderInputException('diagnosticSummary');
    }
    return repository.update(
      id,
      mileageIn: mileageIn,
      diagnosticSummary: diagnosticSummary,
    );
  }
}
