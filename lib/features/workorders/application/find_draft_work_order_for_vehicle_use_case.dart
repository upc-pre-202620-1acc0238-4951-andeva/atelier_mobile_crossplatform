import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Vuelve a buscar la orden en borrador tras una llegada cuya orden aún no aparecía (H10). En línea.
class FindDraftWorkOrderForVehicleUseCase {
  final WorkOrderRepository repository;

  const FindDraftWorkOrderForVehicleUseCase({required this.repository});

  Future<WorkOrder?> execute(String branchId, String vehicleId) {
    return repository.findDraftForVehicle(branchId, vehicleId);
  }
}
