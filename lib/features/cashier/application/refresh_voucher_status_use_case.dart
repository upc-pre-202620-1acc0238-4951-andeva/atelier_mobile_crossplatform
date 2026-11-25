import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Consulta y refresca el estado fiscal de un comprobante ante SUNAT (`GET /invoicing/vouchers/{id}`).
class RefreshVoucherStatusUseCase {
  final CashierRepository repository;

  const RefreshVoucherStatusUseCase({required this.repository});

  Future<Voucher> execute(String voucherId) => repository.getVoucher(voucherId);
}
