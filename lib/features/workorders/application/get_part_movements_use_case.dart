import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Auditoría de repuestos de la orden (US33 E2). En línea.
class GetPartMovementsUseCase {
  final WorkOrderRepository repository;

  const GetPartMovementsUseCase({required this.repository});

  Future<List<PartMovement>> execute(WorkOrderId id) {
    return repository.getPartMovements(id);
  }
}
