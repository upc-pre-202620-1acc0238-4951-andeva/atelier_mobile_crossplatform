import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// US38: historial de cobros del comprobante, en línea.
class GetVoucherPaymentsUseCase {
  final CashierRepository repository;

  const GetVoucherPaymentsUseCase({required this.repository});

  Future<List<Payment>> execute(String voucherId) =>
      repository.getVoucherPayments(voucherId);
}
