import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:decimal/decimal.dart';

/// Emite una nota de crédito electrónica referenciando un comprobante vigente
/// (`invoicing:invoices:issue_sunat`).
class IssueCreditNoteUseCase {
  final CashierRepository repository;

  const IssueCreditNoteUseCase({required this.repository});

  Future<Voucher> execute({
    required String referenceVoucherId,
    required String reason,
    required Decimal amount,
    String? serieOverride,
  }) async {
    final trimmedReason = reason.trim();
    if (!CashierValidation.isValidReason(trimmedReason)) {
      throw const InvalidCashierInputException('reason');
    }
    if (!CashierValidation.isValidMoneyAmount(amount)) {
      throw const InvalidCashierInputException('amount');
    }

    final reference = await repository.getVoucher(referenceVoucherId);
    if (!reference.activeSale || reference.status == VoucherStatus.draft) {
      throw const InvalidCashierInputException('status');
    }
    if (amount > reference.totalAmount.amount) {
      throw const InvalidCashierInputException('amount');
    }
    if (reference.customerId == null) {
      throw const InvalidCashierInputException('customerId');
    }

    final String resolvedSerie;
    final cleanOverride = serieOverride?.trim();
    if (cleanOverride != null && cleanOverride.isNotEmpty) {
      resolvedSerie = cleanOverride.toUpperCase();
    } else {
      final series = await repository.getBranchSeries();
      final creditNoteSeries = series
          .where((s) => s.active && s.type == VoucherType.notaCredito)
          .toList();
      final preferredPrefix = switch (reference.type) {
        VoucherType.factura => 'F',
        VoucherType.boleta => 'B',
        _ => null,
      };
      final activeSeries =
          creditNoteSeries
              .where(
                (s) =>
                    preferredPrefix != null &&
                    s.serie.toUpperCase().startsWith(preferredPrefix),
              )
              .firstOrNull ??
          creditNoteSeries.firstOrNull;
      if (activeSeries == null) {
        throw const MissingFiscalSeriesException();
      }
      resolvedSerie = activeSeries.serie;
    }

    return repository.issueCreditNote(
      referenceVoucher: reference,
      serie: resolvedSerie,
      reason: trimmedReason,
      amount: amount,
    );
  }
}
