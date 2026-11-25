import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:decimal/decimal.dart';

/// Formulario compartido para anular un comprobante electrónico (comunicación de baja).
class VoidForm {
  final String voucherId;
  final String voucherLabel;
  final String reason;

  const VoidForm({
    required this.voucherId,
    required this.voucherLabel,
    this.reason = '',
  });

  bool get reasonValid => CashierValidation.isValidReason(reason);
  bool get canSubmit => reasonValid;

  VoidForm copyWith({String? reason}) => VoidForm(
    voucherId: voucherId,
    voucherLabel: voucherLabel,
    reason: reason ?? this.reason,
  );
}

/// Formulario compartido para emitir una nota de crédito referenciando un comprobante vigente.
class CreditNoteForm {
  final String referenceVoucherId;
  final String referenceLabel;
  final Decimal maxAmount;
  final String? currency;
  final String reason;
  final String amount;
  final List<FiscalSeries> availableSeries;
  final String selectedSerie;

  const CreditNoteForm({
    required this.referenceVoucherId,
    required this.referenceLabel,
    required this.maxAmount,
    this.currency,
    this.reason = '',
    this.amount = '',
    this.availableSeries = const [],
    this.selectedSerie = '',
  });

  bool get reasonValid => CashierValidation.isValidReason(reason);

  bool get serieValid =>
      selectedSerie.isEmpty || CashierValidation.isCreditNoteSeries(selectedSerie);

  Decimal? get parsedAmount {
    final parsed = Decimal.tryParse(amount.trim().replaceAll(',', '.'));
    if (parsed == null) return null;
    return CashierValidation.isValidMoneyAmount(parsed, max: maxAmount) ? parsed : null;
  }

  bool get canSubmit => reasonValid && parsedAmount != null && serieValid;

  CreditNoteForm copyWith({
    String? reason,
    String? amount,
    List<FiscalSeries>? availableSeries,
    String? selectedSerie,
  }) => CreditNoteForm(
    referenceVoucherId: referenceVoucherId,
    referenceLabel: referenceLabel,
    maxAmount: maxAmount,
    currency: currency,
    reason: reason ?? this.reason,
    amount: amount ?? this.amount,
    availableSeries: availableSeries ?? this.availableSeries,
    selectedSerie: selectedSerie ?? this.selectedSerie,
  );
}
