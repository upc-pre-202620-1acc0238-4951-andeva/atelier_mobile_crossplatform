import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Lista los comprobantes electrónicos emitidos de la sede (`invoicing:invoices:read`).
class GetVouchersUseCase {
  final CashierRepository repository;

  const GetVouchersUseCase({required this.repository});

  Future<List<Voucher>> execute({
    VoucherType? type,
    VoucherStatus? status,
    String? from,
    String? to,
  }) => repository.getVouchers(type: type, status: status, from: from, to: to);
}
