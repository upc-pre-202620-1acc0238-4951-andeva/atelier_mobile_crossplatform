import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';

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

String voucherTypeLabel(AppLocalizations strings, VoucherType? type) => switch (type) {
  VoucherType.factura => strings.cashierTypeFactura,
  VoucherType.boleta => strings.cashierTypeBoleta,
  VoucherType.notaCredito => strings.cashierTypeCreditNote,
  null => strings.cashierTypeUnknown,
};

String fiscalDocumentTypeLabel(AppLocalizations strings, FiscalDocumentType? type) => switch (type) {
  FiscalDocumentType.ruc => strings.cashierDocRuc,
  FiscalDocumentType.dni => strings.cashierDocDni,
  FiscalDocumentType.ce => strings.cashierDocCe,
  FiscalDocumentType.pasaporte => strings.cashierDocPassport,
  null => strings.cashierTypeUnknown,
};

/// Texto y tipo de marca del estado fiscal del comprobante.
(String, ChipKind) voucherStatusChip(AppLocalizations strings, VoucherStatus? status) =>
    switch (status) {
      VoucherStatus.draft => (strings.cashierVstatusDraft, ChipKind.idle),
      VoucherStatus.issued => (strings.cashierVstatusIssued, ChipKind.info),
      VoucherStatus.acceptedSunat => (strings.cashierVstatusAccepted, ChipKind.ok),
      VoucherStatus.rejectedSunat => (strings.cashierVstatusRejected, ChipKind.bad),
      VoucherStatus.voided => (strings.cashierVstatusVoided, ChipKind.bad),
      null => (strings.cashierVstatusUnknown, ChipKind.idle),
    };

/// Texto y tipo de marca del estado de cobro del comprobante.
(String, ChipKind) voucherPaymentStatusChip(
  AppLocalizations strings,
  VoucherPaymentStatus? status,
) => switch (status) {
  VoucherPaymentStatus.paid => (strings.cashierPstatusPaid, ChipKind.ok),
  VoucherPaymentStatus.partial => (strings.cashierPstatusPartial, ChipKind.info),
  VoucherPaymentStatus.pending || null => (strings.cashierPstatusPending, ChipKind.idle),
};

/// `B001-00000045` con correlativo a 8 dígitos.
String formatVoucherCode(String serie, int number) =>
    '$serie-${number.toString().padLeft(8, '0')}';

/// Importe con símbolo; acepta la moneda como la envió el backend (PEN si falta o no es USD).
String formatCashierAmount(Decimal amount, String? currency) {
  final money = Money(
    amount: amount.abs(),
    currency: currency == Money.usd ? Money.usd : Money.pen,
  ).format();
  return amount < Decimal.zero ? '−$money' : money;
}

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
