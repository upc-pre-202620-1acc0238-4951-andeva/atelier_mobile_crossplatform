import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:decimal/decimal.dart';

/// Caja (US37, US38, US42). Todo en línea: dinero y documentos fiscales nunca se encolan (06 §2).
/// Solo las cabeceras de comprobantes quedan en la caché `vouchers`. Lo que pide sede lanza
/// `MissingBranchException` sin llamar.
abstract class CashierRepository {
  /// Emite con [serie] sin duplicar la venta de la orden, ni siquiera tras un timeout (H28).
  Future<IssueOutcome> issue(VoucherDraft draft, String serie);

  /// Comprobantes completos de la orden; deja sus cabeceras en la caché.
  Future<List<Voucher>> refreshWorkOrderVouchers(String workOrderId);

  Stream<List<VoucherSummary>> observeWorkOrderVouchers(String workOrderId);

  /// Nunca reintenta. Devuelve el comprobante releído; si no se sabe si el cobro entró, lanza
  /// `PaymentOutcomeUnknownException` (H28).
  Future<Voucher> registerPayment(
    String voucherId,
    Decimal amount,
    PaymentMethod method,
    String? transactionReference,
  );

  Future<List<Payment>> getVoucherPayments(String voucherId);

  /// [date] es un día de Lima (`yyyy-MM-dd`).
  Future<DailyCashSummary> getDailyCashSummary(String date);

  Future<List<FiscalSeries>> getBranchSeries();

  Future<FiscalSeries> configureSeries(
    VoucherType type,
    String serie,
    int? initialCorrelative,
  );

  Future<void> setSeriesActive(String id, bool active);
}
