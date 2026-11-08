import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

/// `ElectronicVoucherResource` (docs/api/invoicing.md). `voucherType` llega como código SUNAT.
class ElectronicVoucherDto {
  final String id;
  final String? branchId;
  final String? customerId;
  final String? workOrderId;
  final String? voucherType;
  final String? serie;
  final int? number;
  final Decimal? subtotal;
  final Decimal? igvAmount;
  final Decimal? totalAmount;
  final Decimal? paidAmount;
  final Decimal? pendingBalance;
  final String? currency;
  final String? status;
  final String? paymentStatus;
  final CustomerFiscalInfoDto? customerInfo;
  final String? pdfUrl;
  final String? xmlUrl;
  final String? cdrUrl;
  final String? sunatResponseCode;
  final String? sunatDescription;
  final List<VoucherLineDto> lines;
  final List<VoucherPaymentDto> payments;
  final String? issuedAt;

  const ElectronicVoucherDto({
    required this.id,
    this.branchId,
    this.customerId,
    this.workOrderId,
    this.voucherType,
    this.serie,
    this.number,
    this.subtotal,
    this.igvAmount,
    this.totalAmount,
    this.paidAmount,
    this.pendingBalance,
    this.currency,
    this.status,
    this.paymentStatus,
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

  factory ElectronicVoucherDto.fromJson(Map<String, dynamic> json) {
    final receipts = json['digitalReceipts'] as Map<String, dynamic>?;
    final sunat = json['sunatResponse'] as Map<String, dynamic>?;
    final info = json['customerInfo'] as Map<String, dynamic>?;
    return ElectronicVoucherDto(
      id: json['id'] as String,
      branchId: json['branchId'] as String?,
      customerId: json['customerId'] as String?,
      workOrderId: json['workOrderId'] as String?,
      voucherType: json['voucherType'] as String?,
      serie: json['serie'] as String?,
      number: (json['number'] as num?)?.toInt(),
      subtotal: decimalFromJson(json['subtotal']),
      igvAmount: decimalFromJson(json['igvAmount']),
      totalAmount: decimalFromJson(json['totalAmount']),
      paidAmount: decimalFromJson(json['paidAmount']),
      pendingBalance: decimalFromJson(json['pendingBalance']),
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      customerInfo: info == null ? null : CustomerFiscalInfoDto.fromJson(info),
      pdfUrl: receipts?['pdfUrl'] as String?,
      xmlUrl: receipts?['xmlUrl'] as String?,
      cdrUrl: receipts?['cdrUrl'] as String?,
      sunatResponseCode: sunat?['responseCode'] as String?,
      sunatDescription: sunat?['description'] as String?,
      lines: [
        for (final line in (json['lines'] as List?) ?? const [])
          VoucherLineDto.fromJson(line as Map<String, dynamic>),
      ],
      payments: [
        for (final payment in (json['payments'] as List?) ?? const [])
          VoucherPaymentDto.fromJson(payment as Map<String, dynamic>),
      ],
      issuedAt: json['issuedAt'] as String?,
    );
  }
}

class CustomerFiscalInfoDto {
  final String? documentType;
  final String? taxId;
  final String? legalName;
  final String? fiscalAddress;

  const CustomerFiscalInfoDto({
    this.documentType,
    this.taxId,
    this.legalName,
    this.fiscalAddress,
  });

  factory CustomerFiscalInfoDto.fromJson(Map<String, dynamic> json) {
    return CustomerFiscalInfoDto(
      documentType: json['documentType'] as String?,
      taxId: json['taxId'] as String?,
      legalName: json['legalName'] as String?,
      fiscalAddress: json['fiscalAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'documentType': documentType,
    'taxId': taxId,
    'legalName': legalName,
    'fiscalAddress': fiscalAddress,
  };
}

class VoucherLineDto {
  final String? id;
  final String? itemId;
  final String? itemType;
  final String? description;
  final Decimal? quantity;
  final Decimal? unitValue;
  final Decimal? unitPrice;
  final Decimal? igvAmount;
  final Decimal? totalLine;

  const VoucherLineDto({
    this.id,
    this.itemId,
    this.itemType,
    this.description,
    this.quantity,
    this.unitValue,
    this.unitPrice,
    this.igvAmount,
    this.totalLine,
  });

  factory VoucherLineDto.fromJson(Map<String, dynamic> json) {
    return VoucherLineDto(
      id: json['id'] as String?,
      itemId: json['itemId'] as String?,
      itemType: json['itemType'] as String?,
      description: json['description'] as String?,
      quantity: decimalFromJson(json['quantity']),
      unitValue: decimalFromJson(json['unitValue']),
      unitPrice: decimalFromJson(json['unitPrice']),
      igvAmount: decimalFromJson(json['igvAmount']),
      totalLine: decimalFromJson(json['totalLine']),
    );
  }
}

/// `VoucherPaymentResource`.
class VoucherPaymentDto {
  final String id;
  final String? voucherId;
  final Decimal? amount;
  final String? currency;
  final String? paymentMethod;
  final String? transactionReference;
  final String? status;
  final String? paidAt;

  const VoucherPaymentDto({
    required this.id,
    this.voucherId,
    this.amount,
    this.currency,
    this.paymentMethod,
    this.transactionReference,
    this.status,
    this.paidAt,
  });

  factory VoucherPaymentDto.fromJson(Map<String, dynamic> json) {
    return VoucherPaymentDto(
      id: json['id'] as String,
      voucherId: json['voucherId'] as String?,
      amount: decimalFromJson(json['amount']),
      currency: json['currency'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      transactionReference: json['transactionReference'] as String?,
      status: json['status'] as String?,
      paidAt: json['paidAt'] as String?,
    );
  }
}

/// `DailyReconciliationResource`.
class DailyReconciliationDto {
  final String? date;
  final Decimal? totalCollected;
  final String? currency;
  final int? paymentCount;
  final Map<String, Decimal?> breakdownByMethod;
  final List<VoucherPaymentDto> payments;

  const DailyReconciliationDto({
    this.date,
    this.totalCollected,
    this.currency,
    this.paymentCount,
    this.breakdownByMethod = const {},
    this.payments = const [],
  });

  factory DailyReconciliationDto.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['breakdownByMethod'] as Map?) ?? const {};
    return DailyReconciliationDto(
      date: json['date'] as String?,
      totalCollected: decimalFromJson(json['totalCollected']),
      currency: json['currency'] as String?,
      paymentCount: (json['paymentCount'] as num?)?.toInt(),
      breakdownByMethod: {
        for (final entry in breakdown.entries)
          entry.key as String: decimalFromJson(entry.value),
      },
      payments: [
        for (final payment in (json['payments'] as List?) ?? const [])
          VoucherPaymentDto.fromJson(payment as Map<String, dynamic>),
      ],
    );
  }
}

/// `SeriesConfigurationResource`.
class SeriesConfigurationDto {
  final String id;
  final String? branchId;
  final String? voucherType;
  final String? serie;
  final int? currentCorrelative;
  final bool? active;

  const SeriesConfigurationDto({
    required this.id,
    this.branchId,
    this.voucherType,
    this.serie,
    this.currentCorrelative,
    this.active,
  });

  factory SeriesConfigurationDto.fromJson(Map<String, dynamic> json) {
    return SeriesConfigurationDto(
      id: json['id'] as String,
      branchId: json['branchId'] as String?,
      voucherType: json['voucherType'] as String?,
      serie: json['serie'] as String?,
      currentCorrelative: (json['currentCorrelative'] as num?)?.toInt(),
      active: json['active'] as bool?,
    );
  }
}

/// `IssueVoucherRequest`: el precio unitario va con IGV y `voucherType` como código (`01|03`).
class IssueVoucherRequestDto {
  final String branchId;
  final String currency;
  final String customerId;
  final CustomerFiscalInfoDto customerInfo;
  final List<VoucherLineRequestDto> lines;
  final String serie;
  final String voucherType;
  final String? workOrderId;

  const IssueVoucherRequestDto({
    required this.branchId,
    required this.currency,
    required this.customerId,
    required this.customerInfo,
    required this.lines,
    required this.serie,
    required this.voucherType,
    this.workOrderId,
  });

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'currency': currency,
    'customerId': customerId,
    'customerInfo': customerInfo.toJson(),
    'lines': [for (final line in lines) line.toJson()],
    'serie': serie,
    'voucherType': voucherType,
    'workOrderId': workOrderId,
  };
}

class VoucherLineRequestDto {
  final String description;
  final String itemType;
  final Decimal quantity;
  final Decimal unitPriceWithIgv;
  final String? itemId;

  const VoucherLineRequestDto({
    required this.description,
    required this.itemType,
    required this.quantity,
    required this.unitPriceWithIgv,
    this.itemId,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'itemType': itemType,
    'quantity': quantity.toDouble(),
    'unitPriceWithIgv': unitPriceWithIgv.toDouble(),
    'itemId': itemId,
  };
}

/// `RegisterPaymentRequest`.
class RegisterPaymentRequestDto {
  final Decimal amount;
  final String branchId;
  final String currency;
  final String paymentMethod;
  final String voucherId;
  final String? transactionReference;

  const RegisterPaymentRequestDto({
    required this.amount,
    required this.branchId,
    required this.currency,
    required this.paymentMethod,
    required this.voucherId,
    this.transactionReference,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount.toDouble(),
    'branchId': branchId,
    'currency': currency,
    'paymentMethod': paymentMethod,
    'voucherId': voucherId,
    'transactionReference': transactionReference,
  };
}

/// `ConfigureSeriesRequest`.
class ConfigureSeriesRequestDto {
  final String branchId;
  final String serie;
  final String voucherType;
  final int? initialCorrelative;

  const ConfigureSeriesRequestDto({
    required this.branchId,
    required this.serie,
    required this.voucherType,
    this.initialCorrelative,
  });

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'serie': serie,
    'voucherType': voucherType,
    'initialCorrelative': initialCorrelative,
  };
}
