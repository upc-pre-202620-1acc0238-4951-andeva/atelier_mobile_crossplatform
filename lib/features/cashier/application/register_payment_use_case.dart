import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:decimal/decimal.dart';

/// US38 E1/E2 (`invoicing:payments:create`). Si el comprobante queda `PAID` recarga la orden; ese
/// fallo no cambia el cobro. `PaymentOutcomeUnknownException`: no cobrar de nuevo sin ver el
/// historial (H28).
class RegisterPaymentUseCase {
  final CashierRepository repository;
  final WorkOrderRepository workOrders;

  const RegisterPaymentUseCase({
    required this.repository,
    required this.workOrders,
  });

  Future<Voucher> execute(
    String voucherId,
    Decimal amount,
    PaymentMethod method, {
    String? transactionReference,
  }) async {
    final voucher = await repository.registerPayment(
      voucherId,
      amount,
      method,
      transactionReference,
    );
    final workOrderId = voucher.workOrderId;
    if (voucher.paymentStatus == VoucherPaymentStatus.paid &&
        workOrderId != null) {
      try {
        await workOrders.getDetail(WorkOrderId(workOrderId));
      } catch (_) {}
    }
    return voucher;
  }
}
