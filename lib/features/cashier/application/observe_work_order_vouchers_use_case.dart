import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Cabeceras en caché, sin red. Para el detalle, `GetWorkOrderVouchersUseCase`.
class ObserveWorkOrderVouchersUseCase {
  final CashierRepository repository;

  const ObserveWorkOrderVouchersUseCase({required this.repository});

  Stream<List<VoucherSummary>> execute(String workOrderId) =>
      repository.observeWorkOrderVouchers(workOrderId);
}
