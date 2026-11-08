import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Comprobantes completos de la orden, en línea; deja las cabeceras en la caché. Recargar con este
/// caso de uso tras `IssuedPendingDetails`.
class GetWorkOrderVouchersUseCase {
  final CashierRepository repository;

  const GetWorkOrderVouchersUseCase({required this.repository});

  Future<List<Voucher>> execute(String workOrderId) =>
      repository.refreshWorkOrderVouchers(workOrderId);
}
