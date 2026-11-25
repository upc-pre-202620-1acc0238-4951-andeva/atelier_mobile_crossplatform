import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Anula un comprobante electrónico mediante comunicación de baja (`invoicing:invoices:issue_sunat`).
/// Exige motivo obligatorio (1..250 caracteres); la ventana de 7 días calendario la valida el backend.
class VoidVoucherUseCase {
  final CashierRepository repository;

  const VoidVoucherUseCase({required this.repository});

  Future<Voucher> execute(String voucherId, String reason) {
    final trimmed = reason.trim();
    if (!CashierValidation.isValidReason(trimmed)) {
      throw const InvalidCashierInputException('reason');
    }
    return repository.voidVoucher(voucherId, trimmed);
  }
}
