import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// `VoucherType` de docs/api/README.md §8: viaja como código SUNAT, no como nombre.
enum VoucherType {
  factura('01'),
  boleta('03'),
  notaCredito('07');

  final String code;
  const VoucherType(this.code);

  /// Acepta el código (`"01"`) o el nombre (`"FACTURA"`, sin importar mayúsculas).
  static VoucherType? fromApi(String? raw) {
    if (raw == null) return null;
    for (final type in values) {
      if (type.code == raw) return type;
    }
    return switch (raw.toUpperCase()) {
      'FACTURA' => factura,
      'BOLETA' => boleta,
      'NOTA_CREDITO' => notaCredito,
      _ => null,
    };
  }
}

enum VoucherStatus {
  draft('DRAFT'),
  issued('ISSUED'),
  acceptedSunat('ACCEPTED_SUNAT'),
  rejectedSunat('REJECTED_SUNAT'),
  voided('VOIDED');

  final String value;
  const VoucherStatus(this.value);

  static VoucherStatus? fromString(String? raw) =>
      _byValue(values, raw, (s) => s.value);
}

enum VoucherPaymentStatus {
  pending('PENDING'),
  partial('PARTIAL'),
  paid('PAID');

  final String value;
  const VoucherPaymentStatus(this.value);

  static VoucherPaymentStatus? fromString(String? raw) =>
      _byValue(values, raw, (s) => s.value);
}

enum PaymentMethod {
  cash('CASH'),
  creditCard('CREDIT_CARD'),
  debitCard('DEBIT_CARD'),
  bankTransfer('BANK_TRANSFER'),
  yape('DIGITAL_WALLET_YAPE'),
  plin('DIGITAL_WALLET_PLIN');

  final String value;
  const PaymentMethod(this.value);

  static PaymentMethod? fromString(String? raw) =>
      _byValue(values, raw, (m) => m.value);
}

enum FiscalDocumentType {
  dni('DNI'),
  ce('CE'),
  ruc('RUC'),
  pasaporte('PASAPORTE');

  final String value;
  const FiscalDocumentType(this.value);

  static FiscalDocumentType? fromString(String? raw) =>
      _byValue(values, raw, (d) => d.value);
}

enum VoucherItemType {
  product('PRODUCT'),
  service('SERVICE');

  final String value;
  const VoucherItemType(this.value);

  static VoucherItemType? fromString(String? raw) =>
      _byValue(values, raw, (t) => t.value);
}

T? _byValue<T>(List<T> values, String? raw, String Function(T) value) {
  for (final item in values) {
    if (value(item) == raw) return item;
  }
  return null;
}

/// Factura o boleta que no está anulada ni rechazada por SUNAT. Un estado nulo o desconocido cuenta
/// como vigente: ante la duda no se emite otra (H28). Una nota de crédito nunca cuenta.
bool isActiveSale(VoucherType? type, VoucherStatus? status) {
  return (type == VoucherType.factura || type == VoucherType.boleta) &&
      status != VoucherStatus.voided &&
      status != VoucherStatus.rejectedSunat;
}

class CustomerFiscalInfo {
  final FiscalDocumentType? documentType;
  final String taxId;
  final String legalName;
  final String? fiscalAddress;

  const CustomerFiscalInfo({
    this.documentType,
    required this.taxId,
    required this.legalName,
    this.fiscalAddress,
  });
}

/// Línea emitida (`VoucherLineResource`); el precio unitario incluye IGV.
class VoucherLine {
  final String? id;
  final String? itemId;
  final VoucherItemType? itemType;
  final String description;
  final Decimal quantity;
  final Decimal? unitValue;
  final Decimal? unitPrice;
  final Decimal? igvAmount;
  final Decimal? totalLine;

  const VoucherLine({
    this.id,
    this.itemId,
    this.itemType,
    required this.description,
    required this.quantity,
    this.unitValue,
    this.unitPrice,
    this.igvAmount,
    this.totalLine,
  });
}

class Payment {
  final String id;
  final String? voucherId;
  final Money amount;
  final PaymentMethod? method;
  final String? transactionReference;
  final String? status;
  final DateTime? paidAt;

  const Payment({
    required this.id,
    this.voucherId,
    required this.amount,
    this.method,
    this.transactionReference,
    this.status,
    this.paidAt,
  });
}

/// Comprobante completo, leído en línea. Los montos van en PEN si el backend envía una moneda
/// desconocida; [currency] guarda la original, y cobrar no la reemplaza.
class Voucher {
  final String id;
  final String? branchId;
  final String? customerId;
  final String? workOrderId;
  final VoucherType? type;
  final String serie;
  final int number;
  final String? currency;
  final Money subtotal;
  final Money igvAmount;
  final Money totalAmount;
  final Money paidAmount;
  final Money pendingBalance;
  final VoucherPaymentStatus? paymentStatus;
  final VoucherStatus? status;
  final CustomerFiscalInfo? customerInfo;
  final String? pdfUrl;
  final String? xmlUrl;
  final String? cdrUrl;
  final String? sunatResponseCode;
  final String? sunatDescription;
  final List<VoucherLine> lines;
  final List<Payment> payments;
  final DateTime? issuedAt;

  const Voucher({
    required this.id,
    this.branchId,
    this.customerId,
    this.workOrderId,
    this.type,
    required this.serie,
    required this.number,
    this.currency,
    required this.subtotal,
    required this.igvAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingBalance,
    this.paymentStatus,
    this.status,
    this.customerInfo,
    this.pdfUrl,
    this.xmlUrl,
    this.cdrUrl,
    this.sunatResponseCode,
    this.sunatDescription,
    this.lines = const [],
    this.payments = const [],
    this.issuedAt,
  });

  bool get activeSale => isActiveSale(type, status);
}

/// Cabecera en la caché `vouchers`: sin moneda, líneas ni cobros.
class VoucherSummary {
  final String id;
  final String? workOrderId;
  final VoucherType? type;
  final String serie;
  final int number;
  final Decimal totalAmount;
  final Decimal paidAmount;
  final Decimal pendingBalance;
  final VoucherPaymentStatus? paymentStatus;
  final VoucherStatus? status;
  final String? pdfUrl;

  const VoucherSummary({
    required this.id,
    this.workOrderId,
    this.type,
    required this.serie,
    required this.number,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingBalance,
    this.paymentStatus,
    this.status,
    this.pdfUrl,
  });

  bool get activeSale => isActiveSale(type, status);
}

class FiscalSeries {
  final String id;
  final String? branchId;
  final VoucherType? type;
  final String serie;
  final int currentCorrelative;
  final bool active;

  const FiscalSeries({
    required this.id,
    this.branchId,
    this.type,
    required this.serie,
    required this.currentCorrelative,
    required this.active,
  });
}

/// Caja de una sede en un día de Lima (US38). Los medios desconocidos no entran en [byMethod].
class DailyCashSummary {
  final String date;
  final Money totalCollected;
  final int paymentCount;
  final Map<PaymentMethod, Money> byMethod;
  final List<Payment> payments;

  const DailyCashSummary({
    required this.date,
    required this.totalCollected,
    required this.paymentCount,
    required this.byMethod,
    required this.payments,
  });
}

/// Resultado de emitir (H28). [voucherId] siempre está.
sealed class IssueOutcome {
  String get voucherId;
}

class Issued extends IssueOutcome {
  final Voucher voucher;

  Issued(this.voucher);

  @override
  String get voucherId => voucher.id;
}

/// La orden ya tenía una factura o boleta vigente: no se emitió otra.
class AlreadyIssued extends IssueOutcome {
  final Voucher voucher;

  AlreadyIssued(this.voucher);

  @override
  String get voucherId => voucher.id;
}

/// Se emitió, pero la respuesta no se pudo leer: recargar con `GetWorkOrderVouchersUseCase`.
class IssuedPendingDetails extends IssueOutcome {
  @override
  final String voucherId;

  IssuedPendingDetails(this.voucherId);
}
