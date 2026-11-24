import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

/// Texto del medio de pago; `null` (medio que el backend envió y la app no conoce) es "Otro medio".
String paymentMethodLabel(AppLocalizations strings, PaymentMethod? method) => switch (method) {
  PaymentMethod.cash => strings.cashierMethodCash,
  PaymentMethod.creditCard => strings.cashierMethodCreditCard,
  PaymentMethod.debitCard => strings.cashierMethodDebitCard,
  PaymentMethod.bankTransfer => strings.cashierMethodBankTransfer,
  PaymentMethod.yape => strings.cashierMethodYape,
  PaymentMethod.plin => strings.cashierMethodPlin,
  null => strings.cashierMethodUnknown,
};

/// Errores propios de caja con su texto; el resto, el `message` del backend (AGENTS.md).
UiText toCashierText(Object error) {
  return switch (error) {
    InvalidCashierInputException(:final field) => UiText.resource(
      (s) => switch (field) {
        'lines' => s.cashierErrLines,
        'taxId' => s.cashierErrTaxId,
        'legalName' => s.cashierErrLegalName,
        'tenantName' || 'tenantLegalName' => s.cashierErrTenantName,
        'serie' => s.cashierErrSerie,
        'initialCorrelative' => s.cashierErrInitial,
        'amount' => s.cashierErrAmount,
        'transactionReference' => s.cashierErrReference,
        'status' => s.cashierErrStatus,
        'reason' => s.cashierErrReason,
        'customerId' => s.cashierErrCustomer,
        _ => s.cashierErrInput,
      },
    ),
    MissingFiscalSeriesException() => UiText.resource((s) => s.cashierErrNoSeries),
    PaymentOutcomeUnknownException() => UiText.resource((s) => s.cashierErrOutcomeUnknown),
    MissingBranchException() => UiText.resource((s) => s.cashierErrNoBranch),
    _ => toUiText(error),
  };
}
