import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Rentabilidad de la orden (US35 E2). En línea.
class GetProfitabilityUseCase {
  final WorkOrderRepository repository;

  const GetProfitabilityUseCase({required this.repository});

  Future<Profitability> execute(WorkOrderId id) {
    return repository.getProfitability(id);
  }
}
