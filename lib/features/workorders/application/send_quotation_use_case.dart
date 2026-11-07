import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Envía la proforma al cliente (US24). Devuelve el correo al que se envió. En línea.
class SendQuotationUseCase {
  final WorkOrderRepository repository;

  const SendQuotationUseCase({required this.repository});

  Future<String> execute(WorkOrderId id) {
    return repository.sendQuotation(id);
  }
}
